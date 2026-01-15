# AMCA Documentation

## Overview

The AMCA flavor handles identifiers for Air Movement and Control Association International standards and related documents. It supports AMCA's Standards, Publications, and Interpretations with copublisher support (ANSI, ASHRAE, etc.). The flavor handles various year formats (2-digit and 4-digit), reaffirmation years, revision codes, and interpretation codes.

## Architecture

This flavor follows the PubID v2 three-layer architecture pattern:

1. **Parser** (`parser.rb`) - Parslet PEG grammar for syntax parsing
   - Converts input strings into structured hash trees
   - Handles interpretation code patterns (JW, KB, RG, etc.)
   - Supports publication revision format (Rev. 01-23)
   - Returns parse tree with component keys

2. **Builder** (`builder.rb`) - Transforms parse trees to domain objects
   - Casts parsed hash values to component objects
   - Distinguishes between Publication, Interpretation, and Standard identifiers
   - Instantiates appropriate identifier class

3. **Identifier** (`identifiers/`) - Lutaml::Model domain classes with rendering logic
   - Base class for all identifier types
   - Standard, Publication, and Interpretation identifiers
   - Custom rendering for each type

## Components

### Flavor-Specific Components

| Component | File | Purpose | Attributes |
|-----------|------|---------|------------|
| N/A | N/A | AMCA uses shared components only | N/A |

### Shared Components Used

| Component | From | Purpose in this flavor |
|-----------|------|------------------------|
| `Code` | `lib/pubid_new/components/code.rb` | Generic string values (number, letter suffix) |
| `Date` | `lib/pubid_new/components/date.rb` | Year-based dates |

## Identifier Classes

### Base Identifiers

#### Standard

- **File:** `lib/pubid_new/amca/identifiers/standard.rb`
- **Parent:** `Base`
- **Purpose:** AMCA Standard documents representing consensus standards
- **Components Used:** `copublisher`, `code`, `year`, `suffix`, `reaffirmed`
- **Patterns Supported:**
  - `ANSI/AMCA 210-16` → Copublished standard with 2-digit year
  - `ANSI/AMCA Standard 99-25` → With "Standard" keyword
  - `AMCA Standard 803-02 (R2008)` → With reaffirmation
  - `ANSI/AMCA 500-D-18` → With letter suffix in code
  - `ANSI/AMCA 210-16 /ASHRAE 51-16` → With additional copublisher
- **TYPED_STAGES:** Not applicable (no typed stages for AMCA)
- **Rendering Formats:** Standard format only

#### Publication

- **File:** `lib/pubid_new/amca/identifiers/publication.rb`
- **Parent:** `Base`
- **Purpose:** AMCA Publications (manuals, guides, etc.)
- **Components Used:** `copublisher`, `code`, `year`, `revision`, `reaffirmed`
- **Patterns Supported:**
  - `AMCA Publication 211-22 (Rev. 01-23)` → With revision
  - `AMCA Publication 311-16` → Simple publication
  - `AMCA Publication 1011-03 (R2010)` → With reaffirmation
  - `AMCA Publication 511-21 (Rev. 12-22)` → With revision
- **TYPED_STAGES:** Not applicable (no typed stages for AMCA)
- **Rendering Formats:** Standard format only, special revision rendering

#### Interpretation

- **File:** `lib/pubid_new/amca/identifiers/interpretation.rb`
- **Parent:** `Base`
- **Purpose:** AMCA Interpretations of standards with letter codes (JW, KB, etc.) or year codes
- **Components Used:** `copublisher`, `code`, `year`, `interpretation_code`
- **Patterns Supported:**
  - `AMCA 99 JW Interp` → With 2-letter interpretation code
  - `AMCA 204 – 1` → With year interpretation code
  - `ANSI/AMCA 204 Interp` → Copublished interpretation
  - `AMCA 511 Interp` → Simple interpretation
- **TYPED_STAGES:** Not applicable (no typed stages for AMCA)
- **Rendering Formats:** Standard format only, special en-dash rendering

## Scheme Registry

The `Scheme` class (`lib/pubid_new/amca/scheme.rb`) is the central registry for this flavor.

### Registry Methods

- **`identifiers`** - Array of all registered identifier classes
  ```ruby
  def initialize
    @identifiers = [
      Identifiers::Standard,
      Identifiers::Publication,
      Identifiers::Interpretation,
    ].freeze
  end
  ```

- **`typed_stages`** - Not applicable (AMCA does not use typed stages)

- **`locate_typed_stage_by_abbr(abbr)`** - Not applicable (AMCA does not use typed stages)

- **`locate_identifier_klass_by_type_code(type_code)`** - Not applicable (AMCA does not use type codes)

### Parser Instance

```ruby
# Parser instance is created on-demand (not memoized in base Scheme)
```

## Rendering Examples

### Standard Format

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `ANSI/AMCA 210-16` | `ANSI/AMCA 210-16` |
| `AMCA Standard 803-02 (R2008)` | `AMCA Standard 803-02 (R2008)` |
| `AMCA Publication 211-22 (Rev. 01-23)` | `AMCA Publication 211-22 (Rev. 01-23)` |
| `AMCA 99 JW Interp` | `AMCA 99 – JW` |
| `ANSI/AMCA 204 Interp` | `ANSI/AMCA 204` |

### Other Formats

| Format | Rendered Output |
|--------|-----------------|
| Not applicable for AMCA | N/A |

## Parser Rules

### Main Rule

```ruby
rule(:identifier) do
  interpretation_identifier |
    publication_identifier |
    standard_identifier
end
```

### Component Rules

```ruby
# Copublisher (ANSI/AMCA or AMCA)
rule(:copublisher) do
  (str("ANSI") >> slash >> str("AMCA")) |
    (str("AMCA"))
end

# Code pattern (e.g., 210, 500-D, 99, 204)
rule(:code) do
  digits >> (dash >> letter).maybe >> (dot >> digits).maybe
end

# Type (Standard or Publication)
rule(:type) do
  str("Standard") | str("Publication")
end

# Year pattern (2 or 4 digits)
rule(:year_digits) do
  (str("19") | str("20")) >> digit.repeat(2, 2) |
    digit.repeat(2, 2)
end

# Publication revision (Rev. 01-23)
rule(:revision) do
  lparen >> str("Rev") >> dot.maybe >> space >>
    digits.as(:revision_year) >> dash >> digits >> rparen
end

# Interpretation code (JW, KB, RG, AW, AH, or number)
rule(:interpretation_code) do
  (letter.repeat(2).as(:interpretation_code)) |
    (digits.as(:interpretation_code))
end
```

### Special Patterns

```ruby
# Interpretation pattern (must come first - more specific)
rule(:interpretation_identifier) do
  copublisher.maybe >> space >> code >> space >>
    (interpretation_code >> interp_keyword |
     (str("–") | str("-")) >> digits.as(:interpretation_year) >> interp_keyword.maybe)
end

# Publication pattern (must come before standard)
rule(:publication_identifier) do
  copublisher.maybe >> space >>
    str("Publication").as(:publication_keyword) >> space >>
    code >> (dash >> year_digits.as(:year)).maybe >>
    (space >> revision).maybe >>
    (space >> reaffirmation).maybe
end

# Standard pattern (most general - must come last)
rule(:standard_identifier) do
  copublisher.maybe >> space >>
    type.as(:type).maybe >> space.maybe >>
    code >> (dash >> year_digits.as(:year)).maybe >>
    (space >> additional_copublisher).maybe >>
    suffix.maybe >> (space >> reaffirmation).maybe
end
```

## Builder Logic

### Identifier Class Selection

The Builder determines which identifier class to instantiate based on:

1. **Publication keyword** - If `:publication_keyword` or `:revision` exists → `Publication`
2. **Interpretation indicators** - If `:interpretation_code` or `:interp_keyword` exists → `Interpretation`
3. **Default** - `Standard`

### Component Casting

Special casting logic in Builder's `extract_attributes()` method:

```ruby
# Copublisher extraction
when :copublisher
  extract_value(parsed[:copublisher])

# Code extraction
when :code
  extract_value(parsed[:code])

# Year extraction (4-digit or 2-digit)
when :year
  extract_value(parsed[:year])

# Reaffirmation year (R2008, R2010)
when :reaffirmed
  extract_value(parsed[:reaffirmed])

# Revision year from Publication
when :revision
  # "Rev. 01-23" → revision="01"

# Interpretation code (JW, KB, etc.)
when :interpretation_code
  extract_value(parsed[:interpretation_code])
```

## Preprocessing

This flavor uses preprocessing to normalize input before parsing:

| Pattern | Input | Output | Purpose |
|---------|-------|--------|---------|
| Space normalization | `ANSI/AMCA   Standard` | `ANSI/AMCA Standard` | Normalize multiple spaces |
| En dash normalization | `AMCA 99 – JW` | `AMCA 99 - JW` | Normalize to regular dash |
| Trailing punctuation | `ANSI/AMCA 210.` | `ANSI/AMCA 210` | Remove trailing periods |

Preprocessing is **explicit** and minimal for AMCA.

## Testing

### Test Coverage

- **Unit tests:** `spec/pubid_new/amca/`
- **Parser tests:** `spec/pubid_new/amca/parser_spec.rb`
- **Builder tests:** `spec/pubid_new/amca/builder_spec.rb`
- **Identifier tests:** `spec/pubid_new/amca/identifiers/`
- **Integration tests:** `spec/integration/amca_`

### Fixtures

Located in: `spec/fixtures/amca/identifiers/`

- **Pass tests:** `pass/` - Valid patterns that should parse successfully
  - `standard.txt` - Standard identifier patterns
  - `publication.txt` - Publication patterns
  - `interpretation.txt` - Interpretation patterns
- **Full tests:** `full/` - Complete fixture sets
- **Fail tests:** `fail/` - Invalid patterns that should raise errors

### Coverage Status

The AMCA flavor has comprehensive test coverage with 92.0% pass rate:
- Interpretation: 100% (7/7)
- Publication: 100% (8/8)
- Standard: 100% (31/31)
- Unknown: 0% (0/4) - intentionally failing patterns

## Migration Notes

### V1 to V2 Changes

**Major architectural changes:**
1. **Three-layer separation** - Parser, Builder, and Identifier are completely separate
2. **Registry-based architecture** - Scheme class manages identifier class registration
3. **Component-based design** - Uses Code and Date components from shared library

**Breaking changes:**
- `Pubid::Amca::Identifier` → `PubidNew::Amca::Identifiers::*` (specific classes)

**Migration guide:**
1. Replace `Pubid::Amca.parse()` with `PubidNew::Amca.parse()`
2. Use specific identifier classes (Standard, Publication, Interpretation)

## References

- **Specification:** AMCA International (https://www.amca.org)
- **Examples:** AMCA Standards Catalog (https://www.amca.org/store)
- **Related implementations:**
  - ASHRAE flavor (similar copublisher patterns)
  - ANSI flavor (copublisher support)

---

## Appendix: Design Decisions

### No Typed Stages

**Context:** AMCA standards do not have formal development stage codes like ISO.

**Decision:** AMCA does not use TYPED_STAGES or typed stage logic.

**Rationale:**
- AMCA standards are either published or proposed
- No formal harmonized stage code system
- Simpler architecture without typed stage overhead

**Alternatives considered:**
- Add typed stages for consistency - Rejected (unnecessary complexity)

### Interpretation Code Format

**Context:** AMCA interpretations use various formats (2-letter codes, years, or none).

**Decision:** Parser supports multiple interpretation code formats explicitly.

**Rationale:**
- Real-world data uses different formats
- Letter codes (JW, KB, RG, AW, AH) identify interpretor
- Year codes identify interpretation year
- Some interpretations have no code at all

**Alternatives considered:**
- Normalize all to single format - Rejected (loses information)

### Publication Revision Format

**Context:** AMCA Publications use "Rev. MM-YY" format for revision tracking.

**Decision:** Store revision as year attribute in Publication class.

**Rationale:**
- Revision format is specific to Publications
- Simple year attribute is sufficient
- Custom rendering in Publication class handles format

**Alternatives considered:**
- Parse full "MM-YY" format - Rejected (over-complication)
- Separate Revision component - Rejected (unnecessary)
