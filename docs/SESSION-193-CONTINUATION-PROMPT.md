# Session 193 Continuation Prompt: NIST Semantic Corrections

**Context:** Session 192 achieved 90.1% but with semantically WRONG implementation. Must correct before proceeding.

**Critical Issue:** Dot and underscore were preprocessed incorrectly, treating them as number separators instead of their true semantic meaning (part separator and edition separator).

---

## What Was Wrong (Session 192)

**Incorrect preprocessing added:**
```ruby
# Line 93-94: WRONG - converts dots to underscores
cleaned = cleaned.gsub(/(?<!v)(?<![IVX]-)(\d{3,})\.(\d{1,4})(?=\s|$)/, '\1_\2')
```

**This created wrong semantics:**
- `NIST SP 984.4` → `984_4` (single number) ❌ WRONG
- Should be: number=984, part=4 ✅ CORRECT

- `NIST.TN.1648_2009` → `1648_2009` (single number) ❌ WRONG  
- Should be: number=1648, edition=2009 ✅ CORRECT

---

## What Needs to Be Done (Session 193)

**READ FIRST:**
- [`docs/SESSION-193-CONTINUATION-PLAN.md`](docs/SESSION-193-CONTINUATION-PLAN.md:1) - Complete implementation plan

**Current Status:** 82/91 (90.1%) with wrong semantics
**Task:** Fix semantics, maintain 90.1%
**Timeline:** 90 minutes

---

## Session 193 Tasks (90 min)

### Phase 1: Revert Incorrect Preprocessing (15 min)

**File:** [`lib/pubid_new/nist/parser.rb`](lib/pubid_new/nist/parser.rb:93)

**Remove lines 93-94:**
```ruby
# DELETE THIS:
# cleaned = cleaned.gsub(/(?<!v)(?<![IVX]-)(\d{3,})\.(\d{1,4})(?=\s|$)/, '\1_\2')
```

**Keep line 240** (underscore in first_number) - this is correct for MR edition

### Phase 2: Add Dot as Part Separator (30 min)

**File:** [`lib/pubid_new/nist/parser.rb`](lib/pubid_new/nist/parser.rb:332)

**Update `report_number` rule:**
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

### Phase 3: Add Underscore as Edition Separator (30 min)

**File:** [`lib/pubid_new/nist/parser.rb`](lib/pubid_new/nist/parser.rb:496)

**Update `mr_identifier` rule:**
```ruby
rule(:mr_identifier) do
  hash_prefix.maybe >>
  publisher >> dot >>
  simple_series >> dot >>
  report_number >>
  # Edition with underscore separator (MR format: 1648_2009)
  (str("_") >> digits.as(:edition_year)).maybe >>
  (dot >> (digits | upper_letter)).repeat(0, 3) >>
  (dash >> str("upd") >> digits.maybe).maybe >>
  parts.repeat >> draft.maybe
end
```

### Phase 4: Test Semantic Correctness (15 min)

```bash
bundle exec ruby -e "
require_relative 'lib/pubid_new/nist/parser'
require_relative 'lib/pubid_new/nist/builder'
require_relative 'lib/pubid_new/nist/scheme'

['NIST SP 984.4', 'NIST.TN.1648_2009'].each do |test|
  begin
    parsed = PubidNew::Nist::Parser.parse(test)
    builder = PubidNew::Nist::Builder.new(PubidNew::Nist::Scheme)
    id = builder.build(parsed)
    
    puts \"✅ #{test}\"
    puts \"   Number: #{id.number.first_number rescue 'N/A'}\"
    puts \"   Part: #{id.number.second_number rescue 'N/A'}\"
    puts \"   Edition: #{id.edition rescue 'N/A'}\"
  rescue => e
    puts \"❌ #{test} - #{e.message.split(\"\n\").first}\"
  end
end
"

bundle exec ruby test_nist_todo.rb 2>&1 | grep "RESULTS:" -A 5
```

---

## Success Criteria

**Minimum:**
- ✅ Dot preprocessing reverted
- ✅ Dot parses as part separator (984.4 → part=4)
- ✅ Underscore parses as edition (1648_2009 → edition=2009)
- ✅ 82/91 (90.1%) maintained with correct semantics

**Target:**
- ✅ All tests passing with semantic validation
- ✅ Ready for Session 194 edge cases

---

## Critical Reminders

**Architecture principles:**
1. **Semantic correctness over test count** - Wrong semantics is worse than failing tests
2. **Part vs Edition distinction** - These are different components with different meanings
3. **FORMAT vs SEMANTICS** - Preprocessing normalizes format, Parser captures semantics

**From Session 192 learning:**
- Dot (`.`) = part separator in NIST (like ISO's dash)
- Underscore (`_`) = edition separator in MR format
- These are NOT interchangeable!

---

## Files to Modify

- `lib/pubid_new/nist/parser.rb` - Lines 93-94 (remove), 332 (update), 496 (update)

---

**Status:** Session 192 complete but needs correction
**Priority:** Semantic correctness CRITICAL
**Architecture:** Must maintain MODEL-DRIVEN, MECE, Three-layer

Let's get NIST semantically correct! 📐
