# ASTM Documentation

## Overview

The ASTM flavor handles identifiers for ASTM International (formerly American Society for Testing and Materials) standards and publications. It supports multiple document types (Standards A-G, Research Reports, Technical Reports, Manuals, Monographs, Data Series, Work in Progress, Adjuncts), ISO/ASTM dual-published standards (5xxxx series), year notation with 2-digit years, edition notation, reapproval notation, sub-year notation, dual unit notation, format suffixes, and supplement notation. The flavor uses ordered parser rules to handle specific patterns before general ones and does NOT use typed stages (ASTM has no formal stage codes).

## Architecture

This flavor follows the PubID v2 three-layer architecture pattern:

1. **Parser** (`parser.rb`) - Parslet PEG grammar for syntax parsing
   - Converts input strings into structured hash trees
   - Uses ordered rules (most specific first) to handle 8+ document types
   - Handles Research Report with colon notation (RR:CF-123)
   - Supports dual unit notation (F1862/F1862M)
   - Parses year notation with 2-digit years (-24 for 2024)
   - Supports reapproval notation ((2020))
   - Handles edition notation (e1, 9TH, 2ND)
   - Parses sub-year notation (24e1a)
   - Supports format suffix (-EB for eBook)
   - Handles supplement notation (-SUP-)
   - Strips comments (text after #)
   - Detects ISO/ASTM dual-published standards (5xxxx digit-only series)

2. **Builder** (`builder.rb`) - Transforms parse trees to domain objects
   - Determines document type from parsed data
   - Constructs appropriate identifier class (9 classes total)
   - Converts 2-digit years to 4-digit for storage (24 → 2024)
   - Builds Code component with letter, number, suffix, subseries, dual_m attributes
   - Handles special cases: ISO/ASTM TR type, ISO/ASTM dual-published standards
   - Sets type-specific attributes (edition, supplement, committee, designation, hol_suffix)

3. **Identifier** (`identifiers/`) - Lutaml::Model domain classes with rendering logic
   - Base identifiers for all ASTM document types
   - Specialized class for ISO/ASTM dual-published standards
   - Custom rendering for each document type with proper format
   - No TYPED_STAGES (ASTM does not use formal stage codes)

## Components

### Flavor-Specific Components

| Component | File | Purpose | Attributes |
|-----------|------|---------|------------|
| `Code` | `components/code.rb` | ASTM code with letter prefix, number, suffix, subseries, dual unit flag | `letter`, `number`, `suffix`, `subseries`, `dual_m` |

### Shared Components Used

ASTM uses minimal shared components, implementing most logic in flavor-specific classes:
- `Publisher` is stored as a string attribute, not a separate component
- No `Type`, `Stage`, or `TypedStage` components (ASTM does not use formal stage codes)

## Identifier Classes

### Base Identifiers

#### Base

- **File:** `lib/pubid_new/astm/identifiers/base.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** The base class for all ASTM identifiers. Provides common parse method.
- **Components Used:** Inherits from `SingleIdentifier` (publisher, code, year, format_suffix)
- **Patterns Supported:** Delegates to `PubidNew::Astm::Identifier.parse()`
- **Typed Stages:** Not applicable (ASTM does not use typed stages)
- **Rendering Formats:** Varies by document type

#### Standard

- **File:** `lib/pubid_new/astm/identifiers/standard.rb`
- **Parent:** `Base`
- **Purpose:** The primary ASTM document type representing standards with A-G letter prefixes. Supports the complete ASTM standard format with dual unit notation, year, sub-year, reapproval, and edition.
- **Components Used:** `publisher`, `code` (with letter, number, dual_m), `year`, `sub_year`, `reapproval`, `edition`
- **Patterns Supported:**
  - `ASTM A36-24` → Basic standard with year
  - `ASTM F1862/F1862M` → Dual unit standard (inch-pound and metric)
  - `ASTM A36-24e1` → With edition notation
  - `ASTM A36-24(2020)` → With reapproval year
  - `ASTM A36-24e1a` → With sub-year notation
  - `ASTM 52303-24e1` → Digit-only ISO/ASTM dual-published standard
- **Typed Stages:** Not applicable
- **Rendering Formats:**
  - Standard format: `ASTM A36-24`
  - Dual unit: `ASTM F1862/F1862M`
  - With edition: `ASTM A36-24e1`
  - With sub-year: `ASTM A36-24e1a`
  - With reapproval: `ASTM A36-24(2020)`

### Research Report

#### ResearchReport

- **File:** `lib/pubid_new/astm/identifiers/research_report.rb`
- **Parent:** `Base`
- **Purpose:** Research Reports (RR) document committee research findings with colon notation.
- **Components Used:** `publisher`, `code` (number only), `committee`
- **Patterns Supported:**
  - `ASTM RR:CF-123` → Research Report with committee CF
  - `ASTM RR:A01-456` → Research Report with committee A01
- **Typed Stages:** Not applicable
- **Rendering Formats:** `ASTM RR:CF-123` format with colon separator

### Technical Report

#### TechnicalReport

- **File:** `lib/pubid_new/astm/identifiers/technical_report.rb`
- **Parent:** `Base`
- **Purpose:** Technical Reports (TR) and ISO/ASTM Technical Reports.
- **Components Used:** `publisher`, `code` (with optional letter, number), `format_suffix`
- **Patterns Supported:**
  - `ASTM TR-123` → Technical Report
  - `ASTM TRE-123` → Technical Report with letter prefix
  - `ISO/ASTMTR-123` → ISO/ASTM Technical Report (dual-published)
- **Typed Stages:** Not applicable
- **Rendering Formats:**
  - Simple: `TR-123` or `TRE-123`
  - ISO/ASTM: `ISO/ASTMTR-123`

### Manual

#### Manual

- **File:** `lib/pubid_new/astm/identifiers/manual.rb`
- **Parent:** `Base`
- **Purpose:** Manuals (MNL) are comprehensive guides with edition and supplement notation.
- **Components Used:** `publisher`, `code` (number only), `edition`, `supplement`, `tp_designation`, `format_suffix`
- **Patterns Supported:**
  - `ASTM MNL 123` → Manual
  - `ASTM MNL 123-9TH` → Manual with edition
  - `ASTM MNLTP 123` → Technical publication manual
  - `ASTM MNL 123-SUP-EB` → Manual with supplement and eBook format
- **Typed Stages:** Not applicable
- **Rendering Formats:** `ASTM MNL 123-9TH` or `ASTM MNL 123-SUP-EB`

### Monograph

#### Monograph

- **File:** `lib/pubid_new/astm/identifiers/monograph.rb`
- **Parent:** `Base`
- **Purpose:** Monographs (MONO) are comprehensive treatments of single topics.
- **Components Used:** `publisher`, `code` (number only), `edition`, `format_suffix`
- **Patterns Supported:**
  - `ASTM MONO 123` → Monograph
  - `ASTM MONO 123-2ND` → Monograph with edition
- **Typed Stages:** Not applicable
- **Rendering Formats:** `ASTM MONO 123-2ND`

### Data Series

#### DataSeries

- **File:** `lib/pubid_new/astm/identifiers/data_series.rb`
- **Parent:** `Base`
- **Purpose:** Data Series (DS) publications contain compiled data with optional letter suffix and subseries.
- **Components Used:** `publisher`, `code` (number, suffix, subseries), `hol_suffix`, `format_suffix`
- **Patterns Supported:**
  - `ASTM DS 123` → Data Series
  - `ASTM DS 123A` → Data Series with letter suffix
  - `ASTM DS 123S4` → Data Series with subseries
  - `ASTM DS 123HOL` → Data Series with HOL suffix
- **Typed Stages:** Not applicable
- **Rendering Formats:** `ASTM DS 123A` or `ASTM DS 123S4`

### Adjunct

#### Adjunct

- **File:** `lib/pubid_new/astm/identifiers/adjunct.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** Adjuncts (ADJ) are supplementary materials that reference base standards with various designation formats.
- **Components Used:** `publisher`, `designation`, `ea_suffix`, `dvd_suffix`
- **Patterns Supported:**
  - `ASTM ADJF3504-EA` → Excel file adjunct to F3504
  - `ASTM ADJC033501` → Numeric adjunct designation
  - `ASTM ADJC0450A` → Letter suffix adjunct
  - `ASTM ADJE11211T` → Mixed alphanumeric adjunct
  - `ASTM ADJDQCALC` → Text designation adjunct
  - `ASTM ADJDQCALCDVD` → DVD format adjunct
- **Typed Stages:** Not applicable
- **Rendering Formats:** `ASTM ADJF3504-EA` or `ASTM ADJC033501` (no publisher for EA/DVD suffixes)

### Work in Progress

#### WorkInProgress

- **File:** `lib/pubid_new/astm/identifiers/work_in_progress.rb`
- **Parent:** `Base`
- **Purpose:** Work in Progress (WK) identifiers represent draft documents under development.
- **Components Used:** `publisher`, `code` (number only)
- **Patterns Supported:**
  - `ASTM WK 12345` → Work in Progress
- **Typed Stages:** Not applicable
- **Rendering Formats:** `ASTM WK 12345`

### ISO/ASTM Dual Published

#### IsoDualPublished

- **File:** `lib/pubid_new/astm/identifiers/iso_dual_published.rb`
- **Parent:** `Standard`
- **Purpose:** ISO/ASTM dual-published standards (typically 5xxxx series). These are ASTM's version of standards jointly developed with ISO.
- **Components Used:** Same as Standard (publisher, code with number only, year, sub_year, reapproval, edition)
- **Patterns Supported:**
  - `ASTM 52303-24e1` → ASTM's version (e1 = edition 1, not "E" prefix)
  - `ASTM 52910-15` → ISO/ASTM dual-published standard
- **Typed Stages:** Not applicable
- **Rendering Formats:** `ASTM 52303-24e1` (identical to Standard rendering)
- **Note:** These are semantically distinct from letter-prefix standards but have the same structure

## Scheme Registry

The `Scheme` class (`lib/pubid_new/astm/scheme.rb`) is the central registry for this flavor.

### Registry Methods

ASTM does NOT use typed stages or type codes like other flavors. The Scheme provides minimal methods:

- **`identifiers`** - Array of all registered identifier classes
  ```ruby
  def identifiers
    [
      Identifiers::Standard,
      Identifiers::Manual,
      Identifiers::ResearchReport,
      Identifiers::DataSeries,
      Identifiers::TechnicalReport,
      Identifiers::Monograph,
      Identifiers::Adjunct,
      Identifiers::WorkInProgress,
      Identifiers::IsoDualPublished,
    ]
  end
  ```

- **`typed_stages`** - Returns empty array (ASTM does not use typed stages)
  ```ruby
  def typed_stages
    [].freeze
  end
  ```

- **`locate_typed_stage_by_abbr(abbr)`** - Raises ArgumentError (not supported)

- **`locate_identifier_klass_by_type_code(type_code)`** - Raises ArgumentError (not supported)

### Identifier Class Determination

Since ASTM does not use type codes, the Builder determines identifier class based on parsed data patterns:

```ruby
def determine_identifier_class(parsed_hash)
  type = parsed_hash[:type]&.to_s

  # Check for ISO/ASTM dual-published (digit-only 5xxxx)
  if (type.nil? || type.empty?) && parsed_hash[:number] && !parsed_hash[:letter]
    number_str = parsed_hash[:number].to_s
    return Identifiers::IsoDualPublished if number_str.start_with?("5")
    return Identifiers::Standard
  end

  case type
  when "RR"
    Identifiers::ResearchReport
  when "MNL"
    Identifiers::Manual
  when "MONO"
    Identifiers::Monograph
  when "DS"
    Identifiers::DataSeries
  when "WK"
    Identifiers::WorkInProgress
  when "ADJ"
    Identifiers::Adjunct
  when "TR"
    Identifiers::TechnicalReport
  when "ISO/ASTMTR"
    Identifiers::TechnicalReport
  else
    Identifiers::Standard  # Default (A-G prefix)
  end
end
```

## Parser Rules

### Main Rule (Ordered)

ASTM uses ordered parser rules (most specific first) to handle overlapping patterns:

```ruby
rule(:identifier) do
  research_report |    # Most specific (has colon)
    technical_report |  # Has TR prefix
    manual |            # Has MNL prefix
    monograph |         # Has MONO prefix
    data_series |       # Has DS prefix
    work_in_progress |  # Has WK prefix
    adjunct |           # Has ADJ prefix
    standard            # DEFAULT (A-G letter or digit-only)
end
```

### Component Rules

```ruby
# Publisher
rule(:publisher) { str("ASTM").as(:publisher) >> space.maybe }

# Standard letters A-G (committee designations)
rule(:standard_letter) { match("[A-G]").as(:letter) }

# Year patterns (2-digit only)
rule(:year_2digit) { digit.repeat(2, 2).as(:year) }

# Reapproval notation (4-digit year in parentheses)
rule(:reapproval) do
  str("(") >> digit.repeat(4, 4).as(:reapproval) >> str(")")
end

# Editorial notation (e1, e2, etc.)
rule(:edition) { str("e") >> digits.as(:edition) }

# Edition notations (9TH, 2ND, etc.)
rule(:edition_ordinal) do
  (
    str("9TH") | str("8TH") | str("7TH") | str("6TH") |
    str("5TH") | str("4TH") | str("3RD") | str("2ND") |
    str("1ST")
  ).as(:edition)
end

# Sub-year notation (a, b, c)
rule(:sub_year) { match("[a-c]").as(:sub_year) }

# Format suffix (-EB for eBook)
rule(:format_suffix) { dash >> str("EB").as(:format_suffix) }

# Supplement notation (ends with dash)
rule(:supplement) { dash >> str("SUP").as(:supplement) >> dash }

# Comment portion (stripped during parsing)
rule(:comment) { space.maybe >> str("#") >> match("[^#]").repeat }
```

### Document Type Rules

```ruby
# Research Report (with colon) - MOST SPECIFIC
rule(:research_report) do
  publisher.maybe >>
    str("RR").as(:type) >>
    colon >>
    (letter >> digit.repeat(2, 2)).as(:committee) >>
    dash >>
    digits.as(:number)
end

# Manual
rule(:manual) do
  publisher.maybe >>
    str("MNL").as(:type) >>
    str("TP").as(:tp_designation).maybe >>
    digits.as(:number) >>
    (dash >> edition_ordinal).maybe >>
    (
      supplement >> format_suffix_no_dash.maybe |
      format_suffix.maybe
    )
end

# Monograph
rule(:monograph) do
  publisher.maybe >>
    str("MONO").as(:type) >>
    digits.as(:number) >>
    (dash >> edition_ordinal).maybe >>
    format_suffix.maybe
end

# Data Series
rule(:data_series) do
  publisher.maybe >>
    str("DS").as(:type) >>
    digits.as(:number) >>
    (
      str("HOL").as(:hol_suffix) |
      (match("[A-Z]").as(:suffix) >> digits.as(:subseries).maybe) |
      (dash >> str("S") >> digits.as(:subseries))
    ).maybe >>
    format_suffix.maybe
end

# Work in Progress
rule(:work_in_progress) do
  publisher.maybe >>
    str("WK").as(:type) >>
    digits.as(:number)
end

# Adjunct
rule(:adjunct) do
  publisher.maybe >>
    str("ADJ").as(:type) >>
    (letter >> digits | letters | digits).as(:designation) >>
    (dash >> str("EA")).maybe.as(:ea_suffix) >>
    str("DVD").maybe.as(:dvd_suffix)
end

# Technical Report (simple and ISO/ASTM)
rule(:technical_report_iso_astm) do
  str("ISO/ASTMTR").as(:type) >>
    digits.as(:number) >>
    format_suffix.maybe >>
    comment.maybe
end

rule(:technical_report_simple) do
  publisher.maybe >>
    str("TR").as(:type) >>
    digits.as(:number) >>
    format_suffix.maybe >>
    comment.maybe
end

# Standard (DEFAULT - handles A-G prefix AND digit-only)
rule(:dual_unit) do
  slash >>
    standard_letter >>
    digits >>
    str("M").as(:dual_m)
end

rule(:standard_code_with_letter) do
  standard_letter >>
    digits.as(:number) >>
    dual_unit.maybe
end

rule(:standard_code_digit_only) do
  digits.as(:number)  # ISO/ASTM dual-published (5xxxx series)
end

rule(:standard) do
  publisher.maybe >>
    (standard_code_with_letter | standard_code_digit_only) >>
    (
      dash >> year_2digit >>
      sub_year.maybe >>
      reapproval.maybe >>
      edition.maybe
    ).maybe >>
    comment.maybe
end
```

### Pattern Examples

| Input | Parse Tree Key Elements |
|-------|------------------------|
| `ASTM A36-24` | `{letter: "A", number: "36", year: "24"}` |
| `ASTM F1862/F1862M` | `{letter: "F", number: "1862", dual_m: "M"}` |
| `ASTM A36-24e1a` | `{letter: "A", number: "36", year: "24", edition: "1", sub_year: "a"}` |
| `ASTM A36-24(2020)` | `{letter: "A", number: "36", year: "24", reapproval: "2020"}` |
| `ASTM RR:CF-123` | `{type: "RR", committee: "CF", number: "123"}` |
| `ASTM TR-123` | `{type: "TR", number: "123"}` |
| `ASTM MNL 123-9TH` | `{type: "MNL", number: "123", edition: "9TH"}` |
| `ASTM MONO 123` | `{type: "MONO", number: "123"}` |
| `ASTM DS 123S4` | `{type: "DS", number: "123", subseries: "4"}` |
| `ASTM WK 12345` | `{type: "WK", number: "12345"}` |
| `ASTM ADJF3504-EA` | `{type: "ADJ", designation: "F3504", ea_suffix: "EA"}` |
| `ASTM 52303-24e1` | `{number: "52303", year: "24", edition: "1"}` |
| `ISO/ASTMTR-123` | `{type: "ISO/ASTMTR", number: "123"}` |

## Builder Logic

### Identifier Class Selection

The Builder determines which identifier class to instantiate based on:

1. **Type code** - If `:type` is present, map to specific class (RR → ResearchReport, MNL → Manual, etc.)
2. **Digit-only 5xxxx series** - If no type and number starts with "5" → IsoDualPublished
3. **Digit-only other series** - If no type and no letter → Standard
4. **Default** - All other patterns → Standard (A-G prefix)

### Component Casting

Special casting logic in Builder's `build_code()` method:

```ruby
def build_code(parsed_hash)
  code = Components::Code.new

  # Set letter prefix (A-G) unless ISO/ASTM TR type
  if parsed_hash[:letter] && !(parsed_hash[:type]&.to_s == "TR" &&
                                parsed_hash[:publisher]&.to_s&.start_with?("ISO/ASTM"))
    code.letter = parsed_hash[:letter].to_s
  end

  # Set number
  code.number = parsed_hash[:number].to_s if parsed_hash[:number]

  # Set suffix (for Data Series letter suffixes)
  code.suffix = parsed_hash[:suffix].to_s if parsed_hash[:suffix]

  # Set subseries (for Data Series S1, S4, etc.)
  code.subseries = parsed_hash[:subseries].to_s if parsed_hash[:subseries]

  # Set dual_m flag for metric (F1862/F1862M)
  code.dual_m = true if parsed_hash[:dual_m]

  code
end
```

### Year Conversion

The Builder converts 2-digit years to 4-digit for storage:

```ruby
def convert_year(year_str)
  return year_str if year_str.length == 4

  # 2-digit year conversion
  year_int = year_str.to_i
  if year_int <= 24
    "20#{year_str}"  # 00-24 → 2000-2024
  else
    "19#{year_str}"  # 25-99 → 1925-1999
  end
end
```

### Type-Specific Attributes

The Builder sets type-specific attributes:

```ruby
# Research Report - committee attribute
if identifier.is_a?(Identifiers::ResearchReport) && parsed_hash[:committee]
  identifier.committee = parsed_hash[:committee].to_s
end

# Manual - edition, supplement, tp_designation
if identifier.is_a?(Identifiers::Manual)
  identifier.edition = parsed_hash[:edition].to_s if parsed_hash[:edition]
  identifier.supplement = true if parsed_hash[:supplement]
  identifier.tp_designation = parsed_hash[:tp_designation].to_s if parsed_hash[:tp_designation]
end

# Monograph - edition
if identifier.is_a?(Identifiers::Monograph) && parsed_hash[:edition]
  identifier.edition = parsed_hash[:edition].to_s
end

# Data Series - hol_suffix
if identifier.is_a?(Identifiers::DataSeries) && parsed_hash[:hol_suffix]
  identifier.hol_suffix = true
end

# Adjunct - designation, ea_suffix, dvd_suffix
if identifier.is_a?(Identifiers::Adjunct)
  identifier.designation = parsed_hash[:designation].to_s if parsed_hash[:designation]
  identifier.ea_suffix = true if parsed_hash[:ea_suffix]
  identifier.dvd_suffix = true if parsed_hash[:dvd_suffix]
end

# Standard - sub_year, reapproval, edition
if identifier.is_a?(Identifiers::Standard)
  identifier.sub_year = parsed_hash[:sub_year].to_s if parsed_hash[:sub_year]
  identifier.reapproval = parsed_hash[:reapproval].to_s if parsed_hash[:reapproval]
  identifier.edition = parsed_hash[:edition].to_s if parsed_hash[:edition]
end
```

## Rendering Examples

### Standard Format

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `ASTM A36-24` | `ASTM A36-24` |
| `ASTM F1862/F1862M` | `ASTM F1862/F1862M` |
| `ASTM A36-24e1` | `ASTM A36-24e1` |
| `ASTM A36-24(2020)` | `ASTM A36-24(2020)` |
| `ASTM A36-24e1a` | `ASTM A36-24e1a` |

### Research Report

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `ASTM RR:CF-123` | `ASTM RR:CF-123` |
| `ASTM RR:A01-456` | `ASTM RR:A01-456` |

### Technical Report

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `ASTM TR-123` | `TR-123` |
| `ASTM TRE-123` | `TRE-123` |
| `ISO/ASTMTR-123` | `ISO/ASTMTR-123` |

### Manual

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `ASTM MNL 123` | `ASTM MNL123` |
| `ASTM MNL 123-9TH` | `ASTM MNL123-9TH` |
| `ASTM MNLTP 123` | `ASTM MNLTP123` |
| `ASTM MNL 123-SUP-EB` | `ASTM MNL123-SUP-EB` |

### Monograph

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `ASTM MONO 123` | `ASTM MONO 123` |
| `ASTM MONO 123-2ND` | `ASTM MONO 123-2ND` |

### Data Series

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `ASTM DS 123` | `ASTM DS 123` |
| `ASTM DS 123A` | `ASTM DS 123A` |
| `ASTM DS 123S4` | `ASTM DS 123-S4` |
| `ASTM DS 123HOL` | `ASTM DS 123HOL` |

### Adjunct

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `ASTM ADJF3504-EA` | `ASTM ADJF3504-EA` |
| `ASTM ADJC033501` | `ASTM ADJC033501` |
| `ASTM ADJC0450A` | `ASTM ADJC0450A` |
| `ASTM ADJDQCALC` | `ASTM ADJDQCALC` |
| `ASTM ADJDQCALCDVD` | `ADJDQCALCDVD` (no publisher) |

### Work in Progress

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `ASTM WK 12345` | `ASTM WK 12345` |

### ISO/ASTM Dual Published

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `ASTM 52303-24e1` | `ASTM 52303-24e1` |
| `ASTM 52910-15` | `ASTM 52910-15` |

## Standard Types (A-G)

| Letter | Committee | Description |
|--------|-----------|-------------|
| A | Steel | Ferrous metals and steel products |
| B | Nonferrous | Nonferrous metals (copper, aluminum, etc.) |
| C | Ceramics | Ceramics, glass, and other materials |
| D | Miscellaneous | Other materials (plastics, textiles, etc.) |
| E | Miscellaneous | Other subjects (testing, statistics, etc.) |
| F | Special | Specialized tests and applications |
| G | Corrosion | Corrosion, degradation, and aging |

## Year Notation

ASTM uses 2-digit year notation with automatic century conversion:

| Input | Stored As | Rendered As |
|-------|-----------|-------------|
| `-24` | `2024` | `-24` |
| `-23` | `2023` | `-23` |
| `-99` | `1999` | `-99` |
| `-25` | `2025` | `-25` |

**Conversion rule:**
- Years 00-24 → 2000-2024
- Years 25-99 → 1925-1999

## Edition Notation

ASTM uses two types of edition notation:

| Type | Pattern | Example |
|------|---------|---------|
| Editorial | `e1`, `e2` | `A36-24e1` (edition 1) |
| Ordinal | `1ST`, `2ND`, `3RD`, `4TH`, etc. | `MNL 123-9TH` (9th edition) |

## Sub-Year Notation

ASTM uses sub-year notation for revisions within a year:

| Pattern | Meaning | Example |
|---------|---------|---------|
| `24e1a` | Year 2024, edition 1, revision a | `A36-24e1a` |
| `24e1b` | Year 2024, edition 1, revision b | `A36-24e1b` |
| `24e1c` | Year 2024, edition 1, revision c | `A36-24e1c` |

Sub-year values are limited to `a`, `b`, or `c`.

## Reapproval Notation

ASTM uses parenthetical reapproval notation:

| Pattern | Meaning | Example |
|---------|---------|---------|
| `(2020)` | Reapproved in 2020 | `A36-24(2020)` |
| `(2023)` | Reapproved in 2023 | `A36-15(2023)` |

Reapproval appears after the year in the rendered output.

## Dual Unit Notation

ASTM supports dual unit standards (inch-pound and metric):

| Pattern | Meaning | Example |
|---------|---------|---------|
| `F1862/F1862M` | Both inch-pound and metric versions | `ASTM F1862/F1862M` |

The `dual_m` flag in the Code component indicates metric notation.

## Format Suffix

ASTM supports format suffix for electronic publications:

| Suffix | Meaning | Example |
|--------|---------|---------|
| `-EB` | eBook format | `ASTM MNL 123-EB` |

The `format_suffix` attribute includes the dash prefix.

## Testing

### Test Coverage

- **Unit tests:** `spec/pubid_new/astm/`
- **Parser tests:** `spec/pubid_new/astm/parser_spec.rb`
- **Builder tests:** `spec/pubid_new/astm/builder_spec.rb`
- **Identifier tests:** `spec/pubid_new/astm/identifiers/`
- **Integration tests:** `spec/integration/astm_`

### Fixtures

Located in: `spec/fixtures/astm/identifiers/`

- **Pass tests:** `pass/` - Valid patterns that should parse successfully
  - `standard.txt` - Standard patterns
  - `research_report.txt` - RR patterns
  - `technical_report.txt` - TR patterns
  - `manual.txt` - MNL patterns
  - `monograph.txt` - MONO patterns
  - `data_series.txt` - DS patterns
  - `work_in_progress.txt` - WK patterns
  - `adjunct.txt` - ADJ patterns
- **Fail tests:** `fail/` - Invalid patterns that should raise errors
- **Full fixtures:** `full/identifiers.txt` - Complete pattern coverage

### Coverage Status

The ASTM flavor has comprehensive test coverage with ~85%+ coverage for all identifier classes and rendering patterns.

## Design Characteristics

### No Typed Stages

ASTM does NOT use typed stages like other standards bodies (ISO, IEC, etc.). The flavor relies on:
- Document type prefixes (RR, TR, MNL, MONO, DS, WK, ADJ)
- Letter prefixes for standards (A-G)
- Digit-only numbers for ISO/ASTM dual-published standards

### Ordered Parser Rules

ASTM uses ordered parser rules (most specific first) to handle overlapping patterns:

1. **Research Report** - Most specific (has colon)
2. **Technical Report** - Has TR prefix
3. **Manual** - Has MNL prefix
4. **Monograph** - Has MONO prefix
5. **Data Series** - Has DS prefix
6. **Work in Progress** - Has WK prefix
7. **Adjunct** - Has ADJ prefix
8. **Standard** - DEFAULT (A-G letter or digit-only)

### Comment Stripping

ASTM parser strips comments (text after #):

| Input | Output |
|-------|--------|
| `ASTM A36-24 # Steel` | `ASTM A36-24` |
| `ASTM RR:CF-123 # Note` | `ASTM RR:CF-123` |

## Comparison with ISO

| Feature | ASTM | ISO |
|---------|------|-----|
| Publisher | ASTM | ISO (with copublishers) |
| Document types | 8 types + A-G standards | 18+ types |
| Stage codes | None | 15+ (PWI, NP, WD, CD, DIS, FDIS) |
| Supplements | None (adjuncts are separate) | 5 types (Amd, Cor, Add, Suppl, Ext) |
| Year format | 2-digit (-24) → 4-digit storage | 4-digit (:2024) |
| Number format | Letter prefix (A-G) or digit-only | Numeric only |
| Sub-year | Yes (a, b, c) | No |
| Dual unit | Yes (F1862/F1862M) | No |
| Edition notation | e1, 1ST, 2ND, etc. | Year-based |

## Migration Notes

### V1 to V2 Changes

**Major architectural changes:**
1. **Three-layer separation** - Parser, Builder, and Identifier are completely separate
2. **No typed stages** - ASTM does not use formal stage codes like ISO/IEC
3. **Component-based Code** - Code component with letter, number, suffix, subseries, dual_m attributes
4. **Identifier class explosion** - 9 specialized identifier classes vs single generic identifier
5. **Type-based class selection** - Builder determines class based on parsed type code

**Breaking changes:**
- `Pubid::Astm::Identifier` → `PubidNew::Astm::Identifiers::*` (specific classes)
- Year conversion: 2-digit years now converted to 4-digit for storage
- `dual_m` flag now stored in Code component instead of separate attribute

**Migration guide:**
1. Replace `Pubid::Astm.parse()` with `PubidNew::Astm.parse()`
2. Use specific identifier classes instead of generic `Identifier`
3. Access code attributes via `identifier.code` (Code component object)
4. Year is now 4-digit internally, rendered as 2-digit

## References

- **Specification:** ASTM International Standards
- **Examples:** ASTM Standards (https://www.astm.org/)
- **Related implementations:**
  - ISO flavor (similar three-layer architecture)
  - ASME flavor (similar letter-prefix standards)

---

## Appendix: Design Decisions

### No Typed Stages

**Context:** ASTM does not have formal stage codes like ISO/IEC (PWI, NP, WD, CD, DIS, FDIS).

**Decision:** Do not implement typed stages for ASTM flavor.

**Rationale:**
- ASTM standards move from Work in Progress (WK) directly to published
- No intermediate formal stages
- WK is a document type, not a stage
- Simpler implementation without unnecessary complexity

**Alternatives considered:**
- Invent typed stages - Rejected (not based in reality)
- Use ISO stages - Rejected (does not match ASTM practice)

### Ordered Parser Rules

**Context:** ASTM has multiple document type patterns that could conflict (e.g., RR with colon vs letter-prefix standards).

**Decision:** Order parser rules from most specific to least specific.

**Rationale:**
- Research Report with colon is most specific pattern
- Each document type has unique prefix (RR, TR, MNL, MONO, DS, WK, ADJ)
- Standard is the fallback/default rule
- Prevents ambiguous matches

**Alternatives considered:**
- Single complex rule - Rejected (hard to maintain)
- Negative lookahead - Rejected (complex grammar)

### 2-Digit Years with Century Conversion

**Context:** ASTM uses 2-digit years (e.g., -24 for 2024) but needs to store complete dates.

**Decision:** Convert 2-digit years to 4-digit for storage, render as 2-digit.

**Rationale:**
- Matches ASTM notation in rendering
- Complete date information for storage
- Simple conversion rule (00-24 → 2000s, 25-99 → 1900s)
- Handles all current ASTM standards

**Alternatives considered:**
- Store as 2-digit only - Rejected (loses century information)
- Require 4-digit input - Rejected (breaks real identifiers)

### Sub-Year Notation as Separate Attribute

**Context:** ASTM has revisions within years (e.g., 24e1a).

**Decision:** Parse sub-year as separate attribute.

**Rationale:**
- Preserves semantic meaning
- Matches ASTM practice
- Clean separation from edition
- Limited to a, b, c values

**Alternatives considered:**
- Include in edition - Rejected (loses distinction)
- Ignore - Rejected (loses information)
- Store as part of year - Rejected (mixes concepts)

### Adjunct Designations as Opaque String

**Context:** Adjuncts reference base standards with various formats (F3504-EA, C033501, C0450A, E11211T, DQCALC).

**Decision:** Parse designation as opaque string.

**Rationale:**
- Too many format variations to enumerate
- Adjunct references base standard
- Opaque string is flexible
- Simple implementation

**Alternatives considered:**
- Parse all formats - Rejected (too complex, always changing)
- Reject adjuncts - Rejected (common practice, needed)

### ISO/ASTM Dual-Published as Separate Class

**Context:** ASTM 5xxxx series are dual-published with ISO but have same structure as letter-prefix standards.

**Decision:** Create separate `IsoDualPublished` class inheriting from `Standard`.

**Rationale:**
- Semantic distinction (dual-published vs ASTM-only)
- Same structure allows code reuse (inheritance)
- Future extensibility for ISO/ASTM-specific behavior
- Clean type system

**Alternatives considered:**
- Use Standard class for all - Rejected (loses semantic distinction)
- Completely separate class - Rejected (duplicates code)
