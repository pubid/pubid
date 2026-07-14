# frozen_string_literal: true

module Pubid
  module Ogc
    # Emits `urn:ogc:<year>:<number>[:<revision>]`, e.g. `urn:ogc:24:032:r1`.
    class UrnGenerator < Pubid::UrnGenerator::Base
      def generate
        parts = ["urn", "ogc", identifier.year.to_s, identifier.number.to_s]
        parts << identifier.revision.to_s if identifier.revision
        parts.join(":")
      end
    end
  end
end
