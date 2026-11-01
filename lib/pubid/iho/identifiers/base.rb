# frozen_string_literal: true

module Pubid
  module Iho
    # Base class for all IHO identifiers. Canonical name Pubid::Iho::Identifier;
    # every concrete IHO identifier (Identifiers::*) descends from it.
    #
    # IHO identifiers have the form:
    #   IHO {S|P|M|B|C}-{number}[ Ap. {appendix}][ Part {part}][ Annex {annex}][ Suppl {supplement}][ {tail}]
    #
    # where the optional {tail} is exactly ONE of:
    #   {version}                 dotted a.b.c edition, e.g. "IHO S-44 5.0.0"
    #   {year}                    four digits, for a series with no edition
    #                             (P-5 Yearbook, P-6 Assembly proceedings,
    #                             P-7 Annual Report), e.g. "IHO P-5 2024"
    #   Vol. {volume}[ No. {issue}]
    #                             the International Hydrographic Review (P-1),
    #                             e.g. "IHO P-1 Vol. 30 No. 1"
    #
    # A nil year/volume/issue is a wildcard for `===`: "IHO P-5" matches every
    # year of the yearbook. The legacy "IHO P-1/30" number form still parses
    # with number "1/30".
    #
    # The leading IHO publisher prefix is optional on input but always
    # emitted on output.
    class Identifier < ::Pubid::Identifier
      # Parse an IHO identifier string into an identifier object
      # @param identifier [String] The IHO identifier string to parse
      # @return [Pubid::Iho::Identifier] The appropriate identifier object
      # @raise [Pubid::Errors::ParseError] If parsing fails
      def self.parse(identifier)
        unless identifier.is_a?(String)
          raise Pubid::Errors::InvalidInputError,
                Pubid::INPUT_NOT_A_STRING_MESSAGE
        end

        if identifier.length > Pubid::MAX_INPUT_LENGTH
          raise Pubid::Errors::InvalidInputError, Pubid::INPUT_TOO_LONG_MESSAGE
        end

        parsed = Pubid::Parg::Backend.parse(:iho, identifier.strip)
        Builder.build(parsed)
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
      attribute :year,       :string
      attribute :volume,     :string
      attribute :issue,      :string

      # A volume and its issue are the edition of a journal (IHO P-1), so an
      # "all parts" identity drops them as it drops the year and version.
      def self.all_parts_edition_keys
        super + %i[volume issue]
      end

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
        map "year",       to: :year
        map "volume",     to: :volume
        map "issue",      to: :issue
      end

      # from_hash is the shared polymorphic dispatch on Pubid::Identifier.
      # IHO_TYPE_MAP remains as the key_value polymorphic_map.
    end

  end
end
