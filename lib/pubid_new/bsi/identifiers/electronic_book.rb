# frozen_string_literal: true

require_relative "../single_identifier"

module PubidNew
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
            number_str = number.respond_to?(:value) ? number.value.to_s : number.to_s

            # Part and subpart
            if part
              part_val = part.respond_to?(:value) ? part.value : part
              number_str += "-#{part_val.to_s.strip}"
            end
            if subpart
              subpart_val = subpart.respond_to?(:value) ? subpart.value : subpart
              number_str += "-#{subpart_val.to_s.strip}"
            end

            parts << number_str
          end

          result = parts.join(" ")

          # Date
          if date
            year_val = date.respond_to?(:year) ? date.year : date.to_i
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