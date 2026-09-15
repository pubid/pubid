# frozen_string_literal: true

module Pubid
  module Evs
    # Parses `urn:evs:…` URNs back into identifiers, following the same
    # pattern as Pubid::CenCenelec::UrnParser: reassemble the adopted
    # identifier's human text and delegate to the real grammar so every
    # structural check happens in parsers, not in this class.
    #
    #   urn:evs:en:18216:2026                → EVS-EN 18216:2026
    #   urn:evs:en:iso:14001:2026            → EVS-EN ISO 14001:2026
    #   urn:evs:en:iso-iec:27017:2026        → EVS-EN ISO/IEC 27017:2026
    #   urn:evs:en:iso:9001:2015:amd:1:2024  → EVS-EN ISO 9001:2015/A1:2024
    class UrnParser < Pubid::UrnParser::Base
      ORGS = {
        "iso" => "ISO",
        "iso-iec" => "ISO/IEC",
        "iec" => "IEC",
        "cispr" => "CISPR",
      }.freeze

      # UrnGenerator emits "urn:evs:" (national-body namespace).
      def flavor_name
        "evs"
      end

      def parse_urn(urn)
        parts = split_parts(strip_namespace(urn))

        type = parts.shift
        unless /\Aen\z/i.match?(type)
          raise Errors::ParseError, "unsupported type in #{urn.inspect}"
        end

        text = +"EN"
        org_parts = []
        org_parts << parts.shift while parts.first&.match?(/\A[a-z][a-z-]*\z/)
        if org_parts.any?
          org = ORGS.fetch(org_parts.join("-")) do
            raise Errors::ParseError, "unknown adopted org in #{urn.inspect}"
          end
          text << " #{org}"
        end

        number = parts.shift
        year = parts.shift
        unless number
          raise Errors::ParseError, 
                "missing number in #{urn.inspect}"
        end

        text << " #{number}"
        text << ":#{year}" if year

        append_supplement(text, parts, urn) unless parts.empty?

        adopted = Pubid::CenCenelec.parse(text)
        ::Pubid::Evs::Identifiers::NationalAdoption.new(
          adopted_identifier: adopted,
        )
      end

      private

      # Appends the trailing `amd|cor : iteration [: year]` in human form.
      def append_supplement(text, parts, urn)
        year = parts.last&.match?(/\A\d{4}\z/) ? parts.pop : nil
        kind = parts.shift
        iteration = parts.shift
        unless %w[amd cor].include?(kind) && iteration && parts.empty?
          raise Errors::ParseError, "malformed supplement in #{urn.inspect}"
        end

        text << (kind == "amd" ? "/A#{iteration}" : "/AC#{iteration}")
        text << ":#{year}" if year
        text
      end
    end
  end
end
