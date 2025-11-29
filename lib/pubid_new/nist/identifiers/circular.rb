# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Nist
    module Identifiers
      # NBS Circular Identifier
      # Examples:
      # - "NBS CIRC 13e2revJune1908" = Circular 13, edition 2, revised June 1908
      # - "NBS CIRC 13" = Circular 13
      class Circular < Base
        attribute :revised_date, :string  # For revJune1908 notation

        def default_publisher
          "NBS"
        end

        def series_code
          "CIRC"
        end

        # Convenience methods for tests that expect string values
        def publisher
          super&.to_s || default_publisher
        end

        def series
          super&.to_s || series_code
        end
      end
    end
  end
end