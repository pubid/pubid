# frozen_string_literal: true

module Pubid
  module Ieee
    # The pubid-scheme URN of IEEE (issue #656; docs/URN-SCHEMES.adoc).
    #
    #   IEEE Std 802.11-2016
    #   urn:pubid:ieee:std:802:stage-Std:part-11:year-2016:f:0.sep-.
    #
    # The core is the document number. Every other value is an optional
    # prefixed atom, in the order below: the shared vocabulary first (who,
    # what, which part, when, which edition, which state), then the IEEE
    # flags, then the identifiers an IEEE id nests.
    #
    # The wrappers that name their wrapped document something other than
    # +base+ (+ieee_identifier+, +first_identifier+, +primary_identifier+ …)
    # write it as a nested atom, not as a root-first chain node, so they do
    # not share the slug prefix of that document. Renaming them to +base+
    # would change #to_hash and needs a relaton-data-ieee re-crawl.
    #
    # The official urn:ieee:std: form (RFC 8069) stays on #to_urn.
    PubidUrnSchema = Pubid::PubidUrn.define("ieee") do
      # Who.
      atom "publisher", "pub"
      atom "publishers", "pubs", kind: :list
      atom "lead_party", "lead"
      atom "copublisher", "co", kind: :list
      atom "copublishers.*.body", "copubs"
      # What.
      atom "prefix", "prefix"
      atom "type", "type"
      atom "variant", "variant"
      # Which part.
      atom "parts", "part", kind: :list
      atom "part", "pt"
      atom "subpart", "subpart"
      # When.
      atom "year", "year"
      atom "month", "month"
      atom "day", "day"
      atom "date.year", "dateyear"
      atom "date.month", "datemonth"
      atom "date.day", "dateday"
      atom "date.undated", "undated", kind: :bool
      atom "date_info", "dateinfo"
      atom "iec_year", "iecyear"
      # Which edition or revision.
      atom "edition", "ed"
      atom "edition_month", "edmonth"
      atom "revision", "rev"
      atom "reaffirmed", "reaff"
      # Which state.
      atom "stage", "stage"
      atom "stage_iteration", "iter"
      atom "iso_stage", "isostage"
      atom "ieee_draft", "ieeedraft"
      atom "draft", "draft"
      atom "draft_info", "draftinfo"
      atom "draft_status", "draftstatus"
      atom "typed_stage.abbr", "tsabbr", kind: :list
      atom "typed_stage.stage_code", "tsstage"
      atom "typed_stage.type_code", "tstype"
      atom "typed_stage.iso_stage_equivalent", "tsiso"
      atom "typed_stage.ieee_draft_equivalent", "tsieee"
      atom "typed_stage.approval_status", "tsapproval"
      atom "typed_stage.project_status", "tsproject", kind: :bool
      # Which language and locality.
      atom "languages.*.code", "lang"
      atom "locality.value", "loc"
      # IEEE flags and free-text designations.
      atom "project_marker", "project", kind: :bool
      atom "redline", "redline", kind: :bool
      atom "interpretation", "interp", kind: :bool
      atom "registered", "registered", kind: :bool
      atom "abbr_suffix", "abbrsuffix", kind: :bool
      atom "abbr_suffix_registered", "abbrsuffixreg", kind: :bool
      atom "rev_bare", "revbare", kind: :bool
      atom "space_before_draft", "spacedraft", kind: :bool
      atom "month_glued", "monthglued", kind: :bool
      atom "ashrae_number", "ashrae"
      atom "ashrae_year", "ashraeyear"
      atom "iso_identifier", "isoid"
      atom "adoption", "adoption"
      atom "amendment_to", "amendmentto"
      atom "crossref", "crossref"
      atom "nickname", "nick"
      atom "note", "note"
      atom "parenthetical_content", "paren"
      atom "relationships.*.relationship_type", "rel"
      # Identifiers an IEEE id nests.
      atom "ieee_identifier", "ieeeid", kind: :id
      atom "iec_identifier", "iecid", kind: :id
      atom "first_identifier", "first", kind: :id
      atom "second_identifier", "second", kind: :id
      atom "primary_identifier", "primary", kind: :id
      atom "secondary_identifier", "secondary", kind: :id
      atom "parenthetical_identifier", "parenid", kind: :id
      atom "adopted_identifiers", "adopted", kind: :ids
      atom "revision_of", "revof", kind: :id
      atom "supplement_to", "supto", kind: :id
      atom "amendments", "amds", kind: :ids
      atom "corrigenda", "cors", kind: :ids
      atom "incorporates", "incl", kind: :ids
      atom "supersedes", "supersedes", kind: :ids

      # Spelling only.
      facet "separator", "sep"
      facet "separators.*", "seps"
      facet "rev_sep", "revsep"
      facet "year_sep", "yearsep"
      facet "date_separator", "datesep"
      facet "original_format", "format"
      facet "languages.*.original_code", "langsrc"

      type "pubid:ieee:standard", "std"
      type "pubid:ieee:project-draft-identifier", "proj"
      type "pubid:ieee:si-standard", "si"
      type "pubid:ieee:redlined-standard", "redlined"
      type "pubid:ieee:joint-development", "joint"
      type "pubid:ieee:iec-ieee-copublished", "iecieee"
      type "pubid:ieee:dual-identifier", "dual"
      type "pubid:ieee:dual-published", "dualpub"
      type "pubid:ieee:csa-dual-published", "csadual"
      type "pubid:ieee:multi-numbered-identifier", "multi"
      type "pubid:ieee:adopted-standard", "adopted"
      type "pubid:ieee:parenthetical-identifier", "paren"

      type "pubid:ieee:amendment", "amd"
      type "pubid:ieee:corrigendum", "cor"
      type "pubid:ieee:interpretation-identifier", "int"
      type "pubid:ieee:conformance-identifier", "conf"
      type "pubid:ieee:supplement-identifier", "sup"

      type "pubid:ieee:aiee", "aiee"
      type "pubid:ieee:ire", "ire"

      type "pubid:ieee:nesc-standard", "nesc"
      type "pubid:ieee:nesc-edition", "nescedition"
      type "pubid:ieee:nesc-handbook", "nescbook"
      type "pubid:ieee:nesc-draft", "nescdraft"
      type "pubid:ieee:nesc-preprint", "nescpre"
      type "pubid:ieee:nesc-redline", "nescredline"

      # The base class. The builder makes one for a parenthetical inside a
      # relationship, whose related ids #to_hash does not serialize today;
      # declared so that one in any other slot still emits.
      type "pubid:ieee:identifier", "id"
    end
  end
end
