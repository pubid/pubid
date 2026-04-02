# frozen_string_literal: true

module Pubid
  module Etsi
    class Identifier
      def self.parse(identifier)
        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse ETSI identifier '#{identifier}': #{e.message}"
      end
    end
  end
end
