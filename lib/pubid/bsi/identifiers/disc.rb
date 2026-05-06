# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # DISC (Delivering Information Solutions to Customers) identifier
      # Examples: "DISC PD 2000-2:1997", "DISC PD 3004:1998"
      class Disc < SingleIdentifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :disc,
            stage_code: :published,
            type_code: :disc,
            abbr: ["DISC"],
            name: "DISC",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :disc, title: "DISC", short: "DISC" }
        end

        def to_s(lang: :en, lang_single: false)
          parts = []

          # DISC prefix
          parts << "DISC"

          # Type (PD) + number
          if number
            number_str = if number.is_a?(Components::Code)
                           number.value.to_s
                         else
                           number.to_s
                         end
            if part
              part_val = part.is_a?(Components::Code) ? part.value : part
              number_str += "-#{part_val.to_s.strip}"
            end
            parts << "PD #{number_str}"
          end

          result = parts.join(" ")

          # Date with colon separator
          if date
            result += ":#{date}"
          end

          result
        end
      end
    end
  end
end
