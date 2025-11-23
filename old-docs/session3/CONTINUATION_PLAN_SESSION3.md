# PubID V2 ISO Parser - Session 3 Continuation Plan

**Date:** 2025-11-22 18:21 HKT
**Previous Session:** Session 2 (100% integration tests passing)
**This Session:** Session 3 - Unit Tests, Documentation, Quality

---

## Current Status

### Completed in Session 2 ✅
- All 20 integration tests passing (100%)
- Parser grammar complete for all ISO identifier patterns
- Builder logic handles all edge cases
- Component architecture validated
- Multi-level supplement support working
- Multiple copublisher support working

### Session 3 Objectives

1. **Unit Test Coverage** (High Priority) - 8 hours
2. **Documentation Updates** (High Priority) - 4 hours
3. **Code Quality & Cleanup** (Medium Priority) - 2 hours
4. **Performance Validation** (Low Priority) - 1 hour

**Total Estimated Time:** 15 hours

---

## Phase 1: Unit Test Suite (8 hours)

### 1.1 Parser Unit Tests (2 hours)

**File:** `spec/pubid_new/iso/parser_spec.rb`

Test coverage for [`lib/pubid_new/iso/parser.rb`](lib/pubid_new/iso/parser.rb):

```ruby
describe PubidNew::Iso::Parser do
  describe ".parse" do
    context "publishers" do
      # Test single publisher
      # Test copublisher patterns (ISO/IEC, ISO/IEC/IEEE, ISO/SAE)
      # Test all valid copublisher combinations
    end

    context "types" do
      # Test all type tokens (Guide, TR, TS, PAS, DATA, DIR, SUP, ISP, IWA, TTA, R)
      # Test type with and without publisher prefix
    end

    context "typed stages" do
      # Test FDAM, PDAM, DAM, FDCOR, DCOR, FDIS, DIS, DTR, DTS patterns
      # Test typed stage standalone (for supplements)
      # Test typed stage with publisher
    end

    context "supplements" do
      # Test single supplement (Amd, Cor, Suppl, Ext)
      # Test multiple supplements (2-level, 3-level)
      # Test supplement with typed_stage
      # Test supplement with year
    end

    context "number and parts" do
      # Test basic number (19115)
      # Test with single part (13818-1)
      # Test with alphanumeric part (A01-B02)
      # Test with multiple parts
    end

    context "years and dates" do
      # Test year with colon
      # Test year with space-colon
      # Test multiple years in supplements
    end

    context "languages" do
      # Test single language (E)
      # Test multiple languages (E/F/R)
      # Test language with comma separator
    end

    context "DIR SUP pattern" do
      # Test "ISO/IEC DIR 1 ISO SUP:2022"
      # Test with different supplement publishers
    end

    context "IWA pattern" do
      # Test "IWA 14-1:2013"
      # Test with typed stage "PWI IWA 36"
    end

    context "error cases" do
      # Test invalid pattern
      # Test malformed input
      # Test edge cases
    end
  end
end
```

### 1.2 Builder Unit Tests (2 hours)

**File:** `spec/pubid_new/iso/builder_spec.rb`

Test coverage for [`lib/pubid_new/iso/builder.rb`](lib/pubid_new/iso/builder.rb):

```ruby
describe PubidNew::Iso::Builder do
  describe ".build" do
    context "identifier class selection" do
      # Test determine_identifier_class for each type
      # Test DIR SUP detection
      # Test default to InternationalStandard
    end

    context "publisher building" do
      # Test single publisher
      # Test copublisher array handling
      # Test merge_array_preserving_duplicates
    end

    context "supplement building" do
      # Test single supplement creation
      # Test multi-level supplement recursion
      # Test typed_stage extraction from nested hash
      # Test supplement_type inference from typed_stage
    end

    context "DirectivesSupplement special handling" do
      # Test base Directives creation
      # Test supplement_publisher extraction
      # Test date placement (on supplement, not base)
    end

    context "component creation" do
      # Test Type component with abbr
      # Test Language component with original_code
      # Test Date component
      # Test Code component
      # Test Stage component
    end
  end
end
```

### 1.3 Identifier Class Unit Tests (3 hours)

Create individual spec files for each identifier class:

#### Core Identifiers
**Files to create:**
- `spec/pubid_new/iso/identifiers/international_standard_spec.rb`
- `spec/pubid_new/iso/identifiers/guide_spec.rb`
- `spec/pubid_new/iso/identifiers/technical_report_spec.rb`
- `spec/pubid_new/iso/identifiers/technical_specification_spec.rb`

**Test patterns for each:**
```ruby
describe PubidNew::Iso::Identifiers::InternationalStandard do
  describe ".type" do
    # Test type hash structure
  end

  describe "#to_s" do
    # Test basic rendering
    # Test with publisher
    # Test with copublisher
    # Test with year
    # Test with part
    # Test with languages
    # Test with stage
  end

  describe "#initialize" do
    # Test attribute assignment
    # Test defaults
  end
end
```

#### Supplement Identifiers
**Files to create:**
- `spec/pubid_new/iso/identifiers/amendment_spec.rb`
- `spec/pubid_new/iso/identifiers/corrigendum_spec.rb`
- `spec/pubid_new/iso/identifiers/supplement_spec.rb`
- `spec/pubid_new/iso/identifiers/extract_spec.rb`

**Test patterns:**
```ruby
describe PubidNew::Iso::Identifiers::Amendment do
  describe "TYPED_STAGES" do
    # Test all typed stages are defined
    # Test abbreviations
    # Test stage codes
  end

  describe "#to_s" do
    # Test with base_identifier
    # Test with typed_stage (FDAM)
    # Test without typed_stage (uses default)
    # Test number formatting with space
    # Test with year
  end

  describe "inheritance" do
    # Test inherits from SupplementIdentifier
    # Test base_identifier attribute
  end
end
```

#### Special Identifiers
**Files to create:**
- `spec/pubid_new/iso/identifiers/data_spec.rb`
- `spec/pubid_new/iso/identifiers/pas_spec.rb`
- `spec/pubid_new/iso/identifiers/technology_trends_assessments_spec.rb`
- `spec/pubid_new/iso/identifiers/international_workshop_agreement_spec.rb`
- `spec/pubid_new/iso/identifiers/international_standardized_profile_spec.rb`
- `spec/pubid_new/iso/identifiers/recommendation_spec.rb`
- `spec/pubid_new/iso/identifiers/directives_spec.rb`
- `spec/pubid_new/iso/identifiers/directives_supplement_spec.rb`

### 1.4 Component Unit Tests (1 hour)

**Files to create:**
- `spec/pubid_new/iso/components/publisher_spec.rb`
- `spec/pubid_new/iso/components/code_spec.rb`

Test Publisher copublisher array handling, Code value storage, etc.

---

## Phase 2: Documentation Updates (4 hours)

### 2.1 README.adoc Architecture Section (2 hours)

**File:** `README.adoc`

Add comprehensive architecture documentation:

```adoc
== ISO Parser Architecture

=== Overview

The ISO parser implements a model-driven architecture that separates parsing, building, and rendering concerns.

.Architecture Diagram
[source]
----
┌─────────────────┐
│  Parser Input   │
│  "ISO/IEC ..."  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Parser        │  Parslet Grammar
│   (Parslet)     │  ├─ Publisher rules
│                 │  ├─ Type rules
│                 │  ├─ Supplement rules
│                 │  └─ IWA/DIR SUP rules
└────────┬────────┘
         │ Parse Tree (Hash)
         ▼
┌─────────────────┐
│   Builder       │  Object Construction
│                 │  ├─ Class selection
│                 │  ├─ Component creation
│                 │  ├─ Supplement recursion
│                 │  └─ Special patterns
└────────┬────────┘
         │ Identifier Object
         ▼
┌─────────────────┐
│  Identifier     │  Model Objects
│  Classes        │  ├─ InternationalStandard
│                 │  ├─ Guide, TR, TS, etc
│                 │  ├─ Supplements
│                 │  └─ Directives
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  #to_s Output   │
│  "ISO/IEC ..."  │
└─────────────────┘
----

=== Component Model

All identifiers use shared components for common attributes:

* `Publisher` - Handles publisher and copublisher array
* `Type` - Document type with `abbr` attribute
* `Date` - Year-based dates
* `Code` - Generic string values (number, part)
* `Language` - Language codes with `original_code` attribute
* `Stage` - Document stage
* `TypedStage` - Combined stage+type (e.g., FDAM)

=== Identifier Classes

==== Inheritance Hierarchy

[source]
----
::PubidNew::Identifier (parent)
  │
  ├─ PubidNew::Iso::SingleIdentifier
  │   ├─ InternationalStandard
  │   ├─ Guide
  │   ├─ TechnicalReport
  │   ├─ TechnicalSpecification
  │   ├─ Data
  │   ├─ Pas
  │   ├─ TechnologyTrendsAssessments
  │   ├─ InternationalWorkshopAgreement
  │   ├─ InternationalStandardizedProfile
  │   ├─ Recommendation
  │   └─ Directives
  │
  └─ PubidNew::Iso::SupplementIdentifier
      ├─ Amendment
      ├─ Corrigendum
      ├─ Supplement
      ├─ Extract
      └─ DirectivesSupplement
----
```

### 2.2 Architecture Documentation (1 hour)

**File:** `docs/architecture/iso-parser.adoc`

Create detailed architecture document covering:
- Parser grammar rules
- Builder algorithm
- Component design
- Supplement recursion pattern
- Special case handling (DIR SUP, IWA)

### 2.3 Usage Examples (1 hour)

**File:** Update `README.adoc` with usage examples

```adoc
== Usage Examples

=== Basic Parsing

[source,ruby]
----
require "pubid_new"

# International Standard
id = PubidNew::Iso::Identifier.parse("ISO 19115:2003")
id.class # => PubidNew::Iso::Identifiers::InternationalStandard
id.to_s  # => "ISO 19115:2003"

# With copublisher
id = PubidNew::Iso::Identifier.parse("ISO/IEC 27001:2013")
id.publisher.to_s # => "ISO/IEC"

# Multiple copublishers
id = PubidNew::Iso::Identifier.parse("ISO/IEC/IEEE 8802-3:2021")
id.publisher.copublisher # => ["IEC", "IEEE"]
----

=== Supplements

[source,ruby]
----
# Amendment
id = PubidNew::Iso::Identifier.parse("ISO 19110:2005/Amd 1:2011")
id.class # => PubidNew::Iso::Identifiers::Amendment
id.base_identifier.to_s # => "ISO 19110:2005"

# Staged amendment
id = PubidNew::Iso::Identifier.parse("ISO/IEC 8802-3:2021/FDAM 1")
id.typed_stage.abbreviation # => "FDAM"

# Multi-level
id = PubidNew::Iso::Identifier.parse("ISO/IEC 13818-1:2015/Amd 3:2016/Cor 1:2017")
id.class # => PubidNew::Iso::Identifiers::Corrigendum
id.base_identifier.class # => PubidNew::Iso::Identifiers::Amendment
----

=== Special Types

[source,ruby]
----
# Technical Report
id = PubidNew::Iso::Identifier.parse("ISO/IEC TR 29186:2012")
id.type.abbr # => "TR"

# Guide
id = PubidNew::Iso::Identifier.parse("ISO/IEC Guide 51:1999(E/F/R)")
id.languages.map(&:original_code) # => ["E/F/R"]

# Directives
id = PubidNew::Iso::Identifier.parse("ISO/IEC DIR 1:2022")
id.class # => PubidNew::Iso::Identifiers::Directives

# Directives Supplement
id = PubidNew::Iso::Identifier.parse("ISO/IEC DIR 1 ISO SUP:2022")
id.class # => PubidNew::Iso::Identifiers::DirectivesSupplement
id.supplement_publisher.to_s # => "ISO"
----
```

---

## Phase 3: Code Quality & Cleanup (2 hours)

### 3.1 Rubocop Cleanup (1 hour)

Run and fix all Rubocop violations:

```bash
bundle exec rubocop lib/pubid_new/iso/ --auto-correct
bundle exec rubocop spec/pubid_new/iso/ --auto-correct
```

Address any remaining manual fixes for:
- Line length (80 chars max)
- Method complexity
- Documentation coverage
- Naming conventions

### 3.2 Remove Debug Code (0.5 hours)

Search and remove:
- `puts` statements
- `pp` or `p` debugging
- Commented-out code blocks
- TODO comments that are completed

### 3.3 Code Review (0.5 hours)

Manual review checklist:
- [ ] All classes follow OOP principles
- [ ] No utility/helper classes
- [ ] No hardcoded values
- [ ] Proper nil checks
- [ ] Component API usage consistent
- [ ] No parent class modifications
- [ ] MECE design maintained

---

## Phase 4: Performance Validation (1 hour)

### 4.1 Benchmark Suite

**File:** `spec/pubid_new/iso/performance_spec.rb`

```ruby
require "benchmark"

RSpec.describe "ISO Parser Performance" do
  let(:simple_id) { "ISO 19115:2003" }
  let(:complex_id) { "ISO/IEC/IEEE 8802-3:2021/FDAM 1" }
  let(:multilevel_id) { "ISO/IEC 13818-1:2015/Amd 3:2016/Cor 1:2017" }

  it "parses simple identifiers efficiently" do
    time = Benchmark.measure do
      1000.times { PubidNew::Iso::Identifier.parse(simple_id) }
    end

    expect(time.real).to be < 1.0 # Should complete in under 1 second
  end

  it "parses complex identifiers efficiently" do
    time = Benchmark.measure do
      1000.times { PubidNew::Iso::Identifier.parse(complex_id) }
    end

    expect(time.real).to be < 2.0
  end
end
```

---

## Phase 5: Documentation Cleanup (Ongoing)

### 5.1 Move Completed Session Docs

Move to `old-docs/`:
- `CONTINUATION_PLAN.md` (Session 2 plan)
- `CONTINUATION_PROMPT.md` (if exists from Session 1)
- Any `SESSION_SUMMARY_*.md` files
- Temporary `NOTES_*.md` files

### 5.2 Update Status Tracker

Keep `IMPLEMENTATION_STATUS.md` current with:
- Test coverage metrics
- Documentation completion status
- Code quality indicators
- Performance benchmarks

---

## Success Criteria

### Must Have ✅
- [ ] All identifier classes have unit test specs
- [ ] Parser has comprehensive unit tests
- [ ] Builder has unit tests covering all branches
- [ ] README.adoc has architecture section
- [ ] All Rubocop violations fixed
- [ ] No debug code remaining
- [ ] All tests passing (integration + unit)

### Should Have 📋
- [ ] Architecture documentation in docs/
- [ ] Usage examples in README
- [ ] Performance benchmarks run
- [ ] Code review completed
- [ ] Old docs moved to old-docs/

### Could Have 💭
- [ ] Additional edge case tests
- [ ] Component specs expanded
- [ ] Memory profiling
- [ ] Code coverage report (>95%)

---

## Risks & Mitigation

### Risk 1: Unit Tests Break Integration Tests
**Mitigation:** Run integration tests after each unit test file creation

### Risk 2: Rubocop Changes Break Functionality
**Mitigation:** Run full test suite after auto-correct, manual review before committing

### Risk 3: Documentation Out of Sync
**Mitigation:** Generate examples directly from working code, verify all examples

---

## Next Session Preview

Session 4 will focus on:
1. Additional identifier patterns (if discovered)
2. French/Russian language support (currently marked `xcontext`)
3. URN rendering support
4. Legacy identifier migration
5. Final production readiness review

---

**Estimated Completion:** Session 3 should complete 100% of core functionality testing and documentation.