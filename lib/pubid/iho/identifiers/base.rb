# frozen_string_literal: true

module Pubid
  module Iho
    module Identifiers
      # Base class for all IHO identifiers.
      #
      # IHO identifiers have the form:
      #   IHO {S|P|M|B|C}-{number}[ Ap. {appendix}][ Part {part}][ Annex {annex}][ Suppl {supplement}][ {version}]
      #
      # The leading IHO publisher prefix is optional on input but always
      # emitted on output.
      class Base < Pubid::Identifier
        # Identity for the Pubid::Iho::Identifier facade (see its comment).
        include Pubid::Iho::Identifier

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
          "pubid:iho:standard"        => "Pubid::Iho::Identifiers::Standard",
          "pubid:iho:publication"     => "Pubid::Iho::Identifiers::Publication",
          "pubid:iho:miscellaneous"   => "Pubid::Iho::Identifiers::Miscellaneous",
          "pubid:iho:bibliographic"   => "Pubid::Iho::Identifiers::Bibliographic",
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

        # Re-instantiate the concrete subclass from `_type`. lutaml's
        # polymorphic_map only validates `_type` on key_value deserialization;
        # without this routing `from_hash` returns a bare Base (no #type, which
        # breaks #to_s). Mirrors Pubid::Iso::Identifier.from_hash.
        def self.from_hash(data, options = {})
          klass_name = IHO_TYPE_MAP[data["_type"] || data[:_type]]
          if klass_name
            klass = Object.const_get(klass_name)
            return klass.from_hash(data, options) unless klass == self
          end
          super
        end

        def self.parse(string)
          Iho::Identifier.parse(string)
        end

        # Render the identifier as a string in canonical IHO form.
        # @return [String]
        def to_s
          render(format: :human)
        end
      end
    end
  end
end
