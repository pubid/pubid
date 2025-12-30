# Session 234 Quick Start: Reach CSA Baseline

**Read Full Plan:** [`docs/SESSION-234-CONTINUATION-PLAN.md`](SESSION-234-CONTINUATION-PLAN.md:1)

---

## Situation

Session 233 fixed French F double rendering in Combined/Bundled (+1 test):
- **Current:** 257/362 (71.0%)
- **Baseline:** 267/362 (73.8%)
- **Gap:** +10 tests

---

## Objective

Reach baseline 73.8%+ through systematic rendering fixes.

**Strategy:** Apply Session 232's fix pattern to ALL identifier classes

---

## Quick Diagnostic

Check for duplicate year rendering code across all identifier classes:

```bash
grep -n "year_part += \"F\"" lib/pubid_new/csa/identifiers/*.rb
```

**Expected:** Should find patterns similar to what we fixed in Session 233

---

## Likely Fixes

### Fix 1: Series Identifier (if exists)
Check [`lib/pubid_new/csa/identifiers/series.rb`](lib/pubid_new/csa/identifiers/series.rb:67) line 67
- Look for: `year_part += "F" if french`
- Change to: `year_part += "F" if french && year_format != "dash" && !year_prefix`

### Fix 2: Package Identifier (if exists)
Check if Package has similar rendering code

### Fix 3: CsaAdopted Identifier (if exists)
Check wrapper classes for render logic

---

## Test Command

```bash
bundle exec rspec spec/pubid_new/csa/ --format progress 2>&1 | grep "examples,"
```

---

## Success Criteria

- ✅ 267+/362 tests (73.8%+) - Baseline reached
- ✅ Zero architectural compromises

---

**Created:** 2025-12-30
**Session:** 234
**Duration:** 60-90 minutes

**Let's reach baseline! 🎯**