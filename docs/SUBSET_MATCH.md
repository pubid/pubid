# Subset match: `reference === candidate`

`Pubid::SubsetMatch` (`lib/pubid/subset_match.rb`) gives every identifier and
every component a subset match. The match is true when the candidate holds
every part that the reference states. A nil or empty part of the reference is
a wildcard.

```ruby
Pubid::Iso.parse("ISO 9001") === Pubid::Iso.parse("ISO 9001:2015")   # => true
Pubid::Bsi.parse("BS 7273-4+A1") === Pubid::Bsi.parse("BS 7273-4:2015+A1:2021") # => true
```

## Why it exists

`#matches?(other, ignore:)` makes the caller name the parts to ignore. relaton
does not know which parts the user omitted, so it had to guess an `ignore:`
list for each flavor. `===` reads the omission from the reference itself.

**relaton note:** `Bibliography` matching can call `reference === row_id`
instead of an `ignore:` list. Nothing breaks until relaton opts in. `#matches?`
and `#exclude` stay. The hand-off `exclude-recursion-depth` loses most of its
pressure, because reference matching no longer goes through `#exclude`.

## Rules (decided)

- **Not symmetric.** The receiver is the reference. Ruby calls `===` for `case`
  and `grep`, so `catalogue.grep(reference)` works. RSpec fuzzy matchers and
  mock argument matchers also call it when `==` is false; use `eq` for exact
  equality in a spec. A suite run with an instrument showed that no spec
  outside `spec/pubid/subset_match_spec.rb` reaches `===` today.
- **Identical classes** (`instance_of?`). A bare `BS 7273-4` does not fall back
  to the `#base_document` of `BS 7273-4:2015+A1:2021`. `#base_document` is not
  uniform across flavors, so a fallback belongs to relaton.
- **A default value is stated.** `ISO 9001` is the published stage, so it does
  not match `ISO/DIS 9001` or `ISO 9001 (all parts)`.
- **Collections match by position**, and the reference can be shorter:
  `ISO/IEC 9001` matches `ISO/IEC/IEEE 9001`; `ISO/IEEE 9001` does not.
- `#==` does not change. An error from an attribute reader propagates.

## Why it walks objects, not `to_hash`

The hand-off prototype compared `to_hash` subsets. The chosen design walks the
attributes, so each class can own a rule. The measurement matters:

- A generic object walk failed `parse(s) === from_hash(parse(s).to_hash)` for
  740 of 9,175 sampled ids. An attribute that `to_hash` does not serialize is
  lost on the index row: NIST `first_number`/`second_number` (610), IEC
  `WorkingDocument` fields (111), ISO `original_abbr`.
- A `to_hash` subset failed 12. But the hash view is blind in the other
  direction: IEC `1/2457/FDIS` serializes to `{"_type"}` alone, so a hash subset
  matched every working document to every other one.

The object walk plus a few hooks gets both right.

## Hooks

Both hooks go on the class that owns the attribute:

- `self.subset_ignored_attributes` — attributes that `===` skips.
- `#subset_attribute_match?(name, mine, theirs)` — decides one attribute; call
  `super` for the others. The receiver is the reference.

In use:

| Class | Hook | Reason |
|---|---|---|
| `Nist::Identifiers::Base` | ignores `EQUALITY_IGNORED_ATTRS` | the build artifacts that `==` also skips; not serialized |
| `Components::TypedStage` | ignores `original_abbr` | input spelling (`Amd`/`AMD`) |
| `Itu::Identifiers::Supplement` | ignores `number_glued`, `slash_joined`; skips `sector`/`series`/`code`/`series_word` when `base` is set | mirrors its `==`: rendering flags, and unserialized copies of `base` |
| `Oasis::Identifier` | ignores `original` | verbatim slug; its `#exclude` clears it for the same reason |
| `Csa::SingleIdentifier` | skips the year format flags when `year` is nil, `original_reaffirmation_4digit` when `reaffirmation` is nil | default is stated |
| `Ieee::Identifiers::IecIeeeCopublished` | skips `year_sep` when `year` is nil | default is stated |

**The last two are the "default is stated" trap.** A bare `CSA C22.2 NO. 125`
has `original_year_4digit` at its default `false`, which refused
`CSA C22.2 NO. 125-M1984` until the hook existed. A format flag that has a
default, and that describes a value the reference can omit, needs a hook.

`NIST::Identifiers::Base#matches?(candidate)` is an older NIST-only form of the
same walk. Its signature does not accept the base `ignore:` keyword. `===` makes
it redundant.

## Placement

`include ::Pubid::SubsetMatch` is explicit, in `Pubid::Identifier` and in every
class that subclasses `Lutaml::Model::Serializable` directly (the 13 shared
components and about 30 flavor components). There is no `inherited` or
`prepend` hook, per the annotated-rendering lesson in CLAUDE.md.
`lib/pubid/bsi/model.rb` and `lib/pubid/itu/model.rb` are not loaded and do not
include it.

A value whose class lacks the module falls back to `==`, which is silently
strict. `spec/pubid/subset_match_spec.rb` force-loads every identifier class
and fails when an attribute type lacks the module. The example was verified to
fail with one include removed.

## Verification

Over the whole fixture corpus (100,199 ids):

- Wherever `from_hash(id.to_hash) == id`, `===` holds in both directions:
  0 misses.
- `id.exclude(:date) === id` and `=== row` hold for all 48,791 ids whose
  exclusion only removed keys.

The spec keeps the first invariant on a sample of 300 ids per flavor. It needs
no pending table: a pre-existing `==` defect is not a `===` defect.
