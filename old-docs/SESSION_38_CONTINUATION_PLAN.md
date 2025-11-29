# Session 38+ Continuation Plan: Path to 85% Milestone

**Created:** 2025-11-27
**Status:** Session 37 Complete - Clean Baseline Restored
**Priority:** HIGH - Reach 85% milestone with careful, incremental improvements

---

## Current State (Session 37 Complete)

### Test Results
- **Total:** 2,859 examples
- **Passing:** 2,357 (82.5%)
- **Failing:** 23 (0.8%)
- **Pending:** 480 (16.8%)

### Key Achievement
✅ **Fixed massive regression:** 786 → 23 failures
✅ **Builder enhancement:** Default typed_stage prevents nil errors
✅ **Clean baseline:** Ready for careful improvements

### Critical Lesson Learned
**Parser is EXTREMELY delicate** - Any rule modification can cause 500+ cascading failures. Must test after EVERY atomic change.

---

## Architecture Status

### ✅ What Works (DO NOT TOUCH)
1. **Builder Architecture** - Clean, with default typed_stage support
2. **Rendering System** - 100% complete (zero rendering failures)
3. **Component System** - All components working correctly
4. **Scheme Registry** - TYPED_STAGES register working perfectly

### ⚠️ What Needs Careful Work
1. **Parser Rules** - Extremely sensitive, needs surgical precision
2. **Addendum Support** - 19 failures in addendum_spec
3. **Edge Cases** - 4 failures in other specs

---

## Failure Analysis (23 Total)

### Category 1: Addendum Spec (19 failures)

**Type A: Legacy Hyphen Format (3 failures)**
- Pattern: "ISO 4037-1979/Add. 1-1983(F)"
- Issue: Parser treats "-1979" and "-1983" as parts, not years
- Solution: **Builder normalization** (NOT parser!)
- Expected gain: +3 tests
- Risk: LOW (Builder-only change)

**Type B: DAD Parsing (16 failures)**
- Patterns: "ISO 2631/DAD 1", "ISO 2553/DAD 1:1987"
- Issue: Legacy part rule matches "/DAD" before supplement rule can
- Solution: **Needs careful parser analysis** OR non-parser workaround
- Expected gain: +16 tests
- Risk: HIGH (parser modification required)

### Category 2: Other Specs (4 failures)
- Need detailed analysis
- Expected gain: +4 tests
- Risk: MEDIUM

---

## Strategy: Incremental, Risk-Managed Approach

### Phase 1: Low-Risk Wins (Session 38)
**Goal:** +3-7 tests with zero regressions
**Approach:** Builder-only changes

**Task 1.1: Fix Legacy Hyphen Format (Builder)**
- Modify `Builder.cast(:number_with_part)`
- Detect year patterns (4-digit numbers)
- Move from `part` to `date` field
- **Risk:** LOW - No parser changes
- **Test immediately:** After implementation

**Task 1.2: Analyze Remaining 4 Failures**
- Identify patterns
- Categorize by type
- Estimate fix complexity
- **Risk:** NONE - Analysis only

**Expected Outcome:** 82.5% → 82.7% (2,360+/2,859)

### Phase 2: Medium-Risk Improvements (Session 39)
**Goal:** +4-10 tests with controlled risk
**Approach:** Targeted fixes for non-parser issues

**Task 2.1: Fix Category 2 Failures**
- Based on Phase 1 analysis
- Prioritize Builder/Identifier fixes over parser
- **Risk:** LOW-MEDIUM
- **Test after each fix**

**Expected Outcome:** 82.7% → 83.1% (2,374+/2,859)

### Phase 3: High-Risk Parser Work (Session 40-42)
**Goal:** Fix DAD parsing with extreme caution
**Approach:** ONE atomic change per session with full testing

**Critical Rules for Parser Changes:**
1. ✅ Make ONE change only
2. ✅ Test immediately after change
3. ✅ If >50 failures, revert immediately
4. ✅ Commit working state before next change
5. ✅ Document exact change and reasoning

**Option A: Parser Rule Ordering** (Session 40)
- Try moving `supplement_identifier` before `identifier_copublishers`
- Rationale: Supplements should have priority
- **Risk:** HIGH
- **Revert plan:** `git checkout HEAD -- lib/pubid_new/iso/parser.rb`

**Option B: Legacy Part Precision** (Session 41)
- Add character limit (1-3 chars) to legacy part rule
- Add explicit delimiter check
- **Risk:** HIGH
- **Revert plan:** Same as above

**Option C: Builder Workaround** (Session 42)
- Don't modify parser at all
- Add post-parse correction in Builder
- Detect "/DAD" misparse and restructure
- **Risk:** LOW-MEDIUM
- **Preferred if Options A/B fail**

**Expected Outcome:** 83.1% → 86.7% (2,478+/2,859)

### Phase 4: Final Push to 90% (Session 43-45)
**Goal:** Address remaining edge cases
**Approach:** Surgical fixes based on learned patterns

---

## Success Metrics

### Session 38 (Immediate)
- ✅ +3 tests minimum (legacy hyphen fix)
- ✅ Zero regressions
- ✅ Complete failure analysis
- **Target:** 82.7%+ (2,360+/2,859)

### Session 39-42 (Short-term)
- ✅ +50 tests cumulative
- ✅ DAD parsing working
- ✅ All addendum tests passing
- **Target:** 85%+ (2,430+/2,859)

### Session 43-45 (Medium-term)
- ✅ +100 tests cumulative
- ✅ All identifier specs at 90%+
- **Target:** 90%+ (2,574+/2,859)

---

## Implementation Checklist

### Session 38 Tasks
- [ ] Create detailed failure breakdown (run each failing spec individually)
- [ ] Implement legacy hyphen fix in Builder
- [ ] Test and commit Builder fix
- [ ] Analyze remaining 4 non-addendum failures
- [ ] Document findings for Session 39

### Session 39 Tasks
- [ ] Fix Category 2 failures based on analysis
- [ ] Test after each fix
- [ ] Commit incremental improvements
- [ ] Prepare for DAD parser work

### Session 40+ Tasks
- [ ] Attempt DAD parser fix (Option A)
- [ ] If fails, revert and try Option B
- [ ] If fails, implement Option C (Builder workaround)
- [ ] Continue edge case fixes

---

## Risk Management

### Red Flags (Stop and Revert)
- ❌ >50 failures after parser change
- ❌ >100 failures after any change
- ❌ Rendering regressions
- ❌ Builder default typed_stage breaks

### Yellow Flags (Proceed with Caution)
- ⚠️ 25-50 failures after parser change
- ⚠️ 50-100 failures after any change
- ⚠️ New failure patterns emerge

### Green Lights (Continue)
- ✅ <25 failures after change
- ✅ Net positive test improvement
- ✅ No new failure categories

---

## Architecture Principles (CRITICAL)

1. **Builder > Parser** for normalization and defaults
2. **One change at a time** with immediate testing
3. **Revert immediately** if regressions exceed threshold
4. **Architecture correctness** > test pass rate
5. **MECE organization** in all changes
6. **Separation of concerns** always maintained

---

## Files to Monitor

### Critical (Do Not Break)
- `lib/pubid_new/iso/builder.rb` - Default typed_stage logic
- `lib/pubid_new/iso/scheme.rb` - TYPED_STAGES registry
- `lib/pubid_new/iso/single_identifier.rb` - Rendering

### High-Risk (Modify with Extreme Caution)
- `lib/pubid_new/iso/parser.rb` - Parser rules
- `lib/pubid_new/iso/identifiers/*.rb` - Identifier classes

### Safe to Modify
- Test fixtures in `spec/`
- Documentation in `docs/`

---

## Testing Protocol

### For Builder Changes
```bash
# Run full suite
bundle exec rspec spec/pubid_new/iso/

# Run specific spec
bundle exec rspec spec/pubid_new/iso/identifiers/addendum_spec.rb

# Check failure count
bundle exec rspec spec/pubid_new/iso/ --format progress 2>&1 | grep "examples,"
```

### For Parser Changes (HIGH RISK)
```bash
# BEFORE change: Record baseline
bundle exec rspec spec/pubid_new/iso/ > before.txt 2>&1

# Make ONE atomic change

# IMMEDIATELY test
bundle exec rspec spec/pubid_new/iso/ > after.txt 2>&1

# Compare
grep "examples," before.txt after.txt

# If failures increased >50: REVERT IMMEDIATELY
git checkout HEAD -- lib/pubid_new/iso/parser.rb
```

---

## Session Continuation Template

```markdown
## Session X Summary

**Goal:** [Specific goal]
**Approach:** [Builder/Parser/Analysis]
**Risk Level:** [LOW/MEDIUM/HIGH]

### Changes Made
1. [File and description]
2. [File and description]

### Test Results
- Before: X,XXX passing, XX failures
- After: X,XXX passing, XX failures
- Net: +XX tests

### Commits
- `hash` - description

### Issues Encountered
- [Any problems]

### Next Session Plan
- [Immediate next steps]
```

---

## Success Criteria

**Session 37 → Session 45 Goal:**
- 82.5% → 90%+ pass rate
- All addendum tests passing
- Parser stable and maintainable
- Zero rendering regressions
- Clean, documented codebase

**Timeline:**
- Session 38: +3-7 tests (1 hour)
- Session 39: +4-10 tests (1-2 hours)
- Sessions 40-42: +50 tests (3-5 hours)
- Sessions 43-45: +50 tests (3-5 hours)
- **Total:** 8-13 hours to 90%

---

**Status:** Ready for Session 38
**Next Action:** Implement legacy hyphen fix in Builder
**Expected Outcome:** 82.5% → 82.7%+ with zero regressions