# IEEE Identifier Patterns

IEEE (Institute of Electrical and Electronics Engineers)

## Entry Point

```ruby
require 'pubid/ieee'
id = Pubid::Ieee.parse("...")
```

## Identifier Types

### Adopted Standard

**Class:** `Pubid::Ieee::Identifiers::AdoptedStandard`

### Base

**Class:** `Pubid::Ieee::Identifiers::Base`

### Conformance Identifier

**Class:** `Pubid::Ieee::Identifiers::ConformanceIdentifier`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "Conformance" |  | published |  |

### Corrigendum

**Class:** `Pubid::Ieee::Identifiers::Corrigendum`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "Cor" |  | published |  |

### Csa Dual Published

**Class:** `Pubid::Ieee::Identifiers::CsaDualPublished`

### Dual Identifier

**Class:** `Pubid::Ieee::Identifiers::DualIdentifier`

### Dual Published

**Class:** `Pubid::Ieee::Identifiers::DualPublished`

### Iec Ieee Copublished

**Class:** `Pubid::Ieee::Identifiers::IecIeeeCopublished`

### Interpretation Identifier

**Class:** `Pubid::Ieee::Identifiers::InterpretationIdentifier`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "INT" |  | published |  |

### Joint Development

**Class:** `Pubid::Ieee::Identifiers::JointDevelopment`

### Multi Numbered Identifier

**Class:** `Pubid::Ieee::Identifiers::MultiNumberedIdentifier`

### Nesc

**Class:** `Pubid::Ieee::Identifiers::Nesc`

### Parenthetical Identifier

**Class:** `Pubid::Ieee::Identifiers::ParentheticalIdentifier`

### Project Draft Identifier

**Class:** `Pubid::Ieee::Identifiers::ProjectDraftIdentifier`

### Redlined Standard

**Class:** `Pubid::Ieee::Identifiers::RedlinedStandard`

### Si Standard

**Class:** `Pubid::Ieee::Identifiers::SiStandard`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "SI" |  | published |  |
| "PSI" |  | draft |  |

### Standard

**Class:** `Pubid::Ieee::Identifiers::Standard`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "Std" |  | published |  |

### Supplement Identifier

**Class:** `Pubid::Ieee::Identifiers::SupplementIdentifier`

## URN Support

true

## Pre-parse Normalization

See `data/ieee/update_codes.yaml` for legacy format mappings.
