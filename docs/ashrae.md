# ASHRAE Documentation

## Overview

The ASHRAE flavor handles identifiers for American Society of Heating, Refrigerating and Air-Conditioning Engineers standards and related documents. It supports ASHRAE's complete document lifecycle including Standards and Guidelines with full supplement support (Addenda, Errata, Interpretations, Combined Addenda, Addenda Packages). The flavor handles copublishers (ANSI, AMCA, etc.), reaffirmation years, and various suffix patterns (R for revision, P for proposed).

## Architecture

This flavor follows the PubID v2 three-layer architecture pattern:

1. **Parser** (`parser.rb`) - Parslet PEG grammar for syntax parsing
   - Converts input strings into structured hash trees
   - Handles complex addendum formats with 7 distinct patterns
   - Supports errata dates and interpretation formats
   - Returns parse tree with component keys

2. **Builder** (`builder.rb`) - Transforms parse trees to domain objects
   - Casts parsed hash values to component objects
   - Handles multiple addendum format variants (publisher_addendum, standard_addendum, etc.)
   - Instantiates appropriate identifier class based on type

3. **Identifier** (`identifiers/`) - Lutaml::Model domain classes with rendering logic
   - Base identifiers (SingleIdentifier) for standalone documents
   - Supplement identifiers (SupplementIdentifier) for addenda, errata, interpretations
   - Multi-format rendering support

## Components

### Flavor-Specific Components

| Component | File | Purpose | Attributes |
|-----------|------|---------|------------|
| N/A | N/A | ASHRAE uses shared components only | N/A |

### Shared Components Used

| Component | From | Purpose in this flavor |
|-----------|------|------------------------|
| `Code` | `lib/pubid_new/components/code.rb` | Generic string values (number, part, iteration) |
| `Date` | `lib/pubid_new/components/date.rb` | Year-based dates |
| `TypedStage` | `lib/pubid_new/components/typed_stage.rb` | Combined stage+type with rendering format support |

## Identifier Classes

### Base Identifiers

#### Standard

- **File:** `lib/pubid_new/ashrae/identifiers/standard.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** ASHRAE Standard documents representing consensus standards
- **Components Used:** `publisher`, `code`, `year`, `type`, `suffix`, `reaffirmed`, `copublisher`
- **Patterns Supported:**
  - `ASHRAE Standard 15-2024` → Standard with code and year
  - `ASHRAE Standard 90.1-2022` → Standard with dotted code
  - `ASHRAE Standard 41.10-2018` → Standard with two dotted parts
  - `ANSI/ASHRAE Standard 90.1-2019` → Copublished standard
  - `ASHRAE Standard 90A,B,C-2010` → Standard with letter code variants
  - `ASHRAE Standard 15-2013 (RA 2018)` → Standard with reaffirmation
  - `ASHRAE Standard 62.1-2016R` → Standard with revision suffix
- **TYPED_STAGES:** 3 stages:
  - `Standard`, `ASHRAE` (published) - Published Standard
  - `P` (proposed) - Proposed Standard
  - `R` (revision) - Revision Standard
- **Rendering Formats:** Standard format only

#### Guideline

- **File:** `lib/pubid_new/ashrae/identifiers/guideline.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** ASHRAE Guidelines providing best practices and recommendations
- **Components Used:** `publisher`, `code`, `year`, `type`, `suffix`, `reaffirmed`
- **Patterns Supported:**
  - `ASHRAE Guideline 0-2019` → Guideline with code and year
  - `ASHRAE Guideline 1.5` → Guideline with dotted code (no year)
  - `ASHRAE Guideline 4-2015 (RA 2020)` → Guideline with reaffirmation
- **TYPED_STAGES:** 3 stages:
  - `Guideline`, `ASHRAE` (published) - Published Guideline
  - `P` (proposed) - Proposed Guideline
  - `R` (revision) - Revision Guideline
- **Rendering Formats:** Standard format only

### Supplement Identifiers

#### Addendum

- **File:** `lib/pubid_new/ashrae/identifiers/addendum.rb`
- **Parent:** `SupplementIdentifier`
- **Purpose:** Addenda (a, b, c, ..., aa, ab, ...) modify or add to existing standards/guidelines
- **Components Used:** `base_identifier`, `addendum_code`, `addendum_date`
- **Patterns Supported:**
  - `ASHRAE Addendum a to Standard 15-2001` → Addendum to standard
  - `ASHRAE Addendum b to Guideline 1.4-2019` → Addendum to guideline
  - `ANSI/ASHRAE Addendum a to ANSI/ASHRAE Standard 15-2019` → Copublished addendum
  - `ASHRAE Standard 15-2013 Addendum a` → Alternative format
  - `ANSI/ASHRAE Addendum a to 34-2024` → Missing type keyword
  - `ASHRAE Addendum a to Standard 15-2001 (January 22, 2019)` → With date
- **TYPED_STAGES:** 1 stage:
  - `Addendum`, `Addenda` (published) - Published Addendum
- **Recursion:** Supports multi-level supplements
- **Rendering Formats:** Standard format only

#### Errata

- **File:** `lib/pubid_new/ashrae/identifiers/errata.rb`
- **Parent:** `SupplementIdentifier`
- **Purpose:** Errata correct errors in published standards
- **Components Used:** `base_identifier`, `errata_date`
- **Patterns Supported:**
  - `ASHRAE Guideline 0-2005 Errata (September 28, 2011)` → Errata with date
  - `ANSI/ASHRAE Standard 62.1-2004 Errata (May 4, 2007)` → Copublished errata
  - `ANSI/ASHRAE 51-1999 Errata (May 23, 2014)` → Missing type keyword
  - `ASHRAE Standard 105-2014 Errata (May 23, 2014) – Spanish Edition` → With descriptive text
- **TYPED_STAGES:** 1 stage:
  - `Errata` (published) - Published Errata
- **Recursion:** Not applicable (terminal)
- **Rendering Formats:** Standard format only

#### Interpretation

- **File:** `lib/pubid_new/ashrae/identifiers/interpretation.rb`
- **Parent:** `SupplementIdentifier`
- **Purpose:** Collections of interpretations for a base standard
- **Components Used:** `base_identifier`
- **Patterns Supported:**
  - `Interpretations for Standard 15.2-2022` → Interpretations for standard
  - `Interpretations for Standard 52.1-1992` → With year
- **TYPED_STAGES:** 1 stage:
  - `Interpretations` (published) - Published Interpretations
- **Recursion:** Not applicable (terminal)
- **Rendering Formats:** Standard format only

#### CombinedAddenda

- **File:** `lib/pubid_new/ashrae/identifiers/combined_addenda.rb`
- **Parent:** `SupplementIdentifier`
- **Purpose:** Multiple addendums grouped together (a, b, c, etc.)
- **Components Used:** `base_identifier`, `addendum_codes`, `connector`
- **Patterns Supported:**
  - `ASHRAE Addenda c and d to Standard 15-1994` → Two addendums combined
  - `ASHRAE Addenda f and h for Standard 15-2007` → With "for" connector
  - `ASHRAE Addenda a, b, c to Standard 90.1-2010` → Comma-separated codes
  - `ASHRAE Standard 52.2-1999: Addenda a, b, c` → Colon format
  - `ASHRAE Addenda to Standard 15-1994` → No specific codes
  - `ASHRAE Addenda a, b, c to 105-2007` → Missing type keyword
- **TYPED_STAGES:** 1 stage:
  - `Addenda`, `Combined Addenda` (published) - Published Combined Addenda
- **Recursion:** Not applicable (terminal)
- **Rendering Formats:** Standard format only

#### AddendaPackage

- **File:** `lib/pubid_new/ashrae/identifiers/addenda_package.rb`
- **Parent:** `SupplementIdentifier`
- **Purpose:** Collection packages containing multiple addendums
- **Components Used:** `base_identifier`, `package_description`
- **Patterns Supported:**
  - `ASHRAE Standard 52.2-1999: Addenda Supplement Package` → Standard package
  - `ASHRAE Standard 52.2-2007 Addenda Supplement Package` → Space variant
  - `ASHRAE Standard 62.2-2004: Addenda Supplement Package (PDF)` → With format suffix
  - `2021 Addenda Supplement Package to Standard 62.1-2019` → Year-first format
  - `2021 Supplement Addenda a, b, c to Standard 62.1-2016` → Year-first with codes
- **TYPED_STAGES:** 1 stage:
  - `Addenda Supplement Package`, `Addenda Package` (published) - Published Package
- **Recursion:** Not applicable (terminal)
- **Rendering Formats:** Standard format only

## Scheme Registry

The `Scheme` class (`lib/pubid_new/ashrae/scheme.rb`) is the central registry for this flavor.

### Registry Methods

- **`identifiers`** - Array of all registered identifier classes
  ```ruby
  IDENTIFIERS = [
    Identifiers::Guideline,
    Identifiers::Standard,
    Identifiers::Addendum,
    Identifiers::Interpretation,
    Identifiers::Errata,
    Identifiers::CombinedAddenda,
    Identifiers::AddendaPackage,
  ]
  ```

- **`typed_stages`** - Aggregate TYPED_STAGES from all identifier classes
  ```ruby
  def typed_stages
    identifiers.flat_map { |klass| klass::TYPED_STAGES }
  end
  ```

- **`locate_typed_stage_by_abbr(abbr)`** - Find stage by abbreviation
  - Returns `TypedStage` object or raises `ArgumentError`
  - Empty string or `nil` returns published stage (ASHRAE)
  - Supports abbreviation arrays

- **`locate_identifier_klass_by_type_code(type_code)`** - Select class by type code
  - Returns identifier class based on type_code from parsed data
  - Used by Builder to determine which class to instantiate

### Parser Instance

```ruby
def parser
  @parser ||= Parser.new  # Memoized for performance
end
```

## Rendering Examples

### Short Format (`:short`)

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `ASHRAE Standard 15-2024` | `ASHRAE Standard 15-2024` |
| `ASHRAE Guideline 0-2019` | `ASHRAE Guideline 0-2019` |
| `ANSI/ASHRAE Standard 90.1-2022` | `ANSI/ASHRAE Standard 90.1-2022` |
| `ASHRAE Addendum a to Standard 15-2001` | `ASHRAE Addendum a to Standard 15-2001` |
| `ASHRAE Standard 15-2013 Errata (July 6, 2021)` | `ASHRAE Standard 15-2013 Errata (July 6, 2021)` |

### MR Format (`:mr`)

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `ASHRAE Standard 15-2024` | `ASHRAE Standard 15-2024` |
| `ASHRAE Addendum a to Standard 15-2001` | `ASHRAE Addendum a to Standard 15-2001` |

### Long Format (`:long`)

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `ASHRAE Standard 15-2024` | `ASHRAE Standard 15-2024` |

### Abbreviated Format (`:abbrev`)

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| Not applicable for ASHRAE | N/A |

## Parser Rules

### Main Rule

```ruby
rule(:identifier) do
  errata_identifier |
    interpretation_identifier |
    combined_addenda_identifier |
    year_first_addenda_package_identifier |
    addenda_package_identifier |
    addendum_identifier |
    copublisher_patterns |
    standard_ashrae_pattern
end
```

### Component Rules

```ruby
# Publisher
rule(:publisher) { str("ASHRAE") }

# Type (Guideline or Standard)
rule(:type) do
  str("Guideline") | str("Standard")
end

# Code pattern (e.g., 15, 90.1, 41.10, 90A,B,C)
rule(:code) do
  digits >> (dot >> digits).repeat(0, 2) >>
    (letter >> (comma >> letter).repeat(0, 10)).maybe
end

# Code with year pattern (e.g., 34-2024, 62.1-2022)
rule(:code_with_year) do
  digits >> (dot >> digits).repeat(0, 2) >>
    (letter >> (comma >> letter).repeat(0, 10)).maybe >>
    dash >> year_digits.as(:year)
end

# Addendum code (a, b, ..., aa, ab, ..., aaa)
rule(:addendum_code) do
  letter.repeat(1, 3)
end

# Errata date pattern
rule(:errata_date) do
  lparen >> month_name >> space >> digit.repeat(1, 2) >>
    comma.maybe >> (space | comma.maybe) >> year_digits >> rparen
end
```

### Special Patterns

```ruby
# Reaffirmation pattern (RA YEAR or RA-YEAR)
rule(:reaffirmed) do
  (space.maybe >> lparen >> str("RA") >> space? >> reaffirmation_year >> rparen) |
    (space >> str("RA") >> space >> reaffirmation_year)
end

# Combined Addenda (7 formats supported)
rule(:combined_addenda_identifier) do
  # Format 1: ASHRAE Addenda X, Y and Z to Standard X-YYYY
  # Format 2: ASHRAE Standard X-YYYY: Addenda a, b, c
  # Format 3: Addenda a, b, c to Standard X-YYYY (no publisher)
  # Format 4: ASHRAE Addenda to Standard X-YYYY (no codes)
  # Format 5: ASHRAE Addenda a, b, c to 105-2007 (missing type)
  # Format 6: Addenda a, b, c to 105-2007 (no publisher, no type)
  # Format 7: ASHRAE Standard X-YYYY: Addenda a through z
end
```

## Builder Logic

### Identifier Class Selection

The Builder determines which identifier class to instantiate based on:

1. **Errata keyword** - If `:errata_keyword` exists → `Errata`
2. **Interpretation keyword** - If `:interpretation_identifier` exists → `Interpretation`
3. **Combined addenda** - If `:combined_addenda` exists → `CombinedAddenda`
4. **Addenda package** - If `:addenda_package` exists → `AddendaPackage`
5. **Addendum patterns** - Various patterns → `Addendum`
6. **Type attribute** - `Standard` or `Guideline` determines base class

### Component Casting

Special casting logic in Builder's `build()` method:

```ruby
# Publisher extraction
when :publisher
  extract_value(parsed[:publisher])

# Type extraction (defaults to "Standard")
when :type
  extract_value(parsed[:type]) || "Standard"

# Code with year (contains both code and year)
when :code_with_year
  # "34-2024" → code="34", year="2024"

# Reaffirmation year
when :reaffirmed
  # "(RA 2018)" → reaffirmed="2018"

# Copublisher
when :copublisher
  # "ANSI/ASHRAE" → copublisher="ANSI/ASHRAE"
```

## Preprocessing

This flavor uses preprocessing to normalize input before parsing:

| Pattern | Input | Output | Purpose |
|---------|-------|--------|---------|
| Space normalization | `ASHRAE   Standard` | `ASHRAE Standard` | Normalize multiple spaces |
| Reaffirmation normalization | `(RA2018)` | `(RA 2018)` | Add space after RA |
| Reaffirmation with dash | `RA-2018` | `RA 2018` | Normalize dash format |
| Trailing punctuation | `ASHRAE Standard 15.` | `ASHRAE Standard 15` | Remove trailing periods |
| Double parentheses | `Errata (July 6, 2021))` | `Errata (July 6, 2021)` | Fix typos |
| Addenda "and" normalization | `Addenda a and b` | `Addenda a, b` | Normalize to comma format |
| Addendum to Addenda | `Addendum a, b` | `Addenda a, b` | Pluralize for multiple codes |

Preprocessing is **explicit** and **format-preserving** - the original format is stored for exact reproduction during rendering.

## Testing

### Test Coverage

- **Unit tests:** `spec/pubid_new/ashrae/components/`
- **Parser tests:** `spec/pubid_new/ashrae/parser_spec.rb`
- **Builder tests:** `spec/pubid_new/ashrae/builder_spec.rb`
- **Identifier tests:** `spec/pubid_new/ashrae/identifiers/`
- **Integration tests:** `spec/integration/ashrae_`

### Fixtures

Located in: `spec/fixtures/ashrae/identifiers/`

- **Pass tests:** `pass/` - Valid patterns that should parse successfully
  - `base.txt` - Base identifier patterns (standards, guidelines)
  - `addendum.txt` - Addendum patterns (multiple formats)
  - `errata.txt` - Errata patterns
  - `interpretation.txt` - Interpretation patterns
  - `combined_addenda.txt` - Combined addenda patterns
- **Fail tests:** `fail/` - Invalid patterns that should raise errors

### Coverage Status

The ASHRAE flavor has comprehensive test coverage with 99.43% pass rate. All major identifier classes and rendering patterns are covered.

## Migration Notes

### V1 to V2 Changes

**Major architectural changes:**
1. **Three-layer separation** - Parser, Builder, and Identifier are completely separate
2. **Registry-based architecture** - Scheme class manages all type/stage lookups
3. **TYPED_STAGES array** - Replaces hash-based TYPE_MAP pattern
4. **Supplement identifier types** - Addendum, Errata, Interpretation as separate classes

**Breaking changes:**
- `Pubid::Ashrae::Identifier` → `PubidNew::Ashrae::Identifiers::*` (specific classes)
- Type attribute extracted from TYPED_STAGES instead of hardcoded

**Migration guide:**
1. Replace `Pubid::Ashrae.parse()` with `PubidNew::Ashrae.parse()`
2. Use specific identifier classes instead of generic `Identifier`
3. Access supplements via dedicated identifier classes

## References

- **Specification:** ASHRAE Standards Guidelines (https://www.ashrae.org/standards)
- **Examples:** ASHRAE Standards Catalog (https://www.ashrae.org/standards-research--technology/standards-guidelines)
- **Related implementations:**
  - AMCA flavor (similar copublisher patterns)
  - ANSI flavor (copublisher support)

---

## Appendix: Design Decisions

### Multiple Addendum Format Support

**Context:** ASHRAE addendums have 7 distinct format patterns in real-world usage.

**Decision:** Parser supports all 7 addendum format patterns explicitly.

**Rationale:**
- Real-world data uses multiple formats
- Formats are semantically equivalent but syntactically distinct
- Explicit pattern matching is more reliable than normalization

**Alternatives considered:**
- Normalize all to single format - Rejected (loses format information)
- Use fuzzy parsing - Rejected (less reliable)

### Combined Addenda Notation

**Context:** ASHRAE groups multiple addendums together (a, b, c) with various connectors.

**Decision:** CombinedAddenda class stores `addendum_codes` as comma-separated string.

**Rationale:**
- Preserves original notation
- Simple to render without complex logic
- Supports "and", comma, and "through" patterns

**Alternatives considered:**
- Array of codes - Rejected (loses connector information)
- Individual addendum objects - Rejected (over-complication)

### Code with Year Pattern

**Context:** Some ASHRAE identifiers omit the type keyword (e.g., "ANSI/ASHRAE 34-2024" instead of "ANSI/ASHRAE Standard 34-2024").

**Decision:** Parser supports `code_with_year` pattern for type-less identifiers.

**Rationale:**
- Real-world data frequently omits type keyword
- Default to "Standard" when type is missing
- Maintains backward compatibility

**Alternatives considered:**
- Require type keyword - Rejected (breaks real-world parsing)
- Use separate parser rule - Rejected (duplicate logic)
