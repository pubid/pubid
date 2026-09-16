# GB Identifier Patterns

GB identifiers

## Entry Point

```ruby
require 'pubid/gb'
id = Pubid::Gb.parse("...")
```

## Identifier Types

### Standard

**Class:** `Pubid::Gb::Identifiers::Standard`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "GB" | Chinese Standard | :published |  |

## Examples

| # | Example |
|---|---------|
| 1 | `JB/T 13368-2018` |
| 2 | `HB/Z 12-2010` |
| 3 | `GB/T 20223-2006` |
| 4 | `GB/T 5606.1-2004` |
| 5 | `GB/T 5606 (all parts)` |
| 6 | `GB 1234-2010` |
| 7 | `GB/Z 123-2008` |
| 8 | `# Social-group standard (T/{ORG}) — Chinese typography uses em-dash for year` |
| 9 | `# separator; the parser accepts both forms and normalizes to ASCII dash.` |
| 10 | `T/GZAEPI 001-2018` |

## URN Support

false

## Pre-parse Normalization

No normalization rules defined.
