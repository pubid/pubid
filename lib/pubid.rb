# frozen_string_literal: true

require "lutaml/model"
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
  autoload :Scheme, "pubid/scheme"
  autoload :Serializable, "pubid/serializable"
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
  autoload :Cen, "pubid/cen"
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
end
