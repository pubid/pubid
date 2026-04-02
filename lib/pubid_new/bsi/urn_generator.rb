# frozen_string_literal: true

module PubidNew
  module Bsi
    # Generates RFC 5141-bis compliant URNs from BSI identifiers
    #
    # URN format: urn:bsi:{publisher-copub?}:{prefix?}{flex_prefix?}:{number}[iteration]:{part-subpart}:{second_number?}:{date}:{month}:{edition}:{translation}
    # Example: urn:bsi:bs:1000[9]-1:2000-06:v3:en for "BS 1000[9]-1:2000-06 v3 (English)"
    class UrnGenerator
      attr_reader :identifier

      def initialize(identifier)
        @identifier = identifier
      end

      def generate
        parts = ["urn", "bsi"]

        # Publisher (lowercase)
        if identifier.respond_to?(:publisher) && identifier.publisher
          pub = identifier.publisher.respond_to?(:body) ? identifier.publisher.body : identifier.publisher.to_s
          parts << pub.to_s.downcase
        else
          parts << "bs"
        end

        # Prefix (A, AU, C, M, 2A, etc.)
        if identifier.respond_to?(:prefix) && identifier.prefix
          parts << identifier.prefix.to_s.downcase
        end

        # Flex prefix (CECC, E9111, M, etc.)
        if identifier.respond_to?(:flex_prefix) && identifier.flex_prefix
          parts << identifier.flex_prefix.to_s.downcase
        end

        # Number with iteration
        if identifier.respond_to?(:number) && identifier.number
          number = identifier.number.respond_to?(:value) ? identifier.number.value : identifier.number.to_s
          # Add iteration if present (bracket notation like 1000[9])
          if identifier.respond_to?(:iteration) && identifier.iteration && !identifier.iteration.empty?
            number += "[#{identifier.iteration}]"
          end
          parts << number
        end

        # Part (with dash notation)
        if identifier.respond_to?(:part) && identifier.part
          part = identifier.part.respond_to?(:value) ? identifier.part.value : identifier.part.to_s
          parts << "-#{part}"
        end

        # Subpart
        if identifier.respond_to?(:subpart) && identifier.subpart
          subpart = identifier.subpart.respond_to?(:value) ? identifier.subpart.value : identifier.subpart.to_s
          parts << "-#{subpart}"
        end

        # Second number (for collections like PAS 2035/2030)
        if identifier.respond_to?(:second_number) && identifier.second_number
          second = identifier.second_number.respond_to?(:value) ? identifier.second_number.value : identifier.second_number.to_s
          parts << "/#{second}"
        end

        # Date (year)
        if identifier.respond_to?(:date) && identifier.date
          year = identifier.date.respond_to?(:year) ? identifier.date.year : identifier.date.to_i
          parts << year.to_s
        elsif identifier.respond_to?(:year) && identifier.year
          parts << identifier.year.to_s
        end

        # Month
        if identifier.respond_to?(:month) && identifier.month
          parts << format("%02d", identifier.month)
        end

        # Edition
        if identifier.respond_to?(:edition) && identifier.edition
          parts << "v#{identifier.edition}"
        end

        # Translation
        if identifier.respond_to?(:translation_lang) && identifier.translation_lang
          parts << identifier.translation_lang.to_s.downcase
        elsif identifier.respond_to?(:translation_upper) && identifier.translation_upper
          parts << identifier.translation_upper.to_s.downcase
        end

        # Type (if different from BS)
        if identifier.respond_to?(:type) && identifier.type
          type = identifier.type.respond_to?(:abbr) ? identifier.type.abbr : identifier.type.to_s
          parts << type.to_s.downcase if type && type.to_s != "BS"
        end

        # Stage (for draft documents)
        if identifier.respond_to?(:typed_stage) && identifier.typed_stage
          stage_code = identifier.typed_stage.stage_code
          if stage_code && stage_code != :published
            parts << "stage.#{stage_code}"
          end
        end

        parts.join(":")
      end
    end
  end
end
