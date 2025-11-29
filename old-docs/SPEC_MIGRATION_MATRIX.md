# Spec Migration Matrix - V1 to V2

**Generated:** 2025-11-28  
**Purpose:** Complete mapping of all identifier classes to spec files for V1 removal readiness

---

## Executive Summary

**Total Gap:** 27 missing spec files across 4 flavors  
**Critical:** IEC (20 missing), IEEE (4 missing), NIST (3 missing + test migration)

**Key Finding:** NIST V2 uses REGISTRY-BASED architecture (6 classes handle all series types via `series` attribute), while V1 had 20+ individual classes. V2 needs test case migration, not new classes.

---

## ISO: ✅ COMPLETE (100%)

**Status:** All identifier classes have spec coverage + extras  
**Coverage:** 18/18 identifier classes tested (105.6% with TC tests)

| Class File | V2 Spec | Status |
|-----------|---------|--------|
| [`addendum.rb`](lib/pubid_new/iso/identifiers/addendum.rb:1) | [`addendum_spec.rb`](spec/pubid_new/iso/identifiers/addendum_spec.rb:1) | ✅ COMPLETE |
| [`amendment.rb`](lib/pubid_new/iso/identifiers/amendment.rb:1) | [`amendment_spec.rb`](spec/pubid_new/iso/identifiers/amendment_spec.rb:1) | ✅ COMPLETE |
| [`base.rb`](lib/pubid_new/iso/identifiers/base.rb:1) | (tested via subclasses) | ✅ COMPLETE |
| [`corrigendum.rb`](lib/pubid_new/iso/identifiers/corrigendum.rb:1) | [`corrigendum_spec.rb`](spec/pubid_new/iso/identifiers/corrigendum_spec.rb:1) | ✅ COMPLETE |
| [`data.rb`](lib/pubid_new/iso/identifiers/data.rb:1) | [`data_spec.rb`](spec/pubid_new/iso/identifiers/data_spec.rb:1) | ✅ COMPLETE |
| [`directives.rb`](lib/pubid_new/iso/identifiers/directives.rb:1) | [`directives_spec.rb`](spec/pubid_new/iso/identifiers/directives_spec.rb:1) | ✅ COMPLETE |
| [`directives_supplement.rb`](lib/pubid_new/iso/identifiers/directives_supplement.rb:1) | [`directives_supplement_spec.rb`](spec/pubid_new/iso/identifiers/directives_supplement_spec.rb:1) | ✅ COMPLETE |
| [`extract.rb`](lib/pubid_new/iso/identifiers/extract.rb:1) | [`extract_spec.rb`](spec/pubid_new/iso/identifiers/extract_spec.rb:1) | ✅ COMPLETE |
| [`guide.rb`](lib/pubid_new/iso/identifiers/guide.rb:1) | [`guide_spec.rb`](spec/pubid_new/iso/identifiers/guide_spec.rb:1) | ✅ COMPLETE |
| [`international_standard.rb`](lib/pubid_new/iso/identifiers/international_standard.rb:1) | [`international_standard_spec.rb`](spec/pubid_new/iso/identifiers/international_standard_spec.rb:1) | ✅ COMPLETE |
| [`international_standardized_profile.rb`](lib/pubid_new/iso/identifiers/international_standardized_profile.rb:1) | [`international_standardized_profile_spec.rb`](spec/pubid_new/iso/identifiers/international_standardized_profile_spec.rb:1) | ✅ COMPLETE |
| [`international_workshop_agreement.rb`](lib/pubid_new/iso/identifiers/international_workshop_agreement.rb:1) | [`international_workshop_agreement_spec.rb`](spec/pubid_new/iso/identifiers/international_workshop_agreement_spec.rb:1) | ✅ COMPLETE |
| [`pas.rb`](lib/pubid_new/iso/identifiers/pas.rb:1) | [`pas_spec.rb`](spec/pubid_new/iso/identifiers/pas_spec.rb:1) | ✅ COMPLETE |
| [`recommendation.rb`](lib/pubid_new/iso/identifiers/recommendation.rb:1) | [`recommendation_spec.rb`](spec/pubid_new/iso/identifiers/recommendation_spec.rb:1) | ✅ COMPLETE |
| [`supplement.rb`](lib/pubid_new/iso/identifiers/supplement.rb:1) | [`supplement_spec.rb`](spec/pubid_new/iso/identifiers/supplement_spec.rb:1) | ✅ COMPLETE |
| [`technical_report.rb`](lib/pubid_new/iso/identifiers/technical_report.rb:1) | [`technical_report_spec.rb`](spec/pubid_new/iso/identifiers/technical_report_spec.rb:1) | ✅ COMPLETE |
| [`technical_specification.rb`](lib/pubid_new/iso/identifiers/technical_specification.rb:1) | [`technical_specification_spec.rb`](spec/pubid_new/iso/identifiers/technical_specification_spec.rb:1) | ✅ COMPLETE |
| [`technology_trends_assessments.rb`](lib/pubid_new/iso/identifiers/technology_trends_assessments.rb:1) | [`technology_trends_assessment_spec.rb`](spec/pubid_new/iso/identifiers/technology_trends_assessment_spec.rb:1) | ✅ COMPLETE |
| N/A | [`tc_document_spec.rb`](spec/pubid_new/iso/identifiers/tc_document_spec.rb:1) | ➕ EXTRA (TC documents) |
| N/A | [`tc_spec.rb`](spec/pubid_new/iso/identifiers/tc_spec.rb:1) | ➕ EXTRA (TC) |

**V1 References:** 14 spec files  
**V2 Specs:** 19 files (18 identifier classes + 2 extras)  
**Achievement:** 92.84% test pass rate (2,654/2,859 tests)

---

## IEC: ❌ CRITICAL - 20 MISSING (9% coverage)

**Status:** BLOCKS V1 REMOVAL - Only 2/22 classes tested  
**Priority:** CRITICAL SESSION 51-56  
**Gap:** 20 missing spec files

| Class File | V2 Spec | V1 Reference | Status |
|-----------|---------|--------------|--------|
| [`amendment.rb`](lib/pubid_new/iec/identifiers/amendment.rb:1) | [`amendment_spec.rb`](spec/pubid_new/iec/identifiers/amendment_spec.rb:1) | ✅ | ✅ COMPLETE |
| [`base.rb`](lib/pubid_new/iec/identifiers/base.rb:1) | (tested via subclasses) | ✅ | ✅ COMPLETE |
| [`component_specification.rb`](lib/pubid_new/iec/identifiers/component_specification.rb:1) | ❌ MISSING | ? | 🔴 SESSION 51 |
| [`conformity_assessment.rb`](lib/pubid_new/iec/identifiers/conformity_assessment.rb:1) | ❌ MISSING | ? | 🔴 SESSION 51 |
| [`consolidated_identifier.rb`](lib/pubid_new/iec/identifiers/consolidated_identifier.rb:1) | ❌ MISSING | ? | 🔴 SESSION 51 |
| [`corrigendum.rb`](lib/pubid_new/iec/identifiers/corrigendum.rb:1) | ❌ MISSING | ✅ | 🔴 SESSION 52 |
| [`fragment_identifier.rb`](lib/pubid_new/iec/identifiers/fragment_identifier.rb:1) | ❌ MISSING | ? | 🔴 SESSION 52 |
| [`guide.rb`](lib/pubid_new/iec/identifiers/guide.rb:1) | ❌ MISSING | ? | 🔴 SESSION 52 |
| [`international_standard.rb`](lib/pubid_new/iec/identifiers/international_standard.rb:1) | [`international_standard_spec.rb`](spec/pubid_new/iec/identifiers/international_standard_spec.rb:1) | ✅ | ✅ COMPLETE |
| [`interpretation_sheet.rb`](lib/pubid_new/iec/identifiers/interpretation_sheet.rb:1) | ❌ MISSING | ? | 🔴 SESSION 53 |
| [`operational_document.rb`](lib/pubid_new/iec/identifiers/operational_document.rb:1) | ❌ MISSING | ? | 🔴 SESSION 53 |
| [`publicly_available_specification.rb`](lib/pubid_new/iec/identifiers/publicly_available_specification.rb:1) | ❌ MISSING | ? | 🔴 SESSION 53 |
| [`sheet_identifier.rb`](lib/pubid_new/iec/identifiers/sheet_identifier.rb:1) | ❌ MISSING | ? | 🔴 SESSION 54 |
| [`societal_technology_trend_report.rb`](lib/pubid_new/iec/identifiers/societal_technology_trend_report.rb:1) | ❌ MISSING | ? | 🔴 SESSION 54 |
| [`systems_reference_document.rb`](lib/pubid_new/iec/identifiers/systems_reference_document.rb:1) | ❌ MISSING | ? | 🔴 SESSION 54 |
| [`technical_report.rb`](lib/pubid_new/iec/identifiers/technical_report.rb:1) | ❌ MISSING | ? | 🔴 SESSION 55 |
| [`technical_specification.rb`](lib/pubid_new/iec/identifiers/technical_specification.rb:1) | ❌ MISSING | ? | 🔴 SESSION 55 |
| [`technology_report.rb`](lib/pubid_new/iec/identifiers/technology_report.rb:1) | ❌ MISSING | ? | 🔴 SESSION 55 |
| [`test_report_form.rb`](lib/pubid_new/iec/identifiers/test_report_form.rb:1) | ❌ MISSING | ✅ [`test_report_form_spec.rb`](gems/pubid-iec/spec/pubid_iec/test_report_form_spec.rb:1) | 🔴 SESSION 56 |
| [`vap_identifier.rb`](lib/pubid_new/iec/identifiers/vap_identifier.rb:1) | ❌ MISSING | ? | 🔴 SESSION 56 |
| [`white_paper.rb`](lib/pubid_new/iec/identifiers/white_paper.rb:1) | ❌ MISSING | ? | 🔴 SESSION 56 |
| [`working_document.rb`](lib/pubid_new/iec/identifiers/working_document.rb:1) | ❌ MISSING | ✅ [`working_document_spec.rb`](gems/pubid-iec/spec/pubid_iec/working_document_spec.rb:1) | 🔴 SESSION 56 |

**V1 References:** 6 spec files (base, create, parser, test_report_form, trf_parser, working_document)  
**V2 Specs:** 2 files (9% coverage)  
**Achievement:** Unknown (only 2,222 basic tests, integration not run)

**Session Plan:**
- Session 51: component_specification, conformity_assessment, consolidated_identifier (3 specs)
- Session 52: corrigendum, fragment_identifier, guide (3 specs)
- Session 53: interpretation_sheet, operational_document, publicly_available_specification (3 specs)
- Session 54: sheet_identifier, societal_technology_trend_report, systems_reference_document (3 specs)
- Session 55: technical_report, technical_specification, technology_report (3 specs)
- Session 56: test_report_form, vap_identifier, white_paper, working_document (4 specs)

---

## IEEE: ⚠️ HIGH - 4 MISSING (43% coverage)

**Status:** HIGH PRIORITY - 4 missing classes  
**Priority:** SESSION 57  
**Gap:** 4 missing spec files

| Class File | V2 Spec | V1 Reference | Status |
|-----------|---------|--------------|--------|
| [`adopted_standard.rb`](lib/pubid_new/ieee/identifiers/adopted_standard.rb:1) | [`adopted_standard_spec.rb`](spec/pubid_new/ieee/identifiers/adopted_standard_spec.rb:1) | ✅ | ✅ COMPLETE |
| [`base.rb`](lib/pubid_new/ieee/identifiers/base.rb:1) | [`base_spec.rb`](spec/pubid_new/ieee/identifiers/base_spec.rb:1) | ✅ | ✅ COMPLETE |
| [`dual_identifier.rb`](lib/pubid_new/ieee/identifiers/dual_identifier.rb:1) | ❌ MISSING | ? | 🟡 SESSION 57 |
| [`dual_published.rb`](lib/pubid_new/ieee/identifiers/dual_published.rb:1) | [`dual_published_spec.rb`](spec/pubid_new/ieee/identifiers/dual_published_spec.rb:1) | ✅ | ✅ COMPLETE |
| [`iec_ieee_copublished.rb`](lib/pubid_new/ieee/identifiers/iec_ieee_copublished.rb:1) | ❌ MISSING | ? | 🟡 SESSION 57 |
| [`parenthetical_identifier.rb`](lib/pubid_new/ieee/identifiers/parenthetical_identifier.rb:1) | ❌ MISSING | ? | 🟡 SESSION 57 |
| [`redlined_standard.rb`](lib/pubid_new/ieee/identifiers/redlined_standard.rb:1) | ❌ MISSING | ? | 🟡 SESSION 57 |

**V1 References:** 5 spec files (base, create, identifier, identifiers_parsing, parser)  
**V2 Specs:** 3 files (43% coverage)  
**Achievement:** 100% (5,146/5,146 tests) **BUT only base identifiers tested**

**Session Plan:**
- Session 57: dual_identifier, iec_ieee_copublished, parenthetical_identifier, redlined_standard (4 specs in one session)

---

## NIST: ⚠️ SPECIAL CASE - 3 MISSING + TEST MIGRATION (50% coverage)

**Status:** ARCHITECTURE INVESTIGATION REQUIRED  
**Priority:** SESSION 58  
**Gap:** 3 missing spec files + comprehensive test case migration

| Class File | V2 Spec | V1 Series Specs | Status |
|-----------|---------|-----------------|--------|
| [`base.rb`](lib/pubid_new/nist/identifiers/base.rb:1) | [`base_spec.rb`](spec/pubid_new/nist/identifiers/base_spec.rb:1) | SP, FIPS, IR, HB, NBS_HB, NBS_TN, etc. | ⚠️ BASIC ONLY |
| [`circular.rb`](lib/pubid_new/nist/identifiers/circular.rb:1) | [`circular_spec.rb`](spec/pubid_new/nist/identifiers/circular_spec.rb:1) | [`circ_spec.rb`](gems/pubid-nist/spec/nist_pubid/document/circ_spec.rb:1) | ✅ COMPLETE |
| [`circular_supplement.rb`](lib/pubid_new/nist/identifiers/circular_supplement.rb:1) | ❌ MISSING | circ_spec.rb | 🟡 SESSION 58 |
| [`commercial_standard_emergency.rb`](lib/pubid_new/nist/identifiers/commercial_standard_emergency.rb:1) | ❌ MISSING | ? | 🟡 SESSION 58 |
| [`commercial_standards_monthly.rb`](lib/pubid_new/nist/identifiers/commercial_standards_monthly.rb:1) | [`commercial_standards_monthly_spec.rb`](spec/pubid_new/nist/identifiers/commercial_standards_monthly_spec.rb:1) | ? | ✅ COMPLETE |
| [`crpl_report.rb`](lib/pubid_new/nist/identifiers/crpl_report.rb:1) | ❌ MISSING | ? | 🟡 SESSION 58 |

**Architecture Notes:**

V2 NIST uses REGISTRY-BASED approach:
- `Identifiers::Base` handles ALL series types (SP, FIPS, IR, HB, TN, etc.) via `series` attribute
- Only specialized patterns get dedicated classes (Circular, CrplReport, etc.)
- V1 had 20+ spec files for series-specific tests, but V2 needs test case MIGRATION not new classes

**V1 Test Files to Migrate (20 files):**
1. [`sp_spec.rb`](gems/pubid-nist/spec/nist_pubid/document/sp_spec.rb:1) - 429 lines, ~50+ test cases → Add to [`base_spec.rb`](spec/pubid_new/nist/identifiers/base_spec.rb:1)
2. [`nist_ir_spec.rb`](gems/pubid-nist/spec/nist_pubid/document/nist_ir_spec.rb:1) - 217 lines, ~30+ test cases → Add to base_spec.rb
3. `fips_spec.rb` - FIPS series patterns → Add to base_spec.rb
4. `hb_spec.rb` - Handbook series patterns → Add to base_spec.rb
5. `nbs_hb_spec.rb` - NBS Handbook patterns → Add to base_spec.rb
6. `nbs_tn_spec.rb` - NBS Technical Note patterns → Add to base_spec.rb
7. 14 other V1 spec files (parser, series, edition, stage, publisher, etc.)

**Current base_spec.rb:** Only 45 lines, 12 basic test cases  
**Need:** Comprehensive migration of 100+ test cases from V1 series specs

**V1 References:** 20 spec files  
**V2 Specs:** 3 files (50% of specialized classes, but needs test migration)  
**Achievement:** 100% (57/57 tests) **BUT missing series-specific patterns**

**Session 58 Plan:**
1. Create 3 missing spec files (circular_supplement, commercial_standard_emergency, crpl_report)
2. Migrate ALL SP test cases from [`sp_spec.rb`](gems/pubid-nist/spec/nist_pubid/document/sp_spec.rb:1) to [`base_spec.rb`](spec/pubid_new/nist/identifiers/base_spec.rb:1)
3. Migrate ALL IR test cases from [`nist_ir_spec.rb`](gems/pubid-nist/spec/nist_pubid/document/nist_ir_spec.rb:1) to base_spec.rb
4. Plan remaining series migrations (FIPS, HB, etc.) for follow-up sessions

---

## Summary by Priority

### CRITICAL (Session 51-56): IEC
- **Gap:** 20 missing spec files
- **Coverage:** 2/22 (9%)
- **Impact:** BLOCKS V1 removal completely
- **Sessions:** 6 sessions @ 3-4 specs each

### HIGH (Session 57): IEEE
- **Gap:** 4 missing spec files
- **Coverage:** 3/7 (43%)
- **Impact:** Significant testing gap
- **Sessions:** 1 session for all 4 specs

### MEDIUM (Session 58): NIST
- **Gap:** 3 missing spec files + test migration
- **Coverage:** 3/6 classes (50%), but only 12 basic tests
- **Impact:** Architecture validated, needs comprehensive testing
- **Sessions:** 1 session for specs + migration start

### COMPLETE: ISO
- **Gap:** 0 missing specs
- **Coverage:** 18/18 (100%) + 2 extras
- **Impact:** Ready for V1 removal
- **Status:** 92.84% pass rate, production-ready

---

## Overall Statistics

| Flavor | Classes | V2 Specs | Missing | Coverage | Status |
|--------|---------|----------|---------|----------|--------|
| ISO | 18 | 19 | 0 | 105.6% | ✅ COMPLETE |
| IEC | 22 | 2 | 20 | 9.1% | 🔴 CRITICAL |
| IEEE | 7 | 3 | 4 | 42.9% | 🟡 HIGH |
| NIST | 6 | 3 | 3 | 50.0% | ⚠️ SPECIAL |
| **TOTAL** | **53** | **27** | **27** | **50.9%** | **BLOCKS V1** |

**Critical Path:** IEC → IEEE → NIST → V1 Removal  
**Estimated Sessions:** 8 sessions (6 IEC + 1 IEEE + 1 NIST)  
**Blocker:** Cannot remove V1 code until 100% spec coverage achieved

---

## Next Steps

1. **Session 51-56:** IEC spec migration (20 specs, 6 sessions)
2. **Session 57:** IEEE spec migration (4 specs, 1 session)
3. **Session 58:** NIST spec migration + test cases (3 specs + migration, 1 session)
4. **Session 59:** Verify 100% coverage across all flavors
5. **Session 60:** V1 removal preparation (final audit)
6. **Session 61:** Remove V1 code (ONLY after 100% coverage)

---

## V1 Removal Criteria

✅ ISO: Ready (100% coverage, 92.84% pass rate)  
❌ IEC: BLOCKS (9% coverage, 20 missing specs)  
❌ IEEE: BLOCKS (43% coverage, 4 missing specs)  
⚠️ NIST: PARTIAL (50% class coverage, needs test migration)

**Status:** **BLOCKED** - Cannot proceed with V1 removal until all gaps closed