# Session 162 Continuation Plan: PackageIdentifier & CompositeIdentifier Implementation

**Created:** 2025-12-17 (Post-Session 161)
**Status:** Session 161 complete - Ready for package/composite patterns
**Timeline:** 120 minutes
**Priority:** HIGH - Continue MODEL-DRIVEN redesign

---

## Executive Summary

**Session 161 Achievement:** CsaAdoptedIdentifier complete (6/6 tests, 100% round-trip)

**Session 162 Objective:** Implement PackageIdentifier & CompositeIdentifier for CSA packages with materials

**Architecture Pattern:** Composite pattern where package contains collection of identifiers + package items

**Expected Gain:** +20-30 identifiers

---

## Current Status

### Session 161 Completed ✅
- CsaAdoptedIdentifier wrapper pattern working
- 6/6 test patterns with perfect round-trip
- External parser integration (ISO/IEC/CISPR)
- Year format conversion (4-digit ↔ 2-digit)
- Reaffirmation support

### CSA Architecture Status
**Implemented:**
1. ✅ WrapperIdentifier base class
2. ✅ CanadianAdoptedIdentifier (CAN/{identifier})
3. ✅ CsaAdoptedIdentifier (CSA {ISO/IEC/CISPR})
4. ✅ Standard identifier (basic CSA)
5. ✅ CombinedIdentifier (slash-separated)
6. ✅ BundledIdentifier (plus-separated)

**Pending (Session 162+):**
7. ⏳ CompositeIdentifier base (collection pattern)
8. ⏳ PackageIdentifier (package materials)
9. ⏳ SeriesIdentifier (SERIES as primary type)

---

## Session 162: PackageIdentifier Implementation

### Objective
Implement package identifiers with materials using composite pattern.

### Package Semantics

**Pattern:** `CSA {base_identifier} PACKAGE {materials}`

**Examples:**
- `CSA Z662:23 PACKAGE INCLUDES: +1 (PDF & ESA)`
- `CSA B149.1:20 PACKAGE (PDF + PRINT)`
- `CSA C22.2 NO. 60601-1:15 PACKAGE WITH ADDENDUM`

**Key Characteristics:**
- PACKAGE keyword indicates composite
- Materials describe package contents
- Base identifier is parseable CSA standard
- Package portion not a separate identifier (metadata)

### Part A: Create CompositeIdentifier Base (40 min)

**File:** `lib/pubid_new/csa/composite_identifier.rb`

**Purpose:** Base class for identifiers containing collections

**Implementation:**
```ruby
# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Csa
    # CompositeIdentifier is the base class for identifiers that contain
    # collections of other identifiers or package materials.
    #
    # Examples:
    #   - PackageIdentifier: Base + package materials
    #   - Future: BundleIdentifier refactor to use composite
    class CompositeIdentifier < Lutaml::Model::Serializable
      # The primary/base identifier
      attr_accessor :base_identifier

      # Subclasses MUST implement to_s
      def to_s
        raise NotImplementedError, "Subclasses must implement to_s method"
      end
    end
  end
end
```

### Part B: Create PackageIdentifier Class (50 min)

**File:** `lib/pubid_new/csa/identifiers/package.rb`

**Implementation:**
```ruby
# frozen_string_literal: true

require_relative "../composite_identifier"

module PubidNew
  module Csa
    module Identifiers
      # PackageIdentifier represents CSA standards sold as packages
      # with additional materials (PDF, print, addenda, etc.)
      #
      # Examples:
      #   CSA Z662:23 PACKAGE INCLUDES: +1 (PDF & ESA)
      #   CSA B149.1:20 PACKAGE (PDF + PRINT)
      #   CSA C22.2 NO. 60601-1:15 PACKAGE WITH ADDENDUM
      #
      # This is a composite pattern where:
      #   - base_identifier is the core CSA standard
      #   - package_materials describes what's included
      #   - Package portion is metadata, not a parseable identifier
      class Package < CompositeIdentifier
        # Package materials/contents description
        attribute :package_materials, :string

        # Package keyword variant (PACKAGE, PACKAGE INCLUDES:, etc.)
        attribute :package_keyword, :string

        def to_s
          result = base_identifier.to_s

          # Add package keyword (normalize to "PACKAGE")
          result += " PACKAGE"

          # Add materials if present
          if package_materials && !package_materials.empty?
            # Check if materials already include "INCLUDES:" or other prefix
            if package_materials.match?(/^(INCLUDES:|WITH|)\s*/)
              result += " #{package_materials}"
            else
              result += " INCLUDES: #{package_materials}"
            end
          end

          result
        end
      end
    end
  end
end
```

### Part C: Update Identifier.parse for Packages (25 min)

**File:** `lib/pubid_new/csa/identifier.rb`

**Detection Logic:**
```ruby
# After CSA adoption detection, before legacy handling
# Detect package identifiers
if input.match?(/\sPACKAGE\s/i)
  # Extract base identifier and package portion
  parts = input.split(/\s+PACKAGE\s+/i, 2)
  base_input = parts[0]
  package_portion = parts[1] || ""

  # Parse base identifier recursively
  base_identifier = parse(base_input)
  return nil unless base_identifier

  # Create PackageIdentifier
  require_relative "identifiers/package"
  result = Identifiers::Package.new
  result.base_identifier = base_identifier
  result.package_materials = package_portion.strip
  result.package_keyword = "PACKAGE"

  return result
end
```

### Part D: Testing & Validation (5 min)

**Test Patterns:**
```ruby
test_patterns = [
  "CSA Z662:23 PACKAGE INCLUDES: +1 (PDF & ESA)",
  "CSA B149.1:20 PACKAGE (PDF + PRINT)",
  "CSA C22.2 NO. 60601-1:15 PACKAGE WITH ADDENDUM"
]
```

**Expected:**
- Perfect round-trip on all patterns
- Base identifier correctly parsed
- Package materials preserved
- Clean object composition

---

## Implementation Status Tracker

| Task | Duration | Status | Deliverable |
|------|----------|--------|-------------|
| A. Create CompositeIdentifier | 40 min | ⏳ Pending | `composite_identifier.rb` |
| B. Create Package class | 50 min | ⏳ Pending | `identifiers/package.rb` |
| C. Update Identifier.parse | 25 min | ⏳ Pending | Detection + parsing |
| D. Testing | 5 min | ⏳ Pending | 3+ tests passing |
| **Total** | **120 min** | **READY** | **Complete** |

---

## Success Criteria

### Architectural (CRITICAL)
- ✅ CompositeIdentifier base class created
- ✅ PackageIdentifier inherits from CompositeIdentifier
- ✅ Base identifier recursively parsed
- ✅ No string manipulation, pure object composition
- ✅ Extensible for future composite types

### Functional
- ✅ 3+ package patterns with perfect round-trip
- ✅ Package materials preserved exactly
- ✅ Base identifier correct (any CSA type)
- ✅ PACKAGE keyword handling

### Expected Results
- **Baseline:** ~450/899 (50%) from Session 160
- **After Session 162:** ~470-480/899 (52-53%)
- **Improvement:** +20-30 identifiers
- **Architecture:** 7/8+ identifier types implemented

---

## Technical Notes

### Package vs Bundled

**PackageIdentifier:**
- Contains single base identifier + materials metadata
- Materials are descriptive text, not identifiers
- Example: `CSA Z662:23 PACKAGE (PDF + PRINT)`

**BundledIdentifier:**
- Contains multiple identifiers consolidated
- Each part is a parseable identifier
- Example: `CSA C22.2 NO. 60601-1:14 + A2:22 (R2022)`

### Composite Pattern Benefits

1. **Extensibility:** Easy to add new composite types
2. **Consistency:** All composite identifiers follow same pattern
3. **Type Safety:** base_identifier can be any CSA type
4. **Clean separation:** Composite logic separate from wrapped logic

---

## Files to Create

1. `lib/pubid_new/csa/composite_identifier.rb`
2. `lib/pubid_new/csa/identifiers/package.rb`

## Files to Modify

1. `lib/pubid_new/csa.rb` - Add requires
2. `lib/pubid_new/csa/identifier.rb` - Add package detection

---

## Next Session Preview

**Session 163:** SeriesIdentifier implementation (60 min)
- Implement SERIES as primary type (not just keyword)
- Target: +15-20 SERIES identifiers
- Complete CSA architecture redesign

---

## Key Architectural Principles

**MAINTAIN throughout:**
1. **MODEL-DRIVEN** - Objects not strings
2. **Composite Pattern** - Collections properly modeled
3. **Recursive Parsing** - Base identifiers fully parsed
4. **MECE** - Package ≠ Bundled (different semantics)
5. **Extensibility** - Easy to add new composite types

**NEVER:**
- Hardcode package format strings
- Skip recursive parsing for base
- Mix package and bundled logic
- Use string concatenation for rendering

---

## Quick Start (Session 162)

1. Create `lib/pubid_new/csa/composite_identifier.rb`
2. Create `lib/pubid_new/csa/identifiers/package.rb`
3. Update `lib/pubid_new/csa.rb` with requires
4. Update `lib/pubid_new/csa/identifier.rb` with detection
5. Test on 3+ package patterns
6. Commit Session 162 complete

---

**Created:** 2025-12-17
**Sessions Covered:** 162
**Status:** Ready for execution
**Estimated Time:** 120 minutes

**End Goal:** Package identifiers working perfectly with composite pattern! 🎯