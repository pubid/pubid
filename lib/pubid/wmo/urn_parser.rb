# frozen_string_literal: true

module Pubid
  module Wmo
    # Parses WMO MRN URNs back into identifiers.
    #
    # UrnGenerator emits:
    #   urn:mrn:wmo:pub:wmo-<number>
    #       [:vol-<v>][:status-<s>][:ed<year>][:updated-<y>]
    #   urn:mrn:wmo:pub:wmo-td-<number> / jcomm-tr-<number> / gaw-<number>
    #   urn:mrn:wmo:pub:s-<number>[:ed<x.y.z>]
    #   urn:mrn:wmo:pub:s-<number>:annex[-<letter>][:ed<x.y.z>]
    #
    # Examples:
    #   urn:mrn:wmo:pub:wmo-1364:ed2025     → WMO-No. 1364, 2025 edition
    #   urn:mrn:wmo:pub:wmo-306:vol-i.1     → WMO-No. 306, Volume I.1
    #   urn:mrn:wmo:pub:wmo-8:ed2021-2018   → WMO-No. 8, 2021/2018 edition
    #   urn:mrn:wmo:pub:wmo-td-196          → WMO/TD-No. 196
    #   urn:mrn:wmo:pub:jcomm-tr-14         → JCOMM Technical Report No. 14
    #   urn:mrn:wmo:pub:gaw-312             → GAW Report No. 312
    #   urn:mrn:wmo:pub:s-411:ed1.2.1       → S-411 1.2.1
    #   urn:mrn:wmo:pub:s-411:annex-a       → S-411 Annex A
    class UrnParser < Pubid::UrnParser::Base
      PREFIX = "urn:mrn:wmo:pub:"

      def parse_urn(urn)
        body = strip_mrn_namespace(urn)
        parts = split_parts(body)
        code = parts.fetch(0)
        segments = parts.drop(1)

        # Longest slug first: "wmo-td-" also starts with "wmo-".
        if (match = code.match(/\Awmo-td-(\d+)\z/i))
          parse_publication("TD", match[1], segments)
        elsif (match = code.match(/\Awmo-(\d+)\z/i))
          parse_publication(nil, match[1], segments)
        elsif (match = code.match(/\Ajcomm-tr-(\d+)\z/i))
          parse_publication("JCOMM", match[1], segments)
        elsif (match = code.match(/\Agaw-(\d+)\z/i))
          parse_publication("GAW", match[1], segments)
        elsif (match = code.match(/\As-(\d+)\z/i))
          parse_standard(match[1], segments)
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

      # Publication segments: the optional volume, status and
      # updated-in segments plus the single ed<year> edition. All but
      # the edition are caseless (downcased by the generator), so the
      # rebuild re-cases them into the attested faces. The canonical
      # comma faces are rebuilt and the text parser normalizes from
      # there (one construction path).
      def parse_publication(series, number, segments)
        volume = nil
        status = nil
        edition = nil
        updated_in = nil

        segments.each do |seg|
          case seg
          when /\Avol-([a-z]+(?:\.\d+)*)\z/i
            raise_segment!(seg, "duplicate volume") if volume
            volume = Regexp.last_match(1).upcase
          when /\Astatus-([a-z]+)\z/i
            raise_segment!(seg, "duplicate status") if status
            status = Regexp.last_match(1).capitalize
          when /\Aed(\d{4}(?:-\d{4})?)\z/i
            raise_segment!(seg, "duplicate edition") if edition
            edition = Regexp.last_match(1).tr("-", "/")
          when /\Aupdated-(\d{4})\z/i
            raise_segment!(seg, "duplicate updated") if updated_in
            updated_in = Regexp.last_match(1)
          else
            raise_segment!(seg)
          end
        end

        text = "#{Identifier.series_config(series)[:face]} #{number}"
        text << " Volume #{volume}" if volume
        if edition
          text << if status
                    ", #{status} #{edition} edition"
                  else
                    ", #{edition} edition"
                  end
        end
        text << ", updated in #{updated_in}" if updated_in
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
