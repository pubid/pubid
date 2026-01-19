# frozen_string_literal: true

require_relative "amca/identifier"

module PubidNew
  module Amca
    # Parse an ACMA identifier string into an identifier object
    # @param identifier [String] The ACMA identifier string to parse
    # @return [PubidNew::Amca::Identifier] The appropriate identifier object
    # @raise [Parslet::ParseFailed] If parsing fails
    def self.parse(identifier)
      Identifier.parse(identifier)
    end
  end

  # Register this flavor with the PubidNew registry
end
