# CCSDS Identifier Patterns

CCSDS (Consultative Committee for Space Data Systems)

## Entry Point

```ruby
require 'pubid/ccsds'
id = Pubid::Ccsds.parse("...")
```

## Identifier Types

### Base

**Class:** `Pubid::Ccsds::Identifiers::Base`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "" |  | published |  |

### Base Base 88929

**Class:** `Pubid::Ccsds::Identifiers::BaseBase88929`

### Corrigendum

**Class:** `Pubid::Ccsds::Identifiers::Corrigendum`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "Cor", "Corr" |  | published |  |

## URN Support

true

## Pre-parse Normalization

See `data/ccsds/update_codes.yaml` for legacy format mappings.
