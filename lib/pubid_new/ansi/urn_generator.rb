# frozen_string_literal: true

module PubidNew
  module Ansi
    # Generates RFC 5141-bis compliant URNs from ANSI identifiers
    #
    # URN format: urn:ansi:{number}:{part}:{year}:{type}
    # Example: urn:ansi:119.1-2016 for "ANSI 119.1-2016"
    class UrnGenerator
      attr_reader :identifier

      def initialize(identifier)
        @identifier = identifier
      end

      def generate
        parts = ["urn", "ansi"]

        # Number
        if identifier.respond_to?(:number) && identifier.number
          number = identifier.number.respond_to?(:value) ? identifier.number.value : identifier.number.to_s
          parts << number
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

        # Year
        if identifier.respond_to?(:date) && identifier.date
          year = identifier.date.respond_to?(:year) ? identifier.date.year : identifier.date.to_i
          parts << year.to_s
        elsif identifier.respond_to?(:year) && identifier.year
          parts << identifier.year.to_s
        end

        # Edition
        if identifier.respond_to?(:edition) && identifier.edition
          edition = identifier.edition.respond_to?(:number) ? identifier.edition.number : identifier.edition.to_s
          parts << "ed.#{edition}"
        end

        # Type (for non-ANS types)
        if identifier.respond_to?(:typed_stage) && identifier.typed_stage
          type_code = identifier.typed_stage.type_code
          if type_code && type_code.to_s != "ans"
            parts << type_code.to_s
          end
        end

        # Publisher (with copublishers)
        if identifier.respond_to?(:publisher) && identifier.publisher
          pub = identifier.publisher.respond_to?(:body) ? identifier.publisher.body : identifier.publisher.to_s
          parts[1] = pub.to_s.downcase
        end

        # Copublishers
        if identifier.respond_to?(:copublishers) && identifier.copublishers&.any?
          copubs = identifier.copublishers.map do |cp|
            cp.respond_to?(:body) ? cp.body : cp.to_s
          end
          parts[1] = "#{parts[1]}-#{copubs.join('-').downcase}"
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
