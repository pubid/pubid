  module Pubid
    module BsiPfs
      # The pubid-scheme URN schema, registered under the compiled
      # flavor key. The definition's declared namespace
      # ("bsi") is the scheme's canonical
      # namespace; identifiers carry the scheme's wire tag, so their
      # pubid URNs encode through the scheme's own schema.
      PubidUrnSchema = Pubid::PubidUrn.define("bsi_pfs") do
        atom "publisher.body", "pubbody"
        atom "part", "part"
        atom "year", "year"
        atom "edition", "ed"
        atom "type.abbr", "typeabbr"
        atom "type.name", "typename"
        atom "type.type_code", "typetypecode"
        atom "stage.abbr", "stageabbr"
        atom "stage.name", "stagename"
        atom "stage.stage_code", "stagecode"
        atom "stage.harmonized_stages", "stagehs", kind: :list
        atom "typed_stage.abbr", "tsabbr", kind: :list
        atom "typed_stage.name", "tsname"
        atom "typed_stage.code", "tscode"
        atom "typed_stage.stage_code", "tsstagecode"
        atom "typed_stage.type_code", "tstypecode"
        atom "typed_stage.harmonized_stages", "tshs", kind: :list
        atom "identifiers", "ids", kind: :ids
        type "pubid:bsi:adopted-european-norm", "aen", core: []
        type "pubid:bsi:adopted-international-standard", "ais", core: []
        type "pubid:bsi:amendment", "amd", core: ["number"]
        type "pubid:bsi:british-standard", "bs", core: ["number"]
        type "pubid:bsi:consolidated-identifier", "consol", core: []
        type "pubid:bsi:corrigendum", "cor", core: ["number"]
        type "pubid:bsi:draft-document", "dd", core: ["number"]
        type "pubid:bsi:published-document", "pd", core: ["number"]
        type "pubid:bsi:publicly-available-specification", "pas", core: ["number"]
        type "pubid:bsi:standalone-amendment", "sa", core: ["number"]
        type "pubid:bsi:technical-specification", "ts", core: ["number"]
      end
    end
  end
