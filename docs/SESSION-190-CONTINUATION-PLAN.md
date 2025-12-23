# Session 190+ Continuation Plan: NIST V2 Final Patterns to 100%

**Created:** 2025-12-23 (Post-Session 189)
**Status:** Session 189 complete - 64/91 (70.3%)
**Timeline:** COMPRESSED - Complete remaining 27 patterns in 1-2 sessions (2-3 hours MAX)
**Priority:** HIGH - User requires 100% TODO pattern coverage

---

## Executive Summary

**Current Progress:** 64/91 (70.3%)
**Remaining:** 27 patterns (29.7%)
**Target:** 91/91 (100%)

**Session 189 Achievements:**
- ✅ Fixed update rule (made update_number optional)
- ✅ Enhanced preprocessing for update/revision/supplement patterns
- ✅ Gained +3 patterns with clean architecture

**Remaining Work Categorized:**
1. **Revision spacing fixes (9 patterns)** - Preprocessing order issues
2. **LCIRC patterns (5 patterns)** - Parser support needed
3. **Complex parts (3 patterns)** - Already working, builder/test issues
4. **Edge cases (10 patterns)** - Data quality + special formats

---

## SESSION 190: Final Pattern Implementation (120-150 min)

**Target:** 64/91 → 91/91 (100%) - Gain +27 patterns

### Part A: Fix Revision Before Update Spacing (20 min)

**Issue:** Preprocessing order - `r1-upd` needs space before `-upd` check

**Current (line 52-57):**
```ruby
cleaned = cleaned.gsub(/(\d+)-upd(\d*)/, '\1 -upd\2')    # Matches 8115-upd first
cleaned = cleaned.gsub(/([a-z]\d+)-upd/, '\1 -upd')      # Never reached for r1-upd
```

**Fix:** Process revision patterns BEFORE update patterns
```ruby
# FIX ORDER: Process revisions FIRST, then updates
# Line 29-30: Already has r6/1925 handling
# Add BEFORE update patterns (before line 52):

# Fix revision attached to number: "8115r1" → "8115 r1" (MUST be before -upd check)
cleaned = cleaned.gsub(/(\d)(r\d+)/, '\1 \2')            # 8115r1 → 8115 r1

# Then existing update patterns work correctly:
cleaned = cleaned.gsub(/(\d+)-upd(\d*)/, '\1 -upd\2')
cleaned = cleaned.gsub(/([a-z]\d+)-upd/, '\1 -upd')      # Now catches "r1-upd"
```

**Expected gain:** +6 patterns (all r1-upd variants)

---

### Part B: Add Revision Letter-Only Support (15 min)

**Issue:** Parser revision rule doesn't accept standalone letters (`ra`)

**Current revision rule (line 335):**
```ruby
rule(:revision) do
  (
    (space.maybe >> (str("r") | str("rev")) >> digits.as(:revision) >>
     slash >> digits.as(:revision_year)) |
    (str("rev") >> digits.as(:revision_year)) |
    ((str(" rev ") | str("rev") | str("r")) >>
      (digits.maybe >> lower_letter.maybe).as(:revision))  # BUG: letter after digits
  )
end
```

**Fix:** Allow letters without digits
```ruby
rule(:revision) do
  (
    # ... existing patterns ...
    # Enhanced: Allow digits AND/OR letters
    ((str(" rev ") | str("rev") | str("r") | str(" R")) >>
      (digits >> lower_letter.maybe | lower_letter.repeat(1)).as(:revision))
  )
end
```

**Expected gain:** +1 pattern (`800-27ra`)

---

### Part C: LCIRC Simple Number Support (25 min)

**Issue:** LCIRC patterns not parsing - need both simple numbers and revisions

**Patterns:**
- `NIST LCIRC 1136` (just number)
- `NIST LCIRC 1128r1995` (revision with year - r format)
- `NBS LCIRC 118supp3/1926` (supplement with slash/year)

**Solution 1: Verify compound_series coverage (5 min)**

Check if `NIST LCIRC` and `NBS LCIRC` are in compound_series (line 166) - ALREADY THERE ✅

**Solution 2: Test if report_number.maybe works (5 min)**

The pattern allows `report_number.maybe` so simple `1136` should work.

**Solution 3: Debug why failing (15 min)**

Test directly:
```bash
bundle exec ruby -e "
require_relative 'lib/pubid_new/nist/parser'
PubidNew::Nist::Parser.new.parse('NIST LCIRC 1136')
" 2>&1 | head -20
```

If report_number needs enhancement, check first_number rule.

**Expected gain:** +5 patterns (all LCIRC)

---

### Part D: Complex Part Patterns (10 min)

**Issue:** `p1adde1` patterns - preprocessing works, test if parsing works

**Test patterns:**
- `NBS TN 467p1adde1` (short format)
- `NBS.TN.467p1adde1` (MR format)

**Action:** Test if these now work after r-spacing fix
```bash
bundle exec ruby test_nist_todo.rb 2>&1 | grep "467p1adde1"
```

If failing, check part rule (line 327) - already supports `add` >> `e` >> digits

**Expected gain:** +2 patterns

---

### Part E: CRPL Range Pattern (10 min)

**Pattern:** `NBS CRPL 1-2_3-1A`

**Current:** CRPL range rule exists (line 309), second_number has underscore pattern (line 259-260)

**Action:** Test directly
```bash
bundle exec ruby -e "
require_relative 'lib/pubid_new/nist/parser'
PubidNew::Nist::Parser.parse('NBS CRPL 1-2_3-1A')
"
```

If failing, check if `_3-1A` pattern matches second_number correctly.

**Expected gain:** +1 pattern

---

### Part F: Remaining Edge Cases (30 min)

**Test each pattern individually:**

1. **Month revision** (10 min)
   - `NIST IR 4743rJun1992`
   - Check if rJun needs spacing: `rJun1992` → `r Jun1992`?
   - Or if month_abbrev needs to be in revision rule?

2. **Number suffix** (5 min)
   - `NIST IR 6529-a`
   - Should work with digits_with_suffix (line 207)
   - Test: Does `-a` parse?

3. **Dot in number** (5 min)
   - `NIST SP 984.4`
   - Check preprocessing line 77: `\d{3,}\s+\d{1,2}` → `_`
   - Should be: `984 4` → `984_4`

4. **MR patterns** (10 min)
   - `NIST.TN.1648_2009`
   - `NIST.VTS.100-2sup1`
   - MR identifier rule supports parts.repeat
   - Test if these parse in MR format

**Expected gain:** +6 patterns

---

### Part G: Data Quality Issues - Document (10 min)

**Corrupt/Invalid patterns (2):**
- `NIST CSWP 9NIST.HB.135e2022-upd1` - Malformed (two identifiers concatenated)
- `NISTPUB 0413171251` - Unknown series "PUB"

**Action:** Document as data quality issues, do not compromise architecture

---

## Implementation Strategy

### Compressed Timeline (120-150 min total)

**Phase 1: Critical Fixes (55 min)**
1. Part A: Revision spacing (20 min) → +6 patterns = 70/91 (76.9%)
2. Part B: Revision letters (15 min) → +1 pattern = 71/91 (78.0%)
3. Part C: LCIRC patterns (20 min) → +5 patterns = 76/91 (83.5%)

**Phase 2: Edge Cases (50 min)**
4. Part D: Complex parts (10 min) → +2 patterns = 78/91 (85.7%)
5. Part E: CRPL range (10 min) → +1 pattern = 79/91 (86.8%)
6. Part F: Remaining cases (30 min) → +6 patterns = 85/91 (93.4%)

**Phase 3: Documentation (15 min)**
7. Part G: Document data quality issues → Final 85/91 (93.4%)
8. Create SESSION-190-RESULTS.md
9. Update README if needed

**Stretch Goal:** If all edge cases resolve → 89/91 (97.8%)

---

## Testing Strategy

**After each part:**
```bash
bundle exec ruby test_nist_todo.rb 2>&1 | grep -A 5 "RESULTS:"
```

**Expected progression:**
- After Part A: 70/91 (76.9%)
- After Part B: 71/91 (78.0%)
- After Part C: 76/91 (83.5%)
- After Part D: 78/91 (85.7%)
- After Part E: 79/91 (86.8%)
- After Part F: 85/91 (93.4%)

---

## Success Criteria

### Minimum (85%+)
- ✅ 77+/91 patterns passing (85%+)
- ✅ All categorized patterns addressed
- ✅ Architecture clean
- ✅ Documentation complete

### Target (93%+)
- ✅ 85+/91 patterns passing (93%+)
- ✅ All fixable patterns working
- ✅ Data quality issues documented
- ✅ Comprehensive results doc

### Stretch (97%+)
- ✅ 89+/91 patterns passing (97%+)
- ✅ Only data quality issues remaining
- ✅ README updated with NIST status

---

## Critical Reminders

**Architecture Preservation (NEVER COMPROMISE):**
1. **MODEL-DRIVEN** - Objects not strings
2. **MECE** - Mutually exclusive patterns
3. **Three-layer** - Parser/Builder/Identifier independence
4. **One change at a time** - Test after each
5. **Preprocessing coordinates with parser** - Order matters!

**Preprocessing Order is Critical:**
1. Fix revisions FIRST: `8115r1` → `8115 r1`
2. Then fix updates: `r1-upd` → `r1 -upd` (now works!)
3. Order: revision spacing → update spacing → other patterns

---

## Files to Modify

**Primary:**
- `lib/pubid_new/nist/parser.rb` - Preprocessing order + revision rule

**Documentation:**
- `docs/SESSION-190-RESULTS.md` - Create after completion
- `README.adoc` - Update NIST section if 90%+ achieved

---

**Created:** 2025-12-23
**Session Covered:** 190
**Status:** Ready for execution
**Timeline:** 2-3 hours compressed for 85-93%+ completion

**End Goal:** 85-91/91 patterns (93-100%), NIST V2 production-ready! 🚀
