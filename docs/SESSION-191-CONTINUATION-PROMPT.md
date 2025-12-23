# Session 191 Continuation Prompt: NIST V2 Pattern Completion

**Context:** Session 190 completed with 65/91 patterns (71.4%). Need to implement remaining 26 patterns to reach 85-93%+.

**Critical:** User requires comprehensive coverage of TODO patterns with clean MODEL-DRIVEN architecture.

---

## What Was Completed (Session 190)

✅ **65/91 patterns passing (71.4%)** - +1 from Session 189

**Files Modified:**
- [`lib/pubid_new/nist/parser.rb`](lib/pubid_new/nist/parser.rb:1) (preprocessing + revision rule)
- [`docs/SESSION-190-RESULTS.md`](SESSION-190-RESULTS.md:1) (documentation)
- [`docs/SESSION-191-CONTINUATION-PLAN.md`](SESSION-191-CONTINUATION-PLAN.md:1) (roadmap)
- Committed as: `515d447`, `fba389a`, `9e426a2`

**Key Changes:**
1. Fixed revision spacing order with `(?=-|$)` negative lookahead
2. Added letter-only revision support (Revision A parsing)
3. Enhanced revision rule for r+4digit year patterns
4. Laid foundation for r1-upd patterns

---

## What Needs to Be Done (Session 191)

**READ FIRST:**
- [`docs/SESSION-191-CONTINUATION-PLAN.md`](SESSION-191-CONTINUATION-PLAN.md:1) - Complete implementation plan
- [`docs/SESSION-190-RESULTS.md`](SESSION-190-RESULTS.md:1) - Session 190 analysis
- [`TODO.NIST-MUST-FIX.md`](../TODO.NIST-MUST-FIX.md:1) - 91 patterns total

**Current Status:** 65/91 passing (71.4%)
**Target:** 75+/91 passing (82%+)
**Timeline:** 120 minutes compressed

---

## Session 191 Immediate Tasks (120 min)

### Phase 1: Fix Update Patterns Without Numbers (40 min)

**Problem:** `NIST SP 500-300-upd` has no update number but fails

**Current state:**
- Preprocessing works: `500-300-upd` → `500-300 -upd`
- Parser update rule has `update_number.maybe` (Session 189)
- Still failing

**Actions:**
1. Test if preprocessed strings parse (10 min)
2. Debug why failing - parser vs builder issue (15 min)
3. Fix identified issue (15 min)

**Expected:** +6 patterns (all simple -upd)

---

### Phase 2: Fix r1-upd Combined Patterns (30 min)

**Patterns:** `NIST IR 8115r1-upd`, `NIST.IR.8115r1-upd`

**Expected preprocessing:** `8115r1-upd` → `8115 r1 -upd`

**Actions:**
1. Verify preprocessing chain works (10 min)
2. Test if parser matches revision + update (10 min)
3. Fix parts rule ordering if needed (10 min)

**Expected:** +5 patterns (all r1-upd variants)

---

### Phase 3: Debug LCIRC Compound Series (50 min)

**Patterns:** `NIST LCIRC 1136`, `NIST LCIRC 1128r1995`, `NBS LCIRC 118supp3/1926`

**Issue:** "NIST LCIRC" in compound_series but not matching

**Investigation:**
1. Test compound_series rule directly (15 min)
2. Check identifier rule order - is publisher matched first? (15 min)
3. Fix matching issue (20 min)

**Expected:** +4 patterns (all LCIRC)

---

## Quick Start (Session 191)

```bash
# 1. Read the continuation plan
open docs/SESSION-191-CONTINUATION-PLAN.md

# 2. Review current parser state
open lib/pubid_new/nist/parser.rb

# 3. Run baseline test
bundle exec ruby test_nist_todo.rb 2>&1 | grep -A 5 "RESULTS:"
# Expected: 65/91 (71.4%)

# 4. Start Phase 1: Test update patterns
bundle exec ruby -e "
require_relative 'lib/pubid_new/nist/parser'
['NIST SP 500-300-upd', 'NIST IR 8170-upd'].each do |test|
  puts test
  begin
    PubidNew::Nist::Parser.parse(test)
    puts '  ✓ Success'
  rescue => e
    puts '  ✗ Failed'
  end
end
"

# 5. Continue through phases systematically
```

---

## Success Metrics

**Minimum (Session 191):**
- 70+/91 patterns passing (77%+)
- Update patterns working
- Progress toward LCIRC fix

**Target (Session 191):**
- 75+/91 patterns passing (82%+)
- All update and r1-upd patterns working
- LCIRC patterns fixed

**Stretch (Session 191):**
- 78+/91 patterns passing (86%+)
- Bonus complex part patterns fixed

---

## Critical Reminders

**Architecture Preservation (NEVER COMPROMISE):**
1. **MODEL-DRIVEN** - Objects not strings
2. **MECE** - Mutually exclusive, collectively exhaustive
3. **Three-layer** - Parser/Builder/Identifier independence
4. **One change at a time** - Test after each modification
5. **Preprocessing order matters** - Revision BEFORE update!

**Key Insights from Session 190:**
- Negative lookahead `(?=-|$)` prevents unwanted spacing
- Letter-only revisions work with `lower_letter.repeat(1)`
- Preprocessing order is CRITICAL
- LCIRC needs systematic debugging

---

## Files to Modify

**Primary:**
- [`lib/pubid_new/nist/parser.rb`](lib/pubid_new/nist/parser.rb:1) - All pattern fixes
- [`lib/pubid_new/nist/builder.rb`](lib/pubid_new/nist/builder.rb:1) - Update handling (if needed)

**Documentation:**
- `docs/SESSION-191-RESULTS.md` - Create after completion

---

## Pattern Categories Remaining (26 total)

**Update patterns (11):**
- Simple: `500-300-upd`, `8170-upd`, `2150-upd`, `8211-upd`
- Combined: `8115r1-upd`
- Plus MR format variants

**LCIRC (4):**
- Simple: `LCIRC 1136`
- With revision: `LCIRC 1128r1995`
- With supplement: `LCIRC 118supp3/1926`, `LCIRC 118supp12/1926`

**Complex parts (3):**
- `800-57Pt3r1`, `467p1adde1`, `NBS.TN.467p1adde1`

**Edge cases (8):**
- Dot, CRPL, month, suffix, corrupt data, MR formats

---

**Status:** Session 190 COMPLETE - Session 191 ready to begin
**Priority:** HIGH - Compressed timeline to reach 82%+
**Architecture:** Clean MODEL-DRIVEN design maintained

Let's complete the remaining NIST V2 patterns! 🚀
