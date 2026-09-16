# JIS Identifier Patterns

JIS (Japanese Industrial Standards)

## Entry Point

```ruby
require 'pubid/jis'
id = Pubid::Jis.parse("...")
```

## Identifier Types

### Amendment

**Class:** `Pubid::Jis::Identifiers::Amendment`

### Base

**Class:** `Pubid::Jis::Identifiers::Base`

### Explanation

**Class:** `Pubid::Jis::Identifiers::Explanation`

### Japanese Industrial Standard

**Class:** `Pubid::Jis::Identifiers::JapaneseIndustrialStandard`

### Standard

**Class:** `Pubid::Jis::Identifiers::Standard`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "JIS" | Japanese Industrial Standard | :published |  |

### Technical Report

**Class:** `Pubid::Jis::Identifiers::TechnicalReport`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "TR" | Technical Report | :published |  |

### Technical Specification

**Class:** `Pubid::Jis::Identifiers::TechnicalSpecification`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "TS" | Technical Specification | :published |  |

## URN Support

true

## Pre-parse Normalization

No normalization rules defined.
