# frozen_string_literal: true

require_relative "sae/identifier"
require_relative "sae/scheme"

module PubidNew
  module Sae
    def self.parse(input)
      Identifier.parse(input)
    end
  end

  # Register this flavor with the PubidNew registry
end

# Register Usae flavor with the registry
# PubidNew::Registry.register(:sae, PubidNew::Sae)
