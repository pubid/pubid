# frozen_string_literal: true

module Pubid
  module Ashrae
    # Generates RFC 5141-bis compliant URNs from ASHRAE identifiers
    #
    # URN format: urn:ashrae:{code}:{year}:{type}:{suffix}:{amendment}:{reaffirmed}
    # Example: urn:ashrae:90.1:2019 for "ASHRAE 90.1-2019"
    class UrnGenerator
      attr_reader :identifier

      def initialize(identifier)
        @identifier = identifier
      end

      def generate
        parts = ["urn", "ashrae"]

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

        # Type
        if identifier.respond_to?(:type) && identifier.type
          parts << identifier.type.to_s.downcase
        end

        # Suffix (R for revision, P for proposed, etc.)
        if identifier.respond_to?(:suffix) && identifier.suffix
          parts << identifier.suffix.to_s.downcase
        end

        # Amendment
        if identifier.respond_to?(:amendment) && identifier.amendment
          parts << "amd.#{identifier.amendment}"
        end

        # Reaffirmed
        if identifier.respond_to?(:reaffirmed) && identifier.reaffirmed
          parts << "reaff.#{identifier.reaffirmed}"
        end

        # Copublisher
        if identifier.respond_to?(:copublisher) && identifier.copublisher
          parts << "copub.#{identifier.copublisher.to_s.downcase}"
        end

        # Publisher
        if identifier.respond_to?(:publisher) && identifier.publisher
          pub = identifier.publisher.to_s.downcase
          parts[1] = pub
        end

        # Addendum
        if identifier.respond_to?(:addendum) && identifier.addendum
          parts << "add.#{identifier.addendum}"
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
