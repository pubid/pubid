# frozen_string_literal: true

require_relative "parser"
require_relative "builder"

module PubidNew
  module Cen
    module Identifier
      def self.parse(identifier)
        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse CEN identifier '#{identifier}': #{e.message}"
      end
    end
  end
end