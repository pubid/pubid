# frozen_string_literal: true

module PubidNew
  module Astm
    # Generates RFC 5141-bis compliant URNs from ASTM identifiers
    #
    # URN format: urn:astm:{code}:{year}:{sub_year}:{reapproval}:{edition}
    # Example: urn:astm:f1862:2015:e1 for "ASTM F1862-15e1"
    class UrnGenerator
      attr_reader :identifier

      def initialize(identifier)
        @identifier = identifier
      end

      def generate
        parts = ["urn", "astm"]

        # Type (standard, technical-report, etc.)
        if identifier.respond_to?(:type) && identifier.type
          type = identifier.type.respond_to?(:abbr) ? identifier.type.abbr : identifier.type.to_s
          parts << type.to_s.downcase
        else
          parts << "std"
        end

        # Code (may include dual unit designation like F1862/F1862M)
        if identifier.respond_to?(:code) && identifier.code
          parts << identifier.code.to_s
        end

        # Number (for standard types)
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

        # Year (2-digit format for ASTM)
        if identifier.respond_to?(:year) && identifier.year
          year = identifier.year.to_s
          # Convert to 2-digit format (e.g., 2015 -> 15)
          year = year[-2..] if year.length == 4
          parts << year
        elsif identifier.respond_to?(:date) && identifier.date
          date = identifier.date
          if date.respond_to?(:year)
            year = date.year.to_s
            year = year[-2..] if year.length == 4
            parts << year
          end
        end

        # Sub-year (a, b, c for revisions within a year)
        if identifier.respond_to?(:sub_year) && identifier.sub_year
          parts << identifier.sub_year.to_s
        end

        # Reapproval
        if identifier.respond_to?(:reapproval) && identifier.reapproval
          parts << "reapp.#{identifier.reapproval}"
        end

        # Edition (e1, e2, etc.)
        if identifier.respond_to?(:edition) && identifier.edition
          parts << "e#{identifier.edition}"
        end

        # Work in progress
        if identifier.respond_to?(:work_in_progress) && identifier.work_in_progress
          parts << "wip"
        end

        # WK (work item) designation
        if identifier.respond_to?(:wk) && identifier.wk
          parts << "wk.#{identifier.wk}"
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
