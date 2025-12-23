# Session 187 Continuation Prompt: NIST V2 Pattern Implementation

**Context:** Session 186 completed foundation work with 24/91 patterns passing (26.4%). Need to implement remaining 67 patterns to reach 100% TODO coverage.

**Critical:** User requires ALL patterns from TODO.NIST-MUST-FIX.md to work.

---

## What Was Completed (Session 186)

✅ **24/91 patterns passing (26.4%)** - +5 from Session 185

**Files Modified:**
- lib/pubid_new/nist/parser.rb (6 enhancements)
- docs/SESSION-186-RESULTS.md
- test_single.rb (diagnostic script)

**Enhancements:**
1. Version before volume in parts rule (v1.1 vs v1)
2. Revision letter support (digits.maybe >> lower_letter.maybe)
3. Update preprocessing (-upd, /upd, r1/upd)
4. Dotted version preprocessing (268v1.1 → 268 v1.1)
5. Version rule space handling (space.maybe)

**Commit:** f2eafa3

---

## What Needs to Be Done (Sessions 187-189)

**READ FIRST:**
- [docs/SESSION-187-CONTINUATION-PLAN.md](SESSION-187-CONTINUATION-PLAN.md:1) - Comprehensive 3-session plan
- [TODO.NIST-MUST-FIX.md](../TODO.NIST-MUST-FIX.md:1) - 91 patterns to implement

**Current Status:** 24/91 passing (26.4%)
**Target:** 91/91 passing (100%)
**Timeline:** 3 sessions (4-6 hours compressed)

---

## Session 187 Immediate Tasks (120 min)

### Part A: Version Without Dots (ver2, ver2v1) - 40 min

**Issue:** "800-28ver2" not parsing - preprocessing adds space between digit and "ver" but not after "ver"

**Solution:** Fix preprocessing line 30

**File:** `lib/pubid_new/nist/parser.rb` line 30

**Change:**
```ruby
# FROM:
cleaned = cleaned.gsub(/(\d)ver(\d)/, '\1 ver\2')

# TO:
cleaned = cleaned.gsub(/(\d)ver(\d)/, '\1 ver \2')
```

**Expected:** +10 patterns (all ver without dots)

### Part B: Dash Version Variant (-v1.0) - 20 min

**Patterns:** `NIST SP 500-281-v1.0`, `NIST.SP.500-281-v1.0`

**File:** `lib/pubid_new/nist/parser.rb` line 305

**Enhancement to version rule:**
```ruby
rule(:version) do
  (
    # Verbose "ver" form
    (str("ver") >> (digits >> (dot >> digits).repeat).as(:version)) |
    # Verbose forms with space
    ((str(" Ver. ") | str(" Version ")) >>
      (digits >> dot >> digits >> (dot >> digits).maybe).as(:version)) |
    # Short form with optional dash and space: -v1.0, v1.0
    ((dash | space).maybe >> str("v") >> 
      (digits >> dot >> digits >> (dot >> digits).maybe).as(:version))
  )
end
```

**Expected:** +2 patterns

### Part C: Test and Validate (60 min)

```bash
bundle exec ruby test_nist_todo.rb
```

**Expected Result:** 36/91 (39.6%) minimum, target 45/91 (49.5%)

---

## Quick Start (Session 187)

```bash
# 1. Read the comprehensive plan
open docs/SESSION-187-CONTINUATION-PLAN.md

# 2. Review current parser
open lib/pubid_new/nist/parser.rb

# 3. Run baseline test
bundle exec ruby test_nist_todo.rb

# 4. Make Part A changes (line 30 - add space after "ver")
# Edit: cleaned = cleaned.gsub(/(\d)ver(\d)/, '\1 ver \2')

# 5. Make Part B changes (line 305 - dash.maybe before v)
# Edit version rule to accept (dash | space).maybe

# 6. Test after each change
bundle exec ruby test_nist_todo.rb
```

---

## Success Metrics

**Minimum (Session 187):**
- 35+/91 patterns passing (38%+)
- Version without dots working
- Dash version working

**Target (Session 187):**
- 45/91 patterns passing (49.5%)
- All Part A-B changes validated

**Stretch (Session 187):**
- 48+/91 patterns passing (52%+)
- Some Session 188 patterns started

---

## Critical Patterns for Session 187

**Must work after Part A:**
1. `NIST SP 800-28ver2` - Version without dots
2. `NIST SP 800-40ver2` - Version without dots
3. `NIST SP 800-60ver2v1` - Combined version patterns

**Must work after Part B:**
4. `NIST SP 500-281-v1.0` - Dash before version
5. `NIST.SP.500-281-v1.0` - MR format with dash version

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

**Session 188** (after 187):
- Roman numerals (should work, verify)
- Volume ranges (v2a-l, v2m-z)
- AMS/VTS series
- Complex parts (p1adde1)
- LCIRC patterns (r6/1925)
- **Target:** 75/91 (82%)

**Session 189** (final):
- RPT special patterns (ADHOC, div9, month ranges)
- Lowercase input
- MR format edge cases
- Final validation
- **Target:** 91/91 (100%)

---

**Status:** Session 186 COMPLETE - Ready for Session 187
**Priority:** HIGH - Compressed timeline to complete all patterns
**Architecture:** Clean MODEL-DRIVEN design maintained

Let's complete ALL NIST V2 patterns! 🎯
