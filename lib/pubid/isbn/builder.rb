# frozen_string_literal: true

module Pubid
  module Isbn
    # Builds a Pubid::Isbn::Identifier from a parse tree.
    #
    # Validates the check digit; raises if invalid. Stores both the
    # hyphenated form (for round-trip rendering) and the bare digits
    # (for queries).
    class Builder
      INVALID_LENGTH = /^(?:\d{9}[\dX]|\d{13})$/.freeze

      def self.build(parsed_data)
        new.build(parsed_data)
      end

      def build(data)
        hyphenated = data[:body].to_s
        raw = hyphenated.delete("-")

        validate_length!(raw)
        validate_check_digit!(raw)

        Identifiers::Book.new(raw: raw, hyphenated: hyphenated.include?("-") ? hyphenated : nil)
      end

      private

      def validate_length!(raw)
        return if raw.match?(INVALID_LENGTH)

        raise ArgumentError,
              "ISBN must be 10 or 13 digits (got #{raw.length})"
      end

      def validate_check_digit!(raw)
        return if CheckDigit.valid?(raw)

        raise ArgumentError,
              "ISBN check digit invalid for #{raw}"
      end
    end
  end
end
