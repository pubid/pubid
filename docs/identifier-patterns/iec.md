# IEC Identifier Patterns

IEC (International Electrotechnical Commission)

## Entry Point

```ruby
require 'pubid/iec'
id = Pubid::Iec.parse("...")
```

## Identifier Types

### Amendment

**Class:** `Pubid::Iec::Identifiers::Amendment`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "PWI Amd" | Preliminary Work Item Amendment | :pwi |  |
| "NP Amd" | New Proposal Amendment | :np |  |
| "ANW Amd" | Approved New Work Item Amendment | :anw |  |
| "WD Amd" | Working Draft Amendment | :wd |  |
| CDV | Committee Draft Amendment | :cd |  |
| DAM | Draft Amendment | :damd |  |
| FDIS | Final Draft Amendment | :fdamd |  |
| AMD | Amendment | :published |  |

### Base

**Class:** `Pubid::Iec::Identifiers::Base`

### Component Specification

**Class:** `Pubid::Iec::Identifiers::ComponentSpecification`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "CS" | Component Specification | :published |  |

### Conformity Assessment

**Class:** `Pubid::Iec::Identifiers::ConformityAssessment`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "CA" | Conformity Assessment | :published |  |

### Consolidated Identifier

**Class:** `Pubid::Iec::Identifiers::ConsolidatedIdentifier`

### Corrigendum

**Class:** `Pubid::Iec::Identifiers::Corrigendum`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "PWI Cor" | Preliminary Work Item Corrigendum | :pwi |  |
| "NP Cor" | New Proposal Corrigendum | :np |  |
| "ANW Cor" | Approved New Work Item Corrigendum | :anw |  |
| "WDCor" | Working Draft Corrigendum | :wd |  |
| CDCor | Committee Draft Corrigendum | :cd |  |
| DCOR | Draft Corrigendum | :dcor |  |
| FDCOR | Final Draft Corrigendum | :fdcor |  |
| COR | Corrigendum | :published |  |

### Fragment Identifier

**Class:** `Pubid::Iec::Identifiers::FragmentIdentifier`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "PWI Frag" | Preliminary Work Item Fragment | :pwi |  |
| "NP Frag" | New Proposal Fragment | :np |  |
| "ANW Frag" | Approved New Work Item Fragment | :anw |  |
| "WD Frag" | Working Draft Fragment | :wd |  |
| "CDFRAG" | Committee Draft Fragment | :cd |  |
| "DFRAG" | Draft Fragment | :dfrag |  |
| "FDFRAG", "PRF Frag" | Final Draft Fragment | :fdfrag |  |
| "FRAG" | Fragment | :published |  |

### Guide

**Class:** `Pubid::Iec::Identifiers::Guide`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "PWI Guide" | Preliminary Work Item Guide | :pwi |  |
| "NP Guide" | New Proposal Guide | :np |  |
| "ANW Guide" | Approved New Work Item Guide | :anw |  |
| "WD Guide" | Working Draft Guide | :wd |  |
| "CD Guide" | Committee Draft Guide | :cd |  |
| "DGuide" | Draft Guide | :draft |  |
| "FDGuide", "PRF Guide" | Final Draft Guide | :final_draft |  |
| "GUIDE", "Guide" | Guide | :published |  |

### International Standard

**Class:** `Pubid::Iec::Identifiers::InternationalStandard`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "PWI" | Preliminary Work Item | :pwi |  |
| "NP" | New Proposal | :np |  |
| "ANW" | Approved New Work Item | :anw |  |
| "WD" | Working Draft | :wd |  |
| "CD" | Committee Draft | :cd |  |
| "CDV" | Committee Draft for Vote | :cdv |  |
| "FDIS", "PRF" | Final Draft International Standard | :fdis |  |
| "" | International Standard | :published |  |

### Interpretation Sheet

**Class:** `Pubid::Iec::Identifiers::InterpretationSheet`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "PWI ISH" | Preliminary Work Item Interpretation Sheet | :pwi |  |
| "NP ISH" | New Proposal Interpretation Sheet | :np |  |
| "ANW ISH" | Approved New Work Item Interpretation Sheet | :anw |  |
| "WD ISH" | Working Draft Interpretation Sheet | :wd |  |
| "CDISH" | Committee Draft Interpretation Sheet | :cd |  |
| "DISH" | Draft Interpretation Sheet | :draft |  |
| "ISH" | Interpretation Sheet | :published |  |

### Operational Document

**Class:** `Pubid::Iec::Identifiers::OperationalDocument`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "OD" | Operational Document | :published |  |

### Publicly Available Specification

**Class:** `Pubid::Iec::Identifiers::PubliclyAvailableSpecification`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "PWI PAS" | Preliminary Work Item Publicly Available Specification | :pwi |  |
| "NP PAS" | New Proposal Publicly Available Specification | :np |  |
| "ANW PAS" | Approved New Work Item Publicly Available Specification | :anw |  |
| "WD PAS" | Working Draft Publicly Available Specification | :wd |  |
| "CDPAS" | Committee Draft Publicly Available Specification | :cd |  |
| "DPAS" | Draft Publicly Available Specification | :draft |  |
| "PAS" | Publicly Available Specification | :published |  |

### Sheet Identifier

**Class:** `Pubid::Iec::Identifiers::SheetIdentifier`

### Societal Technology Trend Report

**Class:** `Pubid::Iec::Identifiers::SocietalTechnologyTrendReport`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "Trend Report" | Societal and Technology Trend Report | :published |  |

### Systems Reference Document

**Class:** `Pubid::Iec::Identifiers::SystemsReferenceDocument`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "SRD" | Systems Reference Document | :published |  |

### Technical Report

**Class:** `Pubid::Iec::Identifiers::TechnicalReport`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "PWI TR" | Preliminary Work Item Technical Report | :pwi |  |
| "NP TR" | New Proposal Technical Report | :np |  |
| "ANW TR" | Approved New Work Item Technical Report | :anw |  |
| "WD TR" | Working Draft Technical Report | :wd |  |
| "CD TR" | Committee Draft Technical Report | :cd |  |
| "DTR" | Draft Technical Report | :draft |  |
| "TR" | Technical Report | :published |  |

### Technical Specification

**Class:** `Pubid::Iec::Identifiers::TechnicalSpecification`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "PWI TS" | Preliminary Work Item Technical Specification | :pwi |  |
| "NP TS" | New Proposal Technical Specification | :np |  |
| "ANW TS" | Approved New Work Item Technical Specification | :anw |  |
| "WD TS" | Working Draft Technical Specification | :wd |  |
| "CD TS" | Committee Draft Technical Specification | :cd |  |
| "DTS" | Draft Technical Specification | :draft |  |
| "TS" | Technical Specification | :published |  |

### Technology Report

**Class:** `Pubid::Iec::Identifiers::TechnologyReport`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "Technology Report" | Technology Report | :published |  |

### Test Report Form

**Class:** `Pubid::Iec::Identifiers::TestReportForm`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "TRF" | Test Report Form | :published |  |

### Vap Identifier

**Class:** `Pubid::Iec::Identifiers::VapIdentifier`

### White Paper

**Class:** `Pubid::Iec::Identifiers::WhitePaper`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "White Paper" | White Paper | :published |  |

### Working Document

**Class:** `Pubid::Iec::Identifiers::WorkingDocument`

## URN Support

true

## Pre-parse Normalization

See `data/iec/update_codes.yaml` for legacy format mappings.
