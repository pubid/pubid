# frozen_string_literal: true

require "lutaml/model"
require_relative "pubid/lutaml/no_store_registration"
require "parslet"

module Pubid
  # Registry for tracking all loaded flavors
  class Registry
    @flavors = {}

    class << self
      attr_reader :flavors

      # Register a flavor with the registry
      # @param name [String, Symbol] Flavor name (e.g., :iso, :iec)
      # @param flavor_module [Module] The flavor module (e.g., Pubid::Iso)
      def register(name, flavor_module)
        @flavors[name.to_s.downcase] = flavor_module
      end

      # Get all registered flavor names
      # @return [Array<String>] Array of flavor names
      def flavor_names
        @flavors.keys.sort
      end

      # Get flavor module by name
      # @param name [String, Symbol] Flavor name
      # @return [Module, nil] The flavor module or nil if not found
      def get(name)
        @flavors[name.to_s.downcase]
      end

      # Check if a flavor is registered
      # @param name [String, Symbol] Flavor name
      # @return [Boolean]
      def registered?(name)
        @flavors.key?(name.to_s.downcase)
      end
    end
  end

  autoload :Parser, "pubid/parser"
  autoload :Components, "pubid/components"
  autoload :BundledIdentifier, "pubid/bundled_identifier"
  autoload :Identifier, "pubid/identifier"
  autoload :IdentifierMetadata, "pubid/identifier_metadata"
  autoload :IdentifierRegistry, "pubid/identifier_registry"
  autoload :Rendering, "pubid/rendering"
  autoload :Renderers, "pubid/renderers"
  autoload :FormatDetector, "pubid/format_detector"
  autoload :FormatRegistry, "pubid/format_registry"
  autoload :Scheme, "pubid/scheme"

  autoload :UrnGenerator, "pubid/urn_generator/base"
  autoload :Utils, "pubid/utils"
  autoload :Version, "pubid/version"
  autoload :Core, "pubid/core"

  # Require all flavor modules
  autoload :Amca, "pubid/amca"
  autoload :Ansi, "pubid/ansi"
  autoload :Api, "pubid/api"
  autoload :Ashrae, "pubid/ashrae"
  autoload :Asme, "pubid/asme"
  autoload :Astm, "pubid/astm"
  autoload :Bsi, "pubid/bsi"
  autoload :Ccsds, "pubid/ccsds"
  autoload :CenCenelec, "pubid/cen_cenelec"
  autoload :Cie, "pubid/cie"
  autoload :Csa, "pubid/csa"
  autoload :Etsi, "pubid/etsi"
  autoload :Idf, "pubid/idf"
  autoload :Iec, "pubid/iec"
  autoload :Ieee, "pubid/ieee"
  autoload :Iho, "pubid/iho"
  autoload :Iso, "pubid/iso"
  autoload :Itu, "pubid/itu"
  autoload :Jcgm, "pubid/jcgm"
  autoload :Jis, "pubid/jis"
  autoload :Nist, "pubid/nist"
  autoload :Oiml, "pubid/oiml"
  autoload :Plateau, "pubid/plateau"
  autoload :Export, "pubid/export"
  autoload :Sae, "pubid/sae"

  # Format infrastructure (loaded eagerly so Pubid::Renderers / Pubid::Parsers are always available)
  require "pubid/renderers/base"
  require "pubid/renderers/mr_string"
  require "pubid/renderers/urn"
  require "pubid/parsers/base"
  require "pubid/parsers/mr_string"

  # Initialize global format registry
  Identifier.format_registry = FormatRegistry.new
  Identifier.format_registry.register(:human, renderer: Renderers::HumanReadable)
  Identifier.format_registry.register(:mr_string, renderer: Renderers::MrString)
  Identifier.format_registry.register(:urn, renderer: Renderers::Urn)

  # Unified parse entry point with auto-detection
  #
  # @param string [String] The identifier string to parse
  # @param format [Symbol] :auto, :human, :mr_string, or :urn
  # @return [Identifier] The parsed identifier
  def self.parse(string, format: :auto)
    format = FormatDetector.detect(string) if format == :auto

    case format
    when :mr_string
      Parsers::MrString.parse(string)
    when :urn
      # URN auto-detection: extract flavor from URN namespace
      # e.g., "urn:iso:std:..." → Pubid::Iso
      flavor = detect_flavor_from_urn(string)
      flavor_module = Registry.get(flavor)
      raise ArgumentError, "Unknown flavor in URN: #{flavor}" unless flavor_module

      urn_parser = flavor_module.const_get(:UrnParser)
      urn_parser.parse(string)
    else
      # Default to MR string parser for MR format, human-readable otherwise
      # The MR string parser converts to human-readable and delegates to flavor.parse
      raise ArgumentError, "No flavor specified. Use Pubid::Iso.parse() or another flavor-specific parse method."
    end
  end

  def self.detect_flavor_from_urn(urn)
    # urn:iso:std:... → "iso"
    # urn:iec:std:... → "iec"
    parts = urn.downcase.split(":")
    parts[1] # The namespace part after "urn"
  end
end
