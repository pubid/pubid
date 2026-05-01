# frozen_string_literal: true

module Pubid
  module Iho
    autoload :Builder,      "#{__dir__}/iho/builder"
    autoload :Identifier,   "#{__dir__}/iho/identifier"
    autoload :Identifiers,  "#{__dir__}/iho/identifiers"
    autoload :Parser,       "#{__dir__}/iho/parser"
    autoload :Scheme,       "#{__dir__}/iho/scheme"
    autoload :UrnGenerator, "#{__dir__}/iho/urn_generator"

    # Parse an IHO identifier string into an identifier object
    # @param identifier [String] The IHO identifier string to parse
    # @return [Pubid::Iho::Identifiers::Base] The appropriate identifier object
    def self.parse(identifier)
      Identifier.parse(identifier)
    end
  end
end

Pubid::Registry.register(:iho, Pubid::Iho)
