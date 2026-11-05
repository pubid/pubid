# frozen_string_literal: true

module Pubid
  module Idf
    # The pubid-scheme URN of IDF (issue #670; docs/URN-SCHEMES.adoc).
    #
    #   IDF 146:2003/AMD 1:2023  ->
    #   urn:pubid:idf:is:146:pubbody-IDF:year-2003:amd:1:year-2023
    #
    # The current urn:idf:… form of #to_urn is pubid-invented and stays
    # there. `type`, `stage` and `typed_stage` serialize every registry
    # field of their components, so each field is its own atom (the NIST
    # ruling): reducing them to one identifying value would change to_hash
    # and need a relaton-data re-crawl — a separate decision.
    PubidUrnSchema = Pubid::PubidUrn.define("idf") do
      atom "publisher.body", "pubbody"
      atom "type.abbr", "typeabbr"
      atom "type.name", "typename"
      atom "type.type_code", "typetypecode"
      atom "part", "part"
      atom "year", "year"
      atom "stage.abbr", "stageabbr"
      atom "stage.name", "stagename"
      atom "stage.stage_code", "stagestagecode"
      atom "stage.harmonized_stages", "stageharmonizedstages", kind: :list
      atom "typed_stage.abbr", "typedstageabbr", kind: :list
      atom "typed_stage.name", "typedstagename"
      atom "typed_stage.code", "typedstage"
      atom "typed_stage.long_abbr", "typedstagelongabbr"
      atom "typed_stage.short_abbr", "typedstageshortabbr"
      atom "typed_stage.stage_code", "typedstagestagecode"
      atom "typed_stage.type_code", "typedstagetypecode"
      atom "typed_stage.harmonized_stages", "typedstageharmonizedstages",
           kind: :list

      type "pubid:idf:all-parts", "all"
      type "pubid:idf:amendment", "amd"
      type "pubid:idf:corrigendum", "cor"
      type "pubid:idf:identifier", "id"
      type "pubid:idf:international-standard", "is"
      type "pubid:idf:reviewed-method", "rm"
    end
  end
end
