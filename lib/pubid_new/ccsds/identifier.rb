# frozen_string_literal: true

require_relative "parser"
require_relative "builder"

module PubidNew
  module Ccsds
    module Identifier
      def self.parse(identifier)
        parsed = PubidNew::Ccsds::Parser.parse(identifier)
        PubidNew::Ccsds::Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse CCSDS identifier '#{identifier}': #{e.message}"
      end
    end
  end
end
