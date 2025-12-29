# Session 226+ Continuation Plan: CSA Comprehensive Spec Development

**Created:** 2025-12-29 (Post-Session 225)
**Status:** CSA at 97.34% - Ready for comprehensive spec development
**Timeline:** COMPRESSED - Complete in 2-3 sessions (4-6 hours)

---

## Executive Summary

**Current CSA Status:**
- **Fixtures:** 879/903 (97.34%) ✅
- **Specs:** 0/12 files (0%) - NONE EXIST YET
- **Implementation:** Complete and working
- **Architecture:** MODEL-DRIVEN, MECE, Three-layer

**Objective:** Create 12 comprehensive spec files for complete test coverage

---

## CSA Identifier Architecture

### Identifier Classes (8 total)

**Core Types:**
1. **Standard** (SingleIdentifier) - Basic CSA standards
   - Examples: `CSA B149.1:20`, `CSA C22.1-15`, `CSA 15189HB:25`
   - Attributes: code, no_number, year, year_format, reaffirmation, HB suffix

2. **Series** - SERIES as primary type
   - Examples: `CSA Z240 MH SERIES:16`, `CSA SERIES Z1000:22`
   - Attributes: series_prefix (MH, RV), code, year

3. **Bundled** - Consolidated with + notation
   - Examples: `CSA C22.2 NO. 60601-1:14 + A2:22 (R2022) (CONSOLIDATED)`
   - Attributes: base, bundled_with (array), reaffirmation

4. **Combined** - Multiple identifiers with / or comma
   - Examples: `CSA A23.1:24/CSA A23.2:24`, `CSA B149.1:25, CSA B149.2:25`
   - Attributes: first, second, third, separator (/ or ,)

**Wrapper Types:**
5. **CanadianAdopted** - CAN/CSA- or CAN3- prefix
   - Examples: `CAN/CSA-C22.2 NO. 1-04 (R2009)`, `CAN3-A451.1-M86 (R2001)`
   - Attributes: wrapped_identifier, reaffirmation, prefix format

6. **CsaAdopted** - CSA adoption of international standards
   - Examples: `CSA ISO/IEC TR 19758:04 (R2024)`, `CSA IEC 61000-4-2:12`
   - Attributes: wrapped_identifier (ISO/IEC), reaffirmation

7. **Package** - Standards with package notation
   - Examples: `CSA B149.1:25 Code, Handbook & Training Package`
   - Attributes: base_identifier, package_materials, package_keyword

**Legacy Support:**
8. **Base** - Abstract base class for common attributes

---

## SESSION 226: Core Identifier Specs (120 minutes)

### Objective
Create specs for 4 core identifier types (Standard, Series, Bundled, Combined).

### Part A: Standard Identifier Spec (30 min)

**File:** `spec/pubid_new/csa/identifiers/standard_spec.rb`

**Test Coverage (~25-30 tests):**
```ruby
require "spec_helper"

RSpec.describe PubidNew::Csa::Identifiers::Standard do
  subject { described_class }

  context "basic standards" do
    # Colon year format (6 tests)
    it "CSA B149.1:20" - code, colon year
    it "CSA B149.3:25" - code, colon year  
    it "CSA C22.1:24" - code with dot, colon year
    
    # Dash year format (3 tests)
    it "CSA C22.1-15" - code, dash year
    it "CSA C22.1-18" - code, dash year
    
    # Year prefixes (3 tests)
    it "CSA B149.1:F20" - F prefix (French)
    it "CSA A123.17-05 (R2019)" - reaffirmation
  end

  context "NO. notation" do
    # C22.2 NO. patterns (5 tests)
    it "CSA C22.2 NO. 286:23" - code + NO. number + colon year
    it "CSA C22.2 NO. 1-04 (R2009)" - with reaffirmation
    it "CSA C22.2 NO. 60601-1:14" - complex NO. number
  end

  context "HB (Handbook) suffixes" do
    # NEW: HB patterns (6 tests)
    it "CSA C22.1HB-18" - letter+number+HB, dash year
    it "CSA C22.1CIICHB-18" - multi-letter suffix
    it "CSA B149HB:15" - letter+number+HB, colon year
    it "CSA 15189HB:25" - pure number+HB (NEW fix)
    it "B651HB-18" - code-only (no CSA prefix)
  end

  context "rendering" do
    # Round-trip tests (3 tests)
    it "preserves colon format"
    it "preserves dash format"
    it "preserves HB suffix"
  end
end
```

**Expected:** 25-30 tests

---

### Part B: Series Identifier Spec (25 min)

**File:** `spec/pubid_new/csa/identifiers/series_spec.rb`

**Test Coverage (~20 tests):**
- Series with prefix: `CSA Z240 MH SERIES:16`
- Series without prefix: `CSA SERIES Z1000:22`
- Year formats (colon vs dash)
- Reaffirmation support
- Round-trip tests

---

### Part C: Bundled Identifier Spec (30 min)

**File:** `spec/pubid_new/csa/identifiers/bundled_spec.rb`

**Test Coverage (~25 tests):**
- Single bundle: `CSA C22.2 NO. 60601-1:14 + A2:22`
- Multiple bundles: `CSA ... + A1:15 + A2:21`
- CONSOLIDATED notation
- Reaffirmation on bundled
- Recursive base parsing
- Round-trip tests

---

### Part D: Combined Identifier Spec (35 min)

**File:** `spec/pubid_new/csa/identifiers/combined_spec.rb`

**Test Coverage (~30 tests):**
- Slash separator: `CSA A23.1:24/CSA A23.2:24`
- Comma separator: `CSA B149.1:25, CSA B149.2:25`
- Three-way: `CSA X/Y/Z`
- With package: `... & Training Package`
- Reaffirmation
- Round-trip tests (must preserve separator)

---

## SESSION 227: Wrapper & Component Specs (120 minutes)

### Objective
Create specs for wrapper identifiers and components.

### Part A: CanadianAdopted Spec (30 min)

**File:** `spec/pubid_new/csa/identifiers/canadian_adopted_spec.rb`

**Test Coverage (~25 tests):**
- CAN/CSA- prefix: `CAN/CSA-C22.2 NO. 1-04 (R2009)`
- CAN3- prefix: `CAN3-A451.1-M86 (R2001)`
- Wrapper with Combined identifier
- Wrapper with Bundled identifier
- Reaffirmation handling
- Round-trip (preserve CAN/CSA- vs CAN3-)

---

### Part B: CsaAdopted Spec (30 min)

**File:** `spec/pubid_new/csa/identifiers/csa_adopted_spec.rb`

**Test Coverage (~25 tests):**
- ISO/IEC TR: `CSA ISO/IEC TR 19758:04 (R2024)`
- ISO/IEC TS: Similar patterns
- With amendments: `/A1:06`
- 2-digit to 4-digit year conversion
- Reaffirmation
- Round-trip tests

---

### Part C: Package & Series Specs (30 min each)

**Files:**
- `spec/pubid_new/csa/identifiers/package_spec.rb`
- Already covered series in Session 226

---

### Part D: Code Component Spec (30 min)

**File:** `spec/pubid_new/csa/components/code_spec.rb`

**Test Coverage (~20 tests):**
- Letter + number: `B149`
- Dotted: `C22.2`
- Pure numeric + HB: `15189HB`
- Complex NO. numbers
- Value extraction

---

## SESSION 228: Module & Integration Specs (90 minutes)

### Objective
Create parser, builder, and integration specs.

### Part A: Parser Spec (30 min)

**File:** `spec/pubid_new/csa/parser_spec.rb`

**Test Coverage (~30 tests):**
- Code patterns (all variants)
- Year formats (colon, dash, 2-digit, 4-digit)
- NO. keyword
- Series patterns
- Bundled patterns
- Combined patterns
- HB suffix patterns

---

### Part B: Builder Spec (30 min)

**File:** `spec/pubid_new/csa/builder_spec.rb`

**Test Coverage (~25 tests):**
- build_single
- build_series
- build_bundled
- build_combined
- Year conversion (2-digit → 4-digit)
- Publisher prefix handling

---

### Part C: Integration Spec (30 min)

**File:** `spec/pubid_new/csa/identifier_spec.rb`

**Test Coverage (~40 tests):**
- Parse → render round-trip for all types
- Real-world examples from fixtures
- Edge cases
- Error handling

---

## Implementation Status Tracker

| Session | Files | Tests | Status | Notes |
|---------|-------|-------|--------|-------|
| 226 | 4 identifier specs | ~100 | ⏳ TODO | Core types |
| 227 | 4 wrapper/component specs | ~100 | ⏳ TODO | Wrappers |
| 228 | 3 module specs | ~95 | ⏳ TODO | Integration |
| **Total** | **12 spec files** | **~295** | **⏳ TODO** | **Complete** |

---

## Success Criteria

### Minimum (80%)
- ✅ All 12 spec files created
- ✅ 235+ tests implemented
- ✅ 80%+ passing
- ✅ Standard, Series, Bundled working

### Target (90%)
- ✅ 265+ tests implemented
- ✅ 90%+ passing
- ✅ All identifier types covered
- ✅ Components tested

### Stretch (95%+)
- ✅ 295+ tests implemented
- ✅ 95%+ passing
- ✅ Edge cases covered
- ✅ Parser limitations documented

---

## Key Implementation Patterns

### Test Structure (from IEC/ISO patterns)
```ruby
context "description" do
  describe "CSA B149.1:20" do
    subject { "CSA B149.1:20" }
    let(:parsed) { PubidNew::Csa.parse(subject) }

    it "parses as Standard" do
      expect(parsed).to be_a(PubidNew::Csa::Identifiers::Standard)
    end

    it "parses code" do
      expect(parsed.code.value).to eq("B149.1")
    end

    it "parses year" do
      expect(parsed.year).to eq("2020")
    end

    it "uses colon format" do
      expect(parsed.year_format).to eq("colon")
    end

    it "round-trips" do
      expect(parsed.to_s).to eq(subject)
    end
  end
end
```

### Critical CSA-Specific Tests

**1. Year Format Preservation:**
- Colon: `CSA B149.1:20` → `:20` (must preserve)
- Dash: `CSA C22.1-15` → `-15` (must preserve)

**2. 2-Digit Year Conversion:**
- Input: `:25` → Stored: `2025` → Rendered: `:25`
- Input: `-18` → Stored: `2018` → Rendered: `-18`

**3. Publisher Prefix Preservation:**
- `CAN/CSA-` vs `CSA-` vs `CSA` (must preserve exact format)

**4. HB Suffix Handling:**
- `C22.1HB`, `C22.1CIICHB`, `15189HB` (must preserve)

---

## Architecture Principles

**MAINTAIN throughout:**
1. **MODEL-DRIVEN** - Objects not strings
2. **MECE** - 8 mutually exclusive identifier types
3. **Three-layer** - Parser/Builder/Identifier independence
4. **Round-trip fidelity** - Parse → render preserves exact format
5. **Component reuse** - Code component shared across types

---

## Files to Create

### Session 226
1. `spec/pubid_new/csa/identifiers/standard_spec.rb`
2. `spec/pubid_new/csa/identifiers/series_spec.rb`
3. `spec/pubid_new/csa/identifiers/bundled_spec.rb`
4. `spec/pubid_new/csa/identifiers/combined_spec.rb`

### Session 227
5. `spec/pubid_new/csa/identifiers/canadian_adopted_spec.rb`
6. `spec/pubid_new/csa/identifiers/csa_adopted_spec.rb`
7. `spec/pubid_new/csa/identifiers/package_spec.rb`
8. `spec/pubid_new/csa/components/code_spec.rb`

### Session 228
9. `spec/pubid_new/csa/parser_spec.rb`
10. `spec/pubid_new/csa/builder_spec.rb`
11. `spec/pubid_new/csa/identifier_spec.rb`

### Documentation
12. Create spec directory: `mkdir -p spec/pubid_new/csa/{identifiers,components}`

---

## Next Steps

**Immediate (Session 226):**
1. Read this plan
2. Create spec directory structure
3. Implement Part A-D (4 core identifier specs)
4. Run tests and validate
5. Commit progress

**Then (Session 227):**
- Implement wrapper and component specs
- Validate comprehensive coverage

**Finally (Session 228):**
- Module-level specs
- Integration tests
- Mark CSA COMPLETE

---

**Created:** 2025-12-29
**Sessions Covered:** 226-228
**Status:** Ready for execution
**Estimated Time:** 330 minutes (5.5 hours compressed)

**End Goal:** CSA 100% spec coverage, 80-95% test pass rate, comprehensive validation! 🎯
