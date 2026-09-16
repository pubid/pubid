# DOI Identifier Patterns

DOI identifiers

## Entry Point

```ruby
require 'pubid/doi'
id = Pubid::Doi.parse("...")
```

## Identifier Types

### Resource

**Class:** `Pubid::Doi::Identifiers::Resource`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "DOI" | DOI | :published |  |

## Examples

| # | Example |
|---|---------|
| 1 | `doi:10.1000/182` |
| 2 | `10.1006/jmbi.1998.2354` |
| 3 | `DOI:10.6028/NIST.2022-04-15.001` |
| 4 | `https://doi.org/10.1000/182` |

## URN Support

false

## Pre-parse Normalization

No normalization rules defined.
