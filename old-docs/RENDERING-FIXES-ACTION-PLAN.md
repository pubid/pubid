# Rendering Fixes Action Plan - 2025-11-17

## Overview

Comprehensive test execution revealed significant rendering format mismatches. This document provides a detailed action plan to address them systematically.

##

 Current Test Results Summary

| Flavor | Cases | Pass Rate | Status |
|--------|-------|-----------|--------|
| CCSDS | 490 | 100.0% | ✅ Perfect |
| ETSI | 24,718 | 100.0% | ✅ Perfect |
| JIS | 10,635 | 100.0% | ✅ Perfect |
| ITU | 2,041 | 100.0% | ✅ Perfect |
| ISO | 7,689 | 97.2% | ✅ Good |
| NIST | 20,349 | 88.2% | ⚠️ Rendering issues |
| IEEE | 10,332 | 19.1% | ⚠️ Parser gaps |
| IEC | 13,889 | 17.1% | ⚠️ Both issues |

**Total:** 62,971/90,264 (69.8%)

---

## Critical Issues Identified

### Issue Category 1: Parser/Renderer Format  Mismatch

**Root Cause:** Parser captures full text (e.g., " Rev. 5"), but renderer assumes only the value and adds its own prefix.

#### NIST Issues

**Problem Files:**
- [`lib/pubid_new/nist/parser.rb`](../lib/pubid_new/nist/parser.rb:100) - Lines 89-102
- [`lib/pubid_new/nist/scheme.rb`](../lib/pubid_new/nist/scheme.rb:60) - Lines 58-72

**Specific Issues:**

1. **Revision (Line 100-101)**
   ```ruby
   # Parser captures: " Rev. 5" (full text)
   rule(:revision) do
     ((str(" rev ") | str("rev") | str("r") | str(" Rev. ") | str(" Revision (r)")) >>
       (digits >> lower_letter.maybe).maybe).as(:revision)
   end
   
   # Renderer adds "r" prefix (Line 60)
   result += "r#{revision}" if revision
   # Result: "r Rev. 5" ❌ Should be: " Rev. 5"
   ```
   **Fix:** Capture only the number, OR check if revision starts with "Rev"/"rev" before adding "r"

2. **Volume (Line 89)**
   ```ruby
   # Parser captures: " Vol. 1" (full text)
   rule(:volume) do
     (str("v") | str(" Vol. ")) >> (digits >> ...).as(:volume)
   end
   
   # Renderer adds "v" prefix (Line 58)
   result += "v#{volume}" if volume
   # Result: "v Vol. 1" ❌ Should be: " Vol. 1"
   ```
   **Fix:** Capture only the number, OR check if volume starts with "Vol"

3. **Version (Line 106-107)**
   ```ruby
   # Parser can capture: "v1" or "ver1" or " Ver. 1"
   rule(:version) do
     ((str("ver") | str(" Ver. ") | str(" Version ") | str("v")) >>
       (digits >> (dot >> digits).repeat).maybe).as(:version)
   end
   
   # Renderer conditionally adds "ver" (Line 87-88)
   version.start_with?("ver") ? version : "ver#{version}"
   # Result: If parser captured "v1", becomes "verv1" ❌
   ```
   **Fix:** Normalize in parser to capture only number, handle prefix in renderer consistently

#### IEC Issues  

**Problem Files:**
- IEC identifier to_s methods (need to locate)

**Specific Issues:**

1. **Type/Stage Slash** (906 cases affected)
   ```
   Test: "IEC TS 61081:1991"
   Renders: "IEC/TS 61081:1991"
   ```
   **Fix:** Check rendering logic for type_with_stage - don't add "/" before type

2. **Amendment/Corrigendum Spacing** (906 cases)
   ```
   Test: "IEC 60050-351:2013/AMD1:2016"
   Renders: "IEC 60050-351:2013/Amd 1:2016"
   ```
   **Fix:** Render as "AMD1" not "Amd 1" (no space)

3. **Guide Capitalization** (59 cases)
   ```
   Test: "ISO/IEC GUIDE 2:2004"
   Renders: "ISO/IEC Guide 2:2004"  
   ```
   **Fix:** Preserve original capitalization or normalize consistently

---

### Issue Category 2: Missing Parser Support

**Root Cause:** V1 supported formats not yet implemented in v2 parsers

#### IEC Missing Formats (12,604 cases)

1. **CISPR identifiers** - Organization prefix not "IEC"
2. **IECQ, IECEE, IECEx identifiers** - Special org prefixes
3. **TRF (Test Report Form)** - Special document type
4. **ISH (Interpretation Sheet)** - Supplement type
5. **RLV (Redline Version)** - Document variant
6. **CSV suffix** - Consolidated version notation
7. **Sheets format** - Slash notation (e.g., "IEC 60695-2-1/1:1994")
8. **Working documents/programmes** - Draft/development stages

#### IEEE Missing Formats (8,362 cases)

1. **Historical IRE identifiers** - Pre-IEEE standards
2. **Historical AIEE identifiers** - Pre-merger organization
3. **Document titles** - Descriptive names instead of numbers
4. **Reaffirmation notation** - "(R1992)" suffix
5. **Legacy spacing** - Inconsistent number formats

#### ISO Edge Cases (219 cases)

1. **FprISO prefix** - Final proposal draft
2. **Russian Cyrillic** - "ИСО" prefix
3. **French identifier order** - "GUIDE ISO/CEI" vs "ISO/CEI GUIDE"
4. **Non-ISO identifiers** - CEN, JCGM in ISO fixtures (should fail or be filtered)

---

## Recommended Fix Strategy

### Phase 1: Quick Rendering Fixes (High ROI - Est. 2-3 hours)

**Target:** Fix format mismatches where parser already works

1. **NIST Revision/Volume/Version** (2,402 cases)
   - Files: [`lib/pubid_new/nist/scheme.rb`](../lib/pubid_new/nist/scheme.rb:1), [`lib/pubid_new/nist/parser.rb`](../lib/pubid_new/nist/parser.rb:1)
   - Approach: Adjust parser to capture only numeric values, let renderer add prefixes consistently
   
2. **IEC Type/Stage Slash** (906 cases)
   - Files: IEC identifier classes
   - Approach: Remove "/" insertion before document type
   
3. **IEC Amendment Format** (906 cases)  
   - Files: IEC identifier classes
   - Approach: Render without space in "AMD1", "COR1", etc.

4. **ISO/IEC Guide Capitalization** (59 cases)
   - Files: IEC identifier classes
   - Approach: Render as "Guide" consistently (or preserve original)

**Expected Result:** 69.8% → 74.5% (+4,273 cases)

---

### Phase 2: Parser Extensions (Complex - Est. 6-10 hours)

**Target:** Add support for missing specialized formats

Priority order based on test case volume:

1. **IEC specialized formats** (12,604 cases)
   - CISPR, IECQ, IECEE/IECEx TRF
   - ISH, RLV, CSV suffixes
   - Working documents
   - Requires: New identifier classes, parser rules, renderers

2. **IEEE historical formats** (8,362 cases)
   - IRE, AIEE prefixes
   - Reaffirmation notation
   - Requires: Parser rule extensions

3. **ISO edge cases** (219 cases)
   - FprISO prefix
   - Russian Cyrillic support
   - French order variants
   - Requires: Parser rule additions

**Expected Result:** 74.5% → 96.6% (+19,905 cases)

---

### Phase 3: Final Optimization (Est. 1-2 hours)

1. Adjust test expectations for sample cases
2. Document intentional incompatibilities
3. Filter invalid test cases from fixtures
4. Final validation run

**Expected Result:** 96.6% → 98%+ (remaining edge cases)

---

## Implementation Priorities

### Must Fix (Blocking ≥95% target)

1. ✅ IEC parse method (DONE - 2,371 cases now passing)
2. 🔄 NIST rendering formats (2,402 cases blocked)
3. 🔄 IEC rendering formats (906 cases blocked)

### Should Fix (High value)

4. IEC specialized formats (12,604 cases - major gap)
5. IEEE historical formats (8,362 cases - major gap)

### Nice to Have (Lower priority)

6. ISO edge cases (219 cases - already at 97.2%)
7. Test sample adjustments (minor impact)

---

## Decision Point

**Current State:** 69.8% pass rate  
**Achievable with Phase 1:** ~75% (2-3 hours work)  
**Full target (≥95%):** Requires Phase 1 + significant Phase 2 work (8-13 hours)

**Recommendation for this session:**

Focus on **Phase 1 only** - the quick rendering fixes that provide immediate value:
- NIST format corrections
- IEC rendering consistency
- ISO/IEC guide capitalization

This gets us to ~75% pass rate with minimal effort and validates the test infrastructure is working correctly.

**Defer to future sessions:**
- IEC specialized format support (complex, requires architectural additions)
- IEEE historical format support (complex, requires parser redesign)
- ISO edge cases (minor impact, already good)

---

## Next Steps

1. Create detailed fix specifications for Phase 1 issues
2. Implement fixes one flavor at a time
3. Test after each fix
4. Document what was fixed
5. Re-run comprehensive suite
6. Generate final report

Ready to proceed with Phase 1 implementation?