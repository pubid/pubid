# CIE Documentation

## Overview

The CIE flavor handles identifiers for International Commission on Illumination standards and related documents. It supports CIE's unique dual-style system (legacy pre-2001 dash format vs current colon format), joint publications with ISO and IEC, supplements (-SPN notation), corrigenda (/CorN notation), conference publications, and various language code formats including translation years.

## Architecture

This flavor follows the PubID v2 three-layer architecture pattern:

1. **Parser** (`parser.rb`) - Parslet PEG grammar for syntax parsing
   - Converts input strings into structured hash trees
   - Handles legacy (-) and current (:) date separator detection
   - Supports complex code patterns (iteration, parts with dash/slash)
   - Returns parse tree with component keys

2. **Builder** (`builder.rb`) - Transforms parse trees to domain objects
   - Casts parsed hash values to component objects
   - Distinguishes between 9 identifier types
   - Instantiates appropriate identifier class

3. **Identifier** (`identifiers/`) - Lutaml::Model domain classes with rendering logic
   - Base identifiers (Standard, Conference)
   - Special identifiers (JointPublished, DualPublished, Identical, Bundle, Supplement, TutorialBundle)
   - Supplement identifiers (Corrigendum)

## Components

### Flavor-Specific Components

| Component | File | Purpose | Attributes |
|-----------|------|---------|------------|
| `Code` | `components/code.rb` | Generic string values with number | `number`, `parts`, `iteration` |
| `Language` | `components/language.rb` | Language codes with format preservation | `code`, `format` |

### Shared Components Used

| Component | From | Purpose in this flavor |
|-----------|------|------------------------|
| `Code` | `lib/pubid_new/components/code.rb` | Number values |
| `Language` | `lib/pubid_new/components/language.rb` | Language codes (E, F, G, DE, ES, CN, etc.) |
| `Type` | `lib/pubid_new/components/type.rb` | Document type (for ISO joint publications) |
| `Stage` | `lib/pubid_new/components/stage.rb` | Development stage (DIS, DS) |
| `TypedStage` | `lib/pubid_new/components/typed_stage.rb` | Combined stage+type for Standard |

## Identifier Classes

### Base Identifiers

#### Standard

- **File:** `lib/pubid_new/cie/identifiers/standard.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** CIE Standard documents with dual-style support (legacy vs current)
- **Components Used:** `code`, `language`, `stage`, `s_prefix`, `date_separator`
- **Patterns Supported:**
  - `CIE 001-1980` → Legacy format (dash separator, pre-2001)
  - `CIE 170-1:2005` → Current format (colon separator, 2001+)
  - `CIE 19/2:2005` → Part with slash separator
  - `CIE 006.1:1998` → Iteration with dot
  - `CIE S 014-4:2007` → With S prefix and part
  - `CIE DIS 025-SP1/E:2019` → Draft stage with supplement
  - `CIE 2003 (RU-2021)` → With translation year
  - `CIE 2003/E:2001` → Language with colon format
- **TYPED_STAGES:** Multiple stages for draft/published status
  - `DIS` (dis) - Draft International Standard
  - `DS` (ds) - Draft Standard
  - Published (empty abbr)
- **Rendering Formats:** Standard format with language handling

#### Conference

- **File:** `lib/pubid_new/cie/identifiers/conference.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** CIE Conference publications with x-prefix notation
- **Components Used:** `code`, `year`, `amendment`
- **Patterns Supported:**
  - `CIE x002:2018` → Conference with x-prefix
  - `CIE x019:2009` → Conference with year
  - `CIE x002:2018 Amendment 1` → Conference with amendment
- **TYPED_STAGES:** Not applicable (conferences are always published)
- **Rendering Formats:** Standard format only

#### JointPublished (with ISO)

- **File:** `lib/pubid_new/cie/identifiers/joint_published.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** CIE documents jointly published with ISO
- **Components Used:** `copublisher`, `doc_type`, `code`, `year`
- **Patterns Supported:**
  - `CIE ISO TR 1234:2005` → Joint with ISO Technical Report
  - `CIE ISO 1234:2005` → Joint with ISO
- **TYPED_STAGES:** Not applicable
- **Rendering Formats:** Standard format only

#### DualPublished (with IEC)

- **File:** `lib/pubid_new/cie/identifiers/dual_published.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** CIE documents dual published with IEC (slash separator)
- **Components Used:** `code`, `year`, `iec_identifier`
- **Patterns Supported:**
  - `CIE S 009:2002/IEC 62471:2006` → Dual published with IEC
- **TYPED_STAGES:** Not applicable
- **Rendering Formats:** Standard format only

#### Identical (with ISO)

- **File:** `lib/pubid_new/cie/identifiers/identical.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** CIE documents identical to ISO (parenthetical reference)
- **Components Used:** `s_prefix`, `code`, `iteration`, `part`, `year`, `iso_reference`
- **Patterns Supported:**
  - `CIE S 006.1/1998 (ISO 16508:1999)` → Identical with ISO
  - `CIE S 014-4/E:2007 (ISO 11664-4:2008(E))` → With language and ISO reference
- **TYPED_STAGES:** Not applicable
- **Rendering Formats:** Standard format with ISO reference

#### Bundle

- **File:** `lib/pubid_new/cie/identifiers/bundle.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** CIE document bundles (comma-separated identifiers)
- **Components Used:** `items` (array of document codes)
- **Patterns Supported:**
  - `CIE 188-SP1.1:2010, 189-SP1.1:2010` → Bundle of supplements
- **TYPED_STAGES:** Not applicable
- **Rendering Formats:** Comma-separated format

#### Supplement

- **File:** `lib/pubid_new/cie/identifiers/supplement.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** CIE supplement documents with -SPN notation
- **Components Used:** `base_number`, `supplement_number`, `supplement_part`, `year`
- **Patterns Supported:**
  - `CIE 025-SP1:2019` → Supplement 1
  - `CIE 198-SP1.4:2011` → Supplement with part
- **TYPED_STAGES:** Not applicable
- **Rendering Formats:** Dash-SPN format

#### TutorialBundle

- **File:** `lib/pubid_new/cie/identifiers/tutorial_bundle.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** CIE Tutorial Bundles
- **Components Used:** `bundle_number`
- **Patterns Supported:**
  - `CIE Tutorials Bundle 1` → Tutorial Bundle
- **TYPED_STAGES:** Not applicable
- **Rendering Formats:** Standard format

### Supplement Identifiers

#### Corrigendum

- **File:** `lib/pubid_new/cie/identifiers/corrigendum.rb`
- **Parent:** `SupplementIdentifier`
- **Purpose:** CIE Corrigenda with /CorN notation
- **Components Used:** `base_number`, `base_year`, `base_supplement`, `base_supplement_part`, `cor_number`, `cor_year`
- **Patterns Supported:**
  - `CIE 232:2019/Cor1:2020` → Corrigendum 1
  - `CIE 198-SP1.4:2011/Cor1:2013` → Corrigendum to supplement
- **TYPED_STAGES:** Not applicable
- **Recursion:** Supports corrigenda to supplements
- **Rendering Formats:** Slash-CorN format

## Scheme Registry

The `Scheme` class (`lib/pubid_new/cie/scheme.rb`) is the central registry for this flavor.

### Registry Methods

- **`identifiers`** - Array of all registered identifier classes
  ```ruby
  def identifiers
    [
      Identifiers::Standard,
      Identifiers::Conference,
      Identifiers::Bundle,
      Identifiers::DualPublished,
      Identifiers::Identical,
      Identifiers::JointPublished,
      Identifiers::Supplement,
      Identifiers::TutorialBundle,
    ]
  end
  ```

- **`supplement_identifiers`** - Array of supplement classes
  ```ruby
  def supplement_identifiers
    [Identifiers::Corrigendum]
  end
  ```

- **`typed_stages`** - Aggregate TYPED_STAGES from identifier classes
  ```ruby
  def typed_stages
    identifiers.flat_map { |klass| klass::TYPED_STAGES }
  end
  ```

- **`locate_typed_stage_by_abbr(abbr)`** - Find stage by abbreviation
  - Returns `TypedStage` object or raises `ArgumentError`
  - Empty string returns published stage

- **`locate_identifier_klass_by_type_code(type_code)`** - Select class by type code
  - Returns identifier class based on type_code

### Parser Instance

```ruby
# Parser instance is created on-demand (not memoized in Scheme)
```

## Rendering Examples

### Standard Format

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `CIE 170-1:2005` | `CIE 170-1:2005` |
| `CIE 001-1980` | `CIE 001-1980` |
| `CIE S 014-4/E:2007` | `CIE S 014-4/E:2007` |
| `CIE 009:2002/IEC 62471:2006` | `CIE 009:2002/IEC 62471:2006` |
| `CIE 232:2019/Cor1:2020` | `CIE 232:2019/Cor1:2020` |

### Other Formats

| Format | Rendered Output |
|--------|-----------------|
| Not applicable for CIE | N/A |

## Parser Rules

### Main Rule

```ruby
rule(:identifier) do
  tutorial_bundle |
    bundle_identifier |
    joint_with_iso_cie |
    joint_with_iso |
    joint_with_iec |
    identical_with_iso |
    dis_with_supplement |
    dual_with_iec |
    corrigendum_identifier |
    supplement_identifier |
    standard_with_language_year |
    legacy_code_with_year |
    conference_identifier |
    standard_identifier
end
```

### Component Rules

```ruby
# Date with separator detection (CRITICAL for style)
# Legacy: dash "-" (pre-2001)
# Current: colon ":" (2001+)
rule(:legacy_date) do
  (dash >> year_digits.as(:year)).as(:legacy_date)
end

rule(:current_date) do
  (colon >> year_digits.as(:year)).as(:current_date)
end

# Code patterns (longest match first)
rule(:code) do
  code_with_part_and_iteration_slash |  # 19/2.1
    code_with_part_and_iteration_dash |   # 19-2.1
    code_with_iteration |                  # 006.1
    code_with_part_slash |                 # 170/1
    code_with_part_dash |                  # 170-1
    code_simple                             # 001
end

# Language patterns
rule(:language) do
  language_paren_year |  # (RU-2021)
    language_paren |      # (DE), (ES)
    language_slash        # /E, /F
end
```

### Special Patterns

```ruby
# Corrigendum identifier (/CorN notation)
rule(:corrigendum_identifier) do
  str("CIE") >> space >>
    digits.as(:base_number) >>
    # Could have supplement notation before corrigendum
    (dash >> str("SP") >> digits >>
     (dot >> digits).maybe).maybe >>
    colon >> year_digits.as(:base_year) >>
    # Corrigendum portion
    slash >> str("Cor") >> digits.as(:cor_number) >>
    colon >> year_digits.as(:cor_year)
end

# Identical with ISO (parenthetical reference)
rule(:identical_with_iso) do
  str("CIE") >> space >>
    s_prefix.maybe >>
    digits.as(:number) >>
    # Can have iteration (.1) OR part (-4)
    ((dot >> digits) | (dash >> digits)).maybe >>
    # Slash handling - three mutually exclusive patterns
    slash >> (
      (upper >> colon >> year_digits) |    # /E:2001
      (upper >> year_digits) |              # /E2007
      year_digits                            # /1998
    ).maybe >>
    # ISO reference
    space >> str("(ISO") >> space >>
    match("[0-9A-Z:/.\\-]").repeat(1) >>
    str("(") >> match("[A-Z]").repeat(1) >> str(")").maybe >>
    str(")")
end
```

## Builder Logic

### Identifier Class Selection

The Builder determines which identifier class to instantiate based on:

1. **Corrigendum pattern** - If `:cor_number` exists → `Corrigendum`
2. **Supplement pattern** - If `:supplement_number` exists → `Supplement`
3. **Conference pattern** - If `:conference` exists → `Conference`
4. **Joint/Dual/Identical patterns** - Based on copublisher and reference format
5. **Default** - `Standard`

### Component Casting

Special casting logic in Builder's `cast()` method:

```ruby
# Code extraction
when :number
  Components::Code.new(value: extract_value(parsed[:number]))

# Language extraction with format detection
when :language
  # Preserves format: slash, paren, or paren_year

# Stage detection
when :stage
  # DIS, DS detection for draft status

# Date separator detection
when :legacy_date
  # Dash separator = legacy (pre-2001)
when :current_date
  # Colon separator = current (2001+)
```

## Preprocessing

This flavor uses preprocessing to normalize input before parsing:

| Pattern | Input | Output | Purpose |
|---------|-------|--------|---------|
| Comment removal | `CIE 001 # comment` | `CIE 001` | Remove comments |
| Space normalization | `CIE   001` | `CIE 001` | Normalize spaces |
| Colon insertion | `CIE 014/E2007` | `CIE 014/E:2007` | Fix missing colon in language patterns |

Preprocessing is **explicit** and fixes common data quality issues.

## Testing

### Test Coverage

- **Unit tests:** `spec/pubid_new/cie/`
- **Parser tests:** `spec/pubid_new/cie/parser_spec.rb`
- **Builder tests:** `spec/pubid_new/cie/builder_spec.rb`
- **Identifier tests:** `spec/pubid_new/cie/identifiers/`
- **Integration tests:** `spec/integration/cie_`

### Fixtures

Located in: `spec/fixtures/cie/identifiers/`

- **Pass tests:** `pass/` - Valid patterns that should parse successfully
- **Fail tests:** `fail/` - Invalid patterns that should raise errors

### Coverage Status

The CIE flavor has comprehensive test coverage for all 9 identifier types including legacy and current formats.

## Migration Notes

### V1 to V2 Changes

**Major architectural changes:**
1. **Three-layer separation** - Parser, Builder, and Identifier are completely separate
2. **Nine identifier types** - Separate classes for each publication type
3. **Dual-style detection** - Explicit handling of legacy vs current formats

**Breaking changes:**
- `Pubid::Cie::Identifier` → `PubidNew::Cie::Identifiers::*` (specific classes)
- Date separator explicitly stored for rendering

**Migration guide:**
1. Replace `Pubid::Cie.parse()` with `PubidNew::Cie.parse()`
2. Use specific identifier classes for each type
3. Handle dual-style formats (legacy dash vs current colon)

## References

- **Specification:** CIE Publications (https://cie.co.at/)
- **Examples:** CIE Webshop (https://www.techstreet.com/cie/)
- **Related implementations:**
  - ISO flavor (joint publication patterns)
  - IEC flavor (dual publication patterns)

---

## Appendix: Design Decisions

### Dual-Style System (Legacy vs Current)

**Context:** CIE changed date separator from dash (-) to colon (:) in 2001. Both formats are still used.

**Decision:** Parser explicitly detects and preserves date separator format.

**Rationale:**
- Legacy format (pre-2001) uses dash: CIE 001-1980
- Current format (2001+) uses colon: CIE 170-1:2005
- Date separator indicates document style
- Must preserve original format for rendering

**Alternatives considered:**
- Normalize to single format - Rejected (loses style information)
- Use year to determine format - Rejected (ambiguous boundary)

### Language Format Variants

**Context:** CIE uses multiple language code formats: /E, (DE), (RU-2021)

**Decision:** Language component has `format` attribute to preserve variant.

**Rationale:**
- Slash format (/E, /F) is legacy
- Parenthetical format (DE, ES) is current
- Translation year format (RU-2021) includes year
- Format must be preserved for accurate rendering

**Alternatives considered:**
- Normalize to single format - Rejected (loses information)
- Store as plain string - Rejected (no structure)

### Nine Identifier Types

**Context:** CIE has many publication patterns that don't fit the base/supplement model.

**Decision:** Separate identifier classes for each publication pattern.

**Rationale:**
- Conference (x-prefix) is structurally unique
- JointPublished, DualPublished, Identical have different copublisher patterns
- Bundle, Supplement, TutorialBundle are distinct publication types
- MECE principle - each class handles mutually exclusive patterns

**Alternatives considered:**
- Single class with flags - Rejected (too many flags)
- Supplment class for all - Rejected (violates MECE)
