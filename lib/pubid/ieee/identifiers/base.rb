# frozen_string_literal: true

module Pubid
  module Ieee
    module Components
      # Forward declare component classes
    end

    module Identifiers
      # Base class for all IEEE identifiers
      class Base < Lutaml::Model::Serializable
        # Generate URN for this identifier
        #
        # @return [String] URN representation

        attribute :publisher, :string, default: -> { "IEEE" }
        attribute :copublisher, :string, collection: true # IEC, ISO, ANSI, etc.
        attribute :code, :string # Will store code as object in initialize
        attribute :year, :string
        attribute :type, :string, default: -> { "Std" } # Std, Draft Std
        attribute :draft_status, :string                    # Unapproved, Approved, Active Unapproved
        attribute :draft, :string                           # Will store draft as object
        attribute :edition, :string                         # Edition 1.0
        attribute :month, :string
        attribute :day, :string
        attribute :redline, :boolean, default: -> { false }
        attribute :amendments, Base, collection: true       # Amendment identifiers
        attribute :corrigenda, Base, collection: true       # Corrigendum identifiers
        attribute :revision_of, Base                        # Revision relationships
        attribute :incorporates, Base, collection: true     # Incorporated documents
        attribute :supersedes, Base, collection: true       # Superseded documents
        attribute :supplement_to, Base                      # For supplements
        attribute :iso_identifier, :string # For IEC/IEEE formats
        attribute :parenthetical_content, :string           # Raw parenthetical content
        attribute :note, :string                            # Parenthetical notes
        attribute :adoption, :string                        # Adoption notes
        attribute :amendment_to, :string                    # Amendment to relationships
        attribute :edition_month, :string                   # Month part from Edition YYYY-MM
        attribute :space_before_draft, :boolean, default: -> {
          false
        } # Track space before /D
        attribute :typed_stage, Components::TypedStage # TYPED_STAGE integration
        attribute :relationships, Components::Relationship, collection: true # Relationship metadata
        attribute :nickname, :string # Book nickname (e.g., "[The Orange Book]")
        attribute :interpretation, :boolean, default: -> {
          false
        } # /INT notation
        attribute :conf_number, :string # Conformance document number
        attribute :conf_year, :string # Conformance document year
        attribute :ashrae_number, :string # ASHRAE Guideline number
        attribute :ashrae_year, :string # ASHRAE Guideline year
        attribute :crossref, :string # IEEE cross-reference (e.g., /C62.22.1-1996)
        attribute :reaffirmed, :string # Reaffirmed year (e.g., "2010" for (R2010))

        # Store actual component objects
        attr_accessor :code_obj, :draft_obj

        def initialize(**args)
          super()

          # Handle typed_stage if provided
          if args[:typed_stage]
            self.typed_stage = args[:typed_stage]
          end

          # Handle code as component object
          if args[:code].is_a?(String)
            self.code_obj = Components::Code.parse(args[:code])
            self.code = args[:code]
          elsif args[:code]
            self.code_obj = args[:code]
            self.code = args[:code].to_s
          end

          # Handle draft as component object
          if args[:draft_obj]
            self.draft_obj = args[:draft_obj]
            self.draft = args[:draft_obj].to_s
          elsif args[:draft]
            # If draft is passed as string, try to create Draft object
            if args[:draft].is_a?(String)
              # Try to parse the string to extract version/revision
              if args[:draft] =~ /^D(\d+)(?:\.(\d+))?/
                version = $1
                revision = $2
                self.draft_obj = Components::Draft.new(version: version,
                                                       revision: revision)
              else
                # Simple case - treat as version
                self.draft_obj = Components::Draft.new(version: args[:draft])
              end
              self.draft = draft_obj.to_s
            else
              self.draft_obj = args[:draft]
              self.draft = args[:draft].to_s
            end
          end

          # Set other attributes
          args.each do |key, value|
            next if %i[code draft draft_obj typed_stage].include?(key)

            begin
              send("#{key}=", value)
            rescue NoMethodError
              nil
            end
          end
        end

        # Override accessors to return component objects
        def code
          code_obj
        end

        def draft
          draft_obj
        end

        # Expose numeric month from draft if available
        def draft_month
          return nil unless draft_obj.is_a?(Components::Draft)

          draft_obj.numeric_month
        end

        # Parse IEEE identifier string
        def self.parse(input)
          # Preprocessing: Convert comma-separated dual standards to "and" format
          # This must happen BEFORE the "and" check below
          # Pattern: "IEEE Std 960-1989, Std 1177-1989" -> "IEEE Std 960-1989 and IEEE Std 1177-1989"
          input = input.gsub(/(\d{4}),\s+Std\s/, '\1 and IEEE Std ')

          # Check for AIEE identifiers (but NOT those with parentheses which have relationships/adoptions)
          # AIEE has its own parser/builder for simple identifiers
          # AIEE inputs with parentheses are handled by IEEE parser for relationship/adoption parsing
          if input.start_with?("AIEE ") && !input.include?("(")
            return Aiee::Identifier.parse(input)
          end

          # Check for IEC/IEEE copublished patterns first (before other checks)
          if input.start_with?("IEC/IEEE ")
            return parse_single(input)
          end

          # Check for semicolon-separated dual identifiers (IEC-first patterns)
          # Pattern: "IEC 61523-3 First edition 2004-09; IEEE 1497"
          if input.include?("; ")
            parts = input.split("; ")
            if parts.length == 2
              # Try to parse both parts
              begin
                first = parse_single(parts[0].strip)
                second = parse_single(parts[1].strip)

                return Identifiers::DualPublished.new(
                  first_identifier: first,
                  second_identifier: second,
                )
              rescue Parslet::ParseFailed
                # If parsing fails, continue with normal flow
              end
            end
          end

          # PREPROCESS: Handle (R####) (Revision of...) pattern
          # Convert to single parenthetical: (Reaffirmed ####, Revision of...)
          # This allows parser to capture both in one parenthetical
          if input =~ /\(R(\d{4})\)\s*\(Revision of ([^)]+)\)/
            year = $1
            $2
            # Replace the two parentheticals with reaffirmed info extracted
            # Parse normally but capture year first
            input_modified = input.sub(
              /\(R(\d{4})\)\s*\(Revision of ([^)]+)\)/, "(Revision of \\2)"
            )

            # Parse the modified input
            result = parse_single(input_modified)
            # Add reaffirmed attribute
            begin
              result.reaffirmed = year
            rescue NoMethodError
              result.instance_variable_set(:@reaffirmed, year)
            end
            return result
          end

          # PREPROCESS: Handle (Reaffirmed ####) (Revision of...) pattern (full word format)
          # Pattern: "ANSI/IEEE Std 101-1987 (Reaffirmed 2010) (Revision of IEEE Std 101-1972)"
          if input =~ /\(Reaffirmed\s+(\d{4})\)\s*\(Revision of ([^)]+)\)/
            year = $1
            $2
            # Replace the two parentheticals
            input_modified = input.sub(
              /\(Reaffirmed\s+(\d{4})\)\s*\(Revision of ([^)]+)\)/, "(Revision of \\2)"
            )

            # Parse the modified input
            result = parse_single(input_modified)
            # Add reaffirmed attribute
            begin
              result.reaffirmed = year
            rescue NoMethodError
              result.instance_variable_set(:@reaffirmed, year)
            end
            return result
          end

          # NEW Session 174: Check for IRE dual published pattern
          # Pattern after preprocessing: "IEEE Std 218-1956 (R1980) (56 IRE 28.S2)"
          # First parenthetical: (Rxxx) reaffirmed
          # Second parenthetical: IRE identifier
          if /\(R\d{4}\)\s*\((\d+\s+IRE[^)]+)\)/.match?(input)
            main_part = input.split(" (R").first.strip # Get "IEEE Std 218-1956"
            reaffirmed_year = input.match(/\(R(\d{4})\)/)[1]
            ire_part = input.match(/\((\d+\s+IRE[^)]+)\)/)[1]

            begin
              # Parse main identifier
              ieee_id = parse_single(main_part)
              # Add reaffirmed year
              begin
                ieee_id.reaffirmed = reaffirmed_year
              rescue NoMethodError
                nil
              end

              # Parse IRE identifier
              ire_id = parse_single(ire_part)

              return Identifiers::DualPublished.new(
                first_identifier: ieee_id,
                second_identifier: ire_id,
              )
            rescue Parslet::ParseFailed
              # If parsing fails, fall through to regular processing
            end
          end

          # Check for space-separated dual identifiers (e.g., "IEC 62014-5 IEEE Std 1734-2011")
          # This must be checked before " and " pattern
          # Look for pattern where a second publisher appears after the first complete identifier
          # Publishers: IEEE, AIEE, ANSI, ASA, IEC, ISO, ASTM, NACE, NSF, ASHRAE, NCTA, AESC
          publishers = %w[IEEE AIEE ANSI ASA IEC ISO ASTM NACE NSF ASHRAE NCTA
                          AESC]

          # Find all positions where publishers appear (but NOT inside parentheses)
          # Publishers inside parentheses are part of relationship clauses, not dual published patterns
          publisher_positions = []
          publishers.each do |pub|
            # Look for publisher at word boundaries (preceded by space or start of string)
            regex = /(?:^|\s)(#{Regexp.escape(pub)})(?:\s|\/)/
            input.scan(regex) do
              match_pos = Regexp.last_match.begin(1)

              # Check if this publisher is inside parentheses (relationship clause)
              # Count parens before this position
              before_match = input[0...match_pos]
              paren_count = before_match.count("(") - before_match.count(")")

              # Skip publishers inside parentheses - they're part of relationship clauses
              next if paren_count.positive?

              publisher_positions << { pos: match_pos, publisher: pub }
            end
          end

          # If we have 2 or more publishers at distinct positions (not co-publishers with /)
          if publisher_positions.length >= 2
            # Sort by position
            publisher_positions.sort_by! { |p| p[:pos] }

            # Check if they're not part of a co-published pattern (Publisher1/Publisher2)
            # by ensuring there's no slash between them
            first_pub = publisher_positions[0]
            second_pub = publisher_positions[1]

            # Get the substring between the two publishers
            between = input[first_pub[:pos]..(second_pub[:pos] - 1)]

            # If there's no slash and no " and ", this might be space-separated dual
            if !between.include?("/") && !between.include?(" and ")
              # Try to split at the second publisher position
              # Back up to find the space before the second publisher
              split_pos = second_pub[:pos]
              while split_pos.positive? && input[split_pos - 1] == " "
                split_pos -= 1
              end

              first_part = input[0...split_pos].strip
              second_part = input[split_pos..].strip

              # Try to parse both parts
              begin
                first = parse_single(first_part)
                second = parse_single(second_part)

                # Only treat as dual if both parse successfully
                return Identifiers::DualPublished.new(
                  first_identifier: first,
                  second_identifier: second,
                )
              rescue Parslet::ParseFailed
                # If parsing fails, continue with normal flow
              end
            end
          end

          # Check for dual published patterns with " and "
          if input.include?(" and ")
            # DON'T split if " and " is inside parentheses (likely a relationship clause)
            # Check if parentheses are balanced and " and " is inside them
            paren_count = 0
            and_outside_parens = false
            and_position = nil

            input.each_char.with_index do |char, i|
              paren_count += 1 if char == "("
              paren_count -= 1 if char == ")"

              # Check if " and " starts at this position and we're outside parens
              if paren_count.zero? && input[i..(i + 4)] == " and "
                and_outside_parens = true
                and_position = i
                break
              end
            end

            # Only split if " and " is outside parentheses
            if and_outside_parens && and_position
              # Split at the found position only (not at all " and " occurrences)
              first_part = input[0...and_position].strip
              second_part = input[(and_position + 5)..].strip

              # Parse each part separately
              first = parse_single(first_part)
              second = parse_single(second_part)

              return Identifiers::DualPublished.new(
                first_identifier: first,
                second_identifier: second,
              )
            end
          end

          # NEW Session 171: Check for dual published patterns with " & " (ampersand)
          if input.include?(" & ")
            # DON'T split if " & " is inside parentheses
            paren_count = 0
            ampersand_outside_parens = false

            input.each_char.with_index do |char, i|
              paren_count += 1 if char == "("
              paren_count -= 1 if char == ")"

              # Check if " & " starts at this position and we're outside parens
              if paren_count.zero? && input[i..(i + 2)] == " & "
                ampersand_outside_parens = true
                break
              end
            end

            # Only split if " & " is outside parentheses
            if ampersand_outside_parens
              parts = input.split(" & ")
              if parts.length == 2
                # Parse each part separately
                first = parse_single(parts[0].strip)
                second = parse_single(parts[1].strip)

                return Identifiers::DualPublished.new(
                  first_identifier: first,
                  second_identifier: second,
                )
              end
            end
          end

          # Special case: AIEE identifiers with ASA parenthetical references
          # Pattern: "AIEE No 18-1934 (ASA C55 1934)"
          if input.match?(/^AIEE\s+/) && input.include?("(") && input.include?("ASA")
            main_part = input.split("(").first.strip
            adoption_match = input.match(/\((ASA[^)]+)\)/)

            if adoption_match
              adoption_part = adoption_match.captures.first
              # Parse the main AIEE identifier
              begin
                aiee_id = parse_single(main_part)
                # Parse the ASA identifier
                asa_id = parse_single(adoption_part)

                return Identifiers::AdoptedStandard.new(
                  ieee_identifier: aiee_id,
                  adopted_identifier: asa_id,
                )
              rescue Parslet::ParseFailed
                # If parsing fails, fall through to regular processing
              end
            end
          end

          # Check for adopted standards (parenthetical adoptions)
          # Only consider it an adoption if the parenthetical content looks like an identifier
          if input.include?("(") && input.include?(")") && !input.start_with?("IEC/IEEE ")
            # Extract the part before parentheses and the adoption part
            main_part = input.split("(").first.strip
            adoption_match = input.match(/\(([^)]+)\)/)
            adoption_part = adoption_match&.captures&.first

            # Check if adoption_part looks like an identifier (contains publisher or type keywords)
            # BUT exclude revision/amendment/supersedes notes
            # AND exclude Pattern 4 relationship types
            if main_part && adoption_part &&
                !adoption_part.match?(/^\s*(Revision|Revison|Amendment|Corrigendum|Corrigenda|incorporates|Incorporating|Incorporates|Adoption|Supplement|Draft Amendment|DRAFT Amendment|Draft Revision|Reaffirmation|Redesignation|redesignated as|Supersedes|Supercedes|Includes|Previously designated as|Notebooks|Standard Newspaper)/i) &&
                (adoption_part.match?(/\b(ANSI|ISO|IEC|IEEE|AIEE|IRE|ASA|ASTM|CSA|ASME|NACE|NSF|ASHRAE|NCTA|AESC)\s/) ||
                 adoption_part.match?(/^\s*(ANSI|ISO|IEC|IEEE|AIEE|IRE|ASA|ASTM|CSA|ASME|NACE|NSF|ASHRAE|NCTA|AESC)\b/) ||
                 adoption_part.match?(/\bStd\s+\d+/))
              # Parse the main IEEE identifier
              ieee_id = parse_single(main_part)

              # Parse comma-separated adopted identifiers
              adopted_parts = adoption_part.split(",").map(&:strip)
              adopted_ids = adopted_parts.map do |part|
                if part.strip.start_with?("IEC")
                  # Use IEC parser for IEC adoptions
                  # Preprocess to convert "Edition X.Y" to IEC format
                  # Pattern: "IEC 60255-24 Edition 2.0 2013-04" → "IEC 60255-24:2013-04 ED2.0"
                  iec_part = part.dup
                  # Replace " Edition X.Y YYYY-MM" (or similar) with ":YYYY-MM EDX.Y"
                  iec_part.gsub!(/\s+Edition\s+([0-9.]+)\s+([0-9-]+)/,
                                 ':\2 ED\1')
                  # Replace " Edition X.Y" at end (no date)
                  iec_part.gsub!(/\s+Edition\s+([0-9.]+)\s*$/, ' ED\1')
                  Pubid::Iec.parse(iec_part)
                elsif part.strip.start_with?("ANSI")
                  # Use ANSI parser for ANSI adoptions
                  Pubid::Ansi.parse(part)
                else
                  # Use IEEE parser for other adoptions
                  parse_single(part)
                end
              end

              return Identifiers::AdoptedStandard.new(
                ieee_identifier: ieee_id,
                adopted_identifiers: adopted_ids,
              )
            end
            # If it doesn't look like an identifier, let the parser handle it as additional_parameters
          end

          # Fall back to single identifier parsing
          parse_single(input)
        end

        # Parse a single IEEE identifier
        def self.parse_single(input)
          # Apply legacy update_codes normalization first, before Parser's extensive preprocessing
          normalized = Core::UpdateCodes.apply(input, :ieee)
          parsed = Parser.parse(normalized) # Use class method for preprocessing
          builder = Builder.new(Base)
          # Pass the original input string to builder for context
          builder.instance_variable_set(:@original_input, input)
          builder.build(parsed)
        end

        def to_s
          parts = []

          # Publisher(s) - handle copublisher array properly
          if copublisher && !copublisher.empty?
            # Copublisher is an array, join all publishers with single slash
            parts << [publisher, *copublisher].join("/")
          else
            parts << publisher
          end

          # Draft status
          parts << draft_status if draft_status

          # Type - only render for IEEE/AIEE publishers, and only for non-projects
          # Must come BEFORE code
          should_render_type = publisher&.match?(/^(IEEE|AIEE)/)

          if should_render_type && !typed_stage&.project_status && type && !type.to_s.strip.empty? && type != "P"
            # Non-project with explicit type (Std, No, etc.)
            type_str = type.dup
            # Remove P prefix if somehow present
            type_str = type_str.sub(/^P/, "") if type_str.start_with?("P")
            parts << type_str unless type_str.strip.empty?
          end

          # Code - with P prefix for projects (concatenated, not separated)
          if code_obj
            result = code_obj.to_s

            # Prepend P if this is a project AND code doesn't already have P
            if typed_stage&.project_status && should_render_type && !result.start_with?("P")
              result = "P#{result}"
            end

            # Only attach year to code if there's no edition, no month, and no draft
            result += "-#{year}" if year && !draft_obj && !edition && !month

            # Append draft to code - with or without space based on original format
            if draft_obj
              result += space_before_draft ? " #{draft_obj}" : draft_obj.to_s
            end

            # Append interpretation notation (/INT)
            result += "/INT" if interpretation

            # Append conformance notation (/ConformanceNN-YYYY)
            if conf_number
              result += "/Conformance#{conf_number}"
              result += "-#{conf_year}" if conf_year
            end

            # Append ASHRAE joint publication (/ASHRAE Guideline NN-YYYY)
            if ashrae_number
              result += "/ASHRAE Guideline #{ashrae_number}"
              result += "-#{ashrae_year}" if ashrae_year
            end

            # Append IEEE cross-reference (/C62.22.1-1996)
            result += crossref if crossref

            parts << result
          elsif should_render_type && typed_stage&.project_status
            # No code but is a project - add standalone P
            parts << "P"
          end

          # Edition - with year if present (IEC style)
          if edition
            edition_str = "Edition #{edition}"
            if year
              edition_str += " #{year}"
              edition_str += "-#{edition_month}" if edition_month
            end
            parts << edition_str
          end

          # Build the main identifier (without month yet)
          result = parts.join(" ")

          # Month/Day - append directly to avoid extra space before comma
          if month
            # Format: ", Month Day, Year" or ", Month, Year"
            result += ", #{month}"
            result += " #{day}" if day
            if year && !edition
              # Add comma after month if year follows
              result += ", #{year}"
            end
          end

          # Add parenthetical content if present
          # Handle multiple parenthetical clauses (reaffirmed + relationships/revision)
          parentheticals = []

          reaff = reaffirmed
          if reaff && !reaff.to_s.strip.empty?
            parentheticals << "(R#{reaff})"
          end

          # Then add relationships/revision/amendment as second parenthetical
          if parenthetical_content
            parentheticals << "(#{parenthetical_content})"
          elsif relationships && !relationships.empty?
            # Render relationships (multiple separated by /)
            relationship_str = relationships.join(" / ")
            parentheticals << "(#{relationship_str})"
          elsif revision_of
            parentheticals << "(Revision of IEEE Std #{revision_of})"
          elsif amendment_to
            parentheticals << "(Amendment to IEEE Std #{amendment_to})"
          elsif adoption
            parentheticals << "(Adoption of #{adoption})"
          elsif note && !note.to_s.strip.empty?
            # Only add note if it doesn't duplicate other content
            parentheticals << "(#{note})"
          end

          # Append all parentheticals with space separation
          result += " #{parentheticals.join(' ')}" unless parentheticals.empty?

          # Book nickname - outside parentheses in square brackets
          result += " [#{nickname}]" if nickname && !nickname.to_s.strip.empty?

          # Redline suffix
          result += " - Redline" if redline

          result
        end
      end
    end
  end
end
