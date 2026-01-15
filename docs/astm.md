# ASTM Documentation

## Overview

The ASTM flavor handles identifiers for ASTM International (formerly American Society for Testing and Materials) standards and publications. ASTM identifiers include multiple document types (Standards A-G, Research Reports, Technical Reports, Manuals, Monographs, Data Series, Work in Progress, Adjuncts), year notation, edition notation, reapproval notation, and sub-year notation. The flavor uses ordered parser rules to handle specific patterns before general ones.

## Architecture

This flavor follows the PubID v2 three-layer architecture pattern:

1. **Parser** (`parser.rb`) - Parslet PEG grammar for syntax parsing
   - Uses ordered rules (most specific first)
   - Handles Research Report with colon (RR:CF-123)
   - Supports multiple document type prefixes
   - Parses dual unit notation (F1862/F1862M)
   - Handles year notation with 2-digit years (-24)
   - Supports reapproval notation ( (2020) )
   - Parses edition notation (e1, 9TH)
   - Handles sub-year notation (24e1a)
   - Supports format suffix (-EB)

2. **Builder** (`builder.rb`) - Transforms parse trees to domain objects
   - Determines document type from parsed data
   - Constructs appropriate identifier class

3. **Identifier** (`identifiers/`) - Lutaml::Model domain classes with rendering logic

## Document Types

| Type | Full Name | Description |
|------|-----------|-------------|
| Standard | Standard | Standard (A-G prefix) |
| RR | Research Report | Committee research report |
| TR | Technical Report | Technical report |
| MNL | Manual | Manual |
| MONO | Monograph | Monograph |
| DS | Data Series | Data series publication |
| WK | Work in Progress | Draft document |
| ADJ | Adjunct | Supplementary material |

## Standard Types (A-G)

| Letter | Committee | Description |
|--------|-----------|-------------|
| A | Steel | Ferrous metals |
| B | Nonferrous | Nonferrous metals |
| C | Ceramics | Ceramics, glass, etc. |
| D | Miscellaneous | Other materials |
| E | Miscellaneous | Other subjects |
| F | Special | Specialized tests |
| G | Corrosion | Corrosion tests |

## Parser Rules

### Main Rule (Ordered)

```ruby
rule(:identifier) do
  research_report |  # Most specific (has colon)
    technical_report |
    manual |
    monograph |
    data_series |
    work_in_progress |
    adjunct |
    standard  # DEFAULT (A-G letter)
end
```

### Component Rules

```ruby
# Publisher
rule(:publisher) { str("ASTM").as(:publisher) >> space.maybe }

# Standard letters A-G
rule(:standard_letter) { match("[A-G]").as(:letter) }

# Year (2-digit)
rule(:year_2digit) { digit.repeat(2, 2).as(:year) }

# Reapproval
rule(:reapproval) do
  str("(") >> digit.repeat(4, 4).as(:reapproval) >> str(")")
end

# Edition
rule(:edition) { str("e") >> digits.as(:edition) }

# Sub-year notation
rule(:sub_year) { match("[a-c]").as(:sub_year) }

# Format suffix
rule(:format_suffix) { dash >> str("EB").as(:format_suffix) }

# Research Report (with colon)
rule(:research_report) do
  publisher.maybe >>
    str("RR").as(:type) >>
    colon >>
    (letter >> digit.repeat(2, 2)).as(:committee) >>
    dash >>
    digits.as(:number)
end

# Dual unit pattern
rule(:dual_unit) do
  slash >>
    standard_letter >>
    digits >>
    str("M").as(:dual_m)
end
```

### Pattern Examples

| Input | Parse Tree Key Elements |
|-------|------------------------|
| `ASTM A36-24` | `{letter: "A", number: "36", year: "24"}` |
| `ASTM F1862/F1862M` | `{letter: "F", number: "1862", dual_m: "M"}` |
| `ASTM RR:CF-123` | `{type: "RR", committee: "CF", number: "123"}` |
| `ASTM MNL 123` | `{type: "MNL", number: "123"}` |
| `ASTM MONO 123` | `{type: "MONO", number: "123"}` |
| `ASTM DS 123S4` | `{type: "DS", number: "123", suffix: "S4"}` |
| `ASTM WK 12345` | `{type: "WK", number: "12345"}` |
| `ASTM ADJF3504-EA` | `{type: "ADJ", designation: "F3504", ea_suffix: "EA"}` |
| `ASTM D52303-24e1` | `{number: "52303", year: "24", edition: "1"}` |

## Year Notation

ASTM uses 2-digit year notation:
- `-24` - Year 2024
- `-23e1` - Year 2023, edition 1
- `-24e1a` - Year 2024, edition 1, sub-year a

## Sub-Year Notation

ASTM uses sub-year notation for revisions within a year:
- `24e1a` - Year 2024, edition 1, revision a
- `24e1b` - Year 2024, edition 1, revision b
- `24e1c` - Year 2024, edition 1, revision c

## Edition Notation

ASTM uses edition notation:
- `e1` - Edition 1
- `e2` - Edition 2
- `9TH` - 9th edition
- `8TH` - 8th edition

## Reapproval Notation

ASTM uses parenthetical reapproval:
- `(2020)` - Reapproved in 2020
- Appears after year: `A36-24 (2020)`

## Adjunct Designations

ASTM Adjuncts have various designations:
- `ADJF3504-EA` - Excel file adjunct
- `ADJC033501` - Numeric adjunct designation
- `ADJC0450A` - Letter suffix adjunct
- `ADJE11211T` - Mixed alphanumeric
- `ADJDQCALC` - Text designation

## ISO/ASTM Dual Publication

ASTM 5xxxx series are ISO/ASTM dual-published:
- `ASTM 52303-24` - ASTM's version (e1 = edition 1)
- `ISO/ASTM 52303:2024` - ISO's version

These are semantically dual-published but parsed as digit-only standards.

## Usage Examples

### Parsing

```ruby
# Parse standard
id = PubidNew::Astm.parse("ASTM A36-24")
id.letter  # => "A"
id.number  # => "36"

# Parse research report
id = PubidNew::Astm.parse("ASTM RR:CF-123")
id.type  # => "RR"

# Parse dual unit
id = PubidNew::Astm.parse("ASTM F1862/F1862M")
id.dual_m  # => "M"
```

### Rendering

```ruby
id.to_s  # => "ASTM A36-24"
```

## Design Characteristics

### Ordered Parser Rules

ASTM uses ordered parser rules (most specific first):
1. Research Report (has colon)
2. Technical Report (has TR)
3. Manual (has MNL)
4. Monograph (has MONO)
5. Data Series (has DS)
6. Work in Progress (has WK)
7. Adjunct (has ADJ)
8. Standard (default)

### 2-Digit Years

ASTM uses 2-digit years:
- `-24` = 2024
- Assumes 2000s for 2-digit years

### Comment Stripping

ASTM parser strips comments (text after #):
- `ASTM A36-24 # comment` → `ASTM A36-24`

## Comparison with ISO

| Feature | ASTM | ISO |
|---------|------|-----|
| Document types | 8 types + A-G standards | 18+ types |
| Stage codes | None | 15+ (PWI, NP, WD, CD, DIS, FDIS) |
| Supplements | None | 5 types (Amd, Cor, Add, Suppl, Ext) |
| Year format | 2-digit (-24) | 4-digit (:2024) |
| Number format | Letter prefix or digit-only | Numeric |
| Sub-year | Yes (a, b, c) | No |

## Testing

### Test Coverage

- **Unit tests:** `spec/pubid_new/astm/`
- **Parser tests:** `spec/pubid_new/astm/parser_spec.rb`
- **Builder tests:** `spec/pubid_new/astm/builder_spec.rb`
- **Identifier tests:** `spec/pubid_new/astm/identifiers/`

### Fixtures

Located in: `spec/fixtures/astm/identifiers/`

- **Pass tests:** `pass/` - Valid patterns
- **Fail tests:** `fail/` - Invalid patterns

## References

- **Specification:** ASTM International
- **Examples:** ASTM Standards

---

## Appendix: Design Decisions

### Ordered Parser Rules

**Context:** ASTM has multiple document type patterns that overlap.

**Decision:** Order parser rules from most specific to least specific.

**Rationale:**
- Research Report has unique colon pattern
- Avoids ambiguous matches
- Each rule handles distinct patterns

**Alternatives considered:**
- Single complex rule - Rejected (hard to maintain)
- Priority-based parsing - Rejected (same as ordering)

### 2-Digit Years

**Context:** ASTM uses 2-digit years (e.g., -24 for 2024).

**Decision:** Store as 2-digit string, assume 2000s.

**Rationale:**
- Matches ASTM notation
- No century ambiguity in current use
- Simple storage

**Alternatives considered:**
- Convert to 4-digit - Rejected (loses original format)
- Store with century - Rejected (unnecessary)

### Sub-Year Notation

**Context:** ASTM has revisions within years (e.g., 24e1a).

**Decision:** Parse as separate sub_year attribute.

**Rationale:**
- Preserves semantic meaning
- Matches ASTM practice
- Clean separation

**Alternatives considered:**
- Include in edition - Rejected (loses distinction)
- Ignore - Rejected (loses information)

### Adjunct Designations

**Context:** Adjuncts reference base standards with various formats.

**Decision:** Parse designation as opaque string.

**Rationale:**
- Too many format variations
- Adjunct references base standard
- Opaque is flexible

**Alternatives considered:**
- Parse all formats - Rejected (too complex)
- Reject adjuncts - Rejected (common practice)
