# frozen_string_literal: true

require_relative "ashrae/identifier"

module PubidNew
  module Ashrae
    # Parse an ASHRAE identifier string into an identifier object
    # @param identifier [String] The ASHRAE identifier string to parse
    # @return [PubidNew::Ashrae::Identifiers::Base] The appropriate identifier object
    # @raise [Parslet::ParseFailed] If parsing fails
    def self.parse(identifier)
      Identifier.parse(identifier)
    end
  end

  # Register this flavor with the PubidNew registry
  Registry.register(:ashrae, Ashrae)
end
