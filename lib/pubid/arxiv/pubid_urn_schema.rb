# frozen_string_literal: true

module Pubid
  module Arxiv
    # The pubid-scheme URN of arXiv (docs/URN-SCHEMES.adoc, [[urn-arxiv]]).
    #
    #   arXiv:2301.00001v1
    #     -> urn:pubid:arxiv:eprint:2023:1:00001:v-1
    #   arXiv:math.GT/0309136
    #     -> urn:pubid:arxiv:eprint:2003:9:136:archive-math:sc-GT
    #
    # Every e-print has a year, a month and a number, so they are the
    # positional core. The archive and subject class (old ids only) and the
    # version can be absent, so they are atoms. arXiv registers no official
    # URN namespace.
    PubidUrnSchema = Pubid::PubidUrn.define("arxiv") do
      atom "archive", "archive"
      atom "subject_class", "sc"
      atom "version", "v", kind: :int

      core = [["year", :int], ["month", :int], "number"]
      type "pubid:arxiv:eprint", "eprint", core: core
      type "pubid:arxiv:identifier", "id", core: core
    end
  end
end
