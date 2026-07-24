# frozen_string_literal: true

module Pubid
  module Isbn
    class Identifier < ::Pubid::Identifier
      # The digits-only ISBN (no hyphens), including check digit. 10 or 13 chars.
      attribute :raw, :string

      # Original hyphenated form (may be nil when the input had no hyphens).
      # Preserved for round-trip rendering; not queryable semantics.
      attribute :hyphenated, :string

      ISBN_TYPE_MAP = {
        "pubid:isbn:book" => "Pubid::Isbn::Identifiers::Book",
      }.freeze

      key_value do
        map "_type", to: :_type, polymorphic_map: ISBN_TYPE_MAP
        map "raw", to: :raw
        map "hyphenated", to: :hyphenated
      end

      PUBLISHER = "ISBN"

      # Returns :isbn10 or :isbn13.
      def form
        case raw.to_s.length
        when 10 then :isbn10
        when 13 then :isbn13
        else raise "Invalid ISBN length: #{raw.inspect}"
        end
      end

      def check_digit
        raw.to_s[-1]
      end

      def valid?
        CheckDigit.valid?(raw)
      end

      def to_s(**opts)
        render(format: :human, **opts)
      end

      def self.parse(identifier)
        if identifier.length > Pubid::MAX_INPUT_LENGTH
          raise ArgumentError, Pubid::INPUT_TOO_LONG_MESSAGE
        end

        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse ISBN '#{identifier}': #{e.message}"
      rescue ArgumentError => e
        # Builder validates length/check-digit; surface as a parse error so
        # the error contract matches other flavors (always raises a string
        # beginning with "Failed to parse").
        raise "Failed to parse ISBN '#{identifier}': #{e.message}"
      end
    end
  end
end
