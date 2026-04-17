# BSI Identifier Patterns

BSI (British Standards Institution)

## Entry Point

```ruby
require 'pubid/bsi'
id = Pubid::Bsi.parse("...")
```

## Identifier Types

### Addendum Document

**Class:** `Pubid::Bsi::Identifiers::AddendumDocument`

### Adopted European Norm

**Class:** `Pubid::Bsi::Identifiers::AdoptedEuropeanNorm`

### Adopted International Standard

**Class:** `Pubid::Bsi::Identifiers::AdoptedInternationalStandard`

### Aerospace Standard

**Class:** `Pubid::Bsi::Identifiers::AerospaceStandard`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "BS" | Aerospace/Specialized Standard | :published |  |

### Amendment

**Class:** `Pubid::Bsi::Identifiers::Amendment`

### Base

**Class:** `Pubid::Bsi::Identifiers::Base`

### British Industrial Practice

**Class:** `Pubid::Bsi::Identifiers::BritishIndustrialPractice`

### British Standard

**Class:** `Pubid::Bsi::Identifiers::BritishStandard`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "BS" | British Standard | :published |  |
| "Draft BS", "DBS" | Draft British Standard | :draft |  |

### Bundled Identifier

**Class:** `Pubid::Bsi::Identifiers::BundledIdentifier`

### Committee Document

**Class:** `Pubid::Bsi::Identifiers::CommitteeDocument`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "DC" | Draft Committee Document | :draft |  |

### Consolidated Identifier

**Class:** `Pubid::Bsi::Identifiers::ConsolidatedIdentifier`

### Corrigendum

**Class:** `Pubid::Bsi::Identifiers::Corrigendum`

### Detailed Specification

**Class:** `Pubid::Bsi::Identifiers::DetailedSpecification`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "DETAILED SPEC" | Detailed Specification | :published |  |

### Disc

**Class:** `Pubid::Bsi::Identifiers::Disc`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "DISC" | DISC | :published |  |

### Draft Document

**Class:** `Pubid::Bsi::Identifiers::DraftDocument`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "DD" | Draft Document | :published |  |

### Electronic Book

**Class:** `Pubid::Bsi::Identifiers::ElectronicBook`

### Expert Commentary

**Class:** `Pubid::Bsi::Identifiers::ExpertCommentary`

### Explanatory Supplement

**Class:** `Pubid::Bsi::Identifiers::ExplanatorySupplement`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "BS" | Explanatory Supplement | :published |  |

### Flex

**Class:** `Pubid::Bsi::Identifiers::Flex`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "Flex", "BSI Flex" | BSI Flex | :published |  |

### Handbook

**Class:** `Pubid::Bsi::Identifiers::Handbook`

### Index

**Class:** `Pubid::Bsi::Identifiers::Index`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "Index" | Index | :published |  |

### Method

**Class:** `Pubid::Bsi::Identifiers::Method`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "Method", "Methods" | Method | :published |  |

### National Annex

**Class:** `Pubid::Bsi::Identifiers::NationalAnnex`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "NA" | National Annex | :published |  |

### Practice Guide

**Class:** `Pubid::Bsi::Identifiers::PracticeGuide`

### Publicly Available Specification

**Class:** `Pubid::Bsi::Identifiers::PubliclyAvailableSpecification`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "PAS" | Publicly Available Specification | :published |  |

### Published Document

**Class:** `Pubid::Bsi::Identifiers::PublishedDocument`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "PD" | Published Document | :published |  |

### Section

**Class:** `Pubid::Bsi::Identifiers::Section`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "Section" | Section | :published |  |

### Set

**Class:** `Pubid::Bsi::Identifiers::Set`

### Standalone Amendment

**Class:** `Pubid::Bsi::Identifiers::StandaloneAmendment`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "AMD" | Amendment | :published |  |

### Supplement Document

**Class:** `Pubid::Bsi::Identifiers::SupplementDocument`

### Supplementary Index

**Class:** `Pubid::Bsi::Identifiers::SupplementaryIndex`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "BS" | Supplementary Index | :published |  |

### Technical Specification

**Class:** `Pubid::Bsi::Identifiers::TechnicalSpecification`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "TS" | Technical Specification | :published |  |

### Test Method

**Class:** `Pubid::Bsi::Identifiers::TestMethod`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "BS" | Test Method | :published |  |

### Value Added Publication

**Class:** `Pubid::Bsi::Identifiers::ValueAddedPublication`

## URN Support

true

## Pre-parse Normalization

No normalization rules defined.
