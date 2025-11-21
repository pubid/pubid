# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Nist
    module Identifiers
      # NBS Circular Supplement Identifier
      # Examples:
      # - "NBS CIRC sup" = General supplement
      # - "NBS CIRC supJun1925-Jun1926" = Supplement covering date range June 1925 to June 1926
      class CircularSupplement < Base
        attribute :date_range_start, :string  # Jun1925
        attribute :date_range_end, :string    # Jun1927

        def publisher
          "NBS"
        end

        def series
          "CIRC"
        end

        def to_s
          result = "NBS CIRC sup"
          if date_range_start && date_range_end
            result += "#{date_range_start}-#{date_range_end}"
          end
          result
        end
      end
    end
  end
end