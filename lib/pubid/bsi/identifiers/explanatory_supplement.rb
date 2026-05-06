# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # ExplanatorySupplement represents BSI explanatory supplement documents
      # Format: BS {number}-{part}:Explanatory Supplement:{year}
      #
      # Examples:
      #   BS 5655-1:Explanatory Supplement:1981
      class ExplanatorySupplement < SingleIdentifier
        # TYPED_STAGES for explanatory supplement (published by default)
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :pubexplanatorysupplement,
            stage_code: :published,
            type_code: :explanatory_supplement,
            abbr: ["BS"],
            name: "Explanatory Supplement",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          {
            key: :explanatory_supplement,
            title: "Explanatory Supplement",
            short: "BS",
          }
        end

        def to_s(lang: :en, lang_single: false)
          # Explanatory Supplement format:
          # BS {number}-{part}:Explanatory Supplement:{year}
          parts = []
          parts << "BS"

          # Number with part/subpart
          if number
            number_str = if number.is_a?(Components::Code)
                           number.value.to_s
                         else
                           number.to_s
                         end

            # Part and subpart
            if part
              part_val = if part.is_a?(Components::Code)
                           part.value
                         else
                           part
                         end
              number_str += "-#{part_val}"
            end
            if subpart
              subpart_val = if supart.is_a?(Components::Code)
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
            year_val = date.is_a?(Components::Date) ? date.year : date.to_i
            result += ":Explanatory Supplement:#{year_val}"
            # Month if present
            result += "-#{format('%02d', month)}" if month
          end

          result
        end
      end
    end
  end
end
