# Session 198 Continuation Prompt: Fix 5 SP Version Patterns

**Read first:** [`docs/SESSION-198-CONTINUATION-PLAN.md`](SESSION-198-CONTINUATION-PLAN.md)

**Current status:** 19,786/19,827 (99.79%)
**Target:** 19,791/19,827 (99.82%) - Fix 5 SP patterns
**Timeline:** 30-45 minutes

---

## Quick Start

**Critical patterns to fix:**
```
NIST SP 500-268v1 1
NIST SP 500-270v1 1
NIST SP 500-280v2 1
NIST SP 800-63v1 0 1
NIST SP 800-63v1 0 2
```

---

## Implementation Steps

### Step 1: Verify Current Preprocessing (5 min)

Test that existing preprocessing is working:

```bash
cd /Users/mulgogi/src/mn/pubid
ruby -e '
inputs = ["NIST SP 500-268v1 1", "NIST SP 800-63v1 0 1"]
inputs.each do |input|
  cleaned = input.dup
  cleaned = cleaned.gsub(/([v\d]+[-A-Z]*)\s+(\d+)\s+(\d+)/, '\''\1.\2.\3'\'')
  cleaned = cleaned.gsub(/([v\d]+[-A-Z]*)\s+(\d+)/, '\''\1.\2'\'')
  puts "#{input} → #{cleaned}"
end
'
```

**Expected:** Should show conversion to `v1.1` and `v1.0.1` formats.

### Step 2: Add Preprocessing Fix (10 min)

**File:** `lib/pubid_new/nist/parser.rb`

**Location:** Around line 50-52, AFTER the dotted version fix at line 49-51, BEFORE the version space fix at lines 64-67

**Add these 2 lines:**
```ruby
# NEW: Separate version from number AND convert spaces to dots in one step
cleaned = cleaned.gsub(/(\d)(v\d+)\s+(\d+)$/, '\1 \2.\3')               # Two-part: "268v1 1" → "268 v1.1"
cleaned = cleaned.gsub(/(\d)(v\d+)\s+(\d+)\s+(\d+)$/, '\1 \2.\3.\4')    # Three-part: "63v1 0 1" → "63 v1.0.1"
```

**CRITICAL:** Place these BEFORE the existing version space fixes at lines 64-67 so they run first!

### Step 3: Test Target Patterns (5 min)

```bash
ruby -e '
require "./lib/pubid_new"
tests = ["NIST SP 500-268v1 1", "NIST SP 800-63v1 0 1"]
tests.each { |t| puts "✓ #{t} → #{PubidNew::Nist.parse(t).to_s}" }
'
```

**Expected:** Both should parse successfully.

### Step 4: Run Full Classification (5 min)

```bash
cd /Users/mulgogi/src/mn/pubid/spec/fixtures/nist
ruby ../run_classify.rb nist | tail -5
```

**Expected:**
- Pass: 19,791/19,827 (99.82%)
- Gain: +5 identifiers
- Zero regressions

### Step 5: Commit (5 min)

```bash
cd /Users/mulgogi/src/mn/pubid
git add lib/pubid_new/nist/parser.rb
git commit -m "feat(nist): fix 5 SP version patterns for 99.82%

Added preprocessing to separate version indicators from numbers and
convert spaces to dots in a single step. This ensures patterns like
'500-268v1 1' are normalized to '500-268 v1.1' before the generic
version space processing runs.

Fixed patterns:
- NIST SP 500-268v1 1
- NIST SP 500-270v1 1
- NIST SP 500-280v2 1
- NIST SP 800-63v1 0 1
- NIST SP 800-63v1 0 2

Result: 19,786 → 19,791/19,827 (99.79% → 99.82%)"
```

---

## Success Criteria

- ✅ All 5 SP patterns parsing
- ✅ +5 identifiers gained
- ✅ Zero regressions (19,786+ baseline maintained)
- ✅ NIST at 99.82%

---

## If Issues Occur

**Pattern still failing:**
- Check that preprocessing runs BEFORE lines 64-67
- Test the regex directly with ruby -e
- Ensure the $ anchor is present to match end of string

**Regressions detected:**
- Revert the change immediately
- Analyze which patterns broke
- Adjust regex to be more specific

---

**Ready to execute!** Follow steps 1-5 systematically.
