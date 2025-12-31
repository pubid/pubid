# Session 241+ Continuation Plan: NIST V1→V2 Spec Migration (Final Flavor)

**Created:** 2025-12-30 (Post-Session 240 - JIS Complete)
**Status:** JIS at 100%, only NIST remaining at 30%
**Timeline:** COMPRESSED - Complete in 6-8 sessions (12-16 hours)

---

## Executive Summary

**Session 240 Achievement:** JIS V1→V2 migration complete - 10/12 flavors at 100%! 🎉

**Current Status:**
- **10/12 flavors at 100%** V1→V2 migration ✅
- **JIS:** 62/62 tests, 10,635 identifiers (100%) ✅
- **NIST:** 6 V2 specs vs 20 V1 specs (30% coverage)
- **NIST is the ONLY remaining flavor for migration**

**Remaining Work:** NIST systematic spec migration (18 V1 specs to port)

---

## NIST V1 Spec Analysis

### V1 Structure (20 spec files)

**Series-Specific Specs (12 files):**
1. `circ_spec.rb` - Circular series
2. `sp_spec.rb` - Special Publications
3. `fips_spec.rb` - Federal Information Processing Standards
4. `hb_spec.rb` - Handbooks
5. `nbs_hb_spec.rb` - NBS Handbooks (historical)
6. `nbs_tn_spec.rb` - NBS Technical Notes (historical)
7. `nist_ir_spec.rb` - Internal Reports
8. `nist_tech_pubs_spec.rb` - Technical Publications

**Generic Integration Specs (8 files):**
9. `create_spec.rb` - Creation workflows
10. `default_spec.rb` - Default values
11. `document_merge_spec.rb` - Combined identifiers
12. `edition_spec.rb` - Edition handling
13. `publisher_spec.rb` - Publisher component
14. `series_spec.rb` - Series component
15. `stage_spec.rb` - Stage/draft handling
16. `update_spec.rb` - Update workflows

**Duplicates/Utilities:**
17-20. Duplicate circ_spec.rb and sp_spec.rb files (likely test data duplicates)

### Current V2 Structure (6 specs)

**Existing:**
1. `identifier_spec.rb` - Integration tests
2. `parser_spec.rb` - Parser unit tests
3. `builder_spec.rb` - Builder unit tests
4. `identifier/base_spec.rb` - Base class tests
5. `identifier/federal_information_processing_standard_spec.rb` - FIPS
6. `identifier/special_publication_spec.rb` - SP

**Architecture:** Already follows MODEL-DRIVEN with proper class separation

---

## Implementation Strategy

### Phase 1: Series Identifier Specs (Sessions 241-244, 8 hours)

Create specs for all NIST series types to achieve MECE coverage.

**Session 241: Core Series Part 1 (2 hours)**
- Create `circular_spec.rb` - CIRC series
- Create `handbook_spec.rb` - HB series
- Create `internal_report_spec.rb` - IR series
- **Expected:** +60-80 tests

**Session 242: Core Series Part 2 (2 hours)**
- Create `technical_note_spec.rb` - TN series (if exists)
- Create `technical_publication_spec.rb` - Tech pubs
- Create historical series specs if needed
- **Expected:** +40-60 tests

**Session 243: Historical NBS Series (2 hours)**
- Create `nbs_handbook_spec.rb` - NBS HB series
- Create `nbs_technical_note_spec.rb` - NBS TN series
- Create `nbs_monograph_spec.rb` - if exists
- **Expected:** +40-60 tests

**Session 244: Validation (2 hours)**
- Run all NIST specs
- Verify MECE organization
- Document coverage
- Fix any issues

---

### Phase 2: Component Specs (Sessions 245-246, 4 hours)

**Session 245: Core Components (2 hours)**
- Create `components/publisher_spec.rb` - Publisher component
- Create `components/series_spec.rb` - Series component
- Create `components/edition_spec.rb` - Edition component
- **Expected:** +30-40 tests

**Session 246: Advanced Components (2 hours)**
- Create `components/stage_spec.rb` - Stage/draft component
- Create `components/code_spec.rb` - if needed
- Integration tests for components
- **Expected:** +20-30 tests

---

### Phase 3: Integration Tests (Sessions 247-248, 4 hours)

**Session 247: Creation & Update (2 hours)**
- Port V1 `create_spec.rb` patterns
- Port V1 `update_spec.rb` patterns
- Test programmatic creation
- **Expected:** +40-60 tests

**Session 248: Advanced Features (2 hours)**
- Port `document_merge_spec.rb` patterns (if applicable)
- Port `default_spec.rb` patterns
- Final validation
- **Expected:** +20-40 tests

---

## NIST Architecture Verification

### Current V2 NIST Classes (MECE)

**Base Classes:**
- `Identifiers::Base` - Common functionality
- `SingleIdentifier` - For base documents

**Series-Specific Classes (expect 8-12):**
1. `FederalInformationProcessingStandard` (FIPS)
2. `SpecialPublication` (SP)
3. `Circular` (CIRC) - likely exists
4. `Handbook` (HB) - likely exists
5. `InternalReport` (IR) - likely exists
6. `TechnicalNote` (TN) - check existence
7. NBS variants - check existence

**Supplement Classes (if applicable):**
- Amendment/Revision classes if NIST uses them

### Verification Needed

**Check if these files exist:**
```
lib/pubid_new/nist/identifiers/circular.rb
lib/pubid_new/nist/identifiers/handbook.rb
lib/pubid_new/nist/identifiers/internal_report.rb
lib/pubid_new/nist/identifiers/technical_note.rb
lib/pubid_new/nist/identifiers/nbs_handbook.rb
lib/pubid_new/nist/identifiers/nbs_technical_note.rb
```

---

## Success Criteria

### Per Session
- ✅ Series specs created with 20-30 tests each
- ✅ All tests passing
- ✅ MECE architecture maintained
- ✅ No mocking - real parsing tests
- ✅ Round-trip tests for all patterns

### Overall (Complete Migration)
- ✅ All 20 V1 NIST specs analyzed
- ✅ All patterns ported to V2
- ✅ 8-12 series identifier specs created
- ✅ 4-6 component specs created
- ✅ 2-4 integration specs created
- ✅ 200-300+ new NIST tests
- ✅ 12/12 V1 flavors at 100% migration

---

## Files to Create (Estimated)

### Series Specs (8-12 files)
- `spec/pubid_new/nist/identifiers/circular_spec.rb`
- `spec/pubid_new/nist/identifiers/handbook_spec.rb`
- `spec/pubid_new/nist/identifiers/internal_report_spec.rb`
- `spec/pubid_new/nist/identifiers/technical_note_spec.rb`
- `spec/pubid_new/nist/identifiers/technical_publication_spec.rb`
- `spec/pubid_new/nist/identifiers/nbs_handbook_spec.rb`
- `spec/pubid_new/nist/identifiers/nbs_technical_note_spec.rb`
- Additional series as discovered

### Component Specs (4-6 files)
- `spec/pubid_new/nist/components/publisher_spec.rb`
- `spec/pubid_new/nist/components/series_spec.rb`
- `spec/pubid_new/nist/components/edition_spec.rb`
- `spec/pubid_new/nist/components/stage_spec.rb`
- Additional components as needed

### Integration Specs (2-4 files)
- `spec/pubid_new/nist/creation_spec.rb`
- `spec/pubid_new/nist/update_spec.rb`
- `spec/pubid_new/nist/merge_spec.rb` (if applicable)
- `spec/pubid_new/nist/defaults_spec.rb`

---

## Timeline Summary

| Sessions | Focus | Duration | Deliverables |
|----------|-------|----------|--------------|
| 241-244 | Series specs | 8 hours | 8-12 specs, 180-260 tests |
| 245-246 | Component specs | 4 hours | 4-6 specs, 50-70 tests |
| 247-248 | Integration specs | 4 hours | 2-4 specs, 60-100 tests |
| **Total** | **NIST migration** | **16 hours** | **100% complete** |

---

## Key Architectural Principles

**MAINTAIN throughout:**
1. **MODEL-DRIVEN** - All identifiers are objects, not strings
2. **MECE** - Each series type is a separate class
3. **Three-layer** - Parser/Builder/Identifier independence
4. **No mocking** - Test real parsing and rendering
5. **Round-trip** - All patterns tested for perfect fidelity
6. **Component testing** - Test shared components separately

---

## Next Immediate Steps (Session 241)

1. Read this continuation plan
2. Read V1 NIST series specs (circ, hb, ir)
3. Verify V2 NIST identifier classes exist
4. Create first batch of series specs
5. Test and validate
6. Commit progress

---

**Created:** 2025-12-30
**Sessions Covered:** 241-248
**Status:** Ready for execution
**Estimated Time:** 16 hours (compressed)

**End Goal:** 12/12 flavors at 100% V1→V2 migration - PROJECT COMPLETE! 🎉