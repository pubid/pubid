# Session 83+ Continuation Plan: Complete RFC 5141-bis URN Implementation

**Created:** 2025-12-01 (Post-Session 82)  
**Status:** RFC 5141-bis SIMPLIFIED, 143 URN failures remaining  
**Timeline:** COMPRESSED - 4-5 sessions to completion (Sessions 83-87)

---

## Executive Summary

**Session 82 Achievement:** Simplified UrnGenerator to RFC 5141-bis only

**Current Status:**
- **Simplification:** ✅ COMPLETE (RFC 5141-bis only, no dual-mode)
- **Type filtering:** ✅ FIXED (`:is` correctly filtered)
- **URN Tests:** 185/328 passing (56.4%), 143 failures, 34 pending
- **Amendment tests:** 21/49 passing (42.9%)

**Remaining Work:**
1. **Phase 1 (Session 83):** Fix stage handling (NP, WD, CD patterns) - 60-90 min
2. **Phase 2 (Session 84):** Fix language and harmonized stages - 60-90 min
3. **Phase 3 (Session 85):** BundledIdentifier + Edge cases - 90-120 min
4. **Phase 4 (Sessions 86-87):** Documentation and compliance - 120-180 min

**End Goal:** 90%+ URN tests passing, RFC 5141-bis compliance certified

---

## CURRENT STATE (Session 82 Complete)

### Session 82 Achievement Summary

**Part A: Simplification (60 min)**
- Removed MODE_RFC5141 and MODE_BIS constants
- Removed `mode` parameter from all methods
- Fixed type_code comparison bug (string vs symbol)
- Simplified to RFC 5141-bis only

**Results:**
- Code: 325 → 290 lines (35 lines removed)
- Amendment URNs: 0/49 → 21/49 (+42.9%)
- Overall URNs: 185/328 (56.4%)

**Commit:** `bcb0aa4` - refactor(iso): simplify UrnGenerator to RFC 5141-bis only

### Test Breakdown

| Test Suite | Passing | Failing | Pending | Pass Rate |
|------------|---------|---------|---------|-----------|
| Amendments | 21 | 28 | 0 | 42.9% |
| All URN tests | 185 | 143 | 34 | 56.4% |

### Failure Analysis Needed

Primary failure patterns (to be analyzed in Session 83):
1. Draft stage handling (NP, WD, CD, etc.)
2. Harmonized stage codes (stage-XX.XX)
3. Language code explicit inclusion
4. Iteration formatting
5. Edition placement in supplements

---

## PHASE 1: FIX STAGE HANDLING (Session 83)

### Objective
Fix draft stage URN generation to use proper typed stage codes

### Current Problem

**Failure Example:**
```
Expected: "urn:iso:std:iso:10791:-6:stage-00.00:amd:1:v1"
Got:      "urn:iso:std:iso:10791:-6:amd:1:v1"
```

Draft stages (NP, WD, CD, etc.) are not being included in URNs when they should be.

### Root Cause

The `stage_component` method only includes stages from `TYPED_STAGE_MAP`, but many draft stages are not in the map. It returns `nil` for unmapped stages, but it should fall back to harmonized stage codes.

### Solution

**Enhance `stage_component` to handle all stages:**

```ruby
def stage_component
  return nil unless identifier.typed_stage
  
  stage_code = identifier.typed_stage.stage_code
  return nil if !stage_code || stage_code.to_s == "published"

  # Try typed stage abbreviations first (RFC 5141-bis)
  if TYPED_STAGE_MAP.key?(stage_code.to_sym)
    stage_abbr = TYPED_STAGE_MAP[stage_code.to_sym]
    
    # Add iteration if present
    if identifier.stage_iteration
      return "#{stage_abbr}.#{identifier.stage_iteration.value}"
    end
    
    return stage_abbr
  end

  # Fallback: use harmonized stage codes for unmapped stages
  harmonized_code = identifier.typed_stage.harmonized_stages&.first
  return nil unless harmonized_code
  
  # Skip published documents
  return nil if harmonized_code.start_with?("60.")

  stage_part = "stage-#{harmonized_code}"
  
  # Add iteration if present
  if identifier.stage_iteration
    stage_part += ".#{identifier.stage_iteration.value}"
  end
  
  stage_part
end
```

### Expected Results

- **NP/WD/CD stages:** Should use harmonized codes (stage-00.00, stage-20.20, stage-30.00)
- **Typed stages:** Continue using typed abbreviations (FDAM, DAM, etc.)
- **Published:** No stage component (filtered)

**Expected improvement:** +40-50 tests (185/328 → 225-235/328, 68-72%)

**Time:** 60-90 minutes

---

## PHASE 2: FIX LANGUAGE & HARMONIZED STAGES (Session 84)

### Objective
Ensure explicit language codes and correct harmonized stage handling

### Tasks

#### Task 1: Explicit Language Codes (30 min)

**Problem:** Language codes not always included when they should be

**Solution:**
- Verify `language_component` always returns language codes
- Ensure supplements include language codes from both base and supplement
- Test with multilingual identifiers

#### Task 2: Harmonized Stage Edge Cases (30 min)

**Problem:** Some harmonized stages not handled correctly

**Solution:**
- Handle all stage codes from 00.00 to 95.99
- Ensure proper filtering of published stages (60.00, 60.60)
- Test with edge case stages

#### Task 3: Stage Iterations (30 min)

**Problem:** Iteration formatting inconsistent

**Current:** Some use `v1.2`, some use different formats

**Solution:**
- Supplements without dates: `v#{number}.#{iteration}` if iteration present
- Supplements with dates: `v#{number}.#{iteration}` format
- Ensure consistency across all identifier types

### Expected Results

**Expected improvement:** +30-40 tests (225-235/328 → 255-275/328, 78-84%)

**Time:** 90 minutes

---

## PHASE 3: BUNDLED IDENTIFIERS & EDGE CASES (Session 85)

### Objective
Complete URN support for all identifier types

### Tasks

#### Task 1: BundledIdentifier URN Support (45 min)

**Create `to_urn` method:**

```ruby
# lib/pubid_new/iso/identifiers/bundled_identifier.rb
def to_urn
  require_relative '../urn_generator'
  # Bundled identifiers need special format
  # e.g., "ISO 8601-1+8601-2:2019" → "urn:iso:std:iso:8601:-1,-2:ed-1:en"
  parts = identifiers.map { |id| UrnGenerator.new(id).generate }
  # Combine intelligently
  combined_urn = generate_bundled_urn(parts)
  combined_urn
end

private

def generate_bundled_urn(parts)
  # Implementation for bundling multiple URNs
  # Follow RFC 5141-bis bundled identifier syntax
end
```

#### Task 2: Edge Cases (45 min)

**Fix remaining edge cases:**
- Multi-level supplements (Amd/Cor chains)
- Draft base identifiers with supplements
- Complex edition handling
- Special identifier types (Addendum, Extract, etc.)

### Expected Results

**Expected improvement:** +20-30 tests (255-275/328 → 275-305/328, 84-93%)

**Time:** 90-120 minutes

---

## PHASE 4: DOCUMENTATION & COMPLIANCE (Sessions 86-87)

### Session 86: Technical Documentation (120 min)

#### Task 1: URN Generation Guide (60 min)

**Create:** `docs/URN-GENERATION-GUIDE.adoc`

**Content:**
- RFC 5141-bis overview
- Usage examples for all identifier types
- Component-by-component explanation
- API documentation
- Troubleshooting guide

#### Task 2: Update Architecture Docs (30 min)

**Update:** `docs/V2_ARCHITECTURE.adoc`

**Add section:**
- URN generation architecture
- UrnGenerator design decisions
- Component interaction diagram

#### Task 3: Update README (30 min)

**Update:** `README.adoc`

**Add:**
- RFC 5141-bis announcement
- URN generation examples
- Link to detailed guide

---

### Session 87: Compliance & Cleanup (60-120 min)

#### Task 1: RFC 5141-bis Compliance Testing (60 min)

**Create compliance test suite:**

```ruby
# spec/pubid_new/iso/rfc_5141_bis_spec.rb
RSpec.describe "RFC 5141-bis Compliance" do
  RFC_5141_BIS_EXAMPLES = [
    { 
      input: "ISO/IEC/IEEE 29148:2018",
      urn: "urn:iso:std:iso-iec-ieee:29148:ed-1:en"
    },
    # ... 30-40 examples from RFC 5141-bis spec
  ].freeze
  
  RFC_5141_BIS_EXAMPLES.each do |example|
    it "generates compliant URN for #{example[:input]}" do
      id = PubidNew::Iso.parse(example[:input])
      expect(id.to_urn).to eq(example[:urn])
    end
  end
end
```

**Extract examples from:** `docs/RFC-5141-BIS.adoc`

#### Task 2: Create Compliance Report (30 min)

**Create:** `docs/RFC-5141-BIS-COMPLIANCE-REPORT.md`

**Content:**
- Compliance percentage
- Extensions implemented
- Deviations (if any)
- Test coverage
- Certification statement

#### Task 3: Archive Temporary Docs (30 min)

**Move to `docs/old-docs/sessions/`:**
- `SESSION-81-CONTINUATION-PLAN.md`
- `SESSION-82-CONTINUATION-PLAN.md`
- `session-79-iso-analysis.md`
- Other session-specific docs

---

## SUCCESS CRITERIA

### Minimum Success (Core Functionality)
- ✅ RFC 5141-bis only (no dual-mode) - COMPLETE
- ✅ Type filtering working - COMPLETE
- ⏳ Stage handling for all stages - Session 83
- ⏳ Language codes explicit - Session 84
- ⏳ 85%+ URN tests passing - Sessions 83-85

### Target Success (Production Ready)
- ⏳ 90%+ URN tests passing
- ⏳ BundledIdentifier support
- ⏳ Comprehensive documentation
- ⏳ RFC 5141-bis compliance certified

### Stretch Success (Complete)
- ⏳ 95%+ URN tests passing
- ⏳ All edge cases handled
- ⏳ Performance optimized
- ⏳ Full compliance report

---

## ARCHITECTURAL PRINCIPLES (NEVER COMPROMISE)

**RFC 5141-bis Only:**
- No MODE_RFC5141/MODE_BIS duality ✅
- Always explicit language codes
- Always typed stage codes when available
- Extended document types supported
- Dynamic copublisher combinations

**Clean Architecture:**
- UrnGenerator separate from identifiers ✅
- Component-based generation ✅
- Single responsibility per method
- MECE organization
- Extension through inheritance

**Testing Strategy:**
- Spec examples as fixtures
- Compliance-driven development
- Round-trip validation
- Performance targets: <1ms per URN

---

## TIMELINE SUMMARY

| Session | Focus | Duration | Deliverable |
|---------|-------|----------|-------------|
| 82 | Simplification | 60m | RFC 5141-bis only ✅ |
| 83 | Stage handling | 60-90m | All stages supported |
| 84 | Language & harmonized | 90m | Explicit languages |
| 85 | Bundled & edge cases | 90-120m | 85-93% passing |
| 86 | Documentation | 120m | Complete guides |
| 87 | Compliance & cleanup | 60-120m | Certification |

**Total:** 480-600 minutes (8-10 hours, 4-5 sessions)

---

## SESSION 83 START CHECKLIST

**Before starting:**

1. ✅ Read this continuation plan
2. ✅ Read Session 82 commit message (`bcb0aa4`)
3. ✅ Review `lib/pubid_new/iso/urn_generator.rb`
4. ✅ Understand: Simplification complete, now fix stage handling

**First commands:**
```bash
# Analyze stage-related failures
bundle exec rspec spec/pubid_new/iso/ -e "generates urn" 2>&1 | \
  grep -B 3 "stage-" | head -40

# Look for patterns
bundle exec rspec spec/pubid_new/iso/identifiers/amendment_spec.rb \
  -e "generates urn" 2>&1 | grep -E "(NP|WD|CD|DIS)" | head -20
```

**Key focus:** Enhance `stage_component` to handle unmapped stages via harmonized codes

---

## KEY DELIVERABLES

### Code
- [x] `lib/pubid_new/iso/urn_generator.rb` - Simplified (Session 82)
- [ ] Enhanced stage_component method (Session 83)
- [ ] BundledIdentifier.to_urn (Session 85)

### Documentation
- [x] `docs/RFC-5141-BIS.adoc` (948 lines) - Specification
- [x] `docs/RFC-5141-BIS-IMPLEMENTATION-PLAN.md` (717 lines) - Original plan
- [x] `docs/ISO_URN_ANALYSIS.md` (501 lines) - V1/V2 analysis
- [ ] `docs/URN-GENERATION-GUIDE.adoc` (Session 86)
- [ ] `docs/RFC-5141-BIS-COMPLIANCE-REPORT.md` (Session 87)

### Testing
- [x] Current: 185/328 tests passing (56.4%)
- [ ] Target: 295/328 tests passing (90%+)
- [ ] RFC 5141-bis compliance suite (30-40 tests)

---

## NOTES

### Time Compression Strategy
- Focus on highest-impact fixes first
- Accept 90% as excellent (not 100%)
- Document known limitations
- Prioritize documentation completion

### Risk Management
- If stuck on specific failures: Document and move forward
- Documentation is non-negotiable
- Compliance testing ensures correctness
- 90%+ pass rate is production-ready

---

**Ready for Session 83!** 🚀

Focus: Fix stage handling to support all draft stages via harmonized codes.