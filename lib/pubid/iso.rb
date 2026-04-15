# frozen_string_literal: true

require "lutaml/model"

module Pubid
  module Iso
    autoload :Builder, "#{__dir__}/iso/builder"
    autoload :BundledIdentifier, "#{__dir__}/iso/bundled_identifier"
    autoload :CombinedIdentifier, "#{__dir__}/iso/combined_identifier"
    autoload :Components, "#{__dir__}/iso/components"
    autoload :FormatResolver, "#{__dir__}/iso/format_resolver"
    autoload :Identifier, "#{__dir__}/iso/identifier"
    autoload :Identifiers, "#{__dir__}/iso/identifiers"
    autoload :Parser, "#{__dir__}/iso/parser"
    autoload :RenderingStyle, "#{__dir__}/iso/rendering_style"
    autoload :Scheme, "#{__dir__}/iso/scheme"
    autoload :SingleIdentifier, "#{__dir__}/iso/single_identifier"
    autoload :SupplementIdentifier, "#{__dir__}/iso/supplement_identifier"
    autoload :UrnGenerator, "#{__dir__}/iso/urn_generator"
    autoload :UrnParser, "#{__dir__}/iso/urn_parser"
    autoload :Utilities, "#{__dir__}/iso/utilities"

    # Parse an ISO identifier string
    # @param identifier [String] the identifier string to parse
    # @return [Identifier] the parsed identifier
    def self.parse(identifier)
      normalized = Core::UpdateCodes.apply(identifier, :iso)
      Scheme.parse(normalized)
    end

    # Parse an ISO URN string
    # @param urn [String] the URN string to parse
    # @return [Identifier] the parsed identifier
    # @raise [Errors::ParseError] if URN is invalid
    def self.parse_urn(urn)
      UrnParser.parse(urn)
    end
  end
end
