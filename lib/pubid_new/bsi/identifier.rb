# frozen_string_literal: true

require_relative "parser"
require_relative "builder"
require_relative "scheme"

module PubidNew
  module Bsi
    module Identifier
      def self.parse(string)
        parser = Parser.new
        scheme = Scheme.new
        
        parsed = parser.parse(string)
        Builder.build(parsed, scheme)
      rescue Parslet::ParseFailed => e
        raise StandardError, "Failed to parse '#{string}': #{e.message}"
      end
    end
  end
end