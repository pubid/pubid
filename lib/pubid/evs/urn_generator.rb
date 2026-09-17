# frozen_string_literal: true

module Pubid
  module Evs
    # URNs mirror the CEN adoption namespace with the national-body prefix:
    #
    #   "EVS-EN 18216:2026"            → urn:evs:en:18216:2026
    #   "EVS-EN ISO 14001:2026"        → urn:evs:en:iso:14001:2026
    #   "EVS-EN ISO/IEC 27017:2026"    → urn:evs:en:iso-iec:27017:2026
    #   "EVS-EN ISO 9001:2015/A1:2024" → urn:evs:en:iso:9001:2015:amd:1:2024
    #
    # Generation delegates to the adopted CEN identifier's URN and swaps the
    # `urn:cen:` namespace for `urn:evs:`, so the two stay consistent by
    # construction.
    class UrnGenerator < Pubid::UrnGenerator::Base
      CEN_NAMESPACE = "urn:cen:"
      EVS_NAMESPACE = "urn:evs:"

      def generate
        adopted_urn = identifier.base.to_urn
        unless adopted_urn.start_with?(CEN_NAMESPACE)
          raise Errors::ParseError,
                "expected adopted CEN URN, got #{adopted_urn.inspect}"
        end

        adopted_urn.sub(/\A#{Regexp.escape(CEN_NAMESPACE)}/o, EVS_NAMESPACE)
      end
    end
  end
end
