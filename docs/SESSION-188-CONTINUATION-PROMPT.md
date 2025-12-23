# Session 188 Continuation Prompt: NIST V2 Complex Patterns

**Context:** Session 187 completed with 36/91 patterns (39.6%). Need to implement 24 more patterns to reach 60/91 (65.9%).

**Critical:** User requires ALL patterns from TODO.NIST-MUST-FIX.md to work.

---

## What Was Completed (Session 187)

✅ **36/91 patterns passing (39.6%)** - +12 from Session 186

**Files Modified:**
- lib/pubid_new/nist/parser.rb (3 enhancements)
- docs/SESSION-187-RESULTS.md (documentation)
- docs/SESSION-187-CONTINUATION-PLAN.md (updated tracker)

**Enhancements:**
1. Version without dots: `cleaned.gsub(/(\d)ver(\d)/, '\1 ver \2')`
2. Dash version variant: `(dash | space).maybe >> str("v")`
3. Version rule space handling: `space.maybe >> str("ver") >> space.maybe`

**Commit:** Ready for commit (see SESSION-187-RESULTS.md)

---

## What Needs to Be Done (Session 188)

**READ FIRST:**
- [docs/SESSION-187-CONTINUATION-PLAN.md](SESSION-187-CONTINUATION-PLAN.md:1) - Updated 3-session plan
- [docs/SESSION-187-RESULTS.md](SESSION-187-RESULTS.md:1) - Session 187 completion details
- [TODO.NIST-MUST-FIX.md](../TODO.NIST-MUST-FIX.md:1) - 91 patterns to implement

**Current Status:** 36/91 passing (39.6%)
**Target:** 60/91 passing (65.9%)
**Timeline:** 2 hours compressed

---

## Session 188 Immediate Tasks (120 min)

### Part A: Verify Roman Numerals (Already Work?) - 15 min

**Patterns:** `NIST SP 1011-I-2.0`, `NIST SP 1011-II-1.0`

**Investigation:**
```bash
bundle exec ruby test_single.rb "NIST SP 1011-I-2.0"
```

Check preprocessing line 21:
```ruby
cleaned = cleaned.gsub(/([-\d]+[IVX]+[-\d]+)\s+(\d+)/, '\1.\2')
```

This converts: "1011-I-2 0" → "1011-I-2.0"

**Expected:** These should work already! Test to confirm.
**If working:** +2 patterns (skip to Part B)
**If not:** Debug and fix (15 min max)

### Part B: Volume Range Patterns (v2a-l, v2m-z) - 25 min

**Patterns:** `NBS SP 535v2a-l`, `NBS SP 535v2m-z`

**Issue:** Volume rule doesn't handle letter ranges

**File:** `lib/pubid_new/nist/parser.rb` line 289

**Enhancement needed:**
```ruby
rule(:volume) do
  (space.maybe >> (str("v") | str(" Vol. "))) >>
  (digits >>
   (str("a-l") | str("m-z")).maybe >>  # Add letter ranges
   upper_letter.repeat(0, 2)
  ).as(:volume)
end
```

**Expected gain:** +2 patterns

### Part C: AMS and VTS Series - 20 min

**Patterns:** `NIST AMS 300-8r1/upd`, `NIST.AMS.300-8r1/upd`, `NIST.VTS.100-2sup1`

**Issue:** AMS and VTS not in simple_series

**File:** `lib/pubid_new/nist/parser.rb` line 149

**Add to simple_series:**
```ruby
rule(:simple_series) do
  (
    str("AMS") | str("VTS") |  # NEW - Add these first
    str("BSS") | str("BMS") | str("BH") |
    str("FIPS") | str("GCR") | str("HB") | str("MONO") |
    # ... existing series
  ).as(:series)
end
```

**Expected gain:** +2 patterns (VTS pattern has supplement issue)

### Part D: Verify Complex Parts (p1adde1) - 15 min

**Pattern:** `NBS TN 467p1adde1`, `NBS.TN.467p1adde1`

**Investigation:** Already enhanced in Session 185 (line 294):
```ruby
rule(:part) do
  (str("pt") | str("p") | str("P") | str(" Part ")) >>
    (digits >>
     (str("add") >> (str("e") >> digits).maybe).maybe >>
     (dash >> digits).maybe).as(:part)
end
```

**Test to confirm this works:**
```bash
bundle exec ruby test_single.rb "NBS TN 467p1adde1"
```

**Expected:** Should work! +2 patterns if confirmed

### Part E: LCIRC Revision/Year Patterns (r6/1925) - 30 min

**Patterns:**
- `NBS LCIRC 145r6/1925`
- `NBS LCIRC 145r11/1925`
- `NBS LCIRC 59r5/1924`
- `NBS LCIRC 59r11/1924`
- `NBS LCIRC 118supp3/1926`
- `NBS LCIRC 118supp12/1926`

**Issue:** Revision rule doesn't handle slash+year format

**File:** `lib/pubid_new/nist/parser.rb` line 302

**Enhancement needed:**
```ruby
rule(:revision) do
  (
    # Revision with slash and year: r6/1925, r11/1924
    ((str("r") | str("rev")) >> digits.as(:revision) >>
     slash >> digits.as(:revision_year)) |
    # Revision with year: rev2013
    (str("rev") >> digits.as(:revision_year)) |
    # Revision with optional digits AND optional letter: r1a, ra, r1
    ((str(" rev ") | str("rev") | str("r") | str(" Rev. ") | str(" Revision (r)")) >>
      (digits.maybe >> lower_letter.maybe).as(:revision))
  )
end
```

**Expected gain:** +6 patterns

### Part F: RPT Special Patterns - 15 min

**Start with high-value patterns:**
- `NBS RPT ADHOC` - Special text number
- `NBS RPT div9` - Division number

**Add to first_number rule (line 189):**
```ruby
rule(:first_number) do
  (
    # Special text patterns (MOST SPECIFIC FIRST)
    str("ADHOC") | (str("div") >> digits) |
    # Roman numeral patterns...
    (digits >> dash >> (str("III") | str("II")...
```

**Expected gain:** +2 patterns (test others in Session 189)

---

## Testing Strategy

**After each part:**
```bash
bundle exec ruby test_nist_todo.rb 2>&1 | grep "Passing:"
```

**Target progression:**
- After Part A: 38/91 (41.8%)
- After Part B: 40/91 (44.0%)
- After Part C: 42/91 (46.2%)
- After Part D: 44/91 (48.4%)
- After Part E: 50/91 (54.9%)
- After Part F: 52/91 (57.1%)

**Minimum acceptable:** 50/91 (54.9%)
**Target:** 60/91 (65.9%)
**Stretch:** 65/91 (71.4%)

---

## Quick Start (Session 188)

```bash
# 1. Read the continuation plan
open docs/SESSION-187-CONTINUATION-PLAN.md
open docs/SESSION-187-RESULTS.md

# 2. Review current parser
open lib/pubid_new/nist/parser.rb

# 3. Run baseline test
bundle exec ruby test_nist_todo.rb 2>&1 | grep -A 5 "RESULTS:"

# 4. Start with Part A (Roman numerals verification)
bundle exec ruby test_single.rb "NIST SP 1011-I-2.0"

# 5. Make Part B changes (volume ranges)
# Edit line 289: Add str("a-l") | str("m-z")

# 6. Test after each change
bundle exec ruby test_nist_todo.rb 2>&1 | grep "Passing:"
```

---

## Success Metrics

**Minimum (Session 188):**
- 50+/91 patterns passing (54.9%+)
- Roman numerals working
- Volume ranges working
- AMS/VTS series working

**Target (Session 188):**
- 60/91 patterns passing (65.9%)
- All Part A-F changes complete
- All LCIRC patterns working

**Stretch (Session 188):**
- 65+/91 patterns passing (71.4%+)
- Some Session 189 patterns started

---

## Critical Reminders

**Architecture Preservation (NEVER COMPROMISE):**
1. **MODEL-DRIVEN** - Objects not strings
2. **MECE** - Mutually exclusive patterns
3. **Three-layer** - Parser/Builder/Identifier independence
4. **Pattern Priority** - Most specific first
5. **One change at a time** - Test after each modification

**Parser Coordination:**
- Preprocessing adds spaces → Parser MUST accept them
- Pattern ordering matters in rules
- Use space.maybe liberally for flexibility

**Testing Discipline:**
- Use `test_single.rb` for targeted debugging
- Run full suite after each enhancement
- Document actual gain vs expected

---

## Files to Modify

**Primary:**
- `lib/pubid_new/nist/parser.rb` - Parser enhancements (all parts)

**Testing:**
- `test_nist_todo.rb` - Main test script
- `test_single.rb` - Diagnostic script

**Documentation:**
- `docs/SESSION-188-RESULTS.md` - Create after completion
- `docs/SESSION-187-CONTINUATION-PLAN.md` - Update tracker

---

## Next Session Preview (Session 189)

**Target:** 60/91 → 91/91 (100%)

**Focus areas:**
- RPT month-range patterns (15 patterns)
- Update patterns (-upd, /upd) (13 patterns)
- Lowercase input (1 pattern)
- Remaining edge cases (2 patterns)

**Estimated time:** 120 minutes
**End goal:** 100% TODO pattern coverage

---

**Status:** Session 187 COMPLETE - Ready for Session 188
**Priority:** HIGH - Compressed timeline to reach 100%
**Architecture:** Clean MODEL-DRIVEN design maintained

Let's implement ALL remaining NIST V2 patterns! 🚀