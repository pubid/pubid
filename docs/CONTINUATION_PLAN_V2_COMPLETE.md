# PubID V2 Completion Plan - Updated After Session 50 Audit

**Last Updated:** 2025-11-28 (Session 50 Complete)  
**Status:** CRITICAL - 27 missing spec files block V1 removal

---

## CRITICAL DISCOVERY - Session 50 Findings

**"100% passing" tests were MISLEADING:**
- NIST: 57/57 (100%) but only 3/6 classes have specs + needs test migration
- IEEE: 5,146/5,146 (100%) but only 3/7 classes have specs
- IEC: 2,222 passing but only 2/22 classes have specs
- ISO: 2,654/2,859 (92.84%) **ACTUALLY COMPLETE** - all 18 classes tested

**Gap Analysis:**
- IEC: 20 missing spec files (9% coverage) - CRITICAL BLOCKER
- IEEE: 4 missing spec files (43% coverage) - HIGH PRIORITY
- NIST: 3 missing spec files + comprehensive test migration (50% coverage) - SPECIAL CASE

**Detailed Results:** [`docs/SPEC_MIGRATION_MATRIX.md`](docs/SPEC_MIGRATION_MATRIX.md:1)

---

## Phase 0: Complete Spec Coverage (Sessions 51-58) 🚨 CRITICAL

**Purpose:** Achieve 100% per-class spec coverage before V1 removal  
**Blocker:** Cannot remove V1 code without complete test coverage  
**Sessions:** 8 sessions to close 27-spec gap

### Session 51-56: IEC Spec Migration (6 sessions)

**Critical:** 20 missing spec files (9% coverage)

**Session 51:** Component specs (3 specs)
- Create [`spec/pubid_new/iec/identifiers/component_specification_spec.rb`](spec/pubid_new/iec/identifiers/component_specification_spec.rb:1)
- Create [`spec/pubid_new/iec/identifiers/conformity_assessment_spec.rb`](spec/pubid_new/iec/identifiers/conformity_assessment_spec.rb:1)
- Create [`spec/pubid_new/iec/identifiers/consolidated_identifier_spec.rb`](spec/pubid_new/iec/identifiers/consolidated_identifier_spec.rb:1)

**Session 52:** Supplement & Guide specs (3 specs)
- Create [`spec/pubid_new/iec/identifiers/corrigendum_spec.rb`](spec/pubid_new/iec/identifiers/corrigendum_spec.rb:1)
- Create [`spec/pubid_new/iec/identifiers/fragment_identifier_spec.rb`](spec/pubid_new/iec/identifiers/fragment_identifier_spec.rb:1)
- Create [`spec/pubid_new/iec/identifiers/guide_spec.rb`](spec/pubid_new/iec/identifiers/guide_spec.rb:1)

**Session 53:** Interpretation & PAS specs (3 specs)
- Create [`spec/pubid_new/iec/identifiers/interpretation_sheet_spec.rb`](spec/pubid_new/iec/identifiers/interpretation_sheet_spec.rb:1)
- Create [`spec/pubid_new/iec/identifiers/operational_document_spec.rb`](spec/pubid_new/iec/identifiers/operational_document_spec.rb:1)
- Create [`spec/pubid_new/iec/identifiers/publicly_available_specification_spec.rb`](spec/pubid_new/iec/identifiers/publicly_available_specification_spec.rb:1)

**Session 54:** Sheet & Systems specs (3 specs)
- Create [`spec/pubid_new/iec/identifiers/sheet_identifier_spec.rb`](spec/pubid_new/iec/identifiers/sheet_identifier_spec.rb:1)
- Create [`spec/pubid_new/iec/identifiers/societal_technology_trend_report_spec.rb`](spec/pubid_new/iec/identifiers/societal_technology_trend_report_spec.rb:1)
- Create [`spec/pubid_new/iec/identifiers/systems_reference_document_spec.rb`](spec/pubid_new/iec/identifiers/systems_reference_document_spec.rb:1)

**Session 55:** Technical specs (3 specs)
- Create [`spec/pubid_new/iec/identifiers/technical_report_spec.rb`](spec/pubid_new/iec/identifiers/technical_report_spec.rb:1)
- Create [`spec/pubid_new/iec/identifiers/technical_specification_spec.rb`](spec/pubid_new/iec/identifiers/technical_specification_spec.rb:1)
- Create [`spec/pubid_new/iec/identifiers/technology_report_spec.rb`](spec/pubid_new/iec/identifiers/technology_report_spec.rb:1)

**Session 56:** Specialized specs (5 specs - final IEC push)
- Create [`spec/pubid_new/iec/identifiers/test_report_form_spec.rb`](spec/pubid_new/iec/identifiers/test_report_form_spec.rb:1) - Migrate from [`gems/pubid-iec/spec/pubid_iec/test_report_form_spec.rb`](gems/pubid-iec/spec/pubid_iec/test_report_form_spec.rb:1)
- Create [`spec/pubid_new/iec/identifiers/vap_identifier_spec.rb`](spec/pubid_new/iec/identifiers/vap_identifier_spec.rb:1)
- Create [`spec/pubid_new/iec/identifiers/white_paper_spec.rb`](spec/pubid_new/iec/identifiers/white_paper_spec.rb:1)
- Create [`spec/pubid_new/iec/identifiers/working_document_spec.rb`](spec/pubid_new/iec/identifiers/working_document_spec.rb:1) - Migrate from [`gems/pubid-iec/spec/pubid_iec/working_document_spec.rb`](gems/pubid-iec/spec/pubid_iec/working_document_spec.rb:1)

**Expected:** IEC 100% coverage (22/22 classes tested)

### Session 57: IEEE Spec Migration (1 session)

**Priority:** HIGH - 4 missing spec files (43% coverage)

**Create 4 specs:**
- Create [`spec/pubid_new/ieee/identifiers/dual_identifier_spec.rb`](spec/pubid_new/ieee/identifiers/dual_identifier_spec.rb:1)
- Create [`spec/pubid_new/ieee/identifiers/iec_ieee_copublished_spec.rb`](spec/pubid_new/ieee/identifiers/iec_ieee_copublished_spec.rb:1)
- Create [`spec/pubid_new/ieee/identifiers/parenthetical_identifier_spec.rb`](spec/pubid_new/ieee/identifiers/parenthetical_identifier_spec.rb:1)
- Create [`spec/pubid_new/ieee/identifiers/redlined_standard_spec.rb`](spec/pubid_new/ieee/identifiers/redlined_standard_spec.rb:1)

**Expected:** IEEE 100% coverage (7/7 classes tested)

### Session 58: NIST Spec Migration + Test Cases (1 session)

**Priority:** MEDIUM - 3 missing spec files + comprehensive test migration

**Architecture Note:** NIST V2 uses registry-based Base class for all series (SP, FIPS, IR, HB, TN, etc.). V1 had 20+ series-specific spec files with 100+ test cases that need migration to [`base_spec.rb`](spec/pubid_new/nist/identifiers/base_spec.rb:1).

**Create 3 missing specs:**
- Create [`spec/pubid_new/nist/identifiers/circular_supplement_spec.rb`](spec/pubid_new/nist/identifiers/circular_supplement_spec.rb:1) - Migrate from [`gems/pubid-nist/spec/nist_pubid/document/circ_spec.rb`](gems/pubid-nist/spec/nist_pubid/document/circ_spec.rb:1)
- Create [`spec/pubid_new/nist/identifiers/commercial_standard_emergency_spec.rb`](spec/pubid_new/nist/identifiers/commercial_standard_emergency_spec.rb:1)
- Create [`spec/pubid_new/nist/identifiers/crpl_report_spec.rb`](spec/pubid_new/nist/identifiers/crpl_report_spec.rb:1)

**Expand base_spec.rb:**
- Current: 45 lines, 12 basic test cases
- Migrate SP test cases from [`gems/pubid-nist/spec/nist_pubid/document/sp_spec.rb`](gems/pubid-nist/spec/nist_pubid/document/sp_spec.rb:1) (429 lines, 50+ tests)
- Migrate IR test cases from [`gems/pubid-nist/spec/nist_pubid/document/nist_ir_spec.rb`](gems/pubid-nist/spec/nist_pubid/document/nist_ir_spec.rb:1) (217 lines, 30+ tests)
- Identify FIPS, HB, NBS_HB, NBS_TN patterns for follow-up migration

**Expected:** NIST 100% class coverage (6/6 classes tested) + comprehensive series testing

---

## Phase 1: Documentation (Sessions 59-60)

**Prerequisites:** All spec files created (100% coverage achieved)

### Session 59: ISO Documentation

**Purpose:** Document ISO V2 achievements and prepare for production

**Tasks:**
- Update [`README.adoc`](lib/pubid_new/iso/README.adoc:1) with URN generation section (RFC 5141)
- Document harmonized stage codes (V1→V2 differences)
- Update feature completeness status (92.84% pass rate)
- Document known limitations (BundledIdentifier, DirectivesSupplement JTC)

### Session 60: V1→V2 Migration Guide

**Purpose:** Help users migrate from V1 to V2 architecture

**Tasks:**
- Create migration guide explaining architectural changes
- Document V1/V2 API differences
- Provide code examples for common patterns
- Explain TYPED_STAGES register vs V1 hash-based types
- Document namespace changes (Pubid → PubidNew)

---

## Phase 2: V1 Removal (Session 61)

**Prerequisites:** 
- ✅ 100% spec coverage across all flavors
- ✅ All documentation complete
- ✅ Production-ready status confirmed

### Session 61: Remove V1 Code

**CRITICAL:** Only execute after spec coverage verified at 100%

**Tasks:**
1. Final spec coverage audit (must be 100%)
2. Run all tests to confirm baseline
3. Delete `gems/` folder entirely
4. Rename `lib/pubid_new/` → `lib/pubid/`
5. Rename namespace `PubidNew` → `Pubid`
6. Update all requires and imports
7. Run full test suite
8. Update `README.adoc` main file
9. Update gemspec files
10. Commit with semantic message

**Success Criteria:**
- All tests passing after rename
- No V1 code remains
- Clean namespace structure
- Production-ready for release

---

## Current Status Summary

| Phase | Sessions | Status | Blocking |
|-------|----------|--------|----------|
| **Phase 0: Spec Coverage** | 51-58 | 🔴 IN PROGRESS | YES - BLOCKS V1 removal |
| Phase 1: Documentation | 59-60 | ⏸️ WAITING | Phase 0 |
| Phase 2: V1 Removal | 61 | ⏸️ WAITING | Phase 0 + 1 |

**Current Milestone:** Session 51 (IEC component specs)  
**Next Milestone:** Session 58 completion (100% spec coverage)  
**Final Milestone:** Session 61 (V1 code removal)

---

## Spec Coverage by Flavor

| Flavor | Classes | V2 Specs | Missing | Coverage | Tests Passing | Status |
|--------|---------|----------|---------|----------|---------------|--------|
| ISO | 18 | 19 | 0 | 105.6% | 2,654/2,859 (92.84%) | ✅ COMPLETE |
| IEC | 22 | 2 | 20 | 9.1% | 2,222 basic | 🔴 BLOCKS V1 |
| IEEE | 7 | 3 | 4 | 42.9% | 5,146/5,146 (100%) | 🟡 BLOCKS V1 |
| NIST | 6 | 3 | 3 | 50.0% | 57/57 (100%) | ⚠️ NEEDS MIGRATION |
| **TOTAL** | **53** | **27** | **27** | **50.9%** | **10,079 total** | **🔴 BLOCKS V1** |

---

## Key Learnings from Session 50

1. **"100% passing" is misleading** - Tests may pass but only cover subset of classes
2. **Per-class verification required** - Each identifier class needs its own spec file
3. **NIST architecture validated** - Registry pattern works, just needs test migration
4. **IEC is critical blocker** - 20 missing specs is largest gap (6 sessions needed)
5. **ISO truly complete** - Only flavor ready for V1 removal (92.84% with full coverage)

---

## Next Steps

**IMMEDIATE (Session 51):**
1. Begin IEC spec migration with component specs
2. Create 3 spec files for Session 51
3. Target ~50-100 test cases per spec
4. Ensure round-trip parsing works

**SHORT TERM (Sessions 52-58):**
1. Systematic IEC migration (Sessions 52-56)
2. IEEE migration (Session 57)
3. NIST migration + test cases (Session 58)
4. Achieve 100% spec coverage

**LONG TERM (Sessions 59-61):**
1. Complete documentation (Sessions 59-60)
2. Remove V1 code (Session 61)
3. Production release preparation

---

## Critical Path

```
Session 50 (AUDIT) → Session 51-56 (IEC) → Session 57 (IEEE) → Session 58 (NIST) → Session 59-60 (DOCS) → Session 61 (V1 REMOVAL)
     ✅                  🔴 CURRENT           🔴 BLOCKED        🔴 BLOCKED          ⏸️ WAITING         ⏸️ WAITING
```

**Estimated Completion:** 11 sessions total (8 spec + 2 docs + 1 removal)  
**Current Progress:** Session 50/61 complete  
**Blocker Status:** CRITICAL - 27 specs must be created before V1 removal