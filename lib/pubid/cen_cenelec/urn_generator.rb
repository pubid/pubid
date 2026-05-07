# frozen_string_literal: true

module Pubid
  module CenCenelec
    class UrnGenerator < Pubid::UrnGenerator::Base
      def generate
        if identifier.is_a?(CenCenelec::SupplementIdentifier)
          generate_supplement_urn
        else
          generate_base_urn
        end
      end

      protected

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
        if date
          year = date.year
          parts << year.to_s
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

      def generate_supplement_urn
        parts = ["urn", "cen"]

        base_id = maybe(:base_identifier)
        if base_id
          base_gen = self.class.new(base_id)
          base_urn = base_gen.generate_base_urn

          base_part = base_urn.sub(/^urn:cen:/, "")
          base_parts = base_part.split(":")

          parts.concat(base_parts)

          typed_stage = maybe(:typed_stage)
          if typed_stage
            supp_type = typed_stage.type_code.to_s
            parts << supp_type if supp_type
          end

          amendment_number = maybe(:amendment_number)
          if amendment_number
            parts << amendment_number.to_s
          elsif identifier.number
            number = identifier.number.to_s
            parts << number
          end

          amendment_year = maybe(:amendment_year)
          if amendment_year
            parts << amendment_year.to_s
          elsif identifier.date
            year = identifier.date.year
            parts << year.to_s
          end
        else
          parts << "unknown"
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
