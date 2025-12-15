# Session 143 Continuation Plan: ASTM Flavor Implementation (16th Flavor!)

**Created:** 2025-12-15 (Post-Session 142 Correction)
**Status:** Session 142 corrected - Ready for ASTM implementation
**Timeline:** COMPRESSED - Complete in 90-120 minutes
**Priority:** Complete ASTM as 16th production-ready flavor

---

## Executive Summary

**Session 142 Correction Complete:**
- ✅ Reverted incorrect SI/PSI implementation
- ✅ Understanding: IEEE/ASTM SI/PSI are just regular IEEE/ASTM copublished standards
- ✅ ASTM already recognized as IEEE copublisher

**ASTM Flavor Ready for Implementation:**
- 289 identifiers analyzed
- 8 distinct identifier types (MECE)
- Clean V2 architecture design prepared

---

## ASTM Architecture Design (MECE)

### 8 Identifier Classes

1. **Standard** (76/289 = 26%) - DEFAULT class
   - Pattern: Letter A-G + Number + Year
   - Examples: `ASTM E2938-15(2023)`, `ASTM F1862/F1862M-17`
   - Features: Dual unit (metric M suffix), reapproval year, editorial (e1)

2. **WorkInProgress** (3/289 = 1%)
   - Pattern: WK + Number
   - Examples: `ASTM WK91249`, `ASTM WK95199`

3. **Adjunct** (4/289 = 1%)
   - Pattern: ADJ + Code OR just Code with ADJ prefix
   - Examples: `ASTM ADJD2148`, `ADJF3504-EA`

4. **TechnicalReport** (11/289 = 4%)
   - Pattern: TR + Number + -EB OR ISO/ASTMTR + Number + -EB
   - Examples: `TR1-EB`, `ISO/ASTMTR52916-EB`

5. **Manual** (75/289 = 26%)
   - Pattern: MNL + Number + Edition + -EB
   - Examples: `ASTM MNL1-9TH-EB`, `ASTM MNL20-2ND-SUP-EB`

6. **Monograph** (10/289 = 3%)
   - Pattern: MONO + Number + Edition + -EB
   - Examples: `ASTM MONO1-EB`, `ASTM MONO12-4TH-EB`

7. **DataSeries** (33/289 = 11%)
   - Pattern: DS + Code + -EB
   - Examples: `ASTM DS4B-EB`, `ASTM DS55S10-EB`

8. **ResearchReport** (59/289 = 20%)
   - Pattern: RR: + Committee + Dash + Number
   - Examples: `ASTM RR:A01-1001`, `ASTM RR:C09-2005`

### Three-Layer Architecture

```
Input: "ASTM E2938-15(2023)"
    ↓
Parser (Syntax) → {publisher: "ASTM", letter: "E", number: "2938", year: "15", reapproval: "2023"}
    ↓
Builder (Objects) → Standard.new(letter: "E", number: "2938", year: "15", reapproval: "2023")
    ↓
Identifier (Logic) → identifier.to_s => "ASTM E2938-15(2023)"
```

---

## Implementation Plan (COMPRESSED - 90-120 min)

### Phase 1: Core Files (40 min)

**Step 1.1: Module Loader (5 min)**
File: `lib/pubid_new/astm.rb`
```ruby
require_relative "astm/identifier"

module PubidNew
  module Astm
    def self.parse(input)
      Identifier.parse(input)
    end
  end
end
```

**Step 1.2: Base Identifier (10 min)**
File: `lib/pubid_new/astm/identifier.rb`
- Inherit from PubidNew::Identifier
- Implement parse() class method
- Define ASTM-specific constants

**Step 1.3: Parser (15 min)**
File: `lib/pubid_new/astm/parser.rb`
- Parslet grammar with 8 distinct patterns
- Priority order: ResearchReport (colon), WorkInProgress (WK), Adjunct (ADJ),
  Manual (MNL), Monograph (MONO), DataSeries (DS), TechnicalReport (TR),
  Standard (letter A-G) - DEFAULT last

**Step 1.4: Builder (10 min)**
File: `lib/pubid_new/astm/builder.rb`
- Route to correct class based on pattern
- Extract components (code, dual_unit, edition, etc.)

### Phase 2: Identifier Classes (30 min)

**Step 2.1: SingleIdentifier Base (5 min)**
File: `lib/pubid_new/astm/single_identifier.rb`
- Base class for all 8 types
- Common attributes: publisher, code, year

**Step 2.2: Standard Class (10 min)**
File: `lib/pubid_new/astm/identifiers/standard.rb`
- Attributes: letter, number, year, sub_year, dual_unit, reapproval, editorial
- Rendering: `ASTM {letter}{number}-{year}{sub_year}({reapproval}){editorial}`

**Step 2.3: Remaining 7 Classes (15 min)**
Files: `lib/pubid_new/astm/identifiers/{work_in_progress,adjunct,technical_report,manual,monograph,data_series,research_report}.rb`
- Each class with specific attributes and rendering
- Follow MECE principles

### Phase 3: Components (10 min)

**Step 3.1: Code Component (5 min)**
File: `lib/pubid_new/astm/components/code.rb`
- For letter+number patterns (E2938, F1862)

**Step 3.2: DualUnit Component (5 min)**
File: `lib/pubid_new/astm/components/dual_unit.rb`
- For metric designations (F1862M)

### Phase 4: Testing (15 min)

**Step 4.1: Unit Tests (10 min)**
File: `spec/pubid_new/astm/identifier_spec.rb`
- Test 2-3 examples from each of 8 types
- Total: ~20 test cases

**Step 4.2: Integration Test (5 min)**
- Parse all 289 fixtures
- Document pass rate

### Phase 5: Documentation (15 min)

**Step 5.1: Update README.adoc (10 min)**
- Add ASTM section with all 8 types
- Usage examples

**Step 5.2: Update Memory Bank (5 min)**
- Add Session 143 completion entry
- Update project status to 16/16 flavors

---

## Implementation Status Tracker

| Phase | Task | File | Duration | Status |
|-------|------|------|----------|--------|
| 1.1 | Module loader | astm.rb | 5 min | ⏳ |
| 1.2 | Base identifier | identifier.rb | 10 min | ⏳ |
| 1.3 | Parser | parser.rb | 15 min | ⏳ |
| 1.4 | Builder | builder.rb | 10 min | ⏳ |
| 2.1 | SingleIdentifier | single_identifier.rb | 5 min | ⏳ |
| 2.2 | Standard | identifiers/standard.rb | 10 min | ⏳ |
| 2.3 | 7 classes | identifiers/*.rb | 15 min | ⏳ |
| 3.1 | Code | components/code.rb | 5 min | ⏳ |
| 3.2 | DualUnit | components/dual_unit.rb | 5 min | ⏳ |
| 4.1 | Unit tests | spec/*.rb | 10 min | ⏳ |
| 4.2 | Integration | - | 5 min | ⏳ |
| 5.1 | README | README.adoc | 10 min | ⏳ |
| 5.2 | Memory bank | context.md | 5 min | ⏳ |
| **Total** | **All tasks** | - | **105 min** | **0%** |

---

## Critical Implementation Details

### Parser Pattern Priority (Longest First)

```ruby
rule(:identifier) do
  research_report |      # RR: (has colon - most specific)
  work_in_progress |     # WK prefix
  adjunct |              # ADJ prefix
  manual |               # MNL prefix
  monograph |            # MONO prefix
  data_series |          # DS prefix
  technical_report |     # TR prefix or ISO/ASTMTR
  standard               # Letter A-G (DEFAULT, least specific)
end
```

### Standard Pattern Details

```ruby
rule(:standard) do
  (str("ASTM") >> space).maybe.as(:publisher) >>
  match("[A-G]").as(:letter) >>
  digits.as(:number) >>
  (slash >> match("[A-G]") >> digits >> str("M")).maybe.as(:dual_unit) >>
  (dash >> digit.repeat(2,2).as(:year)) >>  # 2-digit year
  match("[a-z]").maybe.as(:sub_year) >>      # a, b, c
  (str("(") >> digit.repeat(4,4).as(:reapproval) >> str(")")).maybe >>
  (str("e") >> digits).maybe.as(:editorial) >>
  (dash >> str("EB")).maybe  # Format suffix (optional)
end
```

### Research Report Pattern

```ruby
rule(:research_report) do
  (str("ASTM") >> space).maybe >>
  str("RR:").as(:type) >>
  match("[A-Z]") >> digit.repeat(2,2) >>  # Committee code
  dash >>
  digits.as(:number)
end
```

---

## Success Criteria

### Minimum (80%)
- ✅ 8 identifier classes created
- ✅ Parser handles Standard (76 IDs)
- ✅ Builder routes correctly
- ✅ 16/20 test cases passing
- ✅ 230+/289 fixtures parsing (80%+)

### Target (90%)
- ✅ All 8 types working
- ✅ Dual unit support
- ✅ Editorial variations
- ✅ 18/20 test cases passing
- ✅ 260+/289 fixtures parsing (90%+)

### Stretch (95%+)
- ✅ All patterns working
- ✅ Edge cases handled
- ✅ 20/20 test cases passing
- ✅ 275+/289 fixtures parsing (95%+)

---

## Key Architectural Principles

**MAINTAIN throughout:**
1. **MODEL-DRIVEN** - Objects not strings
2. **MECE** - 8 mutually exclusive classes
3. **Three-layer** - Parser/Builder/Identifier separation
4. **Component-based** - Reusable Code, DualUnit
5. **Default class** - Standard handles A-G prefixes

---

## Files to Create

### Core (4 files)
1. `lib/pubid_new/astm.rb`
2. `lib/pubid_new/astm/identifier.rb`
3. `lib/pubid_new/astm/parser.rb`
4. `lib/pubid_new/astm/builder.rb`

### Base (1 file)
5. `lib/pubid_new/astm/single_identifier.rb`

### Identifiers (8 files)
6. `lib/pubid_new/astm/identifiers/standard.rb`
7. `lib/pubid_new/astm/identifiers/work_in_progress.rb`
8. `lib/pubid_new/astm/identifiers/adjunct.rb`
9. `lib/pubid_new/astm/identifiers/technical_report.rb`
10. `lib/pubid_new/astm/identifiers/manual.rb`
11. `lib/pubid_new/astm/identifiers/monograph.rb`
12. `lib/pubid_new/astm/identifiers/data_series.rb`
13. `lib/pubid_new/astm/identifiers/research_report.rb`

### Components (2 files)
14. `lib/pubid_new/astm/components/code.rb`
15. `lib/pubid_new/astm/components/dual_unit.rb`

### Tests (1 file)
16. `spec/pubid_new/astm/identifier_spec.rb`

**Total:** 16 new files

---

## Next Immediate Steps (Session 143)

1. Create `lib/pubid_new/astm.rb` module loader
2. Create `lib/pubid_new/astm/parser.rb` with 8 patterns
3. Create `lib/pubid_new/astm/builder.rb` with routing
4. Create `lib/pubid_new/astm/identifier.rb` base class
5. Create all 8 identifier classes
6. Create 2 component classes
7. Create test file with 20 test cases
8. Run tests and validate
9. Update README.adoc
10. Update memory bank

---

**Created:** 2025-12-15
**Status:** Ready for Session 143 execution
**Estimated Time:** 90-120 minutes (compressed)
**End Goal:** ASTM as 16th production-ready flavor! 🎉