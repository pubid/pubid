# IHO flavor notes

- **Series publications carry a year, or a volume and issue, instead of a
  version (relaton#407)**: IHO P-5 (Yearbook), P-6 (Assembly proceedings) and
  P-7 (Annual Report) are series with no edition, and P-1 (International
  Hydrographic Review) is a journal. relaton-data-iho gave them the placeholder
  edition `1.0.0`, so `IHO P-5 1.0.0` named no real document. The identifier
  now ends in **exactly one** optional tail: a dotted `version`
  (`IHO S-44 5.0.0`), a four-digit `year` (`IHO P-5 2024`), or
  `Vol. {volume}[ No. {issue}]` (`IHO P-1 Vol. 30 No. 1`). The three new
  values are plain `:string` attributes on `Pubid::Iho::Identifier`, so every
  series type has them; no per-series type exists, by the relaton
  maintainer's decision. A nil value is a wildcard for `===`, so `IHO P-5`
  matches every year and relaton picks the latest; do not make them
  `subset_strict`.
  **The one-tail rule is in the grammar** (`[version / year / volume]` in
  `data/parg/iho.json`), so `IHO P-5 2024 1.0.0` and `IHO P-5 24` raise.
  `version` is tried first and needs dots, so `2024` falls through to `year`.
  **`IHO P-1/30` keeps parsing as number `"1/30"`.** The published data prints
  IHR volumes that way; the grammar does not reinterpret `/30` as a volume,
  because relaton-data-iho re-keys those records itself.
  **`year` is a declared attribute, so the shared code needs no override**:
  `exclude(:year)` nils it, the `date`→`year` folding of `from_hash` is
  skipped, and `to_hash` emits a bare `"year"` only when it is set. A row
  written before these keys existed loads unchanged.
  **URN segments are tagged** (`urn:iho:p:5:y.2024`, `urn:iho:p:1:vol.30:no.1`)
  so they cannot be read as the untagged version. `UrnParser` reads any number
  of tagged segments through `TAG_LABELS`, and refuses an untagged segment
  that is not a dotted version: the number may hold an unescaped colon
  (`IHO S-158:100`), so `urn:iho:s:158:2024` must raise, not decode to the
  year 2024 of `IHO S-158`. The renderer and the generator
  walk one `SEGMENTS` table each, so a new tail is one table row in each file.
  **The grammar source is the `source` field of the artifact.** To change it,
  extract that field to a `.parg` file, edit it, then
  `parsanol _1.3.114_ parg compile <file> -o data/parg/iho.json`, and confirm
  with `parsanol _1.3.114_ parg check --source <file> --artifact data/parg/iho.json`
  (the version must match the Gemfile pin). Keep the grammar `test` block in
  step: it holds the accept/reject cases above.
  **`all_parts_edition_keys` adds `volume` and `issue`** (the 3GPP `release`
  precedent): a volume is the edition of a journal, so `to_all_parts` of
  `IHO P-1 Vol. 30` matches `IHO P-1 Vol. 31`. `year` was already a default key.
  **Known gap, not fixed here**: the MR slug ignores `year`/`volume`/`issue`
  (`IHO P-5 2024` and `IHO P-5 2025` both give `iho.5`), as it already ignored
  `version` (`S-44 5.0.0` and `6.0.0` both give `iho.44`).
  Locked by `spec/pubid/iho/series_spec.rb`.
