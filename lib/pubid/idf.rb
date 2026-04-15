# frozen_string_literal: true

module Pubid
  module Idf
    autoload :Builder, "#{__dir__}/idf/builder"
    autoload :Identifier, "#{__dir__}/idf/identifier"
    autoload :Identifiers, "#{__dir__}/idf/identifiers"
    autoload :Parser, "#{__dir__}/idf/parser"
    autoload :Scheme, "#{__dir__}/idf/scheme"
    autoload :SingleIdentifier, "#{__dir__}/idf/single_identifier"
    autoload :SupplementIdentifier, "#{__dir__}/idf/supplement_identifier"
    autoload :UrnGenerator, "#{__dir__}/idf/urn_generator"

    def self.parse(identifier)
      parser = Parser.new
      builder = Builder.new

      parsed = parser.parse(identifier)
      builder.build(parsed)
    end
  end
end

# Register Uidf flavor with the registry
Pubid::Registry.register(:idf, Pubid::Idf)
