# frozen_string_literal: true

module Pubid
  module Amca
    module Identifier
      # Parse an ACMA identifier string into an identifier object
      # @param identifier [String] The ACMA identifier string to parse
      # @return [Pubid::Amca::Identifier] The appropriate identifier object
      # @raise [Parslet::ParseFailed] If parsing fails
      def self.parse(identifier)
        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse ACMA identifier '#{identifier}': #{e.message}"
      end
    end
  end
end
