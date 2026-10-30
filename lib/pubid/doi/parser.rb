# frozen_string_literal: true

module Pubid
  module Doi
    # Grammar for Digital Object Identifiers per ISO 26324.
    #
    # Accepts:
    #   [doi:|DOI:]10.{REGISTRAR}/{SUFFIX}
    #   https://doi.org/10.{REGISTRAR}/{SUFFIX}
    #
    # SUFFIX is one-or-more chars from [A-Za-z0-9._\-/()] (printable minus
    # whitespace). The grammar is intentionally permissive on suffix chars
    # because real DOIs cover the full printable range.
    class Parser
    end
  end
end
