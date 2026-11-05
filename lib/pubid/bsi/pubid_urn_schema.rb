# frozen_string_literal: true

module Pubid
  module Bsi
    # The pubid-scheme URN of BSI (issue #670; docs/URN-SCHEMES.adoc).
    #
    #   BS EN 1073-2:2002  ->
    #   urn:pubid:bsi:aen:cencenelec:en:1073:part-2:year-2002
    #
    # An adopted norm carries the European document along +base+, so the
    # wrapper and the document share the slug prefix and the document keeps
    # its own flavor's schema (`cencenelec`, `iec`, `iso`). The rest of the
    # family follows the wrapper precedents: a consolidated identifier and
    # a bundle are `ids` bracketed lists; a national annex carries its
    # supplements as `nasup`; `type`, `stage` and `typed_stage` serialize
    # every registry field of their components, so each field is its own
    # atom (the NIST ruling) — reducing them to one identifying value would
    # change to_hash and need a re-crawl, a separate decision.
    #
    # The current urn:bsi:… form of #to_urn is pubid-invented and stays
    # there.
    PubidUrnSchema = Pubid::PubidUrn.define("bsi") do
      atom "publisher.body", "pubbody"
      atom "copublishers", "co", kind: :list
      atom "prefix", "prefix"
      atom "flex_prefix", "flexprefix"
      atom "part", "part"
      atom "subpart", "subpart"
      atom "year", "year"
      atom "month", "month", kind: :int
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
      atom "format", "format"
      atom "topic", "topic"
      atom "separators", "seps", kind: :list
      atom "separator", "sep"
      atom "reverse_format", "revfmt", kind: :bool
      atom "common_year.year", "cyear"
      atom "supplement_number", "sup"
      atom "supplement_year", "supyear", kind: :int
      atom "addendum_number", "addn"
      atom "addendum_year", "addy", kind: :int
      atom "method_code", "mcode"
      atom "method_to", "mto"
      atom "method_and", "mand"
      atom "is_plural", "isplural", kind: :bool
      atom "section_id", "secid"
      atom "section_format", "secfmt"
      atom "second_number.value", "snd"
      atom "spec_code.value", "spc"
      atom "index_format", "idxfmt"
      atom "issue_number", "issue"
      atom "translation_lang", "translang"
      atom "test_id", "testid"
      atom "test_series", "testseries"
      atom "iteration", "iter"
      atom "fragment_number", "frag"
      atom "explicit_prefix", "expprefix", kind: :bool
      atom "explicit_publisher", "exppub", kind: :bool
      atom "space_separated_part", "sspart", kind: :bool
      atom "amd_suffix_form", "amdsuffix", kind: :bool
      atom "bundle_type", "btype"
      atom "identifiers", "ids", kind: :ids
      atom "na_supplements", "nasup", kind: :ids

      type "pubid:bsi:addendum-document", "ad"
      type "pubid:bsi:adopted-european-norm", "aen", core: []
      type "pubid:bsi:adopted-international-standard", "ais", core: []
      type "pubid:bsi:aerospace-standard", "as"
      type "pubid:bsi:amendment", "amd"
      type "pubid:bsi:british-industrial-practice", "bip"
      type "pubid:bsi:british-standard", "bs"
      type "pubid:bsi:bundled-identifier", "bundle", core: []
      type "pubid:bsi:committee-document", "cd"
      type "pubid:bsi:consolidated-identifier", "consol", core: []
      type "pubid:bsi:corrigendum", "cor"
      type "pubid:bsi:detailed-specification", "ds"
      type "pubid:bsi:disc", "disc"
      type "pubid:bsi:draft-document", "dd"
      type "pubid:bsi:electronic-book", "eb"
      type "pubid:bsi:expert-commentary", "ec", core: []
      type "pubid:bsi:explanatory-supplement", "es"
      type "pubid:bsi:flex", "flex"
      type "pubid:bsi:handbook", "hb"
      type "pubid:bsi:identifier", "id"
      type "pubid:bsi:index", "index"
      type "pubid:bsi:method", "method"
      type "pubid:bsi:national-annex", "na"
      type "pubid:bsi:practice-guide", "pg"
      type "pubid:bsi:publicly-available-specification", "pas"
      type "pubid:bsi:published-document", "pd"
      type "pubid:bsi:section", "section"
      type "pubid:bsi:set", "set", core: []
      type "pubid:bsi:standalone-amendment", "sa"
      type "pubid:bsi:supplement-document", "sd"
      type "pubid:bsi:supplementary-index", "si"
      type "pubid:bsi:technical-specification", "ts"
      type "pubid:bsi:test-method", "tm"
      type "pubid:bsi:value-added-publication", "vap"
    end
  end
end
