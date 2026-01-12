# frozen_string_literal: true

require_relative "../single_identifier"

module PubidNew
  module Bsi
    module Identifiers
      # TechnicalSpecification represents BSI technical specifications
      # Format: TS {number}:{year}
      #
      # Examples:
      #   TS 3:1993
      #   TS 1:1998
      #   TS 1:1995
      class TechnicalSpecification < SingleIdentifier
        # TYPED_STAGES for technical specifications (published by default)
        TYPED_STAGES = [
          PubidNew::Components::TypedStage.new(
            code: :pubts,
            stage_code: :published,
            type_code: :ts,
            abbr: ["TS"],
            name: "Technical Specification",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :ts, title: "Technical Specification", short: "TS" }
        end

        def to_s(lang: :en, lang_single: false)
          # Technical specifications use a simple format: TS {number}:{year}
          parts = []
          parts << "TS"

          # Number with part/subpart
          if number
            number_str = if number.respond_to?(:value)
                           number.value.to_s
                         else
                           number.to_s
                         end

            # Part and subpart
            if part
              part_val = if part.respond_to?(:value)
                           part.value
                         else
                           part
                         end
              number_str += "-#{part_val}"
            end
            if subpart
              subpart_val = if subpart.respond_to?(:value)
                              subpart.value
                            else
                              subpart
                            end
              number_str += "-#{subpart_val}"
            end

            parts << number_str
          end

          result = parts.join(" ")

          # Date
          if date
            year_val = date.respond_to?(:year) ? date.year : date.to_i
            result += ":#{year_val}"
            # Month if present
            result += "-#{format('%02d', month)}" if month
          end

          result
        end
      end
    end
  end
end
