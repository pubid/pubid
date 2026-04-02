# frozen_string_literal: true

module Pubid
  module Ieee
    module Identifiers
      module Nesc
        # Draft NESC identifier
        #
        # Represents draft versions of the National Electrical Safety Code
        # that are under development or review.
        #
        # @example
        #   nesc = Pubid::Ieee.parse("Draft National Electrical Safety Code, January 2016")
        #   nesc.to_s  # => "Draft National Electrical Safety Code, January 2016"
        class Draft < Base
          # Render draft identifier
          #
          # @return [String] Draft format with optional month and year
          def to_s
            parts = ["Draft National Electrical Safety Code"]
            parts << ", #{month} #{year.year}" if month && year
            parts.join
          end
        end
      end
    end
  end
end
