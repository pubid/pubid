# frozen_string_literal: true

require "parslet"
require "lutaml/model"
require_relative "identifier"
require_relative "asme/identifier"
require_relative "asme/components/code"
require_relative "asme/single_identifier"
require_relative "asme/parser"
require_relative "asme/builder"

# Identifier classes
require_relative "asme/identifiers/base"
require_relative "asme/identifiers/standard"

# Scheme (must be loaded after identifiers)
require_relative "asme/scheme"

module PubidNew
  module Asme
    def self.parse(str)
      Identifier.parse(str)
    end
  end

  # Register this flavor with the PubidNew registry
end

# Register Uasme flavor with the registry
PubidNew::Registry.register(:asme, PubidNew::Asme)
