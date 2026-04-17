# ETSI Identifier Patterns

ETSI (European Telecommunications Standards Institute)

## Entry Point

```ruby
require 'pubid/etsi'
id = Pubid::Etsi.parse("...")
```

## Identifier Types

### Amendment

**Class:** `Pubid::Etsi::Identifiers::Amendment`

### Base

**Class:** `Pubid::Etsi::Identifiers::Base`

### Corrigendum

**Class:** `Pubid::Etsi::Identifiers::Corrigendum`

### Etsi Standard

**Class:** `Pubid::Etsi::Identifiers::EtsiStandard`

### Supplement Identifier

**Class:** `Pubid::Etsi::Identifiers::SupplementIdentifier`

## URN Support

true

## Pre-parse Normalization

No normalization rules defined.
