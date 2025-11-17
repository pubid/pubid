require_relative "ccsds/identifier"
require_relative "ccsds/single_identifier"
require_relative "ccsds/supplement_identifier"
require_relative "ccsds/scheme"
require_relative "ccsds/parser"
require_relative "ccsds/builder"

module PubidNew
  module Ccsds
    # Main entry point for CCSDS identifiers
    
    def self.parse(identifier_string)
      parsed = Parser.new.parse(identifier_string)
      Builder.new(Scheme).build(parsed)
    end
  end
end