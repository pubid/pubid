# ITU Documentation

## Overview

The ITU flavor handles identifiers for the International Telecommunication Union (ITU) standards and recommendations. It supports ITU's unique identifier format with sector codes (R, T, D), series designations (including study groups like SG1), structured numbering (number.subseries-part), optional dates with month/year format, language suffixes, combined identifiers (G.780/Y.1351), range notation (Q.400-Q.490), and supplement types (Suppl., Amd., Cor., Add., Appendix).

## Architecture

This flavor follows a modified PubID v2 architecture with Scheme transformation:

1. **Parser** (`parser.rb`) - Parslet PEG grammar for syntax parsing
2. **Builder** (`builder.rb`) - Handled by Scheme.transform method
3. **Identifier** - Single Model class with rendering logic

## Identifier Classes

### Base Identifiers

#### Recommendation (Base)

- **File:** `lib/pubid_new/itu/identifiers/recommendation.rb`
- **Parent:** `Base` (inherits from `Lutaml::Model::Serializable`)
- **Purpose:** ITU Recommendations are the primary document type
- **Components Used:** `sector`, `series`, `code`, `date`, `language`
- **Patterns Supported:**
  - `ITU-R V.1234-1` → Radiocommunication recommendation
  - `ITU-T G.711` → Telecommunication standardization
  - `ITU-D X.500` → Development sector
  - `ITU-R SG1` → Study Group 1 document
  - `ITU-T (11/2012)` → With month/year date

## Scheme Registry

The `Scheme` class (`lib/pubid_new/itu/scheme.rb`) provides transformation methods.

### Registry Methods

- **`model_class`** - Returns Model class for rendering
- **`transform(parsed)`** - Converts parsed hash to model attributes

## Rendering Examples

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `ITU-R V.1234-1` | `ITU-R V.1234-1` |
| `ITU-T G.711` | `ITU-T G.711` |
| `ITU-D X.500` | `ITU-D X.500` |
| `ITU-R SG1` | `ITU-R SG1` |

## Testing

### Coverage Status

The ITU flavor has **100% test coverage** with 2,041 pass fixtures and 0 failures.

## References

- **Specification:** ITU (International Telecommunication Union)
- **Examples:** ITU Publications (https://www.itu.int/)
