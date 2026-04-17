# frozen_string_literal: true

require_relative "../../iso/components/publisher"
require_relative "../../components/date"

module Pubid
  module Astm
    module Identifiers
      # IsoDualPublished represents ASTM standards that are dual-published with ISO
      #
      # SEMANTIC NOTE: ISO/ASTM dual-published standards (typically 5xxxx series)
      # - ASTM version: ASTM 52303-24e1 (e1 = edition 1, not "E" prefix)
      # - ISO version: ISO/ASTM 52303:2024
      #
      # Distinguishing feature: Starts with digit (typically 5xxxx series)
      # These are ASTM's version of standards jointly developed with ISO
      class IsoDualPublished < Standard
        # Inherits all behavior from Standard:
        # - sub_year (a, b, c)
        # - reapproval ((2023))
        # - edition (e1)
        # - code (number without letter prefix)
        # - year (2024 → 24)

        # No additional attributes needed - same structure as Standard
        # The semantic difference is the classification itself

        # Rendering is identical to Standard
        # Example: ASTM 52303-24e1

        # Convert to ISO/ASTM dual-published format
        # @return [Pubid::Iso::Identifiers::InternationalStandard] ISO version
        #
        # @example Convert ASTM to ISO format
        #   astm = Pubid::Astm.parse("ASTM 52303-24e1")
        #   iso = astm.to_iso_identifier
        #   iso.to_s # => "ISO/ASTM 52303:2024"
        def to_iso_identifier
          require_relative "../../iso/identifiers/international_standard"
          require_relative "../../iso/components/code"
          require_relative "../../components/publisher"

          iso = Pubid::Iso::Identifiers::InternationalStandard.new

          # Set publisher as ISO with ASTM as copublisher (in Publisher component)
          iso.publisher = Pubid::Iso::Components::Publisher.new(
            publisher: "ISO",
            copublisher: ["ASTM"],
          )

          # Also set copublishers attribute (array of Publisher objects) for rendering
          astm_publisher = ::Pubid::Components::Publisher.new(body: "ASTM")
          iso.copublishers = [astm_publisher]

          # Set code number (same as ASTM) - use ISO Code component
          if code
            iso_code = Pubid::Iso::Components::Code.new
            iso_code.number = code.number
            iso.number = iso_code
          end

          # Set year as date component - use base Date component
          if year
            iso_date = ::Pubid::Components::Date.new
            iso_date.year = year.to_s
            iso.date = iso_date
          end

          iso
        end
      end
    end
  end
end
