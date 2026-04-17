# IDF Identifier Patterns

IDF (International Dairy Federation)

## Entry Point

```ruby
require 'pubid/idf'
id = Pubid::Idf.parse("...")
```

## Identifier Types

### Amendment

**Class:** `Pubid::Idf::Identifiers::Amendment`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| AMD | Amendment | :published |  |

### Corrigendum

**Class:** `Pubid::Idf::Identifiers::Corrigendum`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| COR | Corrigendum | :published |  |

### International Standard

**Class:** `Pubid::Idf::Identifiers::InternationalStandard`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "PWI" | Proposed Work Item for International Standard | :pwi |  |
| "NP", "NWIP" | New Work Item Proposal for International Standard | :np |  |
| "AWI" | Approved Work Item for International Standard | :awi |  |
| "WD" | Working Draft for International Standard | :wd |  |
| "CD" | Committee Draft for International Standard | :cd |  |
| "FCD" | Final Committee Draft for International Standard | :fcd |  |
| "DIS", "FPD" | Draft International Standard | :dis |  |
| "FDIS" | Final Draft International Standard | :fdis |  |
| "PRF", "Fpr" | Proof International Standard | :prf |  |
| "" | International Standard | :published |  |
| "WDR" | Proposed for Withdrawal | :wdr |  |
| "WDA" | Withdrawal Approved | :wda |  |
| "WDAR" | Withdrawal Archived | :wdar |  |

### Reviewed Method

**Class:** `Pubid::Idf::Identifiers::ReviewedMethod`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "PWI RM" | Proposed Work Item for Reviewed Method | :pwi |  |
| "NP RM" | New Work Item Proposal for Reviewed Method | :np |  |
| "AWI RM" | Approved Work Item for Reviewed Method | :awi |  |
| "WD RM" | Working Draft Reviewed Method | :wd |  |
| "CD RM" | Committee Draft Reviewed Method | :cd |  |
| "PDRM" | Proposed Draft Reviewed Method | :cd |  |
| "DRM" | Draft Reviewed Method |  |  |
| "FDRM" | Final Draft Reviewed Method |  |  |
| "PRF RM" | Proof Reviewed Method | :prf |  |
| "RM" | Published Reviewed Method | :published |  |

## URN Support

true

## Pre-parse Normalization

No normalization rules defined.
