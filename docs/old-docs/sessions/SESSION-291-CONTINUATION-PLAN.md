# Session 291+ Continuation Plan: Complete BSI & ASTM Implementation

**Created:** 2026-01-07 (Post-Session 290)
**Status:** Ready to execute
**Scope:** Fix ALL 535 BSI unknown failures + ASTM rspec creation
**Timeline:** Estimated 6-8 hours total across multiple sessions

---

## Executive Summary

**Current BSI Status:** 1,044/1,579 (66.12%)
**Target:** 1,579/1,579 (100%)
**Gap:** 535 "unknown" failures
**ASTM Status:** No specs, 248 fixtures ready

**ALL work must follow fixture-based approach - Session 288 lesson learned!**

---

## Part A: BSI Unknown Failures Analysis (535 IDs)

### Priority 1: Supplement & Addendum (61 IDs, ~2h)

**Fixtures:**
- `supplement.txt` (32 IDs)
- `addendum.txt` (29 IDs)

**Patterns to implement:**
```
# Supplement patterns
BS 1000[9]:Supplement No. 1:1972
BS 449-1 Supplement No. 1:1959
Supplement No. 1 (1970) to BS 1831:1969

# Addendum patterns
BS 1501-2 Addendum No. 1:1973
BS 2000-0:Addendum 1:1983
BS 6034:1981:Addendum No. 1:1986
```

**Implementation:**
1. Create `SupplementDocument` class
2. Create `AddendumDocument` class
3. Update parser with supplement/addendum patterns
4. Update builder for class selection
5. Update scheme registry

### Priority 2: Range Identifiers (40 IDs, ~1.5h)

**Fixture:** `range.txt` (40 IDs)

**Patterns to implement:**
```
BS SP 10 & 11:1949                      # Ampersand
BS SP 115 to 117:1956                   # "to"
BS SP 139 and SP 140:1969               # "and" with prefix
BS SP 13; 14; 15 and 16:1949            # Semicolon + and
BS 4048:Parts 1 and 2:1966              # Parts range
BS 558 and 564:1970                     # Number range
```

**Implementation:**
1. Create `RangeIdentifier` class
2. Support 6 range pattern types
3. Parser patterns for all range syntax
4. Builder construction logic

### Priority 3: Additional Identifier Types (~434 IDs, ~4-5h)

**Fixtures to analyze:**
- `automotive_standard.txt` (34 IDs)
- `committee_document.txt` (? IDs)
- `test_method.txt` (? IDs)
- `tickit.txt` (? IDs)
- `electronic_book.txt` (? IDs)
- `issue.txt` (? IDs)
- `explanatory_supplement.txt` (? IDs)
- `method.txt` (? IDs)
- Plus ~20 more fixture files

**Action:** Systematically check each fixture file, count IDs, implement classes

---

## Part B: ASTM Rspec Creation (~30 min)

### Current ASTM Status

**Fixtures:** 248 identifiers (100% classified)
**Implementation:** Complete (all 9 identifier types)
**Missing:** Rspec integration tests

**Fixture Structure:**
```
spec/fixtures/astm/identifiers/pass/
├── adjunct.txt (4)
├── data_series.txt (33)
├── iso_dual_published.txt (5)
├── manual.txt (74)
├── monograph.txt (11)
├── research_report.txt (59)
├── standard.txt (54)
├── technical_report.txt (5)
└── work_in_progress.txt (3)
```

### Implementation Task

**File:** `spec/pubid_new/astm/identifier_spec.rb`

**Structure to follow:** (Like ISO pattern)

```ruby
require "spec_helper"
require_relative "../../../lib/pubid_new"

RSpec.describe PubidNew::Astm::Identifier do
  subject { described_class }

  describe ".parse" do
    context "with valid identifier" do
      let(:id) { described_class.parse(pubid) }

      context "Standard ASTM A36/A36M-19" do
        let(:pubid) { "ASTM A36/A36M-19" }
        it "handles ASTM A36/A36M-19" do
          expect(id.class).to eq(PubidNew::Astm::Identifiers::Standard)
          expect(id.to_s).to eq(pubid)
        end
      end

      # Add 1 example per identifier type (9 total)
      # Use actual fixture data
    end
  end
end
```

**Steps:**
1. Read one example from each fixture file
2. Add context+test for each of 9 types
3. Verify round-trip fidelity
4. Run: `bundle exec rspec spec/pubid_new/astm/identifier_spec.rb`

---

## Implementation Strategy

### Session 291: Supplement & Addendum (2h)

**Goal:** +61 IDs (66.12% → 69.98%)

**Tasks:**
1. Analyze supplement.txt patterns (15 min)
2. Create SupplementDocument class (30 min)
3. Analyze addendum.txt patterns (15 min)
4. Create AddendumDocument class (30 min)
5. Update parser/builder/scheme (20 min)
6. Test and validate (10 min)

**Expected:** 1,105/1,579 (69.98%)

### Session 292: Range Identifiers (1.5h)

**Goal:** +40 IDs (69.98% → 72.51%)

**Tasks:**
1. Analyze all range patterns (20 min)
2. Create RangeIdentifier class (40 min)
3. Parser support for 6 range types (20 min)
4. Test and validate (10 min)

**Expected:** 1,145/1,579 (72.51%)

### Session 293: Automotive + Analysis (1.5h)

**Goal:** Implement automotive, analyze remaining

**Tasks:**
1. Create AutomotiveStandard (34 IDs) (45 min)
2. List all remaining fixture files (15 min)
3. Count IDs per file, prioritize (15 min)
4. Plan next 3 sessions (15 min)

**Expected:** 1,179/1,579 (74.67%)

### Session 294-296: Systematic Completion (4-5h)

**Goal:** 100% BSI implementation

**Approach:**
- Process fixtures in order of ID count (high to low)
- Create class per fixture type
- Test incrementally
- Reach 100%

### Session 297: ASTM Rspec + Documentation (1h)

**Goal:** ASTM tests + final docs

**Tasks:**
1. Create ASTM identifier_spec.rb (30 min)
2. Update README.adoc (15 min)
3. Update memory bank (15 min)

---

## Architecture Principles (CRITICAL)

### Fixture-First Approach

**LESSON FROM SESSION 288:** ALWAYS check fixtures before creating classes!

1. ✅ Read fixture file first
2. ✅ Analyze patterns
3. ✅ Create class matching fixture name
4. ✅ Implement patterns exactly as in fixtures
5. ❌ NEVER create arbitrary classes

### MODEL-DRIVEN Architecture

**All new classes MUST:**
- Inherit from `Identifiers::Base`
- Use `Lutaml::Model::Serializable`
- Follow three-layer pattern (Parser/Builder/Identifier)
- Maintain MECE organization
- Preserve round-trip fidelity

### Testing Strategy

**For each new identifier type:**
1. Unit tests for class
2. Parser tests for patterns
3. Builder tests for construction
4. Integration tests via fixtures
5. 100% coverage target

---

## Success Metrics

### BSI Completion Targets

| Session | New IDs | Cumulative | Rate | Status |
|---------|---------|------------|------|--------|
| 289 (baseline) | - | 1,044 | 66.12% | ✅ Done |
| 291 | +61 | 1,105 | 69.98% | Target |
| 292 | +40 | 1,145 | 72.51% | Target |
| 293 | +34 | 1,179 | 74.67% | Target |
| 294-296 | +400 | 1,579 | 100% | **GOAL** |

### ASTM Completion Target

- ✅ 9/9 identifier types implemented
- ✅ 248/248 fixtures classified
- ⏳ Integration spec creation
- 🎯 100% test coverage

---

## File Structure Overview

### BSI Files to Create/Modify

**New Identifier Classes:**
```
lib/pubid_new/bsi/identifiers/
├── supplement_document.rb (NEW)
├── addendum_document.rb (NEW)
├── range_identifier.rb (NEW)
├── automotive_standard.rb (NEW)
└── [12+ more based on analysis]
```

**Files to Modify:**
```
lib/pubid_new/bsi/
├── parser.rb (add patterns)
├── builder.rb (add construction)
└── scheme.rb (add registry)
```

### ASTM Files to Create

```
spec/pubid_new/astm/
└── identifier_spec.rb (NEW - 9 test contexts)
```

---

## Next Immediate Steps (Session 291)

### Phase 1: Analysis (15 min)

1. Read `spec/fixtures/bsi/identifiers/full/supplement.txt`
2. Identify all supplement patterns
3. Design SupplementDocument class structure

### Phase 2: Supplement Implementation (45 min)

1. Create `lib/pubid_new/bsi/identifiers/supplement_document.rb`
2. Add parser rules for supplement patterns
3. Update builder with supplement construction
4. Update scheme registry

### Phase 3: Addendum Implementation (45 min)

1. Read `spec/fixtures/bsi/identifiers/full/addendum.txt`
2. Create `lib/pubid_new/bsi/identifiers/addendum_document.rb`
3. Add parser rules for addendum patterns
4. Update builder and scheme

### Phase 4: Validation (15 min)

1. Run BSI fixture validation
2. Verify +61 IDs gain
3. Update progress tracking
4. Prepare Session 292 plan

---

## Risk Mitigation

### Known Risks

1. **Pattern Complexity:** Some BSI patterns may be highly irregular
   - **Mitigation:** Analyze thoroughly before implementing
   - **Fallback:** Document edge cases for future sessions

2. **Time Estimates:** May need more sessions than planned
   - **Mitigation:** Break into smaller increments
   - **Adjustment:** Re-plan after Session 293 analysis

3. **Architecture Drift:** Risk of cutting corners under pressure
   - **Mitigation:** NEVER compromise MODEL-DRIVEN principles
   - **Rule:** Better to take longer and do it right

### Quality Gates

**Each session MUST:**
- ✅ Maintain MODEL-DRIVEN architecture
- ✅ Follow fixture-based approach
- ✅ Pass all existing tests
- ✅ Add comprehensive new tests
- ✅ Update documentation

**NEVER:**
- ❌ Lower test thresholds
- ❌ Skip architecture review
- ❌ Create arbitrary classes
- ❌ Compromise on quality

---

## Continuation Prompt

When ready to start Session 291, use:

```
Continue Session 291: BSI Supplement & Addendum Implementation

Follow docs/SESSION-291-CONTINUATION-PLAN.md Part A Priority 1.

Implement SupplementDocument and AddendumDocument classes following
fixture-based approach. Target: +61 IDs (66.12% → 69.98%).

Remember:
1. Read fixtures FIRST
2. MODEL-DRIVEN architecture
3. Three-layer pattern
4. MECE organization
5. 100% round-trip fidelity

Start with supplement.txt analysis.
```

---

**Created:** 2026-01-07
**Status:** READY FOR EXECUTION
**Target:** 100% BSI + ASTM rspec completion
**Estimated Duration:** 6-8 hours across Sessions 291-297