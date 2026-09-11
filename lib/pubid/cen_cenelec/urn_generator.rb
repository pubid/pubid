# frozen_string_literal: true

module Pubid
  module CenCenelec
    class UrnGenerator < Pubid::UrnGenerator::Base
      def generate
        urn_for(identifier)
      end

      protected

      # The URN of +id+, walking the wrapper structure:
      #   EN 13250:2000/A1:2005    urn:cen:en:13250:2000:amd:1:2005
      #   EN 285:2015+A1:2021      urn:cen:en:285:2015:plus:amd:1:2021
      #   EN 60038 AMD1 FRAG2      urn:cen:en:60038:amd:1:frag:2
      #   CEN ISO/TS 21003-7:2019  urn:cen:cen:iso:ts:21003-7:2019
      #   ENV ISO 11079:1999       urn:cen:env:iso:11079:1999
      #   prEN ISO 1234:2020       urn:cen:en:iso:1234:2020:stage.proposal
      # The "plus" marker keeps a consolidated identifier apart from the
      # standalone amendment with the same number and year.
      def urn_for(id)
        case id
        when nil
          "urn:cen"
        when Identifiers::Amendment, Identifiers::Corrigendum,
             Identifiers::Fragment
          [urn_for(id.base), *supplement_segments(id)].join(":")
        when Identifiers::ConsolidatedIdentifier
          base, *supplements = id.identifiers
          [urn_for(base), *supplements.flat_map do |s|
            ["plus", *supplement_segments(s)]
          end].join(":")
        else
          if adoption?(id)
            # The publisher, then the adopted document's MR string with its
            # dot and underscore separators as colons, then a draft stage as
            # the base URN writes it.
            body = [id.mr_publisher, id.adopted&.to_mr_string]
              .compact.reject(&:empty?).join(".").tr("._", "::")
            ["urn:cen:#{body}", *stage_segment(id)].join(":")
          else
            self.class.new(id).generate_base_urn
          end
        end
      end

      # "EN ISO 8601:2019" or "ENV ISO 11079:1999": the document identity is
      # on the adopted ISO/IEC identifier, not on this one.
      def adoption?(id)
        id.is_a?(Identifiers::AdoptedEuropeanNorm) ||
          (id.is_a?(Identifiers::EuropeanPrestandard) && id.adopted)
      end

      # ["stage.proposal"] for a draft stage, [] for a published document.
      def stage_segment(id)
        code = id.typed_stage&.stage_code
        return [] if code.nil? || code.to_s == "published"

        ["stage.#{code}"]
      end

      # The segments that a supplement adds to its base: type, number (none
      # for an unnumbered "/AC"), then the date.
      def supplement_segments(id)
        segments = case id
                   when Identifiers::Amendment
                     ["amd", id.number, id.year]
                   when Identifiers::Corrigendum
                     ["cor", id.number, id.supplement_date]
                   when Identifiers::Fragment
                     ["frag", id.number]
                   else
                     []
                   end
        segments.map(&:to_s).reject(&:empty?)
      end

      def generate_base_urn
        parts = ["urn", "cen"]

        if identifier.publisher
          pub = identifier.publisher.to_s
          parts << pub.to_s.downcase
        else
          parts << "en"
        end

        copubs = maybe(:copublishers)
        if copubs&.any?
          cp = copubs.map(&:to_s)
          parts[-1] = "#{parts[-1]}-#{cp.join('-').downcase}"
        end

        type_comp = type_component
        parts << type_comp if type_comp

        if identifier.number
          number = identifier.number.to_s
          parts << number
        end

        part = maybe(:part)
        if part
          p = part.to_s
          parts[-1] = "#{parts[-1]}-#{p}"
        end

        subpart = maybe(:subpart)
        if subpart
          sp = subpart.to_s
          parts[-1] = "#{parts[-1]}-#{sp}"
        end

        date = maybe(:date)
        if date&.is_a?(::Pubid::Components::Date) && date.present?
          parts << date.render(context: URN_CONTEXT)
        elsif date
          parts << date.to_s
        elsif identifier.year
          parts << identifier.year.to_s
        end

        typed_stage = maybe(:typed_stage)
        if typed_stage
          stage_code = typed_stage.stage_code
          if stage_code && stage_code != :published
            parts << "stage.#{stage_code}"
          end
        end

        languages = maybe(:languages)
        if languages&.any?
          lang_codes = languages.map(&:code).join(",")
          parts << lang_codes
        end

        parts.join(":")
      end

      def type_component
        typed_stage = maybe(:typed_stage)
        return nil unless typed_stage

        type_code = typed_stage.type_code
        return nil if !type_code || type_code.to_s == "en"

        type_code.to_s
      end
    end
  end
end
