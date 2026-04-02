# frozen_string_literal: true

module Pubid
  module Sae
    class Identifier
      def self.parse(input)
        parsed = Parser.parse(input)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse SAE identifier: #{input}\n#{e.message}"
      end
    end
  end
end
