# IHO flavor notes

IHO (International Hydrographic Organization) identifiers: the
S/P/M/B/C letter series, their parg-driven parse, and the series
components introduced for relaton/relaton#407.

Read this before you change `lib/pubid/iho/` or `spec/pubid/iho/`. The
root `CLAUDE.md` keeps the cross-flavor contract that every flavor
obeys.

## Parsing runs on the parg artifact

There is no `parser.rb` and no Parslet anywhere in this flavor: parse
goes `Pubid::Parg::Backend.parse(:iho, ...)` over the baked artifact
`data/parg/iho.json`. The artifact is baked from the flavor grammar
source `grammars/iho.parg` in the pubid-grammar repository (commit
840b2b1d "Retire the last live Parslet parsers" ports the original
13-rule Parslet grammar byte-identically).

**Drift warning:** the artifact on this branch carries the
relaton/relaton#407 tail rules (year / volume / issue), while the
checked-in `grammars/iho.parg` in pubid-grammar still has only the
version tail. Until the updated grammar source lands in pubid-grammar,
the artifact is ahead of its source and not reproducible from it —
the same artifact-ahead-of-source state the root notes describe under
grammar-artifact drift. Do not re-bake from the stale source, and do
not hand-edit the artifact; land the grammar first.

## Series components (relaton/relaton#407)

The B-7, P-1, P-5, P-6 series are continuously updated publications
whose trailing component is not an a.b.c edition: P-5/P-6 (and B-7)
are identified by **year**, P-1 (the International Hydrographic
Review) by **volume** with an optional **issue**. The grammar tail
picks exactly one discriminator, so only one of `version` / `year` /
`volume` is ever present, with `issue` only beside a volume:

- `IHO P-5 2024` — year is a plain `:string` scalar, 19xx/20xx only
  (`IHO P-5 1850` and the two-segment `IHO B-12 3.0` reject).
- `IHO P-1 Vol. 30 (2)` — volume/issue scalars; `Issue 2` is an input
  alias whose canonical print is `(2)`.
- `IHO S-44 5.0.0` — the dotted `version` stays for the edition-bearing
  series and legacy `1.0.0` placeholder rows.

All three are ordinary lutaml attributes mapped through the flavor's
`key_value` block — no converters, no hand-rolled serialization.

**Identity semantics:** the components are identity-bearing in `==` /
`matches?`; a bare reference (`IHO P-5`) leaves all four nil and
wildcards the series (`spec/pubid/partial_ref_spec.rb` locks the
omitted-key set). The volume/issue pair is a scalar **cluster**:
`exclude(:volume)` nils the issue with it, so a reference that omits
the issue still matches a hit that carries one — the same
additive-alias shape the base applies to `:year -> :date`. A lone
scalar `:year` needs no override; the base nils a declared `:year`
directly.

**`all_parts_edition_keys` needs no override:** the default
`%i[date year edition version]` already covers `:year` and `version`,
and volume/issue only ride part-less ids, which cannot join
`AllParts` (`validate_member!` demands a `part`). The audit case in
`spec/pubid/all_parts_edition_keys_audit_spec.rb` covers the
version-bearing S-series collapse.

**URN conventions:** only the dotted `version` is an untagged
segment. A year is tagged `y.N` (`urn:iho:p:5:y.2024`); a volume is a
`vol.N` segment with an optional `issue.N` segment after it
(`urn:iho:p:1:vol.30:issue.2`). The URN parser walks the tagged
segments as a run and hands the rebuilt text back through the flavor
parse, so a URN round-trip exercises the same grammar as a string.
**The number is not escaped and can hold a colon** (`IHO S-158:100`
gives `urn:iho:s:158:100`), so the parser joins every untagged segment
that is not an a.b.c version back into the number. That is why the
year must carry a tag: with the bare year that pubid 2.0.2 emitted,
`IHO S-158:2024` and `IHO S-158 2024` both gave `urn:iho:s:158:2024`,
and no colon number round-tripped at all. A 2.0.2 year URN such as
`urn:iho:p:5:2024` now decodes as the number `5:2024`; it was emitted
only by 2.0.2. A tagged segment with an unknown tag raises
`Pubid::Errors::UrnParseError`.

## Fixtures run through the classify pipeline

`spec/fixtures/iho/identifiers/full/identifiers.txt` is the input
corpus; `rake "validation:classify[iho]"` regenerates `pass/` and
`fail/` from it (the classifier deletes pass/fail first — never edit
them by hand, edit `full/` and reclassify). Before the relaton#407
branch the pass files were hand-curated with **no** `full/` tree, the
OASIS hazard: a classify run would have wiped 131 entries and rebuilt
nothing. The classifier's per-flavor class detection has an `iho`
case, so fail entries land in a named class file.

## relaton-side follow-ups (not this repo)

relaton/relaton#407 items 3-4 stay open on the relaton side:
`Relaton::Iho::Bibliography#pubid_match?`/`version_key` need the new
component, relaton-cli's `MachineIndex::REFINABLE_KEYS` needs
`year`/`volume` beside `version`/`edition`, and the pubid pin bumps
in step with the relaton-data-iho re-key.
