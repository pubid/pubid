# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Itu
    autoload :Builder, "#{__dir__}/itu/builder"
    autoload :Identifier, "#{__dir__}/itu/identifier"
    autoload :Identifiers, "#{__dir__}/itu/identifiers"
    autoload :Parser, "#{__dir__}/itu/parser"
    autoload :Scheme, "#{__dir__}/itu/scheme"
    autoload :UrnGenerator, "#{__dir__}/itu/urn_generator"
    autoload :Model, "#{__dir__}/itu/model"

    def self.parse(identifier)
      Identifier.parse(identifier)
    end
  end
end

# Register ITU flavor with the registry
Pubid::Registry.register(:itu, Pubid::Itu)
