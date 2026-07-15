# frozen_string_literal: true

module Pubid
  module Iana
    # Emits `urn:iana:<registry>[:<sub_registry>]`. Slugs contain no ":"
    # (charset is [a-zA-Z0-9._-]), so the two levels split unambiguously.
    class UrnGenerator < Pubid::UrnGenerator::Base
      def generate
        parts = ["urn", "iana", identifier.registry]
        parts << identifier.sub_registry if identifier.sub_registry
        parts.join(":")
      end
    end
  end
end
