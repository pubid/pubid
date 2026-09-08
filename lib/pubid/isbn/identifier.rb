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
        unless identifier.is_a?(String)
          raise ArgumentError, Pubid::INPUT_NOT_A_STRING_MESSAGE
        end

        if identifier.length > Pubid::MAX_INPUT_LENGTH
          raise ArgumentError, Pubid::INPUT_TOO_LONG_MESSAGE
        end

        # The two guards above must stay OUTSIDE build_identifier: this method
        # rescues ArgumentError to convert the Builder's check-digit and
        # length validation into a parse failure, and that rescue used to
        # swallow the guards' own ArgumentError and re-raise it as a
        # RuntimeError - so ISBN was the one guarded flavor where an over-long
        # input did not surface as ArgumentError.
        build_identifier(identifier)
      end

      # @raise [Parslet::ParseFailed] if the string is not a valid ISBN
      def self.build_identifier(identifier)
        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      rescue ArgumentError => e
        # The Builder validates length and check digit. Surface that as a parse
        # failure, so every ISBN rejection reaches the caller as the same class
        # a grammar rejection does.
        raise Parslet::ParseFailed, "invalid ISBN '#{identifier}': #{e.message}"
      end
      private_class_method :build_identifier
    end
  end
end
