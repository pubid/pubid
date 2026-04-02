# frozen_string_literal: true

module Pubid
  module Sae
    # Generates RFC 5141-bis compliant URNs from SAE identifiers
    #
    # URN format: urn:sae:{type}:{number}:{year}
    # Example: urn:sae:aerospace:as4101:2008 for "SAE Aerospace AS4101"
    class UrnGenerator
      attr_reader :identifier

      def initialize(identifier)
        @identifier = identifier
      end

      def generate
        parts = ["urn", "sae"]

        # Type (AMS, AIR, ARP, AS, MA, etc.)
        if identifier.respond_to?(:type) && identifier.type
          type = identifier.type.respond_to?(:abbr) ? identifier.type.abbr : identifier.type.to_s
          parts << type.to_s.downcase
        else
          parts << "std"
        end

        # Number (may include letter prefix and number)
        if identifier.respond_to?(:number) && identifier.number
          parts << identifier.number.to_s
        end

        # Year
        if identifier.respond_to?(:date) && identifier.date
          year = identifier.date.respond_to?(:year) ? identifier.date.year : identifier.date.to_i
          parts << year.to_s
        elsif identifier.respond_to?(:year) && identifier.year
          parts << identifier.year.to_s
        end

        # Revision (e.g., "A", "B", etc.)
        if identifier.respond_to?(:revision) && identifier.revision
          parts << "rev.#{identifier.revision}"
        end

        # Edition
        if identifier.respond_to?(:edition) && identifier.edition
          edition = identifier.edition.respond_to?(:number) ? identifier.edition.number : identifier.edition.to_s
          parts << "ed.#{edition}"
        end

        # Publisher (with copublishers)
        if identifier.respond_to?(:publisher) && identifier.publisher
          pub = identifier.publisher.to_s.downcase
          parts[1] = pub
        end

        # Language codes
        if identifier.respond_to?(:languages) && identifier.languages&.any?
          lang_codes = identifier.languages.map(&:code).join(",")
          parts << lang_codes
        end

        parts.join(":")
      end
    end
  end
end
