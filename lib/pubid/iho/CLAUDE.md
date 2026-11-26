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
attribute-named scalar, and `Builder` dispatches the series letter to
its concrete class and resolves two grammar-level aliases (the S-100
`v1`/`v5.1` shorthand pads `edition` to `1.0.0`/`5.1.0`; the S-158
draft-era part faces rebind onto `product`). The artifact is baked
from `grammars/iho.parg` in pubid-grammar; the vendored twin
`data/parg/iho.parg` is the embedded source's provenance copy and must
move together with `data/parg/iho.json` (the ISO pattern).

**Bake pin:** the artifact must be baked at parsanol 1.5.1.0 (the
fleet pin; the grammar repo's `scripts/bake-one.rb` forces the gem
version and verifies the `compiler_version` stamp; bake at ruby 3.4.8).

## The component model (owner rulings, 2026-11-03; the S-158 series
   model, issue #774, 2026-11-25)

Every component is a FIRST-CLASS SEMANTIC component: a typed `:string`
attribute, independently addressable, URN-encodable and matchable —
never a string suffix. All of them live flat on `Pubid::Iho::Identifier`
(mapped through the flavor `key_value` block, no converters):

| component   | attribute          | canonical face    | parse-only aliases           |
|-------------|--------------------|-------------------|------------------------------|
| edition     | `edition`          | `1.0.0` (bare)    | `v1`/`v5.1` (padded)         |
| S-158 member | `product`     | `:102` (the S-158 colon designator) | `Part S-102`, `S-158-S-102`, `Part 102` (the draft-era faces; `product_face` keeps the spelling) |
| supplement  | `supplement`       | `Sup 1`           | `Suppl 1`                    |
| part        | `part`             | `Part A`/`Part 1` | `S-5-B`, `S-100-1` (compact) |
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
- **Series-reference parts are DEAD on S-158 (issue #774, the S-158
  series model; S-158 Ed 1.0.0 clause 2.1):** S-158 is a framework
  publication defining a series of separate check specifications —
  S-158:100 (generic), S-158:1xx (one per S-100 product; :101 ENC,
  :102 Bathymetric Surface), S-158:98 (interoperability), S-158:128
  (catalogue) — each a publication of its own with its own edition
  stream. The colon designator `S-158:102` is the PRIMARY form and
  binds the typed `product` component; the draft-era spellings
  (`S-158 Part S-102`, `S-158-S-102`, `S-158 Part 102`) are
  NON-NORMALIZED ALIASES of the same identity — facets-spelling-only
  (the render keeps the Part face through `product_face`;
  equality/URN use the canonical shape), and the edition that follows
  the part face is the BASE edition (the parted- mis-bind of #775 is
  fixed). A series-reference-shaped part face rebinds only while
  product is UNBOUND: `S-158:100 Part 2` keeps a genuine part. The
  member designator rides the S-158 anchor only (`S-44:5` rejects).
  Lettered/compound part values on other series are untouched
  (`S-100-1` stays Part 1).
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
  C-x stays the C Capacity Building series, and the 3-digit `[1-6]xx`
  shape keeps the B Bathymetric series (B-12) on the main branch).
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

## URN schemes — the adopted IHO MRN guidance + the legacy positional decode

The full scheme documentation lives in `lib/pubid/iho/urn.adoc` (the
per-flavor home of the former `docs/URN-SCHEMES.adoc` iho section; the
owner's per-flavor split ruling of 2026-11-25). The laws:

- **The emission of every series is the IHO MRN guidance form**
  (`urn:mrn:iho:pub:<type>:<name>[:<edition>][:trailing...]`); the
  five series bind 1:1 onto the guidance's five publication type
  codes — `spec` (S), `per` (P), `reg` (M), `bathy` (B Bathymetric
  Publications), `cb` (C Capacity Building Publications). The B/C
  bindings cite IHO S-11 Part C Ed 1.0.0 section 1.2, which arranges
  the IHO publications under five groups ("B - Bathymetric
  Publications (Mainly related to GEBCO)", "C - Capacity Building
  Publications", M - Miscellaneous Publications (including Basic
  Documents), P - Periodic Publications, S - Standards and
  Specifications) — the five groups onto the guidance's five codes.
  The name is the lowercase `sNNN`/`bNNN`/`cNNN` (the guidance's own
  s57/s98 spelling); the dotted edition is the bare canonical 4th
  segment; the S-158 member joins the name hyphenated (`s158-102`,
  the fleet extension for compound publication numbers).
- **The legacy positional `urn:iho:` grammar is decode-only for every
  series, emitted by none** (all five series carry a guidance type
  code): marker segments, positional `ed-`/`year-`, the
  bare appendix-subnumber atom, and the further bare digit segment
  binding the S-158 member. The legacy 2.0.x spellings (dotted keys,
  bare `a.b.c` editions, `y.`) stay decodable, never emitted.
- **Both decode paths build through `Builder.build`** — the S-158
  alias unification and every other semantic validation is shared
  with the text parse; a URN decode renders the canonical shape (the
  spelling face is parse-only).

    IHO S-44 5.0.0               -> urn:mrn:iho:pub:spec:s44:5.0.0
    IHO S-158:102 1.0.0          -> urn:mrn:iho:pub:spec:s158-102:1.0.0
    IHO S-158 Part S-102 0.2.0   -> urn:mrn:iho:pub:spec:s158-102:0.2.0 (order-stable)
    IHO M-2 Sup 1                -> urn:mrn:iho:pub:reg:m2:sup-1
    IHO P-1 Vol. 30 (2)          -> urn:mrn:iho:pub:per:p1:vol-30:issue-2
    IHO B-12 3.0.0               -> urn:mrn:iho:pub:bathy:b12:3.0.0 (CSB Guidance)
    IHO C-51 6.0.0               -> urn:mrn:iho:pub:cb:c51:6.0.0 (Manual on Hydrography)

**Breaking URN migrations this scheme carries** (legacy forms stay
decodable, never emitted): the official-URN namespace moved to the
guidance form (`urn:mrn:iho:pub:...`) — first for S/P/M, then for the
B/C rows too (the legacy `urn:iho:b:/c:` emission is dead); the S-158
member
moved to the `s158-NNN` name encoding (issue #774) with the draft-era
part spellings rebinding onto `product` (#775's parted- mis-bind
fixed); the dotted keys (`part.4a`, `suppl.1`, `ap.A`, `annex.A`,
`vol.30`, `issue.2`, `appendix.D-2`) and the bare a.b.c edition segment
stay decode-only; the #635/#637 `y.2024` tag decodes into the
**volume**. The wire-type names are honest (the B/C rows were
misnomers): `pubid:iho:bibliographic` -> `pubid:iho:bathymetric`
(`Identifiers::Bathymetric`), `pubid:iho:circular-letter` ->
`pubid:iho:capacity_building` (`Identifiers::CapacityBuilding`) — a
clean rename of the model (no attribute/face alias kept; the S-158
checks_for->product precedent); the pubid-scheme slugs `b`/`cl` are
unchanged. The PRE-RENAME `_type` wire names stay DECODABLE (decode-only,
never emitted — the LEGACY pattern of this wave): stored rows (the
relaton-data-iho v2 index, snapshots crawled before the rename) still
carry them, and the relaton index loader rejects a file whose `_type`
fails to route — `polymorphic_type_map` merges the two aliases and
`from_hash` re-tags a legacy `_type` onto the renamed wire name, so a
decoded row equals a parsed query under `==` (which reads `_type`).
Removable once relaton-data-iho is re-crawled. relaton-data-iho needs a
re-crawl (it is already legacy pre-pubid-2 shape); the frozen
testsuite corpus rows are re-frozen in the coupled corpus round.

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

`lib/pubid/iho/pubid_urn_schema.rb`; rulings in the flavor's
`lib/pubid/iho/urn.adoc`. The atoms follow the containment order of
the official URN — the S-158 member designator rides the document code
(`product-102`, issue #774) before the document's `ed-`/`year-`, then
each component with its own edition/year right after it (`sup-`,
`part-`, `parted-`, `appendix-`, `appsub-`, `vol-`, `issue-` …). Case
is preserved (`part-A`); the yearbook year is a volume (`vol-2024`, no
`year-` value — the legacy `y.` marker stays decodable in the official
URN parser, never emitted). The draft-era part-faceted S-158 emission
(`part-S-102`, `parted-`) is dead: the `from_hash` unification
redirects it onto the `product` identity, so the legacy URN fails
the canonical gate. The official URN of every series is the
adopted IHO MRN guidance form (`urn:mrn:iho:pub:...`); the
`urn:pubid:iho:` scheme is pubid's own and is not governed by the
guidance.
