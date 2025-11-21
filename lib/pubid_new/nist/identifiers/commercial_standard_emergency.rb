# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Nist
    module Identifiers
      # NBS Commercial Standard (Emergency) Identifier
      # Format: NBS CS eNNN-YY where NNN is edition number, YY is 2-digit year
      # Example: "NBS CS e104-43" = Commercial Standard Emergency edition 104, year 1943
      class CommercialStandardEmergency < Base
        def publisher
          "NBS"
        end

        def series
          "CS"
        end

        def to_s
          result = "NBS CS"
          result += " #{first_number}" if first_number
          result
        end
      end
    end
  end
end