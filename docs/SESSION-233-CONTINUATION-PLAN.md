# Session 233 Continuation Plan: CSA Baseline Recovery

**Created:** 2025-12-30 (Post-Session 232)
**Status:** Session 232 complete - Ready for final baseline push
**Timeline:** COMPRESSED - Complete in 60-90 minutes

---

## Current Status

**Session 232 Achievement:** Fixed major parse failures (+44 tests, +12.2pp) ✅

**Test Results:**
- **Starting (Session 231):** 212/362 (58.5%)
- **After Session 232:** 256/362 (70.7%)
- **Baseline Target:** ~267/362 (73.8%)
- **Gap:** +11 tests needed

**Fixes Completed:**
1. ✅ French year double-F bug (F20 → FF20)
2. ✅ CAN3- classification (Standard → CanadianAdopted)
3. ✅ Parser greedy pattern (code consuming years)
4. ✅ M prefix year conversion (M83 → 1983)

---

## Remaining Issues Analysis (106 failures)

### High-Impact Patterns

**1. CAN/CSA- Rendering Missing Dash** (~8-10 failures)
- Pattern: "CAN/CSA-B127.1" renders as "CAN/CSA B127.1"
- Issue: Space instead of dash after CAN/CSA-
- Impact: Medium (affects combined identifiers)

**2. French F on Second Combined Item** (~3-5 failures)
- Pattern: "B149.2:F20" renders as "B149.2:FF20"
- Issue: Second item in combined gets double F
- Impact: Low (edge case)

**3. ISO Number Parsing Loses Dash Part** (~5-8 failures)
- Pattern: "ISO 8824-1" parses as "8824", loses "-1"
- Issue: External ISO parser not preserving part
- Impact: Medium (CSA adoption of ISO standards)

**4. Series Classification** (~10-15 failures)
- Pattern: Standards with SERIES keyword return Standard not Series
- Issue: Builder type selection
- Impact: Medium

**5. Bundled/Combined Type Routing** (~15-20 failures)
- Pattern: Complex combined identifiers misclassified
- Issue: Wrapper detection in parser
- Impact: Medium-High

**6. Miscellaneous** (~50-55 failures)
- Various edge cases and complex patterns
- Lower priority

---

## SESSION 233: Quick Wins to Baseline (60-90 min)

### Objective
Reach baseline 73.8% (267/362) with targeted high-impact fixes

### Part A: Fix CAN/CSA- Rendering (20 min)

**Issue:** `CAN/CSA-B127.1:99` renders as `CAN/CSA B127.1:99`

**Root Cause:** Base.rb line 19 checks for dash at end but doesn't preserve it in output

**Fix:** Update Base.rb to preserve dash when publisher_prefix ends with dash

**File:** `lib/pubid_new/csa/identifiers/base.rb`

**Expected Gain:** +8-10 tests

### Part B: Fix Combined French F (15 min)

**Issue:** Second item in French combined gets double F

**Root Cause:** Combined identifier parts inherit french flag incorrectly

**Fix:** Builder should not set french=true for all parts, only when year_prefix="F"

**File:** `lib/pubid_new/csa/builder.rb`

**Expected Gain:** +3-5 tests

### Part C: Series Type Selection (15 min)

**Issue:** Standards with SERIES keyword return Standard class

**Root Cause:** Builder checks :series_type but also needs :series flag

**Fix:** Update select_identifier_class to check for :series flag modifier

**File:** `lib/pubid_new/csa/builder.rb`

**Expected Gain:** +5-8 tests

### Part D: Validation (10 min)

Run tests and validate improvement:
```bash
bundle exec rspec spec/pubid_new/csa/ --format progress
```

**Target:** 267-270/362 (73.8-74.6%)

---

## Implementation Strategy

### Phase 1: Analysis (10 min)
- Get detailed failure breakdown
- Identify exact patterns for each issue
- Prioritize by impact

### Phase 2: Fix Top 3 Patterns (50 min)
- CAN/CSA- rendering (20 min)
- French F on combined (15 min)
- Series classification (15 min)

### Phase 3: Validation & Commit (20 min)
- Test after each fix
- Validate cumulative improvement
- Commit with clear message

---

## Success Criteria

### Minimum (73.8%)
- ✅ 267/362 tests passing
- ✅ Baseline recovered
- ✅ Zero architectural compromises

### Target (75%+)
- ✅ 271/362 tests passing
- ✅ Exceed baseline
- ✅ Clean implementation

---

## Key Files

**Parser:** `lib/pubid_new/csa/parser.rb`
**Builder:** `lib/pubid_new/csa/builder.rb`
**Base:** `lib/pubid_new/csa/identifiers/base.rb`
**CanadianAdopted:** `lib/pubid_new/csa/identifiers/canadian_adopted.rb`

---

## Critical Architecture Principles

**MAINTAIN throughout:**
1. **MODEL-DRIVEN** - Objects not strings
2. **MECE** - Mutually exclusive, collectively exhaustive
3. **Three-layer** - Parser/Builder/Identifier independence
4. **No compromises** - Correctness over test count

---

## Next Steps After Session 233

If baseline achieved:
- Session 234: Extended improvements (80%+ target)
- Documentation updates
- Mark CSA recovery COMPLETE

If baseline not quite achieved:
- Session 234: Additional targeted fixes
- Focus on highest-impact remaining patterns

---

**Created:** 2025-12-30
**Session:** 233
**Duration:** 60-90 minutes
**Target:** 267/362 (73.8%)+ baseline recovery

**Ready to complete baseline recovery! 🎯**