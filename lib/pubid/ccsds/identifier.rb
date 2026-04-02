# frozen_string_literal: true

module Pubid
  module Ccsds
    module Identifier
      def self.parse(identifier)
        parsed = Pubid::Ccsds::Parser.parse(identifier)
        Pubid::Ccsds::Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse CCSDS identifier '#{identifier}': #{e.message}"
      end
    end
  end
end
