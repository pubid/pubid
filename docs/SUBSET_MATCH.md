# Subset match: `reference === candidate`

`Pubid::SubsetMatch` (`lib/pubid/subset_match.rb`) gives every identifier and
every component a subset match. The match is true when the candidate holds
every part that the reference states. A nil or empty part of the reference is
a wildcard, unless the flavor declares that part **strict**.

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
- **A strict attribute is exempt from both wildcards.** The reference always
  states it, so a nil value means "this document has none" and a stated
  collection is not a prefix. See *Strict attributes* below.
- **`all_parts` is the part wildcard.** A reference that sets it matches
  every part of the document: `part`, `parts`, `subpart` and `all_parts`
  itself are skipped. `#to_all_parts` makes such a reference from any
  identifier. It returns a copy with `all_parts` true and no part; the date
  and the stage stay (`ISO 9000-1:2015` → `ISO 9000:2015 (all parts)`).
- **A partial date stays a wildcard.** A year-only reference matches a fuller
  date: `Date(2015) === Date(2015-04)`. The month and the day refine the year
  rather than naming a different document, and ISO, IEC and BSI all rely on
  it. This was decided for CalConnect, where `CC/WD 51017:2024` matches the
  row dated `2024-07-23`, and it applies to every flavor.
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

## Strict attributes

Some flavors model a nil component as "this document has none", not as "any
value". Reading it as a wildcard widens the match and the wrong record wins.
A class declares such an attribute with `subset_strict`, on the class that
owns the attribute:

```ruby
class Pubid::Ecma::Identifier < Pubid::Identifier
  subset_strict :part
end
```

A strict attribute is compared exactly. Nil and empty are one value, so an
index row that `from_hash` rebuilt from a hash without the key still matches
the parsed identifier.

| reference | candidate | result |
|---|---|---|
| `nil` | `"1"` | false — a nil value means none |
| `[]` | `["4"]` | false |
| `["4"]` | `["4","5"]` | false — a stated collection is not a prefix |
| `["4"]` | `["4"]` | true |

`subset_strict_attributes` reads the list, and a subclass inherits it.

**Exactness composes; it does not flatten.** A strict value that is itself
a component is matched in both directions with its own `===`, so the class
that owns it keeps its rule. A plain `==` would override it:
`Components::TypedStage` ignores `original_abbr` (the input spelling, `Amd`
against `AMD`) and CEN/CENELEC declares `typed_stage` strict, so a flat
comparison would read the spelling as identity. A strict collection is
compared element by element under the same rule.

In use, with the pair each flavor was losing:

| Class | Attributes | Pair that now returns false |
|---|---|---|
| `Ecma::Identifier` | `part` | `ECMA-418` vs `ECMA-418-1 ed1` |
| `Tgpp::Identifier` | `suffix`, `parts` | `TS 29.198` vs `TS 29.198-04-1`; `TR 00.01` vs `TR 00.01U` |
| `Etsi::Identifiers::EtsiStandard`, `Etsi::Components::Code` | `parts` | `ETSI TS 129 198-4` vs `-4-5` |
| `Calconnect::Identifier` | `series` | `CC 36010` vs `CC/WD 36010:2019` |
| `Gost::Identifier` | `copublisher` | `GOST R 27001` vs `GOST R ISO/IEC 27001-2006` |
| `Plateau::Identifier` | `annex` | `PLATEAU Handbook #10` vs `#10-1 第1.0版` |
| `Oiml::Identifiers::CodeNumber` (7 leaves), `Oiml::Components::Code` | `part`, `suffix` | `OIML R 138` vs `OIML R 138-Amend:2009` |
| `Ccsds::Identifier` | `language`, `suffix` | `CCSDS 650.0-M-2` vs its French translation; `CCSDS 101.0-B-4` vs `CCSDS 101.0-B-4-S` |
| `CenCenelec::Identifier` | `type`, `stage`, `typed_stage` | `EN 1325` vs `prEN 1325` |

The measurement relaton made before the declarations existed: `ECMA-418`
gained 5 part rows, 3GPP broke two committed specs, and over 10,595 bare
ETSI queries the matched set changed for 158 and the `best_match` winner for
122 — `ETSI TS 129 198-4` resolved to `-4-5`.

**Two flavors declare the same attribute twice, and that is deliberate.**
ETSI and OIML hold their identity in flat columns on the leaves and keep a
`Components::Code` that `#code` derives from them. The component is not
reachable through `===` today, because neither `code` is an attribute; the
declaration is there so the two shapes cannot drift.

## Asking for every part

Once a nil part means "none", a reference asks for the whole collection by
setting `all_parts`:

```ruby
Pubid::Iso.parse("ISO 9001 (all parts)") === Pubid::Iso.parse("ISO 9001-1:2015")
# => true

reference = Pubid::Etsi.parse("ETSI EN 300 175")
reference.all_parts = true
reference === Pubid::Etsi.parse("ETSI EN 300 175-1")   # => true
```

`all_parts` is declared on `Pubid::Identifier`, so every flavor carries it;
ISO, IEC, IDF, JIS and GB also print a form for it. `#includes?` and
`Jis::Identifier#==` already read the flag the same way. The rule is an
identifier rule: `#subset_all_parts_wildcard?` returns false in the module
and only `Pubid::Identifier` overrides it, because a component never holds a
document's parts. The other direction is unchanged — `ISO 9001` does not
match `ISO 9001 (all parts)`, because a default is stated.

`#matches?(other, ignore:)` and `#exclude` do not change, so a caller that
prefers to name the parts to ignore still can.

## Hooks

Both hooks go on the class that owns the attribute:

- `subset_strict(*names)` — attributes the reference always states; see
  *Strict attributes* above.
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
