# ISO Identifier Patterns

ISO (International Organization for Standardization)

## Entry Point

```ruby
require 'pubid/iso'
id = Pubid::Iso.parse("...")
```

## Identifier Types

### Addendum

**Class:** `Pubid::Iso::Identifiers::Addendum`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "PWI Add" | Proposed Work Item for Addendum | :proposal |  |
| "NP Add" | New Work Item Proposal for Addendum | :proposal |  |
| "AWI Add" | Approved Work Item for Addendum | :preliminary |  |
| "WD Add" | Working Draft for Addendum | :working_draft |  |
| "CD Add" | Committee Draft for Addendum | :cd |  |
| DAD | Draft Addendum | :dad |  |
| FDAD | Final Draft Addendum | :fdad |  |
| ADD | Addendum | :published |  |

### Amendment

**Class:** `Pubid::Iso::Identifiers::Amendment`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "PWI Amd" | Proposed Work Item for Amendment | :proposal |  |
| "NP Amd" | New Work Item Proposal for Amendment | :proposal |  |
| "AWI Amd" | Approved Work Item for Amendment | :preliminary |  |
| "WD Amd" | Working Draft for Amendment | :working_draft |  |
| "CD Amd" | Committee Draft for Amendment | :cd |  |
| "PDAM" |  | :cd |  |
| DAM | Draft Amendment | :damd |  |
| FDAM | Final Draft Amendment | :fdamd |  |
| "FPDAM" |  | :fdamd |  |
| "PRF Amd" | Proof Amendment | :prf |  |
| AMD | Amendment | :published |  |

### Base

**Class:** `Pubid::Iso::Identifiers::Base`

### Corrigendum

**Class:** `Pubid::Iso::Identifiers::Corrigendum`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "PWI Cor" | Proposed Work Item for Corrigendum | :proposal |  |
| "NP Cor" | New Work Item Proposal for Corrigendum | :proposal |  |
| "AWI Cor" | Approved Work Item for Corrigendum | :preliminary |  |
| "WD Cor" | Working Draft for Corrigendum | :working_draft |  |
| "CD Cor", "pDCOR" | Committee Draft for Corrigendum | :cd |  |
| DCOR | Draft Corrigendum | :dcor |  |
| FDCOR | Final Draft Corrigendum | :fdcor |  |
| "PRF Cor" | Proof Corrigendum | :prf |  |
| COR | Corrigendum | :published |  |

### Data

**Class:** `Pubid::Iso::Identifiers::Data`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "NP DATA" | New Work Item Proposal for Data | :np |  |
| "AWI DATA" | Approved Work Item for Data | :awi |  |
| "WD DATA" | Working Draft for Data | :wd |  |
| "CD DATA" | Committee Draft for Data | :cd |  |
| "D DATA" | Draft Data | :ddata |  |
| "PRF DATA" | Proof Data | :prf |  |
| "DATA" | Data | :published |  |

### Directives

**Class:** `Pubid::Iso::Identifiers::Directives`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| DIR | Directives | :published |  |

### Directives Supplement

**Class:** `Pubid::Iso::Identifiers::DirectivesSupplement`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "DIR SUP", "SUP", "Supplement" | Directives Supplement | :published |  |

### Extract

**Class:** `Pubid::Iso::Identifiers::Extract`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "Ext" | Extract | :published |  |

### Guide

**Class:** `Pubid::Iso::Identifiers::Guide`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "PWI Guide" | Proposed Work Item for International Standard | :pwi |  |
| "NP Guide", "NP GUIDE" | New Work Item Proposal for Guide | :np |  |
| "AWI Guide", "AWI GUIDE" | Approved Work Item for Guide | :awi |  |
| "WD Guide", "WD GUIDE" | Working Draft for Guide | :wd |  |
| "CD Guide", "CD GUIDE" | Committee Draft for Guide | :cd |  |
| "DGuide", "DGUIDE" | Draft Guide | :dguide |  |
| "FDGuide", "FD Guide", "FD GUIDE" | Final Draft Guide | :fdguide |  |
| "PRF Guide", "PRF GUIDE" | Proof Guide | :prf |  |
| "Guide", "GUIDE" | Published Guide | :published |  |

### International Standard

**Class:** `Pubid::Iso::Identifiers::InternationalStandard`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "DP" | Draft Proposal | :dp |  |
| "PWI" | Proposed Work Item for International Standard | :pwi |  |
| "NP", "NWIP" | New Work Item Proposal for International Standard | :np |  |
| "AWI" | Approved Work Item for International Standard | :awi |  |
| "WD" | Working Draft for International Standard | :wd |  |
| "preCD", "PreCD" | Pre-Committee Draft for International Standard | :pcd |  |
| "CD" | Committee Draft for International Standard | :cd |  |
| "DIS", "FPD" | Draft International Standard | :dis |  |
| "FCD" | Final Committee Draft for International Standard | :fcd |  |
| "FDIS" | Final Draft International Standard | :fdis |  |
| "PRF", "Fpr" | Proof International Standard | :prf |  |
| "", "IS" | International Standard | :published |  |
| "WDR" | Proposed for Withdrawal | :wdr |  |
| "WDA" | Withdrawal Approved | :wda |  |
| "WDAR" | Withdrawal Archived | :wdar |  |

### International Standardized Profile

**Class:** `Pubid::Iso::Identifiers::InternationalStandardizedProfile`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "PWI ISP" | Proposed Work Item for International Standardized Profile | :pwi |  |
| "NP ISP" | New Work Item Proposal for International Standardized Profile | :np |  |
| "AWI ISP" | Approved Work Item for International Standardized Profile | :awi |  |
| "WD ISP" | Working Draft for International Standardized Profile | :wd |  |
| "CD ISP" | Committee Draft for International Standardized Profile | :cd |  |
| "DISP" | Draft International Standardized Profile | :disp |  |
| "FDISP" | Final Draft International Standardized Profile | :fdis |  |
| "PRF ISP" | Proof International Standardized Profile | :prf |  |
| "ISP" | International Standardized Profile | :published |  |

### International Workshop Agreement

**Class:** `Pubid::Iso::Identifiers::InternationalWorkshopAgreement`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "PWI IWA" | Proposed Work Item for International Workshop Agreement | :np |  |
| "NP IWA" | New Work Item Proposal for International Workshop Agreement | :np |  |
| "AWI IWA" | Approved Work Item for International Workshop Agreement | :awi |  |
| "WD IWA" | Working Draft for International Workshop Agreement | :wd |  |
| "CD IWA" | Committee Draft for International Workshop Agreement | :cd |  |
| "DIWA" | Draft International Workshop Agreement | :diwa |  |
| "PRF IWA" | Proof International Workshop Agreement | :prf |  |
| "IWA" | International Workshop Agreement | :published |  |

### Pas

**Class:** `Pubid::Iso::Identifiers::Pas`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "PWI PAS" | Proposed Work Item for Publicly Available Specification | :pwi |  |
| "NP PAS" | New Work Item Proposal for Publicly Available Specification | :np |  |
| "AWI PAS" | Approved Work Item for Publicly Available Specification | :awi |  |
| "WD PAS" | Working Draft for Publicly Available Specification | :wd |  |
| "CD PAS" | Committee Draft for Publicly Available Specification | :cd |  |
| "DPAS" | Draft Publicly Available Specification | :dpas |  |
| "FDPAS" | Final Draft Publicly Available Specification | :final_draft |  |
| "PRF PAS" | Proof Publicly Available Specification | :prf |  |
| "PAS" | Publicly Available Specification | :published |  |

### Recommendation

**Class:** `Pubid::Iso::Identifiers::Recommendation`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "DP" | Draft Proposal | :np |  |
| "R" | Recommendation | :published |  |

### Supplement

**Class:** `Pubid::Iso::Identifiers::Supplement`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "NP Suppl" | New Work Item Proposal for Supplement | :np |  |
| "AWI Suppl" | Approved Work Item for Supplement | :awi |  |
| "WD Suppl" | Working Draft for Supplement | :wd |  |
| "CD Suppl" | Committee Draft for Supplement | :cd |  |
| "DSuppl" | Draft Supplement | :dsuppl |  |
| "FDSuppl", "FDIS Suppl" | Final Draft Supplement | :fdsuppl |  |
| "PRF Suppl" | Proof Supplement | :prf |  |
| "Suppl", "Suppl." | Supplement | :published |  |

### Tc Document

**Class:** `Pubid::Iso::Identifiers::TcDocument`

### Technical Report

**Class:** `Pubid::Iso::Identifiers::TechnicalReport`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "PWI TR" | Proposed Work Item for Technical Report | :pwi |  |
| "NP TR" | New Work Item Proposal for Technical Report | :np |  |
| "AWI TR" | Approved Work Item for Technical Report | :awi |  |
| "WD TR" | Working Draft Technical Report | :wd |  |
| "CD TR" | Committee Draft Technical Report | :cd |  |
| "PDTR" | Proposed Draft Technical Report | :cd |  |
| "DTR" | Draft Technical Report | :draft |  |
| "FDTR" | Final Draft Technical Report | :final_draft |  |
| "PRF TR" | Proof Technical Report | :prf |  |
| "TR" | Published Technical Report | :published |  |

### Technical Specification

**Class:** `Pubid::Iso::Identifiers::TechnicalSpecification`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "PWI TS" | Proposed Work Item for Technical Specification | :pwi |  |
| "NP TS" | New Work Item Proposal for Technical Specification | :np |  |
| "AWI TS" | Approved Work Item for Technical Specification | :awi |  |
| "WD TS" | Working Draft Technical Specification | :wd |  |
| "CD TS" | Committee Draft Technical Specification | :cd |  |
| "PDTS" | Proposed Draft Technical Specification | :cd |  |
| "DTS" | Draft Technical Specification | :dts |  |
| "FDTS" | Final Draft Technical Specification | :fdts |  |
| "PRF TS" | Proof Technical Specification | :prf |  |
| "TS" | Published Technical Specification | :published |  |

### Technology Trends Assessments

**Class:** `Pubid::Iso::Identifiers::TechnologyTrendsAssessments`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "PWI TTA" | Proposed Work Item for Technology Trends Assessments | :pwi |  |
| "NP TTA" | New Work Item Proposal for Technology Trends Assessments | :np |  |
| "AWI TTA" | Approved Work Item for Technology Trends Assessments | :awi |  |
| "WD TTA" | Working Draft for Technology Trends Assessments | :wd |  |
| "CD TTA" | Committee Draft for Technology Trends Assessments | :cd |  |
| "DTTA" | Draft Technology Trends Assessments | :draft |  |
| "FDTTA" | Final Draft Technology Trends Assessments | :final_draft |  |
| "PRF TTA" | Proof Technology Trends Assessments | :prf |  |
| "TTA" | Published Technology Trends Assessments | :published |  |

## URN Support

true

## Pre-parse Normalization

See `data/iso/update_codes.yaml` for legacy format mappings.
