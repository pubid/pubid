# Session 232 Quick Start: CSA Parse Failure Recovery

**Read Full Plan:** [`docs/SESSION-232-CONTINUATION-PLAN.md`](SESSION-232-CONTINUATION-PLAN.md:1)

---

## Situation

Session 231 fixed greedy parser patterns and updated NO. normalization tests, but didn't fully recover baseline:
- **Current:** 212/362 (58.5%)
- **Baseline:** 271/366 (73.8%)
- **Gap:** +59 tests needed

---

## Objective

Identify and fix parse failures to recover baseline performance.

**Target:** 242-262/362 (67-72%) after Session 232

---

## Part A: Analyze Parse Failures (20 min)

Get detailed breakdown of what's failing to parse:

```bash
cd /Users/mulgogi/src/mn/pubid
bundle exec rspec spec/pubid_new/csa/ --format documentation 2>&1 | \
  grep -B 5 "Parslet::ParseFailed" | \
  grep "describe\|context" | \
  sort | uniq -c | sort -rn
```

**Goal:** Identify top 3 parse failure patterns

---

## Part B: Fix Top 3 Patterns (50 min)

Based on analysis, likely issues:

### Issue 1: Parser Rule Ordering
- **Symptom:** Specific patterns not matching
- **Fix:** Reorder rules (longest match first)
- **File:** `lib/pubid_new/csa/parser.rb`

### Issue 2: Optional Elements
- **Symptom:** Required elements failing when optional
- **Fix:** Add `.maybe` to appropriate rules
- **File:** `lib/pubid_new/csa/parser.rb`

### Issue 3: Missing Pattern Coverage
- **Symptom:** Valid identifiers rejected
- **Fix:** Add missing pattern alternatives
- **File:** `lib/pubid_new/csa/parser.rb`

**Strategy:**
1. Fix ONE pattern at a time
2. Test after each fix
3. Commit if progress made
4. Move to next pattern

---

## Part C: Validation (20 min)

After each fix:
```bash
bundle exec rspec spec/pubid_new/csa/ --format progress 2>&1 | grep "examples"
```

**Track progress:**
- Baseline: 212/362 (58.5%)
- After Fix 1: ___/362 (___%)
- After Fix 2: ___/362 (___%)
- After Fix 3: ___/362 (___%)

---

## Success Criteria

- ✅ Top 3 parse failure patterns identified
- ✅ Fixes applied systematically
- ✅ 242-262/362 tests passing (67-72%)
- ✅ Zero architectural compromises
- ✅ Ready for Session 233

---

## Key Files

**Parser:** [`lib/pubid_new/csa/parser.rb`](lib/pubid_new/csa/parser.rb:1)
**Builder:** [`lib/pubid_new/csa/builder.rb`](lib/pubid_new/csa/builder.rb:1)

---

## Next Steps After Session 232

Session 233 will focus on:
- CAN3- classification issues
- French year rendering (double F bug)
- Additional classification fixes

---

**Created:** 2025-12-30
**Session:** 232
**Duration:** 90 minutes
**Expected Gain:** +30-50 tests

**Ready to recover! 🚀**