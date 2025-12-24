# Session 199 Continuation Prompt: Fix 31 FIPS Month-Year Patterns

**Read first:** [`docs/SESSION-199-CONTINUATION-PLAN.md`](SESSION-199-CONTINUATION-PLAN.md)

**Current status:** 19,791/19,827 (99.82%)
**Target:** 19,822/19,827 (99.98%) - Fix 31 FIPS patterns
**Timeline:** 60 minutes

---

## Quick Start

**Critical patterns to fix:**
```
NBS FIPS 107-Feb1985
NBS FIPS 114-Dec1985
NBS FIPS 115-Mar1985
NIST FIPS 150-Aug1988
NBS FIPS 11-1-Sep30/1977
NIST FIPS 54-1-Jan15/1991
```

**Root cause:** Parser edition rule doesn't handle dash-month-year format

---

## Implementation Steps

### Step 1: Locate Edition Rule (5 min)

**File:** `lib/pubid_new/nist/parser.rb`

Find the edition rule around line 337. Look for:
```ruby
rule(:edition) do
  (
    # Date format with dash-month-day-slash-year: "11-1-Sep30/1977"
```

### Step 2: Add Dash-Month-Year Variant (15 min)

**Insert BEFORE the existing dash-year variant at approximately line 337:**

```ruby
# NEW: Edition with dash-month-year (FIPS format): -Feb1985, -Aug1988, -Dec1985
# MUST be BEFORE dash-year to match month first (longest match principle)
(dash >> month_abbrev.as(:edition_month) >> digits.as(:edition_year)) |
```

**CRITICAL:** This line must come BEFORE the existing:
```ruby
# Edition with dash and year/month: -2018, -Jan2018, -June1908, -April1909
(dash >> (
```

**Why order matters:** Parslet uses longest match first. If dash-year comes before dash-month-year, it will consume the dash and fail on the month part.

### Step 3: Test Target Patterns (15 min)

```bash
cd /Users/mulgogi/src/mn/pubid
ruby -e '
require "./lib/pubid_new"
tests = [
  "NBS FIPS 107-Feb1985",
  "NBS FIPS 114-Dec1985",
  "NBS FIPS 115-Mar1985",
  "NIST FIPS 150-Aug1988",
  "NBS FIPS 11-1-Sep30/1977",
  "NIST FIPS 54-1-Jan15/1991"
]
tests.each { |t|
  begin
    result = PubidNew::Nist.parse(t)
    puts "✓ #{t} → #{result.to_s}"
  rescue => e
    puts "✗ #{t} → ERROR: #{e.message[0..80]}"
  end
}
'
```

**Expected:** All 6 parse successfully

### Step 4: Run Full Classification (15 min)

```bash
cd /Users/mulgogi/src/mn/pubid/spec/fixtures/nist
ruby ../run_classify.rb nist | tail -10
```

**Expected:**
- Pass: 19,822/19,827 (99.98%)
- Gain: +31 identifiers
- Zero regressions

### Step 5: Commit (10 min)

```bash
cd /Users/mulgogi/src/mn/pubid
git add lib/pubid_new/nist/parser.rb
git commit -m "feat(nist): fix 31 FIPS month-year patterns for 99.98%

Added dash-month-year edition variant to support FIPS date format
patterns like 'FIPS 107-Feb1985'. This variant must come before
dash-year in the edition rule to ensure longest match first.

Fixed patterns:
- NBS FIPS 107-Feb1985, 114-Dec1985, 115-Mar1985, 115-Sep1985
- NBS FIPS 116-Apr1985, 116-Sep1985, 123-Feb1986, 123-Sep1986
- NBS FIPS 130-Apr1986, 130-Dec1986, 130-May1986
- NBS FIPS 25-Jun1973, 33-May1974, 33-Oct1974
- NBS FIPS 82-Sep1980, 85-May1980, 85-Nov1980
- NBS FIPS 89-May1981, 90-Jul1983, 90-Sep1983
- NIST FIPS 150-Aug1988, 150-Nov1988
- Plus 9 more FIPS patterns

Special date formats also working:
- NBS FIPS 11-1-Sep30/1977 (part-month-day/year)
- NIST FIPS 54-1-Jan15/1991 (part-month-day/year)

Implementation:
- Line ~337: Added (dash >> month_abbrev >> digits) variant
- Placement: BEFORE existing dash-year to ensure longest match
- Uses existing month_abbrev rule (Jan-Dec)

Result: 19,791 → 19,822/19,827 (99.82% → 99.98%)"
```

---

## Success Criteria

- ✅ All 6 test patterns parsing
- ✅ +31 identifiers gained
- ✅ Zero regressions (19,791+ baseline maintained)
- ✅ NIST at 99.98%

---

## If Issues Occur

**Pattern still failing:**
- Verify dash-month-year comes BEFORE dash-year in edition rule
- Check month_abbrev rule includes all months (Jan-Dec)
- Test the pattern directly with a simple parse attempt

**Wrong output/regressions:**
- Revert the change immediately
- Check if placement is correct (must be before dash-year)
- Ensure no conflicts with other edition variants

**Only partial gain (+10-20 instead of +31):**
- Some patterns may have other issues (like part-month-day/year)
- Document actual gain and remaining patterns
- Consider those as separate fixes if needed

---

## Debugging Tips

**To see which variant is matching:**
```ruby
# Add to test script
result = PubidNew::Nist::Parser.parse("NBS FIPS 107-Feb1985")
pp result  # Shows parse tree with captured groups
```

**To test just the edition rule:**
```ruby
parser = PubidNew::Nist::Parser.new
result = parser.edition.parse("-Feb1985")
pp result  # Should show edition_month and edition_year
```

---

**Ready to execute!** Follow steps 1-5 systematically.