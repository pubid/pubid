# Session 173+ Continuation Plan: TODO.IEEE-MUST-DO.txt Complete Implementation

**Created:** 2025-12-18 (Post-Session 172)
**Status:** IEEE at 90.02%, TODO file needs full implementation
**Priority:** HIGH - Complete all 46 TODO patterns
**Timeline:** COMPRESSED - 3-4 sessions (240-300 minutes)

---

## Executive Summary

**Session 172 Result:** IEEE at 8,599/9,552 (90.02%) with month period support

**TODO.IEEE-MUST-DO.txt Analysis:**
- **Total patterns:** 46 identifiers
- **Already fixed:** 18 patterns (preprocessing in Sessions 169-171) ✅
- **Already working:** 3 patterns (Includes, &, IEEE/ASTM SI/PSI) ✅
- **Need implementation:** 25 patterns across 8 categories

**Estimated gain:** +20-25 identifiers (90.02% → 90.2-90.3%)

---

## Pattern Analysis

### Category A: Already Fixed (18 patterns) ✅

Lines 1-2, 20-21, 4, 22, 5-6, 23-24, 14, 25: Preprocessing fixes from Sessions 169-171
- Space before/after dash
- HTML entities (&#x2122;, &#x2013;, &amp;)
- IEEE/ ASTM spacing

### Category B: Already Working (3 patterns) ✅

- Line 7, 46: "Includes" relationship (Session 171)
- Line 12: & dual published (Session 171)
- Lines 26-31: IEEE/ASTM SI/PSI (parser rule exists)

### Category C: Need Implementation (25 patterns)

#### C1: Preprocessing Fixes (12 patterns, 30 min)

**Lines 13, 16:** Space-dash-year normalization
```
IEEE Std 802.16g 2007 → IEEE Std 802.16g-2007
802.1ag - 2007 → 802.1ag-2007
```

**Lines 32-35:** Add missing "Std" prefix
```
IEEE 1070-1995 → IEEE Std 1070-1995
IEEE 278-1967 → IEEE Std 278-1967
IEEE 730-1989 → IEEE Std 730-1989
IEEE 751-1991 → IEEE Std 751-1991
```

**Line 36:** Slash spacing
```
IEEE Std 262-1973 /ANSI → IEEE Std 262-1973/ANSI
```

**Line 38:** Publisher order
```
IEEE Std ANSI/IEEE → ANSI/IEEE Std
```

**Lines 39-41:** Comma before Edition + ISO spacing
```
802.1G, 1998 Edition → 802.1G-1998
ISO/IEC15802-5 → ISO/IEC 15802-5
```

**Lines 42, 44:** AIEE space before dash (already handled?)
```
AIEE No 1E -1957 → AIEE No 1E-1957
AIEE No 45 -1951 → AIEE No 45-1951
```

#### C2: Semicolon Dual Published (1 pattern, 30 min)

**Line 8:** Convert semicolon to parenthetical
```
IEEE Std 120-1955; ASME PTC 19.6-1955 →
IEEE Std 120-1955 (ASME PTC 19.6-1955)
```

Implementation: Preprocessing in Parser.parse

#### C3: Edition Abbreviation (2 patterns, 45 min)

**Lines 10-11:** Normalize "Edn. (Reaff YYYY)" → "(RYYYY)"
```
1999 Edn. (Reaff 2003) → 1999 (R2003)
```

Implementation: Preprocessing with careful pattern matching

#### C4: IRE in IEEE Parenthetical (1 pattern, 45 min)

**Line 9:** Complex nested parenthetical
```
IEEE Std 218-1956 (Reaffirmed 1980, 56 IRE 28.S2) →
IEEE Std 218-1956 (R1980) (56 IRE 28.S2)
```

Implementation: Parser enhancement or Base.parse special handling

#### C5: Comma Dual Published (1 pattern, 30 min)

**Line 19:** Convert comma to "and"
```
IEEE Std 960-1989, Std 1177-1989 →
IEEE Std 960-1989 and IEEE Std 1177-1989
```

Implementation: Preprocessing

#### C6: Slash Format Parenthetical (1 pattern, 30 min)

**Line 37:** Convert slash to parenthetical
```
IEEE Std 338-1971/ANSI N41.3 →
IEEE Std 338-1971 (ANSI N41.3)
```

Implementation: Detect pattern, convert format

#### C7: AIEE Month-Dash Format (1 pattern, 45 min)

**Line 43:** A.I.E.E. with month-year
```
A.I.E.E. No. 15 May-1928 → AIEE No 15-1928
```

Implementation: Already supported! AIEE parser handles this (Session 171)

#### C8: AIEE Dual Numbers (1 pattern, 60 min)

**Line 45:** Dual AIEE numbers
```
AIEE Nos 72 and 73 - 1932 →
AIEE No 72-1932 and AIEE No 73-1932
```

Implementation: AIEE parser or Base.parse special handling

---

## Implementation Plan

### SESSION 173: Preprocessing Enhancements (90 min)

**Part A: Simple Normalizations (30 min)**

Add to Parser.parse preprocessing:

```ruby
# Missing dash before year (space-year)
cleaned = cleaned.gsub(/(\d)\s+(\d{4})\b/, '\1-\2')  # "802.16g 2007" → "802.16g-2007"

# Space-dash-space before year
cleaned = cleaned.gsub(/\s+-\s+(\d{4})\b/, '-\1')  # "802.1ag - 2007" → "802.1ag-2007"

# Add missing "Std" after IEEE
cleaned = cleaned.gsub(/^IEEE\s+(\d)/, 'IEEE Std \1')  # "IEEE 1070" → "IEEE Std 1070"

# Space before slash
cleaned = cleaned.gsub(/\s+\//, '/')  # "262-1973 /ANSI" → "262-1973/ANSI"

# Comma before Edition
cleaned = cleaned.gsub(/,\s+(\d{4})\s+Edition/, '-\1')  # ", 1998 Edition" → "-1998"

# ISO/IEC number spacing
cleaned = cleaned.gsub(/(ISO\/IEC)(\d)/, '\1 \2')  # "ISO/IEC15802" → "ISO/IEC 15802"
```

**Part B: Publisher Order (20 min)**

```ruby
# IEEE Std ANSI/IEEE → ANSI/IEEE Std
cleaned = cleaned.gsub(/^IEEE\s+Std\s+(ANSI\/IEEE)/, '\1 Std')
```

**Part C: Semicolon & Comma Dual (20 min)**

```ruby
# Semicolon to parenthetical for dual published
if cleaned.match?(/;\s+[A-Z]+\s+/)
  cleaned = cleaned.sub(/;\s+([A-Z][^;]+)$/, ' (\1)')
end

# Comma-separated dual: "Std 960-1989, Std 1177" → "and"
cleaned = cleaned.gsub(/(\d{4}),\s+(Std\s+\d)/, '\1 and \2')
```

**Part D: Testing (20 min)**

Run classification, verify gain.

---

### SESSION 174: Edition & IRE Patterns (90 min)

**Part A: Edition Abbreviation Normalization (45 min)**

```ruby
# "1999 Edn. (Reaff 2003)" → "1999 (R2003)"
cleaned = cleaned.gsub(/(\d{4})\s+Edn\.\s+\(Reaff\s+(\d{4})\)/, '\1 (R\2)')

# Also handle without space: "1999Edn.(Reaff2003)"
cleaned = cleaned.gsub(/(\d{4})Edn\.\(Reaff(\d{4})\)/, '\1 (R\2)')
```

**Part B: IRE Parenthetical (45 min)**

Two approaches:
1. **Preprocessing:** Convert "Reaffirmed YYYY, IRE" → "(RYYYY) (IRE)"
2. **Parser:** Enhance parenthetical rule to handle comma-separated content

Recommendation: Preprocessing
```ruby
# "Reaffirmed 1980, 56 IRE" → "(R1980) (56 IRE"
cleaned = cleaned.gsub(/\(Reaffirmed\s+(\d{4}),\s+(\d+\s+IRE[^)]+)\)/, '(R\1) (\2)')
```

---

### SESSION 175: AIEE Dual Numbers (60 min)

**Objective:** Handle "Nos X and Y" pattern

**Approach:** Preprocessing to split into two identifiers

```ruby
# "AIEE Nos 72 and 73 - 1932" → "AIEE No 72-1932 and AIEE No 73-1932"
if cleaned.match?(/AIEE\s+Nos\s+(\d+)\s+and\s+(\d+)\s*-\s*(\d{4})/)
  num1, num2, year = cleaned.match(/Nos\s+(\d+)\s+and\s+(\d+)\s*-\s*(\d{4})/).captures
  cleaned = cleaned.sub(/Nos\s+\d+\s+and\s+\d+\s*-\s*\d{4}/, "No #{num1}-#{year} and AIEE No #{num2}-#{year}")
end
```

---

### SESSION 176: Testing & Documentation (60 min)

**Part A: Comprehensive Testing (30 min)**

```bash
cd spec/fixtures && ruby run_classify.rb ieee
```

Verify all 46 TODO patterns passing.

**Part B: Update Documentation (30 min)**

1. Update README.adoc IEEE section
2. Move SESSION-171, SESSION-172 to old-docs/
3. Update memory bank context.md
4. Mark TODO.IEEE-MUST-DO.txt complete

---

## Success Criteria

### Minimum Success (80%)
- ✅ 20+ TODO patterns passing
- ✅ IEEE at 90.15%+ (8,612+/9,552)
- ✅ No regressions

### Target Success (90%)
- ✅ 40+ TODO patterns passing (87%)
- ✅ IEEE at 90.2%+ (8,617+/9,552)
- ✅ Clean preprocessing

### Stretch Success (100%)
- ✅ All 46 TODO patterns passing
- ✅ IEEE at 90.3%+ (8,622+/9,552)
- ✅ Complete documentation

---

## Files to Modify

### Session 173 (Preprocessing)
- `lib/pubid_new/ieee/parser.rb` - Parser.parse method (lines 658-745)

### Session 174 (Edition/IRE)
- `lib/pubid_new/ieee/parser.rb` - Additional preprocessing

### Session 175 (AIEE Dual)
- `lib/pubid_new/ieee/parser.rb` - AIEE-specific preprocessing

### Session 176 (Documentation)
- `README.adoc` - IEEE section update
- `.kilocode/rules/memory-bank/context.md` - Sessions 172-176
- Move to `docs/old-docs/sessions/`:
  - SESSION-171-CONTINUATION-PLAN.md
  - SESSION-172-CONTINUATION-PLAN.md

---

## Architecture Principles

**MAINTAIN throughout:**
1. **Safe preprocessing** - Data quality fixes only in Parser.parse
2. **No compromises** - Correctness over pass rate
3. **Incremental** - Test after each session
4. **MODEL-DRIVEN** - Objects not strings (no changes to identifier classes)
5. **Zero regressions** - Verify other flavors unaffected

**Key insight:** All 25 remaining patterns can be solved with preprocessing - NO parser/builder/identifier changes needed!

---

## Timeline Summary

| Session | Focus | Duration | Expected Gain |
|---------|-------|----------|---------------|
| 173 | Preprocessing batch 1 | 90 min | +8-10 IDs |
| 174 | Edition & IRE | 90 min | +5-7 IDs |
| 175 | AIEE dual | 60 min | +1-2 IDs |
| 176 | Testing & docs | 60 min | Validation |
| **Total** | **Complete** | **300 min** | **+14-19 IDs** |

**Actual expected:** 90.02% → 90.17-90.22% (8,613-8,620/9,552)

---

**Created:** 2025-12-18
**Sessions Covered:** 173-176
**Status:** Ready for execution
**Current:** 8,599/9,552 (90.02%)

**End Goal:** TODO.IEEE-MUST-DO.txt 100% complete, IEEE 90.2%+ 🎯