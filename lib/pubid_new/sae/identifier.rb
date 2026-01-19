# frozen_string_literal: true

require_relative "../identifier"
require_relative "parser"
require_relative "builder"
require_relative "identifiers/base"

module PubidNew
  module Sae
    class Identifier
      def self.parse(input)
        parsed = Parser.parse(input)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise PubidNew::ParseError,
              "Failed to parse SAE identifier: #{input}\n#{e.message}"
      end
    end
  end
end
