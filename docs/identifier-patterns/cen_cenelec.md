# CEN_CENELEC Identifier Patterns

CEN_CENELEC identifiers

## Entry Point

```ruby
require 'pubid/cen_cenelec'
id = Pubid::Cen_cenelec.parse("...")
```

## Identifier Types

### Adopted European Norm

**Class:** `Pubid::Cen_cenelec::Identifiers::AdoptedEuropeanNorm`

### Amendment

**Class:** `Pubid::Cen_cenelec::Identifiers::Amendment`

### Base

**Class:** `Pubid::Cen_cenelec::Identifiers::Base`

### Cen Report

**Class:** `Pubid::Cen_cenelec::Identifiers::CenReport`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "CR" | CEN Report | :published |  |

### Cen Workshop Agreement

**Class:** `Pubid::Cen_cenelec::Identifiers::CenWorkshopAgreement`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "CWA" | CEN Workshop Agreement | :published |  |

### Cenelec Harmonization Document

**Class:** `Pubid::Cen_cenelec::Identifiers::CenelecHarmonizationDocument`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "HD" | CENELEC Harmonization Document | :published |  |

### Consolidated Identifier

**Class:** `Pubid::Cen_cenelec::Identifiers::ConsolidatedIdentifier`

### Corrigendum

**Class:** `Pubid::Cen_cenelec::Identifiers::Corrigendum`

### European Norm

**Class:** `Pubid::Cen_cenelec::Identifiers::EuropeanNorm`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "EN" | European Norm | :published |  |
| "pWI EN" | Preliminary Work Item EN | :preliminary |  |
| "prEN" | Proposal European Norm | :proposal |  |
| "FprEN" | Final Proposal European Norm | :final_proposal |  |
| "FV prEN" | Formal Vote EN | :formal_vote |  |
| "vEN" | Vote EN | :vote |  |
| "rvEN" | Review EN | :review |  |
| "racEN" | Re-activated EN | :reactivation |  |
| "wdEN" | Withdrawn EN | :withdrawn |  |

### European Prestandard

**Class:** `Pubid::Cen_cenelec::Identifiers::EuropeanPrestandard`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "ENV" | European Prestandard | :published |  |

### European Specification

**Class:** `Pubid::Cen_cenelec::Identifiers::EuropeanSpecification`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "ES" | European Specification | :published |  |

### Fragment

**Class:** `Pubid::Cen_cenelec::Identifiers::Fragment`

### Guide

**Class:** `Pubid::Cen_cenelec::Identifiers::Guide`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "Guide" | Guide | :published |  |

### Harmonization Document

**Class:** `Pubid::Cen_cenelec::Identifiers::HarmonizationDocument`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "HD" | Harmonization Document | :published |  |

### Technical Report

**Class:** `Pubid::Cen_cenelec::Identifiers::TechnicalReport`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "TR" | Technical Report | :published |  |

### Technical Specification

**Class:** `Pubid::Cen_cenelec::Identifiers::TechnicalSpecification`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "TS" | Technical Specification | :published |  |
| "prTS" | Proposal Technical Specification | :proposal |  |

## URN Support

true

## Pre-parse Normalization

No normalization rules defined.
