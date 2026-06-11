# frozen_string_literal: true

module Pubid
  module Nist
    # Builder class for constructing NIST identifier objects from parsed data
    # Single Responsibility: Orchestrate parsing pipeline (pre-processing -> routing -> casting -> construction)
    #
    # CRITICAL ARCHITECTURE PRINCIPLE:
    # Builder NEVER makes business logic decisions.
    # Builder ONLY casts parsed data to domain objects.
    #
    # Delegates:
    # - Router: series-to-class mapping (which identifier class to instantiate)
    # - Caster: type coercion (parsed values -> domain component objects)
    class Builder < Pubid::Builder::Base
      def initialize(scheme)
        @scheme = scheme
        @router = Router.new
        @caster = Caster.new
      end

      # Build an identifier object from parsed data
      # @param parsed [Hash, Array] the parsed identifier data
      # @return [Identifiers::Base] the constructed identifier object
      def build(parsed)
        # Parslet can return array of hashes - merge them
        parsed_hash = parsed.is_a?(Array) ? flatten_array(parsed) : parsed

        # NEW: Fix for update year captured as edition_e
        # Pattern: "800-53r4/Upd3-2015" where parser captures "-2015" as :edition_e
        # but it should be :update_year as part of the update component
        if parsed_hash[:update_prefix] && parsed_hash[:update] && parsed_hash[:edition_e]
          # Move edition_e to update_year
          edition_id = parsed_hash[:edition_e][:edition_id]
          parsed_hash[:update] =
            parsed_hash[:update].merge(update_year: edition_id)
          parsed_hash.delete(:edition_e) # Remove the edition_e hash
        end

        # NEW: Fix for letter suffix in number with edition_dash_year
        # Pattern: "304a-2017" where parser returns first_number="304a" and edition_dash_year="2017"
        # Expected: number="304", part="A", edition with type="e" and id="2017"
        # We'll handle this by extracting the info and NOT adding :part to parsed_hash
        # to avoid it being processed by cast(:part, ...) which would set type="pt"
        letter_suffix_part = nil
        edition_from_dash_year = nil
        if parsed_hash[:first_number]&.to_s&.match?(/^[0-9]+[a-zA-Z]$/) && parsed_hash[:edition_dash_year]
          number_str = parsed_hash[:first_number].to_s
          # Extract letter suffix from number
          if match_data = number_str.match(/^([0-9]+)([a-zA-Z])$/)
            base_number = match_data[1]
            letter_suffix = match_data[2].upcase

            # Update first_number to exclude letter suffix
            parsed_hash[:first_number] =
              Components::Code.new(number: base_number)

            # Store Part component for later (after identifier is initialized)
            letter_suffix_part = Components::Part.new(type: "",
                                                      value: letter_suffix)

            # Convert edition_dash_year to Edition component with type="e"
            dash_year = parsed_hash[:edition_dash_year][:dash_year]
            edition_from_dash_year = Components::Edition.new(type: "e",
                                                             id: dash_year)
            parsed_hash.delete(:edition_dash_year) # Remove the old key
          end
        end

        # NEW: Fix for edition_dash_year with embedded edition in first_number
        # Pattern: "44e2-1955" where first_number="44e2" and edition_dash_year="1955"
        # Expected: edition extracted from "44e2" (type: "e", id: "2") with additional_text="1955"
        #
        # We need to check for this pattern BEFORE the simple year-as-edition pattern below
        if parsed_hash[:first_number]&.to_s&.match?(/^[0-9]+[a-zA-Z]\d+$/) && parsed_hash[:edition_dash_year]
          # Extract edition from embedded pattern (e.g., "44e2" -> type="e", id="2")
          number_str = parsed_hash[:first_number].to_s
          if match_data = number_str.match(/^(\d+)([a-zA-Z])(\d+)$/)
            base_number = match_data[1]
            edition_type = match_data[2].downcase
            edition_id = match_data[3]

            # Update first_number to base number only
            parsed_hash[:first_number] =
              Components::Code.new(number: base_number)

            # Create Edition with additional_text from edition_dash_year
            dash_year = parsed_hash[:edition_dash_year][:dash_year]
            edition_obj = Components::Edition.new(
              type: edition_type,
              id: edition_id,
              additional_text: dash_year,
            )
            parsed_hash[:edition_with_year] = edition_obj
            parsed_hash.delete(:edition_dash_year)
          end
        end

        # NEW: Fix for edition embedded in first_number WITHOUT edition_dash_year
        # Pattern: "8115r1" where parser returns first_number="8115r1" with NO edition_dash_year
        # Expected: first_number="8115", edition with type="r", id="1"
        # This handles patterns like IR "8115r1/upd" where r1 is the edition
        # CRITICAL: Only process if NO second_number is present!
        # Otherwise, the compound number logic (lines 418-437) will handle edition+year patterns
        if !parsed_hash[:second_number] &&
            parsed_hash[:first_number]&.to_s&.match?(/^[0-9]+[a-zA-Z]\d+$/) &&
            !parsed_hash[:edition_dash_year]
          number_str = parsed_hash[:first_number].to_s
          if match_data = number_str.match(/^(\d+)([a-zA-Z])(\d+)$/)
            base_number = match_data[1]
            edition_type = match_data[2].downcase
            edition_id = match_data[3]

            # Update first_number to base number only
            parsed_hash[:first_number] =
              Components::Code.new(number: base_number)

            # Create Edition without additional_text (no year in this pattern)
            edition_obj = Components::Edition.new(
              type: edition_type,
              id: edition_id,
            )
            parsed_hash[:edition_with_year] = edition_obj
          end
        end

        # REMOVED: edition_r_with_space pre-processing
        # Now handled by cast_edition method with original_prefix preservation

        # NEW: Fix for second_number_edition_year pattern
        # Pattern: "105-1-1990" where parser returns second_number_edition_year={second_number="1", dash_year="1990"}
        # Expected: number="105-1", edition with type="e", id="1990", original_prefix="-"
        if parsed_hash[:second_number_edition_year]
          second_num_value = parsed_hash[:second_number_edition_year][:second_number]
          dash_year = parsed_hash[:second_number_edition_year][:dash_year]

          # Extract second_number and edition_dash_year from the combined hash
          parsed_hash[:second_number] = second_num_value

          # For HB (Handbook) series, create year-only edition with dash rendering
          is_handbook = begin
            parsed_hash[:series].to_s == "HB"
          rescue StandardError
            false
          end

          if is_handbook && dash_year.to_s.match?(/^\d{4}$/)
            # Create Edition with type="e" and id=dash_year for HB series
            edition_obj = Components::Edition.new(type: "e", id: dash_year)
            parsed_hash[:edition_from_year] = edition_obj
          else
            # For other series, treat dash_year as edition_dash_year for further processing
            parsed_hash[:edition_dash_year] = { dash_year: dash_year }
          end

          parsed_hash.delete(:second_number_edition_year)
        end

        # NEW: Fix for fips_month_year_after_part pattern
        # Pattern: "11-1-Sep1977" where parser returns fips_month_year_after_part={second_number="1", edition_month="Sep", edition_year="1977"}
        # Expected: number="11-1", edition with type="e", id="197709" (year + month number)
        if parsed_hash[:fips_month_year_after_part]
          second_num_value = parsed_hash[:fips_month_year_after_part][:second_number]
          month_str = parsed_hash[:fips_month_year_after_part][:edition_month]
          year_str = parsed_hash[:fips_month_year_after_part][:edition_year]

          # Extract second_number
          parsed_hash[:second_number] = second_num_value

          # Convert month abbreviation to month number and combine with year
          month_num = Date::ABBR_MONTHNAMES.index(month_str) ||
            Date::MONTHNAMES.index(month_str) ||
            month_str.to_i

          edition_id = if month_num&.positive?
                         "#{year_str}#{format('%02d', month_num)}"
                       else
                         year_str
                       end

          # Create Edition with type="e" and combined ID
          edition_obj = Components::Edition.new(type: "e", id: edition_id)
          parsed_hash[:edition_from_year] = edition_obj

          parsed_hash.delete(:fips_month_year_after_part)
        end

        # NEW: Fix for IR compound number vs edition pattern
        # Pattern: "84-2946" where parser returns first_number="84", edition_dash_year={dash_year="2946"}
        # For IR (InteragencyReport), 4-digit second numbers >= 1000 are typically editions
        # EXCEPT for:
        # - Numbers > 2699 which are clearly not valid years (like 2946)
        # - Patterns with embedded edition_e (like "76-1094e2") which should be compound
        if parsed_hash[:series]&.to_s == "IR" && parsed_hash[:first_number] && parsed_hash[:edition_dash_year]
          first_num = parsed_hash[:first_number].to_s
          dash_year = parsed_hash[:edition_dash_year][:dash_year].to_s

          # Check if first_number looks like a 2-digit year (00-99)
          if first_num.match?(/^\d{2}$/) && dash_year.match?(/^\d{4}$/)
            dash_year_num = dash_year.to_i
            # Valid year range for IR: 1901-2026 (NBS establishment to present)
            is_valid_year = dash_year_num.between?(1901, 2026)
            # If there's an embedded edition (e2, e3, etc.), treat as compound, not edition
            has_embedded_edition = parsed_hash[:edition_e]
            if is_valid_year && !has_embedded_edition
              # Edition format: "76e1000", "76e2013", "76e1100", "80e2100", "81e2300", "81e2400", "82e2500", "82e2600"
              parsed_hash[:first_number] =
                Components::Code.new(number: first_num)
              parsed_hash[:edition] =
                Components::Edition.new(type: "e", id: dash_year)
            else
              # Compound number: "84-2946" or "76-1094e2"
              parsed_hash[:first_number] =
                Components::Code.new(number: "#{first_num}-#{dash_year}")
            end
            parsed_hash.delete(:edition_dash_year)
          end
        end

        # NEW: Fix for edition_dash_year that's actually a second_number
        # Pattern: "250-1039" where parser returns edition_dash_year="1039"
        # Also handles RPT date ranges: "1946-1947" where edition_dash_year="1947"
        # but it should be second_number="1039" (not a year - years are 1900+ or 2000+)
        if parsed_hash[:first_number] && parsed_hash[:edition_dash_year] && !parsed_hash[:first_number].to_s.match?(/^[0-9]+[a-zA-Z]\d+$/)
          dash_year = parsed_hash[:edition_dash_year][:dash_year].to_s
          series = begin
            parsed_hash[:series].to_s
          rescue StandardError
            ""
          end

          # Check if dash_year is a valid year (1901-2026)
          dash_year_num = dash_year.to_i
          is_valid_year = dash_year_num.between?(1901, 2026)

          # Check if series uses dash-year as edition (HB, CS, FIPS)
          # These series convert dash-year to edition ONLY for valid years
          uses_dash_year_as_edition = ["HB", "CS", "FIPS"].include?(series)

          # GCR always converts dash-year to edition (e.g., "15-1000" -> "15e1000")
          is_gcr = series == "GCR"

          # IR only converts dash-year to edition for valid years (e.g., "76-1100" -> "76e1100")
          # but NOT for non-years like 2946 (e.g., "84-2946" stays as "84-2946")
          is_ir = series == "IR"

          # Check if series uses compound numbers with dash-year (RPT date ranges)
          is_rpt = series == "RPT"

          if is_rpt
            # For RPT (Report) series with date ranges, create compound number: "1946-1947"
            parsed_hash[:first_number] =
              Components::Code.new(number: "#{parsed_hash[:first_number]}-#{dash_year}")
            parsed_hash.delete(:edition_dash_year)
          elsif is_gcr
            # GCR always converts dash_year to edition regardless of whether it's a valid year
            # e.g., "15-1000" -> "15e1000", "15-1001" -> "15e1001"
            edition_obj = Components::Edition.new(type: "e", id: dash_year)
            parsed_hash[:edition_from_year] = edition_obj
            parsed_hash.delete(:edition_dash_year)
          elsif is_ir && is_valid_year
            # IR only converts valid years to edition
            # e.g., "76-1100" -> "76e1100", but "84-2946" stays as "84-2946"
            edition_obj = Components::Edition.new(type: "e", id: dash_year)
            parsed_hash[:edition_from_year] = edition_obj
            parsed_hash.delete(:edition_dash_year)
          elsif uses_dash_year_as_edition && is_valid_year
            # For HB, CS, FIPS: convert dash_year to edition ONLY if it's a valid year
            edition_obj = Components::Edition.new(type: "e", id: dash_year)
            parsed_hash[:edition_from_year] = edition_obj
            parsed_hash.delete(:edition_dash_year)
          elsif dash_year.to_i < 1900
            # For other series with dash_year < 1900, treat as second_number
            parsed_hash[:second_number] = dash_year
            parsed_hash.delete(:edition_dash_year)
          elsif is_valid_year
            # For remaining cases with valid year (>= 1901), check if series uses it as edition
            is_handbook = series == "HB"
            is_commercial_standard = series == "CS"
            is_fips = series == "FIPS"

            if is_handbook || is_commercial_standard || is_fips
              edition_obj = Components::Edition.new(type: "e", id: dash_year)
              parsed_hash[:edition_from_year] = edition_obj
              parsed_hash.delete(:edition_dash_year)
            end
          end
        end

        # NEW: Fix for edition embedded in second_number
        # Pattern: "53e5" where second_number="53e5" with edition "e5" embedded
        # Expected: second_number="53", edition with type="e" and id="5"
        if parsed_hash[:second_number]&.to_s&.match?(/^\d+[a-zA-Z]\d+$/)
          second_str = parsed_hash[:second_number].to_s
          # Extract edition from second_number (e.g., "53e5" -> "53" + edition "e5")
          if match_data = second_str.match(/^(\d+)([a-zA-Z])(\d+)$/)
            base_number = match_data[1]
            edition_letter = match_data[2]
            edition_id = match_data[3]

            # Update second_number and create Edition component
            parsed_hash[:second_number] =
              Components::Code.new(number: base_number)
            # Store Edition component for later (after identifier is initialized)
            edition_from_embedded = Components::Edition.new(
              type: edition_letter, id: edition_id,
            )
          end
        end

        # NEW: Check for CIRC supplement pattern
        # Note: :base_portion is lost during parser merge, so check for supplement indicators
        if parsed_hash[:supplement_date_range] || parsed_hash[:supplement_slash_year] ||
            parsed_hash[:supplement_month_year] || parsed_hash[:supplement_year] ||
            parsed_hash[:supplement] || parsed_hash[:base_portion]
          return build_circular_supplement(parsed_hash)
        end

        # Locate the appropriate identifier class via Router
        identifier = @router.locate_identifier_klass(parsed_hash).new

        # NEW: If we extracted a letter suffix Part, assign it now (after identifier initialization)
        if letter_suffix_part
          identifier.part = letter_suffix_part
        end

        # NEW: If we extracted an Edition from edition_dash_year, assign it now
        if edition_from_dash_year
          identifier.edition = edition_from_dash_year
        end

        # NEW: If we extracted an Edition from embedded second_number, assign it now
        if edition_from_embedded
          identifier.edition = edition_from_embedded
        end

        # NEW: If we extracted an Edition from edition_dash_year with embedded edition in first_number, assign it now
        if parsed_hash[:edition_embedded_with_year]
          identifier.edition = parsed_hash[:edition_embedded_with_year]
        end

        # NEW: If we extracted an Edition from edition_dash_year as year-only edition, assign it now
        if parsed_hash[:edition_from_year]
          identifier.edition = parsed_hash[:edition_from_year]
        end

        # NEW: If we extracted an Edition from edition_dash_year with embedded edition, assign it now
        if parsed_hash[:edition_with_year]
          identifier.edition = parsed_hash[:edition_with_year]
        end

        # NEW: If we have a direct Edition from parsed_hash, assign it now
        # (Used for IR patterns where large dash_year is treated as edition)
        if parsed_hash[:edition]
          identifier.edition = parsed_hash[:edition]
        end

        # Track first_number, second_number, decimal_number, and letter_number for building compound number
        first_num = nil
        second_num = nil
        decimal_num = nil
        letter_num = nil
        part_num = nil
        extracted_revision = nil

        # Accumulate supplement signals from the casts (a flat value string,
        # the has_revision flag, and date-range start/end) and fold them into a
        # single Components::Supplement at the end. They are intercepted (not
        # assigned) because :supplement is now a component attribute, so a raw
        # string must never be written to it directly.
        supp = { value: nil, has_revision: false, range_start: nil,
                 range_end: nil, present: false }
        capture_supplement = lambda do |k, v|
          case k
          when :supplement then supp[:value] = v
          when :supplement_has_revision then supp[:has_revision] = !!v
          when :supplement_date_range_start then supp[:range_start] = v
          when :supplement_date_range_end then supp[:range_end] = v
          else return false
          end
          supp[:present] = true
          true
        end

        # Cast and assign all attributes
        parsed_hash.each_pair do |key, value|
          realized_components = @caster.cast(key.to_sym, value, parsed_hash) # Pass parsed_hash for context
          next if realized_components.nil?
          next if !realized_components.is_a?(Hash) && capture_supplement.call(
            key.to_sym, realized_components
          )

          # Track number components
          if key == :first_number && realized_components.is_a?(Components::Code)
            first_num = realized_components
          elsif key == :second_number && realized_components.is_a?(Components::Code)
            second_num = realized_components
          elsif key == :crpl_range && realized_components.is_a?(Components::Code)
            # crpl_range is treated as second_number for compound number construction
            second_num = realized_components
          elsif key == :part_number
            part_num = value.to_s
          # NEW: Track decimal_number for IR identifiers (e.g., 80-2073.3)
          # decimal_number is stored as hash with :decimal_base and :decimal_suffix
          elsif key == :decimal_number && realized_components.is_a?(Hash)
            # Store the raw hash for processing during compound number construction
            decimal_num = realized_components
          # NEW: Track letter_number for NCSTAR identifiers (e.g., 1-1A, 1-3B)
          # letter_number is stored as hash with :letter_base and :letter_suffix
          # For SpecialPublication (e.g., 800-56A), we need to:
          # 1. Store the original hash for compound number construction (letter_base)
          # 2. Create a Part component from letter_suffix
          elsif key == :letter_number
            # Store the original hash for compound number construction
            letter_num = value
            # If cast returned a hash with a part component, it will be assigned below
          end

          # Handle composite hash returns (multiple related values)
          case realized_components
          when Hash
            realized_components.each_pair do |sub_key, sub_value|
              # Track first_number from hash returns
              if sub_key == :first_number && sub_value.is_a?(Components::Code)
                first_num = sub_value
              # Track second_number from hash returns
              elsif sub_key == :second_number && sub_value.is_a?(Components::Code)
                second_num = sub_value
              # NEW: Handle second_number with edition (hash with :number_only and :edition_id)
              # For "126r2013": parser returns {:number_only=>"126", :edition_id=>"2013"}
              # We DON'T convert to Components::Code here; we process it during compound number construction
              elsif sub_key == :second_number && sub_value.is_a?(Hash)
                if sub_value[:number_only] && sub_value[:edition_id]
                  # Store the raw hash for processing during compound number construction
                  # This prevents the hash from being assigned directly to identifier.number
                  second_num = sub_value
                  extracted_revision = "r" # Mark as revision format
                end
              # Track revision extraction
              elsif sub_key == :revision
                extracted_revision = sub_value
              end
              # Skip assignment for second_number hashes - they'll be processed during compound number construction
              next if sub_key == :second_number && sub_value.is_a?(Hash) && sub_value[:number_only]

              # Intercept supplement signals into the accumulator instead of
              # assigning them (supplement is now a component built at the end).
              next if capture_supplement.call(sub_key, sub_value)

              attrs = identifier.class.attributes
              setter = "#{sub_key}="
              if attrs.key?(sub_key.to_sym)
                identifier.public_send(setter,
                                       sub_value)
              end
            end
          else
            attrs = identifier.class.attributes
            setter = "#{key}="
            if attrs.key?(key.to_sym)
              identifier.public_send(setter,
                                     realized_components)
            end
          end
        end

        # Build compound number from first_number and second_number
        if first_num && !identifier.number
          # Skip if this is a v#n# pattern - now handled as Part component
          if identifier.volume && identifier.issue_number
          # V#n# pattern handled as Part in first_number cast
          # NEW: Handle decimal number pattern (e.g., 80-2073.3 for IR identifiers)
          # decimal_num is {:decimal_base => "2073", :decimal_suffix => "3"}
          elsif decimal_num
            decimal_base = decimal_num[:decimal_base].to_s
            decimal_suffix = decimal_num[:decimal_suffix].to_s
            identifier.number = Components::Code.new(number: "#{first_num.value}-#{decimal_base}.#{decimal_suffix}")
          # NEW: Handle letter number pattern (e.g., 1-1A, 1-3B for NCSTAR identifiers)
          # letter_num is {:letter_base => "1", :letter_suffix => "A"}
          # Also handles IR series "R" suffix: "79-1786R" -> "79-1786r1"
          elsif letter_num
            letter_base = letter_num[:letter_base].to_s
            letter_suffix = letter_num[:letter_suffix].to_s

            # SPECIAL CASE: IR series with "R" suffix means "r1" (revision 1)
            # "79-1786R" -> number="79-1786", edition="r1"
            is_ir = parsed_hash[:series]&.to_s == "IR"
            if is_ir && letter_suffix == "R"
              # IR "R" suffix converts to revision format "r1"
              identifier.number = Components::Code.new(number: "#{first_num.value}-#{letter_base}")
              edition_obj = Components::Edition.new(type: "r", id: "1")
              identifier.edition = edition_obj
              identifier.edition_component = edition_obj
              identifier.revision = "r1"
            # If a Part component was already set (from cast handler), the letter_suffix
            # is a separate Part component (e.g., SpecialPublication "800-56A" -> number="800-56", part="A")
            # Otherwise, letter_suffix is part of the number (e.g., NCSTAR "1-1A" -> number="1-1A")
            elsif identifier.part
              # SpecialPublication pattern: letter_suffix is separate Part component
              identifier.number = Components::Code.new(number: "#{first_num.value}-#{letter_base}")
            else
              # NCSTAR pattern: letter_suffix is part of the number
              identifier.number = Components::Code.new(number: "#{first_num.value}-#{letter_base}#{letter_suffix}")
            end
          elsif second_num
            # Check for special patterns first
            # NEW: Handle second_number with edition (hash from parser pattern)
            # For "126r2013": second_num is {:number_only=>"126", :edition_id=>"2013"}
            if second_num.is_a?(Hash) && second_num[:number_only] && second_num[:edition_id]
              # Extract components from hash
              number_part = second_num[:number_only].to_s
              edition_id = second_num[:edition_id].to_s

              # Create Edition component
              edition_obj = Components::Edition.new(type: "r", id: edition_id)

              identifier.number = Components::Code.new(number: "#{first_num.value}-#{number_part}")
              identifier.edition = edition_obj
              identifier.edition_component = edition_obj
              identifier.revision = "r#{edition_id}"
            # CS Emergency pattern: e104-43 -> number=104, edition_year=1943
            # Logic: e104-43 means "emergency 104 from 1943" (43 = 1943)
            elsif first_num.value.to_s.match?(/^e(\d{3})$/) &&
                second_num.value.to_s.match?(/^\d{2}$/)
              match_data = first_num.value.to_s.match(/^e(\d{3})$/)
              number_part = match_data[1] # 104
              year_suffix = second_num.value.to_s # 43
              # Edition year: 19 + 43 = 1943 (1900s + year suffix)
              edition_year = "19#{year_suffix}"

              # Create Edition component
              edition_obj = Components::Edition.new(type: "e", id: edition_year)

              identifier.number = Components::Code.new(number: number_part)
              identifier.edition = edition_obj
              identifier.edition_component = edition_obj
            elsif first_num.value.to_s.match?(/^(\d+)e(\d+)$/) &&
                second_num.value.to_s.match?(/^\d{2,4}$/)
              # Pattern: "11e2-1915" OR "123e2-50" parsed as first="11e2"|"123e2", second="1915"|"50"
              # Extract number and edition from first_num
              match_data = first_num.value.to_s.match(/^(\d+)e(\d+)$/)
              number_part = match_data[1]
              edition_id = match_data[2]
              year_part = second_num.value.to_s

              # Expand 2-digit year to 4-digit (50 -> 1950)
              year_part = "19#{year_part}" if year_part.length == 2

              identifier.number = Components::Code.new(number: number_part)

              # For edition+year patterns, handling depends on identifier type:
              # - CIRC: edition number + year as additional_text, rendered with dot ("11e2-1915" -> "11e2.1915")
              # - HB, others: edition number + year as additional_text, rendered with dash ("44e2-1955")
              # Both use the same Edition component structure, only rendering differs
              edition_obj = Components::Edition.new(type: "e",
                                                    id: edition_id, additional_text: year_part)
              identifier.edition = edition_obj
              identifier.edition_component = edition_obj
            elsif first_num.value.to_s.match?(/^(\d+)supp?$/) &&
                second_num.value.to_s.match?(/^\d{4}$/)
              # Pattern: "25supp-1924" parsed as first="25supp", second="1924"
              number_part = first_num.value.to_s.match(/^(\d+)supp?$/)[1]
              year_part = second_num.value.to_s

              identifier.number = Components::Code.new(number: number_part)
              supp[:value] = year_part
              supp[:present] = true
            elsif second_num.value.to_s.match?(/^(\d+)supp?$/)
              # Pattern: "800-53sup"/"800-53supp" - bare marker on the compound
              # second number. Strip it and isolate as supplement="" (single-p).
              second_part = second_num.value.to_s.match(/^(\d+)supp?$/)[1]
              compound = "#{first_num.value}-#{second_part}"
              identifier.number = Components::Code.new(number: compound)
              supp[:value] = ""
              supp[:present] = true
            elsif identifier.is_a?(Identifiers::TechnicalNote) &&
                second_num.value.to_s.match?(/^(19|20)\d{2}$/)
              # SPECIAL CASE FOR TN: second_num is edition year
              # Following "date IS edition" rule: -1993 becomes Edition(type: "e", id: "1993")
              identifier.number = first_num
              edition_obj = Components::Edition.new(type: "e",
                                                    id: second_num.value.to_s)
              identifier.edition_component = edition_obj
              identifier.edition = edition_obj
              identifier.edition_year = second_num.value.to_s
            elsif part_num && parsed_hash[:series].to_s.include?("IR")
              # Normal compound number
              # For IR identifiers, part_number should be a Part component (type="pt"), not in compound number
              identifier.part = Components::Part.new(type: "pt",
                                                     value: part_num)
              identifier.number = Components::Code.new(number: "#{first_num.value}-#{second_num.value}")
            # For IR, create Part component with type="pt"
            else
              # For GCR and others, include part number in compound number
              compound_value = "#{first_num.value}-#{second_num.value}"
              compound_value += "-#{part_num}" if part_num
              identifier.number = Components::Code.new(number: compound_value)
            end
          else
            # No second_num, use first_num directly
            identifier.number = first_num
          end
        end

        # Apply extracted revision if not already set
        if extracted_revision && !identifier.edition
          # Convert extracted revision to Edition component
          identifier.edition = Components::Edition.new(type: "r",
                                                       id: extracted_revision.to_s)
        end

        # IR-SPECIFIC: Handle compound numbers that were converted to edition+year format
        # For IR identifiers, "84-2946" should remain as compound number, not become "84e2946"
        # The preprocessing converts "84-2946" to "84e2946", so we need to convert it back for IR
        is_ir = begin
          parsed_hash[:series].to_s.include?("IR")
        rescue StandardError
          false
        end
        if is_ir && identifier.number && identifier.number.value.to_s.match?(/^(\d+)e(\d{4})$/)
          # Extract the compound number parts from the edition+year format
          match_data = identifier.number.value.to_s.match(/^(\d+)e(\d{4})$/)
          number_part = match_data[1] # "84"
          year_part = match_data[2] # "2946"

          # Convert to compound number format
          identifier.number = Components::Code.new(number: "#{number_part}-#{year_part}")

          # Clear the edition that was incorrectly set from the year
          identifier.edition = nil
          identifier.edition_component = nil
        end

        # Set publisher_was_parsed flag if publisher was set
        # This includes cases where publisher was explicitly parsed or extracted from series prefix
        identifier.publisher_was_parsed = true if identifier.publisher

        # NEW: Convert revision with month+year to update component (V1 compatibility)
        # Patterns like "NIST IR 4743rJun1992" should be rendered as "NIST IR 4743/Upd1-199206"
        if parsed_hash[:revision_month] && parsed_hash[:revision_year]
          # rJun1992 pattern: revision_month is "Jun", revision_year is "1992"
          month_str = parsed_hash[:revision_month].to_s
          year_str = parsed_hash[:revision_year].to_s

          # Convert month name to number (Jun -> 06, Nov -> 11, etc.)
          month_num = @caster.month_name_to_number(month_str)

          # Create update component with default number=1, converted year and month
          update_obj = Components::Update.new(
            number: "1",
            year: year_str,
            month: sprintf("%02d", month_num),
            prefix: "slash", # V1 uses /Upd format
          )

          # Set both V2 component and legacy attribute for backward compatibility
          identifier.update_component = update_obj
          identifier.update = update_obj

          # Clear the legacy revision_year/revision_month attributes
          identifier.revision_year = nil
          identifier.revision_month = nil
        end

        # Fold the accumulated supplement signals into the single structured
        # supplement component (the source of truth).
        if (supp[:present] || supp[:has_revision]) &&
            identifier.class.attributes.key?(:supplement)
          identifier.supplement = supplement_from(
            value: supp[:value], has_revision: supp[:has_revision],
            range_start: supp[:range_start], range_end: supp[:range_end]
          )
        end

        identifier
      end

      # Build a Components::Supplement from the builder's accumulated raw signals
      # (flat value string, has_revision flag, fused date-range start/end). This
      # is the one place raw supplement text becomes the structured component.
      def supplement_from(value:, has_revision:, range_start:, range_end:)
        if range_start || range_end
          component = Components::Supplement.new
          # Split the fused "Jun1925"/"Jun1926" strings into isolated start/end
          # month+year nodes (start reuses :month/:year, end uses *_end).
          if range_start && (m = range_start.match(/\A([A-Za-z]{3,9})(\d{4})\z/))
            component.month = m[1]
            component.year = m[2]
          end
          if range_end && (m = range_end.match(/\A([A-Za-z]{3,9})(\d{4})\z/))
            component.month_end = m[1]
            component.year_end = m[2]
          end
          component
        else
          Components::Supplement.from_raw(value, has_revision: has_revision)
        end
      end

      # Build CircularSupplement with base_identifier wrapping
      # @param parsed_hash [Hash] the parsed supplement data
      # Build a CIRC/LCIRC supplement. Most forms collapse onto the base
      # identifier's normal class (Circular / LetterCircular) with isolated
      # supplement attributes, so they share one model with every other series
      # and are queryable by part. The V1-compat update forms (slash-year
      # "118supp3/1926" -> ".../Upd1-192603"; implicit revision "145r11/1925")
      # render through an Update component the flat supplement model can't
      # express, so they stay on the CircularSupplement wrapper for now.
      def build_circular_supplement(parsed_hash)
        if parsed_hash[:supplement_slash_year].is_a?(Hash) ||
            parsed_hash[:implicit_supplement].is_a?(Hash)
          return build_circular_supplement_wrapper(parsed_hash)
        end

        series_value = if parsed_hash[:circ_series].is_a?(Hash)
                         parsed_hash[:circ_series][:series]
                       else
                         parsed_hash[:series]
                       end

        # Date-range supplement (no base document): a plain base identifier with
        # no number, carrying the range. parsed_format is left at the default so
        # a dotted MR input still normalizes to the spaced short form.
        if parsed_hash[:supplement_date_range].is_a?(Hash)
          range = parsed_hash[:supplement_date_range]
          identifier = build({ series: series_value })
          ms = range[:supp_month_start]&.to_s
          ys = range[:supp_year_start]&.to_s
          me = range[:supp_month_end]&.to_s
          ye = range[:supp_year_end]&.to_s
          identifier.supplement = supplement_from(
            value: nil, has_revision: false,
            range_start: (ms && ys ? "#{ms}#{ys}" : nil),
            range_end: (me && ye ? "#{me}#{ye}" : nil)
          )
          return identifier
        end

        # Based supplement: build the base, then attach the supplement as an
        # isolated component on that normal class.
        identifier = build_circular_supplement_base(parsed_hash, series_value)
        raw = if parsed_hash[:supplement_month_year]
                parsed_hash[:supplement_month_year].to_s
              elsif parsed_hash[:supplement_year]
                parsed_hash[:supplement_year].to_s
              else
                "" # supplement_empty or bare marker
              end
        identifier.supplement = Components::Supplement.from_raw(raw)
        identifier
      end

      # Build just the base identifier for a based CIRC/LCIRC supplement, from
      # base_portion (number, optional edition "101e2" or letter suffix "378G")
      # or the merged first_number fallback. Returns the normal class.
      def build_circular_supplement_base(parsed_hash, series_value)
        base_portion = parsed_hash[:base_portion]
        unless base_portion
          return build({
                         publisher: parsed_hash[:publisher],
                         series: series_value || parsed_hash[:series],
                         first_number: parsed_hash[:first_number],
                         parsed_format: parsed_hash[:parsed_format],
                       })
        end

        base_number = if base_portion.is_a?(Hash)
                        base_portion[:simple_number] || base_portion[:base_number]
                      else
                        base_portion
                      end

        letter_suffix = nil
        if base_portion.is_a?(Hash) && base_portion[:letter_suffix]
          letter_suffix = base_portion[:letter_suffix].to_s.upcase
        end

        publisher_value = nil
        if parsed_hash[:circ_series].is_a?(Hash) && parsed_hash[:circ_series][:series]
          series_str = parsed_hash[:circ_series][:series].to_s
          publisher_value = series_str.split.first if series_str.include?(" ")
        end

        has_edition = base_portion.is_a?(Hash) && base_portion[:edition_number]

        base_number_with_suffix = base_number.to_s
        base_number_with_suffix += letter_suffix if letter_suffix
        if has_edition
          base_number_with_suffix += "e#{base_portion[:edition_number]}"
        end

        base_hash = {
          series: series_value,
          first_number: base_number_with_suffix,
          parsed_format: parsed_hash[:parsed_format],
        }
        base_hash[:publisher] = publisher_value if publisher_value
        base_hash[:edition_e] =
          { edition_id: base_portion[:edition_number] } if has_edition

        build(base_hash)
      end

      # @return [Identifiers::CircularSupplement] the supplement identifier
      def build_circular_supplement_wrapper(parsed_hash)
        supplement = Identifiers::CircularSupplement.new

        # Extract series from circ_series if present (nested structure from parser)
        series_value = nil
        if parsed_hash[:circ_series].is_a?(Hash)
          series_value = parsed_hash[:circ_series][:series]
        elsif parsed_hash[:series]
          series_value = parsed_hash[:series]
        end

        # Handle date range supplement (no base)
        if parsed_hash[:supplement_date_range].is_a?(Hash)
          range = parsed_hash[:supplement_date_range]
          month_start = range[:supp_month_start]&.to_s
          year_start = range[:supp_year_start]&.to_s
          month_end = range[:supp_month_end]&.to_s
          year_end = range[:supp_year_end]&.to_s

          supplement.supplement_date_range_start = "#{month_start}#{year_start}" if month_start && year_start
          supplement.supplement_date_range_end = "#{month_end}#{year_end}" if month_end && year_end

          return supplement
        end

        # Build base identifier from base_portion (if present)
        # If not present (because it was merged during parsing), use first_number
        if parsed_hash[:base_portion]
          # Extract the actual number value from base_portion hash
          # base_portion can be: {:simple_number=>"118"}, {:base_number=>"145", :revision_letter=>"r", :revision_number=>"11"}, etc.
          base_portion = parsed_hash[:base_portion]
          base_number = if base_portion.is_a?(Hash)
                          # Extract the value from whichever key is present
                          base_portion[:simple_number] || base_portion[:base_number]
                        else
                          base_portion
                        end

          # Check for letter suffix in base_portion (e.g., "378G")
          letter_suffix = nil
          if base_portion.is_a?(Hash) && base_portion[:letter_suffix]
            letter_suffix = base_portion[:letter_suffix].to_s.upcase
          end

          # Extract publisher from circ_series if present
          publisher_value = nil
          if parsed_hash[:circ_series].is_a?(Hash) && parsed_hash[:circ_series][:series]
            series_str = parsed_hash[:circ_series][:series].to_s
            # Extract publisher from series (e.g., "NBS LCIRC" -> "NBS")
            publisher_value = series_str.split.first if series_str.include?(" ")
          end

          # Check if base_portion has revision (for patterns like "145r11/1925")
          has_revision = base_portion.is_a?(Hash) && base_portion[:revision_letter] && base_portion[:revision_number]

          # NEW: Check if base_portion has edition_number (for patterns like "101e2")
          has_edition = base_portion.is_a?(Hash) && base_portion[:edition_number]

          # Include letter suffix in base_number if present
          # Also include edition_number if present (for "101e2" pattern)
          base_number_with_suffix = base_number.to_s
          if letter_suffix
            base_number_with_suffix += letter_suffix
          end
          if has_edition
            base_number_with_suffix += "e#{base_portion[:edition_number]}"
          end

          # Reconstruct parse hash for base identifier
          base_hash = {
            series: series_value,
            first_number: base_number_with_suffix,
            parsed_format: parsed_hash[:parsed_format],
          }
          base_hash[:publisher] = publisher_value if publisher_value

          # NEW: Add edition_number to base_hash for patterns like "101e2"
          # This will be processed by the normal build() logic to create Edition component
          if has_edition
            # Create edition_e hash that will be converted to Edition with type="e"
            base_hash[:edition_e] =
              { edition_id: base_portion[:edition_number] }
          end

          # Recursively build base identifier
          # This will go through normal build() process which extracts edition from "101e2"
          supplement.base_identifier = build(base_hash)

          # NEW: Handle revision + implicit supplement pattern (e.g., "145r11/1925")
          # Create update format: "Upd1-{year}{revision_number}"
          if has_revision && parsed_hash[:implicit_supplement].is_a?(Hash)
            revision_number = base_portion[:revision_number].to_s
            supplement_year = parsed_hash[:implicit_supplement][:implicit_supplement_year].to_s

            # Create Update component for revision+supplement pattern
            # Format: Upd1-{year}{revision_number} (always use "1" and concatenate year+revision)
            update_value = "Upd1-#{supplement_year}#{revision_number}"
            supplement.update = update_value
            supplement.implicit_supplement = true # Mark as implicit supplement for rendering
          end
        elsif parsed_hash[:first_number]
          # base_portion was lost during merge, use first_number to build base identifier
          base_hash = {
            publisher: parsed_hash[:publisher],
            series: series_value || parsed_hash[:series],
            first_number: parsed_hash[:first_number],
            parsed_format: parsed_hash[:parsed_format],
          }

          # Recursively build base identifier
          supplement.base_identifier = build(base_hash)
        end

        # Build supplement edition from captured data
        if parsed_hash[:supplement_month_year]
          # Parse month+year format like "Jan1924"
          month_year = parsed_hash[:supplement_month_year].to_s
          supplement.edition = Components::Edition.new(type: "s",
                                                       id: month_year)
        elsif parsed_hash[:supplement_year]
          # Just year: 1924
          supplement.edition = Components::Edition.new(type: "s",
                                                       id: parsed_hash[:supplement_year].to_s)
        elsif parsed_hash[:supplement_slash_year].is_a?(Hash)
          # NEW: Handle supplement_slash_year pattern (e.g., "sup12/1926", "sup1/1927")
          # V1 format: "Upd1-192612" where "1" is fixed and "192612" is year+number concatenated
          # Single digit numbers are zero-padded: "sup1/1927" -> "Upd1-192701"
          supp_hash = parsed_hash[:supplement_slash_year]
          supp_number = supp_hash[:supp_number]&.to_s
          supp_year = supp_hash[:supp_year]&.to_s

          # Pad supplement number to 2 digits for single-digit numbers
          supp_number_padded = supp_number.rjust(2, "0")

          # Create Update component for supplement (V1 compatibility uses Update for supplements)
          # Format: Upd1-{year}{padded_number} (always use "1" and concatenate year+padded_number)
          update_value = "Upd1-#{supp_year}#{supp_number_padded}"
          supplement.update = update_value
        elsif parsed_hash[:supplement_empty]
          # Empty supplement - no edition
          # supplement.edition remains nil
        end

        supplement
      end
    end
  end
end
