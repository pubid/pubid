# ASHRAE Identifier Patterns

ASHRAE (American Society of Heating, Refrigerating and Air-Conditioning Engineers)

## Entry Point

```ruby
require 'pubid/ashrae'
id = Pubid::Ashrae.parse("...")
```

## Identifier Types

### Addenda Package

**Class:** `Pubid::Ashrae::Identifiers::AddendaPackage`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "Addenda Supplement Package", "Addenda Package" |  | published |  |

### Addendum

**Class:** `Pubid::Ashrae::Identifiers::Addendum`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "Addendum", "Addenda" |  | published |  |

### Base

**Class:** `Pubid::Ashrae::Identifiers::Base`

### Combined Addenda

**Class:** `Pubid::Ashrae::Identifiers::CombinedAddenda`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "Addenda", "Combined Addenda" |  | published |  |

### Errata

**Class:** `Pubid::Ashrae::Identifiers::Errata`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "Errata" |  | published |  |

### Guideline

**Class:** `Pubid::Ashrae::Identifiers::Guideline`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "Guideline", "ASHRAE" |  | published |  |
| "P" |  | proposed |  |
| "R" |  | revision |  |

### Interpretation

**Class:** `Pubid::Ashrae::Identifiers::Interpretation`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "Interpretations" |  | published |  |

### Standard

**Class:** `Pubid::Ashrae::Identifiers::Standard`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "Standard", "ASHRAE" |  | published |  |
| "P" |  | proposed |  |
| "R" |  | revision |  |

## URN Support

true

## Pre-parse Normalization

No normalization rules defined.
