# frozen_string_literal: true


module Pubid
  module Bsi
    module Identifiers
      # BSI Handbook
      # Examples: "Handbook 17:1963", "HB 10146:1998"
      class Handbook < Base
        attribute :number, Bsi::Components::Code
        attribute :part, Bsi::Components::Code
        attribute :date, Bsi::Components::Date
        attribute :original_abbr, :string # Preserve "Handbook" or "HB"

        def self.type
          {
            short: "HB",
            full: "Handbook",
            names: ["Handbook", "HB"],
          }
        end

        def to_s(lang: :en, lang_single: false)
          # Use preserved original abbreviation, default to "Handbook"
          abbr = original_abbr || "Handbook"

          number_str = number.respond_to?(:value) ? number.value.to_s : number.to_s
          if part
            part_val = part.respond_to?(:value) ? part.value : part
            number_str += "-#{part_val.to_s.strip}"
          end

          result = "#{abbr} #{number_str}"
          result += ":#{date.year}" if date
          result
        end
      end
    end
  end
end
