# Session 218+ Continuation Plan: Complete OIML, NIST, IEEE to 100%

**Created:** 2025-12-28 (Post-Session 217 - CIE Complete)
**Status:** CIE at 100%, ready for final flavor enhancements
**Timeline:** 3-4 sessions (6-8 hours total)
**Priority:** Required for project completion

---

## Executive Summary

**Session 217 Achievement:** CIE at 100% (341/341) + Validation infrastructure complete

**Current V2 Status:**
- **14 flavors at 100%** (Perfect)
- **2 flavors at 99%+** (Excellent: NIST 99.96%, ISO 99.01%)
- **1 flavor at 97%** (Very Good: CSA 97.23%)
- **1 flavor at 95%** (Good: OIML 94.92%)
- **1 flavor at 90%** (Good: IEEE 90.17%)

**Remaining Work:**
1. OIML: 3 failures → 100% (Session 218)
2. NIST: 7 failures → 100% (Session 219)
3. IEEE: 121 TODO identifiers + parser enhancements (Sessions 220-221)

**Target:** All 19 flavors at 99-100%

---

## SESSION 218: OIML Complete to 100% (60 minutes)

### Objective
Fix 3 OIML failures to achieve 100% (59/59)

### Failures Analysis

**1. Short Amendment Format (2 identifiers):**
```
OIML D 2 Amendment Edition 2004 (E)
OIML D 2 Amendment: 2004 (E)
```
**Pattern:** `Amendment Edition YYYY` and `Amendment: YYYY` (without year in parentheses)
**Current:** Parser expects `Amendment (YYYY) to BASE`
**Fix needed:** Support short forms without "to BASE" clause

**2. Subpart Pattern (1 identifier):**
```
OIML R 134-2: 2004 (E)
```
**Pattern:** Number-part-subpart with space before year `134-2: 2004`
**Current:** Parser expects `134-2:2004` (no space)
**Fix needed:** Make space before year optional

### Implementation Plan

**Part A: Amendment Short Forms (30 min)**

**File:** `lib/pubid_new/oiml/parser.rb`

Add short amendment patterns:
```ruby
rule(:amendment_short_edition) do
  str("OIML") >> space >> doc_type_code >>
  space >> digits.as(:base_number) >>
  (dash >> digits.as(:base_part)).maybe >>
  space >> str("Amendment") >>
  (space >> str("Edition") | str(":")).as(:amd_sep) >>
  space >> year_digits.as(:year) >>
  language_portion.maybe
end

rule(:identifier) do
  amendment_identifier |
  amendment_short_edition |  # NEW: Before annex
  annex_letter_identifier |
  annex_identifier |
  base_identifier
end
```

**Builder update:**
```ruby
# In determine_class
if parsed_hash[:amd_sep]  # Short amendment format
  require_relative "identifiers/amendment"
  return Identifiers::Amendment
end
```

**Part B: Space Before Year (20 min)**

**File:** `lib/pubid_new/oiml/parser.rb`

Make space optional:
```ruby
rule(:date_with_space) do
  (colon | (str("Edition") >> space | str("edition") >> space)) >>
  space.maybe >>  # Space is optional
  year_digits.as(:year)
end
```

**Part C: Testing (10 min)**

```bash
cd spec/fixtures && ruby run_classify.rb oiml
```

**Expected:** 59/59 (100%)

---

## SESSION 219: NIST Complete to 100% (60 minutes)

### Objective
Fix 7 NIST unknown failures to achieve 100% (19,827/19,827)

### Failures Analysis

All 7 are edge cases with typos or unusual formats:

**1. Space in IR Number (2 identifiers):**
```
NBS IR 80-2073 2  # Space before supplement number
NBS IR 80-2073 3
```
**Pattern:** `IR 80-2073 2` (space instead of dash)
**Fix:** Preprocessing to remove/normalize extra space

**2. Typo in Revision (1 identifier):**
```
NIST IR 4743rJun1992  # Missing space after "r"
```
**Pattern:** `4743rJun1992` should be `4743r Jun1992`
**Fix:** Preprocessing to insert space before month

**3. Suffix Letter (1 identifier):**
```
NIST IR 6529-a  # Lowercase letter suffix
```
**Pattern:** `-a` suffix (not part number)
**Fix:** Add suffix support to parser

**4. Invalid Format (3 identifiers):**
```
NISTPUB 0413171251         # Missing space, not a real series
NBS.CIRC.154suprev         # Typo in "sup" (should be supplement?)
NIST CSWP 9NIST.HB.135e2022-upd1  # Corrupted concatenation
```
**Fix:** These are data quality issues - mark as normalizations

### Implementation Plan

**Part A: Preprocessing Fixes (20 min)**

**File:** `lib/pubid_new/nist/parser.rb`

Add preprocessing:
```ruby
def self.parse(string)
  cleaned = string.strip

  # Fix space in IR numbers: "80-2073 2" -> "80-2073-2"
  cleaned = cleaned.gsub(/(\d{2}-\d{4})\s+(\d)/, '\1-\2')

  # Fix missing space before month: "4743rJun" -> "4743r Jun"
  cleaned = cleaned.gsub(/r([A-Z][a-z]{2}\d{4})/, 'r \1')

  new.parse(cleaned)
end
```

**Part B: Suffix Support (20 min)**

Add suffix rule:
```ruby
rule(:letter_suffix) do
  dash >> match("[a-z]").as(:suffix)
end

rule(:report_number) do
  digits.as(:number) >> letter_suffix.maybe
end
```

**Part C: Data Quality (10 min)**

Mark invalid formats as normalizations in fixtures

**Part D: Testing (10 min)**

```bash
cd spec/fixtures && ruby run_classify.rb nist
```

**Expected:** 19,827/19,827 (100%)

---

## SESSION 220: IEEE TODO Identifiers Analysis (90 minutes)

### Objective
Analyze 121 TODO identifiers and categorize by pattern

### Categories (from TODO file)

**Category 1: AIEE/ASA Historical (10 identifiers)**
- Patterns already implemented in Sessions 133
- May need minor enhancements

**Category 2: IEEE/ASTM SI/PSI (6 identifiers)**
- SI = Système International
- PSI = Proposed SI (draft)
- New document types needed

**Category 3: Dual Published with Semicolon (2 identifiers)**
```
IEEE Std 120-1955; ASME PTC 19.6-1955
```

**Category 4: Complex Amendments (15 identifiers)**
- "as amended by" clauses
- Multiple amendments listed
- Long relationship descriptions

**Category 5: Conformance Documents (8 identifiers)**
```
IEEE Std 1904.1/Conformance01-2014
```

**Category 6: Data Quality Issues (30+ identifiers)**
- HTML entities: `&amp;`, `&x2122;` (trademark)
- Typos: `Stad`, missing spaces, extra spaces
- Corrupted text

**Category 7: Joint Development Advanced (20 identifiers)**
- ISO/IEC/IEEE patterns
- Complex copublisher formats

**Category 8: Misc Edge Cases (30 identifiers)**
- `/INT` interpretations
- Redline versions
- Special notations

### Analysis Task

**Part A:** Group all 121 identifiers by category
**Part B:** Prioritize by impact (high-impact = many IDs with similar pattern)
**Part C:** Estimate effort per category
**Part D:** Create implementation roadmap

**Output:** Detailed analysis document

---

## SESSION 221: IEEE High-Impact Fixes (120 minutes)

### Objective
Implement top 3 high-impact patterns to improve IEEE significantly

### Strategy

Based on Session 220 analysis, implement patterns that affect most identifiers:

**Priority 1:** Data quality preprocessing (30+ IDs)
**Priority 2:** IEEE/ASTM SI/PSI (6 IDs)
**Priority 3:** Conformance documents (8 IDs)

**Expected improvement:** IEEE 90.17% → 92-93%

---

## Implementation Status Tracker

| Session | Focus | Files | Est. Gain | Target | Status |
|---------|-------|-------|-----------|--------|--------|
| 217 | CIE enhancement | 7 files | +8 | 100% | ✅ Complete |
| 218 | OIML fixes | parser, builder | +3 | 100% | ⏳ Planned |
| 219 | NIST fixes | parser, preprocessing | +7 | 100% | ⏳ Planned |
| 220 | IEEE analysis | analysis doc | - | - | ⏳ Planned |
| 221 | IEEE fixes | parser, identifiers | +50-100 | 92-93% | ⏳ Planned |

---

## Success Criteria

### Minimum Success (95%)
- ✅ OIML at 100% (59/59)
- ✅ NIST at 100% (19,827/19,827)
- ✅ IEEE at 92%+ (8,763+/9,552)

### Target Success (98%)
- ✅ All 19 flavors at 95%+
- ✅ 16+ flavors at 99-100%
- ✅ IEEE at 93-94%

### Stretch Success (99%)
- ✅ 18 flavors at 99-100%
- ✅ IEEE at 95%+
- ✅ Overall at 99%+

---

## Key Architectural Principles

**MAINTAIN throughout:**
1. **MODEL-DRIVEN** - Objects not strings
2. **MECE** - Mutually exclusive, collectively exhaustive
3. **Three-layer** - Parser/Builder/Identifier independence
4. **Preprocessing** - Data quality fixes acceptable
5. **No compromises** - Architecture quality first

---

## Files to Modify

### Session 218 (OIML)
- `lib/pubid_new/oiml/parser.rb` - Amendment short forms, space handling
- `lib/pubid_new/oiml/builder.rb` - Amendment detection

### Session 219 (NIST)
- `lib/pubid_new/nist/parser.rb` - Preprocessing, suffix support
- Test with all 7 unknown identifiers

### Session 220 (IEEE Analysis)
- `docs/IEEE_TODO_ANALYSIS.md` - NEW: Comprehensive pattern analysis

### Session 221 (IEEE Implementation)
- `lib/pubid_new/ieee/parser.rb` - High-impact patterns
- `lib/pubid_new/ieee/identifiers/si_standard.rb` - NEW
- `lib/pubid_new/ieee/identifiers/conformance.rb` - NEW

---

## Next Steps (Session 218)

1. Read this continuation plan
2. Fix OIML amendment short forms
3. Fix OIML space before year
4. Test and verify 59/59 (100%)
5. Commit progress

---

**Created:** 2025-12-28
**Sessions Covered:** 218-221
**Status:** Ready for execution
**Estimated Time:** 6-8 hours (compressed)

**End Goal:** All flavors at 99-100%, IEEE enhanced to 92%+, project complete! 🎉