# frozen_string_literal: true

require_relative "../single_identifier"

module PubidNew
  module Bsi
    module Identifiers
      # SupplementaryIndex represents BSI supplementary index documents
      # Format: BS {number} Supplementary Index:{year}
      #
      # Examples:
      #   BS 185 Supplementary Index:1965
      class SupplementaryIndex < SingleIdentifier
        # TYPED_STAGES for supplementary index (published by default)
        TYPED_STAGES = [
          PubidNew::Components::TypedStage.new(
            code: :pubsupplementaryindex,
            stage_code: :published,
            type_code: :supplementary_index,
            abbr: ["BS"],
            name: "Supplementary Index",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :supplementary_index, title: "Supplementary Index", short: "BS" }
        end

        def to_s(lang: :en, lang_single: false)
          # Supplementary Index format: BS {number} Supplementary Index:{year}
          parts = []
          parts << "BS"

          # Number with part/subpart
          if number
            number_str = number.respond_to?(:value) ? number.value.to_s : number.to_s

            # Part and subpart
            if part
              part_val = part.respond_to?(:value) ? part.value : part
              number_str += "-#{part_val}"
            end
            if subpart
              subpart_val = subpart.respond_to?(:value) ? subpart.value : subpart
              number_str += "-#{subpart_val}"
            end

            parts << number_str
          end

          result = parts.join(" ")

          # Date
          if date
            year_val = date.respond_to?(:year) ? date.year : date.to_i
            result += " Supplementary Index:#{year_val}"
            # Month if present
            result += "-#{format('%02d', month)}" if month
          end

          result
        end
      end
    end
  end
end
