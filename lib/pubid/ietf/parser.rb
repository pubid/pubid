# frozen_string_literal: true

require "parslet"

module Pubid
  module Ietf
    # Parslet grammar for the three IETF families. The top-level alternation is
    # keyed by leading token, and each alternative captures the raw fields the
    # Builder needs:
    #   * RFC        -> { number: }
    #   * sub-series -> { series:, number: }
    #   * draft      -> { draft_rest: }  (everything after "draft-"; the version
    #                    split is done in the Builder to keep the digit-tail
    #                    heuristic in one place)
    class Parser < Parslet::Parser
      rule(:space) { str(" ") }
      rule(:digit) { match["0-9"] }
      rule(:digits) { digit.repeat(1) }

      # "RFC 2119"
      rule(:rfc) { str("RFC") >> space >> digits.as(:number) }

      # "BCP 3" / "STD 66" / "FYI 1"
      rule(:subseries) do
        (str("BCP") | str("STD") | str("FYI")).as(:series) >>
          space >> digits.as(:number)
      end

      # Internet-Draft slug characters (lowercase, digits, and the "-", "+", "_"
      # separators seen in the corpus). The whole remainder after "draft-" is
      # captured; the Builder anchors the optional trailing "-NN" version.
      rule(:draft_rest) { match['a-z0-9+_\-'].repeat(1).as(:draft_rest) }
      rule(:draft) { str("draft-") >> draft_rest }

      rule(:identifier) { rfc | subseries | draft }
      rule(:root) { identifier }

      def self.parse(input)
        new.parse(input)
      end
    end
  end
end
