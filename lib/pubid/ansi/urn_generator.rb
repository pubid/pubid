# frozen_string_literal: true

module Pubid
  module Ansi
    class UrnGenerator < Pubid::UrnGenerator::Base
      def urn_typed_stage
        return nil unless identifier.typed_stage

        type_code = identifier.typed_stage.type_code
        return nil if type_code && type_code.to_s == "ans"

        type_code&.to_s
      end

      def generate
        parts = ["urn", "ansi"]
        parts << urn_number if urn_number
        parts << urn_part if urn_part
        parts << urn_subpart if urn_subpart
        parts << urn_year if urn_year
        parts << urn_edition if urn_edition
        parts << urn_typed_stage if urn_typed_stage

        if identifier.publisher
          parts[1] = identifier.publisher.render(context: URN_CONTEXT)
        end

        if identifier.copublishers&.any?
          copubs = identifier.copublishers.map { |cp| cp.render(context: URN_CONTEXT) }
          parts[1] = "#{parts[1]}-#{copubs.join('-')}"
        end

        if identifier.languages&.any?
          parts << identifier.languages.map(&:code).join(",")
        end

        parts.join(":")
      end
    end
  end
end
