# frozen_string_literal: true

module Pubid
  module Nist
    module Identifiers
      # NIST Federal Information Processing Standards (FIPS)
      # Examples:
      # - "FIPS 140-3" (no NIST prefix)
      # - "NIST FIPS 140-3" / "FIPS PUB 140-3" (also accepted; both parse
      #   to the same identity, and the NIST-published face renders as
      #   "FIPS PUB 140-3")
      class FederalInformationProcessingStandards < Identifier
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

          # Bare "FIPS 197" names the NIST document (NIST/CSRC list every
          # FIPS, NBS-era ones included, as "NIST FIPS"). A parsed "NBS"
          # stays NBS.
          def series_default_publisher
            "NIST"
          end

          def type
            { key: :fips,
            web: :federal_information_processing_standards, title: "Federal Information Processing Standards",
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

        # Override to_mr_style so FIPS adds no default "NIST" prefix
        def to_mr_style
          # "NIST.FIPS.197" keeps a parsed publisher (the DOI suffix NIST
          # publishes); "FIPS.46e1977" has none and invents none.
          # A bare "FIPS 197" carries the series default publisher NIST but
          # did not spell it, so it prints no prefix either.
          # Note: edition is appended directly to number without dot for FIPS
          result = [printed_publisher, series_code].compact.join(".")
          result += ".#{number}" if number

          # FIPS uses dash notation for parts; render here and skip the generic
          # part rendering in the shared tail (which appends volume, edition,
          # supplement, version, update, etc.).
          result += "-#{part.value}" if part.is_a?(Components::Part)
          result += parts.map { |p| "-#{p}" }.join if parts&.any?

          result += append_mr_components(skip_part: true)

          result
        end

        public

        # The short-face lead: the official printed "FIPS PUB" for a spelled
        # NIST publisher (owner ruling 2026-11-12), the spelled historical
        # publisher for NBS rows, and the bare series code when the input
        # spelled no publisher — the series-default NIST a bare parse fills
        # (#704) is not a printed publisher, so the bare face stays bare.
        def fips_render_lead
          lead_publisher = printed_publisher
          return "FIPS PUB" if lead_publisher == "NIST"
          return "#{lead_publisher} #{series_code}" if lead_publisher && !lead_publisher.empty?

          series_code.to_s
        end

        def to_short_style
          # The official published face is "FIPS PUB <number>": FIPS is
          # government-published, and "PUB" (Federal Information Processing
          # Standards PUBlication) is part of the official designation
          # (owner ruling 2026-11-12). The tail (volume/part/edition/
          # supplement/update/draft) rides the lead unchanged, and the MR
          # face ("NIST.FIPS.197") is an identity surface that does not
          # move.
          result = fips_render_lead

          if number
            # Convert dash-year patterns to edition format for FIPS
            # Pattern: "14-1971" → "14e1971" (edition year format)
            # But preserve dash for parts: "140-3" stays as-is
            if number =~ /^(\d{1,3})-(\d{4})$/
              # This is a number-year pattern (e.g., "14-1971")
              # Convert to edition format: "14e1971"
              number_part = $1
              year_part = $2
              result += " #{number_part}e#{year_part}"
            else
              result += " #{number}"
            end
          end

          # FIPS uses dash notation for parts: -1, -2, -3 (not pt1, pt2, pt3),
          # so render the part here and skip the generic part rendering in the
          # shared tail. The tail still appends volume, edition, version,
          # supplement, update, etc. — components FIPS previously dropped.
          if part.is_a?(Components::Part)
            result += "-#{part.value}"
          end

          result += append_short_components(skip_part: true)

          result
        end

        private

        # The publisher the short and MR faces print: only one the input
        # spelled, never the series default.
        def printed_publisher
          publisher if publisher_was_parsed
        end
      end
    end
  end
end
