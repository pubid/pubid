# frozen_string_literal: true

module Pubid
  module Wmo
    # Parses WMO MRN URNs back into identifiers.
    #
    # UrnGenerator emits:
    #   urn:mrn:wmo:pub:wmo-<number>[:ed<year>]
    #   urn:mrn:wmo:pub:s-<number>[:ed<x.y.z>]
    #   urn:mrn:wmo:pub:s-<number>:annex[-<letter>][:ed<x.y.z>]
    #
    # Examples:
    #   urn:mrn:wmo:pub:wmo-1364:ed2025     → WMO-No. 1364, 2025 edition
    #   urn:mrn:wmo:pub:s-411:ed1.2.1       → S-411 1.2.1
    #   urn:mrn:wmo:pub:s-411:annex-a       → S-411 Annex A
    class UrnParser < Pubid::UrnParser::Base
      PREFIX = "urn:mrn:wmo:pub:"

      def parse_urn(urn)
        body = strip_mrn_namespace(urn)
        parts = split_parts(body)
        code = parts.fetch(0)
        segments = parts.drop(1)

        if (publication = code.match(/\Awmo-(\d+)\z/i))
          parse_publication(publication[1], segments)
        elsif (standard = code.match(/\As-(\d+)\z/i))
          parse_standard(standard[1], segments)
        else
          raise ::Pubid::Errors::UrnParseError,
                "Invalid WMO URN code segment: #{code.inspect}"
        end
      end

      private

      def strip_mrn_namespace(urn)
        unless urn.downcase.start_with?(PREFIX)
          raise ::Pubid::Errors::UrnParseError,
                "Invalid WMO URN: #{urn.inspect}"
        end

        urn[PREFIX.length..]
      end

      # Publication segments: the single ed<year> edition. Rebuilt as the
      # compact year form, which the text parser normalizes to the
      # canonical comma face.
      def parse_publication(number, segments)
        edition = nil

        segments.each do |seg|
          raise_segment!(seg, "duplicate edition") if edition
          edition = edition_value(seg, /\A\d{4}\z/)
        end

        text = "WMO-No. #{number}"
        text += ":ed#{edition}" if edition
        flavor_parse(text)
      end

      # Standard and annex segments: an optional annex segment (at most
      # one), then the optional dotted edition. Rebuilt as the human
      # forms.
      #
      # The annex segment is caseless in the MRN ("annex" / "annex-a"),
      # so the rebuild picks the attested WMO face "Annex" (the DCEG
      # docidentifier). The uppercase "ANNEX" form stays a parse-only
      # human alias; its URN re-renders to the attested face.
      def parse_standard(number, segments)
        annex_letter = nil
        edition = nil
        has_annex = false

        segments.each do |seg|
          case seg
          when /\Aannex(-([a-z]))?\z/i
            raise_segment!(seg, "duplicate annex") if has_annex

            has_annex = true
            annex_letter = Regexp.last_match(2)&.upcase
          else
            raise_segment!(seg) if edition

            edition = edition_value(seg, /\A\d+(\.\d+)+\z/)
          end
        end

        text = "S-#{number}"
        text += " Annex" if has_annex
        text += " #{annex_letter}" if annex_letter
        text += " #{edition}" if edition
        flavor_parse(text)
      end

      # The value of an "ed<value>" segment, validated against +shape+
      # (a year for a publication, dotted for a standard or annex). Any
      # other segment is a parse error, per the ISO urn_parser strictness.
      def edition_value(seg, shape)
        unless seg.match?(/\Aed/i)
          raise_segment!(seg)
        end

        edition = seg.sub(/\Aed/i, "")
        return edition if edition.match?(shape)

        raise_segment!(seg)
      end

      def raise_segment!(seg, reason = nil)
        detail = reason ? " (#{reason})" : ""
        raise ::Pubid::Errors::UrnParseError,
              "Invalid WMO URN segment#{detail}: #{seg.inspect}"
      end
    end
  end
end
