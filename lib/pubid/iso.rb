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
      # Apply legacy-code rewrites (e.g. "ISO/TR 17716.2" -> "ISO/TR 17716")
      # before handing to the grammar. Loaded once and memoized.
      Scheme.parse(rewrites.apply(identifier))
    end

    # Memoized rewrite map loaded from lib/pubid/iso/update_codes.yaml.
    # @return [Pubid::Rewrites]
    def self.rewrites
      @rewrites ||= begin
        require_relative "rewrites"
        Pubid::Rewrites.load_yaml(File.join(__dir__, "iso", "update_codes.yaml"))
      end
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
