# frozen_string_literal: true

module Pubid
  module Wmo
    # Base class for all WMO identifiers. Canonical name
    # Pubid::Wmo::Identifier; every concrete WMO identifier
    # (Identifiers::*) descends from it.
    #
    # The publication series share one type (pubid#763 widened):
    #
    #   WMO-No. <number>[, <year> edition]   the WMO-No. publication
    #                                        series; editions are
    #                                        calendar years
    #   WMO/TD-No. <number>                  the Technical Document
    #                                        series
    #   JCOMM Technical Report No. <number>  the joint WMO/IOC series
    #   GAW Report No. <number>              the GAW series
    #   S-<number>[ <x.y.z>]                 the WMO-published S-100
    #                                        product specifications;
    #                                        editions are dotted x.y.z
    #   S-<number> [Annex|ANNEX] [<letter>] [<x.y.z>]   annex wrapper
    #
    # The edition is ONE string attribute carrying a type-driven face:
    # "2025" on a Publication, "1.2.1" on a Standard or Annex. The
    # compound faces widen it: a year pair ("2021/2018" — the pair IS
    # the identity face) rides the same string, while the status word
    # ("Provisional") and the updated-in year carry their own
    # attributes. The volume face ("I", "I.1", "D") is its own
    # attribute, printed before the edition face.
    class Identifier < ::Pubid::Identifier
      # The publication series beyond the WMO-No. default (the widening
      # prefix law: every head token names its publisher, so the model
      # carries the short key and derives the citation face and the MRN
      # slug from this table). The default row stays out of the table:
      # series is nil for WMO-No., so existing rows serialize without
      # the key.
      SERIES = {
        "TD" => { face: "WMO/TD-No.", mrn: "wmo-td" },
        "JCOMM" => { face: "JCOMM Technical Report No.", mrn: "jcomm-tr" },
        "GAW" => { face: "GAW Report No.", mrn: "gaw" },
      }.freeze
      # The WMO-No. series itself: the face the grammar matches and the
      # MRN slug prefix of the default series (series nil).
      DEFAULT_SERIES = { face: "WMO-No.", mrn: "wmo" }.freeze

      # The series config (face + MRN slug prefix) of a series key,
      # defaulting to the WMO-No. row.
      def self.series_config(key)
        SERIES.fetch(key, DEFAULT_SERIES)
      end

      # The series config of this identifier's own series. A real
      # instance method: lutaml's Serialize#method_missing would swallow
      # anything the class only exposes statically.
      def series_config
        self.class.series_config(series)
      end

      # Parse a WMO identifier string — human form ("WMO-No. 1364",
      # "WMO/TD-No. 196", "S-411 1.2.1") or MRN URN
      # ("urn:mrn:wmo:pub:s-411:ed1.2.1") — into an identifier.
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
      # The publication series key: nil (the WMO-No. default), "TD",
      # "JCOMM" or "GAW". The citation face and the MRN slug prefix
      # derive from SERIES.
      attribute :series, :string
      # One edition column, type-driven face: "2025" or the year pair
      # "2021/2018" (the WMO-No. series' calendar-year edition) or
      # "1.2.1" (the S-100 dotted edition).
      attribute :edition, :string
      # The publication volume face ("I", "I.1", "D"); publication-only.
      attribute :volume, :string
      # The edition status word ("Provisional"); publication-only.
      attribute :edition_status, :string
      # The year the edition was updated in ("2025"); publication-only.
      attribute :updated_in,     :string

      WMO_TYPE_MAP = {
        "pubid:wmo:publication" => "Pubid::Wmo::Identifiers::Publication",
        "pubid:wmo:standard" => "Pubid::Wmo::Identifiers::Standard",
        "pubid:wmo:annex" => "Pubid::Wmo::Identifiers::Annex",
      }.freeze

      key_value do
        map "_type",    to: :_type, polymorphic_map: WMO_TYPE_MAP
        map "number",   to: :number
        map "series",   to: :series
        map "edition",  to: :edition
        map "volume",   to: :volume
        map "edition_status", to: :edition_status
        map "updated_in",     to: :updated_in
      end

      def to_urn
        UrnGenerator.new(self).generate
      end

      # The edition is a plain string (the string-edition flavors precede
      # this); the base mr_edition reads edition.number of a
      # Components::Edition, which would crash on the string. The
      # compound faces ride the same segment so distinct identifiers
      # never collide on the slug (issue #142): the year pair keeps its
      # slash out of the MR charset as a hyphen ("2021/2018" rides as
      # "ed2021-2018", the same hyphenation the MRN edition segment
      # uses), the status word and the updated-in year suffix it.
      def mr_edition
        return nil unless edition

        segment = "ed#{edition.tr('/', '-')}"
        segment << "-#{edition_status.downcase}" if edition_status
        segment << "-updated#{updated_in}" if updated_in
        segment
      end

      # The series is the type discriminator of the publication series:
      # "WMO/TD-No. 196" and "WMO-No. 196" are two documents, so the
      # slug carries the series or they collide. Downcased per the MR
      # charset; nil (no segment) on the WMO-No. default.
      def mr_type
        return nil unless series

        series.downcase
      end

      # The volume is an identity discriminator (the ECMA law): Volume I
      # and Volume II of WMO-No. 8 are two documents sharing one
      # docidentifier, so the MR slug carries the segment or the two
      # collide. Downcased per the MR charset.
      def mr_volume
        return nil unless volume

        "vol-#{volume.downcase}"
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
