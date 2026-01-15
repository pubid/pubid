# BSI Documentation

## Overview

The BSI flavor handles identifiers for British Standards Institution (BSI) standards and related publications. It supports BSI's complete document ecosystem including British Standards (BS), Drafts for Development (DD), Published Documents (PD), Publicly Available Specifications (PAS), Technical Specifications (TS), National Annexes (NA), Handbooks, and 37+ specialized document types. The flavor handles multi-level adoption (BS EN ISO/IEC, BS ISO/IEC, BS EN), adopted international standards (ISO, IEC, CISPR, CEN), supplements (+A1, /AC1), corrigenda, amendments, set notation (+), bundled identifiers (and, to, &, semicolon, comma), value-added publications (PDF, BOOK, TC), expert commentary, and specialized prefixes (AU, HC, MA, PL, QC, TA, CECC, E9111, etc.).

## Architecture

This flavor follows the PubID v2 three-layer architecture pattern:

1. **Parser** (`parser.rb`) - Parslet PEG grammar for syntax parsing
   - Converts input strings into structured hash trees
   - Uses ordered rules (most specific first) to handle 37+ document types
   - Handles specialized prefixes (AU, HC, MA, PL, QC, TA, CECC, E9111, 2HC, 2A, etc.)
   - Supports multi-level adoption hierarchy (EN ISO/IEC → EN → ISO/IEC → CEN)
   - Parses set notation (+ for sets)
   - Handles amendments (+A1:2008, /A2:2019, AMD standalone)
   - Supports corrigenda (+AC:2009, /AC1:2005, +C1:2018, AMD Corrigendum)
   - Parses bundling (and, to, &, semicolon, comma)
   - Handles National Annexes (NA to BS..., NA+A1:2012 to BS...)
   - Parses supplement documents (forward and reverse)
   - Handles addendum documents
   - Supports special document suffixes (Index, Method, Section, N, C)
   - Parses value-added publications (PDF, BOOK, TC)
   - Handles committee documents (YY/NNNNNNNN format)
   - Supports DISC identifiers
   - Handles expert commentary and consolidated editions

2. **Builder** (`builder.rb`) - Transforms parse trees to domain objects via Scheme registry
   - Casts parsed hash values to component objects
   - Uses Scheme registry for type/stage lookups via `locate_typed_stage_by_abbr()`
   - Instantiates appropriate identifier class via `locate_identifier_klass_by_type_code()`
   - Handles special patterns: National Annexes with supplements, adopted identifiers (CEN, ISO, IEC)
   - Constructs bundled identifiers with appropriate separators
   - Builds set identifiers with plus notation
   - Wraps identifiers with expert commentary
   - Wraps identifiers with consolidated editions
   - Handles multi-level adoption hierarchy with delegation
   - Manages opaque identifier strings for adopted standards

3. **Identifier** (`identifiers/`) - Lutaml::Model domain classes with rendering logic
   - Base identifiers for native BSI document types
   - Specialized wrapper classes for National Annexes, adopted standards, bundled identifiers, sets
   - Value-added publication wrappers (PDF, BOOK, TC)
   - Expert commentary wrappers
   - Multi-format rendering with preservation of original format

## Components

### Flavor-Specific Components

| Component | File | Purpose | Attributes |
|-----------|------|---------|------------|
| `FlexPrefix` | `components/flex_prefix.rb` | BSI Flex prefix notation | `prefix` |

### Shared Components Used

| Component | From | Purpose in this flavor |
|-----------|------|------------------------|
| `Publisher` | `lib/pubid_new/components/publisher.rb` | Organization name (BS, BSI) |
| `Code` | `lib/pubid_new/components/code.rb` | Generic string values (number, part) |
| `Date` | `lib/pubid_new/components/date.rb` | Year-based dates |
| `Type` | `lib/pubid_new/components/type.rb` | Document type |
| `Stage` | `lib/pubid_new/components/stage.rb` | Development stage |
| `TypedStage` | `lib/pubid_new/components/typed_stage.rb` | Combined stage+type with harmonized stages |

## Identifier Classes

### Base Identifiers

#### BritishStandard

- **File:** `lib/pubid_new/bsi/identifiers/british_standard.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** The primary BSI document type representing British Standards. Supports published and draft stages.
- **Components Used:** `publisher`, `prefix`, `flex_prefix`, `number`, `iteration`, `part`, `subpart`, `second_number`, `date`, `stage`, `type`, `typed_stage`, `edition`, `month`, `translation_lang`, `translation_upper`
- **Patterns Supported:**
  - `BS 0:1983` → Basic British Standard
  - `BS 2SP 68:1973` → With specialized prefix
  - `BS 13 and 14:1949` → Bundled identifier
  - `BS 13+14+15:1949` → Set notation
  - `BS 1000[9]+1001:1973` → Set with iteration
  - `Draft BS 13:1949` → Draft stage
- **TYPED_STAGES:** 2 stages:
  - `BS` (pubbs) - Published British Standard
  - `Draft BS`, `DBS` (drbs) - Draft British Standard
- **Rendering Formats:** Standard BSI format with type prefix

### Draft for Development

#### DraftForDevelopment

- **File:** `lib/pubid_new/bsi/identifiers/draft_for_development.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** Drafts for Development are consultative documents published for comment and discussion.
- **Components Used:** Same as BritishStandard
- **Patterns Supported:**
  - `DD 133:1973` → Draft for Development
  - `DD 185:1975` → Draft for Development
- **TYPED_STAGES:** Single published stage
  - `DD` (pubdd) - Published Draft for Development
- **Rendering Formats:** Standard format with DD prefix

### Published Document

#### PublishedDocument

- **File:** `lib/pubid_new/bsi/identifiers/published_document.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** Published Documents provide guidance and information.
- **Components Used:** Same as BritishStandard
- **Patterns Supported:**
  - `PD 6461:1971` → Published Document
- **TYPED_STAGES:** Single published stage
  - `PD` (pubpd) - Published Document
- **Rendering Formats:** Standard format with PD prefix

### Publicly Available Specification

#### PubliclyAvailableSpecification

- **File:** `lib/pubid_new/bsi/identifiers/publicly_available_specification.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** Publicly Available Specifications are fast-track standards developed by sponsored bodies.
- **Components Used:** Same as BritishStandard
- **Patterns Supported:**
  - `PAS 1014:1999` → Publicly Available Specification
- **TYPED_STAGES:** Single published stage
  - `PAS` (pubpas) - Published PAS
- **Rendering Formats:** Standard format with PAS prefix

### Technical Specification

#### TechnicalSpecification

- **File:** `lib/pubid_new/bsi/identifiers/technical_specification.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** Technical Specifications for documents under development or with limited stability.
- **Components Used:** Same as BritishStandard
- **Patterns Supported:**
  - `TS 5240:1975` → Technical Specification
- **TYPED_STAGES:** Single published stage
  - `TS` (pubts) - Published Technical Specification
- **Rendering Formats:** Standard format with TS prefix

### National Annex

#### NationalAnnex

- **File:** `lib/pubid_new/bsi/identifiers/national_annex.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** National Annexes provide national implementation details for adopted European standards.
- **Components Used:** `na_supplements` (array), `base_doc`
- **Patterns Supported:**
  - `NA to BS EN 196-1:1995` → National Annex to BS EN
  - `NA+A1:2012 to BS EN 196-1:1995` → National Annex with amendment
  - `NA+AC1:2009 to BS EN 196-2:1995` → National Annex with corrigendum
- **TYPED_STAGES:** Single published stage
  - `NA` (pubna) - Published National Annex
- **Rendering Formats:** Special rendering with "NA to BS..." format, supplements rendered as "+A1:2012"

### Handbook

#### Handbook

- **File:** `lib/pubid_new/bsi/identifiers/handbook.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** Handbooks provide practical guidance and technical information.
- **Components Used:** Same as BritishStandard
- **Patterns Supported:**
  - `Handbook 19:1976` → Handbook
- **TYPED_STAGES:** Single published stage
  - `Handbook` (pubhandbook) - Published Handbook
- **Rendering Formats:** Standard format with "Handbook" prefix

### British Industry Publication

#### BritishIndustryPublication

- **File:** `lib/pubid_new/bsi/identifiers/british_industry_publication.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** British Industry Publications for industry-specific documents.
- **Components Used:** Same as BritishStandard
- **Patterns Supported:**
  - `BIP 2012:1969` → British Industry Publication
- **TYPED_STAGES:** Single published stage
  - `BIP` (pubbip) - Published BIP
- **Rendering Formats:** Standard format with BIP prefix

### Public Procedure

#### PublicProcedure

- **File:** `lib/pubid_new/bsi/identifiers/public_procedure.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** Public Procedures for procedural documents.
- **Components Used:** Same as BritishStandard
- **Patterns Supported:**
  - `PP 7303:1981` → Public Procedure
- **TYPED_STAGES:** Single published stage
  - `PP` (pubpp) - Published Public Procedure
- **Rendering Formats:** Standard format with PP prefix

### BSI Flex

#### BsiFlex

- **File:** `lib/pubid_new/bsi/identifiers/bsi_flex.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** BSI Flex standards are fast-track standards with flexible prefix notation.
- **Components Used:** `flex_prefix` (FlexPrefix component)
- **Patterns Supported:**
  - `BSI Flex 2803:2019` → BSI Flex standard
  - `BS Flex 2803:2019` → Alternative notation
- **TYPED_STAGES:** Single published stage
  - `BSI Flex`, `BS Flex` (pubflex) - Published BSI Flex
- **Rendering Formats:** Preserves original prefix format (BSI Flex or BS Flex)

### Adopted European Norm

#### AdoptedEuropeanNorm

- **File:** `lib/pubid_new/bsi/identifiers/adopted_european_norm.rb`
- **Parent:** `BritishStandard`
- **Purpose:** Wrapper for CEN standards adopted by BSI (BS EN). Delegates to adopted CEN identifier.
- **Components Used:** `adopted_identifier` (CEN object), `edition`
- **Patterns Supported:**
  - `BS EN 196-1:1995` → Adopted European Norm
  - `BS EN ISO 9001:2015` → Adopted EN ISO standard
  - `BS EN IEC 62600:2019` → Adopted EN IEC standard
- **TYPED_STAGES:** Single published stage
  - `BS EN` (pubbsen) - Published BS EN
- **Rendering Formats:** Renders as "BS EN [number]:[year]" with delegation to adopted identifier for number, year, parts

### Adopted International Standard

#### AdoptedInternationalStandard

- **File:** `lib/pubid_new/bsi/identifiers/adopted_international_standard.rb`
- **Parent:** `BritishStandard`
- **Purpose:** Wrapper for ISO/IEC standards directly adopted by BSI (BS ISO, BS IEC). Delegates to adopted identifier.
- **Components Used:** `adopted_identifier` (ISO/IEC object)
- **Patterns Supported:**
  - `BS ISO 9001:2015` → Adopted ISO standard
  - `BS IEC 62600:2019` → Adopted IEC standard
  - `BS ISO/IEC 19757-2:2008` → Adopted ISO/IEC standard
- **TYPED_STAGES:** Single published stage
  - `BS ISO`, `BS IEC`, `BS ISO/IEC` (pubbsis) - Published BS ISO/IEC
- **Rendering Formats:** Renders as "BS ISO [number]:[year]" or "BS IEC [number]:[year]" with delegation to adopted identifier

### Bundled Identifier

#### BundledIdentifier

- **File:** `lib/pubid_new/bsi/identifiers/bundled_identifier.rb`
- **Parent:** `Identifier`
- **Purpose:** Multiple BSI identifiers bundled together with various separators.
- **Components Used:** `identifiers` (array), `separator`
- **Patterns Supported:**
  - `BS 13 and 14:1949` → "and" separator
  - `BS 2SP 68 to BS 2SP 71` → "to" separator (range)
  - `BS 13 & 14:1949` → Ampersand separator
  - `BS 13; 14; 15:1949` → Semicolon separator
  - `BS 13, 14, 15:1949` → Comma separator
- **Rendering Formats:** Joins identifiers with specified separator

### Set Identifier

#### SetIdentifier

- **File:** `lib/pubid_new/bsi/identifiers/set_identifier.rb`
- **Parent:** `Identifier`
- **Purpose:** Multiple BSI identifiers in set notation (+ separator).
- **Components Used:** `identifiers` (array)
- **Patterns Supported:**
  - `BS 13+14+15:1949` → Set of 3 standards
  - `BS 1000[9]+1001:1973` → Set with iteration
- **Rendering Formats:** Joins identifiers with + separator

### Expert Commentary

#### ExpertCommentary

- **File:** `lib/pubid_new/bsi/identifiers/expert_commentary.rb`
- **Parent:** `Identifier`
- **Purpose:** Wrapper for expert commentary documents.
- **Components Used:** `base_identifier`
- **Patterns Supported:**
  - `BS 0(1983) Expert Commentary` → Expert commentary wrapper
  - `BS 0(1983) ExComm (Fire)` → Abbreviated expert commentary
- **Rendering Formats:** Appends " Expert Commentary" or " ExComm (...)" suffix

### Value Added Publication

#### ValueAddedPublication

- **File:** `lib/pubid_new/bsi/identifiers/value_added_publication.rb`
- **Parent:** `Identifier`
- **Purpose:** Wrapper for value-added publication formats (PDF, BOOK, TC).
- **Components Used:** `base_identifier`, `format`
- **Patterns Supported:**
  - `BS 0(1983) PDF` → PDF format
  - `BS 0(1983) BOOK` → Book format
  - `BS 0(1983) - TC` → Tracked changes
- **Rendering Formats:** Appends format suffix (PDF, BOOK, - TC)

### Specialized Document Types

The BSI flavor supports 37+ specialized document types including:

| Type | File | Purpose |
|------|------|---------|
| `AerospaceStandard` | `aerospace_standard.rb` | A prefix aerospace standards |
| `AutomotiveStandard` | `automotive_standard.rb` | AU prefix automotive standards |
| `CeramicsStandard` | `ceramics_standard.rb` | C prefix ceramics standards |
| `FirearmsStandard` | `firearms_standard.rb` | F prefix firearms standards |
| `GasStandard` | `gas_standard.rb` | G prefix gas standards |
| `GeneralStandard` | `general_standard.rb` | B prefix general standards |
| `LightingStandard` | `lighting_standard.rb` | L prefix lighting standards |
| `MarineStandard` | `marine_standard.rb` | MA prefix marine standards |
| `MiscellaneousStandard` | `miscellaneous_standard.rb` | X prefix miscellaneous standards |
| `PlumbingStandard` | `plumbing_standard.rb` | PL prefix plumbing standards |
| `QualityStandard` | `quality_standard.rb` | QC prefix quality standards |
| `RoadStandard` | `road_standard.rb` | M prefix road standards |
| `SoilStandard` | `soil_standard.rb` | S prefix soil standards |
| `TelecommunicationsStandard` | `telecommunications_standard.rb` | TA prefix telecom standards |

## Scheme Registry

The `Scheme` class (`lib/pubid_new/bsi/scheme.rb`) is the central registry for this flavor.

### Registry Methods

- **`typed_stages`** - Aggregate TYPED_STAGES from all identifier classes
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
  - Example: `:bs` → `Identifiers::BritishStandard`, `:bsen` → `Identifiers::AdoptedEuropeanNorm`

### TYPED_STAGES Registry

BSI has a comprehensive TYPED_STAGES registry with 20+ stage definitions:

**Document Type Stages:**
- `BS` (pubbs) - Published British Standard
- `DD` (pubdd) - Published Draft for Development
- `PD` (pubpd) - Published Document
- `PAS` (pubpas) - Published Publicly Available Specification
- `TS` (pubts) - Published Technical Specification
- `NA` (pubna) - Published National Annex
- `Handbook` (pubhandbook) - Published Handbook
- `BIP` (pubbip) - Published British Industry Publication
- `PP` (pubpp) - Published Public Procedure
- `BSI Flex`, `BS Flex` (pubflex) - Published BSI Flex

**Draft Stages:**
- `Draft BS`, `DBS` (drbs) - Draft British Standard
- `Draft DD` (drdd) - Draft Draft for Development
- `Draft PD` (drpd) - Draft Published Document

**Adopted Standard Stages:**
- `BS EN` (pubbsen) - Published BS EN (adopted CEN)
- `BS ISO`, `BS IEC`, `BS ISO/IEC` (pubbsis) - Published BS ISO/IEC (adopted international)

**Specialized Prefix Stages:**
- `A` (puba) - Published aerospace standards
- `AU` (pubau) - Published automotive standards
- `B` (pubb) - Published general standards
- `C` (pubc) - Published ceramics standards
- `F` (pubf) - Published firearms standards
- `G` (pubg) - Published gas standards
- `HC` (pubhc) - Published hovercraft standards
- `L` (publ) - Published lighting standards
- `MA` (pubma) - Published marine standards
- `M` (pubm) - Published road standards
- `PL` (pubpl) - Published plumbing standards
- `QC` (pubqc) - Published quality standards
- `S` (pubs) - Published soil standards
- `TA` (pubta) - Published telecommunications standards
- `X` (pubx) - Published miscellaneous standards

Each TypedStage includes:
- `code` - Internal stage code
- `stage_code` - Stage code (:published or :draft)
- `type_code` - Type code (bs, dd, pd, pas, etc.)
- `abbr` - Array of abbreviations
- `name` - Full name
- `harmonized_stages` - Harmonized stage codes for CEN integration

### Identifier Class Map

The `IDENTIFIER_CLASS_MAP` maps type codes to identifier classes:

```ruby
IDENTIFIER_CLASS_MAP = {
  pubbs: Identifiers::BritishStandard,
  pubdd: Identifiers::DraftForDevelopment,
  pubpd: Identifiers::PublishedDocument,
  pubpas: Identifiers::PubliclyAvailableSpecification,
  pubts: Identifiers::TechnicalSpecification,
  pubna: Identifiers::NationalAnnex,
  pubhandbook: Identifiers::Handbook,
  pubbip: Identifiers::BritishIndustryPublication,
  pubpp: Identifiers::PublicProcedure,
  pubflex: Identifiers::BsiFlex,
  pubbsen: Identifiers::AdoptedEuropeanNorm,
  pubbsis: Identifiers::AdoptedInternationalStandard,
  # ... and 20+ specialized prefix types
}.freeze
```

## Parser Rules

### Main Rule

```ruby
rule(:identifier) do
  # Ordered rules - most specific first
  standalone_amendment |
    committee_document |
    index_identifier |
    supplementary_index_identifier |
    explanatory_supplement_identifier |
    method_identifier |
    test_method_identifier |
    section_identifier |
    detailed_specification_identifier |
    disc_identifier |
    supplement_document_reverse |
    supplement_document_forward |
    addendum_document |
    set_identifier |
    bundled_identifiers |
    bare_adopted_identifier |
    flex_identifier |
    bsi_identifier
end
```

### Component Rules

```ruby
# Publisher with prefix
rule(:publisher) do
  (str("BSI") | str("BS")).as(:publisher) >>
    (space >> prefix.maybe).maybe
end

# Prefix (multi-letter before single-letter)
rule(:prefix) do
  # Multi-letter prefixes: AU, HC, MA, PL, QC, TA, CECC, E9111, 2HC, 2A
  multi_letter_prefix |
    # Single-letter prefixes: A, B, C, F, G, L, M, S, X
    single_letter_prefix |
    # 2-digit prefixes
    two_digit_prefix
end

# Document type
rule(:document_type) do
  str("BS") | str("BSI") | str("DD") | str("PD") | str("PAS") |
  str("TS") | str("NA") | str("Handbook") | str("BIP") | str("PP") |
  str("Flex") | str("Draft BS") | str("DBS")
end

# Number with iteration
rule(:number) do
  digits.as(:number) >>
    (str("[") >> digits.as(:iteration) >> str("]")).maybe
end

# Part and subpart
rule(:part) do
  (str(":") >> digits.as(:part)) |
    (str(".") >> digits.as(:subpart))
end

# Date (year with optional month)
rule(:date) do
  str(":") >>
    (digits.as(:year) >> (str("/") >> digits.as(:month)).maybe)
end

# Stage (draft)
rule(:stage) do
  (str("Draft") | str("DBS")).as(:stage)
end
```

### Special Patterns

```ruby
# Set identifier (+ separator)
rule(:set_identifier) do
  bsi_identifier.as(:first) >>
    (str("+") >> bsi_identifier.as(:second)).repeat(1)
end

# Bundled identifiers (and, to, &, semicolon, comma)
rule(:bundled_identifiers) do
  bsi_identifier.as(:first) >>
    (
      str(" and ") | str(" to ") | str(" & ") |
      str(";") | str(",")
    ).as(:separator) >>
    bsi_identifier.as(:second)
end

# National Annex (forward format)
rule(:national_annex) do
  (str("NA") >> supplements.maybe >> str(" to ")).as(:na_prefix) >>
    bsi_identifier.as(:base_doc)
end

# Supplements (+A1:2008, /AC1:2005)
rule(:supplements) do
  (
    # Amendment
    (str("+") | str("/")) >>
    str("A") >> digits.maybe >> str(":") >> digits.maybe
  ).as(:amendment) |
  (
    # Corrigendum
    (str("+") | str("/")) >>
    (str("AC") | str("C")) >> digits.maybe >> str(":") >> digits.maybe
  ).as(:corrigendum)
end

# Committee document (YY/NNNNNNNN)
rule(:committee_document) do
  digits.repeat(2, 2).as(:year) >>
    str("/") >>
    digits.repeat(8, 8).as(:number)
end

# Standalone amendment
rule(:standalone_amendment) do
  str("AMD") >> space >>
    (
      digits.as(:number) |
      str("Corrigendum") >> space >> digits.as(:number)
    )
end

# Special suffixes
rule(:index_identifier) do
  str(":Index:") >> digits.as(:year)
end

rule(:method_identifier) do
  str(":Method") >> space >> match["A-Z0-9"].repeat(1).as(:method) >> str(":") >> digits.as(:year)
end

rule(:section_identifier) do
  str("Section") >> space >> digits.as(:section) >> str(":") >> digits.as(:year)
end

rule(:detailed_specification_identifier) do
  # N notation: N002:1974
  (str("N") >> digits.repeat(3, 3)).as(:n_spec) >> str(":") >> digits.as(:year) |
  # C notation range: C155-168:1971
  (str("C") >> digits >> str("-") >> digits).as(:c_spec) >> str(":") >> digits.as(:year)
end
```

## Builder Logic

### Identifier Class Selection

The Builder determines which identifier class to instantiate based on:

1. **Special patterns** - National Annex, adopted standards (CEN, ISO, IEC), bundled identifiers, sets
2. **Type code from TypedStage** - `locate_identifier_klass_by_type_code()` called with type_code
3. **Opaque identifier strings** - For adopted standards (CEN, ISO, IEC, CISPR)

### Special Pattern Handling

```ruby
# National Annex with supplements
def build_national_annex(parsed_hash)
  na = Identifiers::NationalAnnex.new

  # Parse supplements from na_prefix (e.g., "NA+A1:2012")
  if parsed_hash[:na_prefix]
    supplements = extract_na_supplements(parsed_hash[:na_prefix])
    na.na_supplements = supplements
  end

  # Build base identifier
  if parsed_hash[:base_doc]
    na.base_doc = build(parsed_hash[:base_doc])
  end

  na
end

# Adopted identifier (CEN, ISO, IEC)
def build_adopted_identifier(parsed_hash)
  # For BS EN, use AdoptedEuropeanNorm
  if parsed_hash[:adopted_type] == "CEN"
    return build_adopted_european_norm(parsed_hash)
  end

  # For BS ISO/IEC, use AdoptedInternationalStandard
  if parsed_hash[:adopted_type] == "ISO" || parsed_hash[:adopted_type] == "IEC"
    return build_adopted_international_standard(parsed_hash)
  end

  # Otherwise use appropriate type from Scheme
  locate_identifier_klass_by_type_code(type_code).new
end

# Bundled identifier
def build_bundled_identifier(parsed_hash)
  bundled = Identifiers::BundledIdentifier.new

  # Build first and second identifiers
  bundled.identifiers = [
    build(parsed_hash[:first]),
    build(parsed_hash[:second])
  ]

  # Set separator
  bundled.separator = parsed_hash[:separator]

  bundled
end

# Set identifier
def build_set(parsed_hash)
  set_id = Identifiers::SetIdentifier.new

  # Build all identifiers in set
  set_id.identifiers = [
    build(parsed_hash[:first]),
    *parsed_hash[:others].map { |id| build(id) }
  ]

  set_id
end
```

### Wrapper Methods

The Builder provides specialized wrapper methods:

- **`wrap_with_expert_commentary()`** - Creates ExpertCommentary wrapper
- **`wrap_with_consolidated()`** - Creates consolidated edition wrapper
- **`wrap_with_value_added_publication()`** - Creates ValueAddedPublication wrapper (PDF, BOOK, TC)

### Delegation Pattern

Adopted standards use delegation pattern:

```ruby
# AdoptedEuropeanNorm delegates to adopted CEN identifier
class AdoptedEuropeanNorm < BritishStandard
  attribute :adopted_identifier, PubidNew::Cen::Identifier
  attribute :edition, String

  # Delegation methods
  def number
    adopted_identifier&.number
  end

  def year
    adopted_identifier&.year
  end

  def date
    adopted_identifier&.date
  end

  # ... more delegation methods
end
```

## Rendering Examples

### Standard Format

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `BS 0:1983` | `BS 0:1983` |
| `BS 2SP 68:1973` | `BS 2SP 68:1973` |
| `DD 133:1973` | `DD 133:1973` |
| `PD 6461:1971` | `PD 6461:1971` |
| `PAS 1014:1999` | `PAS 1014:1999` |
| `TS 5240:1975` | `TS 5240:1975` |

### Adopted Standards

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `BS EN 196-1:1995` | `BS EN 196-1:1995` |
| `BS EN ISO 9001:2015` | `BS EN ISO 9001:2015` |
| `BS EN IEC 62600:2019` | `BS EN IEC 62600:2019` |
| `BS ISO 9001:2015` | `BS ISO 9001:2015` |
| `BS IEC 62600:2019` | `BS IEC 62600:2019` |

### National Annexes

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `NA to BS EN 196-1:1995` | `NA to BS EN 196-1:1995` |
| `NA+A1:2012 to BS EN 196-1:1995` | `NA+A1:2012 to BS EN 196-1:1995` |
| `NA+AC1:2009 to BS EN 196-2:1995` | `NA+AC1:2009 to BS EN 196-2:1995` |

### Set Notation

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `BS 13+14+15:1949` | `BS 13+14+15:1949` |
| `BS 1000[9]+1001:1973` | `BS 1000[9]+1001:1973` |

### Bundled Identifiers

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `BS 13 and 14:1949` | `BS 13 and 14:1949` |
| `BS 2SP 68 to BS 2SP 71` | `BS 2SP 68 to BS 2SP 71` |
| `BS 13 & 14:1949` | `BS 13 & 14:1949` |
| `BS 13; 14; 15:1949` | `BS 13; 14; 15:1949` |
| `BS 13, 14, 15:1949` | `BS 13, 14, 15:1949` |

### Supplements

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `BS 0:1983+A1:2008` | `BS 0:1983+A1:2008` |
| `BS 0:1983/AC1:2005` | `BS 0:1983/AC1:2005` |
| `BS 0:1983+C1:2018` | `BS 0:1983+C1:2018` |

### Drafts

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `Draft BS 13:1949` | `Draft BS 13:1949` |
| `DBS 13:1949` | `DBS 13:1949` |

### Special Suffixes

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `BS 0(1983):Index:1981` | `BS 0(1983):Index:1981` |
| `BS 0(1983):Method 131B:1983` | `BS 0(1983):Method 131B:1983` |
| `BS 0(1983) Section 0:1977` | `BS 0(1983) Section 0:1977` |
| `N002:1974` | `N002:1974` |
| `C155-168:1971` | `C155-168:1971` |

## Testing

### Test Coverage

- **Unit tests:** `spec/pubid_new/bsi/components/`
- **Parser tests:** `spec/pubid_new/bsi/parser_spec.rb`
- **Builder tests:** `spec/pubid_new/bsi/builder_spec.rb`
- **Identifier tests:** `spec/pubid_new/bsi/identifiers/`
- **Integration tests:** `spec/integration/bsi_`

### Fixtures

Located in: `spec/fixtures/bsi/identifiers/`

- **Pass tests:** `pass/` - Valid patterns that should parse successfully
- **Fail tests:** `fail/` - Invalid patterns that should raise errors

### Coverage Status

The BSI flavor has comprehensive test coverage with ~85%+ coverage for all identifier classes and rendering patterns.

## Migration Notes

### V1 to V2 Changes

**Major architectural changes:**
1. **Three-layer separation** - Parser, Builder, and Identifier are completely separate
2. **Registry-based architecture** - Scheme class manages all type/stage lookups via TYPED_STAGES_REGISTRY
3. **TYPED_STAGES array** - Replaces hash-based TYPE_MAP pattern with harmonized stages
4. **Identifier class explosion** - 37+ specialized identifier classes vs single generic identifier
5. **Delegation pattern** - Adopted standards delegate to adopted identifier for number, year, parts
6. **Wrapper classes** - BundledIdentifier, SetIdentifier, ExpertCommentary, ValueAddedPublication

**Breaking changes:**
- `Pubid::Bsi::Identifier` → `PubidNew::Bsi::Identifiers::*` (specific classes)
- `type` and `stage` attributes replaced by `typed_stage` (combined object)
- Adopted standards now use delegation pattern instead of string attributes
- Multi-level adoption (BS EN ISO/IEC) split into separate wrapper classes

**Migration guide:**
1. Replace `Pubid::Bsi.parse()` with `PubidNew::Bsi.parse()`
2. Use specific identifier classes instead of generic `Identifier`
3. Access type/stage via `identifier.typed_stage`
4. For adopted standards, use delegation methods: `identifier.number`, `identifier.year`, etc.
5. For National Annexes, access base via `identifier.base_doc`

## References

- **Specification:** BSI (British Standards Institution)
- **Examples:** BSI Shop (https://shop.bsigroup.com/)
- **Related implementations:**
  - CEN flavor (European harmonization)
  - ISO flavor (adopted standards)
  - IEC flavor (adopted standards)

---

## Appendix: Design Decisions

### Ordered Parser Rules

**Context:** BSI has 37+ document types and many special patterns (committee documents, amendments, special suffixes).

**Decision:** Use ordered parser rules with most specific patterns first.

**Rationale:**
- Committee documents (YY/NNNNNNNN) must match before general identifiers
- Standalone amendments must match before general parsing
- Special suffixes (Index, Method, Section) must match in order
- Prevents ambiguous matches
- Ensures correct pattern recognition

**Alternatives considered:**
- Single identifier rule - Rejected (too permissive)
- Use negative lookahead - Rejected (complex grammar)

### TYPED_STAGES Registry with Harmonized Stages

**Context:** BSI participates in CEN harmonization and needs to map BSI stages to European harmonized stages.

**Decision:** Include `harmonized_stages` array in TypedStage objects.

**Rationale:**
- CEN integration requires stage mapping
- Harmonized stages like "60.00" (published), "30.00" (draft)
- Supports European standard adoption
- Single source of truth for stage mappings

**Alternatives considered:**
- Separate harmonization map - Rejected (violates DRY)
- No harmonization support - Rejected (breaks CEN adoption)

### Multi-Level Adoption Hierarchy

**Context:** BSI adopts standards at multiple levels (BS EN ISO/IEC, BS ISO/IEC, BS EN, bare ISO/IEC/EN).

**Decision:** Create separate wrapper classes for each adoption level with delegation pattern.

**Rationale:**
- BS EN ISO/IEC → AdoptedEuropeanNorm wraps AdoptedInternationalStandard wraps ISO/IEC
- Delegation pattern allows transparent access to adopted identifier attributes
- Clean separation of concerns
- Preserves BSI-specific rendering (BS EN prefix)

**Alternatives considered:**
- Single wrapper with type attribute - Rejected (loses specificity)
- Flatten to single identifier - Rejected (loses adoption hierarchy)

### Specialized Prefix Classes

**Context:** BSI has 20+ specialized prefixes (AU, HC, MA, PL, QC, TA, A, B, C, etc.) for different industries.

**Decision:** Create separate identifier classes for each specialized prefix.

**Rationale:**
- Each prefix has unique semantics
- Clean type separation
- Enables prefix-specific behavior
- Consistent with BSI document organization

**Alternatives considered:**
- Single class with prefix attribute - Rejected (loses type safety)
- Generic prefix handling - Rejected (loses specificity)

### Set and Bundle Notation

**Context:** BSI uses + for sets and various separators (and, to, &, semicolon, comma) for bundles.

**Decision:** Parse as separate SetIdentifier and BundledIdentifier classes.

**Rationale:**
- Sets and bundles have different semantics
- Sets use + (and) - documents sold together
- Bundles use various separators - ranges and groups
- Different rendering requirements

**Alternatives considered:**
- Single notation class - Rejected (loses semantic distinction)
- Rejection - Rejected (common BSI practice)

### National Annex Patterns

**Context:** National Annexes have complex patterns (NA+A1:2012 to BS EN 196-1:1995).

**Decision:** Create dedicated NationalAnnex class with supplements and base_doc.

**Rationale:**
- NA patterns are unique to BSI
- Forward format: "NA to BS..."
- Supplements in prefix: "NA+A1:2012"
- Delegation to base_doc for number, year, parts
- Special rendering with "to" separator

**Alternatives considered:**
- Parse as supplement - Rejected (different format)
- Include in base identifier - Rejected (mixes concerns)

### Value-Added Publication Wrappers

**Context:** BSI has value-added publications (PDF, BOOK, TC) that are formats, not identifiers.

**Decision:** Create ValueAddedPublication wrapper class.

**Rationale:**
- PDF, BOOK, TC are formats, not core identifiers
- Should not affect identifier matching
- Preserved for rendering
- Clean separation of concerns

**Alternatives considered:**
- Include in identifier class - Rejected (mixes concerns)
- Strip during parsing - Rejected (loses information)

### Opaque Adopted Identifiers

**Context:** BSI adopts CEN, ISO, IEC, CISPR standards which have their own complex identifier formats.

**Decision:** Parse adopted standards as opaque strings and delegate to respective flavors.

**Rationale:**
- CEN, ISO, IEC have their own parsers
- Avoids duplication of parsing logic
- Delegation pattern for attribute access
- Each flavor handles its own rendering

**Alternatives considered:**
- Parse in BSI parser - Rejected (duplicates logic, hard to maintain)
- Strip to basic number - Rejected (loses information)
