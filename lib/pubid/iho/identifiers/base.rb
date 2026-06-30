# frozen_string_literal: true

module Pubid
  module Iho
    # Base class for all IHO identifiers. Canonical name Pubid::Iho::Identifier;
    # every concrete IHO identifier (Identifiers::*) descends from it, and
    # Identifiers::Base — aliased at the foot of this file — points back to it.
    #
    # IHO identifiers have the form:
    #   IHO {S|P|M|B|C}-{number}[ Ap. {appendix}][ Part {part}][ Annex {annex}][ Suppl {supplement}][ {version}]
    #
    # The leading IHO publisher prefix is optional on input but always
    # emitted on output.
    class Identifier < ::Pubid::Identifier
      # Parse an IHO identifier string into an identifier object
      # @param identifier [String] The IHO identifier string to parse
      # @return [Pubid::Iho::Identifier] The appropriate identifier object
      # @raise [Parslet::ParseFailed] If parsing fails
      def self.parse(identifier)
        parsed = Parser.parse(identifier)
        Builder.build(parsed)
      rescue Parslet::ParseFailed => e
        raise "Failed to parse IHO identifier '#{identifier}': #{e.message}"
      end

      # `number` overrides the generic Components::Code attribute with a plain
      # string (same pattern as `part` below); it holds the IHO document
      # number (e.g. "100", "1/21"). Kept as the generic `number` so the
      # relaton index sorts/binary-searches on it natively via `id.number`.
      attribute :number,     :string
      attribute :publisher,  :string, default: "IHO"
      attribute :appendix,   :string
      attribute :part,       :string
      attribute :annex,      :string
      attribute :supplement, :string
      attribute :version,    :string

      # Polymorphic type map for lutaml::Model key_value serialization: maps
      # each subclass's polymorphic_name to its class name so `from_hash` can
      # re-instantiate the concrete type from `_type`.
      IHO_TYPE_MAP = {
        "pubid:iho:standard" => "Pubid::Iho::Identifiers::Standard",
        "pubid:iho:publication" => "Pubid::Iho::Identifiers::Publication",
        "pubid:iho:miscellaneous" => "Pubid::Iho::Identifiers::Miscellaneous",
        "pubid:iho:bibliographic" => "Pubid::Iho::Identifiers::Bibliographic",
        "pubid:iho:circular-letter" => "Pubid::Iho::Identifiers::CircularLetter",
      }.freeze

      # The base Pubid::Identifier no longer auto-maps attributes, so each
      # flavor's top class must declare its own key_value mapping. IHO
      # attributes are plain strings, so they map directly. `publisher` is
      # intentionally omitted: it is always the "IHO" default and is restored
      # on load.
      key_value do
        map "_type",      to: :_type, polymorphic_map: IHO_TYPE_MAP
        map "number",     to: :number
        map "appendix",   to: :appendix
        map "part",       to: :part
        map "annex",      to: :annex
        map "supplement", to: :supplement
        map "version",    to: :version
      end

      # from_hash is the shared polymorphic dispatch on Pubid::Identifier.
      # IHO_TYPE_MAP remains as the key_value polymorphic_map.

      # Render the identifier as a string in canonical IHO form.
      # @return [String]
      def to_s
        render(format: :human)
      end
    end

    module Identifiers
      # Backward-compatible alias: IHO's base class used to be
      # Pubid::Iho::Identifiers::Base. It is now Pubid::Iho::Identifier.
      Base = Pubid::Iho::Identifier
    end
  end
end
