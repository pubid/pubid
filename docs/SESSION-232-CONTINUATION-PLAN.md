# Session 232+ Continuation Plan: CSA Complete Recovery

**Created:** 2025-12-30 (Post-Session 231 Recovery)
**Status:** Parser fixed, NO. normalized, need full baseline recovery
**Current:** 212/362 (58.5%)
**Target:** 271/366 (73.8%) baseline recovery
**Gap:** +59 tests needed

---

## Session 231 Recovery Summary

**Achieved:**
- ✅ Fixed greedy parser patterns (dash_year, code_pattern)
- ✅ Updated all NO. test expectations to normalized form
- ✅ Architecture quality maintained

**Current Status:**
- 212/362 passing (58.5%)
- 150 failures remaining
- NO. normalization working correctly

**Root Causes Identified:**
1. Parse failures - many identifiers not parsing
2. CAN3- prefix not being classified as CanadianAdopted
3. French year rendering bug (double F: "FF20" instead of "F20")
4. Systematic builder/rendering issues

---

## SESSION 232: Investigate & Fix Parse Failures (90 min)

### Objective
Identify and fix parse failures to recover significant test count.

### Part A: Analyze Parse Failures (20 min)

**Action:** Get detailed parse failure output
```bash
bundle exec rspec spec/pubid_new/csa/ --format documentation 2>&1 | \
  grep -B 5 "Parslet::ParseFailed" | \
  grep "describe\|context" | \
  sort | uniq -c | sort -rn
```

**Expected patterns:**
- Specific identifier formats not covered by parser
- Parser rule ordering issues
- Optional element handling

### Part B: Fix Top 3 Parse Failure Patterns (50 min)

Focus on highest-impact patterns first.

**Likely fixes needed:**
1. Parser rule ordering (longest match first)
2. Optional element handling (`.maybe` placement)
3. Missing pattern coverage

**File:** `lib/pubid_new/csa/parser.rb`

### Part C: Test & Document (20 min)

```bash
bundle exec rspec spec/pubid_new/csa/ --format progress
```

**Expected improvement:** +30-50 tests

---

## SESSION 233: Fix Classification Issues (60 min)

### Objective
Fix CAN3- and other classification problems.

### Part A: CAN3- Prefix Classification (30 min)

**Issue:** CAN3- identifiers being classified as Standard instead of CanadianAdopted

**Investigation:**
1. Check if `publisher_prefix` is being set correctly in parser
2. Verify builder `select_identifier_class` logic
3. Test CAN3- pattern flow

**File:** `lib/pubid_new/csa/builder.rb` (lines 272-297)

**Likely fix:** Builder logic is correct, issue is parser not setting `publisher_prefix`

### Part B: French Year Rendering (20 min)

**Issue:** "CSA B149.1:FF20" instead of "CSA B149.1:F20"

**Root cause:** Year prefix being rendered twice

**Files to check:**
- `lib/pubid_new/csa/identifiers/base.rb` or `single_identifier.rb`
- Rendering logic duplicating year_prefix

### Part C: Validation (10 min)

```bash
bundle exec rspec spec/pubid_new/csa/ --format progress
```

**Expected improvement:** +10-20 tests

---

## SESSION 234: Remaining Failures & Baseline Recovery (60 min)

### Objective
Address remaining failures and reach 73.8%+ baseline.

### Part A: Analyze Remaining Failures (15 min)

Get breakdown of remaining issues.

### Part B: Targeted Fixes (35 min)

Fix top 2-3 remaining patterns.

### Part C: Final Validation (10 min)

```bash
bundle exec rspec spec/pubid_new/csa/ --format progress
```

**Target:** 267+/362 (73.8%+)

---

## Success Criteria

### Minimum (70%)
- ✅ 253+/362 tests passing
- ✅ NO. normalization working
- ✅ Parser greedy patterns fixed

### Target (73.8%)
- ✅ 267+/362 tests passing (baseline recovered)
- ✅ All classification issues fixed
- ✅ French rendering working

### Stretch (80%)
- ✅ 290+/362 tests passing
- ✅ All systematic issues resolved
- ✅ Ready for Session 230 Priority patterns

---

## Key Architectural Principles

**MAINTAIN throughout:**
1. **MODEL-DRIVEN** - Objects not strings
2. **MECE** - Mutually exclusive, collectively exhaustive
3. **Three-layer** - Parser/Builder/Identifier independence
4. **NO. normalization** - Preprocessing, not parser rules
5. **Architecture correctness** - Test regressions acceptable if architecture improves

---

## Files to Modify

### Session 232 (Parse Failures)
- `lib/pubid_new/csa/parser.rb` - Rule fixes

### Session 233 (Classification)
- `lib/pubid_new/csa/builder.rb` - CAN3- routing (if needed)
- `lib/pubid_new/csa/identifiers/single_identifier.rb` - French rendering
- `lib/pubid_new/csa/parser.rb` - Publisher prefix capture (if needed)

### Session 234 (Final Fixes)
- TBD based on remaining failures

---

## Timeline Summary

| Session | Focus | Duration | Expected Result |
|---------|-------|----------|-----------------|
| 232 | Parse failures | 90 min | 242-262/362 (67-72%) |
| 233 | Classification | 60 min | 252-282/362 (70-78%) |
| 234 | Final fixes | 60 min | 267+/362 (73.8%+) ✅ |
| **Total** | **Recovery** | **210 min** | **Baseline recovered** |

---

## Next Immediate Steps (Session 232)

1. Read this continuation plan
2. Analyze parse failures with detailed output
3. Identify top 3 failure patterns
4. Fix parser rules systematically
5. Test after each fix
6. Document results

---

**Created:** 2025-12-30
**Sessions Covered:** 232-234
**Status:** Ready for execution
**Estimated Time:** 3.5 hours (compressed)

**End Goal:** CSA baseline recovered at 73.8%+ with clean architecture! 🎯