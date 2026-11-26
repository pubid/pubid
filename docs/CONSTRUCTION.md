# Constructing identifiers programmatically

There are three ways to obtain an identifier. Parsing reads a printed
reference; `from_hash` rebuilds one from its serialized form; the constructor
builds one from typed attributes without a source string.

The v1 entry point — the per-gem module function
`Pubid::Iso::Identifier.create(...)` (and its `pubid-core` twin) — no longer
exists. The v2 constructor is the class method `.new` on
`Pubid::<Flavor>::Identifier` or one of its concrete subclasses, called with
keyword arguments. The v1 form is historic; everything below is v2.

```ruby
require "pubid"

id = Pubid::Iso::Identifier.new(number: "8601", part: "1", year: "2019")
id.to_s    # => "ISO 8601-1:2019"
id.to_urn  # => "urn:iso:std:iso:8601:-1:2019"
```

## Parsing

`Pubid.parse` routes on the leading prefix token (longest match first, at a
token boundary), so a reference whose flavor the caller does not know is still
parsed by the right grammar:

```ruby
Pubid.parse("ISO 8601-1:2019").class   # => Pubid::Iso::Identifiers::InternationalStandard
Pubid.parse("JIS Z 8301:2019").class   # => Pubid::Jis::Identifier
Pubid.parse("ISO/IEC DIR 2").to_s      # => "ISO/IEC DIR 2" (normalized)
```

When the flavor is known, name it directly — this skips routing:

```ruby
Pubid::Iso.parse("ISO 9001:2015")
Pubid::Iec.parse("IEC 60038:2009 ED2")
```

A string no grammar accepts raises `Pubid::Errors::ParseError` (which
subclasses `Parslet::ParseFailed`, so existing rescues keep working).

## The constructor: `Pubid::<Flavor>::Identifier.new`

Each flavor's public handle is `Pubid::<Flavor>::Identifier` — a real
identifier class, common ancestor of that flavor's concrete types, and host of
the polymorphic `from_hash`. `.new` takes keyword arguments, one per declared
attribute:

```ruby
Pubid::Iso::Identifier.new(number: "8601", part: "1", year: "2019")
# => ISO 8601-1:2019
```

Omitting the document type gives the flavor's default type (ISO: International
Standard). For another type, construct the concrete class — the class *is* the
type:

```ruby
Pubid::Iso::Identifiers::TechnicalReport.new(number: 123).to_s
# => "ISO/TR 123"
```

### The contract: unknown keys are refused, scalars are coerced

`new` raises `ArgumentError` naming any key the class does not declare. This
is deliberate: `year` on a date-based flavor is a *reader* over the `date`
component, not an attribute, so a silently-dropped key would produce an
identifier with no year and no diagnostic.

```ruby
Pubid::Iso::Identifier.new(number: "1", copublisher: "IEC")
# ArgumentError: unknown attribute for Pubid::Iso::Identifier: copublisher
```

Scalar values are coerced into the component the attribute declares, when the
component is a "degenerate" one (IEC `edition`, `languages`, `copublishers`,
and the `year`/`month`/`day` fold into `date`):

```ruby
id = Pubid::Iec::Identifiers::InternationalStandard.new(
  number: "1000", part: "1", year: 2023, edition: 2, languages: ["en"],
)
id.to_s    # => "IEC 1000-1:2023 ED2(en)"
id.to_urn  # => "urn:iec:std:iec:1000-1:2023::ed-2:en"

# String, Hash and component forms give one result:
Pubid::Iec::Identifiers::InternationalStandard.new(
  number: "1000", languages: ["en"],
).to_hash == Pubid::Iec::Identifiers::InternationalStandard.new(
  number: "1000", languages: [{ code: "en" }],
).to_hash  # => true
```

The coercion is type-aware: a flavor that declares an attribute as a plain
string keeps the string (`ECMA` `edition`, `ASME` `language`), and `number`
is deliberately never wrapped into a `Code` component.

Locked by `spec/pubid/attribute_construction_spec.rb` for every registered
flavor — read it as the executable form of this section.

### Copublishers

Joint publications are modeled per flavor. IEC takes copublisher scalars and
wraps them:

```ruby
Pubid::Iec::Identifiers::InternationalStandard.new(number: "1000", copublishers: ["ISO"]).to_s
# => "IEC/ISO 1000"
```

ISO's copublishers are `Pubid::Iso::Components::Publisher` objects. Construct
the publisher component with the `copublisher` list (the primary publisher is
the component's default, `ISO`):

```ruby
Pubid::Iso::Identifier.new(
  publisher: Pubid::Iso::Components::Publisher.new(copublisher: ["IEC"]),
  number: 123,
).to_s
# => "ISO/IEC 123"
```

A bare `copublishers: ["IEC"]` string list on ISO does not render the
copublisher — ISO's publisher component is its own class, so use the component
form above, or `from_hash` (which accepts the flat string list that `to_hash`
emits).

### Stages

ISO stages are typed stages: a stage and a document type combined (`WD`,
`DIS`, `FDIS`, `WD Amd`, `DAM`, `FDCor`…). Set them with `typed_stage:`,
looking the entry up by abbreviation — `Pubid::Iso.locate_stage` returns the
shared registry object:

```ruby
Pubid::Iso::Identifiers::InternationalStandard.new(
  number: 123, typed_stage: Pubid::Iso.locate_stage("WD"),
).to_s
# => "ISO/WD 123"

Pubid::Iso::Identifiers::TechnicalReport.new(
  number: 123, typed_stage: Pubid::Iso.locate_stage("DTR"),
).to_s
# => "ISO/DTR 123"
```

`Pubid::Iso.locate_stage(name)` searches ISO's typed-stage registry;
`Pubid.locate_stage(name, flavor: :iso)` delegates across flavors and
`Pubid.locate_stage_flavors(name)` names the owners. The returned object
answers `.abbreviation` and `.name`:

```ruby
ts = Pubid::Iso.locate_stage("FDIS")
ts.abbreviation  # => "FDIS"
ts.name          # => "Final Draft International Standard"
ts.harmonized_stages  # => ["50.00", "50.20", "50.60", "50.92", "50.98", "50.99"]
```

The type is derived from `typed_stage` — there is no separate `type:` or
`stage:` attribute to set on ISO identifiers (they are derived readers, and
passing them is refused).

ISO stage iteration (the `.2` in `ISO/DIS 123-1.2`, the *second* DIS of the
same document) is its own attribute — the v1 keyword `iteration:` is historic:

```ruby
Pubid::Iso::Identifiers::InternationalStandard.new(
  number: "123", part: "1",
  typed_stage: Pubid::Iso.locate_stage("DIS"),
  stage_iteration: 2,
).to_s
# => "ISO/DIS 123-1.2"
```

An iteration requires a stage; `ISO/DIS 123-1.2` without the stage is not a
valid form.

### Supplements with a base

A supplement wraps the document it modifies under the uniform `base`
attribute (every flavor names it `base`; the old `base_identifier` is
renamed). The supplement is its own class — Amendment, Corrigendum — with the
supplement ordinal in `number` and its own year:

```ruby
base = Pubid::Iso::Identifiers::InternationalStandard.new(
  number: "123", part: "1", year: 2019,
)

Pubid::Iso::Identifiers::Amendment.new(number: 1, year: 2021, base: base).to_s
# => "ISO 123-1:2019/Amd 1:2021"

Pubid::Iso::Identifiers::Corrigendum.new(number: "1", year: "2021", base: base).to_s
# => "ISO 123-1:2019/Cor 1:2021"

# a staged amendment carries a supplement typed stage:
Pubid::Iso::Identifiers::Amendment.new(
  number: 1, year: 2021, base: base,
  typed_stage: Pubid::Iso.locate_stage("WD Amd"),
).to_s
# => "ISO 123-1:2019/WD Amd 1:2021"
```

IEC supplements render the compact official face (`AMD1`, not `Amd 1`):

```ruby
base = Pubid::Iec::Identifiers::InternationalStandard.new(
  number: "60050", part: "351", year: 2013,
)
Pubid::Iec::Identifiers::Amendment.new(number: "1", year: 2016, base: base).to_s
# => "IEC 60050-351:2013/AMD1:2016"
```

A supplement face written in the legacy prefix notation — the stage token
before the base designation (`IEC/FDAM 60038-1`, `ISO/IEC PDAM 12207`) —
decodes onto the modern identity: the designation stays whole on the base,
the unnumbered token means supplement 1, and the modern on-base face is
what renders (`IEC/FDAM 60038-1` renders the spaced draft face
`IEC 60038-1/FDAM 1` and equals the parse of that form). A supplement parsed or built without any
base designation (`IEC/AMD 1:2017`) synthesizes a bare self-base from its
own number. The decode contract is documented in
link:flavor-guides/iec.md#legacy-supplement-faces[the IEC flavor guide].

IEEE supplements:

```ruby
base = Pubid::Ieee.parse("IEEE Std 535-2013")
Pubid::Ieee::Identifiers::Amendment.new(number: "1", year: "2015", base: base).to_s
# => "IEEE Std 535-2013/Amd 1-2015"
```

A chain wraps recursively — `/Amd 3:2016/Cor 1:2017` is a Corrigendum whose
`base` is the Amendment whose `base` is the standard. `#root` walks the chain
to the base document, and `#base_document` peels one supplement layer.

### IEEE

IEEE's identity is carried by the `code:` keyword (a `Components::Code` is
parsed from it); the draft face uses the `P` prefix plus a `draft:` draft
number:

```ruby
Pubid::Ieee::Identifier.new(code: "802.11", year: 2020).to_s
# => "IEEE Std 802.11-2020"

Pubid::Ieee::Identifier.new(code: "P802.11", year: 2020, draft: "D1").to_s
# => "IEEE Draft P802.11/D1, 2020"
```

`code`, `draft` and `draft_obj` are IEEE constructor parameters beyond the
declared attributes (`extra_init_keys`), so the unknown-key refusal knows them.

### NIST

NIST's edition/revision is an `Edition` component (`type` is `"e"`/`"r"`/`"-"`,
`id` the number or year):

```ruby
Pubid::Nist::Identifier.new(
  publisher: "NIST", series: "SP", number: "800-53",
  edition: Pubid::Nist::Components::Edition.new(type: "r", id: "5"),
).to_s
# => "NIST SP 800-53r5"
```

A bare revision string is not coerced here (the NIST edition is not a
degenerate component) — pass the component, or parse the printed form.

## `from_hash`: rebuilding from a serialized hash

`#to_hash` emits the canonical hash (no defaults, nested supplements under
`base`), and every flavor's `Pubid::<Flavor>::Identifier.from_hash(h)` reads
both that shape and the flat degenerate forms (`edition: "2"`,
`year: "2024"`). The round trip is exact:

```ruby
id = Pubid::Iso.parse("ISO 9001:2015/Amd 1:2020/Cor 1:2021")
Pubid.from_hash(id.to_hash).to_s  # => "ISO 9001:2015/Amd 1:2020/Cor 1:2021"
```

`Pubid.from_hash` is the hash counterpart of `Pubid.parse`: it reads the
`_type` key (`pubid:<flavor>:<type>`), names the concrete class, and builds
without the caller naming the flavor:

```ruby
Pubid.from_hash({
  "_type" => "pubid:iso:international-standard",
  "number" => "9001", "year" => "2015",
}).to_s  # => "ISO 9001:2015"
```

A hash with no `_type` (or an unknown one) raises
`Pubid::Errors::InvalidInputError`. For a relaton-data `index-v2.yaml` row,
pass the identifier hash in the row's `:id` key: `Pubid.from_hash(row[:id])`.

The invariant to keep in mind (locked by `spec/pubid/identifier_roundtrip_spec.rb`
for every flavor): `from_hash(id.to_hash) == id`. A construction path that
holds a value the other path does not breaks `#matches?` — equality is what
relaton's index lookups are made of.

## Keyword conventions across flavors

| Keyword | Meaning | Flavors and notes |
|---------|---------|-------------------|
| `number` | document number | `:string` on `::Pubid::Identifier` for every flavor (never a `Code`) |
| `part`, `subpart` | part / subpart columns | siblings of `number`, not fields of it |
| `year` | publication year | a reader over `date` on component-date flavors (ISO, IEC…); a real attribute on scalar-year flavors (GOST, JIS, IEEE…). `month:`, `day:` fold into `date` where the alias is not declared |
| `edition` | edition/revision | component on ISO/IEC/NIST (coerced from a scalar on IEC); plain string on ECMA/CSA-style flavors |
| `languages` | language codes | component collection on IEC (coerced from `["en"]`); plain strings where declared so |
| `copublishers` | joint publishers | component collection (ISO: `Iso::Components::Publisher`; IEC: coerced from scalars) |
| `typed_stage` | stage + type combined | ISO (look up via `Pubid::Iso.locate_stage`); stage is derived, never stored separately |
| `stage_iteration` | DIS iteration (`.2`) | ISO |
| `base` | the wrapped document | every supplement/wrapper flavor, uniform name |
| `code` | IEEE number designator | IEEE `extra_init_keys` constructor parameter |

When a flavor needs a constructor parameter that is not a serialized attribute
(IEEE `code`/`draft`), it declares it in `extra_init_keys`; everything else
unknown raises.

## URNs

`#to_urn` renders the organization's registered URN scheme (RFC 5141 for ISO;
lossy — it carries no year). `#to_pubid_urn` is pubid's own scheme: it carries
every value, always round-trips through `Pubid.parse_urn`, and is path-safe.
See `docs/URN-GENERATION-GUIDE.adoc` and `docs/URN-SCHEMES.adoc`.

```ruby
Pubid::Iso::Identifier.new(number: "8601", part: "1", year: "2019").to_urn
# => "urn:iso:std:iso:8601:-1:2019"
```

## PFS: the declarative composition layer

A flavor does not have to be hand-written. PFS — the PubID Format Schema —
is the declarative layer above the contracts this page describes: a body
declares its scheme once in a `.pfs` file (plain YAML) in the
[pubid-grammar](https://github.com/pubid/pubid-grammar) repo
(`definitions/`), and the compiler
[`scripts/pfs`](https://github.com/pubid/pubid-grammar/blob/main/scripts/pfs)
generates the PARG edition-2 grammar from the declarations, bakes a
checksum-verified artifact through the pinned parsanol pipeline, verifies
every example the file embeds against that **baked** artifact, and emits
the Ruby flavor module this gem vendors under `lib/pubid/<flavor>_pfs/`.
The TypeScript side loads the same baked artifact, so one definition file
produces both engines' flavors from one conformance set. A compiled module
is generated code — every file carries a `DO NOT EDIT BY HAND` header
naming the source definition, its sha256 and the regeneration command;
fix the definition, never the output.

The embedded examples are not documentation — they are the definition's
live test set. Every positive must parse, render as declared and bind
identically through the baked artifact; every negative must fail. A
compiled flavor ships beside its coded sibling only once its **parity
harness** (`spec/pubid/<flavor>_pfs/parity_spec.rb`) reproduces the coded
flavor byte-for-byte over the corpus — drift is a failed port, never a
fixture edit.

The gem carries five compiled flavors, each registered beside its coded
sibling as the `*_pfs` dev alias (the registry sorts the coded key first,
so `Pubid.parse` keeps routing the coded flavors):

| Compiled flavor | Source definition | Parity harness |
|-----------------|-------------------|----------------|
| `Pubid::DoiPfs` (`doi_pfs`) | `definitions/doi.pfs` | `spec/pubid/doi_pfs/parity_spec.rb` |
| `Pubid::EtsiPfs` (`etsi_pfs`) | `definitions/etsi.pfs` | `spec/pubid/etsi_pfs/parity_spec.rb` |
| `Pubid::CalconnectPfs` (`calconnect_pfs`) | `definitions/calconnect.pfs` | `spec/pubid/calconnect_pfs/parity_spec.rb` |
| `Pubid::CenPfs` (`cen_pfs`) | `definitions/cen.pfs` | `spec/pubid/cen_pfs/parity_spec.rb` |
| `Pubid::BsiPfs` (`bsi_pfs`) | `definitions/bsi.pfs` | `spec/pubid/bsi_pfs/parity_spec.rb` |

### The module library

National standards bodies do not invent identifier schemes — they adopt
the ISO and IEC inner formats, and CEN overlays the European face. That
machinery is declared once in pubid-grammar's
[`definitions/modules/*.pfsmod`](https://github.com/pubid/pubid-grammar/tree/main/definitions/modules)
— six named, versioned modules a definition binds (`bsi.pfs` composes the
BS face from five of them, `national.prefix` parameterized to
`["BS", "BSI"]`):

| Module | Provides |
|--------|----------|
| `iso.inner` | the ISO inner document face as a referenceable library (the declared ISO scheme itself stays coded) |
| `iec.inner` | the IEC inner document face, likewise |
| `en.overlay` | the adoption overlay — the EN face with its draft tokens |
| `national.prefix` | the national body's head tokens (DIN, BS, NF, SS-, NEN-, UNE-, ÖNORM, CAN/CSA) as a **parameter** — one module, one `prefixes` value per body |
| `supplements.core` | the amendment / corrigendum operators as bindings — a definition binds its own spellings to the operator, never the semantics (`ed`, `amd`, `cor` are reserved core tokens) |
| `edition.core` | the edition operator as a binding (`ed` reserved; the body's spelling binds through its own grammar) |

Two soundness rules are enforced at compile time. Modules declare
**identity composition** — an adoption is a wrapper with an adopted base,
not a grammar soup — and they declare their **extension hooks**: where a
body exceeds the module parameters (a BS `+A1` national amendment,
re-dating), it drops to a coded hook beside its definition, explicit and
never implicit.

The normative language reference is
[`definitions/README.md`](https://github.com/pubid/pubid-grammar/blob/main/definitions/README.md)
in pubid-grammar. The concept page and the `.pfs` language reference live
on the website at
[PFS — the PubID Format Schema](https://www.pubid.com/concepts/pfs) and
[The .pfs Format Schema Language](https://www.pubid.com/library/pfs).
