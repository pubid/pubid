# frozen_string_literal: true

require_relative "../single_identifier"

module PubidNew
  module Bsi
    module Identifiers
      # Published Document (PD) identifier
      class PublishedDocument < SingleIdentifier
        TYPED_STAGES = [
          PubidNew::Components::TypedStage.new(
            code: :pubpd,
            stage_code: :published,
            type_code: :pd,
            abbr: ["PD"],
            name: "Published Document",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :pd, title: "Published Document", short: "PD" }
        end

        def to_s(lang: :en, lang_single: false)
          # Build string representation - PD uses type abbreviation as prefix
          parts = []

          # Use type abbreviation (PD) instead of publisher (BS)
          type_abbr = type&.abbr || "PD"
          parts << type_abbr

          # Number with part and subpart
          if number
            number_str = number.respond_to?(:value) ? number.value.to_s : number.to_s

            # Collection (second number with slash, e.g., PD 6430/1)
            if second_number
              second_val = second_number.respond_to?(:value) ? second_number.value : second_number
              number_str += "/#{second_val}"
            end

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
