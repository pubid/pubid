# frozen_string_literal: true

module Pubid
  module Isbn
    # Pure-functional check digit math for ISBN-10 and ISBN-13 per ISO 2108.
    #
    # ISBN-10: weighted sum with weights 10..1, mod 11. Check digit 10 is
    # rendered as "X".
    # ISBN-13: weighted sum with alternating weights 1/3, mod 10. Check digit
    # is 0-9.
    class CheckDigit
      # Compute the correct ISBN-10 check digit for a 9-digit payload.
      # @return [String] "0".."9" or "X"
      def self.compute_isbn10(payload)
        raise ArgumentError, "ISBN-10 payload must be 9 digits" unless payload.to_s.match?(/\A\d{9}\z/)

        sum = payload.to_s.each_char.with_index.sum { |c, i| c.to_i * (10 - i) }
        digit = (11 - sum % 11) % 11
        digit == 10 ? "X" : digit.to_s
      end

      # Compute the correct ISBN-13 check digit for a 12-digit payload.
      # @return [String] "0".."9"
      def self.compute_isbn13(payload)
        raise ArgumentError, "ISBN-13 payload must be 12 digits" unless payload.to_s.match?(/\A\d{12}\z/)

        sum = payload.to_s.each_char.with_index.sum do |c, i|
          c.to_i * (i.even? ? 1 : 3)
        end
        ((10 - sum % 10) % 10).to_s
      end

      # Verify the check digit on a full 10- or 13-digit ISBN string.
      # @param full [String] 10 or 13 chars; ISBN-10 may end with X.
      # @return [Boolean]
      def self.valid?(full)
        digits = full.to_s.upcase.delete("^0-9X")
        case digits.length
        when 10
          payload = digits[0, 9]
          actual = digits[9]
          compute_isbn10(payload) == actual
        when 13
          payload = digits[0, 12]
          actual = digits[12]
          compute_isbn13(payload) == actual
        else
          false
        end
      end
    end
  end
end
