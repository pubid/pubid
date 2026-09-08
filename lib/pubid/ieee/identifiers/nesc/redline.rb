# frozen_string_literal: true

module Pubid
  module Ieee
    module Identifiers
      module Nesc
        # NESC Redline identifier
        #
        # Represents redline versions of NESC which show changes from
        # previous editions with tracked changes highlighted.
        #
        # @example
        #   nesc = Pubid::Ieee.parse("2017 NESC Redline")
        #   nesc.to_s  # => "2017 NESC Redline"
        class Redline < Base
          include Pubid::Ieee::Identifiers::CodeNumber

          def self.polymorphic_name
            "pubid:ieee:nesc-redline"
          end

          # Render redline identifier
          #
          # @param trademark [Boolean] append the IEEE trademark symbol (™/®)
          # @return [String] YYYY NESC Redline format
          def to_s(trademark: false, **opts)
            result = [year, "NESC Redline"].compact.join(" ")
            result += trademark_symbol if trademark
            annotate_plain_render(result, **opts)
          end
        end
      end
    end
  end
end
