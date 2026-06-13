# frozen_string_literal: true

module Pubid
  module Bsi
    module Identifier
      def self.parse(string)
        # Delegate to IEC for bare IEC identifiers
        # This handles IEC-specific features like VAP suffixes (CSV, RLV, etc.)
        # and consolidated supplements (+AMD1:2001)
        if string.match?(/\bIEC\b/) &&
            (string.match?(/\s+(CSV|CMV|RLV|SER|EXV|PAC|PRV)\b/) ||
             string.match?(/\+AMD\d+:/) ||
             string.match?(/\+COR\d+:/))
          return Pubid::Iec.parse(string)
        end

        parser = Parser.new

        parsed = parser.parse(string)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise StandardError, "Failed to parse '#{string}': #{e.message}"
      end
    end
  end
end
