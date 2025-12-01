# RFC 5141-bis Implementation Plan

**Created:** 2025-12-01  
**Status:** Planning Phase  
**Timeline:** 10-12 sessions estimated

---

## Executive Summary

This document outlines the implementation plan for RFC 5141-bis, the supplement to RFC 5141 that extends ISO URN namespace capabilities.

**Deliverables:**
1. RFC 5141-bis specification (✅ COMPLETE - 948 lines)
2. PubID URN generator enhancements
3. Test suite for RFC 5141-bis compliance
4. Updated documentation
5. Backward compatibility validation

**Project Phases:**
- Phase 1: Core URN Extensions (Sessions 81-83, 6 hours)
- Phase 2: Advanced Features (Sessions 84-85, 4 hours)
- Phase 3: Testing & Validation (Session 86, 2 hours)
- Phase 4: Documentation (Sessions 87-88, 4 hours)

**Total Estimated Time:** 16 hours (8 sessions)

---

## Background Context

### Current State (Session 80 Complete)

**ISO Implementation:**
- Core functionality: 2,654/2,654 (100%) ✅
- Active tests: 2,654/2,673 (99.29%)
- **19 URN format differences** (not bugs)

**URN Difference Patterns:**
1. Language code inclusion (15 tests)
2. Edition placement (3 tests)
3. Missing BundledIdentifier.to_urn (1 test)

**RFC 5141-bis Created:**
- 948-line specification
- Documents all RFC 5141 limitations
- Proposes backward-compatible extensions
- Provides complete ABNF syntax

---

## Implementation Philosophy

### Guiding Principles

1. **Backward Compatibility First**
   - All RFC 5141 URNs must remain valid
   - Extensions are additive, not modifications
   - Progressive enhancement strategy

2. **Standards Compliance**
   - Implement RFC 5141-bis exactly as specified
   - Follow ABNF syntax precisely
   - Maintain semantic correctness

3. **Architecture Preservation**
   - Keep MODEL-DRIVEN architecture
   - No changes to core identifier classes
   - URN generation as separate concern

4. **Test-Driven Development**
   - Write tests before implementation
   - RFC 5141-bis examples as test fixtures
   - Comprehensive coverage of edge cases

5. **Pragmatic Adoption**
   - Implement high-value features first
   - Can phase in extensions progressively
   - Document what's implemented vs. planned

---

## Phase 1: Core URN Extensions (Sessions 81-83)

### Session 81: URN Generator Architecture (2 hours)

**Objective:** Create extensible URN generation framework

**Tasks:**

1. **Design URN Generator System** (30 min)
   - Create `PubidNew::Iso::UrnGenerator` class
   - Separate from identifier rendering (SRP)
   - Support both RFC 5141 and RFC 5141-bis modes

2. **Implement Base URN Generation** (45 min)
   - Convert existing `to_urn` to use generator
   - Extract URN components from identifier
   - Handle all RFC 5141 patterns

3. **Add Language Specification** (30 min)
   - Implement explicit language inclusion
   - Follow RFC 5141-bis guidance (explicit > implicit)
   - Update 15 language-related tests

4. **Testing** (15 min)
   - Verify backward compatibility
   - Test language code generation
   - Document changes

**Expected Results:**
- New UrnGenerator class
- Language codes properly included
- 15/19 URN tests passing (78.9% → 84.2%)

**Files to Create:**
- `lib/pubid_new/iso/urn_generator.rb`

**Files to Modify:**
- `lib/pubid_new/iso/identifier.rb` (use generator)
- `spec/pubid_new/iso/identifier_spec.rb` (URN tests)

---

### Session 82: Extended Document Types & Copublishers (2 hours)

**Objective:** Support new document types and copublisher patterns

**Tasks:**

1. **Extended Document Types** (45 min)
   - Add DIR (Directive) support
   - Add DIR-SUP (Directive Supplement)
   - Update type mapping in generator

2. **Extended Copublishers** (45 min)
   - Support dynamic copublisher combinations
   - Handle ISO/IEC/IEEE patterns
   - Alphabetical ordering logic

3. **Testing** (30 min)
   - Test new document types
   - Test extended copublisher patterns
   - Verify RFC 5141 compatibility

**Expected Results:**
- DIR and DIR-SUP URN generation
- ISO/IEC/IEEE copublisher support
- Full RFC 5141-bis type compliance

**Files to Modify:**
- `lib/pubid_new/iso/urn_generator.rb`
- `spec/pubid_new/iso/urn_generator_spec.rb` (new)

---

### Session 83: Stage Codes & Edition Placement (2 hours)

**Objective:** Implement extended stage codes and supplement chain semantics

**Tasks:**

1. **Typed Stage Codes** (60 min)
   - Map TypedStage to RFC 5141-bis codes
   - Handle iteration numbers (no 'v' prefix)
   - Support WD, CD, DIS, FDIS, PDAM, etc.

2. **Supplement Chain Ordering** (45 min)
   - Implement semantic ordering rules
   - Handle edition placement correctly
   - Fix 3 edition-related failures

3. **Testing** (15 min)
   - Test all stage code patterns
   - Test edition placement
   - Verify supplement chains

**Expected Results:**
- Extended stage code support
- Correct edition placement (3 tests fixed)
- 18/19 URN tests passing (94.7%)

**Files to Modify:**
- `lib/pubid_new/iso/urn_generator.rb`
- `spec/pubid_new/iso/urn_generator_spec.rb`

---

## Phase 2: Advanced Features (Sessions 84-85)

### Session 84: Bundled Identifiers (2 hours)

**Objective:** Implement bundled identifier URN generation

**Tasks:**

1. **BundledIdentifier URN Support** (90 min)
   - Implement `to_urn` for BundledIdentifier
   - Handle component bundling with `+`
   - Support multiple document bundling

2. **Base Stage in Supplement Context** (20 min)
   - Support stage specification for base when amended
   - Distinguish draft vs. published bases

3. **Testing** (10 min)
   - Test bundled identifier URNs
   - Test base stage specifications
   - Verify 19/19 tests passing (100%)

**Expected Results:**
- BundledIdentifier.to_urn implemented
- Base stage support complete
- **ISO URN: 100% (19/19 tests passing)** 🎉

**Files to Modify:**
- `lib/pubid_new/iso/identifiers/bundled_identifier.rb`
- `lib/pubid_new/iso/urn_generator.rb`
- `spec/pubid_new/iso/identifiers/bundled_identifier_spec.rb`

---

### Session 85: RFC 5141-bis Compliance Validation (2 hours)

**Objective:** Comprehensive RFC 5141-bis compliance testing

**Tasks:**

1. **Create RFC 5141-bis Test Suite** (90 min)
   - Extract all examples from RFC 5141-bis spec
   - Create comprehensive test fixtures
   - Cover all syntax extensions

2. **Validation & Documentation** (30 min)
   - Run compliance tests
   - Document compliance level
   - Generate compliance report

**Expected Results:**
- Comprehensive RFC 5141-bis test suite
- Documented compliance level
- Ready for production use

**Files to Create:**
- `spec/pubid_new/iso/rfc_5141_bis_spec.rb`
- `docs/RFC-5141-BIS-COMPLIANCE.md`

---

## Phase 3: Testing & Validation (Session 86)

### Session 86: Integration Testing & Edge Cases (2 hours)

**Objective:** Validate integration and handle edge cases

**Tasks:**

1. **Integration Testing** (60 min)
   - Test URN round-trip (if supported)
   - Test complex identifier patterns
   - Test backward compatibility

2. **Edge Case Handling** (45 min)
   - Very long supplement chains
   - Maximum copublishers (4)
   - Future-proofing considerations

3. **Performance Testing** (15 min)
   - Benchmark URN generation
   - Optimize if needed
   - Document performance

**Expected Results:**
- Comprehensive integration tests
- Edge cases handled
- Performance validated

**Files to Create:**
- `spec/pubid_new/iso/urn_integration_spec.rb`

---

## Phase 4: Documentation (Sessions 87-88)

### Session 87: Technical Documentation (2 hours)

**Objective:** Complete technical documentation

**Tasks:**

1. **Update Architecture Documentation** (60 min)
   - Document URN generation architecture
   - Explain RFC 5141-bis support
   - Show usage examples

2. **Create URN Usage Guide** (45 min)
   - How to generate RFC 5141-bis URNs
   - When to use which syntax
   - Migration from RFC 5141

3. **Update README** (15 min)
   - Add RFC 5141-bis announcement
   - Link to specification
   - Update feature list

**Expected Results:**
- Complete technical documentation
- Usage guide
- Updated README

**Files to Create:**
- `docs/URN-GENERATION-GUIDE.adoc`

**Files to Modify:**
- `docs/V2_ARCHITECTURE.adoc`
- `README.adoc`

---

### Session 88: Final Polish & Release Notes (2 hours)

**Objective:** Finalize documentation and prepare for release

**Tasks:**

1. **Create Release Notes** (45 min)
   - RFC 5141-bis implementation changelog
   - Breaking changes (if any)
   - Upgrade guide

2. **Compliance Documentation** (45 min)
   - Document RFC 5141-bis compliance level
   - List implemented extensions
   - Note future enhancements

3. **Final Review** (30 min)
   - Review all documentation
   - Verify examples work
   - Update implementation status

**Expected Results:**
- Complete release notes
- RFC 5141-bis compliance certified
- **Project ready for release**

**Files to Create:**
- `docs/RFC-5141-BIS-RELEASE-NOTES.md`
- `docs/RFC-5141-BIS-COMPLIANCE-REPORT.md`

---

## Implementation Architecture

### URN Generator Design

**Separation of Concerns:**

```ruby
# Current (tightly coupled)
class Identifier
  def to_urn
    # URN generation mixed with identifier logic
  end
end

# RFC 5141-bis (clean separation)
class Identifier
  def to_urn(mode: :bis)
    UrnGenerator.new(self, mode: mode).generate
  end
end

class UrnGenerator
  def initialize(identifier, mode: :bis)
    @identifier = identifier
    @mode = mode # :rfc5141 or :bis
  end

  def generate
    # Clean URN generation logic
    # Delegates to component generators
  end
end
```

**Component Generators:**

```ruby
class UrnGenerator
  def originator_component
    # Handle extended copublishers
  end

  def type_component
    # Handle extended document types
  end

  def stage_component
    # Handle typed stages with iterations
  end

  def language_component
    # Explicit language specification
  end

  def supplement_component
    # Handle supplement chains with semantics
  end
end
```

---

## Testing Strategy

### Test Pyramid

**Level 1: Unit Tests (RFC 5141-bis Components)**
- Test each URN component in isolation
- ExtendedCopublisher generation
- ExtendedDocumentType mapping
- TypedStage conversion
- Language specification logic
- Supplement chain ordering

**Level 2: Integration Tests (Full URN Generation)**
- Test complete URN generation
- Test complex patterns
- Test backward compatibility
- Test mode switching (RFC 5141 vs. bis)

**Level 3: Compliance Tests (RFC 5141-bis Examples)**
- Test all specification examples
- Verify ABNF compliance
- Document conformance level

**Level 4: Regression Tests (Existing ISO URN Tests)**
- Ensure no regressions
- Validate fixes for 19 failures
- Maintain or improve pass rate

---

## Success Criteria

### Minimum Success (80%)

- ✅ RFC 5141-bis specification complete
- ✅ URN Generator architecture implemented
- ✅ Language code extension (15/19 tests)
- ✅ Basic documentation complete

### Target Success (95%)

- ✅ All RFC 5141-bis extensions implemented
- ✅ 19/19 ISO URN tests passing (100%)
- ✅ Comprehensive test suite
- ✅ Complete technical documentation

### Stretch Success (100%)

- ✅ RFC 5141-bis fully certified
- ✅ Performance optimized
- ✅ Migration guide complete
- ✅ Community validation

---

## Risk Management

### Technical Risks

**Risk:** URN generation complexity
- **Mitigation:** Clean architecture, separate generator
- **Fallback:** Phase in features progressively

**Risk:** Backward compatibility issues
- **Mitigation:** Comprehensive regression testing
- **Fallback:** Support both RFC 5141 and bis modes

**Risk:** ABNF parsing ambiguities
- **Mitigation:** Follow spec exactly, document decisions
- **Fallback:** Consult RFC authors if needed

### Schedule Risks

**Risk:** Implementation takes longer than 8 sessions
- **Mitigation:** Focus on high-value features first
- **Fallback:** Document partial compliance, plan future work

**Risk:** Testing reveals architectural issues
- **Mitigation:** Early integration testing
- **Fallback:** Revise architecture if needed

---

## Dependencies

### Internal Dependencies

- PubID V2 architecture (stable)
- ISO identifier classes (complete)
- Component model (stable)
- TypedStage system (working)

### External Dependencies

- RFC 5141 specification (published 2008)
- RFC 5141-bis specification (this project)
- ISO/IEC Directives (reference)

---

## Deliverables Checklist

### Specifications

- [x] RFC 5141-bis specification (948 lines)
- [ ] RFC 5141-bis compliance report
- [ ] URN generation guide
- [ ] Migration guide

### Implementation

- [ ] UrnGenerator class
- [ ] Extended copublisher support
- [ ] Extended document type support
- [ ] Extended stage code support
- [ ] BundledIdentifier.to_urn
- [ ] Language specification logic
- [ ] Supplement chain semantics

### Testing

- [ ] RFC 5141-bis test suite
- [ ] Integration tests
- [ ] Backward compatibility tests
- [ ] Performance benchmarks

### Documentation

- [ ] Architecture documentation
- [ ] Usage guide
- [ ] Release notes
- [ ] Compliance report
- [ ] Updated README

---

## Session-by-Session Summary

| Session | Focus | Duration | Deliverable |
|---------|-------|----------|-------------|
| 81 | URN Generator + Language | 2h | Generator class, 15/19 tests |
| 82 | Types + Copublishers | 2h | Extended support |
| 83 | Stages + Edition | 2h | 18/19 tests passing |
| 84 | Bundled IDs | 2h | 19/19 tests (100%!) |
| 85 | RFC Compliance | 2h | Compliance suite |
| 86 | Integration | 2h | Edge cases handled |
| 87 | Tech Docs | 2h | Complete documentation |
| 88 | Polish | 2h | Release ready |

**Total:** 16 hours (8 sessions)

---

## Next Steps

**Immediate (Session 81):**
1. Review this implementation plan
2. Create UrnGenerator class architecture
3. Implement language code extension
4. Begin fixing URN tests

**Short-term (Sessions 82-84):**
1. Implement all RFC 5141-bis extensions
2. Fix all 19 URN test failures
3. Create comprehensive test suite

**Medium-term (Sessions 85-86):**
1. Validate RFC 5141-bis compliance
2. Integration testing
3. Performance validation

**Long-term (Sessions 87-88):**
1. Complete all documentation
2. Prepare for release
3. Community validation

---

## Appendix: RFC 5141-bis Extension Summary

### Implemented in Specification

1. ✅ Extended copublisher syntax (dynamic combinations)
2. ✅ Extended document types (DIR, DIR-SUP, IWA-SUP)
3. ✅ Extended stage codes (WD, CD, DIS, FDIS, PDAM, etc.)
4. ✅ Supplement chain ordering semantics
5. ✅ Base identifier stage specification
6. ✅ Bundled identifier syntax
7. ✅ Explicit language specification guidance
8. ✅ Complete ABNF syntax
9. ✅ Comprehensive examples

### To Be Implemented in PubID

1. ⏳ UrnGenerator architecture
2. ⏳ Language code explicit inclusion
3. ⏳ Extended copublisher support
4. ⏳ Extended document type support
5. ⏳ Extended stage code conversion
6. ⏳ Edition placement semantics
7. ⏳ BundledIdentifier URN generation
8. ⏳ Base stage specification

### Testing Coverage

1. ⏳ Fix 19 existing URN test failures
2. ⏳ Add RFC 5141-bis example tests
3. ⏳ Add integration tests
4. ⏳ Add edge case tests
5. ⏳ Add performance tests

---

**Document Version:** 1.0  
**Last Updated:** 2025-12-01  
**Status:** Planning Complete, Ready for Implementation