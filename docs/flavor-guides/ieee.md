# IEEE identifier patterns

Ported from the archived `pubid-ieee` README ("Historic identifier patterns"),
restated against the pubid 2.0 monogem. The Type I/II pattern grammar below
describes the identifiers the flavor accepts; the live parser is the pubid 2
grammar (`lib/pubid/ieee/parser.rb`, pre-cleaned by
`lib/pubid/ieee/pre_parser.rb` and `data/ieee/update_codes.yaml`), not the
regexes — the regexes are reproduced as the pattern record.

There are two major pattern series, for historical reasons: the old
(**Type I**) and the new (**Type II**). The flavor parses both, plus two
predecessor-organization families (AIEE, IRE) and their transitional forms.

## Elements of the PubID

Publisher:: `IEEE` (Institute of Electrical and Electronics Engineers);
`ANSI/IEEE` for co-published drafts and adoptions
Report number (`{number}`):: one or more digits, optionally prefixed with an
uppercase letter and suffixed with letters (`802.11`, `C22.2`, `1613.1`)
Part (`{part}`):: digits with optional trailing letters, prefixed with `.` or
`-`; optional
Subpart (`{subpart}`):: a digit with optional letter, prefixed with `.`;
optional, several possible
Year (`{year}`):: 4 digits, prefixed with `-`, `:`, ` - `, or a comma+space;
optional
Corrigendum/Amendment (`{cor}`):: `Cor {n}-{year}` or `Amd.{n}-{year}`;
optional

## Type I pattern

```
{publisher} {type} {series} {number}{part}.{subpart}{year} {edition}/{conform}/{correction}
```

* `{publisher}` — `IEEE`
* `{type}` — one of `Standard`, `Std`, `Draft`, `Draft Standard`,
  `Draft Supplement` (optional)
* `{series}` — `ISO/IEC`, `ISO/IEC/IEEE` (optional)
* `{number}` — digits, optionally letter-prefixed/letter-suffixed
* `{part}` — 1–2 digits prefixed with `.` or `-`, optionally suffixed with up
  to 4 letters (optional)
* `{subpart}` — 1 digit optionally suffixed with a letter (optional)
* `{year}` — 4 digits prefixed with `-`, `:`, ` - `, or a comma+space (optional)
* `{edition}` — prefix `Edition` plus a bracketed reference, or prefix
  `First edition` plus a `YYYY-MM-DD` date (optional)
* `{conform}` — prefix `Conformance`, 2 digits, dash, 4-digit year (optional)
* `{correction}` — prefix `Cor` (optional trailing space) or prefix `Amd.` plus
  1–2 digits, dash, 4-digit year (optional)

An identifier can be composed of two identifiers joined by a space; only the
first needs the publisher.

The regex that parsed 100% of the type I identifiers of the archived
bibxml-ieee dataset (historic record of the pattern; the v2 grammar accepts
the same shapes):

```regex
^IEEE\s
((?<type1>Standard|Std|Draft(\sStandard|\sSupplement)?)\s)?
((?<series>ISO\/IEC(\/IEEE)?)\s)?
(?<number1>[A-Z]?\d+[[:alpha:]]?)
([.-](?<part1>\d{1,2}(?!\d)[[:alpha:]]{0,4}))?
(\.(?<subpart1>\d[[:alpha:]]?))?
(?<year1>([-:]|\s-\s|,\s)\d{4})?
(\s(IEEE\s(?<type2>Std)\s)?(?<number2>[A-Z]?\d+[[:alpha:]]?)
  ([.-](?<part2>\d{1,2}(?!\d)[[:alpha:]]{0,4}))?
  ([.](?<subpart2>\d[[:alpha:]]?))?
  (?<year2>([-:.]|_-|\s-\s|,\s)\d{4})?)?
(\s(?<edition>Edition(\s\([^)]+\))?|First\sedition\s[\d-]+))?
(\/(?<conform>Conformance\d{2})-(?<confyear>\d{4}))?
(\/(?<correction>(Cor\s?|(Amd\.)\d{1,2})
  (?<coryear>(:|-|:-)\d{4}))?$
```

## Type II pattern

The regex that covered 99% of the archived bibxml-ieee-new dataset (historic
record; the v2 grammar accepts these shapes):

```regex
^IEEE\s(?<number1>\w+(\.[A-Z]\d|\sHBK)?)
(?<part1>(\.|\s)\d{1,4}[[:alpha:],]{0,7}|-\d?[A-Z]+|-\d(?=[-.]))?
(?<subpart11>\.\d{1,3}[a-z]?|-\d{5}[a-z]?|-\d+(?=[-:_]))?
(?<subpart12>\.\d|-\d+(?=-))?
(?<year1>([-:.]|_-|\s-\s)\d{4})?
(\/(?<number2>([A-Z]?\d+[a-z]?|Conformance\d+))
  ((\.|-)(?<part2>\d{1,3}[a-z]?)(?!\d))?
  (\.(?<subpart21>\d{1,2}))?)?
(\/(?<number3>\d+)(\.(?<part3>\d))?)?
(?<year2>([-:.]|_-|\s-\s)\d{4})?
((\/|_|-|\s\/)(?<correction>(Cor|(?i)Amd(?-i))(\s|\.|\.\s)?\d{1,2})
  (?<coryear>(:|-|:-|_[A-Z][a-z]{2}_)\d{4}(-\d{4})?)?)?$
```

## Parsing in pubid 2

```ruby
require "pubid"

Pubid::Ieee.parse("IEEE Std 802.11-2020").class
# => Pubid::Ieee::Identifiers::Standard
```

Composite forms resolve to dedicated classes: `/Cor. 1-2017` to
`Identifiers::Corrigendum` (with `cor_number`, `cor_year`, `base`),
CSA dual publications to `Identifiers::CsaDualPublished` (`IEEE Std
844.1-2017/CSA C22.2 No. 293.1-17`), adoptions to
`Identifiers::AdoptedStandard` (`IEEE No 18-1934 (ASA C55 1934)` renders
`IEEE Std 18-1934 (ASA C55-1934)`), and the relationship clause to the
`relationships` collection:

```ruby
id = Pubid::Ieee.parse("IEEE Std 1613.1-2019 (Revision of IEEE Std 1613-2009)")
id.relationships.first.relationship_type  # => "revision_of"
```

Eleven relationship types are recognized, among them `revision_of`,
`amendment_to`, `corrigendum_to`, `incorporates`, `adoption_of`,
`supplement_to`, `draft_amendment_to`, `draft_revision_of`,
`reaffirmation_of`, `redesignation_of`; several can be joined with `;`.

**`to_s` is a bounded identifier.** The relationship narrative — an
"as amended by …" list that can run hundreds of characters — is parsed into
`#relationships` but deliberately *not* re-embedded in `#to_s`, because
consumers use `to_s` as the document number and output filename (relaton-data-ieee
slugs it directly, and the OS 255-byte limit silently dropped crawl batches).
`IEEE Std 1613.1-2019 (Revision of IEEE Std 1613-2009)` therefore parses with
the relationship intact but renders `"IEEE Std 1613.1-2019"`. Short
identity-bearing parentheticals (co-designations like `S-135 (IPCEA P46-426)`)
stay in `to_s`.

Drafts spell the draft word `Draft` alone in every rendering face and use the
`P` number prefix with a `/D{n}` draft number: `IEEE P802.11-2020/D1, 2020`.

## Filename generator

The v1 rule — replace `/`, `\`, `,`, `'`, `"`, `(`, `)` and spaces with `_`,
squeeze repeated `_` — is **historic**. pubid 2 generates filenames and
URL-safe keys from the machine-readable string, not from the human face:

```ruby
id = Pubid::Ieee.parse("IEEE Std 802.11-2020")
id.to_mr_string  # => "ieee.std.802.11.2020"
id.to_slug       # => "ieee.std.802.11.2020"  (same; already slug-safe)

id = Pubid::Ieee.parse("IEEE Std 535-2013/Cor. 1-2017")
id.to_slug       # => "ieee.std.535.2013_cor.1.2017"
```

Distinct identifiers never collide on `to_mr_string`; supplements append
`_{type}.{number}.{year}` segments recursively and copublishers join with `-`.
For the two predecessor organizations the slug carries the organization:
`AIEE No. 552, November 1955` → `aiee.no..552.1955`,
`52 IRE 7.S2` → `ire.7.s2.1952`.

## Historic eras: AIEE and IRE

The American Institute of Electrical Engineers (AIEE, 1884–1963) and the
Institute of Radio Engineers (IRE, 1912–1963) merged into IEEE in 1963; their
identifiers are parsed as their own classes (`Pubid::Ieee::Aiee::Identifier`,
`Pubid::Ieee::Ire::Identifier`):

```ruby
aiee = Pubid::Ieee.parse("AIEE No. 552, November 1955")
aiee.to_s                       # => "AIEE No. 552, November 1955"
aiee.to_s(date_format: :short)  # => "AIEE No. 552-1955"
aiee.to_s(date_format: :long)   # => "AIEE No. 552, November 1955"

ire = Pubid::Ieee.parse("52 IRE 7.S2")
ire.to_s   # => "52 IRE 7.S2"  (2-digit year rendered as parsed; 1952 internally)
ire.year   # => "1952"
```

AIEE always uses `No`/`No.` (never `Std`) and supports the short (dash) and
long (comma + optional month) date profiles; IRE is year-first with 2-digit
years (12–63 → 1912–1963) and committee notation (`7.S2`, `28 S1`).
Transitional forms (`IEEE-AIEE No. 56`, `IEEE-IRE X`) parse as well. The full
era narrative lives in the archived pubid-ieee README and
`docs/IEEE-DRAFT-STAGES.md` covers the draft-stage codes.
