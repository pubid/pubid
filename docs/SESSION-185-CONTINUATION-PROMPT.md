# Session 185 Continuation Prompt: NIST V2 TODO Pattern Completion

**Context:** Session 184 completed basic NIST V2 patterns (stage, translation, 4-format rendering). Testing against TODO.NIST-MUST-FIX.md reveals 24/27 complex patterns still failing (11% pass rate). Need comprehensive parser pattern implementation.

**Critical:** User requires ALL patterns from TODO.NIST-MUST-FIX.md to work, including complex series types (AMS, CSWP, VTS, LCIRC, RPT, GCR, HB, TN, IR) and complex number patterns (volume ranges, roman numerals, dotted versions, complex parts).

---

## What Was Completed (Session 184)

✅ **Basic patterns working:**
- 4 rendering formats (short, mr, long, abbrev)
- Stage system (old-style "(IPD)", new-style "ipd")
- Translation normalization (es→spa, pt→por)
- Simple revisions (r5, r1)
- Format cross-conversion

✅ **Architecture clean:**
- MODEL-DRIVEN with V2 components
- MECE separation Parser/Builder/Identifier
- Builder returns composite hashes for component mapping

**Files Modified:**
- lib/pubid_new/nist/identifiers/base.rb
- lib/pubid_new/nist/builder.rb
- lib/pubid_new/nist/parser.rb
- spec/pubid_new/nist/format_conversion_spec.rb

---

## What Needs to Be Done (Sessions 185-187)

**READ FIRST:**
- [docs/SESSION-185-CONTINUATION-PLAN.md](SESSION-185-CONTINUATION-PLAN.md:1) - Full implementation plan
- [TODO.NIST-MUST-FIX.md](../TODO.NIST-MUST-FIX.md:1) - 27 patterns to implement

**Current Status:** 3/27 passing (11%)

**Target:** 27/27 passing (100%)

---

## Session 185 Immediate Tasks (120 min)

### Part A: Add Missing Series to Parser (30 min)

**File:** `lib/pubid_new/nist/parser.rb`

Add LCIRC to compound_series (NBS LCIRC already there, check positioning):
```ruby
rule(:compound_series) do
  (
    # Add if missing
    str("NBS LCIRC") |
    # ... existing patterns
  ).as(:series)
end
```

Verify RPT, LCIRC are in simple_series rule.

### Part B: Enhance Volume Rule (20 min)

**File:** `lib/pubid_new/nist/parser.rb` line 269

Current: `(digits >> (str("a-l") | str("m-z")).maybe >> upper_letter.repeat(0, 2))`

Enhancement needed:
- Volume ranges: v2a-l, v2m-z ✅ (already there!)
- Single letters: v3B, v1A ✅ (already there!)
- Issue: Parser might not be matching correctly

### Part C: Enhance Version Rule (30 min)

**File:** `lib/pubid_new/nist/parser.rb` line 286

Current version rule only matches "v" with dots (v1.0.2).

Enhancement: The `v` pattern needs to be after `ver` to avoid consuming version as volume:
```ruby
rule(:version) do
  (
    # Verbose forms FIRST (longest match)
    ((str("ver") | str(" Ver. ") | str(" Version ")) >>
      (digits >> (dot >> digits).repeat).as(:version)) |
    # Short form "v" with mandatory dots (v1.0, v1.0.2)
    (str("v") >>
      (digits >> dot >> digits >> (dot >> digits).repeat).as(:version))
  )
end
```

**Part D: Enhance Part Rule (20 min)

**File:** `lib/pubid_new/nist/parser.rb` line 272

Current: `(digits >> (str("add") >> (str("e") >> digits).maybe).maybe >> (dash >> digits).maybe)`

Enhancement: Should work but verify pattern order.

### Part E: Enhance Revision Rule (20 min)

**File:** `lib/pubid_new/nist/parser.rb` line 280

Current: `((str(" rev ") | str("rev") | str("r") ...) >> (digits >> lower_letter.maybe).maybe)`

Enhancement: Add revision with year pattern BEFORE others:
```ruby
rule(:revision) do
  (
    # With year FIRST: rev2013
    (str("rev") >> digits.as(:revision_year)) |
    # Then standard patterns
    ((str(" rev ") | str("rev") | str("r") | str(" Rev. ") | str(" Revision (r)")) >>
      (digits >> lower_letter.maybe).maybe).as(:revision)
  )
end
```

---

## Session 186: Testing & Iteration (90 min)

### Part A: Run TODO Test Suite (20 min)

```bash
ruby test_nist_todo.rb
```

Document which patterns pass/fail.

### Part B: Fix Identified Issues (50 min)

Iterate on failing patterns:
1. Analyze parse tree for failing pattern
2. Identify missing/incorrect parser rule
3. Fix parser rule
4. Test again
5. Repeat until 22+/27 passing (80%+)

### Part C: Update Builder if Needed (20 min)

If parser returns new data structures, update Builder casting.

---

## Session 187: Final Validation (60 min)

### Part A: Create Comprehensive Test Suite (40 min)

**File:** `spec/pubid_new/nist/todo_patterns_spec.rb`

Test all 27 patterns with:
- Parsing validation
- Component extraction
- 4-format rendering
- Round-trip tests

### Part B: Documentation (20 min)

Update documentation with final results.

---

## Quick Start (Session 185)

```bash
# 1. Read the full plan
open docs/SESSION-185-CONTINUATION-PLAN.md

# 2. Read TODO patterns
open TODO.NIST-MUST-FIX.md

# 3. Run baseline test
ruby test_nist_todo.rb

# 4. Start with Part A: Add missing series
# Edit lib/pubid_new/nist/parser.rb

# 5. Test after each enhancement
ruby test_nist_todo.rb
```

---

## Success Metrics

**Minimum (Session 185):**
- 15+/27 patterns passing (55%+)
- All series recognized
- Volume/version/part enhancements done

**Target (Session 186):**
- 22+/27 patterns passing (80%+)
- All major pattern categories working
- Revision/update variants handling

**Stretch (Session 187):**
- 27/27 patterns passing (100%)
- Comprehensive test suite
- Documentation complete

---

## Critical Patterns

**Must work for production:**
1. Volume ranges: v2a-l, v2m-z
2. Dotted versions: v1.0.2, v1.1
3. Roman numerals: -I-2.0, -II-1.0
4. Complex parts: p1adde1 (part 1 addition edition 1)
5. Revision variants: rev2013, r1a, ra
6. Version+edition: ver2, ver2v1, ver1e2006
7. Update patterns: -upd, /upd
8. All series: AMS, CSWP, VTS, LCIRC, RPT, GCR, HB, TN, IR

---

**Status:** Session 184 basic patterns complete (11% TODO coverage)
**Priority:** HIGH - Comprehensive pattern implementation needed
**Timeline:** 4-6 hours (Sessions 185-187)

Let's complete ALL NIST patterns! 🎯