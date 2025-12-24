# Session 197 Continuation Plan: Fix Remaining SP and IR Edge Cases

**Created:** 2025-12-24 (Post-Session 196)
**Status:** 19,786/19,827 (99.79%), 41 failures remaining
**Current:** 8 SP failures + 5 IR patterns in unknown
**Target:** 19,799+/19,827 (99.86%+) minimum, 19,827/19,827 (100%) stretch goal
**Timeline:** 60-90 minutes compressed

---

## Current Status

**Session 196 Achievement:**
- ✅ Fixed 9 SP patterns (standalone r, revision+language)
- ✅ NIST at 99.79% (19,786/19,827)

**Remaining Failures (41 total):**
- **SP:** 8 identifiers (5 are original unpre processed versions)
- **IR:** 5+ identifiers (various edge cases)
- **Other:** FIPS, CIRC (month formats)

---

## Problem Analysis

### Issue 1: SP Version Patterns Not Actually Fixed

**The 5 "working" patterns from Session 196 are still failing in fixtures!**

Patterns showing as failures:
```
#NIST SP 500-268v1 1#  (original format with spaces)
#NIST SP 500-270v1 1#
#NIST SP 500-280v2 1#
#NIST SP 800-63v1 0 1# (original format with spaces)
#NIST SP 800-63v1 0 2#
```

**Root Cause:** These are the ORIGINAL strings from fixtures (before preprocessing). The preprocessing at lines 66-67 converts them to `v1.1` format, but there's a bug - the patterns aren't being captured from the ORIGINAL input.

**The preprocessing works for testing but fixtures store ORIGINAL strings!**

### Issue 2: IR Edge Cases Not Handling Trailing Space+Digit

**Pattern:** `NBS IR 80-2073 2` and `NBS IR 80-2073 3`
- Number with trailing space and single digit
- Could be edition, part, or volume
- Not being captured by parts rules

### Issue 3: IR Lowercase Suffix

**Pattern:** `NIST IR 6529-a`
- Lowercase letter suffix after dash
- `number_suffix` rule only allows uppercase or digits after lowercase

### Issue 4: Month-Year Without Abbreviation

**Pattern:** `NBS CIRC 15-April1909`
- Full month name (April) not abbreviated
- `month_abbrev` rule doesn't include full names

### Issue 5: MR Format with Supplement+Revision

**Pattern:** `NBS.CIRC.154suprev`
- Machine-readable format
- Combined supplement and revision
- MR identifier path may not handle `suprev` properly

---

## Implementation Plan (60-90 minutes)

### Phase 1: Analyze Actual Fixture Data (10 min)

**Check what the actual fixture files contain:**
```bash
cd spec/fixtures/nist/identifiers/full
grep -n "500-268v1 1" *.txt
grep -n "80-2073 2" *.txt
grep -n "6529-a" *.txt
```

**Understand the data format and if preprocessing is being applied during classification.**

### Phase 2: Fix Trailing Space+Digit (15 min)

**Issue:** `NBS IR 80-2073 2` not matching any parts rule

**Strategy:** These look like volume or edition indicators

**Parser enhancement (line 372-377 volume rule):**
```ruby
rule(:volume) do
  (space.maybe >> (str("v") | str(" Vol. ")) |
   # NEW: Standalone space+digit at end (treated as volume)
   (space >> digit.repeat(1, 2) >> any.absent?).as(:volume_standalone)) >>
  (digits >>
   (str("a-l") | str("m-z")).maybe >>
   upper_letter.repeat(0, 2)).as(:volume)
end
```

**OR add to parts as a catch-all:**
```ruby
# In parts rule (line 521-531), add at end:
rule(:trailing_number) do
  space >> digits.as(:trailing_number)
end

# Add to parts alternatives
```

**Expected gain:** +2 identifiers

### Phase 3: Fix Lowercase Suffix (10 min)

**Issue:** `6529-a` not parsing due to lowercase after dash

**Parser enhancement (line 252-256):**
```ruby
rule(:digits_with_suffix) do
  digits >>
    # Allow lowercase OR uppercase letter suffix
    ((match("[a-zA-Z]") >> digit.absent?).maybe)
end
```

**Update second_number to allow lowercase (line 302-316):**
```ruby
rule(:second_number) do
  (
    # ... existing patterns ...
    # Regular number with optional suffix (allow lowercase too)
    (digits >> match("[a-zA-Z]").maybe)
  ).as(:second_number)
end
```

**Expected gain:** +1 identifier

### Phase 4: Add Full Month Names (15 min)

**Issue:** `April1909` not matching month_abbrev

**Parser enhancement (line 160-166):**
```ruby
rule(:month_abbrev) do
  str("January") | str("February") | str("March") | str("April") |
  str("May") | str("June") | str("July") | str("August") |
  str("September") | str("October") | str("November") | str("December") |
  str("Jan") | str("Feb") | str("Mar") | str("Apr") |
  str("Jun") | str("Jul") | str("Aug") | str("Sep") | str("Oct") | str("Nov") | str("Dec")
end
```

**Already has full names! Check if preprocessing is stripping them:**

**Ah! Need to check series-specific patterns. Add to edition rule (line 320-352):**
```ruby
# Add after line 337 in edition rule:
# With full month name and year: -April1909, -June1908
(dash >> (
  str("January") | str("February") | str("March") | str("April") |
  str("May") | str("June") | str("July") | str("August") |
  str("September") | str("October") | str("November") | str("December")
).as(:edition_month) >> digits.as(:edition_year))
```

**Expected gain:** +1 identifier

### Phase 5: Fix MR Supplement+Revision (10 min)

**Issue:** `NBS.CIRC.154suprev` not parsing

**Check supplement rule at line 446-464:**
```ruby
rule(:supplement) do
  space.maybe >>
  (str("supp") | str("sup")) >>
  (
    # Supplement followed by revision: supprev
    (str("rev")).as(:supplement_with_rev) |
    # ... other patterns
  ).maybe
end
```

**This should work! Check if MR format is using parts.repeat properly.**

**Issue might be in mr_identifier rule (line 536-546). Ensure it allows supplements:**

Already has `parts.repeat` so should work. May need preprocessing:
```ruby
# In Parser.parse add:
# Fix supplement in MR format: .154suprev → .154 suprev
cleaned = cleaned.gsub(/\.(\d+)(sup+rev)/, '.\1 \2')
```

**Expected gain:** +1 identifier

### Phase 6: Investigate SP "Failures" (20 min)

**Critical question:** Are these actually failing or are they duplicate fixture entries?

**Check fixture files:**
```bash
# Find the actual entries
cd spec/fixtures/nist/identifiers/full
grep "500-268" sp.txt | head -5
grep "800-63v" sp.txt | head -5
```

**Two possibilities:**
1. **Duplicates:** Fixtures have both `v1 1` AND `v1.1` versions
2. **Bug:** Classification script not applying preprocessing

**If duplicates:** These are DATA QUALITY issues, not parser issues. The parser works correctly. We should mark them as normalized variants.

**If preprocessing bug:** Fix classification script to use `Parser.parse()` which applies preprocessing.

### Phase 7:  Test and Validate (10 min)

```bash
cd spec/fixtures/nist
ruby ../run_classify.rb nist
```

**Expected results:**
- Minimum: 19,791/19,827 (99.82%) - +5 identifiers
- Target: 19,799/19,827 (99.86%) - +13 identifiers
- Stretch: 19,810+/19,827 (99.91%+)

### Phase 8: Commit and Document (10 min)

```bash
git add lib/pubid_new/nist/parser.rb
git commit -m "feat(nist): fix remaining SP and IR edge cases for 99.86%+

Session 197 enhancements:
- Add standalone trailing digit as volume indicator
- Allow lowercase letter suffix in numbers
- Add full month names to edition patterns
- Fix MR format supplement+revision
- Investigate SP version pattern duplicates

Result: 19,786 → 19,799+/19,827 (99.79% → 99.86%+)"
```

---

## Critical Reminders

1. **Test preprocessed vs original:** Understand fixture format
2. **Incremental changes:** Test after each phase
3. **Data quality vs parser:** Distinguish real failures from duplicates
4. **Semantic correctness:** Maintain dot=part, underscore=edition

---

## Files to Modify

- `lib/pubid_new/nist/parser.rb` - Lines 252-256 (suffix), 320-352 (edition), 372-377 (volume), 536-546 (MR)

---

## Expected Outcome

**Minimum:** 99.82% (19,791/19,827) - +5 identifiers
**Target:** 99.86% (19,799/19,827) - +13 identifiers
**Stretch:** 99.91%+ (19,810+/19,827) - +24 identifiers

---

**Created:** 2025-12-24
**Priority:** HIGH - User requested edge case fixes
**Estimated Time:** 60-90 minutes