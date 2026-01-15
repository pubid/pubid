# PLATEAU Documentation

## Overview

The PLATEAU flavor handles identifiers for PLATEAU (Japanese PLATEAU Project) standards and related documents. It supports PLATEAU Handbooks and Technical Reports with Japanese edition notation (第X版), optional annexes (-1, -2, etc.), and special annex supplements (Annex A, Annex B, etc.). The format is specifically designed for Japanese metadata standards.

## Architecture

This flavor follows the PubID v2 three-layer architecture pattern:

1. **Parser** (`parser.rb`) - Parslet PEG grammar for syntax parsing
   - Converts input strings into structured hash trees
   - Handles simple, clean patterns specific to PLATEAU
   - Returns parse tree with component keys

2. **Builder** (`builder.rb`) - Transforms parse trees to domain objects
   - Casts parsed hash values to component objects
   - Instantiates appropriate identifier class

3. **Identifier** (`identifiers/`) - Lutaml::Model domain classes with rendering logic
   - Base class for all PLATEAU identifiers
   - Handbook and TechnicalReport classes
   - Annex supplement class

## Components

### Flavor-Specific Components

| Component | File | Purpose | Attributes |
|-----------|------|---------|------------|
| N/A | N/A | PLATEAU uses hash-based storage in identifiers | N/A |

### Shared Components Used

| Component | From | Purpose in this flavor |
|-----------|------|------------------------|
| N/A | N/A | PLATEAU does not use shared components | N/A |

## Identifier Classes

### Base Identifiers

#### TechnicalReport

- **File:** `lib/pubid_new/plateau/identifiers/technical_report.rb`
- **Parent:** `Base`
- **Purpose:** PLATEAU Technical Report documents
- **Components Used:** `type`, `number`, `annex`
- **Patterns Supported:**
  - `PLATEAU Technical Report #00` → Technical Report with number
  - `PLATEAU Technical Report #01-1` → Technical Report with annex
  - `PLATEAU Technical Report #14` → Technical Report
- **TYPED_STAGES:** Not applicable (PLATEAU does not use typed stages)
- **Rendering Formats:** Standard format only

#### Handbook

- **File:** `lib/pubid_new/plateau/identifiers/handbook.rb`
- **Parent:** `Base`
- **Purpose:** PLATEAU Handbook documents with Japanese edition notation
- **Components Used:** `type`, `number`, `annex`, `edition`
- **Patterns Supported:**
  - `PLATEAU Handbook #00 第1.0版` → Handbook with edition 1.0
  - `PLATEAU Handbook #01 第2.3版` → Handbook with edition 2.3
  - `PLATEAU Handbook #03-1 第1.0版` → Handbook with annex and edition
  - `PLATEAU Handbook #09 第4.0版` → Handbook with edition 4.0
- **TYPED_STAGES:** Not applicable (PLATEAU does not use typed stages)
- **Rendering Formats:** Standard format with Japanese edition notation

### Supplement Identifiers

#### Annex

- **File:** `lib/pubid_new/plateau/identifiers/annex.rb`
- **Parent:** `Base`
- **Purpose:** PLATEAU Annex supplements with letter notation
- **Components Used:** `base_identifier`, `annex_letter`
- **Patterns Supported:**
  - `PLATEAU Handbook #00 Annex A` → Annex A to Handbook
  - `PLATEAU Technical Report #01 Annex B` → Annex B to Technical Report
- **TYPED_STAGES:** Not applicable
- **Recursion:** Not applicable (terminal)
- **Rendering Formats:** Annex letter format

## Scheme Registry

The `Scheme` class (`lib/pubid_new/plateau/scheme.rb`) is the central registry for this flavor.

### Registry Methods

- **`identifiers`** - Not used (PLATEAU uses custom Scheme class)
  ```ruby
  class Scheme < Lutaml::Model::Serializable
    attribute :type, :string
    attribute :number, :integer
    attribute :annex, :integer, default: -> {}
    attribute :edition, :string, default: -> {}
  end
  ```

- **`typed_stages`** - Not applicable (PLATEAU does not use typed stages)

- **`locate_typed_stage_by_abbr(abbr)`** - Not used

- **`locate_identifier_klass_by_type_code(type_code)`** - Not used

### Parser Instance

```ruby
# Parser instance is created on-demand (not in Scheme class)
```

## Rendering Examples

### Standard Format

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `PLATEAU Technical Report #00` | `PLATEAU Technical Report #00` |
| `PLATEAU Technical Report #03-1` | `PLATEAU Technical Report #03-1` |
| `PLATEAU Handbook #00 第1.0版` | `PLATEAU Handbook #00 第1.0版` |
| `PLATEAU Handbook #03-1 第2.0版` | `PLATEAU Handbook #03-1 第2.0版` |
| `PLATEAU Handbook #00 Annex A` | `PLATEAU Handbook #00 Annex A` |

### Other Formats

| Format | Rendered Output |
|--------|-----------------|
| Not applicable for PLATEAU | N/A |

## Parser Rules

### Main Rule

```ruby
rule(:identifier) do
  annex_identifier | handbook | technical_report
end
```

### Component Rules

```ruby
# Publisher
rule(:publisher) { str("PLATEAU") }

# Document type
rule(:doc_type) do
  (str("Handbook") | str("Technical Report")).as(:type)
end

# Number: #00, #01, #46, etc.
rule(:number) { hash >> digits.as(:number) }

# Annex: -1, -2, etc.
rule(:annex) { dash >> digits.as(:annex) }

# Edition: 第1.0版, 第2.3版, etc. (only for Handbook)
rule(:edition_part) do
  str("第") >>
    (digits >> str(".") >> digits).as(:edition) >>
    str("版")
end

rule(:edition) { space >> edition_part }

# Annex supplement: "Annex A", "Annex B", etc.
rule(:annex_letter) { match["A-Z"].as(:annex_letter) }
rule(:annex_supplement) do
  space >> str("Annex") >> space >> annex_letter
end
```

### Special Patterns

```ruby
# Full identifier patterns
rule(:handbook) do
  publisher >> space >> doc_type >> space >>
    number >> annex.maybe >> edition.maybe
end

rule(:technical_report) do
  publisher >> space >> doc_type >> space >>
    number >> annex.maybe
end

# Annex identifier (supplement)
rule(:annex_identifier) do
  (handbook | technical_report).as(:base_identifier) >> annex_supplement
end
```

## Builder Logic

### Identifier Class Selection

The Builder determines which identifier class to instantiate based on:

1. **Type attribute** - "Handbook" → `Handbook`, "Technical Report" → `TechnicalReport`
2. **Annex letter** - If exists → `Annex` class

### Component Casting

Special casting logic in Builder's `build()` method:

```ruby
# Extract type
when :type
  extract_value(parsed[:type])

# Extract number (as integer)
when :number
  extract_value(parsed[:number]).to_i

# Extract annex (as integer)
when :annex
  extract_value(parsed[:annex]).to_i

# Extract edition (keep as string)
when :edition
  extract_value(parsed[:edition])
```

## Preprocessing

This flavor uses minimal preprocessing:

| Pattern | Input | Output | Purpose |
|---------|-------|--------|---------|
| Space trimming | `PLATEAU   Handbook` | `PLATEAU Handbook` | Normalize spaces |

## Testing

### Test Coverage

- **Unit tests:** `spec/pubid_new/plateau/`
- **Parser tests:** `spec/pubid_new/plateau/parser_spec.rb`
- **Builder tests:** `spec/pubid_new/plateau/builder_spec.rb`
- **Identifier tests:** `spec/pubid_new/plateau/identifiers/`
- **Integration tests:** `spec/integration/plateau_`

### Fixtures

Located in: `spec/fixtures/plateau/identifiers/`

- **Pass tests:** `pass/` - Valid patterns that should parse successfully
  - `technical_report.txt` - Technical Report patterns (83 examples)
  - `handbook.txt` - Handbook patterns (32 examples)
- **Fail tests:** `fail/` - Invalid patterns that should raise errors

### Coverage Status

The PLATEAU flavor has 100% test coverage (115/115 pass rate):
- Handbook: 32/32 (100%)
- Technical Report: 83/83 (100%)

## Migration Notes

### V1 to V2 Changes

**Major architectural changes:**
1. **Three-layer separation** - Parser, Builder, and Identifier are completely separate
2. **Simple hash-based storage** - Uses custom Base class instead of complex components
3. **Japanese edition notation** - Preserved as string attribute

**Breaking changes:**
- `Pubid::Plateau::Identifier` → `PubidNew::Plateau::Identifiers::*` (specific classes)

**Migration guide:**
1. Replace `Pubid::Plateau.parse()` with `PubidNew::Plateau.parse()`
2. Use specific identifier classes (Handbook, TechnicalReport, Annex)

## References

- **Specification:** PLATEAU Project (https://www.mlit.go.jp/plateau/)
- **Examples:** PLATEAU Specifications Repository
- **Related implementations:**
  - JIS flavor (similar Japanese notation patterns)

---

## Appendix: Design Decisions

### Custom Scheme Class

**Context:** PLATEAU has unique identifier format not similar to other standards.

**Decision:** PLATEAU uses custom Scheme class with hash-based storage.

**Rationale:**
- PLATEAU format is specific to Japanese metadata standards
- Simple hash storage is sufficient
- No need for complex component architecture

**Alternatives considered:**
- Use base Scheme class - Rejected (unnecessary complexity)
- Use full component system - Rejected (overkill)

### Japanese Edition Notation

**Context:** PLATEAU Handbooks use Japanese edition format (第1.0版).

**Decision:** Store edition as string attribute, render with special formatting.

**Rationale:**
- Japanese notation must be preserved exactly
- Edition format includes major.minor version (1.0, 2.3, etc.)
- No translation or localization needed

**Alternatives considered:**
- Parse into major/minor components - Rejected (loses format)
- Translate to English - Rejected (loses authenticity)

### Number Format (#NN)

**Context:** PLATEAU uses hash-prefixed zero-padded numbers (#00, #01, etc.).

**Decision:** Store number as integer, format with hash prefix and zero-padding on render.

**Rationale:**
- Zero-padded format is part of PLATEAU identity
- Hash prefix (#) is required notation
- Simple integer storage with custom rendering

**Alternatives considered:**
- Store as string with prefix - Rejected (mixes format and data)
- No zero-padding - Rejected (breaks format)
