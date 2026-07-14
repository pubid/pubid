# frozen_string_literal: true

module Pubid
  module Gost
    # Builds a GOST identifier object from the Parslet parse tree.
    class Builder
      # Year is the trailing 2- or 4-digit run after the LAST separator
      # (hyphen / em-dash / en-dash, optionally with surrounding
      # whitespace). Anything before is the number, including any
      # subpart dashes (`14179-1`).
      NUMBER_YEAR_SPLIT = /\A(.+?)\s*[-—–]\s*(\d{2}|\d{4})\z/.freeze

      def build(parsed)
        number, year = split_number_year(stringify(parsed[:raw]))

        attrs = {
          scope:       scope_from_tree(parsed),
          copublisher: stringify(parsed[:copublisher]),
          number:      number,
          year:        year,
        }.compact

        Identifiers::Standard.new(**attrs)
      end

      def self.build(parsed)
        new.build(parsed)
      end

      private

      def scope_from_tree(parsed)
        parsed[:scope_r] ? "russian" : nil
      end

      def split_number_year(raw)
        return [raw, nil] unless raw

        m = raw.match(NUMBER_YEAR_SPLIT)
        return [raw, nil] unless m

        [m[1], m[2]]
      end

      def stringify(value)
        return nil if value.nil?

        str = value.to_s
        str.empty? ? nil : str
      end
    end
  end
end
