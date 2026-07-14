# frozen_string_literal: true

require "parslet"

module Pubid
  module Ogc
    # Parslet grammar for OGC identifiers.
    #
    # Recognizes `<yy>-<nnn>` optionally followed by a revision suffix that
    # begins with a letter (r/c/a/R…) and may carry a trailing letter
    # (e.g. "r3a"). An optional leading "OGC" publisher token is accepted for
    # leniency, though the canonical printed form omits it.
    #
    # Examples: "25-023", "24-032r1", "01-009a", "04-095c1", "OGC 24-032r1".
    class Parser < Parslet::Parser
      rule(:space) { match["\\s"].repeat(1) }
      rule(:digits) { match["0-9"].repeat(1) }

      # Optional leading publisher token, e.g. "OGC " — consumed, not captured.
      rule(:publisher) { (str("OGC") >> space).maybe }

      # Revision suffix: a run of letters/digits that starts after the numeric
      # part (which greedily consumes all digits, so the suffix begins with a
      # separator letter). Kept as a single token for the builder to normalize.
      rule(:revision) { match["A-Za-z0-9"].repeat(1).as(:revision) }

      rule(:identifier) do
        publisher >>
          digits.as(:year) >> str("-") >> digits.as(:number) >>
          revision.maybe >> space.maybe
      end

      root(:identifier)

      def self.parse(input)
        new.parse(input)
      end
    end
  end
end
