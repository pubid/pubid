# Session 186+ Continuation Plan: NIST V2 Complete Pattern Implementation

**Created:** 2025-12-22 (Post-Session 185)
**Status:** Session 185 complete - 19/91 patterns (20.9%)
**Timeline:** COMPRESSED - Complete ALL 72 remaining patterns in 3-4 sessions (6-8 hours)
**Priority:** HIGH - User requires ALL TODO patterns working

---

## Executive Summary

**Current Progress:** 19/91 (20.9%)
**Remaining:** 72 patterns (79.1%)
**Target:** 91/91 (100%)

**Session 185 Achievements:**
- ✅ Version rule enhanced (ver2, ver1 working)
- ✅ NIST LCIRC, NBS RPT series added
- ✅ Report number patterns (1088sp, 4817-A)
- ✅ +7 patterns (+7.7pp improvement)

**Architectural Quality:** MODEL-DRIVEN, MECE, Three-layer separation maintained

---

## Critical Understanding: Complex Part Patterns

**"p1adde1"** = Part 1 + Addendum + Edition 1
- `p1` = part 1
- `add` = addendum indicator
- `e1` = edition 1

**"Pt3r1"** = Part 3 + Revision 1
- `Pt3` = Part 3
- `r1` = revision 1

These are COMPOUND patterns requiring parser to capture multiple components from single string.

---

## SESSION 186: Quick Wins Phase (120 min)

**Target:** 19/91 → 40/91 (44%) - Gain +21 patterns

### Part A: Dotted Versions - Distinguish from Volume (40 min)

**Issue:** Parser must distinguish `v1.1` (version) from `v1` (volume)

**Current volume rule:**
```ruby
rule(:volume) do
  (str("v") | str(" Vol. ")) >>
  (digits >> (str("a-l") | str("m-z")).maybe >> upper_letter.repeat(0, 2)).as(:volume)
end
```

**Current version rule:**
```ruby
rule(:version) do
  (str("ver") >> (digits >> (dot >> digits).repeat).as(:version)) |
  ((str(" Ver. ") | str(" Version ")) >> ...) |
  (str("v") >> (digits >> dot >> digits >> (dot >> digits).maybe).as(:version))
end
```

**Problem:** Both start with "v" + digits

**Solution:** In parts order, put version BEFORE volume:
```ruby
rule(:parts) do
  (
    new_stage |
    section | index | insert | appendix | pd_suffix |
    edition | revision |
    version |  # BEFORE volume!
    volume | part | update | addendum |
    supplement | errata | language_code
  )
end
```

**Expected gain:** +11 patterns (all dotted version patterns)

### Part B: Revision with Letter Patterns (25 min)

**Patterns:** `r1a`, `ra`

**Enhancement to revision rule:**
```ruby
rule(:revision) do
  (
    # Revision with year: rev2013
    (str("rev") >> digits.as(:revision_year)) |
    # Revision with optional digits AND optional letter: r1a, ra, r1
    ((str(" rev ") | str("rev") | str("r") | str(" Rev. ") | str(" Revision (r)")) >>
      (digits.maybe >> lower_letter.maybe).as(:revision))
  )
end
```

**Key:** Make digits optional with `.maybe`

**Expected gain:** +5 patterns

### Part C: Update Pattern Preprocessing (30 min)

**Patterns:** 13 patterns with `-upd`, `/upd`

**Issue:** Parser expects space before update, but data has `-upd` or `/upd` directly

**Current preprocessing (line 37):**
```ruby
cleaned = cleaned.gsub(/(\d+)-upd$/, '\1 -upd')
```

**Enhancement - Handle more cases:**
```ruby
# Fix update patterns: ensure space before -upd or /upd
cleaned = cleaned.gsub(/(\d+)-upd/, '\1 -upd')    # Not just at end
cleaned = cleaned.gsub(/(\d+)\/upd/, '\1 /upd')   # Slash variant
cleaned = cleaned.gsub(/([a-z]\d+)\/upd/, '\1 /upd')  # After revision: r1/upd

# Fix AMS series if needed
cleaned = cleaned.gsub(/\bAMS\b/, 'AMS') # Ensure AMS recognized
```

**Expected gain:** +13 patterns

### Part D: Test and Validate (25 min)

```bash
bundle exec ruby test_nist_todo.rb
```

**Expected:** 40/91 (44%)

---

## SESSION 187: Medium Priority Patterns (90 min)

**Target:** 40/91 → 55/91 (60%) - Gain +15 patterns

### Part A: Complex Part Patterns (40 min)

**Pattern 1: "p1adde1"** = part 1 addendum edition 1

**Enhancement to part rule:**
```ruby
rule(:part) do
  (str("pt") | str("p") | str("P") | str(" Part ")) >>
  (
    # Complex: p1adde1 (part 1 addendum edition 1)
    (digits.as(:part_number) >>
     str("add").as(:part_addendum) >>
     (str("e") >> digits.as(:part_edition)).maybe) |
    # Simple: pt3, p1, Part 1
    (digits.as(:part_number) >> (dash >> digits).maybe)
  )
end
```

**Pattern 2: "Pt3r1"** - Already handled by preprocessing (Session 185 line 26):
```ruby
cleaned = cleaned.gsub(/(\d)Pt(\d+)(r\d+)/, '\1 pt\2 \3')
```

**Expected gain:** +3 patterns

### Part B: Version+Edition Combinations (25 min)

**Patterns:** `ver2v1`, `ver1e2006`

**Already handled by preprocessing (Session 185 lines 30-31):**
```ruby
cleaned = cleaned.gsub(/ver(\d+)e(\d{4})/, 'ver\1 e\2')
cleaned = cleaned.gsub(/ver(\d+)v(\d+)/, 'ver\1 v\2')
```

**Test to confirm these work after Part A volume/version ordering fix**

**Expected gain:** +3 patterns (if not already working)

### Part C: Roman Numeral Patterns (15 min)

**Patterns:** `1011-I-2.0`, `1011-II-1.0`

**Already in first_number (line 175):**
```ruby
(digits >> dash >> (str("III") | str("II") | str("IV") | str("I") | str("V")...) >> dash >> digits)
```

**But preprocessing transforms spaces to dots (line 21):**
```ruby
cleaned = cleaned.gsub(/([-\d]+[IVX]+[-\d]+)\s+(\d+)/, '\1.\2')
```

**This should already work!** Test to confirm.

**Expected gain:** +2 patterns

### Part D: Volume Range Patterns (10 min)

**Patterns:** `v2a-l`, `v2m-z`

**Already in volume rule (line 269):**
```ruby
(digits >> (str("a-l") | str("m-z")).maybe >> upper_letter.repeat(0, 2))
```

**This should already work!** Test to confirm.

**Expected gain:** +2 patterns

---

## SESSION 188: Complex RPT/LCIRC Patterns (120 min)

**Target:** 55/91 → 75/91 (82%) - Gain +20 patterns

### Part A: Add AMS and VTS to Simple Series (10 min)

```ruby
rule(:simple_series) do
  (
    str("AMS") | str("VTS") |  # Add these NEW series
    str("BSS") | str("BMS") | str("BH") |
    # ... existing
  ).as(:series)
end
```

**Expected gain:** +3 patterns (NIST AMS, NIST.AMS, NIST.VTS)

### Part B: LCIRC Complex Patterns (40 min)

**Patterns:** `118supp3/1926`, `145r6/1925`, etc.

**Enhancement to supplement rule:**
```ruby
rule(:supplement) do
  (str("supp") | str("sup")) >>
  (
    # Supplement with number and slash-year: supp3/1926
    (digits.as(:supp_number) >> slash >> digits.as(:supp_year)).as(:supplement_slash_year) |
    # Existing patterns...
  ).maybe
end
```

**Revision with slash-year:**
```ruby
rule(:revision) do
  (
    # Revision with slash and year: r6/1925, r11/1925
    ((str("r") | str("rev")) >> digits.as(:revision) >> slash >> digits.as(:revision_year)) |
    # Existing patterns...
  )
end
```

**Expected gain:** +7 patterns

### Part C: RPT Special Patterns (50 min)

**Date range patterns:** `Apr-Jun1948`, `Jan-Mar1950`, etc.

**Special patterns:** `ADHOC`, `div9`

**Enhancement - Add special number patterns to first_number:**
```ruby
rule(:first_number) do
  (
    # Special text patterns
    str("ADHOC") | (str("div") >> digits) |
    # Date ranges: Apr-Jun1948, Jan-Mar1950
    (month_abbrev >> dash >> month_abbrev >> digits) |
    # Existing patterns...
  ).as(:first_number)
end
```

**Expected gain:** +15 patterns

### Part D: Test and Clean Up (20 min)

---

## SESSION 189: Final Patterns & Documentation (90 min)

**Target:** 75/91 → 91/91 (100%) - Complete ALL patterns

### Part A: Handle Remaining Edge Cases (40 min)

1. **Lowercase input:** Already handled by preprocessing (line 17-18)
2. **MR format variants:** Already handled by mr_identifier rule
3. **Special NIST patterns:** NISTPUB, CSWP edge cases
4. **Any remaining failures:** Systematic analysis and fixes

### Part B: Comprehensive Testing (30 min)

```bash
# Run full test suite
bundle exec ruby test_nist_todo.rb

# Test 4-format rendering
bundle exec rspec spec/pubid_new/nist/format_conversion_spec.rb

# Spot check critical patterns
bundle exec ruby -e "
require 'bundler/setup'
require_relative 'lib/pubid_new/nist'

# Test each pattern category
patterns = [
  'NIST SP 800-63v1.0.2',  # Dotted version
  'NIST SP 800-22r1a',     # Revision with letter
  'NIST IR 8170-upd',      # Update
  'NIST SP 1011-I-2.0',    # Roman numeral
  'NBS TN 467p1adde1',     # Complex part
  'NBS LCIRC 145r6/1925',  # LCIRC with revision/date
  'NBS RPT Apr-Jun1948'    # RPT date range
]

patterns.each do |p|
  begin
    result = PubidNew::Nist.parse(p)
    puts \"✅ #{p}\"
  rescue => e
    puts \"❌ #{p}: #{e.message[0..80]}\"
  end
end
"
```

### Part C: Update Official Documentation (20 min)

**Move to old-docs/:**
- docs/SESSION-185-CONTINUATION-PLAN.md (already superseded by this file)
- docs/SESSION-185-CONTINUATION-PROMPT.md

**Update README.adoc - Add NIST V2 section:**
```asciidoc
=== NIST (National Institute of Standards and Technology) - V2

**Status:** ✅ Complete - 91/91 TODO patterns (100%)

**Features:**
- 4 rendering formats: short, mr (machine-readable), long, abbrev
- Stage system: old-style (IPD), new-style (ipd)
- Translation normalization
- Complete pattern support:
  * Volume ranges (v2a-l, v2m-z)
  * Dotted versions (v1.0.2)
  * Roman numerals (1011-I-2.0)
  * Complex parts (p1adde1 = part 1 addendum edition 1)
  * Update patterns (-upd, /upd)
  * All series types (SP, FIPS, IR, HB, TN, GCR, CSWP, VTS, AMS, LCIRC, RPT, etc.)

**Example:**
[source,ruby]
----
require 'pubid_new/nist'

id = PubidNew::Nist.parse('NIST SP 800-63v1.0.2')
id.to_s(format: :short)  # => "NIST SP 800-63v1.0.2"
id.to_s(format: :mr)     # => "NIST.SP.800-63v1.0.2"
id.to_s(format: :long)   # => "NIST Special Publication 800-63 Version 1.0.2"
----
```

---

## Implementation Status Tracker

### Session 185: Foundation ✅
- [x] Version rule enhancement (ver without dots)
- [x] NIST LCIRC, NBS RPT series
- [x] Report number patterns (sp suffix, capital letters)
- [x] Preprocessing improvements
- **Result:** 19/91 (20.9%)

### Session 186: Quick Wins
- [ ] Dotted versions (v1.1, v1.0.2) - 11 patterns
- [ ] Revision letters (r1a, ra) - 5 patterns
- [ ] Update preprocessing enhancement - 13 patterns
- [ ] Test and validate
- **Target:** 40/91 (44%)

### Session 187: Medium Priority
- [ ] Complex part patterns (p1adde1, Pt3r1) - 3 patterns
- [ ] Version+edition (ver2v1, ver1e2006) - 3 patterns
- [ ] Roman numerals (1011-I-2.0) - 2 patterns
- [ ] Volume ranges (v2a-l, v2m-z) - 2 patterns
- [ ] Test residual patterns
- **Target:** 55/91 (60%)

### Session 188: Complex Patterns
- [ ] AMS, VTS series - 3 patterns
- [ ] LCIRC complex (supp3/1926, r6/1925) - 7 patterns
- [ ] RPT special (ADHOC, div9, date ranges) - 15 patterns
- [ ] Test and validate
- **Target:** 75/91 (82%)

### Session 189: Completion
- [ ] Handle remaining edge cases - 16 patterns
- [ ] Comprehensive testing
- [ ] Update official documentation
- [ ] Move old docs to old-docs/
- **Target:** 91/91 (100%)

---

## Architectural Principles (NEVER COMPROMISE)

1. **MODEL-DRIVEN** - All concepts as Lutaml::Model objects
2. **MECE** - Mutually exclusive, collectively exhaustive patterns
3. **Three-layer** - Parser/Builder/Identifier independence
4. **Pattern Priority** - Longest/most specific first
5. **Preprocessing** - Data quality fixes BEFORE parsing
6. **One Responsibility** - Each rule has single purpose
7. **Open/Closed** - Easy to extend without modifying existing
8. **Separation of Concerns** - Parser syntax only, Builder construction only

---

## Testing Strategy

**After each session:**
```bash
# 1. Run TODO test
bundle exec ruby test_nist_todo.rb

# 2. Run format conversion tests
bundle exec rspec spec/pubid_new/nist/format_conversion_spec.rb

# 3. Spot check critical patterns manually
```

**Regression prevention:**
- Test that previously passing patterns still pass
- Ensure no architectural compromises for test count
- Document any intentional behavior changes

---

## Success Criteria

### Minimum (80%)
- ✅ 73+/91 patterns passing
- ✅ All quick wins implemented
- ✅ Architecture clean

### Target (90%)
- ✅ 82+/91 patterns passing
- ✅ All medium priority patterns
- ✅ Comprehensive testing

### Stretch (100%)
- ✅ 91/91 patterns passing
- ✅ All TODO patterns working
- ✅ Production-ready quality
- ✅ Documentation complete

---

## Files to Modify

**Primary:**
- `lib/pubid_new/nist/parser.rb` - Parser enhancements
- `test_nist_todo.rb` - Testing script

**Secondary (if needed):**
- `lib/pubid_new/nist/builder.rb` - Component construction
- `lib/pubid_new/nist/identifiers/base.rb` - Identifier logic

**Documentation:**
- `README.adoc` - NIST V2 section
- Move completed plans to `docs/old-docs/`

---

**Created:** 2025-12-22
**Timeline:** Sessions 186-189 (6-8 hours compressed)
**Target:** 91/91 TODO patterns (100%)
**Status:** Ready for comprehensive implementation