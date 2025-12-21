# Session 179+ Continuation Plan: Complete Remaining IEEE TODO Patterns

**Created:** 2025-12-21 (Post-Session 178)
**Status:** Session 178 complete - AIEE combined + SI/PSI verified
**Priority:** HIGH - Complete all remaining edge cases
**Timeline:** COMPRESSED - Complete in 3-4 sessions (6-8 hours)

---

## Executive Summary

**Session 178 Achievement:** AIEE combined identifiers + IEEE/ASTM SI/PSI verified (7 patterns) ✅

**Current Status:**
- **IEEE: 8,612/9,552 (90.16%)**
- **TODO Progress: 37/46 complete (80%)**
- **Remaining: 9 patterns** (complex edge cases)

**Goal:** Complete all 9 remaining TODO patterns to achieve 90.3-90.5% IEEE validation

---

## Remaining TODO Patterns Analysis

### Pattern Group 1: "Includes" Relationship (1 identifier)

**Line 7 & 48 (duplicate):**
```
IEEE Std 1003.5b-1996 (Includes IEEE Std 1003.5-1992)
```

**Pattern:** "Includes" relationship type
**Status:** Already implemented (Session 171) ✅
**Action:** Verify working, may just need fixture update

### Pattern Group 2: Combined Identifiers with Corrigendum (1 identifier)

**Line 12:**
```
IEEE Std 802.16e-2005 and IEEE Std 802.16-2004/Cor 1-2005 (Amendment and Corrigendum to IEEE Std 802.16-2004)
```

**Pattern:** "and"-combined identifier where one has corrigendum
**Challenge:** Parser needs to handle "and" with complex supplements
**Estimated gain:** +1 identifier

### Pattern Group 3: Complex Multi-Amendment Patterns (1 identifier)

**Line 17:**
```
IEEE Std 802.3bz-2016 (Amendment to IEEE Std 802.3-2015 as amended by IEEE Std 802.3bw-2015, IEEE Std 802.3by(TM)-2016, IEEE Std 802.3bq-2016, IEEE Std 802.3bp-2016, IEEE Std 802.3br-2016, and IEEE Std 802.3bn-2016)
```

**Pattern:** "as amended by" with 6 intermediate amendments
**Challenge:** Long list parsing
**Status:** Pattern 4 should handle this (Session 125)
**Action:** Verify and debug if needed

---

## Implementation Plan

### SESSION 179: Combined Identifier with Corrigendum (90 min)

**Objective:** Handle "X and Y/Cor" pattern where second identifier has supplement

#### Phase 1: Parser Enhancement (40 min)

Update `lib/pubid_new/ieee/parser.rb`:

```ruby
# Enhanced combined identifier rule
rule(:combined_identifier_with_supplements) do
  # First identifier (may have supplements)
  identifier.as(:first) >>
  # "and" separator
  space >> str("and") >> space >>
  # Second identifier (may have corrigendum or amendment)
  identifier.as(:second) >>
  # Optional shared parenthetical
  parenthetical.maybe
end
```

**Add to identifier rule** (try before generic patterns):
```ruby
rule(:identifier) do
  combined_identifier_with_supplements |
  # ... existing rules
end
```

#### Phase 2: Builder Enhancement (30 min)

Update `lib/pubid_new/ieee/builder.rb`:

```ruby
def build_combined_with_supplements(parsed)
  first_id = build_single_identifier(parsed[:first])
  second_id = build_single_identifier(parsed[:second])

  # Check if there's shared parenthetical relationship
  if parsed[:relationship_clause] || parsed[:parameters]
    # Apply relationship to combined identifier wrapper
  end

  Identifiers::DualPublished.new(
    first_identifier: first_id,
    second_identifier: second_id,
    separator: " and "
  )
end
```

#### Phase 3: Testing (20 min)

Test both patterns:
- Line 12: Amendment and Corrigendum combined
- Verify no regressions on existing combined patterns

**Expected gain:** +1 identifier (Line 12)

---

### SESSION 180: Complex Amendment Lists (60 min)

**Objective:** Debug and verify multi-amendment "as amended by" patterns

#### Phase 1: Verification (20 min)

Test Line 17 pattern:
```ruby
PubidNew::Ieee.parse("IEEE Std 802.3bz-2016 (Amendment to IEEE Std 802.3-2015 as amended by IEEE Std 802.3bw-2015, ...)")
```

**Expected:** Should already work with Pattern 4 (Session 125)

#### Phase 2: Debug if Needed (30 min)

If fails, enhance `as_amended_by_clause` rule:
```ruby
rule(:as_amended_by_clause) do
  str(" as amended by ") >>
  # Handle "IEEE Std" prefix OR "IEEE's" prefix
  (str("IEEE Std ") | str("IEEE's ")).maybe >>
  identifier_list.as(:amendments) >>
  # Handle "and its approved amendments" clause
  (str(" and") >> space >> str("its approved amendments")).maybe
end
```

#### Phase 3: Final Validation (10 min)

- Test Line 17
- Verify all Pattern 4 relationships still work

**Expected gain:** +1 identifier (Line 17)

---

### SESSION 181: Final Validation & Documentation (90 min)

**Objective:** Complete all remaining patterns, validate, and document

#### Phase 1: Pattern Verification (30 min)

Verify all patterns from TODO:
1. Lines 1-6: Already complete (data quality fixes)
2. Line 7: "Includes" relationship (verify)
3. Lines 8-11: Already complete (preprocessing)
4. Line 12: Combined with corrigendum (Session 179)
5. Lines 13-16: Already complete (preprocessing)
6. Line 17: Complex amendments (Session 180)
7. Lines 18-44: Already complete (various patterns)
8. Line 45: AIEE combined (Session 178)
9. Line 46-47: Analysis comments
10. Line 48: Duplicate of Line 7

#### Phase 2: Final Testing (30 min)

```bash
# Run full fixture classification
cd spec/fixtures && ruby run_classify.rb ieee

# Expected: 8,620-8,625/9,552 (90.3-90.5%)
```

#### Phase 3: Documentation Updates (30 min)

1. **README.adoc** - Add IEEE Pattern 4 & AIEE combined sections
2. **TODO.IEEE-MUST-DO.txt** - Mark all 46 lines as complete
3. **Create SESSION-179-SUMMARY.md** - Document final achievements
4. **Archive old docs** - Move session plans 171-179 to old-docs/

---

## Implementation Status Tracker

### Pattern Categories

| Category | Lines | Description | Status | Est. Gain |
|----------|-------|-------------|--------|-----------|
| **Data Quality** | 1-6, 20-24 | Space/typo fixes | ✅ Session 171 | - |
| **Preprocessing** | 8-11, 13-16, 32-42 | Format normalization | ✅ Sessions 173-174 | - |
| **AIEE Combined** | 45 | Nos X and Y pattern | ✅ Session 178 | +1 |
| **SI/PSI** | 25-31 | IEEE/ASTM standards | ✅ Session 178 | +6 |
| **Includes Relation** | 7, 48 | Already implemented | ⏳ Verify | 0 |
| **Combined w/ Supplement** | 12 | and with /Cor | ⏳ Session 179 | +1 |
| **Complex Amendments** | 17 | Multi-amendment list | ⏳ Session 180 | +1 |

**Total Remaining:** 2-3 patterns requiring work
**Total Expected Gain:** +2-3 identifiers (90.18-90.20%)

### Session Progress

| Session | Focus | Duration | Deliverables | Status |
|---------|-------|----------|--------------|--------|
| 177 | AIEE analysis | 60 min | Pattern documented | ✅ Complete |
| 178 | AIEE + SI/PSI | 60 min | 7 patterns done | ✅ Complete |
| 179 | Combined w/ supplement | 90 min | Line 12 working | ⏳ Pending |
| 180 | Complex amendments | 60 min | Line 17 verified | ⏳ Pending |
| 181 | Final validation | 90 min | All complete | ⏳ Pending |

**Total Remaining:** 240 minutes (4 hours compressed)

---

## Success Criteria

### Minimum (90.2%)
- ✅ Line 12 combined pattern working
- ✅ Line 17 verified working
- ✅ IEEE at 8,618+/9,552 (90.2%)
- ✅ No regressions

### Target (90.3%)
- ✅ All TODO patterns resolved
- ✅ IEEE at 8,620/9,552 (90.3%)
- ✅ Complete documentation
- ✅ All session docs archived

### Stretch (90.5%)
- ✅ Additional optimizations
- ✅ IEEE at 8,630/9,552 (90.5%)
- ✅ Comprehensive test coverage

---

## Key Architectural Principles

**MAINTAIN throughout:**
1. **MODEL-DRIVEN** - Combined identifiers as proper objects
2. **MECE** - Clear pattern separation
3. **Three-layer** - Parser/Builder/Identifier independence
4. **Incremental** - Test after each change
5. **Zero regressions** - Verify existing patterns still work
6. **Architecture first** - Correctness over pass rate

---

## Files to Modify

### Session 179 (Combined with Supplements)
- `lib/pubid_new/ieee/parser.rb` - Add combined_identifier_with_supplements
- `lib/pubid_new/ieee/builder.rb` - Add build_combined_with_supplements
- Test files

### Session 180 (Complex Amendments)
- `lib/pubid_new/ieee/parser.rb` - Enhance as_amended_by_clause (if needed)
- Test and verify

### Session 181 (Documentation)
- `README.adoc` - Add Pattern 4 & AIEE sections
- `TODO.IEEE-MUST-DO.txt` - Mark all complete
- Move old docs to `docs/old-docs/sessions/`

---

## Risk Mitigation

### High-Risk Areas

**1. Combined Identifier Parsing**
- Risk: Breaking existing "and" patterns
- Mitigation: Try new rule before general patterns
- Test: All existing combined tests must pass

**2. Complex Amendment Lists**
- Risk: Parser ambiguity with long lists
- Mitigation: Already handled by Pattern 4
- Test: Verify with Line 17 specifically

### Validation Checkpoints

**After Session 179:**
- [ ] Line 12 parsing correctly
- [ ] No regression in combined patterns
- [ ] IEEE at 8,613+/9,552

**After Session 180:**
- [ ] Line 17 parsing correctly
- [ ] All Pattern 4 tests passing
- [ ] IEEE at 8,614+/9,552

**After Session 181:**
- [ ] All TODO patterns verified
- [ ] Documentation complete
- [ ] IEEE at 90.2-90.5%
- [ ] Project ready for release

---

## Next Immediate Steps (Session 179)

1. Read this continuation plan
2. Implement combined_identifier_with_supplements parser rule
3. Add builder support
4. Test Line 12 pattern
5. Verify no regressions
6. Commit progress

---

**Created:** 2025-12-21
**Sessions Covered:** 179-181
**Status:** Ready for execution
**Estimated Time:** 4 hours (compressed timeline)

**End Goal:** Complete all 46 TODO patterns, IEEE at 90.2-90.5%, project finalized! 🎉