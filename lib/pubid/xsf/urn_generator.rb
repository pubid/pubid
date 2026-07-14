# frozen_string_literal: true

module Pubid
  module Xsf
    # Emits `urn:xsf:xep:<number>` (e.g. urn:xsf:xep:0001). The number keeps its
    # zero padding so the URN round-trips back to the printed identifier.
    class UrnGenerator < Pubid::UrnGenerator::Base
      def generate
        ["urn", "xsf", "xep", identifier.number.to_s].join(":")
      end
    end
  end
end
