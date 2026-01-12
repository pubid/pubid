# PubID BSI V2 Memory Bank Context

**Last Updated:** 2026-01-12

## Project Overview

PubID is a Ruby library for parsing and generating standard document identifiers.
The BSI (British Standards Institution) module implements identifier handling for
British Standards using a MODEL-DRIVEN architecture.

## Current Status (Session 297 Complete)

### Coverage
- **Overall Coverage:** 88.79% (1,402/1,579 patterns)
- **Test Suite:** 248 examples, 0 failures, 6 pending
- **Remaining:** 177 patterns (11.21%)

### Architecture

The BSI V2 implementation follows a MODEL-DRIVEN, three-layer architecture:

1. **Parser Layer** (`lib/pubid_new/bsi/parser.rb`)
   - Parses identifier strings into structured components
   - Uses typed stage detection to determine identifier types

2. **Builder Layer** (`lib/pubid_new/bsi/builder.rb`)
   - Constructs identifiers from components
   - Provides fluent interface for identifier creation

3. **Identifier Layer** (`lib/pubid_new/bsi/identifiers/`)
   - Individual identifier classes for each document type
   - Each class inherits from `PubidNew::Bsi::SingleIdentifier`
   - Implements type-specific serialization rules

### Implemented Identifier Classes (33 total)

Core Types:
- BritishStandard (default)
- PubliclyAvailableSpecification (PAS)
- PublishedDocument (PD)
- DraftDocument (DD)
- Handbook (HB)

Adoption Types:
- AdoptedEuropeanNorm (BS EN...)
- AdoptedInternationalStandard (BS ISO/IEC...)

Supplement Types:
- SupplementDocument (BS NUMBER:Supplement...)
- AddendumDocument (BS NUMBER:Addendum...)
- Amendment (+A1:...)
- Corrigendum (+C1:...)
- StandaloneAmendment (AMD 11015)

Special Types:
- NationalAnnex (NA to...)
- BundledIdentifier (BS X & Y)
- ValueAddedPublication (VAP wrapper)
- ConsolidatedIdentifier

New Types (Session 297):
- AerospaceStandard (A 1-20...)
- Index
- Method
- Section
- DISC
- DetailedSpecification
- CommitteeDocument
- TechnicalSpecification
- ExplanatorySupplement
- SupplementaryIndex
- TestMethod
- Set
- ElectronicBook
- Flex
- PracticeGuide
- BritishIndustrialPractice
- ExpertCommentary

## Known Limitations

### 1. Multi-Level Part/Subpart Parsing
- **Issue:** Parser cannot separate multi-level parts (e.g., BS 8888-2-1:2020)
- **Current Behavior:** Captures "2" as part, loses "-1" as subpart
- **Impact:** ~10-15 patterns
- **Workaround:** Use combined part value
- **Priority:** MEDIUM

### 2. CEN CR Type
- **Issue:** CEN parser missing CR (CEN Report) type
- **Affected:** DD/PD adoptions like DD CR 13933:2000
- **Impact:** ~100 patterns
- **Solution Required:** Add CenReport class to CEN parser
- **Priority:** HIGH

### 3. Standalone AMD Patterns
- **Issue:** AMD without base identifier not parsed
- **Affected:** Patterns like AMD 11015, AMD 16019
- **Priority:** LOW - Rare pattern

### 4. Not Implemented
- Issue (3 patterns)
- Tickit (3 patterns)

## Key Design Decisions

1. **PAS/PD/DD are TYPES, not publishers** - Publisher is always "BS"
2. **NationalAnnex wraps base_doc** - Delegates number, date, part, subpart
3. **TypedStage registry** - Maps abbreviations to identifier classes
4. **Original abbreviation preservation** - HB vs Handbook preserved via `original_abbr`
5. **Model-driven approach** - Each identifier type is a dedicated class
6. **Three-layer separation** - Parser → Builder → Identifier

## File Structure

```
lib/pubid_new/bsi/
├── bsi.rb                    # Main module
├── builder.rb                # Builder class
├── parser.rb                 # Parser class
├── scheme.rb                 # Scheme configuration
├── single_identifier.rb      # Base identifier class
├── components/               # Component classes
│   ├── code.rb
│   ├── date.rb
│   ├── publisher.rb
│   └── type.rb
└── identifiers/              # Identifier classes (33 files)
```

## Testing

- **Test Framework:** RSpec
- **Test Files:** `spec/pubid_new/bsi/`
- **Fixture Files:** `spec/fixtures/bsi/identifiers/`
- **Coverage Test:** `ruby test_bsi_full_coverage.rb` (if available)

## Session History

| Session | Coverage | Key Changes |
|---------|----------|-------------|
| 291 | 58.6% | Supplement/Addendum |
| 292 | 65.9% | Various types |
| 293 | 68.9% | ASTM, various |
| 294 | 78.7% | PAS/PD/DD/Handbook |
| 297 | 88.8% | Index/Method/Section/DISC/etc. |

## Next Steps

1. Fix CEN Parser (HIGH - unblocks ~100 patterns)
2. Handle Multi-Level Part/Subpart Parsing (MEDIUM - ~10 patterns)
3. Implement Issue and Tickit classes (LOW - 6 patterns)
4. Improve edge cases for Expert Commentary and complex bundle separators

## Commands

```bash
# Run integration tests
bundle exec rspec spec/pubid_new/bsi/

# Run specific identifier tests
bundle exec rspec spec/pubid_new/bsi/identifiers/

# Run linter
bundle exec rubocop -A --auto-gen-config
```
