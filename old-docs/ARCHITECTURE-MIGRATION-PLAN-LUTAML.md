# PubID v2 Architecture Migration Plan - Lutaml::Model Implementation
#
# Branch: rt-new-lutaml-model
# Date: 2025-11-17
# Status: Ready for Execution

**Executive Summary**

This document outlines the migration plan for converting all PubID v2 flavor implementations to proper Lutaml::Model architecture. Current implementations for NIST, IEEE, ETSI, ITU, and JIS use an incorrect monolithic `Scheme` class pattern. The correct pattern, demonstrated by ISO and CCSDS, uses a hierarchy of identifier classes inheriting from Lutaml::Model::Serializable.

**Migration Priority Order (Easiest → Hardest):**
1. **IEC** (13,889 cases) - Nearly identical to ISO, ideal starting point
2. **JIS** (10,635 cases) - Subset of ISO patterns
3. **ETSI** (24,718 cases) - Simple TS/TR structure
4. **ITU** (2,041 cases) - Simple Recommendation structure
5. **IEEE** (640 cases) - Complex with copublishers and amendments
6. **NIST** (20,211 cases) - Most complex with 9+ document types

**Estimated Timeline:** 8-10 weeks total

**Key Principle:** Preserve all valuable parser, builder, and test work while converting to proper architectural patterns.

## Current State Analysis

### What's Correct ✅
- **ISO implementation** (`lib/pubid_new/iso/`) - Perfect reference model
- **CCSDS implementation** (`lib/pubid_new/ccsds/`) - Already correct
- **Parser logic** - Parslet rules are sound across all flavors
- **Test fixtures** - All 79,876 test cases are valuable
- **Integration test infrastructure** - FixtureLoader utility works well

### What Needs Migration ❌
- **NIST, IEEE, ETSI, ITU, JIS** - Using monolithic Scheme as data model
- Missing proper identifier class hierarchy
- Not leveraging Lutaml::Model::Serializable components
- Scheme should be registry, not data model

## Architecture Overview

### Incorrect Pattern (Current for Most Flavors)

```ruby
# WRONG: Scheme used as data model
class Scheme < Lutaml::Model::Serializable
  attribute :series, :string
  attribute :number, :string
  attribute :part, :string
  # ... many attributes

  def to_s
    # Complex rendering logic
  end
end
```

**Problems:**
- Single class handles all identifier types
- No polymorphism for type-specific behavior
- Difficult to extend with new types
- Violates Single Responsibility Principle

### Correct Pattern (ISO/CCSDS)

```ruby
# Component classes
module Components
  class Code < Lutaml::Model::Serializable
    attribute :prefix, :string
    attribute :number, :string

    def to_s
      "#{prefix} #{number}"
    end
  end

  class Publisher < Lutaml::Model::Serializable
    attribute :name, :string
    attribute :abbr, :string
  end
end

# Base identifier
class SingleIdentifier < Identifier
  attribute :code, Components::Code
  attribute :publisher, Components::Publisher
  attribute :typed_stage, Components::TypedStage

  def self.type
    raise NotImplementedError
  end
end

# Concrete identifier classes
class TechnicalReport < SingleIdentifier
  TYPED_STAGES = [
    Components::TypedStage.new(
      code: :dtr,
      type_code: :tr,
      abbr: ["DTR"],
      name: "Draft Technical Report"
    ),
    Components::TypedStage.new(
      code: :tr,
      type_code: :tr,
      abbr: ["TR"],
      name: "Technical Report"
    )
  ].freeze

  def self.type
    { key: :tr, title: "Technical Report", short: "TR" }
  end
end

# Registry pattern
class Scheme
  IDENTIFIER_CLASSES = [
    InternationalStandard,
    TechnicalReport,
    TechnicalSpecification,
    Guide
  ].freeze

  def self.parse(string)
    parsed = Parser.new.parse(string)
    Builder.new(self).build(parsed)
  end

  def locate_typed_stage_by_abbr(abbr)
    IDENTIFIER_CLASSES.each do |klass|
      klass::TYPED_STAGES.each do |stage|
        return stage if stage.abbr.include?(abbr)
      end
    end
    nil
  end

  def locate_identifier_klass_by_type_code(type_code)
    IDENTIFIER_CLASSES.find { |k| k.type[:key] == type_code }
  end
end
```

**Benefits:**
- Component-based design with semantic types
- Polymorphic identifier classes for each document type
- Self-describing through TYPED_STAGES
- Easy to extend with new types
- Clear separation of concerns

## Understanding TYPED_STAGES Pattern

### The Flow

1. **Parser** extracts stage/type abbreviation (e.g., "DTR", "TR", "TS")
2. **Builder** calls `scheme.locate_typed_stage_by_abbr(abbr)`
3. **Scheme** searches all identifier classes' TYPED_STAGES arrays
4. **Scheme** returns matching TypedStage object
5. **Builder** extracts `typed_stage.type_code`
6. **Builder** calls `scheme.locate_identifier_klass_by_type_code(type_code)`
7. **Scheme** returns identifier class where `type[:key] == type_code`
8. **Builder** instantiates that class with typed_stage and attributes

### Why No TYPE_MAP?

**DON'T DO THIS (violates OO principles):**
```ruby
TYPE_MAP = {
  'TR' => TechnicalReport,
  'TS' => TechnicalSpecification
}.freeze
```

**WHY:**
- Hardcoded mapping in wrong place
- Classes can't declare their own types
- Not extensible (Open/Closed violation)
- Not self-documenting

**DO THIS (proper OO design):**
- Each class declares its TYPED_STAGES
- Scheme provides lookup methods
- Classes are self-describing
- Extensible by adding new classes

### v1 to v2 Conversion

**IEC v1 (Hash-based):**
```ruby
TYPED_STAGES = {
  dtr: {
    abbr: "DTR",
    name: "Draft Technical Report"
  }
}
```

**IEC v2 (Object-based):**
```ruby
TYPED_STAGES = [
  Components::TypedStage.new(
    code: :dtr,
    abbr: ["DTR"],
    name: "Draft Technical Report"
  )
].freeze
```

The pattern is the same, just the format changed!

## Phase 1: IEC Migration (Week 1-2)

### Why IEC First?

- **Nearly identical to ISO** - Same international standards structure
- **Quick validation** - If IEC works, pattern is proven
- **High test coverage** - 13,889 test cases
- **Multiple document types** - Tests full architecture
- **Reusable components** - Most can come from ISO

### IEC Document Types (from v1 analysis)

**Main Types:**
1. InternationalStandard (IEC xxxxx)
2. TechnicalReport (IEC TR xxxxx)
3. TechnicalSpecification (IEC TS xxxxx)
4. Guide (IEC Guide xx)
5. PubliclyAvailableSpecification (IEC PAS xxxxx)

**IEC-Specific Types:**
6. TestReportForm (IEC xxxxx TRF)
7. InterpretationSheet (IEC xxxxx ISH)
8. WorkingDocument (committee documents)

**Special Features:**
- Consolidated amendments (+AMD1+AMD2 format)
- VAP suffix codes (CMV, RLV, etc.)
- Multiple copublishers (CISPR, IECEE, IECEx, IECQ)
- CSV publications

### Step-by-Step IEC Migration

#### Step 1: Study References (0.5 day)

**Read ISO v2 Implementation:**
```
lib/pubid_new/iso.rb - Entry point
lib/pubid_new/iso/scheme.rb - Registry pattern
lib/pubid_new/iso/builder.rb - Type determination
lib/pubid_new/iso/single_identifier.rb - Base class
lib/pubid_new/iso/identifier/technical_report.rb - Example type
```

**Analyze IEC v1 Implementation:**
```
gems/pubid-iec/lib/pubid/iec/identifier/ - All identifier types
gems/pubid-iec/lib/pubid/iec/identifier/base.rb - v1 base patterns
```

**Document Findings:**
Create `docs/IEC-MIGRATION-ANALYSIS.md` noting:
- Which types exist
- Which components needed
- Differences from ISO
- IEC-specific features

#### Step 2: Create Component Classes (1 day)

Location: `lib/pubid_new/iec/components/`

**Reuse from ISO (copy as-is):**
- `part.rb` - Part handling
- `amendment.rb` - Amendment handling
- `corrigendum.rb` - Corrigendum handling
- `supplement.rb` - Supplement handling
- `date.rb` - Date handling

**Create IEC-Specific:**

`publisher.rb`:
```ruby
module PubidNew
  module Iec
    module Components
      class Publisher < Lutaml::Model::Serializable
        PUBLISHERS = {
          'IEC' => 'International Electrotechnical Commission',
          'ISO/IEC' => 'ISO/IEC Joint Technical Committee',
          'CISPR' => 'International Special Committee on Radio Interference',
          'IECEE' => 'IEC System of Conformity Assessment Schemes',
          'IECEx' => 'IEC System for Certification to Standards',
          'IECQ' => 'IEC Quality Assessment System'
        }.freeze

        attribute :code, :string

        def to_s
          code
        end
      end
    end
  end
end
```

`code.rb`:
```ruby
module PubidNew
  module Iec
    module Components
      class Code < Lutaml::Model::Serializable
        attribute :prefix, :string  # IEC, TR, TS, etc.
        attribute :number, :string  # 60034, etc.
        attribute :part, :string, default: -> { nil }

        def to_s
          result = "#{prefix} #{number}"
          result += "-#{part}" if part
          result
        end
      end
    end
  end
end
```

`consolidated_amendment.rb` (NEW):
```ruby
module PubidNew
  module Iec
    module Components
      class ConsolidatedAmendment < Lutaml::Model::Serializable
        attribute :amendments, :string, collection: true

        def to_s
          amendments.map { |a| "+AMD#{a}" }.join
        end
      end
    end
  end
end
```

`vap_suffix.rb` (NEW):
```ruby
module PubidNew
  module Iec
    module Components
      class VapSuffix < Lutaml::Model::Serializable
        SUFFIXES = %w[CMV RLV SER].freeze

        attribute :code, :string

        def validate!
          unless SUFFIXES.include?(code)
            raise "Unknown VAP suffix: #{code}"
          end
        end

        def to_s
          " #{code}"
        end
      end
    end
  end
end
```

**Each component gets a spec file:**
```
spec/pubid_new/iec/components/publisher_spec.rb
spec/pubid_new/iec/components/code_spec.rb
spec/pubid_new/iec/components/consolidated_amendment_spec.rb
spec/pubid_new/iec/components/vap_suffix_spec.rb
```

#### Step 3: Create Identifier Classes (2 days)

Location: `lib/pubid_new/iec/identifier/`

**Base Class** (`base.rb`):
```ruby
module PubidNew
  module Iec
    module Identifier
      class Base < ::Identifier
        attribute :publisher, Components::Publisher
        attribute :code, Components::Code
        attribute :typed_stage, Components::TypedStage, default: -> { nil }
        attribute :edition, Components::Edition, default: -> { nil }
        attribute :part, Components::Part, default: -> { nil }
        attribute :amendment, Components::Amendment, default: -> { nil }
        attribute :corrigendum, Components::Corrigendum, default: -> { nil }
        attribute :consolidated_amendments, Components::ConsolidatedAmendment, default: -> { nil }
        attribute :vap_suffix, Components::VapSuffix, default: -> { nil }

        def to_s(format = :short)
          # Common rendering logic
        end

        def self.type
          raise NotImplementedError, "Subclass must implement"
        end
      end
    end
  end
end
```

**Concrete Classes** (copy from ISO TechnicalReport and adapt):

`international_standard.rb`:
```ruby
module PubidNew
  module Iec
    module Identifier
      class InternationalStandard < Base
        TYPED_STAGES = [
          # Copy from v1, convert to TypedStage objects
          Components::TypedStage.new(
            code: :published,
            type_code: :is,
            abbr: ["IEC"],
            name: "International Standard"
          )
        ].freeze

        def self.type
          { key: :is, title: "International Standard", short: "IEC" }
        end
      end
    end
  end
end
```

Create similarly:
- `technical_report.rb`
- `technical_specification.rb`
- `guide.rb`
- `publicly_available_specification.rb`
- `test_report_form.rb`
- `interpretation_sheet.rb`
- `working_document.rb`

**Each gets a comprehensive spec:**
```
spec/pubid_new/iec/identifier/international_standard_spec.rb
# Tests parsing, rendering, validation, edge cases
```

#### Step 4: Update Builder (1 day)

File: `lib/pubid_new/iec/builder.rb`

```ruby
module PubidNew
  module Iec
    class Builder
      def initialize(scheme)
        @scheme = scheme
      end

      def build(parsed)
        # 1. Determine type through TYPED_STAGES lookup
        abbr = extract_type_abbr(parsed)
        typed_stage = @scheme.locate_typed_stage_by_abbr(abbr)

        # 2. Get identifier class
        klass = @scheme.locate_identifier_klass_by_type_code(typed_stage.type_code)

        # 3. Extract and build attributes
        attributes = extract_attributes(parsed, typed_stage)

        # 4. Instantiate
        klass.new(**attributes)
      end

      private

      def extract_type_abbr(parsed)
        parsed[:type] || parsed[:series] || 'IEC'
      end

      def extract_attributes(parsed, typed_stage)
        {
          publisher: build_publisher(parsed[:publisher]),
          code: build_code(parsed),
          typed_stage: typed_stage,
          edition: build_edition(parsed[:edition]),
          # ... all attributes
        }.compact
      end

      def build_publisher(value)
        return nil unless value
        Components::Publisher.new(code: value.to_s)
      end

      def build_code(parsed)
        Components::Code.new(
          prefix: parsed[:prefix] || 'IEC',
          number: parsed[:number].to_s,
          part: parsed[:part]&.to_s
        )
      end

      # ... other builder methods
    end
  end
end
```

#### Step 5: Update Scheme (0.5 day)

File: `lib/pubid_new/iec/scheme.rb`

```ruby
module PubidNew
  module Iec
    class Scheme
      IDENTIFIER_CLASSES = [
        Identifier::InternationalStandard,
        Identifier::TechnicalReport,
        Identifier::TechnicalSpecification,
        Identifier::Guide,
        Identifier::PubliclyAvailableSpecification,
        Identifier::TestReportForm,
        Identifier::InterpretationSheet,
        Identifier::WorkingDocument
      ].freeze

      def self.parse(string)
        parsed = Parser.new.parse(string)
        Builder.new(new).build(parsed)
      rescue Parslet::ParseFailed => e
        raise Errors::ParseError, "Failed to parse: #{string}"
      end

      def locate_typed_stage_by_abbr(abbr)
        IDENTIFIER_CLASSES.each do |klass|
          klass::TYPED_STAGES.each do |stage|
            return stage if stage.abbr.include?(abbr)
          end
        end
        nil
      end

      def locate_identifier_klass_by_type_code(type_code)
        IDENTIFIER_CLASSES.find { |k| k.type[:key] == type_code }
      end
    end
  end
end
```

#### Step 6: Wire Entry Point (0.5 day)

File: `lib/pubid_new/iec.rb`

```ruby
require 'lutaml/model'

# Require components
require_relative 'iec/components/publisher'
require_relative 'iec/components/code'
require_relative 'iec/components/consolidated_amendment'
require_relative 'iec/components/vap_suffix'

# Require shared components
require_relative 'components/part'
require_relative 'components/amendment'
require_relative 'components/corrigendum'
require_relative 'components/typed_stage'
require_relative 'components/edition'

# Require identifier classes
require_relative 'iec/identifier/base'
require_relative 'iec/identifier/international_standard'
require_relative 'iec/identifier/technical_report'
require_relative 'iec/identifier/technical_specification'
require_relative 'iec/identifier/guide'
require_relative 'iec/identifier/publicly_available_specification'
require_relative 'iec/identifier/test_report_form'
require_relative 'iec/identifier/interpretation_sheet'
require_relative 'iec/identifier/working_document'

# Require infrastructure
require_relative 'iec/parser'
require_relative 'iec/builder'
require_relative 'iec/scheme'
require_relative 'iec/errors'

module PubidNew
  module Iec
    def self.parse(string)
      Scheme.parse(string)
    end
  end
end
```

#### Step 7: Test & Validate (1 day)

Run integration test:
```bash
bundle exec rspec spec/integration/iec_spec.rb --format documentation
```

**Success Criteria:**
- All unit tests passing
- Integration test running (target: maintain 22.82% baseline, aim for 35%+)
- Basic types working (IS, TR, TS, Guide)
- Architecture matches ISO reference
- No hardcoded TYPE_MAP or similar anti-patterns

#### Step 8: Document & Review (0.5 day)

Create `docs/IEC-MIGRATION-COMPLETE.md`:
- What was migrated
- Lessons learned
- Patterns to reuse for other flavors
- Remaining IEC-specific work (CSV, TRF enhancements)

## Remaining Phases

### Phase 2: JIS Migration (Week 3)
- Copy IEC/ISO patterns
- JIS categories instead of types
- Simpler than IEC (no consolidate amendments)
- Timeline: 1 week

### Phase 3: ETSI Migration (Week 4)
- Simple TS/TR structure
- Copy from ISO TechnicalReport/TechnicalSpecification
- Timeline: 1 week

### Phase 4: ITU Migration (Week 5)
- Recommendations with sector/series
- Simpler inheritance structure
- Timeline: 1 week

### Phase 5: IEEE Migration (Week 6-7)
- Standards with amendments/corrigenda
- Multiple copublisher support (ANSI, etc.)
- Reaffirmation dates
- Timeline: 1-2 weeks

### Phase 6: NIST Migration (Week 8-9)
- Most complex: 9+ document types
- Historical NBS → NIST transition
- Multiple series with different rules
- Date-based editions
- Apply all lessons learned
- Timeline: 2 weeks

### Phase 7: Testing & Polish (Week 10)
- Full integration test suite
- Performance optimization
- Documentation completion
- Final validation

## Quality Gates

Every phase must meet these criteria before proceeding:

✅ **Architecture Compliance**
- All identifiers inherit from Lutaml::Model::Serializable
- Proper component-based design
- TYPED_STAGES declared in each class
- Scheme uses lookup methods, not TYPE_MAP
- No hardcoded magic values

✅ **Testing**
- Every class has comprehensive spec file
- Integration tests maintain or improve pass rate
- All edge cases covered
- No lowered thresholds

✅ **Code Quality**
- Each class has ONE responsibility
- MECE principles followed
- Clear separation of concerns
- Self-documenting code
- Proper error handling

✅ **Documentation**
- README updated
- Architecture documented
- Examples provided
- Lessons learned captured

## Timeline Summary

| Phase | Flavor | Complexity | Duration | Cumulative |
|-------|--------|------------|----------|------------|
| 1 | IEC | Low (like ISO) | 5-7 days | 1 week |
| 2 | JIS | Low (subset ISO) | 5 days | 2 weeks |
| 3 | ETSI | Low (simple) | 5 days | 3 weeks |
| 4 | ITU | Low (simple) | 5 days | 4 weeks |
| 5 | IEEE | Medium | 7-10 days | 6 weeks |
| 6 | NIST | High | 10-14 days | 8 weeks |
| 7 | Polish | - | 5-7 days | 9 weeks |
| **TOTAL** | **All** | - | **8-10 weeks** | - |

## Execution Prompt for Phase 1

```
START IEC MIGRATION - PHASE 1.1

OBJECTIVE: Create IEC v2 base infrastructure using ISO as template

STEP 1: Study ISO Implementation (2 hours)
Read these files completely:
- lib/pubid_new/iso.rb
- lib/pubid_new/iso/scheme.rb
- lib/pubid_new/iso/builder.rb
- lib/pubid_new/iso/single_identifier.rb
- lib/pubid_new/iso/identifier/technical_report.rb
- lib/pubid_new/components/typed_stage.rb

Understand:
1. How Builder determines identifier class (through Scheme lookup)
2. How TYPED_STAGES work (self-describing classes)
3. Component pattern (semantic types)
4. Registry pattern (Scheme)

STEP 2: Analyze IEC v1 (2 hours)
Read gems/pubid-iec/lib/pubid/iec/ structure
Document in docs/IEC-MIGRATION-ANALYSIS.md:
- Document types found
- Components needed
- TYPED_STAGES to convert
- IEC-specific features

STEP 3: Create Components (1 day)
Location: lib/pubid_new/iec/components/

Create:
- publisher.rb (with spec)
- code.rb (with spec)
- consolidated_amendment.rb (with spec)
- vap_suffix.rb (with spec)

Copy from ISO:
- Reuse part, amendment, corrigendum, supplement

STEP 4: Create Identifier Classes (2 days)
Location: lib/pubid_new/iec/identifier/

Create base.rb + 8 concrete classes (each with spec):
- international_standard.rb
- technical_report.rb
- technical_specification.rb
- guide.rb
- publicly_available_specification.rb
- test_report_form.rb
- interpretation_sheet.rb
- working_document.rb

Convert v1 TYPED_STAGES to v2 format (hash → TypedStage objects)

STEP 5: Update Builder (1 day)
Adapt lib/pubid_new/iec/builder.rb:
- Use scheme.locate_typed_stage_by_abbr
- Use scheme.locate_identifier_klass_by_type_code
- Transform to component objects
- Write comprehensive spec

STEP 6: Update Scheme (0.5 day)
Convert lib/pubid_new/iec/scheme.rb to registry:
- List IDENTIFIER_CLASSES
- Implement locate_typed_stage_by_abbr
- Implement locate_identifier_klass_by_type_code
- Write spec

STEP 7: Wire Entry Point (0.5 day)
Update lib/pubid_new/iec.rb:
- Require all components
- Require all identifier classes
- Provide PubidNew::Iec.parse

STEP 8: Test (1 day)
Run: bundle exec rspec spec/integration/iec_spec.rb
Create unit specs for all new classes
Target: 30%+ pass rate (up from 22.82%)

VALIDATION CHECKLIST:
□ Architecture matches ISO reference
□ No TYPE_MAP or hardcoded mappings
□ Every class has spec file
□ TYPED_STAGES in each identifier class
□ Components properly reused
□ Code follows MECE principles
□ Integration test improvement

NEXT: Phase 1.2 will add IEC-specific features (CSV, TRF)

BEGIN: Step 1 - Study ISO implementation
```

## Success Criteria

✅ All 79,876 test cases pass after migration
✅ All flavors follow ISO architectural pattern
✅ Every identifier has proper class hierarchy
✅ All classes have comprehensive specs
✅ Code is maintainable and extensible
✅ No architectural shortcuts or compromises
✅ Production-ready implementation

---

**Document Status:** Complete and ready for execution
**Next Action:** Execute Phase 1.1 - IEC Migration using the prompt above
