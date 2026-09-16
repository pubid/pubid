# JCGM Identifier Patterns

JCGM (Joint Committee for Guides in Metrology)

## Entry Point

```ruby
require 'pubid/jcgm'
id = Pubid::Jcgm.parse("...")
```

## Identifier Types

### Amendment

**Class:** `Pubid::Jcgm::Identifiers::Amendment`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "Amd" | Amendment | :published |  |

### Guide

**Class:** `Pubid::Jcgm::Identifiers::Guide`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "" |  | :published |  |

### Gum Guide

**Class:** `Pubid::Jcgm::Identifiers::GumGuide`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "" | GUM Guide | :published |  |

## URN Support

true

## Pre-parse Normalization

No normalization rules defined.
