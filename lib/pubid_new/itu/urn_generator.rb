# frozen_string_literal: true

module PubidNew
  module Itu
    # Generates RFC 5141-bis compliant URNs from ITU identifiers
    #
    # URN format: urn:itu:{sector}:{series}.{code}:{date}:{language}
    # Example: urn:itu:t:g.989:2004 for "ITU-T G.989 (2004)"
    class UrnGenerator
      attr_reader :identifier

      def initialize(identifier)
        @identifier = identifier
      end

      def generate
        if identifier.is_a?(Identifiers::Supplement)
          generate_supplement_urn
        else
          generate_base_urn
        end
      end

      private

      def generate_base_urn
        parts = ["urn", "itu"]

        # Sector (T, R, D, etc.)
        if identifier.respond_to?(:sector) && identifier.sector
          sector = identifier.sector.respond_to?(:value) ? identifier.sector.value : identifier.sector.to_s
          parts << sector.to_s.downcase
        else
          parts << "itu"
        end

        # Series and code
        if identifier.respond_to?(:series) && identifier.series
          series = identifier.series.respond_to?(:value) ? identifier.series.value : identifier.series.to_s
          if identifier.respond_to?(:code) && identifier.code
            code = identifier.code.respond_to?(:value) ? identifier.code.value : identifier.code.to_s
            parts << "#{series}.#{code}"
          else
            parts << series
          end
        elsif identifier.respond_to?(:code) && identifier.code
          code = identifier.code.respond_to?(:value) ? identifier.code.value : identifier.code.to_s
          parts << code
        end

        # Date (year or month/year)
        if identifier.respond_to?(:date) && identifier.date
          date = identifier.date
          if date.respond_to?(:year) && date.respond_to?(:month)
            parts << "#{date.month}/#{date.year}"
          elsif date.respond_to?(:year)
            parts << date.year.to_s
          end
        end

        # Language
        if identifier.respond_to?(:language) && identifier.language
          parts << identifier.language.to_s.downcase
        end

        parts.join(":")
      end

      def generate_supplement_urn
        # For supplements (amendments, corrigenda), include base and supplement info
        parts = ["urn", "itu"]

        if identifier.respond_to?(:base) && identifier.base
          base_gen = self.class.new(identifier.base)
          base_urn = base_gen.send(:generate_base_urn)

          # Extract base URN components (after "urn:itu:")
          base_part = base_urn.sub(/^urn:itu:/, "")
          base_parts = base_part.split(":")

          # Add base identifier components
          parts.concat(base_parts[0..-1])
        else
          # Fallback to sector/series/code if no base
          if identifier.respond_to?(:sector) && identifier.sector
            sector = identifier.sector.respond_to?(:value) ? identifier.sector.value : identifier.sector.to_s
            parts << sector.to_s.downcase
          end
          if identifier.respond_to?(:series) && identifier.series
            series = identifier.series.respond_to?(:value) ? identifier.series.value : identifier.series.to_s
            if identifier.respond_to?(:code) && identifier.code
              code = identifier.code.respond_to?(:value) ? identifier.code.value : identifier.code.to_s
              parts << "#{series}.#{code}"
            else
              parts << series
            end
          end
        end

        # Add supplement type (Amd for amendment, Cor for corrigendum)
        if identifier.respond_to?(:supplement_notation)
          parts << identifier.supplement_notation.to_s.downcase
        end

        # Add supplement number
        if identifier.respond_to?(:number) && identifier.number
          parts << identifier.number.to_s
        end

        # Add supplement date
        if identifier.respond_to?(:date) && identifier.date
          date = identifier.date
          if date.respond_to?(:year) && date.respond_to?(:month)
            parts << "#{date.month}/#{date.year}"
          elsif date.respond_to?(:year)
            parts << date.year.to_s
          end
        end

        parts.join(":")
      end
    end
  end
end
