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

