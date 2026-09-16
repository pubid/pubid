# CEN-CENELEC Identifier Patterns

CEN (European Committee for Standardization)

## Entry Point

```ruby
require 'pubid/cen_cenelec'
id = Pubid::CenCenelec.parse("...")
```

## Identifier Types

### Adopted European Norm

**Class:** `Pubid::CenCenelec::Identifiers::AdoptedEuropeanNorm`

### Amendment

**Class:** `Pubid::CenCenelec::Identifiers::Amendment`

### Base

**Class:** `Pubid::CenCenelec::Identifiers::Base`

### Cen Report

**Class:** `Pubid::CenCenelec::Identifiers::CenReport`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "CR" | CEN Report | :published |  |

### Cen Workshop Agreement

**Class:** `Pubid::CenCenelec::Identifiers::CenWorkshopAgreement`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "CWA" | CEN Workshop Agreement | :published |  |

### Cenelec Harmonization Document

**Class:** `Pubid::CenCenelec::Identifiers::CenelecHarmonizationDocument`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "HD" | CENELEC Harmonization Document | :published |  |

### Consolidated Identifier

**Class:** `Pubid::CenCenelec::Identifiers::ConsolidatedIdentifier`

### Corrigendum

**Class:** `Pubid::CenCenelec::Identifiers::Corrigendum`

### European Norm

**Class:** `Pubid::CenCenelec::Identifiers::EuropeanNorm`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "EN" | European Norm | :published |  |
| "prEN" | Proposal European Norm | :proposal |  |
| "FprEN" | Final Proposal European Norm | :final_proposal |  |

### European Prestandard

**Class:** `Pubid::CenCenelec::Identifiers::EuropeanPrestandard`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "ENV" | European Prestandard | :published |  |

### European Specification

**Class:** `Pubid::CenCenelec::Identifiers::EuropeanSpecification`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "ES" | European Specification | :published |  |

### Fragment

**Class:** `Pubid::CenCenelec::Identifiers::Fragment`

### Guide

**Class:** `Pubid::CenCenelec::Identifiers::Guide`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "Guide" | Guide | :published |  |

### Harmonization Document

**Class:** `Pubid::CenCenelec::Identifiers::HarmonizationDocument`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "HD" | Harmonization Document | :published |  |

### Technical Report

**Class:** `Pubid::CenCenelec::Identifiers::TechnicalReport`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "TR" | Technical Report | :published |  |

### Technical Specification

**Class:** `Pubid::CenCenelec::Identifiers::TechnicalSpecification`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "TS" | Technical Specification | :published |  |
| "prTS" | Proposal Technical Specification | :proposal |  |

## URN Support

true

## Pre-parse Normalization

No normalization rules defined.
