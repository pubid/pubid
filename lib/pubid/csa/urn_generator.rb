# frozen_string_literal: true

module Pubid
  module Csa
    # Generates RFC 5141-bis compliant URNs from CSA identifiers
    #
    # URN format: urn:csa:{prefix}:{number}:{year}:{reaffirmation}:{package}:{series}
    # Example: urn:csa:can:z245.1-10:2016 for "CAN/CSA-Z245.1-10:2016"
    class UrnGenerator
      attr_reader :identifier

      def initialize(identifier)
        @identifier = identifier
      end

      def generate
        parts = ["urn", "csa"]

        # Publisher prefix (CAN, CAN3, etc.)
        if identifier.respond_to?(:publisher_prefix) && identifier.publisher_prefix
          parts << identifier.publisher_prefix.to_s.downcase
        else
          parts << "csa"
        end

        # Number
        if identifier.respond_to?(:number) && identifier.number
          number = identifier.number.respond_to?(:value) ? identifier.number.value : identifier.number.to_s
          parts << number
        end

        # NO. keyword
        if identifier.respond_to?(:no_number) && identifier.no_number
          parts << "no.#{identifier.no_number}"
        end

        # Series
        if identifier.respond_to?(:series) && identifier.series
          parts << "series.#{identifier.series}"
        end

        # Series prefix
        if identifier.respond_to?(:series_prefix) && identifier.series_prefix
          parts << "series.#{identifier.series_prefix}"
        end

        # Year
        if identifier.respond_to?(:year) && identifier.year
          year = identifier.year.to_s
          # Convert 4-digit to 2-digit if needed
          year = year[-2..] if year.length == 4 && year.start_with?("20")
          parts << year
        end

        # Year prefix (M or F)
        if identifier.respond_to?(:year_prefix) && identifier.year_prefix
          parts[-1] = "#{identifier.year_prefix}#{parts[-1]}"
        end

        # Reaffirmation
        if identifier.respond_to?(:reaffirmation) && identifier.reaffirmation
          parts << "reaff.#{identifier.reaffirmation}"
        end

        # Package
        if identifier.respond_to?(:package) && identifier.package
          parts << "pkg.#{identifier.package}"
        end

        # Year format
        if identifier.respond_to?(:year_format) && identifier.year_format == "dash"
          parts << "format.dash"
        end

        # French
        if identifier.respond_to?(:french) && identifier.french
          parts << "french"
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
