# frozen_string_literal: true

module Pubid
  module Ogc
    # Grammar for OGC identifiers.
    #
    # Recognizes `<yy>-<nnn>` optionally followed by a revision suffix that
    # begins with a letter (r/c/a/R…) and may carry a trailing letter
    # (e.g. "r3a"). An optional leading "OGC" publisher token is accepted for
    # leniency, though the canonical printed form omits it.
    #
    # Examples: "25-023", "24-032r1", "01-009a", "04-095c1", "OGC 24-032r1".
    class Parser
    end
  end
end
