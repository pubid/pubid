# CCSDS Documentation

## Overview

The CCSDS flavor handles identifiers for the Consultative Committee for Space Data Systems (CCSDS) standards and related documents. It supports CCSDS's unique identifier format with structured numbering (NUMBER.PART-TYPE-EDITION), type codes (B, G, M, R, Y, O, etc.), edition notation, optional suffixes, corrigendum supplements, and language translation metadata. The flavor uses a simple Lutaml::Model-based architecture with two identifier classes (Base and Corrigendum) and follows the CCSDS numbering scheme exactly.

## Architecture

This flavor follows a simplified PubID v2 architecture using Lutaml::Model:

1. **Parser** (`parser.rb`) - Parslet PEG grammar for syntax parsing
   - Converts input strings into structured hash trees
   - Parses CCSDS prefix and structured number format
   - Handles part notation (.1, .2, etc.)
   - Parses type letter codes (B, G, M, R, Y, O, etc.)
   - Supports edition notation with dots (4, 4.1, etc.)
   - Handles suffix notation (-S, etc.)
   - Parses corrigendum supplements (Cor. 1, Cor. 2)
   - Supports language metadata (French Translated, Russian Translated)

2. **Builder** (`builder.rb`) - Transforms parse trees to domain objects
   - Constructs Base or Corrigendum identifier based on parsed data
   - Wraps base identifier with corrigendum recursively
   - Converts parsed values to proper types

3. **Identifier** (`identifiers/`) - Lutaml::Model domain classes with rendering logic
   - Base identifiers (Base) for standalone CCSDS documents
   - Supplement identifiers (Corrigendum) for corrigenda
   - Simple rendering matching CCSDS format

## Components

### Flavor-Specific Components

| Component | File | Purpose | Attributes |
|-----------|------|---------|------------|
| None | N/A | CCSDS uses direct attributes | N/A |

### Shared Components Used

| Component | From | Purpose in this flavor |
|-----------|------|------------------------|
| None | N/A | CCSDS doesn't use shared components | N/A |

## Identifier Classes

### Base Identifiers

#### Base

- **File:** `lib/pubid_new/ccsds/identifiers/base.rb`
- **Parent:** `Lutaml::Model::Serializable`
- **Purpose:** CCSDS identifier with structured format NUMBER.PART-TYPE-EDITION[-SUFFIX]. This is the primary and only base identifier class for CCSDS documents.
- **Components Used:** `number`, `part`, `type`, `edition`, `suffix`, `language`
- **Patterns Supported:**
  - `CCSDS 120.0-G-1` → Base document with number, part, type, edition
  - `CCSDS 120.0-G-1-S` → Document with suffix
  - `CCSDS 101.0-B-1` → Blue Book (B type)
  - `CCSDS 130.0-G-1` → Green Book (G type)
  - `CCSDS 100.0-M-1` → Magenta Book (M type)
  - `CCSDS 101.0-R-1` → Red Book (R type)
  - `CCSDS 101.0-Y-1` → Yellow Book (Y type)
  - `CCSDS 120.1-G-1` → With part 1
  - `CCSDS 101.0-B-4.1` → With dotted edition (4.1)
- **Rendering Formats:** Single format
- **Special Features:**
  - Number: Can be alphanumeric (e.g., 120, A02)
  - Part: Optional dot-separated number (e.g., .0, .1)
  - Type: Letter code (B=Blue Book, G=Green Book, M=Magenta Book, R=Red Book, Y=Yellow Book, O=Orange Book, etc.)
  - Edition: Integer with optional decimal (e.g., 1, 4.1)
  - Suffix: Optional letter (e.g., -S)
  - Language: Metadata for translations (e.g., "French Translated")

### Supplement Identifiers

#### Corrigendum

- **File:** `lib/pubid_new/ccsds/identifiers/corrigendum.rb`
- **Parent:** `SupplementIdentifier`
- **Purpose:** Corrigenda correct errors in published CCSDS documents.
- **Components Used:** `base_identifier`, `cor_number`
- **Patterns Supported:**
  - `CCSDS 120.0-G-1 Cor. 1` → Base with corrigendum 1
  - `CCSDS 101.0-B-3 Cor. 2` → Base with corrigendum 2
  - `CCSDS 101.0-B-3 Cor. 1 Cor. 2` → Base with multiple corrigenda
- **Rendering Formats:** Single format with `Cor. {number}` suffix
- **Recursion:** Supports multiple corrigenda (rendered as space-separated list)
- **Special Features:**
  - `Cor.` keyword with number
  - Multiple corrigenda rendered in sequence
  - Wraps base identifier recursively

## Scheme Registry

The `Scheme` class (`lib/pubid_new/ccsds/scheme.rb`) is minimal for this flavor.

### Registry Methods

- **`identifiers`** - Array of base identifier classes
  ```ruby
  def identifiers
    [Identifiers::Base]
  end
  ```

- **`supplement_identifiers`** - Array of supplement identifier classes
  ```ruby
  def supplement_identifiers
    [Identifiers::Corrigendum]
  end
  ```

## Rendering Examples

### Short Format (default)

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `CCSDS 120.0-G-1` | `CCSDS 120.0-G-1` |
| `CCSDS 120.0-G-1-S` | `CCSDS 120.0-G-1-S` |
| `CCSDS 101.0-B-1` | `CCSDS 101.0-B-1` |
| `CCSDS 120.0-G-1 Cor. 1` | `CCSDS 120.0-G-1 Cor. 1` |

## Parser Rules

### Main Rule

```ruby
rule(:identifier) do
  ccsds_prefix >>
    number >>
    part.maybe >>
    type.maybe >>
    edition.maybe >>
    suffix.maybe >>
    corrigenda >>
    language_metadata.maybe
end
```

## Testing

### Test Coverage

The CCSDS flavor has **100% test coverage** with 490 pass fixtures and 0 failures.

## References

- **Specification:** CCSDS (Consultative Committee for Space Data Systems)
- **Examples:** CCSDS Publications (https://public.ccsds.org/)
