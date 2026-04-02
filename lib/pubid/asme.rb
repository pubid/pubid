# frozen_string_literal: true

module Pubid
  module Asme
    autoload :Builder, "#{__dir__}/asme/builder"
    autoload :Components, "#{__dir__}/asme/components/code"
    autoload :Identifier, "#{__dir__}/asme/identifier"
    autoload :Identifiers, "#{__dir__}/asme/identifiers"
    autoload :Parser, "#{__dir__}/asme/parser"
    autoload :Scheme, "#{__dir__}/asme/scheme"
    autoload :SingleIdentifier, "#{__dir__}/asme/single_identifier"
    autoload :UrnGenerator, "#{__dir__}/asme/urn_generator"

    def self.parse(str)
      Identifier.parse(str)
    end
  end
end

# Register Uasme flavor with the registry
Pubid::Registry.register(:asme, Pubid::Asme)