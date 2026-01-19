require_relative "idf/identifier"
# frozen_string_literal: true
require_relative "idf/single_identifier"
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
end

require_relative "idf/scheme"
require_relative "idf/builder"
require_relative "idf/parser"
