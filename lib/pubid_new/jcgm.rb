# frozen_string_literal: true

module PubidNew
  module Jcgm
    # Parse a JCGM identifier string
    # @param identifier [String] the identifier string to parse
    # @return [Identifier] the parsed identifier
    def self.parse(identifier)
      parser = Parser.new
      builder = Builder.new(Scheme)

      parsed = parser.parse(identifier)
      builder.build(parsed)
    end
  end
end

require_relative "jcgm/identifier"
require_relative "jcgm/single_identifier"
require_relative "jcgm/supplement_identifier"
require_relative "jcgm/identifiers/guide"
require_relative "jcgm/identifiers/gum_guide"
require_relative "jcgm/identifiers/amendment"
require_relative "jcgm/builder"
require_relative "jcgm/parser"
require_relative "jcgm/scheme"