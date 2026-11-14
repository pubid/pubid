# frozen_string_literal: true

module Pubid
  module Iec
    # Identifier that represents a supplement to a base identifier.
    class SupplementIdentifier < SingleIdentifier
      # The supplement number a legacy standalone face implies when its
      # type token carries none ("IEC/DCOR 60038-1" is Corrigendum 1 of
      # 60038-1); the owner's no-number rule.
      LEGACY_STANDALONE_SUPPLEMENT_NUMBER = "1"

      attribute :base, Identifier, polymorphic: true

      # Serialize the supplemented document under "base". The supplement's own
      # number/date/stage come from the inherited common maps; route the nested
      # base hash back through Identifier.from_hash so its concrete subclass (and
      # any further nesting) is reconstructed.
      key_value do
        map "base", with: { to: :base_to_kv, from: :base_from_kv }
      end

      def base_to_kv(model, doc)
        base = model.base
        return unless base

        # `base` synthesises a base for a supplement that has none
        # (e.g. a bare "+AMD1:2008" nested in a consolidation): a fake doc whose
        # number equals the supplement's own. It renders nothing and the getter
        # recreates it identically on load, so don't persist it. A standalone
        # supplement in the legacy prefix face ("IEC/DCOR 60038-1") instead
        # holds the real base designation (base.number != own number), which
        # must be kept.
        return if model.synthetic_base? && base.number.to_s == model.number.to_s

        doc.add_child(Lutaml::KeyValue::DataModel::Element.new("base",
                                                              base.to_hash))
      end

      def base_from_kv(model, value)
        return unless value

        # A bare SingleIdentifier here is the synthetic base of a standalone
        # supplement; #synthetic_base? reads that class, so nothing else needs
        # restoring. "number" already holds the supplement number, which is
        # what ensure_base stores on the parse path too.
        model.base = ::Pubid::Iec::Identifier.from_hash(value)
      end

      # Override base getter to ensure it's always created for standalone supplements
      def base
        @base || ensure_base
      end

      # A standalone supplement written in the legacy prefix face holds the
      # grammar's layout (the whole base designation on itself) until
      # #ensure_base moves it. Not every construction path goes through one
      # builder branch ("IEC DCOR 60038-1" reaches the typed branch, a
      # hand-built Amendment none), so these readers make the move before
      # they answer: the result never depends on which reader ran first, and
      # #exclude, which copies through the readers, copies the moved layout.
      # They only TRIGGER the move; they return the stored value.
      def number
        settle_standalone_layout
        super
      end

      def part
        settle_standalone_layout
        super
      end

      # Delegate publisher and copublishers to base whenever there is
      # a base (a supplement carries the publisher of the document it
      # supplements). Checking base first — rather than `@publisher || base` — is
      # required now that the publisher attribute has an IEC default, which would
      # otherwise mask the delegation.
      def publisher
        return @publisher if @ensuring_base

        base ? base.publisher : @publisher
      end

      def copublishers
        return @copublishers if @ensuring_base

        base ? base.copublishers : @copublishers
      end

      # Synthesise the base of a supplement that names none, and return it.
      #
      # A standalone supplement written in the legacy prefix face ("IEC/DCOR
      # 60038-1", "IEC/DISH 60038-1") arrives from the grammar with the BASE
      # designation stored on itself — the base number in `number`, the base
      # part (and subpart) in `part`/`subpart`. That layout is the grammar's
      # bound shape, not the identity: the face names a supplement OF that
      # designation, so the designation moves WHOLE onto a concrete
      # InternationalStandard base (publisher, copublishers and the date go
      # with it — old notation prints the base's year, and a draft
      # supplement carries no publication date of its own) and the
      # supplement keeps a number of its own, defaulting to 1 — the
      # no-number rule (an unnumbered draft face means
      # Amendment/Corrigendum/Interpretation-Sheet 1; owner ruling
      # 2026-11-12, reversing #693's part-to-number move, which stole the
      # base's part for the supplement). The concrete base is what makes the
      # decode hash-match (and equal) the modern on-base parse of the same
      # document: `parse("IEC/DCOR 60038-1") == parse("IEC 60038-1/DCOR 1")`.
      #
      # A supplement with no part (a true standalone like "IEC/AMD 1:2017",
      # or a bare "+AMD1:2008" in a consolidation) keeps its own number and
      # gets a synthetic self-base whose number equals it; its date stays
      # its own.
      #
      # The base deliberately gets NO typed_stage. A stage without a code is
      # not serialized, so `from_hash` cannot restore one, and a stage set
      # here alone made `parse != from_hash(to_hash)` — `==` compares `base`
      # (`lib/pubid/iec/CLAUDE.md`).
      def ensure_base
        return @base if @base

        # publisher/copublishers read through `base`; this guard makes them
        # read the supplement's own value while the base is being built.
        @ensuring_base = true
        return nil unless publisher && (@number || @part)

        if @part
          base = Identifiers::InternationalStandard.new
          base.publisher = publisher
          base.copublishers = copublishers if copublishers&.any?
          base.number = @number
          base.part = @part
          base.subpart = @subpart if @subpart
          base.date = date if date
          @number = LEGACY_STANDALONE_SUPPLEMENT_NUMBER
          @part = nil
          @date = nil
        else
          base = SingleIdentifier.new
          base.publisher = publisher
          base.number = @number if @number
          base.date = date if date
        end

        @base = base
      ensure
        @ensuring_base = false
      end

      # True when the base is the bare SingleIdentifier that #ensure_base (or
      # from_hash) synthesised for a standalone supplement; a real attached
      # base is always a concrete type (InternationalStandard, SheetIdentifier
      # …). Read from the base itself, so it survives #exclude, which copies
      # `base` into a new object. A legacy prefix face's designation moves
      # onto a CONCRETE InternationalStandard instead (see #ensure_base), so
      # it renders in the attached, modern form and hash-matches the modern
      # on-base parse of the same document.
      def synthetic_base?
        base.instance_of?(::Pubid::Iec::SingleIdentifier)
      end

      def to_s(**opts)
        render(format: :human, **opts)
      end

      # MR supplement suffix: `/{type}.{number}.{year}` (e.g. "/amd.1.2016").
      # The MrString renderer recurses into `base` and appends this so the
      # full supplement chain round-trips losslessly (issue #142).
      def mr_supplement_suffix
        segments = []
        segments << mr_type if mr_type
        segments << number&.to_s if number
        segments << date&.year&.to_s if date&.year
        return nil if segments.empty?

        segments.join(".")
      end

      private

      def settle_standalone_layout
        ensure_base if @base.nil? && @part && !@ensuring_base
      end
    end
  end
end
