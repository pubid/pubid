# frozen_string_literal: true

module Pubid
  module Cen
    autoload :Builder, "#{__dir__}/cen/builder"
    autoload :Identifier, "#{__dir__}/cen/identifier"
    autoload :Identifiers, "#{__dir__}/cen/identifiers"
    autoload :Parser, "#{__dir__}/cen/parser"
    autoload :Scheme, "#{__dir__}/cen/scheme"
    autoload :SingleIdentifier, "#{__dir__}/cen/single_identifier"
    autoload :SupplementIdentifier, "#{__dir__}/cen/supplement_identifier"
    autoload :UrnGenerator, "#{__dir__}/cen/urn_generator"

    def self.parse(identifier)
      Cen::Identifier.parse(identifier)
    end
  end
end

# Register Ucen flavor with the registry
Pubid::Registry.register(:cen, Pubid::Cen)