# frozen_string_literal: true

module Pubid
  module Jis
    autoload :Builder, "#{__dir__}/jis/builder"
    autoload :Components, "#{__dir__}/jis/components"
    autoload :Identifier, "#{__dir__}/jis/identifier"
    autoload :Identifiers, "#{__dir__}/jis/identifiers"
    autoload :Parser, "#{__dir__}/jis/parser"
    autoload :Scheme, "#{__dir__}/jis/scheme"
    autoload :SingleIdentifier, "#{__dir__}/jis/single_identifier"
    autoload :SupplementIdentifier, "#{__dir__}/jis/supplement_identifier"
    autoload :UrnGenerator, "#{__dir__}/jis/urn_generator"

    # Parse a JIS identifier string
    def self.parse(identifier)
      Identifier.parse(identifier)
    end
  end
end

# Register JIS flavor with the registry
Pubid::Registry.register(:jis, Pubid::Jis)
