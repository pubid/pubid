# frozen_string_literal: true

module Pubid
  module Amca
    autoload :Identifier, "#{__dir__}/amca/identifier"
    autoload :Identifiers, "#{__dir__}/amca/identifiers"
    autoload :Builder, "#{__dir__}/amca/builder"
    autoload :Parser, "#{__dir__}/amca/parser"
    autoload :Scheme, "#{__dir__}/amca/scheme"
    autoload :SingleIdentifier, "#{__dir__}/amca/single_identifier"
    autoload :UrnGenerator, "#{__dir__}/amca/urn_generator"

    # Parse an ACMA identifier string into an identifier object
    # @param identifier [String] The ACMA identifier string to parse
    # @return [Pubid::Amca::Identifier] The appropriate identifier object
    # @raise [Parslet::ParseFailed] If parsing fails
    def self.parse(identifier)
      Identifier.parse(identifier)
    end
  end

  # Register this flavor with the Pubid registry
end

# Register Uamca flavor with the registry
Pubid::Registry.register(:amca, Pubid::Amca)
