# frozen_string_literal: true

module Pubid
  module Cie
    module Components
      autoload :Code, "#{__dir__}/cie/components/code"
      autoload :Language, "#{__dir__}/cie/components/language"
    end

    autoload :Builder, "#{__dir__}/cie/builder"
    autoload :Identifier, "#{__dir__}/cie/identifier"
    autoload :Identifiers, "#{__dir__}/cie/identifiers"
    autoload :Parser, "#{__dir__}/cie/parser"
    autoload :Scheme, "#{__dir__}/cie/scheme"
    autoload :SingleIdentifier, "#{__dir__}/cie/single_identifier"
    autoload :SupplementIdentifier, "#{__dir__}/cie/supplement_identifier"
    autoload :UrnGenerator, "#{__dir__}/cie/urn_generator"

    # Main entry point for CIE identifiers
    # Delegates to Identifier.parse
    def self.parse(input)
      Identifier.parse(input)
    end
  end
end

# Register Ucie flavor with the registry
Pubid::Registry.register(:cie, Pubid::Cie)
