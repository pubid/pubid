# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Ieee
    module Components
      # Represents a relationship between IEEE identifiers
      # E.g., "Revision of IEEE Std X, Y" or "incorporates A, B, C"
      #
      # Relationships capture metadata about how identifiers relate to each other:
      # - Revision relationships (one standard revises another)
      # - Amendment relationships (amendments to base standards)
      # - Incorporation relationships (one standard incorporates others)
      # - Adoption relationships (adopting external standards)
      #
      # Example usage:
      #   relationship = Relationship.new(
      #     relationship_type: Relationship::REVISION_OF,
      #     related_identifiers: [Base.parse("IEEE Std 802.11-2012")]
      #   )
      #   relationship.to_s  # => "Revision of IEEE Std 802.11-2012"
      class Relationship < Lutaml::Model::Serializable
        # Relationship type constants
        REVISION_OF = "revision_of"
        AMENDMENT_TO = "amendment_to"
        CORRIGENDUM_TO = "corrigendum_to"
        INCORPORATES = "incorporates"
        INCORPORATING = "incorporating"  # Synonym for incorporates
        ADOPTION_OF = "adoption_of"
        SUPPLEMENT_TO = "supplement_to"
        DRAFT_AMENDMENT_TO = "draft_amendment_to"
        DRAFT_REVISION_OF = "draft_revision_of"
        REAFFIRMATION_OF = "reaffirmation_of"
        REDESIGNATION_OF = "redesignation_of"
        SUPERSEDES = "supersedes"
        PREVIOUSLY_DESIGNATED_AS = "previously_designated_as"
        INCLUDES = "includes"  # NEW Session 171: For "Includes IEEE Std X" pattern

        # All valid relationship types
        VALID_TYPES = [
          REVISION_OF,
          AMENDMENT_TO,
          CORRIGENDUM_TO,
          INCORPORATES,
          INCORPORATING,
          ADOPTION_OF,
          SUPPLEMENT_TO,
          DRAFT_AMENDMENT_TO,
          DRAFT_REVISION_OF,
          REAFFIRMATION_OF,
          REDESIGNATION_OF,
          SUPERSEDES,
          PREVIOUSLY_DESIGNATED_AS,
          INCLUDES  # NEW Session 171
        ].freeze

        # Attributes
        attribute :relationship_type, :string

        # Use regular Ruby attributes to avoid circular dependency
        # related_identifiers: Array of Base identifiers
        # intermediate_amendments: Array of Base identifiers (for "as amended by" clause)
        attr_accessor :related_identifiers, :intermediate_amendments, :approved_amendments_flag

        # Validation
        def initialize(**args)
          # Extract our non-Lutaml attributes before calling super
          @related_identifiers = args.delete(:related_identifiers)
          @intermediate_amendments = args.delete(:intermediate_amendments)
          @approved_amendments_flag = args.delete(:approved_amendments_flag)

          # Let Lutaml handle relationship_type
          super

          # Normalize INCORPORATING to INCORPORATES for consistent rendering
          if relationship_type == INCORPORATING
            self.relationship_type = INCORPORATES
          end

          # Validate after initialization
          validate_relationship_type if relationship_type
        end

        def validate_relationship_type
          unless VALID_TYPES.include?(relationship_type)
            raise ArgumentError, "Invalid relationship type: #{relationship_type}. " \
                                 "Valid types: #{VALID_TYPES.join(', ')}"
          end
        end

        # Rendering
        def to_s
          return "" if related_identifiers.nil? || related_identifiers.empty?

          # Format: "Relationship Type IEEE Std X, IEEE Std Y, and IEEE Std Z"
          prefix = format_relationship_prefix
          ids = format_identifier_list(related_identifiers)

          # Add intermediate amendments if present (for "as amended by" clause)
          if intermediate_amendments && !intermediate_amendments.empty?
            amendments = format_identifier_list(intermediate_amendments)
            "#{prefix} #{ids} as amended by #{amendments}"
          elsif approved_amendments_flag
            # "and its approved amendments" clause (no specific list)
            "#{prefix} #{ids} and its approved amendments"
          else
            "#{prefix} #{ids}"
          end
        end

        private

        # Get the human-readable prefix for the relationship type
        def format_relationship_prefix
          case relationship_type
          when REVISION_OF then "Revision of"
          when AMENDMENT_TO then "Amendment to"
          when CORRIGENDUM_TO then "Corrigendum to"
          when INCORPORATES, INCORPORATING then "incorporates"
          when ADOPTION_OF then "Adoption of"
          when SUPPLEMENT_TO then "Supplement to"
          when DRAFT_AMENDMENT_TO then "Draft Amendment to"
          when DRAFT_REVISION_OF then "Draft Revision of"
          when REAFFIRMATION_OF then "Reaffirmation of"
          when REDESIGNATION_OF then "Redesignation of"
          when SUPERSEDES then "Supersedes"
          when PREVIOUSLY_DESIGNATED_AS then "Previously designated as"
          when INCLUDES then "Includes"  # NEW Session 171
          else relationship_type
          end
        end

        # Format a list of identifiers using proper English grammar:
        # - Single: "IEEE Std X"
        # - Two: "IEEE Std X and IEEE Std Y"
        # - Three+: "IEEE Std X, IEEE Std Y, and IEEE Std Z"
        def format_identifier_list(identifiers)
          return "" if identifiers.nil? || identifiers.empty?

          case identifiers.length
          when 1
            identifiers.first.to_s
          when 2
            "#{identifiers.first} and #{identifiers.last}"
          else
            # X, Y, and Z format (Oxford comma)
            last = identifiers.last
            others = identifiers[0..-2]
            "#{others.join(', ')}, and #{last}"
          end
        end
      end
    end
  end
end