# IDF Documentation

## Overview

The IDF flavor handles identifiers for International Dairy Federation standards and related documents. It supports IDF's complete document lifecycle including International Standards and Reviewed Methods with full harmonized stage code support (similar to ISO/IEC), supplement identifiers (Amendments and Corrigenda), and multi-level supplement recursion. The flavor uses slash notation for supplements (IDF 148-1:2008 / COR 1:2009).

## Architecture

This flavor follows the PubID v2 three-layer architecture pattern:

1. **Parser** (`parser.rb`) - Parslet PEG grammar for syntax parsing
   - Converts input strings into structured hash trees
   - Uses shared common parse rules and methods
   - Handles alphanumeric numbers (IDF 125A:1988)
   - Returns parse tree with component keys

2. **Builder** (`builder.rb`) - Transforms parse trees to domain objects via shared base builder
   - Uses common parse methods from shared library
   - Casts parsed hash values to component objects
   - Instantiates appropriate identifier class

3. **Identifier** (`identifiers/`) - Lutaml::Model domain classes with rendering logic
   - Base identifiers (InternationalStandard, ReviewedMethod)
   - Supplement identifiers (Amendment, Corrigendum)
   - Uses shared SingleIdentifier and SupplementIdentifier base classes

## Components

### Flavor-Specific Components

| Component | File | Purpose | Attributes |
|-----------|------|---------|------------|
| N/A | N/A | IDF uses shared components only | N/A |

### Shared Components Used

| Component | From | Purpose in this flavor |
|-----------|------|------------------------|
| `Code` | `lib/pubid_new/components/code.rb` | Generic string values with number and parts |
| `Date` | `lib/pubid_new/components/date.rb` | Year-based dates with optional month/day |
| `Type` | `lib/pubid_new/components/type.rb` | Document type |
| `TypedStage` | `lib/pubid_new/components/typed_stage.rb` | Combined stage+type with harmonized stages |
| `Language` | `lib/pubid_new/components/language.rb` | Language codes (single-char or ISO) |

## Identifier Classes

### Base Identifiers

#### InternationalStandard

- **File:** `lib/pubid_new/idf/identifiers/international_standard.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** IDF International Standards with full harmonized stage support
- **Components Used:** `publisher`, `type`, `number`, `part`, `date`, `languages`
- **Patterns Supported:**
  - `IDF 87:2019` → Published International Standard
  - `IDF 125A:1988` → With letter in number
  - `IDF/ISO 10303-231:2005` → Joint with ISO
  - `IDF 80-1:2001` → With part
  - `IDF 148-1:2008 / COR 1:2009` → With corrigendum (supplement recursion)
  - `IDF 140-1:2007 / AMD1:2012` → With amendment (no space)
- **TYPED_STAGES:** 13 stages covering full lifecycle:
  - `PWI` (pwiis) - Proposed Work Item
  - `NP`, `NWIP` (isnp) - New Work Item Proposal
  - `AWI` (awiis) - Approved Work Item
  - `WD` (wdis) - Working Draft
  - `CD` (cdis) - Committee Draft
  - `FCD` (fcdis) - Final Committee Draft
  - `DIS`, `FPD` (dis) - Draft International Standard
  - `FDIS` (fdis) - Final Draft International Standard
  - `PRF`, `Fpr` (prfis) - Proof
  - `` (is) - Published (default, empty abbr)
  - `WDR` (wdr) - Proposed for Withdrawal
  - `WDA` (wda) - Withdrawal Approved
  - `WDAR` (wdar) - Withdrawal Archived
- **Rendering Formats:** Standard format with URN support

#### ReviewedMethod

- **File:** `lib/pubid_new/idf/identifiers/reviewed_method.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** IDF Reviewed Methods (special document type)
- **Components Used:** `publisher`, `type`, `number`, `part`, `date`, `languages`
- **Patterns Supported:**
  - `IDF/RM 82:2004` → Reviewed Method
  - `IDF/RM 254:2022` → Reviewed Method with year
- **TYPED_STAGES:** Uses same stages as InternationalStandard
- **Rendering Formats:** Standard format only

### Supplement Identifiers

#### Amendment

- **File:** `lib/pubid_new/idf/identifiers/amendment.rb`
- **Parent:** `SupplementIdentifier`
- **Purpose:** IDF Amendments (AMD) modify or add to existing standards
- **Components Used:** `base_identifier`, `type`, `number`, `part`, `date`, `languages`
- **Patterns Supported:**
  - `IDF 148-1:2008 / AMD1:2012` → Amendment 1 (no space)
  - `IDF 140-1:2007 / AMD 1:2012` → Amendment 1 (with space)
- **TYPED_STAGES:** 1 stage:
  - `AMD` (published) - Published Amendment
- **Recursion:** Supports multi-level supplements (amendment to amendment)
- **Rendering Formats:** Standard AMD format with space/number variants

#### Corrigendum

- **File:** `lib/pubid_new/idf/identifiers/corrigendum.rb`
- **Parent:** `SupplementIdentifier`
- **Purpose:** IDF Corrigenda (COR) correct errors in published standards
- **Components Used:** `base_identifier`, `type`, `number`, `part`, `date`, `languages`
- **Patterns Supported:**
  - `IDF 148-1:2008 / COR 1:2009` → Corrigendum 1
  - `IDF 87:2019 / COR 2:2020` → Corrigendum 2
- **TYPED_STAGES:** 1 stage:
  - `COR` (published) - Published Corrigendum
- **Recursion:** Supports multi-level supplements (corrigendum to amendment)
- **Rendering Formats:** Standard COR format

## Scheme Registry

The `Scheme` class (`lib/pubid_new/idf/scheme.rb`) is the central registry for this flavor.

### Registry Methods

- **`identifiers`** - Array of all registered identifier classes
  ```ruby
  def identifiers
    @identifiers ||= [
      Identifiers::InternationalStandard,
      Identifiers::ReviewedMethod,
    ].freeze
  end
  ```

- **`supplement_identifiers`** - Array of supplement classes
  ```ruby
  def supplement_identifiers
    @supplement_identifiers ||= [
      Identifiers::Amendment,
      Identifiers::Corrigendum,
    ].freeze
  end
  ```

- **`typed_stages`** - Aggregate TYPED_STAGES from identifier classes
  ```ruby
  def typed_stages
    @typed_stages ||= identifiers.flat_map { |klass| klass::TYPED_STAGES }
  end
  ```

- **`supplement_typed_stages`** - TYPED_STAGES for supplement identifiers
  ```ruby
  def supplement_typed_stages
    @supplement_typed_stages ||= supplement_identifiers.flat_map { |klass| klass::TYPED_STAGES }
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
| `IDF 87:2019` | `IDF 87:2019` |
| `IDF 125A:1988` | `IDF 125A:1988` |
| `IDF/ISO 10303-231:2005` | `IDF/ISO 10303-231:2005` |
| `IDF 148-1:2008 / COR 1:2009` | `IDF 148-1:2008 / COR 1:2009` |
| `IDF 140-1:2007 / AMD1:2012` | `IDF 140-1:2007 / AMD1:2012` |

### Other Formats

| Format | Rendered Output |
|--------|-----------------|
| Not applicable for IDF | N/A |

## Parser Rules

### Main Rule

```ruby
rule(:identifier) do
  supplement_identifier |
    identifier_publisher
end
```

### Component Rules

```ruby
# Publisher (IDF or IDF/ISO)
rule(:prefix_sole_publisher) do
  str("IDF").as(:publisher)
end

# Number can be alphanumeric (IDF 125A:1988)
rule(:number) do
  match('\w').repeat(1, 5)
end

# Date with optional month/day
rule(:date) do
  (year_digits >>
    (dash >> month_digits).maybe >>
    (dash >> day_digits).maybe
  ).as(:date)
end

# Part and subpart
rule(:part_and_subpart) do
  dash >> space? >>
    match('\w').repeat >>
    (dash >> match('\w').repeat).repeat.maybe
end

# Type with stage (IS, RM, etc.)
rule(:type_with_stage) do
  array_to_str(TYPED_STAGES).as(:type_with_stage) >>
    (match('\d').as(:stage_iteration) >> space).maybe
end

# Language codes
rule(:language) do
  str("(") >>
    ((match["a-z"].repeat(1) >> str(",").maybe) |
     (match["EFARDS"] >> str("/").maybe)).repeat.as(:languages) >>
    str(")")
end
```

### Special Patterns

```ruby
# Supplement identifier (slash notation)
rule(:supplement_identifier) do
  supplement_identifier_no_third >> third_part
end

rule(:supplement_identifier_no_third) do
  identifier_publisher_no_third.as(:base_identifier) >>
    space? >> str("/") >> space? >>
    supplement_type_with_stage >>
    space.maybe >> second_part
end
```

## Builder Logic

### Identifier Class Selection

The Builder uses shared common parse methods which determine identifier class based on:

1. **Supplement type code** - AMD → `Amendment`, COR → `Corrigendum`
2. **Base identifier type** - IS → `InternationalStandard`, RM → `ReviewedMethod`

### Component Casting

Uses shared common parse methods from `lib/pubid_new/parser/common_parse_methods.rb`:

```ruby
# Type with stage casting
when :type_with_stage
  # Returns TypedStage with harmonized stages

# Language casting
when :languages
  # Supports both single-char (E/F/R) and ISO (en/fr/de) codes

# Date casting
when :date
  # Supports full date (YYYY-MM-DD) or year-only (YYYY)
```

## Preprocessing

This flavor uses minimal preprocessing (inherited from shared parser):

| Pattern | Input | Output | Purpose |
|---------|-------|--------|---------|
| Dash normalization | `IDF 125‑1988` | `IDF 125-1988` | Normalize Unicode dashes |

## Testing

### Test Coverage

- **Unit tests:** `spec/pubid_new/idf/`
- **Parser tests:** `spec/pubid_new/idf/parser_spec.rb`
- **Builder tests:** `spec/pubid_new/idf/builder_spec.rb`
- **Identifier tests:** `spec/pubid_new/idf/identifiers/`
- **Integration tests:** `spec/integration/idf_`

### Fixtures

Located in: `spec/fixtures/idf/identifiers/`

- **Pass tests:** `pass/` - Valid patterns that should parse successfully
  - Base identifier patterns
  - Amendment patterns
  - Corrigendum patterns
- **Fail tests:** `fail/` - Invalid patterns that should raise errors

### Coverage Status

The IDF flavor has good test coverage for all identifier types and supplement patterns.

## Migration Notes

### V1 to V2 Changes

**Major architectural changes:**
1. **Three-layer separation** - Parser, Builder, and Identifier are completely separate
2. **Shared components** - Uses Code, Date, Type, TypedStage, Language from shared library
3. **Harmonized stages** - Uses ISO-style harmonized stage codes

**Breaking changes:**
- `Pubid::Idf::Identifier` → `PubidNew::Idf::Identifiers::*` (specific classes)
- Type attribute extracted from TYPED_STAGES instead of hardcoded

**Migration guide:**
1. Replace `Pubid::Idf.parse()` with `PubidNew::Idf.parse()`
2. Use specific identifier classes (InternationalStandard, ReviewedMethod)
3. Access stages via TypedStage objects

## References

- **Specification:** IDF Standards (https://www.fil-idf.org/)
- **Examples:** IDF Standards Catalog (https://www.fil-idf.org/standards/)
- **Related implementations:**
  - ISO flavor (similar TYPED_STAGES pattern)
  - IEC flavor (supplement patterns)

---

## Appendix: Design Decisions

### ISO-Style Harmonized Stages

**Context:** IDF uses harmonized stage codes similar to ISO/IEC (00.00 through 95.99).

**Decision:** IDF uses TYPED_STAGES with harmonized_stages attribute.

**Rationale:**
- IDF follows ISO/IEC stage code conventions
- Enables interoperability with ISO systems
- Proven pattern from ISO flavor

**Alternatives considered:**
- Custom stage codes - Rejected (less interoperable)
- No stages - Rejected (loses lifecycle information)

### Alphanumeric Numbers

**Context:** IDF numbers can contain letters (IDF 125A:1988).

**Decision:** Parser allows alphanumeric characters in number pattern.

**Rationale:**
- Real-world IDF standards have letter suffixes
- Simple pattern: `\w` repeat 1-5 characters
- Matches actual IDF numbering

**Alternatives considered:**
- Digits only - Rejected (breaks real identifiers)
- Separate letter suffix pattern - Rejected (unnecessary complexity)

### Slash Notation for Supplements

**Context:** IDF uses slash notation for supplements (IDF 148-1:2008 / COR 1:2009).

**Decision:** Parser matches slash-separated base and supplement.

**Rationale:**
- Standard IDF notation
- Clear separation of base and supplement
- Matches ISO pattern for supplements

**Alternatives considered:**
- ISO-style (Amd 1) - Rejected (not IDF notation)
- Hyphen notation - Rejected (not used by IDF)
