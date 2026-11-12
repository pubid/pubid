# ISO flavor notes

- **No identifier attribute holds a `Components::Code` any more**: `number`,
  `part` and `subpart` on `Pubid::Iso::Identifier`, the committee structure on
  `Identifiers::TcDocument` (`tc_type`/`tc_number`/`sc_type`/`sc_number`/
  `wg_type`/`wg_number`), `Identifiers::Directives#subgroup` and the
  `edition.number` the builder writes are all plain strings, and
  `Pubid::Iso::Components::Code` is deleted.
  **The component was degenerate everywhere it was used.** Measured over the
  whole 7,613-id pass corpus: no ISO Code carries `prefix`, `part`, `subpart`
  or `parts`, `parts` is never written anywhere in `lib/pubid/iso`, and no Code
  renders differently from its own `value`. ISO's part and subpart are sibling
  attributes of the identifier, not fields of the number — the `-` join in
  `Code#to_s` was unreachable.
  **`edition.number` was worse than degenerate: it leaked a live object.**
  `Components::Edition#number` is typed `Lutaml::Model::Type::Value`, so lutaml
  never serialized it — `to_hash` returned the `Components::Code` instance
  itself, and `to_yaml` emitted `!ruby/object:Pubid::Components::Code` with its
  internal ivars, which `YAML.safe_load` refuses. An edition now serializes
  `{"number" => "13", "original_text" => "Ed 13"}`.
  **The TC converters are gone with it**: twelve `*_to_kv`/`*_from_kv` helpers
  were replaced by plain `map "tc_type", to: :tc_type` declarations (the
  ETSI/OIML shape), because a String needs no converter to flatten.
  **Two shared surfaces needed a change, and both are the documented shims**:
  `Renderers::DirectivesRenderer` called `subgroup.render(context:)` directly
  and now reads through `render_component`; `Pubid::Iso.build_code` returned a
  Code and now returns the string (ASTM's `to_iso_identifier` goes through it,
  which is how one ASTM example caught the `NameError` after the class was
  deleted).
  **Verification — replay a baseline, do not trust the suite alone.** Against
  all 7,621 pass-fixture ids captured on the parent commit, `to_s`, `to_urn`,
  `to_mr_string`, `root.number` and the identifier class are **byte-identical**,
  and `to_hash` differs for exactly **12** ids: the 9 `subgroup` rows and the 3
  editions below. The first replay also caught a real regression the specs did
  not — `directives.rb` still called `part.value.downcase`, so 4 Directives
  URNs raised.
  **relaton note — `relaton-data-iso` needs a re-crawl, and only for one key.**
  `subgroup` flattens from `{"value" => "JTC 1"}` to `"JTC 1"`, and the
  published `index-v2.yaml` (branch `v2`) carries **5 such rows**, all ISO/IEC
  JTC 1 directives. **No compatibility shim is kept** — a stored nested
  `subgroup` will not deserialize. The edition change reaches nothing stored:
  `grep -c edition` over that index returns **0**.
  **Spec fallout is the shape to expect for the remaining flavors**: 592
  assertions across 25 files read `.number.value` / `.part.value`. The rewrite
  needs a lookbehind, because `tc_number.value` and `edition.number.value` are
  different attributes — the first pass stripped `edition.number.value` too,
  and two corrigendum examples caught it.

- **URN item paths and document versions are cut, not parsed (issue #645).**
  Glossarist-rendered corpora cite parent documents with URNs like
  `urn:iso:std:iso:10303:-2:ed-1:v1:en:tech:ACTIVITY_MIM` and a duplicated
  `:tech:X:tech:X:X` extraction tail. Neither tail is document identity, so
  `UrnParser` drops both: the bare document-version token (`v1` right after
  `ed-N` — the base identifier has no version attribute, and before this fix
  the supplement loop consumed it as a type-less supplement number, which
  wrapped the document as that phantom supplement and collapsed
  "ISO 10303-2" to "ISO 1"), and the item path, cut at the first
  supplement-loop token that can be nothing else (`item_path_segment?`).
  Two invariants to keep when editing this loop:
  **the cut's allow-list must mirror exactly what the loop consumes** —
  `stage-`, a bare typed-stage abbr, the `ABBR.N` form, a supplement type,
  digits, a `\Av\d` version, or a language field (`LANGUAGE_FIELD_RE`,
  2-3-letter ISO 639 codes, comma-separated). A token allowed through that
  no branch consumes spins the loop forever: the language branch used to be
  the loose catch-all that guaranteed progress, and gating it on
  `LANGUAGE_FIELD_RE` (so item-path segments stop overwriting the base
  language as a bogus "(ACTIVITY_MIM)" suffix) removed that guarantee —
  `FDAM.3` in `urn:iso:std:iso:17301:-1:FDAM.3:amd:2022:v1.3` exposed it.
  That is also why the loop gained an explicit `ABBR.N` arm: the base stage
  block deliberately skips a supplement-family stage when its own supplement
  follows, and the loop had to consume the token instead. It is consumed
  **and dropped** — the supplement layer has no stage-iteration slot, and
  the old catch-all carried it as a bogus base language visible only in the
  generated URN (`…:fdam.3:amd:1:2022:v1` → now `…:amd:1:2022:v1`; the
  locked `to_s` "ISO 17301-1/AMD 1:2022" is unchanged). Net effect:
  `parse(render(parse(urn)))` round-trips for both item-path forms — the
  face renders `(EN)` (a form the grammar accepts) instead of the
  unparseable `(ACTIVITY_MIM)` — and identifiers without an item path
  render byte-identically. No grammar or renderer change was needed.

- **Typed model bindings (Phase D): the builder consumes the grammar's bound
  map, not a parse tree.** `Identifier.parse` and `Normalizer` parse through
  `Pubid::Parg::Model.bound(:iso, …)`; `UrnParser#build_identifier` constructs
  the same bound-map dialect. The grammar is edition 2 with every
  builder-consumed capture bound (`grammars/iso.parg`, `bindings identifier`).
  The conversion preserved byte fidelity: `to_s` and `to_hash` are identical
  for all 7,859 fixture inputs replayed against a `main` baseline, and the
  wasm engine agrees with Ruby on every tree and bound map (the
  `corpus-parity` gate). **What to know before editing either side:**

  - **Supplement layers capture into position-scoped prefixes** — `supp_*`
    (first supplement), `supp2_*`/`supp3_*` (chain layers), `isor_supp_*`
    (ISO/R supplement), `dsupp_*` (directive supplement), `bs1_/bs2_/bs3_`
    (bundle items), `idf_*/idf_supp_*` (the joint's IDF side, whose rules are
    inlined from the imported idf grammar so the names never collide with the
    ISO ones). Bindings.collect_captures collects captures globally by name
    and delivers the FIRST occurrence, so shared names across layers would
    collapse a layer's number/date onto the base's. `Builder#build` peels the
    layers outermost-first, re-keying each prefix onto the builder-input
    names and nesting the rest as the layer's `:base`.
  - **The base document's own edition captures as `base_edition`** wherever a
    supplement layer's third_part can carry its own edition
    (`supplement_base_no_third`, the joint base). The builder re-keys it onto
    `:edition` only at the innermost base — moving it inside a peel step
    mis-assigns the edition to the wrapper on multi-layer chains (the
    `ISO/IEC Guide 98-3 ED1/Suppl 1:2008/Cor 1:2009` spec caught that).
  - **No array bindings.** The wasm engine's array-group harvest pads
    non-firing reps with empty hashes (parsanol-ruby#399), so Ruby and wasm
    bound maps disagree on any input whose parse backtracks past the array
    branch. Two consequences: copublishers capture as ONE scalar span
    (`"/IEC/IEEE"`, at-least-one item, absent when none) that the builder
    splits, and bundle items capture into `bs1_/bs2_/bs3_` prefixes the
    builder assembles into `supplements`. Verified to hold unchanged at the
    1.3.121 pin (the capture-flatten release): the re-baked artifact's
    grammar/entries/bindings/tests/tables are byte-identical to the 1.3.114
    bake. A newer engine's `(raw)` wrapper interiors would replace both
    shapes — re-visit when such a wrapper ships.
  - **The artifact exposes `["identifier", "idf.identifier"]`** — the
    `use idf` import survives the conversion so the joint composition's
    entry surface stays available (the fleet gate asserts the entry list).
    The joint's IDF side itself binds as `idf_*` scalars; the pilot's
    `publisher -> publisher_name (string) preprocess: publisher_names`
    binding is also kept (the T1 materialization asserts the full
    organization name), and the Ruby builder's `cast` returns nil for
    `:publisher_name` — the Ruby identifier has no such attribute. The
    Ruby artifact load resolves `use idf` against `data/parg/idf.parg`,
    which sits beside the vendored artifact.
  - **Captures must inline their bodies to raw terms.** A capture wrapping a
    bare rule ref exposes the ref's child nodes and cannot bind as a string
    (`cannot bind a Array capture`), and date/language bodies are inlined at
    all capture sites for that reason. Multi-line rules must be brace bodies
    (line-mode rejects newlines inside groups).
  - **The URN parser emits the same dialect**: its supplement loop writes
    `supp_`/`supp2_`/`supp3_`-prefixed flat keys (the prefixes the builder
    peels), not `{base:, **supp}` nesting; the builder peels `supp_year` and
    `supp_supplement_version` the same way by prefix. Its raw-stage fallback
    (`:stage`), `:document_type` and `:supplement_version` keys are
    builder-input names, not grammar captures, and pass through `cast`
    unchanged.
  - **Grammar probes**: `ruby -e 'gem "parsanol", "1.3.121"; …'` against the
    artifact (`parse_and_bind`) shows the bound map; `Model.bound(:iso, …)`
    shows the builder's actual input. The artifact and its vendored twin
    (`data/parg/iso.parg`) must move together — the twin is the embedded
    source's provenance copy.

- **`typed_stage.original_abbr` is spelling, so `==` skips it (issue #656).**
  The parse path stores the input token (`Amd.`, `COR`, `DAmd`, `pDCOR`) and
  `stage_from_kv` stores the canonical one (`Amd`, `Cor`, `DAM`); the value is
  not serialized. Before the fix, 90 pass ids (supplements, Directives,
  Guides, `ISO/NWIP`) were not `==` after `from_hash(to_hash)`, so
  `#matches?` against an index row returned false with no error. ISO cannot
  delete the write as JCGM and IEC did, because `detect_stage_format_long`
  reads it. `Components::TypedStage` now declares
  `equality_ignored :original_abbr`. Since `to_s` reads the value, two `==`
  ids may render differently, which the #656 rule allows. Locked by
  `spec/pubid/iso/typed_stage_round_trip_spec.rb`.
  **Still open, and not covered by that spec**: 14 pass ids stay unequal for
  another reason — `DirectivesSupplement#supplement_publisher` is an
  `Iso::Components::Publisher` after `parse` and a `Pubid::Components::Publisher`
  after `from_hash` (11 supplements, 3 bundles).

- **Historic TYPE-first ballot faces decode to the canonical on-base slash
  form (owner ruling 2026-11-12, Option B — IHO-style decode-to-modern;
  SSOT `data/iso/historic-schemes.md`).** The DAM-family token in TYPE
  position (`ISO/IEC FDAM 1 14496-12:2004`, `ISO/PDAM 19973-2`) and the
  space-attached ballot face (`ISO 15877-5:2009 FDAM 1`) used to raise; the
  grammar (v0.5.0) gained two additive branches at the END of the
  identifier alternation, so every face an existing member parses keeps its
  exact parse (replayed: 15,307 fixture inputs and 213,414 stored
  docidentifier faces byte-identical on `to_s`/`to_urn`/`to_hash`/
  `to_mr_string`). What to know before editing either side:
  - **The ballot token captures as `ballot_type_with_stage`** (table
    `typed_stages_ballots`: PDAM, DAM, DAmd, FDAM, FDAmd, FPDAM), NOT as
    `supp_type_with_stage` — a shared name would make the builder's
    supplement-prefix peel wrap a second layer, while the stored twins keep
    ONE level. `Builder#build_ballot_supplement` assembles the single
    amendment layer and nests the rest (prefix, copublishers, the base's
    own `type_with_stage` — the `TR` of `PDAM TR 9573-11` — and
    `number_with_part`/`date`) as `:base`.
  - **`ballot_number` is space-bounded on both sides** (mandatory trailing
    space in the grammar group) so `PDAM 19973-2` cannot read 19973 as the
    ballot number: with no second space the group backtracks and 19973
    stays in `second_part`. This is the base-whole guard — the IEC-flavor
    hazard (#693's `ensure_base`) of a base part migrating into the
    supplement slot cannot happen here; the legacy slash-part of
    `FPDAM 9075/1` stays a base part (`9075-1`).
  - **The number precedence is TYPE token → on-base stamp → implied "1"**;
    the stamp's number/date capture as `ballot_stamp_*` while its token
    letters match UNCAPTURED (Option B keeps no spelling — the ballot's
    stage is the TYPE token's). The implied 1 is the owner's no-number
    rule, applied by `Builder#apply_implied_amendment_number` on EVERY
    builder path (parse, URN, bundle members) for `Identifiers::Amendment`
    with a nil number and `typed_stage.code` ∈ `{pdam, damd, fdamd, fpdam}`
    — by `#code`, NOT `#stage_code` (PDAM's stage_code is `:cd`), and
    `to_sym`-ed (the bound map delivers strings). The published stage
    (abbr `Amd`) is out of scope: a numberless `ISO 1234/Amd` stays nil.
  - **The `Am` spelling** joined `typed_stages_supplements` (after the Amd
    entries) and the published stage's abbr list, so `/Am1:2006` parses as
    an alias of `/Amd 1` through the EXISTING supplement branch and the
    ballot stamp accepts it the same way. `detect_stage_format_long` now
    treats an original spelling that is a prefix of the long abbr as the
    long family, so `Am` renders canonical `Amd`; `AMD` still renders short
    (facets keep spelling on render), `Amd.` still renders `Amd`.
  - **The decode is one-way**: parse-in only, canonical renders emit the
    on-base slash face, and a ballot face == its canonical spelling
    (original_abbr is equality-ignored). Locked by
    `spec/pubid/iso/ballot_face_decode_spec.rb` (all 13 SSOT anchors, the
    no-number rule, base-whole guards, Am alias, stored-twin agreement, and
    the website-face-vs-stored-face drift rows the SSOT §5 records).
