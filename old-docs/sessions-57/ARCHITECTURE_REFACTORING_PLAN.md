# Architecture Refactoring Plan - MODEL-DRIVEN Pattern for All Flavors

**Created:** 2025-11-28  
**Goal:** Ensure ALL flavors follow clean MODEL-DRIVEN architecture with complete spec coverage  
**Deadline:** ASAP - Compressed timeline

---

## Core Architectural Principles

### 1. ONE CLASS PER TYPE (CRITICAL)
- One identifier class per document/standard type
- NOT one base class handling all types via attributes
- Example: ISO has InternationalStandard, TechnicalReport, TechnicalSpecification, Guide, etc.
- Example: NIST now has SpecialPublication, InternalReport, Handbook, TechnicalNote, etc.

### 2. COMPONENTS ARE SHARED
- Volume, parts, revisions, editions → Components (NOT class inheritance)
- Publisher, Code, Date, Edition, Language, Stage, Type → Component classes
- Components inherit from Lutaml::Model::Serializable

### 3. CLEAN BUILDER PATTERN
- `Builder.new(scheme)` - Receives Scheme for lookups
- Single `cast()` method handles ALL conversions
- NO hardcoded business logic in Builder
- Composite hash returns for related values

### 4. SCHEME REGISTRY
- Scheme class provides identifier class registry
- `locate_typed_stage_by_abbr()` or `series_to_class_map()` depending on flavor
- `locate_identifier_klass()` determines correct class from parsed data

### 5. COMPLETE SPEC COVERAGE
- **Every identifier class** MUST have its own spec file
- **Every component class** SHOULD have its own spec file (if complex logic)
- NO gaps in per-class testing

---

## Implementation Status by Flavor

### ✅ ISO - COMPLETE (Reference Implementation)
**Status:** 100% MODEL-DRIVEN, 92.84% tests passing (2,654/2,859)

**Architecture:**
- ✅ Scheme class with TYPED_STAGES registry
- ✅ Builder with clean cast() pattern
- ✅ Components: Publisher, Code, Date, Edition, Language, Stage, Type, TypedStage
- ✅ 18 identifier classes (one per type):
  - InternationalStandard, TechnicalReport, TechnicalSpecification
  - Guide, PAS, Data, TechnologyTrendsAssessments
  - InternationalWorkshopAgreement, InternationalStandardizedProfile
  - Recommendation, Directives
  - Amendment, Corrigendum, Supplement, Extract, Addendum
  - DirectivesSupplement

**Spec Coverage:**
- ✅ 19 identifier spec files (100% coverage + 2 extras)
- ✅ All components tested
- ✅ Parser, Builder, Scheme tested

**Status:** Production-ready reference implementation

---

### ✅ NIST - COMPLETE (Just Refactored)
**Status:** 100% MODEL-DRIVEN, 100% tests passing (57/57)

**Architecture:**
- ✅ Scheme class with series-to-class registry
- ✅ Builder with clean cast() pattern
- ✅ Components: Publisher, Code (plus shared Date, Edition, etc.)
- ✅ 11 identifier classes (one per series type):
  - SpecialPublication (SP)
  - FederalInformationProcessingStandards (FIPS)
  - InternalReport (IR)
  - Handbook (HB)
  - TechnicalNote (TN)
  - Circular (CIRC)
  - CircularSupplement, CrplReport
  - CommercialStandardEmergency, CommercialStandardsMonthly
  - Base (fallback)

**Spec Coverage:**
- ✅ 3 identifier spec files (base, circular, csm)
- ⚠️ MISSING: 8 per-series spec files (SP, FIPS, IR, HB, TN, etc.)
- ✅ Parser, Builder tested

**Status:** Architecture complete, needs spec expansion (Session 51+)

---

### ⚠️ IEC - PARTIAL (Architecture Started, Needs Completion)
**Status:** ~40% MODEL-DRIVEN, 63.16% tests passing (2,469/3,910)

**Current State:**
- ⚠️ Has some identifier classes but incomplete
- ⚠️ Builder exists but may need cast() refactoring
- ⚠️ Components partially implemented
- ⚠️ 22 identifier classes defined, but architecture unclear

**Required Work:**
1. **Audit current architecture** - Determine if MODEL-DRIVEN
2. **Create/update Scheme class** - TYPED_STAGES or series registry
3. **Refactor Builder** - Ensure clean cast() pattern
4. **Verify Components** - Publisher, Code, etc.
5. **Create missing specs** - 20 missing per Session 50 audit

**Identifier Classes (22 total):**
- InternationalStandard, TechnicalReport, TechnicalSpecification
- Guide, PubliclyAvailableSpecification
- Amendment, Corrigendum
- ComponentSpecification, ConformityAssessment, ConsolidatedIdentifier
- FragmentIdentifier, InterpretationSheet, OperationalDocument
- SheetIdentifier, SocietalTechnologyTrendReport, SystemsReferenceDocument
- TechnologyReport, TestReportForm
- VapIdentifier, WhitePaper, WorkingDocument, Base

**Spec Coverage:**
- ✅ 2 specs (amendment, international_standard)
- ❌ MISSING: 20 identifier spec files

**Status:** HIGH PRIORITY - Blocks V1 removal (Session 51-56)

---

### ⚠️ IEEE - PARTIAL (Architecture Unknown, Needs Audit)
**Status:** Unknown, 100% tests passing (5,146/5,146) but only 3/7 classes tested

**Current State:**
- ⚠️ Has 7 identifier classes
- ⚠️ Architecture pattern unknown
- ⚠️ Builder/Scheme status unknown

**Required Work:**
1. **Audit current architecture** - Determine if MODEL-DRIVEN
2. **Create/update Scheme class** if needed
3. **Refactor Builder** if needed
4. **Verify Components**
5. **Create missing specs** - 4 missing per Session 50 audit

**Identifier Classes (7 total):**
- Base, AdoptedStandard, DualPublished
- DualIdentifier, IecIeeeCopublished
- ParentheticalIdentifier, RedlinedStandard

**Spec Coverage:**
- ✅ 3 specs (base, adopted_standard, dual_published)
- ❌ MISSING: 4 identifier spec files

**Status:** MEDIUM PRIORITY (Session 57)

---

### ❌ JIS - NOT STARTED
**Status:** 0% refactored, unknown test coverage

**Required Work:**
1. **Complete audit** - Current architecture unknown
2. **Implement MODEL-DRIVEN pattern**
3. **Create Scheme, Components, Builder**
4. **Create all identifier classes**
5. **Create complete spec suite**

**Status:** LOW PRIORITY (future work)

---

### ❌ ITU - NOT STARTED
**Status:** 0% refactored, unknown test coverage

**Required Work:**
1. **Complete audit** - Current architecture unknown
2. **Implement MODEL-DRIVEN pattern**
3. **Create Scheme, Components, Builder**
4. **Create all identifier classes**
5. **Create complete spec suite**

**Status:** LOW PRIORITY (future work)

---

### ❌ CCSDS - NOT STARTED
**Status:** 0% refactored, 100% tests passing (62/62)

**Required Work:**
1. **Complete audit** - Current architecture unknown
2. **Implement MODEL-DRIVEN pattern**
3. **Create Scheme, Components, Builder**
4. **Create all identifier classes**
5. **Create complete spec suite**

**Status:** LOW PRIORITY (future work)

---

### ❌ BSI, CEN, PLATEAU, ETSI, ANSI, IDF - NOT STARTED
**Status:** 0% refactored

**Required Work:** Same as above for each flavor

**Status:** LOWEST PRIORITY (future work)

---

## Phased Implementation Plan

### Phase 1: Complete High-Priority Flavors (Sessions 51-58)

**Priority Order:**
1. **IEC** (20 missing specs) - Sessions 51-56
2. **IEEE** (4 missing specs) - Session 57
3. **NIST** (8 missing specs) - Session 58

**Goal:** Achieve 100% spec coverage for ISO, NIST, IEC, IEEE

### Phase 2: Audit and Refactor Remaining Flavors (Sessions 59-70)

**For each flavor:**
1. **Audit Session** - Understand current architecture
2. **Refactor Session(s)** - Implement MODEL-DRIVEN pattern
3. **Spec Session(s)** - Create complete spec coverage
4. **Validation Session** - Test and document

**Estimated Timeline:**
- JIS: 3 sessions (audit + refactor + specs)
- ITU: 3 sessions
- CCSDS: 2 sessions (already has tests)
- BSI: 3 sessions
- CEN: 3 sessions
- PLATEAU: 2 sessions
- ETSI: 2 sessions
- ANSI: 2 sessions
- IDF: 2 sessions

**Total:** ~22 sessions for Phase 2

### Phase 3: Documentation and V1 Removal (Sessions 71-73)

1. **Session 71:** Update all flavor README.adoc files
2. **Session 72:** Create V1→V2 migration guide
3. **Session 73:** Remove V1 code (ONLY after 100% coverage confirmed)

---

## Success Criteria

### Architecture Criteria ✅
- [x] ISO follows MODEL-DRIVEN pattern
- [x] NIST follows MODEL-DRIVEN pattern
- [ ] IEC follows MODEL-DRIVEN pattern
- [ ] IEEE follows MODEL-DRIVEN pattern
- [ ] All other flavors follow MODEL-DRIVEN pattern

### Spec Coverage Criteria 🚧
- [x] ISO: 100% class coverage (18/18)
- [ ] NIST: 100% class coverage (3/11 = 27%)
- [ ] IEC: 100% class coverage (2/22 = 9%)
- [ ] IEEE: 100% class coverage (3/7 = 43%)
- [ ] All other flavors: 100% class coverage

### Test Pass Rate Criteria ✅
- [x] ISO: 92.84% passing (production-ready)
- [x] NIST: 100% passing (architecture complete)
- [ ] IEC: >90% passing
- [ ] IEEE: >90% passing
- [ ] All other flavors: >90% passing

### V1 Removal Criteria ❌
- [ ] ALL flavors follow MODEL-DRIVEN pattern
- [ ] ALL identifier classes have spec files
- [ ] ALL tests passing or failures documented
- [ ] Documentation complete

**Current Status:** NOT READY for V1 removal

---

## Next Steps (Immediate)

### Session 51-56: IEC Spec Creation (HIGH PRIORITY)
Create 20 missing identifier spec files:
- component_specification_spec.rb
- conformity_assessment_spec.rb
- consolidated_identifier_spec.rb
- corrigendum_spec.rb
- fragment_identifier_spec.rb
- guide_spec.rb
- interpretation_sheet_spec.rb
- operational_document_spec.rb
- publicly_available_specification_spec.rb
- sheet_identifier_spec.rb
- societal_technology_trend_report_spec.rb
- systems_reference_document_spec.rb
- technical_report_spec.rb
- technical_specification_spec.rb
- technology_report_spec.rb
- test_report_form_spec.rb
- vap_identifier_spec.rb
- white_paper_spec.rb
- working_document_spec.rb
- base_spec.rb (if missing)

### Session 57: IEEE Spec Creation (MEDIUM PRIORITY)
Create 4 missing identifier spec files:
- dual_identifier_spec.rb
- iec_ieee_copublished_spec.rb
- parenthetical_identifier_spec.rb
- redlined_standard_spec.rb

### Session 58: NIST Spec Creation (MEDIUM PRIORITY)
Create 8 missing series spec files:
- special_publication_spec.rb
- federal_information_processing_standards_spec.rb
- internal_report_spec.rb
- handbook_spec.rb
- technical_note_spec.rb
- crpl_report_spec.rb (may exist)
- commercial_standard_emergency_spec.rb
- circular_supplement_spec.rb

---

## Reference Architecture Pattern

### ISO Pattern (TYPED_STAGES Registry)
```ruby
# Scheme
class Scheme
  TYPED_STAGES_REGISTRY = [...]
  
  def locate_typed_stage_by_abbr(abbr)
    # Returns TypedStage from registry
  end
  
  def locate_identifier_klass_by_type_code(type_code)
    # Returns identifier class
  end
end

# Builder
class Builder
  def initialize(scheme)
    @scheme = scheme
  end
  
  def cast(type, value)
    case type
    when :type_with_stage
      typed_stage = @scheme.locate_typed_stage_by_abbr(value)
      { stage:, type:, typed_stage: }
    # ... other cases
    end
  end
end

# Identifier
class TechnicalReport < SingleIdentifier
  TYPED_STAGES = [
    TypedStage.new(abbr: ["TR"], stage_code: "published"),
    TypedStage.new(abbr: ["DTR"], stage_code: "draft"),
  ]
end
```

### NIST Pattern (Series Registry)
```ruby
# Scheme
class Scheme
  def series_to_class_map
    {
      "SP" => SpecialPublication,
      "IR" => InternalReport,
      # ...
    }
  end
  
  def locate_identifier_klass(parsed_hash)
    series = extract_series(parsed_hash)
    series_to_class_map[series] || Base
  end
end

# Builder
class Builder
  def initialize(scheme)
    @scheme = scheme
  end
  
  def cast(type, value)
    case type
    when :series
      # Extract publisher if compound
      # Return composite hash
    # ... other cases
    end
  end
end

# Identifier
class SpecialPublication < Base
  def series_code
    "SP"
  end
end
```

**Both patterns are MODEL-DRIVEN and follow the same core principles!**

---

## Critical Reminders

1. **ONE CLASS PER TYPE** - Not one base handling all via attributes
2. **COMPONENTS ARE SHARED** - Volume, parts, etc. are attributes/components
3. **BUILDER NEVER DECIDES** - Only casts, never makes business logic decisions
4. **SCHEME PROVIDES REGISTRY** - All type/class lookups via Scheme
5. **EVERY CLASS NEEDS SPEC** - No gaps in per-class testing
6. **ARCHITECTURE > TESTS** - Correct architecture is priority, tests will follow

---

## Deadline Compression Strategy

**Instead of 73 sessions, we can compress to ~40-50 sessions:**

1. **Combine spec creation** - Create 3-5 specs per session instead of 1
2. **Parallel refactoring** - Audit + refactor in same session for simple flavors
3. **Batch similar work** - All audits together, all refactorings together
4. **Prioritize by dependency** - Focus on flavors blocking V1 removal first

**Revised Timeline:**
- Phase 1 (IEC/IEEE/NIST specs): 8 sessions (already planned)
- Phase 2 (Refactor all flavors): 15-20 sessions (compressed from 22)
- Phase 3 (Documentation): 3 sessions
- **Total: 26-31 sessions** (vs 73 original)

---

## Tracking Document

This document serves as the master tracking document for architecture refactoring. Update status as work progresses.

**Last Updated:** 2025-11-28  
**Next Update:** After each phase completion