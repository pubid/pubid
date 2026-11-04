# frozen_string_literal: true

module Pubid
  module Nist
    # The pubid-scheme URN of NIST (issue #656; docs/URN-SCHEMES.adoc).
    #
    #   NIST SP 800-53r5
    #   urn:pubid:nist:sp:800-53:pub-NIST:series-SP:subseries-800:edtype-r:ed-5
    #
    # The core is the document number. +publisher+ and +series+ are atoms,
    # because a few series print no number ("NIST OWMWP 06-13-2018" keeps
    # its date there) and the series spelling varies inside one type
    # ("CIRC", "NBS.CIRC", "LCIRC").
    #
    # +update+ and +update_component+ serialize every field of their
    # component, so each field is its own atom. Reducing them to one
    # identifying value changes #to_hash and needs a relaton-data-nist
    # re-crawl; that is a separate decision (docs/URN-SCHEMES.adoc).
    #
    # Facets: +parsed_format+ (the input was an MR string), the printed
    # prefix of a revision (" Rev. " against "r") and the bracketed
    # +translation+ ("(spa)"), whose code is the +lang+ atom.
    PubidUrnSchema = Pubid::PubidUrn.define("nist") do
      atom "publisher", "pub"
      atom "series", "series"
      atom "subseries", "subseries"
      atom "part.type", "parttype"
      atom "part.value", "part"
      atom "section", "section"
      atom "volume", "vol"
      atom "edition.type", "edtype"
      atom "edition.id", "ed"
      atom "edition.additional_text", "edtext"
      atom "edition_year", "edyear"
      atom "supplement.number", "sup"
      atom "supplement.suffix", "supsuffix"
      atom "supplement.year", "supyear"
      atom "supplement.month", "supmonth"
      atom "supplement.year_end", "supyearend"
      atom "supplement_date_range_start", "suprangestart"
      atom "supplement_date_range_end", "suprangeend"
      atom "supplement.has_revision", "suprev", kind: :bool
      atom "implicit_supplement", "implicitsup", kind: :bool
      atom "update.prefix", "updprefix"
      atom "update.number", "upd"
      atom "update.year", "updyear"
      atom "update.month", "updmonth"
      atom "update_component.prefix", "ucprefix"
      atom "update_component.number", "uc"
      atom "update_component.year", "ucyear"
      atom "update_component.month", "ucmonth"
      atom "revision_year", "revyear"
      atom "revision_month", "revmonth"
      atom "revised_date", "reviseddate"
      atom "update_number", "updnumber"
      atom "update_year", "updnumberyear"
      atom "stage.type", "stagetype"
      atom "stage.id", "stage"
      atom "draft_number", "draftnumber"
      atom "version_component.value", "v"
      atom "version", "version"
      atom "year", "year", kind: :int
      atom "month", "month", kind: :int
      atom "date_year", "dateyear"
      atom "date_month", "datemonth"
      atom "date_day", "dateday"
      atom "dated_seq", "datedseq"
      atom "prefix", "prefix"
      atom "range_notation", "range"
      atom "translation_component.code", "lang"
      atom "draft", "draft"
      atom "index", "index"
      atom "insert", "insert"
      atom "errata", "errata"
      atom "appendix", "appendix"
      atom "addendum", "addendum"
      atom "addendum_number", "addendumnumber"

      facet "publisher_was_parsed", "pubparsed", kind: :bool
      facet "parsed_format", "format"
      facet "edition.original_prefix", "edprefix"
      facet "translation", "translationsrc"

      type "pubid:nist:identifier", "id"
      type "pubid:nist:circular", "circ"
      type "pubid:nist:circular-supplement", "circsup"
      type "pubid:nist:commercial-standard", "cs"
      type "pubid:nist:commercial-standard-emergency", "cse"
      type "pubid:nist:commercial-standards-monthly", "csm"
      type "pubid:nist:crpl-report", "crpl"
      type "pubid:nist:dated-document", "dd"
      type "pubid:nist:federal-information-processing-standards", "fips"
      type "pubid:nist:grant-contractor-report", "gcr"
      type "pubid:nist:handbook", "hb"
      type "pubid:nist:interagency-report", "ir"
      type "pubid:nist:letter-circular", "lc"
      type "pubid:nist:miscellaneous-publication", "mp"
      type "pubid:nist:monograph", "mono"
      type "pubid:nist:ncstar", "ncstar"
      type "pubid:nist:nsrds", "nsrds"
      type "pubid:nist:owmwp", "owmwp"
      type "pubid:nist:report", "rpt"
      type "pubid:nist:special-publication", "sp"
      type "pubid:nist:technical-note", "tn"
      type "pubid:nist:supplement-identifier", "sup"
    end
  end
end
