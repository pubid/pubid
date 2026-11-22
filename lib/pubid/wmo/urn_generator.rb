# frozen_string_literal: true

module Pubid
  module Wmo
    # Generates URN strings for WMO identifiers under the WMO assigning
    # authority of the IANA-registered `mrn` namespace, following the
    # IALA pattern (pubid#763 proposed form; no authoritative WMO
    # urn:mrn:wmo: rule is published — the S-411 repository carries none
    # — so this shape is the fleet's extension until one exists):
    #
    #   urn:mrn:wmo:pub:wmo-<number>[:vol-<v>][:status-<s>][:ed<year>]
    #       [:updated-<year>]           the WMO-No. series
    #   urn:mrn:wmo:pub:wmo-td-<number>   the Technical Document series
    #   urn:mrn:wmo:pub:jcomm-tr-<number> the joint WMO/IOC series
    #   urn:mrn:wmo:pub:gaw-<number>      the GAW series
    #   urn:mrn:wmo:pub:s-<number>[:ed<x.y.z>]      the S-100 specs
    #   urn:mrn:wmo:pub:s-<number>:annex[-<letter>][:ed<x.y.z>]
    #
    # The segment order mirrors the human face order (volume, status,
    # edition, updated-in). Volume and status segment values are
    # caseless (downcased like the annex letter, re-cased by the
    # parser). The year pair keeps its slash out of the NSS — RFC 2141
    # has no slash in the trans set — as a hyphen ("2021/2018" rides as
    # "ed2021-2018", the same hyphenation the MR slug uses).
    #
    # Examples:
    #   urn:mrn:wmo:pub:wmo-1364:ed2025
    #   urn:mrn:wmo:pub:wmo-306:vol-i.1
    #   urn:mrn:wmo:pub:wmo-8:ed2021-2018
    #   urn:mrn:wmo:pub:wmo-8:status-provisional:ed2026
    #   urn:mrn:wmo:pub:wmo-1364:ed2023:updated-2025
    #   urn:mrn:wmo:pub:wmo-td-196
    #   urn:mrn:wmo:pub:jcomm-tr-14
    #   urn:mrn:wmo:pub:gaw-312
    #   urn:mrn:wmo:pub:s-411:ed1.2.1
    #   urn:mrn:wmo:pub:s-411:annex-a
    class UrnGenerator
      attr_reader :identifier

      def initialize(identifier)
        @identifier = identifier
      end

      def generate
        return generate_annex if identifier.is_a?(Identifiers::Annex)

        parts = ["urn:mrn:wmo:pub", code_segment]
        parts << "vol-#{identifier.volume.downcase}" if identifier.volume
        if identifier.edition_status
          parts << "status-#{identifier.edition_status.downcase}"
        end
        parts << mrn_edition if identifier.edition
        parts << "updated-#{identifier.updated_in}" if identifier.updated_in
        parts.join(":")
      end

      private

      # The publication series code via its SERIES slug ("wmo-1364",
      # "wmo-td-196", "jcomm-tr-14", "gaw-312"); the S-100 specs keep
      # their lexical form lowercased ("s-411").
      def code_segment
        if identifier.is_a?(Identifiers::Publication)
          "#{identifier.series_config[:mrn]}-#{identifier.number}"
        else
          "s-#{identifier.number}"
        end
      end

      # The edition segment: the edition value glued after "ed", with
      # the year pair's slash hyphenated.
      def mrn_edition
        "ed#{identifier.edition.tr('/', '-')}"
      end

      # URN for an annex: the base specification's code, then an "annex"
      # segment (lettered form for the "ANNEX A" style, bare for "Annex"
      # without a letter), then the annex's own edition.
      def generate_annex
        base = identifier.base
        parts = ["urn:mrn:wmo:pub", "s-#{base.number}"]
        parts << annex_segment
        parts << "ed#{identifier.edition}" if identifier.edition
        parts.join(":")
      end

      def annex_segment
        if identifier.letter
          "annex-#{identifier.letter.downcase}"
        else
          "annex"
        end
      end
    end
  end
end
