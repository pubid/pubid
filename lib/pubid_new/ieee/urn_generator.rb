# frozen_string_literal: true

module PubidNew
  module Ieee
    # Generates RFC 5141-bis compliant URNs from IEEE identifiers
    #
    # URN format includes all components for full identifier serialization:
    # urn:ieee:{type}:{code}-{year}:{draft}:{edition}:{month-day}:{modifiers}:{relationships}
    # Example: urn:ieee:std:802.3-2018:d1.0:ed.1:2018-06-20:redline
    class UrnGenerator
      attr_reader :identifier

      def initialize(identifier)
        @identifier = identifier
      end

      def generate
        parts = ["urn", "ieee"]

        # Publisher component (with copublishers)
        parts << publisher_component

        # Special identifier type component (comes before regular type)
        # This explicitly differentiates special identifier classes
        special_type = special_identifier_type_component
        parts << special_type if special_type

        # Type (Std, Draft Std, etc.)
        parts << type_component if type_component

        # Code component (includes all modifiers like /INT, /Conformance, /ASHRAE)
        parts << code_component

        # Year (if present)
        parts << identifier.year if identifier.respond_to?(:year) && identifier.year

        # Draft component (D1.0, etc.)
        parts << draft_component if draft_component

        # Edition component
        parts << edition_component if edition_component

        # Month/Day component
        parts << month_day_component if month_day_component

        # Draft status
        parts << draft_status_component if draft_status_component

        # Redline (only if not already handled by special type)
        unless special_type
          parts << "redline" if identifier.respond_to?(:redline) && identifier.redline
        end

        # Interpretation (only if not already handled by special type)
        unless special_type
          parts << "int" if identifier.respond_to?(:interpretation) && identifier.interpretation
        end

        # Conformance notation (only if not already handled by special type)
        unless special_type == "conformance"
          if identifier.respond_to?(:conf_number) && identifier.conf_number
            conf = "conf.#{identifier.conf_number}"
            conf += "-#{identifier.conf_year}" if identifier.conf_year
            parts << conf
          end
        end

        # ASHRAE joint publication
        if identifier.respond_to?(:ashrae_number) && identifier.ashrae_number
          ashrae = "ashrae.#{identifier.ashrae_number}"
          ashrae += "-#{identifier.ashrae_year}" if identifier.ashrae_year
          parts << ashrae
        end

        # Cross-reference
        parts << "xref.#{identifier.crossref}" if identifier.respond_to?(:crossref) && identifier.crossref

        # Relationships (supersedes, incorporates, etc.)
        if identifier.respond_to?(:relationships) && identifier.relationships&.any?
          rel = identifier.relationships.map(&:to_s).join("/")
          parts << "rel.#{rel}"
        end

        # Revision of
        if identifier.respond_to?(:revision_of) && identifier.revision_of
          parts << "revof.#{identifier.revision_of.to_s}"
        end

        # Amendment to
        if identifier.respond_to?(:amendment_to) && identifier.amendment_to
          parts << "amdto.#{identifier.amendment_to}"
        end

        # Adoption
        if identifier.respond_to?(:adoption) && identifier.adoption
          parts << "adopt.#{identifier.adoption}"
        end

        # Reaffirmed (if present as separate attribute)
        if identifier.respond_to?(:reaffirmed) && identifier.reaffirmed
          parts << "reaff.#{identifier.reaffirmed}"
        end

        # Note (additional metadata)
        if identifier.respond_to?(:note) && identifier.note
          parts << "note.#{identifier.note}"
        end

        # Nickname
        if identifier.respond_to?(:nickname) && identifier.nickname
          parts << "nick.#{identifier.nickname}"
        end

        parts.join(":")
      end

      private

      # Detect special identifier types for explicit URN differentiation
      # This ensures RedlinedStandard, SiStandard, ConformanceIdentifier, etc.
      # have unique URN representations
      def special_identifier_type_component
        # Check based on class name or specific attributes
        class_name = identifier.class.name.to_s

        case class_name
        when /RedlinedStandard/
          "redlined"
        when /SiStandard/
          "si"
        when /ConformanceIdentifier/
          "conformance"
        when /InterpretationIdentifier/
          "interpretation"
        when /SupplementIdentifier/
          # For supplement identifiers, use typed_stage type_code if available
          if identifier.respond_to?(:typed_stage) && identifier.typed_stage
            type_code = identifier.typed_stage.type_code
            # Map type codes to URN-friendly format
            case type_code.to_s
            when "amd"
              "amendment"
            when "cor"
              "corrigendum"
            when "errata"
              "errata"
            else
              type_code.to_s
            end
          end
        else
          # For regular Base identifiers, check typed_stage for special types
          if identifier.respond_to?(:typed_stage) && identifier.typed_stage
            type_code = identifier.typed_stage.type_code
            # Map SI type codes
            case type_code.to_s
            when "SI"
              "si"
            end
          end
        end
      end

      def publisher_component
        pub = identifier.respond_to?(:publisher) ? identifier.publisher : "IEEE"
        pub = pub.to_s.downcase

        # Add copublishers if present
        if identifier.respond_to?(:copublisher) && identifier.copublisher&.any?
          copubs = identifier.copublisher.map(&:to_s).map(&:downcase)
          pub = [pub, *copubs].join("-")
        end

        pub
      end

      def type_component
        return nil unless identifier.respond_to?(:type)

        type = identifier.type
        return nil if !type || type.to_s.strip.empty? || type.to_s == "Std"

        type.to_s.downcase.gsub(" ", ".")
      end

      def code_component
        return nil unless identifier.respond_to?(:code_obj)

        code = identifier.code_obj
        return nil unless code

        code.to_s
      end

      def draft_component
        return nil unless identifier.respond_to?(:draft_obj)

        draft = identifier.draft_obj
        return nil unless draft

        "draft.#{draft.to_s}"
      end

      def edition_component
        return nil unless identifier.respond_to?(:edition) && identifier.edition

        "ed.#{identifier.edition}"
      end

      def month_day_component
        parts = []

        if identifier.respond_to?(:month) && identifier.month
          parts << identifier.month
        end

        if identifier.respond_to?(:day) && identifier.day
          parts << identifier.day
        end

        return nil if parts.empty?

        parts.join("-")
      end

      def draft_status_component
        return nil unless identifier.respond_to?(:draft_status) && identifier.draft_status

        status = identifier.draft_status.downcase
        status.gsub(" ", ".")
      end
    end
  end
end
