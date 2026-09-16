# GB (Chinese Standard) flavor notes

`Pubid::Gb` covers national (`GB`), confidential national (`GBn`),
sector/industry (`JB`, `HB`, `NY`, …) and social-group (`T/{ORG}`) Chinese
standards. The mandate category follows a slash: `T` (recommended), `Z`
(guideline), or nothing (mandatory).

## A flavor `key_value` block REPLACES the base maps — list every attribute

`Pubid::Gb::Identifier` declared its own `key_value` block and mapped
`publisher_code`, `mandate`, `number`, `part` and `all_parts` — but not
`date`. lutaml does not merge such a block with the maps of
`::Pubid::Identifier`; it replaces them. So `to_hash` silently dropped the
publication year of **every** dated GB identifier:

```ruby
id = Pubid::Gb::Identifier.parse("GB/T 20223-2006")
id.to_s                                            # => "GB/T 20223-2006"
id.year                                            # => "2006"
id.to_hash                                         # no year at all
Pubid::Gb::Identifier.from_hash(id.to_hash).to_s   # => "GB/T 20223"
```

The year survived `to_s`, `exclude` and `matches?`, so nothing in the flavor's
own behaviour looked wrong. Only `from_hash(to_hash) == parse` saw it — the
silent failure mode this repository records elsewhere: `#matches?` is
`exclude(*ignore) == other.exclude(*ignore)`, so a parsed reference never
matched a `from_hash`-ed index row, and the lookup returned nothing with no
error. Two editions of one document (`GB/T 20223-2006` and `GB/T 20223-2014`)
also collapsed onto one hash.

The fix is one line — `map "date", to: :date` — because the shared flat-scalar
rules do the rest: `flatten_scalar_components` (in `Identifier#to_hash`) writes
a bare `"year" => "2006"` instead of a nested `date` component, and
`inflate_scalar_components` reads it back. GB declares no `year` attribute, so
the `date` → `year` rename applies.

```ruby
Pubid::Gb::Identifier.parse("GB/T 20223-2006").to_hash
# => {"_type" => "pubid:gb:standard", "publisher_code" => "GB",
#     "mandate" => "T", "number" => "20223", "year" => "2006"}
```

**Lesson for any flavor with its own `key_value` block**: an attribute absent
from the block does not serialize. Assert `from_hash(id.to_hash) == id`, not
only `to_s` and `to_hash` — the two shapes that were already correct here.

GB publishes no `relaton-data-gb` index, so no re-crawl follows.

## `GBn` — a lowercase letter inside the publisher token

`GBn` is the confidential national series, and the only one of the 67 prefixes
the relaton GB flavor carries that did not parse. The publisher rule accepted
`[A-Z]{1,3}`, which consumed `GB` and then stopped at the `n`.

A PEG takes the first branch that matches and does not backtrack into the
alternatives, so the `str("GBn")` branch comes **before** the uppercase-only
branch in `rule(:publisher_code)`. `GBn`, `GBn/T` and `GBn/Z` now parse, and
`GBn GBn/T GBn/Z` are in `PREFIXES`, so `Pubid.parse` routes them.

All 67 relaton prefixes now round-trip a dated identifier.

## Decision: the em dash normalizes to an ASCII hyphen

Chinese portals print an em dash before the year (`T/ZS 0467—2023`). The parser
accepts both spellings and the renderer prints an ASCII hyphen:

```ruby
Pubid::Gb::Identifier.parse("T/ZS 0467—2023").to_s   # => "T/ZS 0467-2023"
```

This is deliberate, not a defect. The two spellings give **equal** identifiers,
so a reference in either form matches the document. The alternative — a stored
separator attribute, the CIE `date_separator` shape — would make the two
spellings unequal and would need an `exclude` override. The relaton fixture
`spec/gb/fixtures/tgzaepi_001_2018.xml` records the em-dash form and is the one
place that must follow this decision.

## Known gaps

`spec/pubid/gb/fixtures_spec.rb` now reads `spec/fixtures/gb/`, which nothing
read before (the `ten-dead-fixture-specs` class). It carries a tripwire example
asserting both globs are non-empty, because a wrong glob reports 0 examples
instead of a failure. GB has no `identifiers/full/identifiers.txt`, so the
fixtures are hand-written and `rake validation:classify[gb]` does not drive
them; the reader accepts both the plain and the generated line shapes.

The URN carries the number and the year only: `GB/T 20223-2006` and
`GBn 20223-2006` both give `urn:gb:20223:2006`. The publisher code and the
mandate are lost, and there is no `Pubid::Gb::UrnParser` to read a URN back.
Nothing consumes a GB URN today, so this is recorded, not fixed.

## Not supported (deliberately)

These forms do not parse. Each is outside what the relaton GB flavor supports
today:

| form | what it is |
|---|---|
| `DB11/T 123-2020`, `DB37 1234-2020` | local standards; a province code follows `DB` |
| `Q/SY 123-2020` | enterprise standard |
| `GB/T 1.1-2020/XG1-2021` | amendment sheet (修改单) |

`PREFIXES` lists bare `DB`, `DB/T` and `DB/Z`, so the province-numbered form
was intended but is not parsed.
