# ETSI Documentation

## Overview

The ETSI flavor handles identifiers for the European Telecommunications Standards Institute (ETSI) standards and related documents. It supports ETSI's complete identifier ecosystem including 15 document types (EN, ES, EG, TS, ETR, ETS, I-ETS, TBR, TCRTR, NET, GR, GS, SR, TR, GTS) with complex numbering patterns (dotted, GSM format, complex format), version notation (V1.2.3), edition notation (ed.2), and supplement identifiers (amendments and corrigenda). The flavor uses a unique Code component that handles multiple number formats and a Date component with year-month format.

## Architecture

This flavor follows a modified PubID v2 architecture with custom components:

1. **Parser** (`parser.rb`) - Parslet PEG grammar for syntax parsing
   - Converts input strings into structured hash trees
   - Handles 15 document type codes (EN, ES, EG, TS, etc.)
   - Parses complex number patterns (GSM 11.14, 123 456, IP6 031)
   - Supports dotted number format (11.40)
   - Handles version notation (V1.2.3) and edition notation (ed.2)
   - Parses date format (YYYY-MM)
   - Supports supplement identifiers (amendments, corrigenda)

2. **Builder** (`builder.rb`) - Transforms parse trees to domain objects
   - Constructs Code component from complex number patterns
   - Builds Version component (version or edition)
   - Creates Date component (year-month)
   - Wraps base identifier with supplements recursively

3. **Identifier** (`identifiers/`) - Lutaml::Model domain classes with rendering logic
   - Base identifiers (EtsiStandard) for all document types
   - Supplement identifiers (Amendment, Corrigendum) wrapping base
   - Custom rendering with type prefix and date format

## Components

### Flavor-Specific Components

| Component | File | Purpose | Attributes |
|-----------|------|---------|------------|
| `Code` | `components/code.rb` | ETSI code with number, minor, parts | `number`, `minor`, `parts` |
| `Version` | `components/version.rb` | Version or edition information | `version`, `is_edition` |

### Shared Components Used

| Component | From | Purpose in this flavor |
|-----------|------|------------------------|
| `Date` | `lib/pubid_new/components/date.rb` | Year-month dates (YYYY-MM format) |
| `Publisher` | Not used | ETSI is hardcoded in rendering |
| `Type` | Not used | Type is string attribute |
| `Language` | Not used | ETSI doesn't use language codes |
| `Stage` | Not used | ETSI doesn't use stages |
| `TypedStage` | Not used | ETSI doesn't use typed stages |

## Identifier Classes

### Base Identifiers

#### EtsiStandard

- **File:** `lib/pubid_new/etsi/identifiers/etsi_standard.rb`
- **Parent:** `Base` (inherits from `Lutaml::Model::Serializable`)
- **Purpose:** Single class for all ETSI document types. Type is passed as parameter, handling 15 different document types (EN, ES, EG, TS, ETR, ETS, I-ETS, TBR, TCRTR, NET, GR, GS, SR, TR, GTS).
- **Components Used:** `type`, `code`, `version`, `date`
- **Patterns Supported:**
  - `ETSI EG 200 053 V1.5.1 (2004-06)` → ETSI Guide with dotted number and version
  - `ETSI GR ZSM 009-3 V1.1.1 (2023-08)` → Group Report with parts
  - `ETSI GTS GSM 02.01 V5.5.0 (1999-01)` → GTS with GSM number format
  - `ETSI EN 300 328 V2.2.2 (2018-06)` → European Standard with dotted number
  - `ETSI TS 123 251 V9.1.0 (2010-03)` → Technical Specification
  - `ETSI ES 201 880 V1.1.1 (2000-09)` → ETSI Standard
- **Rendering Formats:** Single format with type prefix
- **Special Features:**
  - Type code determines document type (EN, ES, EG, TS, etc.)
  - Code component handles complex numbering:
    - Dotted format: `200 053` → `200.053`
    - GSM format: `GSM 11.14` (preserved as-is)
    - Complex format: `ABC 123` or `ABC-DEF 123`
    - Simple format: `123456`
  - Version component: `V1.2.3` (version) or `ed.2` (edition)
  - Date component: `(YYYY-MM)` format
  - Parts: `-1`, `-2` appended to code

### Supplement Identifiers

#### Amendment

- **File:** `lib/pubid_new/etsi/identifiers/amendment.rb`
- **Parent:** `Base` (inherits from `Lutaml::Model::Serializable`)
- **Purpose:** Amendments modify or add to existing ETSI documents.
- **Components Used:** `base`, `number`
- **Patterns Supported:**
  - `ETSI EN 300 328 V2.2.2/A1` → Standard with amendment 1
  - `ETSI TS 123 251 V9.1.0/A2 (2010-03)` → Standard with amendment 2
  - `ETSI ES 201 880 V1.1.1/A3` → Standard with amendment 3
- **Rendering Formats:** Single format with `/A{number}` suffix
- **Recursion:** Supports multi-level supplements (amendment to amendment)
- **Special Features:**
  - `/A` prefix for amendment (instead of `/AMENDMENT`)
  - Amendment number required (1, 2, 3, etc.)
  - Wraps base identifier (which may itself have supplements)

#### Corrigendum

- **File:** `lib/pubid_new/etsi/identifiers/corrigendum.rb`
- **Parent:** `Base` (inherits from `Lutaml::Model::Serializable`)
- **Purpose:** Corrigenda correct errors in published ETSI documents.
- **Components Used:** `base`, `number`
- **Patterns Supported:**
  - `ETSI EN 300 328 V2.2.2/C1` → Standard with corrigendum 1
  - `ETSI TS 123 251 V9.1.0/C2` → Standard with corrigendum 2
- **Rendering Formats:** Single format with `/C{number}` suffix
- **Recursion:** Supports multi-level supplements
- **Special Features:**
  - `/C` prefix for corrigendum (instead of `/CORRIGENDUM`)
  - Corrigendum number required (1, 2, 3, etc.)
  - Wraps base identifier

## Scheme Registry

The `Scheme` class (`lib/pubid_new/etsi/scheme.rb`) is a simple model class, not a registry.

### Registry Methods

ETSI does not use a traditional registry pattern. The `Scheme` class is a Lutaml::Model::Serializable class with:

- **Attributes:** `type`, `number`, `part` (collection), `version`, `edition`, `date`, `amendment`, `corrigendum`
- **No identifier registry:** All documents use `EtsiStandard` class
- **No typed stages:** ETSI doesn't use stages
- **No type code lookup:** Type is stored as string attribute

### Parser Instance

ETSI doesn't use a memoized parser instance like other flavors.

## Rendering Examples

### Short Format (default)

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `ETSI EG 200 053 V1.5.1 (2004-06)` | `ETSI EG 200 053 V1.5.1 (2004-06)` |
| `ETSI GR ZSM 009-3 V1.1.1 (2023-08)` | `ETSI GR ZSM 009-3 V1.1.1 (2023-08)` |
| `ETSI GTS GSM 02.01 V5.5.0 (1999-01)` | `ETSI GTS GSM 02.01 V5.5.0 (1999-01)` |
| `ETSI EN 300 328 V2.2.2/A1` | `ETSI EN 300 328 V2.2.2/A1` |
| `ETSI TS 123 251 V9.1.0/C2` | `ETSI TS 123 251 V9.1.0/C2` |

## Parser Rules

### Main Rule

```ruby
rule(:identifier) do
  etsi_prefix >>
    type >>
    space >>
    number >>
    parts >>
    minor.maybe >>
    space.maybe >>
    version_or_edition.maybe >>
    supplements.maybe >>
    space.maybe >>
    date_part.maybe
end
```

### Component Rules

```ruby
# ETSI prefix
rule(:etsi_prefix) { str("ETSI") >> space }

# Type prefixes - all 15 types
rule(:type) do
  (str("I-ETS") | str("TCRTR") | str("GTS") | str("ETR") |
   str("ETS") | str("TBR") | str("NET") | str("EN") |
   str("ES") | str("EG") | str("TS") | str("GR") |
   str("GS") | str("SR") | str("TR")).as(:type)
end

# Number variants

# GSM with dotted number: "GSM 11.14", "GSM 02.01"
rule(:gsm_with_space_number) do
  str("GSM").capture(:gsm_prefix) >> space >>
    digits.capture(:main) >> dot >> digits.capture(:sub)
end

# Number with dot: 11.40, 02.01
rule(:dotted_number) do
  digits.capture(:main) >> dot >> digits.capture(:sub)
end

# Complex format: ABC 123 or ABC-DEF 123 or IP6 031
rule(:complex_number) do
  alnums.capture(:prefix1) >>
    (dash >> alnums.capture(:prefix2)).maybe >>
    space >>
    digits.capture(:num)
end

# Simple format: just digits
rule(:simple_number) do
  digits.capture(:num)
end

# Main number
rule(:number) do
  (gsm_with_space_number | dotted_number | complex_number | simple_number).as(:number)
end

# Optional minor part
rule(:minor) do
  space >> digits.as(:minor)
end

# Parts
rule(:part) do
  dash >> alnums.as(:part)
end

rule(:parts) { part.repeat(0).as(:parts) }

# Version
rule(:version) do
  str("V") >> match["0-9."].repeat(1).as(:version)
end

# Edition
rule(:edition) do
  str("ed.") >> digits.as(:edition)
end

# Version or edition
rule(:version_or_edition) do
  version | edition
end

# Published date
rule(:date_part) do
  str("(") >>
    digit.repeat(4, 4).as(:year) >>
    dash >>
    digit.repeat(2, 2).as(:month) >>
    str(")")
end

# Individual supplements
rule(:amendment) do
  str("/A") >> digits.as(:number)
end

rule(:corrigendum) do
  str("/C") >> digits.as(:number)
end

# Supplements (can be multiple)
rule(:supplements) do
  (amendment.as(:amendment) | corrigendum.as(:corrigendum)).repeat(1).as(:supplements)
end
```

## Builder Logic

### Identifier Class Selection

The Builder determines which identifier class to instantiate based on:

1. **Supplements presence** - If `:supplements` exists → build with supplements (Amendment/Corrigendum)
2. **No supplements** - Build `EtsiStandard` with type, code, version, date

### Supplement Building

Supplements are built recursively:

```ruby
# Build base identifier first (without supplements)
base = build_etsi_standard(base_data)

# Build supplements recursively - each wraps the previous
supplements_array.reduce(base) do |current_base, supp|
  if supp[:amendment]
    Identifiers::Amendment.new(
      base: current_base,
      number: supp[:amendment][:number].to_i,
    )
  elsif supp[:corrigendum]
    Identifiers::Corrigendum.new(
      base: current_base,
      number: supp[:corrigendum][:number].to_i,
    )
  end
end
```

### Component Building

#### Code Component

```ruby
def build_code(data)
  number_data = data[:number]

  # Extract number string based on format
  number = if number_data.is_a?(Hash)
             if number_data[:gsm_prefix]
               # GSM with space: "GSM 11.14"
               "GSM #{number_data[:main]}.#{number_data[:sub]}"
             elsif number_data[:main] && number_data[:sub]
               # Dotted format: "11.40"
               "#{number_data[:main]}.#{number_data[:sub]}"
             elsif number_data[:prefix1]
               # Complex format: "ABC 123" or "ABC-DEF 123"
               prefix = number_data[:prefix1].to_s
               prefix += "-#{number_data[:prefix2]}" if number_data[:prefix2]
               "#{prefix} #{number_data[:num]}"
             else
               number_data[:num].to_s
             end
           else
             number_data.to_s
           end

  parts = extract_parts(data[:parts])

  Components::Code.new(
    number: number,
    minor: data[:minor]&.to_s,
    parts: parts,
  )
end
```

#### Version Component

```ruby
def build_version(data)
  # Handle both version and edition
  if data[:version]
    Components::Version.new(version: data[:version].to_s, is_edition: false)
  elsif data[:edition]
    Components::Version.new(version: data[:edition].to_s, is_edition: true)
  else
    Components::Version.new(version: "1.0.0", is_edition: false)  # Default
  end
end
```

#### Date Component

```ruby
def build_date(data)
  PubidNew::Components::Date.new(
    year: data[:year].to_s,
    month: data[:month].to_s,
  )
end
```

## Preprocessing

ETSI does not use extensive preprocessing. Most normalization happens during parsing and building.

| Pattern | Input | Output | Purpose |
|---------|-------|--------|---------|
| Version format | `V1.5.1` | `version: "1.5.1"` | Extract version number |
| Edition format | `ed.2` | `edition: "2"` | Extract edition number |
| Date format | `(2004-06)` | `year: "2004", month: "06"` | Parse year-month |

## Testing

### Test Coverage

- **Unit tests:** `spec/pubid_new/etsi/components/`
- **Parser tests:** `spec/pubid_new/etsi/parser_spec.rb`
- **Builder tests:** `spec/pubid_new/etsi/builder_spec.rb`
- **Identifier tests:** `spec/pubid_new/etsi/identifiers/`
- **Integration tests:** `spec/integration/etsi_`

### Fixtures

Located in: `spec/fixtures/etsi/identifiers/`

- **Pass tests:** `pass/` - Valid patterns that should parse successfully
  - `etsi_standard.txt` - Base standard patterns
  - `amendment.txt` - Amendment patterns
  - `corrigendum.txt` - Corrigendum patterns
- **Fail tests:** `fail/` - Invalid patterns that should raise errors

### Coverage Status

The ETSI flavor has **100% test coverage** with 24,718 pass fixtures and 0 failures. All identifier classes and rendering patterns are fully covered.

## Migration Notes

### V1 to V2 Changes

**Major architectural changes:**
1. **Single identifier class** - All ETSI types use `EtsiStandard` class
2. **Custom components** - Code and Version components specific to ETSI
3. **Supplement recursion** - Amendments and corrigenda wrap base recursively
4. **Type as string** - Type code stored as attribute, not separate classes
5. **No typed stages** - ETSI doesn't use stages

**Breaking changes:**
- `Pubid::Etsi::Identifier` → `PubidNew::Etsi::Identifiers::EtsiStandard`
- Type is now string attribute, not class selector
- Supplements accessed via `base` attribute

**Migration guide:**
1. Replace `Pubid::Etsi.parse()` with `PubidNew::Etsi.parse()`
2. Use `EtsiStandard` class for all ETSI documents
3. Access type via `type` attribute
4. Access supplements via `base` attribute

## References

- **Specification:** ETSI (European Telecommunications Standards Institute)
- **Examples:** ETSI Deliverables (https://www.etsi.org/)
- **Related implementations:**
  - ITU flavor (similar telecom standards structure)
  - CCSDS flavor (similar version/edition patterns)

---

## Appendix: Design Decisions

### Single Identifier Class

**Context:** Most PubID flavors have separate classes for each document type.

**Decision:** ETSI uses single `EtsiStandard` class for all 15 document types.

**Rationale:**
- ETSI types are distinguished only by type code (EN, ES, EG, etc.)
- All types share identical structure and rendering
- Type code as attribute is simpler than 15 classes
- Easier to maintain and extend

**Alternatives considered:**
- Separate class for each type - Rejected (too much duplication)
- Use typed stages - Rejected (ETSI doesn't have stages)

### Custom Code Component

**Context:** ETSI has complex numbering patterns (GSM, dotted, complex, simple).

**Decision:** Create custom Code component to handle all patterns.

**Rationale:**
- Code component encapsulates number, minor, and parts
- Preserves original format information
- Flexible for different number patterns
- Shared components too generic for ETSI needs

**Alternatives considered:**
- Use shared Code component - Rejected (doesn't handle ETSI patterns)
- Store as string - Rejected (loses structure)

### Version and Edition

**Context:** ETSI uses both version notation (V1.2.3) and edition notation (ed.2).

**Decision:** Create Version component that handles both formats.

**Rationale:**
- Version and edition are semantically similar (version identifier)
- `is_edition` flag distinguishes format
- Single component simplifies code
- Default version (1.0.0) when not specified

**Alternatives considered:**
- Separate Version and Edition components - Rejected (duplication)
- Store as string - Rejected (loses format distinction)

### Date with Month

**Context:** ETSI dates include month (YYYY-MM format), unlike many flavors that only use year.

**Decision:** Date component stores both year and month.

**Rationale:**
- ETSI standards track specific publication months
- More precise than year-only dates
- Matches ETSI official format
- Date component already supports month

**Alternatives considered:**
- Store year only - Rejected (loses precision)
- Store full date - Rejected (ETSI doesn't use day)

### Recursive Supplement Wrapping

**Context:** ETSI supports supplements to supplements (e.g., amendment with corrigendum).

**Decision:** Build supplements recursively, each wrapping the previous.

**Rationale:**
- Clean object composition
- Each supplement is independent
- Preserves supplement order
- Flexible for arbitrary nesting

**Alternatives considered:**
- Flat array of supplements - Rejected (loses nesting information)
- Single combined supplement - Rejected (loses individual supplements)
