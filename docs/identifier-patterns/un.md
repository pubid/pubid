# UN Identifier Patterns

UN identifiers

## Entry Point

```ruby
require 'pubid/un'
id = Pubid::Un.parse("...")
```

## Identifier Types

### Document

**Class:** `Pubid::Un::Identifiers::Document`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "UN" | UN Document | :published |  |

## Examples

| # | Example |
|---|---------|
| 1 | `A/RES/78/1` |
| 2 | `UN A/RES/78/1` |
| 3 | `TRADE/CEFACT/2004/32` |
| 4 | `TRADE/WP.4/1068` |
| 5 | `TRADE/WP.4/R.1068` |

## URN Support

false

## Pre-parse Normalization

No normalization rules defined.
