# frozen_string_literal: true

require_relative "components/publisher"
require_relative "components/code"
require_relative "components/stage"
require_relative "components/edition"
require_relative "components/version"
require_relative "components/update"
require_relative "components/translation"
require_relative "components/issue_number"
require_relative "components/volume"
require_relative "components/part"

module PubidNew
  module Nist
    # Builder class for constructing NIST identifier objects from parsed data
    # Single Responsibility: Transform parsed data into identifier objects
    #
    # CRITICAL ARCHITECTURE PRINCIPLE:
    # Builder NEVER makes business logic decisions.
    # Builder ONLY casts parsed data to domain objects.
    class Builder
      # Translation normalization map (V1 compatibility)
      TRANSLATION_MAP = {
        "es" => "spa",
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
        parsed_hash = parsed.is_a?(Array) ? merge_parsed_array(parsed) : parsed

        # NEW: Check for CIRC supplement pattern
        if parsed_hash[:supplement_date_range] || parsed_hash[:base_portion]
          return build_circular_supplement(parsed_hash)
        end

        # Locate the appropriate identifier class via Scheme
        identifier = @scheme.locate_identifier_klass(parsed_hash).new

        # Track first_number and second_number for building compound number
        first_num = nil
        second_num = nil
        part_num = nil
        extracted_revision = nil

        # Cast and assign all attributes
        parsed_hash.each_pair do |key, value|
          realized_components = cast(key.to_sym, value, parsed_hash) # Pass parsed_hash for context
          next if realized_components.nil?

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
              # Track revision extraction
              elsif sub_key == :revision
                extracted_revision = sub_value
              end
              if identifier.respond_to?("#{sub_key}=")
                identifier.send("#{sub_key}=",
                                sub_value)
              end
            end
          else
            if identifier.respond_to?("#{key}=")
              identifier.send("#{key}=",
                              realized_components)
            end
          end
        end

        # Build compound number from first_number and second_number
        if first_num && !identifier.number
          # Skip if this is a v#n# pattern - now handled as Part component
          if identifier.volume && identifier.issue_number
            # V#n# pattern handled as Part in first_number cast
          elsif second_num
            # Check for special patterns first
            # CS Emergency pattern: e104-43 → number=104, edition_year=1943
            # Logic: e104-43 means "emergency 104 from 1943" (43 = 1943)
            if first_num.value.to_s.match?(/^e(\d{3})$/) &&
                second_num.value.to_s.match?(/^\d{2}$/)
              match_data = first_num.value.to_s.match(/^e(\d{3})$/)
              number_part = match_data[1] # 104
              year_suffix = second_num.value.to_s # 43
              # Edition year: 19 + 43 = 1943 (1900s + year suffix)
              edition_year = "19#{year_suffix}"

              identifier.number = Components::Code.new(number: number_part)
              identifier.edition = Components::Edition.new(type: "e",
                                                           id: edition_year)
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
              identifier.edition = Components::Edition.new(type: "e",
                                                           id: edition_id, additional_text: year_part)
            elsif first_num.value.to_s.match?(/^(\d+)supp?$/) &&
                second_num.value.to_s.match?(/^\d{4}$/)
              # Pattern: "25supp-1924" parsed as first="25supp", second="1924"
              number_part = first_num.value.to_s.match(/^(\d+)supp?$/)[1]
              year_part = second_num.value.to_s

              identifier.number = Components::Code.new(number: number_part)
              identifier.supplement = year_part
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

        identifier
      end

      # Build CircularSupplement with base_identifier wrapping
      # @param parsed_hash [Hash] the parsed supplement data
      # @return [Identifiers::CircularSupplement] the supplement identifier
      def build_circular_supplement(parsed_hash)
        supplement = Identifiers::CircularSupplement.new

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

        # Build base identifier from base_portion
        if parsed_hash[:base_portion]
          base_str = parsed_hash[:base_portion].to_s
          # Reconstruct parse hash for base identifier
          base_hash = {
            series: parsed_hash[:series],
            first_number: base_str,
            parsed_format: parsed_hash[:parsed_format],
          }

          # Recursively build base identifier
          # This will go through normal build() process which extracts edition from "101e2"
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
        elsif parsed_hash[:supplement_empty]
          # Empty supplement - no edition
          # supplement.edition remains nil
        end

        supplement
      end

      private

      # Merge an array of parsed hashes into a single hash
      # @param parsed_array [Array<Hash>] array of parsed hashes
      # @return [Hash] merged hash
      def merge_parsed_array(parsed_array)
        parsed_array.inject({}) { |result, hash| result.merge(hash) }
      end

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

        when :first_number, :second_number
          return nil if value.nil? || value.to_s.strip.empty?

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
            elsif str_value =~ /^(\d+)e(\d+)$/ && !parsed_hash[:second_number]
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
          if str_value =~ /^(.+?)(r\d+\/\d{4})$/i
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
          elsif str_value =~ /^(.+?)(r\d{4})$/i
            # Pattern: r1963 (revision as 4-digit year)
            number_part = $1
            year_value = $2.sub(/^r/, "") # Strip 'r' prefix
            return {
              type => Components::Code.new(number: number_part),
              edition: Components::Edition.new(type: "r", id: year_value),
            }
          elsif str_value =~ /^(.+?)(r[A-Za-z]{3,9}\d{4})$/i
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
          elsif str_value =~ /^(.+?)(r\d+[a-z]?)$/i
            # Pattern: r5, r1a (simple revision)
            number_part = $1
            revision_value = $2.sub(/^r/, "") # Strip 'r' prefix
            return {
              type => Components::Code.new(number: number_part),
              edition: Components::Edition.new(type: "r", id: revision_value),
            }
          elsif str_value =~ /^(.+?)(r)$/i
            # Pattern: bare r with no digits (e.g., "800-90r")
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

            if parsed_hash[:parsed_format] == :mr || is_report || is_fips || is_ir || is_lc || is_mono || is_mp
              # For MR format, Report, FIPS, IR, LC, MONO, and MP, preserve letter suffix as part of number
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
          value.to_s if value

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
            number = value[:update_number]&.to_s # Don't default to "1"
            year = value[:update_year]&.to_s     # String not integer
            month = value[:update_month]&.to_s   # String not integer

            # Determine prefix from update_prefix key (captured by parser)
            # If not present, default to "slash" (/Upd format)
            prefix_str = value[:update_prefix]&.to_s
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
            # Empty update string means "-upd" with no details
            # Create Update with default number="1" (no year/month)
            # Default prefix to "dash" for empty update (common case like "-upd")
            update_obj = Components::Update.new(number: "1", year: nil,
                                                month: nil, prefix: "dash")
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
            Components::Volume.new(value: str_value)
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

        when :edition_year, :edition_month, :edition_day, :edition_has_rev
          # Skip if this is edition_month, edition_day, or edition_has_rev
          # These are only used as context for edition_year
          return nil if type != :edition_year

          return nil if value.nil? || value.to_s.strip.empty?

          # Build Edition component from parsed edition data
          edition_attrs = { year: value.to_s } # Keep as string

          # Add month and day if present in parsed_hash
          if parsed_hash[:edition_month]
            month_str = parsed_hash[:edition_month].to_s
            month_num = Date::ABBR_MONTHNAMES.index(month_str) ||
              Date::MONTHNAMES.index(month_str) ||
              month_str.to_i
            edition_attrs[:month] = month_num if month_num && month_num > 0
          end
          if parsed_hash[:edition_day]
            edition_attrs[:day] = parsed_hash[:edition_day].to_s.to_i
          end

          # Create Edition component
          edition_obj = Components::Edition.new(**edition_attrs)

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
          if str_value =~ /^(\d+)add/
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
          value.to_s

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
          # Unknown types are ignored (returning nil)
          nil
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
