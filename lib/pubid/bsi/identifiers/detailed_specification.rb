# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # Detailed Specification identifier with N or C notation
      # Examples: "BS 9074 N002:1974", "BS 9300 C155-168:1971"
      class DetailedSpecification < SingleIdentifier
        attribute :spec_code, Components::Code

        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :detailed_spec,
            stage_code: :published,
            type_code: :detailed_specification,
            abbr: ["DETAILED SPEC"],
            name: "Detailed Specification",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          {
            key: :detailed_specification,
            title: "Detailed Specification",
            short: "DETAILED SPEC",
          }
        end

        def to_s(lang: :en, lang_single: false)
          parts = []

          # Publisher prefix
          parts << "BS"

          # Base number
          if number
            number_str = if number.respond_to?(:value)
                           number.value.to_s
                         else
                           number.to_s
                         end
            parts << number_str
          end

          # Spec notation (N002 or C155-168)
          if spec_code
            code_val = if spec_code.respond_to?(:value)
                         spec_code.value
                       else
                         spec_code
                       end
            result = "#{parts.join(' ')} #{code_val}"
          else
            result = parts.join(" ")
          end

          # Date
          if date
            year_val = date.respond_to?(:year) ? date.year : date.to_i
            result += ":#{year_val}"
          end

          result
        end
      end
    end
  end
end
