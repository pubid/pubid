# Session 186 Continuation Prompt: NIST V2 Pattern Implementation

**Context:** Session 185 completed foundation work with 19/91 patterns passing (20.9%). Need to implement remaining 72 patterns to reach 100% TODO coverage.

**Critical:** User requires ALL patterns from TODO.NIST-MUST-FIX.md to work.

**Important Pattern Semantics:**
- **"p1adde1"** = Part 1 + Addendum + Edition 1 (compound pattern)
- **"Pt3r1"** = Part 3 + Revision 1 (compound pattern)

---

## What Was Completed (Session 185)

✅ **19/91 patterns passing (20.9%)**

**Files Modified:**
- lib/pubid_new/nist/parser.rb (5 enhancements)
- test_nist_todo.rb (test script)
- docs/SESSION-185-RESULTS.md

**Enhancements:**
1. Version rule: supports "ver" without mandatory dots
2. Compound series: added NIST LCIRC, NBS RPT
3. Report numbers: added "sp" suffix (1088sp), capital letters (4817-A)
4. Preprocessing: space before "ver" patterns

**Commit:** 25095ee

---

## What Needs to Be Done (Sessions 186-189)

**READ FIRST:**
- [docs/SESSION-186-CONTINUATION-PLAN.md](SESSION-186-CONTINUATION-PLAN.md:1) - Comprehensive 4-session plan
- [TODO.NIST-MUST-FIX.md](../TODO.NIST-MUST-FIX.md:1) - 91 patterns to implement

**Current Status:** 19/91 passing (20.9%)
**Target:** 91/91 passing (100%)
**Timeline:** 3-4 sessions (6-8 hours compressed)

---

## Session 186 Immediate Tasks (120 min)

### Part A: Fix Dotted Versions - Volume/Version Conflict (40 min)

**Issue:** Parser must distinguish `v1.1` (version) from `v1` (volume)

**Solution:** Reorder parts rule to try version BEFORE volume

**File:** `lib/pubid_new/nist/parser.rb` line 395

**Change:**
```ruby
rule(:parts) do
  (
    new_stage |
    section | index | insert | appendix | pd_suffix |
    edition | revision | 
    version |  # MOVE BEFORE volume!
    volume | part | update | addendum |
    supplement | errata | language_code
  )
end
```

**Expected:** +11 patterns (all dotted versions)

### Part B: Fix Revision with Letters (25 min)

**Patterns:** `r1a`, `ra` (revision with optional digits and optional letter)

**File:** `lib/pubid_new/nist/parser.rb` line 281

**Enhancement:**
```ruby
rule(:revision) do
  (
    # Revision with year: rev2013
    (str("rev") >> digits.as(:revision_year)) |
    # Revision with optional digits AND optional letter: r1a, ra, r1
    ((str(" rev ") | str("rev") | str("r") | str(" Rev. ") | str(" Revision (r)")) >>
      (digits.maybe >> lower_letter.maybe).as(:revision))
  )
end
```

**Key:** Make BOTH digits and letter optional with `.maybe`

**Expected:** +5 patterns

### Part C: Fix Update Preprocessing (30 min)

**Patterns:** 13 patterns with `-upd`, `/upd`

**File:** `lib/pubid_new/nist/parser.rb` lines 37-40

**Enhancement:** 
```ruby
# Fix update patterns: ensure space before -upd or /upd (not just at end)
cleaned = cleaned.gsub(/(\d+)-upd/, '\1 -upd')    # Not just at end
cleaned = cleaned.gsub(/(\d+)\/upd/, '\1 /upd')   # Slash variant
cleaned = cleaned.gsub(/([a-z]\d+)\/upd/, '\1 /upd')  # After revision: r1/upd
```

**Expected:** +13 patterns

### Part D: Test and Validate (25 min)

```bash
bundle exec ruby test_nist_todo.rb
```

**Expected Result:** 40/91 (44%)

---

## Quick Start (Session 186)

```bash
# 1. Read the comprehensive plan
open docs/SESSION-186-CONTINUATION-PLAN.md

# 2. Review current parser
open lib/pubid_new/nist/parser.rb

# 3. Run baseline test
bundle exec ruby test_nist_todo.rb

# 4. Make Part A changes (version before volume in parts rule)
# Edit lib/pubid_new/nist/parser.rb line 395

# 5. Make Part B changes (revision with optional digits/letter)
# Edit lib/pubid_new/nist/parser.rb line 281

# 6. Make Part C changes (update preprocessing enhancements)
# Edit lib/pubid_new/nist/parser.rb lines 37-40

# 7. Test after each change
bundle exec ruby test_nist_todo.rb
```

---

## Success Metrics

**Minimum (Session 186):**
- 35+/91 patterns passing (38%+)
- Dotted versions working
- Revision letters working

**Target (Session 186):**
- 40/91 patterns passing (44%)
- Update patterns working
- All Part A-C changes validated

**Stretch (Session 186):**
- 42+/91 patterns passing (46%+)
- Some Session 187 patterns started

---

## Critical Patterns for Session 186

**Must work after Part A:**
1. `NIST SP 500-268v1.1` - Dotted version
2. `NIST SP 800-63v1.0.2` - Three-part version
3. `NIST SP 500-270v1.1` - Another dotted version

**Must work after Part B:**
4. `NIST SP 800-22r1a` - Revision with letter
5. `NIST SP 800-27ra` - Revision letter only

**Must work after Part C:**
6. `NIST SP 500-300-upd` - Update without number
7. `NIST IR 8170-upd` - IR series with update
8. `NIST AMS 300-8r1/upd` - Revision with slash update

---

## Architecture Reminders

**MAINTAIN throughout:**
1. **MODEL-DRIVEN** - Objects not strings
2. **MECE** - Mutually exclusive patterns
3. **Three-layer** - Parser/Builder/Identifier independence
4. **Pattern Priority** - Longest/most specific first
5. **One change at a time** - Test after each modification

**DO NOT:**
- Compromise architecture for test count
- Add business logic to Parser
- Make multiple changes without testing
- Skip validation steps

---

## Next Sessions Preview

**Session 187** (after 186):
- Complex part patterns (p1adde1, Pt3r1)
- Version+edition combinations
- Roman numerals (should already work)
- Volume ranges (should already work)
- **Target:** 55/91 (60%)

**Session 188** (after 187):
- AMS, VTS series
- LCIRC complex patterns
- RPT special patterns (date ranges, ADHOC, div9)
- **Target:** 75/91 (82%)

**Session 189** (final):
- Remaining edge cases
- Comprehensive testing
- Documentation updates
- **Target:** 91/91 (100%)

---

**Status:** Session 185 COMPLETE - Ready for Session 186
**Priority:** HIGH - Compressed timeline to complete all patterns
**Architecture:** Clean MODEL-DRIVEN design maintained

Let's complete ALL NIST V2 patterns! 🎯