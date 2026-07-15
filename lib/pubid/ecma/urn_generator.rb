# frozen_string_literal: true

module Pubid
  module Ecma
    # Emits `urn:ecma:<tag>:<number>[:part-<part>]` where the tag is bare for
    # standards, "tr" for technical reports and "mem" for mementos:
    #   ECMA-411      -> urn:ecma:411
    #   ECMA-418-1    -> urn:ecma:418:part-1
    #   ECMA TR/101   -> urn:ecma:tr:101
    #   ECMA MEM/1970 -> urn:ecma:mem:1970
    class UrnGenerator < Pubid::UrnGenerator::Base
      def generate
        parts = ["urn", "ecma"]

        tag = identifier.type_prefix&.downcase
        parts << tag if tag

        parts << identifier.number.to_s
        parts << "part-#{identifier.part}" if identifier.part

        parts.join(":")
      end
    end
  end
end
