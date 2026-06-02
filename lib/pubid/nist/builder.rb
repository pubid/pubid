# frozen_string_literal: true

module Pubid
  module Nist
    # Builder class for constructing NIST identifier objects from parsed data
    # Single Responsibility: Transform parsed data into identifier objects
    #
    # CRITICAL ARCHITECTURE PRINCIPLE:
    # Builder NEVER makes business logic decisions.
    # Builder ONLY casts parsed data to domain objects.
    class Builder < Pubid::Builder::Base
      # Translation normalization map (V1 compatibility)
      TRANSLATION_MAP = {
        "es" => "spa",
        "sp" => "spa",
        "pt" => "por",
        "id" => "ind",
        "chi" => "zho",
        "viet" => "vie",
        "port" => "por",
        "esp" => "spa",
      }.freeze

      def initialize(scheme)
        @scheme = scheme
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

          # GCR always converts dash-year to edition (e.g., "15-1000" → "15e1000")
          is_gcr = series == "GCR"

          # IR only converts dash-year to edition for valid years (e.g., "76-1100" → "76e1100")
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
            # e.g., "15-1000" → "15e1000", "15-1001" → "15e1001"
            edition_obj = Components::Edition.new(type: "e", id: dash_year)
            parsed_hash[:edition_from_year] = edition_obj
            parsed_hash.delete(:edition_dash_year)
          elsif is_ir && is_valid_year
            # IR only converts valid years to edition
            # e.g., "76-1100" → "76e1100", but "84-2946" stays as "84-2946"
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
          # Extract edition from second_number (e.g., "53e5" → "53" + edition "e5")
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

        # Locate the appropriate identifier class via Scheme
        identifier = @scheme.locate_identifier_klass(parsed_hash).new

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
          realized_components = cast(key.to_sym, value, parsed_hash) # Pass parsed_hash for context
          next if realized_components.nil?
          next if !realized_components.is_a?(Hash) && capture_supplement.call(key.to_sym, realized_components)

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
          # Also handles IR series "R" suffix: "79-1786R" → "79-1786r1"
          elsif letter_num
            letter_base = letter_num[:letter_base].to_s
            letter_suffix = letter_num[:letter_suffix].to_s

            # SPECIAL CASE: IR series with "R" suffix means "r1" (revision 1)
            # "79-1786R" → number="79-1786", edition="r1"
            is_ir = parsed_hash[:series]&.to_s == "IR"
            if is_ir && letter_suffix == "R"
              # IR "R" suffix converts to revision format "r1"
              identifier.number = Components::Code.new(number: "#{first_num.value}-#{letter_base}")
              edition_obj = Components::Edition.new(type: "r", id: "1")
              identifier.edition = edition_obj
              identifier.edition_component = edition_obj
              identifier.revision = "r1"
            # If a Part component was already set (from cast handler), the letter_suffix
            # is a separate Part component (e.g., SpecialPublication "800-56A" → number="800-56", part="A")
            # Otherwise, letter_suffix is part of the number (e.g., NCSTAR "1-1A" → number="1-1A")
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
            # CS Emergency pattern: e104-43 → number=104, edition_year=1943
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

              # Expand 2-digit year to 4-digit (50 → 1950)
              year_part = "19#{year_part}" if year_part.length == 2

              identifier.number = Components::Code.new(number: number_part)

              # For edition+year patterns, handling depends on identifier type:
              # - CIRC: edition number + year as additional_text, rendered with dot ("11e2-1915" → "11e2.1915")
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

          # Convert month name to number (Jun → 06, Nov → 11, etc.)
          month_num = month_name_to_number(month_str)

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
            identifier.respond_to?(:supplement=)
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

      # Convert month name to month number
      # @param month_name [String] month abbreviation (Jan, Feb, Mar, etc.)
      # @return [Integer] month number (1-12)
      def month_name_to_number(month_name)
        month_map = {
          "Jan" => 1, "January" => 1,
          "Feb" => 2, "February" => 2,
          "Mar" => 3, "March" => 3,
          "Apr" => 4, "April" => 4,
          "May" => 5,
          "Jun" => 6, "June" => 6,
          "Jul" => 7, "July" => 7,
          "Aug" => 8, "August" => 8,
          "Sep" => 9, "Sept" => 9, "September" => 9,
          "Oct" => 10, "October" => 10,
          "Nov" => 11, "November" => 11,
          "Dec" => 12, "December" => 12
        }
        month_map[month_name] || 1 # Default to January if not found
      end

      # Build CircularSupplement with base_identifier wrapping
      # @param parsed_hash [Hash] the parsed supplement data
      # Build a CIRC/LCIRC supplement. Most forms collapse onto the base
      # identifier's normal class (Circular / LetterCircular) with isolated
      # supplement attributes, so they share one model with every other series
      # and are queryable by part. The V1-compat update forms (slash-year
      # "118supp3/1926" → ".../Upd1-192603"; implicit revision "145r11/1925")
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
        base_hash[:edition_e] = { edition_id: base_portion[:edition_number] } if has_edition

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
          # Single digit numbers are zero-padded: "sup1/1927" → "Upd1-192701"
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

      private

      # Cast parsed value to appropriate component type
      # ALL conversions happen in this single method
      # @param type [Symbol] the parameter type
      # @param value [Object] the parsed value
      # @param parsed_hash [Hash] the full parsed hash for context
      # @return [Object, Hash, nil] the cast component(s)
      def cast(type, value, parsed_hash = {})
        case type
        when :publisher
          return nil if value.nil? || value.to_s.strip.empty?

          Components::Publisher.new(publisher: value.to_s)

        when :series
          return nil if value.nil? || value.to_s.strip.empty?

          str_value = value.to_s
          publisher_extracted = nil

          # For compound series like "NBS CIRC", extract publisher and series separately
          if str_value.start_with?("NBS ")
            publisher_extracted = "NBS"
            str_value = str_value.sub("NBS ", "")
          end

          # Return composite hash with both publisher and series if extracted
          if publisher_extracted
            {
              publisher: Components::Publisher.new(publisher: publisher_extracted),
              series: Components::Code.new(number: str_value),
            }
          else
            Components::Code.new(number: str_value)
          end

        when :volume_number
          # Volume from v#n# pattern - return Volume component
          return nil if value.nil? || value.to_s.strip.empty?

          { volume: Components::Volume.new(value: value.to_s) }

        when :issue_number
          # Issue number from v#n# pattern - return Part component
          return nil if value.nil? || value.to_s.strip.empty?

          { part: Components::Part.new(type: "n", value: value.to_s) }

        when :part_number
          # Part number from GCR pattern (e.g., 85-3273-37)
          # Return raw value for inclusion in compound number
          return nil if value.nil? || value.to_s.strip.empty?

          value # Return raw value to be tracked in builder

        when :letter_number
          # Letter number pattern (e.g., 800-56A, 1-1A for NCSTAR, 73-197Ur for IR)
          # Parser returns: {:letter_base=>"56", :letter_suffix=>"A"} or
          # {:letter_base=>"197", :letter_suffix=>"U", :letter_suffix_extra=>"r"}
          # For SpecialPublication, create Part component with letter suffix as value
          # For MONO and NCSTAR, preserve letter suffix as part of the number (return raw value)
          return nil if value.nil? || !value.is_a?(Hash)

          letter_suffix = value[:letter_suffix]&.to_s&.strip
          letter_suffix_extra = value[:letter_suffix_extra]&.to_s&.strip

          # Combine letter_suffix and letter_suffix_extra (e.g., "U" + "r" = "Ur")
          full_suffix = if letter_suffix_extra && !letter_suffix_extra.empty?
                          letter_suffix + letter_suffix_extra
                        else
                          letter_suffix
                        end

          return nil if full_suffix.nil? || full_suffix.empty?

          # Check if this is a MONO or NCSTAR series
          # For these series, the letter suffix should be part of the number, not a separate Part component
          # For IR with "R" or "Ur" suffix, also return raw value so builder can convert to edition "r1"
          is_mono = begin
            parsed_hash[:series].to_s.include?("MONO")
          rescue StandardError
            false
          end
          is_ncstar = begin
            parsed_hash[:series].to_s.include?("NCSTAR")
          rescue StandardError
            false
          end
          # IR with "R" suffix needs special handling (convert to edition "r1")
          # Also handle "Ur" which combines uppercase U with lowercase r
          is_ir_with_r = begin
            parsed_hash[:series].to_s.include?("IR") && (letter_suffix == "R" || full_suffix == "Ur")
          rescue StandardError
            false
          end

          if is_mono || is_ncstar || is_ir_with_r
            # For MONO and NCSTAR, preserve letter suffix as part of the number
            # For IR with "R" or "Ur", return raw value so builder can convert "79-1786R" to "79-1786r1"
            # Return raw value so builder can construct proper format
            value[:letter_suffix] = full_suffix
            value
          else
            # For SpecialPublication and others, create Part component
            { part: Components::Part.new(type: "", value: full_suffix.upcase) }
          end

        when :fips_part
          # Part number from FIPS date pattern (e.g., 11-1-Sep30/1977)
          # Return Part component with pt type
          return nil if value.nil? || value.to_s.strip.empty?

          { part: Components::Part.new(type: "pt", value: value.to_s) }

        when :owmwp_date_number
          # OWMWP date-based number format (MM-DD-YYYY)
          # Parser returns: {:owmwp_month=>"06", :owmwp_day=>"13", :owmwp_year=>"2018"}
          # Convert to number + edition: "06-13" + edition "e2018"
          return nil if value.nil?

          number_part = "#{value[:owmwp_month]}-#{value[:owmwp_day]}"
          edition_part = Components::Edition.new(type: "e",
                                                 id: value[:owmwp_year])
          { first_number: Components::Code.new(number: number_part), edition: edition_part }

        when :first_number, :second_number
          return nil if value.nil? || value.to_s.strip.empty?

          # NEW: Handle OWMWP date-based number (nested hash structure)
          # Parser returns: {:owmwp_date_number=>{:owmwp_month=>"06", :owmwp_day=>"13", :owmwp_year=>"2018"}}
          # Convert to number + edition: "06-13" + edition "e2018"
          if value.is_a?(Hash) && value[:owmwp_date_number]
            owmwp_hash = value[:owmwp_date_number]
            number_part = "#{owmwp_hash[:owmwp_month]}-#{owmwp_hash[:owmwp_day]}"
            edition_part = Components::Edition.new(type: "e",
                                                   id: owmwp_hash[:owmwp_year])
            return { type => Components::Code.new(number: number_part), edition: edition_part }
          end

          # NEW: Handle second_number with edition (hash with :number_only and :edition_id)
          # This handles "126r2013" pattern where parser returns {:number_only=>"126", :edition_id=>"2013"}
          # CRITICAL: Wrap in a structure that builder loop can recognize
          # The builder loop expects keys like :second_number to be present in the hash
          if type == :second_number && value.is_a?(Hash) && value[:number_only] && value[:edition_id]
            # Return wrapped hash so builder loop finds :second_number key
            return { second_number: value }
          end

          # NEW: Handle second_number with revision_letter (hash with :revision_letter containing :number_only and :letter)
          # This handles "27ra" pattern where parser returns {revision_letter: {number_only: "27", letter: "a"}}
          # Should be combined to "27rA" format
          if type == :second_number && value.is_a?(Hash) && value[:revision_letter]
            revision_data = value[:revision_letter]
            number_only = revision_data[:number_only].to_s
            letter = revision_data[:letter].to_s.upcase
            # Return as second_number with combined format "27rA"
            return { second_number: Components::Code.new(number: "#{number_only}r#{letter}") }
          end

          # Handle v#n# pattern (CSM series) - comes as hash from parser
          # Return Volume and Part components separately
          if value.is_a?(Hash) && value[:volume_number] && value[:issue_number]
            volume_num = value[:volume_number].to_s
            issue_num = value[:issue_number].to_s
            return {
              volume: Components::Volume.new(value: volume_num),
              part: Components::Part.new(type: "n", value: issue_num),
            }
          end

          str_value = value.to_s

          # Handle special patterns embedded in first_number
          if type == :first_number

            # NEW: Handle first_number hash with number_with_rev_year (e.g., "1013rv1953")
            # Parser returns: {:number_with_rev_year=>{:number=>"1013", :revision_year=>"1953"}}
            if value.is_a?(Hash) && value[:number_with_rev_year]
              number_part = value[:number_with_rev_year][:number].to_s
              revision_year = value[:number_with_rev_year][:revision_year].to_s
              return {
                first_number: Components::Code.new(number: number_part),
                edition: Components::Edition.new(type: "rv", id: revision_year),
              }
            end

            # NEW: Handle first_number hash with language_code (e.g., "1262es")
            # Parser returns: {:number=>"1262", :language_code=>"es"}
            if value.is_a?(Hash) && value[:number] && value[:language_code]
              number_part = value[:number].to_s
              language_code = value[:language_code].to_s.strip.downcase
              # Apply normalization map (es → spa, pt → por, etc.)
              normalized_code = TRANSLATION_MAP[language_code] || language_code
              return {
                first_number: Components::Code.new(number: number_part),
                translation_component: Components::Translation.new(code: normalized_code),
              }
            end

            # NEW: Handle first_number hash with number, part_number, and edition_year (MR format)
            # Parser returns: {:number=>"28", :part_number=>"1", :edition_year=>"1969"}
            # For "NBS.HB.28pt1e1969" MR format input
            if value.is_a?(Hash) && value[:number] && value[:part_number] && value[:edition_year]
              number_part = value[:number].to_s
              part_number = value[:part_number].to_s
              edition_year = value[:edition_year].to_s
              return {
                first_number: Components::Code.new(number: number_part),
                part: Components::Part.new(type: "pt", value: part_number),
                edition: Components::Edition.new(type: "e", id: edition_year),
              }
            end

            # NEW: Check for edition_year_separate in parsed_hash context
            # This handles "11e2-1915" where first_number="11e2" and edition_year_separate="1915"
            if parsed_hash[:edition_year_separate] && str_value =~ /^(\d+)e(\d+)$/
              number_part = $1
              edition_id = $2
              year_part = parsed_hash[:edition_year_separate].to_s
              return {
                first_number: Components::Code.new(number: number_part),
                edition: Components::Edition.new(type: "e", id: edition_id,
                                                 additional_text: year_part),
              }
            end

            # NEW: Check for number_with_volume in value hash (for first_number)
            # This handles "539v10" where parser captures :number and :volume_suffix separately
            # Parse tree: value = {:number_with_volume => {:number => "539", :volume_suffix => "10"}}
            if value.is_a?(Hash) && value[:number_with_volume] && value[:number_with_volume][:volume_suffix]
              number_part = value[:number_with_volume][:number].to_s
              volume_value = value[:number_with_volume][:volume_suffix].to_s
              return {
                first_number: Components::Code.new(number: number_part),
                volume: Components::Volume.new(value: volume_value),
              }
            end

            # NEW: Check for historical_month and historical_year in parsed_hash context
            # This handles "-April1909" where it's captured as separate month/year
            if parsed_hash[:historical_month] && parsed_hash[:historical_year]
              month_part = parsed_hash[:historical_month].to_s
              year_part = parsed_hash[:historical_year].to_s
              # Check if str_value is just a number (the part before dash)
              if /^\d+$/.match?(str_value)
                return {
                  first_number: Components::Code.new(number: str_value),
                  edition: Components::Edition.new(type: "-",
                                                   additional_text: "#{month_part}#{year_part}"),
                }
              else
                # No number, just historical edition
                return {
                  edition: Components::Edition.new(type: "-",
                                                   additional_text: "#{month_part}#{year_part}"),
                }
              end
            end

            # Pattern "9350sup"/"5893supp" - number with bare supplement marker
            # (no trailing payload). Accept both single-p "sup" and double-p
            # "supp" so the marker is isolated as supplement="" and rendered as
            # canonical single-p "sup", instead of staying baked into the number
            # as an opaque suffix. E.g. "NBS RPT 5893supp", "NBS MONO 32supp".
            if str_value =~ /^(\d+)supp?$/
              return {
                first_number: Components::Code.new(number: $1),
                supplement: "",
              }
            end

            # NEW: Check for supplement_year in parsed_hash context
            # This handles "25supp-1924" where first_number="25supp" and supplement_year="1924"
            if parsed_hash[:supplement_year] && str_value =~ /^(\d+)supp?$/
              number_part = $1
              year_part = parsed_hash[:supplement_year].to_s
              return {
                first_number: Components::Code.new(number: number_part),
                supplement: year_part,
              }
            end

            # Pattern: "154supprev" - supplement with revision
            if str_value =~ /^(\d+)supprev$/
              return {
                first_number: Components::Code.new(number: $1),
                supplement: "",
                supplement_has_revision: true,
              }
            # NEW: Pattern "11e2-1915" - edition with separate year (inline match)
            # Creates: number="11", Edition(type: "e", id: "2", additional_text: "1915")
            # Renders: "NBS CIRC 11e2.1915"
            elsif str_value =~ /^(\d+)e(\d+)-(\d{4})$/
              number_part = $1
              edition_id = $2
              year_part = $3
              return {
                first_number: Components::Code.new(number: number_part),
                edition: Components::Edition.new(type: "e", id: edition_id,
                                                 additional_text: year_part),
              }
            # NEW: Pattern "-April1909" - historical edition with month+year (inline match)
            # Creates: Edition(type: "-", additional_text: "April1909")
            # Renders: "NBS CIRC -April1909"
            elsif str_value =~ /^-([A-Za-z]{3,9})(\d{4})$/
              month_part = $1
              year_part = $2
              return {
                edition: Components::Edition.new(type: "-",
                                                 additional_text: "#{month_part}#{year_part}"),
              }
            # NEW: CS Emergency pattern "e104" or "e104-43" → extract number
            # This must come BEFORE bare edition check to avoid conflict
            # CS emergency always has 3+ digit number (e104, not e2)
            # NOTE: If second_number exists (e104-43 pattern), defer to compound number logic
            elsif /^e(\d{3,})$/.match?(str_value) && !parsed_hash[:second_number]
              # Extract emergency number: e104 → 104 (only when no second_number)
              emergency_num = str_value.sub(/^e/, "")
              return {
                first_number: Components::Code.new(number: emergency_num),
              }
            # If e104-43 pattern (with second_number), keep e prefix for compound number logic
            elsif /^e(\d{3,})$/.match?(str_value) && parsed_hash[:second_number]
              # Keep e104 as-is, let compound number logic handle it
              return {
                first_number: Components::Code.new(number: str_value),
              }
            # NEW: Bare edition pattern like "100e1" (CS series without year)
            # ONLY when NO second_number present (to avoid conflict with "123e2-50")
            # Creates: number="100", Edition(type: "e", id: "1")
            # Renders: "NBS CS 100e1"
            # CRITICAL: Skip if edition_dash_year is present - let that handler create Edition with additional_text
            elsif str_value =~ /^(\d+)e(\d+)$/ && !parsed_hash[:second_number] && !parsed_hash[:edition_dash_year]
              number_part = $1
              edition_id = $2

              return {
                first_number: Components::Code.new(number: number_part),
                edition: Components::Edition.new(type: "e", id: edition_id),
              }
            # NEW: Bare edition pattern "e2" - just edition without number prefix
            # Creates: Edition(type: "e", id: "2")
            # Renders: "NBS CIRC e2"
            # Only matches single or double digit (e1, e2, not e104 which is emergency)
            elsif str_value =~ /^e(\d{1,2})$/
              edition_id = $1
              return {
                edition: Components::Edition.new(type: "e", id: edition_id),
              }
            # Pattern: "13e2rev1908" - edition with revision year-only (NO month)
            # Creates: Edition(type: "e", id: "2", additional_text: "1908")
            # Renders: "e2.1908" (DOT separator)
            elsif str_value =~ /^(\d+)e(\d+)rev(\d{4})$/
              # CRITICAL: Capture BEFORE any regex method calls!
              number_part = $1
              edition_id_part = $2
              year_part = $3
              return {
                first_number: Components::Code.new(number: number_part),
                edition: Components::Edition.new(type: "e",
                                                 id: edition_id_part, additional_text: year_part),
              }
            # Pattern: "13e2revJune1908" - edition with revision month+year
            # Creates: Edition(type: "e", id: "2", additional_text: "June1908")
            # Renders: "e2.June1908" (DOT separator)
            elsif str_value =~ /^(\d+)e(\d+)(rev.+)$/
              # CRITICAL: Capture $1, $2, $3 BEFORE calling .sub() which resets them!
              number_part = $1
              edition_id_part = $2
              rev_part = $3
              # Strip "rev" prefix from additional_text - store only "June1908" or "1908"
              additional_text = rev_part.sub(/^rev/, "")
              return {
                first_number: Components::Code.new(number: number_part),
                edition: Components::Edition.new(type: "e",
                                                 id: edition_id_part, additional_text: additional_text),
              }
            # NEW: Pattern "24suppJan1924" - supplement with month and year in first_number
            # Creates: number="24", supplement="Jan1924"
            elsif str_value =~ /^(\d+)supp([A-Za-z]{3,9})(\d{4})$/
              number_part = $1
              month_part = $2
              year_part = $3
              return {
                first_number: Components::Code.new(number: number_part),
                supplement: "#{month_part}#{year_part}",
              }
            # NEW: Pattern "25supp1924" - supplement with year (no dash, no month)
            # Creates: number="25", supplement="1924"
            # Renders: "NBS SP 25supp1924"
            elsif str_value =~ /^(\d+)supp(\d{4})$/
              number_part = $1
              year_part = $2
              return {
                first_number: Components::Code.new(number: number_part),
                supplement: year_part,
              }
            # NEW: Pattern "25supp-1924" - supplement with dash-year (inline match)
            # Creates: number="25", supplement="1924"
            # Renders: "NBS CIRC 25supp-1924"
            elsif str_value =~ /^(\d+)supp-(\d{4})$/
              number_part = $1
              year_part = $2
              return {
                first_number: Components::Code.new(number: number_part),
                supplement: year_part,
              }
            # NEW: Pattern "101e2supp" - edition + supplement
            # Creates: number="101", Edition(type: "e", id: "2"), supplement=""
            # Renders: "NBS CIRC 101e2supp"
            elsif str_value =~ /^(\d+)e(\d+)supp$/
              number_part = $1
              edition_id = $2
              return {
                first_number: Components::Code.new(number: number_part),
                edition: Components::Edition.new(type: "e", id: edition_id),
                supplement: "",
              }
            end
          elsif type == :second_number && value.is_a?(Hash) && value[:first_number]
            # Handle second_number as a hash with first_number context
            # e.g., for pattern 800-57pt1r4
            number_part = value[:first_number].to_s
            part_value = value[:part_value]&.to_s
            revision_value = value[:revision_value]&.to_s
            return {
              first_number: Components::Code.new(number: number_part),
              part: Components::Part.new(value: part_value),
              edition: Components::Edition.new(type: "r", id: revision_value),
            }
          end

          # Extract revision suffix from number (e.g., "53r5" → "53" + Edition(r, 5))
          # ENHANCED: Also extract revision with slash-year (e.g., "53r5/1917" → "53" + Edition)
          # ENHANCED: Also extract revision with 4-digit year (e.g., "1019r1963" → "1019" + Edition)
          # ENHANCED: Also extract revision with month+year (e.g., "4743rJun1992" → "4743" + Edition)

          # NEW: Extract part suffix from number (e.g., "800-57pt1" → "800-57" + Part(1))
          # This handles SP series part notation
          # IMPORTANT: Handle combined part+revision first (e.g., "800-57pt1r4")
          if str_value =~ /^(.+?)pt(\d+)r(\d+[a-z]?)$/
            number_part = $1
            part_value = $2
            revision_value = $3
            return {
              type => Components::Code.new(number: number_part),
              part: Components::Part.new(type: "pt", value: part_value),
              edition: Components::Edition.new(type: "r", id: revision_value),
            }
          elsif str_value =~ /^(.+?)pt(\d+)$/
            number_part = $1
            part_value = $2
            return {
              type => Components::Code.new(number: number_part),
              part: Components::Part.new(type: "pt", value: part_value),
            }
          end

          # NEW: Extract volume suffix from number (e.g., "539v10" → "539" + volume="10")
          # This handles CIRC volume notation
          if str_value =~ /^(\d+)v(\d+)$/
            number_part = $1
            volume_part = $2
            return {
              type => Components::Code.new(number: number_part),
              volume: volume_part,
            }
          end

          # REVISION PATTERNS - These must come BEFORE letter suffix to avoid conflicts
          case str_value
          when /^(.+?)(r\d+\/\d{4})$/i
            # Pattern: r6/1925 (revision with slash-year)
            number_part = $1
            revision_with_year = $2 # e.g., "r6/1925"
            # Extract revision and year
            if revision_with_year =~ /^r(\d+)\/(\d{4})$/
              revision_id = $1
              year_part = $2
              return {
                type => Components::Code.new(number: number_part),
                edition: Components::Edition.new(type: "r", id: revision_id,
                                                 additional_text: year_part),
              }
            end
          when /^(.+?)(r\d{4})$/i
            # Pattern: r1963 (revision as 4-digit year)
            number_part = $1
            year_value = $2.sub(/^r/, "") # Strip 'r' prefix
            return {
              type => Components::Code.new(number: number_part),
              edition: Components::Edition.new(type: "r", id: year_value),
            }
          when /^(.+?)(r[A-Za-z]{3,9}\d{4})$/i
            # Pattern: rJun1992 (revision with month and year)
            number_part = $1
            revision_with_date = $2 # e.g., "rJun1992"
            # Extract month and year
            if revision_with_date =~ /^r([A-Za-z]{3,9})(\d{4})$/
              month_part = $1
              year_part = $2
              return {
                type => Components::Code.new(number: number_part),
                edition: Components::Edition.new(type: "r",
                                                 id: "#{month_part}#{year_part}"),
              }
            end
          when /^(.+?)(r\d+[a-z]?)$/i
            # Pattern: r5, r1a (simple revision)
            number_part = $1
            revision_value = $2.sub(/^r/, "") # Strip 'r' prefix
            return {
              type => Components::Code.new(number: number_part),
              edition: Components::Edition.new(type: "r", id: revision_value),
            }
          when /^(.+?)(?<![a-zA-Z])(r)$/i
            # Pattern: bare r with no digits (e.g., "800-90r")
            # Negative lookbehind ensures r is NOT preceded by a letter (avoids matching Ur, Ua, etc.)
            number_part = $1
            return {
              type => Components::Code.new(number: number_part),
              edition: Components::Edition.new(type: "r", id: "1"),
            }
          end

          # NEW: Extract UPPERCASE letter suffix as Part component (e.g., "800-56A" → "800-56" + Part)
          # IMPORTANT: These patterns come AFTER revision patterns to avoid conflicts
          # Letter suffixes are UPPERCASE letters A-Z only (no lowercase to avoid revision markers)

          # Pattern: UPPERCASE letter + revision (e.g., "800-56Ar2" → number + Part("", "A") + Edition(r, 2))
          # NO /i flag - only match uppercase letters!
          if str_value =~ /^(.+?)([A-Z])(r\d+[a-z]?)$/
            number_part = $1
            letter_part = $2
            revision_part = $3.sub(/^r/, "")
            return {
              type => Components::Code.new(number: number_part),
              part: Components::Part.new(type: "", value: letter_part),
              edition: Components::Edition.new(type: "r", id: revision_part),
            }
          # Pattern: bare UPPERCASE letter suffix (e.g., "800-56A" → number + Part("", "A"))
          # Only matches uppercase letters - won't match revision markers
          # IMPORTANT: For MR format preservation, keep letter suffix as part of number
          # IMPORTANT: For Report, FIPS, IR, and LC series, preserve letter suffix as part of number
          elsif str_value =~ /^(.+?)([A-Z])$/
            number_part = $1
            letter_part = $2
            # Check if we should preserve letter suffix in number
            # Check for specific series that need letter suffix preserved
            is_report = begin
              parsed_hash[:series].to_s.include?("RPT")
            rescue StandardError
              false
            end
            is_fips = begin
              parsed_hash[:series].to_s.include?("FIPS")
            rescue StandardError
              false
            end
            is_ir = begin
              parsed_hash[:series].to_s.include?("IR")
            rescue StandardError
              false
            end
            is_crpl = begin
              parsed_hash[:series].to_s.include?("CRPL")
            rescue StandardError
              false
            end
            is_mono = begin
              parsed_hash[:series].to_s.include?("MONO")
            rescue StandardError
              false
            end
            is_mp = begin
              parsed_hash[:series].to_s.include?("MP")
            rescue StandardError
              false
            end
            # Check for LC but exclude LCIRC (Letter Circular uses LC, not LCIRC)
            is_lc = begin
              parsed_hash[:series].to_s.include?("LC") && !parsed_hash[:series].to_s.include?("LCIRC")
            rescue StandardError
              false
            end

            if parsed_hash[:parsed_format] == :mr || is_report || is_fips || is_ir || is_crpl || is_lc || is_mono || is_mp
              # For MR format, Report, FIPS, IR, CRPL, LC, MONO, and MP, preserve letter suffix as part of number
              return { type => Components::Code.new(number: str_value) }
            else
              # For other formats, extract letter suffix as separate Part component
              return {
                type => Components::Code.new(number: number_part),
                part: Components::Part.new(type: "", value: letter_part),
              }
            end
          end

          Components::Code.new(number: str_value)

        when :crpl_range
          return nil if value.nil? || value.to_s.strip.empty?

          # For CRPL range patterns like "2_3-1" or "2_3-1A" (with supplement)
          # Format: X_Y-Z where X,Y,Z are digits, optional trailing letter is supplement
          # This should split into:
          # - X → second_number (to combine with first_number as "1-X")
          # - Y-Z → Part component (with type "pt" for CRPL)
          # - trailing letter (if present) → Supplement
          str_value = value.to_s

          # Check for supplement letter suffix (e.g., "2_3-1A" → supplement="A")
          if str_value =~ /^(\d+)_(\d+-\d+)([A-Z])$/
            second_num_part = $1 # "2"
            part_value = $2 # "3-1"
            supplement_letter = $3 # "A"

            # Return second_number, Part, and Supplement
            {
              second_number: Components::Code.new(number: second_num_part),
              part: Components::Part.new(type: "pt", value: part_value),
              supplement: supplement_letter,
            }
          elsif str_value =~ /^(\d+)_(\d+-\d+)$/
            # No supplement letter
            second_num_part = $1 # "2"
            part_value = $2 # "3-1"

            # Return second_number and Part
            {
              second_number: Components::Code.new(number: second_num_part),
              part: Components::Part.new(type: "pt", value: part_value),
            }
          else
            # Fallback: treat entire value as second_number (shouldn't happen with valid CRPL patterns)
            Components::Code.new(number: str_value)
          end

        # ========== V2 COMPONENT CASTING ==========

        when :stage
          # Stage from nested hash with id and type
          return nil unless value.is_a?(Hash)

          stage_id = value[:stage_id]&.to_s&.downcase
          stage_type = value[:stage_type]&.to_s&.downcase
          return nil if stage_id.nil? || stage_type.nil? || stage_id.empty? || stage_type.empty?

          # Return as hash to set the stage attribute
          { stage: Components::Stage.new(id: stage_id, type: stage_type) }

        when :stage_id, :stage_type
          # These are captured by :stage, so skip individual processing
          nil

        when :parsed_format
          # Format detection result from parser
          value&.to_s

        when :translation
          # V1 TRANSLATION NORMALIZATION
          return nil if value.nil? || value.to_s.strip.empty?

          code = value.to_s.strip.downcase
          # Apply normalization map (es → spa, pt → por, etc.)
          normalized_code = TRANSLATION_MAP[code] || code

          # Return as hash to set translation_component attribute
          { translation_component: Components::Translation.new(code: normalized_code) }

        when :version
          # Version component with dotted notation
          return nil if value.nil? || value.to_s.strip.empty?

          # Return as hash to set version_component attribute
          { version_component: Components::Version.new(value: value.to_s) }

        when :update
          # Update component with number, year, and optional month
          if value.is_a?(Hash)
            # Convert Parslet slice to regular Hash for reliable key access
            value_hash = value.to_h

            number = value_hash[:update_number]&.to_s # Don't default to "1"
            year = value_hash[:update_year]&.to_s     # String not integer
            month = value_hash[:update_month]&.to_s   # String not integer

            # Determine prefix from update_prefix key (captured by parser)
            # If not present, default to "slash" (/Upd format)
            prefix_str = value_hash[:update_prefix]&.to_s
            prefix_value = if prefix_str&.include?("-") || prefix_str == "-upd"
                             "dash"
                           else
                             "slash"
                           end

            # Create update with at least number
            update_obj = Components::Update.new(number: number, year: year,
                                                month: month, prefix: prefix_value)
            {
              update: update_obj, # Main attribute for tests
              update_component: update_obj, # V2 component
            }
          elsif value.to_s.strip.empty?
            # Empty update string means "-upd" or "/upd" with no details
            # Create Update with default number="1" (no year/month)
            # Check update_prefix key to determine correct prefix format
            prefix_str = parsed_hash[:update_prefix]&.to_s
            prefix_value = if prefix_str&.include?("-") || prefix_str == "-upd"
                             "dash"
                           else
                             "slash"
                           end
            update_obj = Components::Update.new(number: "1", year: nil,
                                                month: nil, prefix: prefix_value)
            {
              update: update_obj,
              update_component: update_obj,
            }
          else
            # Simple string value - shouldn't reach here
            { update: value.to_s.strip } unless value.to_s.strip.empty?
          end

        when :update_prefix, :update_number, :update_year, :update_month
          # Captured as part of :update processing
          nil

        # ========== END V2 COMPONENTS ==========

        when :volume, :section, :appendix, :translation,
             :errata, :index, :insert, :version
          return nil if value.nil?
          return nil if value.is_a?(Array) && value.empty?

          str_value = value.to_s.strip
          return nil if str_value.empty?

          # For volume, create Volume component from string value
          # This handles patterns like "v1" that come from parser as simple strings
          if type == :volume
            { volume: Components::Volume.new(value: str_value) }
          else
            str_value
          end

        when :revision
          # Revision MUST be Edition component with type "r"
          return nil if value.nil? || value.to_s.strip.empty?

          # Handle new structure with :revision_prefix and :revision_id (format preservation)
          if value.is_a?(Hash) && value[:revision_prefix] && value[:revision_id]
            prefix = value[:revision_prefix].to_s
            id = value[:revision_id].to_s.strip

            # Normalize bare "r" → "r1"
            revision_id = if id.empty? || id == "r" || id == "R"
                            "1"
                          # Handle "r4", "R5", "4" etc. (but prefix already has the r/rev/etc.)
                          elsif id =~ /^(\d+[a-z]?)$/
                            $1
                          else
                            id
                          end

            # Return Edition component with original_prefix for format preservation
            {
              edition: Components::Edition.new(type: "r", id: revision_id,
                                               original_prefix: prefix),
            }
          else
            # Legacy handling: revision as simple string value
            str_value = value.to_s.strip

            # Handle bare "r" → normalize to "r1"
            revision_id = if str_value.empty? || str_value == "r" || str_value == "R"
                            "1"
                          # Handle "r4", "R5", "4" etc.
                          elsif str_value =~ /^[rR]?(\d+[a-z]?)$/
                            $1
                          else
                            str_value
                          end

            # Return Edition component (no original_prefix available)
            {
              edition: Components::Edition.new(type: "r", id: revision_id),
            }
          end

        when :revision_year, :revision_month
          # When revision_year comes from parser as separate element (e.g., "1019 r1963")
          # Create Edition component
          if type == :revision_year
            year_value = value.to_s.strip
            # Check if this should be an Edition component or legacy revision_year
            # If revision_month is also present, use legacy attributes for "revJune1908" pattern
            if parsed_hash[:revision_month]
              # Legacy: revision with month - keep as revision_year/revision_month
              year_value
            else
              # V2: revision with year only - create Edition component
              {
                edition: Components::Edition.new(type: "r", id: year_value),
              }
            end
          else
            # revision_month - preserve as string for legacy rendering
            return nil if value.nil? || value.to_s.strip.empty?

            value.to_s.strip
          end

        when :edition_year_separate
          # NEW: Edition year from "e2-1915" pattern (captured separately by parser)
          # This comes with first_number like "11e2" and separate year "1915"
          # Already handled in first_number regex matching above, but if it reaches here
          # as a separate capture, we need to process it
          return nil if value.nil? || value.to_s.strip.empty?

          value.to_s # Return as string for potential use

        when :historical_month
          # NEW: Historical month from "-April1909" pattern
          # Handled in first_number pattern matching, but return as string if separate
          return nil if value.nil? || value.to_s.strip.empty?

          value.to_s

        when :historical_year
          # NEW: Historical year from "-April1909" pattern
          # Handled in first_number pattern matching, but return as string if separate
          return nil if value.nil? || value.to_s.strip.empty?

          value.to_s

        when :supplement_year
          # NEW: Supplement year from "supp-1924" pattern (captured separately by parser)
          # This comes with first_number like "25supp" and separate year "1924"
          # Already handled in first_number regex matching above, but if it reaches here
          # as a separate capture, return as supplement value
          return nil if value.nil? || value.to_s.strip.empty?

          { supplement: value.to_s } # Return as supplement attribute

        when :supplement
          handle_supplement_cast(value)

        when :supplement_date_range
          return nil unless value.is_a?(Hash)

          month_start = value[:supp_month_start]&.to_s
          year_start = value[:supp_year_start]&.to_s
          month_end = value[:supp_month_end]&.to_s
          year_end = value[:supp_year_end]&.to_s

          {
            supplement_date_range_start: (month_start && year_start ? "#{month_start}#{year_start}" : nil),
            supplement_date_range_end: (month_end && year_end ? "#{month_end}#{year_end}" : nil),
          }

        when :supplement_date
          return nil unless value.is_a?(Hash)

          month = value[:supp_month]&.to_s
          year = value[:supp_year]&.to_s

          month && year ? "#{month}#{year}" : nil

        when :supplement_slash_year
          return nil unless value.is_a?(Hash)

          number = value[:supp_number]&.to_s
          year = value[:supp_year]&.to_s

          number && year ? "#{number}/#{year}" : nil

        when :supplement_with_rev
          { supplement: "", supplement_has_revision: true }

        when :supp_year
          # Parser extracts supplement year from patterns like "187supp1924"
          # This should set the supplement attribute with the year value
          { supplement: value.to_s }

        # ========== V2 EDITION COMPONENT ==========

        when :edition_e_date
          # Edition with "e" prefix + 6-digit date (YYYYMM): e199206, e202103
          # Used for IR revision+month patterns after preprocessing: "4743rJun1992" → "4743e199206"
          return nil unless value.is_a?(Hash) && value[:edition_date]

          edition_date = value[:edition_date].to_s
          # Parse 6-digit date as YYYYMM
          # Store as id directly - renders as "e199206"
          {
            edition: Components::Edition.new(type: "e", id: edition_date),
            edition_component: Components::Edition.new(type: "e",
                                                       id: edition_date),
          }

        when :edition_e
          # Edition with "e" prefix: e2, e2021
          return nil unless value.is_a?(Hash) && value[:edition_id]

          edition_id = value[:edition_id].to_s

          {
            edition: Components::Edition.new(type: "e", id: edition_id),
            edition_component: Components::Edition.new(type: "e",
                                                       id: edition_id),
          }

        when :edition_r
          # Revision with "r" prefix: r5, r2021
          return nil unless value.is_a?(Hash) && value[:edition_id]

          edition_id = value[:edition_id].to_s

          {
            edition: Components::Edition.new(type: "r", id: edition_id),
            edition_component: Components::Edition.new(type: "r",
                                                       id: edition_id),
            revision: "r#{edition_id}", # Also set revision string attribute for compatibility
          }

        when :edition_r_no_space
          # Revision with "r" prefix (no space pattern): r2, r5
          # Used for patterns like "800-56Ar2" where edition is "r2"
          return nil unless value.is_a?(Hash) && value[:edition_id]

          edition_id = value[:edition_id].to_s

          {
            edition: Components::Edition.new(type: "r", id: edition_id),
            edition_component: Components::Edition.new(type: "r",
                                                       id: edition_id),
            revision: "r#{edition_id}", # Also set revision string attribute for compatibility
          }

        when :edition_rev
          # Revision with "rev" prefix (verbose): rev2013, rev 2013
          return nil unless value.is_a?(Hash) && value[:edition_id]

          edition_id = value[:edition_id].to_s

          {
            edition: Components::Edition.new(type: "r", id: edition_id),
            edition_component: Components::Edition.new(type: "r",
                                                       id: edition_id),
            revision: "r#{edition_id}", # Also set revision string attribute for compatibility
          }

        when :edition_r_letter
          # Revision with "r" prefix and letter suffix: r1a, r2b (for SP patterns like 800-22r1a)
          return nil unless value.is_a?(Hash) && value[:edition_id] && value[:edition_letter]

          edition_id = value[:edition_id].to_s
          edition_letter = value[:edition_letter].to_s.downcase

          {
            edition: Components::Edition.new(type: "r", id: edition_id,
                                             additional_text: edition_letter),
            edition_component: Components::Edition.new(type: "r",
                                                       id: edition_id,
                                                       additional_text: edition_letter),
            revision: "r#{edition_id}#{edition_letter}", # Also set revision string attribute for compatibility
          }

        when :edition_r_letter_only
          # Revision with "r" prefix and only letter (no digit): ra, rb (for SP patterns like 800-27ra)
          return nil unless value.is_a?(Hash) && value[:edition_letter]

          edition_letter = value[:edition_letter].to_s.downcase

          {
            edition: Components::Edition.new(type: "r", id: edition_letter),
            edition_component: Components::Edition.new(type: "r",
                                                       id: edition_letter),
            revision: "r#{edition_letter}", # Also set revision string attribute for compatibility
          }

        when :edition_historical
          # Historical with "-" prefix: -3, -4
          return nil unless value.is_a?(Hash) && value[:edition_id]

          edition_id = value[:edition_id].to_s

          {
            edition: Components::Edition.new(type: "-", id: edition_id),
            edition_component: Components::Edition.new(type: "-",
                                                       id: edition_id),
          }

        when :edition_r_with_space_letter
          # Revision with "r" prefix, space, and letter: r 5A (format preservation)
          # Used for patterns like "NIST SP 800-53 r5A"
          # NOTE: If there's an update component, the space was added by preprocessing
          return nil unless value.is_a?(Hash) && value[:edition_id] && value[:edition_letter]

          edition_id = value[:edition_id].to_s
          edition_letter = value[:edition_letter].to_s.upcase

          # Check if this is an embedded edition with update (space added by preprocessing)
          has_update = parsed_hash[:update_prefix] || parsed_hash[:update]

          if has_update
            # No original_prefix - space was added by preprocessing
            {
              edition: Components::Edition.new(type: "r", id: edition_id,
                                               additional_text: edition_letter),
              edition_component: Components::Edition.new(type: "r",
                                                         id: edition_id,
                                                         additional_text: edition_letter),
              revision: "r#{edition_id}#{edition_letter}",
            }
          else
            # Space was in original input - preserve format
            {
              edition: Components::Edition.new(type: "r", id: edition_id,
                                               additional_text: edition_letter,
                                               original_prefix: " r"),
              edition_component: Components::Edition.new(type: "r",
                                                         id: edition_id,
                                                         additional_text: edition_letter,
                                                         original_prefix: " r"),
              revision: "r#{edition_id}#{edition_letter}",
            }
          end

        when :edition_r_with_space
          # Revision with "r" prefix and space: r 5 (format preservation)
          # Used for patterns like "NIST SP 800-53 r5"
          # NOTE: If there's an update component, the space was added by preprocessing
          # for patterns like "8115r1/upd" → "8115 r1/upd", so don't set original_prefix
          return nil unless value.is_a?(Hash) && value[:edition_id]

          edition_id = value[:edition_id].to_s

          # Check if this is an embedded edition with update (space added by preprocessing)
          # Patterns like "8115r1/upd" become "8115 r1/upd" after preprocessing
          has_update = parsed_hash[:update_prefix] || parsed_hash[:update]

          if has_update
            # No original_prefix - space was added by preprocessing
            {
              edition: Components::Edition.new(type: "r", id: edition_id),
              edition_component: Components::Edition.new(type: "r",
                                                         id: edition_id),
              revision: "r#{edition_id}",
            }
          else
            # Space was in original input - preserve format
            {
              edition: Components::Edition.new(type: "r", id: edition_id,
                                               original_prefix: " r"),
              edition_component: Components::Edition.new(type: "r",
                                                         id: edition_id,
                                                         original_prefix: " r"),
              revision: "r#{edition_id}",
            }
          end

        when :edition_id
          # Captured by edition_e, edition_r, edition_rev, edition_historical
          nil

        when :edition_date
          # Captured by edition_e_date
          nil

        # ========== LEGACY EDITION (for migration) ==========

        when :legacy_edition
          # Legacy edition patterns - will be phased out
          # For now, map to old edition_year/edition_month attributes
          nil # Handled by existing edition_year logic below

        when :edition_month, :edition_year, :edition_day, :edition_has_rev
          # These work together: edition_month + edition_year → single edition ID
          # Skip processing if this is edition_month alone (will be processed with edition_year)
          return nil if type == :edition_month

          # Process edition_year, combining with edition_month if present
          return nil if value.nil? || value.to_s.strip.empty?

          # Build the edition ID from year and optional month
          edition_id = value.to_s # Start with year (e.g., "1985")

          # Add month if present (e.g., "Mar" → "03", so "1985" + "03" = "198503")
          # For FIPS with day: "Sep30/1977" → "19770930" (year + month + day)
          if parsed_hash[:edition_month]
            month_str = parsed_hash[:edition_month].to_s
            month_num = Date::ABBR_MONTHNAMES.index(month_str) ||
              Date::MONTHNAMES.index(month_str) ||
              month_str.to_i
            if month_num&.positive?
              # Check if this is FIPS series - FIPS uses number format (e198503), not month abbreviations
              # For historical NBS documents, preserve month name: "April1909" not "190904"
              is_fips = parsed_hash[:series]&.to_s == "FIPS"
              if !is_fips && month_str.match?(/^[A-Z][a-z]+/) && edition_id.to_s.match?(/^\d{4}$/)
                # Historical NBS month+year format: preserve month name, use "-" type for special rendering
                edition_obj = Components::Edition.new(
                  type: "-",
                  id: "",
                  additional_text: "#{month_str}#{edition_id}",
                )
                return {
                  edition: edition_obj,
                  edition_component: edition_obj,
                  edition_year: edition_id.to_s,
                }
              else
                # Modern format (and FIPS): combine year and month as single number: 1985 + 03 = 198503
                edition_id = "#{edition_id}#{format('%02d', month_num)}"

                # For FIPS with day, append day as well: "Sep30/1977" → "19770930"
                if is_fips && parsed_hash[:edition_day]
                  day_num = parsed_hash[:edition_day].to_s.to_i
                  if day_num.positive? && day_num <= 31
                    edition_id = "#{edition_id}#{format('%02d', day_num)}"
                  end
                end
              end
            end
          end

          # Create Edition component with type="e" (edition) and combined ID
          edition_obj = Components::Edition.new(type: "e", id: edition_id)

          # Return as hash to set edition and edition_year
          {
            edition: edition_obj, # Main attribute for tests
            edition_component: edition_obj, # V2 component
            edition_year: value.to_s, # Keep string for render logic
          }

        when :part
          # Part component - handle part number with optional addendum
          return nil if value.nil? || value.to_s.strip.empty?

          str_value = value.to_s.strip

          # Pattern: "1adde1" → Part(value: "1"), addendum=true
          # Note: eN after add is discarded (not included in output per fixture)
          if str_value =~ /^(\d+)add(e\d+)$/
            {
              part: Components::Part.new(type: "pt", value: $1),
              addendum: "true",
            }
          elsif str_value =~ /^(\d+)add/
            {
              part: Components::Part.new(type: "pt", value: $1),
              addendum: "true",
            }
          else
            # Just a part number - return Part component with pt type
            { part: Components::Part.new(type: "pt", value: str_value) }
          end

        when :part_extracted
          # Legacy - this is now handled by :part
          nil

        when :edition_letter
          return nil if value.nil? || value.to_s.strip.empty?

          value.to_s

        when :public_draft
          return nil if value.nil?

          value.to_s

        when :draft
          # Extract draft number from "-draft N" pattern for pd rendering
          return nil if value.nil?

          str_value = value.to_s.strip
          return nil if str_value.empty?

          # Pattern: " -draft 2" or "-draft 2" → extract "2" for pd rendering
          if str_value =~ /^\s*-draft\s+(\d+)$/
            { draft_number: $1 }
          # Pattern: " 2pd" → already in pd format
          elsif str_value =~ /^\s*(\d+)pd$/
            { public_draft: $1 }
          # Other patterns (parenthetical, simple -draft)
          else
            str_value
          end

        when :update
          handle_update_cast(value)

        when :update_number, :update_year
          return nil if value.nil? || value.to_s.strip.empty?

          value.to_s

        when :addendum
          handle_addendum_cast(value)

        when :addendum_number
          return nil if value.nil? || value.to_s.strip.empty?

          value.to_s

        when :supplement_suffix
          # Return as hash to set supplement attribute (not supplement_suffix)
          { supplement: value.to_s }

        when :date
          # Date component per NIST spec
          return nil unless value.is_a?(Hash)

          # NEW: Check if this is historical edition pattern ("-April1909")
          # Parser captures as date with month + year, but semantically it's an edition
          if value[:date_month] && value[:date_year] && !value[:date_day]
            month_str = value[:date_month].to_s
            year_str = value[:date_year].to_s
            # If month is a word like "April", this is historical edition format
            if month_str.match?(/^[A-Za-z]+$/)
              return {
                edition: Components::Edition.new(type: "-",
                                                 additional_text: "#{month_str}#{year_str}"),
              }
            end
          end

          # Regular date processing
          value[:date_year]&.to_s
          value[:date_month]&.to_s
          value[:date_day]&.to_s

        else
          # Unknown types: return the original value for default processing
          # This allows hashes with arbitrary structures to be processed
          # e.g., second_number hash with number_only and edition_id
          value.is_a?(Hash) ? value : nil
        end
      end

      # Handle supplement casting with all its variants
      def handle_supplement_cast(value)
        return nil unless value

        if value.is_a?(Array) && value.empty?
          # Empty array means "supp" was present but no suffix
          ""
        else
          str_value = value.to_s.strip
          str_value.empty? ? nil : str_value
        end
      end

      # Handle update casting (number and year)
      def handle_update_cast(value)
        if value.is_a?(Hash)
          {
            update_number: value[:update_number]&.to_s,
            update_year: value[:update_year]&.to_s,
          }.compact
        elsif value.to_s.strip.empty?
          # Empty update string (just "-upd" with no details)
          # Don't create update component - not enough data
          nil
        else
          str_value = value.to_s.strip
          str_value.empty? ? nil : str_value
        end
      end

      # Handle addendum casting (number)
      def handle_addendum_cast(value)
        if value.is_a?(Hash)
          addendum_num = value[:addendum_number]&.to_s&.strip
          if addendum_num && !addendum_num.empty?
            { addendum_number: addendum_num }
          else
            { addendum: "true" }
          end
        else
          str_value = value.to_s.strip
          if str_value.empty?
            { addendum: "true" }
          else
            { addendum_number: str_value }
          end
        end
      end
    end
  end
end
