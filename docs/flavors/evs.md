# EVS flavor notes

- **The wrapped document is `base`, the uniform parent accessor**: EVS shipped
  with `adopted_identifier`, the name the rest of the codebase already retired.
  The rename covers the Ruby attribute **and** the serialization key, so an EVS
  row now reads `{"_type" => "pubid:evs:national-adoption", "base" => {…}}`.
  **The name is load-bearing, not cosmetic.** `Pubid::Identifier#root` walks
  `base`, so every EVS identifier used to be its own root with a nil `number`,
  and relaton keyed all of them under the empty string `""` — the index-key
  defect this repository records for wrappers in many other flavors.
  `root.number` is now the origin standard's number (`"9001"` for
  `EVS-EN ISO 9001:2015/A1:2024`, through two wrapper layers, because `#root`
  recurses). `Renderers::Annotator#emit_tokens` also walks `base`, so
  `to_s(annotated: true)` now annotates the wrapped document instead of
  returning a bare string.
  **What moved and what did not**: `to_s`, `to_urn` and the identifier classes
  are unchanged; `to_hash` changes one key name, and `to_s(annotated: true)`
  gains spans. EVS has no published `relaton-data-evs` index, so nothing stored
  needs a migration — but the **pubid-testsuite corpus rows carry the old key**
  and report `canonical hash` for all 10 EVS cases until the flavor is
  re-exported. `to_mr_string` is still `""` for EVS (pre-existing: EVS supplies
  no `mr_*` hooks).
  Locked by the "uniform parent accessor" block in `spec/pubid/evs/evs_spec.rb`.

- **`from_hash` raised on every EVS hash — a raw default, not load order
  (pubid#383)**: `Pubid::Evs::Identifier.from_hash(id.to_hash)` raised
  `Lutaml::Model::InvalidFormatError` (`undefined method 'key?' for an instance
  of Symbol`). The cause was one line in
  `lib/pubid/evs/identifiers/national_adoption.rb`:
  `attribute :type, Components::Type, default: -> { self.class.type[:key] }`.
  The default was the Symbol `:evs_en`, not a `Components::Type`. The canonical
  `to_hash` drops a default-valued attribute, so no row carries `type`. On
  `from_hash`, lutaml finds no `type` key, resolves the default, and casts it
  into the component through `Components::Type.from_hash(:evs_en)`, which
  raises. The nested cross-flavor wrapped identifier was never the problem:
  it deserializes alone through `Pubid.from_hash`.
  **The fix landed on `main` in `ea6cab30`**, which gives EVS and all six IDF
  classes a `self.class.default_type` class method returning
  `Components::Type.new(abbr: type[:short])` — the cen_cenelec shape. Nothing in
  EVS reads `type` (builder, renderer, URN generator and URN parser), and `type`
  is still absent from the hash, so nothing rendered or serialized moved.
  **The issue thread called it process-shape dependent. It is not.** It raises
  in every load order tried (plain `require`, `Pubid.eager_load_flavors!`, CEN
  loaded first, BSI loaded first), and all 10 corpus cases raised on `main`,
  not only the one row the testsuite ledger names. The exporter looked clean
  because `Conformance::Generator#round_trips?` rescues `StandardError` and
  returns `false`, so a raise there never reached the report.
  **Do not read `self.class` inside the default lambda body.** lutaml calls the
  lambda with `instance_exec` when it has an instance, but calls it plainly
  (`options[:default].call`) when it has none, and `self.class` is then `Class`.
  A `default_type` class method keeps that resolution in one place.
  **Two specs guard the bug class, and they are complementary**:
  `spec/pubid/evs/from_hash_spec.rb` greps `lib/` for the one raw spelling, so a
  copy of that exact line fails fast; `spec/pubid/component_attribute_default_spec.rb`
  **evaluates** every component-typed default of every identifier class of every
  flavor, so a raw default of any spelling or component type fails, whatever
  flavor introduces it. Its `PENDING_RAW_DEFAULTS` table is empty today; an
  entry that starts to pass turns red, which is the signal to delete it.
