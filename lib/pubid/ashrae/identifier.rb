# frozen_string_literal: true

module Pubid
  module Ashrae
    module Identifier
      # Parse an ASHRAE identifier string into an identifier object
      # @param identifier [String] The ASHRAE identifier string to parse
      # @return [Identifiers::Base] The appropriate identifier object
      # @raise [Parslet::ParseFailed] If parsing fails
      def self.parse(identifier)
        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse ASHRAE identifier '#{identifier}': #{e.message}"
      end
    end
  end
end
