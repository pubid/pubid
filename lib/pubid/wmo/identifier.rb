# frozen_string_literal: true

module Pubid
  module Wmo
    # Base class for all WMO identifiers. Canonical name
    # Pubid::Wmo::Identifier; every concrete WMO identifier
    # (Identifiers::*) descends from it.
    #
    # Two series share the flavor (pubid#763):
    #
    #   WMO-No. <number>[, <year> edition]   the WMO-No. publication
    #                                        series; editions are
    #                                        calendar years
    #   S-<number>[ <x.y.z>]                 the WMO-published S-100
    #                                        product specifications;
    #                                        editions are dotted x.y.z
    #   S-<number> [Annex|ANNEX] [<letter>] [<x.y.z>]   annex wrapper
    #
    # The edition is ONE string attribute carrying a type-driven face:
    # "2025" on a Publication, "1.2.1" on a Standard or Annex. The
    # renderer and the MRN URN generator key the face off the type.
    class Identifier < ::Pubid::Identifier
      # Parse a WMO identifier string — human form ("WMO-No. 1364",
      # "S-411 1.2.1") or MRN URN ("urn:mrn:wmo:pub:s-411:ed1.2.1") —
      # into an identifier.
      # @param identifier [String]
      # @return [Pubid::Wmo::Identifier]
      # @raise [Pubid::Errors::ParseError] If parsing fails
      def self.parse(identifier)
        unless identifier.is_a?(String)
          raise Pubid::Errors::InvalidInputError,
                Pubid::INPUT_NOT_A_STRING_MESSAGE
        end

        if identifier.length > Pubid::MAX_INPUT_LENGTH
          raise Pubid::Errors::InvalidInputError, Pubid::INPUT_TOO_LONG_MESSAGE
        end

        identifier = ::Pubid.utf8_input(identifier)

        if FormatDetector.detect(identifier) == :urn
          UrnParser.parse(identifier)
        else
          parsed = Pubid::Parg::Model.bound(:wmo, identifier)
          Builder.build(parsed)
        end
      end

      attribute :publisher, :string, default: "WMO"
      attribute :number,    :string # "1364", "411"
      # One edition column, type-driven face: "2025" (the WMO-No. series'
      # calendar-year edition) or "1.2.1" (the S-100 dotted edition).
      attribute :edition,   :string

      WMO_TYPE_MAP = {
        "pubid:wmo:publication" => "Pubid::Wmo::Identifiers::Publication",
        "pubid:wmo:standard" => "Pubid::Wmo::Identifiers::Standard",
        "pubid:wmo:annex" => "Pubid::Wmo::Identifiers::Annex",
      }.freeze

      key_value do
        map "_type",    to: :_type, polymorphic_map: WMO_TYPE_MAP
        map "number",   to: :number
        map "edition",  to: :edition
      end

      def to_urn
        UrnGenerator.new(self).generate
      end

      # The edition is a plain string (the string-edition flavors precede
      # this); the base mr_edition reads edition.number of a
      # Components::Edition, which would crash on the string.
      def mr_edition
        return nil unless edition

        "ed#{edition}"
      end

      # "WMO-No." and the S-number are designations, not publisher
      # tokens: the canonical faces carry no publisher prefix for
      # with_publisher to cut (the GB/GOST/ECMA rule).
      def publisher_prefixes
        []
      end
    end
  end
end
