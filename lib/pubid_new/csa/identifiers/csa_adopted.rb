# frozen_string_literal: true

require_relative "../wrapper_identifier"

module PubidNew
  module Csa
    module Identifiers
      # CsaAdoptedIdentifier represents CSA adoption of international standards
      # (ISO, IEC, ISO/IEC, CISPR, etc.)
      #
      # Examples:
      #   CSA ISO/IEC TR 12785-3:15
      #   CSA ISO/IEC TR 19758:04 (R2024)
      #   CSA CISPR 16-1-1:18
      #
      # Key difference from CanadianAdopted:
      #   - CsaAdopted wraps ISO/IEC/CISPR standards (external)
      #   - CanadianAdopted wraps CSA standards (internal)
      #
      # This is a wrapper pattern where:
      #   - CSA prefix indicates adoption
      #   - The wrapped_identifier is the external standard (ISO/IEC/CISPR)
      #   - Wrapped identifier is recursively parsed using external flavor parsers
      class CsaAdopted < WrapperIdentifier
        def to_s
          # Get string representation from wrapped identifier
          base_str = wrapped_identifier.to_s

          # Convert 4-digit years to 2-digit for CSA adoption format
          # ISO/IEC TR 12785-3:2015 → ISO/IEC TR 12785-3:15
          if base_str =~ /:(\d{4})\b/
            year = $1
            if year.start_with?("20")
              short_year = year[2..3]
              base_str = base_str.sub(":#{year}", ":#{short_year}")
            elsif year.start_with?("19")
              # Handle 1900s years: 1998 → 98
              short_year = year[2..3]
              base_str = base_str.sub(":#{year}", ":#{short_year}")
            end
          end

          # Prepend CSA prefix
          result = "CSA #{base_str}"

          # Append reaffirmation if present
          result += " (R#{reaffirmation})" if reaffirmation

          result
        end
      end
    end
  end
end
