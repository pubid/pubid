require_relative "jis/identifier"
require_relative "jis/single_identifier"
require_relative "jis/scheme"
require_relative "jis/parser"
require_relative "jis/builder"

module PubidNew
  module Jis
    # Main entry point for JIS identifiers
    
    def self.parse(identifier_string)
      parsed = Parser.new.parse(identifier_string)
      Builder.new(Scheme).build(parsed)
    end
  end
end