# frozen_string_literal: true

module Pubid
  module Ecma
    # Grammar for ECMA identifiers.
    #
    # Four printed forms:
    #   ECMA-411          standard
    #   ECMA-418-1        standard with part
    #   ECMA TR/101       technical report
    #   ECMA MEM/1970     memento
    #
    # Any of them may carry an edition and a volume, in that order:
    #   ECMA-269 ed3      third edition
    #   ECMA-402 ed5.1    decimal edition (real: ECMA-402)
    #   ECMA-269 ed3 vol2 second volume of the third edition
    #
    # Each branch captures its number under a distinct key so the builder can
    # pick the identifier class without a separate type token. Numbers are kept
    # as strings to preserve any leading zeros.
    class Parser
    end
  end
end
