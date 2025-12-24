# Session 194+ Continuation Plan: NIST Edge Cases to 95%+

**Created:** 2025-12-24 (Post-Session 193)
**Status:** Session 193 semantic corrections complete - Ready for edge cases
**Timeline:** COMPRESSED - Complete in 2-3 sessions (3-4 hours)
**Current:** 82/91 (90.1%) with correct semantics ✅

---

## Executive Summary

**Session 193 Achievement:** Semantic corrections complete - dot and underscore now have correct meanings ✅

**Current Status:**
- **NIST:** 82/91 (90.1%)
- **Semantics:** CORRECT (dot=part, underscore=edition)
- **Remaining:** 9 genuine edge cases + 2 data quality issues

**Target:** 87/91 (95.6%) - Skip 2 data quality issues, fix 7 edge cases

---

## SESSION 194: Remaining Edge Cases (120 minutes)

### Objective
Fix 7 remaining genuine edge cases to achieve 95%+ validation rate.

### Pattern Analysis (7 Fixable Patterns)

**Category 1: Rev with year (1 pattern) - 20 min**
- Pattern: `NIST SP 260-126rev2013`
- Issue: Preprocessing at line 27 should add space but may not trigger
- Debug: Check why `(\d)rev(\d{4})` pattern not matching
- **Expected gain:** +1 (90.1% → 91.2%)

**Category 2: Month in revision (1 pattern) - 20 min**
- Pattern: `NIST IR 4743rJun1992`
- Enhancement: Add month support to revision rule
- Parser: `(str("r") >> month_abbrev >> digits.as(:revision_year))`
- **Expected gain:** +1 (91.2% → 92.3%)

**Category 3: Lowercase suffix (1 pattern) - 15 min**
- Pattern: `NIST IR 6529-a`
- Verify: `number_suffix` at line 213 should accept lowercase
- Test: May already work, just needs validation
- **Expected gain:** +1 (92.3% → 93.4%)

**Category 4: CRPL range with suffix (1 pattern) - 25 min**
- Pattern: `NBS CRPL 1-2_3-1A`
- Current: `crpl_range` rule at line 331 doesn't include suffix
- Enhancement: `(digits >> str("_") >> digits >> dash >> digits >> upper_letter.maybe).as(:crpl_range)`
- **Expected gain:** +1 (93.4% → 94.5%)

**Category 5: Complex parts (3 patterns) - 40 min**
- Patterns:
  - `NIST SP 800-57Pt3r1` - Part with revision
  - `NBS TN 467p1adde1` - Part with addendum and edition
  - `NBS.TN.467p1adde1` - MR format variant

**Strategy:** Enhance `part` rule to accept revision after part number:
```ruby
rule(:part) do
  (str("pt") | str("p") | str("P") | str(" Part ")) >>
    (digits >>
     # Revision after part: pt3r1
     (str("r") >> digits).maybe >>
     # Addendum with optional edition: add, adde1
     (str("add") >> (str("e") >> digits).maybe).maybe >>
     (dash >> digits).maybe
    ).as(:part)
end
```

**Expected gain:** +3 patterns (94.5% → 97.8%)

**Data Quality (2 patterns) - SKIP:**
- `NISTPUB 0413171251` - "PUB" is not valid series
- `NIST CSWP 9NIST.HB.135e2022-upd1` - Corrupt concatenation

**Final expected:** 87/91 (95.6%) ✅

---

## Implementation Status Tracker

### Session 193: Semantic Corrections ✅
- [x] Revert dot preprocessing (15 min)
- [x] Add dot as part separator (30 min)
- [x] Add underscore as edition separator (30 min)
- [x] Test semantic correctness (15 min)
- Result: 82/91 (90.1%) with CORRECT semantics

### Session 194: Edge Cases (120 min)
- [ ] Rev with year: `260-126rev2013` (20 min)
- [ ] Month in revision: `rJun1992` (20 min)
- [ ] Lowercase suffix: `6529-a` (15 min)
- [ ] CRPL range with suffix: `1-2_3-1A` (25 min)
- [ ] Complex parts: `Pt3r1`, `p1adde1` (40 min)
- Expected: 82/91 → 87/91 (95.6%)

### Session 195: Documentation (30 min)
- [ ] Update memory bank context.md
- [ ] Move session docs to old-docs/
- [ ] Create session summaries
- [ ] Mark NIST edge case work complete

---

## Detailed Implementation Guide

### Task 1: Rev with Year (20 min)

**File:** `lib/pubid_new/nist/parser.rb` line 27

**Debug preprocessing:**
```ruby
# Current line 27:
cleaned = cleaned.gsub(/(\d)rev(\d{4})/, '\1 rev\2')
```

**Test why not matching:**
- Pattern should match `260-126rev2013`
- The `\d` requires digit immediately before `rev`
- But we have `6rev` which should match
- May need to test manually

**If not working, enhance pattern:**
```ruby
# Match rev with optional dash before year
cleaned = cleaned.gsub(/(\d)rev(\d{4})/, '\1 rev\2')
cleaned = cleaned.gsub(/(\d)(rev)(\d{4})/, '\1 \2 \3')  # Add space before year too
```

### Task 2: Month in Revision (20 min)

**File:** `lib/pubid_new/nist/parser.rb` line 363-376

**Add month pattern to revision rule:**
```ruby
rule(:revision) do
  (
    # Revision with month and year: rJun1992 (NEW)
    ((str("r") | str("rev")) >> month_abbrev.as(:revision_month) >> digits.as(:revision_year)) |
    # Revision with slash and year: r6/1925, r11/1924
    (space.maybe >> (str("r") | str("rev")) >> digits.as(:revision) >>
     slash >> digits.as(:revision_year)) |
    # ... existing patterns
  )
end
```

### Task 3: Lowercase Suffix (15 min)

**File:** `lib/pubid_new/nist/parser.rb` line 213

**Verify `number_suffix` accepts lowercase:**
```ruby
rule(:number_suffix) do
  match("[a-zA-Z]") >> ...  # Should already accept lowercase 'a'
end
```

**Test directly:**
```bash
bundle exec ruby -e "
require_relative 'lib/pubid_new/nist'
id = PubidNew::Nist.parse('NIST IR 6529-a')
puts id.to_s
"
```

### Task 4: CRPL Range with Suffix (25 min)

**File:** `lib/pubid_new/nist/parser.rb` line 331

**Current:**
```ruby
rule(:crpl_range) do
  (digits >> str("_") >> digits >> dash >> digits).as(:crpl_range)
end
```

**Enhanced:**
```ruby
rule(:crpl_range) do
  (digits >> str("_") >> digits >> dash >> digits >> upper_letter.maybe).as(:crpl_range)
end
```

### Task 5: Complex Parts (40 min)

**File:** `lib/pubid_new/nist/parser.rb` line 354-360

**Current:**
```ruby
rule(:part) do
  (str("pt") | str("p") | str("P") | str(" Part ")) >>
    (digits >>
     (str("add") >> (str("e") >> digits).maybe).maybe >>
     (dash >> digits).maybe).as(:part)
end
```

**Enhanced:**
```ruby
rule(:part) do
  (str("pt") | str("p") | str("P") | str(" Part ")) >>
    (digits >>
     # Revision after part: pt3r1, p1r1
     (str("r") >> digits).maybe >>
     # Addendum with optional edition: add, adde1
     (str("add") >> (str("e") >> digits).maybe).maybe >>
     (dash >> digits).maybe
    ).as(:part)
end
```

**This handles:**
- `800-57Pt3r1` → After preprocessing: `800-57 pt3 r1` → part=3r1
- `467p1adde1` → After preprocessing: `467 p1adde1` → part=1adde1

---

## Testing Strategy

### After Each Enhancement

```bash
# Test specific pattern
bundle exec ruby -e "
require_relative 'lib/pubid_new/nist'
test = 'NIST SP 260-126rev2013'
id = PubidNew::Nist.parse(test)
puts \"✅ #{test} → #{id.to_s}\"
"

# Run full TODO suite
bundle exec ruby test_nist_todo.rb 2>&1 | grep "RESULTS:" -A 5
```

### Success Criteria Per Task

| Task | Pattern | Expected | Actual |
|------|---------|----------|--------|
| 1 | `260-126rev2013` | Pass | TBD |
| 2 | `rJun1992` | Pass | TBD |
| 3 | `6529-a` | Pass | TBD |
| 4 | `1-2_3-1A` | Pass | TBD |
| 5a | `800-57Pt3r1` | Pass | TBD |
| 5b | `467p1adde1` | Pass | TBD |
| 5c | `.467p1adde1` | Pass | TBD |

---

## Success Criteria

### Minimum (92%)
- ✅ Rev with year working
- ✅ Month in revision working
- ✅ Lowercase suffix verified
- ✅ 84/91 (92.3%)

### Target (95%+)
- ✅ All fixable patterns working
- ✅ CRPL range with suffix
- ✅ Complex parts (all 3 variants)
- ✅ 87/91 (95.6%)

### Documentation
- ✅ Memory bank updated
- ✅ Session docs archived
- ✅ Known limitations documented

---

## Known Limitations (Document in README)

**Data Quality Issues (2 patterns - NOT fixable):**

1. `NISTPUB 0413171251`
   - Issue: "PUB" is not a valid NIST series
   - Should be: NIST + valid series code
   - Status: Document as invalid identifier

2. `NIST CSWP 9NIST.HB.135e2022-upd1`
   - Issue: Corrupt data - two identifiers concatenated
   - Should be: Either `NIST CSWP 9` OR `NIST HB 135e2022-upd1`
   - Status: Document as data quality issue

---

## Files to Modify

### Session 194
- `lib/pubid_new/nist/parser.rb` - All edge case enhancements
- Test after each change

### Session 195
- `.kilocode/rules/memory-bank/context.md` - Session 193-194 summary
- `docs/old-docs/sessions/session-193-summary.md` - NEW
- Move continuation plans to old-docs/

---

## Next Steps (Session 194)

1. Read this continuation plan
2. Implement Task 1: Rev with year (20 min)
3. Test and validate (+1 pattern)
4. Implement Task 2: Month in revision (20 min)
5. Test and validate (+1 pattern)
6. Implement Task 3: Lowercase suffix (15 min)
7. Test and validate (+1 pattern)
8. Implement Task 4: CRPL range (25 min)
9. Test and validate (+1 pattern)
10. Implement Task 5: Complex parts (40 min)
11. Final validation (expect 87/91 = 95.6%)

---

**Created:** 2025-12-24
**Sessions Covered:** 194-195
**Status:** Ready for execution
**Estimated Time:** 150 minutes total

**End Goal:** NIST at 95.6% with architecturally correct implementation! 📐