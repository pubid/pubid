# frozen_string_literal: true

module Pubid
  module Ccsds
    autoload :Builder, "#{__dir__}/ccsds/builder"
    autoload :Identifier, "#{__dir__}/ccsds/identifier"
    autoload :Identifiers, "#{__dir__}/ccsds/identifiers"
    autoload :Parser, "#{__dir__}/ccsds/parser"
    autoload :Scheme, "#{__dir__}/ccsds/scheme"
    autoload :SingleIdentifier, "#{__dir__}/ccsds/single_identifier"
    autoload :SupplementIdentifier, "#{__dir__}/ccsds/supplement_identifier"
    autoload :UrnGenerator, "#{__dir__}/ccsds/urn_generator"

    def self.parse(identifier)
      Identifier.parse(identifier)
    end
  end
end

# Register Uccsds flavor with the registry
Pubid::Registry.register(:ccsds, Pubid::Ccsds)
