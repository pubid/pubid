# frozen_string_literal: true

require "lutaml/model"
require_relative "../components/typed_stage"
require_relative "../components/relationship"

module PubidNew
  module Ieee
    module Components
      # Forward declare component classes
    end

    module Identifiers
      # Base class for all IEEE identifiers
      class Base < Lutaml::Model::Serializable
        attribute :publisher, :string, default: -> { "IEEE" }
        attribute :copublisher, :string, collection: true  # IEC, ISO, ANSI, etc.
        attribute :code, :string                            # Will store code as object in initialize
        attribute :year, :string
        attribute :type, :string, default: -> { "Std" }    # Std, Draft Std
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
        attribute :iso_identifier, :string                   # For IEC/IEEE formats
        attribute :parenthetical_content, :string           # Raw parenthetical content
        attribute :note, :string                            # Parenthetical notes
        attribute :adoption, :string                        # Adoption notes
        attribute :amendment_to, :string                    # Amendment to relationships
        attribute :edition_month, :string                   # Month part from Edition YYYY-MM
        attribute :space_before_draft, :boolean, default: -> { false }  # Track space before /D
        attribute :typed_stage, Components::TypedStage      # TYPED_STAGE integration
        attribute :relationships, Components::Relationship, collection: true  # Relationship metadata

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
            require_relative "../components/code"
            self.code_obj = Components::Code.parse(args[:code])
            self.code = args[:code]
          elsif args[:code]
            self.code_obj = args[:code]
            self.code = args[:code].to_s
          end

          # Handle draft as component object
          if args[:draft_obj]
            self.draft_obj = args[:draft_obj]
            self.draft = args[:draft_obj].to_s if args[:draft_obj].respond_to?(:to_s)
          elsif args[:draft]
            # If draft is passed as string, try to create Draft object
            require_relative "../components/draft"
            if args[:draft].is_a?(String)
              # Try to parse the string to extract version/revision
              if args[:draft].match(/^D(\d+)(?:\.(\d+))?/)
                version = $1
                revision = $2
                self.draft_obj = Components::Draft.new(version: version, revision: revision)
              else
                # Simple case - treat as version
                self.draft_obj = Components::Draft.new(version: args[:draft])
              end
              self.draft = self.draft_obj.to_s
            else
              self.draft_obj = args[:draft]
              self.draft = args[:draft].to_s if args[:draft].respond_to?(:to_s)
            end
          end

          # Set other attributes
          args.each do |key, value|
            next if key == :code || key == :draft
            send("#{key}=", value) if respond_to?("#{key}=")
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
          return nil unless draft_obj&.respond_to?(:numeric_month)
          draft_obj.numeric_month
        end

        # Parse IEEE identifier string
        def self.parse(input)
          require_relative "../parser"
          require_relative "../builder"
          require_relative "dual_published"
          require_relative "adopted_standard"
          require_relative "iec_ieee_copublished"

          # Check for IEC/IEEE copublished patterns first (before other checks)
          if input.start_with?("IEC/IEEE ")
            return parse_single(input)
          end

          # Check for space-separated dual identifiers (e.g., "IEC 62014-5 IEEE Std 1734-2011")
          # This must be checked before " and " pattern
          # Look for pattern where a second publisher appears after the first complete identifier
          # Publishers: IEEE, AIEE, ANSI, ASA, IEC, ISO, ASTM, NACE, NSF, ASHRAE, NCTA, AESC
          publishers = %w[IEEE AIEE ANSI ASA IEC ISO ASTM NACE NSF ASHRAE NCTA AESC]

          # Find all positions where publishers appear
          publisher_positions = []
          publishers.each do |pub|
            # Look for publisher at word boundaries (preceded by space or start of string)
            regex = /(?:^|\s)(#{Regexp.escape(pub)})(?:\s|\/)/
            input.scan(regex) do
              publisher_positions << { pos: Regexp.last_match.begin(1), publisher: pub }
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
            between = input[first_pub[:pos]..second_pub[:pos]-1]

            # If there's no slash and no " and ", this might be space-separated dual
            if !between.include?("/") && !between.include?(" and ")
              # Try to split at the second publisher position
              # Back up to find the space before the second publisher
              split_pos = second_pub[:pos]
              while split_pos > 0 && input[split_pos - 1] == " "
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
                  second_identifier: second
                )
              rescue Parslet::ParseFailed
                # If parsing fails, continue with normal flow
              end
            end
          end

          # Check for dual published patterns with " and "
          if input.include?(" and ")
            parts = input.split(" and ")
            if parts.length == 2
              # Parse each part separately
              first = parse_single(parts[0].strip)
              second = parse_single(parts[1].strip)

              return Identifiers::DualPublished.new(
                first_identifier: first,
                second_identifier: second
              )
            end
          end

          # Check for adopted standards (parenthetical adoptions)
          # Only consider it an adoption if the parenthetical content looks like an identifier
          if input.include?("(") && input.include?(")") && !input.start_with?("IEC/IEEE ")
            # Extract the part before parentheses and the adoption part
            main_part = input.split("(").first.strip
            adoption_match = input.match(/\(([^)]+)\)/)
            adoption_part = adoption_match ? adoption_match.captures.first : nil

            # Check if adoption_part looks like an identifier (contains publisher or type keywords)
            # BUT exclude revision/amendment/supersedes notes
            # AND exclude multi-part adoptions (containing commas)
            # AND exclude Pattern 4 relationship types
            if main_part && adoption_part &&
               !adoption_part.include?(",") &&  # Skip multi-part adoptions
               !adoption_part.match?(/^\s*(Revision|Revison|Amendment|Corrigendum|incorporates|Incorporating|Adoption|Supplement|Draft Amendment|DRAFT Amendment|Draft Revision|Supersedes|Supercedes|Notebooks|Standard Newspaper)/i) &&
               (adoption_part.match?(/\b(ANSI|ISO|IEC|IEEE|AIEE|ASA|ASTM|NACE|NSF|ASHRAE|NCTA|AESC)\s/) ||
                adoption_part.match?(/^\s*(ANSI|ISO|IEC|IEEE|AIEE|ASA|ASTM|NACE|NSF|ASHRAE|NCTA|AESC)\b/) ||
                adoption_part.match?(/\bStd\s+\d+/))
              # Parse the main IEEE identifier
              ieee_id = parse_single(main_part)

              # Parse the adopted identifier (could be ANSI, ISO, etc.)
              adopted_id = parse_single(adoption_part)

              return Identifiers::AdoptedStandard.new(
                ieee_identifier: ieee_id,
                adopted_identifier: adopted_id
              )
            end
            # If it doesn't look like an identifier, let the parser handle it as additional_parameters
          end

          # Fall back to single identifier parsing
          parse_single(input)
        end

        # Parse a single IEEE identifier
        def self.parse_single(input)
          parsed = Parser.parse(input)  # Use class method for preprocessing
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
          if month && !draft_obj
            # Format: ", Month Day, Year" or ", Month Year"
            result += ", #{month}"
            result += " #{day}" if day
            result += " #{year}" if year && !edition  # Don't duplicate year if already in edition
          end

          # Add parenthetical content if present
          if parenthetical_content
            result += " (#{parenthetical_content})"
          elsif relationships && !relationships.empty?
            # Render relationships (multiple separated by /)
            relationship_str = relationships.map(&:to_s).join(" / ")
            result += " (#{relationship_str})"
          elsif revision_of
            result += " (Revision of IEEE Std #{revision_of})"
          elsif amendment_to
            result += " (Amendment to IEEE Std #{amendment_to})"
          elsif adoption
            result += " (Adoption of #{adoption})"
          elsif note
            # Only add note if it doesn't duplicate other content
            result += " (#{note})" unless note.to_s.strip.empty?
          end

          # Redline suffix
          result += " - Redline" if redline

          result
        end
      end
    end
  end
end