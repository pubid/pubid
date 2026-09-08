# frozen_string_literal: true

module Pubid
  module Iec
    # Generates IEC URNs in the positional format used as ground truth by
    # relaton-data-iec:
    #
    #   urn:iec:std:{authority}:{number}[-{part}[-{subpart}]]
    #       :{date}:{stage-or-type}:{deliverable}:{language}{adjuncts}
    #
    # e.g. +urn:iec:std:iec:60050-102:2007:::+. Absent trailing slots are
    # emitted as empty fields. The all-parts series URN is the one exception:
    # a bare series omits the language slot (8 fields).
    #
    # This used to be a port of relaton-iec's +code_to_urn+, which regex-scraped
    # +identifier.to_s+. Three defects followed from reading the printed form:
    # the stage was folded into the authority slot (+urn:iec:std:iec-np:...+),
    # the edition was never emitted, and the regex was unanchored, so any type
    # token outside its hard-coded list consumed the publisher instead
    # (+IEC/DTS 62271-1+ became +urn:iec:std:dts:62271-1::::+, and every
    # +IECEE TRF ...+ keyed +urn:iec:std:trf:...+). The generator now reads the
    # identifier's own components. The slot ORDER is unchanged, because the
    # published corpus uses it. See issue #360 item 4.
    class UrnGenerator < Pubid::UrnGenerator::Base
      URN_CONTEXT = Rendering::RenderingContext.urn.freeze
      private_constant :URN_CONTEXT

      # Type codes that occupy the type slot. `is` and `trf` render empty
      # there, as they always have. `tec` and `wp` never appear in the corpus
      # but the legacy grammar accepted them, so they stay recognised.
      TYPE_SLOT_CODES = %w[tr ts pas srd guide tec wp].freeze

      # Deliverable markers occupying the deliverable slot. "ser" reaches this
      # list as a spelled-out VAP code ("IEC 60034:2026 SER"), which is not the
      # same thing as the `all_parts` series form handled below.
      DELIVERABLES = %w[cmv csv exv prv rlv ser].freeze

      # Supplement classes that contribute an adjunct, and the token each one
      # writes into it.
      ADJUNCT_TOKENS = {
        "Amendment" => "amd",
        "Corrigendum" => "cor",
        "InterpretationSheet" => "ish",
      }.freeze

      def generate
        doc = document
        return nil if doc.nil?

        num = number_segment(doc)
        return nil if num.nil? || num.empty?

        slots = ["urn", "iec", "std", authority(doc), num,
                 date_slot(doc), stage_or_type_slot(doc), deliverable_slot]
        adjuncts = adjunct_slots(identifier)
        language = language_slot
        slots << language unless bare_series?(slots, adjuncts, language)

        (slots + adjuncts).join(":").downcase
      end

      private

      # The document the URN names: the origin standard, with every amendment,
      # corrigendum, consolidation, VAP and fragment layer peeled off. Those
      # layers are what the adjunct and deliverable slots record.
      #
      # A CISPR test report form carries no number of its own — the document it
      # reports on sits in `cispr_identifier`, and that is what the URN has
      # always named.
      def document
        doc = identifier.respond_to?(:root) ? identifier.root : identifier
        return doc if doc.nil? || number_segment(doc)

        maybe_of(doc, :cispr_identifier) || doc
      end

      # A publisher body may carry a space ("IEC CA", "IECQ CS", "IECQ OD").
      # The published corpus records only the last token for those
      # (+urn:iec:std:ca:01:2017:::+), which is what the old whitespace-
      # splitting regex produced. Keeping that spelling is what keeps those
      # rows byte-identical; correcting it to "iec-ca" would need a data
      # migration first.
      def authority(doc)
        publishers = [doc.publisher] + Array(doc.copublishers)
        publishers.compact.map { |p| p.body.to_s.split(/\s+/).last.to_s }
          .reject(&:empty?).join("-")
      end

      def number_segment(doc)
        return nil unless doc.respond_to?(:number) && doc.number

        segment = [doc.number, maybe_of(doc, :part), maybe_of(doc, :subpart)]
          .compact.map(&:to_s).reject(&:empty?).join("-")
        return nil if segment.empty?

        # A few document numbers are multi-word ("DIR 1 IEC SUP"). A URN
        # carries no spaces, so they become hyphens.
        segment.gsub(/\s+/, "-")
      end

      # `Components::Date#render` under a URN context deliberately drops the
      # month, which is the ISO convention. IEC keeps the precision it was
      # given ("IEC CA 01:2025-10" keys ...:2025-10:...), so this reads the
      # printed form.
      def date_slot(doc)
        maybe_of(doc, :date).to_s
      end

      # The stage slot and the type slot are the same slot, and a draft of a
      # typed document has both. Both are kept, type first
      # ("ts-stage-50.00"), because the harmonized codes are shared across
      # types: dropping the type would make a draft TS, a draft TR and a draft
      # International Standard collide, and `parse_urn` would resolve every one
      # of them to an International Standard.
      def stage_or_type_slot(doc)
        type = type_token(doc)
        stage = stage_token(doc)

        return type if stage.nil?

        [type, stage].reject { |t| t.nil? || t.empty? }.join("-")
      end

      def type_token(doc)
        ts = maybe_of(doc, :typed_stage)
        code = ts&.type_code.to_s.downcase
        TYPE_SLOT_CODES.include?(code) ? code : ""
      end

      # nil when the document is published (or carries no stage at all), so the
      # slot keeps holding the bare type token for every published row.
      def stage_token(doc)
        stage = maybe_of(doc, :typed_stage)&.to_stage || maybe_of(doc, :stage)
        harmonized = stage&.harmonized_stages&.first.to_s
        return nil if harmonized.empty?
        return nil if published_stage?(stage)

        "stage-#{harmonized}"
      end

      def published_stage?(stage)
        stage.stage_code.to_s == "published"
      end

      # A deliverable code owns the slot; the edition takes it only when there
      # is none.
      def deliverable_slot
        return "ser" if maybe_of(identifier, :all_parts)

        vap = vap_codes
        return vap unless vap.empty?

        edition = maybe_of(identifier, :edition)
        return "" unless edition&.number

        edition.render(context: URN_CONTEXT).to_s
      end

      # A deliverable sits on the VAP layer, which is not always the outermost
      # one: "IEC 60079-10-1:2020 CMV/COR1:2021" is a corrigendum wrapping the
      # CMV, so the codes have to be looked for down the chain.
      def vap_codes
        codes = find_down(:vap)
        return "" unless codes

        Array(codes).map { |c| c.to_s.downcase }
          .select { |c| DELIVERABLES.include?(c) }.join("-")
      end

      # First non-empty value of `attribute` from the outermost identifier
      # inwards.
      def find_down(attribute)
        id = identifier
        while id
          value = maybe_of(id, attribute)
          return value unless value.nil? ||
            (value.respond_to?(:empty?) && value.empty?)

          id = maybe_of(id, :base) ||
            Array(maybe_of(id, :identifiers)).first
        end
        nil
      end

      def language_slot
        langs = maybe_of(identifier, :languages)
        return "" unless langs&.any?

        langs.map { |l| l.code.to_s }.join("-")
      end

      # A bare, undated, stage- and language-less all-parts series drops the
      # trailing empty language slot, matching the canonical relaton-data-iec
      # form urn:iec:std:iec:80000:::ser. A dated series, or one carrying a
      # stage, keeps the slot.
      def bare_series?(slots, adjuncts, language)
        slots.last == "ser" && slots[5, 2].all? { |s| s.to_s.empty? } &&
          adjuncts.empty? && language.empty?
      end

      # Walks the identifier tree for the amendment / corrigendum /
      # interpretation-sheet layers, innermost first. A member of a
      # consolidated identifier carries the "plus" relation marker, which the
      # printed form spells "+".
      def adjunct_slots(id)
        return [] if id.nil?

        case id.class.name.split("::").last
        when "ConsolidatedIdentifier"
          members = Array(id.identifiers)
          adjunct_slots(members.first) +
            members.drop(1).flat_map { |m| adjunct_fields(m, plus: true) }
        when *ADJUNCT_TOKENS.keys
          adjunct_slots(id.base) + adjunct_fields(id, plus: false)
        else
          adjunct_slots(id.respond_to?(:base) ? id.base : nil)
        end
      end

      def adjunct_fields(id, plus:)
        token = ADJUNCT_TOKENS[id.class.name.split("::").last]
        return adjunct_slots(id.respond_to?(:base) ? id.base : nil) unless token

        [plus ? "plus" : "", token, id.number.to_s,
         maybe_of(id, :date)&.render(context: URN_CONTEXT).to_s]
      end

      # Not every IEC class declares every attribute, and a wrapper may not
      # declare one its base does. The `respond_to?` guard covers the missing
      # attribute; the rescue covers an attribute that exists but nil-chases
      # while resolving — `SupplementIdentifier#number` runs `ensure_base` and
      # reads through a base that may not be built yet. It is deliberately
      # narrow: a broader rescue would swallow a real bug into a silently
      # empty URN slot instead of failing loudly.
      def maybe_of(id, attribute)
        return nil unless id.respond_to?(attribute)

        id.public_send(attribute)
      rescue NoMethodError
        nil
      end
    end
  end
end
