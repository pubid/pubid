# frozen_string_literal: true

require_relative "pubid_new/version"
require_relative "pubid_new/scheme"

module PubidNew
  # Registry for tracking all loaded flavors
  class Registry
    @flavors = {}

    class << self
      attr_reader :flavors

      # Register a flavor with the registry
      # @param name [String, Symbol] Flavor name (e.g., :iso, :iec)
      # @param flavor_module [Module] The flavor module (e.g., PubidNew::Iso)
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
end

# Require all flavor modules
require_relative "pubid_new/iso"
require_relative "pubid_new/iec"
require_relative "pubid_new/nist"
require_relative "pubid_new/jcgm"
require_relative "pubid_new/ieee"
require_relative "pubid_new/jis"
require_relative "pubid_new/etsi"
require_relative "pubid_new/ccsds"
require_relative "pubid_new/itu"
require_relative "pubid_new/plateau"
require_relative "pubid_new/ansi"
require_relative "pubid_new/cen"
require_relative "pubid_new/bsi"
require_relative "pubid_new/idf"
require_relative "pubid_new/oiml"
require_relative "pubid_new/asme"
require_relative "pubid_new/csa"
require_relative "pubid_new/cie"
require_relative "pubid_new/astm"
require_relative "pubid_new/ashrae"
require_relative "pubid_new/amca"
require_relative "pubid_new/api"
require_relative "pubid_new/sae"

module PubidNew
end
