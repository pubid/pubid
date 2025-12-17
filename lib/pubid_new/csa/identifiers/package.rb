# frozen_string_literal: true

require_relative "../composite_identifier"

module PubidNew
  module Csa
    module Identifiers
      # PackageIdentifier represents CSA standards sold as packages
      # with additional materials (PDF, print, addenda, etc.)
      #
      # Examples:
      #   CSA Z662:23 PACKAGE INCLUDES: +1 (PDF & ESA)
      #   CSA B149.1:20 PACKAGE (PDF + PRINT)
      #   CSA C22.2 NO. 60601-1:15 PACKAGE WITH ADDENDUM
      #
      # This is a composite pattern where:
      #   - base_identifier is the core CSA standard (recursively parsed)
      #   - package_materials describes what's included in the package
      #   - Package portion is metadata, not a parseable identifier
      #
      # Difference from BundledIdentifier:
      #   - Package: Single base + materials metadata
      #   - Bundled: Multiple identifiers consolidated together
      class Package < CompositeIdentifier
        # Package materials/contents description
        # Examples: "INCLUDES: +1 (PDF & ESA)", "(PDF + PRINT)", "WITH ADDENDUM"
        attribute :package_materials, :string

        # Package keyword variant (for future extensibility)
        # Usually "PACKAGE" but could be variations
        attribute :package_keyword, :string

        def to_s
          result = base_identifier.to_s

          # Add package keyword (always "PACKAGE")
          result += " PACKAGE"

          # Add materials if present
          if package_materials && !package_materials.empty?
            result += " #{package_materials}"
          end

          result
        end
      end
    end
  end
end