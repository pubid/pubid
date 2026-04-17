# PLATEAU Identifier Patterns

PLATEAU (Japanese urban planning standards)

## Entry Point

```ruby
require 'pubid/plateau'
id = Pubid::Plateau.parse("...")
```

## Identifier Types

### Annex

**Class:** `Pubid::Plateau::Identifiers::Annex`

### Base

**Class:** `Pubid::Plateau::Identifiers::Base`

### Handbook

**Class:** `Pubid::Plateau::Identifiers::Handbook`

### Technical Report

**Class:** `Pubid::Plateau::Identifiers::TechnicalReport`

## URN Support

true

## Pre-parse Normalization

See `data/plateau/update_codes.yaml` for legacy format mappings.
