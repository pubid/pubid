# frozen_string_literal: true

module PubidNew
  module Amca
    # Generates RFC 5141-bis compliant URNs from AMCA identifiers
    #
    # URN format: urn:amca:{code}:{year}:{suffix}:{reaffirmed}
    # Example: urn:amca:210:2016 for "AMCA 210-2016"
    class UrnGenerator
      attr_reader :identifier

      def initialize(identifier)
        @identifier = identifier
      end

      def generate
        parts = ["urn", "amca"]

        # Code
        if identifier.respond_to?(:code) && identifier.code
          parts << identifier.code.to_s
        end

        # Year
        if identifier.respond_to?(:year) && identifier.year
          year = identifier.year.respond_to?(:value) ? identifier.year.value : identifier.year.to_s
          parts << year
        elsif identifier.respond_to?(:date) && identifier.date
          year = identifier.date.respond_to?(:year) ? identifier.date.year : identifier.date.to_i
          parts << year.to_s
        end

        # Suffix
        if identifier.respond_to?(:suffix) && identifier.suffix
          parts << identifier.suffix.to_s.downcase
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

        # Type
        if identifier.respond_to?(:type) && identifier.type
          parts << identifier.type.to_s.downcase
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
