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

### Base Backup 88929

**Class:** `Pubid::Ccsds::Identifiers::BaseBackup88929`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "" |  | published |  |

### Base Base 88929

**Class:** `Pubid::Ccsds::Identifiers::BaseBase88929`

### Base Local 88929

**Class:** `Pubid::Ccsds::Identifiers::BaseLocal88929`

### Base Remote 88929

**Class:** `Pubid::Ccsds::Identifiers::BaseRemote88929`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "" |  | published |  |

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
