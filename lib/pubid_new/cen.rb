require_relative "cen/identifier"
require_relative "cen/single_identifier"
require_relative "cen/supplement_identifier"
require_relative "cen/scheme"
require_relative "cen/parser"
require_relative "cen/builder"

module PubidNew
  module Cen
    # Main entry point for CEN identifiers
    
    def self.parse(identifier_string)
      parsed = Parser.new.parse(identifier_string)
      Builder.new(Scheme).build(parsed)
    end
  end
end