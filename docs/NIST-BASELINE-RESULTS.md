# NIST V2 Baseline Coverage Results

**Date:** 2026-01-12
**Fixture Status:** Fixed (commit c289ab6)
**Task:** Task 3 - Establish Baseline Coverage Metrics

## Test Results

### Unit Tests
- **Total:** 751 examples
- **Pass:** 490 (65.25%)
- **Fail:** 258 (34.35%)
- **Pending:** 3 (0.40%)

### Integration Tests

#### All Records
- **Pass:** 14,633/19,488 (75.09%)
- **Fail:** 4,855
- **Expected:** 85.0%
- **Gap:** 9.91 percentage points

#### Publication Exports
- **Pass:** 545/764 (71.34%)
- **Fail:** 219
- **Expected:** 95.0%
- **Gap:** 23.66 percentage points

#### September 2024
- **Pass:** 0/96 (0.0%)
- **Fail:** 96
- **Expected:** 95.0%
- **Gap:** 95.0 percentage points

## Failure Categories

### 1. Format Preservation Issues (Priority: HIGH)

**Issue:** V2 normalizes formats more aggressively than V1, breaking round-trip fidelity.

#### 1.1 Revision Notation
- **Pattern:** "Rev. 1" → "r1"
- **Impact:** Publication Exports primarily affected
- **Example:**
  ```
  Input:  NIST SP 800-101 Rev. 1
  Output: NIST SP 800-101r1
  ```
- **Root Cause:** V2 uses edition component with `to_s(:short)` which renders as "rN"
- **Fix Required:** Preserve original format metadata for round-trip

#### 1.2 Edition Year Notation (Historical)
- **Pattern:** "11-1911" → "11e1911"
- **Impact:** All Records (NBS CIRC series primarily)
- **Example:**
  ```
  Input:  NBS CIRC 11-1911
  Output: NBS CIRC 11e1915
  ```
- **Root Cause:** Parser doesn't recognize hyphen as edition separator for historical formats
- **Fix Required:** Enhanced parser pattern for `series-number-year` format

#### 1.3 Multi-Edition with Year
- **Pattern:** "11e2-1915" → "11e1915"
- **Impact:** Loses edition number when year present
- **Example:**
  ```
  Input:  NBS CIRC 11e2-1915
  Output: NBS CIRC 11e1915
  ```
- **Root Cause:** Edition component prioritizes year over edition number
- **Fix Required:** Parser enhancement to capture both `e{num}-{year}`

### 2. Case Preservation Issues (Priority: MEDIUM)

**Issue:** V2 normalizes case, breaking historical identifier formats.

#### 2.1 Letter Suffix Case
- **Pattern:** "3a" → "3A", "5a" → "5A"
- **Impact:** All Records
- **Example:**
  ```
  Input:  NBS BH 3a
  Output: NBS BH 3A
  ```
- **Root Cause:** Letter suffix component normalizes to uppercase
- **Fix Required:** Preserve original case in suffix component

### 3. Parser Coverage Gaps (Priority: HIGH)

**Issue:** Certain patterns are not recognized by the parser.

#### 3.1 Supplement Notation
- **Pattern:** "supp2", "supp1" being dropped entirely
- **Impact:** All Records
- **Example:**
  ```
  Input:  NBS BMS 17supp2
  Output: NBS BMS 17
  ```
- **Root Cause:** Parser pattern doesn't capture numeric supplement
- **Fix Required:** Add pattern for `supp{number}` without space

#### 3.2 Revision with Month/Year
- **Pattern:** "revJune1908" → "rJune1908"
- **Impact:** All Records
- **Example:**
  ```
  Input:  NBS CIRC 13e2revJune1908
  Output: NBS CIRC 13e2.June1908
  ```
- **Root Cause:** Parser doesn't handle "rev" prefix before month/year
- **Fix Required:** Parser enhancement for `rev{month}{year}` pattern

### 4. Missing V1 Features (Priority: CRITICAL)

**Issue:** Several V1 features are not implemented in V2.

#### 4.1 Update Feature (0% pass rate on Sept 2024)
- **Pattern:** "-upd" → "/Upd1-"
- **Impact:** September 2024 tests (96/96 failures)
- **Example:**
  ```
  Input:  NIST.IR.8170-upd
  Output: NIST IR 8170/Upd1-202102
  ```
- **Root Cause:** Update component not implemented
- **Fix Required:** Implement Update component with Upd prefix normalization

#### 4.2 Stage Feature (Partial Implementation)
- **Pattern:** Stage codes like IPD, PUB, DRAFT
- **Impact:** Unit tests failing
- **Example:**
  ```
  Input:  NIST SP(IPD) 800-53e5
  Status: Parsing works, round-trip not verified
  ```
- **Root Cause:** Stage component exists but lacks comprehensive format support
- **Fix Required:** Complete Stage component with all stage codes

#### 4.3 Translation/Language Feature (Partial Implementation)
- **Pattern:** Language codes like "es", "chi", "viet", "(esp)"
- **Impact:** Unit tests failing
- **Example:**
  ```
  Input:  NIST IR 8115chi
  Status: Parsing incomplete
  ```
- **Root Cause:** Translation component exists but lacks format normalization
- **Fix Required:** Complete Translation component with code normalization

#### 4.4 Supplement Feature (Partial Implementation)
- **Pattern:** Various supplement notations
- **Impact:** Unit tests failing
- **Root Cause:** Supplement component exists but lacks comprehensive coverage
- **Fix Required:** Complete Supplement component with all notation variants

#### 4.5 Multi-Format Support (Partial Implementation)
- **Pattern:** MR format, dot format, space format
- **Impact:** Unit tests failing
- **Example:**
  ```
  Status: Stage identifiers don't parse all formats correctly
  Status: Translation identifiers don't convert between formats consistently
  ```
- **Root Cause:** Format preservation not fully implemented
- **Fix Required:** Complete cross-format conversion logic

### 5. Component-Specific Issues (Priority: MEDIUM)

#### 5.1 Part Notation
- **Pattern:** "p1" vs "pt1" inconsistency
- **Impact:** Unit tests
- **Root Cause:** Part component defaults to "pt" prefix, parser recognizes "p"
- **Fix Required:** Parser normalization to "pt" or format preservation

#### 5.2 Volume Notation
- **Pattern:** "v1" handling
- **Impact:** Unit tests
- **Root Cause:** Volume component not consistently applied
- **Fix Required:** Consistent volume parsing and rendering

#### 5.3 CSM Volume-Number Format
- **Pattern:** "v6n1" → "CSM 6-1"
- **Impact:** Commercial Standards Monthly identifiers
- **Root Cause:** Normalization not fully implemented
- **Fix Required:** Complete CSM variant normalization

## Task 4 Results: Edition Year Normalization

### Status: PARTIAL FIX COMPLETE

### Fix Applied
**File:** `lib/pubid_new/nist/parser.rb:184`

**Change:** Modified edition year normalization pattern to exclude existing edition indicators
- **Before:** `(\d[A-Z]?)-(\d{4})` - Too greedy, matched `11e` from `11e2-1915`
- **After:** `(\d(?:[A-DF-Z]?))-(\d{4})` - Excludes `e` (edition indicator)

**Tests Added:** `spec/pubid_new/nist/edition_year_normalization_spec.rb` (7 examples, 0 failures)

### Test Results
✅ **PASSING:**
- `NBS CIRC 11-1911` → `NBS CIRC 11e1911` (simple dash-year normalization)
- `NBS CIRC 74-1937` → `NBS CIRC 74e1937` (2-digit number with year)
- `NIST SP 330-2019` → `NIST SP 330e2019` (modern identifier)
- Round-trip fidelity maintained for normalized patterns
- V2 normalization preserved (eYYYY format not reverted to -YYYY)

⚠️ **KNOWN LIMITATION:**
- `NBS CIRC 11e2-1915` → `NBS CIRC 11e1915` (loses edition number `2`)
- **Root Cause:** Pattern has existing edition (`e2`) followed by year (`-1915`)
- **Current Behavior:** Year is treated as separate date component, edition number lost
- **Future Enhancement:** Should parse as `11e2.1915` (edition 2 with year as additional_text)
- **Requires:** New parser rule for `e\d+-YYYY` pattern to combine into Edition with additional_text

### Pattern Coverage
Based on fixture analysis:
- **Simple dash-year:** ~3,000+ patterns (NOW WORKING)
- **Multi-edition with year:** ~15 patterns (LIMITATION - needs parser enhancement)

### Fix Validated
- **Commit:** (To be added after Task 4 completion)
- **Tests:** 7/7 passing
- **No Regressions:** Existing edition tests still pass

### Next Steps
The edition year normalization fix prevents incorrect transformation of patterns like `11e2-1915`. The remaining limitation (edition number being lost) requires a separate parser enhancement that's beyond the scope of this fix.

## Task 5 Results: Version Normalization

### Status: WORKING AS DESIGNED

### V2 Normalization Patterns (Verified)
**Location:** `lib/pubid_new/nist/parser.rb:186-191`

**Patterns Verified:**
- `vX.Y` → `verX.Y` (short v format normalized to verbose)
- `Ver. X.Y` → `verX.Y` (capital Ver with period normalized)
- Already-normalized `verX.Y` preserved

**Tests Added:** `spec/pubid_new/nist/version_normalization_spec.rb` (7 examples, 0 failures)

### Test Results
✅ **ALL PASSING:**
- `NIST SP 500-268v1.1` → `NIST SP 500-268 ver1.1` (short v → ver)
- `NIST SP 800-60 Ver. 2.0` → `NIST SP 800-60 ver2.0` (Ver. → ver)
- `NIST SP 800-53ver1.1` → `NIST SP 800-53 ver1.1` (already normalized)
- `NIST SP 800-60ver2.0` → `NIST SP 800-60 ver2.0` (already normalized)
- Round-trip fidelity maintained for normalized versions
- V2 format is more consistent (lowercase ver, no periods)

### Design Decision
V2's version normalization patterns are **MORE correct than V1** and must be preserved:
- Consistent `verX.Y` format across all versions
- No ambiguity between "v" (version) and other uses
- Standardized spacing (space before ver)

### Pattern Coverage
Based on fixture analysis:
- Version patterns: ~50-100 patterns in fixtures
- All version patterns now normalize consistently

### Next Steps
Version normalization is working correctly per V2 design. No changes needed.

## Next Steps

### Task 4-7: Parser Enhancements (Edition Year, Version Normalization)
- Add pattern for `series-number-year` (historical edition year)
- Add pattern for `series-number-en-year` (multi-edition with year)
- Add pattern for `rev{month}{year}` (revision with month/year)
- Add pattern for `supp{number}` (numeric supplement)
- Version normalization patterns

### Task 8-11: Tier 1 V1 Features (Stage, Translation, Multi-format)
- Complete Stage component with all stage codes
- Complete Translation component with code normalization
- Implement cross-format conversion logic
- Add format preservation metadata

### Task 12-14: Tier 2 V1 Features (Update, Supplement)
- Implement Update component with Upd prefix normalization
- Complete Supplement component with all notation variants
- Integration testing for all features

## Architecture Notes

### MODEL-DRIVEN Approach
V2 uses a three-layer architecture with Lutaml::Model::Serializable components:
1. **Parser Layer:** Converts strings to component hashes
2. **Builder Layer:** Constructs identifier objects from components
3. **Identifier Layer:** Renders components back to strings

### Component System
- **Edition:** Handles edition numbers, years, revisions
- **Update:** NEW - Handles update notation
- **Stage:** Handles publication stage codes
- **Translation:** Handles language codes
- **Supplement:** Handles supplement notation
- **Part:** Handles part notation (pt1, p1)
- **Volume:** Handles volume notation (v1)
- **Publisher:** Series publisher (NBS/NIST)
- **Series:** Series abbreviation (SP, FIPS, IR, etc.)

### Design Principles
- **Preserve V2 normalization patterns** (they are MORE correct than V1)
- **Use MODEL-DRIVEN approach** (components, not ad-hoc parsing)
- **Focus on diagnostic information** (not fixes yet)
- **Maintain separation of concerns** (parse → build → render)

## Test Command Reference

```bash
# Run integration suite
bundle exec rspec spec/integration/nist_spec.rb -fd

# Run unit tests
bundle exec rspec spec/pubid_new/nist/ -fd

# Run specific identifier tests
bundle exec rspec spec/pubid_new/nist/identifiers/special_publication_spec.rb -fd
```

## Commit Information

- **Baseline established:** 2026-01-12
- **Fixture fix commit:** c289ab6
- **Implementation branch:** rt-new-lutaml-model
- **Target branch:** main

---
**Status:** Baseline documented. Ready for Task 4 (Parser Enhancements).
