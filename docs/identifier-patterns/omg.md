# OMG Identifier Patterns

OMG identifiers

## Entry Point

```ruby
require 'pubid/omg'
id = Pubid::Omg.parse("...")
```

## Identifier Types

### Specification

**Class:** `Pubid::Omg::Identifiers::Specification`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "OMG" | OMG Specification | :published |  |

## Examples

| # | Example |
|---|---------|
| 1 | `OMG AMI4CCM 1.0` |
| 2 | `OMG AMI4CCM 1.1` |
| 3 | `OMG UML 2.5.1` |
| 4 | `OMG SysML 1.6` |
| 5 | `OMG DDS 5 beta 3` |

## URN Support

false

## Pre-parse Normalization

No normalization rules defined.
