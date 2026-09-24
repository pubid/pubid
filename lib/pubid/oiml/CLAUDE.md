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

## Subset match: strict attributes

Read `docs/SUBSET_MATCH.md` first. `===` reads a nil part of the reference as
a wildcard, which is wrong for the attributes below: the flavor models a nil
value as "this document has none". They are declared with `subset_strict`, so
`===` compares them exactly and a stated collection is not a prefix. A caller
that does want every part of a document sets `all_parts` on the reference, or
keeps `#matches?(other, ignore:)`.

- **`part`, `subpart` and `suffix` are strict**, so `OIML R 138` does not
  match `OIML R 138-Amend:2009`, which is its amendment, and
  `OIML R 137-1 (F)` does not match `OIML R 137-1-2:2012 (F)`, which names a
  subpart it doesn't. The declaration rides the `Identifiers::CodeNumber`
  mixin (`lib/pubid/oiml/identifiers/code_number.rb`), so it reaches all
  seven leaves that install the columns; `Bulletin`, which does not include
  the mixin, is unaffected. `Oiml::Components::Code` carries the same
  declaration for the shapes not to drift, although `===` does not reach it
  today.
- **`language` is strict**, declared separately on `SingleIdentifier` and
  `SupplementIdentifier` (each declares its own `language` attribute), so
  `OIML R 126:2015 Errata` does not match `OIML R 126:2015 Errata (E)`, its
  English edition. It could not be declared once on the shared `Identifier`
  ancestor: `spec/pubid/subset_match_spec.rb`'s "names only attributes the
  class declares" check requires every `subset_strict` name to be a real
  attribute on the declaring class, and `Identifier` itself declares neither
  `language` nor `letter`.
- **`Annex#letter` is strict**, so `OIML R 102 Annexes` (no letter — the
  plural form) does not match `OIML R 102:1995 Annex B-C`, which names one.
  Found in review alongside the `language`/`subpart` work above: same bug
  shape, on the one OIML attribute besides `language` that names a specific
  sub-document and had no `subset_strict` declaration.

## Subset match: ignored render flags

`parsed_format` (`SingleIdentifier`/`SupplementIdentifier`), `year_on_base`
(`Annex`), `space_suffix` (`CodeNumber` mixin / `Components::Code`),
`trailing` and `joined` (`SupplementIdentifier`) are Boolean or string
attributes with a non-nil default that record which of two equivalent input
spellings a reference used (short vs long format, dash- vs space-separated
suffix, trailing-word vs prose supplement form, year glued to the base vs to
the marker) — never something the document itself states. Left alone, their
non-nil default reads as "stated" to `===` even in a bare reference (the
CSA/IEEE year-format trap `docs/SUBSET_MATCH.md` describes), which is why
`OIML R 102 Annex B-C === OIML R 102:1995 Annex B-C` used to disagree with
relaton's own OIML match on `year_on_base` alone. They are listed in
`Oiml::Identifier.subset_ignored_attributes` (`lib/pubid/oiml/identifier.rb`)
as one shared list on the flavor's common ancestor: a name that isn't an
attribute of a given leaf (e.g. `year_on_base` only exists on `Annex`) is a
harmless no-op there, since `===` only walks `self.class.attributes`.

**Measurement that drove this** (hand-off
`metanorma__pubid__oiml-subset-match-strict-language.md`): relaton compared
`===` against its own OIML match over the full 5,646-row `relaton-data-oiml`
index (4.57M pairs) and found 192 disagreeing pairs outside the Bulletins —
156 on `language`, 6 on `subpart`, 30 on `year_on_base` — all wrong on the
`===` side before this branch.

## Dual-published identifiers: OIML co-publication with another SDO (pubid #437)

**The shape.** OIML sometimes co-publishes a document jointly with another
SDO — ISO confirmed so far. The printed reference carries both identifiers,
joined by a bare `|`, e.g. `ISO 4064-1:2024|OIML R 49-1:2024`. Both sides
name the same document, each in its own SDO's scheme.

**`Identifiers::DualPublished` is a THIRD sibling** of `SingleIdentifier`/
`SupplementIdentifier` under `Oiml::Identifier` — same shape as
`SupplementIdentifier`, and the same lesson applies: it inherits **nothing**
from `SingleIdentifier`, so every identity-bearing reader `UrnGenerator` or
the MR-slug renderer calls (`code`, `type`, `stage`, `iteration`,
`publisher`, and the `mr_publisher`/`mr_type`/`mr_number_with_part`/
`mr_year` hooks, plus `#root`) is hand-delegated to whichever side is OIML.
Without the `mr_*` delegations this class would have shipped with the exact
same empty-slug gap already recorded above for Amendment/Errata/Annex; this
class closes it from day one instead of reproducing it.

**`first`/`second` hold the two sides in original left-to-right print
order**, each a real `attribute ..., ::Pubid::Identifier, polymorphic: true`
— never an `attr_accessor` (see IEEE's `CsaDualPublished`, which used one
and silently dropped its second identifier from `to_hash`/`from_hash`/
`#exclude`). `#oiml_identifier`/`#external_identifier` pick the OIML-typed
member out of the pair by `is_a?`, not by position, since nothing guarantees
which side prints first.

**`language`/`parsed_format` are declared locally even though this class
never sets them.** `Oiml::Identifier`'s shared `key_value` block (inherited
by every OIML class) maps `"language"` and `"parsed_format"` to real
attributes; a subclass's own `key_value` block **merges** with its parent's
rather than replacing it, so `to_hash`/`from_hash` would call
`model.language`/`model.language=` regardless of what this class declares.
Leaving them undeclared would crash `to_hash` outright (no such method);
delegating `language` as a read-only method would crash `from_hash` (no
setter). `SingleIdentifier` and `SupplementIdentifier` both declare these
locally for the same reason — this class follows the same pattern rather
than inventing a new one.

**Parse dispatch lives in `Pubid::Oiml.parse`/
`Identifiers::DualPublished.build`, not the Parslet grammar.** The string is
split on `|` before the grammar ever runs; the side that matches `PREFIXES`
(`["OIML"]`) is parsed via `Oiml.parse` (re-entering this same module
method — safe, since the substring has no `|`), the other via the generic
top-level `Pubid.parse`, which auto-routes to any flavor by prefix. `.build`
returns `nil` for anything that isn't exactly two non-empty sides with
exactly one OIML side, letting the caller fall through to the ordinary
grammar — which has no `|` rule, so it raises the standard
`Parslet::ParseFailed`, keeping the uniform parse-error contract intact. The
side is detected by content, not position, so `OIML R 49-1:2024|ISO
4064-1:2024` parses identically in the other order.

**The URN represents only the OIML side** (`urn:oiml:...`) — there is no
joint URN scheme anywhere in this codebase, matching every other
cross-flavor wrapper (IEEE's `AdoptedStandard`/`MultiNumberedIdentifier`).
One generator change was required: `UrnGenerator::Base#urn_year` gates on
`identifier.class.attributes.key?(:date)`, and `DualPublished` declares no
`date` of its own (it lives on whichever side is OIML) — so
`Oiml::UrnGenerator#urn_year` special-cases the class and reads the date
through `#oiml_identifier` directly. Every other URN segment
(`urn_type`/`urn_number`/`urn_stage`/`urn_iteration`/`urn_language`) works
for free through the §1 delegations, since they already read plain
`identifier.type`/`.code`/etc. rather than going through the attributes
registry.

**`(de)serialization goes through `Pubid.from_hash`/`#to_hash`, not the
OIML-scoped `Identifier.from_hash`**, because either side of `first`/
`second` may belong to any flavor — `Identifier.from_hash` only resolves
OIML `_type` values. Verified this round-trips both an OIML-native nested
hash and a foreign one via the shared global `TypeResolver`.

**Known, deliberately out-of-scope gaps**, matching the issue's one
confirmed example (a plain `Recommendation` on the OIML side, no edition):

- An OIML side that is itself a Amendment/Annex/Errata
  (`SupplementIdentifier`) is untested — the delegation chain should mostly
  work transitively, but this hasn't been exercised.
- Only two-way co-publication is modeled (two fixed attributes), not
  three-or-more.
- **`edition` is not delegated**, unlike `code`/`type`/`stage`/etc. This is
  deliberate, not an oversight: OIML's own `edition` is a plain `:string`
  attribute (`SingleIdentifier`), but the shared `#mr_edition`/`#urn_edition`
  (`lib/pubid/identifier.rb`, `lib/pubid/urn_generator/base.rb`) assume the
  `Components::Edition` shape and call `edition.number` — a **pre-existing**
  bug in OIML itself: `Pubid::Oiml.parse("OIML E 5 6th Edition 2015
  (E)").to_mr_string` already raises `NoMethodError` on `main`, with no
  `DualPublished` involved. Delegating `edition` here would only reproduce
  that crash through a second path; leaving it undelegated means an
  edition-bearing OIML side silently drops its edition from the MR slug/URN
  instead of raising — worse data loss, but no new crash surface. Fixing the
  root cause (OIML's edition/MR-edition type mismatch) is unrelated to
  dual-published identifiers and is left for its own change.
- **Annotated rendering (`to_s(annotated: true)`) only spans the OIML
  side's publisher/type**, not its number/year, and not the external side at
  all. This matches — not regresses — the existing shipped behavior of the
  closest precedent, IEEE's `Identifiers::AdoptedStandard`: `Renderers::
  Annotator#nested_identifiers` (`lib/pubid/renderers/annotator.rb`) only
  recurses into `base`/`ids`/`identifiers`/`bundled_with`, none of which
  `DualPublished` (or `AdoptedStandard`, which uses `ieee_identifier`/
  `adopted_identifiers`) uses, so neither wrapper's nested sides get full
  token annotation. The uniform contract this repo enforces is narrower than
  full annotation: every `to_s` must **accept** `annotated:` without
  raising, which this class does (verified by a spec). Widening
  `Annotator#nested_identifiers` to close this for every such wrapper at
  once is a separate, cross-flavor change.
