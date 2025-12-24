# Session 196 Continuation Prompt: Fix 9 Remaining NIST SP Patterns

**Status:** Ready to fix remaining patterns
**Current:** 19,781/19,827 (99.77%)
**Target:** 19,790+/19,827 (99.81%+)
**Timeline:** 60-90 minutes

---

## Quick Start

Session 195 successfully fixed 1/10 patterns (`260-126rev2013`). The remaining 9 patterns have correct preprocessing but need parser rule enhancements.

**Read first:** [`docs/SESSION-196-CONTINUATION-PLAN.md`](SESSION-196-CONTINUATION-PLAN.md)

---

## Step 1: Debug Current Parser Behavior (15 min)

Identify exact failure points for each preprocessed pattern:

```bash
cd /Users/mulgogi/src/mn/pubid && bundle exec ruby -e '
require "./lib/pubid_new/nist/parser"

patterns = {
  "NIST SP 800-56a r" => "standalone r after letter",
  "NIST SP 800-181 r1 es" => "r1 + language code",
  "NIST SP 800-27 r" => "standalone r",
  "NIST SP 500-268 v1.1" => "version with dots",
  "NIST SP 800-63 v1.0.1" => "three-part version"
}

parser = PubidNew::Nist::Parser.new
puts "Testing preprocessed patterns:\n\n"
patterns.each do |input, desc|
  begin
    result = parser.parse(input)
    puts "✓ #{desc}: #{input}"
  rescue Parslet::ParseFailed => e
    puts "✗ #{desc}: #{input}"
    puts "  #{e.message[0..80]}"
  end
  puts
end
'
```

**Document which patterns actually fail vs work.**

---

## Step 2: Fix Standalone 'r' Revision (15 min)

**Issue:** Revision rule requires digits/letters, doesn't accept standalone 'r'.

**File:** `lib/pubid_new/nist/parser.rb` around line 383

**Current problem:** Rule always expects content after 'r':
```ruby
((str(" r") | str("r")) >> (digits >> lower_letter.maybe | lower_letter.repeat(1)).as(:revision))
```

**Fix:** Add alternative for standalone 'r' at END of revision rule (after all other patterns):

```ruby
rule(:revision) do
  (
    # ... (keep all existing patterns)

    # Revision with digits/letters
    ((str(" rev ") | str("rev") | str(" r") | str("r") | str(" Rev. ") | str(" Revision (r)")) >>
      (digits >> lower_letter.maybe | lower_letter.repeat(1)).as(:revision)) |

    # NEW: Standalone 'r' without digits (MUST be LAST)
    (space >> str("r") >> (space | str_end)).as(:revision_standalone)
  )
end
```

**Note:** Use `str_end` or check for following space/end to avoid consuming 'r' from other patterns.

**Test:**
```bash
bundle exec ruby -e '
require "./lib/pubid_new/nist/parser"
parser = PubidNew::Nist::Parser.new
["NIST SP 800-56a r", "NIST SP 800-27 r"].each do |input|
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

## Step 3: Fix Revision + Language Code (10 min)

**Issue:** Language code not matching after revision.

**File:** `lib/pubid_new/nist/parser.rb` around line 163

**Test if language_code matches "es"/"pt":**
```bash
bundle exec ruby -e '
require "./lib/pubid_new/nist/parser"
parser = PubidNew::Nist::Parser.new

# Test if "es" and "pt" are recognized
test = "NIST SP 800-181 r1 es"
begin
  parser.parse(test)
  puts "✓ Parses: #{test}"
rescue => e
  puts "✗ Fails: #{test}"
  puts "  Might need to enhance language_code rule"
end
'
```

**If failing, the issue is that "es" and "pt" are only in the alternatives, not the primary pattern.**

**Current rule:**
```ruby
rule(:language_code) do
  (str("es") | str("pt") | str("chi") | str("viet") | str("port") | str("esp") |
   match("[a-z]").repeat(2, 4)).as(:translation)
end
```

This should work! If not, check if revision rule is consuming the space before "es".

**Alternative fix:** Make sure revision doesn't consume trailing space:
```ruby
# In revision rule, after "r1", don't consume following space
```

---

## Step 4: Verify Version Patterns Work (5 min)

Test if version patterns already work (they should based on Session 195 testing):

```bash
bundle exec ruby -e '
require "./lib/pubid_new/nist/parser"
parser = PubidNew::Nist::Parser.new

versions = [
  "NIST SP 500-268 v1.1",
  "NIST SP 800-63 v1.0.1"
]

versions.each do |input|
  begin
    parser.parse(input)
    puts "✓ #{input}"
  rescue
    puts "✗ #{input}"
  end
end
'
```

**If these work, no changes needed for patterns 1-3, 5-6!**

---

## Step 5: Run Full Classification (5 min)

```bash
cd /Users/mulgogi/src/mn/pubid/spec/fixtures/nist && ruby ../run_classify.rb nist
```

**Check results:**
```bash
cat fail/sp.txt | wc -l
cat fail/sp.txt  # See which patterns still fail
```

---

## Step 6: Iterate if Needed (20 min buffer)

If patterns still fail:
1. Check parser error messages
2. Enhance specific rules
3. Test incrementally
4. Re-run classification

---

## Step 7: Commit (5 min)

```bash
cd /Users/mulgogi/src/mn/pubid
git add lib/pubid_new/nist/parser.rb
git commit -m "feat(nist): fix remaining 9 SP patterns to reach 99.8%+

Enhancements:
- Add standalone 'r' revision pattern (800-56ar, 800-27 r)
- Fix revision + language code parsing (r1es, r1pt)
- Verify version patterns with dots already working

Results: 19,781 → 19,790+ (99.77% → 99.81%+)"
```

---

## Success Criteria

- ✅ Minimum: 19,787/19,827 (99.80%) - +6 patterns
- ✅ Target: 19,790/19,827 (99.81%) - +9 patterns
- ✅ Stretch: 19,827/19,827 (100%) - All patterns

---

## Files to Modify

- `lib/pubid_new/nist/parser.rb` - revision rule (line ~383)

---

## Critical Notes

1. **Standalone 'r' MUST be last pattern** in revision rule
2. **Test after each change** - don't make multiple changes at once
3. **Version patterns may already work** - verify before changing

---

**Ready to execute!** Start with Step 1 to identify actual failure points.