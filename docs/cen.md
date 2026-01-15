# CEN Documentation

## Overview

The CEN flavor handles identifiers for European Committee for Standardization (Comité Européen de Normalisation) documents. CEN identifiers follow European standards harmonization with support for multiple publishers (EN, CEN, CLC combinations), various document types (EN, HD, ES, TR, TS, Guide, etc.), amendments and corrigenda, and adopted standards (ISO, IEC). The flavor uses a complex parser with preprocessing normalization and supports both forward and reverse supplement notations.

## Architecture

This flavor follows the PubID v2 three-layer architecture pattern:

1. **Parser** (`parser.rb`) - Parslet PEG grammar for syntax parsing
   - Handles multiple publisher combinations: EN, EN/CLC, CEN/CLC, CLC/CEN
   - Supports document types: EN, HD, ES, TR, TS, Guide, ENV, CR, CWA
   - Parses stage prefixes: prEN, FprEN
   - Handles adopted standards (ISO, IEC, CISPR)
   - Supports amendments: +A1:2008, /A2:2019
   - Supports corrigenda: +AC:2009, /AC1:2005, +C1:2018
   - Parses edition notation: ED2, ED3
   - Normalizes publisher combinations (CEN-CLC → CEN/CLC)

2. **Builder** (`builder.rb`) - Transforms parse trees to domain objects
   - Handles publisher combinations
   - Builds supplement identifiers
   - Manages adopted standards

3. **Identifier** (`identifiers/`) - Lutaml::Model domain classes with rendering logic

## Components

CEN uses shared components from `lib/pubid_new/components/`:
- `Code` - Document numbers
- `Date` - Year/month dates
- `Type` - Document types
- `Language` - Language codes

## Document Types

| Type | Full Name | Description |
|------|-----------|-------------|
| EN | European Standard | Harmonized standard |
| HD | Harmonization Document | Document for harmonization |
| ES | European Standard | European standard (alt notation) |
| TR | Technical Report | Technical report |
| TS | Technical Specification | Technical specification |
| Guide | Guide | Guidance document |
| ENV | European Prestandard | Prestandard (withdrawn, now EN) |
| CR | CEN Report | Committee report |
| CWA | CEN Workshop Agreement | Workshop agreement |

## Parser Rules

### Main Rule

```ruby
rule(:identifier) do
  fragment_identifier |
    (stage_prefix | publisher) >>
      (space >> adopted_string).maybe >>
      (space >> type | slash >> type).maybe >>
      (space >> number >> parts >>
      year.maybe).maybe >>
      supplements >>
      edition.maybe
end
```

### Component Rules

```ruby
# Publishers
rule(:en) { str("EN") }
rule(:cen) { str("CEN") }
rule(:clc) { str("CLC") }
rule(:cwa) { str("CWA") }
rule(:hd) { str("HD") }
rule(:es) { str("ES") }
rule(:cr) { str("CR") }
rule(:env) { str("ENV") }

# Publisher (can be combined like EN/CLC or CEN/CLC)
rule(:publisher) do
  (cwa | hd | es | cr | env).as(:publisher) |
    (en.as(:publisher) >> (slash >> clc.as(:copublisher)).maybe) |
    (cen.as(:publisher) >> (slash >> clc.as(:copublisher)).maybe) |
    (clc.as(:publisher) >> (slash >> cen.as(:copublisher)).maybe) |
    en.as(:publisher)
end

# Stage prefixes
rule(:stage_prefix) { (str("FprEN") | str("prEN")).as(:type_with_stage) }

# Type
rule(:type) do
  (str("Guide") | str("GUIDE") | str("TR") | str("TS")).as(:type)
end

# Number
rule(:number) { digits.as(:number) }

# Part (can be multi-level)
rule(:part) { dash >> match["0-9-"].repeat(1).as(:part) }

# Year with optional month
rule(:year) { colon >> digit.repeat(4, 4).as(:year) }
rule(:year_with_month) do
  colon >> digit.repeat(4, 4).as(:year) >> dash >> month_digits
end

# Amendment
rule(:amendment) do
  (plus.as(:amd_sep_plus) | slash.as(:amd_sep_slash)) >>
    str("A") >> digits.as(:amd_number) >>
    (colon >> digit.repeat(4, 4).as(:amd_year)).maybe
end

# Corrigendum
rule(:corrigendum) do
  (plus.as(:amd_sep_plus) | slash.as(:amd_sep_slash)) >>
    str("AC") >> digits.maybe.as(:cor_number) >>
    (year_with_month | (colon >> digit.repeat(4, 4).as(:year))).maybe
end
```

### Pattern Examples

| Input | Parse Tree Key Elements |
|-------|------------------------|
| `EN 300 001:1997` | `{publisher: "EN", number: "300001", year: "1997"}` |
| `EN/CLC 300 001` | `{publisher: "EN", copublisher: "CLC", number: "300001"}` |
| `prEN 300 001` | `{type_with_stage: "prEN", number: "300001"}` |
| `EN 300 001+A1:2008` | `{publisher: "EN", number: "300001", supplements: [{amendment: {number: "1", year: "2008"}}]}` |
| `EN 300 001/AC:2009` | `{publisher: "EN", number: "300001", supplements: [{corrigendum: {year: "2009"}}]}` |

## Preprocessing

CEN uses preprocessing to normalize input:

| Pattern | Input | Output | Purpose |
|---------|-------|--------|---------|
| Dash normalization | `EN 300‑001` | `EN 300-001` | Normalize Unicode dashes |
| Publisher normalization | `CEN-CLC` | `CEN/CLC` | Standardize publisher separator |
| Guide case normalization | `GUIDE` | `Guide` | Normalize case |
| Remove corrigendum notes | ` (corrigendum)` | `` | Remove parenthetical notes |

## Testing

### Test Coverage

- **Unit tests:** `spec/pubid_new/cen/`
- **Parser tests:** `spec/pubid_new/cen/parser_spec.rb`
- **Builder tests:** `spec/pubid_new/cen/builder_spec.rb`
- **Identifier tests:** `spec/pubid_new/cen/identifiers/`

### Fixtures

Located in: `spec/fixtures/cen/identifiers/`

- **Pass tests:** `pass/` - Valid patterns
- **Fail tests:** `fail/` - Invalid patterns

## Design Characteristics

### Publisher Combinations

CEN supports multiple publisher combinations:
- `EN` - Single publisher
- `EN/CLC` - EN with CLC copublisher
- `CEN/CLC` - CEN with CLC copublisher
- `CLC/CEN` - CLC with CEN copublisher

### Stage Prefixes

CEN uses stage prefixes for draft standards:
- `prEN` - Preliminary European Standard
- `FprEN` - Final preliminary European Standard

### Supplement Notation

CEN supports multiple supplement notations:
- `+A1:2008` - Plus separator, amendment 1
- `/A2:2019` - Slash separator, amendment 2
- `+AC:2009` - Plus separator, corrigendum
- `/AC1:2005` - Slash separator, corrigendum 1
- `+C1:2018` - Plus separator, corrigendum 1

### Adopted Standards

CEN can adopt ISO and IEC standards:
- `EN ISO 9001` - Adopted ISO standard
- `EN IEC 62600` - Adopted IEC standard
- Adopted standards are parsed as opaque strings

## Comparison with ISO

| Feature | CEN | ISO |
|---------|-----|-----|
| Publisher | EN, CEN, CLC (with combos) | ISO (with copublishers) |
| Stage prefixes | prEN, FprEN | PWI, NP, WD, CD, DIS, FDIS |
| Supplements | Amd, Cor (AC) | Amd, Cor, Add, Suppl, Ext |
| Supplement separator | + or / | / only |
| Date format | :YYYY or :YYYY-MM | :YYYY or (YYYY) |
| Edition notation | ED2, ED3 | Year-based |

## References

- **Specification:** CEN/CENELEC
- **Examples:** CEN Publications
- **Related implementations:**
  - BSI flavor (similar European standards body)
  - ISO flavor (harmonized standards structure)

---

## Appendix: Design Decisions

### Publisher Combinations

**Context:** CEN identifiers can have multiple publishers (EN/CLC, CEN/CLC).

**Decision:** Parse as separate publisher and copublisher attributes.

**Rationale:**
- Preserves semantic structure
- Flexible rendering options
- Matches CEN notation

**Alternatives considered:**
- Single string with slash - Rejected (loses structure)
- Only EN publisher - Rejected (loses information)

### Dual Supplement Separators

**Context:** CEN uses both + and / for supplements.

**Decision:** Parse both separators and preserve in attributes.

**Rationale:**
- Matches actual CEN practice
- Preserves original format
- Flexible rendering

**Alternatives considered:**
- Normalize to single separator - Rejected (loses information)
- Reject one format - Rejected (doesn't match practice)

### Preprocessing Normalization

**Context:** CEN identifiers have inconsistent formats (CEN-CLC vs CEN/CLC).

**Decision:** Normalize during preprocessing, not parsing.

**Rationale:**
- Simplifies parser
- Consistent internal format
- Preserves semantics

**Alternatives considered:**
- Handle in parser - Rejected (more complex)
- Don't normalize - Rejected (inconsistent parsing)

### Adopted Standards as Opaque Strings

**Context:** CEN adopts ISO/IEC standards with their original notation.

**Decision:** Parse adopted standards as opaque strings.

**Rationale:**
- Avoids complex nested parsing
- Preserves original format
- ISO/IEC can be parsed separately if needed

**Alternatives considered:**
- Full recursive parsing - Rejected (too complex)
- Reject adopted standards - Rejected (common practice)
