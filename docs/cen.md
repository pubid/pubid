# CEN Documentation

## Overview

The CEN flavor handles identifiers for European Committee for Standardization (Comité Européen de Normalisation) documents. It supports European standards harmonization with multiple document types (EN, HD, ES, TR, TS, Guide, CWA, CR, ENV), stage prefixes (prEN, FprEN), adopted standards (ISO, IEC, CISPR), amendments and corrigenda with dual separator notation (+ and /), fragment identifiers, consolidated identifiers, and multiple publisher combinations (EN, CEN, CLC). The flavor implements the complete European standards harmonization system with harmonized stage codes.

## Architecture

This flavor follows the PubID v2 three-layer architecture pattern:

1. **Parser** (`parser.rb`) - Parslet PEG grammar for syntax parsing
   - Converts input strings into structured hash trees
   - Handles multiple publisher combinations: EN, EN/CLC, CEN/CLC, CLC/CEN
   - Supports document types: EN, HD, ES, TR, TS, Guide, ENV, CR, CWA
   - Parses stage prefixes: prEN, FprEN
   - Handles adopted standards (ISO, IEC, CISPR)
   - Supports amendments: +A1:2008, /A2:2019
   - Supports corrigenda: +AC:2009, /AC1:2005, +C1:2018
   - Parses edition notation: ED2, ED3
   - Handles fragment identifiers: AMD+FRAG
   - Parses consolidated identifiers with supplement chains
   - Normalizes publisher combinations (CEN-CLC → CEN/CLC)

2. **Builder** (`builder.rb`) - Transforms parse trees to domain objects via Scheme registry
   - Casts parsed hash values to component objects using `cast()` method
   - Uses Scheme registry for type/stage lookups via `locate_typed_stage_by_abbr()`
   - Instantiates appropriate identifier class via `locate_identifier_klass_by_type_code()`
   - Handles special cases: adopted standards (ISO, IEC, CISPR), fragment identifiers
   - Creates consolidated wrappers with supplement chains
   - Manages dual supplement separators (slash vs plus)
   - Builds amendment and corrigendum wrappers

3. **Identifier** (`identifiers/`) - Lutaml::Model domain classes with rendering logic
   - Base identifiers for all CEN document types
   - Specialized wrappers for adopted standards, amendments, corrigenda
   - Multi-format rendering with preservation of original format
   - Delegation pattern for adopted standards

## Components

### Flavor-Specific Components

CEN uses shared components from `lib/pubid_new/components/` without flavor-specific custom components.

### Shared Components Used

| Component | From | Purpose in this flavor |
|-----------|------|------------------------|
| `Publisher` | `lib/pubid_new/components/publisher.rb` | Organization name (EN, CEN, CLC) with copublisher support |
| `Code` | `lib/pubid_new/components/code.rb` | Generic string values (number, part) |
| `Date` | `lib/pubid_new/components/date.rb` | Year-based dates with optional month |
| `Type` | `lib/pubid_new/components/type.rb` | Document type |
| `Language` | `lib/pubid_new/components/language.rb` | Language codes with original_code preservation |
| `Stage` | `lib/pubid_new/components/stage.rb` | Development stage |
| `TypedStage` | `lib/pubid_new/components/typed_stage.rb` | Combined stage+type with harmonized stages |

## Identifier Classes

### Base Identifiers

#### Base

- **File:** `lib/pubid_new/cen/identifiers/base.rb`
- **Parent:** `Lutaml::Model::Serializable`
- **Purpose:** The base class for all CEN identifiers. Handles the complete CEN identifier format with publisher, copublisher, type, number, part, subpart, year, month, edition, amendments, and corrigenda.
- **Components Used:** `publisher`, `copublisher`, `type`, `number`, `part`, `subpart`, `year`, `month`, `edition`, `amendments`, `corrigenda`, `supplements`
- **Patterns Supported:**
  - `EN 300 001:1997` → European Norm
  - `EN/CLC 300 001` → With copublisher
  - `prEN 300 001` → Proposal stage
  - `FprEN 300 001` → Final proposal stage
  - `EN 300 001+A1:2008` → With plus separator amendment
  - `EN 300 001/AC:2009` → With slash separator corrigendum
  - `EN ISO 9001` → Adopted ISO standard
- **Typed Stages:** Varies by document type (see specific classes below)
- **Rendering Formats:** Standard CEN format with publisher prefix

### European Norm

#### EuropeanNorm

- **File:** `lib/pubid_new/cen/identifiers/european_norm.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** The primary CEN document type representing European Standards (EN). Supports the complete harmonized stage lifecycle from proposal through published.
- **Components Used:** `publisher`, `copublisher`, `type`, `number`, `part`, `subpart`, `year`, `month`, `edition`
- **Patterns Supported:**
  - `EN 300 001:1997` → Published European Norm
  - `prEN 300 001` → Proposal European Norm
  - `FprEN 300 001` → Final Proposal European Norm
  - `EN 300 001+A1:2008` → With amendment (plus separator)
  - `EN 300 001/AC:2009` → With corrigendum (slash separator)
- **TYPED_STAGES:** 3 stages covering main lifecycle:
  - `EN` (puben) - Published European Norm (harmonized stages: 60.00, 60.60)
  - `prEN` (pren) - Proposal European Norm (harmonized stages: 30.00, 30.20, 30.60, 30.92, 30.98, 30.99)
  - `FprEN` (fpren) - Final Proposal European Norm (harmonized stages: 40.00, 40.20, 40.60, 40.92, 40.98, 40.99)
- **Rendering Formats:** Standard format with EN/prEN/FprEN prefix

### Harmonization Document

#### HarmonizationDocument

- **File:** `lib/pubid_new/cen/identifiers/harmonization_document.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** Harmonization Documents (HD) for documents used for harmonization purposes.
- **Components Used:** Same as EuropeanNorm
- **Patterns Supported:**
  - `HD 300 001:1997` → Harmonization Document
- **TYPED_STAGES:** Single published stage
  - `HD` (pubhd) - Published Harmonization Document

### Technical Specification

#### TechnicalSpecification

- **File:** `lib/pubid_new/cen/identifiers/technical_specification.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** Technical Specifications for documents under development or with limited stability.
- **Components Used:** Same as EuropeanNorm
- **Patterns Supported:**
  - `TS 300 001` → Technical Specification
  - `prTS 300 001` → Proposal Technical Specification
- **TYPED_STAGES:** 2 stages:
  - `TS` (pubts) - Published
  - `prTS` (prts) - Proposal
- **Rendering Formats:** Standard format with TS/prTS prefix

### Technical Report

#### TechnicalReport

- **File:** `lib/pubid_new/cen/identifiers/technical_report.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** Technical Reports containing collected data or information.
- **Components Used:** Same as EuropeanNorm
- **Patterns Supported:**
  - `TR 300 001` → Technical Report
  - `prTR 300 001` → Proposal Technical Report
- **TYPED_STAGES:** 2 stages:
  - `TR` (pubtr) - Published
  - `prTR` (prtr) - Proposal
- **Rendering Formats:** Standard format with TR/prTR prefix

### CEN Workshop Agreement

#### CenWorkshopAgreement

- **File:** `lib/pubid_new/cen/identifiers/cen_workshop_agreement.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** CEN Workshop Agreements (CWA) are fast-track documents developed by workshops.
- **Components Used:** Same as EuropeanNorm
- **Patterns Supported:**
  - `CWA 300 001` → CEN Workshop Agreement
- **TYPED_STAGES:** Single published stage
  - `CWA` (pubcwa) - Published

### Guide

#### Guide

- **File:** `lib/pubid_new/cen/identifiers/guide.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** CEN Guides provide rules, guidelines, or recommendations for standards development.
- **Components Used:** Same as EuropeanNorm
- **Patterns Supported:**
  - `Guide 300 001` → CEN Guide
- **TYPED_STAGES:** Single published stage
  - `Guide` (pubguide) - Published
- **Rendering Formats:** Standard format with "Guide" prefix

### CEN Report

#### CenReport

- **File:** `lib/pubid_new/cen/identifiers/cen_report.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** CEN Reports (CR) document committee reports and studies.
- **Components Used:** Same as EuropeanNorm
- **Patterns Supported:**
  - `CR 300 001` → CEN Report
- **TYPED_STAGES:** Single published stage
  - `CR` (pubcr) - Published

### European Prestandard

#### EuropeanPrestandard

- **File:** `lib/pubid_new/cen/identifiers/european_prestandard.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** European Prestandards (ENV) were provisional standards (now withdrawn, replaced by EN).
- **Components Used:** Same as EuropeanNorm
- **Patterns Supported:**
  - `ENV 300 001` → European Prestandard
- **TYPED_STAGES:** Single published stage
  - `ENV` (pubenv) - Published

### Supplement Identifiers

#### Amendment

- **File:** `lib/pubid_new/cen/identifiers/amendment.rb`
- **Parent:** `Identifier` (wrapper)
- **Purpose:** Amendments (AMD) modify or add to an existing base standard.
- **Components Used:** `base_identifier`, `amendment_number`, `amendment_year`
- **Patterns Supported:**
  - `EN 300 001:1997+A1:2008` → Amendment with plus separator
  - `EN 300 001:1997/A2:2019` → Amendment with slash separator
  - `EN 300 001:1997+A1:2008+AMD+FRAG` → Fragment of amendment
- **Rendering Formats:** Appends amendment notation with preserved separator

#### Corrigendum

- **File:** `lib/pubid_new/cen/identifiers/corrigendum.rb`
- **Parent:** `Identifier` (wrapper)
- **Purpose:** Corrigenda (COR/AC) correct errors in published standards.
- **Components Used:** `base_identifier`, `corrigendum_number`, `corrigendum_year`
- **Patterns Supported:**
  - `EN 300 001:1997+AC:2009` → Corrigendum with plus separator
  - `EN 300 001:1997/AC1:2005` → Corrigendum with slash separator
  - `EN 300 001:1997+C1:2018` → Corrigendum with C notation
- **Rendering Formats:** Appends corrigendum notation with preserved separator

### Special Identifiers

#### AdoptedEuropeanNorm

- **File:** `lib/pubid_new/cen/identifiers/adopted_european_norm.rb`
- **Parent:** `EuropeanNorm`
- **Purpose:** Wrapper for ISO, IEC, or CISPR standards adopted by CEN. Delegates to adopted identifier.
- **Components Used:** `adopted_identifier` (ISO/IEC/CISPR object), `edition`
- **Patterns Supported:**
  - `EN ISO 9001` → Adopted ISO standard
  - `EN IEC 62600` → Adopted IEC standard
  - `EN ISO/IEC 19757-2` → Adopted ISO/IEC standard
- **Typed Stages:** Single published stage
  - `EN ISO`, `EN IEC`, `EN ISO/IEC` (adopted) - Published adopted standard
- **Rendering Formats:** Renders as "EN ISO [number]:[year]" or "EN IEC [number]:[year]" with delegation to adopted identifier for number, year, parts

#### ConsolidatedIdentifier

- **File:** `lib/pubid_new/cen/identifiers/consolidated_identifier.rb`
- **Parent:** `Identifier`
- **Purpose:** Consolidated versions including base standard and all amendments.
- **Components Used:** `base_identifier`, `amendments` (array)
- **Patterns Supported:**
  - `EN 300 001:1997+A1:2008+A2:2010` → Consolidated with amendments
- **Rendering Formats:** Special rendering with + notation for amendments

## Scheme Registry

The `Scheme` class (`lib/pubid_new/cen/scheme.rb`) is the central registry for this flavor.

### Registry Methods

- **`typed_stages`** - Aggregate TYPED_STAGES from TYPED_STAGES_REGISTRY
  ```ruby
  def typed_stages
    TYPED_STAGES_REGISTRY.values.flatten
  end
  ```

- **`locate_typed_stage_by_abbr(abbr)`** - Find stage by abbreviation
  - Returns `TypedStage` object or raises `ArgumentError`
  - Searches through TYPED_STAGES_REGISTRY
  - Case-insensitive matching

- **`locate_identifier_klass_by_type_code(type_code)`** - Select class by type code
  - Returns identifier class from IDENTIFIER_CLASS_MAP
  - Used by Builder to determine which class to instantiate
  - Example: `:en` → `Identifiers::EuropeanNorm`, `:hd` → `Identifiers::HarmonizationDocument`

### TYPED_STAGES Registry

CEN has a comprehensive TYPED_STAGES registry with 9 document types:

**European Norm (EN):**
- `EN` (puben) - Published European Norm (harmonized: 60.00, 60.60)
- `prEN` (pren) - Proposal European Norm (harmonized: 30.00, 30.20, 30.60, 30.92, 30.98, 30.99)
- `FprEN` (fpren) - Final Proposal European Norm (harmonized: 40.00, 40.20, 40.60, 40.92, 40.98, 40.99)

**Other Document Types:**
- `HD` (pubhd) - Published Harmonization Document
- `ES` (pubes) - Published European Standard (alt notation)
- `TR` (pubtr) - Published Technical Report
- `prTR` (prtr) - Proposal Technical Report
- `TS` (pubts) - Published Technical Specification
- `prTS` (prts) - Proposal Technical Specification
- `Guide` (pubguide) - Published Guide
- `ENV` (pubenv) - Published European Prestandard
- `CR` (pubcr) - Published CEN Report
- `CWA` (pubcwa) - Published CEN Workshop Agreement

Each TypedStage includes:
- `code` - Internal stage code
- `stage_code` - Stage code (:published, :proposal, :final_proposal)
- `type_code` - Type code (en, hd, tr, ts, etc.)
- `abbr` - Array of abbreviations
- `name` - Full name
- `harmonized_stages` - Harmonized stage codes for European integration

### Identifier Class Map

The `IDENTIFIER_CLASS_MAP` maps type codes to identifier classes:

```ruby
IDENTIFIER_CLASS_MAP = {
  en: Identifiers::EuropeanNorm,
  hd: Identifiers::HarmonizationDocument,
  es: Identifiers::EuropeanNorm,  # Alt notation
  tr: Identifiers::TechnicalReport,
  ts: Identifiers::TechnicalSpecification,
  guide: Identifiers::Guide,
  env: Identifiers::EuropeanPrestandard,
  cr: Identifiers::CenReport,
  cwa: Identifiers::CenWorkshopAgreement,
}.freeze
```

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

## Builder Logic

### Identifier Class Selection

The Builder determines which identifier class to instantiate based on:

1. **Fragment identifier indicators** - If `:fragment_number` or `:amendment_fragment` → fragment identifier
2. **Adopted standard indicators** - If `:adopted_string` or `:adopted_type` → `AdoptedEuropeanNorm`
3. **Type code from TypedStage** - `locate_identifier_klass_by_type_code()` called with type_code
4. **Consolidated indicators** - Multiple supplements → wrap with consolidated

### Component Casting

Special casting logic in Builder's `cast()` method:

```ruby
# Publisher with copublisher
when :publisher, :copublisher
  # "EN" with copublisher "CLC" → ["EN", "CLC"]
  # Create Publisher object with copublisher array

# Type with stage
when :type_with_stage
  # "prEN" → TypedStage with code=:pren
  # "FprEN" → TypedStage with code=:fpren

# Number (concatenates)
when :number
  # "300 001" → "300001"
  # Remove spaces from parsed number

# Amendment with separator
when :amendment
  # Preserve separator (plus vs slash)
  # +A1:2008 → {separator: "plus", number: "1", year: "2008"}
  # /A2:2019 → {separator: "slash", number: "2", year: "2019"}

# Corrigendum with separator
when :corrigendum
  # Preserve separator (plus vs slash)
  # +AC:2009 → {separator: "plus", year: "2009"}
  # /AC1:2005 → {separator: "slash", number: "1", year: "2005"}
```

### Adopted Standard Handling

The Builder creates `AdoptedEuropeanNorm` for adopted standards:

```ruby
def build_adopted_identifier(parsed_hash)
  adopted = Identifiers::AdoptedEuropeanNorm.new

  # Set publisher (EN with optional copublisher)
  adopted.publisher = cast(:publisher, parsed_hash[:publisher])
  adopted.copublisher = cast(:copublisher, parsed_hash[:copublisher]) if parsed_hash[:copublisher]

  # Parse and set adopted identifier (ISO, IEC, CISPR)
  if parsed_hash[:adopted_string]
    # Use appropriate flavor parser for adopted standard
    adopted_identifier = parse_adopted_standard(parsed_hash[:adopted_string], parsed_hash[:adopted_type])
    adopted.adopted_identifier = adopted_identifier
  end

  adopted
end
```

### Fragment Identifier Building

The Builder creates fragment identifiers for AMD+FRAG notation:

```ruby
def build_fragment_identifier(parsed_hash)
  fragment = Identifiers::Amendment.new

  # Reconstruct base identifier
  base_string = reconstruct_base_string(parsed_hash[:base_identifier])
  fragment.base_identifier = parse(base_string)

  # Set fragment number
  fragment.amendment_number = parsed_hash[:fragment_number]

  fragment
end
```

### Consolidated Identifier Building

The Builder wraps identifiers with multiple supplements:

```ruby
def wrap_with_consolidated(base, supplements)
  consolidated = Identifiers::ConsolidatedIdentifier.new
  consolidated.base_identifier = base
  consolidated.amendments = supplements
  consolidated
end
```

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
- **Integration tests:** `spec/integration/cen_`

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

## Migration Notes

### V1 to V2 Changes

**Major architectural changes:**
1. **Three-layer separation** - Parser, Builder, and Identifier are completely separate
2. **Registry-based architecture** - Scheme class manages all type/stage lookups via TYPED_STAGES_REGISTRY
3. **TYPED_STAGES array** - Replaces hash-based TYPE_MAP pattern with harmonized stages
4. **Identifier class explosion** - Multiple specialized identifier classes vs single generic identifier
5. **Delegation pattern** - Adopted standards delegate to adopted identifier for number, year, parts
6. **Wrapper classes** - Amendment, Corrigendum, ConsolidatedIdentifier wrappers

**Breaking changes:**
- `Pubid::Cen::Identifier` → `PubidNew::Cen::Identifiers::*` (specific classes)
- `type` and `stage` attributes replaced by `typed_stage` (combined object)
- Adopted standards now use delegation pattern instead of string attributes
- Dual supplement separators (+ and /) preserved in attributes

**Migration guide:**
1. Replace `Pubid::Cen.parse()` with `PubidNew::Cen.parse()`
2. Use specific identifier classes instead of generic `Identifier`
3. Access type/stage via `identifier.typed_stage`
4. For adopted standards, use delegation methods: `identifier.number`, `identifier.year`, etc.

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
