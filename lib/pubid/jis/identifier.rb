# frozen_string_literal: true

module Pubid
  module Jis
    module Identifier
      # Parse a JIS identifier string into an identifier object
      # @param identifier [String] The JIS identifier string to parse
      # @return [Identifiers::Base] The appropriate identifier object
      # @raise [Parslet::ParseFailed] If parsing fails
      def self.parse(identifier)
        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse JIS identifier '#{identifier}': #{e.message}"
      end
    end
  end
end
