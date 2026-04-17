# frozen_string_literal: true

module Pubid
  module Etsi
    # Generates RFC 5141-bis compliant URNs from ETSI identifiers
    #
    # URN format: urn:etsi:{type}:{code}:{version}:{date}
    # Example: urn:etsi:en:300001:v1.1.1:2022-12 for "ETSI EN 300 001 V1.1.1 (2022-12)"
    class UrnGenerator
      attr_reader :identifier

      def initialize(identifier)
        @identifier = identifier
      end

      def generate
        # Check if identifier is a supplement by checking class name
        if identifier.class.name&.include?("SupplementIdentifier")
          generate_supplement_urn
        else
          generate_base_urn
        end
      end

      private

      def generate_base_urn
        parts = ["urn", "etsi"]

        # Type (EN, ES, EG, TS, ETR, ETS, I-ETS, TBR, TCRTR, NET, GR, GS, SR, TR, GTS)
        parts << if identifier.respond_to?(:type) && identifier.type
                   identifier.type.to_s.downcase
                 else
                   "en"
                 end

        # Code (may include series and number)
        if identifier.respond_to?(:code) && identifier.code
          parts << identifier.code.to_s
        end

        # Version
        if identifier.respond_to?(:version) && identifier.version
          parts << identifier.version.to_s.downcase
        end

        # Date (year-month format)
        if identifier.respond_to?(:date) && identifier.date
          date = identifier.date
          if date.respond_to?(:year) && date.respond_to?(:month)
            parts << "#{date.year}-#{format('%02d', date.month)}"
          elsif date.respond_to?(:year)
            parts << date.year.to_s
          end
        end

        parts.join(":")
      end

      def generate_supplement_urn
        # For supplements (amendments, corrigenda), include base and supplement info
        parts = ["urn", "etsi"]

        if identifier.respond_to?(:base) && identifier.base
          base_gen = self.class.new(identifier.base)
          base_urn = base_gen.send(:generate_base_urn)

          # Extract base URN components (after "urn:etsi:")
          base_part = base_urn.sub(/^urn:etsi:/, "")
          base_parts = base_part.split(":")

          # Add base identifier components
          parts.concat(base_parts)
        else
          # Fallback to identifier's own type/code/version if no base
          if identifier.respond_to?(:type) && identifier.type
            parts << identifier.type.to_s.downcase
          end
          if identifier.respond_to?(:code) && identifier.code
            parts << identifier.code.to_s
          end
          if identifier.respond_to?(:version) && identifier.version
            parts << identifier.version.to_s.downcase
          end
          if identifier.respond_to?(:date) && identifier.date
            date = identifier.date
            if date.respond_to?(:year) && date.respond_to?(:month)
              parts << "#{date.year}-#{format('%02d', date.month)}"
            elsif date.respond_to?(:year)
              parts << date.year.to_s
            end
          end
        end

        # Add supplement type (A for amendment, C for corrigendum)
        if identifier.respond_to?(:supplement_notation)
          parts << identifier.supplement_notation.to_s.downcase
        end

        # Add supplement number
        if identifier.respond_to?(:number) && identifier.number
          parts << identifier.number.to_s
        end

        parts.join(":")
      end
    end
  end
end
