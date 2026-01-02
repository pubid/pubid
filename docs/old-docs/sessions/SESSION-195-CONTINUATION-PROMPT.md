# Session 195 Continuation Prompt: Fix Final 10 NIST SP Patterns

**Status:** Ready to implement fixes for 10 remaining SP patterns
**Current:** 19,780/19,827 (99.76%)
**Target:** 19,827/19,827 (100%) or 99.95%+

---

## Task Overview

Fix the final 10 NIST SP patterns in `spec/fixtures/nist/identifiers/fail/sp.txt`:

1. `NIST SP 260-126rev2013` - Rev with year → number 126, subseries 260, revision 2013
2-4. `NIST SP 500-268v1 1`, `500-270v1 1`, `500-280v2 1` - Version with spaces
5. `NIST SP 800-56ar` - number 56a (suffix), revision r
6-7. `NIST SP 800-63v1 0 1`, `800-63v1 0 2` - Three-part version
8-9. `NIST SP 800-181r1es`, `800-181r1pt` - Revision + language
10. `NIST SP 800-27 Revision (r)` - Verbose revision

---

## Implementation Steps

### Step 1: Debug Preprocessing (10 min)

Test what preprocessing actually produces:

```ruby
cd /Users/mulgogi/src/mn/pubid && ruby -e '
tests = [
  "NIST SP 260-126rev2013",
  "NIST SP 500-268v1 1",
  "NIST SP 800-56ar",
  "NIST SP 800-63v1 0 1",
  "NIST SP 800-181r1es"
]

tests.each do |test|
  cleaned = test.dup
  # Show what Parser.parse preprocessing does
  # ... (copy preprocessing logic from parser)
  puts "#{test} → #{cleaned}"
end
'
```

### Step 2: Fix Identified Gaps (30 min)

Based on debugging, enhance `lib/pubid_new/nist/parser.rb`:

**A. Fix suffix+revision pattern:**
```ruby
# Line ~213: Enhance number_suffix to NOT consume 'r' at end
# OR Line ~82: Add preprocessing: "56ar" → "56a r"
cleaned = cleaned.gsub(/(\d[a-z])(r\b)/, '\1 \2')
```

**B. Ensure multi-space version ordering:**
```ruby
# Lines 60-61: May need to run THREE-part BEFORE two-part
```

**C. Verify revision+language separation:**
```ruby
# Line 82: Check if "r1es" → "r1 es" actually runs
```

**D. Check space-before-version:**
```ruby
# After line 59: May need " v1 1" pattern too
cleaned = cleaned.gsub(/\s+(v\d+)\s+(\d+)\s+(\d+)/, ' \1.\2.\3')
```

### Step 3: Enhance Parser Rules if Needed (20 min)

If preprocessing works but parser doesn't match:

**A. Revision rule** (Line ~363):
```ruby
# Ensure handles standalone "r" and "rev" with space.maybe
((str(" r") | str("r")) >> space.maybe >> ...).as(:revision)
```

**B. Language_code after revision:**
```ruby
# Ensure revision can be followed by language
```

### Step 4: Test (10 min)

```bash
cd spec/fixtures/nist && ruby ../run_classify.rb nist
cat fail/sp.txt | wc -l  # Should be 0-2 lines
```

---

## Expected Outcome

**Minimum:** 99.95% (19,817/19,827) - Fix 7/10
**Target:** 100% (19,827/19,827) - Fix all 10

---

## Critical Reminders

1. **Session 193 semantics MUST be preserved:**
   - Dot = part separator
   - Underscore = edition separator

2. **Preprocessing runs BEFORE parsing**
   - Order matters!
   - Later gsub may undo earlier ones

3. **Test after EACH change**
   - Reclassify immediately
   - Verify no regressions

---

## Files to Modify

- `lib/pubid_new/nist/parser.rb` - Lines 27, 60-61, 82, 94-97, 213, 363

---

**Ready to implement!** Start with Step 1 debugging.