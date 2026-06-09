# frozen_string_literal: true


module Pubid
  module CenCenelec
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
