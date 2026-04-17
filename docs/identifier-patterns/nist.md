# NIST Identifier Patterns

NIST (National Institute of Standards and Technology)

## Entry Point

```ruby
require 'pubid/nist'
id = Pubid::Nist.parse("...")
```

## Identifier Types

### Base

**Class:** `Pubid::Nist::Identifiers::Base`

### Circular

**Class:** `Pubid::Nist::Identifiers::Circular`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "CIRC", "NBS CIRC" |  | published |  |

### Circular Supplement

**Class:** `Pubid::Nist::Identifiers::CircularSupplement`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "CIRC", "NBS CIRC" |  | published |  |

### Commercial Standard

**Class:** `Pubid::Nist::Identifiers::CommercialStandard`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "CS", "NBS CS" |  | published |  |

### Commercial Standard Emergency

**Class:** `Pubid::Nist::Identifiers::CommercialStandardEmergency`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "CS-E", "NBS CS-E" |  | published |  |

### Commercial Standards Monthly

**Class:** `Pubid::Nist::Identifiers::CommercialStandardsMonthly`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "CSM", "NBS CSM" |  | published |  |

### Crpl Report

**Class:** `Pubid::Nist::Identifiers::CrplReport`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "CRPL", "NBS CRPL", "CRPL-F-B", "CRPL-F-A", "NBS CRPL-F-B", "NBS CRPL-F-A" |  | published |  |

### Federal Information Processing Standards

**Class:** `Pubid::Nist::Identifiers::FederalInformationProcessingStandards`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "FIPS", "NIST FIPS" |  | published |  |

### Grant Contractor Report

**Class:** `Pubid::Nist::Identifiers::GrantContractorReport`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "GCR", "NIST GCR" |  | published |  |

### Handbook

**Class:** `Pubid::Nist::Identifiers::Handbook`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "HB", "NIST HB", "NBS HB" |  | published |  |

### Internal Report

**Class:** `Pubid::Nist::Identifiers::InternalReport`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "IR", "NIST IR", "NBS IR" |  | published |  |

### Letter Circular

**Class:** `Pubid::Nist::Identifiers::LetterCircular`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "LCIRC" |  | published |  |

### Miscellaneous Publication

**Class:** `Pubid::Nist::Identifiers::MiscellaneousPublication`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "MP", "NBS MP" |  | published |  |

### Monograph

**Class:** `Pubid::Nist::Identifiers::Monograph`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "MONO", "NBS MONO", "NIST MONO" |  | published |  |

### Ncstar

**Class:** `Pubid::Nist::Identifiers::Ncstar`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "NCSTAR", "NIST NCSTAR" |  | published |  |

### Nsrds

**Class:** `Pubid::Nist::Identifiers::Nsrds`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "NSRDS", "NBS NSRDS" |  | published |  |

### Owmwp

**Class:** `Pubid::Nist::Identifiers::Owmwp`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "OWMWP", "NIST OWMWP" |  | published |  |

### Report

**Class:** `Pubid::Nist::Identifiers::Report`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "RPT", "NBS RPT" |  | published |  |

### Special Publication

**Class:** `Pubid::Nist::Identifiers::SpecialPublication`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "SP", "NIST SP", "NBS SP" |  | published |  |

### Technical Note

**Class:** `Pubid::Nist::Identifiers::TechnicalNote`

#### Typed Stages

| Abbr | Name | Stage Code | Harmonized Codes |
|------|------|-----------|-----------------|
| "TN", "NIST TN", "NBS TN" |  | published |  |

## URN Support

true

## Pre-parse Normalization

See `data/nist/update_codes.yaml` for legacy format mappings.
