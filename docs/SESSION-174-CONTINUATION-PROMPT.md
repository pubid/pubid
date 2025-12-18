# Session 174 Continuation Prompt: Edition/IRE/Slash Patterns

**Session:** 174
**Previous:** Session 173 complete - IEEE at 90.15%
**Focus:** Implement Edition abbreviation, IRE parenthetical, slash patterns
**Timeline:** 90 minutes

---

## Quick Start

**Read these files first:**
1. [`docs/SESSION-174-CONTINUATION-PLAN.md`](SESSION-174-CONTINUATION-PLAN.md:1) - Complete implementation plan
2. [`TODO.IEEE-MUST-DO.txt`](../TODO.IEEE-MUST-DO.txt:1) - Target patterns (17 remaining)
3. [`.kilocode/rules/memory-bank/context.md`](../.kilocode/rules/memory-bank/context.md:1) - Current status

**Current metrics:**
- IEEE: 8,611/9,552 (90.15%)
- TODO patterns: 29/46 complete (63%)
- Remaining: 17 patterns

---

## Session 174 Objectives

### Part A: Edition Abbreviation (30 min)

**File:** [`lib/pubid_new/ieee/parser.rb`](../lib/pubid_new/ieee/parser.rb:790) (add after line 790)

**Add preprocessing:**

```ruby
# Edition abbreviation: ", YYYY Edn. (Reaff YYYY)" → "-YYYY (RYYYY)"
cleaned = cleaned.gsub(/,\s+(\d{4})\s+Edn\.\s+\(Reaff\s+(\d{4})\)/, '-\1 (R\2)')
cleaned = cleaned.gsub(/(\d{4})\s+Edn\.\s+\(Reaff\s+(\d{4})\)/, '\1 (R\2)')
```

**Expected:** +2 identifiers (lines 10-11)

### Part B: IRE Parenthetical Split (30 min)

**Add preprocessing:**

```ruby
# Split "Reaffirmed YYYY, XX IRE" → "(RYYYY) (XX IRE"
cleaned = cleaned.gsub(/\(Reaffirmed\s+(\d{4}),\s+(\d+\s+IRE[^)]+)\)/, '(R\1) (\2)')
```

**Expected:** +1 identifier (line 9)

### Part C: Slash to Parenthetical (20 min)

**Add preprocessing:**

```ruby
# Convert "year/ANSI identifier" → "year (ANSI identifier)"
cleaned = cleaned.gsub(%r{(\d{4})/ANSI\s+([^(]+)(?=\s*\(|$)}, '\1 (ANSI \2)')
```

**Expected:** +1 identifier (line 37)

### Part D: ISO/IEC TR Spacing (10 min)

**Add preprocessing:**

```ruby
# Add space after TR: "ISO/IEC TR11802" → "ISO/IEC TR 11802"
cleaned = cleaned.gsub(/(ISO\/IEC\s+TR)(\d)/, '\1 \2')
```

**Expected:** +1 identifier (line 40)

---

## Testing

After all implementations:

```bash
cd spec/fixtures && ruby run_classify.rb ieee
```

**Expected result:**
- IEEE: 8,616-8,620/9,552 (90.20-90.26%)
- +5-9 identifiers from preprocessing

---

## Success Criteria

### Minimum (80%)
- ✅ 3+ patterns working
- ✅ IEEE at 90.18%+ (8,614+/9,552)
- ✅ No regressions

### Target (90%)
- ✅ All 4 parts complete
- ✅ IEEE at 90.20%+ (8,617+/9,552)
- ✅ Ready for Session 175

---

## Troubleshooting

**If gain is lower than expected:**
- Some patterns may already be handled
- Others may need parser changes (Session 175)
- Check TODO individually

**If regressions occur:**
- Check pattern specificity
- Verify order of substitutions
- May need more conservative patterns

---

**Created:** 2025-12-18
**Status:** Ready for execution
**Current:** 8,611/9,552 (90.15%)
**Target:** 8,616-8,620/9,552 (90.20-90.26%)

**Start:** Read continuation plan, implement 4 parts, test, commit!