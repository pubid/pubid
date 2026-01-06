# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Nist
    module Identifiers
      # NBS Commercial Standard (Emergency) Identifier
      # Format: NBS CS eNNN-YY where NNN is edition number, YY is 2-digit year
      # Example: "NBS CS e104-43" = Commercial Standard Emergency edition 104, year 1943
      class CommercialStandardEmergency < Base
        def series_code
          "CS-E"
        end

        private

        def to_short_style
          result = ""

          # Publisher
          effective_publisher = publisher ? publisher.to_s : "NBS"
          result += effective_publisher

          # Series as CS-E
          result += " CS-E"

          # Number (already extracted from e104 → 104 in builder)
          result += " #{number.value}" if number

          result
        end
      end
    end
  end
end