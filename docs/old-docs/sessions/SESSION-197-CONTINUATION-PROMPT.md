# Session 197 Continuation Prompt: Fix Remaining SP and IR Edge Cases

**Status:** Ready to fix remaining edge cases
**Current:** 19,786/19,827 (99.79%)
**Target:** 19,799+/19,827 (99.86%+)
**Timeline:** 60-90 minutes

---

## Quick Start

**Read first:** [`docs/SESSION-197-CONTINUATION-PLAN.md`](SESSION-197-CONTINUATION-PLAN.md)

**Current failures:**
- 8 SP patterns (5 might be fixture duplicates)
- 5+ IR patterns (trailing digits, lowercase suffix, month format)
- Other series (FIPS month, CIRC)

---

## Step 1: Investigate SP "Failures" (15 min)

**Critical question:** Are the 5 SP version patterns actually failing or are they fixture duplicates?

```bash
cd /Users/mulgogi/src/mn/pubid/spec/fixtures/nist/identifiers/full

# Check if both formats exist
grep -c "500-268v1 1" sp.txt
grep -c "500-268 v1.1" sp.txt

# Find actual entries
grep "500-268" sp.txt | head -5
grep "800-63v" sp.txt | head -10
```

**Test directly with parser:**
```bash
bundle exec ruby -e '
require "./lib/pubid_new/nist"

# These should work after preprocessing
tests = [
  "NIST SP 500-268v1 1",
  "NIST SP 800-63v1 0 1"
]

tests.each do |input|
  begin
    result = PubidNew::Nist.parse(input)
    puts "✓ #{input} → #{result.to_s}"
  rescue => e
    puts "✗ #{input}: #{e.class}"
  end
end
'
```

**If duplicates exist:** These are data quality issues, can be ignored or normalized.

---

## Step 2: Fix IR Trailing Space+Digit (15 min)

**Pattern:** `NBS IR 80-2073 2` and `NBS IR 80-2073 3`

**File:** `lib/pubid_new/nist/parser.rb`

**Add at end of parts rule (before language_code at line 530):**

```ruby
rule(:trailing_digit) do
  # Standalone space + 1-2 digits at end - treat as volume
  (space >> digit.repeat(1, 2) >> any.absent?).as(:volume)
end

# In parts rule alternatives (line 521-531):
rule(:parts) do
  (
    new_stage |
    section | index | insert | appendix | pd_suffix |
    edition | revision |
    version | volume | part | update | addendum |
    supplement | errata | trailing_digit | language_code  # NEW: trailing_digit before language_code
  )
end
```

**Test:**
```bash
bundle exec ruby -e '
require "./lib/pubid_new/nist/parser"
parser = PubidNew::Nist::Parser.new
["NBS IR 80-2073 2", "NBS IR 80-2073 3"].each do |input|
  begin
    parser.parse(input)
    puts "✓ #{input}"
  rescue
    puts "✗ #{input}"
  end
end
'
```

**Expected: Both should pass.**

---

## Step 3: Fix IR Lowercase Suffix (10 min)

**Pattern:** `NIST IR 6529-a`

**File:** `lib/pubid_new/nist/parser.rb` around line 302-316

**Update second_number rule:**

```ruby
rule(:second_number) do
  (
    # CRPL range with underscore (e.g., "2_3-1A")
    (digits >> str("_") >> digits >> dash >> digits >> upper_letter.maybe) |
    # Letter followed by dash and digits (e.g., "m-5")
    (lower_letter >> dash >> digits) |
    # Number with pt suffix (e.g., "57pt1")
    (digits >> str("pt") >> digits) |
    # Special patterns like "NCNR", "PERMIS", "BFRL"
    str("NCNR") | str("PERMIS") | str("BFRL") |
    # Just capital letters (e.g., "A", "B")
    upper_letter.repeat(1, 3) |
    # NEW: Allow lowercase letter suffix after dash
    (digits >> match("[a-zA-Z]").maybe)  # Changed from digits_with_suffix to allow lowercase
  ).as(:second_number)
end
```

**Test:**
```bash
bundle exec ruby -e '
require "./lib/pubid_new/nist/parser"
parser = PubidNew::Nist::Parser.new
result = parser.parse("NIST IR 6529-a")
puts "✓ NIST IR 6529-a"
'
```

---

## Step 4: Add Full Month Names to Edition (10 min)

**Pattern:** `NBS CIRC 15-April1909`

**File:** `lib/pubid_new/nist/parser.rb` around line 338-343

**month_abbrev already has full names!** But edition rule needs enhancement:

```ruby
# In edition rule, after line 338, add:
# Edition with dash and full month name + year: -April1909, -June1908
(dash >> (
  str("January") | str("February") | str("March") | str("April") |
  str("May") | str("June") | str("July") | str("August") |
  str("September") | str("October") | str("November") | str("December")
).as(:edition_month) >> digits.as(:edition_year)) |
```

**Full edition rule update (lines 320-352):**

```ruby
rule(:edition) do
  (
    # Date format check (must come first to avoid conflict)
    (dash >> digits.as(:part) >> dash >> month_abbrev.as(:date_month) >>
      digits.as(:date_day) >> slash >> digits.as(:date_year)).absent? >>
    # Edition with complex revision patterns: r1a, r2b
    ((str("r") | str(" R")) >> match("[0-9]").repeat(1, 2).as(:edition) >> lower_letter.as(:edition_letter)) |
    # Edition with revision and year: rev2013, rev2020
    (str("rev") >> digits.as(:edition_year)) |
    # Edition with revision and date: e2revJune1908, e3revJan1925
    ((str("e") | str(" E")) >> match("[0-9]").repeat(1, 3).as(:edition) >>
     str("rev") >> match("[A-Za-z]").repeat(3, 9).as(:edition_month) >> digits.as(:edition_year)) |
    # Edition with year and month: e201801, e2018
    (str("e") >> match("[0-9]").repeat(4, 4).as(:edition_year) >> match("[0-9]").repeat(2, 2).as(:edition_month).maybe) |
    # Edition number with dash and year: e2-1915, e3-2020
    ((str("e") | str(" E")) >> match("[0-9]").repeat(1, 3).as(:edition) >> dash >> digits.as(:edition_year)) |
    # NEW: Edition with dash and FULL month name + year: -April1909, -June1908
    (dash >> (
      str("January") | str("February") | str("March") | str("April") |
      str("May") | str("June") | str("July") | str("August") |
      str("September") | str("October") | str("November") | str("December")
    ).as(:edition_month) >> digits.as(:edition_year)) |
    # Edition with dash and abbreviated month + year: -Jan2018, -June1908
    (dash >> (
      (match("[A-Za-z]").repeat(3, 9).as(:edition_month) >> digits.as(:edition_year)) |
     digits.as(:edition_year) |
      (match("[A-Za-z]").repeat(3, 3).as(:edition_month) >> match("[0-9]").repeat(2, 2).as(:edition_day) >>
        slash >> digits.as(:edition_year))
    )) |
    # Edition with e prefix and revision suffix: e2rev
    ((str("e") | str(" E")) >> match("[0-9]").repeat(1, 3).as(:edition) >> str("rev").as(:edition_has_rev).maybe) |
    # Edition with e prefix: e2, e3
    ((str("e") | str(" E")) >> match("[0-9]").repeat(1, 3).as(:edition)) |
    # Edition with revision and year: rev2013, rev2020
    (space.maybe >> str("rev") >> digits.as(:edition_year)) |
    # Revision-based edition: revJune1908, revJan1925
    (str("rev") >> match("[A-Za-z]").repeat(3, 9).as(:edition_month) >> digits.as(:edition_year))
  )
end
```

**Test:**
```bash
bundle exec ruby -e '
require "./lib/pubid_new/nist/parser"
parser = PubidNew::Nist::Parser.new
result = parser.parse("NBS CIRC 15-April1909")
puts "✓ NBS CIRC 15-April1909"
'
```

---

## Step 5: Fix MR Suprev Pattern (10 min)

**Pattern:** `NBS.CIRC.154suprev`

**Add preprocessing for MR format (line 107):**

```ruby
# After line 107 (after "Suppl" normalization):
# Fix MR supplement+revision: .154suprev → .154 suprev
cleaned = cleaned.gsub(/\.(\d+)(sup+rev)/, '.\1 \2')
```

**Test:**
```bash
bundle exec ruby -e '
require "./lib/pubid_new/nist/parser"
parser = PubidNew::Nist::Parser.new
result = parser.parse("NBS.CIRC.154suprev")
puts "✓ NBS.CIRC.154suprev"
'
```

---

## Step 6: Run Full Classification (5 min)

```bash
cd /Users/mulgogi/src/mn/pubid/spec/fixtures/nist && ruby ../run_classify.rb nist
```

**Check results:**
```bash
cat fail/sp.txt | wc -l  # Should be 0-3
cat fail/unknown.txt | grep "IR" | wc -l  # Should be 0-2
```

---

## Step 7: Commit (5 min)

```bash
cd /Users/mulgogi/src/mn/pubid
git add lib/pubid_new/nist/parser.rb
git commit -m "feat(nist): fix remaining SP and IR edge cases for 99.86%+

Enhancements:
- Add trailing_digit rule for space+digit at end (IR patterns)
- Allow lowercase letter suffix in second_number (6529-a)
- Add full month names to edition rule (April1909)
- Fix MR format supplement+revision preprocessing (suprev)

Results: 19,786 → 19,799+/19,827 (99.79% → 99.86%+)"
```

---

## Success Criteria

- ✅ Minimum: 19,791/19,827 (99.82%) - +5 identifiers
- ✅ Target: 19,799/19,827 (99.86%) - +13 identifiers
- ✅ Stretch: 19,810+/19,827 (99.91%+) - +24 identifiers

---

## Files to Modify

- `lib/pubid_new/nist/parser.rb` - Lines 107 (preprocessing), 302-316 (second_number), 320-352 (edition), 521-531 (parts/trailing_digit)

---

## Critical Notes

1. **SP patterns may be duplicates** - investigate fixture data first
2. **Test after each change** - don't combine multiple fixes
3. **Maintain semantics** - dot=part, underscore=edition

---

**Ready to execute!** Start with Step 1 to investigate SP patterns.