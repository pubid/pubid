# Session 239+ V1 to V2 Spec Migration Plan

**Created:** 2025-12-30  
**Purpose:** Systematic migration of V1 specs to V2 architecture  
**Reference:** [`docs/V1_TO_V2_SPEC_MIGRATION_TRACKER.md`](V1_TO_V2_SPEC_MIGRATION_TRACKER.md)

---

## Overview

**Total work identified:** 18 hours across 3 phases  
**Flavors needing work:** 5 (NIST, JIS, CCSDS, ETSI, PLATEAU)  
**Priority:** HIGH for NIST, JIS, CCSDS; MEDIUM for ETSI, PLATEAU

---

## SESSION 239: Phase 1 - Quick Wins (2 hours)

### Objective
Complete spec migration for CCSDS, ETSI, PLATEAU (3 flavors)

### Part A: CCSDS Verification (40 min)

**Files to compare:**
- V1: `archived-gems/pubid-ccsds/spec/pubid/ccsds/identifier_spec.rb`
- V1: `archived-gems/pubid-ccsds/spec/pubid/ccsds/create_spec.rb`
- V2: `spec/pubid_new/ccsds/identifier_spec.rb`

**Tasks:**
1. Read V1 `identifier_spec.rb` - extract all test cases (15 min)
2. Read V1 `create_spec.rb` - extract creation patterns (10 min)
3. Compare with V2 `identifier_spec.rb` - identify gaps (10 min)
4. Add missing test cases to V2 spec (5 min)

**Expected outcome:** CCSDS at 100% migration

---

### Part B: ETSI Verification (40 min)

**Files to compare:**
- V1: `archived-gems/pubid-etsi/spec/pubid/etsi/identifier_spec.rb`
- V1: `archived-gems/pubid-etsi/spec/pubid/etsi/create_spec.rb`
- V2: `spec/pubid_new/etsi/identifier_spec.rb`

**Tasks:**
1. Read V1 `identifier_spec.rb` - extract all test cases (15 min)
2. Read V1 `create_spec.rb` - extract creation patterns (10 min)
3. Compare with V2 `identifier_spec.rb` - identify gaps (10 min)
4. Add missing test cases to V2 spec (5 min)

**Expected outcome:** ETSI at 100% migration

---

### Part C: PLATEAU Verification (40 min)

**Files to compare:**
- V1: `archived-gems/pubid-plateau/spec/pubid/plateau/identifier_spec.rb`
- V1: `archived-gems/pubid-plateau/spec/pubid/plateau/create_spec.rb`
- V2: `spec/pubid_new/plateau/identifier_spec.rb`

**Tasks:**
1. Read V1 `identifier_spec.rb` - extract all test cases (15 min)
2. Read V1 `create_spec.rb` - extract creation patterns (10 min)
3. Compare with V2 `identifier_spec.rb` - identify gaps (10 min)
4. Add missing test cases to V2 spec (5 min)

**Expected outcome:** PLATEAU at 100% migration

---

## SESSION 240-241: Phase 2 - JIS Migration (4 hours)

### Objective
Complete JIS spec migration (4 V1 → full V2 coverage)

### Session 240: Analysis & Base Specs (2 hours)

**Part A: Analyze V1 Structure (40 min)**

**Files to read:**
```
archived-gems/pubid-jis/spec/pubid/jis/
├── base_spec.rb
├── create_spec.rb
├── identifier_spec.rb
└── renderer_spec.rb
```

**Tasks:**
1. Read all 4 V1 spec files
2. Extract test patterns and coverage
3. Identify JIS identifier types tested
4. Map to V2 architecture

**Part B: Create Base Spec (40 min)**

**File:** `spec/pubid_new/jis/identifiers/base_spec.rb`

**Coverage:**
- Base class functionality
- Common attributes (number, part, year)
- Publisher handling
- Round-trip tests

**Part C: Create Identifier Type Specs (40 min)**

Based on V1 analysis, create specs for JIS identifier types:
- Standard spec
- Amendment spec (if applicable)
- Any other types discovered

---

### Session 241: Component & Integration Specs (2 hours)

**Part A: Component Specs (60 min)**

**Files to create:**
- `spec/pubid_new/jis/components/code_spec.rb` (if needed)
- `spec/pubid_new/jis/components/publisher_spec.rb` (if needed)

**Part B: Integration Tests (60 min)**

**File:** Enhance `spec/pubid_new/jis/identifier_spec.rb`

Add:
- Creation workflow tests (from V1 create_spec.rb)
- Parsing integration tests
- Rendering tests (modern V2 approach, not V1 renderer pattern)

**Expected outcome:** JIS at 100% migration

---

## SESSION 242-246: Phase 3 - NIST Migration (12 hours)

### Objective
Complete NIST spec migration (20 V1 → full V2 coverage)

### Session 242: Analysis & Series Structure (2 hours)

**Part A: Analyze V1 NIST Specs (60 min)**

**Read all V1 specs:**
```
archived-gems/pubid-nist/spec/pubid/nist/
├── circ_spec.rb (2 files - check for duplicates)
├── sp_spec.rb (2 files - check for duplicates)
├── create_spec.rb
├── default_spec.rb
├── document_merge_spec.rb
├── edition_spec.rb
├── fips_spec.rb
├── hb_spec.rb
├── nbs_hb_spec.rb
├── nbs_tn_spec.rb
├── nist_ir_spec.rb
├── nist_tech_pubs_spec.rb
├── publisher_spec.rb
├── series_spec.rb
├── stage_spec.rb
└── update_spec.rb
```

**Tasks:**
1. Catalog all test patterns
2. Identify NIST series types tested
3. Extract component test requirements
4. Map integration test workflows

**Part B: Series Spec Planning (60 min)**

Create implementation plan for series-specific specs:
- Which series need dedicated specs
- Which can be covered by base spec
- Component test requirements
- Integration test requirements

---

### Session 243: Component Specs (2 hours)

**Create component specs:**

1. **publisher_spec.rb** (40 min)
   - NIST vs NBS prefix
   - Publisher-specific logic

2. **series_spec.rb** (40 min)
   - All NIST series types (SP, FIPS, IR, TN, HB, CIRC, etc.)
   - Series validation
   - Historical NBS series

3. **edition_spec.rb** (20 min)
   - Edition handling specific to NIST

4. **stage_spec.rb** (20 min)
   - Draft stages
   - Publication stages

---

### Session 244: Series Identifier Specs Part 1 (2 hours)

**Create identifier specs for major series:**

1. **special_publication_spec.rb** (enhanced) (30 min)
   - Extend existing spec
   - Add SP-specific patterns from V1 sp_spec.rb

2. **federal_information_processing_standard_spec.rb** (enhanced) (30 min)
   - Extend existing spec
   - Add FIPS patterns from V1 fips_spec.rb

3. **internal_report_spec.rb** (40 min)
   - New spec from V1 nist_ir_spec.rb
   - IR-specific patterns

4. **technical_note_spec.rb** (20 min)
   - New spec from V1 nbs_tn_spec.rb
   - TN patterns

---

### Session 245: Series Identifier Specs Part 2 (2 hours)

**Create identifier specs for remaining series:**

1. **handbook_spec.rb** (40 min)
   - Combined from V1 hb_spec.rb + nbs_hb_spec.rb
   - HB-specific patterns

2. **circular_spec.rb** (40 min)
   - From V1 circ_spec.rb files
   - CIRC-specific patterns

3. **tech_pubs_spec.rb** (40 min)
   - From V1 nist_tech_pubs_spec.rb
   - Technical publications patterns

---

### Session 246: Integration & Default Specs (2 hours)

**Create integration test specs:**

1. **default_spec.rb** (30 min)
   - From V1 default_spec.rb
   - Default identifier behavior

2. **document_merge_spec.rb** (30 min)
   - From V1 document_merge_spec.rb
   - Document merging logic

3. **update_spec.rb** (30 min)
   - From V1 update_spec.rb
   - Update workflows

4. **Enhance identifier_spec.rb** (30 min)
   - Add creation integration tests from V1 create_spec.rb
   - Comprehensive parsing tests

**Expected outcome:** NIST at 100% migration

---

## Success Metrics

### Per Session
- ✅ All V1 test patterns identified
- ✅ V2 specs follow MODEL-DRIVEN architecture
- ✅ Tests use real identifier strings (no mocking)
- ✅ Round-trip tests for all patterns
- ✅ Component tests for shared logic

### Overall
- ✅ 100% V1 test coverage in V2 specs
- ✅ Better organization than V1 (MECE)
- ✅ Each identifier type has dedicated spec
- ✅ Components properly tested
- ✅ Integration workflows covered

---

## Continuation Prompts

### For Session 239 (Quick Wins)
```
Read: docs/SESSION-239-V1-TO-V2-MIGRATION-PLAN.md

Execute Session 239: Phase 1 - Quick Wins (CCSDS, ETSI, PLATEAU)

Part A: CCSDS verification
Part B: ETSI verification  
Part C: PLATEAU verification

Goal: 3 flavors at 100% migration in 2 hours
```

### For Session 240 (JIS Part 1)
```
Read: docs/SESSION-239-V1-TO-V2-MIGRATION-PLAN.md

Execute Session 240: JIS Migration Part 1

Part A: Analyze V1 structure
Part B: Create base spec
Part C: Create identifier type specs

Goal: JIS foundation specs complete
```

### For Session 242 (NIST Analysis)
```
Read: docs/SESSION-239-V1-TO-V2-MIGRATION-PLAN.md

Execute Session 242: NIST Migration Analysis

Part A: Analyze all 20 V1 NIST specs
Part B: Plan series spec structure

Goal: Complete understanding of NIST test requirements
```

---

## Architecture Principles (NEVER VIOLATE)

**Throughout ALL migration work:**

1. **MODEL-DRIVEN** - Objects not strings
2. **MECE** - Each identifier type is distinct
3. **No mocking** - Test real parsing/rendering
4. **Round-trip** - Parse → Object → String must match
5. **Component tests** - Test shared components separately
6. **Integration tests** - Test creation workflows
7. **Fixture-based** - Use real identifier examples

---

**Created:** 2025-12-30  
**Sessions:** 239-246 (18 hours estimated)  
**Status:** Ready for execution

