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

## Equality includes the class

- `Identifier#==` requires `other.instance_of?(self.class)`: `JIS TR X
  0014:1999` is not `JIS X 0014:1999` (3 such pairs are in the published
  index), and `WES 7700` is never a JIS standard. `#matches?` follows, since it
  compares `exclude(…)` results with `==`.
- `SupplementIdentifier#==` also compares `symbol` and `reaffirmed?`:
  `…/AMD 3:2025R SYMBOL 65700` is not `…/AMD 3:2025`.
- The all-parts match is `===` (`Pubid::AllParts`), not `==`, and is
  unchanged.
