# frozen_string_literal: true

module Pubid
  module Jcgm
    autoload :Builder, "#{__dir__}/jcgm/builder"
    autoload :Components, "#{__dir__}/jcgm/components"
    autoload :Identifier, "#{__dir__}/jcgm/identifier"
    autoload :Identifiers, "#{__dir__}/jcgm/identifiers"
    autoload :Parser, "#{__dir__}/jcgm/parser"
    autoload :Scheme, "#{__dir__}/jcgm/scheme"
    autoload :SingleIdentifier, "#{__dir__}/jcgm/single_identifier"
    autoload :SupplementIdentifier, "#{__dir__}/jcgm/supplement_identifier"
    autoload :UrnGenerator, "#{__dir__}/jcgm/urn_generator"

    # Parse a JCGM identifier string
    # @param identifier [String] the identifier string to parse
    # @return [Identifier] the parsed identifier
    def self.parse(identifier)
      parser = Parser.new
      builder = Builder.new(Scheme)

      parsed = parser.parse(identifier)
      builder.build(parsed)
    end
  end

  # Register this flavor with the Pubid registry
end

# Register Ujcgm flavor with the registry
Pubid::Registry.register(:jcgm, Pubid::Jcgm)
