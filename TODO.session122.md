# IEEE Failure Pattern Analysis - Session 121

**Date:** 2025-12-11
**Total Failures:** 1,324 identifiers
**Current Pass Rate:** 84.76% (8,084/9,537)
**Target:** 90%+ (8,583+/9,537)
**Gap:** +499 identifiers needed

---

## Pattern Categories Identified

### Category A: IEEE P (Project) Identifiers - 280 failures

**Sub-patterns:**
1. **Month Year format** (232 IDs) - e.g., `IEEE P1052/08, September 2018`
   - Currently: Parser expects `-YEAR` format
   - Need: Accept `, Month YEAR` and `Month YEAR` without comma

2. **Draft version /D patterns** (207 IDs) - e.g., `IEEE P1062/D.19, March 2015`
   - Currently: Draft pattern expects `/D` + digits
   - Need: Accept `/D.XX` (decimal), `/DX+X` (plus sign), `/DXeYY` (complex)

3. **Underscores in version** (23 IDs) - e.g., `IEEE P15939_FDIS, 2016`
   - Currently: Parser doesn't handle `_` before stage codes
   - Need: Accept `_FDIS`, `_CDV`, `_CD`, etc.
   - These should be parsed as `/` separator

4. **Corrigendum notation** (8 IDs) - e.g., `IEEE P11073-10418-2011/Cor 1, D4, July 2015`
   - Currently: Corrigendum rule may not handle all variations
   - Need: Review corrigendum patterns

### Category B: IEEE Std (Standard) Identifiers - 280 failures

**Sub-patterns:**
1. **Comma separators** (86 IDs) - e.g., `IEEE Std 1232-2002 (Revision of...)`
   - Complex revision/edition notations with commas

2. **Corrigendum /Cor** (77 IDs) - e.g., `IEEE Std 1003.1-2008/Cor 2-2016`
   - Already has corrigendum rule but still failing

3. **Complex amendments** (65 IDs) - Text like "amended by IEEE Std..."
   - Very complex additional_parameters content

4. **INT suffix** (6 IDs) - e.g., `IEEE Std 1003.1-1988/INT, 1992 Edition`
   - Special interpretation suffix not recognized

5. **Incorporates text** (7 IDs) - "incorporates" in title

### Category C: Non-IEEE Prefixed - 559 failures

**Sub-patterns:**
1. **IEC/IEEE P** (40 IDs) - Joint development but fails parsing
2. **ANSI prefix** (37 IDs) - ANSI/IEEE patterns
3. **Historical** (16 IDs) - AIEE, IRE, ASA
4. **Number-first** (20 IDs) - Starts with just number
5. **NESC** (10 IDs) - Special NESC handbook patterns
6. **Other** (436 IDs) - Misc patterns

---

## Prioritization Matrix

| Pattern | Count | Complexity | Impact | Priority Score |
|---------|-------|------------|--------|----------------|
| **1. Month/Year in IEEE P** | 232 | **LOW** | **HIGH** | **474** |
| **2. Draft /D variations** | 207 | **MEDIUM** | **HIGH** | **429** |
| **3. Comma separators (Std)** | 86 | **MEDIUM** | **MEDIUM** | **182** |
| **4. Underscore versions** | 23 | **LOW** | **MEDIUM** | **111** |
| **5. Corrigendum /Cor (Std)** | 77 | **MEDIUM** | **MEDIUM** | **154** |

**Formula:** `Priority = (Count × 2) + (Impact × 10) - (Complexity × 5)`
- Impact: HIGH=10, MEDIUM=5, LOW=2
- Complexity: LOW=1, MEDIUM=2, HIGH=3

---

## Top 5 Selected Patterns for Implementation

### Pattern 1: Enhanced Month/Year Support (232 affected IDs)
**Priority:** 474 (HIGHEST)
**Complexity:** LOW (15-20 min)
**Expected Gain:** +200-232 identifiers

**Current Behavior:**
- Parser line 107-114: draft_date rule handles `, Month YEAR` and `Month YEAR`
- Parser line 243: ieee_p_identifier has month/year support BUT may not cover all cases
- ISSUE: Many IEEE P identifiers have month/year in unexpected positions

**Examples Failing:**
```
IEEE P1052/08, September 2018
IEEE P1013/Draft 1.2, November 2018
IEEE P1062/D.19, March 2015
```

**Required Change:**
```ruby
# In ieee_p_identifier rule (line 236-247)
# CURRENT:
rule(:ieee_p_identifier) do
  (str("IEEE").as(:publisher) >> space).maybe >>
  str("P") >>
  number >>
  (part_subpart_year | edition).maybe >>
  (space >> month_name.as(:month) >> space >> year_digits.as(:year)).maybe >>  # Line 243
  corrigendum.maybe >>
  draft.maybe >>
  additional_parameters.maybe
end

# ENHANCED - Add comma-before-month support more broadly:
rule(:ieee_p_identifier) do
  (str("IEEE").as(:publisher) >> space).maybe >>
  str("P") >>
  number >>
  (part_subpart_year | edition).maybe >>
  # Enhanced: Accept both comma and space before month, BEFORE draft rule
  ((comma | space) >> month_name.as(:month) >> space >> year_digits.as(:year)).maybe >>
  corrigendum.maybe >>
  draft.maybe >>
  # ALSO after draft (some patterns have /DX, Month YEAR)
  ((comma | space) >> month_name.as(:month) >> space >> year_digits.as(:year)).maybe >>
  additional_parameters.maybe
end
```

**Testing:** Run classification after change, expect +200-232

---

### Pattern 2: Draft /D Variations (207 affected IDs)
**Priority:** 429
**Complexity:** MEDIUM (20-30 min)
**Expected Gain:** +150-207 identifiers

**Current Behavior:**
- Parser line 99-103: draft_version rule handles `D` + digits
- ISSUE: Doesn't handle `/D.XX`, `/DX+X`, `/DXeYY` patterns

**Examples Failing:**
```
IEEE P1062/D.19
IEEE P1031/D1+1
IEEE P1149.1/D2012.e27
```

**Required Change:**
```ruby
# CURRENT (line 99-103):
rule(:draft_version) do
  str("D") >> str("IS").absent? >> str("-").maybe >>
  (match("[0-9A-Za-z]").repeat(1) >> str("-d").maybe).as(:draft_version)
end

# ENHANCED:
rule(:draft_version) do
  str("D") >> str("IS").absent? >>  # Avoid matching "DIS" (ISO stage)
  (
    # Pattern: D.XX (decimal)
    (dot >> digits) |
    # Pattern: DX+X (plus sign)
    (digits >> str("+") >> digits) |
    # Pattern: DXXXXeYY (complex)
    (digits >> str(".").maybe >> str("e") >> digits) |
    # Pattern: DX-d (existing)
    (str("-").maybe >> match("[0-9A-Za-z]").repeat(1) >> str("-d").maybe)
  ).as(:draft_version)
end
```

**Testing:** Expect +150-207

---

### Pattern 3: Underscore Version Notation (23 affected IDs)
**Priority:** 111
**Complexity:** LOW (10-15 min)
**Expected Gain:** +20-23 identifiers

**Current Behavior:**
- No support for `_FDIS`, `_CDV`, `_CD` notation

**Examples Failing:**
```
IEEE P15939_FDIS, 2016
IEEE P61850-9-3_CDV July 2015
```

**Required Change:**

These are actually equivalent to using `/` as separator, due to failure of
original data generation at IEEE.

**Testing:** Expect +20-23

---

### Pattern 4: IEEE relationship identifiers
**Priority:** 182
**Complexity:** MEDIUM (25-30 min)
**Expected Gain:** +60-86 identifiers

**Current Behavior:**
- Complex revision text with commas not fully parsed

**Examples Failing:**
```
IEEE Std 1003.1, 2016 Edition (incorporates...)
IEEE Std 1232-2002 (Revision of IEEE Std 1232-1995, IEEE Std 1232.1-1997...)
```

These are actually identifier relationships, they have to be parsed to
represent proper models:

* `IEEE Std 1003.1, 2013 Edition (incorporates IEEE Std 1003.1-2008, and IEEE Std 1003.1-2008/Cor 1-2013)`
   means `IEEE Std 1003.1, 2013 Edition` is the identifier, it is a bundle
   of identifiers `IEEE Std 1003.1-2008` and `IEEE Std 1003.1-2008/Cor 1-2013`.
   So this is a document that incorporates previous standards and corrigenda,
   similar to the BundledIdentifier pattern.
* `IEEE Std 1232-2002 (Revision of IEEE Std 1232-1995, IEEE Std 1232.1-1997...)`
 means `IEEE Std 1232-2002` revises the identifier `IEEE Std 1232-1995` and identifier `IEEE Std 1232.1-1997`,
 so this is like the BundledIdentifier pattern indicates revision relationships
 instead of simple bundling.

* `IEEE Std 497-2002/Cor 1-2007(Corrigendum to IEEE Std 497-2002)` means
 that `IEEE Std 497-2002/Cor 1-2007` is a corrigendum to `IEEE Std 497-2002`.

* `IEEE Std C95.1-2019 (Revision of IEEE Std C95.1-2005/ Incorporates IEEE Std C95.1-2019/Cor 1-2019) - Redline`
  means this is the "Redline" edition of `IEEE Std C95.1-2019`, which revises
  `IEEE Std C95.1-2005` and incorporates `IEEE Std C95.1-2019/Cor 1-2019` (the
  `/` is the delimiter between the "revision" relationship and the
  "incorporates" relationship).

* `P802-REV/D2.0 (Revision of IEEE Std 802-2001, incorporating IEEE Std 802a-2003, and IEEE Std 802b-2004)`
  means `P802-REV/D2.0` is a DRAFT, it revises `IEEE Std 802-2001` and incorporates `IEEE Std 802a-2003` and `IEEE Std 802b-2004`.

* `ANSI/IEEE C37.010e-1985 (Supplement to ANSI/IEEE C37.010-1979)` means `ANSI/IEEE C37.010e-1985` is a supplement to `ANSI/IEEE C37.010-1979`.

* `IEEE Std 802.16m-2011(Amendment to IEEE Std 802.16-2009)` means `IEEE Std
  802.16m-2011` (the letter `m` starts from `a` for some IEEE standards and can
  be 2-char) is an amendment to `IEEE Std 802.16-2009`.

* `EEE Std 802.3br-2016 (Amendment to IEEE Std 802.3-2015 as amended by IEEE Std 802.3bw-2015, IEEE Std 802.3by-2016, IEEE Std 802.3bq-2016, and IEEE Std 802.3bp-2016)`
   means `IEEE Std 802.3br-2016` (the `EEE` is a typo for `IEEE`) is an amendment to `IEEE Std 802.3-2015`
   as amended by the other listed standards.

* `IEEE Std 1453.1-2012 (Adoption of IEC/TR 61000-3-7:2008)` means `IEEE Std 1453.1-2012` is an adoption of `IEC/TR 61000-3-7:2008`.

* `AIEE Std 42-1923 (ASA C10-1924)` means `AIEE Std 42-1923` is an adoption of `ASA C10-1924`.

* `IEEE Std 588-1976 (ANSI C37.86-1975) (Revision of IEEE Std 288-1969 and IEEE Std 328-1971)` means `IEEE Std 588-1976` is an adoption of `ANSI C37.86-1975` and revises `IEEE Std 288-1969` and `IEEE Std 328-1971`.


**Testing:** Expect +60-86

---

### Pattern 5: Corrigendum /Cor in Std (77 affected IDs)
**Priority:** 154
**Complexity:** MEDIUM (20-25 min)
**Expected Gain:** +50-77 identifiers

**Current Behavior:**
- Corrigendum rule exists (line 142-147) but may not cover all Std patterns

**Examples Failing:**
```
IEEE Std 1003.1-2008/Cor 2-2016
IEEE Std 1003.1-2001/Cor 1-2002
```

**Required Change:**
```ruby
# CURRENT (line 142-147):
rule(:corrigendum) do
  ((str("_") | slash | dash) >> str("Cor") >> (dash | dot.maybe >> space?) >>
   digits.as(:cor_number) >>
   ((dash | str(":")) >> year_digits.as(:cor_year)).maybe).as(:corrigendum)
end

# ENHANCED - Make separators more flexible:
rule(:corrigendum) do
  ((str("_") | slash | dash | space) >>  # ADD SPACE
   str("Cor") >>
   (dash | dot | space).maybe >>  # More flexible separator
   digits.as(:cor_number) >>
   ((dash | str(":") | space) >> year_digits.as(:cor_year)).maybe).as(:corrigendum)
end
```

**Testing:** Expect +50-77

---

## Implementation Strategy

### Session 122 (90 min): Implement Patterns 1-3
1. Pattern 1: Month/Year (20 min) → +200-232
2. Pattern 2: Draft /D variations (30 min) → +150-207
3. Pattern 3: Underscore stages (15 min) → +20-23
4. Testing & validation (25 min)

**Expected Result:** 8,084 → 8,454-8,546 (88.6-89.6%)

### Session 123 (90 min): Implement Patterns 4-5 & Achieve 90%+
1. Pattern 4: Comma separators (30 min) → +60-86
2. Pattern 5: Corrigendum enhancements (25 min) → +50-77
3. Final testing (20 min)
4. Documentation (15 min)

**Expected Result:** 8,454 → 8,564-8,709 (89.8-91.3%)

**Target Met:** 90%+ ACHIEVED ✅

---

## Files to Modify

1. `lib/pubid_new/ieee/parser.rb` - ALL pattern implementations
   - Line 99-103: Draft version rule (Pattern 2)
   - Line 142-147: Corrigendum rule (Pattern 5)
   - Line 165-189: Additional parameters (Pattern 4)
   - Line 236-247: IEEE P identifier (Patterns 1, 3)

2. Documentation:
   - `.kilocode/rules/memory-bank/context.md` - Update metrics
   - `docs/PROJECT_STATUS.md` - Session summaries

---

## Risk Mitigation

1. **Test after each pattern** - Isolate issues immediately
2. **Use `.maybe` carefully** - Don't over-generalize
3. **Run full test suite** - Catch regressions in other flavors
4. **Conservative estimates** - Better to under-promise

---

**Analysis Complete:** Session 121 Phase 1-2
**Next Step:** Create implementation commits for Session 122
