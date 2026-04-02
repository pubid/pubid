# frozen_string_literal: true

module Pubid
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
          # Check if this is actually a bundled/combined identifier with + or /
          # that should NOT be wrapped in CanadianAdopted
          wrapped_input = input.sub(/^CAN\//, "")

          # Check for bundled (+) or combined (/ or ,) patterns that should remain as-is
          # These should be parsed normally, with publisher prefix applied to each part
          # Patterns to detect:
          # 1. Bundled: + separator (e.g., "CSA B127.1:99 + B127.2:99")
          # 2. Combined with space: / separator with space before CSA- (e.g., "CSA A23.1:24/CSA A23.2:24")
          # 3. Combined with CAN/CSA-: / separator with CSA- appearing multiple times (e.g., "CSA-B138.1-17/CSA-B138.2-17")
          if wrapped_input.include?('+') ||
             (wrapped_input.include?('/') && wrapped_input.match?(/\s+CSA-/)) ||
             (wrapped_input.include?('/') && wrapped_input.scan(/CSA-/).length > 1)
            # This is a bundled or combined identifier - parse normally and add prefix
            # Normalize CSA- to CSA (with space) for parsing
            normalized = wrapped_input.sub(/^CSA-/, "CSA ")
            normalized = normalized.gsub(/CAN\/CSA-/, "CSA ").gsub(/CAN3-/, "CSA ")
            normalized = normalized.gsub(/\s+/, " ").strip

            # Parse normally (will create Bundled or Combined identifier)
            tree = Parser.new.parse(normalized)
            result = Builder.new.build(tree)

            # Apply CAN/CSA- prefix to the appropriate parts
            if result
              set_publisher_prefix(result, "CAN/CSA-")

              # Handle reaffirmation if present
              if wrapped_input =~ /\(R(\d{4})\)/
                result.reaffirmation = $1 if result.respond_to?(:reaffirmation=)
              end
            end

            return result
          end

          # This is a standard single identifier wrapped in CanadianAdopted
          # Remove CAN/ prefix (already done above)

          # Extract reaffirmation FIRST (before any other processing)
          reaffirm_year = nil
          reaffirmation_was_4digit = false  # Track original format
          if wrapped_input =~ /\(R(\d{2,4})\)/
            reaffirm_year = $1
            reaffirmation_was_4digit = ($1.length == 4)  # Track if original was 4-digit
            # Convert 2-digit year to 4-digit if needed
            if reaffirm_year.length == 2
              year_int = reaffirm_year.to_i
              reaffirm_year = year_int < 50 ? "20#{reaffirm_year}" : "19#{reaffirm_year}"
            end
            wrapped_input = wrapped_input.sub(/\s*\(R\d{2,4}\)/, "")
          end

          # Detect and preserve original format (CSA- vs CSA)
          # Also track that this is a CAN/CSA- identifier (not just CSA-)
          original_prefix = if wrapped_input.start_with?("CSA-")
                              "CSA-"
                            elsif wrapped_input.start_with?("CSA ")
                              "CSA"
                            end
          is_can_csa = true  # Track that this has the CAN/ wrapper

          # Normalize CSA- to CSA  (with space) for parsing
          wrapped_input = wrapped_input.sub(/^CSA-/, "CSA ")

          # Parse the wrapped identifier recursively
          wrapped_identifier = parse(wrapped_input)
          return nil unless wrapped_identifier

          # NOTE: Series identifiers should be wrapped in CanadianAdopted when
          # they have CAN/CSA- prefix. The Series will handle rendering correctly.
          # Do NOT return Series directly - always wrap in CanadianAdopted.

          # Set publisher prefix on wrapped identifier
          # For Series identifiers with CAN/ wrapper, use full "CAN/CSA-" prefix
          # For other identifiers, use the detected original_prefix ("CSA-" or "CSA")
          if wrapped_identifier.respond_to?(:publisher_prefix=)
            if is_can_csa && wrapped_identifier.is_a?(Identifiers::Series)
              # Series gets full "CAN/CSA-" prefix for proper rendering
              wrapped_identifier.publisher_prefix = "CAN/CSA-"
            elsif original_prefix
              # For Combined identifiers, set on first identifier
              if wrapped_identifier.respond_to?(:first) && wrapped_identifier.first
                wrapped_identifier.first.publisher_prefix = original_prefix if wrapped_identifier.first.respond_to?(:publisher_prefix=)
              else
                # For non-Combined identifiers, set directly
                wrapped_identifier.publisher_prefix = original_prefix
              end
            end
          end

          # Set reaffirmation on wrapped_identifier if it has the attribute
          if wrapped_identifier.respond_to?(:reaffirmation=) && reaffirm_year
            wrapped_identifier.reaffirmation = reaffirm_year
            if wrapped_identifier.respond_to?(:original_reaffirmation_4digit=)
              wrapped_identifier.original_reaffirmation_4digit = reaffirmation_was_4digit
            end
          end

          # Create CanadianAdoptedIdentifier wrapper
          result = Identifiers::CanadianAdopted.new
          result.wrapped_identifier = wrapped_identifier
          result.reaffirmation = reaffirm_year if reaffirm_year

          return result
        end

        # Detect CAN3- wrapper (historical Canadian adoption)
        if input.start_with?("CAN3-")
          # This is a historical Canadian adoption - parse as wrapper
          # Remove CAN3- prefix
          wrapped_input = input.sub(/^CAN3-/, "CSA ")

          # Detect year format before normalization (CAN3- standards use dash format)
          # Format: CAN3-Z299.0-86 (uses dash, not colon)
          has_dash_year = wrapped_input.match?(/-\d{2}\b/)  # Match -86, -05, etc. (2-digit years)

          # Extract reaffirmation FIRST (before any other processing)
          reaffirm_year = nil
          reaffirmation_was_4digit = false  # Track original format
          if wrapped_input =~ /\(R(\d{2,4})\)/
            reaffirm_year = $1
            reaffirmation_was_4digit = ($1.length == 4)  # Track if original was 4-digit
            # Convert 2-digit year to 4-digit if needed
            if reaffirm_year.length == 2
              year_int = reaffirm_year.to_i
              reaffirm_year = year_int < 50 ? "20#{reaffirm_year}" : "19#{reaffirm_year}"
            end
            wrapped_input = wrapped_input.sub(/\s*\(R\d{2,4}\)/, "")
          end

          # Parse the wrapped identifier recursively
          wrapped_identifier = parse(wrapped_input)
          return nil unless wrapped_identifier

          # Set year_format for dash format identifiers (preserve original 2-digit year)
          if has_dash_year && wrapped_identifier.respond_to?(:year_format=)
            wrapped_identifier.year_format = "dash"
            # Mark original year as 2-digit so renderer converts back (1986 → 86)
            if wrapped_identifier.respond_to?(:original_year_4digit=)
              wrapped_identifier.original_year_4digit = false
            end
          end

          # Check if this is a Series identifier - return it directly with CAN3- prefix
          # Series identifiers are complete identifier types and handle the prefix themselves
          # They don't need to be wrapped in CanadianAdopted
          if wrapped_identifier.is_a?(Identifiers::Series)
            wrapped_identifier.publisher_prefix = "CAN3-"
            wrapped_identifier.reaffirmation = reaffirm_year if reaffirm_year
            wrapped_identifier.original_reaffirmation_4digit = reaffirmation_was_4digit
            return wrapped_identifier
          end

          # Set CAN3- as publisher prefix on wrapped identifier
          if wrapped_identifier.respond_to?(:publisher_prefix=)
            wrapped_identifier.publisher_prefix = "CAN3-"
          end

          # Set reaffirmation on wrapped_identifier if it has the attribute
          if wrapped_identifier.respond_to?(:reaffirmation=) && reaffirm_year
            wrapped_identifier.reaffirmation = reaffirm_year
            if wrapped_identifier.respond_to?(:original_reaffirmation_4digit=)
              wrapped_identifier.original_reaffirmation_4digit = reaffirmation_was_4digit
            end
          end

          # Create CanadianAdoptedIdentifier wrapper
          result = Identifiers::CanadianAdopted.new
          result.wrapped_identifier = wrapped_identifier
          result.reaffirmation = reaffirm_year if reaffirm_year

          return result
        end

        # Detect CSA adoption of international standards
        # Examples: CSA ISO/IEC TR 12785-3:15, CSA CISPR 16-1-1:18, CSA IEC 60601-1:08
        #          CSA CEI/IEC 61000-4-28-01 (bilingual)
        if input.match?(/^CSA (ISO\/IEC|CEI\/IEC|CISPR|IEC|CEI|ISO)\s/)
          # This is CSA adoption of international standard
          # Extract the wrapped standard portion
          wrapped_input = input.sub(/^CSA\s+/, "")

          # Extract reaffirmation FIRST (before parsing)
          reaffirm_year = nil
          if wrapped_input =~ /\(R(\d{2,4})\)/
            reaffirm_year = $1
            # Convert 2-digit year to 4-digit if needed
            if reaffirm_year.length == 2
              year_int = reaffirm_year.to_i
              reaffirm_year = year_int < 50 ? "20#{reaffirm_year}" : "19#{reaffirm_year}"
            end
            wrapped_input = wrapped_input.sub(/\s*\(R\d{2,4}\)/, "")
          end

          # Convert 2-digit years to 4-digit for external parser
          # :15 → :2015, :04 → :2004
          if wrapped_input =~ /:(\d{2})\b/
            short_year_str = $1 # Keep as string "04", "15", etc.
            short_year_int = short_year_str.to_i
            # Determine century: 00-49 → 2000s, 50-99 → 1900s
            full_year = short_year_int < 50 ? "20#{short_year_str}" : "19#{short_year_str}"
            wrapped_input = wrapped_input.sub(/:#{short_year_str}\b/,
                                              ":#{full_year}")
          end

          # Convert CSA amendment format to ISO/IEC format
          # /A1:22 → /Amd 1:2022, /A1-22 → /Amd 1-2022
          # Also handle 2-digit and 4-digit amendment years (convert to 4-digit)
          # Note: In gsub blocks with string regex, we must use $1, $2, $3
          # because the block receives a String, not MatchData
          wrapped_input = wrapped_input.gsub(%r{/A(\d+)([:/-])(\d{2,4})\b}) do
            amendment_num = $1
            separator = $2
            amend_year_str = $3
            amend_year_int = amend_year_str.to_i
            # Convert 2-digit year to 4-digit if needed
            if amend_year_str.length == 2
              amend_full_year = amend_year_int < 50 ? "20#{amend_year_str}" : "19#{amend_year_str}"
            else
              amend_full_year = amend_year_str
            end
            "/Amd #{amendment_num}#{separator}#{amend_full_year}"
          end

          # Parse with appropriate flavor parser
          wrapped_identifier = parse_external_standard(wrapped_input)
          return nil unless wrapped_identifier

          # Create CsaAdoptedIdentifier wrapper
          result = Identifiers::CsaAdopted.new
          result.wrapped_identifier = wrapped_identifier
          result.reaffirmation = reaffirm_year if reaffirm_year

          return result
        end

        # Detect package identifiers
        # Examples: CSA Z662:23 PACKAGE INCLUDES: +1 (PDF & ESA)
        #           CSA B149.1:25 Code, Handbook & Training Package (materials BEFORE keyword)
        #           CSA B149.1:20 PACKAGE (PDF + PRINT) (no materials)
        #           CSA B108:23 PACKAGE (no trailing space)
        if input.match?(/\sPACKAGE\b/i)
          # Handle two formats:
          # 1. {base} PACKAGE {materials} - materials after keyword
          # 2. {base} {materials} PACKAGE - materials before keyword

          # Check if materials come after PACKAGE keyword
          # Match: "CSA Z662:23 PACKAGE INCLUDES: +1" or "CSA B149.1:20 PACKAGE (PDF + PRINT)"
          if input.match?(/\sPACKAGE\s+[A-Z]/i)
            # Format: {base} PACKAGE {materials}
            # Extract materials after PACKAGE keyword
            base_input, package_materials = input.split(/\s+PACKAGE\s+/i, 2)
            base_input = base_input.strip
            package_materials = package_materials ? package_materials.strip : ""
            materials_after = true
          else
            # Format: {base} PACKAGE or {base} {materials} PACKAGE
            # Examples: "C22.1-15 PACKAGE" (no materials), "CSA B149.1:25 Code, Handbook & Training Package"

            # Check if there's a year followed by materials before PACKAGE
            # Must check this BEFORE the generic "{base} PACKAGE" pattern
            if input.match?(/:(\d{2,4})(\s+[^P]+)\s+PACKAGE/i)
              # Format: {base} {materials} PACKAGE - "CSA B149.1:25 Code, Handbook & Training Package"
              # OR: Combined identifier with package: "CSA B149.1:25, CSA B149.2:25 & Training Package"
              year_str = $1
              materials_with_package = $2

              # Check if this is a combined identifier (has comma with CSA after it)
              # Pattern: ", CSA" or ", CAN" which indicates combined identifier
              if input.match?(/,\s+CSA/)
                # For combined identifiers, we need to extract everything before "& Training Package"
                # The base is the combined identifier, materials is just "& Training Package"
                combined_match = input.match(/^(.+?)(\s+&[^P]+)\s+PACKAGE$/i)
                if combined_match
                  base_input = combined_match[1].strip
                  package_materials = combined_match[2].strip + " Package"  # Keep "& Training Package"
                else
                  # Fallback to year-based extraction
                  year_match = input.match(/:\d{2,4}/)
                  if year_match
                    base_input = input[0..year_match.end(0) - 1]
                    materials_input = input[year_match.end(0)..].strip
                    package_materials = materials_input
                  end
                end
              else
                # Standard single identifier with materials before PACKAGE
                year_match = input.match(/:\d{2,4}/)
                if year_match
                  base_input = input[0..year_match.end(0) - 1]
                  # Materials is everything between base and PACKAGE - keep the "Package" suffix for correct capitalization
                  materials_input = input[year_match.end(0)..].strip
                  package_materials = materials_input  # Keep full materials including "Package" suffix
                  base_input = base_input.strip
                end
              end
              materials_after = false
            elsif input.match?(/^(.+?)\s+PACKAGE\s*$/i)
              # Format: {base} PACKAGE (no materials) - "C22.1-15 PACKAGE"
              # Treat PACKAGE as the package description
              base_input = input.sub(/\s+PACKAGE\s*$/i, "").strip
              package_materials = ""  # No additional materials
              materials_after = true
            else
              # Fallback: try parsing incrementally
              tokens = input.split(/\s+/)
              base_input = ""
              tokens.each do |token|
                break if token.match?(/^PACKAGE$/i)
                test_input = base_input.empty? ? token : "#{base_input} #{token}"
                parsed = parse(test_input)
                if parsed
                  base_input = test_input
                else
                  break
                end
              end

              # Extract materials as everything between base and PACKAGE
              if base_input && base_input.length < input.length
                materials_input = input[base_input.length..].strip
                package_materials = materials_input.sub(/\s+PACKAGE\s*$/i, "").strip
                materials_after = !package_materials.empty?
              end
            end
          end

          # Parse base identifier recursively
          base_identifier = base_input ? parse(base_input) : nil
          return nil unless base_identifier

          # Create PackageIdentifier
          result = Identifiers::Package.new
          result.base_identifier = base_identifier
          # Set materials if present
          if package_materials && !package_materials.empty?
            result.package_materials = package_materials
          end
          result.package_keyword = "PACKAGE"
          # Set materials_after_keyword flag based on which format we detected
          result.materials_after_keyword = materials_after

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
        if obj.respond_to?(:first) && obj.first && obj.first.respond_to?(:publisher_prefix=)
          obj.first.publisher_prefix = prefix
        end
        if obj.respond_to?(:second) && obj.second && obj.second.respond_to?(:has_publisher) && obj.second.has_publisher && obj.second.respond_to?(:publisher_prefix=)
          obj.second.publisher_prefix = prefix
        end
        if obj.respond_to?(:third) && obj.third && obj.third.respond_to?(:has_publisher) && obj.third.has_publisher && obj.third.respond_to?(:publisher_prefix=)
          obj.third.publisher_prefix = prefix
        end

        # Set on bundled identifier base
        if obj.respond_to?(:base) && obj.base
          set_publisher_prefix(obj.base, prefix)
        end
      end

      def self.parse_external_standard(input)
        # Ensure full Pubid is loaded (handles Scheme and all flavors)
        require_relative "../../pubid" unless defined?(Pubid::Iso) && defined?(Pubid::Iec)

        # Try ISO/IEC first (most common)
        if input.match?(/^(ISO\/IEC|ISO|IEC|CEI|CEI\/IEC)\s/)
          begin
            # Normalize CEI/IEC to IEC for parsing (CEI is French for IEC)
            normalized_input = input.sub(/^CEI\/IEC/, 'IEC')
            return Pubid::Iso.parse(normalized_input)
          rescue StandardError
            return nil
          end
        end

        # Try CISPR (uses IEC parser)
        if input.match?(/^CISPR\s/)
          begin
            return Pubid::Iec.parse(input)
          rescue StandardError
            return nil
          end
        end

        nil
      end
    end
  end
end
