# IEEE Documentation

## Overview

The IEEE flavor handles identifiers for Institute of Electrical and Electronics Engineers (IEEE) standards and related documents. It supports IEEE's complete document lifecycle including draft stages (D1-D9), published standards, and specialized identifier types. The flavor handles copublishers (ISO, IEC, ANSI, etc.), dual published standards, joint development with ISO/IEC, adopted standards, and special identifiers including corrigenda, interpretations, conformance documents, and SI/PSI (Système International) standards. It also supports historical AIEE and IRE standards.

## Architecture

This flavor follows the PubID v2 three-layer architecture pattern:

1. **Parser** (`parser.rb`) - Parslet PEG grammar for syntax parsing
   - Converts input strings into structured hash trees
   - Handles syntax validation and lenient parsing
   - Supports dual published patterns (comma, semicolon, "and", "&" separated)
   - Parses adopted standards (parenthetical adoptions)
   - Handles draft notation (/D1-D9, /P)
   - Supports ISO/IEC stages for joint development (PWI, NP, WD, CD, DIS, FDIS)
   - Parses supplements (/COR, /INT, /Conformance)
   - Handles NESC (National Electrical Safety Code) patterns
   - Supports AIEE and IRE historical standards
   - Extracts relationships (revision_of, amendment_to, supersedes, incorporates)

2. **Builder** (`builder.rb`) - Transforms parse trees to domain objects via Scheme registry
   - Casts parsed hash values to component objects
   - Uses Scheme registry for type/stage lookups via `locate_typed_stage_by_abbr()`
   - Instantiates appropriate identifier class via `determine_identifier_class()`
   - Handles special cases: dual published, adopted standards, IEC/IEEE copublished
   - Creates specialized wrappers (Corrigendum, Interpretation, Conformance)
   - Builds relationship objects (revision_of, amendment_to, etc.)
   - Supports recursive base identifier parsing for supplements

3. **Identifier** (`identifiers/`) - Lutaml::Model domain classes with rendering logic
   - Base identifier for all IEEE standards
   - Specialized classes for adopted, dual published, joint development
   - Supplement identifiers (Corrigendum, Interpretation, Conformance)
   - Historical identifiers (AIEE, IRE)
   - Multi-format rendering with preservation of original format

## Components

### Flavor-Specific Components

| Component | File | Purpose | Attributes |
|-----------|------|---------|------------|
| `Code` | `components/code.rb` | IEEE standard number with letter prefix and parts | `letter`, `number`, `parts` |
| `Draft` | `components/draft.rb` | Draft information (version, revision, date) | `version`, `revision`, `month`, `year`, `day` |
| `Relationship` | `components/relationship.rb` | Document relationships (revision, amendment, supersedes) | `relationship_type`, `related_identifiers`, `intermediate_amendments` |
| `TypedStage` | `components/typed_stage.rb` | Combined stage+type with IEEE/ISO stage equivalents | `abbr`, `stage_code`, `type_code`, `ieee_draft_equivalent`, `iso_stage_equivalent`, `approval_status`, `project_status` |

### Shared Components Used

| Component | From | Purpose in this flavor |
|-----------|------|------------------------|
| `Publisher` | `lib/pubid_new/components/publisher.rb` | Organization name (IEEE, ANSI, etc.) |
| `Code` | `lib/pubid_new/components/code.rb` | Not used - IEEE has its own Code implementation |
| `Type` | `lib/pubid_new/components/type.rb` | Document type (Std, Draft Std, etc.) |
| `Date` | `lib/pubid_new/components/date.rb` | Year-based dates with optional month/day |

## Identifier Classes

### Base Identifiers

#### Base

- **File:** `lib/pubid_new/ieee/identifiers/base.rb`
- **Parent:** `Lutaml::Model::Serializable`
- **Purpose:** The base class for all IEEE identifiers. Handles the complete IEEE standard format with publisher, copublishers, type, code, draft information, year, edition, and relationships.
- **Components Used:** `publisher`, `copublisher`, `code_obj`, `draft_obj`, `type`, `year`, `month`, `day`, `edition`, `typed_stage`, `relationships`, `redline`, `amendments`, `corrigenda`
- **Patterns Supported:**
  - `IEEE Std 802.3-2018` → Published standard
  - `ANSI/IEEE Std 500-1984` → With copublisher (ANSI)
  - `IEEE P802.3` → Project standard (P prefix)
  - `IEEE Std 802.3/D1` → Draft with version
  - `IEEE Std 802.3-2018 Edition 1.0` → With edition
  - `IEEE Std 802.3-2018, January 2019` → With month
  - `IEEE Std 802.3-2018 (R2023)` → Reaffirmed
  - `IEEE Std 802.3-2018 (Revision of IEEE Std 802.3-2015)` → With relationship
- **Typed Stages:** Supports IEEE draft notation (D1-D9) and ISO stages (PWI, NP, WD, CD, DIS, FDIS) for joint development
- **Rendering Formats:** Preserves original format (space before draft, comma before month, etc.)

#### Standard

- **File:** `lib/pubid_new/ieee/identifiers/standard.rb`
- **Parent:** `Base`
- **Purpose:** Published IEEE standards with "Std" type designation.
- **Components Used:** Same as Base
- **Patterns Supported:**
  - `IEEE Std 802.3-2018` → Standard format
  - `ANSI/IEEE Std 500-1984` → Copublished with ANSI
- **Typed Stages:** Single stage ("Std" - published)
- **Rendering Formats:** Standard IEEE format with "Std" type

### Supplement Identifiers

#### Corrigendum

- **File:** `lib/pubid_new/ieee/identifiers/corrigendum.rb`
- **Parent:** `Base` (with base_identifier)
- **Purpose:** Corrigenda (COR) correct errors in published IEEE standards.
- **Components Used:** `base_identifier`, `cor_number`, `cor_year`
- **Patterns Supported:**
  - `IEEE Std 802.3-2018/COR 1-2019` → Corrigendum with year
  - `IEEE Std 802.3-2018/COR 1` → Corrigendum without year
- **Rendering Formats:** Appends /COR notation with optional year

#### InterpretationIdentifier

- **File:** `lib/pubid_new/ieee/identifiers/interpretation_identifier.rb`
- **Parent:** `Base` (with base_identifier)
- **Purpose:** Interpretations (INT) provide official interpretations of IEEE standards.
- **Components Used:** `base_identifier`, `int_year`, `interpretation` flag
- **Patterns Supported:**
  - `IEEE Std 802.3-2018/INT-2019` → Interpretation with year
  - `IEEE Std 802.3-2018/INT` → Interpretation without year
- **Rendering Formats:** Appends /INT notation with optional year

#### ConformanceIdentifier

- **File:** `lib/pubid_new/ieee/identifiers/conformance_identifier.rb`
- **Parent:** `Base` (with base_identifier)
- **Purpose:** Conformance documents specify how to demonstrate compliance with a standard.
- **Components Used:** `base_identifier`, `conf_number`, `conf_year`
- **Patterns Supported:**
  - `IEEE Std 802.3-2018/Conformance1-2019` → Conformance with year
  - `IEEE Std 802.3-2018/Conformance1` → Conformance without year
- **Rendering Formats:** Appends /Conformance notation with optional year

### Special Identifiers

#### AdoptedStandard

- **File:** `lib/pubid_new/ieee/identifiers/adopted_standard.rb`
- **Parent:** `Identifier` (wrapper)
- **Purpose:** IEEE standards that adopt other organizations' standards (ANSI, ISO, IEC, etc.).
- **Components Used:** `ieee_identifier`, `adopted_identifier`
- **Patterns Supported:**
  - `IEEE Std 802.3-2018 (ANSI/INCITS 518-2009)` → Adopted ANSI standard
  - `IEEE Std C62.41-1991 (IEC 801-4:1988)` → Adopted IEC standard
- **Rendering Formats:** Main identifier with adopted standard in parentheses

#### DualPublished

- **File:** `lib/pubid_new/ieee/identifiers/dual_published.rb`
- **Parent:** `Identifier` (wrapper)
- **Purpose:** Two distinct IEEE identifiers published together (separated by "and", comma, semicolon, or "&").
- **Components Used:** `first_identifier`, `second_identifier`, `separator`
- **Patterns Supported:**
  - `IEEE Std 960-1989 and IEEE Std 1177-1989` → "and" separated
  - `IEEE Std 960-1989, Std 1177-1989` → Comma separated (preprocessed)
  - `IEC 62014-5; IEEE Std 1734-2011` → Semicolon separated
  - `IEEE Std 960-1989 & IEEE Std 1177-1989` → Ampersand separated
- **Rendering Formats:** Joins identifiers with specified separator

#### JointDevelopment

- **File:** `lib/pubid_new/ieee/identifiers/joint_development.rb`
- **Parent:** `Identifier`
- **Purpose:** Standards jointly developed by multiple organizations (IEEE/ISO/IEC).
- **Components Used:** `publishers`, `code`, `year`, `lead_party`, `typed_stage`, `ieee_draft`, `iso_stage`
- **Patterns Supported:**
  - `IEEE/ISO 14644-1` → Joint IEEE/ISO standard
  - `ISO/IEEE 11073-20601:2014` → ISO-led joint standard
  - `IEEE P14644-1/D8` → IEEE-led joint draft
- **Rendering Formats:** Publisher order depends on lead_party (IEEE-first or ISO-first)

#### IecIeeeCopublished

- **File:** `lib/pubid_new/ieee/identifiers/iec_ieee_copublished.rb`
- **Parent:** `Identifier`
- **Purpose:** IEC/IEEE copublished standards with separate numbers and years.
- **Components Used:** `copublished_number`, `draft_info`, `iec_year`, `date_info`
- **Patterns Supported:**
  - `IEC/IEEE 60601-1-2:2014; IEEE 60601-1-2:2014` → Full copublished format
  - `IEC 62014-5 IEEE Std 1734-2011` → Simplified format
- **Rendering Formats:** Special copublished format with IEC year

#### CsaDualPublished

- **File:** `lib/pubid_new/ieee/identifiers/csa_dual_published.rb`
- **Parent:** `Identifier` (wrapper)
- **Purpose:** IEEE/CSA dual published standards (Canadian Standards Association).
- **Components Used:** `ieee_identifier`, `csa_identifier`
- **Patterns Supported:**
  - `IEEE/CSA P844.1-2017` → IEEE/CSA project
  - `IEEE/CSA Std 844.1-2017` → IEEE/CSA published standard
- **Rendering Formats:** Uses CSA parser for CSA portion

#### MultiNumberedIdentifier

- **File:** `lib/pubid_new/ieee/identifiers/multi_numbered_identifier.rb`
- **Parent:** `Identifier` (wrapper)
- **Purpose:** IEEE standards with multiple designations (cross-references or joint standards).
- **Components Used:** `primary_identifier`, `secondary_identifier`
- **Patterns Supported:**
  - `IEEE Std 802.3-2018/C62.22.1-1996` → Cross-reference notation
  - `IEEE Std 802.3-2018, Std 1177-1989` → Joint standard notation
- **Rendering Formats:** Appends cross-reference or joint notation

#### SiStandard

- **File:** `lib/pubid_new/ieee/identifiers/si_standard.rb`
- **Parent:** `Base`
- **Purpose:** IEEE/ASTM SI (Système International) and PSI (project SI) standards.
- **Components Used:** `publisher`, `copublisher`, `code`, `draft_obj`, `typed_stage`, `year`, `month`, `relationships`
- **Patterns Supported:**
  - `IEEE/ASTM SI 10-2016` → Published SI standard
  - `IEEE/ASTM PSI 10-2016` → Project SI standard (draft)
- **Typed Stages:** Two stages (SI - published, PSI - project)
- **Rendering Formats:** SI/PSI notation with draft version if PSI

#### RedlinedStandard

- **File:** `lib/pubid_new/ieee/identifiers/redlined_standard.rb`
- **Parent:** `Base`
- **Purpose:** IEEE standards with redline (changes marked) notation.
- **Components Used:** Same as Base, plus `redline` flag
- **Patterns Supported:**
  - `IEEE Std 802.3-2018 - Redline` → Redline standard
- **Rendering Formats:** Appends " - Redline" suffix

#### SupplementIdentifier

- **File:** `lib/pubid_new/ieee/identifiers/supplement_identifier.rb`
- **Parent:** `Base` (with base_identifier)
- **Purpose:** Generic supplements to IEEE standards.
- **Components Used:** `base_identifier`, `supplement_type`, `supplement_number`, `supplement_year`
- **Patterns Supported:**
  - `IEEE Std 802.3-2018/AMD 1-2019` → Amendment
  - `IEEE Std 802.3-2018/ERRATA 1` → Errata
- **Rendering Formats:** Appends supplement notation with optional year

### Historical Identifiers

#### AIEE Standards

- **File:** `lib/pubid_new/ieee/aiee/` (separate module)
- **Parent:** Historical standard class
- **Purpose:** American Institute of Electrical Engineers (AIEE) standards (pre-1963).
- **Components Used:** `publisher`, `code`, `year`, `type` ("No" or "No.")
- **Patterns Supported:**
  - `AIEE No 18-1934` → AIEE standard
  - `AIEE No. 18-1934` → Alternative format
- **Rendering Formats:** Uses "No" or "No." type designation

#### IRE Standards

- **File:** `lib/pubid_new/ieee/ire/` (separate module)
- **Parent:** Historical standard class
- **Purpose:** Institute of Radio Engineers (IRE) standards (pre-1963).
- **Components Used:** `publisher`, `number`, `year`, `series`
- **Patterns Supported:**
  - `56 IRE 28.S2` → IRE standard
  - `22 IRE 18.S1` → Alternative format
- **Rendering Formats:** Uses series notation

## Scheme Registry

The `Scheme` class (`lib/pubid_new/ieee/scheme.rb`) is the central registry for this flavor.

### Registry Methods

- **`locate_typed_stage_by_abbr(abbr)`** - Find stage by abbreviation
  - Returns `TypedStage` object or default to "Std"
  - Supports IEEE draft notation (D1-D9, P)
  - Supports ISO stages (PWI, NP, WD, CD, DIS, FDIS)
  - Supports historical stages ("No", "No.")

- **`locate_typed_stage_by_ieee_draft(draft)`** - Find stage by IEEE draft notation
  - Returns `TypedStage` object or nil
  - Example: "D1" → working_draft stage
  - Example: "D8" → final_draft stage

- **`locate_typed_stage_by_iso_stage(stage)`** - Find stage by ISO stage code
  - Returns `TypedStage` object or nil
  - Example: "WD" → working_draft stage
  - Example: "FDIS" → final_draft stage

- **`locate_identifier_klass_by_type_code(type_code)`** - Select class by type code
  - Returns identifier class based on type_code
  - Example: "standard" → `Identifiers::Standard`
  - Example: "draft" → `Identifiers::Base`

### Typed Stages Registry

IEEE has a comprehensive typed stages registry with 15+ stages:

**IEEE Draft Stages:**
- `D1` - Initial working draft (unapproved)
- `D2, D3` - Committee draft stages (unapproved)
- `D4, D5, D6` - Draft standard stages (unapproved)
- `D7, D8, D9` - Final draft stages (approved)
- `P` - Generic project prefix (unapproved)
- `Draft` - Draft without specific version (unapproved)

**ISO Stages (for joint development):**
- `PWI` - Preliminary work item
- `NP` - New proposal
- `WD` - Working draft
- `CD, CD2, CD3` - Committee draft
- `DIS` - Draft international standard
- `FDIS` - Final draft international standard

**Published Stages:**
- `Std` - Published standard
- `No`, `No.` - Historical AIEE published standard

Each TypedStage includes:
- `abbr` - Array of abbreviations
- `stage_code` - Internal stage code
- `type_code` - Type code (standard, draft)
- `ieee_draft_equivalent` - IEEE draft notation (D1-D9, P)
- `iso_stage_equivalent` - ISO stage notation (WD, CD, DIS, etc.)
- `approval_status` - approved/unapproved/published
- `project_status` - true for drafts/projects, false for published

## Parser Rules

### Main Rule

```ruby
rule(:identifier) do
  dual_identifier |
    copublished_identifier |
    identifier_with_parameters
end
```

### Component Rules

```ruby
# Publishers with copublishers
rule(:publishers) do
  publisher.as(:publisher) >>
    (copublishers.as(:copublishers)).maybe
end

# Copublishers (ISO, IEC, ANSI, etc.)
rule(:copublishers) do
  (str("/") >> space? >> array_to_str(PUBLISHERS).as(:copublisher)).repeat(1)
end

# Type (Std, Draft Std, etc.)
rule(:type) do
  (str("P") | array_to_str(TYPES)).as(:type)
end

# Code with letter prefix and parts
rule(:code) do
  letter.as(:letter) >> number.as(:number) >>
    (part >> subpart.repeat).maybe
end

# Draft notation (/D1-D9)
rule(:draft) do
  str("/") >>
    (str("D").as(:draft_prefix) >>
     digits.as(:draft_version) >>
     (str(".") >> digits.as(:draft_revision)).maybe)
end

# Year with optional month/day
rule(:year) do
  (str("-") >> digits.as(:year)) |
    (str(",") >> space >> month.as(:month) >>
     (space >> digits.as(:day)).maybe >>
     (space >> digits.as(:year)).maybe)
end

# Edition
rule(:edition) do
  str("Edition") >> space >> edition_number.as(:edition)
end

# Relationships (revision_of, amendment_to, etc.)
rule(:relationship_clause) do
  str("(") >>
    ((relationship_type >> space >> identifiers).as(:relationship) |
     revision_of.as(:revision_of) |
     amendment_to.as(:amendment_to)) >>
    str(")")
end
```

### Special Patterns

```ruby
# Adopted standard (parenthetical)
rule(:adopted_standard) do
  identifier.as(:main_identifier) >>
    space? >>
    str("(") >>
    array_to_str(PUBLISHERS).as(:adopted_publisher) >>
    space >>
    identifier.as(:adopted_identifier) >>
    str(")")
end

# Corrigendum supplement
rule(:corrigendum) do
  str("/") >>
    (str("COR") | str("Cor")).as(:cor_prefix) >>
    space.maybe >>
    digits.as(:cor_number) >>
    (str("-") >> digits.as(:cor_year)).maybe
end

# Interpretation supplement
rule(:interpretation) do
  str("/") >>
    (str("INT") | str("Int")).as(:int_prefix) >>
    (str("-") >> digits.as(:int_year)).maybe
end

# Conformance supplement
rule(:conformance) do
  str("/") >>
    (str("Conformance") | str("CONFORMANCE")).as(:conf_prefix) >>
    digits.as(:conf_number) >>
    (str("-") >> digits.as(:conf_year)).maybe
end

# NESC (National Electrical Safety Code)
rule(:nesc) do
  (str("NESC") | str("National Electrical Safety Code")).as(:nesc)
end

# Dual identifier (comma or semicolon separated)
rule(:dual_identifier) do
  first_identifier.as(:first) >>
    (str(",") | str(";")) >>
    space >>
    second_identifier.as(:second)
end

# Cross-reference notation
rule(:crossref) do
  str("/C") >>
    digits.as(:crossref_number) >>
    (str(".") >> parts).maybe >>
    (str("-") >> digits.as(:crossref_year)).maybe
end
```

## Builder Logic

### Identifier Class Selection

The Builder determines which identifier class to instantiate based on:

1. **Special patterns** - Dual published, CSA dual published, IEC/IEEE copublished, NESC, AIEE, IRE, SI/PSI
2. **Supplement indicators** - base_identifier + cor_number, int_year, or conf_number
3. **Joint development** - joint_publishers or iso_stage presence
4. **Multi-numbered** - primary_identifier + secondary_crossref or secondary_joint
5. **Type code from TypedStage** - `locate_identifier_klass_by_type_code()` called with type_code
6. **Structural attributes** - adoption, redline, interpretation flag

### Component Casting

Special casting logic in Builder's `extract_attributes()` method:

```ruby
# Code with letter prefix and parts
when :code
  # "C62.22.1" → letter="C", number="62.22.1"
  # "802.3" → letter=nil, number="802.3"
  # "802.3ac" → letter=nil, number="802.3", parts=["ac"]
  # Create Code component object

# Draft version and revision
when :draft
  # "D1" → version="1"
  # "D8.2" → version="8", revision="2"
  # Create Draft component object with version, revision, month, year

# Year extraction from code (AIEE pattern)
  # If code ends with "-YYYY" and no separate year attribute
  # Extract year from code: "535-2013" → code="535", year="2013"

# Publishers and copublishers
when :publisher, :copublisher
  # Join with "/" for rendering
  # ["ANSI", "IEEE"] → "ANSI/IEEE"

# Month with space before draft detection
  # If original input has ", Month /D" pattern
  # Set space_before_draft flag for proper rendering
```

### Recursive Parsing

The Builder supports recursive parsing for supplements:

```ruby
# For corrigenda, interpretations, conformance documents
def build_corrigendum_supplement(parsed_hash)
  # Reconstruct base identifier string from parsed components
  base_string = reconstruct_base_string(parsed_hash[:base_identifier])

  # Recursively parse base identifier
  base_identifier = Identifiers::Base.parse(base_string)

  # Create supplement with parsed base
  Identifiers::Corrigendum.new(
    base_identifier: base_identifier,
    cor_number: extract_value(parsed_hash[:cor_number]),
    cor_year: extract_value(parsed_hash[:cor_year]),
  )
end
```

### Relationship Building

The Builder creates Relationship objects for complex document relationships:

```ruby
# Pattern 4: Revision/amendment relationships
def build_relationships(parsed_hash)
  relationships = []

  if parsed_hash[:relationship_type]
    rel_type = extract_relationship_type(parsed_hash[:relationship_type])
    related = parse_identifier_list(parsed_hash[:related_ids])

    # Handle "as amended by" clause
    amendments = parse_identifier_list(parsed_hash[:amendments]) if parsed_hash[:amendments]
    approved_flag = parsed_hash[:amendments]&.dig(:approved_amendments)

    relationships << Components::Relationship.new(
      relationship_type: rel_type,
      related_identifiers: related,
      intermediate_amendments: amendments,
      approved_amendments_flag: approved_flag,
    )
  end

  relationships
end
```

## Rendering Examples

### Standard Format

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `IEEE Std 802.3-2018` | `IEEE Std 802.3-2018` |
| `ANSI/IEEE Std 500-1984` | `ANSI/IEEE Std 500-1984` |
| `IEEE P802.3` | `IEEE P802.3` |
| `IEEE Std 802.3/D1` | `IEEE Std 802.3/D1` |
| `IEEE Std 802.3/D8` | `IEEE Std 802.3/D8` |

### Drafts with Dates

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `IEEE Std 802.3, January 2019` | `IEEE Std 802.3, January 2019` |
| `IEEE Std 802.3-2018 Edition 1.0` | `IEEE Std 802.3-2018 Edition 1.0` |

### Supplements

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `IEEE Std 802.3-2018/COR 1-2019` | `IEEE Std 802.3-2018/COR 1-2019` |
| `IEEE Std 802.3-2018/INT-2019` | `IEEE Std 802.3-2018/INT-2019` |
| `IEEE Std 802.3-2018/Conformance1-2019` | `IEEE Std 802.3-2018/Conformance1-2019` |

### Dual Published

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `IEEE Std 960-1989 and IEEE Std 1177-1989` | `IEEE Std 960-1989 and IEEE Std 1177-1989` |
| `IEC 62014-5; IEEE Std 1734-2011` | `IEC 62014-5; IEEE Std 1734-2011` |

### Adopted Standards

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `IEEE Std 802.3-2018 (ANSI/INCITS 518-2009)` | `IEEE Std 802.3-2018 (ANSI/INCITS 518-2009)` |
| `IEEE Std C62.41-1991 (IEC 801-4:1988)` | `IEEE Std C62.41-1991 (IEC 801-4:1988)` |

### Historical Standards

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `AIEE No 18-1934` | `AIEE No 18-1934` |
| `56 IRE 28.S2` | `56 IRE 28.S2` |

## Preprocessing

This flavor uses extensive preprocessing to normalize input before parsing:

| Pattern | Input | Output | Purpose |
|---------|-------|--------|---------|
| Dual standard (comma) | `IEEE Std 960-1989, Std 1177-1989` | `IEEE Std 960-1989 and IEEE Std 1177-1989` | Normalize to "and" format |
| Dual standard (semicolon) | `IEC 62014-5; IEEE Std 1734-2011` | Parse as dual published | Split into two identifiers |
| Reaffirmed + revision | `(R1980) (Revision of IEEE Std 101-1972)` | `(Revision of IEEE Std 101-1972)` + reaffirmed=1980 | Extract reaffirmed year |
| IRE dual published | `IEEE Std 218-1956 (R1980) (56 IRE 28.S2)` | Parse as dual published | Split IEEE and IRE |
| AIEE + ASA adoption | `AIEE No 18-1934 (ASA C55 1934)` | Parse as adopted standard | Create AdoptedStandard wrapper |

Preprocessing is **explicit** and **format-preserving** - the original format is stored for exact reproduction during rendering.

## Testing

### Test Coverage

- **Unit tests:** `spec/pubid_new/ieee/components/`
- **Parser tests:** `spec/pubid_new/ieee/parser_spec.rb`
- **Builder tests:** `spec/pubid_new/ieee/builder_spec.rb`
- **Identifier tests:** `spec/pubid_new/ieee/identifiers/`
- **Integration tests:** `spec/integration/ieee_`

### Fixtures

Located in: `spec/fixtures/ieee/identifiers/`

- **Pass tests:** `pass/` - Valid patterns that should parse successfully
  - `standard.txt` - Standard patterns
  - `draft.txt` - Draft patterns
  - `base.txt` - Base identifier patterns
- **Fail tests:** `fail/` - Invalid patterns that should raise errors

### Coverage Status

The IEEE flavor has comprehensive test coverage with ~90%+ coverage for all identifier classes and rendering patterns.

## Migration Notes

### V1 to V2 Changes

**Major architectural changes:**
1. **Three-layer separation** - Parser, Builder, and Identifier are completely separate
2. **Registry-based architecture** - Scheme class manages all type/stage lookups
3. **TYPED_STAGES array** - Replaces hash-based TYPE_MAP pattern
4. **TypedStage enhancements** - Includes IEEE/ISO stage equivalents and approval status
5. **Component objects** - Code, Draft, Relationship are proper Lutaml::Model objects

**Breaking changes:**
- `Pubid::Ieee::Identifier` → `PubidNew::Ieee::Identifiers::*` (specific classes)
- `draft_number` and `draft_revision` replaced by `Draft` component object
- `type` and `stage` attributes enhanced with `typed_stage` (combined object)
- `copublisher` is now an array (not a single string)

**Migration guide:**
1. Replace `Pubid::Ieee.parse()` with `PubidNew::Ieee.parse()`
2. Use specific identifier classes instead of generic `Identifier`
3. Access type/stage via `identifier.typed_stage`
4. Use `draft_obj` instead of separate `draft_number`/`draft_revision`
5. Access copublishers as array: `identifier.copublisher.first`

## References

- **Specification:** IEEE Standards Association Operations Manual
- **Examples:** IEEE Standards Store (https://standards.ieee.org/)
- **Related implementations:**
  - IEC flavor (copublisher support, joint development)
  - ISO flavor (stage code equivalents)

---

## Appendix: Design Decisions

### IEEE Draft Notation vs ISO Stages

**Context:** IEEE has its own draft notation (D1-D9) but also participates in joint development with ISO/IEC which uses ISO stage codes (PWI, NP, WD, CD, DIS, FDIS).

**Decision:** TypedStage includes both `ieee_draft_equivalent` and `iso_stage_equivalent` attributes.

**Rationale:**
- Joint development standards need to reference both systems
- IEEE D8 ≈ ISO FDIS (both are board-approved/final draft)
- Allows automatic conversion between notations
- Preserves original notation during parsing

**Alternatives considered:**
- Separate TypedStage registries for IEEE and ISO - Rejected (duplicates stages)
- Only support IEEE notation - Rejected (can't handle ISO stages in joint docs)

### Recursive Base Parsing for Supplements

**Context:** IEEE supplements (corrigenda, interpretations, conformance) need to wrap a base identifier that may itself be complex.

**Decision:** Reconstruct base identifier string from parsed components and recursively parse it.

**Rationale:**
- Handles arbitrary base identifier complexity
- Base identifier parsed with full validation
- Supports supplements to supplements
- Cleaner than trying to nest parsed hash trees

**Alternatives considered:**
- Store parsed hash tree directly - Rejected (loses validation)
- Parse base first, then wrap - Rejected (requires two-pass parsing)

### Relationship Objects

**Context:** IEEE identifiers have complex relationships (revision_of, amendment_to, supersedes, incorporates) with intermediate amendments.

**Decision:** Create dedicated `Relationship` component class.

**Rationale:**
- Captures relationship semantics (not just string data)
- Supports intermediate amendments (as amended by)
- Extensible for new relationship types
- Clean rendering logic per relationship type

**Alternatives considered:**
- Store relationships as string hash - Rejected (loses semantics)
- Use same attributes for all relationships - Rejected (can't capture intermediate amendments)

### Dual Published Detection

**Context:** IEEE has multiple patterns for dual published standards (comma, semicolon, "and", "&", space-separated).

**Decision:** Detect dual published patterns in `Base.parse()` before parsing.

**Rationale:**
- Separation of concerns (detection vs parsing)
- Each pattern can be preprocessed to canonical form
- Simplifies parser grammar
- Handles edge cases (parentheticals, publishers within identifiers)

**Alternatives considered:**
- Handle all patterns in parser - Rejected (complex grammar, hard to maintain)
- Require specific format - Rejected (loses flexibility, breaks real identifiers)
