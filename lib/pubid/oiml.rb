# frozen_string_literal: true

module Pubid
  module Oiml
    autoload :Builder, "#{__dir__}/oiml/builder"
    autoload :Components, "#{__dir__}/oiml/components"
    autoload :Identifier, "#{__dir__}/oiml/identifier"
    autoload :Identifiers, "#{__dir__}/oiml/identifiers"
    autoload :Parser, "#{__dir__}/oiml/parser"
    autoload :Scheme, "#{__dir__}/oiml/scheme"
    autoload :SingleIdentifier, "#{__dir__}/oiml/single_identifier"
    autoload :SupplementIdentifier, "#{__dir__}/oiml/supplement_identifier"
    autoload :UrnGenerator, "#{__dir__}/oiml/urn_generator"

    def self.parse(identifier)
      parser = Parser.new
      builder = Builder.new

      parsed = parser.parse(identifier)
      builder.build(parsed)
    end
  end
end

# Register Uoiml flavor with the registry
Pubid::Registry.register(:oiml, Pubid::Oiml)
