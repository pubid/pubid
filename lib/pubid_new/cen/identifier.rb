# frozen_string_literal: true

require_relative "parser"
require_relative "builder"
require_relative "scheme"

module PubidNew
  module Cen
    module Identifier
      def self.parse(identifier)
        scheme = Scheme.new
        parsed = Parser.parse(identifier)
        Builder.new(scheme).build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse CEN identifier '#{identifier}': #{e.message}"
      end
    end
  end
end