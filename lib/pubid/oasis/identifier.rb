# frozen_string_literal: true

module Pubid
  module Oasis
    # Base class for every OASIS identifier AND the flavor's parse/create entry
    # point. The single concrete type `Identifiers::Standard` descends from this
    # class, so a parsed OASIS id is an instance of `Pubid::Oasis::Identifier`.
    #
    # OASIS identifiers are free-form slugs with an inconsistent internal
    # structure (spec name + version + approval stage + part + label, in
    # varying order). To guarantee a lossless round-trip we always keep the
    # exact printed slug verbatim in `original` (which alone drives `to_s`); the
    # remaining component fields are a best-effort decomposition for relaton
    # querying and can be nil without ever affecting the rendered string.
    class Identifier < ::Pubid::Identifier
      # The exact slug printed after "OASIS " — always set. Drives `to_s`, so
      # the printed form round-trips verbatim regardless of decomposition.
      attribute :original, :string
      # Best-effort decomposition (any may be nil). `spec`/`label` are plain
      # slug fragments; `version`/`stage`/`part` carry the recognized fragment
      # verbatim (e.g. "3.0", "v1.2.1", "PS01", "Errata01", "Pt8", "Part1").
      attribute :spec, :string
      attribute :version, :string
      # `stage`/`part` intentionally override the inherited Components::Stage /
      # Components::Code attributes with plain strings (same mechanism JIS uses
      # for `number`, W3C for `date`): OASIS stages/parts are opaque tokens that
      # must round-trip exactly and are never re-parsed as structured parts.
      attribute :stage, :string
      attribute :part, :string
      attribute :label, :string

      # Polymorphic type map for lutaml::Model key_value (de)serialization: maps
      # the subclass's polymorphic_name to its class name so a stored hash
      # rebuilds the correct identifier type via from_hash.
      OASIS_TYPE_MAP = {
        "pubid:oasis:standard" => "Pubid::Oasis::Identifiers::Standard",
      }.freeze

      key_value do
        map "_type", to: :_type, polymorphic_map: OASIS_TYPE_MAP
        map "original", to: :original
        map "spec", to: :spec
        map "version", to: :version
        map "stage", to: :stage
        map "part", to: :part
        map "label", to: :label
      end

      # Publisher is always "OASIS". A plain constant (not a `publisher` method)
      # so it doesn't shadow the inherited lutaml `publisher` attribute, which
      # would otherwise fail serialization type validation.
      PUBLISHER = "OASIS"

      attr_reader :with_publisher

      def to_s(with_publisher: true, **opts)
        @with_publisher = with_publisher
        render(format: :human, **opts)
      end

      # from_hash is the shared polymorphic dispatch on Pubid::Identifier;
      # OASIS_TYPE_MAP remains as the key_value polymorphic_map.

      # Parse an OASIS identifier string into an identifier object
      # @param identifier [String] The OASIS identifier string to parse
      # @return [Identifier] The Standard identifier object
      # @raise [RuntimeError] If parsing fails
      def self.parse(identifier)
        # Reject pathological inputs before they reach the parser
        # (CodeQL rb/polynomial-redos barrier — inline .length by design).
        if identifier.length > Pubid::MAX_INPUT_LENGTH
          raise ArgumentError, Pubid::INPUT_TOO_LONG_MESSAGE
        end

        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse OASIS identifier '#{identifier}': #{e.message}"
      end
    end
  end
end
