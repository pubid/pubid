# frozen_string_literal: true

require "parslet"

module Pubid
  module Oiml
    class Parser < Parslet::Parser
      include ::Pubid::Parser::CommonParseRules
      include ::Pubid::Parser::CommonParseMethods

      root :identifier

      # Additional basic rules not in CommonParseRules
      rule(:colon) { str(":") }
      rule(:lparen) { str("(") }
      rule(:rparen) { str(")") }
      rule(:slash) { str("/") }

      # Main identifier pattern - check supplements first
      rule(:identifier) do
        amendment_identifier | amendment_short | annex_letter_identifier |
          annex_identifier | plus_supplement_identifier |
          trailing_supplement_identifier | bulletin_identifier | base_identifier
      end

      # Publisher - always "OIML"
      rule(:publisher) { str("OIML").as(:publisher) >> space }

      # Document type - single letter
      rule(:doc_type) { match("[BDEGRSVX]").as(:type) >> space }

      # Bulletin locator — structured form. Year optionally followed by
      # 2-digit issue and 2-digit sequence:
      #   "OIML Bulletin", "OIML Bulletin 1960",
      #   "OIML Bulletin 1960-03", "OIML Bulletin 1960-03-01"
      # All four shapes appear as primary docids in relaton-data-oiml.
      rule(:bulletin_date) do
        space >> year_digits.as(:year) >>
          (dash >> two_digits.as(:issue)).maybe >>
          (dash >> two_digits.as(:sequence)).maybe
      end

      # Two-digit zero-padded number (used for issue / sequence).
      rule(:two_digits) { match('\d').repeat(2, 2) }

      # Roman numeral token composed of I,V,X,L,C,D,M (uppercase, matching
      # OIML's print convention). Captured so the builder can cross-check
      # the declared volume against the year implied by the article_id.
      rule(:roman_numeral) { match("[IVXLCDM]").repeat(1).as(:volume_roman) }

      # Bulletin locator — citation form. The format OIML prints on the
      # article page is: "LXVII(2) 20260211" where LXVII is the volume in
      # roman numerals, (2) is the issue in arabic without zero padding,
      # and 20260211 is the 8-digit oiml.org article id (YYYYNNSS).
      rule(:bulletin_citation) do
        space >> roman_numeral >>
          lparen >> digits.as(:issue_arabic) >> rparen >>
          space >> match('\d').repeat(8, 8).as(:article_id)
      end

      # Bulletin identifier — no code; the locator (when present) is the
      # (year, issue, sequence) tuple drawn from either the structured
      # YYYY-II-SS form or the citation VOLUME(ISSUE) ARTID form. Both
      # decode to the same record. Tried before base_identifier because
      # "Bulletin" is a word that the single-letter doc_type rule cannot
      # match.
      rule(:bulletin_identifier) do
        publisher >> str("Bulletin").as(:type) >>
          (bulletin_citation | bulletin_date).maybe >>
          language_portion.maybe.as(:language)
      end

      # Number with optional part and subpart
      rule(:number_only) { digits.as(:number) }

      # Part number, optionally a slashed multi-part continuation captured
      # verbatim, e.g. "1/-2" in "OIML R 46-1/-2:2012".
      rule(:part_number) do
        dash >> (digits >> (slash >> dash >> digits).repeat).as(:part)
      end

      rule(:subpart_number) { dash >> digits.as(:subpart) }

      # Free-form named/lettered code suffix glued after the numeric part:
      #   -GUM 1, -special, -sup, -erratum, -A, -ISO3930, -Amend, -Amended_2012
      # plus the space-separated "Brochure" label. "GUM <n>" is tried first so
      # its trailing number isn't lost to the bare-word alternative. The
      # trailing `(_?digits)*` captures joint codes ("ISO3930") and the
      # "Amended_2012" amendment label (the hand-off treats these as part
      # suffixes, preserved verbatim for round-trip).
      rule(:named_suffix) do
        (dash >> (
          (str("GUM") >> space >> digits) |
          (match("[A-Za-z]").repeat(1) >> (str("_").maybe >> digits).repeat)
        ).as(:code_suffix)) |
          (space >> str("Brochure").as(:code_suffix) >> str("").as(:space_suffix))
      end

      rule(:full_number) do
        (number_only >> part_number >> subpart_number >> named_suffix.maybe) |
          (number_only >> part_number >> named_suffix.maybe) |
          (number_only >> named_suffix.maybe)
      end

      # Edition number - ordinal numbers
      rule(:edition_number) do
        (
          str("6th") | str("5th") | str("4th") | str("3rd") |
          str("2nd") | str("1st") |
          (digits >> (str("th") | str("nd") | str("rd") | str("st")))
        ).as(:edition)
      end

      # Edition text - uppercase or lowercase
      rule(:edition_text) { str("Edition") | str("edition") }

      # Edition portion - handles "6th Edition 2015" or "Edition 2013" or ", edition 1992"
      rule(:edition_portion) do
        (
          (str(", ") | space) >>
          edition_number.maybe >> space.maybe >> edition_text >> space.maybe >> year_digits.as(:year)
        ).as(:edition_format) # Wrap entire match to capture that Edition was used
      end

      # Date - year after colon OR edition portion (with optional space before year)
      rule(:date) do
        edition_portion | (colon >> space.maybe >> year_digits.as(:year))
      end

      # Draft stage - WD or CD with optional iteration
      rule(:stage_iteration) do
        (
          (digits >> str(".") >> digits) | # 3.1
          digits # 1, 2, 3
        ).as(:iteration)
      end

      rule(:stage_abbr) do
        (str("WD") | str("CD")).as(:stage)
      end

      rule(:draft_stage) do
        space >> stage_iteration.maybe >> stage_abbr
      end

      # Language codes
      #
      # relaton-data-oiml encodes the publication language with its own code
      # set (lib/oiml_fetcher.rb DOCID_LANG_CODE): single uppercase letters
      # E F D R S C A U X, plus two-letter PO/PT/PE/SR. The two-letter OIML
      # codes must be tried before the single-letter rule so e.g. "PE" isn't
      # left with a dangling "E".
      rule(:lang_single) do
        match("[EFRXDSCAU]")
      end

      rule(:lang_multi_oiml) do
        str("PO") | str("PT") | str("PE") | str("SR")
      end

      rule(:lang_multi) do
        match("[a-z]").repeat(2, 2) # Two letters: en, fr, etc.
      end

      rule(:language_code) do
        (
          (lang_single >> slash >> lang_single) | # E/F
          lang_multi_oiml |                        # PO, PT, PE, SR
          lang_single |                            # E, F, D, R, S, C, A, U, X
          lang_multi                               # en, fr
        ).as(:language)
      end

      rule(:language_with_space) do
        space >> lparen >> language_code >> rparen >> str("").as(:space_before_lang)
      end

      rule(:language_without_space) do
        lparen >> language_code >> rparen
      end

      rule(:language_portion) do
        language_with_space | language_without_space
      end

      # Amendment identifier - "Amendment (YYYY) to BASE"
      rule(:amendment_identifier) do
        str("Amendment") >> space >> lparen >> year_digits.as(:year) >> rparen >>
          space >> str("to") >> space >>
          base_without_language.as(:base_identifier) >>
          language_portion.maybe.as(:language)
      end

      # Short amendment forms - "OIML TYPE NUMBER Amendment Edition YYYY" or "Amendment: YYYY"
      rule(:amendment_short) do
        publisher >>
          doc_type >>
          full_number.as(:base_code) >>
          space >> str("Amendment").as(:amd_marker) >>
          (
            (space >> edition_text >> space.maybe >> year_digits.as(:year)).as(:edition_format) |
            (colon >> space.maybe >> year_digits.as(:year))
          ) >>
          language_portion.maybe.as(:language)
      end

      # Trailing supplement word - "BASE Amendment" / "BASE Errata" where the
      # publication year stays on the base (e.g. "OIML R 138:2009 Amendment").
      # amendment_short is tried first; it only matches when a year follows the
      # word, so the no-year trailing form falls through to here.
      rule(:trailing_supplement_identifier) do
        base_without_language.as(:base_identifier) >>
          space >> (str("Amendment") | str("Errata")).as(:trailing_marker) >>
          language_portion.maybe.as(:language)
      end

      # Plus-joined supplement - "BASE:YEAR+Supplement:YEAR" form where both
      # the base and the supplement carry their own year. Used for amendments
      # and errata to dated bases (e.g. "OIML B 10:2011+Amendment:2012").
      # Annexes already encode the year-on-base intent via their own model.
      rule(:plus_supplement_identifier) do
        base_without_language.as(:base_identifier) >>
          str("+") >>
          (str("Amendment") | str("Errata")).as(:plus_marker) >>
          (colon >> year_digits.as(:year)).maybe >>
          language_portion.maybe.as(:language)
      end

      # Annex identifier - "BASE Annexes Edition YYYY" / "BASE Annexes:YYYY" /
      # "BASE:YYYY Annexes" (year on the base, no annex year).
      rule(:annex_identifier) do
        base_without_language.as(:base_identifier) >>
          space >> str("Annexes").as(:annex_marker) >>
          (
            (space >> edition_text >> space >> year_digits.as(:year)).as(:edition_format) |
            (colon >> year_digits.as(:year))
          ).maybe >>
          language_portion.maybe.as(:language)
      end

      # Annex letter or letter range, e.g. "A" or "B-C".
      rule(:annex_letter_value) do
        (match("[A-Z]") >> (dash >> match("[A-Z]")).maybe).as(:annex_letter)
      end

      # Annex with letter - "BASE Annex A Edition YYYY" / "BASE:YYYY Annex B-C"
      rule(:annex_letter_identifier) do
        base_without_language.as(:base_identifier) >>
          space >> str("Annex") >> space >> annex_letter_value >>
          ((space >> edition_text >> space >> year_digits.as(:year)) | (colon >> year_digits.as(:year))).maybe >>
          language_portion.maybe.as(:language)
      end

      # Base identifier without language (for use in supplements)
      rule(:base_without_language) do
        publisher >>
          doc_type >>
          full_number >>
          date.maybe >>
          draft_stage.maybe
      end

      # Base identifier for recursion and standalone parsing
      rule(:base_identifier) do
        publisher >>
          doc_type >>
          full_number >>
          date.maybe >>
          draft_stage.maybe >>
          language_portion.maybe
      end
    end
  end
end
