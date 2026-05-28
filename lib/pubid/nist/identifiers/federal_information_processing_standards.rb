# frozen_string_literal: true

module Pubid
  module Nist
    module Identifiers
      # NIST Federal Information Processing Standards (FIPS)
      # Examples:
      # - "FIPS 140-3" (no NIST prefix)
      # - "NIST FIPS 140-3" (also accepted, normalizes to FIPS 140-3)
      class FederalInformationProcessingStandards < Base
        TYPED_STAGES = [
          Pubid::Components::TypedStage.new(
            abbr: ["FIPS", "NIST FIPS"],
            stage_code: "published",
            type_code: "fips",
          ),
        ].freeze

        class << self
          def typed_stages
            TYPED_STAGES
          end

          def type
            { key: :fips, title: "Federal Information Processing Standards",
              short: "FIPS" }
          end
        end

        def series_code
          "FIPS"
        end

        # FIPS identifiers default to no publisher prefix
        def default_publisher
          ""
        end

        # Override to_mr_style to not add "NIST" prefix for FIPS
        def to_mr_style
          # "FIPS.46e1977" (machine-readable with dots, no publisher prefix)
          # Note: edition is appended directly to number without dot for FIPS
          result = series_code

          if number
            result += ".#{number}"
            # Append edition directly to number (no dot) for FIPS MR format
            if edition
              result += edition.to_s
            end
          end

          result += parts.map { |p| "-#{p}" }.join if parts&.any?

          result
        end

        private

        def to_short_style
          # FIPS format: "FIPS 14e1971" or "NIST FIPS 140-3" (preserve publisher if set)
          result = publisher ? "#{publisher} " : ""
          result += series_code

          if number
            # Convert dash-year patterns to edition format for FIPS
            # Pattern: "14-1971" → "14e1971" (edition year format)
            # But preserve dash for parts: "140-3" stays as-is
            if number.value =~ /^(\d{1,3})-(\d{4})$/
              # This is a number-year pattern (e.g., "14-1971")
              # Convert to edition format: "14e1971"
              number_part = $1
              year_part = $2
              result += " #{number_part}e#{year_part}"
            else
              result += " #{number.value}"
            end
          end

          # FIPS uses dash notation for parts: -1, -2, -3 (not pt1, pt2, pt3)
          if part.is_a?(Components::Part)
            result += "-#{part.value}"
          end
          # Render edition for FIPS
          # FIPS editions use "e" prefix: e1971, e198503, e19770930
          if edition
            result += "#{edition.type}#{edition.id}"
          end

          # Mirror Base#to_short_style update rendering — FIPS overrides
          # to_short_style entirely, so update (e.g. /Upd2) would otherwise
          # be dropped.
          if update_component
            result += update_component.to_s(:short)
          elsif update
            result += "-upd#{update}"
          end

          result
        end
      end
    end
  end
end
