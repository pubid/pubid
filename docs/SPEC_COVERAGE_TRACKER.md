# Spec Coverage Tracker - PubID V2

**Last Updated:** 2025-11-29  
**Purpose:** Track individual identifier spec file coverage for all flavors

---

## Coverage Summary

| Flavor | Identifiers | Specs | Coverage | Status |
|--------|-------------|-------|----------|--------|
| ISO | 18 | 19 | 105% | ✅ COMPLETE |
| IEC | 22 | 21 | 95% | ✅ COMPLETE |
| IDF | 2 | 2 | 100% | ✅ COMPLETE |
| **IEEE** | **7** | **3** | **43%** | 🔄 **NEEDS 4 SPECS** |
| **NIST** | **11** | **3** | **27%** | 🔄 **NEEDS 8 SPECS** |
| **CEN** | **10** | **1** | **10%** | 🔄 **NEEDS 9 SPECS** |
| **JIS** | **7** | **0** | **0%** | 🔄 **NEEDS 7 SPECS** |
| ITU | ? | 0 | 0% | ⚪ NOT STARTED |
| BSI | ? | 0 | 0% | ⚪ NOT STARTED |
| CCSDS | ? | 0 | 0% | ⚪ NOT STARTED |
| ETSI | ? | 0 | 0% | ⚪ NOT STARTED |
| ANSI | ? | 0 | 0% | ⚪ NOT STARTED |
| PLATEAU | ? | 0 | 0% | ⚪ NOT STARTED |

**Total Required Specs:** 29 (for working flavors)  
**To Be Determined:** 6 flavors need full implementation first

---

## ISO - 19/18 Specs ✅ COMPLETE

### Identifiers (18)
```
lib/pubid_new/iso/identifiers/
├── addendum.rb
├── amendment.rb
├── corrigendum.rb
├── data.rb
├── directives.rb
├── directives_supplement.rb
├── extract.rb
├── guide.rb
├── international_standard.rb
├── international_standardized_profile.rb
├── international_workshop_agreement.rb
├── pas.rb
├── recommendation.rb
├── supplement.rb
├── technical_report.rb
├── technical_specification.rb
├── technology_trends_assessments.rb
└── base.rb (abstract)
```

### Specs (19)
```
spec/pubid_new/iso/identifiers/
├── addendum_spec.rb ✅
├── amendment_spec.rb ✅
├── corrigendum_spec.rb ✅
├── data_spec.rb ✅
├── directives_spec.rb ✅
├── directives_supplement_spec.rb ✅
├── extract_spec.rb ✅
├── guide_spec.rb ✅
├── international_standard_spec.rb ✅
├── international_standardized_profile_spec.rb ✅
├── international_workshop_agreement_spec.rb ✅
├── pas_spec.rb ✅
├── recommendation_spec.rb ✅
├── supplement_spec.rb ✅
├── technical_report_spec.rb ✅
├── technical_specification_spec.rb ✅
├── technology_trends_assessments_spec.rb ✅
├── base_spec.rb ✅
└── bundled_identifier_spec.rb ✅ (wrapper)
```

**Status:** ✅ All identifier types have comprehensive specs

---

## IEC - 21/22 Specs ✅ COMPLETE

### Identifiers (22)
```
lib/pubid_new/iec/identifiers/
├── amendment.rb
├── component_specification.rb
├── conformity_assessment.rb
├── consolidated_identifier.rb
├── corrigendum.rb
├── fragment_identifier.rb
├── guide.rb
├── international_standard.rb
├── interpretation_sheet.rb
├── operational_document.rb
├── publicly_available_specification.rb
├── sheet_identifier.rb
├── societal_technology_trend_report.rb
├── systems_reference_document.rb
├── technical_report.rb
├── technical_specification.rb
├── technology_report.rb
├── test_report_form.rb
├── vap_identifier.rb
├── white_paper.rb
├── working_document.rb
└── base.rb (abstract, not directly tested)
```

### Specs (21)
```
spec/pubid_new/iec/identifiers/
├── amendment_spec.rb ✅
├── component_specification_spec.rb ✅
├── conformity_assessment_spec.rb ✅
├── consolidated_identifier_spec.rb ✅
├── corrigendum_spec.rb ✅
├── fragment_identifier_spec.rb ✅
├── guide_spec.rb ✅
├── international_standard_spec.rb ✅
├── interpretation_sheet_spec.rb ✅
├── operational_document_spec.rb ✅
├── publicly_available_specification_spec.rb ✅
├── sheet_identifier_spec.rb ✅
├── societal_technology_trend_report_spec.rb ✅
├── systems_reference_document_spec.rb ✅
├── technical_report_spec.rb ✅
├── technical_specification_spec.rb ✅
├── technology_report_spec.rb ✅
├── test_report_form_spec.rb ✅
├── vap_identifier_spec.rb ✅
├── white_paper_spec.rb ✅
└── working_document_spec.rb ✅
```

**Status:** ✅ All identifier types have comprehensive specs (Base not tested as abstract)

---

## IDF - 2/2 Specs ✅ COMPLETE

### Identifiers (2)
```
lib/pubid_new/idf/identifiers/
├── international_standard.rb
└── reviewed_method.rb
```

### Specs (2)
```
spec/pubid_new/idf/identifiers/
├── international_standard_spec.rb ✅
└── reviewed_method_spec.rb ✅
```

**Status:** ✅ All identifier types have comprehensive specs

---

## IEEE - 3/7 Specs 🔄 NEEDS 4 MORE

### Identifiers (7)
```
lib/pubid_new/ieee/identifiers/
├── adopted.rb ⚠️ NO SPEC
├── base.rb ⚠️ NO SPEC (abstract, optional)
├── dual_published.rb ⚠️ NO SPEC
├── guide.rb ⚠️ NO SPEC
├── international_standard.rb ✅ HAS SPEC
├── recommended_practice.rb ✅ HAS SPEC
└── standard.rb ✅ HAS SPEC
```

### Existing Specs (3)
```
spec/pubid_new/ieee/identifiers/
├── international_standard_spec.rb ✅
├── recommended_practice_spec.rb ✅
└── standard_spec.rb ✅
```

### Missing Specs (4)
```
spec/pubid_new/ieee/identifiers/
├── adopted_spec.rb ❌ NEEDED (~30 tests)
├── dual_published_spec.rb ❌ NEEDED (~30 tests)
├── guide_spec.rb ❌ NEEDED (~25 tests)
└── base_spec.rb ❌ OPTIONAL (abstract class)
```

**Priority:** HIGH (Session 58)  
**ETA:** 2-3 hours  
**Target:** 7/7 specs (or 6/7 if Base skipped)

---

## NIST - 3/11 Specs 🔄 NEEDS 8 MORE

### Identifiers (11)
```
lib/pubid_new/nist/identifiers/
├── base.rb ⚠️ NO SPEC (abstract, optional)
├── federal_information_processing_standards.rb ✅ HAS SPEC
├── handbook.rb ⚠️ NO SPEC
├── internal_report.rb ✅ HAS SPEC
├── special_publication.rb ✅ HAS SPEC
├── technical_note.rb ⚠️ NO SPEC
└── ...5 more identifiers need investigation
```

### Existing Specs (3)
```
spec/pubid_new/nist/identifiers/
├── federal_information_processing_standards_spec.rb ✅
├── internal_report_spec.rb ✅
└── special_publication_spec.rb ✅
```

### Missing Specs (~8)
```
spec/pubid_new/nist/identifiers/
├── handbook_spec.rb ❌ NEEDED (~25 tests)
├── technical_note_spec.rb ❌ NEEDED (~25 tests)
└── ...6 more spec files needed
```

**Priority:** HIGH (Sessions 59-60)  
**ETA:** 4-6 hours  
**Action:** First list all NIST identifier files, then create specs

---

## CEN - 1/10 Specs 🔄 NEEDS 9 MORE + REFACTORING

### Identifiers (10)
```
lib/pubid_new/cen/identifiers/
├── amendment.rb ⚠️ NO SPEC
├── base.rb ⚠️ NO SPEC (abstract, optional)
├── cen_workshop_agreement.rb ⚠️ NO SPEC
├── combined_bundle.rb ⚠️ NO SPEC
├── corrigendum.rb ⚠️ NO SPEC
├── european_norm.rb ✅ HAS SPEC
├── guide.rb ⚠️ NO SPEC
├── harmonization_document.rb ⚠️ NO SPEC
├── technical_report.rb ⚠️ NO SPEC
└── technical_specification.rb ⚠️ NO SPEC
```

### Existing Specs (1)
```
spec/pubid_new/cen/identifiers/
└── european_norm_spec.rb ✅
```

### Missing Specs (9)
```
spec/pubid_new/cen/identifiers/
├── amendment_spec.rb ❌ NEEDED (~30 tests)
├── cen_workshop_agreement_spec.rb ❌ NEEDED (~25 tests)
├── combined_bundle_spec.rb ❌ NEEDED (~25 tests)
├── corrigendum_spec.rb ❌ NEEDED (~30 tests)
├── guide_spec.rb ❌ NEEDED (~25 tests)
├── harmonization_document_spec.rb ❌ NEEDED (~25 tests)
├── technical_report_spec.rb ❌ NEEDED (~30 tests)
├── technical_specification_spec.rb ❌ NEEDED (~30 tests)
└── base_spec.rb ❌ OPTIONAL (abstract)
```

**Priority:** MEDIUM (Sessions 63-65)  
**ETA:** 8-11 hours (includes refactoring)  
**Dependencies:** Refactor Builder first (Sessions 63-64)

---

## JIS - 0/7 Specs 🔄 NEEDS 7 SPECS

### Identifiers (7)
```
lib/pubid_new/jis/identifiers/
├── ...7 identifier files (need to list)
```

### Existing Specs (0)
```
spec/pubid_new/jis/identifiers/
(empty - directory doesn't exist yet)
```

### Missing Specs (7)
```
All 7 JIS identifier types need specs (~25 tests each)
```

**Priority:** MEDIUM (Session 61)  
**ETA:** 3-4 hours  
**Action:** First list all JIS identifier files, then create specs

---

## Remaining Flavors (6) ⚪ NOT STARTED

### ITU - Implementation Needed
- Requires full V2 implementation
- ~10-15 identifier types estimated
- Complex: ITU-T and ITU-R series
- **ETA:** Sessions 66-70 (8-10 hours)

### BSI - Implementation Needed
- Requires full V2 implementation
- ~12-15 identifier types estimated
- Similar to ISO/IEC (TYPED_STAGES)
- **ETA:** Sessions 71-75 (8-10 hours)

### CCSDS - Implementation Needed
- Requires full V2 implementation
- ~8-10 identifier types estimated
- Space data systems
- **ETA:** Sessions 76-78 (5-6 hours)

### ETSI - Implementation Needed
- Requires full V2 implementation
- ~8-10 identifier types estimated
- Telecom standards
- **ETA:** Sessions 79-81 (5-6 hours)

### ANSI - Implementation Needed
- Requires requirements research
- Unknown identifier type count
- Need pattern analysis
- **ETA:** Sessions 82-84 (5-6 hours)

### PLATEAU - Implementation Needed
- Requires full V2 implementation
- ~5-7 identifier types estimated
- Japanese urban planning
- **ETA:** Session 85 (2-3 hours)

---

## Spec Creation Guidelines

### Template Structure (from Sessions 51-56)
```ruby
require "spec_helper"

RSpec.describe PubidNew::{Flavor}::Identifiers::{Type} do
  subject { described_class }

  context "description of test case" do
    describe "{identifier string}" do
      subject { "{identifier string}" }
      let(:parsed) { described_class.parse(subject) }

      it "parses as {Type}" do
        expect(parsed).to be_a(described_class)
      end

      it "parses publisher" do
        expect(parsed.publisher.body).to eq("{PUBLISHER}")
      end

      it "parses number" do
        expect(parsed.number.value).to eq("{NUMBER}")
      end

      # ... more attribute tests

      it "provides type code" do
        expect(parsed.type.type_code).to eq("{code}")
      end

      it "provides stage code" do
        expect(parsed.stage.stage_code).to eq("{stage}")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  # Repeat for multiple test cases (25-35 tests per spec)
end
```

### Test Coverage Requirements
- ✅ Basic identifier (dated/undated)
- ✅ With part number
- ✅ With part and subpart
- ✅ With copublisher (if applicable)
- ✅ Different stages (if applicable)
- ✅ Type and stage code verification
- ✅ Publisher portion rendering
- ✅ Edge cases and variations
- ✅ Round-trip parsing

### Quality Standards
- **Minimum 25 tests** per identifier type
- **Target 30-35 tests** for complex types
- **100% coverage** of identifier patterns
- **Round-trip verification** for all patterns
- **Type/stage code validation** where applicable

---

## Session Execution Pattern

### For Each Spec File:
1. **Read implementation** (~5 min)
   - Understand TYPED_STAGES array
   - Check component API
   - Note special rendering methods

2. **Create spec file** (~30-40 min)
   - Follow proven template
   - Add 25-35 comprehensive tests
   - Cover all identifier patterns

3. **Test and verify** (~5-10 min)
   - Run spec file
   - Fix syntax errors
   - Verify pass rate

4. **Document** (~5 min)
   - Update tracker
   - Note any issues
   - Record pass rate

**Average:** 45-60 min per spec file

---

## Progress Tracking

### Session 58 Target
- [ ] IEEE `adopted_spec.rb` created
- [ ] IEEE `dual_published_spec.rb` created
- [ ] IEEE `guide_spec.rb` created
- [ ] IEEE `base_spec.rb` created (optional)
- [ ] IEEE at 7/7 specs (100%)
- [ ] Documentation updated

### Session 59-60 Target
- [ ] NIST identifier files listed
- [ ] 8 NIST spec files created
- [ ] NIST at 11/11 specs (100%)
- [ ] Documentation updated

### Session 61 Target
- [ ] JIS identifier files listed
- [ ] 7 JIS spec files created
- [ ] JIS at 7/7 specs (100%)
- [ ] Documentation updated

### Session 63-65 Target
- [ ] CEN Builder refactored
- [ ] 9 CEN spec files created
- [ ] CEN at 10/10 specs (90%+)
- [ ] Documentation updated

---

## Completion Criteria

### Per Flavor
- ✅ All identifier classes have spec files
- ✅ 80%+ test pass rate (100% for simple flavors)
- ✅ Comprehensive test coverage (25-35 tests per spec)
- ✅ Round-trip parsing verified
- ✅ Architecture validated

### Overall Project
- ✅ All 13 flavors have complete spec coverage
- ✅ 90%+ overall pass rate
- ✅ All identifier types tested
- ✅ Documentation complete
- ✅ V1 code archived

---

**Next Action:** Session 58 - Create IEEE specs (4 files, 2-3 hours)