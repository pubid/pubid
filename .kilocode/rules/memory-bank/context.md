# PubID Memory Bank Context

**Last Updated:** 2026-01-13

## Project Overview

PubID is a Ruby library for parsing and generating standard document identifiers.
The library supports multiple standards organizations with MODEL-DRIVEN architecture:
- **BSI** (British Standards Institution) - British Standards
- **NIST** (National Institute of Standards and Technology) - NIST/NBS Publications
- **CEN** (European Committee for Standardization) - European Standards
- **IEEE** (Institute of Electrical and Electronics Engineers) - IEEE Standards

---

## BSI Module Status (Session 297 Complete)

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

---

## NIST Module Status (Session 298 Complete)

### Coverage
- **All Records:** 14,494/19,488 (74.37%)
- **Publication Exports:** 727/764 (95.16%) ✅ Target met!
- **Unit Tests:** 901 examples, 267 failures, 3 pending
- **Component Tests:** 130/130 passing (100%)

### Architecture

The NIST V2 implementation follows a MODEL-DRIVEN, three-layer architecture:

1. **Parser Layer** (`lib/pubid_new/nist/parser.rb`)
   - Parses identifier strings into structured components
   - Uses Parslet parser combinators for flexible pattern matching
   - Handles historical NBS formats and modern NIST formats

2. **Builder Layer** (`lib/pubid_new/nist/builder.rb`)
   - Constructs identifiers from parsed components
   - Maps parser output to identifier classes

3. **Identifier Layer** (`lib/pubid_new/nist/identifiers/`)
   - Individual identifier classes for each document type
   - Each class inherits from `PubidNew::Nist::Identifiers::Base`
   - Implements multi-format rendering (short, mr, full, abbrev)

### Implemented Components

- **Stage** - Publication stage codes (ipd, fpd, wd, etc.)
- **Translation** - Language codes (chi, spa, por, etc.)
- **Edition** - Edition numbers, years, revisions with format preservation
- **Update** - Errata updates with number, year, month
- **Supplement** - Supplement notation (supp2, suppJan1924, etc.)
- **Version** - Version numbers (v1.1, ver2.0)
- **Part** - Part notation (pt1, p1)
- **Volume** - Volume notation (v1)
- **Publisher** - Series publisher (NBS/NIST)
- **Code** - Series and number components

### Key Achievements (Session 298)

1. **Revision Format Preservation** - "Rev. 5" format preserved (not normalized to "r5")
2. **Edition Year Normalization** - Patterns like "11-1911" → "11e1911" working
3. **Version Normalization** - Patterns like "Ver. 2.0" → "ver2.0" consistent
4. **Tier 1 Features** - Stage, Translation, Multi-Format rendering (77/77 tests passing)
5. **Tier 2 Features** - Update, Supplement components (53/53 tests passing)

### Known Limitations

1. **Supplement Integration** - Supplement component exists but not integrated into parser/builder
   - Impact: ~50-100 patterns dropping supplement notation
   - Status: Component complete, needs builder integration

2. **Part Notation** - Parser doesn't consistently capture part numbers
   - Pattern: "-1" being dropped in "800-63-1"
   - Impact: ~50-100 patterns
   - Status: Needs parser enhancement

3. **Update Feature** - Update component exists but not integrated
   - Impact: September 2024 tests (0% pass rate - 96/96 failures)
   - Status: Component complete, needs parser/builder integration

4. **Multi-Edition with Year** - Loses edition number in patterns like "11e2-1915"
   - Impact: ~15 patterns
   - Status: Documented limitation, requires separate parser enhancement

5. **Letter Suffix Case** - Parser normalizes to uppercase ("3a" → "3A")
   - Impact: ~10-20 patterns
   - Status: Acceptable per V2 design

### File Structure

```
lib/pubid_new/nist/
├── nist.rb                    # Main module
├── builder.rb                 # Builder class
├── parser.rb                  # Parser class (Parslet)
├── scheme.rb                  # Scheme configuration
├── components/                # Component classes
│   ├── code.rb
│   ├── date.rb
│   ├── edition.rb             # Edition with format preservation
│   ├── issue_number.rb
│   ├── part.rb
│   ├── publisher.rb
│   ├── stage.rb               # Stage component (NEW)
│   ├── supplement.rb          # Supplement component (NEW)
│   ├── translation.rb         # Translation component (NEW)
│   ├── update.rb              # Update component (NEW)
│   ├── version.rb
│   └── volume.rb
└── identifiers/               # Identifier classes
    ├── base.rb                # Base identifier class
    ├── special_publication.rb
    ├── federal_information_processing_standards.rb
    ├── internal_report.rb
    ├── handbook.rb
    ├── technical_note.rb
    └── ... (20+ identifier classes)
```

### Test Files Created (Session 298)

- `spec/pubid_new/nist/components/stage_spec.rb` (29 tests)
- `spec/pubid_new/nist/components/translation_spec.rb` (24 tests)
- `spec/pubid_new/nist/components/update_spec.rb` (23 tests)
- `spec/pubid_new/nist/components/supplement_spec.rb` (30 tests)
- `spec/pubid_new/nist/multi_format_rendering_spec.rb` (24 tests)

### Documentation

- `docs/NIST-BASELINE-RESULTS.md` - Complete baseline and task results

### Next Steps (NIST)

1. Integrate Supplement component into parser/builder (HIGH - ~50-100 patterns)
2. Integrate Update component into parser/builder (HIGH - 96 patterns)
3. Enhance part notation parsing (MEDIUM - ~50-100 patterns)
4. Handle multi-edition with year patterns (LOW - ~15 patterns)

---

## Commands

### BSI Commands
```bash
# Run integration tests
bundle exec rspec spec/pubid_new/bsi/

# Run specific identifier tests
bundle exec rspec spec/pubid_new/bsi/identifiers/
```

### NIST Commands
```bash
# Run integration tests
bundle exec rspec spec/integration/nist_spec.rb

# Run unit tests
bundle exec rspec spec/pubid_new/nist/

# Run specific component tests
bundle exec rspec spec/pubid_new/nist/components/
```

### Common Commands
```bash
# Run linter
bundle exec rubocop -A --auto-gen-config

# Run all tests
bundle exec rspec
```
