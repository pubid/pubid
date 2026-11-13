# JIS flavor notes

## WES lives in the JIS flavor (relaton-jis#18)

- WES (Japan Welding Engineering Society) ids — `WES 7700-1:2019`,
  `WES 7301:2020R` — parse as `Identifiers::WeldingEngineeringStandard`
  (`_type: pubid:jis:welding-engineering-standard`). JSA Webdesk sells WES next
  to JIS and relaton crawls both into one `relaton-data-jis` index, so a
  separate `Pubid::Wes` flavor was rejected.
- **Grammar**: `data/parg/jis.json` is `identifier = wes_identifier /
  jis_identifier`. The WES branch is `"WES" space number parts …` with the same
  tail as JIS (year, `R`, language, 規格群, supplements, SYMBOL) and binds a
  `wes` capture, which the builder keys on. `JIS WES 7700` and `WES X 7700`
  are rejected: the JIS prefix and a series letter belong only to JIS.
- **The artifact is vendored, not baked here.** `data/parg/jis.json` is a
  verbatim copy of pubid/pubid-grammar `artifacts/jis.json` (main `31fb965`,
  parsanol **1.3.121**). Change the grammar there and copy the artifact back;
  `spec/pubid/jis/parg_reaffirmed_spec.rb` pins its `source_hash`, so a local
  rebake fails that spec.
- **`reaffirmed` binds the whole run of R's** (`":1997R"` → `"R"`, `":1997RR"`
  → `"RR"`; same for `amd_reaffirmed`/`corr_reaffirmed`). The builder reads
  each only for truth (`true if data[:reaffirmed]`), so `RR` renders as `R`.
- **`series` is nil** for WES (JIS keeps its `""`-coerced String), so the hash
  carries no `series` key. `number` is the bare number (`"7700"`), the index
  key.
- **"WES" is the root, not a publisher**: `publisher_prefix` is nil, `code`
  is `"WES 7700-1"`, so `to_s(with_publisher: false)` still prints `WES …`,
  also as the base of a supplement. The URN is `urn:jis:WES 7700-1:2019`;
  `UrnParser` does not prepend `JIS ` to a code that starts with `WES `.
- `PREFIXES` includes `"WES"`, so `Pubid.parse("WES …")` routes to JIS.

## WES `(E)` before the year, `WES TR`, `WES TS` (relaton-jis#18)

- JSA Webdesk lists 14 WES ids that the grammar does not read:
  `WES 1112(E):2022`, `WES TR 2032:2024`, `WES TS 2816(E):2015`.
- **A Ruby shim reads them, not the grammar.** `Parser.ingest` cuts
  the `TR`/`TS` token and a `(E)`/`(J)` that comes before `:year`, and
  binds them as `wes_type` and `wes_language`. Other input passes unchanged.
  The hand-off `pubid__pubid-grammar__jis-wes-language-tr-ts` asks
  pubid-grammar to bind the same two captures. After that lands, re-vendor
  `jis.json`, re-pin `parg_reaffirmed_spec.rb`, and delete the shim. The
  builder does not change.
- **`WES TR`/`WES TS` are classes**: `WeldingEngineeringTechnicalReport`
  and `…TechnicalSpecification` < `WeldingEngineeringStandard`, with
  `WES_TYPE` in `code` (`WES TR 2032`) and in `mr_type`. Class-strict `==`
  keeps them apart from `WES 2032` and `JIS TR Z 2032`.
- **`language_before_year`** records where the source put the language. It
  is spelling only (`equality_ignored`, a `langfirst` facet in the pubid
  URN): `WES 1112(E):2022 == WES 1112:2022(E)`, and each renders as written.
  The language itself is identity, so the `(E)` edition is not the Japanese
  one. JIS ids never set the flag; `JIS X 0208(E):1997` still fails.
- The pubid URN schema now places `language` and the supplement ordinal
  (`core: [["number", :int]]`; an `EXPL` number is the atom `n`). Before,
  every `(E)` id and every supplement raised in `to_pubid_urn`, and no
  supplement was in the fixture corpus to show it.
- **`Builder` reads both parse shapes.** The typed bindings
  (`Parg::Model.bound`) carry a supplement flat (`amd_type`, …); the raw
  tree (`Parg::Backend.parse`) nests it under `:amendment`/`:explanation`/
  `:corrigendum`. `flatten_supplement` folds the nested form. Before, the
  tree path dropped every supplement silently (`…/AMD 1:2000` built as the
  bare base). `typed_binding_parity_spec.rb` found it when the first
  supplement entered the pass corpus.
- **The shim lives in `Parser.ingest`** and returns `[face, bindings]`.
  `typed_binding_parity_spec.rb` calls it on the tree path too and merges
  the bindings, as `Identifier.parse` does.

## Equality includes the class

- `Identifier#==` requires `other.instance_of?(self.class)`: `JIS TR X
  0014:1999` is not `JIS X 0014:1999` (3 such pairs are in the published
  index), and `WES 7700` is never a JIS standard. `#matches?` follows, since it
  compares `exclude(…)` results with `==`.
- `SupplementIdentifier#==` also compares `symbol` and `reaffirmed?`:
  `…/AMD 3:2025R SYMBOL 65700` is not `…/AMD 3:2025`.
- The all-parts match is `===` (`Pubid::AllParts`), not `==`, and is
  unchanged.
