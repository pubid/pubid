# Session 37+ Continuation Plan: Complete ISO Addendum & Fix Parser Regressions

**Created:** 2025-11-27
**Status:** Session 36 achieved partial success but introduced regressions
**Priority:** HIGH - Fix regressions, complete Addendum, reach 85%

---

## Critical Context

### Session 36 Results

**Partial Success:**
- ✅ Fixed DAD parsing for patterns like "ISO 2631/DAD 1" (+11 tests)
- ✅ Made TYPED_STAGES dynamic (architectural improvement)
- ✅ Enhanced legacy part matching precision

**Major Regression:**
- ❌ Full ISO suite: 23 failures → 786 failures (unacceptable)
- ❌ Root cause: Overly aggressive negative lookahead in `identifier_copublishers_no_third`
- ✅ Core fix (legacy part lookahead) works correctly

**Test Status:**
- addendum_spec: 19 → 8 failures (+11 tests) ✅
- Full ISO: 2,859 examples, 786 failures, 480 pending ❌

---

## Root Cause Analysis

### What Works

```ruby
# lib/pubid_new/iso/parser.rb (line ~135)
# Legacy part matching with positive lookahead
(
  str("/") >> space? >>
  match('\w').repeat(1, 3) >> 
  (match[':\-\('].present? | space.absent?)  # ✅ WORKS
)
```

This prevents "/Amd ", "/Cor ", "/DAD " from matching as legacy parts.

### What Broke

```ruby
# lib/pubid_new/iso/parser.rb (line ~217)
# Negative lookahead in identifier_copublishers_no_third
(space? >> str("/") >> (supplement_type_with_stage >> space?).absent? >> type_with_stage).maybe
#                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ ❌ TOO AGGRESSIVE
```

This breaks many identifiers because the lookahead prevents proper parsing.

---

## Phase 1: Fix Regressions (Session 37 Priority 1)

### Task 1.1: Revert Problematic Change (15 min)

**Action:** Remove the negative lookahead from `identifier_copublishers_no_third`

```ruby
# REVERT TO:
rule(:identifier_copublishers_no_third) do
  (guide_prefix.as(:type_with_stage_fr) >> space).maybe >>
    prefix_with_copublishers.maybe >> space? >> str("/").maybe >>
    type_with_stage.maybe >>
    space.maybe >>
    second_part >> third_part_edition
end
```

**Verify:** Full ISO suite should return to ~23 failures baseline

### Task 1.2: Alternative Solution for "/" Ambiguity (30 min)

**Problem:** When parsing "ISO 8601/Amd 1", we need to distinguish:
- "ISO 8601" + "/" + "Amd" (supplement separator)
- "ISO 8601" + "/6" (legacy part)

**Solution:** The legacy part fix (Task 1.1 preserves this) already prevents the issue!

The key insight: `/Amd ` has a space after "Amd", so `(match[':\-\('].present? | space.absent?)` will FAIL, causing backtracking. The parser will then try `supplement_identifier` which WILL match.

**Test:**
```ruby
"ISO 8601/Amd 1"  # space.absent? fails on "/Amd ", backtrack, supplement_identifier matches ✅
"ISO 5843/6"      # No space after "6", matches as legacy part ✅
"ISO 5843/6:1988" # ":" present, matches as legacy part with date ✅
```

**Action:** Verify this works without the negative lookahead

---

## Phase 2: Complete Addendum Tests (Session 37 Priority 2)

### Remaining 8 Failures

**5 failures: Missing typed_stage on International Standards**

Examples:
- "ISO 1942:1983/Add 1:1983" - base has nil typed_stage
- "ISO 2631/DAD 1" - base has nil typed_stage

**Root Cause:** Builder doesn't set default TypedStage for International Standards when `type_with_stage` is empty

**Solution:** Update Builder.cast(:type_with_stage) to handle nil/empty:

```ruby
when :type_with_stage
  original_value = value.to_s
  
  # If empty, use default International Standard typed_stage
  if original_value.strip.empty?
    default_ts = @scheme.locate_typed_stage_by_abbr("")
    return {
      stage: default_ts.to_stage,
      type: default_ts.to_type,
      typed_stage: default_ts
    }
  end
  
  # Otherwise proceed normally...
```

**Files:** `lib/pubid_new/iso/builder.rb` (line ~214)

**Expected:** +5 tests

**3 failures: Legacy hyphen format**

Example: "ISO 4037-1979/Add. 1-1983(F)"

**Problem:** Parser treats "-1979" and "-1983" as parts instead of dates

**Solution:** Builder normalization in `cast(:number_with_part)`:

```ruby
when :number_with_part
  # ... existing code ...
  
  # Legacy format: "4037-1979" where "1979" looks like part but is actually year
  if part && part.match?(/^\d{4}$/)
    # This is a year, not a part
    return { 
      number: Components::Code.new(number: number),
      date: Components::Date.new(year: part)
    }
  end
```

**Expected:** +3 tests

---

## Phase 3: Target 85% (Session 38+)

### Current: 82.5% (2,357/2,859)
### Target: 85% (2,430/2,859) = +73 tests

**Strategy:**
1. Fix typed_stage defaults (+5 tests) → 82.7%
2. Fix legacy hyphen (+3 tests) → 82.8%
3. Identify next 65 low-hanging fruit

**Likely candidates:**
- Parser enhancements for edge cases
- Other supplement types (Amendment, Corrigendum may have similar issues)
- Stage iteration handling

---

## Implementation Checklist

### Session 37 (Immediate)

- [ ] **Task 1.1:** Revert negative lookahead in identifier_copublishers_no_third
- [ ] **Verify:** Full ISO suite returns to 23 failures
- [ ] **Task 1.2:** Confirm legacy part lookahead prevents "/Amd" matching
- [ ] **Test:** Run addendum_spec - should still have 8 failures but all DAD tests pass
- [ ] **Task 2.1:** Fix Builder typed_stage defaults (+5 tests)
- [ ] **Task 2.2:** Fix Builder legacy hyphen format (+3 tests)
- [ ] **Target:** addendum_spec 100%, full suite ~15 failures, 82.8%+

### Session 38+ (Next Steps)

- [ ] Identify remaining failure patterns
- [ ] Prioritize by impact
- [ ] Target 85% milestone
- [ ] Update README.adoc

---

## Key Principles

1. **Architecture First:** The dynamic TYPED_STAGES loading is correct
2. **Parser Precision:** Use positive lookaheads for what SHOULD follow, not negative for what shouldn't
3. **Builder Responsibility:** Normalization happens in Builder, not Parser
4. **Test First:** Verify baseline before making changes
5. **Incremental:** One fix at a time, test after each

---

## Success Criteria

**Session 37 Complete When:**
- ✅ Full ISO suite at or below 23 failures (no regression)
- ✅ addendum_spec fully passing (0 failures)
- ✅ 82.8%+ pass rate (2,365+/2,859)

**Final Goal:**
- 85%+ pass rate (2,430+/2,859)
- All Addendum patterns working
- Clean, maintainable architecture

---

## Files to Modify

1. `lib/pubid_new/iso/parser.rb` - Revert line 217 change
2. `lib/pubid_new/iso/builder.rb` - Add typed_stage default + legacy hyphen handling
3. `spec/pubid_new/iso/identifiers/addendum_spec.rb` - All should pass

---

## Rollback Plan

If regressions persist:
1. `git diff lib/pubid_new/iso/parser.rb` - Review all changes
2. Keep only the legacy part lookahead fix (line ~135)
3. Revert everything else
4. Re-approach the "/" ambiguity problem differently

---

**Status:** Ready for Session 37
**Next Action:** Revert identifier_copublishers_no_third change
**Expected Outcome:** 82.8%+ (2,365+/2,859), 0 addendum failures