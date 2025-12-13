// ... create new file ...
# Session 129 Continuation Prompt

**Context:** Implement IEEE parser patterns 1-4 to achieve 96%+ validation rate

**Previous Session:** Session 128 - Failure analysis complete
**Current Session:** Session 129 - Implement TOP 5 priority patterns
**Full Plan:** `.kilocode/rules/memory-bank/session-129-continuation-plan.md`

---

## Immediate Objective: Session 129

**Implement Patterns 1-4:** Text Month Format, Copublisher, P Complex, Optional Prefix (90 minutes)

### Tasks

1. **Pattern 1: Text Month Format** (25 min) ⭐⭐⭐
   - Add month_text_full, month_text_abbr rules (January, Feb, etc.)
   - Add month_numeric rule (01-12)
   - Add date_with_month_text and date_with_month_numeric rules
   - Replace date rule to support all three formats
   - Test: `cd spec/fixtures && ruby run_classify.rb ieee`
   - **Expected: +750-831 identifiers (HUGE!)**

2. **Pattern 2: ISO/IEC/IEEE Copublisher** (15 min)
   - Update copublisher rule to support three-way combinations
   - Add str("/ISO/IEC"), str("/IEC/ISO") (longest first)
   - Test: Three-way copublisher identifiers
   - **Expected: +200-241 identifiers**

3. **Pattern 3: IEEE P Prefix Complex** (20 min)
   - Make space after P optional: `str("IEEE P") >> space.maybe`
   - Update draft_version for D3.1 format, Draft 3, D[0-9]
   - Add revision_notation rule (_Rev, -rev, /D)
   - Test: D3.1 format identifiers
   - **Expected: +200-272 identifiers**

4. **Pattern 4: Optional IEEE Prefix** (15 min)
   - Create ieee_prefix rule (IEEE Std, IEEE, or empty)
   - Make prefix optional with .maybe
   - Update identifier rule to use ieee_prefix
   - Test: Identifiers without IEEE prefix
   - **Expected: +180-250 identifiers**
   - **CAUTION: Medium risk - test carefully**

5. **Final Testing & Validation** (15 min)
   - Run full classification: `ruby run_classify.rb ieee`
   - Run unit tests: `bundle exec rspec spec/pubid_new/ieee/`
   - Verify no regressions: `ruby run_classify.rb iso && ruby run_classify.rb iec`
   - Expected final: 9,161-9,448/9,537 (96.1-99.0%)

6. **Commit Changes** (8 min)
   - Use semantic commit message template from plan
   - Document actual gains achieved
   - Update metrics

### Expected Deliverables

- ✅ Pattern 1 implemented with month support
- ✅ Pattern 2 implemented with three-way copublisher
- ✅ Pattern 3 implemented with D3.1 draft format
- ✅ Pattern 4 implemented with optional prefix
- ✅ IEEE at 96%+ (9,155+/9,537) - target 90%+ significantly exceeded
- ✅ All unit tests passing (28/28)
- ✅ Zero regressions in other flavors

### Success Criteria

- ✅ IEEE validation rate: 96%+ (minimum 90%+)
- ✅ Conservative estimate met: +930-1,116 identifiers
- ✅ All patterns working correctly
- ✅ Clean architecture maintained (parser-only changes)
- ✅ Ready for optional Session 130 or documentation phase

---

## Full Scope (Sessions 128-135)

**Phase 1:** Parser Enhancement to 90%+ (Sessions 128-130, 5 hours)
- Session 128: ✅ COMPLETE - Failure analysis & pattern identification
- Session 129: Implement patterns 1-4 (90 min)
- Session 130: Implement patterns 6-8 (90 min) - OPTIONAL if 96%+ achieved

**Phase 2:** Historical AIEE/IRE Patterns (Sessions 131-133, 5.5 hours) - OPTIONAL
**Phase 3:** Documentation (Sessions 134-135, 2.5 hours)

**Total:** 13 hours compressed, IEEE at 92-95% expected

---

**Read the full plan:** `.kilocode/rules/memory-bank/session-129-continuation-plan.md`
**Analysis document:** `/tmp/ieee_pattern_analysis.md`