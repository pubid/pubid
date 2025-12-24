# Session 198 Continuation Plan: Fix Remaining 5 SP Version Patterns

**Created:** 2025-12-24 (Post-Session 197)
**Status:** 19,786/19,827 (99.79%), 5 critical SP patterns to fix
**Target:** 19,791/19,827 (99.82%) minimum
**Timeline:** 30-45 minutes (focused fix)

---

## Current Status

**Session 197 Result:** All attempted fixes caused regressions due to duplicate preprocessing code. Baseline maintained at 99.79%.

**User Requirement:** Fix these 5 specific SP patterns:
```
NIST SP 500-268v1 1
NIST SP 500-270v1 1  
NIST SP 500-280v2 1
NIST SP 800-63v1 0 1
NIST SP 800-63v1 0 2
```

---

## Root Cause Analysis

**Existing Preprocessing (lines 66-67):**
```ruby
cleaned = cleaned.gsub(/([v\d]+[-A-Z]*)\s+(\d+)\s+(\d+)/, '\1.\2.\3')  # Three parts
cleaned = cleaned.gsub(/([v\d]+[-A-Z]*)\s+(\d+)/, '\1.\2')             # Two parts
```

**Why These Patterns Fail:**

The patterns like `500-268v1 1` match the regex `/([v\d]+[-A-Z]*)\s+(\d+)/` and become `500-268v1.1`, which should work. But they're still failing, which means:

1. **Order Issue:** The preprocessing happens AFTER other preprocessing that might interfere
2. **Pattern Issue:** The `v1` part might not be matching correctly with the preceding number
3. **Parser Issue:** The version rule might not accept these patterns even after normalization

**The Real Problem:** The pattern `/([v\d]+[-A-Z]*)\s+(\d+)/` matches `268v1 1` and converts it to `268v1.1`, but this creates `500-268v1.1` which might not be recognized by the version rule.

---

## Implementation Strategy

### Phase 1: Verify Preprocessing is Working (10 min)

**Test the actual preprocessing:**
```ruby
inputs = [
  "NIST SP 500-268v1 1",
  "NIST SP 800-63v1 0 1"
]

inputs.each do |input|
  cleaned = input.dup
  # Apply existing preprocessing
  cleaned = cleaned.gsub(/([v\d]+[-A-Z]*)\s+(\d+)\s+(\d+)/, '\1.\2.\3')
  cleaned = cleaned.gsub(/([v\d]+[-A-Z]*)\s+(\d+)/, '\1.\2')
  puts "#{input} → #{cleaned}"
end
```

**Expected output:**
```
NIST SP 500-268v1 1 → NIST SP 500-268v1.1
NIST SP 800-63v1 0 1 → NIST SP 800-63v1.0.1
```

**Then test if these parse:**
```ruby
["NIST SP 500-268v1.1", "NIST SP 800-63v1.0.1"].each do |test|
  result = PubidNew::Nist.parse(test)
  puts "✓ #{test}"
end
```

### Phase 2: Fix the Preprocessing Order (15 min)

**Problem:** The version preprocessing needs to happen BEFORE the number gets separated from the version indicator.

**Solution:** Add SPECIFIC preprocessing for version patterns attached to numbers:

```ruby
# NEW: Separate version from number BEFORE other preprocessing
# "268v1 1" → "268 v1 1" so that later "v1 1" → "v1.1" works correctly
cleaned = cleaned.gsub(/(\d)(v\d+)\s+(\d+)/, '\1 \2.\3')      # Two-part version
cleaned = cleaned.gsub(/(\d)(v\d+)\s+(\d+)\s+(\d+)/, '\1 \2.\3.\4')  # Three-part version
```

**Place this at line 50-52**, BEFORE the existing version preprocessing at lines 66-67.

### Phase 3: Test Without Regression (10 min)

**Critical:** Test that this doesn't break OTHER patterns.

```bash
# Test the 5 target patterns
ruby -e 'require "./lib/pubid_new"; ["NIST SP 500-268v1 1", "NIST SP 800-63v1 0 1"].each { |t| puts PubidNew::Nist.parse(t).to_s }'

# Run full classification to check for regressions
cd spec/fixtures/nist && ruby ../run_classify.rb nist
```

**Success Criteria:**
- 5 patterns now parsing: +5 identifiers
- Zero regressions: Still at 19,786+ passing
- Target: 19,791/19,827 (99.82%)

### Phase 4: Commit (5 min)

```bash
git add lib/pubid_new/nist/parser.rb
git commit -m "feat(nist): fix 5 SP version patterns for 99.82%

Added preprocessing to separate version indicators from numbers before
space-to-dot conversion. This allows patterns like '500-268v1 1' to be
properly normalized to '500-268 v1.1' and parse correctly.

Fixed patterns:
- NIST SP 500-268v1 1
- NIST SP 500-270v1 1
- NIST SP 500-280v2 1
- NIST SP 800-63v1 0 1
- NIST SP 800-63v1 0 2

Result: 19,786 → 19,791/19,827 (99.79% → 99.82%)"
```

---

## Critical Reminders

1. **Single focused change**: Only add the 2 new preprocessing lines
2. **Correct placement**: Must be BEFORE existing version preprocessing (line 50-52)
3. **Test incrementally**: Test after adding the lines, before committing
4. **No other changes**: Don't touch anything else to avoid regressions
5. **Verify gain**: Must see +5 identifiers with zero regressions

---

## Expected Outcome

**Minimum Success:**
- 19,791/19,827 (99.82%) - +5 identifiers
- Zero regressions
- All 5 SP patterns parsing

**Files Modified:**
- `lib/pubid_new/nist/parser.rb` - Add 2 preprocessing lines at line 50-52

---

**Created:** 2025-12-24
**Priority:** HIGH - User requested specific fix
**Estimated Time:** 30-45 minutes
