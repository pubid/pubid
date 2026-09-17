# ECMA Identifier Patterns

ECMA identifiers

## Entry Point

```ruby
require 'pubid/ecma'
id = Pubid::Ecma.parse("...")
```

## Identifier Types

### Memento

**Class:** `Pubid::Ecma::Identifiers::Memento`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "MEM" | Memento | :published |  |

### Standard

**Class:** `Pubid::Ecma::Identifiers::Standard`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "ECMA" | Standard | :published |  |

### Technical Report

**Class:** `Pubid::Ecma::Identifiers::TechnicalReport`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "TR" | Technical Report | :published |  |

## URN Support

true

## Pre-parse Normalization

No normalization rules defined.
