# TGPP Identifier Patterns

TGPP identifiers

## Entry Point

```ruby
require 'pubid/tgpp'
id = Pubid::Tgpp.parse("...")
```

## Identifier Types

### Technical Report

**Class:** `Pubid::Tgpp::Identifiers::TechnicalReport`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "TR" | Technical Report | :published |  |

### Technical Specification

**Class:** `Pubid::Tgpp::Identifiers::TechnicalSpecification`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "TS" | Technical Specification | :published |  |

## URN Support

true

## Pre-parse Normalization

No normalization rules defined.
