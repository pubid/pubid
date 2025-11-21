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

        def publisher
          "NBS"
        end

        def series
          "CIRC"
        end

        def to_s
          # Use the Base class rendering logic but override series
          super
        end
      end
    end
  end
end