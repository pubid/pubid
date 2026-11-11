# IHO flavor notes

IHO (International Hydrographic Organization) identifiers: the
S/P/M/B/C letter series, their parg-driven parse, and the full
component model (edition, supplement, part, annex, appendix +
subnumber, volume, issue, with-year qualifier) from the owner rulings
of 2026-11-03.

Read this before you change `lib/pubid/iho/` or `spec/pubid/iho/`. The
root `CLAUDE.md` keeps the cross-flavor contract that every flavor
obeys.

## Parsing runs on the parg artifact, through typed bindings

There is no `parser.rb` and no Parslet anywhere in this flavor: parse
goes `Pubid::Parg::Model.bound(:iho, ...)` — the artifact's
`bindings identifier` block delivers every component as an
attribute-named scalar, and `Builder` only dispatches the series
letter to its concrete class and pads one grammar-level alias (the
S-100 `v1`/`v5.1` shorthand fills `edition` as `1.0.0`/`5.1.0`). The
artifact is baked from `grammars/iho.parg` in pubid-grammar; the
vendored twin `data/parg/iho.parg` is the embedded source's provenance
copy and must move together with `data/parg/iho.json` (the ISO
pattern).

**Bake pin:** the artifact must be baked at parsanol 1.3.126 (the
grammar repo's `scripts/bake-one.rb` forces the gem version and
verifies the `compiler_version` stamp). 1.3.127 is broken fleet-wide
(parsanol-ruby#434 — its loud-loss check matches the binding PATH
instead of the CAPTURE name), so both repos pin below it: the grammar
repo's CI moved 1.3.121 → 1.3.126 with the component-model PR.

## The component model (owner rulings, 2026-11-03)

Every component is a FIRST-CLASS SEMANTIC component: a typed `:string`
attribute, independently addressable, URN-encodable and matchable —
never a string suffix. All of them live flat on `Pubid::Iho::Identifier`
(mapped through the flavor `key_value` block, no converters):

| component   | attribute          | canonical face    | parse-only aliases           |
|-------------|--------------------|-------------------|------------------------------|
| edition     | `edition`          | `1.0.0` (bare)    | `v1`/`v5.1` (padded)         |
| supplement  | `supplement`       | `Sup 1`           | `Suppl 1`                    |
| part        | `part`             | `Part A`/`Part 1`/`Part S-102` | `S-5-B`, `S-100-1`, `S-158-S-102` (compact) |
| annex       | `annex`            | `Annex A`         | —                            |
| appendix    | `appendix`         | `Appendix D`      | `App`, `Ap.`                 |
| subnumber   | `appendix_subnumber` | `-2` (joined)   | —                            |
| volume      | `volume`           | `Vol. 30`/`Vol. 2024` | `/21` (slash chain), bare `2024` |
| issue       | `issue`            | `(2)`             | `Issue 2`                    |
| year (qualifier) | `year`        | `(2024)`          | —                            |
| component edition | `<kind>_edition` (+ `<kind>_year`) | `<kind> x.y.z (2024)` | —     |

- **Two main syntaxes:** `IHO S-100 1.0.0` (dated = edition-specific)
  and `IHO S-100` (undated = edition-non-specific). The official IHO
  edition is the dotted x.y.z WITHOUT a year; a year beside an edition
  is the with-year qualifier, never a year-keyed docidentifier. The
  canonical part face is edition-before-part: `IHO S-100 1.0.0 Part 2`.
- **The part's compact face is hyphenated** (`IHO S-5-B`,
  `IHO S-100-1`) — it parses AND renders via `to_s(compact: true)`.
  Gluing without a separator is disallowed as a form: it cannot extend
  to numbered parts unambiguously (`S-1001`). The four lettered glued
  bases in the records (S-5A, S-5B, S-8A, S-8B) are LEGACY parse-only
  aliases, never rendered; the owner rules later whether to reject
  them. The dash-digit suffix that used to join the number (`P-6-3` as
  number "6-3") is now the part component.
- **One serial locator: the volume.** P-1 and P-6 are volume-keyed;
  the yearbook year IS a volume (`IHO P-5 Vol. 2024`, short
  `IHO P-5/2024`). The bare year (`IHO P-5 2024`) is a legacy alias
  that binds INTO `volume` — `year` never carries a serial locator.
- **The with-year qualifier** (`IHO S-100 5.0.0 Part 2 (2024)`) is the
  only base `year` face, always parenthesized beside an edition.
- **Component-edition duality** (owner: "this can happen with any
  independently publishable artifacts"): supplement, part, annex,
  appendix and volume each carry an optional `<kind>_edition` (+
  `<kind>_year`) of their own, MUTUALLY EXCLUSIVE with the base edition
  context — within-edition (`IHO P-6 1.0.0 Vol. 2`, the component rides
  the base's edition) vs separately-published (`IHO P-6 Vol. 2 1.0.1`,
  `IHO S-98 Part A 1.0.0`, `IHO S-158 Part S-102 0.2.0`; the base is
  cited edition-less). The builder raises when both appear. Every
  trailing edition now follows a component, so the historical
  edition-last spellings reinterpret as component editions.
- **Series-reference parts**: a check standard applied to another IHO
  series cites it as its part — `IHO S-158 0.2.0 Part S-102`, compact
  `IHO S-158-S-102` (the part value vocabulary is letter | number |
  `[SPMBC]-<digits>`). The wild glued `S-158-102` stays a plain number
  part: the syntax cannot distinguish it from `S-100-1` = Part 1, and
  normalizing it needs an IHO series table (owner call pending).
- **Supplement canonical face is `Sup`** (the M-2 spelling — why save
  two characters when Annex and Appendix stay full-length); `Suppl`
  (the S-66 wild spelling) is the parse-only alias, never rendered.
- **Appendix canonical face is `Appendix`**; the subnumber keeps its
  own component (`Appendix D` + `appendix_subnumber` "2" render joined
  as `Appendix D-2`).

The compact face (`compact: true`) folds the code-adjacent components
onto the code: supplement and part hyphenated, volume as the slash
chain — `IHO M-2-2`, `IHO S-100-2 5.0.0`, `IHO P-5/2024`.

## S-4 loose-leaf sections and specs (owner rulings, 2026-11-11)

The S-4 loose-leaf publication (Parts A/B/C → Sections 100-600, Part C
100-500 → Regulations/Specifications cited `<letter>-<hundreds><seq>`)
is modeled ONE COMPONENT DEEP, not two tiers: the spec number IS the
leaf. `B-401` binds the letter into `part` ("B") and the number into
`spec` ("401"); the SECTION (the hundreds digit) is DERIVED —
`#spec_section` (`B-401` → `"400"`) — never stored, never emitted, and
the `00` slot (B-400) IS the section-level citation, so `S-4 Part B,
Section 400` ≡ `IHO S-4 B-400` (one identity, two spellings).

| component    | attribute    | canonical face      | parse-only forms                    |
|--------------|--------------|---------------------|-------------------------------------|
| spec         | `spec`       | `B-401` (with part) | the spelled section (", Section 400") |
| spec sub     | `spec_sub`   | `.1`                | —                                   |
| spec variant | `spec_variant` | `(I)`             | —                                   |

- **Faces**: canonical compact `IHO S-4 B-401` (dated:
  `IHO S-4 4.10.0 B-401` — the edition precedes the citation, as it
  precedes the part). The citation face REPLACES the Part face in the
  renderer (`compact: true` is a no-op on it — it is already compact).
  Subs and variants combine (`B-351.1(I)` is in the 4.9.0 text).
- **Three forms parse to one identity**: the anchored citation, the
  LONG form `S-4 Part B, Section 400[, B-401]` (normalizing parse; the
  spelled section becomes `spec` alone, and beside a citation it only
  cross-checks the citation's derived section — "Section 500, B-401"
  raises) and the BARE `B-401` (implicit S-4 anchor; B only — bare
  C-x stays the Circular Letter series, and the 3-digit `[1-6]xx`
  shape keeps the B Bibliographic series (B-12) on the main branch).
  `IHO B-401` (publisher + bare) parses to the spec too.
- **The anchor is load-bearing**: a spec citation requires the S-4
  anchor (series S number 4 — the builder raises otherwise), a
  lettered Part (A/B/C, not a numbered part), and no component
  editions or S-4-foreign components (supplement/annex/appendix/
  volume/issue); the citation letter must agree with a Part-rule
  capture.
- **Reserved numbers** (`B-170`, `B-230`, `B-305`, `B-323` — "NOT
  CURRENTLY USED" in the Ed 4.9.0 and 4.10.0 contents) parse and
  resolve AS RESERVED, never invalid: `#reserved?` answers from
  `data/iho/s4-reserved-specs.yaml` (edition-keyed, provenance in the
  file; an edition-less reference is reserved when ANY seeded edition
  reserves the number). `lib/pubid/iho/reserved_specs.rb` is the
  loader (`Pubid::Iho::ReservedSpecs`).
- **URN atoms**: the citation is a child of its part — the letter rides
  the existing `part-` atom (case preserved: `part-B`, never the
  lowercase `part-b` sketch), then `spec-`, `specsub-`, `specvar-`
  (the `appsub-` naming convention; the `:sub-1`/`:variant-i` in the
  ruling's sketch are these atoms). `urn:iho:s:4:ed-4.10.0:part-B:
  spec-401`; the section is not emitted. No `ed-`/`year-` after a
  spec node (UrnParseError — the spec rides its publication's
  edition); `specsub-`/`specvar-` only after `spec-`.

## Identity semantics

- The components are identity-bearing in `==`/`matches?`; a bare
  reference (`IHO P-5`) leaves them all nil and wildcards the series
  (`spec/pubid/partial_ref_spec.rb` locks the omitted-key set:
  edition/year/volume/issue).
- Scalar **clusters**: `exclude(:volume)` nils `issue` with it, and
  `exclude(:appendix)` nils `appendix_subnumber` — a reference that
  omits the finer component still matches a hit that carries one (the
  base's additive `:year -> :date` alias shape).
- `all_parts_edition_keys` needs no override: the default
  `%i[date year edition version]` already covers `:year` and
  `:edition`.

## URN scheme — positional, containment-ordered

The URN mirrors the containment tree, one semantic atom per segment;
the segment grammar table lives in the grammar header
(`grammars/iho.parg`) and is implemented by
`urn_generator.rb`/`urn_parser.rb`:

    urn:iho:<type>:<number>[:ed-<x.y.z>][:sup-<n>][:part-<X>]
      [:annex-<A>][:appendix-<B>][:<sub>][:vol-<n>][:issue-<n>]
      [:year-<yyyy>]

- Markers are the lowercased face tokens (`ed-` follows ISO's
  RFC 5141 precedent); letters are case-preserved.
- `ed-` and `year-` are POSITIONAL: the edition attaches to the node it
  follows — the base when no component precedes it, else that
  component's own edition (`vol-2:ed-1.0.1` = separately-published
  volume). A `year-` belongs to a component only when it follows that
  component's own edition; otherwise it is the base with-year
  qualifier.
- Containment: part ⊃ annex ⊃ appendix ⊃ subnumber (bare digit atom,
  only directly after its appendix); vol ⊃ issue.
- The number occupies every leading bare segment up to the first
  marker, so a colon number (`S-158:100` → `urn:iho:s:158:100`)
  round-trips without escaping. A colon number and a volume stay
  distinct because the volume is marker-tagged (`urn:iho:s:158:2024`
  vs `urn:iho:s:158:vol-2024` — the #637 hazard, kept under the
  positional scheme).
- The yearbook year emits as the volume (`urn:iho:p:5:vol-2024`);
  `year-` exists only for the standards qualifier.
- The parser validates every marker value against its own pattern and
  rejects unknown/reordered/duplicate/junk segments with
  `Pubid::Errors::UrnParseError` (the ISO urn_parser strictness); it
  builds through `Builder.build` from the decoded attributes, so URN
  decode and string parse share one construction path.

**Breaking URN migrations this scheme carries** (legacy forms stay
decodable, never emitted): the dotted keys (`part.4a`, `suppl.1`,
`ap.A`, `annex.A`, `vol.30`, `issue.2`, `appendix.D-2`) and the bare
a.b.c edition segment move to the marker segments; the #635/#637
`y.2024` tag decodes into the **volume** (`urn:iho:p:5:y.2024` now
re-emits as `urn:iho:p:5:vol-2024`). relaton-data-iho needs a re-crawl
(it is already legacy pre-pubid-2 shape); the frozen testsuite corpus
rows are re-frozen in the coupled corpus round.

## Fixtures run through the classify pipeline

`spec/fixtures/iho/identifiers/full/identifiers.txt` is the input
corpus (seeded from the hand-curated pass files, the #407 serial
forms and the component-model matrix off the IHO publications
spreadsheet); `rake "validation:classify[iho]"` regenerates `pass/`
and `fail/` from it (the classifier deletes pass/fail first — never
edit them by hand, edit `full/` and reclassify). The normalizing
parses (Suppl→Sup, Ap.→Appendix, glued→expanded, bare year→Vol.,
v-shorthand→dotted) are recorded as `!input!rendered` entries.

## relaton-side follow-ups (not this repo)

`Relaton::Iho::Bibliography#pubid_match?`/`version_key` need the
edition rename (the serialized key moved `version` → `edition`) and
the volume unification; relaton-cli's `MachineIndex::REFINABLE_KEYS`
needs `edition`/`volume` beside the retired `version`/`year` keys; the
pubid pin moves in step with the relaton-data-iho re-key.

## pubid-scheme URN (issue #670)

`lib/pubid/iho/pubid_urn_schema.rb`; rulings in `docs/URN-SCHEMES.adoc`
(`[[urn-iho]]`). The atoms follow the containment order of
`UrnGenerator::SEGMENTS` — the document's `ed-`/`year-` first, then each
component with its own edition/year right after it (`sup-`, `part-`,
`parted-`, `appendix-`, `appsub-`, `vol-`, `issue-` …). Case is preserved
(`part-A`); the yearbook year is a volume (`vol-2024`, no `year-` value —
the legacy `y.` marker stays decodable in the official URN parser, never
emitted). The positional `urn:iho:` form of `UrnGenerator` stays on
`#to_urn` — pubid emits no `urn:mrn:iho:…` URN.
