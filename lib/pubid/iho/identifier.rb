# frozen_string_literal: true

module Pubid
  module Iho
    # Entry point for parsing IHO identifiers.
    module Identifier
      # Parse an IHO identifier string into an identifier object
      # @param identifier [String] The IHO identifier string to parse
      # @return [Pubid::Iho::Identifiers::Base] The appropriate identifier object
      # @raise [Parslet::ParseFailed] If parsing fails
      def self.parse(identifier)
        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse IHO identifier '#{identifier}': #{e.message}"
      end
    end
  end
end
