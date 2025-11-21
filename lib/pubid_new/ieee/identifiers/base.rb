# frozen_string_literal: true

require "lutaml/model"

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

        # Store actual component objects
        attr_accessor :code_obj, :draft_obj

        def initialize(**args)
          super()

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

          # Check for dual published patterns first
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
          if input.include?("(") && input.include?(")") && !input.start_with?("IEC/IEEE ")
            # Extract the part before parentheses and the adoption part
            main_part = input.split("(").first.strip
            adoption_match = input.match(/\(([^)]+)\)/)
            adoption_part = adoption_match ? adoption_match.captures.first : nil

            if main_part && adoption_part
              # Parse the main IEEE identifier
              ieee_id = parse_single(main_part)

              # Parse the adopted identifier (could be ANSI, ISO, etc.)
              adopted_id = parse_single(adoption_part)

              return Identifiers::AdoptedStandard.new(
                ieee_identifier: ieee_id,
                adopted_identifier: adopted_id
              )
            end
          end

          # Fall back to single identifier parsing
          parse_single(input)
        end

        # Parse a single IEEE identifier
        def self.parse_single(input)
          parsed = Parser.new.parse(input)
          Builder.new.build(parsed)
        end

        def to_s
          parts = []

          # Publisher(s)
          if copublisher && !copublisher.empty?
            parts << [publisher, *copublisher].join("/")
          else
            parts << publisher
          end

          # Draft status
          parts << draft_status if draft_status

          # Type
          parts << type

          # Code with year (no space before dash)
          if code_obj
            result = code_obj.to_s
            result += "-#{year}" if year && !draft_obj
            parts << result
          end

          # Draft
          parts << draft_obj.to_s if draft_obj

          # Edition
          parts << "Edition #{edition}" if edition

          # Month/Day (if not already in draft)
          if month && !draft_obj
            parts << ", #{month}"
            parts << " #{day}" if day
            parts << ", #{year}" if year
          end

          # Redline suffix
          parts << "- Redline" if redline

          parts.join(" ")
        end
      end
    end
  end
end