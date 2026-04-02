# frozen_string_literal: true

module Pubid
  module Cie
    # Generates RFC 5141-bis compliant URNs from CIE identifiers
    #
    # URN format: urn:cie:{s_prefix?}{code}:{year}:{language}:{stage}
    # Example: urn:cie:s001:2008:en for "CIE S 001:2008 (E)"
    class UrnGenerator
      attr_reader :identifier

      def initialize(identifier)
        @identifier = identifier
      end

      def generate
        parts = ["urn", "cie"]

        # Special identifier type component (comes before other components)
        # This explicitly differentiates special identifier classes
        special_type = special_identifier_type_component
        parts << special_type if special_type

        # S prefix
        if identifier.respond_to?(:s_prefix) && identifier.s_prefix
          parts << "s"
        end

        # Publisher (with copublishers)
        parts << publisher_component

        # Code
        if identifier.respond_to?(:code) && identifier.code
          parts << identifier.code.to_s
        end

        # Year
        if identifier.respond_to?(:year) && identifier.year
          parts << identifier.year.to_s
        elsif identifier.respond_to?(:date) && identifier.date
          year = identifier.date.respond_to?(:year) ? identifier.date.year : identifier.date.to_i
          parts << year.to_s
        end

        # Language (multiple formats: slash, slash_colon, parenthetical)
        if identifier.respond_to?(:language) && identifier.language
          lang = identifier.language
          if lang.respond_to?(:code)
            parts << lang.code.to_s.downcase
            if lang.respond_to?(:format) && lang.format
              parts << lang.format.to_s.downcase
            end
          else
            parts << lang.to_s.downcase
          end
        end

        # Stage (DIS, DS, etc.)
        if identifier.respond_to?(:stage) && identifier.stage
          parts << identifier.stage.to_s.downcase
        end

        # Date separator
        if identifier.respond_to?(:date_separator) && identifier.date_separator
          parts << "sep.#{identifier.date_separator}"
        end

        # IEC identifier (for DualPublished)
        if identifier.respond_to?(:iec_identifier) && identifier.iec_identifier
          parts << "iec.#{identifier.iec_identifier}"
        end

        # ISO reference (for Identical)
        if identifier.respond_to?(:iso_reference) && identifier.iso_reference
          parts << "iso.#{identifier.iso_reference}"
        end

        # Doc type (for JointPublished)
        if identifier.respond_to?(:doc_type) && identifier.doc_type
          parts << "doctype.#{identifier.doc_type}"
        end

        # Identifiers string (for Bundle)
        if identifier.respond_to?(:identifiers_string) && identifier.identifiers_string
          parts << "bundle.#{identifier.identifiers_string}"
        end

        # Bundle number (for TutorialBundle)
        if identifier.respond_to?(:bundle_number) && identifier.bundle_number
          parts << "tut-bundle.#{identifier.bundle_number}"
        end

        # Language codes (collection)
        if identifier.respond_to?(:languages) && identifier.languages&.any?
          lang_codes = identifier.languages.map(&:code).join(",")
          parts << lang_codes
        end

        parts.join(":")
      end

      private

      # Detect special identifier types for explicit URN differentiation
      # This ensures DualPublished, Identical, JointPublished, Bundle, TutorialBundle
      # have unique URN representations
      def special_identifier_type_component
        return nil unless identifier.class

        class_name = identifier.class.name.to_s
        case class_name
        when /DualPublished/
          "dual-pub"
        when /Identical/
          "identical"
        when /JointPublished/
          "joint-pub"
        when /Bundle$/
          "bundle"
        when /TutorialBundle/
          "tut-bundle"
        else
          nil
        end
      end

      def publisher_component
        # Get publisher from identifier or default to "cie"
        pub = "cie"

        if identifier.respond_to?(:publisher) && identifier.publisher
          pub = identifier.publisher.respond_to?(:body) ? identifier.publisher.body : identifier.publisher.to_s
          pub = pub.to_s.downcase
        end

        # Add copublishers if present
        if identifier.respond_to?(:copublisher) && identifier.copublisher
          copub = identifier.copublisher.respond_to?(:body) ? identifier.copublisher.body : identifier.copublisher.to_s
          pub = "#{pub}-#{copub.to_s.downcase}"
        elsif identifier.respond_to?(:copublishers) && identifier.copublishers&.any?
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
