# frozen_string_literal: true

module Pubid
  module Ashrae
    autoload :Builder, "#{__dir__}/ashrae/builder"
    autoload :Identifier, "#{__dir__}/ashrae/identifier"
    autoload :Identifiers, "#{__dir__}/ashrae/identifiers"
    autoload :Parser, "#{__dir__}/ashrae/parser"
    autoload :Scheme, "#{__dir__}/ashrae/scheme"
    autoload :SingleIdentifier, "#{__dir__}/ashrae/single_identifier"
    autoload :SupplementIdentifier, "#{__dir__}/ashrae/supplement_identifier"
    autoload :UrnGenerator, "#{__dir__}/ashrae/urn_generator"

    def self.parse(identifier)
      Identifier.parse(identifier)
    end
  end
end

# Register Uashrae flavor with the registry
Pubid::Registry.register(:ashrae, Pubid::Ashrae)
