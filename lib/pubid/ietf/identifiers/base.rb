# frozen_string_literal: true

module Pubid
  module Ietf
    # Base class for every IETF identifier AND the flavor's parse/create entry
    # point (mirrors Pubid::Jis::Identifier). Concrete identifiers under
    # Pubid::Ietf::Identifiers descend from this class, so a parsed IETF id is
    # an instance of Pubid::Ietf::Identifier.
    #
    # All families are flat, supplement-free, and use plain string attributes:
    #   * Rfc            -> number ("2119")
    #   * Bcp/Std/Fyi    -> series ("BCP"/"STD"/"FYI") + number ("3")
    #   * InternetDraft  -> name ("draft-giuliano-treedn") + optional version
    class Identifier < ::Pubid::Identifier
      # Numeric part of an RFC or sub-series id, kept as a string (no zero-pad
      # in the printed form, so "2119" not "02119").
      attribute :number, :string
      # Sub-series token for BCP/STD/FYI ("BCP"/"STD"/"FYI"); nil otherwise.
      attribute :series, :string
      # Full Internet-Draft slug including the leading "draft-"; nil otherwise.
      attribute :name, :string
      # Internet-Draft version, a two-digit string preserving zero-pad ("02");
      # nil for the unversioned "latest" sibling.
      attribute :version, :string

      # Polymorphic type map for lutaml::Model key_value (de)serialization: maps
      # each subclass's polymorphic_name to its class name so a stored hash
      # rebuilds the correct identifier type via the shared from_hash dispatch.
      IETF_TYPE_MAP = {
        "pubid:ietf:rfc" => "Pubid::Ietf::Identifiers::Rfc",
        "pubid:ietf:bcp" => "Pubid::Ietf::Identifiers::Bcp",
        "pubid:ietf:std" => "Pubid::Ietf::Identifiers::Std",
        "pubid:ietf:fyi" => "Pubid::Ietf::Identifiers::Fyi",
        "pubid:ietf:internet-draft" =>
          "Pubid::Ietf::Identifiers::InternetDraft",
      }.freeze

      # Only these keys serialize; the inherited Pubid::Identifier attributes
      # are intentionally dropped. nil-valued attributes are stripped by the
      # base canonicalizer, so each family serializes just the keys it uses.
      key_value do
        map "_type", to: :_type, polymorphic_map: IETF_TYPE_MAP
        map "number", to: :number
        map "series", to: :series
        map "name", to: :name
        map "version", to: :version
      end

      # Publisher is always "IETF". A plain constant (not a `publisher` method)
      # so it doesn't shadow the inherited lutaml `publisher` attribute, which
      # would otherwise fail serialization type validation.
      PUBLISHER = "IETF"

      # Basic string representation. Delegates to the flavor renderer.
      def to_s(**opts)
        render(format: :human, **opts)
      end

      # from_hash is the shared polymorphic dispatch on Pubid::Identifier; the
      # IETF_TYPE_MAP above serves as its key_value polymorphic_map.

      # Parse an IETF identifier string into the appropriate identifier object.
      # @param identifier [String] the IETF identifier string to parse
      # @return [Identifier] the concrete identifier object
      # @raise [RuntimeError] if parsing fails
      def self.parse(identifier)
        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse IETF identifier '#{identifier}': #{e.message}"
      end
    end

  end
end
