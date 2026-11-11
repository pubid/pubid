# NIST flavor notes

NIST rendering formats and annotated output.

Read this before you change `lib/pubid/nist/` or `spec/pubid/nist/`. The root
`CLAUDE.md` keeps the cross-flavor contract that every flavor obeys.

- **Six NIST types rendered plain under `to_s(annotated: true)`, and two
  more carried a latent corruption.** NIST's `to_s` takes a **positional**
  `format`, which Ruby fills with a Hash when a caller passes `annotated:`;
  `Identifiers::Base#to_s` already handles that and annotates. The six that
  did not — `CommercialStandardsMonthly`, `CrplReport`, `InteragencyReport`,
  `MiscellaneousPublication`, `Monograph`, `Report` — either compose their
  own string or hand `super` a **Symbol**, which drops the flag. Each now
  pulls `annotated` out of the Hash itself and wraps its result.

  **`Circular` and `Handbook` are the interesting half.** Both did
  `result = super` — which annotates — and then rewrote the edition with a
  **`$`-anchored** regex. Once the string ends in `</span>` the anchor
  cannot match, so the rewrite silently stops applying. Both now strip the
  flag before `super`, rewrite, then annotate.

  **An output assertion cannot catch that**, and this is the lesson: for
  both fixture references (`NBS CIRC 11e2-1915`, `NBS HB 44e2-1955`) the
  annotator matches only the leading publisher, so the tail is bare and the
  wrong order still produces the right string. The spec asserts the
  **ordering** instead — it wraps `annotate_plain_render` and checks the
  string handed to it is already rewritten and carries no span — and that
  assertion was verified to fail when the order is reverted.

  `CircularSupplement` and `SupplementIdentifier` were also normalised:
  both had a date-range branch that returned a hand-composed string without
  ever reaching `super`. `SupplementIdentifier` has four exits, so its
  composition moved into a private `render_plain`; **`super` is not
  reachable from a private method**, so `to_s` hands it in as a block —
  `render_plain(format) { super(format) }`.

- **`all_parts_edition_keys` needed `update`/`update_component`, not
  `edition_year`.** `Identifier.all_parts_edition_keys` defaults to
  `%i[date year edition version]`; NIST's primary edition carrier
  (`edition`, a `Components::Edition`) is already covered, but the Letter
  Circular / Circular "rJun1992"-style revision (`Builder` around the
  "Convert revision with month+year to update component" comment) parses
  into a **separate** attribute, `update`/`update_component`
  (`Components::Update`: number+year+month), which the default list
  missed entirely — `"NBS LC 800 rJun1992"` and `"NBS LC 800 rJul1995"`
  failed to collapse under `#to_all_parts`/`#===`. Fixed with
  `Pubid::Nist::Identifier.all_parts_edition_keys` (`super + %i[update
  update_component]`). **`edition_year` and `revision_year`/
  `revision_month` were investigated and are NOT added**: `Builder` only
  ever sets `edition_year` alongside the real `edition` component (never
  as its sole carrier, e.g. the TechnicalNote "date IS edition" branch),
  and `revision_year`/`revision_month` are transient — converted into
  `update`/`update_component` and cleared to `nil` before the object is
  returned. Neither carries live information `edition`/`update` doesn't
  already cover. Locked by `spec/pubid/all_parts_edition_keys_audit_spec.rb`.

- **The URN parser must rebuild the human face the generator started from,
  field for field.** `UrnGenerator` dot-joins identity fields after the
  number (`urn:nist:sp:304.e2017.A.supp`), and `UrnParser#parse_payload`
  splits them back: the edition/volume/revision glue onto the number, a
  single capital-letter token is a **part** glued to the code
  (`304A`), an edition's additional text keeps its dot (`13e2.June1908` —
  the token after `eN`), `insert`/`errata`/`add` markers glue verbatim,
  the bare `.supp` is supplementability (non-identity) and a valued
  `.supp-<v>` is `sup<v>`. The rebuild is only correct if the flavor's own
  grammar accepts it, so every branch is measured against the corpus —
  before this, the five rows with a part letter, an edition additional
  text, or an addendum marker failed to re-parse and the reference's own
  `parse_urn` raised on its own output. The ts mirror must reproduce
  Ruby's `String#split` behaviour and drop **trailing** empty fields
  (`"800-38.A.supp.add."` splits with a trailing `""` in JS but not in
  Ruby; keeping it appends a stray `.`). Locked by
  `spec/pubid/nist/urn_parser_spec.rb`.

- **FIPS MR keeps the parsed publisher.** `FederalInformationProcessingStandards`
  sets `default_publisher` to `""`, and its `to_mr_style` once started from
  `series_code` alone, so `NIST.FIPS.197-upd1.ipd` rendered `FIPS.197-upd1.ipd`
  — not the DOI suffix NIST publishes. It now mirrors its own
  `to_short_style`: the publisher prefixes only when the input carried one
  (`NIST.`/`NBS.`), and a bare `FIPS 140-3` still renders `FIPS.140-3`.
  Locked by `spec/pubid/nist/identifiers/fips_spec.rb`.

- **pubid-scheme URN (issue #656).** `lib/pubid/nist/pubid_urn_schema.rb`
  covers all 22 types; rulings in `docs/URN-SCHEMES.adoc` (`[[urn-nist]]`).
  `update` and `update_component` serialize every field, so each field is
  its own atom (`upd-`, `updyear-`, `uc-` …); reducing them changes
  `to_hash` and needs a `relaton-data-nist` re-crawl, so it was not done.
  `publisher_was_parsed` (`false` for a bare `FIPS 140-3`),
  `parsed_format`, `edition.original_prefix` and the bracketed
  `translation` are facets. No pass fixture sets `publisher_was_parsed`,
  `supplement.year_end` or the Integer `year`; the review found them by a
  sweep of `full/` and the spec literals, so sweep those too when a schema
  changes. Found in passing, not fixed:
  `NIST.IR.8259Apt` parses as `NIST IR 8259(por)` and loses the `A`.
- **The from_hash shape residual (part letter suffix and SP subseries)**:
  the parse path builds two shapes the stored rows lost on the way through
  the wire, and the relaton corpus gate's Law 1b
  (parse(render(x)).to_hash == x.to_hash) failed for every affected row
  (run 42204581379, 16–22 NEW nist-structure per slice; the class the
  relaton manifest describes as "the n+UPPER token's structural placement
  differs between the parsed and deserialized forms"). (1) A `part` hash
  without a `type` is the letter suffix — the parse of the printed face
  ("NIST NCSTAR 1A") carries `type: ""`; left nil the component fell back
  to the annex face and rendered "1nA", a different document (the true
  faces are in the relaton-data-nist document records: NIST NCSTAR 1A, NBS
  HR 1-1A). Every type-less part value in the published index is a single
  letter, so the inference is safe. This also repaired the three
  nist-fidelity rows ("NIST SP 1075-NCNnR", "NIST SP 1113-BFRnL",
  "NIST SP 1113-PERMInS"). (2) An SP row's `subseries` is derived metadata
  ("800" from "800-53", Appendix A.2) that parse always recomputes;
  `from_hash` now derives it by the Builder's own condition and rules
  (`derive_subseries_code`, sharing SP_SUBSERIES). Locked by
  `spec/pubid/nist/from_hash_shapes_spec.rb`.

- **The bare compound series is the SERIES REFERENCE (owner ruling on the
  relaton fuzz gate's `NBS CS` mutant).** The compound-series branch of the
  grammar demanded a separator after the series token, so the bare
  abbreviation of a named series failed to parse; the fuzz gate drops the
  edition from a published `NBS CS e15`-style row and kept recording the
  mutant. The ruling: the bare form is a legitimate identity — the v1
  pubid-nist `series.yaml` names CS as Commercial Standards, CSM as
  Commercial Standards Monthly, CIS as Consumer Information Series, CS-E
  as the emergency form — the same partial/bare-reference pattern as
  BIPM's `SI Brochure`. The grammar (pubid-grammar, fleet compiler
  1.3.121) makes the compound branch's separator+tail one optional group,
  so every previously accepted form parses byte-identically and exactly
  the bare compound-series forms join the accept set; simple-series bare
  forms (`CS` alone, no publisher) are deliberately NOT covered. The bare
  forms route through the normal series classes (`NBS CS` →
  CommercialStandard …, `NBS CIS`/`NIST PS`/`NIST DCI` → the base
  `Identifier`), render the short face as the abbreviation and the MR
  face per the v1 series table (`NBS.CS`), and match their series members
  as wildcard queries (`#matches?`). Locked by
  `spec/pubid/nist/bare_series_reference_spec.rb`; the corpus round froze
  the six rows (`NBS CS`, `NBS CSM`, `NBS CIS`, `NBS CS-E`, `NIST PS`,
  `NIST DCI`) into the testsuite with the gem twin in lockstep.

- **"FIPS PUB <number>" is a preprocessor alias, not a grammar face
  (pubid#697).** NIST prints the series as "FIPS PUB <number>" but the
  grammar reads "NIST FIPS <number>", so `normalize_fips_pub_alias!`
  (head-anchored, immediately after the publisher/series stage) rewrites
  the printed prefix and the parse lands on exactly the canonical model —
  hash-, render-, URN- and MR-identical to "NIST FIPS <number>". The
  hyphenated numbers and the revision forms the grammar models
  ("FIPS PUB 199 Rev. 1" with its `original_prefix` facet, compact
  "rev1") ride the prefix alias; bare "FIPS <number>"
  (publisher_was_parsed: false) and NBS FIPS are untouched.
