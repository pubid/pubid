# frozen_string_literal: true

module Pubid
  module Csa
    class Parser
      # Pre-parse ingestion normalizations (R2): every parse path feeds
      # the grammar the same normalized string.
      def self.normalize_input(input)
        # Skip comment lines
        if input.strip.start_with?("#")
          raise Pubid::Errors::ParseError.new(
            "Comment line", input: input, flavor: "csa"
          )
        end
        __normalize_input(input)
      end

      def self.__normalize_input(input)
        # Remove CONSOLIDATED notation FIRST (before other processing)
        normalized = input.gsub(/\s*\(\s*CONSOLIDATED\s*\)\s*/, " ")
        normalized = normalized.gsub(/\s*\bCONSOLIDATED\b\s*/, " ")

        # Fix missing space before reaffirmation
        # Matches: XX(RYYYY), XXX(RYY), or any non-space chars before (R
        # Examples: 04(R2009) -> 04 (R2009), 16(R24) -> 16 (R24)
        normalized = normalized.gsub(/(\S)\(R(\d{2,4})\)/, '\1 (R\2)')

        # DO NOT normalize NO., let it be parsed as a separate identifier component

        # Normalize CEI/IEC to IEC (CEI is French name for IEC)
        normalized = normalized.gsub("CEI/IEC", "IEC")
        normalized = normalized.gsub(/\bCEI\b/, "IEC")

        # Track original publisher prefix
        publisher_prefix = if normalized.start_with?("CAN/CSA-")
                             "CAN/CSA-"
                           elsif normalized.start_with?("CAN3-")
                             "CAN3-"
                           elsif normalized.start_with?("CSA ")
                             "CSA"
                           end

        # Normalize CAN/CSA- and CAN3- to CSA (preserving space before code)
        normalized = normalized.gsub("CAN/CSA-", "CSA ")
        normalized = normalized.gsub("CAN3-", "CSA ")

        # Clean up extra spaces
        normalized = normalized.gsub(/\s+/, " ").strip

        normalized
      end

      def self.publisher_prefix_for(input)
        if input.start_with?("CAN/CSA-")
          "CAN/CSA-"
        elsif input.start_with?("CAN3-")
          "CAN3-"
        elsif input.start_with?("CSA ")
          "CSA"
        end
      end

      private

      def self.inject_publisher_prefix(hash, prefix)
        # Combined and bundled identifiers carry their parts under the
        # csa_code_part[] group; the first part always takes the prefix,
        # later ones only when they spell their own publisher token (a
        # slash continuation like "CSA X/60601-1-6" does not).
        if (parts = hash[:csa_code_part])
          parts.each_with_index do |part, index|
            next if index.positive? && !part[:part_has_publisher] &&
                    !hash[:comma_separator]

            part[:publisher_prefix] = prefix
          end
          return hash
        end

        hash[:publisher_prefix] = prefix
        hash
      end
    end
  end
end
