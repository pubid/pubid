# Session 18 Continuation Plan - ISO V2 Path to 50%

## Current Status (Session 17 Complete)

**Test Results:**
- 1,420 passing (49.7%)
- 718 failures (25.1%)
- 721 pending (25.2%)
- Total: 2,859 examples
- Core tests: 106/106 passing ✅

**Progress Tracking:**
- Session 15: 1,316 passing (46.0%) - Speculative approach (+4 tests)
- Session 16: 1,420 passing (49.7%) - Data-driven approach (+104 tests) 🎉
- Session 17: 1,420 passing (49.7%) - Analysis session (no changes committed)

## Session 17 Key Learnings

### What Was Discovered

1. **Pattern 1 (DAD typed stage)**: Already fully implemented
   - Present in `Addendum.TYPED_STAGES` (line 17)
   - Present in parser `typed_stage` rule (line 55)
   - Not a real opportunity

2. **Pattern 4 (Base+Supplement stage extraction)**: Parser limitation, not builder issue
   - Examples: "ISO/IEC FDIS 23008-1/WD Amd 1"
   - These have NEVER parsed (parse failure, not attribute failure)
   - Requires parser architecture changes to support typed_stage on base + separate stage on supplement
   - Builder-only fix made things worse (-1 test)

3. **Critical Distinction**: Parse failures vs Attribute failures
   - Parse failures: String doesn't match parser grammar → can't be fixed with builder
   - Attribute failures: Parses successfully but wrong attribute values → fixable with builder/identifier changes

### Validation of Session 16 Strategy

Session 16's data-driven approach with impact estimation:
- Yielded +104 tests (26x better than Session 15's speculative +4)
- Proves systematic failure analysis is the ONLY effective strategy
- Speculative fixes without analysis are counterproductive

## Session 18 Goal - Reach 50% Milestone

**Target:** 1,430 passing (50.0%) - **Only +10 tests needed!**

**Time Budget:** 60-90 minutes max

**Success Criteria:**
- ✅ Reach or exceed 50% pass rate
- ✅ Core tests remain at 106/106
- ✅ Single semantic commit with comprehensive documentation

## Session 18 Strategy

### Core Principle: Focus on Attribute Failures, NOT Parse Failures

From Session 16 analysis, remaining high-impact patterns that are **attribute failures** (not parse failures):

### Pattern B: Stage Code Preservation (~100 tests estimated)

**Issue:** Stage codes defaulting to "published" instead of preserving actual stage

**Evidence from Session 16 analysis:**
```
Expected "cd" got "published"
Expected "pwi" got "published"  
Expected "wd" got "published"
Expected "np" got "published"
```

**Root Cause:** Builder or identifier classes defaulting to "published" when stage is present

**Files to investigate:**
- `lib/pubid_new/iso/builder.rb` - stage handling in build_supplement_identifier
- Various identifier classes - stage_code logic

**Impact:** ~100 tests (high confidence)

### Alternative Quick Wins (if Pattern B is complex)

If stage code preservation proves complex, pivot to:

1. **Check pending tests** - Some may now pass due to Session 16 changes
2. **Rendering fixes** - Simple to_s fixes for known patterns
3. **Type code fixes** - Similar to stage code but simpler

## Implementation Approach

### Step 1: Analyze Pattern B Failures (15 minutes)

```bash
# Find specific examples of stage_code failures
cd /Users/mulgogi/src/mn/pubid
bundle exec rspec spec/pubid_new/iso/ 2>&1 | grep "stage_code" | head -20

# Or search test files for stage_code expectations
grep -r "stage_code" spec/pubid_new/iso/identifiers/*.rb | head -30
```

### Step 2: Identify Root Cause (15 minutes)

1. Read failing test to understand expected vs actual
2. Trace through code:
   - Parser captures stage correctly?
   - Builder extracts stage correctly?
   - Identifier preserves stage correctly?
3. Identify exact line(s) causing issue

### Step 3: Implement Fix (20 minutes)

1. Make targeted fix to identified issue
2. Verify core tests still pass
3. Run small subset of affected tests
4. If promising, run full suite

### Step 4: Validate and Commit (15 minutes)

1. Confirm +10 or more tests achieved
2. Verify 50% milestone reached
3. Create semantic commit with detailed documentation
4. Update memory bank

## Decision Tree

```
START
  │
  ├─→ Pattern B (Stage Code) seems fixable?
  │     │
  │     ├─→ YES → Implement fix → Test
  │     │           │
  │     │           ├─→ +10+ tests → COMMIT & CELEBRATE
  │     │           └─→ <10 tests → Revert, try Alternative
  │     │
  │     └─→ NO → Check Alternative Quick Wins
  │                │
  │                ├─→ Pending tests now pass? → Count them → COMMIT if 10+
  │                ├─→ Simple rendering fix found? → Implement → Test
  │                └─→ No easy wins → Document for Session 19
  │
  └─→ If 50% achieved → CELEBRATE & UPDATE MEMORY BANK
      If not → Document what was learned for next session
```

## Warning Flags 🚩

**STOP and document if:**
1. Fix requires changing parser grammar
2. Fix breaks core tests
3. After 60 minutes, no clear path to +10 tests
4. Fix makes test count go down

**These are signs to:**
- Document findings
- Update memory bank with lessons
- Plan Session 19 with better target

## Expected Outcome

**Minimum Success:** Document why 50% wasn't reached, clear plan for Session 19
**Target Success:** Reach 50% (+10 tests)
**Stretch Success:** Exceed 50% significantly (+20-30 tests)

## Files to Update

After successful session:
1. `.kilocode/rules/memory-bank/context.md` - Update session info
2. This continuation plan - Mark as complete
3. Git commit message - Follow semantic format

## Post-Session Checklist

- [ ] Test count improved or stayed same (no regression)
- [ ] Core tests at 106/106
- [ ] Architecture principles maintained
- [ ] Semantic commit created (if changes made)
- [ ] Memory bank updated
- [ ] Session 19 plan created (if 50% not reached)

## Key Quotes to Remember

> "Data-driven analysis yields 26x better results than speculative fixes"

> "Parser failures cannot be fixed with builder changes"

> "Only commit changes that improve test count"

> "50% is within easy reach with the right target"

---

**Ready to Start Session 18!** 🚀

Focus: Pattern B (Stage Code Preservation) - ~100 tests available
Goal: +10 tests minimum to reach 50%
Time: 60-90 minutes
Strategy: Data-driven, targeted, measured
