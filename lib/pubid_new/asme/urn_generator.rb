# frozen_string_literal: true

module PubidNew
  module Asme
    # Generates RFC 5141-bis compliant URNs from ASME identifiers
    #
    # URN format: urn:asme:{special-type}:{code}:{part}:{year}:{edition}
    # Example: urn:asme:ptc:4.3:2015 for "ASME PTC 4.3-2015"
    # Example: urn:asme:handbook:b31.3:2020 for "ASME B31.3-2020 Handbook"
    class UrnGenerator
      attr_reader :identifier

      def initialize(identifier)
        @identifier = identifier
      end

      def generate
        parts = ["urn", "asme"]

        # Special identifier type component (comes before code)
        # This explicitly differentiates special identifier types
        special_type = special_identifier_type_component
        parts << special_type if special_type

        # Publisher (with copublishers)
        parts << publisher_component

        # Code
        if identifier.respond_to?(:code) && identifier.code
          parts << identifier.code.to_s
        end

        # Part
        if identifier.respond_to?(:part) && identifier.part
          part = identifier.part.respond_to?(:value) ? identifier.part.value : identifier.part.to_s
          parts[-1] = "#{parts[-1]}-#{part}"
        end

        # Subpart
        if identifier.respond_to?(:subpart) && identifier.subpart
          subpart = identifier.subpart.respond_to?(:value) ? identifier.subpart.value : identifier.subpart.to_s
          parts[-1] = "#{parts[-1]}-#{subpart}"
        end

        # Year (draft_year or year)
        if identifier.respond_to?(:draft_year) && identifier.draft_year
          parts << identifier.draft_year.to_s
        elsif identifier.respond_to?(:year) && identifier.year
          parts << identifier.year.to_s
        end

        # Edition
        if identifier.respond_to?(:edition) && identifier.edition
          edition = identifier.edition.respond_to?(:number) ? identifier.edition.number : identifier.edition.to_s
          parts << "ed.#{edition}"
        end

        # PTC suffix value (only if not already handled by special type)
        if special_type != "ptc" && identifier.respond_to?(:ptc_suffix) && identifier.ptc_suffix
          parts << "ptc-suffix.#{identifier.ptc_suffix}"
        end

        # CSA dual-published (only if not already handled by special type)
        if special_type != "csa" && identifier.respond_to?(:csa_number) && identifier.csa_number
          parts << "csa.#{identifier.csa_number}"
        end

        # First publisher (for joint published)
        if identifier.respond_to?(:first_publisher) && identifier.first_publisher
          parts << "pub1.#{identifier.first_publisher.to_s.downcase}"
        end

        # First code (for joint published)
        if identifier.respond_to?(:first_code) && identifier.first_code
          parts << "code1.#{identifier.first_code.to_s}"
        end

        # Second publisher (for joint published)
        if identifier.respond_to?(:second_publisher) && identifier.second_publisher
          parts << "pub2.#{identifier.second_publisher.to_s.downcase}"
        end

        # Joint publisher (ISO/ASME, ASME/ANS, etc.)
        if identifier.respond_to?(:joint_publisher) && identifier.joint_publisher
          parts << "joint.#{identifier.joint_publisher.to_s.downcase}"
        end

        # Language
        if identifier.respond_to?(:language) && identifier.language
          parts << identifier.language.to_s.downcase
        end

        # Reaffirmation
        if identifier.respond_to?(:reaffirmation) && identifier.reaffirmation
          parts << "reaff.#{identifier.reaffirmation}"
        end

        # Revision note
        if identifier.respond_to?(:revision_note) && identifier.revision_note
          parts << "revnote.#{identifier.revision_note}"
        end

        # Parenthetical revision
        if identifier.respond_to?(:parenthetical_revision) && identifier.parenthetical_revision
          parts << "prev.#{identifier.parenthetical_revision}"
        end

        # Language codes
        if identifier.respond_to?(:languages) && identifier.languages&.any?
          lang_codes = identifier.languages.map(&:code).join(",")
          parts << lang_codes
        end

        parts.join(":")
      end

      private

      # Detect special identifier types for explicit URN differentiation
      # This ensures PTC, Handbook, and CSA dual-published identifiers
      # have unique URN representations
      def special_identifier_type_component
        # Check based on attributes that indicate special types
        if identifier.respond_to?(:handbook) && identifier.handbook
          return "handbook"
        end

        if identifier.respond_to?(:ptc_suffix) && identifier.ptc_suffix
          return "ptc"
        end

        if identifier.respond_to?(:csa_number) && identifier.csa_number
          return "csa"
        end

        # Check class name for additional special types
        class_name = identifier.class.name.to_s
        case class_name
        when /PTC/
          "ptc"
        when /Handbook/
          "handbook"
        else
          nil
        end
      end

      def publisher_component
        # Get publisher from identifier or default to "asme"
        pub = "asme"

        if identifier.respond_to?(:publisher) && identifier.publisher
          pub = identifier.publisher.respond_to?(:body) ? identifier.publisher.body : identifier.publisher.to_s
          pub = pub.to_s.downcase
        end

        # Add copublishers if present
        if identifier.respond_to?(:copublishers) && identifier.copublishers&.any?
          copubs = identifier.copublishers.map do |cp|
            cp.respond_to?(:body) ? cp.body : cp.to_s
          end
          pub = "#{pub}-#{copubs.join('-').downcase}"
        end

        pub
      end
    end
  end
end
