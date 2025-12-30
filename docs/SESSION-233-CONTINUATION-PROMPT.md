# Session 233 Quick Start: CSA Baseline Recovery

**Read Full Plan:** [`docs/SESSION-233-CONTINUATION-PLAN.md`](SESSION-233-CONTINUATION-PLAN.md:1)

---

## Situation

Session 232 successfully fixed major parse failures (+44 tests), but still short of baseline:
- **Current:** 256/362 (70.7%)
- **Baseline:** ~267/362 (73.8%)
- **Gap:** +11 tests needed

---

## Objective

Reach baseline 73.8%+ with targeted high-impact fixes.

**Target:** 267-270/362 (73.8-74.6%) after Session 233

---

## Part A: CAN/CSA- Rendering Fix (20 min)

**Issue:** `CAN/CSA-B127.1:99` renders as `CAN/CSA B127.1:99` (missing dash)

**Fix:** Update [`lib/pubid_new/csa/identifiers/base.rb`](lib/pubid_new/csa/identifiers/base.rb:19)

Modify line 19 to preserve dash when publisher_prefix ends with dash:
- Current: `needs_space = !prefix.end_with?("-")`
- Problem: Doesn't add dash in output, just skips space
- Solution: When prefix ends with "-", join without space (preserves dash)

**Expected:** +8-10 tests

---

## Part B: French F on Combined Items (15 min)

**Issue:** `CSA B149.1:F20/B149.2:F20` renders as `CSA B149.1:F20/B149.2:FF20`

**Fix:** Update [`lib/pubid_new/csa/builder.rb`](lib/pubid_new/csa/builder.rb:244)

Problem: Line 244-246 sets `french=true` when `year_prefix="F"`, but this causes Base.rb to add another F
- Current logic: `if year_prefix == "F" then french = true`
- Base.rb then adds F if french=true AND no year_prefix
- But for combined, second item may inherit french flag incorrectly

Solution: Don't set french=true when year_prefix already set, OR fix Base.rb rendering logic

**Expected:** +3-5 tests

---

## Part C: Series Classification (15 min)

**Issue:** Standards with SERIES keyword return Standard instead of Series class

**Fix:** Update [`lib/pubid_new/csa/builder.rb`](lib/pubid_new/csa/builder.rb:276)

Current select_identifier_class only checks `:series_type` (primary SERIES keyword)
Need to also check `:series` flag (modifier on standards)

**Expected:** +5-8 tests

---

## Quick Test Command

```bash
cd /Users/mulgogi/src/mn/pubid
bundle exec rspec spec/pubid_new/csa/ --format progress 2>&1 | grep "examples,"
```

---

## Success Criteria

- ✅ 267+/362 tests passing (73.8%+)
- ✅ Baseline recovered
- ✅ Zero architectural compromises

---

**Created:** 2025-12-30
**Session:** 233
**Duration:** 60-90 minutes

**Ready to recover baseline! 🎯**