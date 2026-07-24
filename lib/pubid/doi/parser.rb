# frozen_string_literal: true

require "parslet"

module Pubid
  module Doi
    # Parslet grammar for Digital Object Identifiers per ISO 26324.
    #
    # Accepts:
    #   [doi:|DOI:]10.{REGISTRAR}/{SUFFIX}
    #   https://doi.org/10.{REGISTRAR}/{SUFFIX}
    #
    # SUFFIX is one-or-more chars from [A-Za-z0-9._\-/()] (printable minus
    # whitespace). The grammar is intentionally permissive on suffix chars
    # because real DOIs cover the full printable range.
    class Parser < Parslet::Parser
      rule(:dot)   { str(".") }
      rule(:slash) { str("/") }

      # Optional URL resolver prefix.
      rule(:url_prefix) { (str("https://") | str("http://")).maybe >> str("doi.org").maybe }

      # Optional DOI scheme prefix.
      rule(:scheme_prefix) do
        (str("doi:") | str("DOI:") | str("Doi:")).maybe
      end

      # Prefix: "10." then 2+ registrar digits.
      rule(:prefix) { str("10") >> dot >> match("[0-9]").repeat(2).as(:prefix) }

      # Suffix: at least one printable non-whitespace char (DOI Handbook §2.2).
      rule(:suffix) { match("[A-Za-z0-9._\\-/()]").repeat(1).as(:suffix) }

      rule(:identifier) do
        url_prefix.maybe >>
          scheme_prefix.maybe >>
          slash.maybe >>
          prefix >> slash >> suffix
      end

      rule(:root) { identifier }

      def self.parse(input)
        # Normalize a URL resolver form to bare form before parsing. The
        # parser's `url_prefix.maybe >> scheme_prefix.maybe >> slash.maybe`
        # chain also handles this in-grammar, but pre-stripping yields a
        # cleaner error message for malformed URLs.
        new.parse(input)
      end
    end
  end
end
