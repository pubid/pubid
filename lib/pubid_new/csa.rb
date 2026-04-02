# frozen_string_literal: true

require_relative "csa/identifier"
require_relative "csa/wrapper_identifier"
require_relative "csa/composite_identifier"
require_relative "csa/identifiers/base"
require_relative "csa/identifiers/standard"
require_relative "csa/identifiers/combined"
require_relative "csa/identifiers/bundled"
require_relative "csa/identifiers/canadian_adopted"
require_relative "csa/identifiers/csa_adopted"
require_relative "csa/identifiers/package"
require_relative "csa/identifiers/series"
require_relative "csa/identifiers/cec"

# Scheme (must be loaded after identifiers)
require_relative "csa/scheme"

module PubidNew
  module Csa
    def self.parse(identifier_string)
      Identifier.parse(identifier_string)
    end
  end

  # Register this flavor with the PubidNew registry
end

# Register Ucsa flavor with the registry
PubidNew::Registry.register(:csa, PubidNew::Csa)
