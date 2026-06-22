# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Components
    # Relationship component — captures how one identifier relates to others.
    #
    # Originally modeled as IEEE's Components::Relationship; promoted to the
    # shared namespace because the same relationship vocabulary applies to
    # ISO, IEC, and other flavors that need to express "revises", "amends",
    # "incorporates", "adopts", etc.
    #
    # Shape:
    # - relationship_type: one of the VALID_TYPES constants below.
    # - related_identifiers: array of identifier objects the relationship
    #   points at (e.g., the standards being revised).
    # - intermediate_amendments: optional array of identifiers that amended
    #   the related identifier between its original publication and the
    #   current revision (renders as "... as amended by ...").
    # - approved_amendments_flag: when true and no intermediate_amendments
    #   are listed, renders "... and its approved amendments".
    class Relationship < Lutaml::Model::Serializable
      REVISION_OF = "revision_of"
      AMENDMENT_TO = "amendment_to"
      CORRIGENDUM_TO = "corrigendum_to"
      INCORPORATES = "incorporates"
      INCORPORATING = "incorporating"
      ADOPTION_OF = "adoption_of"
      SUPPLEMENT_TO = "supplement_to"
      DRAFT_AMENDMENT_TO = "draft_amendment_to"
      DRAFT_REVISION_OF = "draft_revision_of"
      REAFFIRMATION_OF = "reaffirmation_of"
      REDESIGNATION_OF = "redesignation_of"
      SUPERSEDES = "supersedes"
      PREVIOUSLY_DESIGNATED_AS = "previously_designated_as"
      INCLUDES = "includes"

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
        INCLUDES,
      ].freeze

      attribute :relationship_type, :string

      attr_accessor :related_identifiers, :intermediate_amendments,
                    :approved_amendments_flag

      PREFIXES = {
        REVISION_OF => "Revision of",
        AMENDMENT_TO => "Amendment to",
        CORRIGENDUM_TO => "Corrigendum to",
        INCORPORATES => "incorporates",
        ADOPTION_OF => "Adoption of",
        SUPPLEMENT_TO => "Supplement to",
        DRAFT_AMENDMENT_TO => "Draft Amendment to",
        DRAFT_REVISION_OF => "Draft Revision of",
        REAFFIRMATION_OF => "Reaffirmation of",
        REDESIGNATION_OF => "Redesignation of",
        SUPERSEDES => "Supersedes",
        PREVIOUSLY_DESIGNATED_AS => "Previously designated as",
        INCLUDES => "Includes",
      }.freeze

      def initialize(**args)
        @related_identifiers = args.delete(:related_identifiers)
        @intermediate_amendments = args.delete(:intermediate_amendments)
        @approved_amendments_flag = args.delete(:approved_amendments_flag)
        super
        normalize_incorporating!
        validate_relationship_type if relationship_type
      end

      def normalize_incorporating!
        return unless relationship_type == INCORPORATING

        self.relationship_type = INCORPORATES
      end

      def validate_relationship_type
        return if VALID_TYPES.include?(relationship_type)

        raise ArgumentError,
              "Invalid relationship type: #{relationship_type}. " \
              "Valid types: #{VALID_TYPES.join(', ')}"
      end

      def to_s
        return "" if related_identifiers.nil? || related_identifiers.empty?

        prefix = format_relationship_prefix
        ids = format_identifier_list(related_identifiers)
        return "#{prefix} #{ids}" unless intermediate_clause?

        "#{prefix} #{ids} #{intermediate_clause}"
      end

      def render(context: nil)
        to_s
      end

      private

      def intermediate_clause?
        (intermediate_amendments && !intermediate_amendments.empty?) ||
          approved_amendments_flag
      end

      def intermediate_clause
        if intermediate_amendments && !intermediate_amendments.empty?
          "as amended by #{format_identifier_list(intermediate_amendments)}"
        else
          "and its approved amendments"
        end
      end

      def format_relationship_prefix
        PREFIXES.fetch(relationship_type, relationship_type)
      end

      # Format a list of identifiers using proper English grammar:
      # - Single: "IEEE Std X"
      # - Two: "IEEE Std X and IEEE Std Y"
      # - Three+: "IEEE Std X, IEEE Std Y, and IEEE Std Z" (Oxford comma)
      def format_identifier_list(identifiers)
        return "" if identifiers.nil? || identifiers.empty?

        case identifiers.length
        when 1
          identifiers.first.to_s
        when 2
          "#{identifiers.first} and #{identifiers.last}"
        else
          "#{identifiers[0..-2].join(', ')}, and #{identifiers.last}"
        end
      end
    end
  end
end
