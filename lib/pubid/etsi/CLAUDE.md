# ETSI flavor notes

ETSI index key, part exclusion and MR slug.

These notes were part of the root `CLAUDE.md`. Read them before you change `lib/pubid/etsi/` or `spec/pubid/etsi/`. The root file keeps the cross-flavor contract that every flavor obeys.

## From the root note "ETSI and OIML index key (`root.number`): the `code` component became flat leaf columns"

**(3) `exclude(:part)` needed an override.** With `parts` a real collection attribute the base `#exclude` reaches it and nils it — but a part-less reference parses with `parts` defaulting to `[]`, so `nil != []` would break `==` and therefore `#matches?` against exactly the reference the exclusion exists to match. `Pubid::Etsi::Identifier#exclude` resets it to `[]` after `super` (the "reset the WHOLE cluster" rule from CSA's year and IEEE's year/month/day); this also covers supplements, since the base recurses into the nested `base` through `exclude_from_nested`. The old `exclude_from_nested` `Components::Code` special-case was deleted as dead. **(4) The ETSI MR slug was rewritten, and this is the loud part of the change.** ETSI defined no `mr_*` hooks, and the base ones read the inherited `number`/`part`/`typed_stage`/`edition` — all nil for ETSI — so **every** ETSI slug was `etsi.<date>`: **454 distinct slugs for 24,724 documents**, 794 of them sharing `etsi.2018-07`, and `to_slug` is what consumers use as an output **filename**. `EtsiStandard` now supplies `mr_number_with_part` (number + `parts`), `mr_type` (the ETSI type token) and `mr_edition` (the `version`) — all four fields ETSI's `==` compares, per the rule that an identity-bearing marker must reach **every** identity surface, not just `==`. `SupplementIdentifier` gained `mr_supplement_suffix` so the shared renderer **recurses into `base`** instead of slugging the supplement flat off its own ordinal (which made every `/C1` corrigendum of one month share `etsi.1.<date>`) — the ITU `AnnexOfRecommendation` precedent. A shared **`mr_sanitize`** filters **by charset** (`[^a-z0-9-]` → `-`), not by an enumerated escape list: an ETSI number legitimately contains a **space** (`300 175`, `GSM 02.01`), which is outside the `[a-z0-9.-]` charset `Renderers::MrString` documents, and a dot inside a segment would break that renderer's `.`-joined segment structure (the BIPM `bipm.si-brochure.9e-v3-01.e` precedent). Result: **24,724 distinct slugs for 24,724 ids, 0 collisions, 0 unsafe characters.** OIML's MR is **unchanged** — it already had its own `mr_number_with_part` reading through `code`, which the derived reader keeps working.

## Subset match: strict attributes

Read `docs/SUBSET_MATCH.md` first. `===` reads a nil part of the reference as
a wildcard, which is wrong for the attributes below: the flavor models a nil
value as "this document has none". They are declared with `subset_strict`, so
`===` compares them exactly and a stated collection is not a prefix. A caller
that does want every part of a document sets `all_parts` on the reference, or
keeps `#matches?(other, ignore:)`.

- **`parts` is strict**, on the leaf `EtsiStandard` and on
  `Etsi::Components::Code`. A stated part list is not a prefix, so
  `ETSI TS 129 198-4 === ETSI TS 129 198-4-5` is false. This was the
  largest case relaton measured: over 10,595 bare type+code queries the
  matched set changed for 158 and the `best_match` winner for 122, and
  `ETSI TS 129 198-4` resolved to `-4-5`.
- The declaration sits **on the leaf**, beside the flat columns and for the
  same reason — `EtsiStandard` owns `number`/`minor`/`parts`, while the
  shared `Pubid::Etsi::Identifier` is also `SupplementIdentifier`'s parent.
  `Etsi::Components::Code` carries the same declaration although `===`
  cannot reach it today (`#code` is a derived reader, not an attribute), so
  the two shapes cannot drift.
- `SUBSET_PAIRS["etsi"]` in `spec/pubid/subset_match_spec.rb` moved from
  `ETSI EN 300 175` to `ETSI EN 300 175-1`: the reference now states its
  part, and the version and the date are what it omits.
