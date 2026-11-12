module Pubid
  module DoiPfs
    # PFS-generated parser shell. Parsing runs through the baked
    # PARG artifact (data/parg/doi_pfs.json) via Pubid::Parg::Model.bound;
    # the grammar source lives in pubid-grammar
    # (grammars/doi_pfs.parg, compiled from definitions/doi.pfs).
    class Parser
    end
  end
end
