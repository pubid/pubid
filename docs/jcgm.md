# JCGM Documentation

## Overview

The JCGM flavor handles identifiers for the Joint Committee for Guides in Metrology (JCGM) documents. It supports JCGM's complete identifier ecosystem including 2 distinct document types (Guide and GUM Guide) with optional language codes, year-based dates, and amendment supplements.

## Architecture

This flavor follows the PubID v2 three-layer architecture pattern:

1. **Parser** (`parser.rb`) - Parslet PEG grammar for syntax parsing
2. **Builder** (`builder.rb`) - Transforms parse trees to domain objects via Scheme registry
3. **Identifier** (`identifiers/`) - Lutaml::Model domain classes with rendering logic

## Identifier Classes

### Base Identifiers

#### Guide

- **File:** `lib/pubid_new/jcgm/identifiers/guide.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** JCGM Guides provide guidance on metrology practices
- **Patterns Supported:**
  - `JCGM 100:2008` → Guide with year
  - `JCGM 100:2008(E)` → Guide with English language
  - `JCGM 200:2012(E/F)` → Guide with bilingual language codes

#### GumGuide

- **File:** `lib/pubid_new/jcgm/identifiers/gum_guide.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** GUM (Guide to the Expression of Uncertainty in Measurement) Guides
- **Patterns Supported:**
  - `JCGM 100:2008` → GUM Guide
  - `JCGM 100:2008(E)` → GUM Guide with English language
  - `JCGM 200:2007(F)` → GUM Guide with French language

### Supplement Identifiers

#### Amendment

- **File:** `lib/pubid_new/jcgm/identifiers/amendment.rb`
- **Parent:** `SupplementIdentifier`
- **Purpose:** Amendments modify or add to existing JCGM documents
- **Patterns Supported:**
  - `JCGM 100:2008/Amd 1:2010` → Guide with amendment
  - `JCGM 200:2012/Amd 2:2015` → GUM Guide with amendment 2

## Scheme Registry

The `Scheme` class (`lib/pubid_new/jcgm/scheme.rb`) is the central registry.

### Registry Methods

- **`identifiers`** - Array of all registered identifier classes
  ```ruby
  def identifiers
    [
      Identifiers::Guide,
      Identifiers::GumGuide,
    ]
  end
  ```

- **`supplement_identifiers`** - Array of supplement identifier classes
  ```ruby
  def supplement_identifiers
    [
      Identifiers::Amendment,
    ]
  end
  ```

## Rendering Examples

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `JCGM 100:2008` | `JCGM 100:2008` |
| `JCGM 100:2008(E)` | `JCGM 100:2008(E)` |
| `JCGM 200:2012(E/F)` | `JCGM 200:2012(E/F)` |
| `JCGM 100:2008/Amd 1:2010` | `JCGM 100:2008/Amd 1:2010` |

## Testing

### Coverage Status

The JCGM flavor has **100% test coverage** with 9 pass fixtures and 0 failures.

## References

- **Specification:** JCGM (Joint Committee for Guides in Metrology)
- **Examples:** JCGM Publications (https://www.bipm.org/en/committees/jc/jcgm/)
