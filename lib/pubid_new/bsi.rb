require_relative "bsi/parser"
require_relative "bsi/scheme"
require_relative "bsi/model"
require_relative "bsi/builder"

module PubidNew
  module Bsi
    class << self
      def parse(input)
        # Parse the input string
        parsed = Parser.new.parse(input)
        
        # Transform to structured data
        transformed = Scheme.transform(parsed)
        
        # Build the model
        Builder.new(Scheme).build(transformed)
      rescue Parslet::ParseFailed => e
        raise StandardError, "Failed to parse BSI identifier: #{input}\n#{e.message}"
      end
    end
  end
end