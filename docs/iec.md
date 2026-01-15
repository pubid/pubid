# IEC Documentation

## Overview

The IEC flavor handles identifiers for International Electrotechnical Commission (IEC) standards and related documents. It supports IEC's complete document lifecycle including International Standards, Technical Specifications, Technical Reports, Publicly Available Specifications, and Guides with full harmonized stage code support (00.00 through 95.99). The flavor also handles copublishers (ISO, IEEE, etc.), multi-level supplements (amendments, corrigenda), joint identifiers with ISO, and special identifier types including working documents, consolidated versions, VAP identifiers, sheet identifiers, and fragment identifiers.

## Architecture

This flavor follows the PubID v2 three-layer architecture pattern:

1. **Parser** (`parser.rb`) - Parslet PEG grammar for syntax parsing
   - Converts input strings into structured hash trees
   - Handles syntax validation and lenient parsing
   - Returns parse tree with component keys including typed stage abbreviations
   - Supports French-style identifiers (Guide IEC)
   - Parses joint identifiers (IEC 60414|ISO 8528)
   - Handles consolidated identifiers (+AMD chains)
   - Parses VAP suffixes (CSV/CMV/RLV/SER)
   - Handles sheet identifiers (/N:YEAR notation)
   - Parses fragment identifiers (/FRAGN notation)

2. **Builder** (`builder.rb`) - Transforms parse trees to domain objects via Scheme registry
   - Casts parsed hash values to component objects using `cast()` method
   - Uses Scheme registry for type/stage lookups via `locate_typed_stage_by_abbr()`
   - Instantiates appropriate identifier class via `locate_identifier_klass_by_type_code()`
   - Handles special cases: FRAG/FRAGC notation, TRF with CISPR identifiers
   - Detects and preserves rendering style from parsed input (long vs short stage format, language codes)
   - Wraps identifiers with specialized wrappers (ConsolidatedIdentifier, SheetIdentifier, FragmentIdentifier, VapIdentifier)
   - Merges copublishers into Publisher objects
   - Converts roman numeral parts to integers

3. **Identifier** (`identifiers/`) - Lutaml::Model domain classes with rendering logic
   - Base identifiers (SingleIdentifier) for standalone documents
   - Supplement identifiers (SupplementIdentifier) for amendments/corrigenda
   - Multi-format rendering support (:short, :long, :abbrev, :mr)
   - URN generation following ISO/IEC conventions
   - Automatic rendering style detection from parsed input

## Components

### Flavor-Specific Components

| Component | File | Purpose | Attributes |
|-----------|------|---------|------------|
| `VapSuffix` | `components/vap_suffix.rb` | VAP suffix codes (CSV/CMV/RLV/SER) | `code` |
| `RenderingStyle` | `rendering_style.rb` | IEC-specific rendering options | `with_language_code`, `stage_format_long`, `with_date` |

### Shared Components Used

| Component | From | Purpose in this flavor |
|-----------|------|------------------------|
| `Publisher` | `lib/pubid_new/components/publisher.rb` | Organization name and copublishers |
| `Code` | `lib/pubid_new/components/code.rb` | Generic string values (number, part, iteration) |
| `Date` | `lib/pubid_new/components/date.rb` | Year-based dates with optional month |
| `Type` | `lib/pubid_new/components/type.rb` | Document type |
| `Language` | `lib/pubid_new/components/language.rb` | Language codes with original_code preservation |
| `Stage` | `lib/pubid_new/components/stage.rb` | Development stage |
| `TypedStage` | `lib/pubid_new/components/typed_stage.rb` | Combined stage+type with rendering format support (short_abbr, long_abbr) |
| `Edition` | `lib/pubid_new/components/edition.rb` | Edition information with original text preservation |

## Identifier Classes

### Base Identifiers

#### InternationalStandard

- **File:** `lib/pubid_new/iec/identifiers/international_standard.rb`
- **Parent:** `Base` (via `SingleIdentifier`)
- **Purpose:** The primary IEC document type representing International Standards. Supports the complete harmonized stage lifecycle from CD through published.
- **Components Used:** `publisher`, `type`, `number`, `part`, `subpart`, `stage_iteration`, `date`, `languages`, `edition`
- **Patterns Supported:**
  - `IEC 60038` → Published International Standard
  - `IEC/IEEE 60335-2-96` → Joint IEC/IEEE standard
  - `IEC 60038-1` → Standard with part
  - `IEC 60038:2015` → Standard with edition year
  - `IEC CD 60038` → Committee Draft stage
  - `IEC CDV 60038` → Committee Draft for Vote
  - `IEC FDIS 60038` → Final Draft International Standard
  - `IEC 60038:2015/AMD 1:2017` → Standard with amendment (supplement recursion)
- **TYPED_STAGES:** 4 stages covering main lifecycle:
  - `` (is) - Published International Standard (default, empty abbr)
  - `CD` (cdis) - Committee Draft
  - `CDV` (cdv) - Committee Draft for Vote
  - `FDIS` (fdis) - Final Draft International Standard
- **PROJECT_STAGES:** IEC-specific workflow stages (11 stages: AFDIS, CCDV, CDVM, CFDIS, DECFDIS, NCDV, NFDIS, PRVC, PRVD, RFDIS, TCDV)
- **Rendering Formats:** All formats supported (:short, :long, :abbrev, :mr)

#### TechnicalSpecification

- **File:** `lib/pubid_new/iec/identifiers/technical_specification.rb`
- **Parent:** `Base`
- **Purpose:** Technical Specifications for documents still under development or with limited stability.
- **Components Used:** `publisher`, `type`, `number`, `part`, `subpart`, `date`, `languages`, `edition`
- **Patterns Supported:**
  - `IEC TS 62607-6-1` → Published Technical Specification
  - `IEC TS 62607-6-1:2019` → Technical Specification with year
  - `IEC DTS 62607-6-1` → Draft Technical Specification
- **TYPED_STAGES:** 2 stages:
  - `DTS` (dts) - Draft
  - `TS` (ts) - Published
- **PROJECT_STAGES:** 6 IEC-specific workflow stages (ADTS, CDTS, DTSM, NDTS, PRVDTS, TDTS)
- **Rendering Formats:** All formats supported

#### TechnicalReport

- **File:** `lib/pubid_new/iec/identifiers/technical_report.rb`
- **Parent:** `Base`
- **Purpose:** Technical Reports containing collected data or information. Used for informative documents that are not full standards.
- **Components Used:** `publisher`, `type`, `number`, `part`, `subpart`, `date`, `languages`, `edition`
- **Patterns Supported:**
  - `IEC TR 61000-1-1` → Published Technical Report
  - `IEC/TR 61000-1-1:2019` → Technical Report with year
  - `IEC DTR 61000-1-1` → Draft Technical Report
- **TYPED_STAGES:** 2 stages:
  - `DTR` (dtr) - Draft
  - `TR` (tr) - Published
- **PROJECT_STAGES:** 6 IEC-specific workflow stages (ADTR, CDTR, DTRM, NDTR, PRVDTR, TDTR)
- **Rendering Formats:** All formats supported

#### PubliclyAvailableSpecification

- **File:** `lib/pubid_new/iec/identifiers/publicly_available_specification.rb`
- **Parent:** `Base`
- **Purpose:** Publicly Available Specifications (PAS) are fast-track documents developed by external organizations and approved by IEC.
- **Components Used:** `publisher`, `type`, `number`, `part`, `subpart`, `date`, `languages`, `edition`
- **Patterns Supported:**
  - `IEC PAS 62696-1` → Published PAS
  - `IEC/PAS 62696-1:2021` → PAS with year
  - `IEC DPAS 62696-1` → Draft PAS
- **TYPED_STAGES:** 3 stages:
  - `DPAS` (dpas) - Draft
  - `CDPAS` (cdpas) - Draft circulated
  - `PAS` (pas) - Published
- **PROJECT_STAGES:** 1 stage (PRVDPAS)
- **Rendering Formats:** All formats supported

#### Guide

- **File:** `lib/pubid_new/iec/identifiers/guide.rb`
- **Parent:** `Base`
- **Purpose:** IEC and IEC/ISO Guides provide rules, guidelines, or recommendations for standards development. Uses space before "Guide".
- **Components Used:** `publisher`, `type`, `number`, `part`, `subpart`, `date`, `languages`, `edition`
- **Patterns Supported:**
  - `IEC GUIDE 108` → Published Guide (canonical form)
  - `IEC/ISO GUIDE 37:2016` → Joint Guide with year
  - `Guide IEC 108` → French style (reverse order)
  - `IEC DGuide 108` → Draft Guide
  - `IEC FDGuide 108` → Final Draft Guide
- **TYPED_STAGES:** 3 stages:
  - `DGuide` (dguide) - Draft
  - `FDGuide` (fdguide) - Final Draft
  - `GUIDE`, `Guide` (guide) - Published
- **Rendering Formats:** All formats supported. Special rendering: space before "Guide".

### Supplement Identifiers

#### Amendment

- **File:** `lib/pubid_new/iec/identifiers/amendment.rb`
- **Parent:** `SupplementIdentifier`
- **Purpose:** Amendments (Amd) modify or add to an existing base standard.
- **Components Used:** `base_identifier`, `type`, `number`, `part`, `subpart`, `date`, `languages`, `edition`
- **Patterns Supported:**
  - `IEC 60038:2015/AMD 1:2017` → Standard with amendment
  - `IEC 60038:2015/DAM 1` → Draft amendment
  - `IEC 60038:2015/FDAM 1` → Final draft amendment
  - `IEC 60038:2015/AMD 1/AMD 2` → Amendment to amendment (multi-level recursion)
- **TYPED_STAGES:** 4 stages:
  - `CDAM` (cdamd) - Committee Draft
  - `DAM` (damd) - Draft
  - `FDAM` (fdamd) - Final Draft
  - `Amd`, `AMD` (pubamd) - Published
- **Recursion:** Supports multi-level amendments (amendment to amendment)
- **Rendering Formats:** All formats supported with short/long stage format detection

#### Corrigendum

- **File:** `lib/pubid_new/iec/identifiers/corrigendum.rb`
- **Parent:** `SupplementIdentifier`
- **Purpose:** Corrigenda (Cor) correct errors in published standards.
- **Components Used:** `base_identifier`, `type`, `number`, `part`, `subpart`, `date`, `languages`, `edition`
- **Patterns Supported:**
  - `IEC 60038:2015/COR 1:2017` → Standard with corrigendum
  - `IEC 60038:2015/DCOR 1` → Draft corrigendum
  - `IEC 60038:2015/FDCOR 1` → Final draft corrigendum
  - `IEC 60038:2015/AMD 1/COR 1` → Corrigendum to amendment
- **TYPED_STAGES:** 4 stages:
  - `CDCor` (cdcor) - Committee Draft
  - `DCOR` (dcor) - Draft
  - `FDCOR` (fdcor) - Final Draft
  - `Cor`, `COR` (pubcor) - Published
- **Recursion:** Supports multi-level supplements (corrigendum to amendment, etc.)
- **Rendering Formats:** All formats supported

### Special Identifiers

#### WorkingDocument

- **File:** `lib/pubid_new/iec/identifiers/working_document.rb`
- **Parent:** `Base`
- **Purpose:** IEC working documents with technical committee prefix and draft number (e.g., 1/1823/CDV).
- **Components Used:** `technical_committee`, `wd_number`, `wd_stage`
- **Patterns Supported:**
  - `1/1823/CDV` → Working document with CDV stage
  - `122/45/CD` → Committee document
- **Rendering Formats:** Short format (working document notation)

#### ConsolidatedIdentifier

- **File:** `lib/pubid_new/iec/identifiers/consolidated_identifier.rb`
- **Parent:** `Identifier`
- **Purpose:** Consolidated versions including base standard and all amendments (+AMD notation).
- **Components Used:** `identifiers` (array of base + supplements)
- **Patterns Supported:**
  - `IEC 60038-1:1999+AMD1:2001+AMD2:2005CSV` → Consolidated with amendments
- **Rendering Formats:** Special rendering with + notation

#### SheetIdentifier

- **File:** `lib/pubid_new/iec/identifiers/sheet_identifier.rb`
- **Parent:** `Identifier`
- **Purpose:** Sheet identifier with sheet number and year (/N:YEAR notation).
- **Components Used:** `base_identifier`, `sheet_number`, `year`
- **Patterns Supported:**
  - `IEC 60038:2009/1:2012` → Sheet identifier
- **Rendering Formats:** Special rendering with /N:YEAR notation

#### FragmentIdentifier

- **File:** `lib/pubid_new/iec/identifiers/fragment_identifier.rb`
- **Parent:** `Identifier`
- **Purpose:** Fragment identifier extracted from amendment or corrigendum (/FRAGN notation).
- **Components Used:** `base_identifier`, `fragment_number`, `edition`
- **Patterns Supported:**
  - `IEC 60038:2015/AMD 1:2017/FRAG1` → Fragment identifier
- **Rendering Formats:** Special rendering with /FRAGN notation

#### VapIdentifier

- **File:** `lib/pubid_new/iec/identifiers/vap_identifier.rb`
- **Parent:** `Identifier`
- **Purpose:** VAP (Verified Adoption Process) identifier with suffix code (CSV/CMV/RLV/SER).
- **Components Used:** `base_identifier`, `vap_suffix`, `edition`
- **Patterns Supported:**
  - `IEC 60038-1-2 Ed. 2.0 CSV` → VAP with CSV suffix
  - `IEC 60038-1-2 Ed. 2.0 CMV` → VAP with CMV suffix
- **Rendering Formats:** Special rendering with VAP suffix

## Scheme Registry

The `Scheme` class (`lib/pubid_new/iec/scheme.rb`) is the central registry for this flavor.

### Registry Methods

- **`identifiers`** - Array of all registered identifier classes
  ```ruby
  IDENTIFIERS = [
    Identifiers::InternationalStandard,
    Identifiers::TechnicalSpecification,
    Identifiers::TechnicalReport,
    Identifiers::PubliclyAvailableSpecification,
    Identifiers::Guide,
  ]
  ```

- **`supplement_identifiers`** - Array of supplement identifier classes
  ```ruby
  SUPPLEMENT_IDENTIFIERS = [
    Identifiers::Amendment,
    Identifiers::Corrigendum,
  ]
  ```

- **`typed_stages`** - Aggregate TYPED_STAGES from all identifier classes
  ```ruby
  def typed_stages
    identifiers.flat_map { |klass| klass::TYPED_STAGES }
  end
  ```

- **`supplement_typed_stages`** - TYPED_STAGES for supplement identifiers only
  ```ruby
  def supplement_typed_stages
    supplement_identifiers.flat_map { |klass| klass::TYPED_STAGES }
  end
  ```

- **`locate_typed_stage_by_abbr(abbr)`** - Find stage by abbreviation
  - Returns `TypedStage` object or raises `ArgumentError`
  - Searches through all registered TYPED_STAGES
  - Empty string (`""`) returns published International Standard (default)
  - Supports abbreviation arrays

- **`locate_identifier_klass_by_type_code(type_code)`** - Select class by type code
  - Returns identifier class based on type_code from parsed data
  - Used by Builder to determine which class to instantiate
  - Example: `:is` → `Identifiers::InternationalStandard`, `:amd` → `Identifiers::Amendment`

### Parser Instance

```ruby
# Parser is not memoized in IEC
# Parser.new() is called directly in Identifier.parse()
```

## Rendering Examples

### Short Format (`:short`)

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `IEC 60038:2015` | `IEC 60038:2015` |
| `IEC/IEEE 60335-2-96:2012` | `IEC/IEEE 60335-2-96:2012` |
| `IEC/TR 61000-1-1:2019` | `IEC TR 61000-1-1:2019` |
| `IEC 60038:2015/AMD 1:2017` | `IEC 60038:2015/AMD 1:2017` |
| `IEC 60038:2015/COR 1` | `IEC 60038:2015/COR 1` |

### Long Format (`:long`)

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `IEC 60038:2015` | `IEC 60038:2015` |
| `IEC 60038:2015/AMD 1:2017` | `IEC 60038:2015/DAm 1:2017` |
| `IEC 60038:2015/COR 1` | `IEC 60038:2015/DCor 1` |

## Parser Rules

### Main Rule

```ruby
rule(:identifier) do
  (type_with_stage.as(:type_with_stage) >> space).maybe >>
    prefix_with_copublishers.as(:publisher) >>
    space >>
    number_with_part.as(:number_with_part) >>
    stage_iteration.maybe >>
    date.maybe >>
    (space >> edition).maybe >>
    languages.maybe
end
```

### Component Rules

```ruby
# Publisher with optional copublishers
rule(:prefix_with_copublishers) do
  prefix_sole_publisher >> space? >> copublishers.maybe
end

# Copublishers (ISO, IEEE, etc.)
rule(:copublishers) do
  (str("/") >> space? >> array_to_str(ORGANIZATIONS).as(:copublisher)).repeat.as(:copublishers)
end

# Number with optional part and subpart
rule(:number_with_part) do
  (number >> part_and_subpart.maybe).as(:number_with_part)
end

# Type with stage (CD, CDV, FDIS, etc.)
rule(:type_with_stage) do
  array_to_str(TYPED_STAGES).as(:type_with_stage) >>
    (match('\d').as(:stage_iteration) >> space).maybe
end

# Supplement type with stage (AMD, COR, DAM, FDCOR, etc.)
rule(:supplement_type_with_stage) do
  array_to_str(TYPED_STAGES_SUPPLEMENTS).as(:type_with_stage)
end

# Language codes (E/F/R or en/fr/ru)
rule(:language) do
  str("(") >>
    ((match["a-z"].repeat(1) >> str(",").maybe) |
     (match["EFARDS"] >> str("/").maybe)).repeat.as(:languages) >>
    str(")")
end

# Edition (Ed.2, Ed 2, Edition 13)
rule(:edition) do
  (array_to_str(EDITION_STRINGS) >> space? >> digits.maybe).as(:edition)
end
```

### Special Patterns

```ruby
# Consolidated identifier (base + supplements)
rule(:consolidated_supplement) do
  str("+") >>
    (supplement_type.as(:supplement_type) >>
     supplement_number.as(:supplement_number) >>
     (str(":") >> supplement_year.as(:supplement_year)).maybe)
end

# VAP suffix (CSV/CMV/RLV/SER)
rule(:vap_suffix) do
  str("Ed.") >> space >> edition_number.as(:edition_number) >> space >> str("CSV").as(:vap_suffix) |
  str("Ed.") >> space >> edition_number.as(:edition_number) >> space >> str("CMV").as(:vap_suffix) |
  str("Ed.") >> space >> edition_number.as(:edition_number) >> space >> str("RLV").as(:vap_suffix) |
  str("Ed.") >> space >> edition_number.as(:edition_number) >> space >> str("SER").as(:vap_suffix)
end

# Fragment identifier
rule(:fragment_identifier) do
  str("/") >> (str("FRAG") | str("FRAGC")).as(:type_with_stage) >>
    fragment_number.as(:fragment_number) >>
    (space >> edition).maybe
end

# Sheet identifier
rule(:sheet_identifier) do
  str("/") >> sheet_number.as(:sheet_number) >> str(":") >> sheet_year.as(:sheet_year)
end
```

## Builder Logic

### Identifier Class Selection

The Builder determines which identifier class to instantiate based on:

1. **Working document indicators** - If `:wp_stage` or `:technical_committee`+`:wd_number` → `WorkingDocument`
2. **Type code from TypedStage** - `locate_identifier_klass_by_type_code()` called with type_code

### Type Code Mappings

| Type Code | Identifier Class |
|-----------|------------------|
| `:is` | `InternationalStandard` |
| `:ts` | `TechnicalSpecification` |
| `:tr` | `TechnicalReport` |
| `:pas` | `PubliclyAvailableSpecification` |
| `:guide` | `Guide` |
| `:amd` | `Amendment` |
| `:cor` | `Corrigendum` |

### Component Casting

Special casting logic in Builder's `cast()` method:

```ruby
# Number with part (handles multi-level parts and roman numerals)
when :number_with_part
  # "60038-1" → number="60038", part="1"
  # "60038-1-2" → number="60038", part="1", subpart="2"
  # "29110-5-1-1" → number="29110", part="5", subpart="1-1"
  # Roman numerals converted to integers

# Type with stage (preserves original abbreviation)
when :type_with_stage
  # "CDV" → TypedStage with original_abbr="CDV"
  # "DAM" → TypedStage with short_abbr="DAM"

# Languages (supports both single-char and ISO codes)
when :languages
  # "E/F/R" → original_code preserved
  # "en,fr,ru" → converted to 2-char codes

# Publisher (merges copublishers)
when :publisher
  # Hash: {publisher: "IEC", copublisher: ["ISO", "IEEE"]}
  # → Publisher object with copublisher array
```

### Rendering Style Detection

The Builder automatically detects rendering style from parsed input:

```ruby
# Stage format detection (long vs short)
stage_format_long = if ts.long_abbr && ts.original_abbr && ts.original_abbr.include?(" ")
                      true  # "Amd 1", "Cor 1" (space before number)
                    else
                      false # "AMD1", "COR1" (no space)
                    end

# Language code format detection
with_language_code = if first_lang.original_code&.length == 1
                       :single  # "E", "F", "R"
                     else
                       :iso    # "en", "fr", "ru"
                     end
```

### Wrapper Methods

The Builder provides specialized wrapper methods:

- **`wrap_with_fragment`** - Creates FragmentIdentifier for /FRAGN notation
- **`wrap_with_sheet`** - Creates SheetIdentifier for /N:YEAR notation
- **`wrap_with_consolidated`** - Creates ConsolidatedIdentifier for +AMD chains
- **`wrap_with_vap`** - Creates VapIdentifier for VAP suffixes

## Preprocessing

This flavor uses preprocessing to normalize input before parsing:

| Pattern | Input | Output | Purpose |
|---------|-------|--------|---------|
| Dash normalization | `IEC 60038‑1` (en-dash) | `IEC 60038-1` | Normalize Unicode dashes to ASCII hyphen |
| French Guide | `Guide IEC 51` | `type_with_stage_fr=Guide` | French-style identifier |
| Fragment notation | `IEC 60038/FRAG1` | `type_with_stage=FRAG` | Fragment indicator |
| VAP suffix | `IEC 60038 Ed. 2.0 CSV` | `vap_suffix=CSV` | VAP indicator |

Preprocessing is **explicit** and **format-preserving** - the original format is stored for exact reproduction during rendering.

## Testing

### Test Coverage

- **Unit tests:** `spec/pubid_new/iec/components/`
- **Parser tests:** `spec/pubid_new/iec/parser_spec.rb`
- **Builder tests:** `spec/pubid_new/iec/builder_spec.rb`
- **Identifier tests:** `spec/pubid_new/iec/identifiers/`
- **Integration tests:** `spec/integration/iec_`

### Fixtures

Located in: `spec/fixtures/iec/identifiers/`

- **Pass tests:** `pass/` - Valid patterns that should parse successfully
- **Fail tests:** `fail/` - Invalid patterns that should raise errors

### Coverage Status

The IEC flavor has comprehensive test coverage with ~95%+ coverage for all identifier classes and rendering patterns.

## Migration Notes

### V1 to V2 Changes

**Major architectural changes:**
1. **Three-layer separation** - Parser, Builder, and Identifier are completely separate
2. **Registry-based architecture** - Scheme class manages all type/stage lookups
3. **TYPED_STAGES array** - Replaces hash-based TYPE_MAP pattern
4. **Rendering styles** - Explicit rendering style objects (RenderingStyle class)
5. **V2 components** - Edition, Volume, Part components instead of raw strings

**Breaking changes:**
- `Pubid::Iec::Identifier` → `PubidNew::Iec::Identifiers::*` (specific classes)
- `type` and `stage` attributes replaced by `typed_stage` (combined object)
- `render()` method replaced by `to_s(format: ...)` or `rendering_style` object

**Migration guide:**
1. Replace `Pubid::Iec.parse()` with `PubidNew::Iec.parse()`
2. Use specific identifier classes instead of generic `Identifier`
3. Access type/stage via `identifier.typed_stage`
4. Use `format: :short|:long` parameter for different renderings

## References

- **Specification:** IEC/ISO Directives, Part 2 - Rules for the structure and drafting of International Standards
- **Examples:** IEC webstore (https://webstore.iec.ch/)
- **Related implementations:**
  - ISO flavor (similar structure, shared TYPED_STAGES pattern)
  - IEEE flavor (copublisher support)

---

## Appendix: Design Decisions

### IEC-specific Rendering Styles

**Context:** IEC identifiers have multiple valid formats for the same semantic content (AMD vs Amd, short vs long stage format, language codes).

**Decision:** Builder detects and preserves rendering style from parsed input using `RenderingStyle` class.

**Rationale:**
- Round-trip preservation: parsed identifiers render identically
- IEC-specific convention: space indicates long form (Amd 1), no space indicates short (AMD1)
- Language codes: single-char (E/F/R) vs ISO format (en/fr/ru)

**Alternatives considered:**
- Always render canonical form - Rejected (loses format information)
- Store format as separate parameter - Rejected (less elegant)

### Specialized Wrapper Classes

**Context:** IEC has complex identifier patterns that don't fit the base/supplement model (Consolidated, Sheet, Fragment, VAP).

**Decision:** Create specialized wrapper classes for each pattern type.

**Rationale:**
- Clean separation of concerns
- Each wrapper has its own rendering logic
- Base identifiers remain unchanged
- Extensible for future IEC patterns

**Alternatives considered:**
- Add flags to base identifier - Rejected (too many flags, less clear)
- Store as string literals - Rejected (loses structure)

### Working Document Notation

**Context:** IEC working documents use a special notation (e.g., 1/1823/CDV) that differs from standard identifiers.

**Decision:** Create separate `WorkingDocument` class with dedicated parsing rules.

**Rationale:**
- Working documents have fundamentally different structure
- TC prefix, WD number, and stage are all required
- Cannot be parsed by standard identifier rules
- Clear separation between working documents and published standards

**Alternatives considered:**
- Parse as base identifier with custom fields - Rejected (confusing structure)
- Store as string literal - Rejected (loses validation)
