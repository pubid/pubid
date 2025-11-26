# Session 32+ Continuation Plan: Parser Enhancement Phase 2

**Created:** 2025-11-26
**Session:** 32
**Phase:** Parser Enhancement Phase 2 - Special Formats
**Target:** 80.5% milestone (2,301 passing tests, need +12 from current 2,289)

---

## Executive Summary

**Session 31 completed Phase 1 of Parser Enhancement (+2 tests, 80.07% achieved).**

**Current Achievement:**
- ✅ Phase 1 Complete: +9 tests total (Session 30: +7, Session 31: +2)
- ✅ 80% milestone crossed (80.07%)
- 🎯 Begin Phase 2: Special Formats targeting 80.5%

**Status:** Ready to begin Phase 2 special format parsing

---

## Current Status (Session 31 Complete)

### Test Results
```
Total:    2,859 examples
Passing:  2,289 (80.07%) - Phase 1 Complete ✅
Failing:    143 (5.0%) - Down from 145 (-2 tests)
Pending:    427 (14.9%) - Intentional (URN + batch + builder_spec)
```

### Failure Breakdown (143 tests - ALL PARSER)

| Category | Count | Issue | Phase |
|----------|-------|-------|-------|
| Edge cases | ~88 | `identifier_spec.rb` complex patterns | Phase 4 |
| Legacy format | 81 | `addendum_spec.rb` "ISO/R 947:1969/Add 1" | Phase 3 |
| Special format | 9 | `directives_supplement_spec.rb` "Consolidated" | **Phase 2 (Next)** |
| Malformed IDs | 0 | `technical_specification_spec.rb` **FIXED ✅** | Phase 1 Done |
| Guide spacing | 0 | `guide_spec.rb` "FD Guide" **FIXED ✅** | Phase 1 Done |
| Other | ~9 | Various parser edge cases | Phase 2-4 |

### Architecture Status

**Rendering: LOCKED ✅**
- Zero failures
- 13/19 specs at 100%
- All 5 principles validated
- NO CHANGES ALLOWED

**Parser: PHASE 2 BEGINNING 🎯**
- Phase 1 complete (+9 tests)
- Special format parsing required
- Legacy format support needed (Phase 3)
- Edge case handling needed (Phase 4)

---

## Parser Enhancement Roadmap Progress

### Phase 1: Quick Wins (Sessions 30-31) - ✅ COMPLETE

**Achieved:** +9 tests (exceeded +9 target)
- ✅ Fix "FD Guide" spacing issue (7 tests) - Session 30
- ✅ Fix malformed identifiers (2 tests) - Session 31
- **Result:** 80.07% achieved (exceeded 79.9% target)

**Key Changes:**
- Session 30: Added "FD Guide" to FDGuide abbreviations array
- Session 31: Normalized malformed IDs with `.reject(&:empty?)` and `&.strip`

### Phase 2: Special Formats (Sessions 32-35) - 🎯 CURRENT

**Target:** +15-20 tests (reach 80.5%, 2,304 passing)
**Estimated Time:** 3-4 sessions (180-270 minutes)
**Difficulty:** Medium

**Tasks:**

#### Priority 1: Parse "Consolidated ISO Supplement" (+9 tests)

**Issue:** Special format not recognized by parser
- Format: "Consolidated ISO Supplement" in directives_supplement_spec
- File: [`lib/pubid_new/iso/parser.rb`](lib/pubid_new/iso/parser.rb:1)
- Change: Add grammar rule for consolidated supplements
- Test: [`spec/pubid_new/iso/identifiers/directives_supplement_spec.rb`](spec/pubid_new/iso/identifiers/directives_supplement_spec.rb:1)
- Estimated: 120 minutes

**Implementation Steps:**
1. Analyze failing test patterns
2. Add parser rule for "Consolidated" keyword
3. Handle special format in Builder
4. Update identifier class if needed
5. Validate round-trip parsing

#### Priority 2: Handle Other Special Formats (+6-11 tests)

**Issue:** Various special format variations
- File: [`lib/pubid_new/iso/parser.rb`](lib/pubid_new/iso/parser.rb:1)
- Change: Extend grammar for edge cases
- Tests: Various specs
- Estimated: 90 minutes

**Success Criteria:** 2,304+ passing tests (80.5%+), **Phase 2 complete**

### Phase 3: Legacy Formats (Sessions 36-40)

**Target:** +80 tests (reach 83.5%, 2,384 passing)
**Estimated Time:** 5 sessions (300-450 minutes)
**Difficulty:** High

**Tasks:**

#### Handle "ISO/R" Legacy Addendum Format (+81 tests)

**Issue:** "ISO/R 947:1969/Add 1" - old recommendation format
- File: [`lib/pubid_new/iso/parser.rb`](lib/pubid_new/iso/parser.rb:1)
- Change: Add grammar for legacy "R" (recommendation) type
- Strategy: Parse as legacy, may normalize to modern format
- Test: [`spec/pubid_new/iso/identifiers/addendum_spec.rb`](spec/pubid_new/iso/identifiers/addendum_spec.rb:1)
- Estimated: 240 minutes

**Implementation Steps:**
1. Research ISO/R format specifications
2. Add parser rule for "ISO/R" prefix
3. Handle in Builder
4. Decide: Preserve or normalize?
5. Update Recommendation identifier class
6. Validate extensive test coverage

**Success Criteria:** 2,384 passing tests (83.5%)

### Phase 4: Edge Cases (Sessions 41-45)

**Target:** +90 tests (reach 86.5%, 2,474 passing)
**Estimated Time:** 5 sessions (300-450 minutes)
**Difficulty:** High

**Tasks:**

#### Fix identifier_spec Edge Cases (+88 tests)

**Issue:** Complex identifier patterns not parsed
- File: [`lib/pubid_new/iso/parser.rb`](lib/pubid_new/iso/parser.rb:1)
- Change: Enhance grammar for complex patterns
- Strategy: Systematic analysis of each failure
- Test: [`spec/pubid_new/iso/identifier_spec.rb`](spec/pubid_new/iso/identifier_spec.rb:1)
- Estimated: 360 minutes

**Implementation Steps:**
1. Run identifier_spec with detailed output
2. Group failures by pattern type
3. Fix one pattern type at a time
4. Validate after each fix
5. Document patterns discovered

**Success Criteria:** 2,474 passing tests (86.5%)

---

## Session 32 Immediate Actions

### Priority 1: Analyze "Consolidated ISO Supplement" Failures (30 min)

**Goal:** Understand the pattern and requirements

**Commands:**
```bash
cd /Users/mulgogi/src/mn/pubid && \
bundle exec rspec spec/pubid_new/iso/identifiers/directives_supplement_spec.rb \
  --format documentation 2>&1 | grep -A 5 "Consolidated"
```

**Expected:** 9 failures with "Consolidated ISO Supplement" format

### Priority 2: Design Parser Solution (45 min)

**Analysis:**
1. Read failing test examples
2. Identify patterns
3. Design grammar rule
4. Plan Builder changes if needed

**File to modify:** [`lib/pubid_new/iso/parser.rb`](lib/pubid_new/iso/parser.rb:280)

**Approach:**
- Add rule for "Consolidated" keyword
- May need new identifier type or wrapper
- Ensure doesn't break existing patterns

### Priority 3: Implement and Test (90 min)

**Implementation:**
1. Add parser rule
2. Update Builder if needed
3. Test progressive changes
4. Validate round-trip

**Testing:**
```bash
bundle exec rspec spec/pubid_new/iso/identifiers/directives_supplement_spec.rb
bundle exec rspec spec/pubid_new/iso/ 2>&1 | grep "examples"
```

**Success:** 2,298+ passing tests (80.3%+)

---

## Critical Principles (NEVER VIOLATE)

### 1. Rendering Architecture is LOCKED

**The 5 core principles are validated and unchanging:**
1. TYPED_STAGE REGISTER is source of truth
2. Builder receives Scheme for lookups
3. Single cast() method for conversions
4. Composite hash returns for related values
5. Components render themselves

**DO NOT:**
- Modify Builder architecture
- Add type/stage logic outside Scheme
- Create new builder methods
- Change identifier rendering patterns

**Parser work must NOT touch rendering code.**

### 2. Normalization Strategy

**Session 31 established:** Malformed input should be **normalized**, not preserved
- Example: `"ISO/TS 10303- 1751:2014"` → `"ISO/TS 10303-1751:2014"`
- Parser: Lenient (accepts malformed)
- Builder: Normalizes (cleans up)
- Output: Correct format

**Apply this principle to all special formats.**

### 3. Object-Oriented and MECE

**Every change must:**
- Maintain separation of concerns
- Be mutually exclusive, collectively exhaustive
- Follow single responsibility principle
- Use proper inheritance and composition
- Prioritize architectural solutions

---

## Testing Strategy

### After Each Parser Change

**Required Checks:**
1. Run affected spec file
2. Run full ISO test suite
3. Verify no rendering regressions
4. Check round-trip parsing
5. Validate architecture principles

**Commands:**
```bash
# Test specific file
bundle exec rspec spec/pubid_new/iso/identifiers/directives_supplement_spec.rb

# Test full ISO
bundle exec rspec spec/pubid_new/iso/

# Check progress
bundle exec rspec spec/pubid_new/iso/ 2>&1 | grep "examples"
```

### Success Criteria Per Phase

**Phase 2:** 2,304+ passing (80.5%+)
**Phase 3:** 2,384 passing (83.5%)
**Phase 4:** 2,474 passing (86.5%)

---

## Documentation Updates Required

### Session 32: Update Official Documentation

**Do NOT do these yet, but plan for Session 33-34:**

**Update [`README.adoc`](README.adoc:1):**
- Document V2 architecture completion
- Add rendering complete milestone
- Update status badges
- Document parser enhancement phase

**Update `docs/architecture.md`:**
- Document clean architecture principles
- Add Scheme-based lookup pattern
- Document TYPED_STAGES register
- Add component rendering pattern

**Create `docs/v2-migration-status.md`:**
- Document rendering phase completion
- Document parser enhancement roadmap
- Track milestone progress
- Link to memory bank

### Session 32: Move Outdated Documentation

**Already done in Session 30 planning.**

---

## Risk Management

### Known Risks

1. **Parser Changes Break Rendering**
   - **Mitigation:** Run full test suite after each change
   - **Recovery:** Revert parser change, analyze impact

2. **Special Formats Complex**
   - **Mitigation:** Phase 2 has 3-4 sessions allocated
   - **Recovery:** Break into smaller sub-phases

3. **Edge Cases Uncover Architecture Issues**
   - **Mitigation:** Validate architecture principles each session
   - **Recovery:** Document as finding, update roadmap

### Contingency Plans

**If Phase 2 takes longer than expected:**
- Focus only on "Consolidated" format (+9 tests)
- Defer other special formats to Phase 3
- Adjust roadmap estimates

**If 80.5% not reached by Phase 2:**
- Reassess Phase 3 estimate
- Consider breaking Phase 3 into sub-phases
- Document findings for future reference

**If architecture issues discovered:**
- HALT parser work immediately
- Document issue in memory bank
- Discuss architectural solution
- Update roadmap

---

## Session 32 Continuation Prompt Template

```markdown
Continue Session 32 parser enhancement work:

1. Analyze "Consolidated ISO Supplement" failures
2. Design parser solution for consolidated format
3. Implement parser rule and test
4. Validate +9 tests improvement

Current: 2,289 passing (80.07%)
Target: 2,298+ passing (80.3%+)

Remember:
- Parser changes ONLY
- NO rendering modifications
- Validate architecture principles
- Normalize malformed inputs
- Test after each change
```

---

## Success Metrics

### Rendering Phase (COMPLETE ✅)
- ✅ Zero rendering failures
- ✅ 13/19 specs at 100%
- ✅ Clean architecture validated
- ✅ 2,277 passing tests (79.6%)

### Parser Phase Progress

**Phase 1: COMPLETE ✅**
- ✅ 2,289 passing (80.07%)
- ✅ +9 tests achieved
- ✅ 80% milestone crossed

**Phase 2: CURRENT 🎯**
- 🎯 Target: 2,304+ passing (80.5%+)
- 🎯 +15 tests minimum
- 🎯 Goal: Complete special formats

**Phase 3: PLANNED**
- 🎯 Target: 2,384 passing (83.5%)
- 🎯 +80 tests (legacy "ISO/R")

**Phase 4: PLANNED**
- 🎯 Target: 2,474 passing (86.5%)
- 🎯 +90 tests (edge cases)

**Final Goal:**
- 🎯 2,574+ passing (90%+)

---

## Memory Bank Integration

**Read before EVERY session:**
1. [`.kilocode/rules/memory-bank/architecture.md`](.kilocode/rules/memory-bank/architecture.md:1) - Full architecture
2. [`.kilocode/rules/memory-bank/context.md`](.kilocode/rules/memory-bank/context.md:1) - Current status
3. This file (`CONTINUATION_PLAN_SESSION32.md`) - Implementation plan

**Update after major milestones:**
- `context.md` - Current status and recent changes
- This file - Implementation status tracker

---

## Important Reminders

1. **Rendering is complete** - Focus 100% on parser
2. **Architecture is locked** - No changes to 5 principles
3. **Normalize malformed input** - Don't preserve broken formats
4. **One change at a time** - Validate after each
5. **Document findings** - Update tracker and memory bank

---

**Status:** Ready for Session 32
**Next Action:** Analyze "Consolidated ISO Supplement" failures
**Expected Outcome:** 2,298+ passing (80.3%+), Phase 2 ~50% complete

---

**Phase 1: COMPLETE ✅** (Sessions 30-31)
**Phase 2: SESSION 32 BEGINNING 🎯**
