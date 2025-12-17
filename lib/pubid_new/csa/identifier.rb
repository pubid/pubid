# frozen_string_literal: true

require_relative "parser"
require_relative "builder"
require_relative "single_identifier"

module PubidNew
  module Csa
    class Identifier
      def self.parse(input)
        # Filter out comments
        return nil if input.start_with?("#")

        # Filter out non-standards
        return nil if input.match?(/^CSA (Communities|Group|Learning|OnDemand|Update)/)

        # Preprocessing: normalize CEI to IEC (French name)
        input = input.gsub(/CEI\/IEC/, "IEC").gsub(/\bCEI\b/, "IEC")

        # Detect CAN/ wrapper (Canadian adoption)
        if input.start_with?("CAN/")
          # This is a Canadian adoption - parse as wrapper
          # Remove CAN/ prefix
          wrapped_input = input.sub(/^CAN\//, "")

          # Extract reaffirmation FIRST (before any other processing)
          reaffirm_year = nil
          if wrapped_input =~ /\(R(\d{4})\)/
            reaffirm_year = $1
            wrapped_input = wrapped_input.sub(/\s*\(R\d{4}\)/, "")
          end

          # Detect and preserve original format (CSA- vs CSA)
          original_prefix = if wrapped_input.start_with?("CSA-")
                             "CSA-"
                           elsif wrapped_input.start_with?("CSA ")
                             "CSA"
                           else
                             nil
                           end

          # Normalize CSA- to CSA  (with space) for parsing
          wrapped_input = wrapped_input.sub(/^CSA-/, "CSA ")

          # Parse the wrapped identifier recursively
          wrapped_identifier = parse(wrapped_input)
          return nil unless wrapped_identifier

          # Restore original prefix format to wrapped identifier
          if original_prefix
            # For Combined identifiers, set on first identifier
            if wrapped_identifier.respond_to?(:first) && wrapped_identifier.first
              wrapped_identifier.first.publisher_prefix = original_prefix if wrapped_identifier.first.respond_to?(:publisher_prefix=)
            elsif wrapped_identifier.respond_to?(:publisher_prefix=)
              # For non-Combined identifiers, set directly
              wrapped_identifier.publisher_prefix = original_prefix
            end
          end

          # Create CanadianAdoptedIdentifier wrapper
          require_relative "identifiers/canadian_adopted"
          result = Identifiers::CanadianAdopted.new
          result.wrapped_identifier = wrapped_identifier
          result.reaffirmation = reaffirm_year if reaffirm_year

          return result
        end

        # Detect CSA adoption of international standards
        # Examples: CSA ISO/IEC TR 12785-3:15, CSA CISPR 16-1-1:18, CSA IEC 60601-1:08
        if input.match?(/^CSA (ISO\/IEC|CISPR|IEC|CEI|ISO)\s/)
          # This is CSA adoption of international standard
          # Extract the wrapped standard portion
          wrapped_input = input.sub(/^CSA\s+/, "")

          # Extract reaffirmation FIRST (before parsing)
          reaffirm_year = nil
          if wrapped_input =~ /\(R(\d{4})\)/
            reaffirm_year = $1
            wrapped_input = wrapped_input.sub(/\s*\(R\d{4}\)/, "")
          end

          # Convert 2-digit years to 4-digit for external parser
          # :15 → :2015, :04 → :2004
          if wrapped_input =~ /:(\d{2})\b/
            short_year_str = $1  # Keep as string "04", "15", etc.
            short_year_int = short_year_str.to_i
            # Determine century: 00-49 → 2000s, 50-99 → 1900s
            full_year = short_year_int < 50 ? "20#{short_year_str}" : "19#{short_year_str}"
            wrapped_input = wrapped_input.sub(/:#{short_year_str}\b/, ":#{full_year}")
          end

          # Parse with appropriate flavor parser
          wrapped_identifier = parse_external_standard(wrapped_input)
          return nil unless wrapped_identifier

          # Create CsaAdoptedIdentifier wrapper
          require_relative "identifiers/csa_adopted"
          result = Identifiers::CsaAdopted.new
          result.wrapped_identifier = wrapped_identifier
          result.reaffirmation = reaffirm_year if reaffirm_year

          return result
        end

        # Detect package identifiers
        # Examples: CSA Z662:23 PACKAGE INCLUDES: +1 (PDF & ESA)
        #           CSA B149.1:20 PACKAGE (PDF + PRINT)
        if input.match?(/\sPACKAGE\s/i)
          # Extract base identifier and package portion
          parts = input.split(/\s+PACKAGE\s+/i, 2)
          base_input = parts[0]
          package_portion = parts[1] || ""

          # Parse base identifier recursively
          base_identifier = parse(base_input)
          return nil unless base_identifier

          # Create PackageIdentifier
          require_relative "identifiers/package"
          result = Identifiers::Package.new
          result.base_identifier = base_identifier
          result.package_materials = package_portion.strip
          result.package_keyword = "PACKAGE"

          return result
        end

        # Legacy handling for CAN/CSA- and CAN3- (will be migrated to proper classes later)
        # Detect original publisher prefix before normalization
        publisher_prefix = if input.start_with?("CAN/CSA-")
                            "CAN/CSA-"
                          elsif input.start_with?("CAN3-")
                            "CAN3-"
                          elsif input.start_with?("CSA ")
                            "CSA"
                          else
                            nil
                          end

        # Detect year format before normalization
        # CAN/CSA- standards use dash format: CAN/CSA-C22.2-05
        # Modern CSA standards use colon format: CSA B149:20
        has_dash_year = input.match?(/-\d{2}\b/)

        # Normalize CAN/CSA- and CAN3- to CSA (global replacement for combined identifiers)
        normalized = input.gsub(/CAN\/CSA-/, "CSA ")
        # Normalize CAN3- to CSA (historical prefix)
        normalized = normalized.gsub(/CAN3-/, "CSA ")

        tree = Parser.new.parse(normalized)
        result = Builder.new.build(tree)

        # Set publisher prefix if detected
        if result && publisher_prefix
          set_publisher_prefix(result, publisher_prefix)
        end

        # Set year format if detected as dash and not already set
        if result && has_dash_year && result.year_format.nil?
          result.year_format = "dash"
        end

        result
      rescue Parslet::ParseFailed => e
        raise e
      end

      def self.set_publisher_prefix(obj, prefix)
        # Set on main object if it has the attribute
        obj.publisher_prefix = prefix if obj.respond_to?(:publisher_prefix=)

        # Set on combined identifier parts
        if obj.respond_to?(:first) && obj.first
          obj.first.publisher_prefix = prefix if obj.first.respond_to?(:publisher_prefix=)
        end
        if obj.respond_to?(:second) && obj.second && obj.second.respond_to?(:has_publisher) && obj.second.has_publisher
          obj.second.publisher_prefix = prefix if obj.second.respond_to?(:publisher_prefix=)
        end
        if obj.respond_to?(:third) && obj.third && obj.third.respond_to?(:has_publisher) && obj.third.has_publisher
          obj.third.publisher_prefix = prefix if obj.third.respond_to?(:publisher_prefix=)
        end

        # Set on bundled identifier base
        if obj.respond_to?(:base) && obj.base
          set_publisher_prefix(obj.base, prefix)
        end
      end

      def self.parse_external_standard(input)
        # Ensure full PubidNew is loaded (handles Scheme and all flavors)
        require_relative "../../pubid_new" unless defined?(PubidNew::Iso) && defined?(PubidNew::Iec)

        # Try ISO/IEC first (most common)
        if input.match?(/^(ISO\/IEC|ISO|IEC|CEI)\s/)
          begin
            return PubidNew::Iso.parse(input)
          rescue StandardError
            return nil
          end
        end

        # Try CISPR (uses IEC parser)
        if input.match?(/^CISPR\s/)
          begin
            return PubidNew::Iec.parse(input)
          rescue StandardError
            return nil
          end
        end

        nil
      end
    end
  end
end