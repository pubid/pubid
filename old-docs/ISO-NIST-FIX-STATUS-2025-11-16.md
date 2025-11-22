# ISO & NIST Fix Status - 2025-11-16

## Critical Discovery: Root Cause Identified

### ISO Status: 73.97% (MAJOR PROGRESS)

**ROOT CAUSE**: Missing `parse()` method in [`PubidNew::Iso`](lib/pubid_new/iso.rb) module.

**FIX APPLIED**: Added `parse()` method following IEEE/CEN pattern:
```ruby
def self.parse(identifier)
  parser = Parser.new
  builder = Builder.new(Scheme)
  
  parsed = parser.parse(identifier)
  builder.build(parsed)
end
```

**RESULT**: ISO can now parse identifiers! Quick test shows **73.97% pass rate** (233/315 samples).

---

## Current Failure Analysis

### ISO Failures (26.03% = 82 cases)

All failures are **RENDERING issues**, not parsing issues. The parser works correctly.

#### Pattern 1: Case Sensitivity in Supplement Types
```
Input:  ISO 105-B01:1994/AMD 1:1998
Output: ISO 105-B01:1994/Amd 1:1998
        ^^^                    ^^^

Input:  ISO 105-G01:1993/COR 1:1995  
Output: ISO 105-G01:1993/Cor 1:1995
        ^^^                    ^^^

Input:  ISO 10993-18:2020/DAmd 1
Output: ISO 10993-18:2020/DAM 1
        ^^^^^                ^^^

Input:  ISO 11137-2:2013/FDAmd 1
Output: ISO 11137-2:2013/FDAM 1
        ^^^^^                ^^^^
```

**Issue**: Renderer outputs canonical form (`Amd`, `Cor`, `DAM`, `FDAM`) but fixtures use variants (`AMD`, `COR`, `DAmd`, `FDAmd`).

**Fix Location**: [`lib/pubid_new/iso/scheme.rb`](lib/pubid_new/iso/scheme.rb) - TypedStage definitions or renderer templates.

#### Pattern 2: Language Code Mapping
```
Input:  ISO 10993-4:2002/Amd.1:2006(E)
Output: ISO 10993-4:2002/Amd 1:2006(en)
                                   ^^ ^^

Input:  ISO 15002:2008/DAM 2:2020(F)
Output: ISO 15002:2008/DAM 2:2020(fr)
                                   ^^ ^^
```

**Issue**: Parser accepts single-char codes `(E)`, `(F)`, `(R)` but renderer always outputs 2-char codes `(en)`, `(fr)`, `(ru)`.

**Fix Location**: [`lib/pubid_new/iso/builder.rb`](lib/pubid_new/iso/builder.rb:227) - `LANG_CHAR_MAP` or rendering logic.

#### Pattern 3: Number Spacing Format
```
Input:  ISO 10993-4:2002/Amd.1:2006(E)
Output: ISO 10993-4:2002/Amd 1:2006(en)
                             ^ ^  (dot vs space)
```

**Issue**: Fixtures use `Amd.1` but renderer outputs `Amd 1`.

**Fix Location**: Supplement identifier renderer.

---

## Test Fixture Issues (IMPORTANT)

### Non-ISO Identifiers in fixtures/iso/

The file `spec/fixtures/iso/non-iso-identifiers.txt` contains:
- CEN identifiers (e.g., `CEN/TS 15370-1:2006`, `EN 12643:2014`)
- IEC identifiers (e.g., `IEC 31010:2019(en,fr)`, `IEC 80601-2-60`)
- **JCGM identifiers** (e.g., `JCGM 200:2007(F)`, `JCGM 200:2008(F)`)

**RECOMMENDATION**:
1. Exclude `non-iso-identifiers.txt` from ISO v2 tests
2. CEN/IEC should use their respective parsers
3. **JCGM needs a separate parser** (joint initiative, not ISO-specific)

**Action**: Update test script to exclude non-ISO fixtures:
```ruby
exclude_files = ['non-iso-identifiers.txt']
```

---

## NIST Status: 97.8% (22 failures from ~1,000 tests)

### NIST Failure Pattern 1: "sup" vs "supp" (14 cases)
```
Input:  NIST SP 800-90A sup
Output: NIST SP 800-90A supp
```
**Fix**: [`lib/pubid_new/nist/parser.rb:142`](lib/pubid_new/nist/parser.rb:142)

### NIST Failure Pattern 2: Edition-Date "e2-1915" (4 cases)
```
Input:  NIST HB 44 e2-1915
Error:  Parsing failure
```
**Fix**: Parser rule for edition followed by hyphen and year.

### NIST Failure Pattern 3: Supplement-Month "supJan1924" (4 cases)
```
Input:  NIST HB 44 supJan1924
Error:  Parsing failure
```
**Fix**: Parser rule for supplement with month abbreviation.

---

## Next Session Action Plan

### Priority 1: ISO Rendering Fixes (2-3 hours)

1. **Fix case sensitivity** in supplement types:
   - Location: [`lib/pubid_new/iso/scheme.rb`](lib/pubid_new/iso/scheme.rb)
   - Make renderer accept and preserve original casing (`AMD`/`Amd`, `COR`/`Cor`)
   - OR: Normalize fixtures to canonical forms

2. **Fix language code mapping**:
   - Location: [`lib/pubid_new/iso/builder.rb`](lib/pubid_new/iso/builder.rb:227)
   - Preserve single-char codes when parsing
   - OR: Update fixtures to use 2-char codes consistently

3. **Fix number spacing**:
   - Preserve `Amd.1` format OR normalize fixtures to `Amd 1`

4. **Update test script**:
   - Exclude `non-iso-identifiers.txt`
   - Re-run full test suite
   - Target: 100% on actual ISO identifiers

### Priority 2: NIST Fixes (2 hours)

1. Fix "sup" vs "supp" in [`parser.rb:142`](lib/pubid_new/nist/parser.rb:142)
2. Add edition-date rule for "e2-1915" pattern
3. Add supplement-month rule for "supJan1924" pattern
4. Retest: Target 100%

### Priority 3: JCGM Parser (Future Enhancement)

- JCGM (Joint Committee for Guides in Metrology) is NOT an ISO-specific format
- Should have dedicated parser similar to IDF
- Consider creating `lib/pubid_new/jcgm/` with parser, scheme, builder

---

## Architecture Lessons Learned

### The `parse()` Method Pattern
Every flavor module MUST have this structure:
```ruby
module PubidNew
  module FlavorName
    def self.parse(identifier)
      parser = Parser.new
      builder = Builder.new(Scheme)
      
      parsed = parser.parse(identifier)
      builder.build(parsed)
    end
  end
end
```

### Separation of Concerns
- **Parser**: Converts string → AST (handles MANY variations)
- **Builder**: Converts AST → Objects (canonical model)
- **Renderer**: Converts Objects → String (ONE canonical format)

**Key Insight**: Failures can be in:
1. **Parser**: Can't parse input → Error
2. **Builder**: Parses but can't build → Error  
3. **Renderer**: Builds but output ≠ input → **Most common issue**

For ISO, it's #3: Parser and builder work perfectly, but renderer outputs canonical format that differs from some fixture variations.

---

## Files Modified This Session

1. [`lib/pubid_new/iso.rb`](lib/pubid_new/iso.rb) - Added `parse()` method
2. [`test_iso_v2.rb`](test_iso_v2.rb) - Created comprehensive test script

---

## Test Results Summary

| Flavor | Status | Pass Rate | Notes |
|--------|--------|-----------|-------|
| IEC | ✅ | 100% | Complete |
| IDF | ✅ | 100% | Complete |
| CEN | ✅ | 100% | Complete |
| CCSDS | ✅ | 100% | Complete |
| JIS | ✅ | 100% | Complete |
| PLATEAU | ✅ | 100% | Complete |
| ETSI | ✅ | 100% | Complete |
| ITU | ✅ | 100% | Complete |
| BSI | ✅ | 100% | Complete |
| IEEE | ✅ | 97.8% | MVP ready (500 tests) |
| **ISO** | 🔧 | **73.97%** | Rendering issues identified |
| **NIST** | 🔧 | **97.8%** | 22 failures (sup, edition, supp-month) |

---

## Estimated Time to 100%

- **ISO**: 2-3 hours (rendering fixes)
- **NIST**: 2 hours (parser rules)
- **Total**: 4-5 hours to complete all 12 flavors