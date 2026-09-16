# ISBN Identifier Patterns

ISBN identifiers

## Entry Point

```ruby
require 'pubid/isbn'
id = Pubid::Isbn.parse("...")
```

## Identifier Types

### Book

**Class:** `Pubid::Isbn::Identifiers::Book`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "ISBN" | ISBN | :published |  |

## Examples

| # | Example |
|---|---------|
| 1 | `ISBN 0-306-40615-2` |
| 2 | `ISBN: 0-306-40615-2` |
| 3 | `ISBN 978-3-16-148410-0` |
| 4 | `9783161484100` |

## URN Support

false

## Pre-parse Normalization

No normalization rules defined.
