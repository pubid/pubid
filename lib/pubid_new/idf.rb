require_relative "idf/identifiers/international_standard"
require_relative "idf/identifiers/reviewed_method"
require_relative "idf/identifiers/amendment"
require_relative "idf/identifiers/corrigendum"

module PubidNew
  module Idf
    def self.parse(identifier)
      parser = Parser.new
      builder = Builder.new

      parsed = parser.parse(identifier)
      builder.build(parsed)
    end
  end

  # Register this flavor with the PubidNew registry
  Registry.register(:idf, Idf)
end

require_relative "idf/scheme"
require_relative "idf/builder"
require_relative "idf/parser"
