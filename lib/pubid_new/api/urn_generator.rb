# frozen_string_literal: true

module PubidNew
  module Api
    # Generates RFC 5141-bis compliant URNs from API identifiers
    #
    # URN format: urn:api:{type}:{number}:{year}
    # Example: urn:api:spec:5l:2012 for "API Spec 5L"
    class UrnGenerator
      attr_reader :identifier

      def initialize(identifier)
        @identifier = identifier
      end

      def generate
        parts = ["urn", "api"]

        # Type (bulletin, mpms, publication, recommended-practice, specification, standard, technical-report, typeless-standard)
        if identifier.respond_to?(:type) && identifier.type
          type = identifier.type.respond_to?(:abbr) ? identifier.type.abbr : identifier.type.to_s
          parts << type.to_s.downcase.gsub(" ", "-")
        else
          parts << "std"
        end

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

        # Month
        if identifier.respond_to?(:month) && identifier.month
          parts << format("%02d", identifier.month)
        end

        # Publisher
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
