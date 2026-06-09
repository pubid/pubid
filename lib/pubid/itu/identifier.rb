# frozen_string_literal: true

require_relative "parser"
require_relative "builder"
require_relative "identifiers"
require_relative "components/sector"
require_relative "components/series"
require_relative "components/code"

module Pubid
  module Itu
    module Identifier
      def self.parse(identifier)
        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse ITU identifier '#{identifier}': #{e.message}"
      end
    end
  end
end
