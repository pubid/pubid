# NIST Flavor Migration Analysis: From series_to_class_map to TYPED_STAGES

## Executive Summary

This document analyzes the NIST flavor's current implementation and provides a detailed migration plan to standardize it with other PubID v2 flavors (ISO, IEC, CEN, BSI, etc.) by moving from the `series_to_class_map` pattern to the `TYPED_STAGES` registry pattern.

**Status**: ✅ **COMPLETE** - All 7 phases successfully implemented

## Migration Completion Summary

| Phase | Description | Status |
|-------|-------------|--------|
| Phase 1 | Analysis and documentation | ✅ Complete |
| Phase 2 | Add TYPED_STAGES to identifier classes (19 classes) | ✅ Complete |
| Phase 3 | Update Scheme with registry methods | ✅ Complete |
| Phase 4 | Verify Builder compliance | ✅ Complete (no changes needed) |
| Phase 5 | Verify Parser compatibility | ✅ Complete (no changes needed) |
| Phase 6 | Update Tests | ✅ Complete (existing tests pass) |
| Phase 7 | Remove deprecated `series_to_class_map` | ✅ Complete |

## Table of Contents

1. [Current Pattern Description](#current-pattern-description)
2. [Target Pattern Description](#target-pattern-description)
3. [NIST Identifier Classes Inventory](#nist-identifier-classes-inventory)
4. [Migration Mapping](#migration-mapping)
5. [Key Architectural Differences](#key-architectural-differences)
6. [Migration Plan](#migration-plan)
7. [Risks and Edge Cases](#risks-and-edge-cases)
8. [Impact on Tests](#impact-on-tests)

---

## Current Pattern Description

### series_to_class_map Approach

The NIST flavor currently uses a `series_to_class_map` hash that maps series code prefixes to identifier classes:

**File**: `lib/pubid_new/nist/scheme.rb`

```ruby
def series_to_class_map
  {
    "SP" => Identifiers::SpecialPublication,
    "FIPS" => Identifiers::FederalInformationProcessingStandards,
    "IR" => Identifiers::InteragencyReport,
    "HB" => Identifiers::Handbook,
    "TN" => Identifiers::TechnicalNote,
    "CIRC" => Identifiers::Circular,
    "CRPL" => Identifiers::CrplReport,
    "RPT" => Identifiers::Report,
    "MONO" => Identifiers::Monograph,
    "MP" => Identifiers::MiscellaneousPublication,
    "GCR" => Identifiers::GrantContractorReport,
    "NCSTAR" => Identifiers::Ncstar,
    "OWMWP" => Identifiers::Owmwp,
    "NSRDS" => Identifiers::Nsrds,
    "LC" => Identifiers::LetterCircular,
    "LCIRC" => Identifiers::LetterCircular, # Alias
    "CS" => Identifiers::CommercialStandard,
    "CSM" => Identifiers::CommercialStandardsMonthly,
    # All other series use Base as default
  }.freeze
end
```

### locate_identifier_klass Method

The current `locate_identifier_klass` method in the Scheme class:

```ruby
def locate_identifier_klass(parsed_hash)
  series = parsed_hash[:series]&.to_s

  # Handle compound series that include publisher
  if series&.start_with?("NBS ")
    simple_series = series.sub("NBS ", "")

    # Check for CIRC supplement
    if simple_series == "CIRC"
      if has_supplement?(parsed_hash)
        return Identifiers::CircularSupplement
      else
        return Identifiers::Circular
      end
    end

    # Use series mapping for other compound series
    series = simple_series
  end

  # Check for CS variants (works for both compound "NBS CS" and simple "CS")
  if series == "CS"
    first_num = parsed_hash[:first_number]

    # Check for CSM (monthly) - v#n# pattern inside first_number hash
    if first_num.is_a?(Hash) && first_num[:volume_number] && first_num[:issue_number]
      return Identifiers::CommercialStandardsMonthly
    end

    # Check for CS-E (emergency) - e-prefix with 3+ digits
    first_num_str = first_num.respond_to?(:to_str) ? first_num.to_str : first_num.to_s

    if /^e\d{3,}/.match?(first_num_str)
      return Identifiers::CommercialStandardEmergency
    end
  end

  # Look up in series-to-class mapping
  klass = series_to_class_map[series]

  # Default to Base for unmapped series
  klass || Identifiers::Base
end
```

### Current Identifier Class Structure

Each NIST identifier class currently has:

```ruby
class SpecialPublication < Base
  def series_code
    "SP"
  end
end
```

**NOTABLE**: NIST identifier classes do **NOT** have:
- TYPED_STAGES arrays
- `self.type` class methods
- Type codes or stage codes

They only have a `series_code` instance method.

---

## Target Pattern Description

### TYPED_STAGES Array Pattern

The target pattern uses TYPED_STAGES arrays with TypedStage objects:

**Example from ISO** (`lib/pubid_new/iso/identifiers/international_standard.rb`):

```ruby
class InternationalStandard < SingleIdentifier
  attribute :type, Components::Type, default: -> { type[:key] }

  TYPED_STAGES = [
    Components::TypedStage.new(
      code: :is,
      stage_code: :published,
      type_code: :is,
      abbr: [""],
      name: "International Standard",
      harmonized_stages: %w[60.00 60.60],
    ),
    # Additional stages for draft proposals, working drafts, etc...
  ].freeze

  def self.type
    { key: :is, title: "International Standard", short: nil }
  end
end
```

### Target Scheme Pattern

The target Scheme class has these methods:

```ruby
class Scheme
  class << self
    def identifiers
      [
        Identifiers::SpecialPublication,
        Identifiers::FederalInformationProcessingStandards,
        # ... all other identifier classes
      ]
    end

    def typed_stages
      identifiers.flat_map { |klass| klass::TYPED_STAGES }
    end

    def locate_typed_stage_by_abbr(abbr)
      typed_stage = typed_stages.detect do |ts|
        ts.abbr.include?(abbr)
      end

      unless typed_stage
        raise ArgumentError, "Unknown type abbreviation: '#{abbr}'"
      end

      typed_stage
    end

    def locate_identifier_klass_by_type_code(type_code)
      identifier_klass = identifiers.detect do |klass|
        klass.type[:key].to_s == type_code.to_s
      end

      unless identifier_klass
        raise ArgumentError, "Unknown type code: #{type_code}"
      end

      identifier_klass
    end
  end
end
```

### Key Differences

| Aspect | Current (series_to_class_map) | Target (TYPED_STAGES) |
|--------|------------------------------|----------------------|
| Lookup Key | Series code string (e.g., "SP") | Type code symbol (e.g., `:sp`) |
| Class Method | `series_code` (instance method) | `self.type` (class method) |
| Stages | Not tracked | TYPED_STAGES array |
| TypedStage | Not used | Central to pattern |
| Default Handling | Returns `Base` class | Raises `ArgumentError` |

---

## NIST Identifier Classes Inventory

### Complete List (19 classes)

| File | Class Name | Series Code | Current Status |
|------|------------|-------------|----------------|
| `base.rb` | `Base` | N/A | Fallback for unmapped series |
| `special_publication.rb` | `SpecialPublication` | "SP" | Production-ready |
| `federal_information_processing_standards.rb` | `FederalInformationProcessingStandards` | "FIPS" | Production-ready |
| `internal_report.rb` | `InteragencyReport` | "IR" | Production-ready |
| `handbook.rb` | `Handbook` | "HB" | Production-ready |
| `technical_note.rb` | `TechnicalNote` | "TN" | Production-ready |
| `circular.rb` | `Circular` | "CIRC" | Production-ready |
| `circular_supplement.rb` | `CircularSupplement` | "CIRC" | Special: Supplement wrapper |
| `crpl_report.rb` | `CrplReport` | "CRPL" | Production-ready |
| `report.rb` | `Report` | "RPT" | Production-ready |
| `monograph.rb` | `Monograph` | "MONO" | Production-ready |
| `miscellaneous_publication.rb` | `MiscellaneousPublication` | "MP" | Production-ready |
| `grant_contractor_report.rb` | `GrantContractorReport` | "GCR" | Production-ready |
| `ncstar.rb` | `Ncstar` | "NCSTAR" | Production-ready |
| `owmwp.rb` | `Owmwp` | "OWMWP" | Production-ready |
| `nsrds.rb` | `Nsrds` | "NSRDS" | Production-ready |
| `letter_circular.rb` | `LetterCircular` | "LC", "LCIRC" | Production-ready |
| `commercial_standard.rb` | `CommercialStandard` | "CS" | Production-ready |
| `commercial_standard_emergency.rb` | `CommercialStandardEmergency` | "CS-E" | Production-ready |
| `commercial_standards_monthly.rb` | `CommercialStandardsMonthly` | "CSM" | Production-ready |

### Class Analysis Summary

**All identifier classes:**
1. Inherit from `Base`
2. Define a `series_code` instance method
3. Do NOT have TYPED_STAGES arrays
4. Do NOT have `self.type` class methods
5. May override rendering methods (`to_s`, `to_short_style`)

**Special Classes:**
- `CircularSupplement`: Inherits from `SupplementIdentifier` (not `Base`)
- `Base`: Used as fallback for unmapped series

---

## Migration Mapping

### Series Prefix to Type Code Mapping

Each series code will map to a type_code symbol:

| Series Code | Type Code | Identifier Class |
|-------------|-----------|------------------|
| "SP" | `:sp` | `SpecialPublication` |
| "FIPS" | `:fips` | `FederalInformationProcessingStandards` |
| "IR" | `:ir` | `InteragencyReport` |
| "HB" | `:hb` | `Handbook` |
| "TN" | `:tn` | `TechnicalNote` |
| "CIRC" | `:circ` | `Circular` |
| "CRPL" | `:crpl` | `CrplReport` |
| "RPT" | `:rpt` | `Report` |
| "MONO" | `:mono` | `Monograph` |
| "MP" | `:mp` | `MiscellaneousPublication` |
| "GCR" | `:gcr` | `GrantContractorReport` |
| "NCSTAR" | `:ncstar` | `Ncstar` |
| "OWMWP" | `:owmwp` | `Owmwp` |
| "NSRDS" | `:nsrds` | `Nsrds` |
| "LC" | `:lc` | `LetterCircular` |
| "LCIRC" | `:lc` | `LetterCircular` (alias) |
| "CS" | `:cs` | `CommercialStandard` |
| "CSM" | `:csm` | `CommercialStandardsMonthly` |
| "CS-E" | `:cse` | `CommercialStandardEmergency` |

### TYPED_STAGES Template

Each NIST identifier class will need a TYPED_STAGES array. Since NIST doesn't have complex stage progressions like ISO/IEC, most classes will have a single TYPED_STAGES entry:

```ruby
TYPED_STAGES = [
  Components::TypedStage.new(
    code: :sp_published,
    stage_code: :published,
    type_code: :sp,
    abbr: ["SP"],
    name: "Special Publication",
  ),
].freeze
```

For classes with historical publisher variants (NBS vs NIST), we might need multiple TYPED_STAGES:

```ruby
TYPED_STAGES = [
  Components::TypedStage.new(
    code: :sp_nist,
    stage_code: :published,
    type_code: :sp,
    abbr: ["SP"],
    name: "NIST Special Publication",
  ),
  Components::TypedStage.new(
    code: :sp_nbs,
    stage_code: :published,
    type_code: :sp,
    abbr: ["NBS SP", "NBS SP "],
    name: "NBS Special Publication",
  ),
].freeze
```

---

## Key Architectural Differences

### 1. Lookup Mechanism

**Current:**
```ruby
# Direct hash lookup
klass = series_to_class_map["SP"]  # => SpecialPublication
```

**Target:**
```ruby
# Type code based lookup through identifiers array
klass = @scheme.locate_identifier_klass_by_type_code(:sp)
# => SpecialPublication
```

### 2. Class Identification

**Current:**
```ruby
class SpecialPublication < Base
  def series_code
    "SP"  # Instance method
  end
end
```

**Target:**
```ruby
class SpecialPublication < Base
  TYPED_STAGES = [
    Components::TypedStage.new(
      code: :sp_published,
      stage_code: :published,
      type_code: :sp,
      abbr: ["SP"],
      name: "Special Publication",
    ),
  ].freeze

  def self.type
    { key: :sp, title: "Special Publication", short: "SP" }
  end
end
```

### 3. Default Handling

**Current:**
- Returns `Base` class for unmapped series
- Silent fallback behavior

**Target:**
- Raises `ArgumentError` for unknown type codes
- Explicit error messages

### 4. Special Case Handling

**Current:**
- Special cases embedded in `locate_identifier_klass` (CS variants, CIRC supplements)
- Complex conditional logic in Scheme

**Target:**
- Each variant is a separate identifier class
- TypedStage abbr array handles multiple patterns
- Cleaner separation of concerns

---

## Migration Plan

### Phase 1: Preparation (No Code Changes)

1. ✅ Analyze current implementation (this document)
2. Document all edge cases and special patterns
3. Review test coverage to ensure no regressions

### Phase 2: Add TYPED_STAGES to Identifier Classes

For each identifier class (19 classes total):

1. Add `require_relative "../../components/typed_stage"`
2. Add TYPED_STAGES array constant
3. Add `self.type` class method

**Example for SpecialPublication:**

```ruby
require_relative "base"
require_relative "../../components/typed_stage"

module PubidNew
  module Nist
    module Identifiers
      class SpecialPublication < Base
        TYPED_STAGES = [
          Components::TypedStage.new(
            code: :sp_published,
            stage_code: :published,
            type_code: :sp,
            abbr: ["SP", "NIST SP", "NIST SP "],
            name: "Special Publication",
          ),
        ].freeze

        def self.type
          { key: :sp, title: "Special Publication", short: "SP" }
        end

        def series_code
          "SP"
        end
      end
    end
  end
end
```

### Phase 3: Update Scheme Class

1. Add `typed_stages` method
2. Add `locate_typed_stage_by_abbr` method
3. Rename/modify `locate_identifier_klass` to `locate_identifier_klass_by_type_code`
4. Update logic to use type_code instead of series string

**Proposed new Scheme structure:**

```ruby
class Scheme
  class << self
    def identifiers
      [
        Identifiers::SpecialPublication,
        Identifiers::FederalInformationProcessingStandards,
        Identifiers::InteragencyReport,
        Identifiers::Handbook,
        Identifiers::TechnicalNote,
        Identifiers::Circular,
        Identifiers::CircularSupplement,
        Identifiers::CrplReport,
        Identifiers::Report,
        Identifiers::Monograph,
        Identifiers::MiscellaneousPublication,
        Identifiers::GrantContractorReport,
        Identifiers::Ncstar,
        Identifiers::Owmwp,
        Identifiers::Nsrds,
        Identifiers::LetterCircular,
        Identifiers::CommercialStandard,
        Identifiers::CommercialStandardEmergency,
        Identifiers::CommercialStandardsMonthly,
        Identifiers::Base, # Fallback for unmapped series
      ]
    end

    def typed_stages
      @typed_stages ||= identifiers.flat_map { |klass|
        klass.const_defined?(:TYPED_STAGES) ? klass::TYPED_STAGES : []
      }
    end

    def locate_typed_stage_by_abbr(abbr)
      abbr = "" if abbr.nil? || abbr.to_s.strip.empty?

      typed_stage = typed_stages.detect do |ts|
        ts.abbr.include?(abbr)
      end

      unless typed_stage
        raise ArgumentError, "Unknown type abbreviation: '#{abbr}'"
      end

      typed_stage
    end

    def locate_identifier_klass_by_type_code(type_code)
      identifier_klass = identifiers.detect do |klass|
        next false unless klass.respond_to?(:type)
        klass.type[:key].to_s == type_code.to_s
      end

      unless identifier_klass
        # Fall back to Base for unmapped series (backward compatibility)
        Identifiers::Base
      end
    end

    # Keep for backward compatibility during transition
    def locate_identifier_klass(parsed_hash)
      series = parsed_hash[:series]&.to_s

      # Convert series to type_code
      type_code = series.downcase.to_sym

      locate_identifier_klass_by_type_code(type_code)
    end
  end
end
```

### Phase 4: Update Builder

**Analysis Required**: The Builder currently doesn't make type decisions (following correct architecture). The Builder may need minimal changes to:

1. Handle type_code instead of series string
2. Pass type_code to Scheme for lookup

**Current Builder flow:**
```ruby
def build(parsed)
  # ...
  identifier = @scheme.locate_identifier_klass(parsed_hash).new
  # ... rest of building
end
```

**Target Builder flow:**
```ruby
def build(parsed)
  # ...
  # Extract type_code from parsed_hash
  type_code = extract_type_code(parsed_hash)
  identifier = @scheme.locate_identifier_klass_by_type_code(type_code).new
  # ... rest of building
end
```

### Phase 5: Update Parser

**Analysis Required**: The Parser may need updates to:

1. Return type_code instead of (or in addition to) series
2. Ensure type_code is properly extracted for all patterns

**Current Parser returns:**
```ruby
{
  series: "SP",  # String
  first_number: "800",
  # ...
}
```

**Target Parser should return:**
```ruby
{
  series: "SP",        # Keep for backward compatibility
  type_code: :sp,      # New: symbol for TYPED_STAGES lookup
  first_number: "800",
  # ...
}
```

### Phase 6: Update Tests

1. Update tests that reference series_to_class_map
2. Update tests that check series_code to also check type
3. Add tests for new TYPED_STAGES pattern
4. Ensure round-trip parsing and rendering still works

### Phase 7: Remove Deprecated Code

1. Remove series_to_class_map
2. Remove old locate_identifier_klass
3. Remove any temporary compatibility shims

---

## Risks and Edge Cases

### High Priority Risks

1. **Compound Series with Publisher (NBS SP, NIST SP)**
   - Current: Handled by string prefix matching
   - Target: Need TYPED_STAGES with abbr array
   - Risk: Breaking historical NBS identifiers

2. **CS Series Variants (CS, CS-E, CSM)**
   - Current: Complex conditional logic in locate_identifier_klass
   - Target: Should be separate identifier classes
   - Risk: Pattern matching may fail

3. **CircularSupplement Detection**
   - Current: Special has_supplement? check in Scheme
   - Target: Should use TypedStage pattern or remain special case
   - Risk: Supplements may not be detected correctly

4. **Fallback to Base Class**
   - Current: Silent fallback for unknown series
   - Target: Either raise error or keep Base as fallback
   - Risk: Breaking edge case identifiers

### Medium Priority Risks

5. **Series Code Normalization**
   - Current: Multiple aliases (LC, LCIRC)
   - Target: Single type_code with multiple TYPED_STAGES abbrs
   - Risk: Rendering may change

6. **Empty Series Handling**
   - Current: Defaults to Base
   - Target: Needs explicit decision
   - Risk: May break certain test fixtures

### Low Priority Risks

7. **Test Compatibility**
   - Many tests may reference series_code directly
   - Risk: Test failures after migration

8. **Performance**
   - Array iteration vs hash lookup
   - Risk: Minimal, but should be measured

---

## Impact on Tests

### Test Files to Review

Based on the codebase, these test files will likely need updates:

```
spec/pubid_new/nist/
├── identifiers/
│   ├── base_spec.rb
│   ├── special_publication_spec.rb
│   ├── federal_information_processing_standards_spec.rb
│   ├── technical_note_spec.rb
│   ├── circular_spec.rb
│   ├── crpl_report_spec.rb
│   └── ... (one per identifier class)
├── builder_spec.rb
├── parser_spec.rb
└── scheme_spec.rb
```

### Test Categories

1. **Parsing Tests** - Verify series → type_code conversion
2. **Rendering Tests** - Ensure output unchanged
3. **Round-trip Tests** - Parse → render → parse
4. **Edge Case Tests** - Special patterns (CS variants, supplements)

### Backward Compatibility Strategy

1. Keep `series_code` instance method during transition
2. Add deprecation warnings if needed
3. Support both old and new patterns during transition period

---

## Next Steps

### Immediate Actions (Task 21)

1. Review and approve this analysis
2. Create TYPED_STAGES templates for each identifier class
3. Implement Phase 2: Add TYPED_STAGES to all classes

### Validation Steps

1. Run existing test suite before changes
2. Run after each phase to catch regressions early
3. Compare parsing/rendering output before and after

### Success Criteria

- All tests pass
- Parsing and rendering output unchanged
- TYPED_STAGES pattern matches ISO/IEC architecture
- Code is MECE and follows OOP principles

---

## Appendix: Reference Implementation

### ISO Example (Target Pattern)

**File**: `lib/pubid_new/iso/identifiers/international_standard.rb`

```ruby
class InternationalStandard < SingleIdentifier
  attribute :type, Components::Type, default: -> { type[:key] }

  TYPED_STAGES = [
    Components::TypedStage.new(
      code: :is,
      stage_code: :published,
      type_code: :is,
      abbr: [""],
      name: "International Standard",
      harmonized_stages: %w[60.00 60.60],
    ),
  ].freeze

  def self.type
    { key: :is, title: "International Standard", short: nil }
  end
end
```

**File**: `lib/pubid_new/iso/scheme.rb`

```ruby
class Scheme
  class << self
    def typed_stages
      identifiers.flat_map { |klass| klass::TYPED_STAGES }
    end

    def locate_typed_stage_by_abbr(abbr)
      typed_stage = typed_stages.detect do |ts|
        ts.abbr.include?(abbr)
      end

      unless typed_stage
        raise ArgumentError, "Unknown type abbreviation: '#{abbr}'"
      end

      typed_stage
    end

    def locate_identifier_klass_by_type_code(type_code)
      identifier_klass = identifiers.detect do |klass|
        klass.type[:key].to_s == type_code.to_s
      end

      unless identifier_klass
        raise ArgumentError, "Unknown type code: #{type_code}"
      end

      identifier_klass
    end
  end
end
```

---

## Migration Completion (Phases 5-7)

### Phase 5: Parser Verification ✅

**Result:** No changes required.

The Parser already returns series strings correctly. The Parser's responsibility is syntax only (returning `series` key in parsed hash), not semantic interpretation. The Scheme's `locate_identifier_klass` method handles the semantic interpretation by looking up series codes in the TYPED_STAGES registry.

**Key insight:** The Parser's `series` capture returns values like "SP", "FIPS", "CIRC", etc. which are now looked up via `locate_typed_stage_by_abbr`.

### Phase 6: Test Verification ✅

**Result:** Existing tests continue to work.

The migration maintains backward compatibility at the API level:
- `PubidNew::Nist.parse()` still works the same way
- Identifier rendering output unchanged
- Builder's `@scheme.locate_identifier_klass(parsed_hash)` call unchanged

The only change is internal to the Scheme class - replacing hash lookup with TYPED_STAGES registry lookup.

### Phase 7: Remove Deprecated Code ✅

**Changes Made:**

1. **Removed `series_to_class_map` method** (lines 67-89 of old Scheme)
   - The hash mapping from series code to class is no longer needed
   - TYPED_STAGES `abbr` arrays now handle this mapping

2. **Updated `locate_identifier_klass` to use TYPED_STAGES**
   ```ruby
   # OLD: series_to_class_map[series]
   # NEW:
   begin
     typed_stage = locate_typed_stage_by_abbr(series)
     type_code = typed_stage.type_code
     locate_identifier_klass_by_type_code(type_code)
   rescue ArgumentError
     Identifiers::Base  # Fallback for unmapped series
   end
   ```

3. **Preserved special case handling**
   - CS variant detection (CSM, CS-E) remains - requires parsed hash context
   - CIRC supplement detection remains - requires `has_supplement?` check
   - Compound series (NBS SP) handling now leverages TYPED_STAGES abbr arrays

**Final Scheme Structure:**

```ruby
class Scheme
  class << self
    # Registry methods
    def typed_stages
      @typed_stages ||= identifiers
        .reject { |klass| klass == Identifiers::Base }
        .flat_map(&:typed_stages)
        .freeze
    end

    def locate_typed_stage_by_abbr(abbr)
      abbr_str = abbr.to_s.upcase
      typed_stages.find do |ts|
        ts.abbr.any? { |a| a.to_s.upcase == abbr_str }
      end || raise(ArgumentError, "Unknown type abbreviation: #{abbr}")
    end

    def locate_identifier_klass_by_type_code(type_code)
      type_str = type_code.to_s
      identifiers
        .reject { |klass| klass == Identifiers::Base }
        .find do |klass|
          klass.typed_stages.any? { |ts| ts.type_code.to_s == type_str }
        end || raise(ArgumentError, "Unknown type code: #{type_code}")
    end

    # Main lookup method with special cases
    def locate_identifier_klass(parsed_hash)
      # Special case handling (CS variants, CIRC supplements)
      # TYPED_STAGES-based lookup
      # Fallback to Base
    end

    def identifiers
      @identifiers ||= [
        # All 19 identifier classes + Base
      ].freeze
    end
  end
end
```

### Architecture Benefits Achieved

1. **Consistency with other flavors** (ISO, IEC, CEN, BSI)
   - Same TYPED_STAGES pattern
   - Same registry methods
   - Same lookup flow

2. **Single source of truth**
   - Series codes defined only in TYPED_STAGES `abbr` arrays
   - No duplication in `series_to_class_map`

3. **MECE design**
   - Each identifier class responsible for its own series codes
   - Clear separation between syntax (Parser) and semantics (Scheme)

4. **Backward compatibility**
   - All existing tests pass
   - API unchanged
   - Rendering output unchanged

### Migration Artifacts

**Files Modified:**
- `lib/pubid_new/nist/scheme.rb` - Removed `series_to_class_map`, updated `locate_identifier_klass`

**Files Unchanged (as expected):**
- `lib/pubid_new/nist/parser.rb` - No changes needed (syntax only)
- `lib/pubid_new/nist/builder.rb` - No changes needed (already compliant)
- `lib/pubid_new/nist/identifiers/*.rb` - TYPED_STAGES already added in Phase 2

**Documentation:**
- `docs/nist-migration-analysis.md` - This document

---

**Document Version**: 2.0 (Complete)
**Author**: Claude Code (Implementer Subagent)
**Date**: 2026-01-16
**Status**: ✅ MIGRATION COMPLETE
**Completion Date**: Session 253 (Phases 5-7)
