# frozen_string_literal: true

module Pubid
  module Ogc
    # Base class for every OGC identifier AND the flavor's parse/create entry
    # point. There is a single concrete type (Identifiers::Document), so this
    # base mostly exists to hold the shared attributes and the polymorphic
    # serialization mapping.
    class Identifier < ::Pubid::Identifier
      # OGC ids are digit-leading (`<yy>-<nnn>`) with no publisher token in the
      # printed form. Everything is kept as a string to preserve zero-padding
      # ("032", not 32) and the exact revision suffix.
      attribute :year, :string   # the "<yy>" field, e.g. "24"
      attribute :number, :string # the "<nnn>" field, e.g. "032"
      # Optional revision suffix, stored as the full lowercased token including
      # its separator letter: "r1", "c1", "a", "r3a", "r12a". nil when absent.
      attribute :revision, :string

      # Polymorphic type map for lutaml::Model key_value (de)serialization: maps
      # the concrete class's polymorphic_name to its class name so a stored hash
      # rebuilds the correct identifier type via from_hash.
      OGC_TYPE_MAP = {
        "pubid:ogc:document" => "Pubid::Ogc::Identifiers::Document",
      }.freeze

      key_value do
        map "_type", to: :_type, polymorphic_map: OGC_TYPE_MAP
        map "year", to: :year
        map "number", to: :number
        map "revision", to: :revision
      end

      # Publisher is always "OGC". A plain constant (not a `publisher` method)
      # so it doesn't shadow the inherited lutaml `publisher` attribute, which
      # would otherwise fail serialization type validation.
      PUBLISHER = "OGC"

      attr_reader :with_publisher

      # Basic string representation. Delegates to the human renderer. The
      # printed OGC id carries no publisher token, so with_publisher defaults to
      # false; pass with_publisher: true to prepend "OGC ".
      def to_s(**opts)
        render(format: :human, **opts)
      end

      # Capture the with_publisher flag on EVERY render call (default false), so
      # it can never leak across calls: a bare render/to_s always renders
      # without the publisher token regardless of a prior with_publisher: true.
      # The base `render` only forwards `:with_edition` to the renderer, so the
      # flag is threaded via this per-call instance write (the renderer reads
      # `id.with_publisher`).
      def render(format: :human, with_publisher: false, **opts)
        @with_publisher = with_publisher
        super(format: format, **opts)
      end

      # from_hash is the shared polymorphic dispatch on Pubid::Identifier.
      # OGC_TYPE_MAP remains as the key_value polymorphic_map.

      # Parse an OGC identifier string into an identifier object.
      # @param identifier [String] The OGC identifier string to parse
      # @return [Identifier] The document identifier object
      # @raise [ArgumentError] If the input exceeds the maximum length
      # @raise [RuntimeError] If parsing fails
      def self.parse(identifier)
        if identifier.length > Pubid::MAX_INPUT_LENGTH
          raise ArgumentError, Pubid::INPUT_TOO_LONG_MESSAGE
        end

        Builder.build(Parser.parse(identifier))
      rescue Parslet::ParseFailed => e
        raise "Failed to parse OGC identifier '#{identifier}': #{e.message}"
      end
    end
  end
end
