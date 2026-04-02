# frozen_string_literal: true

require "parslet"

module Pubid
  module Plateau
    autoload :Builder, "#{__dir__}/plateau/builder"
    autoload :Identifiers, "#{__dir__}/plateau/identifiers"
    autoload :Parser, "#{__dir__}/plateau/parser"
    autoload :Scheme, "#{__dir__}/plateau/scheme"
    autoload :SupplementIdentifier, "#{__dir__}/plateau/supplement_identifier"
    autoload :UrnGenerator, "#{__dir__}/plateau/urn_generator"

    def self.parse(input)
      parser = Parser.new
      parsed = parser.parse(input)
      Builder.build(parsed)
    end
  end
end

# Register Uplateau flavor with the registry
Pubid::Registry.register(:plateau, Pubid::Plateau)
