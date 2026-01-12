# NIST V2 Complete Implementation Design

**Date:** 2026-01-12
**Status:** Design Complete - Ready for Implementation
**Approach:** Comprehensive Overhaul (3-Layer)
**Current Status:** 0/0 pass rate (fixture loading issue)

## Executive Summary

Complete the NIST V2 implementation through a comprehensive three-layer approach:
1. **Fix fixture infrastructure** (unblocks validation)
2. **Implement parser enhancements** with V2's superior normalization patterns
3. **Migrate essential V1 features** while preserving V2's MODEL-DRIVEN architecture

**Critical Design Principle:** V2 has some parts MORE correct than V1. Specifically, the normalization patterns (`-YYYY` → `eYYYY` and `v1.1`/`Ver. 2.0` → `ver1.1`/`ver2.0`) are V2 improvements that MUST be preserved.

## Current State Analysis

### Known Issues
1. **Fixture Loading Failure**: Integration tests showing `0/0 (0.0%)` - `load_gem_fixture` not returning records
2. **Parser Coverage Gap**: Only 65% coverage (34/52 SP tests per Session 276)
3. **Sample Test Failure**: `"NIST SP 800-53 Rev. 5"` rendering as `"NIST SP 800-53r5"` (format not preserved)
4. **V1 Features Missing**: Stage system, multi-format rendering, translation codes not yet migrated

### V2 Superior Patterns (PRESERVE THESE)
- **Edition normalization**: `-YYYY` → `eYYYY` (more explicit than V1)
- **Version normalization**: `v1.1`/`Ver. 2.0` → `ver1.1`/`ver2.0` (consistent format)

### Architecture Foundation (ALREADY COMPLETE)
- MODEL-DRIVEN three-layer: Parser → Builder → Identifier
- 21 identifier classes implemented
- Lutaml::Model::Serializable component-based modeling
- Round-trip fidelity: `parse(str).to_s == str`

## Three-Layer Implementation Strategy

### Layer 1: Foundation - Fixture Infrastructure Fix

**Problem**: `load_gem_fixture(:nist, "allrecords.txt")` returns 0 records

**Diagnostic Steps**:
1. Verify fixture file existence at `spec/fixtures/nist/allrecords.txt`
2. Read `spec/support/fixture_loader.rb` implementation
3. Check file path resolution (gem fixtures vs. local fixtures)
4. Add debug logging to trace failure point

**Expected Fix**: One of:
- File path correction in fixture loader
- Fixture file relocation to expected directory
- Loader implementation update for NIST fixtures

**Estimated Time**: 15-30 minutes
**Blocks**: All validation and testing

### Layer 2: Parser Enhancements

**Enhancement 1 - Edition Year Normalization**
- Input: `"NIST SP 330-2019"`
- Output: `"NIST SP 330e2019"`
- Pattern: `-YYYY` → `eYYYY` (dash becomes `e` prefix)
- Test Count: ~9 patterns
- Estimated Time: 30-45 minutes

**Enhancement 2 - Version Normalization**
- Input: `"NIST SP 500-268v1.1"` → Output: `"NIST SP 500-268ver1.1"`
- Input: `"NIST SP 800-60 Ver. 2.0"` → Output: `"NIST SP 800-60ver2.0"`
- Pattern: `vX.Y` or `Ver. X.Y` → `verX.Y` (normalized lowercase)
- Test Count: ~6 patterns
- Estimated Time: 30-45 minutes

**Implementation Location**: `lib/pubid_new/nist/parser.rb`
- Add transformation rules in post-processing stage
- Apply AFTER parsing, BEFORE building identifier object
- Use Parslet transform rules for consistency

**Total Estimated Time**: 60-90 minutes

### Layer 3: V1 Feature Migration (Tiered Priority)

**Tier 1 - Essential (Production-Blocking)**

1. **Stage System**
   - Suffixes: `ipd`, `fpd`, `2pd`, `pd`, `prd`, `std`
   - Short/long rendering: `ipd` vs `Initial Public Draft`
   - New component: `lib/pubid_new/nist/components/stage.rb`
   - Parser updates for stage detection
   - Estimated Time: 60-90 minutes

2. **Multi-Format Rendering**
   - Formats: `:short`, `:long`, `:abbrev`, `:mr`
   - Method: `identifier.render(format: :long)`
   - Implementation: Base class method with format-specific logic
   - Estimated Time: 45-60 minutes

3. **Translation Codes**
   - Codes: `spa`, `por`, `ind`, etc. (3-letter ISO)
   - Suffix format: `NIST SP 800-53spa`
   - New component: `lib/pubid_new/nist/components/translation.rb`
   - Parser updates for translation detection
   - Estimated Time: 30-45 minutes

**Tier 2 - Important (Quality/Completeness)**

1. **Update System**
   - Format: `/Upd1-YYYYMM` (e.g., `NIST SP 800-53/Upd1-202309`)
   - Current: Partial implementation
   - Enhancement: Full format with month code
   - Estimated Time: 30-45 minutes

2. **Supplement System**
   - Prefix: `sup` (separate from edition)
   - Format: `NIST SP 800-53sup1`
   - Component extension to Edition
   - Estimated Time: 30-45 minutes

3. **Revision Formatting**
   - Preserve: `"Rev. 5"` format (not `"r5"`)
   - Context-aware rendering
   - Estimated Time: 20-30 minutes

**Tier 3 - Nice-to-Have (Future)**

1. **Volume attributes**: Multi-volume support
2. **Part numbers**: Beyond current implementation
3. **Additional metadata**: DOI, ISBN mappings

**Total Tier 1 Time**: 2-3 hours
**Total Tier 2 Time**: 1.5-2 hours

## Architecture Extension

### Parser Layer (`lib/pubid_new/nist/parser.rb`)
```ruby
# Add to existing parser
rule(:stage) do
  str("ipd") | str("fpd") | str("2pd") | str("pd") | str("prd") | str("std")
end

rule(:translation_code) do
  # 3-letter language codes
  str("spa") | str("por") | str("ind") | # ... more codes
end

rule(:update_with_month) do
  str("/Upd") >> digit >> str("-") >> digit.repeat(6)
end
```

### Component Layer (`lib/pubid_new/nist/components/`)
```ruby
# NEW: stage.rb
module PubidNew
  module Nist
    module Components
      class Stage < Lutaml::Model::Serializable
        attribute :stage, :string

        def to_s(format: :short)
          format == :long ? long_name : @stage
        end

        def long_name
          # Map ipd → "Initial Public Draft", etc.
        end
      end
    end
  end
end

# NEW: translation.rb
module PubidNew
  module Nist
    module Components
      class Translation < Lutaml::Model::Serializable
        attribute :language_code, :string
      end
    end
  end
end
```

### Identifier Layer (`lib/pubid_new/nist/identifiers/base.rb`)
```ruby
def render(format: :short)
  case format
  when :short then to_s
  when :long then to_long_s
  when :abbrev then to_abbrev_s
  when :mr then to_mr_s
  end
end

def to_long_s
  # Full rendering with stage names, etc.
  "#{publisher} #{series} #{number}#{stage.to_s(format: :long)}:#{year}"
end
```

## Testing & Validation Strategy

### Integration Tests (`spec/integration/nist_spec.rb`)
**Target Metrics**:
- All records: 85%+ (realistic for complex legacy data)
- Publication exports: 95%+ (cleaner subset)
- September 2024: 85%+ (newer data)

### Unit Tests
**Per Identifier Class**:
- Parsing tests (all pattern variations)
- Rendering tests (all 4 formats)
- Round-trip fidelity: `parse(str).to_s == str`

**Feature-Specific Tests**:
- Stage system (all 6 stage types × 2 formats)
- Translation codes (all supported languages)
- Format rendering (4 formats × multiple identifiers)

### Coverage Goals
- Parser coverage: 90%+ of real-world patterns
- Identifier coverage: All 21 classes fully tested
- Format coverage: All 4 rendering formats validated

## Execution Phases

### Phase 1: Foundation (Day 1 - Morning)
1. Diagnose fixture loading issue
2. Fix fixture infrastructure
3. Verify test suite runs without 0/0 results
4. Establish baseline coverage metrics

### Phase 2: Parser Enhancements (Day 1 - Afternoon)
1. Implement edition year normalization
2. Implement version normalization
3. Add transformation tests
4. Validate against fixture files
5. Fix revision formatting ("Rev. 5" preservation)

### Phase 3: Tier 1 V1 Features (Day 2)
1. Implement Stage system (component + parser + tests)
2. Implement multi-format rendering (base class method)
3. Implement translation codes (component + parser + tests)
4. Integration testing and validation

### Phase 4: Tier 2 V1 Features (Day 2-3)
1. Implement Update system (full `/Upd1-YYYYMM` format)
2. Implement Supplement system (separate from edition)
3. Final integration testing

### Phase 5: Validation & Documentation (Day 3)
1. Run full integration suite
2. Achieve target coverage (85%+/95%+)
3. Update NIST status documentation
4. Update memory bank context
5. RuboCop cleanup

## Quality Gates

Each phase must pass these gates before proceeding:

1. ✅ All fixture patterns for implemented features parse correctly
2. ✅ Round-trip fidelity maintained for all patterns
3. ✅ Zero regressions in existing tests
4. ✅ Integration test coverage meets phase targets
5. ✅ RuboCop clean: `bundle exec rubocop -A`
6. ✅ MODEL-DRIVEN architecture maintained

## Success Criteria

### Coverage Targets
- **Phase 1 Complete**: Tests running, baseline established
- **Phase 2 Complete**: 75%+ coverage (parser enhancements)
- **Phase 3 Complete**: 85%+ coverage (Tier 1 features)
- **Phase 4 Complete**: 90%+ coverage (Tier 2 features)
- **Final**: 90%+ overall, 95%+ on publication exports

### Quality Targets
- Integration Tests: Meeting targets above
- Round-trip Fidelity: 100% on all implemented patterns
- Format Preservation: "Rev. 5" NOT "r5"
- Architecture Compliance: 100% MODEL-DRIVEN

## Critical Design Decisions

1. **Preserve V2 Normalization**: The `-YYYY` → `eYYYY` and `verX.Y` patterns are V2 improvements over V1 - do NOT revert to V1 patterns
2. **Component-Based Features**: Stage, Translation, etc. are modeled components (not ad-hoc parsing)
3. **Format Flexibility**: Multiple rendering formats via single `render(format:)` method
4. **Incremental Validation**: Fixtures first, then parsers, then features - each layer validated before next

## Files to Modify/Create

### Created
- `lib/pubid_new/nist/components/stage.rb`
- `lib/pubid_new/nist/components/translation.rb`
- `spec/pubid_new/nist/components/stage_spec.rb`
- `spec/pubid_new/nist/components/translation_spec.rb`

### Modified
- `lib/pubid_new/nist/parser.rb` (edition/version transforms, stage, translation, update parsing)
- `lib/pubid_new/nist/identifiers/base.rb` (multi-format rendering)
- `lib/pubid_new/nist/components/edition.rb` (supplement support)
- `lib/pubid_new/nist/components/update.rb` (full month code support)
- `spec/support/fixture_loader.rb` (fix fixture loading)
- `spec/integration/nist_spec.rb` (adjust targets if needed)

### Updated
- `docs/NIST-IMPLEMENTATION-STATUS.md` (create)
- `.kilocode/rules/memory-bank/context.md` (NIST section)

## Estimated Total Timeline

- **Phase 1**: 2-3 hours (fixture fix + baseline)
- **Phase 2**: 2-3 hours (parser enhancements)
- **Phase 3**: 4-6 hours (Tier 1 V1 features)
- **Phase 4**: 2-3 hours (Tier 2 V1 features)
- **Phase 5**: 1-2 hours (validation + documentation)

**Total**: 11-17 hours (2-3 days)

---

**Design Status**: Complete and approved
**Ready for Implementation**: Yes (pending fixture diagnosis)
**First Task**: Phase 1.1 - Diagnose and fix fixture loading issue
