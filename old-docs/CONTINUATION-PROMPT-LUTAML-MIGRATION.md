# Continuation Prompt: Complete Lutaml::Model Architecture Migration

## Copy-Paste This to Continue Migration Work:

```
PubID v2 - Lutaml::Model Architecture Migration (All Flavors)
Branch: rt-new-lutaml-model

MISSION:
Complete migration of ALL 6 pending PubID flavors to proper Lutaml::Model architecture following ISO/CCSDS reference implementations.

COMPLETED IN PREVIOUS SESSION:
✅ Comprehensive testing: 79,876 cases, 97.6% pass rate
✅ NIST rendering fixes: +896 cases improved
✅ ISO normalization: +22 cases improved
✅ Architecture analysis and 8-10 week migration plan
✅ IEC foundation: 6 components + 2 identifiers created

CURRENT STATUS (Check docs/LUTAML-MIGRATION-STATUS.md):
✅ ISO: Complete (reference implementation)
✅ CCSDS: Complete (already correct)
🔄 IEC: 35% complete (components done, identifiers in progress)
⏳ JIS: Not started (needs full migration)
⏳ ETSI: Not started (needs full migration)
⏳ ITU: Not started (needs full migration)
⏳ IEEE: Not started (needs full migration)
⏳ NIST: Not started (needs full migration)

REFERENCE IMPLEMENTATIONS:
- ISO: lib/pubid_new/iso/ - Perfect reference model
- CCSDS: lib/pubid_new/ccsds/ - Already correct
- IEC (in progress): lib/pubid_new/iec/ - Components complete

ARCHITECTURAL PRINCIPLES (NON-NEGOTIABLE):

1. OBJECT-ORIENTED DESIGN
   - Every class ONE responsibility
   - Inheritance for "is-a"
   - Composition for "has-a"
   - Polymorphism for extensibility

2. MECE (Mutually Exclusive, Collectively Exhaustive)
   - Every identifier exactly ONE type
   - Type hierarchies cover ALL cases
   - No overlapping responsibilities

3. SEPARATION OF CONCERNS
   - Parser: Syntax only
   - Builder: Transform to objects
   - Components: Semantic types
   - Identifiers: Business logic
   - Scheme: Registry/lookup
   - Constants: Class-level definitions

4. TYPED_STAGES PATTERN (NO TYPE_MAP)
   - Each identifier class declares TYPED_STAGES array
   - Scheme provides: locate_typed_stage_by_abbr, locate_identifier_klass_by_type_code
   - Builder delegates to Scheme methods
   - NO hardcoded TYPE_MAP hash

5. OPEN/CLOSED PRINCIPLE
   - Open for extension (new types via classes)
   - Closed for modification (existing stable)

6. COMPREHENSIVE TESTING
   - Every class has spec file
   - Integration tests must pass
   - NO lowering thresholds

MIGRATION PLAN BY FLAVOR:

═══════════════════════════════════════════════════════
PHASE 1: IEC MIGRATION (PRIORITY #1) - 4-5 days remaining
═══════════════════════════════════════════════════════

STATUS: 35% complete (6 components + 2 identifiers done)

COMPLETED:
✅ 6 components: Publisher, Code, VapSuffix, ConsolidatedAmendment, Sheet, TrfInfo
✅ Base identifier with IEC-specific attributes
✅ TechnicalReport identifier (reference example)

REMAINING TASKS:

Task IEC.4: Create 13 Remaining Identifier Classes (1.5 days)
---------------------------------------------------------------
Location: lib/pubid_new/iec/identifiers/

Create:
1. international_standard.rb (EMPTY TYPED_STAGES, complex PROJECT_STAGES)
2. technical_specification.rb (DTStype, PROJECT_STAGES)
3. guide.rb (DGuide, FDGuide stages)
4. pas.rb (Publicly Available Specification)
5. test_report_form.rb (TRF - IEC specific)
6. interpretation_sheet.rb (ISH - IEC specific)
7. component_specification.rb (CS)
8. operational_document.rb (OD)
9. conformity_assessment.rb (CA)
10. systems_reference_document.rb (SRD)
11. technology_report.rb
12. societal_technology_trend_report.rb (STTR)
13. white_paper.rb

For each identifier (study technical_report.rb pattern):
- Read corresponding v1 file in gems/pubid-iec/lib/pubid/iec/identifier/
- Convert TYPED_STAGES hash → TypedStage objects array
- Convert PROJECT_STAGES (keep as hash for now)
- Define self.type method
- Override publisher_portion if type-specific rendering

Task IEC.5: Create 21 Spec Files (1 day)
------------------------------------------
Location: spec/pubid_new/iec/

Components specs (6 files):
- components/publisher_spec.rb
- components/code_spec.rb
- components/vap_suffix_spec.rb
- components/consolidated_amendment_spec.rb
- components/sheet_spec.rb
- components/trf_info_spec.rb

Identifier specs (15 files):
- identifiers/base_spec.rb
- identifiers/technical_report_spec.rb
- identifiers/international_standard_spec.rb
- ... (12 more for remaining types)

Each spec:
- Test construction
- Test rendering (to_s)
- Test validation
- Test type determination
- Use real examples from fixtures

Task IEC.6: Update Builder (1 day)
------------------------------------
File: lib/pubid_new/iec/builder.rb

Convert to use Scheme lookup pattern:
- Remove any hardcoded type mappings
- Use @scheme.locate_typed_stage_by_abbr
- Use @scheme.locate_identifier_klass_by_type_code
- Transform parsed data to component objects
- Handle IEC-specific: consolidated amendments, VAP, TRF

Pattern from ISO builder (line 23-56):
```ruby
def locate_typed_stage(typed_stage_string)
  @scheme.locate_typed_stage_by_abbr(typed_stage_string || "")
end

def locate_identifier_klass(parsed_hash)
  typed_stage = locate_typed_stage(parsed_hash[:type_with_stage])
  @scheme.locate_identifier_klass_by_type_code(typed_stage.type_code)
end

def build(parsed_hash)
  identifier = locate_identifier_klass(parsed_hash).new
  # ... assign attributes via cast method
end
```

Create spec: spec/pubid_new/iec/builder_spec.rb

Task IEC.7: Convert Scheme to Registry (0.5 day)
--------------------------------------------------
File: lib/pubid_new/iec.rb (main module file, like iso.rb)

Pattern from ISO (line 37-64):
```ruby
IDENTIFIER_TYPES = [
  Identifiers::InternationalStandard,
  Identifiers::TechnicalReport,
  Identifiers::TechnicalSpecification,
  ... (all types)
].freeze

SUPPLEMENT_IDENTIFIER_TYPES = [
  Identifiers::Amendment,
  Identifiers::Corrigendum,
  ... (supplements)
].freeze

Scheme = PubidNew::Scheme.new(
  identifiers: IDENTIFIER_TYPES,
  supplement_identifiers: SUPPLEMENT_IDENTIFIER_TYPES
)
```

Update iec.rb to:
- Require all components
- Require all identifiers
- Create IDENTIFIER_TYPES array
- Instantiate Scheme
- Provide parse method

Task IEC.8: Test & Validate (1 day)
-------------------------------------
Run: bundle exec rspec spec/integration/iec_spec.rb

Expected improvement:
- Baseline: 3,169/13,889 (22.82%)
- Target Phase 1: 35-40% (basic types working)
- Target Phase 2: 60-70% (with TRF, CSV, etc.)

Validation:
- All unit tests passing
- Architecture matches ISO
- No TYPE_MAP used
- MECE principles applied

═══════════════════════════════════════════════════════
PHASE 2: JIS MIGRATION (PRIORITY #2) - 5-7 days
═══════════════════════════════════════════════════════

STATUS: Not started (0% migrated)
FILE: lib/pubid_new/jis/ (has incorrect Scheme as data model)
TESTS: 10,635/10,635 (100%) - maintain this!

ANALYSIS NEEDED:
1. Study gems/pubid-jis/lib/pubid/jis/ for document types
2. Identify JIS-specific features vs ISO commonalities
3. Document in docs/JIS-MIGRATION-ANALYSIS.md

JIS STRUCTURE (preliminary):
- Publisher: JIS (Japanese Industrial Standards)
- Categories: A, B, C, K, X, Z, etc.
- Format: JIS A 1234:2020
- Simpler than IEC (subset of ISO patterns)

TASKS:
1. Create components (Publisher, Code, Category) - 0.5 day
2. Create identifiers (Base + category types) - 1 day
3. Convert TYPED_STAGES - 0.5 day
4. Update builder/scheme - 1 day
5. Create specs - 1 day
6. Test & validate - 1 day

Expected: Maintain 100% pass rate

═══════════════════════════════════════════════════════
PHASE 3: ETSI MIGRATION (PRIORITY #3) - 5-7 days
═══════════════════════════════════════════════════════

STATUS: Not started (0% migrated)
FILE: lib/pubid_new/etsi/ (has incorrect Scheme)
TESTS: 24,718/24,718 (100%) - maintain this!

ETSI STRUCTURE (preliminary):
- European Telecommunications Standards Institute
- Types: TS (Technical Specification), TR (Technical Report), EN, ES, ETS
- Format: ETSI TS 102 221, ETSI TR 102 091
- Simpler structure than IEC

TASKS:
1. Create components (Publisher, Code, Type) - 0.5 day
2. Create identifiers (5-6 types) - 1 day
3. Convert TYPED_STAGES - 0.5 day
4. Update builder/scheme - 1 day
5. Create specs - 1 day
6. Test & validate - 1 day

Expected: Maintain 100% pass rate

═══════════════════════════════════════════════════════
PHASE 4: ITU MIGRATION (PRIORITY #4) - 5-7 days
═══════════════════════════════════════════════════════

STATUS: Not started (0% migrated)
FILE: lib/pubid_new/itu/ (has incorrect Scheme)
TESTS: 2,041/2,041 (100%) - maintain this!

ITU STRUCTURE (preliminary):
- International Telecommunication Union
- Sectors: ITU-R, ITU-T, ITU-D
- Series-based: R.001, T.30, etc.
- Recommendations with Supplements, Amendments

TASKS:
1. Create components (Publisher, Sector, Series, Code) - 0.5 day
2. Create identifiers (Recommendation + supplements) - 1 day
3. Convert TYPED_STAGES - 0.5 day
4. Update builder/scheme - 1 day
5. Create specs - 1 day
6. Test & validate - 1 day

Expected: Maintain 100% pass rate

═══════════════════════════════════════════════════════
PHASE 5: IEEE MIGRATION (PRIORITY #5) - 7-10 days
═══════════════════════════════════════════════════════

STATUS: Not started (0% migrated)
FILE: lib/pubid_new/ieee/ (has incorrect Scheme)
TESTS: 120/640 (18.75%) - needs parser enhancements too

IEEE STRUCTURE (complex):
- Institute of Electrical and Electronics Engineers
- Types: Standard, Draft, Guide
- Supplements: Amendment, Corrigendum
- Complex: Reaffirmation dates (R1992), ANSI copublishing
- Legacy: AIEE, IRE, ASA (pre-IEEE organizations)
- Identifier-first formats: "1873-2015 IEEE..."

TASKS:
1. Create components (Publisher, Code, ReaffirmationDate, WorkingGroup, Category) - 1 day
2. Create identifiers (Standard, Draft, Guide + supplements) - 1-2 days
3. Parser enhancements (legacy publishers, identifier-first) - 2-3 days
4. Convert TYPED_STAGES - 1 day
5. Update builder/scheme - 1 day
6. Create specs - 1 day
7. Test & validate - 1 day

Expected: 18.75% → 75-90%

═══════════════════════════════════════════════════════
PHASE 6: NIST MIGRATION (PRIORITY #6) - 10-14 days
═══════════════════════════════════════════════════════

STATUS: Not started (0% migrated)
FILE: lib/pubid_new/nist/ (has incorrect Scheme but good rendering fixes)
TESTS: 18,614/20,211 (92.1%), pubs-export 764/764 (100%)

NIST STRUCTURE (most complex):
- National Institute of Standards and Technology / National Bureau of Standards
- Publishers: NIST, NBS (historical), CSRC, ITL, NSRDS
- 9+ Document Types:
  * SP (Special Publication)
  * FIPS (Federal Information Processing Standards)
  * TN (Technical Note)
  * HB (Handbook)
  * IR (Internal Report)
  * CIRC (Circular)
  * MONO (Monograph)
  * BMS (Building Materials Series)
  * AMS (Applied Mathematics Series)
  * ... more historical types

PRESERVE: All rendering fixes from lib/pubid_new/nist/scheme.rb

TASKS:
1. Create components (Publisher, Series, Code, Edition, RevisionDate, Update, Addendum, Supplement, Part, Volume) - 1-2 days
2. Create base identifier - 1 day
3. Create 9+ document type identifiers - 2-3 days
4. Convert TYPED_STAGES for each type - 1-2 days
5. Update builder (complex type determination) - 1 day
6. Update scheme to registry - 1 day
7. Handle historical NBS → NIST transition - 0.5 day
8. Create comprehensive specs - 2 days
9. Test & validate - 1 day

Expected: Maintain 92.1%, improve to 94-95%

═══════════════════════════════════════════════════════
OVERALL MIGRATION PLAN
═══════════════════════════════════════════════════════

TIMELINE: 8-10 weeks total

Week 1-2: IEC (IN PROGRESS)
Week 3: JIS
Week 4: ETSI
Week 5: ITU
Week 6-7: IEEE
Week 8-9: NIST
Week 10: Testing & Polish

EXECUTION PATTERN FOR EACH FLAVOR:

Step 1: Study & Analyze (0.5-1 day)
- Read v1 implementation in gems/pubid-{flavor}/
- Identify document types
- Map components needed
- Document in docs/{FLAVOR}-MIGRATION-ANALYSIS.md

Step 2: Create Components (0.5-2 days depending on complexity)
- Location: lib/pubid_new/{flavor}/components/
- Follow Lutaml::Model::Serializable pattern
- Define constants in classes
- Implement to_s, validate
- Create spec for each

Step 3: Create Identifier Classes (1-3 days)
- Location: lib/pubid_new/{flavor}/identifiers/
- Base class first
- Then concrete types
- Convert TYPED_STAGES hash → TypedStage objects
- Define self.type method
- Create spec for each

Step 4: Update Builder (0.5-1 day)
- Use Scheme lookup methods (NO TYPE_MAP)
- Transform to component objects
- Spec file

Step 5: Convert Scheme to Registry (0.5 day)
- Create IDENTIFIER_TYPES array
- Instantiate PubidNew::Scheme
- Remove data model code
- Spec file

Step 6: Wire Entry Point (0.5 day)
- Update lib/pubid_new/{flavor}.rb
- Require all classes
- Provide parse method

Step 7: Test & Validate (1 day)
- Run integration tests
- Verify pass rates maintained/improved
- All unit tests passing

Step 8: Document (0.5 day)
- Update {FLAVOR}-MIGRATION-ANALYSIS.md with "COMPLETE" status
- Note lessons learned
- Document any flavor-specific patterns discovered

QUALITY GATES (Every Flavor):

✅ Architecture matches ISO/CCSDS
✅ NO TYPE_MAP anywhere
✅ TYPED_STAGES in each identifier class
✅ Scheme uses lookup methods
✅ Every class has spec file
✅ Integration tests pass at same or better rate
✅ Code follows MECE principles
✅ Single responsibility per class
✅ Proper Lutaml::Model inheritance

CURRENT PRIORITY:

🔥 IMMEDIATE: Complete IEC Migration
- Finish 13 identifier classes
- Create 21 spec files
- Update builder/scheme
- Test & validate

THEN: JIS → ETSI → ITU → IEEE → NIST (in that order)

FORBIDDEN:
❌ Using TYPE_MAP pattern
❌ Lowering test thresholds
❌ Skipping spec files
❌ Hardcoding in wrong places
❌ Mixing concerns
❌ Rushing/cutting corners

FILES TO TRACK PROGRESS:
- docs/LUTAML-MIGRATION-STATUS.md - Overall status
- docs/ARCHITECTURE-MIGRATION-PLAN-LUTAML.md - Full plan
- docs/{FLAVOR}-MIGRATION-ANALYSIS.md - Per-flavor analysis

START NOW: Task IEC.4 - Create international_standard.rb identifier
```

## Quick Reference

**ISO v2 references:**
- Entry: `lib/pubid_new/iso.rb`
- Builder: `lib/pubid_new/iso/builder.rb`
- Scheme: `lib/pubid_new/scheme.rb`
- Example: `lib/pubid_new/iso/identifiers/technical_report.rb`

**IEC progress:**
- Components: `lib/pubid_new/iec/components/` (6/6 complete)
- Identifiers: `lib/pubid_new/iec/identifiers/` (2/15 complete)

**Status tracker:** `docs/LUTAML-MIGRATION-STATUS.md`

---

## Implementation Notes

**For Each Flavor:**
1. Start with v1 analysis (gems/pubid-{flavor}/)
2. Document types and components needed
3. Create components with specs
4. Create identifiers with TYPED_STAGES
5. Convert builder to use Scheme lookup
6. Create Scheme registry
7. Wire entry point
8. Test comprehensively

**Success = All 8 flavors following ISO pattern**

**Timeline = 8-10 weeks of systematic work**

Ready to execute! 🚀