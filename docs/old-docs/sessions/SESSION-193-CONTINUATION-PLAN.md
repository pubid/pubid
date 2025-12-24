# Session 193+ Continuation Plan: NIST Semantic Corrections & Edge Cases

**Created:** 2025-12-23 (Post-Session 192)
**Status:** Session 192 identified architectural issue - dot/underscore semantics wrong
**Timeline:** COMPRESSED - Complete in 2-3 sessions (3-4 hours)
**Priority:** CRITICAL - Architectural correctness before further progress

---

## Critical Discovery (Session 192 Post-Analysis)

**ARCHITECTURAL ERROR IDENTIFIED:**

Session 192's preprocessing was semantically WRONG:

**Incorrect interpretation:**
- `NIST SP 984.4` → `984_4` (treated as single number)
- `NIST.TN.1648_2009` → `1648_2009` (treated as single number)

**Correct interpretation:**
- `NIST SP 984.4` → number=984, **part=4** (dot is part separator!)
- `NIST.TN.1648_2009` → number=1648, **edition=2009** (underscore is edition separator!)

**Impact:** Our "fix" created 2 passing tests with WRONG semantics! Must revert and fix properly.

---

## SESSION 193: Semantic Corrections (90 minutes)

### Objective
Fix dot and underscore handling to use correct architectural semantics.

### Phase 1: Revert Incorrect Changes (15 min)

**Revert lines 93-99 dot preprocessing:**
```ruby
# REMOVE THIS (semantically wrong):
# cleaned = cleaned.gsub(/(?<!v)(?<![IVX]-)(\d{3,})\.(\d{1,4})(?=\s|$)/, '\1_\2')
```

**Keep underscore as edition separator in MR format** - this is semantically correct.

### Phase 2: Add Part Separator Support (30 min)

**Update `report_number` rule to handle dot-separated parts:**

```ruby
# Full report number - support dot-separated parts AND CRPL ranges
rule(:report_number) do
  first_number >> 
  (
    # Dot-separated part (e.g., 984.4 = number 984, part 4)
    (dot >> second_number) |
    # Dash-separated (traditional)
    (dash >> (crpl_range | second_number))
  ).maybe
end
```

**Expected gain:** +1 pattern (`NIST SP 984.4` with correct semantics)

### Phase 3: Edition Separator Handling (30 min)

**Underscore in MR format = edition separator:**

Add to `parts` or `edition` rules:

```ruby
# In edition rule, add underscore variant for MR format
rule(:edition) do
  (
    # Underscore-separated edition in MR format (e.g., 1648_2009)
    (str("_") >> digits.as(:edition_year)) |
    # ... existing edition patterns
  )
end
```

**Or add as separate rule after number in MR format:**
```ruby
rule(:mr_identifier) do
  hash_prefix.maybe >>
  publisher >> dot >>
  simple_series >> dot >>
  report_number >>
  # Edition with underscore separator (MR format specific)
  (str("_") >> digits.as(:edition_year)).maybe >>
  (dot >> (digits | upper_letter)).repeat(0, 3) >>
  parts.repeat >> draft.maybe
end
```

**Expected gain:** +1 pattern (`NIST.TN.1648_2009` with correct semantics)

### Phase 4: Testing & Validation (15 min)

**Test both patterns with correct semantics:**
```ruby
id = PubidNew::Nist.parse("NIST SP 984.4")
id.number.first_number  # => "984"
id.number.second_number # => "4" (part)

id = PubidNew::Nist.parse("NIST.TN.1648_2009")
id.number.first_number  # => "1648"
id.edition              # => "2009" (edition year)
```

**Expected result:** 80/91 → 82/91 (but with CORRECT semantics)

---

## SESSION 194: Remaining Edge Cases (120 minutes)

### Objective
Fix remaining 7 genuine edge cases (skip 2 data quality issues).

### Pattern Analysis

**Category 1: Rev with year (1 pattern) - 20 min**
- `NIST SP 260-126rev2013`
- Line 26 preprocessing should add space: `260-126 rev2013`
- Debug why it's not working
- **Expected gain:** +1

**Category 2: Month in revision (1 pattern) - 20 min**
- `NIST IR 4743rJun1992`
- Enhance revision rule to accept month after 'r'
- **Expected gain:** +1

**Category 3: Lowercase suffix (1 pattern) - 15 min**
- `NIST IR 6529-a`
- Verify `number_suffix` accepts lowercase (it should at line 209)
- Add test case if needed
- **Expected gain:** +1

**Category 4: CRPL range (1 pattern) - 25 min**
- `NBS CRPL 1-2_3-1A`
- Pattern: first_number=1, crpl_range=2_3-1, suffix=A
- Enhance crpl_range rule to accept letter suffix
- **Expected gain:** +1

**Category 5: Complex parts (3 patterns) - 40 min**
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

**Expected gain:** +3 patterns

**Category 6: Data quality (2 patterns) - SKIP**
- `NISTPUB 0413171251` - "PUB" is not valid series (document in README)
- `NIST CSWP 9NIST.HB.135e2022-upd1` - Corrupt concatenation (document in README)

---

## Implementation Status Tracker

### Session 192: Wrong Semantics ⚠️
- [x] Dot→underscore preprocessing (WRONG - reverted in 193)
- [x] Underscore support in parser (CORRECT - edition in MR format)
- [x] Typo fix: rule! → rule
- Result: 82/91 (90.1%) but with incorrect semantics

### Session 193: Semantic Corrections (CRITICAL)
- [ ] Revert dot→underscore preprocessing (15 min)
- [ ] Add dot as part separator (30 min)
- [ ] Keep underscore as edition separator for MR format (30 min)
- [ ] Test with correct semantics (15 min)
- Expected: 80/91 → 82/91 with CORRECT semantics

### Session 194: Remaining Edge Cases
- [ ] Rev with year: `260-126rev2013` (20 min)
- [ ] Month in revision: `rJun1992` (20 min)
- [ ] Lowercase suffix: `6529-a` (15 min)
- [ ] CRPL range with suffix: `1-2_3-1A` (25 min)
- [ ] Complex parts: `Pt3r1`, `p1adde1` (40 min)
- Expected: 82/91 → 87/91 (95.6%)

---

## Success Criteria

### Minimum (Session 193)
- ✅ Dot correctly parses as part separator
- ✅ Underscore correctly parses as edition separator
- ✅ Both patterns pass with correct semantics
- ✅ 82/91 (90.1%) maintained

### Target (Session 194)
- ✅ All edge cases except data quality fixed
- ✅ 87/91 (95.6%) achieved
- ✅ Clean architecture maintained

### Documentation
- ✅ Known limitations documented in README
- ✅ Data quality issues clearly marked
- ✅ Semantic corrections explained

---

## Key Architectural Principles

**NEVER COMPROMISE:**
1. **Semantic correctness** - Architecture over test pass rate
2. **MODEL-DRIVEN** - Objects with proper attributes (number, part, edition)
3. **MECE** - Each component has clear responsibility
4. **Three-layer** - Parser captures syntax, Builder assigns semantics

**Critical lesson:** Preprocessing should normalize FORMAT, not change SEMANTICS!

---

## Files to Modify

### Session 193
- `lib/pubid_new/nist/parser.rb` - Lines 93-99 (revert), 332-334 (dot separator), MR edition
- `test_nist_todo.rb` - Verify semantic correctness

### Session 194
- `lib/pubid_new/nist/parser.rb` - Edge case enhancements
- `.kilocode/rules/memory-bank/context.md` - Session 193-194 summary
- `docs/SESSION-192-CONTINUATION-PLAN.md` - Mark superseded

---

**Created:** 2025-12-23
**Sessions Covered:** 193-194
**Status:** Critical architectural correction needed
**Priority:** Session 193 MUST be done before proceeding

**End Goal:** NIST at 95%+ with architecturally CORRECT implementation! 🎯
