# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifiers
      # Publicly Available Specification (PAS) identifier
      class PubliclyAvailableSpecification < SingleIdentifier
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            code: :pubpas,
            stage_code: :published,
            type_code: :pas,
            abbr: ["PAS"],
            name: "Publicly Available Specification",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :pas, title: "Publicly Available Specification", short: "PAS" }
        end

        def to_s(lang: :en, lang_single: false)
          # Build string representation - PAS uses type abbreviation as prefix
          parts = []

          # Use type abbreviation (PAS) instead of publisher (BS)
          type_abbr = type&.abbr || "PAS"
          parts << type_abbr

          # Number with part and subpart
          if number
            number_str = number.is_a?(Components::Code) ? number.value.to_s : number.to_s

            # Collection (second number with slash, e.g., PAS 2035/2030)
            if second_number
              second_val = second_number.is_a?(Components::Code) ? second_number.value : second_number
              number_str += "/#{second_val}"
            end

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
            # Month if present
            result += "-#{format('%02d', month)}" if month
          end

          # Edition
          result += " v#{edition}" if edition

          # Translation
          if translation_lang
            result += " (#{translation_lang})"
          elsif translation_upper
            result += " (#{translation_upper})"
          end

          result
        end
      end
    end
  end
end
