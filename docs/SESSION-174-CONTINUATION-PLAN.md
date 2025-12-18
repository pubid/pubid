# Session 174+ Continuation Plan: TODO.IEEE-MUST-DO.txt Completion

**Created:** 2025-12-18 (Post-Session 173)
**Status:** IEEE at 90.15%, 17 TODO patterns remaining
**Priority:** MEDIUM - Continue TODO implementation for 90.2%+
**Timeline:** COMPRESSED - 2-3 sessions (150-180 minutes)

---

## Executive Summary

**Session 173 Result:** IEEE at 8,611/9,552 (90.15%) with 8 TODO patterns implemented

**Remaining Work:**
- **Total remaining:** 17 patterns from TODO.IEEE-MUST-DO.txt
- **Category C3:** Edition abbreviation (2 patterns) - Lines 10-11
- **Category C4:** IRE parenthetical (1 pattern) - Line 9
- **Category C6:** Slash to parenthetical (1 pattern) - Line 37
- **Category C7:** AIEE month-dash (1 pattern) - Line 43 (likely already working!)
- **Category C8:** AIEE dual numbers (1 pattern) - Line 45
- **ISO/IEC TR spacing:** (1 pattern) - Line 40

**Estimated gain:** +8-12 identifiers (90.15% → 90.23-90.28%)

---

## Pattern Analysis (Remaining 17)

### Already Implemented (29 patterns) ✅

**Sessions 169-171 (18 patterns):**
- Lines 1-2, 20-21: Space normalization
- Lines 4, 22: HTML entities
- Lines 5-6, 23-24: Space/missing paren
- Line 14, 25: En-dash, IEEE/ ASTM

**Session 173 (8 patterns):**
- Lines 13, 16: Space-dash-year
- Lines 32-35: Missing "Std"
- Line 36: Space before slash
- Line 38: Publisher order
- Lines 39, 41: Comma Edition, ISO/IEC spacing
- Line 8: Semicolon dual
- Line 19: Comma dual with "and IEEE Std"

**Already Working (3 patterns):**
- Lines 7, 46: "Includes" relationship
- Line 12: & dual published
- Lines 26-31: IEEE/ASTM SI/PSI

### Remaining Implementation (17 patterns)

#### Priority 1: Edition Abbreviation (2 patterns, 45 min)

**Lines 10-11:** Normalize "Edn. (Reaff YYYY)" → "(RYYYY)"

```
!IEEE Std 802.11g-2003 (Amendment to IEEE Std 802.11, 1999 Edn. (Reaff 2003)...
 => IEEE Std 802.11g-2003 (Amendment to IEEE Std 802.11-1999 (R2003)...

!IEEE Std 802.11h-2003 (Amendment to IEEE Std 802.11, 1999 Edn. (Reaff 2003))
 => IEEE Std 802.11h-2003 (Amendment to IEEE Std 802.11-1999 (R2003))
```

**Pattern:**
- ", 1999 Edn. (Reaff 2003)" should become "-1999 (R2003)"
- Requires careful handling to avoid affecting valid text

**Implementation:** Preprocessing in Parser.parse

#### Priority 2: IRE Parenthetical (1 pattern, 45 min)

**Line 9:** Split nested IRE reference

```
!#IEEE Std 218-1956 (Reaffirmed 1980, 56 IRE 28.S2)
 => IEEE Std 218-1956 (R1980) (56 IRE 28.S2)
```

**Pattern:**
- Nested reaffirmation + IRE reference needs splitting
- "Reaffirmed 1980, 56 IRE" → "(R1980) (56 IRE"

**Implementation:** Preprocessing to split into two parentheticals

#### Priority 3: Slash to Parenthetical (1 pattern, 30 min)

**Line 37:** Convert specific slash format

```
!IEEE Std 338-1971/ANSI N41.3
 => IEEE Std 338-1971 (ANSI N41.3)
```

**Pattern:**
- Slash followed by ANSI identifier (not Revision/Amendment clause)
- Needs to be converted to parenthetical

**Implementation:** Preprocessing with pattern detection

#### Priority 4: ISO/IEC TR Spacing (1 pattern, 20 min)

**Line 40:** Add space between TR and number

```
!IEEE Std 802.1H, 1997 Edition (ISO/IEC TR11802-5:1997)
 => IEEE Std 802.1H-1997 (ISO/IEC TR 11802-5:1997)
```

**Pattern:**
- "ISO/IEC TR11802" → "ISO/IEC TR 11802"
- Missing space after TR

**Already handled:** Comma Edition normalization

#### Priority 5: AIEE Month-Dash (1 pattern, LIKELY WORKING)

**Line 43:** A.I.E.E. with month-year

```
!A.I.E.E. No. 15 May-1928
 => AIEE No 15-1928
```

**Status:** Session 171 implemented AIEE month-dash support
**Action:** Verify if already working, if not enhance AIEE parser

#### Priority 6: AIEE Dual Numbers (1 pattern, 60 min)

**Line 45:** Dual AIEE numbers

```
!AIEE Nos 72 and 73 - 1932
 => AIEE No 72-1932 and AIEE No 73-1932
```

**Pattern:**
- "Nos X and Y - YEAR" needs splitting into two identifiers
- Each gets "No" (singular) and the year

**Implementation:** Preprocessing to expand into "and" format

#### Lines 42, 44: AIEE Space Before Dash

Already handled by Session 171 preprocessing (space before dash normalization).

---

## Implementation Plan

### SESSION 174: Edition & IRE & Slash Patterns (90 min)

**Part A: Edition Abbreviation Normalization (30 min)**

Add to Parser.parse preprocessing:

```ruby
# Edition abbreviation: ", YYYY Edn. (Reaff YYYY)" → "-YYYY (RYYYY)"
# Very specific pattern to avoid false positives
cleaned = cleaned.gsub(/,\s+(\d{4})\s+Edn\.\s+\(Reaff\s+(\d{4})\)/, '-\1 (R\2)')

# Also handle without initial comma (might occur in relationships)
cleaned = cleaned.gsub(/(\d{4})\s+Edn\.\s+\(Reaff\s+(\d{4})\)/, '\1 (R\2)')
```

**Part B: IRE Parenthetical Split (30 min)**

```ruby
# Split "Reaffirmed YYYY, XX IRE" → "(RYYYY) (XX IRE"
# Must be careful with parenthesis counting
cleaned = cleaned.gsub(/\(Reaffirmed\s+(\d{4}),\s+(\d+\s+IRE[^)]+)\)/, '(R\1) (\2)')
```

**Part C: Slash to Parenthetical (20 min)**

```ruby
# Convert "number-year/ANSI identifier" → "number-year (ANSI identifier)"
# Only if slash is followed by ANSI and NOT a relationship keyword
cleaned = cleaned.gsub(%r{(\d{4})/ANSI\s+([^(]+)(?=\s*\(|$)}, '\1 (ANSI \2)')
```

**Part D: ISO/IEC TR Spacing (10 min)**

```ruby
# Add space after TR: "ISO/IEC TR11802" → "ISO/IEC TR 11802"
cleaned = cleaned.gsub(/(ISO\/IEC\s+TR)(\d)/, '\1 \2')
```

---

### SESSION 175: AIEE Patterns Verification (60 min)

**Part A: Verify AIEE Month-Dash (15 min)**

Test if line 43 already works with Session 171's AIEE enhancements.

If not working, enhance AIEE parser to handle "May-1928" format.

**Part B: AIEE Dual Numbers (45 min)**

Add to Parser.parse preprocessing:

```ruby
# AIEE dual: "Nos X and Y - YEAR" → "No X-YEAR and AIEE No Y-YEAR"
if cleaned.match?(/AIEE\s+Nos\s+(\d+)\s+and\s+(\d+)\s*-\s*(\d{4})/)
  cleaned = cleaned.sub(/AIEE\s+Nos\s+(\d+)\s+and\s+(\d+)\s*-\s*(\d{4})/) do
    "AIEE No #{$1}-#{$3} and AIEE No #{$2}-#{$3}"
  end
end
```

---

### SESSION 176: Testing & Documentation (60 min)

**Part A: Comprehensive Validation (30 min)**

```bash
cd spec/fixtures && ruby run_classify.rb ieee
```

Verify all 46 TODO patterns now passing.

**Part B: Update Documentation (30 min)**

1. Update `.kilocode/rules/memory-bank/context.md` with Sessions 173-176
2. Create session summary: `docs/old-docs/sessions/session-173-summary.md`
3. Move to old-docs:
   - `docs/SESSION-171-CONTINUATION-PLAN.md`
   - `docs/SESSION-172-CONTINUATION-PLAN.md`
   - `docs/SESSION-173-CONTINUATION-PLAN.md`
   - `docs/SESSION-173-CONTINUATION-PROMPT.md`
4. Update README.adoc IEEE section if significant

---

## Success Criteria

### Minimum Success (80%)
- ✅ 12+ TODO patterns passing (75%+ of remaining)
- ✅ IEEE at 90.17%+ (8,613+/9,552)
- ✅ No regressions

### Target Success (90%)
- ✅ 15+ TODO patterns passing (88%+ of remaining)
- ✅ IEEE at 90.20%+ (8,617+/9,552)
- ✅ Clean preprocessing

### Stretch Success (100%)
- ✅ All 17 remaining patterns passing
- ✅ IEEE at 90.23-90.28% (8,620-8,624/9,552)
- ✅ Complete TODO implementation
- ✅ Comprehensive documentation

---

## Files to Modify

### Session 174 (Preprocessing)
- `lib/pubid_new/ieee/parser.rb` - Parser.parse method (lines 750+)

### Session 175 (AIEE)
- `lib/pubid_new/ieee/parser.rb` - AIEE preprocessing
- `lib/pubid_new/ieee/aiee/parser.rb` - If month-dash enhancement needed

### Session 176 (Documentation)
- `.kilocode/rules/memory-bank/context.md` - Sessions 173-176 summary
- `docs/old-docs/sessions/session-173-summary.md` - NEW
- Move completed docs to old-docs/sessions/

---

## Architecture Principles

**MAINTAIN throughout:**
1. **Safe preprocessing** - Data quality fixes only in Parser.parse
2. **No compromises** - Correctness over pass rate
3. **Incremental** - Test after each session
4. **MODEL-DRIVEN** - Objects not strings (no identifier changes)
5. **Zero regressions** - Verify other flavors unaffected

**Key insight:** All remaining patterns solvable with preprocessing - NO parser/builder/identifier changes needed!

---

## Implementation Status Tracker

| Pattern | Lines | Category | Status | Session |
|---------|-------|----------|--------|---------|
| Space normalization | 1-2, 20-21 | Already fixed | ✅ | 169-171 |
| HTML entities | 4, 22 | Already fixed | ✅ | 169-171 |
| Space/paren fixes | 5-6, 23-24 | Already fixed | ✅ | 169-171 |
| En-dash, spacing | 14, 25 | Already fixed | ✅ | 169-171 |
| "Includes" | 7, 46 | Already working | ✅ | 171 |
| & dual published | 12 | Already working | ✅ | 171 |
| IEEE/ASTM SI/PSI | 26-31 | Already working | ✅ | Parser |
| Space-dash-year | 13, 16 | Normalization | ✅ | 173 |
| Missing "Std" | 32-35 | Normalization | ✅ | 173 |
| Space before slash | 36 | Normalization | ✅ | 173 |
| Publisher order | 38 | Normalization | ✅ | 173 |
| Comma Edition | 39, 41 | Normalization | ✅ | 173 |
| Semicolon dual | 8 | Normalization | ✅ | 173 |
| Comma dual | 19 | Normalization | ✅ | 173 |
| **Edition abbr** | **10-11** | **Preprocessing** | **⏳** | **174** |
| **IRE paren** | **9** | **Preprocessing** | **⏳** | **174** |
| **Slash paren** | **37** | **Preprocessing** | **⏳** | **174** |
| **ISO/IEC TR** | **40** | **Preprocessing** | **⏳** | **174** |
| **AIEE month** | **43** | **Verify/enhance** | **⏳** | **175** |
| **AIEE dual** | **45** | **Preprocessing** | **⏳** | **175** |
| **AIEE space** | **42, 44** | **Already fixed** | **✅** | **171** |

**Progress:** 29/46 complete (63%), 17 remaining (37%)

---

## Timeline Summary

| Session | Focus | Duration | Expected Gain |
|---------|-------|----------|---------------|
| 174 | Edition/IRE/Slash/TR | 90 min | +6-8 IDs |
| 175 | AIEE verification | 60 min | +2-4 IDs |
| 176 | Testing & docs | 60 min | Validation |
| **Total** | **Complete** | **210 min** | **+8-12 IDs** |

**Final target:** 8,619-8,623/9,552 (90.23-90.28%)

---

## Key Patterns Detail

### Edition Abbreviation (Lines 10-11)

**Current:**
```
IEEE Std 802.11, 1999 Edn. (Reaff 2003)
```

**Expected:**
```
IEEE Std 802.11-1999 (R2003)
```

**Dual normalization:**
1. `, YYYY Edn.` → `-YYYY`
2. `(Reaff YYYY)` → `(RYYYY)`

### IRE Parenthetical (Line 9)

**Current:**
```
IEEE Std 218-1956 (Reaffirmed 1980, 56 IRE 28.S2)
```

**Expected:**
```
IEEE Std 218-1956 (R1980) (56 IRE 28.S2)
```

**Split nested parenthetical** with comma separator

### Slash to Parenthetical (Line 37)

**Current:**
```
IEEE Std 338-1971/ANSI N41.3
```

**Expected:**
```
IEEE Std 338-1971 (ANSI N41.3)
```

**Convert slash to parenthetical** for adoption format

### AIEE Dual Numbers (Line 45)

**Current:**
```
AIEE Nos 72 and 73 - 1932
```

**Expected:**
```
AIEE No 72-1932 and AIEE No 73-1932
```

**Expand plural** into two separate identifiers

---

## Architecture References

**Memory Bank:**
- `.kilocode/rules/memory-bank/context.md` - Session 172-173 status
- `.kilocode/rules/memory-bank/architecture.md` - V2 architecture principles

**Continuation Plans:**
- `docs/SESSION-173-CONTINUATION-PLAN.md` - Original plan (this supersedes parts)

**Key Files:**
- `lib/pubid_new/ieee/parser.rb` - All preprocessing in Parser.parse method
- `TODO.IEEE-MUST-DO.txt` - Complete pattern list with expected outputs

---

## Next Immediate Steps (Session 174)

1. Read this continuation plan
2. Implement Edition abbreviation preprocessing (30 min)
3. Implement IRE parenthetical split (30 min)
4. Implement slash to parenthetical (20 min)
5. Implement ISO/IEC TR spacing (10 min)
6. Test: `cd spec/fixtures && ruby run_classify.rb ieee`
7. Verify gain of +6-8 identifiers
8. Commit progress

---

**Created:** 2025-12-18
**Sessions Covered:** 174-176
**Status:** Ready for execution
**Current:** 8,611/9,552 (90.15%)
**Target:** 8,619-8,623/9,552 (90.23-90.28%)

**End Goal:** TODO.IEEE-MUST-DO.txt 100% complete! 🎯