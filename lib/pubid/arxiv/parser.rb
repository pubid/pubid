# frozen_string_literal: true

module Pubid
  module Arxiv
    # Grammar for arXiv identifiers. The parser of record is the baked
    # artifact `data/parg/arxiv.json` (source: pubid-grammar
    # `grammars/arxiv.parg`), run by Pubid::Parg::Model.bound.
    #
    # Accepts:
    #   [arXiv(:| )] YYMM.NNNN[vN] | YYMM.NNNNN[vN]
    #   [arXiv(:| )] archive[.SC]/YYMMNNN[vN]
    #
    # The prefix is case-insensitive. Date ranges, the month and the version
    # are checked by the Builder.
    class Parser
    end
  end
end
