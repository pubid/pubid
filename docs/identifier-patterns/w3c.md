# W3C Identifier Patterns

W3C identifiers

## Entry Point

```ruby
require 'pubid/w3c'
id = Pubid::W3c.parse("...")
```

## Identifier Types

### Candidate Recommendation

**Class:** `Pubid::W3c::Identifiers::CandidateRecommendation`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "CR" | Candidate Recommendation | :candidate_recommendation |  |

### Candidate Recommendation Draft

**Class:** `Pubid::W3c::Identifiers::CandidateRecommendationDraft`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "CRD" | Candidate Recommendation Draft | :candidate_recommendation_draft |  |

### Draft Note

**Class:** `Pubid::W3c::Identifiers::DraftNote`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "DNOTE" | Draft W3C Note | :draft_note |  |

### Note

**Class:** `Pubid::W3c::Identifiers::Note`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "NOTE" | W3C Note | :note |  |

### Obsolete Recommendation

**Class:** `Pubid::W3c::Identifiers::ObsoleteRecommendation`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "OBSL" | Obsolete Recommendation | :obsolete_recommendation |  |

### Proposed Edited Recommendation

**Class:** `Pubid::W3c::Identifiers::ProposedEditedRecommendation`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "PER" | Proposed Edited Recommendation | :proposed_edited_recommendation |  |

### Proposed Recommendation

**Class:** `Pubid::W3c::Identifiers::ProposedRecommendation`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "PR" | Proposed Recommendation | :proposed_recommendation |  |

### Recommendation

**Class:** `Pubid::W3c::Identifiers::Recommendation`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "REC" | Recommendation | :recommendation |  |

### Standard

**Class:** `Pubid::W3c::Identifiers::Standard`

### Superseded Recommendation

**Class:** `Pubid::W3c::Identifiers::SupersededRecommendation`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "SPSD" | Superseded Recommendation | :superseded_recommendation |  |

### Working Draft

**Class:** `Pubid::W3c::Identifiers::WorkingDraft`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "WD" | Working Draft | :working_draft |  |

## URN Support

true

## Pre-parse Normalization

No normalization rules defined.
