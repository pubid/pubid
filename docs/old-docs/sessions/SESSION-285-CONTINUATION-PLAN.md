# Session 285 Continuation Plan: Comprehensive Multi-Flavor Enhancement

**Created:** 2026-01-07 (Post-Session 284)
**Status:** Ready for execution
**Timeline:** COMPRESSED - Complete all enhancements in ONE session (8-10 hours)
**Principle:** Architecture correctness > Test pass rate

---

## Executive Summary

**Session 284 completed V2 release preparation.** Session 285 will implement all identified post-release enhancements in a single comprehensive session:

1. **BSI ValueAddedPublication** - Architectural refactoring (wrapper pattern)
2. **CEN New Identifier Classes** - 4 new types (ES, CR, HD, ENV)
3. **SAE Flavor** - New 18th organization
4. **BSI New Identifier Classes** - 3 new types (Handbook, PracticeGuide, BritishIndustrialPractice)
5. **Extended Test Coverage** - 40+ new BSI test cases

**Total Impact:** +60-80 new identifier types, architectural consistency across all flavors

---

## Phase 1: BSI ValueAddedPublication Architecture (120 min)

### Objective
Replace boolean attributes (`pdf`, `tracked_changes`) with proper wrapper class following IEC VapIdentifier pattern.

### Current Architecture (INCORRECT)
```ruby
class SingleIdentifier
  attribute :pdf, :boolean
  attribute :tracked_changes, :boolean

  def to_s
    result += " - TC" if tracked_changes
    result += " PDF" if pdf
  end
end
```

### Target Architecture (CORRECT)
```ruby
class ValueAddedPublication < Base
  attribute :base_identifier, Base, polymorphic: true
  attribute :format, :string, values: ["PDF", "TC", "BOOK"]

  def to_s
    case format
    when "TC" then "#{base_identifier} - TC"
    when "PDF" then "#{base_identifier} PDF"
    when "BOOK" then "#{base_identifier} BOOK"
    end
  end
end
```

### Implementation Steps

#### Step 1.1: Create ValueAddedPublication Class (30 min)
**File:** `lib/pubid_new/bsi/identifiers/value_added_publication.rb`

```ruby
# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Bsi
    module Identifiers
      # Value-Added Publication Identifier
      # Wraps base identifier with format suffix (PDF, TC, BOOK)
      # Similar to IEC VapIdentifier and BSI ExpertCommentary
      class ValueAddedPublication < Base
        attribute :base_identifier, Base, polymorphic: true
        attribute :format, :string, values: ["PDF", "TC", "BOOK"]

        def to_s
          base_str = base_identifier.to_s

          case format
          when "TC"
            "#{base_str} - TC"
          when "PDF"
            "#{base_str} PDF"
          when "BOOK"
            "#{base_str} BOOK"
          end
        end

        # Delegate common attributes to base_identifier
        def publisher
          base_identifier&.publisher
        end

        def number
          base_identifier&.number
        end

        def year
          base_identifier&.year
        end

        def date
          base_identifier&.date
        end
      end
    end
  end
end
```

#### Step 1.2: Update Parser (20 min)
**File:** `lib/pubid_new/bsi/parser.rb`

Update to recognize PDF/TC/BOOK as wrapper identifiers, not attributes:
```ruby
# Change pdf_suffix to wrapper pattern
rule(:vap_suffix) do
  (
    space >> str("PDF").as(:pdf_format) |
    space >> str("-") >> space >> str("TC").as(:tc_format) |
    space >> str("BOOK").as(:book_format)
  )
end

# Update identifier rule to handle VAP wrapping
rule(:identifier) do
  vap_wrapped_identifier |
  expert_commentary_identifier |
  # ... other patterns
end

rule(:vap_wrapped_identifier) do
  base_identifier.as(:vap_base) >> vap_suffix
end
```

#### Step 1.3: Update Builder (30 min)
**File:** `lib/pubid_new/bsi/builder.rb`

```ruby
def build(parsed_hash)
  # Check for VAP wrapper first
  if parsed_hash[:pdf_format] || parsed_hash[:tc_format] || parsed_hash[:book_format]
    return build_value_added_publication(parsed_hash)
  end

  # ... existing logic
end

def build_value_added_publication(data)
  format = if data[:pdf_format]
    "PDF"
  elsif data[:tc_format]
    "TC"
  elsif data[:book_format]
    "BOOK"
  end

  base_id = build(data[:vap_base])

  Identifiers::ValueAddedPublication.new(
    base_identifier: base_id,
    format: format
  )
end
```

#### Step 1.4: Remove Boolean Attributes (10 min)
**File:** `lib/pubid_new/bsi/single_identifier.rb`

Remove:
```ruby
attribute :pdf, :boolean, default: -> { false }
attribute :tracked_changes, :boolean, default: -> { false }

# Remove from to_s:
result += " - TC" if tracked_changes
result += " PDF" if pdf
```

#### Step 1.5: Update Tests (30 min)
Update all tests expecting boolean attributes to use ValueAddedPublication wrapper.

**Expected Results:**
- `PD 5500:2018+A3:2020 PDF` → ValueAddedPublication with format="PDF"
- `PAS 96:2017 - TC` → ValueAddedPublication with format="TC"
- `PP 7722:2006 BOOK` → ValueAddedPublication with format="BOOK"

---

## Phase 2: CEN New Identifier Classes (90 min)

### Objective
Add 4 new CEN identifier types following MECE organization.

### New Classes

#### 2.1: EuropeanSpecification (ES) (20 min)
**File:** `lib/pubid_new/cen/identifiers/european_specification.rb`

```ruby
module PubidNew
  module Cen
    module Identifiers
      class EuropeanSpecification < SingleIdentifier
        def self.type
          {
            short: "ES",
            full: "European Specification"
          }
        end
      end
    end
  end
end
```

**Examples:**
- `ES 59008-6-1:1999`
- `ES 59008-6-1:1999 E`

#### 2.2: CenReport (CR) (20 min)
**File:** `lib/pubid_new/cen/identifiers/cen_report.rb`

```ruby
module PubidNew
  module Cen
    module Identifiers
      class CenReport < SingleIdentifier
        def self.type
          {
            short: "CR",
            full: "CEN Report"
          }
        end
      end
    end
  end
end
```

**Examples:**
- `CR 13933:2000`
- `CR 13933:2000 E`
- `CR R210-010:2002`

#### 2.3: CenelecHarmonizationDocument (HD) (20 min)
**File:** `lib/pubid_new/cen/identifiers/cenelec_harmonization_document.rb`

```ruby
module PubidNew
  module Cen
    module Identifiers
      class CenelecHarmonizationDocument < SingleIdentifier
        def self.type
          {
            short: "HD",
            full: "CENELEC Harmonization Document"
          }
        end
      end
    end
  end
end
```

**Examples:**
- `HD 384.7.711 S1:2003`
- `HD 384.7.711 S1:2003 E`

#### 2.4: EuropeanPrestandard (ENV) (20 min)
**File:** `lib/pubid_new/cen/identifiers/european_prestandard.rb`

```ruby
module PubidNew
  module Cen
    module Identifiers
      class EuropeanPrestandard < SingleIdentifier
        def self.type
          {
            short: "ENV",
            full: "European Prestandard"
          }
        end

        # May have ISO adoption
        attribute :adopted_identifier, PubidNew::Iso::Identifier, polymorphic: true

        def to_s
          if adopted_identifier
            "ENV #{adopted_identifier}"
          else
            super
          end
        end
      end
    end
  end
end
```

**Examples:**
- `ENV ISO 11079:1999`
- `ENV 41111:1991`
- `ENV 41111:1991 E`

#### 2.5: Update Parser & Builder (10 min)
Add recognition for ES, CR, HD, ENV prefixes in CEN parser and builder.

---

## Phase 3: SAE Flavor Implementation (120 min)

### Objective
Implement 18th flavor: Society of Automotive Engineers (SAE)

### Architecture
Follow established V2 MODEL-DRIVEN pattern:
- Parser (Parslet grammar)
- Builder (object construction)
- Components (Code, Date, Type)
- Identifiers (Standard base class + type-specific)

### Implementation

#### 3.1: Create SAE Directory Structure (10 min)
```
lib/pubid_new/sae/
├── sae.rb                    # Module entry point
├── parser.rb                 # Parslet grammar
├── builder.rb                # Object construction
├── identifier.rb             # Base class
├── single_identifier.rb      # Base documents
├── components/
│   ├── code.rb              # Number component
│   ├── date.rb              # Year component
│   └── type.rb              # Document type (AMS, AIR, etc.)
└── identifiers/
    └── base.rb              # Shared logic
```

#### 3.2: Implement Parser (40 min)
**File:** `lib/pubid_new/sae/parser.rb`

Pattern analysis from examples:
- `SAE AMS 7904F:2024` - Type: AMS, Number: 7904F, Year: 2024
- `SAE AIR 8466:2024` - Type: AIR, Number: 8466, Year: 2024
- `SAE AMS 2813G:2022` - Type: AMS, Number: 2813G, Year: 2022

```ruby
module PubidNew
  module Sae
    class Parser < Parslet::Parser
      rule(:space) { str(" ") }
      rule(:digit) { match("[0-9]") }
      rule(:letter) { match("[A-Z]") }

      # Publisher
      rule(:publisher) { str("SAE") }

      # Document types
      rule(:doc_type) do
        (
          str("AMS") |  # Aerospace Material Specification
          str("AIR") |  # Aerospace Information Report
          str("AS") |   # Aerospace Standard
          str("ARP") |  # Aerospace Recommended Practice
          str("MA")     # Material Advisory
        ).as(:type)
      end

      # Number with optional letter suffix
      rule(:number) do
        (digit.repeat(1) >> letter.repeat(0, 1)).as(:number)
      end

      # Year
      rule(:year) { digit.repeat(4, 4).as(:year) }

      # Date
      rule(:date) { str(":") >> year }

      # Main identifier
      rule(:identifier) do
        publisher >> space >> doc_type >> space >>
        number >> date.maybe
      end

      root(:identifier)
    end
  end
end
```

#### 3.3: Implement Builder (30 min)
**File:** `lib/pubid_new/sae/builder.rb`

Standard V2 builder pattern with component casting.

#### 3.4: Implement Components (20 min)
- Code component (handles number with letter suffix)
- Date component (year only)
- Type component (AMS, AIR, AS, ARP, MA)

#### 3.5: Implement Identifiers (20 min)
**File:** `lib/pubid_new/sae/identifiers/base.rb`

Standard base identifier with to_s rendering.

---

## Phase 4: BSI New Identifier Classes (90 min)

### Objective
Add 3 new BSI identifier types: Handbook, PracticeGuide, BritishIndustrialPractice

### 4.1: Handbook Class (25 min)
**File:** `lib/pubid_new/bsi/identifiers/handbook.rb`

```ruby
module PubidNew
  module Bsi
    module Identifiers
      class Handbook < Base
        attribute :number, Bsi::Components::Code
        attribute :date, Bsi::Components::Date

        def self.type
          {
            short: "Handbook",
            full: "BSI Handbook"
          }
        end

        def to_s
          result = "Handbook #{number}"
          result += ":#{date.year}" if date
          result
        end
      end
    end
  end
end
```

**Examples:**
- `Handbook 17:1963`
- `Handbook 3:1985`

### 4.2: PracticeGuide Class (25 min)
**File:** `lib/pubid_new/bsi/identifiers/practice_guide.rb`

```ruby
module PubidNew
  module Bsi
    module Identifiers
      class PracticeGuide < Base
        attribute :number, Bsi::Components::Code
        attribute :date, Bsi::Components::Date

        def self.type
          {
            short: "PP",
            full: "Published Practice"
          }
        end

        def to_s
          result = "PP #{number}"
          result += ":#{date.year}" if date
          result
        end
      end
    end
  end
end
```

**Examples:**
- `PP 888:1982`
- `PP 7307:1986`
- `PP 7722:2006` (can be wrapped in ValueAddedPublication)

### 4.3: BritishIndustrialPractice Class (25 min)
**File:** `lib/pubid_new/bsi/identifiers/british_industrial_practice.rb`

```ruby
module PubidNew
  module Bsi
    module Identifiers
      class BritishIndustrialPractice < Base
        attribute :number, Bsi::Components::Code
        attribute :date, Bsi::Components::Date

        def self.type
          {
            short: "BIP",
            full: "British Industrial Practice"
          }
        end

        def to_s
          result = "BIP #{number}"
          result += ":#{date.year}" if date
          result
        end
      end
    end
  end
end
```

**Examples:**
- `BIP 2225:2022`
- `BIP 0142:2014`
- `BIP 0009:2020` (can be wrapped in ValueAddedPublication with PDF)

### 4.4: Update Parser & Builder (15 min)
Add recognition for Handbook, PP, and BIP prefixes.

---

## Phase 5: Extended Test Coverage (60 min)

### Objective
Add 40+ new BSI test cases covering historical and edge cases.

### Test Categories

#### 5.1: Historical PD Documents (15 min)
```ruby
test_cases = [
  ["PD 572:1946"],
  ["PD 854a:1951"],
  ["PD 6166"],
  ["PD 6432-2:1969"],
  ["PD ISO/TR 10200:1990"],
  ["PD 0017:2001"],
  ["PD 6627:2001 Issue 3.1"],
  # ... more
]
```

#### 5.2: CWA and DISC Documents (10 min)
```ruby
test_cases = [
  ["CWA 13620-5:1999"],
  ["CWA 13849-3:2000"],
  ["DISC PD 2000-2:1997"],
  # ... more
]
```

#### 5.3: Extended Adopted Documents (15 min)
```ruby
test_cases = [
  ["PD ISO/TR 27929:2025"],
  ["PD CLC IEC/TS 62271-314:2025"],
  ["PD CEN ISO/TS 19166:2025 - TC"],
  ["PD ISO/IEC TS 18013-6:2025 - TC"],
  ["PD IEC TR 63400:2025"],
  ["PD IEC TS 62607-6-27:2025"],
  # ... more
]
```

#### 5.4: DD ENV Documents (10 min)
```ruby
test_cases = [
  ["DD ENV ISO 11079:1999"],
  ["DD ENV 41112:1991"],
  ["DD ENV 41511:1991"],
  # ... more
]
```

#### 5.5: New Identifier Types (10 min)
```ruby
test_cases = [
  ["Handbook 17:1963"],
  ["Handbook 3:1985"],
  ["PP 888:1982"],
  ["PP 7307:1986"],
  ["PP 7722:2006 BOOK"],
  ["BIP 2225:2022"],
  ["BIP 0142:2014"],
  ["BIP 0009:2020 (PDF)"],  # VAP wrapped
  # ... more
]
```

---

## Phase 6: Documentation Updates (30 min)

### 6.1: Update README.adoc (15 min)
Add sections for:
- SAE flavor
- BSI new identifier types
- CEN new identifier types
- ValueAddedPublication architecture

### 6.2: Create Session Summary (10 min)
Document Session 285 completion in memory bank.

### 6.3: Archive Temporary Docs (5 min)
Move Session 284 continuation plan to old-docs/sessions/.

---

## Phase 7: BSI Full Fixture Classification & Validation (60 min)

### Objective
Classify and validate all 1,854 BSI identifiers from `spec/fixtures/bsi/identifiers/full.txt`

### Background
BSI has comprehensive fixture set (1,854 identifiers) that needs validation after all architectural improvements.

### Implementation Steps

#### Step 7.1: Initial Classification (15 min)
```bash
cd spec/fixtures
ruby run_classify.rb bsi
```

**Analyze results:**
- Count passing identifiers
- Identify failure patterns
- Group failures by type

#### Step 7.2: Common Pattern Analysis (15 min)
Review failure types:
1. Missing identifier classes (should be caught by Phase 4)
2. Parser patterns not recognized
3. Builder construction issues
4. Rendering mismatches

**Document top 5 failure patterns with counts**

#### Step 7.3: Targeted Fixes (20 min)
Implement fixes for common patterns:
- Enhanced parser rules for edge cases
- Builder handling for special formats
- Component updates if needed

**Priority:** Fix patterns affecting 10+ identifiers first

#### Step 7.4: Re-classification & Validation (10 min)
```bash
cd spec/fixtures
ruby run_classify.rb bsi
```

**Expected Results:**
- **Baseline:** Unknown (need initial classification)
- **Target:** 90%+ (1,669+/1,854)
- **Stretch:** 95%+ (1,761+/1,854)

**Note:** Perfect 100% unlikely due to edge cases and data quality issues

### Success Metrics

**Minimum (85%):**
- 1,576+/1,854 identifiers passing
- All new identifier classes recognized
- ValueAddedPublication working

**Target (90%):**
- 1,669+/1,854 identifiers passing
- Common patterns handled
- Round-trip fidelity verified

**Stretch (95%):**
- 1,761+/1,854 identifiers passing
- Edge cases documented
- Known limitations catalogued

---

## Implementation Status Tracker

### Phase 1: BSI ValueAddedPublication
- [ ] Step 1.1: Create ValueAddedPublication class (30 min)
- [ ] Step 1.2: Update parser (20 min)
- [ ] Step 1.3: Update builder (30 min)
- [ ] Step 1.4: Remove boolean attributes (10 min)
- [ ] Step 1.5: Update tests (30 min)

### Phase 2: CEN New Classes
- [ ] Step 2.1: EuropeanSpecification (20 min)
- [ ] Step 2.2: CenReport (20 min)
- [ ] Step 2.3: CenelecHarmonizationDocument (20 min)
- [ ] Step 2.4: EuropeanPrestandard (20 min)
- [ ] Step 2.5: Update parser/builder (10 min)

### Phase 3: SAE Flavor
- [ ] Step 3.1: Directory structure (10 min)
- [ ] Step 3.2: Parser (40 min)
- [ ] Step 3.3: Builder (30 min)
- [ ] Step 3.4: Components (20 min)
- [ ] Step 3.5: Identifiers (20 min)

### Phase 4: BSI New Classes
- [ ] Step 4.1: Handbook (25 min)
- [ ] Step 4.2: PracticeGuide (25 min)
- [ ] Step 4.3: BritishIndustrialPractice (25 min)
- [ ] Step 4.4: Update parser/builder (15 min)

### Phase 5: Extended Tests
- [ ] Step 5.1: Historical PD (15 min)
- [ ] Step 5.2: CWA/DISC (10 min)
- [ ] Step 5.3: Extended adopted (15 min)
- [ ] Step 5.4: DD ENV (10 min)
- [ ] Step 5.5: New types (10 min)

### Phase 6: Documentation
- [ ] Step 6.1: Update README.adoc (15 min)
- [ ] Step 6.2: Session summary (10 min)
- [ ] Step 6.3: Archive docs (5 min)

### Phase 7: BSI Full Fixture Classification
- [ ] Step 7.1: Initial classification (15 min)
- [ ] Step 7.2: Failure pattern analysis (15 min)
- [ ] Step 7.3: Targeted fixes (20 min)
- [ ] Step 7.4: Re-classification & validation (10 min)

**Total Estimated Time:** 9-11 hours (compressed timeline)

---

## Success Criteria

### Minimum Success (80%)
- ✅ BSI ValueAddedPublication architecture implemented
- ✅ All new identifier classes created
- ✅ SAE flavor basic parsing working
- ✅ Core tests passing
- ✅ BSI classification at 85%+ (1,576+/1,854)

### Target Success (90%)
- ✅ All phases complete
- ✅ Extended test coverage added
- ✅ Documentation updated
- ✅ Zero architectural regressions
- ✅ BSI classification at 90%+ (1,669+/1,854)

### Stretch Success (100%)
- ✅ All tests passing
- ✅ Round-trip fidelity verified
- ✅ Performance optimized
- ✅ Complete documentation
- ✅ BSI classification at 95%+ (1,761+/1,854)

---

## Key Architectural Principles

**MAINTAIN throughout ALL work:**
1. **MODEL-DRIVEN** - Objects not strings, proper Lutaml::Model classes
2. **MECE** - Each identifier is one type, mutually exclusive
3. **Wrapper Pattern** - ValueAddedPublication, ExpertCommentary consistency
4. **Three-Layer** - Parser/Builder/Identifier independence
5. **Architecture correctness** - Test failures acceptable if architecture correct
6. **Open/Closed** - Easy to extend, hard to modify

**NEVER compromise architecture for test pass rate!**

---

## Files to Create

### BSI
1. `lib/pubid_new/bsi/identifiers/value_added_publication.rb`
2. `lib/pubid_new/bsi/identifiers/handbook.rb`
3. `lib/pubid_new/bsi/identifiers/practice_guide.rb`
4. `lib/pubid_new/bsi/identifiers/british_industrial_practice.rb`

### CEN
5. `lib/pubid_new/cen/identifiers/european_specification.rb`
6. `lib/pubid_new/cen/identifiers/cen_report.rb`
7. `lib/pubid_new/cen/identifiers/cenelec_harmonization_document.rb`
8. `lib/pubid_new/cen/identifiers/european_prestandard.rb`

### SAE
9. `lib/pubid_new/sae.rb`
10. `lib/pubid_new/sae/parser.rb`
11. `lib/pubid_new/sae/builder.rb`
12. `lib/pubid_new/sae/identifier.rb`
13. `lib/pubid_new/sae/single_identifier.rb`
14. `lib/pubid_new/sae/components/code.rb`
15. `lib/pubid_new/sae/components/date.rb`
16. `lib/pubid_new/sae/components/type.rb`
17. `lib/pubid_new/sae/identifiers/base.rb`

### Tests
18. `spec/pubid_new/sae/parser_spec.rb`
19. `spec/pubid_new/sae/identifier_spec.rb`
20. Update `spec/integration/bsi_spec.rb`
21. Update `spec/integration/cen_spec.rb`

---

## Next Immediate Steps (Session 285)

1. Read this continuation plan thoroughly
2. Begin Phase 1: BSI ValueAddedPublication (most critical)
3. Test after each step
4. Proceed through phases sequentially
5. Commit incrementally with semantic messages
6. Document as you go

---

**Created:** 2026-01-07
**Status:** Ready for execution
**Estimated Time:** 10 hours (compressed, all phases in one session)

**End Goal:** All post-release enhancements complete, 18 flavors production-ready! 🚀