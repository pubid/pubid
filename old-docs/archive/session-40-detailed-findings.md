# Session 40 Detailed Findings: Parser Investigation for DAD Parsing

**Date:** 2025-11-27  
**Session Duration:** ~70 minutes  
**Outcome:** UNSUCCESSFUL - All approaches caused massive regressions  
**Recommendation:** Builder workaround (Session 41)

---

## Problem Statement

**Target:** Enable parsing of valid ISO identifiers with DAD (Draft for Addendum) supplements:
- "ISO 2631/DAD 1" (8 test failures)
- "ISO 2553/DAD 1:1987" (8 test failures)
- "ISO/DIS 1151-1/DAD 2" (already passes)

**Total Impact:** 16 test failures to fix

---

## Root Cause Analysis

### Parser Flow for "ISO 2631/DAD 1"

1. Root `identifier` rule tries rules in order (line 24-32):
   - `directives_identifiers` - No match
   - `iso_r_supplement_identifier` - No match (not ISO/R)
   - `iso_r_identifier` - No match (not ISO/R)
   - `supplement_supplement_identifier` - No match (no nested supplement)
   - **`supplement_identifier`** - ATTEMPTS TO MATCH ⬇️

2. `supplement_identifier` calls `supplement_identifier_no_third` (line 256-261):
   ```ruby
   identifier_copublishers_no_third.as(:base_identifier) >>
     str("/") >> supplement_type_with_stage >>
     space? >> second_part
   ```

3. `identifier_copublishers_no_third` (line 203-211) tries to parse "ISO 2631":
   ```ruby
   prefix_with_copublishers.maybe >> space? >> str("/").maybe >>
     type_with_stage.maybe >>
     space.maybe >>
     second_part >> third_part_edition
   ```

4. **PROBLEM**: The `str("/").maybe` on line 207 **greedily consumes "/"** from "ISO 2631/DAD"
   - Parser sees: "ISO 2631/"
   - Consumes: "/" (thinking it might be for type like "ISO/TR")
   - Tries to match: "DAD 1" as `type_with_stage`
   - Looks up "DAD" in: base TYPED_STAGES
   - **FAILS**: "DAD" is NOT in base TYPED_STAGES (correctly only in TYPED_STAGES_SUPPLEMENTS)

5. Since base parse failed, `supplement_identifier` fails, entire parse fails

### Why Architecture Is Correct

- ✅ DAD belongs in `TYPED_STAGES_SUPPLEMENTS` (not base TYPED_STAGES)
- ✅ DAD is defined in `Addendum.TYPED_STAGES` array
- ✅ Supplement parsing structure is proper
- ❌ Only the parser grammar needs fixing

---

## Approaches Attempted

### Attempt 1: Atomic Slash+Type

**Change:** Make slash and type required together
```ruby
# Line 207-208
prefix_with_copublishers.maybe >> space? >> 
  (str("/") >> type_with_stage).maybe >>  # ATOMIC
  space.maybe >>
  second_part >> third_part_edition
```

**Result:** 652 failures (+635 regression)

**Why It Failed:**
- Copublisher parsing uses "/" in `prefix_with_copublishers`
- Example: "ISO/IEC 8601"
  - `prefix_with_copublishers` matches "ISO/IEC"
  - Then line 207 tries `(str("/") >> type_with_stage).maybe`
  - But "/" already consumed by copublisher rule!
  - Parse fails on valid identifiers

**Regressions:** All identifiers with copublishers failed

---

### Attempt 2: Negative Lookahead After Slash

**Change:** Check for supplement types after consuming slash
```ruby
# Line 207-209
prefix_with_copublishers.maybe >>
  (space? >> 
    str("/") >> 
    array_to_str(TYPED_STAGES_SUPPLEMENTS).absent? >>
    type_with_stage
  ).maybe >>
  space.maybe >>
  second_part >> third_part_edition
```

**Result:** 654 failures (+637 regression)

**Why It Failed:**
- `.absent?` checks AFTER "/" is consumed
- Parslet's `.maybe` behavior: Even if absent? fails, "/" already gone
- Similar to Attempt 1 - broke copublisher parsing

---

### Attempt 3: Negative Lookahead Before Slash

**Change:** Check supplement types before consuming slash
```ruby
# Line 207-209
prefix_with_copublishers.maybe >>
  (space? >> 
    array_to_str(TYPED_STAGES_SUPPLEMENTS).absent() >>
    str("/") >> 
    type_with_stage
  ).maybe >>
  space.maybe >>
  second_part >> third_part_edition
```

**Result:** 652 failures (+635 regression)

**Why It Failed:**
- Still interfered with copublisher parsing
- Lookahead timing didn't solve the fundamental issue
- "/" consumed by different rules in different contexts

---

### Attempt 4: Specialized Supplement Rule (BEST ATTEMPT)

**Change:** Create separate rule for base identifiers in supplements
```ruby
# New rule (line 213-223)
rule(:identifier_copublishers_no_third_for_supplement) do
  (guide_prefix.as(:type_with_stage_fr) >> space).maybe >>
    prefix_with_copublishers.maybe >>
    # NO slash/type matching - let supplement rule handle "/"
    space.maybe >>
    second_part >> third_part_edition
end

# Use in supplement_identifier_no_third (line 258)
identifier_copublishers_no_third_for_supplement.as(:base_identifier) >>
  str("/") >> supplement_type_with_stage >>
  space? >> second_part
```

**Result:** 207 failures (+190 regression), then improved to 168 failures with refinements

**Why It Partially Worked:**
- Separated supplement-base parsing from general parsing
- Reduced conflicts significantly (652→207→168)
- Correct architectural approach

**Why It Still Failed:**
- DAD tests still didn't pass (8 failures remained)
- New rule too restrictive - didn't handle type patterns in bases
- Example: "ISO/TR 8601:2019/Amd 1" has "/TR" in base

**Refinement Attempts:**
1. Added atomic slash+type back: `(space? >> str("/") >> type_with_stage).maybe`
   - Result: 168 failures
2. Added positive lookahead: `(space? >> (str("/") >> array_to_str(TYPED_STAGES)).present? >> str("/") >> type_with_stage).maybe`
   - Result: 169 failures
3. Various spacing adjustments
   - Result: No improvement

**Analysis:**
- Right direction but incomplete
- Needs fuller understanding of all contexts where base parsing used
- Specialized rules need to cover ALL cases properly

---

### Attempt 5-6: Additional Lookahead Variations

**Changes:** Multiple combinations of positive/negative lookahead, spacing adjustments

**Results:** 168-169 failures consistently

**Conclusion:** Incremental improvements plateaued at ~150 regression threshold

---

## Key Technical Insights

### 1. Rule Context Complexity

`identifier_copublishers_no_third` is used in FOUR contexts:

1. **Standalone identifiers**: "ISO 8601:2019"
   - Needs: Full parsing including optional slash/type

2. **Base for supplements**: "ISO 2631" in "ISO 2631/DAD 1"
   - Needs: NO slash consumption (supplement uses it)

3. **Base for joint identifiers**: "ISO 5537" in "ISO 5537|IDF 26" 
   - Needs: Full parsing including optional slash/type

4. **With type patterns**: "ISO/TR 8601" or "ISO/TS 20594-1"
   - Needs: Slash+type matching

**Problem:** Single rule can't serve all contexts with current grammar

### 2. Parslet `.maybe` Behavior

- `.maybe` means "try to match, if fails continue"
- BUT: Partial matches can still consume input!
- Example: `(str("/") >> type_with_stage).maybe`
  - Matches "/" 
  - Tries to match type
  - Type fails
  - "/" already consumed even though `.maybe` failed!

**Solution needed:** True atomic grouping or proper lookahead

### 3. Copublisher Slash Consumption

The `copublishers` rule (line 81-83) consumes "/" for each copublisher:
```ruby
(str("/") >> space? >> array_to_str(ORGANIZATIONS).as(:copublisher)).repeat.as(:copublishers)
```

This means "/" is consumed at TWO different levels:
1. In `copublishers` (for "ISO/IEC/IEEE")
2. In `identifier_copublishers_no_third` (for "ISO/TR")

**Conflict:** Hard to distinguish these cases in parsing

### 4. Supplement vs Type Ambiguity

Both use "/" separator:
- Type: "ISO/TR 8601"
- Supplement: "ISO 8601/Amd 1"

Parser must decide which "/" means what, and current grammar conflates them.

---

## Why Builder Workaround Is Better

### Parser Fix Challenges:
1. **High regression risk**: ANY change causes 150+ failures
2. **Complex interactions**: 4+ contexts using same rule
3. **Parslet limitations**: `.maybe` behavior hard to control
4. **Time intensive**: Requires full parser architecture understanding

### Builder Workaround Advantages:
1. **Zero parser changes**: Zero risk to 2,363 passing tests
2. **Explicit handling**: Can detect "/DAD" patterns before parsing
3. **Isolated**: Changes only in Builder layer
4. **Testable**: Easy to unit test and debug
5. **Quick**: 60-90 min implementation vs 3-4 hours parser refactor

### Builder Implementation Strategy:
```ruby
# Pre-process DAD patterns
if string.match?(/^(.+?)\/(F?DAD)\s+(.+)$/)
  base_str, dad_type, supplement_str = extract_parts(string)
  base = parse(base_str)  # Recursive - no DAD to confuse parser
  supplement = build_dad_supplement(dad_type, supplement_str)
  return Addendum.new(base_identifier: base, ...)
end

# Normal parsing for everything else
parser.parse(string)
```

**Expected:** +16 tests with <10 regressions (acceptable)

---

## Recommendations for Future Parser Work

### If Builder Workaround Insufficient:

**Phase 1: Complete Context Audit** (2-3 hours)
1. Map ALL uses of `identifier_copublishers_no_third`
2. Document required behavior for each context
3. Identify minimal set of specialized rules needed

**Phase 2: Incremental Refactor** (4-6 hours)
1. Create context-specific rules:
   - `base_for_supplement` (no slash/type)
   - `base_for_joint` (full matching)
   - `standalone_identifier` (current implementation)
2. Test each change incrementally
3. Update all call sites

**Phase 3: Parser Architecture Cleanup** (3-4 hours)
1. Consolidate duplicate logic
2. Add comprehensive parser unit tests
3. Document parser design patterns

### Estimated Total: 9-13 hours for complete parser fix

---

## Test Impact Analysis

### Baseline: 2,859 examples, 17 failures, 480 pending

### Regression Patterns by Approach:

| Approach | Failures | Regression | Primary Cause |
|----------|----------|------------|---------------|
| Atomic slash+type | 652 | +635 | Copublisher break |
| Lookahead after | 654 | +637 | Copublisher break + timing |
| Lookahead before | 652 | +635 | Same as atomic |
| Specialized rule (v1) | 207 | +190 | Too restrictive |
| Specialized rule (v2) | 168 | +151 | Still incomplete |
| Lookahead variations | 168-169 | +151-152 | Plateau |

### Regression Threshold Analysis:

- **< 25 failures**: Acceptable, can fix incrementally
- **25-150 failures**: Caution, needs careful analysis
- **150+ failures**: Unacceptable, fundamental approach problem
- **600+ failures**: Critical failure, immediate revert

---

## Documentation Created

1. **Session 40 summary** - In context.md
2. **Continuation plan** - docs/continuation-plan-session-41.md
3. **Session 41 prompt** - docs/session-41-prompt.md
4. **This detailed findings** - docs/session-40-detailed-findings.md

---

## Lessons for Future Sessions

1. **Parser changes require extreme care** - Any modification needs full context understanding
2. **Specialized rules reduce but don't eliminate conflicts** - Need complete separation
3. **Parslet behavior is complex** - Test each construct in isolation first
4. **Architecture correctness trumps test pass rate** - DAD placement is right, parser is wrong
5. **Builder workarounds are viable** - Don't over-commit to parser-only solutions
6. **Document thoroughly** - Saves hours in future attempts
7. **Revert quickly** - Don't try to fix massive regressions, start over with new approach

---

## Files Examined

- `lib/pubid_new/iso/parser.rb` (lines 1-435)
- `lib/pubid_new/iso/identifiers/addendum.rb` (lines 1-43)
- `spec/pubid_new/iso/identifiers/addendum_spec.rb` (lines 386-514)
- `.kilocode/rules/memory-bank/architecture.md`
- `.kilocode/rules/memory-bank/context.md`

---

## Exit State

- All changes reverted ✅
- Baseline restored: 2,363/2,859 (82.7%) ✅
- Zero code modifications committed ✅
- Comprehensive documentation created ✅
- Clear path forward identified ✅

**Next:** Session 41 - Builder workaround approach