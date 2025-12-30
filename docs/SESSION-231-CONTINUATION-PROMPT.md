# Session 231 Quick Start: CSA Parser Enhancement

**Read Plan First:** [`docs/SESSION-231-CONTINUATION-PLAN.md`](SESSION-231-CONTINUATION-PLAN.md:1)

---

## Pre-Session Checklist

✅ Read comprehensive plan (SESSION-231-CONTINUATION-PLAN.md)
✅ Review Session 230 results (271/367, 73.8%)
✅ Understand remaining 96 failures (6 categories)

---

## Session 231 Objective

Implement medium-impact parser/builder fixes for 82%+ pass rate in 90 minutes.

**Phase:** Parser & Builder Enhancement (Continued)
**Session:** 231 of compressed roadmap

---

## Part A: NO. Number Year Separation (30 min)

**Current Problem:**
```ruby
# Wrong:
parsed.no_number  # => "286:23" (includes year!)
parsed.year       # => nil

# Correct:
parsed.no_number  # => "286"
parsed.year       # => "2023"
```

**Fix in:** `lib/pubid_new/csa/parser.rb` (lines ~60-65)

**Parser change:**
```ruby
rule(:no_number) do
  match("[0-9]").repeat(1) >>
  ((dash | dot) >> match("[0-9]").repeat(1) >> letter.maybe).repeat >>
  letter.repeat(2, 6).maybe >>  # Allow SP suffix
  # Capture year separately if present
  (
    (colon >> year_2digit.as(:no_year)) |
    (dash >> year_2digit.as(:no_year))
  ).maybe
end
```

**Builder change:** `lib/pubid_new/csa/builder.rb`
```ruby
# In build_single method, after NO. number handling:
if data[:no_year]
  year_str = data[:no_year].to_s
  identifier.year = "20#{year_str}"
  identifier.year_format = data[:colon_format] ? "colon" : "dash"
end
```

**Test:**
```bash
bundle exec rspec spec/pubid_new/csa/identifiers/standard_spec.rb -e "NO. 286:23"
```

**Expected:** +10 tests passing (cumulative: 281/367, 76.5%)

---

## Part B: Package Parser Patterns (40 min)

**Current Problem:** Parser fails on Package patterns with text like "Code & Handbook Package"

**Fix in:** `lib/pubid_new/csa/parser.rb` (lines ~100-115)

**Parser enhancement:**
```ruby
# Enhance package_portion to capture full text
rule(:package_portion) do
  space >>
  (
    # Match full package description text
    (package_keyword >>
     (
       (comma >> space >> package_keyword) |
       (space >> ampersand >> space >> package_keyword)
     ).repeat
    ) |
    # Or just "PACKAGE" suffix
    str("PACKAGE")
  ).as(:package_portion)
end
```

**Test:**
```bash
bundle exec rspec spec/pubid_new/csa/identifiers/package_spec.rb
```

**Expected:** +20 tests passing (cumulative: 301/367, 82.0%)

---

## Part C: Combined/Bundled Verification (20 min)

**Review:** Check existing builder routing works for edge cases

**Files to check:**
- `lib/pubid_new/csa/builder.rb` (build method, lines 11-29)

**Test:**
```bash
bundle exec rspec spec/pubid_new/csa/identifiers/bundled_spec.rb
bundle exec rspec spec/pubid_new/csa/identifiers/combined_spec.rb
```

**Expected:** Any additional fixes needed, verify routing

---

## Part D: Final Validation (5 min)

**Run full test suite:**
```bash
bundle exec rspec spec/pubid_new/csa/
```

**Expected Results:**
- **Before:** 271/367 (73.8%)
- **After:** 301/367 (82.0%)
- **Gain:** +30 tests (+8.2pp)

**Verify:**
- ✅ No regressions in passing tests
- ✅ Architecture integrity preserved
- ✅ MECE organization maintained

---

## Testing Strategy

**After each fix:**
1. Run affected spec file
2. Verify expected gain
3. Check no new failures
4. Commit if successful

**Incremental commits:**
- After Priority 4: "fix(csa): separate NO. number from year"
- After Priority 5: "fix(csa): enhance package parser patterns"
- After Priority 6: "fix(csa): verify combined/bundled routing"

---

## Critical Reminders

**Parser Principles:**
```ruby
# ✅ CORRECT: Capture semantics clearly
rule(:no_number) do
  digits >> (dash | dot >> digits).repeat >>
  (colon >> year_2digit.as(:no_year)).maybe
end

# ❌ WRONG: Capture everything together
rule(:no_number) do
  match("[^\\s]").repeat(1).as(:no_number)  # Too broad!
end
```

**Builder Principles:**
- Check for data presence before extraction
- Convert 2-digit years to 4-digit
- Set year_format appropriately
- Preserve MECE class selection

**Architecture:**
- ✅ MODEL-DRIVEN throughout
- ✅ Parser handles syntax only
- ✅ Builder handles transformation only
- ✅ Identifiers handle rendering only

---

## Expected Progress

| Priority | Tests | Cumulative | Pass Rate |
|----------|-------|------------|-----------|
| Baseline | 271 | 271/367 | 73.8% |
| Priority 4 (+10) | 281 | 281/367 | 76.5% |
| Priority 5 (+20) | 301 | 301/367 | 82.0% |
| Priority 6 (verify) | 301 | 301/367 | 82.0% |

**Target achieved:** 82.0% > 80% excellent ✅

---

## Next Session Preview

**Session 232** will focus on:
- Round-trip rendering polish
- Edge case cleanup
- Final documentation
- Target: 90%+ (330/367)

---

## Files to Read

**Before starting:**
1. `lib/pubid_new/csa/parser.rb` - Understand NO. and package parsing
2. `lib/pubid_new/csa/builder.rb` - Review class selection logic
3. `spec/pubid_new/csa/identifiers/standard_spec.rb` - See NO. tests

---

**Created:** 2025-12-30
**Timeline:** 90 minutes
**Phase:** Medium-impact fixes
**Target:** 82.0% (301/367 tests)

**Ready to continue CSA enhancement!** 🚀