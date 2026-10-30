# frozen_string_literal: true

module Pubid
  module Ietf
    # Grammar for the three IETF families. The top-level alternation is
    # keyed by leading token, and each alternative captures the raw fields the
    # Builder needs:
    #   * RFC        -> { number: }
    #   * sub-series -> { series:, number: }
    #   * draft      -> { draft_rest: }  (everything after "draft-"; the version
    #                    split is done in the Builder to keep the digit-tail
    #                    heuristic in one place)
    class Parser
    end
  end
end
