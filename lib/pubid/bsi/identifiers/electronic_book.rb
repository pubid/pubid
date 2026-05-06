# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # Electronic Publication (EP) identifier
      class ElectronicBook < SingleIdentifier
        def self.type
          { key: :ep, title: "Electronic Publication", short: "EP" }
        end

        def to_s(lang: :en, lang_single: false)
          # Build string representation - EP uses type abbreviation as prefix
          parts = []

          # Use type abbreviation (EP)
          parts << "EP"

          # Number with part and subpart
          if number
            number_str = number.is_a?(Components::Code) ? number.value.to_s : number.to_s

            # Part and subpart
            if part
              part_val = part.is_a?(Components::Code) ? part.value : part
              number_str += "-#{part_val.to_s.strip}"
            end
            if subpart
              subpart_val = subpart.is_a?(Components::Code) ? subpart.value : subpart
              number_str += "-#{subpart_val.to_s.strip}"
            end

            parts << number_str
          end

          result = parts.join(" ")

          # Date
          if date
            year_val = date.is_a?(Components::Date) ? date.year : date.to_i
            result += ":#{year_val}"
          end

          # Edition/Version
          result += " Version #{edition}" if edition

          result
        end
      end
    end
  end
end
