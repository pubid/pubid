# frozen_string_literal: true

module Pubid
  module Oasis
    # Emits `urn:oasis:<slug>`, echoing the verbatim `original` as a single URN
    # segment (OASIS slugs never contain ":"). The only characters that occur in
    # real records outside the URN-safe set are the space and a stray "]" (both
    # only in a handful of malformed records); these are percent-encoded so the
    # URN stays well-formed, and UrnParser reverses them exactly.
    #
    #   "OASIS amqp-core"          -> "urn:oasis:amqp-core"
    #   "OASIS OSLC-CM-v1.0-CS01"  -> "urn:oasis:OSLC-CM-v1.0-CS01"
    class UrnGenerator < Pubid::UrnGenerator::Base
      # Character -> percent-encoding for the non-URN-safe characters that
      # actually appear in OASIS slugs. Kept explicit (not a blanket URI escape)
      # so clean slugs — dots, hyphens, mixed case — pass through unchanged.
      ENCODE = { " " => "%20", "]" => "%5D" }.freeze

      def generate
        slug = identifier.original.to_s.gsub(/[ \]]/) { |c| ENCODE[c] }
        "urn:oasis:#{slug}"
      end
    end
  end
end
