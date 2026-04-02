# frozen_string_literal: true

module Pubid
  module Csa
    autoload :Builder, "#{__dir__}/csa/builder"
    autoload :Identifier, "#{__dir__}/csa/identifier"
    autoload :Identifiers, "#{__dir__}/csa/identifiers"
    autoload :Parser, "#{__dir__}/csa/parser"
    autoload :Scheme, "#{__dir__}/csa/scheme"
    autoload :SingleIdentifier, "#{__dir__}/csa/single_identifier"
    autoload :UrnGenerator, "#{__dir__}/csa/urn_generator"
    autoload :WrapperIdentifier, "#{__dir__}/csa/wrapper_identifier"
    autoload :CompositeIdentifier, "#{__dir__}/csa/composite_identifier"
    autoload :Components, "#{__dir__}/csa/components"

    def self.parse(identifier_string)
      Identifier.parse(identifier_string)
    end
  end

  # Register this flavor with the Pubid registry
end

# Register Ucsa flavor with the registry
Pubid::Registry.register(:csa, Pubid::Csa)
