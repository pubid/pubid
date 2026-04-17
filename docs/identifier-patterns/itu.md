# ITU Identifier Patterns

ITU (International Telecommunication Union)

## Entry Point

```ruby
require 'pubid/itu'
id = Pubid::Itu.parse("...")
```

## Identifier Types

### Amendment

**Class:** `Pubid::Itu::Identifiers::Amendment`

### Base

**Class:** `Pubid::Itu::Identifiers::Base`

### Combined Identifier

**Class:** `Pubid::Itu::Identifiers::CombinedIdentifier`

### Corrigendum

**Class:** `Pubid::Itu::Identifiers::Corrigendum`

### Recommendation

**Class:** `Pubid::Itu::Identifiers::Recommendation`

### Supplement

**Class:** `Pubid::Itu::Identifiers::Supplement`

## URN Support

true

## Pre-parse Normalization

No normalization rules defined.
