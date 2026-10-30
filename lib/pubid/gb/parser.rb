# frozen_string_literal: true

module Pubid
  module Gb
    # Grammar for Chinese Standard identifiers.
    #
    # Accepts the canonical printed form
    #
    #   {PUBLISHER}[/{TYPE}] {NUMBER}[.{PART}][-|—{YEAR}] [(all parts)]
    #
    # PUBLISHER is one of the leading tokens from PREFIXES (GB, GB/T, JB,
    # T/GZAEPI, ...). TYPE is T (recommended), Z (guideline), or omitted.
    # YEAR is 4 digits, separated by either ASCII dash or em-dash (Chinese
    # typography uses the em-dash form).
    class Parser
    end
  end
end
