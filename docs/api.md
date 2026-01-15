# API Documentation

## Overview

The API flavor handles identifiers for American Petroleum Institute standards and publications. API identifiers include multiple document types (STD, SPEC, TR, RP, MPMS, etc.), MPMS chapter notation, alphanumeric numbers with optional parts, year dates, reaffirmation notation, edition notation, and combined identifiers. The flavor supports API's comprehensive petroleum industry documentation system with both simple and complex identifier patterns.

## Architecture

This flavor follows the PubID v2 three-layer architecture pattern:

1. **Parser** (`parser.rb`) - Parslet PEG grammar for syntax parsing
   - Handles API prefix and document types
   - Supports MPMS with chapter notation (CH 10)
   - Parses alphanumeric numbers (e.g., 579-2, 6D, D16)
   - Handles year dates with dash or colon (-2023, :2023)
   - Parses reaffirmation notation (R2020)
   - Supports edition notation (4th edition)
   - Handles part notation (Part 2)
   - Parses combined identifiers (two identifiers separated by /)

2. **Builder** (`builder.rb`) - Transforms parse trees to domain objects
   - Constructs identifier components
   - Handles combined identifiers

3. **Identifier** (`identifiers/`) - Lutaml::Model domain classes with rendering logic

## Document Types

| Type | Full Name | Description |
|------|-----------|-------------|
| STD | Standard | Formal API standard |
| SPEC | Specification | Technical specification |
| RP | Recommended Practice | Industry best practices |
| TR | Technical Report | Technical report |
| MPMS | Manual of Petroleum Measurement Standards | Measurement standards |
| COS | Compendium of Standards | Standard collection |
| BULL | Bulletin | Informational bulletin |
| PUBL | Publication | General publication |

## Parser Rules

### Main Rule

```ruby
rule(:identifier) do
  combined_identifier | mpms_identifier | typed_identifier | typeless_identifier
end
```

### Component Rules

```ruby
# Publisher
rule(:publisher) { str("API") >> space }

# Document types
rule(:doc_type) do
  (str("MPMS") | str("BULL") | str("SPEC") | str("STD") |
   str("RP") | str("TR") | str("COS") | str("PUBL")).as(:type)
end

# Chapter notation for MPMS
rule(:chapter_notation) do
  space >> str("CH") >> space >> digits.as(:chapter)
end

# Number with optional part
rule(:number_with_part) do
  match("[0-9A-Z]").repeat(1).as(:number) >>
    (dash >> match("[0-9A-Z]").repeat(1).as(:part)).maybe
end

# Year (4-digit)
rule(:year) { digit.repeat(4, 4).as(:year) }

# Date with dash or colon
rule(:date_dash) { dash >> year }
rule(:date_colon) { colon >> year }

# Reaffirmation notation
rule(:reaffirmation) do
  space >> str("(R") >> year >> str(")")
end

# Part notation
rule(:part_notation) do
  str(", Part ") >> digits.as(:part_number)
end

# Edition notation
rule(:edition_notation) do
  str(", ") >>
    digits.as(:edition_number) >>
    (str("st") | str("nd") | str("rd") | str("th")) >>
    str(" edition")
end
```

### Pattern Examples

| Input | Parse Tree Key Elements |
|-------|------------------------|
| `API STD 579-2:2023` | `{type: "STD", number: "579", part: "2", year: "2023"}` |
| `API RP 1104` | `{type: "RP", number: "1104"}` |
| `API MPMS CH 10.4A:2023` | `{type: "MPMS", chapter: "10", section: "4A", year: "2023"}` |
| `API 6D:2023` | `{number: "6D", year: "2023"}` |
| `API SPEC 17TR7:2023 (R2020)` | `{type: "SPEC", number: "17TR7", year: "2023", reaffirmation: "2020"}` |
| `API 579-2, Part 2:2023` | `{number: "579", part: "2", part_number: "2", year: "2023"}` |
| `API STD 620-4, 5th edition:2023` | `{type: "STD", number: "620", part: "4", edition_number: "5", year: "2023"}` |

## MPMS Notation

API MPMS (Manual of Petroleum Measurement Standards) uses chapter notation:
- `API MPMS CH 10.4A:2023` - Chapter 10, section 4A
- `API MPMS CH 3.1A:2020` - Chapter 3, section 1A

Format: `CH {chapter}.{section}{subsection}`

## Alphanumeric Numbers

API numbers can be alphanumeric:
- `579` - Numeric only
- `6D` - Letter suffix
- `D16` - Letter prefix
- `17TR7` - Mixed alphanumeric

## Usage Examples

### Parsing

```ruby
# Parse standard
id = PubidNew::Api.parse("API STD 579-2:2023")
id.type  # => "STD"
id.number  # => "579"

# Parse MPMS
id = PubidNew::Api.parse("API MPMS CH 10.4A:2023")
id.type  # => "MPMS"
id.chapter  # => "10"

# Parse with reaffirmation
id = PubidNew::Api.parse("API SPEC 17TR7:2023 (R2020)")
id.number  # => "17TR7"
```

### Rendering

```ruby
id.to_s  # => "API STD 579-2:2023"
```

## Design Characteristics

### Multiple Date Formats

API supports two date formats:
- `:2023` - Colon separator
- `-2023` - Dash separator

### Reaffirmation Notation

API uses parenthetical reaffirmation:
- `(R2020)` - Reaffirmed in 2020

### Edition Notation

API uses ordinal edition notation:
- `, 5th edition` - Fifth edition

### Part Notation

API supports part notation:
- `, Part 2` - Part 2

## Testing

### Test Coverage

- **Unit tests:** `spec/pubid_new/api/`
- **Parser tests:** `spec/pubid_new/api/parser_spec.rb`
- **Builder tests:** `spec/pubid_new/api/builder_spec.rb`
- **Identifier tests:** `spec/pubid_new/api/identifiers/`

### Fixtures

Located in: `spec/fixtures/api/identifiers/`

- **Pass tests:** `pass/` - Valid patterns
- **Fail tests:** `fail/` - Invalid patterns

## Comparison with ISO

| Feature | API | ISO |
|---------|-----|-----|
| Document types | 8 (STD, SPEC, RP, etc.) | 18+ (IS, TR, TS, etc.) |
| Stage codes | None | 15+ (PWI, NP, WD, CD, DIS, FDIS) |
| Supplements | None | 5 types (Amd, Cor, Add, Suppl, Ext) |
| Date format | :YYYY or -YYYY | :YYYY or (YYYY) |
| Number format | Alphanumeric | Numeric with letter suffix |
| Reaffirmation | (RYYYY) | None |

## References

- **Specification:** API (American Petroleum Institute)
- **Examples:** API Standards

---

## Appendix: Design Decisions

### MPMS Chapter Notation

**Context:** MPMS uses chapter notation different from regular standards.

**Decision:** Create dedicated MPMS identifier rule with chapter/section parsing.

**Rationale:**
- MPMS is unique format
- Chapter notation needs special handling
- Cleaner than combining with regular standards

**Alternatives considered:**
- Parse as regular standard - Rejected (loses structure)
- Use separate type code - Rejected (MPMS is type)

### Alphanumeric Numbers

**Context:** API numbers can be alphanumeric (6D, D16, 17TR7).

**Decision:** Parse as string, preserve original format.

**Rationale:**
- Preserves exact format
- No semantic meaning to parts
- Simple string handling

**Alternatives considered:**
- Parse into components - Rejected (over-complication)
- Normalize to numeric - Rejected (loses information)

### Dual Date Formats

**Context:** API uses both colon and dash date separators.

**Decision:** Parse both formats in parser.

**Rationale:**
- Matches actual API practice
- Flexible parsing
- Can normalize in builder if needed

**Alternatives considered:**
- Single format - Rejected (doesn't match practice)
- Normalize in preprocessing - Rejected (unnecessary)
