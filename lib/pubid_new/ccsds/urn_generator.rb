# frozen_string_literal: true

module PubidNew
  module Ccsds
    # Generates RFC 5141-bis compliant URNs from CCSDS identifiers
    #
    # URN format: urn:ccsds:{series?}{number}.{part}-{book_color}-{edition?}{-S?}:{language?}
    # Example: urn:ccsds:120.0-G-1-S for "CCSDS 120.0-G-1-S"
    class UrnGenerator
      attr_reader :identifier

      def initialize(identifier)
        @identifier = identifier
      end

      def generate
        if identifier.is_a?(SupplementIdentifier)
          generate_supplement_urn
        else
          generate_base_urn
        end
      end

      private

      def generate_base_urn
        parts = ["urn", "ccsds"]

        # Build the CCSDS identifier: series?number.part-book_color-edition-suffix
        # This follows the CCSDS naming convention directly
        identifier_parts = []

        # Series (optional single letter before number, like "A" in "A20.0")
        if identifier.respond_to?(:series) && identifier.series
          series = if identifier.series.respond_to?(:value)
                     identifier.series.value
                   else
                     identifier.series.to_s
                   end
          identifier_parts << series if series && !series.empty?
        end

        # Number (required) - handle both component objects and strings
        if identifier.respond_to?(:number) && identifier.number
          number = if identifier.number.respond_to?(:value)
                     identifier.number.value
                   else
                     identifier.number.to_s
                   end
          identifier_parts << number if number && !number.empty?
        end

        # Part (with dot notation: .0, .1, etc.)
        if identifier.respond_to?(:part) && identifier.part
          part = if identifier.part.respond_to?(:value)
                   identifier.part.value
                 else
                   identifier.part.to_s
                 end
          identifier_parts << ".#{part}" if part && !part.empty?
        end

        # Book color/type (REQUIRED: B, G, M, R, Y, O) - this is the series type
        if identifier.respond_to?(:book_color) && identifier.book_color
          book_color = if identifier.book_color.respond_to?(:value)
                         identifier.book_color.value
                       else
                         identifier.book_color.to_s
                       end
          identifier_parts << "-#{book_color}" if book_color && !book_color.empty?
        elsif identifier.respond_to?(:type) && identifier.type
          type = if identifier.type.respond_to?(:value)
                   identifier.type.value
                 else
                   identifier.type.to_s
                 end
          identifier_parts << "-#{type}" if type && !type.empty?
        end

        # Edition (optional: 1, 2, 3, etc.)
        if identifier.respond_to?(:edition) && identifier.edition
          edition = if identifier.edition.respond_to?(:value) || identifier.edition.respond_to?(:number)
                      if identifier.edition.respond_to?(:number)
                        identifier.edition.number
                      else
                        identifier.edition.value
                      end
                    else
                      identifier.edition.to_s
                    end
          identifier_parts << "-#{edition}" if edition && !edition.empty?
        end

        # Retired/Suffix (optional: -S)
        if identifier.respond_to?(:retired) && identifier.retired
          identifier_parts << "-S"
        elsif identifier.respond_to?(:suffix) && identifier.suffix
          suffix = if identifier.suffix.respond_to?(:value)
                     identifier.suffix.value
                   else
                     identifier.suffix.to_s
                   end
          identifier_parts << "-#{suffix}" if suffix && !suffix.empty?
        end

        # Join identifier parts and add to URN
        parts << identifier_parts.join unless identifier_parts.empty?

        # Language (optional: French Translated, Russian Translated)
        if identifier.respond_to?(:language) && identifier.language
          lang_code = if identifier.language.respond_to?(:code)
                        identifier.language.code
                      elsif identifier.language.is_a?(String)
                        identifier.language
                      elsif identifier.language.respond_to?(:to_s)
                        identifier.language.to_s
                      end
          # Normalize language code (remove "Translated" suffix)
          lang_code = lang_code.gsub(/ Translated$/, '').downcase if lang_code
          parts << lang_code if lang_code && !lang_code.empty?
        end

        parts.join(":")
      end

      def generate_supplement_urn
        # For supplements (corrigenda), we need to include the base identifier
        # and the supplement information
        parts = ["urn", "ccsds"]

        # Walk up to get base identifier
        current = identifier
        supplement_chain = []

        while current.is_a?(SupplementIdentifier)
          supplement_chain.unshift(current)
          current = current.base_identifier if current.respond_to?(:base_identifier)
        end

        # Generate base URN portion
        base_gen = self.class.new(current)
        base_urn = base_gen.send(:generate_base_urn)

        # Extract the identifier portion from base URN (everything after "urn:ccsds:")
        base_identifier_part = base_urn.sub(/^urn:ccsds:/, "")
        parts << base_identifier_part

        # Add supplement chain
        supplement_chain.each do |supp|
          # For CCSDS, supplements are typically corrigenda
          # We add the supplement type and number
          if supp.respond_to?(:number) && supp.number&.value
            parts << "cor.#{supp.number.value}"
          elsif supp.respond_to?(:typed_stage) && supp.typed_stage
            parts << supp.typed_stage.type_code.to_s
          end
        end

        parts.join(":")
      end
    end
  end
end
