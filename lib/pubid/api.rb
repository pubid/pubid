# frozen_string_literal: true

module Pubid
  module Api
    autoload :Builder, "#{__dir__}/api/builder"
    autoload :Identifier, "#{__dir__}/api/identifier"
    autoload :Identifiers, "#{__dir__}/api/identifiers"
    autoload :Parser, "#{__dir__}/api/parser"
    autoload :Renderer, "#{__dir__}/api/renderer"
    autoload :Scheme, "#{__dir__}/api/scheme"
    autoload :SingleIdentifier, "#{__dir__}/api/single_identifier"

    def self.parse(input)
      Identifier.parse(input)
    end
  end
end

# Register Uapi flavor with the registry
Pubid::Registry.register(:api, Pubid::Api)

# Per-flavor format registry: inherits global formats, overrides :human
Pubid::Api::Identifiers::Base.format_registry = Pubid::FormatRegistry.new(parent: Pubid::Identifier.format_registry)
Pubid::Api::Identifiers::Base.format_registry.register(:human, renderer: Pubid::Api::Renderer)
