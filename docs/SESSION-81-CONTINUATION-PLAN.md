# Session 81+ Continuation Plan: RFC 5141-bis Implementation & Final Polish

**Created:** 2025-12-01 (Post-Session 80)  
**Status:** RFC 5141-bis SPECIFICATION COMPLETE  
**Timeline:** 8-10 sessions (Sessions 81-90)

---

## EXECUTIVE SUMMARY

**Session 80 Major Achievement:**
- ✅ Created 948-line RFC 5141-bis specification in Metanorma format
- ✅ Documented all 9 RFC 5141 limitations
- ✅ Proposed backward-compatible extensions
- ✅ Complete ABNF syntax defined
- ✅ Created 717-line implementation plan

**Current Status:**
- **All 13 flavors production-ready (100%)**
- **ISO at 99.29%** (core: 100%, only 19 URN format differences)
- **RFC 5141-bis: READY FOR IMPLEMENTATION**

**Remaining Work:**
1. **Phase 1 (81-84):** Implement RFC 5141-bis URN extensions (8 hours)
2. **Phase 2 (85-86):** Testing & validation (4 hours)
3. **Phase 3 (87-88):** Documentation (4 hours)  
4. **Phase 4 (89-90):** IEC improvements (optional, 4 hours)

---

## PROJECT STATUS

### Completed (Session 80)

**RFC 5141-bis Specification:**
- 948 lines of Metanorma-formatted standard
- Documents 9 major RFC 5141 limitations
- Proposes 8 backward-compatible extensions:
  1. Extended copublisher syntax (dynamic combinations)
  2. Extended document types (DIR, DIR-SUP, IWA-SUP)
  3. Extended stage codes (WD, CD, DIS, FDIS, PDAM, etc.)
  4. Supplement chain ordering semantics
  5. Base identifier stage specification
  6. Bundled identifier syntax  
  7. Explicit language specification guidance
  8. Complete ABNF syntax summary

**Implementation Plan:**
- 717 lines of detailed plan
- 8-session implementation roadmap
- Architecture design complete
- Risk management strategy
- Success criteria defined

**ISO Analysis:**
- 99.29% pass rate (2,654/2,673 active tests)
- Core functionality: 100% (zero failures)
- 19 URN format differences documented
- V2 may be MORE correct than V1 per RFC 5141

---

## PHASE 1: RFC 5141-BIS IMPLEMENTATION (Sessions 81-84)

### Session 81: URN Generator + Language Codes (2 hours)

**Priority:** HIGH (fixes 15/19 URN tests)

**Objective:** Create URN generation framework and fix language code issues

**Tasks:**

1. **Design URN Generator** (30 min)
   ```ruby
   # Create lib/pubid_new/iso/urn_generator.rb
   class PubidNew::Iso::UrnGenerator
     def initialize(identifier, mode: :bis)
       @identifier = identifier
       @mode = mode # :rfc5141 or :bis
     end

     def generate
       # Build URN components
       # Follow RFC 5141-bis semantics
     end
   end
   ```

2. **Implement Language Specification** (45 min)
   - Follow RFC 5141-bis guidance: "explicit is better than implicit"
   - Include `:fr` for French documents
   - Include `:en` for English (if mode is :bis)
   - Fixes 15/19 URN test failures

3. **Update Identifier Class** (30 min)
   ```ruby
   # Modify lib/pubid_new/iso/identifier.rb
   def to_urn(mode: :bis)
     UrnGenerator.new(self, mode: mode).generate
   end
   ```

4. **Testing** (15 min)
   - Run URN tests
   - Verify 15 language code tests now pass
   - Document progress

**Expected Results:**
- New URN generator architecture
- Language codes properly included
- **17/19 URN tests passing** (89.5%)

**Commit Message:**
```
feat(iso): implement RFC 5141-bis URN generator with explicit language codes

- Create UrnGenerator class for clean separation of concerns
- Implement explicit language specification (RFC 5141-bis guidance)
- Fix 15 language-related URN test failures
- Support both RFC 5141 and RFC 5141-bis modes
- ISO URN: 17/19 passing (89.5%, was 0/19)
```

---

### Session 82: Extended Types & Copublishers (2 hours)

**Priority:** MEDIUM (foundation for future work)

**Objective:** Support extended document types and copublisher patterns

**Tasks:**

1. **Extended Document Types** (45 min)
   ```ruby
   # In urn_generator.rb
   TYPE_MAP = {
     :dir => "dir",
     :dir_sup => "dir-sup",
     :iwa_sup => "iwa-sup",
     # ... existing types
   }.freeze

   def type_component
     return nil unless @identifier.type
     TYPE_MAP[@identifier.type&.type_code] || @identifier.type.abbreviation.downcase
   end
   ```

2. **Extended Copublishers** (45 min)
   ```ruby
   def originator_component
     publishers = [@identifier.publisher.body]
     publishers += @identifier.copublisher if @identifier.respond_to?(:copublisher)
     
     # Handle dynamic combinations
     # Alphabetical ordering: ISO before IEC before IEEE
     publishers.sort.join("-").downcase
   end
   ```

3. **Testing** (30 min)
   - Create `spec/pubid_new/iso/urn_generator_spec.rb`
   - Test extended types
   - Test copublisher combinations
   - Verify RFC 5141 compatibility

**Expected Results:**
- Extended document type support
- Dynamic copublisher combinations
- Foundation for DIR/DIR-SUP support
- Still 17/19 URN tests (no regression)

**Commit Message:**
```
feat(iso): add RFC 5141-bis extended document types and copublishers

- Support DIR, DIR-SUP, IWA-SUP document types
- Handle dynamic copublisher combinations (ISO/IEC/IEEE)
- Alphabetical ordering of copublishers
- Maintain RFC 5141 backward compatibility
```

---

### Session 83: Stage Codes & Edition Placement (2 hours)

**Priority:** HIGH (fixes 3/19 URN tests)

**Objective:** Implement typed stages and supplement chain semantics

**Tasks:**

1. **Typed Stage Codes** (60 min)
   ```ruby
   STAGE_MAP = {
     :wd => "WD",
     :wds => "WDS",
     :cd => "CD",
     :cdv => "CDV",
     :dis => "DIS",
     :fdis => "FDIS",
     :pdam => "PDAM",
     :dam => "DAM",
     :fdam => "FDAM",
     # ... more stages
   }.freeze

   def stage_component
     return nil unless @identifier.stage
     
     stage_code = STAGE_MAP[@identifier.stage.stage_code]
     iteration = @identifier.stage.iteration
     
     if iteration && iteration > 1
       "#{stage_code}.#{iteration}"  # No 'v' prefix per RFC 5141-bis
     else
       stage_code
     end
   end
   ```

2. **Supplement Chain Edition Placement** (45 min)
   - Implement RFC 5141-bis ordering semantics
   - Edition applies to immediately preceding identifier
   - Handle multi-level chains correctly
   - Fixes 3 edition-related URN tests

3. **Testing** (15 min)
   - Test all stage code patterns
   - Test edition placement
   - Verify supplement chains

**Expected Results:**
- Typed stage code support
- Correct edition placement (3 tests fixed)
- **18/19 URN tests passing** (94.7%)

**Commit Message:**
```
feat(iso): implement RFC 5141-bis typed stages and edition placement

- Convert TypedStage to URN stage abbreviations (WD, CD, DIS, FDIS, etc.)
- Handle stage iterations without 'v' prefix (RFC 5141-bis)
- Fix edition placement in supplement chains (3 tests)
- ISO URN: 18/19 passing (94.7%, was 17/19)
```

---

### Session 84: Bundled Identifiers (2 hours)

**Priority:** HIGH (fixes final URN test, achieves 100%)

**Objective:** Complete RFC 5141-bis implementation with bundled IDs

**Tasks:**

1. **BundledIdentifier URN Implementation** (90 min)
   ```ruby
   # In lib/pubid_new/iso/identifiers/bundled_identifier.rb
   def to_urn(mode: :bis)
     # Generate URN for bundled components
     # Use '+' separator per RFC 5141-bis
     UrnGenerator.new(self, mode: mode).generate_bundled
   end
   ```

   ```ruby
   # In urn_generator.rb
   def generate_bundled
     # Handle bundled identifier patterns
     # Format: base+part1+part2
   end
   ```

2. **Base Stage Support** (20 min)
   - Include stage of base when amended
   - Distinguish draft vs. published bases

3. **Final Testing** (10 min)
   - Test bundled identifier URNs
   - Verify all 19 URN tests pass
   - **Achieve 100%!**

**Expected Results:**
- BundledIdentifier.to_urn complete
- Base stage specification works
- **19/19 URN tests passing (100%)** 🎉
- **ISO: 2,673/2,673 active tests (100%)** 🎉🎉🎉

**Commit Message:**
```
feat(iso): implement BundledIdentifier URN generation (RFC 5141-bis)

- Add to_urn method for BundledIdentifier class
- Support bundled identifier syntax (ISO 8601-1+8601-2)
- Support base stage specification in supplement context
- ISO URN: 19/19 passing (100%)! 🎉
- ISO TOTAL: 2,673/2,673 active (100%)! 🎉🎉🎉
```

---

## PHASE 2: TESTING & VALIDATION (Sessions 85-86)

### Session 85: RFC 5141-bis Compliance Testing (2 hours)

**Priority:** HIGH (certification)

**Objective:** Comprehensive RFC 5141-bis compliance validation

**Tasks:**

1. **Extract Specification Examples** (60 min)
   - Extract all examples from RFC 5141-bis.adoc
   - Create test fixtures (30-40 examples)
   - Cover all syntax extensions

2. **Create Compliance Test Suite** (45 min)
   ```ruby
   # spec/pubid_new/iso/rfc_5141_bis_spec.rb
   RSpec.describe "RFC 5141-bis Compliance" do
     context "Extended copublishers" do
       # Test dynamic combinations
     end
     
     context "Extended document types" do
       # Test DIR, DIR-SUP, etc.
     end
     
     context "Extended stage codes" do
       # Test WD, CD, DIS, etc.
     end
     
     # ... all extensions
   end
   ```

3. **Generate Compliance Report** (15 min)
   - Document compliance level
   - List implemented extensions
   - Note any limitations

**Expected Results:**
- Comprehensive RFC 5141-bis test suite (30-40 tests)
- Compliance level: 100%
- Documented certification

**Deliverable:**
- `docs/RFC-5141-BIS-COMPLIANCE-REPORT.md`

---

### Session 86: Integration & Edge Cases (2 hours)

**Priority:** MEDIUM (quality assurance)

**Objective:** Validate integration and handle edge cases

**Tasks:**

1. **Integration Testing** (60 min)
   - Test complex identifier patterns
   - Test backward compatibility
   - Test mode switching (RFC 5141 vs. bis)

2. **Edge Case Testing** (45 min)
   - Very long supplement chains (5+ levels)
   - Maximum copublishers (4)
   - Mixed mode URNs
   - Future document types

3. **Performance Testing** (15 min)
   - Benchmark URN generation
   - Compare to V1 (if available)
   - Optimize if needed

**Expected Results:**
- Edge cases handled gracefully
- Performance acceptable (<1ms per URN)
- Integration validated

---

## PHASE 3: DOCUMENTATION (Sessions 87-88)

### Session 87: Technical Documentation (2 hours)

**Priority:** HIGH (user-facing)

**Objective:** Complete technical documentation for RFC 5141-bis

**Tasks:**

1. **Create URN Generation Guide** (75 min)
   ```asciidoc
   = URN Generation Guide
   
   == Overview
   PubID supports both RFC 5141 and RFC 5141-bis URN generation.
   
   == Usage
   [source,ruby]
   ----
   id = PubidNew::Iso.parse("ISO/IEC 27001:2013")
   
   # RFC 5141-bis (default, explicit language)
   id.to_urn
   # => "urn:iso:std:iso-iec:27001:ed-1:en"
   
   # RFC 5141 (backward compatible)
   id.to_urn(mode: :rfc5141)
   # => "urn:iso:std:iso-iec:27001:ed-1"
   ----
   
   == Extensions
   [Details of RFC 5141-bis extensions]
   
   == Examples
   [Comprehensive examples]
   ====
   ```

2. **Update Architecture Documentation** (30 min)
   - Add URN generation section to `docs/V2_ARCHITECTURE.adoc`
   - Explain clean separation (UrnGenerator)
   - Show component design

3. **Update README** (15 min)
   - Add RFC 5141-bis announcement
   - Link to specification and guides
   - Update feature list

**Expected Results:**
- Complete URN generation guide
- Updated architecture docs
- Updated README

**Deliverables:**
- `docs/URN-GENERATION-GUIDE.adoc`
- Updated `docs/V2_ARCHITECTURE.adoc`
- Updated `README.adoc`

---

### Session 88: Release Notes & Polish (2 hours)

**Priority:** HIGH (release preparation)

**Objective:** Finalize documentation and prepare for release

**Tasks:**

1. **Create Release Notes** (60 min)
   ```markdown
   # RFC 5141-bis Implementation Release Notes
   
   ## Overview
   PubID V2 now supports RFC 5141-bis, extending ISO URN capabilities.
   
   ## New Features
   - Extended copublisher syntax (ISO/IEC/IEEE)
   - Extended document types (DIR, DIR-SUP)
   - Extended stage codes (WD, CD, DIS, FDIS, PDAM, etc.)
   - Bundled identifier URN generation
   - Explicit language specification
   - Supplement chain ordering
   
   ## Breaking Changes
   - Language codes now included by default (explicit > implicit)
   - Can revert to RFC 5141 mode if needed
   
   ## Migration Guide
   [Details on migrating from RFC 5141]
   ```

2. **Finalize Compliance Report** (45 min)
   - Document 100% RFC 5141-bis compliance
   - List all implemented extensions
   - Provide certification statement

3. **Archive Temporary Documentation** (15 min)
   ```bash
   mkdir -p docs/old-docs
   mv docs/session-*.md docs/old-docs/
   mv docs/SESSION-*.md docs/old-docs/
   ```

**Expected Results:**
- Complete release notes
- RFC 5141-bis certification
- Clean documentation structure
- **Project ready for release**

**Deliverables:**
- `docs/RFC-5141-BIS-RELEASE-NOTES.md`
- `docs/RFC-5141-BIS-COMPLIANCE-REPORT.md`
- Clean docs/ directory

---

## PHASE 4: IEC IMPROVEMENTS (Sessions 89-90, Optional)

### Session 89-90: IEC Polish (4 hours, optional)

**Priority:** LOW (optional improvement)

**Objective:** Bring IEC from 86.0% to 90%+

**Tasks:**

1. **Analyze IEC Failures** (60 min)
   - Group 136 failures by pattern
   - Identify top 3-5 fixable patterns

2. **Implement IEC Fixes** (120 min)
   - Focus on highest-impact patterns
   - Parser enhancements
   - Test incrementally

3. **Documentation** (60 min)
   - Document IEC improvements
   - Update status

**Expected Results:**
- IEC: 876-896/973 (90-92%, +39-59 tests)
- All 13 flavors ≥90% or documented

---

## SUCCESS CRITERIA

### Minimum Success (Sessions 81-84)

- ✅ RFC 5141-bis specification complete (948 lines)
- ✅ Implementation plan complete (717 lines)
- ✅ URN Generator implemented
- ✅ 19/19 ISO URN tests passing (100%)
- ✅ Basic documentation

### Target Success (Sessions 81-88)

- ✅ All RFC 5141-bis extensions implemented
- ✅ Comprehensive test suite (30-40 tests)
- ✅ 100% RFC 5141-bis compliance
- ✅ Complete technical documentation
- ✅ Release notes and compliance report

### Stretch Success (Sessions 81-90)

- ✅ RFC 5141-bis certified
- ✅ IEC improvements to 90%+
- ✅ All documentation polished
- ✅ Community validation

---

## KEY DELIVERABLES CHECKLIST

### Specifications

- [x] RFC 5141-bis specification (948 lines, Metanorma format)
- [x] Implementation plan (717 lines)
- [x] ISO URN analysis (501 lines)
- [ ] RFC 5141-bis compliance report
- [ ] URN generation guide
- [ ] Release notes

### Implementation

- [ ] UrnGenerator class architecture
- [ ] Extended copublisher support
- [ ] Extended document type support
- [ ] Extended stage code support
- [ ] BundledIdentifier.to_urn method
- [ ] Explicit language specification
- [ ] Supplement chain semantics

### Testing

- [ ] Language code tests (15 tests fixed)
- [ ] Edition placement tests (3 tests fixed)
- [ ] Bundled identifier test (1 test fixed)
- [ ] RFC 5141-bis compliance suite (30-40 new tests)
- [ ] Integration tests
- [ ] Edge case tests

### Documentation

- [ ] URN generation guide (AsciiDoc)
- [ ] Architecture documentation updates
- [ ] README updates
- [ ] Release notes
- [ ] Compliance report
- [ ] Migration guide

---

## TIMELINE SUMMARY

| Phase | Sessions | Duration | Key Deliverable |
|-------|----------|----------|-----------------|
| Planning | 80 | 2h | RFC 5141-bis spec + plan ✅ |
| Implementation | 81-84 | 8h | 19/19 URN tests (100%) |
| Testing | 85-86 | 4h | RFC compliance certified |
| Documentation | 87-88 | 4h | Complete docs + release notes |
| Polish (optional) | 89-90 | 4h | IEC improvements |
| **TOTAL** | **80-90** | **22h** | **RFC 5141-bis complete** |

---

## SESSION 81 START CHECKLIST

**Before starting Session 81:**

1. ✅ Read this continuation plan
2. ✅ Read RFC 5141-bis specification (`docs/RFC-5141-BIS.adoc`)
3. ✅ Read implementation plan (`docs/RFC-5141-BIS-IMPLEMENTATION-PLAN.md`)
4. ✅ Read memory bank files:
   - `.kilocode/rules/memory-bank/architecture.md`
   - `.kilocode/rules/memory-bank/context.md`
   - `docs/ISO_URN_ANALYSIS.md`

**First commands to run:**
```bash
# Confirm baseline
bundle exec rspec spec/pubid_new/iso/identifier_spec.rb | grep "urn generation"

# Count URN failures
bundle exec rspec spec/pubid_new/iso/identifier_spec.rb 2>&1 | grep -c "urn generation"
```

**Then proceed with:**
1. Create `lib/pubid_new/iso/urn_generator.rb`
2. Implement language code explicit specification
3. Update `identifier.rb` to use generator
4. Fix 15 language-related URN tests

---

## ARCHITECTURAL PRINCIPLES (REMINDER)

**For RFC 5141-bis Implementation:**

1. **Separation of Concerns**
   - URN generation separate from identifier logic
   - UrnGenerator class with single responsibility
   - Component-based generation

2. **Backward Compatibility**
   - Support both RFC 5141 and RFC 5141-bis modes
   - Default to RFC 5141-bis (explicit > implicit)
   - Allow mode switching via parameter

3. **Standards Compliance**
   - Follow RFC 5141-bis ABNF exactly
   - Implement all specified extensions
   - Document any deviations

4. **Clean Architecture**
   - No hardcoded URN strings
   - Component generators for each part
   - Testable, maintainable code

5. **Progressive Enhancement**
   - Can implement extensions incrementally
   - Each extension independently testable
   - Graceful degradation if needed

---

**Good luck with Session 81 - implementing RFC 5141-bis URN generator!** 🚀

**Remember:** This is a major enhancement that brings PubID beyond RFC 5141 capabilities while maintaining full backward compatibility. Take time to design the architecture correctly in Session 81, and the rest will follow smoothly.