# Complete Specs Implementation Plan: All 105 Missing Specs

**Created:** 2025-12-29
**Status:** Ready for execution
**Timeline:** Compressed - 25-30 sessions (~40-50 hours total)
**Goal:** Achieve 90%+ spec coverage across all 19 flavors

---

## Executive Summary

**Current State:**
- Total Identifier Classes: 162
- Total Spec Files: 61
- Missing Specs: 105 (64.8% coverage gap)

**Target State:**
- Total Spec Files: 146+ (90%+ coverage)
- All production flavors at 80%+ coverage
- All 0% coverage flavors completed

**Approach:** Phased implementation prioritizing:
1. 0% coverage flavors (highest ROI)
2. Production-critical gaps
3. Completion to 100% where feasible

---

## Phase 1: CSA Complete Coverage (Sessions 226-228) - 3 sessions

**Priority:** 🔴 CRITICAL - Session 226 in progress
**Duration:** 4-5 hours total
**Target:** CSA 100% (0/8 → 8/8 specs)

### Session 226: CSA Core Specs (120 min) ✅ IN PROGRESS
**Files to create:**
1. `spec/pubid_new/csa/identifiers/standard_spec.rb` (~25-30 tests)
2. `spec/pubid_new/csa/identifiers/series_spec.rb` (~20 tests)
3. `spec/pubid_new/csa/identifiers/bundled_spec.rb` (~25 tests)
4. `spec/pubid_new/csa/identifiers/combined_spec.rb` (~30 tests)

**Expected:** 100 tests, 80-90% pass rate

### Session 227: CSA Adopted Specs (90 min)
**Files to create:**
1. `spec/pubid_new/csa/identifiers/base_spec.rb` (~25 tests)
2. `spec/pubid_new/csa/identifiers/canadian_adopted_spec.rb` (~20 tests)
3. `spec/pubid_new/csa/identifiers/csa_adopted_spec.rb` (~25 tests)

**Expected:** 70 tests, 80-90% pass rate

### Session 228: CSA Package + Components (30 min)
**Files to create:**
1. `spec/pubid_new/csa/identifiers/package_spec.rb` (~15 tests)
2. `spec/pubid_new/csa/components/code_spec.rb` (~10 tests)

**Expected:** 25 tests, 80-90% pass rate

**Phase 1 Total:** 195 tests, CSA 100% complete ✅

---

## Phase 2: Small Flavors Complete (Sessions 229-232) - 4 sessions

**Priority:** 🔴 HIGH - Quick wins, complete coverage
**Duration:** 5-6 hours total
**Target:** ANSI, ASME, CCSDS, IDF supplements complete

### Session 229: ANSI + ASME (90 min)
**ANSI (1 spec):**
- `spec/pubid_new/ansi/identifiers/american_national_standard_spec.rb` (~30 tests)

**ASME (2 specs):**
- `spec/pubid_new/asme/identifiers/base_spec.rb` (~20 tests)
- `spec/pubid_new/asme/identifiers/standard_spec.rb` (~25 tests)

**Expected:** 75 tests total

### Session 230: CCSDS (60 min)
**CCSDS (2 specs):**
- `spec/pubid_new/ccsds/identifiers/base_spec.rb` (~25 tests)
- `spec/pubid_new/ccsds/identifiers/corrigendum_spec.rb` (~20 tests)

**Expected:** 45 tests total

### Session 231: IDF Supplements (60 min)
**IDF (2 specs):**
- `spec/pubid_new/idf/identifiers/amendment_spec.rb` (~25 tests)
- `spec/pubid_new/idf/identifiers/corrigendum_spec.rb` (~20 tests)

**Expected:** 45 tests total

### Session 232: JCGM Complete (90 min)
**JCGM (3 specs):**
- `spec/pubid_new/jcgm/identifiers/guide_spec.rb` (~30 tests)
- `spec/pubid_new/jcgm/identifiers/gum_guide_spec.rb` (~25 tests)
- `spec/pubid_new/jcgm/identifiers/amendment_spec.rb` (~20 tests)

**Expected:** 75 tests total

**Phase 2 Total:** 240 tests, 4 flavors at 100% ✅

---

## Phase 3: OIML Complete (Sessions 233-236) - 4 sessions

**Priority:** 🔴 HIGH - Newly implemented, needs coverage
**Duration:** 6-7 hours total
**Target:** OIML 100% (0/10 → 10/10 specs)

### Session 233: OIML Base Documents (120 min)
**Files to create:**
1. `spec/pubid_new/oiml/identifiers/base_spec.rb` (~20 tests)
2. `spec/pubid_new/oiml/identifiers/basic_publication_spec.rb` (~25 tests)
3. `spec/pubid_new/oiml/identifiers/document_spec.rb` (~25 tests)
4. `spec/pubid_new/oiml/identifiers/recommendation_spec.rb` (~30 tests)

**Expected:** 100 tests

### Session 234: OIML Special Documents (90 min)
**Files to create:**
1. `spec/pubid_new/oiml/identifiers/guide_spec.rb` (~25 tests)
2. `spec/pubid_new/oiml/identifiers/expert_report_spec.rb` (~25 tests)
3. `spec/pubid_new/oiml/identifiers/seminar_report_spec.rb` (~20 tests)

**Expected:** 70 tests

### Session 235: OIML Vocabulary + Supplements (90 min)
**Files to create:**
1. `spec/pubid_new/oiml/identifiers/vocabulary_spec.rb` (~25 tests)
2. `spec/pubid_new/oiml/identifiers/amendment_spec.rb` (~25 tests)
3. `spec/pubid_new/oiml/identifiers/annex_spec.rb` (~25 tests)

**Expected:** 75 tests

### Session 236: OIML Components (30 min)
**Files to create:**
1. `spec/pubid_new/oiml/components/code_spec.rb` (~15 tests)

**Expected:** 15 tests

**Phase 3 Total:** 260 tests, OIML 100% complete ✅

---

## Phase 4: JIS Complete (Sessions 237-239) - 3 sessions

**Priority:** 🔴 HIGH - Production flavor, 0% coverage
**Duration:** 4-5 hours total
**Target:** JIS 100% (0/7 → 7/7 specs)

### Session 237: JIS Core (120 min)
**Files to create:**
1. `spec/pubid_new/jis/identifiers/base_spec.rb` (~20 tests)
2. `spec/pubid_new/jis/identifiers/standard_spec.rb` (~30 tests)
3. `spec/pubid_new/jis/identifiers/japanese_industrial_standard_spec.rb` (~30 tests)

**Expected:** 80 tests

### Session 238: JIS Types (90 min)
**Files to create:**
1. `spec/pubid_new/jis/identifiers/technical_report_spec.rb` (~25 tests)
2. `spec/pubid_new/jis/identifiers/technical_specification_spec.rb` (~25 tests)
3. `spec/pubid_new/jis/identifiers/explanation_spec.rb` (~20 tests)

**Expected:** 70 tests

### Session 239: JIS Supplements (60 min)
**Files to create:**
1. `spec/pubid_new/jis/identifiers/amendment_spec.rb` (~25 tests)

**Expected:** 25 tests

**Phase 4 Total:** 175 tests, JIS 100% complete ✅

---

## Phase 5: CIE Complete (Sessions 240-242) - 3 sessions

**Priority:** 🔴 HIGH - Production flavor, 0% coverage
**Duration:** 4-5 hours total
**Target:** CIE 100% (0/9 → 9/9 specs)

### Session 240: CIE Core (120 min)
**Files to create:**
1. `spec/pubid_new/cie/identifiers/standard_spec.rb` (~30 tests)
2. `spec/pubid_new/cie/identifiers/joint_published_spec.rb` (~25 tests)
3. `spec/pubid_new/cie/identifiers/dual_published_spec.rb` (~25 tests)

**Expected:** 80 tests

### Session 241: CIE Special (90 min)
**Files to create:**
1. `spec/pubid_new/cie/identifiers/identical_spec.rb` (~25 tests)
2. `spec/pubid_new/cie/identifiers/conference_spec.rb` (~20 tests)
3. `spec/pubid_new/cie/identifiers/supplement_spec.rb` (~25 tests)

**Expected:** 70 tests

### Session 242: CIE Bundles + Supplements (60 min)
**Files to create:**
1. `spec/pubid_new/cie/identifiers/bundle_spec.rb` (~20 tests)
2. `spec/pubid_new/cie/identifiers/tutorial_bundle_spec.rb` (~15 tests)
3. `spec/pubid_new/cie/identifiers/corrigendum_spec.rb` (~20 tests)

**Expected:** 55 tests

**Phase 5 Total:** 205 tests, CIE 100% complete ✅

---

## Phase 6: ASTM Complete (Sessions 243-245) - 3 sessions

**Priority:** 🟡 MEDIUM - 90% missing coverage
**Duration:** 4-5 hours total
**Target:** ASTM 100% (1/10 → 10/10 specs)

### Session 243: ASTM Core (120 min)
**Files to create:**
1. `spec/pubid_new/astm/identifiers/base_spec.rb` (~20 tests)
2. `spec/pubid_new/astm/identifiers/standard_spec.rb` (~30 tests)
3. `spec/pubid_new/astm/identifiers/technical_report_spec.rb` (~25 tests)

**Expected:** 75 tests

### Session 244: ASTM Types (90 min)
**Files to create:**
1. `spec/pubid_new/astm/identifiers/adjunct_spec.rb` (~20 tests)
2. `spec/pubid_new/astm/identifiers/manual_spec.rb` (~20 tests)
3. `spec/pubid_new/astm/identifiers/monograph_spec.rb` (~20 tests)

**Expected:** 60 tests

### Session 245: ASTM Special (90 min)
**Files to create:**
1. `spec/pubid_new/astm/identifiers/data_series_spec.rb` (~25 tests)
2. `spec/pubid_new/astm/identifiers/research_report_spec.rb` (~20 tests)
3. `spec/pubid_new/astm/identifiers/work_in_progress_spec.rb` (~20 tests)

**Expected:** 65 tests

**Phase 6 Total:** 200 tests, ASTM 100% complete ✅

---

## Phase 7: API Complete (Sessions 246-248) - 3 sessions

**Priority:** 🔴 HIGH - Production flavor, 0% coverage
**Duration:** 4-5 hours total
**Target:** API 100% (0/10 → 10/10 specs)

### Session 246: API Core (120 min)
**Files to create:**
1. `spec/pubid_new/api/identifiers/base_spec.rb` (~20 tests)
2. `spec/pubid_new/api/identifiers/standard_spec.rb` (~30 tests)
3. `spec/pubid_new/api/identifiers/specification_spec.rb` (~25 tests)

**Expected:** 75 tests

### Session 247: API Types (120 min)
**Files to create:**
1. `spec/pubid_new/api/identifiers/recommended_practice_spec.rb` (~25 tests)
2. `spec/pubid_new/api/identifiers/technical_report_spec.rb` (~25 tests)
3. `spec/pubid_new/api/identifiers/bulletin_spec.rb` (~20 tests)
4. `spec/pubid_new/api/identifiers/publication_spec.rb` (~20 tests)

**Expected:** 90 tests

### Session 248: API Special (60 min)
**Files to create:**
1. `spec/pubid_new/api/identifiers/mpms_spec.rb` (~25 tests)
2. `spec/pubid_new/api/identifiers/continuous_operations_standard_spec.rb` (~20 tests)
3. `spec/pubid_new/api/identifiers/typeless_standard_spec.rb` (~15 tests)

**Expected:** 60 tests

**Phase 7 Total:** 225 tests, API 100% complete ✅

---

## Phase 8: NIST Completion (Sessions 249-251) - 3 sessions

**Priority:** 🟡 MEDIUM - 73% missing coverage
**Duration:** 4-5 hours total
**Target:** NIST 100% (3/11 → 11/11 specs)

### Session 249: NIST Core Series (120 min)
**Files to create:**
1. `spec/pubid_new/nist/identifiers/special_publication_spec.rb` (~30 tests)
2. `spec/pubid_new/nist/identifiers/internal_report_spec.rb` (~25 tests)
3. `spec/pubid_new/nist/identifiers/technical_note_spec.rb` (~25 tests)

**Expected:** 80 tests

### Session 250: NIST FIPS + Handbook (90 min)
**Files to create:**
1. `spec/pubid_new/nist/identifiers/federal_information_processing_standards_spec.rb` (~30 tests)
2. `spec/pubid_new/nist/identifiers/handbook_spec.rb` (~25 tests)

**Expected:** 55 tests

### Session 251: NIST Historical (90 min)
**Files to create:**
1. `spec/pubid_new/nist/identifiers/circular_supplement_spec.rb` (~20 tests)
2. `spec/pubid_new/nist/identifiers/commercial_standard_emergency_spec.rb` (~20 tests)
3. `spec/pubid_new/nist/identifiers/crpl_report_spec.rb` (~20 tests)

**Expected:** 60 tests

**Phase 8 Total:** 195 tests, NIST 100% complete ✅

---

## Phase 9: IEEE/ETSI/BSI/CEN Gaps (Sessions 252-256) - 5 sessions

**Priority:** 🟡 MEDIUM - Fill production gaps
**Duration:** 7-8 hours total
**Target:** Improve coverage on partially-tested flavors

### Session 252: IEEE NESC + Special (120 min)
**Files to create:**
1. `spec/pubid_new/ieee/identifiers/nesc/base_spec.rb` (~20 tests)
2. `spec/pubid_new/ieee/identifiers/nesc/draft_spec.rb` (~20 tests)
3. `spec/pubid_new/ieee/identifiers/nesc/handbook_spec.rb` (~20 tests)
4. `spec/pubid_new/ieee/identifiers/nesc/redline_spec.rb` (~15 tests)

**Expected:** 75 tests

### Session 253: IEEE Special Types (120 min)
**Files to create:**
1. `spec/pubid_new/ieee/identifiers/si_standard_spec.rb` (~25 tests)
2. `spec/pubid_new/ieee/identifiers/csa_dual_published_spec.rb` (~25 tests)
3. `spec/pubid_new/ieee/identifiers/iec_ieee_copublished_spec.rb` (~25 tests)

**Expected:** 75 tests

### Session 254: IEEE Wrappers (90 min)
**Files to create:**
1. `spec/pubid_new/ieee/identifiers/dual_identifier_spec.rb` (~20 tests)
2. `spec/pubid_new/ieee/identifiers/parenthetical_identifier_spec.rb` (~25 tests)
3. `spec/pubid_new/ieee/identifiers/redlined_standard_spec.rb` (~20 tests)

**Expected:** 65 tests

### Session 255: ETSI Complete (90 min)
**Files to create:**
1. `spec/pubid_new/etsi/identifiers/base_spec.rb` (~20 tests)
2. Additional ETSI identifier specs as needed (~40 tests)

**Expected:** 60 tests

### Session 256: BSI + CEN Gaps (120 min)
**BSI (6 specs):**
- `amendment_spec.rb`, `base_spec.rb`, `consolidated_identifier_spec.rb`
- `corrigendum_spec.rb`, `expert_commentary_spec.rb`, `flex_spec.rb`

**CEN (6 specs):**
- `amendment_spec.rb`, `base_spec.rb`, `consolidated_identifier_spec.rb`
- `corrigendum_spec.rb`, `fragment_spec.rb`, `technical_specification_spec.rb`

**Expected:** 120 tests total (prioritize most critical 4-5)

**Phase 9 Total:** 395 tests, multiple flavors improved ✅

---

## Phase 10: Final Completions (Sessions 257-260) - 4 sessions

**Priority:** 🟢 LOW - Final cleanup
**Duration:** 4-5 hours total
**Target:** ISO/ITU 100%, documentation updates

### Session 257: ISO Final 2 (60 min)
**Files to create:**
1. `spec/pubid_new/iso/identifiers/base_spec.rb` (~25 tests)
2. `spec/pubid_new/iso/identifiers/technology_trends_assessments_spec.rb` (~25 tests)

**Expected:** 50 tests

### Session 258: ITU Final 2 (60 min)
**Files to create:**
1. `spec/pubid_new/itu/identifiers/base_spec.rb` (~20 tests)
2. `spec/pubid_new/itu/identifiers/combined_identifier_spec.rb` (~25 tests)

**Expected:** 45 tests

### Session 259: IEC Final 3 (60 min)
**Files to create:**
1. `spec/pubid_new/iec/identifiers/base_spec.rb` (~20 tests)
2. `spec/pubid_new/iec/identifiers/test_report_form_spec.rb` (~20 tests)
3. `spec/pubid_new/iec/identifiers/working_document_spec.rb` (~20 tests)

**Expected:** 60 tests

### Session 260: Documentation + Wrap-up (90 min)
**Tasks:**
1. Update README.adoc with complete spec coverage
2. Move all session plans to docs/old-docs/sessions/
3. Update memory bank with completion status
4. Create comprehensive testing guide

**Expected:** Documentation complete

**Phase 10 Total:** 155 tests + documentation ✅

---

## Timeline Summary

| Phase | Sessions | Duration | Specs | Tests | Deliverable |
|-------|----------|----------|-------|-------|-------------|
| 1 | 226-228 | 4-5h | 8 | 195 | CSA 100% |
| 2 | 229-232 | 5-6h | 8 | 240 | ANSI/ASME/CCSDS/IDF/JCGM 100% |
| 3 | 233-236 | 6-7h | 10 | 260 | OIML 100% |
| 4 | 237-239 | 4-5h | 7 | 175 | JIS 100% |
| 5 | 240-242 | 4-5h | 9 | 205 | CIE 100% |
| 6 | 243-245 | 4-5h | 9 | 200 | ASTM 100% |
| 7 | 246-248 | 4-5h | 10 | 225 | API 100% |
| 8 | 249-251 | 4-5h | 8 | 195 | NIST 100% |
| 9 | 252-256 | 7-8h | 21+ | 395 | IEEE/ETSI/BSI/CEN improved |
| 10 | 257-260 | 4-5h | 7 | 155 | ISO/ITU/IEC 100% + docs |
| **Total** | **35** | **46-56h** | **97+** | **2,245+** | **90%+ coverage** |

---

## Success Criteria

### Per Phase
- ✅ All spec files created and compiling
- ✅ 70%+ pass rate minimum per flavor
- ✅ No architecture compromises
- ✅ Documentation updated incrementally

### Overall Project
- ✅ 146+ spec files (90%+ coverage)
- ✅ All 0% coverage flavors completed
- ✅ All production flavors at 80%+ test coverage
- ✅ Comprehensive testing documentation
- ✅ All session plans archived

---

## Implementation Guidelines

**Per Session:**
1. Read relevant identifier implementation files (2-5 files)
2. Review fixture examples for test data
3. Follow test template pattern consistently
4. Test after each spec file creation
5. Commit progress incrementally

**Architecture Principles:**
- MODEL-DRIVEN: Test real object behavior
- No mocking/stubbing: Test actual parsing/rendering
- Round-trip validation: Parse → render must match
- Fixture-based: Use real identifier examples
- One spec per class: Complete coverage

**Quality Over Speed:**
- Correctness of architecture > test count
- 70%+ pass rate acceptable during development
- Failed tests highlight parser needs, not spec issues
- Incremental improvement is success

---

## Risk Mitigation

**High-Risk Areas:**
- Parser limitations causing test failures
- Round-trip fidelity issues
- Complex identifier patterns

**Mitigation:**
- Document parser limitations in comments
- Focus on architecture correctness
- Mark pending tests for future parser work
- Progressive enhancement approach

---

## Final Deliverable

**End State:**
- 90%+ spec coverage across all flavors
- Complete testing documentation
- All 0% coverage flavors at 100%
- Production-ready test suite
- Comprehensive spec examples for future development

---

**Created:** 2025-12-29
**Status:** READY FOR EXECUTION
**Next Session:** 226 (CSA Core Specs - IN PROGRESS)

