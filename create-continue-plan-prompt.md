# Session 17 Continuation Plan - ISO V2 Path to 50%

## Current Status (Session 16 Complete)

**Test Results:**
- 1,420 passing (49.7%)
- 718 failures (25.1%)
- 721 pending (25.2%)
- Total: 2,859 examples
- Core tests: 106/106 passing ✅

**Recent Progress:**
- Session 14: +80 tests (2.8pp) ⚡
- Session 15: +4 tests (0.1pp) ⚠️ (speculative approach)
- Session 16: +104 tests (3.6pp) 🎉 (data-driven approach)

## Session 16 Success Validation

**Strategy Effectiveness:**
- Speculative fixes (Session 15): +4 tests
- Data-driven fixes (Session 16): +104 tests (**26x improvement**)

**What Worked:**
1. Systematic failure analysis BEFORE coding
2. Prioritizing patterns by estimated impact (50-150+ tests)
3. Implementing multiple high-impact patterns in single session
4. Edition+language in supplements: ~60 tests
5. Guide TYPED_STAGES: ~40 tests
6. FPDAM parser support: ~4 tests

**Key Insight:** Data-driven analysis with impact estimation is the only effective strategy going forward.

## Session 17 Goal - Reach 50% Milestone

**Target:** 1,430 passing (50.0%) - **Only +10 tests needed!**

This is a symbolic milestone and should be easily achievable with remaining high-impact patterns from Session 16 analysis.

## Remaining High-Impact Patterns (From Session 16 Analysis)

### Pattern 1: DAD Typed Stage for Addendum (+6 tests)
**Status:** Quick win, implementation ready
**Files:** `lib/pubid_new/iso/identifiers/addendum.rb`
**Action:** Add DAD to Addendum.TYPED_STAGES (already exists but may need verification)

### Pattern 4: Base+Supplement Stage Extraction (+10-15 tests)
**Status:** Medium complexity, builder logic
**Examples:**
- ISO/IEC FDIS 23008-1/WD Amd 1
- ISO/IEC FDIS 23090-14/DAmd 1
- ISO/IEC 14496-12:2012/PDAM 4 ED4
- ISO/IEC DIS 23008-1/DAM 2:2021(E)

**Root Cause:** Builder may not correctly extract both:
- Base identifier stage (FDIS, DIS)
- Supplement typed stage (WD Amd, DAmd, PDAM)

**Files:** `lib/pubid_new/iso/builder.rb` - stage extraction in build_supplement_identifier

### Pattern 5: Directives (DIR) Implementation (+24 tests)
**Status:** Requires new identifier class
**Examples:**
- ISO/IEC Directives Part 1
- ISO/IEC Directives, Part 1:2022
- ISO/IEC JTC 1 DIR
- ISO/IEC DIR 2 ISO

**Files to create/modify:**
- `lib/pubid_new/iso/identifiers/directives.rb` (new)
- `lib/pubid_new/iso/parser.rb` (directives rule)
- `lib/pubid_new/iso/builder.rb` (directives type selection)

### Pattern 6: DIR SUP Implementation (+12 tests)
**Status:** Requires new supplement class
**Examples:**
- ISO/IEC DIR 1 SUP
- ISO Directives Part 1 Supplement 2013

**Files to create/modify:**
- `lib/pubid_new/iso/identifiers/directives_supplement.rb` (new)
- Parser and builder already partially handle this

### Pattern B: Stage Code Preservation (~100 tests)
**Status:** Complex, affects multiple identifier classes
**Issue:** Stage codes not being preserved for non-published states
- Expected "cd" got "published"
- Expected "pwi" got "published"
- Expected "wd" got "published"
- Expected "np" got "published"

**Root Cause:** Builder or identifier classes defaulting to "published" instead of preserving stage

## Session 17 Strategy

### Approach: Focus on Quick Wins to Hit 50%

Since we only need +10 tests for 50%, prioritize:

1. **Pattern 1 (DAD)**: +6 tests (5 minutes)
2. **Pattern 4 (Base+Supplement stages)**: +10-15 tests (30 minutes)

This should comfortably exceed the +10 target.

**Time Budget:**
- Analysis/Verification: 15 minutes
- Implementation: 45 minutes
- Testing/Validation: 15 minutes
- Commit/Documentation: 15 minutes
- **Total: 90 minutes**

### Optional Stretch Goals (If Time Permits)

If the above is completed quickly:

3. **Pattern 5+6 (Directives)**: +36 tests (60 minutes)
   - More complex but high impact
   - Create new identifier classes
   - Good architectural exercise

## Implementation Plan

### Step 1: Verify DAD Implementation (10 minutes)

Check if DAD is actually missing from Addendum.TYPED_STAGES or if it's a different issue:

```bash
grep -n "DAD" lib/pubid_new/iso/identifiers/addendum.rb
```

If missing, add it. If present, investigate why it's not working.

### Step 2: Fix Base+Supplement Stage Extraction (40 minutes)

**Analysis:**
1. Read failing test examples to understand pattern
2. Trace through builder.rb build_supplement_identifier method
3. Identify where base stage is lost or supplement stage isn't extracted

**Likely Issue:**
- When parsing `ISO/IEC FDIS 23008-1/WD Amd 1`:
  - Base should have stage="FDIS"
  - Supplement should have typed_stage matching "WD Amd"
  - Builder may be dropping one or both

**Fix Locations:**
- `lib/pubid_new/iso/builder.rb` lines 139-227 (build_supplement_identifier)
- May need to extract base stage before building base identifier
- May need to handle stage + typed_stage combination in supplements

### Step 3: Validation (20 minutes)

1. Run core tests: `bundle exec rspec spec/pubid_new/iso/identifier_spec.rb`
2. Run full suite: `bundle exec rspec spec/pubid_new/iso/`
3. Verify +10+ tests achieved
4. Check 50% milestone reached

### Step 4: Commit and Document (15 minutes)

Create semantic commit with:
- What was fixed
- Test impact
- Pass rate achievement
- Milestone celebration 🎉

## Success Metrics

**Minimum Target:** 1,430 passing (50.0%) - **+10 tests**
- Conservative goal, easily achievable

**Realistic Target:** 1,440-1,450 passing (50.4-50.7%) - **+20-30 tests**
- Expected if both Pattern 1 and Pattern 4 work well

**Stretch Target:** 1,470+ passing (51.4%+) - **+50+ tests**
- If Directives patterns are also implemented

**Pass/Fail Criteria:**
- ✅ PASS: Reach 50% milestone (+10+ tests)
- ⚠️ MIXED: +5-9 tests (close but need more work)
- ❌ FAIL: <5 tests (strategy needs revision)

## Key Principles from Session 16

1. **Always start with failure analysis**
2. **Estimate impact before implementing**
3. **Prioritize by test impact, not complexity**
4. **Implement multiple patterns in one session**
5. **Verify core tests pass after each change**
6. **Single commit with comprehensive documentation**

## Next Developer Actions

1. ✅ Read this plan
2. ✅ Verify DAD implementation status
3. ✅ Implement DAD fix if needed (+6 tests)
4. ✅ Analyze Pattern 4 failures in detail
5. ✅ Implement Base+Supplement stage fix (+10-15 tests)
6. ✅ Run safety check (core tests)
7. ✅ Run full suite
8. ✅ Celebrate 50% milestone! 🎉
9. ✅ Create commit
10. ✅ Update memory bank

## Post-50% Strategy

Once 50% is achieved, Session 18+ will focus on:

1. **Directives implementation** (+36 tests) - New identifier classes
2. **Stage code preservation** (+100 tests) - Builder/identifier fixes
3. **Remaining parse failures** (~500 tests) - Various patterns
4. **Path to 60%**: Goal for Sessions 18-20

## Celebration Plan

Reaching 50% is a significant milestone:
- Validates V2 architecture approach
- Demonstrates data-driven strategy effectiveness
- Shows sustainable path to 100%
- Proves three-layer design works at scale

**Let's get to 50%!** 🚀
