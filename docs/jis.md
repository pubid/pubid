# JIS Documentation

## Overview

The JIS flavor handles identifiers for Japanese Industrial Standards (JIS) published by the Japanese Industrial Standards Committee. It supports JIS's complete identifier ecosystem including 3 distinct document types (JapaneseIndustrialStandard, TechnicalReport, TechnicalSpecification) with full 4-digit year support, multi-level part numbering, Japanese character normalization, and supplement identifiers (amendments and explanations). The flavor handles both Japanese and English rendering formats with language code suffixes.

## Architecture

This flavor follows the PubID v2 three-layer architecture pattern:

1. **Parser** (`parser.rb`) - Parslet PEG grammar for syntax parsing
   - Converts input strings into structured hash trees
   - Handles Japanese character normalization (full-width to half-width)
   - Supports type prefixes (TR, TS) with optional slash separator
   - Parses multi-level parts (-1, -2-1, -3-2-1)
   - Handles language codes ((E), (J), (E/J))
   - Parses Japanese "規格群" (all parts) notation
   - Supports supplement identifiers (AMENDMENT, EXPLANATION)

2. **Builder** (`builder.rb`) - Transforms parse trees to domain objects via Scheme registry
   - Casts parsed hash values to component objects
   - Uses Scheme registry for type lookups via `locate_typed_stage_by_abbr()`
   - Instantiates appropriate identifier class via `locate_identifier_klass_by_type_code()`
   - Handles special cases: type prefix detection, supplement wrapping

3. **Identifier** (`identifiers/`) - Lutaml::Model domain classes with rendering logic
   - Base identifiers (SingleIdentifier) for standalone documents
   - Supplement identifiers (SupplementIdentifier) for amendments/explanations
   - Multi-format rendering support (:short, :long, :abbrev)
   - Japanese character handling

## Components

### Flavor-Specific Components

| Component | File | Purpose | Attributes |
|-----------|------|---------|------------|
| None | N/A | JIS uses shared components | N/A |

### Shared Components Used

| Component | From | Purpose in this flavor |
|-----------|------|------------------------|
| `Publisher` | `lib/pubid_new/components/publisher.rb` | Organization name (JIS) |
| `Code` | `lib/pubid_new/components/code.rb` | Generic string values (number, parts) |
| `Date` | `lib/pubid_new/components/date.rb` | 4-digit year dates |
| `Type` | `lib/pubid_new/components/type.rb` | Document type (JIS, TR, TS) |
| `Language` | `lib/pubid_new/components/language.rb` | Language codes (E, J, E/J) with original_code preservation |
| `TypedStage` | `lib/pubid_new/components/typed_stage.rb` | Combined stage+type with rendering format support |

## Identifier Classes

### Base Identifiers

#### JapaneseIndustrialStandard

- **File:** `lib/pubid_new/jis/identifiers/japanese_industrial_standard.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** The primary JIS document type representing Japanese Industrial Standards. This is the default type when no type prefix is specified.
- **Components Used:** `publisher`, `type`, `series`, `number`, `part`, `date`, `languages`
- **Patterns Supported:**
  - `JIS A 0001:1999` → Standard with series letter A and 4-digit year
  - `JIS A 0005:1966` → Standard from 1960s
  - `JIS B 0060-1:2015` → Standard with single part
  - `JIS Z 8301:2019` → Standard with series Z
  - `JIS A 0015:1976` → Standard from 1970s
- **TYPED_STAGES:** 1 stage:
  - `JIS` (pubjis) - Published Japanese Industrial Standard (default, empty abbr)
- **Rendering Formats:** All formats supported (:short, :long, :abbrev)
- **Special Features:**
  - No type prefix in rendering (JIS is implicit)
  - 4-digit year format (no 2-digit conversion)
  - Series letter (A, B, Z, etc.) required
  - Multi-level parts supported (-1, -2-1, -3-2-1)
  - Language codes: (E), (J), (E/J)

#### TechnicalReport

- **File:** `lib/pubid_new/jis/identifiers/technical_report.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** Technical Reports containing collected data or information. Used for informative documents that are not full standards.
- **Components Used:** `publisher`, `type`, `series`, `number`, `part`, `date`, `languages`
- **Patterns Supported:**
  - `JIS TR Z 8301:2019` → Technical Report with series Z
  - `JIS/TR Z 8302:2020` → Technical Report with slash separator
  - `JIS TR A 0001:2021` → Technical Report with series A
- **TYPED_STAGES:** 1 stage:
  - `TR` (pubjis) - Published Technical Report
- **Rendering Formats:** All formats supported
- **Special Features:**
  - `TR` type prefix rendered before series letter
  - Optional slash separator (JIS TR vs JIS/TR)
  - Same structure as JapaneseIndustrialStandard

#### TechnicalSpecification

- **File:** `lib/pubid_new/jis/identifiers/technical_specification.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** Technical Specifications for documents still under development or with limited stability.
- **Components Used:** `publisher`, `type`, `series`, `number`, `part`, `date`, `languages`
- **Patterns Supported:**
  - `JIS TS Z 0030-1:2017` → Technical Specification with part
  - `JIS/TS Z 0030-2:2018` → Technical Specification with slash separator
  - `JIS TS R 0001:2019` → Technical Specification with series R
- **TYPED_STAGES:** 1 stage:
  - `TS` (pubjis) - Published Technical Specification
- **Rendering Formats:** All formats supported
- **Special Features:**
  - `TS` type prefix rendered before series letter
  - Optional slash separator (JIS TS vs JIS/TS)
  - Same structure as JapaneseIndustrialStandard

### Supplement Identifiers

#### Amendment

- **File:** `lib/pubid_new/jis/identifiers/amendment.rb`
- **Parent:** `SupplementIdentifier`
- **Purpose:** Amendments (AMENDMENT or AMD) modify or add to an existing base standard.
- **Components Used:** `base_identifier`, `number`, `date`
- **Patterns Supported:**
  - `JIS A 0001:1999/AMENDMENT 1:2015` → Standard with amendment
  - `JIS A 0001:1999/AMD 1:2015` → Standard with amendment (abbreviated)
  - `JIS Z 8301:2019/AMENDMENT 2:2020` → Technical report with amendment
- **TYPED_STAGES:** Not applicable (supplement doesn't have stages)
- **Recursion:** Not supported (JIS amendments don't amend other amendments)
- **Rendering Formats:** All formats supported
- **Special Features:**
  - `AMENDMENT` or `AMD` keyword after base identifier
  - Amendment number required (1, 2, etc.)
  - Amendment year required (4-digit format)
  - Slash separator between base and amendment

#### Explanation

- **File:** `lib/pubid_new/jis/identifiers/explanation.rb`
- **Parent:** `SupplementIdentifier`
- **Purpose:** Explanations (EXPLANATION or EXPL) provide additional information about existing standards.
- **Components Used:** `base_identifier`, `number` (optional), `date`
- **Patterns Supported:**
  - `JIS A 0001:1999/EXPLANATION` → Standard with explanation (no number)
  - `JIS A 0001:1999/EXPL` → Standard with explanation (abbreviated)
  - `JIS A 0001:1999/EXPLANATION 1` → Standard with numbered explanation
- **TYPED_STAGES:** Not applicable (supplement doesn't have stages)
- **Recursion:** Not supported
- **Rendering Formats:** All formats supported
- **Special Features:**
  - `EXPLANATION` or `EXPL` keyword after base identifier
  - Number is optional (explanations may not be numbered)
  - No year required for explanations

## Scheme Registry

The `Scheme` class (`lib/pubid_new/jis/scheme.rb`) is the central registry for this flavor.

### Registry Methods

- **`identifiers`** - Array of all registered identifier classes
  ```ruby
  def identifiers
    [
      Identifiers::Standard,
      Identifiers::TechnicalReport,
      Identifiers::TechnicalSpecification,
    ]
  end
  ```

- **`typed_stages`** - Aggregate TYPED_STAGES from all identifier classes
  ```ruby
  def typed_stages
    identifiers.flat_map { |klass| klass::TYPED_STAGES }
  end
  ```

- **`locate_typed_stage_by_abbr(abbr)`** - Find stage by abbreviation
  - Returns `TypedStage` object or raises `ArgumentError`
  - Empty string (`""`) or `nil` returns published JIS (default)
  - `TR` returns TechnicalReport stage
  - `TS` returns TechnicalSpecification stage

- **`locate_identifier_klass_by_type_code(type_code)`** - Select class by type code
  - Returns identifier class based on type_code
  - `:jis` → `Identifiers::Standard` (JapaneseIndustrialStandard)
  - `:jis` with type prefix → TR or TS class based on prefix

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
| `JIS A 0001:1999` | `JIS A 0001:1999` |
| `JIS TR Z 8301:2019` | `JIS TR Z 8301:2019` |
| `JIS TS Z 0030-1:2017` | `JIS TS Z 0030-1:2017` |
| `JIS A 0001:1999/AMENDMENT 1:2015` | `JIS A 0001:1999/AMENDMENT 1:2015` |

### Long Format (`:long`)

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `JIS A 0001:1999` | `JIS A 0001:1999` |
| `JIS TR Z 8301:2019` | `JIS TR Z 8301:2019` |

### Abbreviated Format (`:abbrev`)

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `JIS A 0001:1999` | `JIS A 0001:1999` |

## Parser Rules

### Main Rule

```ruby
rule(:identifier) do
  jis_prefix.maybe >>
    type_prefix.maybe >>
    space.maybe >>
    series >>
    space.maybe >>
    number >>
    parts >>
    year.maybe >>
    language.maybe >>
    all_parts.maybe >>
    supplement.maybe
end
```

### Component Rules

```ruby
# Japanese character normalization
rule(:jp_dash) { str("ｰ") } # Full-width dash
rule(:jp_space) { str("　") }  # Full-width space
rule(:jp_colon) { str("：") }  # Full-width colon
rule(:jp_lparen) { str("（") }
rule(:jp_rparen) { str("）") }

# Normalized separators
rule(:dash) { (str("-") | jp_dash).as(:dash) }
rule(:space) { (str(" ") | jp_space) }
rule(:colon) { (str(":") | jp_colon) }

# JIS prefix (optional, handles both "JIS " and "JIS/")
rule(:jis_prefix) { str("JIS") >> (space | str("/")).maybe }

# Type prefix (TR or TS, can come with or without slash)
rule(:type_prefix) do
  (str("TR") | str("TS")).as(:type) >> (space | str("/"))
end

# Series letter
rule(:series) { letter.as(:series) }

# Number (preserve as string to maintain leading zeros)
rule(:number) { digits.as(:number) }

# Parts (multi-level: -1, -2-1, -3-2-1, etc.)
rule(:part) do
  dash >> digits.as(:part)
end

rule(:parts) { part.repeat(0).as(:parts) }

# Year
rule(:year) do
  colon >> digits.as(:year)
end

# Language code
rule(:language) do
  (str("(") | jp_lparen) >>
    match["EJ"].as(:language) >>
    (str(")") | jp_rparen)
end

# All-parts notation (Japanese)
rule(:all_parts) do
  ((jp_lparen >> str("規格群") >> jp_rparen) |
   (str("(") >> str("規格群") >> str(")"))).as(:all_parts)
end

# Amendment supplement
rule(:amendment) do
  str("/") >>
    (str("AMENDMENT") | str("AMD")).as(:amd_type) >>
    space >>
    digits.as(:amd_number) >>
    colon >>
    digits.as(:amd_year)
end

# Explanation supplement
rule(:explanation) do
  str("/") >>
    (str("EXPLANATION") | str("EXPL")).as(:expl_type) >>
    (space >> digits.as(:expl_number)).maybe
end
```

## Builder Logic

### Identifier Class Selection

The Builder determines which identifier class to instantiate based on:

1. **Supplement presence** - If `:amendment` or `:explanation` exists → supplement class
2. **Type prefix** - `TR` → TechnicalReport, `TS` → TechnicalSpecification
3. **No type prefix** - JapaneseIndustrialStandard (default)

### Type Code Mappings

| Type Code | Identifier Class |
|-----------|------------------|
| `:jis` | `Standard` (JapaneseIndustrialStandard) |
| `:jis` with `TR` prefix | `TechnicalReport` |
| `:jis` with `TS` prefix | `TechnicalSpecification` |

### Component Casting

Special casting logic in Builder:

```ruby
# Number (preserves leading zeros)
when :number
  parsed_hash[:number].to_s

# Parts (array of part numbers)
when :parts
  parsed_hash[:parts]&.map { |p| p[:part].to_s }

# Year (4-digit, no conversion)
when :year
  parsed_hash[:year].to_s

# Type (from prefix or default)
when :type
  parsed_hash[:type].to_s  # "TR" or "TS" or nil

# Series letter
when :series
  parsed_hash[:series].to_s

# Language code
when :language
  Language.new(code: parsed_hash[:language].to_s, original_code: parsed_hash[:language].to_s)
```

## Preprocessing

This flavor handles Japanese character normalization during parsing:

| Pattern | Input | Output | Purpose |
|---------|-------|--------|---------|
| Full-width dash | `ｰ` | `-` | Normalize to ASCII dash |
| Full-width space | `　` | ` ` | Normalize to ASCII space |
| Full-width colon | `：` | `:` | Normalize to ASCII colon |
| Full-width parens | `（` `）` | `(` `)` | Normalize to ASCII parens |

## Testing

### Test Coverage

- **Unit tests:** `spec/pubid_new/jis/components/`
- **Parser tests:** `spec/pubid_new/jis/parser_spec.rb`
- **Builder tests:** `spec/pubid_new/jis/builder_spec.rb`
- **Identifier tests:** `spec/pubid_new/jis/identifiers/`
- **Integration tests:** `spec/integration/jis_`

### Fixtures

Located in: `spec/fixtures/jis/identifiers/`

- **Pass tests:** `pass/` - Valid patterns that should parse successfully
  - `japanese_industrial_standard.txt` - Base standard patterns
  - `technical_report.txt` - Technical Report patterns
  - `technical_specification.txt` - Technical Specification patterns
- **Fail tests:** `fail/` - Invalid patterns that should raise errors

### Coverage Status

The JIS flavor has **100% test coverage** with 10,555 pass fixtures and 0 failures. All identifier classes are fully covered.

## Migration Notes

### V1 to V2 Changes

**Major architectural changes:**
1. **Three-layer separation** - Parser, Builder, and Identifier are completely separate
2. **Registry-based architecture** - Scheme class manages type lookups
3. **TYPED_STAGES array** - Simplified to single stage per identifier type
4. **Japanese character normalization** - Handled in parser rules
5. **Multi-level parts** - Proper array handling for nested parts

**Breaking changes:**
- `Pubid::Jis::Identifier` → `PubidNew::Jis::Identifiers::*` (specific classes)
- Type prefix now determines class (TR/TS)
- Supplements use separate identifier classes

**Migration guide:**
1. Replace `Pubid::Jis.parse()` with `PubidNew::Jis.parse()`
2. Use specific identifier classes instead of generic `Identifier`
3. Japanese characters are automatically normalized
4. Access supplements via `base_identifier` attribute

## References

- **Specification:** Japanese Industrial Standards Committee (JISC)
- **Examples:** JIS Standard Search (https://www.jisc.go.jp/)
- **Related implementations:**
  - ISO flavor (similar structure with TR/TS types)
  - KS flavor (Korean standards, similar structure)

---

## Appendix: Design Decisions

### Simplified Typed Stages

**Context:** ISO has multiple stages per document type (WD, CD, DIS, etc.).

**Decision:** JIS uses single published stage per identifier type.

**Rationale:**
- JIS standards are published (no development stages in identifiers)
- TR and TS are document types, not stages
- Simpler architecture without stage complexity
- Type prefix (TR, TS) determines class, not stage

**Alternatives considered:**
- Use multi-stage system like ISO - Rejected (JIS doesn't have stages)
- Use type codes without stages - Selected approach

### Type Prefix Determines Class

**Context:** JIS has 3 document types distinguished by prefix (TR, TS, or none).

**Decision:** Type prefix in identifier determines which class to instantiate.

**Rationale:**
- `TR` prefix → TechnicalReport class
- `TS` prefix → TechnicalSpecification class
- No prefix → JapaneseIndustrialStandard class
- Clear separation of concerns
- Easy to extend with new types

**Alternatives considered:**
- Single class with type attribute - Rejected (less clear)
- Use type codes only - Rejected (class-based is more extensible)

### Japanese Character Normalization

**Context:** JIS identifiers may use full-width Japanese characters (ｰ,　,：, （, ）).

**Decision:** Normalize full-width characters to half-width during parsing.

**Rationale:**
- Full-width and half-width are semantically identical
- Normalization simplifies parsing and rendering
- Original format can be preserved if needed via attributes
- Consistent handling across all JIS identifiers

**Alternatives considered:**
- Preserve full-width characters - Rejected (complex parsing)
- Reject full-width characters - Rejected (user-hostile)

### 4-Digit Year Format

**Context:** CSA uses 2-digit years, ISO uses 4-digit years.

**Decision:** JIS uses 4-digit year format only (no conversion).

**Rationale:**
- JIS has used 4-digit years consistently
- No ambiguity about century
- Simpler rendering (no conversion logic)
- Matches JISC official format

**Alternatives considered:**
- Support 2-digit years - Rejected (not used in practice)
- Auto-convert 2-digit to 4-digit - Rejected (unnecessary complexity)

### Multi-Level Parts

**Context:** JIS standards can have multi-level parts (e.g., -1, -2-1, -3-2-1).

**Decision:** Store parts as array of strings, render with dash separator.

**Rationale:**
- Parts are hierarchical but rendered linearly
- Array storage preserves structure
- Dash-separated rendering matches JIS format
- Extensible to arbitrary nesting depth

**Alternatives considered:**
- Store as single string - Rejected (loses structure)
- Use nested objects - Rejected (overkill for simple hierarchy)
