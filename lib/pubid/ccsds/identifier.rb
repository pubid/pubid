# frozen_string_literal: true

module Pubid
  module Ccsds
    # Abstract root for every CCSDS identifier AND the flavor's parse entry
    # point — mirrors Pubid::Iso::Identifier / Pubid::Jis::Identifier. Concrete
    # identifiers (Identifiers::Base, Identifiers::Corrigendum) descend from this
    # class, so a parsed CCSDS id is an instance of Pubid::Ccsds::Identifier and
    # relaton-index can pass this class as `pubid_class` for from_hash/to_hash.
    #
    # Keeping the root abstract (it is never itself a serialized type, so it is
    # absent from CCSDS_TYPE_MAP) is what breaks the polymorphic recursion a
    # supplement's `base_identifier` would otherwise hit if it pointed at a
    # concrete type that is also its own superclass.
    class Identifier < ::Pubid::Identifier
      # CCSDS stores every code component as a plain string (the Builder passes
      # strings, never Components::Code/Edition objects), so override the
      # inherited Components::Code/Edition attribute types with :string. This
      # both matches the runtime values and yields a lean, round-trippable
      # key_value (`to_hash`) serialization instead of nested component hashes.
      # `type` (single book-color letter B/G/M/R/Y/O), `suffix`, and `language`
      # are likewise CCSDS-specific plain strings.
      attribute :number, :string
      attribute :part, :string
      attribute :edition, :string
      attribute :type, :string
      attribute :suffix, :string
      attribute :language, :string

      # Polymorphic type map for lutaml::Model key_value (de)serialization,
      # mapping each concrete class's polymorphic_name to its class name.
      CCSDS_TYPE_MAP = {
        "pubid:ccsds:base" => "Pubid::Ccsds::Identifiers::Base",
        "pubid:ccsds:corrigendum" => "Pubid::Ccsds::Identifiers::Corrigendum",
      }.freeze

      # The shared Pubid::Identifier no longer auto-maps attributes, so the
      # flavor's root declares the full key_value mapping; subclasses
      # (SupplementIdentifier/Corrigendum) merge their own blocks on top. Every
      # value is a plain string, so a direct `to:` map round-trips.
      key_value do
        map "_type", to: :_type, polymorphic_map: CCSDS_TYPE_MAP
        map "number", to: :number
        map "part", to: :part
        map "edition", to: :edition
        map "type", to: :type
        map "suffix", to: :suffix
        map "language", to: :language
      end

      def publisher
        "CCSDS"
      end

      # Parse a CCSDS identifier string into the appropriate identifier object.
      def self.parse(identifier)
        # Apply legacy update_codes normalization first
        normalized = Core::UpdateCodes.apply(identifier, :ccsds)
        parsed = Pubid::Ccsds::Parser.parse(normalized)
        Pubid::Ccsds::Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse CCSDS identifier '#{identifier}': #{e.message}"
      end

      # Dispatch deserialization to the concrete class named by the stored
      # `_type`, so `from_hash` rebuilds a Corrigendum rather than a bare root
      # (lutaml resolves `_type` only for validation, not instantiation).
      # Mirrors Pubid::Jis::Identifier.from_hash. The `klass == self` guard lets
      # the matched subclass fall through to lutaml's inherited from_hash.
      def self.from_hash(data, options = {})
        type = data["_type"] || data[:_type]
        klass_name = CCSDS_TYPE_MAP[type]
        if klass_name
          klass = Object.const_get(klass_name)
          return klass.from_hash(data, options) unless klass == self
        end
        super
      end
    end
  end
end
