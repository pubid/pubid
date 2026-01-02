# Session 196 Continuation Plan: Fix Remaining 9 NIST SP Patterns

**Created:** 2025-12-24 (Post-Session 195)
**Status:** 1/10 patterns fixed, 9 remaining
**Current:** 19,781/19,827 (99.77%)
**Target:** 19,790/19,827 (99.81%) minimum, 19,827/19,827 (100%) stretch goal

---

## Current Status

**Session 195 Achievement:**
- ✅ Fixed `NIST SP 260-126rev2013` (+1 identifier)
- ⏳ Added preprocessing for 9 more patterns (not yet working)

**Remaining 9 Patterns:**
1. `NIST SP 500-268v1 1` - Two-part version with space
2. `NIST SP 500-270v1 1` - Same pattern
3. `NIST SP 500-280v2 1` - Same pattern
4. `NIST SP 800-56ar` - Letter suffix + standalone 'r'
5. `NIST SP 800-63v1 0 1` - Three-part version
6. `NIST SP 800-63v1 0 2` - Same pattern
7. `NIST SP 800-181r1es` - Revision + language code
8. `NIST SP 800-181r1pt` - Same pattern
9. `NIST SP 800-27 Revision (r)` - Verbose revision format

---

## Root Cause Analysis

**Problem:** Preprocessing is working, but parser rules are insufficient.

**Evidence from testing:**
```ruby
# These preprocessed strings SHOULD work but DON'T:
"NIST SP 500-268 v1.1"  # ✓ Works (verified)
"NIST SP 800-56a r"     # ✗ Fails
"NIST SP 800-63 v1.0.1" # ✓ Works (verified)
"NIST SP 800-181 r1 es" # ✗ Fails
"NIST SP 800-27 r"      # ✗ Fails
```

**Key findings:**
1. Version patterns with dots work (patterns 1-3, 5-6) ✓
2. Standalone 'r' revision fails (patterns 4, 9) ✗
3. Revision with language code fails (patterns 7-8) ✗

---

## Implementation Plan (60-90 minutes)

### Phase 1: Debug Actual Parser Behavior (15 min)

Test each preprocessed pattern directly to identify exact failure points:

```bash
bundle exec ruby -e '
require "./lib/pubid_new/nist/parser"

test_cases = {
  "NIST SP 800-56a r" => "standalone r",
  "NIST SP 800-181 r1 es" => "r1 + language",
  "NIST SP 800-27 r" => "standalone r"
}

parser = PubidNew::Nist::Parser.new
test_cases.each do |input, desc|
  begin
    result = parser.parse(input)
    puts "✓ #{desc}: #{input}"
  rescue Parslet::ParseFailed => e
    puts "✗ #{desc}: #{input}"
    puts "  Error: #{e.parse_failure_cause.ascii_tree}"
  end
end
'
```

### Phase 2: Fix Standalone 'r' Revision (15 min)

**Issue:** Revision rule doesn't accept standalone 'r' without digits.

**Current revision rule (line 383):**
```ruby
rule(:revision) do
  (
    # ... existing patterns
    ((str(" rev ") | str("rev") | str(" r") | str("r") | str(" Rev. ") | str(" Revision (r)")) >>
      (digits >> lower_letter.maybe | lower_letter.repeat(1)).as(:revision))
  )
end
```

**Problem:** Requires `digits` or `lower_letter.repeat(1)` - doesn't accept just 'r' alone!

**Fix:** Add pattern for standalone 'r':
```ruby
rule(:revision) do
  (
    # NEW: Month+year revision (longest match first)
    ((str("r") | str("rev")) >> space.maybe >> month_abbrev.as(:revision_month) >> digits.as(:revision_year)) |
    # Revision with slash and year
    (space.maybe >> (str("r") | str("rev")) >> digits.as(:revision) >> slash >> digits.as(:revision_year)) |
    # Revision with 4-digit year
    ((str(" r") | str("r")) >> space.maybe >> match("[0-9]").repeat(4, 4).as(:revision_year)) |
    # Revision with year after rev
    (str("rev") >> space.maybe >> digits.as(:revision_year)) |
    # Revision with digits/letters
    ((str(" rev ") | str("rev") | str(" r") | str("r") | str(" Rev. ") | str(" Revision (r)")) >>
      (digits >> lower_letter.maybe | lower_letter.repeat(1)).as(:revision)) |
    # NEW: Standalone 'r' (first revision)
    ((str(" r") | str("r")) >> space.absent?).as(:revision_standalone)
  )
end
```

**Expected gain:** +3 identifiers (patterns 4, 9, and one more)

### Phase 3: Fix Revision + Language Code (10 min)

**Issue:** Language code rule not accepting after revision.

**Current parts order (line 513):**
```ruby
rule(:parts) do
  (
    new_stage |
    section | index | insert | appendix | pd_suffix |
    edition | revision |
    version | volume | part | update | addendum |
    supplement | errata | language_code
  )
end
```

**Problem:** `language_code` is last, but it's being preprocessed to separate position.

**Test if language_code actually matches:**
```ruby
# Test pattern: "NIST SP 800-181 r1 es"
# After preprocessing, this should be parsed as:
# - number: 181
# - revision: r1
# - language_code: es
```

**If language_code doesn't match "es"/"pt", enhance rule (line 163):**
```ruby
rule(:language_code) do
  (str("es") | str("pt") | str("chi") | str("viet") | str("port") | str("esp") |
   str("en") | str("fr") | str("de") | str("ru") | str("ja") |  # Add common codes
   match("[a-z]").repeat(2, 4)).as(:translation)
end
```

**Expected gain:** +2 identifiers (patterns 7-8)

### Phase 4: Verify Version Patterns (10 min)

**Test directly:**
```bash
bundle exec ruby -e '
require "./lib/pubid_new/nist/parser"

test_cases = [
  "NIST SP 500-268 v1.1",
  "NIST SP 500-270 v1.1",
  "NIST SP 500-280 v2.1",
  "NIST SP 800-63 v1.0.1",
  "NIST SP 800-63 v1.0.2"
]

parser = PubidNew::Nist::Parser.new
test_cases.each do |input|
  begin
    result = parser.parse(input)
    puts "✓ #{input}"
  rescue => e
    puts "✗ #{input}: #{e.message[0..60]}"
  end
end
'
```

**If failing:** Version rule may not accept leading space. Check line 403:
```ruby
rule(:version) do
  (
    (space.maybe >> str("ver") >> space.maybe >> (digits >> (dot >> digits).repeat).as(:version)) |
    ((str(" Ver. ") | str(" Version ")) >> (digits >> dot >> digits >> (dot >> digits).maybe).as(:version)) |
    ((dash | space).maybe >> str("v") >> (digits >> dot >> digits >> (dot >> digits).maybe).as(:version))
  )
end
```

**Expected gain:** +4 identifiers (patterns 1-3, 5-6) if not already working

### Phase 5: Test and Validate (10 min)

```bash
cd spec/fixtures/nist && ruby ../run_classify.rb nist
cat fail/sp.txt | wc -l  # Should be 0-3
```

**Success criteria:**
- Minimum: 19,787+/19,827 (99.80%) - Fix 6+ patterns
- Target: 19,790+/19,827 (99.81%) - Fix 9 patterns
- Stretch: 19,827/19,827 (100%) - Fix all + any other failures

### Phase 6: Commit and Document (10 min)

```bash
git add lib/pubid_new/nist/parser.rb
git commit -m "feat(nist): fix remaining 9 SP patterns for 99.8%+

- Add standalone 'r' revision pattern
- Enhance language code matching after revision
- Verify version patterns with dots
- Accept leading space before version

Fixes:
- NIST SP 800-56ar (letter+r)
- NIST SP 800-181r1es/r1pt (revision+language)
- NIST SP 800-27 Revision (r) (verbose standalone)
- NIST SP 500-268v1 1 through 500-280v2 1 (version)
- NIST SP 800-63v1 0 1/v1 0 2 (three-part version)"
```

---

## Critical Reminders

1. **Session 193 semantics MUST be preserved:**
   - Dot = part separator
   - Underscore = edition separator

2. **Test incrementally:**
   - Fix one pattern at a time
   - Test after each change
   - Commit working changes

3. **Parser rule order matters:**
   - Longest match first
   - More specific before general
   - Test alternatives thoroughly

---

## Files to Modify

- `lib/pubid_new/nist/parser.rb` - Lines 383-398 (revision rule), 163-166 (language_code)

---

## Expected Outcome

**Minimum:** 99.80% (19,787/19,827) - +6 patterns fixed
**Target:** 99.81% (19,790/19,827) - +9 patterns fixed
**Stretch:** 100% (19,827/19,827) - All patterns fixed

---

**Created:** 2025-12-24
**Priority:** HIGH - User requested immediate fix
**Estimated Time:** 60-90 minutes compressed timeline