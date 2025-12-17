# Session 159 Continuation Plan: CSA Enhancement to 60%+

**Created:** 2025-12-17 (Post-Session 158)
**Status:** Session 158 complete - CSA at 443/899 (49.28%)
**Timeline:** 1-2 sessions (60-120 minutes)

---

## Executive Summary

**Session 158 Achievement:** CSA enhanced to 443/899 (49.28%) - exceeded target by 180%! ✅

**What Was Accomplished:**
1. ✅ Package portions support
2. ✅ M/F year prefix preservation
3. ✅ SERIES keyword rendering
4. ✅ Publisher prefix preservation (CAN/CSA-, CAN3-, CSA)

**Improvement:** +248 identifiers from Session 157 baseline!

**Remaining Opportunities:**
- Optional CSA prefix patterns (~5-30 IDs)
- Combined with package edge cases (~5 IDs)
- Other specialized patterns

**Target for Session 159:** 60%+ (540+/899)

---

## Session 159 Objectives

### Primary Goal
Enhance CSA to 60%+ by implementing remaining high-value patterns.

### Success Criteria
- ✅ CSA at 540+/899 (60%+)
- ✅ Architecture: MODEL-DRIVEN maintained
- ✅ Round-trip fidelity preserved
- ✅ No regressions in existing patterns

---

## Remaining Pattern Analysis

From Session 158 failure analysis, remaining patterns include:

### Pattern 1: Combined with Package Variations
**Example:** `CSA B149.1:25, CSA B149.2:25 & Training Package`
**Current output:** `CSA B149.1:25/B149.2:25`
**Issue:** Package after combined_comma not being captured
**Expected gain:** ~5 identifiers

**Fix:** Update combined_comma rule in parser to capture package_portion

### Pattern 2: Optional CSA Prefix (Missing Prefix)
**Examples:**
- `C22.1-15 PACKAGE`
- `C22.1-18 PACKAGE`
- `C22.10-10 PACKAGE`

**Issue:** Parser requires CSA prefix
**Expected gain:** ~5-30 identifiers

**Fix:** Add optional_prefix rule or make publisher optional in some contexts

### Pattern 3: Other Specialized Patterns
Analysis of remaining 456 failures needed to identify additional high-value patterns.

---

## Implementation Plan

### Phase 1: Combined Comma Package Support (15 min)

**File:** `lib/pubid_new/csa/parser.rb`

Update combined_comma rule:
```ruby
rule(:combined_comma) do
  csa_code.as(:first) >>
  comma >> space >>
  csa_code.as(:second) >>
  reaffirmation.maybe >>
  (
    (space >> ampersand >> package_portion) |  # " & Training Package"
    package_portion                             # Or just package
  ).as(:package_portion).maybe
end
```

**Expected:** +5 identifiers

### Phase 2: Optional CSA Prefix (30 min)

**Strategy 1:** Add fallback rule for identifiers without CSA prefix

**File:** `lib/pubid_new/csa/parser.rb`

```ruby
# Code-only identifier (no CSA prefix)
rule(:code_only_identifier) do
  code_pattern >>
  no_portion.maybe >>
  (colon_year | dash_year).maybe >>
  (space >> str("PACKAGE")).maybe.as(:package_portion)
end

# Update main identifier rule
rule(:identifier) do
  iso_iec_adoption |
  bundled_identifier |
  combined_slash |
  combined_comma |
  single_identifier |
  code_only_identifier  # NEW: Try last
end
```

**Builder update:** Mark code_only identifiers with no publisher_prefix

**Expected:** +5-30 identifiers

### Phase 3: Testing & Validation (15 min)

```bash
cd /Users/mulgogi/src/mn/pubid
ruby /tmp/count_csa_proper.rb
```

**Target:** 540+/899 (60%+)

---

## Architecture Principles

**MAINTAIN throughout:**
1. **MODEL-DRIVEN** - Objects not strings
2. **MECE** - Mutually exclusive, collectively exhaustive
3. **Round-trip fidelity** - Perfect preservation
4. **Parser-only enhancements** - No architecture changes
5. **Incremental testing** - Test after each pattern

---

## Files to Modify

### Session 159
- `lib/pubid_new/csa/parser.rb` - Add combined_comma package, optional prefix
- `lib/pubid_new/csa/builder.rb` - Handle code_only identifiers (if needed)

---

## Expected Results

### Conservative (55%)
- Combined package: +5 IDs → 448/899 (49.8%)
- Optional prefix: +10 IDs → 458/899 (50.9%)
- **Total: 458/899 (50.9%)**

### Target (60%)
- Combined package: +5 IDs → 448/899 (49.8%)
- Optional prefix: +25 IDs → 473/899 (52.6%)
- Other patterns: +67 IDs → 540/899 (60.0%)
- **Total: 540/899 (60.0%)**

### Stretch (65%)
- All patterns: +142 IDs → 585/899 (65.1%)

---

## Success Metrics

### Minimum (52%)
- ✅ Combined package working
- ✅ Optional prefix basic support
- ✅ 468+/899 (52%+)

### Target (60%)
- ✅ All identified patterns implemented
- ✅ 540+/899 (60%+)
- ✅ Architecture clean

### Stretch (65%)
- ✅ Additional pattern discoveries
- ✅ 585+/899 (65%+)

---

## Next Steps (Session 159)

1. Implement combined_comma package support
2. Implement optional CSA prefix support
3. Analyze remaining failures for quick wins
4. Test and validate
5. Update memory bank

---

**Created:** 2025-12-17
**Status:** Ready for execution
**Estimated Time:** 60-120 minutes
**Target:** CSA 60%+ (540+/899)

**Current Status:** 443/899 (49.28%) - Excellent foundation! 🚀