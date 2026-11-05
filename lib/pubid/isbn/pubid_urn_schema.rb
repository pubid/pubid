# frozen_string_literal: true

module Pubid
  module Isbn
    # The pubid-scheme URN of ISBN (issue #670; docs/URN-SCHEMES.adoc).
    #
    #   ISBN 0-306-40615-2  ->  urn:pubid:isbn:book:hyphenated-0-306-40615-2:raw-0306406152
    #
    # There is no positional core: the hyphenated and raw spellings are both
    # optional atoms (an ISBN given bare serializes only `raw`). The official
    # urn:isbn: namespace (RFC 3187) stays on #to_urn.
    PubidUrnSchema = Pubid::PubidUrn.define("isbn") do
      atom "hyphenated", "hyphenated"
      atom "raw", "raw"

      type "pubid:isbn:book", "book", core: []
      type "pubid:isbn:identifier", "id", core: []
    end
  end
end
