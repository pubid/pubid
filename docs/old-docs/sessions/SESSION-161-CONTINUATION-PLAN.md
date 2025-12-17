# Session 161 Continuation Plan: CsaAdoptedIdentifier Implementation

**Created:** 2025-12-17 (Post-Session 160)
**Status:** Session 160 complete - Ready for CSA adoption wrappers
**Timeline:** 90 minutes
**Priority:** HIGH - Continue MODEL-DRIVEN redesign

---

## Executive Summary

**Session 160 Achievement:** CanadianAdoptedIdentifier wrapper pattern complete (10/10 tests, 100%)

**Session 161 Objective:** Implement CsaAdoptedIdentifier for CSA adoptions of ISO/IEC/CISPR standards

**Architecture Pattern:** Wrapper pattern where CSA wraps external standards (ISO/IEC, CISPR, etc.)

**Expected Gain:** +100-150 identifiers

---

## Current Status

### Session 160 Completed ✅
- WrapperIdentifier base class created
- CanadianAdoptedIdentifier working perfectly
- Format preservation (CSA- vs CSA) working
- Reaffirmation handling fixed
- 10/10 CAN/ patterns with perfect round-trip

### CSA Architecture Status
**Implemented:**
1. ✅ WrapperIdentifier base class
2. ✅ CanadianAdoptedIdentifier (CAN/{identifier})
3. ✅ Standard identifier (basic CSA)
4. ✅ CombinedIdentifier (slash-separated)

**Pending (Session 161+):**
5. ⏳ CsaAdoptedIdentifier (CSA {ISO/IEC/CISPR})
6. ⏳ PackageIdentifier (composite pattern)
7. ⏳ BundleIdentifier (PACKAGE keyword)
8. ⏳ SeriesIdentifier (SERIES as primary type)

---

## Session 161: CsaAdoptedIdentifier Implementation

### Objective
Implement CSA adoptions of international standards as proper wrapper pattern.

### Key Semantic Distinction

**CanadianAdopted vs CsaAdopted:**
- **CanadianAdopted:** `CAN/{CSA standard}` - Canadian adoption of CSA standards
- **CsaAdopted:** `CSA {ISO/IEC/CISPR standard}` - CSA adoption of international standards

### Part A: Create CsaAdoptedIdentifier Class (30 min)

**File:** `lib/pubid_new/csa/identifiers/csa_adopted.rb`

**Implementation:**
```ruby
# frozen_string_literal: true

require_relative "../wrapper_identifier"

module PubidNew
  module Csa
    module Identifiers
      # CsaAdoptedIdentifier represents CSA adoption of international standards
      # (ISO, IEC, ISO/IEC, CISPR, etc.)
      #
      # Examples:
      #   CSA ISO/IEC TR 12785-3:15
      #   CSA ISO/IEC TR 19758:04 (R2024)
      #   CSA CISPR 16-1-1:18
      #
      # Key difference from CanadianAdopted:
      #   - CsaAdopted wraps ISO/IEC/CISPR standards (external)
      #   - CanadianAdopted wraps CSA standards (internal)
      class CsaAdopted < WrapperIdentifier
        def to_s
          # Wrapped identifier is ISO/IEC/CISPR (external standard)
          result = "CSA #{wrapped_identifier}"
          result += " (R#{reaffirmation})" if reaffirmation
          result
        end
      end
    end
  end
end
```

**Testing:**
- Create unit tests for basic rendering
- Test with ISO/IEC TR patterns
- Test with CISPR patterns
- Test with reaffirmation

### Part B: Update Identifier.parse for CSA Adoptions (40 min)

**File:** `lib/pubid_new/csa/identifier.rb`

**Detection Logic:**
```ruby
# After CAN/ detection, before legacy handling
# Detect CSA adoption of international standards
if input.match?(/^CSA (ISO\/IEC|CISPR|IEC|CEI|ISO)\s/)
  # This is CSA adoption of international standard
  # Extract the wrapped standard portion
  wrapped_input = input.sub(/^CSA\s+/, "")

  # Extract reaffirmation FIRST (before parsing)
  reaffirm_year = nil
  if wrapped_input =~ /\(R(\d{4})\)/
    reaffirm_year = $1
    wrapped_input = wrapped_input.sub(/\s*\(R\d{4}\)/, "")
  end

  # Parse with appropriate flavor parser
  wrapped_identifier = parse_external_standard(wrapped_input)
  return nil unless wrapped_identifier

  # Create CsaAdoptedIdentifier wrapper
  require_relative "identifiers/csa_adopted"
  result = Identifiers::CsaAdopted.new
  result.wrapped_identifier = wrapped_identifier
  result.reaffirmation = reaffirm_year if reaffirm_year

  return result
end

# Helper method for parsing external standards
def self.parse_external_standard(input)
  # Try ISO/IEC first (most common)
  if input.match?(/^(ISO\/IEC|ISO|IEC|CEI)\s/)
    require_relative "../iso"
    return PubidNew::Iso.parse(input) rescue nil
  end

  # Try CISPR
  if input.match?(/^CISPR\s/)
    # CISPR is handled by IEC flavor
    require_relative "../iec"
    return PubidNew::Iec.parse(input) rescue nil
  end

  nil
end
```

**Key Challenges:**
1. Year format: CSA adoptions use 2-digit years (`:15` not `:2015`)
2. External parsing: Need to parse with ISO/IEC/CISPR parsers
3. Error handling: External parsers may fail

### Part C: Handle 2-Digit Year Rendering (15 min)

**Strategy:** CSA adoptions preserve 2-digit year format from source

**Options:**
1. **Transform before parsing:** Convert `:04` to `:2004` before calling ISO parser
2. **Transform after rendering:** Parse normally, convert year in CsaAdopted.to_s
3. **Custom wrapper:** Wrap external standard and override year rendering

**Recommended:** Option 2 (transform after rendering)

**Implementation in CsaAdopted:**
```ruby
def to_s
  base_str = wrapped_identifier.to_s

  # Convert 4-digit years to 2-digit for CSA adoption format
  # ISO/IEC TR 12785-3:2015 → ISO/IEC TR 12785-3:15
  if base_str =~ /:(\d{4})\b/
    year = $1
    if year.start_with?("20")
      short_year = year[2..3]
      base_str = base_str.sub(":#{year}", ":#{short_year}")
    end
  end

  result = "CSA #{base_str}"
  result += " (R#{reaffirmation})" if reaffirmation
  result
end
```

### Part D: Testing & Validation (5 min)

**Test Patterns:**
```ruby
test_patterns = [
  "CSA ISO/IEC TR 12785-3:15",
  "CSA ISO/IEC TR 19758:04 (R2024)",
  "CSA CISPR 16-1-1:18",
  "CSA ISO/IEC 61010-1:14 (R2019)",
  "CSA IEC 60601-1:08",
  "CSA ISO 9001:15"
]
```

**Validation:**
- Perfect round-trip on all patterns
- External standards correctly parsed
- Year format correct (2-digit)
- Reaffirmation working

---

## Implementation Status Tracker

| Task | Duration | Status | Deliverable |
|------|----------|--------|-------------|
| A. Create CsaAdopted class | 30 min | ⏳ Pending | `csa_adopted.rb` |
| B. Update Identifier.parse | 40 min | ⏳ Pending | Detection + parsing |
| C. Year format handling | 15 min | ⏳ Pending | 2-digit rendering |
| D. Testing | 5 min | ⏳ Pending | 6+ tests passing |
| **Total** | **90 min** | **READY** | **Complete** |

---

## Success Criteria

### Architectural (CRITICAL)
- ✅ CsaAdopted inherits from WrapperIdentifier
- ✅ Wraps external standards as objects (ISO/IEC/CISPR)
- ✅ Recursive parsing via external flavor parsers
- ✅ No string manipulation, pure object composition
- ✅ MECE with CanadianAdopted

### Functional
- ✅ 6+ CSA adoption patterns with perfect round-trip
- ✅ Year format correct (2-digit)
- ✅ Reaffirmation working
- ✅ ISO/IEC TR patterns working
- ✅ CISPR patterns working
- ✅ Error handling for unparseable externals

### Expected Results
- **Baseline:** ~450/899 (50%) from Session 159
- **After Session 161:** ~550-600/899 (61-67%)
- **Improvement:** +100-150 identifiers
- **Architecture:** 5/8+ identifier types implemented

---

## Technical Notes

### External Parser Integration

**ISO/IEC Standards:**
- Use `PubidNew::Iso.parse()`
- Handles ISO, IEC, ISO/IEC, CEI prefixes
- Returns ISO identifier objects

**CISPR Standards:**
- Use `PubidNew::Iec.parse()`
- CISPR is part of IEC system
- Returns IEC identifier objects

### Year Format Conversion

**CSA Adoption Format:**
- `:04` = year 2004
- `:15` = year 2015
- `:24` = year 2024

**ISO/IEC Format:**
- `:2004` = year 2004
- `:2015` = year 2015
- `:2024` = year 2024

**Strategy:** Parse as 4-digit, render as 2-digit

### Error Handling

**External parse failures:**
- If ISO/IEC parser fails, return nil
- Identifier.parse will skip and continue
- Fallback to legacy CSA parsing if needed

---

## Files to Create

1. `lib/pubid_new/csa/identifiers/csa_adopted.rb`

## Files to Modify

1. `lib/pubid_new/csa.rb` - Add require for csa_adopted
2. `lib/pubid_new/csa/identifier.rb` - Add CSA adoption detection

---

## Next Session Preview

**Session 162:** PackageIdentifier + CompositeIdentifier base (120 min)
- Implement composite pattern for packages with materials
- Target: +20-30 package identifiers
- Architecture: Collection of identifiers + package items

---

## Key Architectural Principles

**MAINTAIN throughout:**
1. **MODEL-DRIVEN** - Objects not strings
2. **Wrapper Pattern** - External standards wrapped as objects
3. **Recursive Parsing** - Use external flavor parsers
4. **MECE** - CsaAdopted ≠ CanadianAdopted
5. **Semantic Correctness** - Architecture > test count

**NEVER:**
- String prefix manipulation
- Skip wrapper pattern for "simplicity"
- Hardcode external standard formats
- Mix CanadianAdopted and CsaAdopted logic

---

## Quick Start (Session 161)

1. Create `lib/pubid_new/csa/identifiers/csa_adopted.rb`
2. Update `lib/pubid_new/csa.rb` with require
3. Update `lib/pubid_new/csa/identifier.rb` with detection
4. Add `parse_external_standard` helper method
5. Test on 6+ CSA adoption patterns
6. Commit Session 161 complete

---

**Created:** 2025-12-17
**Sessions Covered:** 161
**Status:** Ready for execution
**Estimated Time:** 90 minutes

**End Goal:** CSA adoptions of ISO/IEC/CISPR working perfectly with wrapper pattern! 🎯