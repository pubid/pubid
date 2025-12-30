# Session 240+ Continuation Plan: V1 to V2 Spec Migration - JIS & NIST

**Created:** 2025-12-30 (Post-Session 239)
**Status:** Session 239 complete (CCSDS, ETSI, PLATEAU at 100%)
**Timeline:** COMPRESSED - Complete within 8-10 sessions (16 hours total)

---

## Executive Summary

**Session 239 Achievement:** 3 flavors at 100% (CCSDS, ETSI, PLATEAU) - 44 tests passing

**Current Status:**
- **V1→V2 Migration:** 9/12 flavors (75%)
- **Remaining:** JIS (25%) and NIST (30%)
- **Estimated effort:** 16 hours (Sessions 240-249)

**Target:** Complete all V1→V2 spec migration for production readiness

---

## SESSION 240-241: JIS Migration (4 hours)

### Objective
Complete JIS spec migration from 25% to 100%

### Current V1 JIS Specs (4 files)
```
archived-gems/pubid-jis/spec/pubid/jis/
├── base_spec.rb
├── create_spec.rb
├── identifier_spec.rb
└── renderer_spec.rb
```

### Current V2 JIS Specs (1 file)
- `spec/pubid_new/jis/identifier_spec.rb` (minimal)

### Session 240: Analysis & Base Specs (2 hours)

**Part A: Analyze V1 Structure (40 min)**

Read all V1 specs:
```bash
archived-gems/pubid-jis/spec/pubid/jis/base_spec.rb
archived-gems/pubid-jis/spec/pubid/jis/create_spec.rb
archived-gems/pubid-jis/spec/pubid/jis/identifier_spec.rb
archived-gems/pubid-jis/spec/pubid/jis/renderer_spec.rb
```

Document:
1. All test patterns
2. JIS identifier types
3. Component requirements
4. Integration patterns

**Part B: Create Base Spec (60 min)**

File: `spec/pubid_new/jis/identifiers/base_spec.rb`

Coverage:
- Base class functionality
- Common attributes (number, part, year)
- Publisher handling
- Round-trip tests
- Estimated: 20-25 tests

**Part C: Create Identifier Type Specs (20 min)**

Based on V1 analysis, create type-specific specs if needed.

### Session 241: Component & Integration Specs (2 hours)

**Part A: Component Specs (60 min)**

Files (if needed):
- `spec/pubid_new/jis/components/code_spec.rb`
- `spec/pubid_new/jis/components/publisher_spec.rb`

**Part B: Integration Tests (60 min)**

Enhance `spec/pubid_new/jis/identifier_spec.rb`:
- Creation workflow tests
- Parsing integration tests
- Rendering tests (V2 approach, not V1 renderer pattern)
- All V1 patterns covered

**Expected Outcome:** JIS at 100% migration (40-50 tests)

---

## SESSION 242-246: NIST Migration (12 hours)

### Objective
Complete NIST spec migration from 30% to 100%

### Current V1 NIST Specs (20 files)
```
archived-gems/pubid-nist/spec/pubid/nist/
├── circ_spec.rb (2 files - check duplicates)
├── sp_spec.rb (2 files - check duplicates)
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

### Current V2 NIST Specs (6 files)
- identifier_spec.rb
- parser_spec.rb
- builder_spec.rb
- identifier/base_spec.rb
- identifier/federal_information_processing_standard_spec.rb
- identifier/special_publication_spec.rb

### Session 242: Analysis & Series Structure (2 hours)

**Part A: Analyze V1 NIST Specs (60 min)**

Read all 20 V1 spec files and catalog:
1. All test patterns
2. NIST series types tested
3. Component test requirements
4. Integration test workflows

**Part B: Series Spec Planning (60 min)**

Create implementation plan:
- Which series need dedicated specs
- Which can be covered by base spec
- Component test requirements
- Integration test requirements

Create planning document: `docs/NIST-SPEC-MIGRATION-PLAN.md`

### Session 243: Component Specs (2 hours)

**Create component specs** (4 files):

1. **publisher_spec.rb** (40 min)
   - NIST vs NBS prefix
   - Publisher-specific logic
   - ~15 tests

2. **series_spec.rb** (40 min)
   - All NIST series types (SP, FIPS, IR, TN, HB, CIRC, etc.)
   - Series validation
   - Historical NBS series
   - ~20 tests

3. **edition_spec.rb** (20 min)
   - Edition handling specific to NIST
   - ~8 tests

4. **stage_spec.rb** (20 min)
   - Draft stages
   - Publication stages
   - ~8 tests

**Expected:** ~51 component tests

### Session 244: Series Identifier Specs Part 1 (2 hours)

**Create identifier specs for major series** (4 files):

1. **special_publication_spec.rb** (enhanced) (30 min)
   - Extend existing spec
   - Add SP-specific patterns from V1 sp_spec.rb
   - ~15 tests

2. **federal_information_processing_standard_spec.rb** (enhanced) (30 min)
   - Extend existing spec
   - Add FIPS patterns from V1 fips_spec.rb
   - ~15 tests

3. **internal_report_spec.rb** (40 min)
   - New spec from V1 nist_ir_spec.rb
   - IR-specific patterns
   - ~20 tests

4. **technical_note_spec.rb** (20 min)
   - New spec from V1 nbs_tn_spec.rb
   - TN patterns
   - ~12 tests

**Expected:** ~62 series tests

### Session 245: Series Identifier Specs Part 2 (2 hours)

**Create identifier specs for remaining series** (3 files):

1. **handbook_spec.rb** (40 min)
   - Combined from V1 hb_spec.rb + nbs_hb_spec.rb
   - HB-specific patterns
   - ~20 tests

2. **circular_spec.rb** (40 min)
   - From V1 circ_spec.rb files
   - CIRC-specific patterns
   - ~20 tests

3. **tech_pubs_spec.rb** (40 min)
   - From V1 nist_tech_pubs_spec.rb
   - Technical publications patterns
   - ~20 tests

**Expected:** ~60 series tests

### Session 246: Integration & Default Specs (2 hours)

**Create integration test specs** (4 tasks):

1. **default_spec.rb** (30 min)
   - From V1 default_spec.rb
   - Default identifier behavior
   - ~15 tests

2. **document_merge_spec.rb** (30 min)
   - From V1 document_merge_spec.rb
   - Document merging logic
   - ~12 tests

3. **update_spec.rb** (30 min)
   - From V1 update_spec.rb
   - Update workflows
   - ~12 tests

4. **Enhance identifier_spec.rb** (30 min)
   - Add creation integration tests from V1 create_spec.rb
   - Comprehensive parsing tests
   - ~15 tests

**Expected:** ~54 integration tests

**NIST Total Expected:** ~227 tests (51 component + 62 + 60 + 54)

---

## SESSION 247-249: Documentation & Finalization (3 hours)

### Session 247: Update README.adoc (60 min)

**Update sections:**

1. V1 to V2 Migration Status
2. Spec Coverage Table
3. Testing Documentation
4. Architecture Notes

### Session 248: Archive Old Documentation (30 min)

**Move to old-docs/:**
- SESSION-239-*.md files
- SESSION-240-*.md files (after completion)
- Any temporary migration documents

### Session 249: Final Validation (90 min)

**Comprehensive testing:**
```bash
# All V2 specs
bundle exec rspec spec/pubid_new/jis/ --format progress
bundle exec rspec spec/pubid_new/nist/ --format progress

# Verify no regressions
bundle exec rake test:all
```

**Final commit and documentation**

---

## Success Criteria

### Per Session
- ✅ Clear objectives achieved
- ✅ Tests passing or documented failures
- ✅ Documentation updated
- ✅ No architectural regressions
- ✅ Incremental commits

### Overall (Sessions 240-249)
- ✅ JIS at 100% V1→V2 migration
- ✅ NIST at 100% V1→V2 migration
- ✅ 12/12 V1 flavors complete
- ✅ Comprehensive test coverage
- ✅ Clean architecture maintained
- ✅ Documentation current

---

## Timeline Summary

| Sessions | Focus | Duration | Deliverables |
|----------|-------|----------|--------------|
| 240-241 | JIS migration | 4 hours | JIS 100% |
| 242 | NIST analysis | 2 hours | Plan |
| 243 | NIST components | 2 hours | 51 tests |
| 244 | NIST series 1 | 2 hours | 62 tests |
| 245 | NIST series 2 | 2 hours | 60 tests |
| 246 | NIST integration | 2 hours | 54 tests |
| 247-249 | Documentation | 3 hours | Complete |
| **Total** | **All work** | **17 hours** | **V1→V2 DONE** |

---

## Key Architectural Principles

**NEVER compromise throughout ALL sessions:**

1. **MODEL-DRIVEN** - Objects not strings
2. **MECE** - Each identifier type is distinct
3. **No mocking** - Test real parsing/rendering
4. **Round-trip** - Parse → Object → String must match
5. **Component tests** - Test shared components separately
6. **Integration tests** - Test creation workflows
7. **Fixture-based** - Use real identifier examples
8. **Architecture correctness** - Even if tests fail, architecture must be correct

---

## Next Immediate Steps (Session 240)

1. Read this continuation plan
2. Read all 4 V1 JIS spec files
3. Document JIS patterns and requirements
4. Create `spec/pubid_new/jis/identifiers/base_spec.rb`
5. Test and validate
6. Commit progress

---

**Created:** 2025-12-30
**Sessions Covered:** 240-249
**Status:** Ready for execution
**Estimated Time:** 17 hours (compressed timeline)

**End Goal:** 12/12 V1 flavors at 100% V2 migration! 🎉