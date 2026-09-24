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
