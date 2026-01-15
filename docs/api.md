# API Documentation

## Overview

The API flavor handles identifiers for American Petroleum Institute standards and publications. It supports multiple document types (STD, SPEC, RP, TR, MPMS, BULL, COS, PUBL), MPMS chapter notation (CH 10.4A), alphanumeric numbers with optional parts (6D, D16, 17TR7), dual date formats (-2023 or :2023), reaffirmation notation ((R2020)), edition notation (, 5th edition), part notation (, Part 2), and combined identifiers (two identifiers separated by /). The flavor supports API's comprehensive petroleum industry documentation system with both simple and complex identifier patterns.

## Architecture

This flavor follows the PubID v2 three-layer architecture pattern:

1. **Parser** (`parser.rb`) - Parslet PEG grammar for syntax parsing
   - Converts input strings into structured hash trees
   - Handles MPMS with chapter notation (CH 10.4A)
   - Parses alphanumeric numbers (e.g., 579-2, 6D, D16, 17TR7)
   - Supports dual date formats (-2023, :2023)
   - Parses reaffirmation notation ((R2020))
   - Supports edition notation (, 5th edition)
   - Handles part notation (, Part 2)
   - Parses combined identifiers (two identifiers separated by /)
   - Preprocessing: Normalizes MPMP typo to MPMS

2. **Builder** (`builder.rb`) - Transforms parse trees to domain objects
   - Determines document type from parsed data
   - Constructs appropriate identifier class (9 classes total)
   - Casts components to proper types (year, reaffirmation, edition, part)
   - Handles combined identifiers
   - Manages MPMS chapter/section/subsection parsing

3. **Identifier** (`identifiers/`) - Lutaml::Model domain classes with rendering logic
   - Base identifiers for all API document types
   - Specialized class for MPMS with chapter notation
   - Custom rendering for each document type with proper format
   - No typed stages (API does not use formal stage codes)

## Components

### Flavor-Specific Components

API uses shared components from `lib/pubid_new/components/` without flavor-specific custom components.

### Shared Components Used

| Component | From | Purpose in this flavor |
|-----------|------|------------------------|
| `Publisher` | `lib/pubid_new/components/publisher.rb` | Organization name (API) |
| `Code` | `lib/pubid_new/components/code.rb` | Generic string values (number, part, iteration) |
| `Date` | `lib/pubid_new/components/date.rb` | Year-based dates |

## Identifier Classes

### Base Identifiers

#### Base

- **File:** `lib/pubid_new/api/identifiers/base.rb`
- **Parent:** `Lutaml::Model::Serializable`
- **Purpose:** The base class for all API identifiers. Provides common parse method.
- **Components Used:** `publisher`, `code` (number, part), `year`, `reaffirmation`, `edition`, `part_number`, `parsed_format`
- **Patterns Supported:** Delegates to `PubidNew::Api::Identifier.parse()`
- **Typed Stages:** Not applicable (API does not use typed stages)
- **Rendering Formats:** Varies by document type

### Document Type Identifiers

#### Standard

- **File:** `lib/pubid_new/api/identifiers/standard.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** API Standards (STD) are formal standards developed by API.
- **Components Used:** `publisher`, `code` (number, part), `year`, `reaffirmation`, `edition`, `part_number`
- **Patterns Supported:**
  - `API STD 579-2:2023` → Standard with part and year
  - `API STD 620-4, 5th edition:2023` → With edition notation
  - `API STD 579-2, Part 2:2023` → With part notation
- **Typed Stages:** Not applicable
- **Rendering Formats:** `API STD 579-2:2023` or `API STD 620-4, 5th edition:2023`

#### Specification

- **File:** `lib/pubid_new/api/identifiers/specification.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** Specifications (SPEC) are technical specifications.
- **Components Used:** Same as Standard
- **Patterns Supported:**
  - `API SPEC 17TR7:2023` → Specification with alphanumeric number
  - `API SPEC 17TR7:2023 (R2020)` → With reaffirmation
- **Typed Stages:** Not applicable
- **Rendering Formats:** `API SPEC 17TR7:2023`

#### RecommendedPractice

- **File:** `lib/pubid_new/api/identifiers/recommended_practice.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** Recommended Practices (RP) document industry best practices.
- **Components Used:** Same as Standard
- **Patterns Supported:**
  - `API RP 1104` → Basic recommended practice
  - `API RP 1104:2023` → With year
- **Typed Stages:** Not applicable
- **Rendering Formats:** `API RP 1104`

#### TechnicalReport

- **File:** `lib/pubid_new/api/identifiers/technical_report.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** Technical Reports (TR) document technical studies and findings.
- **Components Used:** Same as Standard
- **Patterns Supported:**
  - `API TR 12S1` → Technical report
- **Typed Stages:** Not applicable
- **Rendering Formats:** `API TR 12S1`

#### Bulletin

- **File:** `lib/pubid_new/api/identifiers/bulletin.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** Bulletins (BULL) provide informational updates.
- **Components Used:** Same as Standard
- **Patterns Supported:**
  - `API BULL 2C2` → Bulletin
- **Typed Stages:** Not applicable
- **Rendering Formats:** `API BULL 2C2`

#### Mpms

- **File:** `lib/pubid_new/api/identifiers/mpms.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** Manual of Petroleum Measurement Standards (MPMS) with chapter notation.
- **Components Used:** `chapter`, `section`, `subsection`, `year`
- **Patterns Supported:**
  - `API MPMS CH 10.4A:2023` → Chapter 10, section 4A
  - `API MPMS CH 3.1A:2020` → Chapter 3, section 1A
  - `API MPMS CH 12.2.3:2023` → Chapter 12, section 2, subsection 3
- **Typed Stages:** Not applicable
- **Rendering Formats:** `API MPMS CH 10.4A:2023` (with chapter notation)

#### ContinuousOperationsStandard

- **File:** `lib/pubid_new/api/identifiers/continuous_operations_standard.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** Continuous Operations Standards (COS) for ongoing operations.
- **Components Used:** Same as Standard
- **Patterns Supported:**
  - `API COS 1-15` → Continuous operations standard
- **Typed Stages:** Not applicable
- **Rendering Formats:** `API COS 1-15`

#### Publication

- **File:** `lib/pubid_new/api/identifiers/publication.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** Publications (PUBL) are general publications.
- **Components Used:** Same as Standard
- **Patterns Supported:**
  - `API PUBL 45` → Publication
- **Typed Stages:** Not applicable
- **Rendering Formats:** `API PUBL 45`

#### TypelessStandard

- **File:** `lib/pubid_new/api/identifiers/typeless_standard.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** Typeless standards without document type prefix.
- **Components Used:** `code` (number, part), `year`
- **Patterns Supported:**
  - `API 6D:2023` → Typeless standard with year
  - `API 6A` → Typeless standard without year
- **Typed Stages:** Not applicable
- **Rendering Formats:** `API 6D:2023`

## Scheme Registry

The `Scheme` class (`lib/pubid_new/api/scheme.rb`) is the central registry for this flavor.

### Registry Methods

API does NOT use typed stages or type codes like other flavors. The Scheme provides minimal methods:

- **`identifiers`** - Array of all registered identifier classes
  ```ruby
  def identifiers
    [
      Identifiers::Standard,
      Identifiers::Specification,
      Identifiers::RecommendedPractice,
      Identifiers::TechnicalReport,
      Identifiers::Bulletin,
      Identifiers::Mpms,
      Identifiers::ContinuousOperationsStandard,
      Identifiers::Publication,
      Identifiers::TypelessStandard,
    ]
  end
  ```

- **`typed_stages`** - Returns empty array (API does not use typed stages)
  ```ruby
  def typed_stages
    [].freeze
  end
  ```

### Identifier Class Determination

Since API does not use type codes, the Builder determines identifier class based on parsed data:

```ruby
def determine_identifier_class(parsed_hash)
  type = parsed_hash[:type]&.to_s

  case type
  when "MPMS"
    Identifiers::Mpms
  when "BULL"
    Identifiers::Bulletin
  when "SPEC"
    Identifiers::Specification
  when "STD"
    Identifiers::Standard
  when "RP"
    Identifiers::RecommendedPractice
  when "TR"
    Identifiers::TechnicalReport
  when "COS"
    Identifiers::ContinuousOperationsStandard
  when "PUBL"
    Identifiers::Publication
  when nil, ""
    Identifiers::TypelessStandard
  else
    Identifiers::Standard  # Default
  end
end
```

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

## Builder Logic

### Identifier Class Selection

The Builder determines which identifier class to instantiate based on:

1. **Type code** - If `:type` is present, map to specific class (MPMS → Mpms, BULL → Bulletin, etc.)
2. **No type** - If `:type` is nil or empty → TypelessStandard

### Component Casting

Special casting logic in Builder:

```ruby
# Year (from dash or colon date)
when :year
  # Both "-2023" and ":2023" → year="2023"
  value.to_s

# Reaffirmation (extract year)
when :reaffirmation
  # "(R2020)" → "2020"
  value.to_s.gsub(/[^0-9]/, "")

# Part number
when :part_number
  # ", Part 2" → "2"
  value.to_s

# Edition number
when :edition_number
  # ", 5th edition" → "5"
  value.to_s
```

### MPMS Special Handling

The Builder creates `Mpms` class with special chapter/section parsing:

```ruby
if parsed_hash[:type] == "MPMS"
  mpms = Identifiers::Mpms.new

  # Parse chapter
  if parsed_hash[:chapter]
    mpms.chapter = parsed_hash[:chapter].to_s
  end

  # Parse section (e.g., "4A" from "10.4A")
  if parsed_hash[:section]
    mpms.section = parsed_hash[:section].to_s
  end

  # Parse subsection (e.g., "3" from "12.2.3")
  if parsed_hash[:subsection]
    mpms.subsection = parsed_hash[:subsection].to_s
  end

  # Set year
  if parsed_hash[:year]
    mpms.year = parsed_hash[:year].to_s
  end

  mpms
end
```

### Combined Identifier Handling

The Builder parses combined identifiers (two identifiers separated by /):

```ruby
# Parse combined: "API STD 579-2/API STD 620"
if parsed_hash[:combined]
  first_identifier = build(parsed_hash[:first])
  second_identifier = build(parsed_hash[:second])

  # Return array of identifiers
  [first_identifier, second_identifier]
end
```

## Rendering Examples

### Standard Format

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `API STD 579-2:2023` | `API STD 579-2:2023` |
| `API STD 620-4, 5th edition:2023` | `API STD 620-4, 5th edition:2023` |
| `API STD 579-2, Part 2:2023` | `API STD 579-2, Part 2:2023` |

### Specification Format

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `API SPEC 17TR7:2023` | `API SPEC 17TR7:2023` |
| `API SPEC 17TR7:2023 (R2020)` | `API SPEC 17TR7:2023 (R2020)` |

### Recommended Practice Format

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `API RP 1104` | `API RP 1104` |
| `API RP 1104:2023` | `API RP 1104:2023` |

### Technical Report Format

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `API TR 12S1` | `API TR 12S1` |

### Bulletin Format

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `API BULL 2C2` | `API BULL 2C2` |

### MPMS Format

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `API MPMS CH 10.4A:2023` | `API MPMS CH 10.4A:2023` |
| `API MPMS CH 3.1A:2020` | `API MPMS CH 3.1A:2020` |
| `API MPMS CH 12.2.3:2023` | `API MPMS CH 12.2.3:2023` |

### Typeless Standard Format

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `API 6D:2023` | `API 6D:2023` |
| `API 6A` | `API 6A` |

### Continuous Operations Standard Format

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `API COS 1-15` | `API COS 1-15` |

### Publication Format

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `API PUBL 45` | `API PUBL 45` |

## Testing

### Test Coverage

- **Unit tests:** `spec/pubid_new/api/`
- **Parser tests:** `spec/pubid_new/api/parser_spec.rb`
- **Builder tests:** `spec/pubid_new/api/builder_spec.rb`
- **Identifier tests:** `spec/pubid_new/api/identifiers/`
- **Integration tests:** `spec/integration/api_`

### Fixtures

Located in: `spec/fixtures/api/identifiers/`

- **Pass tests:** `pass/` - Valid patterns that should parse successfully
  - `standard.txt` - Standard patterns
  - `mpms.txt` - MPMS patterns
  - `specification.txt` - SPEC patterns
  - `recommended_practice.txt` - RP patterns
- **Fail tests:** `fail/` - Invalid patterns that should raise errors
- **Full fixtures:** `full/identifiers.txt` - Complete pattern coverage

### Coverage Status

The API flavor has comprehensive test coverage with ~85%+ coverage for all identifier classes and rendering patterns.

## Design Characteristics

### MPMS Chapter Notation

API MPMS (Manual of Petroleum Measurement Standards) uses chapter notation:
- `CH 10.4A` - Chapter 10, section 4A
- `CH 12.2.3` - Chapter 12, section 2, subsection 3

Format: `CH {chapter}.{section}{subsection}`

### Alphanumeric Numbers

API numbers can be alphanumeric:
- `579` - Numeric only
- `6D` - Letter suffix
- `D16` - Letter prefix
- `17TR7` - Mixed alphanumeric
- `12S1` - Letter in middle

### Dual Date Formats

API supports two date formats:
- `:2023` - Colon separator (common)
- `-2023` - Dash separator (also used)

### Reaffirmation Notation

API uses parenthetical reaffirmation:
- `(R2020)` - Reaffirmed in 2020

### Edition Notation

API uses ordinal edition notation:
- `, 5th edition` - Fifth edition
- `, 2nd edition` - Second edition

### Part Notation

API supports part notation:
- `, Part 2` - Part 2

### Combined Identifiers

API supports combined identifiers:
- `API STD 579-2/API STD 620` - Two standards combined

## Comparison with ISO

| Feature | API | ISO |
|---------|-----|-----|
| Publisher | API | ISO (with copublishers) |
| Document types | 8 (STD, SPEC, RP, etc.) | 18+ (IS, TR, TS, etc.) |
| Stage codes | None | 15+ (PWI, NP, WD, CD, DIS, FDIS) |
| Supplements | None | 5 types (Amd, Cor, Add, Suppl, Ext) |
| Date format | :YYYY or -YYYY | :YYYY or (YYYY) |
| Number format | Alphanumeric (6D, D16, 17TR7) | Numeric with letter suffix |
| Reaffirmation | (RYYYY) | None |
| Edition notation | ", 5th edition" | Year-based |
| Special notation | MPMS CH 10.4A | Part notation (dash) |

## Migration Notes

### V1 to V2 Changes

**Major architectural changes:**
1. **Three-layer separation** - Parser, Builder, and Identifier are completely separate
2. **No typed stages** - API does not use formal stage codes like ISO/IEC
3. **Component-based Code** - Code component with number and part attributes
4. **Identifier class explosion** - 9 specialized identifier classes vs single generic identifier
5. **Type-based class selection** - Builder determines class based on parsed type code

**Breaking changes:**
- `Pubid::Api::Identifier` → `PubidNew::Api::Identifiers::*` (specific classes)
- `mpms_chapter` attribute split into `chapter`, `section`, `subsection`
- `reaffirmation` is now a string attribute (year only)
- `edition` and `part_number` are separate attributes

**Migration guide:**
1. Replace `Pubid::Api.parse()` with `PubidNew::Api.parse()`
2. Use specific identifier classes instead of generic `Identifier`
3. Access MPMS chapter via separate attributes: `identifier.chapter`, `identifier.section`, `identifier.subsection`
4. Access code attributes via `identifier.code` (Code component object)

## References

- **Specification:** API (American Petroleum Institute)
- **Examples:** API Standards (https://www.api.org/)
- **Related implementations:**
  - ISO flavor (similar three-layer architecture)
  - ASME flavor (similar industry-specific standards)

---

## Appendix: Design Decisions

### MPMS Chapter Notation

**Context:** MPMS uses chapter notation different from regular standards.

**Decision:** Create dedicated MPMS identifier class with chapter/section/subsection parsing.

**Rationale:**
- MPMS is unique format within API
- Chapter notation (CH 10.4A) needs special handling
- Section and subsection are optional
- Cleaner than combining with regular standards

**Alternatives considered:**
- Parse as regular standard - Rejected (loses structure)
- Use separate type code for each chapter - Rejected (too many variations)

### Alphanumeric Numbers

**Context:** API numbers can be alphanumeric (6D, D16, 17TR7).

**Decision:** Parse as string, preserve original format.

**Rationale:**
- Preserves exact format
- No semantic meaning to parts
- Simple string handling
- Flexible for future patterns

**Alternatives considered:**
- Parse into components (letter prefix, number, letter suffix) - Rejected (over-complication)
- Normalize to numeric - Rejected (loses information)

### Dual Date Formats

**Context:** API uses both colon and dash date separators.

**Decision:** Parse both formats in parser.

**Rationale:**
- Matches actual API practice
- Flexible parsing
- Can normalize in builder if needed
- No semantic difference between formats

**Alternatives considered:**
- Single format - Rejected (doesn't match practice)
- Normalize in preprocessing - Rejected (unnecessary)

### No Typed Stages

**Context:** API does not have formal stage codes like ISO/IEC (PWI, NP, WD, CD, DIS, FDIS).

**Decision:** Do not implement typed stages for API flavor.

**Rationale:**
- API standards move directly to published
- No intermediate formal stages
- Simpler implementation without unnecessary complexity
- Matches actual API practice

**Alternatives considered:**
- Invent typed stages - Rejected (not based in reality)
- Use ISO stages - Rejected (does not match API practice)

### Reaffirmation Notation

**Context:** API uses parenthetical reaffirmation notation ((R2020)).

**Decision:** Parse reaffirmation as separate attribute with year only.

**Rationale:**
- Preserves semantic meaning
- Year is the key information
- Simple string storage
- Clean rendering

**Alternatives considered:**
- Include as part of year - Rejected (mixes concepts)
- Ignore - Rejected (loses information)
- Store as full string with parentheses - Rejected (harder to work with)

### Edition and Part Notation

**Context:** API has both edition notation (", 5th edition") and part notation (", Part 2").

**Decision:** Parse as separate attributes.

**Rationale:**
- Different semantics (edition vs part)
- Clean separation
- Flexible rendering
- Matches API practice

**Alternatives considered:**
- Single "edition_or_part" attribute - Rejected (loses distinction)
- Parse into single text field - Rejected (loses structure)

### Combined Identifiers

**Context:** API sometimes combines two identifiers with / separator.

**Decision:** Return array of identifiers for combined notation.

**Rationale:**
- Preserves both identifiers
- Flexible handling
- Can be processed separately
- Matches actual API practice

**Alternatives considered:**
- Single identifier with combined attribute - Rejected (loses structure)
- Reject combined notation - Rejected (common practice)
