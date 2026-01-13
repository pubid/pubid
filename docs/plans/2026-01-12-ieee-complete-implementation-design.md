# IEEE V2 Complete Implementation Design

**Date:** 2026-01-12
**Status:** Design Complete - Ready for Implementation
**Approach:** Targeted Enhancement (Single-Issue Focus)
**Current Status:** 90.34% pass rate (8629/9552) - "standard" class at 0.11%

## Executive Summary

Complete the IEEE V2 implementation by diagnosing and fixing the critical "standard" identifier class failure rate. Unlike NIST (which had fixture loading issues), IEEE has excellent overall coverage but a specific identifier class ("standard") is nearly completely broken (1/924 = 0.11%).

**Critical Finding:** IEEE has comprehensive MODEL-DRIVEN architecture with excellent coverage for most identifier types. The issue is isolated to the "standard" identifier class specifically.

## Current State Analysis

### Coverage Summary (from SUMMARY.txt)

| Identifier Class | Pass Rate | Count |
|------------------|-----------|-------|
| adopted_standard | 100% | 76/76 |
| base | 100% | 7220/7220 |
| corrigendum | 100% | 188/188 |
| csa_dual_published | 100% | 4/4 |
| draft | 100% | 1/1 |
| dual_published | 100% | 1009/1009 |
| handbook | 100% | 2/2 |
| identifier | 100% | 66/66 |
| iec_ieee_copublished | 100% | 50/50 |
| joint_development | 100% | 5/5 |
| si_standard | 100% | 7/7 |
| **standard** | **0.11%** | **1/924** |

**Total:** 90.34% (8629/9552)

### Known Issues

1. **"standard" class near-total failure**: Only 1 of 924 identifiers passing
2. **Fixture file size**: 10,331 lines in complete_dataset.txt (large dataset)
3. **TODO patterns**: All 46 patterns marked as complete (per TODO.IEEE-MUST-DO.txt)
4. **Must-fix IDs**: 115 specific identifiers in TODO.IEEE-MUST-FIX-IDs.txt

### Architecture Foundation (ALREADY EXCELLENT)

- MODEL-DRIVEN three-layer: Parser → Builder → Identifier
- 12 identifier types implemented (base, dual_published, joint_development, etc.)
- Lutaml::Model::Serializable component-based modeling
- Comprehensive preprocessing (270+ lines of typo fixes, HTML entities, spacing)
- TypedStage system with IEEE/ISO stage code mapping
- Round-trip fidelity: `parse(str).to_s == str`

## Root Cause Analysis

### Why is "standard" failing?

The "standard" class appears to be a separate or deprecated identifier class that may:
1. Have routing issues in the builder (not matching expected patterns)
2. Have parsing issues (not being recognized correctly)
3. Be a legacy class that conflicts with "base" class

**Key Question:** Is "standard" distinct from "base", or should these identifiers route to "base"?

### Investigation Plan

1. **Read the "standard" identifier class** to understand its purpose
2. **Check builder routing logic** to see how identifiers are assigned to classes
3. **Sample failing fixtures** to understand what patterns are failing
4. **Compare "base" vs "standard"** to determine if they're redundant

## Single-Focus Implementation Strategy

### Phase 1: Diagnosis (Critical - Do First)

**Task 1.1: Read the standard identifier class**

File: `lib/pubid_new/ieee/identifiers/standard.rb`

Questions:
- What is the purpose of this class?
- How does it differ from `Base`?
- Is it supposed to be used or deprecated?

**Task 1.2: Examine builder routing logic**

File: `lib/pubid_new/ieee/builder.rb:377-404` (determine_identifier_class method)

Questions:
- When does an identifier get routed to "standard" vs "base"?
- Are the routing rules correct?
- Is there a pattern mismatch?

**Task 1.3: Analyze failing fixtures**

Action: Run integration test and capture first 20 "standard" failures

```bash
bundle exec rspec spec/integration/ieee_spec.rb -n "all identifiers" 2>&1 | grep "standard" | head -20
```

**Task 1.4: Sample parse attempts**

For each failure, test:
```ruby
PubidNew::Ieee.parse(failing_identifier)
```

Expected outcome: Understand why they're not parsing correctly

### Phase 2: Fix Implementation (Based on Diagnosis)

**Option A: If "standard" is redundant with "base"**

Action: Route all "standard" patterns to "base" class
- Update `determine_identifier_class` method
- Remove or deprecate "standard" class
- Update tests

**Option B: If "standard" has distinct purpose**

Action: Fix the routing/parsing logic
- Update parser rules to capture "standard" patterns
- Update builder to route correctly
- Fix any rendering issues

**Option C: If "standard" is legacy/deprecated**

Action: Officially deprecate and document
- Mark class as deprecated
- Route all patterns to "base"
- Update documentation

### Phase 3: Address Must-Fix IDs

File: `TODO.IEEE-MUST-FIX-IDs.txt` (115 specific identifiers)

Categories:
1. HTML entity issues (&amp;, &x2122;, etc.)
2. Spacing/formatting issues
3. Complex multi-amendment patterns
4. Historical identifier formats
5. IEC/IEEE copublished patterns

**Priority:** High (these are documented as "must fix")

## Testing & Validation Strategy

### Integration Tests (`spec/integration/ieee_spec.rb`)

**Target Metrics:**
- All records: 95%+ (from 90.34% baseline)
- "standard" class: 95%+ (from 0.11% baseline)
- Other classes: Maintain 100%

### Unit Tests

**Per Identifier Class:**
- Verify "standard" class (or its routes to "base")
- Test all 115 must-fix identifiers
- Round-trip fidelity: `parse(str).to_s == str`

**Feature-Specific Tests:**
- Builder routing logic
- Parser pattern matching
- Multi-format rendering (if applicable)

### Coverage Goals

- Parser coverage: 95%+ of real-world patterns
- Identifier coverage: All 12 classes fully tested
- "standard" resolution: Either fixed or properly deprecated

## Execution Phases

### Phase 1: Diagnosis (Day 1 - Morning)

1. Read `lib/pubid_new/ieee/identifiers/standard.rb`
2. Analyze builder routing logic in `determine_identifier_class`
3. Run integration test and capture failures
4. Sample parse 10-20 failing identifiers
5. Document root cause

**Expected Time:** 1-2 hours

### Phase 2: Fix Implementation (Day 1 - Afternoon)

Based on Phase 1 findings:

**If routing issue:**
1. Update `determine_identifier_class` method
2. Test with sampled failures
3. Run full integration test
4. Iterate until fixed

**If parsing issue:**
1. Update parser rules
2. Test with sampled failures
3. Run full integration test
4. Iterate until fixed

**If deprecation needed:**
1. Mark "standard" as deprecated
2. Route all patterns to "base"
3. Update documentation
4. Run full integration test

**Expected Time:** 2-4 hours

### Phase 3: Must-Fix IDs (Day 2)

1. Address 115 must-fix identifiers from TODO
2. Group by issue type (HTML, spacing, patterns)
3. Fix parser preprocessing rules
4. Add tests for each fix
5. Run full integration test

**Expected Time:** 3-5 hours

### Phase 4: Validation & Documentation (Day 2-3)

1. Run full integration suite
2. Achieve target coverage (95%+ overall)
3. Update IEEE status documentation
4. Create implementation summary
5. RuboCop cleanup

**Expected Time:** 1-2 hours

## Quality Gates

Each phase must pass these gates before proceeding:

1. All fixture patterns for implemented features parse correctly
2. Round-trip fidelity maintained for all patterns
3. Zero regressions in existing tests
4. Integration test coverage meets phase targets
5. RuboCop clean: `bundle exec rubocop -A`
6. MODEL-DRIVEN architecture maintained

## Success Criteria

### Coverage Targets

- **Phase 1 Complete**: Root cause identified
- **Phase 2 Complete**: 95%+ "standard" class coverage
- **Phase 3 Complete**: 95%+ overall coverage
- **Final**: 95%+ overall, all must-fix IDs addressed

### Quality Targets

- Integration Tests: 95%+ overall
- "standard" class: 95%+ (or properly deprecated)
- Round-trip Fidelity: 100% on all implemented patterns
- Must-Fix IDs: All 115 addressed
- Architecture Compliance: 100% MODEL-DRIVEN

## Critical Design Decisions

1. **"standard" vs "base":** Determine if "standard" is distinct or redundant
2. **Deprecation vs. Fix:** Based on root cause analysis
3. **Backward Compatibility:** Ensure existing "base" patterns still work
4. **Test Coverage:** Comprehensive testing for the fix

## Files to Modify/Create

### Read First (Diagnosis)
- `lib/pubid_new/ieee/identifiers/standard.rb` (Does this exist?)
- `lib/pubid_new/ieee/builder.rb:377-404` (determine_identifier_class)
- `spec/fixtures/ieee/identifiers/pass/standard.txt` (Sample fixtures)

### Potentially Modify
- `lib/pubid_new/ieee/parser.rb` (if parsing issue)
- `lib/pubid_new/ieee/builder.rb` (if routing issue)
- `spec/integration/ieee_spec.rb` (adjust targets if needed)

### Potentially Create
- `spec/pubid_new/ieee/standard_identifier_spec.rb` (tests for standard class)
- `spec/pubid_new/ieee/builder_routing_spec.rb` (tests for routing logic)

### Update
- `docs/IEEE-IMPLEMENTATION-STATUS.md` (create)
- `.kilocode/rules/memory-bank/context.md` (IEEE section)

## Estimated Total Timeline

- **Phase 1**: 1-2 hours (diagnosis)
- **Phase 2**: 2-4 hours (fix implementation)
- **Phase 3**: 3-5 hours (must-fix IDs)
- **Phase 4**: 1-2 hours (validation + documentation)

**Total**: 7-13 hours (1-2 days)

---

**Design Status:** Complete and approved
**Ready for Implementation:** Yes (pending diagnosis)
**First Task:** Phase 1, Task 1.1 - Read the standard identifier class
