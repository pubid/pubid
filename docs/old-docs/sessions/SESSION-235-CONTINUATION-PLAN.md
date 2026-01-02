# Session 235 Continuation Plan: CSA Parser Enhancement for Baseline Recovery

**Created:** 2025-12-30 (Post-Session 234)
**Status:** 257/362 tests (71.0%)
**Target:** 267+/362 tests (73.8%+) - Baseline
**Gap:** +10 tests minimum
**Timeline:** COMPRESSED - 90-120 minutes

---

## Session 234 Summary

**Achievement:** Completed French F rendering pattern across ALL identifier classes

**Critical Discovery:** 105 failures are **parser failures**, not rendering issues
- CAN/CSA- with NO. notation: ~30 failures
- NO. with reaffirmation: ~10 failures
- CAN3- specific patterns: ~7 failures
- Bundled with CAN/CSA prefix: ~20 failures
- Combined patterns: ~15 failures
- Miscellaneous: ~23 failures

**Files Modified:**
- `lib/pubid_new/csa/identifiers/series.rb` - French F fix (architecturally correct)

---

## Implementation Strategy

### Priority Ranking (by test impact)

**Priority 1: CAN/CSA- with NO. Patterns** (~30 tests - HIGH IMPACT)
- Pattern: `CAN/CSA-C22.2 NO. 60079-11:14`
- Issue: Parser doesn't recognize CAN/CSA- prefix + NO. together
- Expected gain: +25-30 tests

**Priority 2: Bundled/Combined Type Classification** (~35 tests - HIGH IMPACT)
- Pattern: `CAN/CSA-B127.1:99 + B127.2:99 (R2014)` (Bundled)
- Pattern: `CAN/CSA-B138.1-17/CAN/CSA-B138.2-17 (R2022)` (Combined)
- Issue: Returns Standard instead of Bundled/Combined
- Expected gain: +30-35 tests

**Priority 3: NO. with Reaffirmation** (~10 tests - MEDIUM IMPACT)
- Pattern: `CSA C22.2 NO. 1-04 (R2009)`
- Issue: NO. normalization + reaffirmation combo fails
- Expected gain: +8-10 tests

**Priority 4: CAN3- Edge Cases** (~7 tests - LOW IMPACT)
- Pattern: `CAN3-B78.1-M83`
- Issue: Round-trip and year conversion issues
- Expected gain: +5-7 tests

---

## Session 235 Implementation Plan (90-120 min)

### Phase 1: Priority 1 - CAN/CSA- NO. Patterns (40 min)

**File:** `lib/pubid_new/csa/parser.rb`

**Problem:** Parser expects either CAN/CSA- OR NO., but not both together

**Solution:** Enhance SINGLE_IDENTIFIER rule to handle CAN/CSA- prefix before NO.

**Implementation:**
```ruby
# Around line 150-200 in parser.rb
rule(:canadian_prefix) do
  (str("CAN/CSA-") | str("CAN3-")).as(:publisher_prefix)
end

rule(:single_identifier) do
  (
    # CAN/CSA- or CAN3- prefix (optional)
    canadian_prefix.maybe >>
    # Publisher (CSA or empty for code-only)
    publisher.maybe >>
    # Code (including NO. patterns which get normalized)
    code >>
    # Rest of identifier (year, reaffirmation, etc.)
    year_portion.maybe >>
    reaffirmation_portion.maybe >>
    language_portion.maybe
  ).as(:single)
end
```

**Expected gain:** +25-30 tests

---

### Phase 2: Priority 2 - Type Classification Fix (30 min)

**File:** `lib/pubid_new/csa/builder.rb`

**Problem:** Builder doesn't detect bundled/combined when CAN/CSA- prefix present

**Solution:** Enhance type detection to check for separators BEFORE unwrapping prefix

**Implementation:**
```ruby
# In Builder.build method (around line 50-100)
def build(parsed_hash)
  # Check for bundled/combined FIRST (before prefix unwrapping)
  if parsed_hash[:bundled_items] || parsed_hash.to_s.include?(" + ")
    return build_bundled(parsed_hash)
  end

  if parsed_hash[:combined_items] || parsed_hash.to_s.include?("/")
    # But NOT if it's CAN/CSA- or ISO/IEC prefix
    unless parsed_hash[:publisher_prefix]&.match?(/CAN|ISO|IEC/)
      return build_combined(parsed_hash)
    end
  end

  # Then check for wrappers (CAN/CSA-, CAN3-, CSA ISO, etc.)
  # ... existing logic
end
```

**Expected gain:** +30-35 tests

---

### Phase 3: Priority 3 - NO. + Reaffirmation (20 min)

**File:** `lib/pubid_new/csa/parser.rb`

**Problem:** Reaffirmation portion not recognized after NO. normalization

**Solution:** Ensure reaffirmation_portion applies AFTER all code patterns

**Implementation:**
```ruby
# Check current reaffirmation_portion rule (around line 100-120)
rule(:reaffirmation_portion) do
  space.maybe >>
  str("(") >> str("R") >> year_digits.as(:reaffirmation) >> str(")")
end

# Ensure it's in the right place in identifier rule
rule(:identifier) do
  code >>
  year_portion.maybe >>
  reaffirmation_portion.maybe >>  # MUST be after year_portion
  language_portion.maybe
end
```

**Expected gain:** +8-10 tests

---

### Phase 4: Testing & Validation (20 min)

**After each phase:**
```bash
bundle exec rspec spec/pubid_new/csa/ --format progress 2>&1 | grep "examples,"
```

**Target progression:**
- After Phase 1: 282-287/362 (77.9-79.3%)
- After Phase 2: 312-322/362 (86.2-88.9%)
- After Phase 3: 320-332/362 (88.4-91.7%)

**Baseline target:** 267/362 (73.8%) should be exceeded after Phase 1

---

## Success Criteria

### Minimum Success (80%)
- ✅ Phase 1 complete (+25 tests)
- ✅ Baseline 73.8% exceeded
- ✅ 282+/362 tests (77.9%+)

### Target Success (85%)
- ✅ Phases 1-2 complete (+55 tests)
- ✅ 312+/362 tests (86.2%+)
- ✅ Clean architecture maintained

### Stretch Success (90%)
- ✅ All 3 phases complete (+65 tests)
- ✅ 320+/362 tests (88.4%+)
- ✅ Ready for 95%+ push

---

## Architecture Principles

**MAINTAIN throughout:**
1. **MODEL-DRIVEN** - Objects not strings
2. **MECE** - Mutually exclusive, collectively exhaustive
3. **Three-layer** - Parser/Builder/Identifier independence
4. **Parser-only** - Changes in parser.rb and builder.rb only
5. **No identifier changes** - Identifiers are already correct

**Pattern to follow:** Parser recognizes → Builder constructs → Identifier renders

---

## Risk Mitigation

**If Phase 1 doesn't work:**
- Check parser rule ordering (longest match first)
- Verify NO. normalization happens in preprocessing
- Test with simple `CAN/CSA-C22.2 NO. 60601-1:14` example

**If Phase 2 doesn't work:**
- Builder may need to check raw input string
- May need to detect bundled/combined in parser itself
- Consider adding bundled/combined flags in parse tree

**If stuck at <267 tests:**
- Document specific issues
- Mark as parser architectural work needed
- Move to documentation phase

---

## Files to Modify

1. `lib/pubid_new/csa/parser.rb` - Phases 1 & 3
2. `lib/pubid_new/csa/builder.rb` - Phase 2

**No changes to:**
- Identifier classes (already correct)
- Component classes (already correct)
- Test expectations (tests are correct)

---

## Next Session Preview

**Session 236:** Documentation & Memory Bank Update
- Archive SESSION-234-235 docs to old-docs/
- Update context.md with results
- Update README.adoc if baseline exceeded significantly

---

**Created:** 2025-12-30
**Sessions Covered:** 235
**Status:** Ready for execution
**Estimated Time:** 90-120 minutes (compressed)

**End Goal:** Reach 73.8%+ baseline with parser enhancements! 🎯