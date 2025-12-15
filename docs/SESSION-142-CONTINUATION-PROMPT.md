# Session 142 Continuation Prompt: Correction & ASTM Flavor

**IMPORTANT:** Session 142 had a misunderstanding. SI/PSI are NOT special identifier types - they're just regular IEEE/ASTM copublished standards. This session will correct that error and implement the ASTM flavor properly.

---

## Context

**What Happened:**
- Session 142 incorrectly created SiStandard and PsiStandard classes
- Misunderstood "IEEE/ASTM SI 10-1997" as a special "SI" type
- Actually, it's just IEEE/ASTM copublished with "SI 10" as the standard number
- "PSI 10/D2" = "Proposed SI 10, Draft 2" (IEEE draft notation, not special type)

**What Needs To Happen:**
1. Delete incorrect SI/PSI classes
2. Revert parser/builder changes
3. Confirm ASTM works as IEEE copublisher
4. Implement ASTM as standalone flavor (16th flavor!)

---

## Phase 1: Rollback Incorrect Implementation (10 min)

### Delete Files
```bash
rm lib/pubid_new/ieee/identifiers/si_standard.rb
rm lib/pubid_new/ieee/identifiers/psi_standard.rb
```

### Revert Parser Changes

**File:** `lib/pubid_new/ieee/parser.rb`

Remove the `ieee_astm_si_psi` rule (added around line 500):
- Delete the entire rule definition
- Remove from identifier rule list

**File:** `lib/pubid_new/ieee/builder.rb`

Remove the `build_si_psi_identifier` method (added around line 55):
- Delete the entire method
- Remove the si_type check in build() method
- Remove SI/PSI routing in determine_identifier_class()

### Revert Memory Bank

**File:** `.kilocode/rules/memory-bank/context.md`

Remove the "Session 142 Complete" entry at the top.

---

## Phase 2: Verify IEEE/ASTM Copublisher Works (5 min)

**Test that ASTM already works as copublisher:**

```ruby
# These should parse correctly with current IEEE implementation
PubidNew::Ieee.parse("IEEE/ASTM SI 10-1997")
# Expected: Base with publisher="IEEE", copublisher=["ASTM"], code="SI 10", year="1997"

PubidNew::Ieee.parse("IEEE/ASTM PSI 10/D2, October 2015")
# Expected: Base with publisher="IEEE", copublisher=["ASTM"], code="PSI 10", draft="D2", month="October", year="2015"
```

ASTM should already be in the organization list (line 72 of parser.rb).

---

## Phase 3: Implement ASTM Flavor (16th Flavor!) (90-120 min)

### ASTM Patterns (289 fixtures)

**Read:** `spec/fixtures/astm/identifiers/full/identifiers.txt`

**Key patterns:**
1. **Standards** (most common): `ASTM E2938-15(2023)`, `ASTM D2148-22`
2. **Dual unit**: `ASTM F1862/F1862M-17`
3. **Editorial**: `ASTM C1028-07e1`
4. **Work in Progress**: `ASTM WK91249`
5. **Adjuncts**: `ASTM ADJD2148`, `ADJF3504-EA`
6. **Technical Reports**: `TR1-EB`, `ISO/ASTMTR52916-EB`
7. **Manuals**: `ASTM MNL1-9TH-EB`
8. **Monographs**: `ASTM MONO1-EB`
9. **Data Series**: `ASTM DS4B-EB`
10. **Research Reports**: `ASTM RR:A01-1001`

### Architecture (MECE)

**8 Identifier Classes:**
1. Standard (A-G letter prefix) - DEFAULT
2. WorkInProgress (WK prefix)
3. Adjunct (ADJ prefix)
4. TechnicalReport (TR prefix or ISO/ASTMTR)
5. Manual (MNL prefix)
6. Monograph (MONO prefix)
7. DataSeries (DS prefix)
8. Research Report (RR: prefix with colon)

### Implementation Structure

```
lib/pubid_new/astm/
├── astm.rb (module loader)
├── identifier.rb (base class with parse())
├── parser.rb (Parslet grammar)
├── builder.rb (object construction)
├── single_identifier.rb (base for documents)
├── components/
│   ├── code.rb (letter + number)
│   └── dual_unit.rb (metric designation)
└── identifiers/
    ├── standard.rb (A-G prefix, most common)
    ├── work_in_progress.rb
    ├── adjunct.rb
    ├── technical_report.rb
    ├── manual.rb
    ├── monograph.rb
    ├── data_series.rb
    └── research_report.rb
```

### Step-by-Step Implementation

#### 1. Create Module Loader (5 min)

**File:** `lib/pubid_new/astm.rb`

```ruby
# frozen_string_literal: true

require_relative "astm/identifier"

module PubidNew
  module Astm
    def self.parse(input)
      Identifier.parse(input)
    end
  end
end
```

#### 2. Create Parser (30 min)

**File:** `lib/pubid_new/astm/parser.rb`

**Rules needed:**
- Publisher: "ASTM" (optional for some patterns)
- Letter prefix: A-G
- Number: 1-9999
- Year: 2 or 4 digits
- Reapproval: (YYYY)
- Editorial: e1, e2
- Dual unit: /CODE M
- WK prefix
- ADJ prefix
- MNL/MONO/DS/TR/RR prefixes
- Edition: 9TH, 2ND
- Format: -EB suffix

#### 3. Create Builder (20 min)

**File:** `lib/pubid_new/astm/builder.rb`

Route to appropriate class based on prefix:
- Match letter A-G → Standard
- Match WK → WorkInProgress
- Match ADJ → Adjunct
- Match TR → TechnicalReport
- Match MNL → Manual
- Match MONO → Monograph
- Match DS → DataSeries
- Match RR: → ResearchReport

#### 4. Create Identifier Classes (40 min)

**Most important:** Standard class (handles 76 of 289)

**Standard pattern:**
```ruby
class Standard < SingleIdentifier
  attribute :letter, :string          # A-G
  attribute :number, :string          # 1-9999
  attribute :year, :string            # Publication year
  attribute :sub_year, :string        # a, b, c
  attribute :dual_unit, DualUnit      # Metric designation
  attribute :reapproval, :string      # (YYYY)
  attribute :editorial, :string       # e1, e2

  def to_s
    # ASTM E2938-15(2023)
    # ASTM F1862/F1862M-17
  end
end
```

#### 5. Create Tests (10 min)

**File:** `spec/pubid_new/astm/identifier_spec.rb`

Test representative examples from each type.

---

## Phase 4: Testing & Validation (15 min)

### Unit Tests
```bash
bundle exec rspec spec/pubid_new/astm/identifier_spec.rb
```

### Fixture Testing
```bash
cd spec/fixtures
ruby run_classify.rb astm
```

**Expected:** High pass rate (85-95%) given the comprehensive patterns

---

## Success Criteria

### Rollback (Phase 1)
- ✅ SI/PSI files deleted
- ✅ Parser reverted (no ieee_astm_si_psi rule)
- ✅ Builder reverted (no build_si_psi_identifier)
- ✅ Memory bank corrected

### IEEE/ASTM Verification (Phase 2)
- ✅ IEEE/ASTM SI 10-1997 parses as Base
- ✅ IEEE/ASTM PSI 10/D2 parses as Base with draft
- ✅ ASTM recognized as copublisher

### ASTM Flavor (Phase 3)
- ✅ 8 identifier classes created
- ✅ Parser handles all patterns
- ✅ Builder routes correctly
- ✅ MODEL-DRIVEN architecture
- ✅ MECE organization

### Testing (Phase 4)
- ✅ Unit tests passing
- ✅ Fixtures: 85%+ (247+/289)
- ✅ Round-trip fidelity
- ✅ Zero regressions

---

## Key Design Principles

1. **MODEL-DRIVEN** - All identifiers are Lutaml::Model objects
2. **MECE** - 8 mutually exclusive classes
3. **Three-layer** - Parser/Builder/Identifier separation
4. **Component-based** - Reusable Code, DualUnit components
5. **Default class** - Standard is default (A-G prefix)

---

## Reference Documents

- **Correction Plan:** `docs/SESSION-142-CORRECTION-PLAN.md`
- **ASTM Fixtures:** `spec/fixtures/astm/identifiers/full/identifiers.txt`
- **ASTM Designation Rules:** Lines 2-26 of fixtures file

---

## Timeline

**Total:** 120-150 minutes compressed

- Phase 1: Rollback (10 min)
- Phase 2: Verification (5 min)
- Phase 3: ASTM Implementation (90-120 min)
- Phase 4: Testing (15 min)

---

**End Goal:** Correct Session 142 error + 16th flavor ASTM production-ready! 🎉