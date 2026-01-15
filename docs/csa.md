# CSA Documentation

## Overview

The CSA flavor handles identifiers for the Canadian Standards Association (CSA Group) standards and related documents. It supports CSA's complete identifier ecosystem including 8 distinct identifier types (Standard, CanadianAdopted, CsaAdopted, Bundled, Package, Series, CEC, Combined) with unique wrapper patterns for adoptions and composite structures for bundled identifiers. The flavor handles both English and French language variants, multiple year formats (colon and dash), reaffirmation notation, and complex numbering patterns including dotted codes and NO. notation for Canadian Electrical Code standards.

## Architecture

This flavor follows a hybrid PubID v2 architecture with some unique patterns:

1. **Parser** (`parser.rb`) - Parslet PEG grammar for syntax parsing
   - Converts input strings into structured hash trees
   - Handles complex code patterns (dotted numbers, NO. notation, letter suffixes)
   - Supports multiple year formats (colon `:23`, dash `-23`, 2-digit and 4-digit years)
   - Parses wrapper patterns (CAN/CSA-, CAN3-, CSA ISO/IEC)
   - Handles combined identifiers with `/` separator
   - Supports bundled identifiers with `+` notation
   - Parses package identifiers with materials metadata

2. **Builder** (`builder.rb`) - Transforms parse trees to domain objects
   - Identifies identifier type based on parsed structure
   - Builds wrapped identifiers recursively (CanadianAdopted, CsaAdopted)
   - Constructs composite identifiers (Package, Bundled, Combined)
   - Casts components to proper types (Code, Date)
   - Preserves rendering format information (year_format, french, year_prefix)

3. **Identifier** (`identifiers/`) - Lutaml::Model domain classes with rendering logic
   - Base identifiers (SingleIdentifier) for standalone documents
   - Wrapper identifiers (WrapperIdentifier) for adoptions
   - Composite identifiers (CompositeIdentifier, Lutaml::Model::Serializable)
   - Custom rendering for NO. notation, SERIES keywords, and reaffirmation

## Components

### Flavor-Specific Components

| Component | File | Purpose | Attributes |
|-----------|------|---------|------------|
| `Code` | `components/code.rb` | Generic string values (code, cec_part, no_number, series_prefix) | `value` |

### Shared Components Used

| Component | From | Purpose in this flavor |
|-----------|------|------------------------|
| `Publisher` | Not used | CSA uses publisher_prefix string attribute instead |
| `Code` | `lib/pubid_new/components/code.rb` | Not used - CSA has its own Code implementation |
| `Date` | `lib/pubid_new/components/date.rb` | Year-based dates (2-digit and 4-digit) |
| `Type` | `lib/pubid_new/components/type.rb` | Not used - CSA doesn't use typed stages |
| `Language` | `lib/pubid_new/components/language.rb` | French language support via `french` boolean |
| `Stage` | Not used | CSA doesn't use stages |
| `TypedStage` | Not used | CSA doesn't use typed stages |

## Identifier Classes

### Base Identifiers

#### Standard

- **File:** `lib/pubid_new/csa/identifiers/standard.rb`
- **Parent:** `Base` (inherits from `SingleIdentifier`)
- **Purpose:** The default CSA document type representing CSA standards. Supports complex code patterns, multiple year formats, reaffirmation notation, and series keywords.
- **Components Used:** `publisher_prefix`, `code`, `year`, `year_format`, `french`, `year_prefix`, `reaffirmation`, `no_number`, `series`, `series_prefix`, `package`
- **Patterns Supported:**
  - `CSA B149.1:20` → Standard with 2-digit year (colon format)
  - `CSA B149.1:F20` → Standard with French year notation
  - `CSA C22.1-15` → Standard with dash year format
  - `CSA Z462:24` → Simple dotted code
  - `CSA Z240 MH SERIES:16` → Standard with SERIES keyword
  - `CSA A123.17-05 (R2019)` → Standard with reaffirmation
  - `CSA C108.1.2-M1981 (R2013)` → Standard with multi-part code and month-year
- **Rendering Formats:** Single format (short) with year format detection
- **Special Features:**
  - Publisher prefixes: `CSA`, `CAN/CSA-`, `CAN3-`, `""` (code_only)
  - Year formats: colon (`:20`) or dash (`-20`)
  - French notation: `F20`, `M20` prefix
  - Reaffirmation: `(R2019)` suffix
  - Series keyword: `SERIES` after code or as primary type
  - NO. notation: `NO.` for CEC standards

#### Cec (Canadian Electrical Code)

- **File:** `lib/pubid_new/csa/identifiers/cec.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** Canadian Electrical Code standards with unique NO. notation. CEC Part (C22.2, C22.3, etc.) indicates the specific series within the C22 family of electrical codes.
- **Components Used:** `publisher_prefix`, `cec_part`, `no_number`, `year`, `year_format`, `french`, `year_prefix`, `reaffirmation`
- **Patterns Supported:**
  - `CSA C22.2 NO. 286:23` → CEC Part 2 with number 286
  - `CSA C22.3 NO. 7:20` → CEC Part 3 with number 7
  - `CAN/CSA-C22.2 NO. 60601-1-9:15` → Adopted CEC with multi-part NO. number
  - `CAN/CSA-C22.1 NO. 1:20` → CEC Part 1 (Canadian Electrical Code, Part I)
- **Rendering Formats:** Single format
- **Special Features:**
  - `cec_part` component: C22.2, C22.3, C22.4, C22.6 (specific CEC series)
  - `no_number` component: Number after NO. (can be multi-part like 60601-1-9)
  - `NO.` keyword preserved as semantic component (not normalized)

#### Series

- **File:** `lib/pubid_new/csa/identifiers/series.rb`
- **Parent:** `Base` (inherits from `SingleIdentifier`)
- **Purpose:** Series identifiers where SERIES is the primary document type, not just a modifier. Used for CSA series documents like MH Series (Manufactured Homes) and RV Series (Recreational Vehicles).
- **Components Used:** `publisher_prefix`, `series_prefix`, `code`, `year`, `year_format`, `french`, `year_prefix`, `reaffirmation`
- **Patterns Supported:**
  - `CSA MH SERIES 3.14:20` → MH Series with code 3.14
  - `CSA RV SERIES 1:19` → RV Series with code 1
  - `CSA SERIES Z1000:22` → Series without prefix
- **Rendering Formats:** Single format
- **Special Features:**
  - `series_prefix` component: MH, RV, etc. (optional)
  - `SERIES` keyword is primary type (rendered after prefix)
  - Different from Standard with `series` attribute where SERIES is a modifier

### Wrapper Identifiers

#### CanadianAdopted

- **File:** `lib/pubid_new/csa/identifiers/canadian_adopted.rb`
- **Parent:** `WrapperIdentifier`
- **Purpose:** Canadian adoption of CSA standards indicated by the CAN/ prefix wrapper. This is a wrapper pattern where CAN/ wraps an entire identifier (which may itself be complex like a combined or bundled identifier).
- **Components Used:** `wrapped_identifier`, `reaffirmation`
- **Patterns Supported:**
  - `CAN/CSA-A123.2-03 (R2023)` → Adopted standard
  - `CAN/CSA-C22.2 NO. 60601-1-9:15` → Adopted CEC standard
  - `CAN/CSA-B138.1-17/CSA B138.2-17 (R2022)` → Adopted combined standard
  - `CAN3-` → Legacy adoption format (no CAN/ prefix added)
- **Rendering Formats:** Single format
- **Special Features:**
  - Recursive parsing: wrapped_identifier is parsed as full CSA identifier
  - CAN3- is standalone (doesn't get CAN/ prefix)
  - Preserves reaffirmation at wrapper level
  - Proper object composition, not string manipulation

#### CsaAdopted

- **File:** `lib/pubid_new/csa/identifiers/csa_adopted.rb`
- **Parent:** `WrapperIdentifier`
- **Purpose:** CSA adoption of international standards (ISO, IEC, ISO/IEC, CISPR, etc.). Key difference from CanadianAdopted: CsaAdopted wraps external standards, CanadianAdopted wraps CSA standards.
- **Components Used:** `wrapped_identifier`, `reaffirmation`
- **Patterns Supported:**
  - `CSA ISO/IEC 8824-1:22` → Adopted ISO/IEC standard
  - `CSA ISO/IEC TR 12785-3:15` → Adopted Technical Report
  - `CSA CISPR 16-1-1:18` → Adopted CISPR standard
  - `CSA ISO/IEC 9075-15:20 (R2024)` → Adopted with reaffirmation
- **Rendering Formats:** Single format with 4-digit to 2-digit year conversion
- **Special Features:**
  - Converts 4-digit years to 2-digit for CSA adoption format
  - Wrapped identifier parsed using external flavor parsers (ISO, IEC)
  - Prepends CSA prefix to wrapped identifier
  - Preserves reaffirmation at wrapper level

### Composite Identifiers

#### Bundled

- **File:** `lib/pubid_new/csa/identifiers/bundled.rb`
- **Parent:** `Lutaml::Model::Serializable`
- **Purpose:** Bundled identifiers consolidate multiple CSA standards together using + notation. Used when multiple amendments/supplements are sold together.
- **Components Used:** `base`, `bundled_with` (collection), `reaffirmation`, `year_format`
- **Patterns Supported:**
  - `CSA Z662:23 + 1` → Base standard with bundled amendment 1
  - `CSA Z662:23 + 1 + 2` → Base with multiple bundled amendments
- **Rendering Formats:** Single format with + separator
- **Special Features:**
  - `base` is the primary standard
  - `bundled_with` is array of additional standards
  - Bundled portions rendered without CSA prefix (continuation style)
  - Each bundled item can have independent year and format

#### Package

- **File:** `lib/pubid_new/csa/identifiers/package.rb`
- **Parent:** `CompositeIdentifier`
- **Purpose:** Package identifiers represent CSA standards sold as packages with additional materials (PDF, print, addenda, etc.). Package portion is metadata, not a parseable identifier.
- **Components Used:** `base_identifier`, `package_materials`, `package_keyword`
- **Patterns Supported:**
  - `CSA Z662:23 PACKAGE INCLUDES: +1 (PDF & ESA)` → Package with materials
  - `CSA B149.1:20 PACKAGE (PDF + PRINT)` → Package with format info
  - `CSA C22.2 NO. 60601-1:15 PACKAGE WITH ADDENDUM` → Package with addendum
- **Rendering Formats:** Single format
- **Special Features:**
  - `base_identifier` is the core CSA standard (recursively parsed)
  - `package_materials` is descriptive string (not parsed)
  - Difference from Bundled: Package has metadata, Bundled has multiple identifiers
  - PACKAGE keyword always rendered

#### Combined

- **File:** `lib/pubid_new/csa/identifiers/combined.rb`
- **Parent:** `Lutaml::Model::Serializable`
- **Purpose:** Combined identifiers join multiple CSA standards with / separator. Used for related standards sold together or consolidated editions.
- **Components Used:** `first`, `second`, `third`, `reaffirmation`, `package`, `year_format`, `separator`
- **Patterns Supported:**
  - `CSA A23.1:24/CSA A23.2:24` → Two standards combined
  - `CSA N285.0:23/CSA N285.6 SERIES:23` → Standard + Series combined
  - `CSA B44:19/B44.1:19/B44.2:19` → Triple combined
  - `CSA A123.1-05/A123.5-05 (R2015)` → Combined with reaffirmation
- **Rendering Formats:** Single format with / separator
- **Special Features:**
  - `separator` attribute: "/" or ", " (comma-separated)
  - Second and third parts rendered without CSA prefix (continuation)
  - Each identifier maintains its own year format and attributes
  - Supports up to 3 combined identifiers

## Scheme Registry

The `Scheme` class (`lib/pubid_new/csa/scheme.rb`) is minimal compared to other flavors.

### Registry Methods

- **`identifiers`** - Array of all registered identifier classes
  ```ruby
  IDENTIFIERS = [
    Identifiers::Standard,
    Identifiers::Bundled,
    Identifiers::CanadianAdopted,
    Identifiers::CsaAdopted,
    Identifiers::Package,
    Identifiers::Series,
    Identifiers::Cec,
    Identifiers::Combined,
  ]
  ```

- **`typed_stages`** - Empty array (CSA doesn't use typed stages)

- **`supplement_identifiers`** - Empty array (CSA doesn't have supplement identifiers)

- **`locate_typed_stage_by_abbr(abbr)`** - Raises ArgumentError (CSA doesn't use typed stages)

- **`locate_identifier_klass_by_type_code(type_code)`** - Raises ArgumentError (CSA doesn't use type codes)

## Rendering Examples

### Short Format (default)

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `CSA B149.1:20` | `CSA B149.1:20` |
| `CSA C22.2 NO. 286:23` | `CSA C22.2 NO. 286:23` |
| `CAN/CSA-A123.2-03 (R2023)` | `CAN/CSA-A123.2-03 (R2023)` |
| `CSA ISO/IEC 8824-1:22` | `CSA ISO/IEC 8824-1:22` |
| `CSA Z662:23 + 1` | `CSA Z662:23 + 1` |
| `CSA A23.1:24/CSA A23.2:24` | `CSA A23.1:24/CSA A23.2:24` |
| `CSA MH SERIES 3.14:20` | `CSA MH SERIES 3.14:20` |

## Parser Rules

### Main Rule

```ruby
rule(:identifier) do
  canadian_adopted_identifier |
    csa_adopted_identifier |
    combined_identifier |
    bundled_identifier |
    package_identifier |
    series_identifier |
    cec_identifier |
    standard_identifier
end
```

### Component Rules

```ruby
# Publisher
rule(:publisher) { str("CSA") >> space }

# Code pattern: letter + dotted numbers
rule(:code_pattern) do
  # Pattern 1: Pure dotted numbers (12.4, 2.15)
  (match("[0-9]").repeat(1) >> dot >> match("[0-9]").repeat(1) >>
   (dash >> match("[0-9]").repeat(1)).repeat >> letter.repeat(2, 6).maybe) |
  # Pattern 2: Pure numbers with HB suffix (15189HB)
  (match("[0-9]").repeat(1) >> letter.repeat(2, 6)) |
  # Pattern 3: Letter + numbers with dots then dashes (C22.2-144, B149.1)
  (letter >> match("[0-9]").repeat(1) >>
   (dot >> match("[0-9]").repeat(1)).repeat >>
   (dash >> (match("[0-9]").repeat(3) | (match("[0-9]").repeat(1, 2) >> letter))).repeat >>
   letter.repeat(2, 6).maybe)
end

# NO. notation (for CEC standards)
rule(:no_notation) do
  space >> (str("NO.") | str("No.")).as(:no_notation) >> space
end

# Number after NO. (can be complex: 60601-1-9, 144.1, 1)
rule(:no_number) do
  (
    (match("[0-9]").repeat(1) >> (dash >> match("[0-9]").repeat(1)).repeat(1)) |
    (match("[0-9]").repeat(1) >> dot >> match("[0-9]").repeat(1)) |
    match("[0-9]").repeat(1)
  ).as(:no_number)
end

# Year with colon or dash
rule(:colon_year) do
  colon >> year_prefix >> (year_4digit | year_2digit).as(:year) >> str("").as(:colon_format)
end

rule(:dash_year) do
  dash >> year_prefix >> (year_4digit | year_2digit).as(:year) >> str("").as(:dash_format)
end

# Reaffirmation notation
rule(:reaffirmation) do
  space >> str("(R") >> year_4digit.as(:reaffirmation) >> str(")")
end
```

### Special Patterns

```ruby
# Canadian adoption wrapper (CAN/CSA- or CAN3-)
rule(:canadian_adopted_identifier) do
  (str("CAN/CSA-") | str("CAN3-")).as(:publisher_prefix) >>
    scope { identifier_no_csa_wrapped }.as(:wrapped_identifier) >>
    reaffirmation.maybe
end

# CSA adoption of external standards (CSA ISO/IEC, CSA CISPR)
rule(:csa_adopted_identifier) do
  str("CSA") >> space >>
    scope { external_identifier }.as(:wrapped_identifier) >>
    reaffirmation.maybe
end

# Combined identifier (/ separator)
rule(:combined_identifier) do
  standard_identifier.as(:first) >>
    (str(", ") | str("/")).as(:separator) >>
    standard_identifier.as(:second) >>
    (str(", ") | str("/") >> standard_identifier.as(:third)).maybe >>
    reaffirmation.maybe
end

# Bundled identifier (+ notation)
rule(:bundled_identifier) do
  standard_identifier.as(:bundled_first) >>
    (space >> str("+") >> space >> standard_identifier).repeat(1).as(:bundled_with) >>
    reaffirmation.maybe
end
```

## Builder Logic

### Identifier Class Selection

The Builder determines which identifier class to instantiate based on:

1. **Wrapper patterns** - `CAN/CSA-` or `CAN3-` → `CanadianAdopted`
2. **Adoption patterns** - `CSA ISO/IEC` or `CSA CISPR` → `CsaAdopted`
3. **Combined separator** - `/` or `, ` with multiple parts → `Combined`
4. **Bundled notation** - `+` between identifiers → `Bundled`
5. **Package keyword** - `PACKAGE` in identifier → `Package`
6. **SERIES as primary** - SERIES in type position → `Series`
7. **CEC pattern** - C22.x with NO. notation → `Cec`
8. **Default** - Standard CSA identifier → `Standard`

### Component Casting

Special casting logic in Builder:

```ruby
# Code (converts to Code component)
when :code
  Components::Code.new(value: parsed_hash[:code].to_s)

# CEC Part (for CEC standards)
when :cec_part
  Components::Code.new(value: parsed_hash[:cec_part].to_s)

# NO. Number (for CEC standards)
when :no_number
  Components::Code.new(value: parsed_hash[:no_number].to_s)

# Year (converts to integer, handles 2-digit and 4-digit)
when :year
  parsed_hash[:year].to_s.rjust(4, "20")  # Normalize to 4-digit

# Year format detection
year_format = if parsed_hash[:dash_format]
                "dash"
              elsif parsed_hash[:colon_format]
                "colon"
              end
```

## Preprocessing

CSA does not use extensive preprocessing. Most normalization happens during parsing and building.

| Pattern | Input | Output | Purpose |
|---------|-------|--------|---------|
| Year normalization | `:20` | `year=2020` | 2-digit years stored as 4-digit |
| Year format detection | `:23`, `-23` | `colon_format`, `dash_format` | Preserve original format |
| French prefix | `F20`, `M20` | `year_prefix="F"`, `year_prefix="M"` | Language/month prefix |

## Testing

### Test Coverage

- **Unit tests:** `spec/pubid_new/csa/components/`
- **Parser tests:** `spec/pubid_new/csa/parser_spec.rb`
- **Builder tests:** `spec/pubid_new/csa/builder_spec.rb`
- **Identifier tests:** `spec/pubid_new/csa/identifiers/`
- **Integration tests:** `spec/integration/csa_`

### Fixtures

Located in: `spec/fixtures/csa/identifiers/`

- **Pass tests:** `pass/` - Valid patterns that should parse successfully
  - `standard.txt` - Standard patterns
  - `canadian_adopted.txt` - Canadian adoption patterns
  - `csa_adopted.txt` - CSA adoption of external standards
  - `cec.txt` - Canadian Electrical Code patterns
  - `combined.txt` - Combined identifier patterns
  - `bundled.txt` - Bundled identifier patterns
  - `package.txt` - Package identifier patterns
  - `series.txt` - Series identifier patterns
  - `nil_class.txt` - Patterns that parse but have nil class
- **Fail tests:** `fail/` - Invalid patterns that should raise errors

### Coverage Status

The CSA flavor has good test coverage with **81.68% overall pass rate** (740/906). Gaps:
- Bundled identifiers: 0% pass (0/2)
- Combined identifiers: 5.43% pass (7/129)
- Package identifiers: 28.57% pass (2/7)
- Series identifiers: 0% pass (0/5)

Areas needing more test coverage: bundled, combined, package, and series patterns.

## Migration Notes

### V1 to V2 Changes

**Major architectural changes:**
1. **Wrapper pattern** - CanadianAdopted and CsaAdopted use proper object composition
2. **No typed stages** - CSA doesn't use TYPED_STAGES (unlike ISO/IEC)
3. **Composite identifiers** - Bundled, Package, Combined use dedicated classes
4. **Publisher prefix** - String attribute instead of Publisher component
5. **Code component** - Custom CSA Code component instead of shared

**Breaking changes:**
- `Pubid::Csa::Identifier` → `PubidNew::Csa::Identifiers::*` (specific classes)
- Adoption patterns now use wrapper classes, not string prefixes
- Year conversion (2-digit ↔ 4-digit) handled in rendering, not storage

**Migration guide:**
1. Replace `Pubid::Csa.parse()` with `PubidNew::Csa.parse()`
2. Use specific identifier classes instead of generic `Identifier`
3. Access adoption via `wrapped_identifier` attribute
4. Year format preserved via `year_format` attribute

## References

- **Specification:** CSA Group Standards Catalogue (https://www.csagroup.org/)
- **Examples:** CSA Online Store (https://store.csagroup.org/)
- **Related implementations:**
  - ASTM flavor (similar structure with adoptions)
  - ANSI flavor (similar adoption patterns)

---

## Appendix: Design Decisions

### No Typed Stages

**Context:** Most PubID flavors (ISO, IEC, JIS) use TYPED_STAGES for stage/type management.

**Decision:** CSA does not use typed stages or type codes.

**Rationale:**
- CSA identifiers don't have stage-based development lifecycle
- Type is determined by structure (adoption wrapper, combined separator, etc.)
- No need for stage code registry
- Simpler architecture for CSA-specific patterns

**Alternatives considered:**
- Use typed stages like ISO - Rejected (CSA has no stage system)
- Use type codes - Rejected (structure-based selection is clearer)

### Wrapper Pattern for Adoptions

**Context:** CSA has two types of adoptions: Canadian adoption (CAN/CSA-) and CSA adoption of external standards (CSA ISO/IEC).

**Decision:** Use WrapperIdentifier class with recursive parsing.

**Rationale:**
- CAN/ wraps entire identifier (which may itself be complex)
- CsaAdopted wraps external standard (parsed by external flavor)
- Proper object composition, not string manipulation
- Each adoption can be independently validated and rendered

**Alternatives considered:**
- Store as string prefix - Rejected (loses structure)
- Use flag attributes - Rejected (less clear, more flags)

### Publisher Prefix Instead of Publisher Component

**Context:** Most flavors use Publisher component for organization name.

**Decision:** CSA uses `publisher_prefix` string attribute.

**Rationale:**
- CSA has multiple prefix variants (CSA, CAN/CSA-, CAN3-, "")
- Prefix is rendered differently based on ending (dash vs no dash)
- No need for copublisher support in CSA
- Simpler than Publisher component for this use case

**Alternatives considered:**
- Use Publisher component - Rejected (overkill for single org variants)
- Store as part of code - Rejected (prefix is semantically distinct)

### NO. Notation Preservation

**Context:** CEC standards use "NO." notation (e.g., C22.2 NO. 286).

**Decision:** Preserve NO. as semantic component, don't normalize.

**Rationale:**
- NO. indicates specific semantic meaning (number within CEC series)
- Not just formatting - part of identifier structure
- CEC Part + NO. Number is the complete identifier
- Must be preserved for round-trip parsing

**Alternatives considered:**
- Normalize to simple number - Rejected (loses semantic meaning)
- Store as part of code - Rejected (code and NO. number are separate)

### Combined Identifier with Continuation Style

**Context:** Combined identifiers join multiple standards (e.g., CSA A23.1:24/CSA A23.2:24).

**Decision:** Second and subsequent parts rendered without CSA prefix.

**Rationale:**
- Matches CSA catalog rendering
- More concise for related standards
- Continuation style indicates relationship
- Each part still independently parseable

**Alternatives considered:**
- Full prefix for all parts - Rejected (doesn't match catalog)
- Use comma separator only - Rejected (slash is common in CSA)
