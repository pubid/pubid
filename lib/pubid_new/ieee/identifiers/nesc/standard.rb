# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Ieee
    module Identifiers
      module Nesc
        # Standard NESC identifier with C2-YYYY format
        #
        # Represents the standard National Electrical Safety Code publications
        # using the C2 designation followed by publication year.
        #
        # @example
        #   nesc = PubidNew::Ieee.parse("C2-1997 National Electric Safety Code")
        #   nesc.to_s  # => "C2-1997 National Electrical Safety Code"
        class Standard < Base
          # Render standard NESC identifier
          #
          # @return [String] C2-YYYY format
          def to_s
            "C2-#{year.year} National Electrical Safety Code"
          end
        end
      end
    end
  end
end
