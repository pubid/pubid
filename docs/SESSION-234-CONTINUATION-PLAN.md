# Session 234 Continuation Plan: CSA Baseline Recovery

**Created:** 2025-12-30 (Post-Session 233)
**Status:** 257/362 tests (71.0%)
**Target:** 267/362 tests (73.8%) - Baseline
**Gap:** +10 tests needed

---

## Session 233 Summary

**Achievement:** Fixed French F double rendering in Combined and Bundled identifiers (+1 test)

**Files Modified:**
1. `lib/pubid_new/csa/identifiers/base.rb` - CAN/CSA- rendering (line 67)
2. `lib/pubid_new/csa/identifiers/combined.rb` - French F fix (line 76)
3. `lib/pubid_new/csa/identifiers/bundled.rb` - French F fix (line 28)

**Key Learning:** Session 232's fix for double-F rendering in base.rb needed propagation to Combined and Bundled classes.

---

## Remaining Failure Analysis Needed

To reach +10 tests, we need systematic analysis of the 105 remaining failures.

### Recommended Approach

**Step 1: Get Failure Breakdown** (5 min)
```bash
bundle exec rspec spec/pubid_new/csa/ --format documentation 2>&1 | \
  grep "FAILED" | \
  sed 's/.*(\(FAILED - [0-9]*\)).*/\1/' | \
  sort | uniq -c | sort -rn
```

**Step 2: Examine Top Failure Patterns** (10 min)
```bash
bundle exec rspec spec/pubid_new/csa/ --format documentation 2>&1 | \
  grep -B 2 "FAILED" | \
  grep "Failure/Error:" | \
  sort | uniq -c | sort -rn | head -10
```

**Step 3: Identify High-Impact Issues** (10 min)
Look for patterns that affect multiple tests:
- Rendering issues (similar to French F fix)
- Parser normalization issues
- Type classification issues
- Year format issues

---

## Likely High-Impact Patterns

Based on Session 230-232 history:

### Pattern 1: Series Rendering in Specific Classes
**Hypothesis:** Series class may have rendering issues
**Check:**
```bash
bundle exec rspec spec/pubid_new/csa/identifiers/series_spec.rb --format progress
```

### Pattern 2: NO. Normalization Rendering
**Hypothesis:** NO. patterns may have rendering inconsistencies
**Files to check:**
- Parser NO. normalization (line 268-273)
- Base identifier rendering

### Pattern 3: CAN/CSA Wrapper Edge Cases
**Hypothesis:** CanadianAdopted may have rendering issues in wrapped standards
**Check:** Inspect CanadianAdopted class for render_continuation pattern

### Pattern 4: Package Identifiers
**Hypothesis:** Package class may need similar fixes
**Files to check:**
- `lib/pubid_new/csa/identifiers/package.rb`

---

## Implementation Strategy

### Session 234 (60-90 min)

**Phase 1: Analysis** (25 min)
1. Run failure breakdown commands
2. Identify top 3 patterns by test count impact
3. Document findings

**Phase 2: Implement Top Fix** (20 min)
1. Fix highest-impact pattern
2. Test improvement
3. Commit if gain >=3 tests

**Phase 3: Implement Second Fix** (20 min)
1. Fix second pattern
2. Test improvement
3. Commit if gain >=2 tests

**Phase 4: Validate** (15 min)
1. Run full spec suite
2. Document final count
3. Update memory bank

---

## Success Criteria

### Minimum Success
- ✅ +5 tests (262/362 = 72.4%)
- ✅ Clear pattern identified for remaining gap
- ✅ Zero architectural compromises

### Target Success
- ✅ +10 tests (267/362 = 73.8%) - **BASELINE REACHED**
- ✅ Clean architecture maintained
- ✅ All fixes documented

### Stretch Success
- ✅ +15 tests (272/362 = 75.1%)
- ✅ Multiple systematic fixes
- ✅ Ready for 80%+ push

---

## Files to Investigate

Based on rendering pattern from Session 233:

1. `lib/pubid_new/csa/identifiers/series.rb` - Check for year rendering
2. `lib/pubid_new/csa/identifiers/package.rb` - Check for duplicate code
3. `lib/pubid_new/csa/identifiers/canadian_adopted.rb` - Check render logic
4. `lib/pubid_new/csa/identifiers/csa_adopted.rb` - Check for similar patterns

---

## Architecture Principles

**MAINTAIN throughout:**
1. **MODEL-DRIVEN** - Objects not strings
2. **MECE** - Mutually exclusive, collectively exhaustive
3. **DRY** - Don't repeat rendering logic
4. **render_continuation** pattern should be consistent
5. **year_prefix** handling must be uniform

**Pattern to apply:** If Session 232's fix needed propagation to 2 classes, check ALL identifier classes for similar rendering code.

---

## Risk Mitigation

**If stuck at <267 tests:**
- Document gap explicitly
- Mark remaining failures as parser work needed
- Move to next priority (Session 235: Documentation)

**If regression occurs:**
- Immediately revert
- Analyze why
- Approach differently

---

## Next Session Preview

**Session 235:** Documentation & Memory Bank Update
- Update context.md with Session 233-234 results
- Move old session docs to archive
- Mark CSA progress in project status

---

**Created:** 2025-12-30
**Sessions Covered:** 234
**Status:** Ready for execution
**Estimated Time:** 60-90 minutes

**End Goal:** Reach 73.8% baseline with systematic rendering fixes! 🎯