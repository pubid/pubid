# frozen_string_literal: true

module Pubid
  module Wmo
    # Generates URN strings for WMO identifiers under the WMO assigning
    # authority of the IANA-registered `mrn` namespace, following the
    # IALA pattern (pubid#763 proposed form; no authoritative WMO
    # urn:mrn:wmo: rule is published — the S-411 repository carries none
    # — so this shape is the fleet's extension until one exists):
    #
    #   urn:mrn:wmo:pub:wmo-<number>[:ed<year>]     the WMO-No. series
    #   urn:mrn:wmo:pub:s-<number>[:ed<x.y.z>]      the S-100 specs
    #   urn:mrn:wmo:pub:s-<number>:annex[-<letter>][:ed<x.y.z>]
    #
    # Examples:
    #   urn:mrn:wmo:pub:wmo-1364:ed2025
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
        parts << "ed#{identifier.edition}" if identifier.edition
        parts.join(":")
      end

      private

      # The WMO-No. series codes as "wmo-<number>" (the proposed MRN
      # form "urn:mrn:wmo:pub:wmo-1364:ed2025"); the S-100 specs keep
      # their lexical form lowercased ("s-411").
      def code_segment
        if identifier.is_a?(Identifiers::Publication)
          "wmo-#{identifier.number}"
        else
          "s-#{identifier.number}"
        end
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
