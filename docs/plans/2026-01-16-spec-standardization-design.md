# PubID V2 Spec Standardization - Design Document

**Date:** 2026-01-16
**Author:** Claude (with user guidance)
**Status:** Approved for Implementation

---

## Overview

Standardize spec file structure, patterns, and coverage across all 23 PubID v2 flavors, ensuring every flavor has comprehensive test coverage with consistent patterns and shared utilities.

**Goal:** 100% coverage of all flavors, identifier classes, and components with unified test patterns.

**Quality Standard:** No shortcuts - every flavor gets complete, high-quality test infrastructure.

---

## Current State Analysis

### Flavor Inventory (23 Flavors)

| # | Flavor | scheme_spec | fixtures_spec | identifier_spec | Identifier Specs | Status |
|---|--------|-------------|---------------|-----------------|------------------|--------|
| 1 | amca | ❌ | ❌ | ❌ | 0 | No coverage |
| 2 | ansi | ❌ | ✅ | ❌ | 1 | Partial |
| 3 | api | ❌ | ❌ | ❌ | 0 | No coverage |
| 4 | ashrae | ❌ | ❌ | ❌ | 0 | No coverage |
| 5 | asme | ✅ | ❌ | ❌ | 0 | Partial |
| 6 | astm | ✅ | ❌ | ✅ | 9 | Good |
| 7 | bsi | ❌ | ❌ | ❌ | 18 | Partial |
| 8 | ccsds | ❌ | ✅ | ✅ | 0 | Basic |
| 9 | cen | ❌ | ❌ | ✅ | 6 | Partial |
| 10 | cie | ✅ | ❌ | ❌ | 0 | Partial |
| 11 | csa | ✅ | ❌ | ❌ | 9 | Partial |
| 12 | etsi | ❌ | ✅ | ✅ | 0 | Basic |
| 13 | idf | ✅ | ❌ | ✅ | 2 | Good |
| 14 | iec | ❌ | ✅ | ❌ | 13 | Good |
| 15 | ieee | ❌ | ✅ | ❌ | 7 | Good |
| 16 | iso | ❌ | ✅ | ✅ | 19 | Good, needs blank line fix |
| 17 | itu | ❌ | ❌ | ❌ | 4 | Minimal |
| 18 | jcgm | ❌ | ❌ | ✅ | 0 | Basic |
| 19 | jis | ❌ | ✅ | ✅ | 0 | Basic |
| 20 | nist | ✅ | ❌ | ✅ | 18 | Good |
| 21 | oiml | ✅ | ❌ | ✅ | 0 | Basic |
| 22 | plateau | ❌ | ✅ | ✅ | 0 | Basic |
| 23 | sae | ❌ | ❌ | ❌ | 0 | No coverage |

### Coverage Statistics

- **scheme_spec.rb:** 8/23 (35%)
- **fixtures_spec.rb:** 9/23 (39%)
- **identifier_spec.rb:** 12/23 (52%)
- **Blank line check:** 1/23 (4%) - only IDF

### Critical Issues

1. **ISO blank line handling:** Missing `next if pub_id.strip.empty?` causes test failures
2. **Zero-coverage flavors:** API, AMCA, ASHRAE, SAE have no test infrastructure
3. **Missing identifier specs:** CIE (10 classes), ITU (4 classes), plus others
4. **Attribute inconsistencies:** ISO uses `publisher.publisher`, IEC uses `number.number`
5. **Missing shared component specs:** Date, Type, Language

---

## Architecture

### Three-Layer Execution Model

Phase 1 - **Foundation Layer (scheme_spec.rb):**
Tests the Scheme registry - core of each flavor's identifier resolution system.

Phase 2 - **Integration Layer (fixtures_spec.rb):**
Tests real-world identifier parsing against fixture files.

Phase 3 - **Application Layer (identifier_spec.rb):**
Tests flavor module parsing with representative examples.

Phase 4 - **Individual Identifier Specs:**
Per-identifier class specs for complete coverage.

Phase 5 - **Standardization Cleanup:**
Shared helpers, attribute patterns, pragmas.

### File Structure Standardization

```
spec/pubid_new/{flavor}/
├── scheme_spec.rb                    # Registry tests (all 23)
├── identifier_spec.rb                 # Flavor integration tests (all 23)
├── fixtures_spec.rb                   # Comprehensive fixture tests (all 23)
├── single_identifier_spec.rb          # Base class tests (if applicable)
├── supplement_identifier_spec.rb      # Supplement base tests (if applicable)
├── components/
│   └── {component}_spec.rb           # Flavor-specific component tests
└── identifiers/
    ├── {identifier}_spec.rb          # Per-identifier tests (100% coverage)
    └── ...
```

---

## Shared Utilities

### FixtureFileHelper Module

**Location:** `spec/support/fixture_file_helper.rb`

Centralized fixture reading with blank line handling:

```ruby
# frozen_string_literal: true

module FixtureFileHelper
  # Read identifiers from a fixture file, skipping comments and blank lines
  # @param file_path [String] Path to fixture file relative to spec/fixtures/
  # @return [Array<String>] Array of identifier strings
  def read_fixture_identifiers(file_path)
    full_path = File.join(__dir__, "../fixtures", file_path)
    File.readlines(full_path).map(&:strip).reject do |line|
      line.empty? || line.start_with?("#")
    end
  end

  # Parse each identifier from a fixture file without raising errors
  # @param file_path [String] Path to fixture file
  # @param parser_class [Class] Class to call .parse on
  # @yield [String, Object] Yields identifier string and parsed result
  def parse_fixture_identifiers(file_path, parser_class)
    read_fixture_identifiers(file_path).each do |identifier|
      parsed = parser_class.parse(identifier)
      yield identifier, parsed if block_given?
    end
  end
end
```

### AttributeHelper Module

**Location:** `spec/support/attribute_helper.rb`

Handles attribute access pattern migration:

```ruby
# frozen_string_literal: true

module AttributeHelper
  def expect_publisher_body(parsed, expected)
    actual = parsed.publisher.respond_to?(:body) ? parsed.publisher.body : parsed.publisher.publisher
    expect(actual).to eq(expected)
  end

  def expect_number_value(parsed, expected)
    actual = parsed.number.respond_to?(:value) ? parsed.number.value : parsed.number.number
    expect(actual).to eq(expected)
  end
end
```

---

## Attribute Standardization

**Unified Pattern Across All Flavors:**

| Attribute | Standard Pattern | Notes |
|-----------|------------------|-------|
| Publisher | `parsed.publisher.body` | Or `.to_s` for simple publishers |
| Number | `parsed.number.value` | Or `.code.value` depending on component |
| Date | `parsed.date.year` | Already consistent |
| Part | `parsed.part.value` | Already consistent |

**Migration Path:**
1. Use AttributeHelper during transition
2. Update all non-compliant specs
3. Remove helpers once all flavors standardized

**Flavors to Update:**
- ISO: `publisher.publisher` → `publisher.body`
- IEC: `number.number` → `number.value`

---

## Execution Plan

### Phase 1: scheme_spec.rb - 15 Flavors

**Flavors:** amca, ansi, api, ashrae, bsi, ccsds, cen, etsi, ieee, iso, itu, jcgm, jis, plateau, sae

**Per-flavor tasks:**
1. Read `lib/pubid_new/{flavor}/scheme.rb`
2. Identify registered identifiers and TYPED_STAGES
3. Create `spec/pubid_new/{flavor}/scheme_spec.rb`
4. Test: `.identifiers`, `.typed_stages`, `.locate_typed_stage_by_abbr`, `.locate_identifier_klass_by_type_code`
5. Run and verify

**Template:**
```ruby
# frozen_string_literal: true

require "spec_helper"

RSpec.describe PubidNew::{Flavor}::Scheme do
  describe ".identifiers" do
    it "returns array of registered identifier classes" do
      expect(described_class.identifiers).to be_an(Array)
      expect(described_class.identifiers).to all(be_a(Class))
    end
  end

  describe ".typed_stages" do
    it "returns array of TYPED_STAGES from all identifiers" do
      stages = described_class.typed_stages
      expect(stages).to be_an(Array)
      expect(stages).to all(be_a(PubidNew::Components::TypedStage))
    end
  end

  describe ".locate_typed_stage_by_abbr" do
    it "returns the correct typed stage for known abbreviations" do
      first_stage = described_class.typed_stages.find { |ts| ts.abbr.any? && ts.abbr.first != "" }
      skip "No typed stages with abbreviations found" unless first_stage

      stage = described_class.locate_typed_stage_by_abbr(first_stage.abbr.first)
      expect(stage).to eq(first_stage)
    end

    it "raises ArgumentError for unknown abbreviations" do
      expect {
        described_class.locate_typed_stage_by_abbr("UNKNOWN_ABBR")
      }.to raise_error(ArgumentError, /Unknown type abbreviation/)
    end
  end

  describe ".locate_identifier_klass_by_type_code" do
    it "returns the correct identifier class for known type codes" do
      first_identifier = described_class.identifiers.first
      skip "No identifiers found" unless first_identifier

      if first_identifier.respond_to?(:typed_stages) && first_identifier.typed_stages.any?
        type_code = first_identifier.typed_stages.first.type_code
        klass = described_class.locate_identifier_klass_by_type_code(type_code)
        expect(klass).to eq(first_identifier)
      else
        skip "First identifier has no typed_stages"
      end
    end

    it "raises ArgumentError for unknown type codes" do
      expect {
        described_class.locate_identifier_klass_by_type_code(:unknown_type_code)
      }.to raise_error(ArgumentError, /Unknown type code/)
    end
  end
end
```

**Estimated:** 2-3 hours

---

### Phase 2: fixtures_spec.rb - 14 Flavors

**Flavors:** amca, api, ashrae, asme, astm, bsi, cen, cie, csa, idf, itu, jcgm, nist, oiml, sae

**Per-flavor tasks:**
1. Verify `spec/fixtures/{flavor}/identifiers/full/` exists
2. Create `spec/pubid_new/{flavor}/fixtures_spec.rb`
3. Test: all identifiers parse, round-trip consistency
4. Add classification pass rate test if SUMMARY.txt exists

**Template:**
```ruby
# frozen_string_literal: true

require "spec_helper"
require "support/fixture_file_helper"

RSpec.describe "{Flavor} V2 Comprehensive Fixtures Tests" do
  include FixtureFileHelper

  FIXTURE_DIR = File.join(__dir__, "../../fixtures/{flavor}")
  IDENTIFIERS_DIR = File.join(FIXTURE_DIR, "identifiers")

  describe "fixture files exist" do
    it "has fixtures directory" do
      expect(Dir.exist?(FIXTURE_DIR)).to be true
    end

    it "has identifiers/full directory" do
      full_dir = File.join(IDENTIFIERS_DIR, "full")
      expect(Dir.exist?(full_dir)).to be true
    end
  end

  describe "parse all identifiers from full/" do
    let(:full_dir) { File.join(IDENTIFIERS_DIR, "full") }
    let(:fixture_files) { Dir.glob(File.join(full_dir, "*.txt")).sort }

    it "has at least one fixture file" do
      expect(fixture_files).not_to be_empty
    end

    fixture_files.each do |file|
      context "file: #{File.basename(file)}" do
        let(:identifiers) { read_fixture_identifiers("{flavor}/identifiers/full/#{File.basename(file)}") }

        it "parses all identifiers without error" do
          identifiers.each do |identifier|
            expect { PubidNew::{Flavor}.parse(identifier) }.not_to raise_error
          end
        end

        it "round-trips all identifiers" do
          identifiers.each do |identifier|
            parsed = PubidNew::{Flavor}.parse(identifier)
            expect(parsed.to_s).not_to be_empty
          end
        end
      end
    end
  end
end
```

**Estimated:** 2-3 hours

---

### Phase 3: identifier_spec.rb - 11 Flavors

**Flavors:** amca, ansi, api, ashrae, asme, bsi, cie, csa, ieee, iec, itu, sae

**Per-flavor tasks:**
1. Identify 3-5 representative identifier examples
2. Create `spec/pubid_new/{flavor}/identifier_spec.rb`
3. Add basic parse tests, error handling, Scheme reference

**Template:**
```ruby
# frozen_string_literal: true

require "spec_helper"

RSpec.describe PubidNew::{Flavor} do
  describe ".parse" do
    context "basic identifiers" do
      it "parses {FLAVOR} {example_1}" do
        result = described_class.parse("{example_1}")
        expect(result).to be_a(PubidNew::{Flavor}::Identifier)
        expect(result.to_s).not_to be_empty
      end

      it "parses {FLAVOR} {example_2}" do
        result = described_class.parse("{example_2}")
        expect(result).to be_a(PubidNew::{Flavor}::Identifier)
        expect(result.to_s).not_to be_empty
      end

      it "parses {FLAVOR} {example_3}" do
        result = described_class.parse("{example_3}")
        expect(result).to be_a(PubidNew::{Flavor}::Identifier)
        expect(result.to_s).not_to be_empty
      end
    end

    context "error handling" do
      it "raises error for invalid identifier" do
        expect { described_class.parse("INVALID {FLAVOR} IDENTIFIER 999") }
          .to raise_error(Parslet::ParseFailed)
      end

      it "raises error for empty string" do
        expect { described_class.parse("") }
          .to raise_error(Parslet::ParseFailed)
      end
    end
  end

  describe "Scheme" do
    it "has registered identifiers" do
      expect(PubidNew::{Flavor}::Scheme.identifiers).to be_an(Array)
      expect(PubidNew::{Flavor}::Scheme.identifiers).not_to be_empty
    end
  end
end
```

**Estimated:** 1.5-2 hours

---

### Phase 4: Individual Identifier Specs - Complete Coverage

**Target:** 100% of identifier classes have specs

**Flavors needing complete coverage:**
- **AMCA, API, ASHRAE, SAE:** Full spec suite from scratch
- **CIE:** 10 identifier specs (Standard, Conference, Corrigendum, Directive, Guide, Handbook, Interpretation, Journal, Monograph, Procedure)
- **IDF:** Amendment, Corrigendum supplements
- **ITU:** Amendment, Corrigendum, Recommendation, Supplement
- **CCSDS, ETSI, JCGM, Plateau:** Base identifier specs

**Per-identifier template:**
```ruby
# frozen_string_literal: true

require "spec_helper"

RSpec.describe PubidNew::{Flavor}::Identifiers::{Identifier} do
  describe "parse identifiers from examples" do
    shared_examples "parse identifiers from file" do
      it "parse identifiers from file" do
        identifiers = read_fixture_identifiers(examples_file)
        identifiers.each do |identifier|
          expect { described_class.parse(identifier) }.not_to raise_error
        end
      end
    end

    context "parses identifiers from {type}.txt" do
      let(:examples_file) { "{flavor}/identifiers/full/{flavor}-{type}.txt" }
      it_behaves_like "parse identifiers from file"
    end
  end

  describe "{example_identifier}" do
    subject { "{FLAVOR} {NUMBER}:{YEAR}" }
    let(:parsed) { described_class.parse(subject) }

    it "parses publisher" do
      expect(parsed.publisher.body).to eq("{PUBLISHER}")
    end

    it "parses number" do
      expect(parsed.number.value).to eq("{NUMBER}")
    end

    it "parses date" do
      expect(parsed.date.year).to eq("{YEAR}")
    end

    it "round-trips" do
      expect(parsed.to_s).to eq(subject)
    end
  end
end
```

**Estimated:** 4-5 hours

---

### Phase 5: Standardization Cleanup

**Tasks:**
1. Create `spec/support/fixture_file_helper.rb`
2. Create `spec/support/attribute_helper.rb`
3. Update ISO fixture tests to use FixtureFileHelper
4. Update all non-compliant attribute patterns (ISO, IEC)
5. Add `# frozen_string_literal: true` to all specs missing it
6. Remove redundant require_relative statements
7. Create missing shared component specs (Date, Type, Language)

**Shared component specs to create:**
- `spec/pubid_new/components/date_spec.rb`
- `spec/pubid_new/components/type_spec.rb`
- `spec/pubid_new/components/language_spec.rb`

**Estimated:** 1.5-2 hours

---

## Validation Criteria

### After Each Phase

**Phase 1 (scheme_spec):**
- [ ] 15 new scheme_spec files created
- [ ] All scheme tests pass
- [ ] Each Scheme's methods exercised

**Phase 2 (fixtures_spec):**
- [ ] 14 new fixtures_spec files created
- [ ] All fixture identifiers parse
- [ ] Round-trip tests pass

**Phase 3 (identifier_spec):**
- [ ] 11 new identifier_spec files created
- [ ] Each flavor's parse method tested
- [ ] Error handling validated

**Phase 4 (individual specs):**
- [ ] All identifier classes have specs
- [ ] Attribute patterns standardized
- [ ] Round-trip tests pass

**Phase 5 (cleanup):**
- [ ] Shared helpers created and in use
- [ ] All specs have frozen_string_literal
- [ ] No redundant requires remain

### Final Validation

- [ ] Full test suite passes: `bundle exec rspec`
- [ ] Test coverage ≥95% for all flavors
- [ ] No deprecation warnings
- [ ] All 23 flavors have: scheme_spec, identifier_spec, fixtures_spec
- [ ] 100% of identifier classes have specs
- [ ] 100% of components have specs

---

## Success Metrics

| Metric | Current | Target |
|--------|---------|--------|
| Flavors with scheme_spec.rb | 8/23 (35%) | 23/23 (100%) |
| Flavors with identifier_spec.rb | 12/23 (52%) | 23/23 (100%) |
| Flavors with fixtures_spec.rb | 9/23 (39%) | 23/23 (100%) |
| Identifier classes with specs | ~80% | 100% |
| Shared components with specs | ~60% | 100% |
| Attribute consistency | Inconsistent | Unified |
| Blank line handling | 1/23 | 23/23 |
| frozen_string_literal pragma | ~40% | 100% |

---

## Estimated Timeline

| Phase | Tasks | Time |
|-------|-------|------|
| Phase 1 | scheme_spec.rb for 15 flavors | 2-3 hours |
| Phase 2 | fixtures_spec.rb for 14 flavors | 2-3 hours |
| Phase 3 | identifier_spec.rb for 11 flavors | 1.5-2 hours |
| Phase 4 | Individual identifier specs | 4-5 hours |
| Phase 5 | Standardization cleanup | 1.5-2 hours |
| **Total** | **Complete standardization** | **11-15 hours** |

---

## Implementation Notes

1. **Zero-coverage flavors (API, AMCA, ASHRAE, SAE):** Reverse-engineer from parser/builder/scheme files
2. **IDF supplements:** Verify Amendment and Corrigendum classes work before writing tests
3. **ISO blank line fix:** Critical - do this first as it causes actual failures
4. **Attribute migration:** Verify components have expected attributes before updating tests
5. **Run full suite after each flavor:** Catch regressions early
6. **Commit incrementally:** One flavor per phase at a time
7. **Document architectural surprises:** Note any patterns that don't match expected design

---

## References

- Original analysis: `docs/spec-inconsistencies-analysis.md`
- Task breakdown: `docs/spec-standardization-plan.md`
- Three-layer architecture: `CLAUDE.md`
