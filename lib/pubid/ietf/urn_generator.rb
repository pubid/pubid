# frozen_string_literal: true

module Pubid
  module Ietf
    # Emits the canonical IETF URNs:
    #   RFC            -> urn:ietf:rfc:2119
    #   BCP/STD/FYI    -> urn:ietf:bcp:3 / urn:ietf:std:66 / urn:ietf:fyi:1
    #   Internet-Draft -> urn:ietf:id:draft-giuliano-treedn[:02]
    class UrnGenerator < Pubid::UrnGenerator::Base
      def generate
        case identifier
        when Identifiers::Rfc
          "urn:ietf:rfc:#{identifier.number}"
        when Identifiers::InternetDraft
          base = "urn:ietf:id:#{identifier.name}"
          identifier.version ? "#{base}:#{identifier.version}" : base
        else # Bcp/Std/Fyi sub-series
          "urn:ietf:#{identifier.series.downcase}:#{identifier.number}"
        end
      end
    end
  end
end
