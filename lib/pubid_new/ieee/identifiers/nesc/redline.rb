# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Ieee
    module Identifiers
      module Nesc
        # NESC Redline identifier
        #
        # Represents redline versions of NESC which show changes from
        # previous editions with tracked changes highlighted.
        #
        # @example
        #   nesc = PubidNew::Ieee.parse("2017 NESC Redline")
        #   nesc.to_s  # => "2017 NESC Redline"
        class Redline < Base
          # Render redline identifier
          #
          # @return [String] YYYY NESC Redline format
          def to_s
            "#{year.year} NESC Redline"
          end
        end
      end
    end
  end
end