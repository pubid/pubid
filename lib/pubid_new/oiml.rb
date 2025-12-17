# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Oiml
    # Parse an OIML identifier string
    # @param identifier [String] the identifier string to parse
    # @return [Identifier] the parsed identifier
    def self.parse(identifier)
      parser = Parser.new
      builder = Builder.new

      parsed = parser.parse(identifier)
      builder.build(parsed)
    end
  end

  # Register this flavor with the PubidNew registry
  Registry.register(:oiml, Oiml)
end

require_relative "oiml/identifier"
require_relative "oiml/parser"
require_relative "oiml/builder"
require_relative "oiml/components/code"
require_relative "oiml/single_identifier"
require_relative "oiml/supplement_identifier"
require_relative "oiml/identifiers/base"
require_relative "oiml/identifiers/basic_publication"
require_relative "oiml/identifiers/document"
require_relative "oiml/identifiers/expert_report"
require_relative "oiml/identifiers/guide"
require_relative "oiml/identifiers/recommendation"
require_relative "oiml/identifiers/seminar_report"
require_relative "oiml/identifiers/vocabulary"
require_relative "oiml/identifiers/amendment"
require_relative "oiml/identifiers/annex"