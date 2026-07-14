# frozen_string_literal: true

module Pubid
  module Iana
    # Base class for every IANA identifier AND the flavor's parse/create entry
    # point. Concrete identifiers under Pubid::Iana::Identifiers descend from
    # this class, so a parsed IANA id is an instance of Pubid::Iana::Identifier.
    #
    # IANA entries are protocol registries, not numbered standards: the value is
    # a hierarchical registry slug (`registry` before the single "/", optional
    # `sub_registry` after it). Both are kept verbatim.
    class Identifier < ::Pubid::Identifier
      # The registry slug (e.g. "_6lowpan-parameters"). Required.
      attribute :registry, :string
      # The sub-registry slug (e.g. "lowpan_nhc"). nil for top registries; a nil
      # default means it is dropped from the serialized hash when absent.
      attribute :sub_registry, :string

      # Polymorphic type map for lutaml::Model key_value (de)serialization: maps
      # the single Registry subclass's polymorphic_name to its class name so a
      # stored hash rebuilds the correct identifier type via from_hash.
      IANA_TYPE_MAP = {
        "pubid:iana:registry" => "Pubid::Iana::Identifiers::Registry",
      }.freeze

      key_value do
        map "_type", to: :_type, polymorphic_map: IANA_TYPE_MAP
        map "registry", to: :registry
        map "sub_registry", to: :sub_registry
      end

      # Publisher is always "IANA". A plain constant (not a `publisher` method)
      # so it doesn't shadow the inherited lutaml `publisher` attribute, which
      # would otherwise fail serialization type validation.
      PUBLISHER = "IANA"

      # Render-time flag stashed by #to_s; when false, the "IANA " token is
      # dropped so callers can recover the bare index-key slug.
      attr_reader :with_publisher

      # The rendered registry code, e.g. "_6lowpan-parameters/lowpan_nhc".
      def code
        sub_registry ? "#{registry}/#{sub_registry}" : registry
      end

      # Basic string representation. Delegates to the renderer. Always emits the
      # "IANA " token (the authoritative printed form) unless with_publisher is
      # false, in which case the bare slug is rendered.
      def to_s(with_publisher: true, **opts)
        @with_publisher = with_publisher
        render(format: :human, **opts)
      end

      # from_hash is the shared polymorphic dispatch on Pubid::Identifier;
      # IANA_TYPE_MAP remains as the key_value polymorphic_map.

      # Parse an IANA identifier string into an identifier object
      # @param identifier [String] The IANA identifier string to parse
      # @return [Identifier] The appropriate identifier object
      def self.parse(identifier)
        if identifier.length > Pubid::MAX_INPUT_LENGTH
          raise ArgumentError, Pubid::INPUT_TOO_LONG_MESSAGE
        end

        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse IANA identifier '#{identifier}': #{e.message}"
      end
    end
  end
end
