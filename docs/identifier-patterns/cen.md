# CEN Identifier Patterns

CEN (European Committee for Standardization)

## Entry Point

```ruby
require 'pubid/cen'
id = Pubid::Cen.parse("...")
```

## Identifier Types

### Adopted European Norm

**Class:** `Pubid::Cen::Identifiers::AdoptedEuropeanNorm`

### Amendment

**Class:** `Pubid::Cen::Identifiers::Amendment`

### Base

**Class:** `Pubid::Cen::Identifiers::Base`

### Cen Report

**Class:** `Pubid::Cen::Identifiers::CenReport`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "CR" | CEN Report | :published |  |

### Cen Workshop Agreement

**Class:** `Pubid::Cen::Identifiers::CenWorkshopAgreement`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "CWA" | CEN Workshop Agreement | :published |  |

### Cenelec Harmonization Document

**Class:** `Pubid::Cen::Identifiers::CenelecHarmonizationDocument`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "HD" | CENELEC Harmonization Document | :published |  |

### Consolidated Identifier

**Class:** `Pubid::Cen::Identifiers::ConsolidatedIdentifier`

### Corrigendum

**Class:** `Pubid::Cen::Identifiers::Corrigendum`

### European Norm

**Class:** `Pubid::Cen::Identifiers::EuropeanNorm`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "EN" | European Norm | :published |  |
| "prEN" | Proposal European Norm | :proposal |  |
| "FprEN" | Final Proposal European Norm | :final_proposal |  |

### European Prestandard

**Class:** `Pubid::Cen::Identifiers::EuropeanPrestandard`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "ENV" | European Prestandard | :published |  |

### European Specification

**Class:** `Pubid::Cen::Identifiers::EuropeanSpecification`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "ES" | European Specification | :published |  |

### Fragment

**Class:** `Pubid::Cen::Identifiers::Fragment`

### Guide

**Class:** `Pubid::Cen::Identifiers::Guide`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "Guide" | Guide | :published |  |

### Harmonization Document

**Class:** `Pubid::Cen::Identifiers::HarmonizationDocument`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "HD" | Harmonization Document | :published |  |

### Technical Report

**Class:** `Pubid::Cen::Identifiers::TechnicalReport`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "TR" | Technical Report | :published |  |

### Technical Specification

**Class:** `Pubid::Cen::Identifiers::TechnicalSpecification`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "TS" | Technical Specification | :published |  |
| "prTS" | Proposal Technical Specification | :proposal |  |

## URN Support

true

## Pre-parse Normalization

No normalization rules defined.
