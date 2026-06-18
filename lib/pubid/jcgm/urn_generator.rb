# frozen_string_literal: true

module Pubid
  module Jcgm
    class UrnGenerator < Pubid::UrnGenerator::Base
      def generate
        if identifier.is_a?(SupplementIdentifier)
          generate_supplement_urn
        else
          generate_base_urn
        end
      end

      protected

      def generate_base_urn
        parts = ["urn", "jcgm"]

        gum_number = maybe(:gum_number)
        if gum_number
          number = gum_number.to_s
          parts << "gum.#{number}"
        elsif identifier.number
          number = identifier.number.to_s
          parts << number
        end

        part = maybe(:part)
        if part
          p = part.to_s
          parts << "-#{p}"
        end

        subpart = maybe(:subpart)
        if subpart
          sp = subpart.to_s
          parts << "-#{sp}"
        end

        if identifier.date&.is_a?(::Pubid::Components::Date) && identifier.date.present?
          parts << identifier.date.render(context: URN_CONTEXT)
        elsif maybe(:year)
          parts << maybe(:year).to_s
        end

        edition = maybe(:edition)
        if edition
          e = edition.number || edition.to_s
          parts << "ed.#{e}"
        end

        stage_iteration = maybe(:stage_iteration)
        if stage_iteration
          iter = stage_iteration.to_s
          parts << "iter.#{iter}"
        end

        if identifier.typed_stage
          type_code = identifier.typed_stage.type_code
          if type_code && type_code.to_s != "guide"
            parts << type_code.to_s
          end
        end

        if identifier.languages&.any?
          lang_codes = identifier.languages.map(&:code).join(",")
          parts << lang_codes
        end

        parts.join(":")
      end

      def generate_supplement_urn
        parts = ["urn", "jcgm"]

        base_id = maybe(:base_identifier)
        if base_id
          base_gen = self.class.new(base_id)
          base_urn = base_gen.generate_base_urn

          base_part = base_urn.sub(/^urn:jcgm:/, "")
          base_parts = base_part.split(":")

          parts.concat(base_parts)

          if identifier.typed_stage
            supp_type = identifier.typed_stage.type_code.to_s
            parts << supp_type if supp_type
          end

          iteration = maybe(:iteration)
          if iteration
            iter = iteration.to_s
            parts << iter
          end

          if identifier.date&.is_a?(::Pubid::Components::Date) && identifier.date.present?
            parts << identifier.date.render(context: URN_CONTEXT)
          end
        else
          parts << "unknown"
        end

        parts.join(":")
      end
    end
  end
end
