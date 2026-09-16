# BIPM Identifier Patterns

BIPM identifiers

## Entry Point

```ruby
require 'pubid/bipm'
id = Pubid::Bipm.parse("...")
```

## Identifier Types

### Committee Document

**Class:** `Pubid::Bipm::Identifiers::CommitteeDocument`

### Guide

**Class:** `Pubid::Bipm::Identifiers::Guide`

### Meeting

**Class:** `Pubid::Bipm::Identifiers::Meeting`

### Mep

**Class:** `Pubid::Bipm::Identifiers::Mep`

### Metrologia Article

**Class:** `Pubid::Bipm::Identifiers::MetrologiaArticle`

### Si Brochure

**Class:** `Pubid::Bipm::Identifiers::SiBrochure`

## URN Support

true

## Pre-parse Normalization

See `data/bipm/update_codes.yaml` for legacy format mappings.
