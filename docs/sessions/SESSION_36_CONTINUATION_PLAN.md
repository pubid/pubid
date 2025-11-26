# Session 36+ Continuation Plan: Complete ISO Addendum Implementation

**Created:** 2025-11-26
**Current Status:** 82.5% (2,357/2,859 passing tests)
**Target:** 85%+ (2,430+ passing tests)

---

## Current State (Session 35 Complete)

### Test Results
- **Total:** 2,859 examples
- **Passing:** 2,357 (82.5%)
- **Failing:** 22 (0.8%)
- **Pending:** 480 (16.8%)

### Session 35 Achievements
- Fixed Addendum stage code typos (dadd→dad, fdadd→fdad)
- Added "Add." legacy abbreviation support
- Impact: +8 tests (2,349 → 2,357)
- Commit: `26bf17f`

### Remaining Failures Breakdown
1. **addendum_spec:** 19 failures
   - Legacy hyphen format: 3 failures
   - DAD parsing: 16 failures
2. **builder_spec:** 3 failures (pre-existing, V1/V2 incompatibility)

---

## Phase 3: Complete Addendum Implementation (Sessions 36-37)

### Priority 1: Fix DAD Parsing (+16 tests) - Session 36

**Patterns:**
- "ISO 2631/DAD 1" (8 failures)
- "ISO 2553/DAD 1:1987" (8 failures)

**Current Status:**
- DAD/FDAD now in TYPED_STAGES (Session 35)
- Parser constants refreshed in tests
- Parser should recognize DAD automatically

**Investigation Steps:**
1. Verify TYPED_STAGES_SUPPLEMENTS includes DAD
2. Check if parser's supplement_type_with_stage rule picks up DAD
3. Test with actual examples
4. Debug parser if DAD not matching

**Expected Solution:**
- Parser should work automatically with refreshed constants
- If not, check parser rule ordering
- Verify Scheme.supplement_typed_stages includes Addendum class

**Files to Check:**
- lib/pubid_new/iso/parser.rb (line 19) - TYPED_STAGES_SUPPLEMENTS
- lib/pubid_new/iso/scheme.rb (line 51) - supplement_typed_stages method
- spec/pubid_new/iso/identifiers/addendum_spec.rb (line 386) - DAD tests

**Estimated Time:** 30-45 minutes
**Target:** 82.5% → 83.1% (2,373 passing)

### Priority 2: Fix Legacy Hyphen Format (+3 tests) - Session 36

**Pattern:** "ISO 4037-1979/Add. 1-1983(F)"

**Problem:**
- Parser treats hyphen as part separator
- Results in part="1979" instead of date.year=1979
- Same for addendum: part="1983" instead of date.year=1983

**Solution: Builder Normalization (Preferred)**
- Detect legacy format in Builder.cast(:number_with_part)
- If part looks like 4-digit year, convert to date
- Preserve architecture: Parser lenient, Builder normalizes

**Files to Modify:**
- lib/pubid_new/iso/builder.rb - Add legacy format detection

**Estimated Time:** 45-60 minutes
**Target:** 83.1% → 83.2% (2,376 passing)

---

## Documentation Tasks

### Session 36 Actions

1. Move SESSION_35_SUMMARY.md to docs/old-docs/
2. Update README.adoc with Addendum support
3. Update continuation plan status

---

## Session 36 Immediate Actions

### Step 1: Fix DAD Parsing (30-45 minutes)
### Step 2: Fix Legacy Hyphen Format (45-60 minutes)  
### Step 3: Documentation (20-30 minutes)

---

**Status:** Ready for Session 36
**Next Action:** Fix DAD parsing
**Expected Outcome:** 2,376+ passing (83.2%+)
