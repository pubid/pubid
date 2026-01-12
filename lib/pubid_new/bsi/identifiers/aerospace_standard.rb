# frozen_string_literal: true

require_relative "../single_identifier"

module PubidNew
  module Bsi
    module Identifiers
      # AerospaceStandard handles BSI aerospace and specialized standards
      # with letter prefixes indicating domain categorization.
      #
      # Categorization includes:
      # - Aircraft (A, B, C, F, G, HC, L, S, SP, X)
      # - Methods related to aircraft (M)
      # - Marine (MA)
      # - Polyester (PL)
      # - Aerospace materials (TA for Titanium-Aluminium alloys)
      # - Automotive (AU)
      # - Multi-letter prefixes (2A, 2B, 2C, 2F, 2G, 2HC, 2HR, 2L, 2M, 2S, 2SP, 2TA, 2X, etc.)
      #
      # Examples:
      #   BS A 109:2024       # Aircraft (A prefix)
      #   BS AU 145e:2018     # Automotive (AU prefix) with letter suffix
      #   BS M 38:1971        # Methods (M prefix)
      #   BS 2A 293:2005      # Multi-letter prefix (2A)
      #   BS SP 113:1954      # Specification (SP prefix)
      #   BS TA 40:1971       # Titanium-Aluminium (TA prefix)
      class AerospaceStandard < SingleIdentifier
        attribute :prefix, :string

        # Single-letter aerospace/specialized prefixes
        SINGLE_LETTER_PREFIXES = %w[
          A B C F G L M S X
          AU HC MA PL QC SP TA
        ].freeze

        # Multi-letter prefixes (number + letter combination)
        MULTI_LETTER_PREFIXES = %w[
          2A 2B 2C 2F 2G 2HC 2HR 2L 2M 2S 2SP 2TA 2X
          3A 3B 3F 3G 3HR 3J 3L 3S 3TA
          4F 4L 4S
          5S 7S
        ].freeze

        ALL_PREFIXES = (SINGLE_LETTER_PREFIXES + MULTI_LETTER_PREFIXES).freeze

        # TYPED_STAGES for aerospace standards (published by default)
        TYPED_STAGES = [
          PubidNew::Components::TypedStage.new(
            code: :pubas,
            stage_code: :published,
            type_code: :aerospace,
            abbr: ["BS"],
            name: "Aerospace/Specialized Standard",
            harmonized_stages: %w[60.00 60.60],
          ),
        ].freeze

        def self.type
          { key: :aerospace, title: "Aerospace/Specialized Standard", short: "BS" }
        end

        def to_s(lang: :en, lang_single: false)
          parts = []
          parts << "BS"  # Always BS for aerospace
          parts << prefix if prefix

          # Number with part/subpart and letter suffix edition
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

          # Letter suffix edition (for aerospace/specialized standards)
          # Append directly to number/part without space or v prefix
          # e.g., BS AU 145e:2018, BS AU 200-1a:1984
          if edition && edition.match?(/^[a-zA-Z]$/)
            result += edition
          end

          # Date
          if date
            year_val = date.respond_to?(:year) ? date.year : date.to_i
            result += ":#{year_val}"
            # Month if present
            result += "-#{format('%02d', month)}" if month
          end

          # Regular edition (non-letter suffix, like v1.0)
          # Only add if edition is not a single letter (already handled above)
          if edition && !edition.match?(/^[a-zA-Z]$/)
            result += " v#{edition}"
          end

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