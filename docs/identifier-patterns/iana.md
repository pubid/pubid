# IANA Identifier Patterns

IANA identifiers

## Entry Point

```ruby
require 'pubid/iana'
id = Pubid::Iana.parse("...")
```

## Identifier Types

### Registry

**Class:** `Pubid::Iana::Identifiers::Registry`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "IANA" | IANA Registry | :published |  |

## URN Support

true

## Pre-parse Normalization

No normalization rules defined.
