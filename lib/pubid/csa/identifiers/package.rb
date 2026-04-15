# frozen_string_literal: true

module Pubid
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

        # Track whether materials come before or after PACKAGE keyword
        # true = materials AFTER: "CSA Z662:23 PACKAGE INCLUDES: +1"
        # false = materials BEFORE: "CSA B149.1:25 Code, Handbook & Training Package"
        attribute :materials_after_keyword, :boolean, default: -> { true }

        def to_s
          result = base_identifier.to_s

          # Add package materials if present
          if package_materials && !package_materials.empty?
            if materials_after_keyword
              # Format: {base} PACKAGE {materials}
              result += " PACKAGE"
              result += " #{package_materials}"
            elsif package_materials.match?(/\sPACKAGE\s*$/i)
              # Format: {base} {materials} PACKAGE
              # Check if materials already end with "Package" (to preserve exact capitalization)
              # Materials already include the Package suffix
              result += " #{package_materials}"
            else
              # Add Package suffix (use the package_keyword value)
              result += " #{package_materials}"
              result += " #{package_keyword}"
            end
          else
            # No materials, just add PACKAGE keyword
            result += " PACKAGE"
          end

          result
        end
      end
    end
  end
end
