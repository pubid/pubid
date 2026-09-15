# OIML flavor notes

OIML index key, bulletins and supplement URNs.

These notes were part of the root `CLAUDE.md`. Read them before you change `lib/pubid/oiml/` or `spec/pubid/oiml/`. The root file keeps the cross-flavor contract that every flavor obeys.

## From the root note "ETSI and OIML index key (`root.number`): the `code` component became flat leaf columns"

**(5) OIML `Bulletin` is the one leaf with no code** (its locator is the year/issue/sequence tuple), so it deliberately does **not** include `CodeNumber`. Its key was first the year, as a derived reader; it is now the issue, stored as `number`. The section "Bulletin: the issue is the `number`" below records why. **(6) A pre-existing OIML crash closed in passing**: `Pubid::Oiml::SupplementIdentifier` descends from `Oiml::Identifier` **directly** — it is a *sibling* of `SingleIdentifier`, where `code` and `iteration` live — while `UrnGenerator` reads both unconditionally, so `to_urn` **raised `NoMethodError`** for every Amendment/Errata/Annex (confirmed on the `main` baseline: all five supplement fixtures already raised). Two delegations (`code`/`iteration` → `base&.…`) fix it. **Two gaps deliberately left open and pinned** by expectations in `root_number_spec.rb` that assert the *current* behaviour, so a future fix must flip them: the OIML URN encodes no supplement marker, so an annex, an amendment and their base share one URN (the documented ITU supplement-URN shape); and a supplement inherits none of `SingleIdentifier`'s `mr_*` hooks, so **every** OIML supplement still slugs to `""` — a filename collision, unchanged from `main`. (follow-up hand-off: oiml-supplement-identity-surfaces.)

## Bulletin: the issue is the `number`

**The problem.** The first design derived `Bulletin#number` from `date&.year` as a reader, and did not serialize it, so that `year` did not repeat in each row. The runtime key was correct: relaton keys on `root.number.to_s`, and 4133 of the 4134 Bulletin rows of the published `relaton-data-oiml` `index-v2.yaml` keyed on their year. But a scan of the raw YAML reported **4134 rows with no `number`**, and a reader of the index could not see the key.

**The change.** The year is the volume and the issue is the number, as in the citation form `LXVII(2)`. So the attribute `issue` became `attribute :number, :string`, mapped as `"number"`, and the derived year reader was deleted. Nothing new is stored: the value moved from the `issue` key to the `number` key. No `issue` method remains, and the constructor refuses an `issue:` key: in Ruby and in the hash, the name is `number`. The attribute is declared on the Bulletin **leaf**, which has no subclasses, so the multi-flavor determinism landmine does not apply (the `CodeNumber` pattern).

**No legacy read.** pubid does not read the old `issue` key, by decision. lutaml ignores a key that no attribute maps, and it raises no error. So an old row loads WITHOUT its issue and becomes a different identifier: `{year: "1960", issue: "03", sequence: "01"}` renders as `OIML Bulletin 1960-01`, with URN `urn:oiml:bulletin:1960-01` and no index key. The published `relaton-data-oiml` `index-v2.yaml` must therefore be crawled again when this change is released, before relaton uses it for a Bulletin lookup.

**The trade-off, measured on the 4134 published Bulletin rows:**

- Rows with no `number`: 4134 → 68. These are the 67 volume rows (`OIML Bulletin 1960`) and the bare `OIML Bulletin`, which name no issue. Their key is `""`, and they share one bucket.
- The largest bucket: 112 → 1215. The key puts the same issue number of all volumes together (all `01` issues), so relaton's filter reads more rows after the binary search. The binary search stays valid.
- The MR slug does not change (`oiml.bulletin.03-01.1960`): `mr_number_with_part` emits `number`-`sequence` and not the year, which `Renderers::MrString` gives its own segment. The slug keeps each article distinct.

**Verified** by replaying a baseline captured on `main` over all 5646 published rows (each Bulletin `issue` key renamed to `number`, as a new crawl writes it) and every OIML fixture: `to_s`, `to_urn`, `to_mr_string` and the class are identical; a Bulletin `to_hash` differs only by `issue` → `number`; `from_hash(to_hash) == id` did not change for any entry. Locked by the "Bulletin keys on its issue" block of `spec/pubid/oiml/root_number_spec.rb`.

**Relaton note (not caused by this change).** `Relaton::Oiml::Bibliography#pubid_match?` compares `exclude(:year, :language).to_s`. For a Bulletin that string is `"OIML Bulletin"` for every article, so a query can return a different article of the same year (hand-off `relaton__relaton__oiml-bulletin-pubid-match`).
