# PubID v2 Standardization and Documentation Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Systematically standardize all 29 PubID v2 flavors to ensure fully OOP architecture with congruent structure, good separation of responsibilities, and comprehensive documentation for release readiness.

**Architecture:** Consolidate all flavors on TYPED_STAGES registry pattern, three-layer architecture (Parser → Builder → Identifier), and complete base class hierarchy (single_identifier, supplement_identifier) for proper supplement recursion.

**Tech Stack:** Ruby 3.3, Parslet (PEG parsing), Lutaml::Model (serialization), RSpec (testing)

---

## Phase 1: Foundation - Create Flavor Documentation Template

**Duration:** ~30 minutes

Create a reusable documentation template that will be used for all 29 flavors.

### Task 1: Create Flavor Documentation Template

**Files:**
- Create: `docs/flavor-documentation-template.md`

**Step 1: Create documentation template**

```markdown
# [Flavor Name] Documentation

## Overview

[2-3 sentences about what this flavor handles]

## Architecture

Three-layer architecture:
1. **Parser** (`parser.rb`) - Parslet PEG grammar for syntax parsing
2. **Builder** (`builder.rb`) - Transforms parse trees to domain objects via Scheme registry
3. **Identifier** (`identifiers/`) - Lutaml::Model domain classes with rendering logic

## Components

### Flavor-Specific Components
[List any components specific to this flavor]

### Shared Components Used
- `Publisher` - Organization name and copublishers
- `Code` - Generic string values (number, part, iteration)
- `Date` - Year-based dates
- `Type` - Document type
- etc.

## Identifier Classes

### Base Identifiers

#### [ClassName]
- **File:** `identifiers/[class_name].rb`
- **Parent:** `SingleIdentifier` or `SupplementIdentifier`
- **Purpose:** [What this identifier represents]
- **Components Used:** [List components]
- **Patterns Supported:**
  - `[Pattern 1]` → `[Example]`
  - `[Pattern 2]` → `[Example]`
- **TYPED_STAGES:** [If applicable]

### Supplement Identifiers

#### [ClassName]
[Same structure as base identifiers]

## Scheme Registry

The `Scheme` class provides:
- `identifiers` array - All registered identifier classes
- `typed_stages` - Aggregate TYPED_STAGES from all identifier classes
- `locate_typed_stage_by_abbr(abbr)` - Find stage by abbreviation
- `locate_identifier_klass_by_type_code(type_code)` - Select class by type code

## Rendering Examples

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| [Pattern] | [Output] |
```

**Step 2: Commit template**

```bash
git add docs/flavor-documentation-template.md
git commit -m "docs: add flavor documentation template for PubID v2 standardization"
```

---

## Phase 2: Fix Missing Base Files in Incomplete Flavors

**Duration:** ~2 hours

Fix 6 flavors missing critical base files: `cie`, `idf`, `asme`, `astm`, `csa`, `oiml`

### Task 2: Fix CIE Flavor - Missing scheme.rb

**Files:**
- Create: `lib/pubid_new/cie/scheme.rb`

**Step 1: Write test for CIE Scheme**

```ruby
# spec/pubid_new/cie/scheme_spec.rb
require "spec_helper"

RSpec.describe PubidNew::Cie::Scheme do
  describe "#identifiers" do
    it "returns array of registered identifier classes" do
      scheme = PubidNew::Cie::Scheme.new
      expect(scheme.identifiers).to include(PubidNew::Cie::Identifiers::Standard)
      expect(scheme.identifiers).to include(PubidNew::Cie::Identifiers::Corrigendum)
    end
  end

  describe "#locate_typed_stage_by_abbr" do
    it "finds stage by abbreviation" do
      scheme = PubidNew::Cie::Scheme.new
      stage = scheme.locate_typed_stage_by_abbr("COR")
      expect(stage).to be_a(PubidNew::Components::TypedStage)
      expect(stage.stage_code).to eq("corrected")
    end
  end
end
```

**Step 2: Run test to verify it fails**

```bash
bundle exec rspec spec/pubid_new/cie/scheme_spec.rb
```
Expected: FAIL with "uninitialized constant PubidNew::Cie::Scheme"

**Step 3: Create CIE Scheme class**

```ruby
# lib/pubid_new/cie/scheme.rb
# frozen_string_literal: true

require_relative "../scheme"
require_relative "identifier"
require_relative "identifiers/base"

module PubidNew
  module Cie
    class Scheme < PubidNew::Scheme
      def initialize
        @identifiers = [
          Identifiers::Standard,
          Identifiers::Conference,
          Identifiers::Corrigendum,
          Identifiers::DualPublished,
          Identifiers::Identical,
          Identifiers::JointPublished,
          Identifiers::Supplement,
          Identifiers::Bundle,
          Identifiers::TutorialBundle,
        ].freeze
      end
    end
  end
end
```

**Step 4: Run test to verify it passes**

```bash
bundle exec rspec spec/pubid_new/cie/scheme_spec.rb
```
Expected: PASS

**Step 5: Commit**

```bash
git add lib/pubid_new/cie/scheme.rb spec/pubid_new/cie/scheme_spec.rb
git commit -m "feat(cie): add Scheme class with registry"
```

### Task 3: Fix CIE Flavor - Missing single_identifier.rb

**Files:**
- Create: `lib/pubid_new/cie/single_identifier.rb`
- Create: `spec/pubid_new/cie/single_identifier_spec.rb`

**Step 1: Write test for SingleIdentifier**

```ruby
# spec/pubid_new/cie/single_identifier_spec.rb
require "spec_helper"

RSpec.describe PubidNew::Cie::SingleIdentifier do
  describe "inheritance" do
    it "inherits from Base" do
      std = PubidNew::Cie::Identifiers::Standard.new(code: "1")
      expect(std).to be_a(PubidNew::Cie::SingleIdentifier)
      expect(std).to be_a(PubidNew::Cie::Identifiers::Base)
    end
  end
end
```

**Step 2: Run test to verify it fails**

```bash
bundle exec rspec spec/pubid_new/cie/single_identifier_spec.rb
```
Expected: FAIL with "uninitialized constant PubidNew::Cie::SingleIdentifier"

**Step 3: Create SingleIdentifier class**

```ruby
# lib/pubid_new/cie/single_identifier.rb
# frozen_string_literal: true

require_relative "identifier"
require_relative "identifiers/base"

module PubidNew
  module Cie
    # Base class for single CIE identifiers (standards, conferences, etc.)
    # Single Responsibility: Provide common attributes for base documents
    class SingleIdentifier < Identifier
      attribute :code, Components::Code
      attribute :year, Components::Date
      attribute :type, Components::Type
      attribute :publisher, Components::Publisher
    end
  end
end
```

**Step 4: Update existing identifier classes to inherit from SingleIdentifier**

For each file in `lib/pubid_new/cie/identifiers/` (standard.rb, conference.rb, etc.), ensure they inherit from `SingleIdentifier`:

```ruby
# lib/pubid_new/cie/identifiers/standard.rb
require_relative "../single_identifier"

module PubidNew
  module Cie
    module Identifiers
      class Standard < SingleIdentifier
        # ... rest of class
      end
    end
  end
end
```

**Step 5: Run tests**

```bash
bundle exec rspec spec/pubid_new/cie/
```

**Step 6: Commit**

```bash
git add lib/pubid_new/cie/ spec/pubid_new/cie/
git commit -m "feat(cie): add SingleIdentifier base class"
```

### Task 4: Fix CIE Flavor - Missing supplement_identifier.rb

**Files:**
- Create: `lib/pubid_new/cie/supplement_identifier.rb`
- Create: `spec/pubid_new/cie/supplement_identifier_spec.rb`

**Step 1: Write test for supplement recursion**

```ruby
# spec/pubid_new/cie/supplement_identifier_spec.rb
require "spec_helper"

RSpec.describe PubidNew::Cie::SupplementIdentifier do
  describe "supplement recursion" do
    it "supports nested supplements" do
      base = PubidNew::Cie::Identifiers::Standard.new(code: "1", year: 2020)
      corr = PubidNew::Cie::Identifiers::Corrigendum.new(
        base_identifier: base,
        code: "1",
        year: 2021
      )
      expect(corr.base_identifier).to eq(base)
    end
  end
end
```

**Step 2: Run test to verify it fails**

```bash
bundle exec rspec spec/pubid_new/cie/supplement_identifier_spec.rb
```
Expected: FAIL with "uninitialized constant PubidNew::Cie::SupplementIdentifier"

**Step 3: Create SupplementIdentifier class**

```ruby
# lib/pubid_new/cie/supplement_identifier.rb
# frozen_string_literal: true

require_relative "identifier"
require_relative "identifiers/base"

module PubidNew
  module Cie
    # Base class for CIE supplements (corrigenda, supplements, bundles)
    # Single Responsibility: Provide base_identifier for supplement recursion
    class SupplementIdentifier < Identifier
      attribute :base_identifier, PubidNew::Cie::Identifiers::Base
      attribute :code, Components::Code
      attribute :year, Components::Date
    end
  end
end
```

**Step 4: Update existing supplement identifiers to inherit from SupplementIdentifier**

For each supplement in `lib/pubid_new/cie/identifiers/` (corrigendum.rb, supplement.rb, bundle.rb), update inheritance:

```ruby
require_relative "../supplement_identifier"

module PubidNew
  module Cie
    module Identifiers
      class Corrigendum < SupplementIdentifier
        # ... rest of class
      end
    end
  end
end
```

**Step 5: Run tests**

```bash
bundle exec rspec spec/pubid_new/cie/
```

**Step 6: Commit**

```bash
git add lib/pubid_new/cie/ spec/pubid_new/cie/
git commit -m "feat(cie): add SupplementIdentifier base class for recursion"
```

### Task 5-19: Repeat for IDF, ASME, ASTM, CSA, OIML

**Pattern:** Repeat Tasks 2-4 for each incomplete flavor, adjusting for their specific identifier classes.

**Use @superpowers:dispatching-parallel-agents** to create 5 parallel agents, one per flavor.

**Each agent should:**
1. Read the flavor's identifiers/ directory to understand what classes exist
2. Create scheme.rb with proper identifiers array
3. Create single_identifier.rb with appropriate attributes
4. Create supplement_identifier.rb with base_identifier attribute
5. Update all identifier classes to use correct base class
6. Write RSpec tests for each new file
7. Run full test suite for flavor
8. Create feature branch and commit

---

## Phase 3: Standardize NIST to TYPED_STAGES Pattern

**Duration:** ~1.5 hours

Convert NIST from series_to_class_map to TYPED_STAGES registry pattern.

### Task 20: Analyze NIST Current Implementation

**Files:**
- Read: `lib/pubid_new/nist/scheme.rb`
- Read: `lib/pubid_new/nist/identifiers/special_publication.rb`

**Step 1: Read current NIST scheme**

```bash
cat lib/pubid_new/nist/scheme.rb
```

**Step 2: Read current NIST identifier**

```bash
cat lib/pubid_new/nist/identifiers/special_publication.rb
```

**Step 3: Document current structure**

Create analysis document: `docs/nist-migration-analysis.md`

```markdown
# NIST Migration Analysis

## Current Pattern
series_to_class_map with prefix matching (SP, FIPS, IR, etc.)

## Target Pattern
TYPED_STAGES array with TypedStage objects

## Identifier Classes to Convert
- SpecialPublication (SP 800-123)
- FederalInformationProcessingStandards (FIPS 201)
- InteragencyReport (IR 1234)
- etc.

## Migration Steps
1. Add TYPED_STAGES to each identifier class
2. Update Scheme to use identifiers array
3. Update Builder to use locate_identifier_klass_by_type_code
4. Remove series_to_class_map
```

### Task 21: Add TYPED_STAGES to NIST SpecialPublication

**Files:**
- Modify: `lib/pubid_new/nist/identifiers/special_publication.rb`

**Step 1: Write test for TYPED_STAGES**

```ruby
# spec/pubid_new/nist/identifiers/special_publication_spec.rb
RSpec.describe PubidNew::Nist::Identifiers::SpecialPublication do
  describe ".typed_stages" do
    it "returns array of typed stages" do
      stages = PubidNew::Nist::Identifiers::SpecialPublication.typed_stages
      expect(stages).to be_a(Array)
      expect(stages.first).to be_a(PubidNew::Components::TypedStage)
    end

    it "includes published stage" do
      stages = PubidNew::Nist::Identifiers::SpecialPublication.typed_stages
      published = stages.find { |s| s.stage_code == "published" }
      expect(published).not_to be_nil
      expect(published.type_code).to eq("sp")
    end
  end
end
```

**Step 2: Run test to verify it fails**

```bash
bundle exec rspec spec/pubid_new/nist/identifiers/special_publication_spec.rb
```
Expected: FAIL with "undefined method 'typed_stages'"

**Step 3: Add TYPED_STAGES to SpecialPublication**

```ruby
# lib/pubid_new/nist/identifiers/special_publication.rb
require_relative "../components/typed_stage"

module PubidNew
  module Nist
    module Identifiers
      class SpecialPublication < SingleIdentifier
        TYPED_STAGES = [
          Components::TypedStage.new(
            abbr: ["SP"],
            stage_code: "published",
            type_code: "sp"
          ),
        ].freeze

        def self.typed_stages
          TYPED_STAGES
        end

        def self.type
          { key: :special_publication, title: "NIST Special Publication", short: "SP" }
        end
      end
    end
  end
end
```

**Step 4: Run test**

```bash
bundle exec rspec spec/pubid_new/nist/identifiers/special_publication_spec.rb
```

**Step 5: Commit**

```bash
git add lib/pubid_new/nist/identifiers/special_publication.rb spec/pubid_new/nist/identifiers/special_publication_spec.rb
git commit -m "feat(nist): add TYPED_STAGES to SpecialPublication"
```

### Task 22-28: Add TYPED_STAGES to All NIST Identifiers

**Pattern:** Repeat Task 21 for each NIST identifier class:
- FederalInformationProcessingStandards
- InteragencyReport
- Handbook
- TechnicalNote
- Circular
- CircularSupplement
- CrplReport
- CommercialStandard
- CommercialStandardEmergency
- Report
- Monograph
- MiscellaneousPublication
- GrantContractorReport
- Ncstar
- Owmwp
- Nsrds
- LetterCircular

**Use @superpowers:dispatching-parallel-agents** to create parallel agents.

### Task 29: Update NIST Scheme to Use TYPED_STAGES

**Files:**
- Modify: `lib/pubid_new/nist/scheme.rb`
- Modify: `lib/pubid_new/nist/builder.rb`

**Step 1: Write test for updated Scheme**

```ruby
# spec/pubid_new/nist/scheme_spec.rb
RSpec.describe PubidNew::Nist::Scheme do
  describe "#locate_identifier_klass_by_type_code" do
    it "returns SpecialPublication for 'sp' type code" do
      scheme = PubidNew::Nist::Scheme.new
      klass = scheme.locate_identifier_klass_by_type_code("sp")
      expect(klass).to eq(PubidNew::Nist::Identifiers::SpecialPublication)
    end

    it "returns FederalInformationProcessingStandards for 'fips'" do
      scheme = PubidNew::Nist::Scheme.new
      klass = scheme.locate_identifier_klass_by_type_code("fips")
      expect(klass).to eq(PubidNew::Nist::Identifiers::FederalInformationProcessingStandards)
    end
  end
end
```

**Step 2: Run test to verify it fails**

```bash
bundle exec rspec spec/pubid_new/nist/scheme_spec.rb
```

**Step 3: Update NIST Scheme class**

```ruby
# lib/pubid_new/nist/scheme.rb
# frozen_string_literal: true

require_relative "../scheme"
require_relative "identifier"
require_relative "identifiers/base"

module PubidNew
  module Nist
    class Scheme < PubidNew::Scheme
      def initialize
        @identifiers = [
          Identifiers::SpecialPublication,
          Identifiers::FederalInformationProcessingStandards,
          Identifiers::InteragencyReport,
          Identifiers::Handbook,
          Identifiers::TechnicalNote,
          Identifiers::Circular,
          Identifiers::CircularSupplement,
          Identifiers::CrplReport,
          Identifiers::CommercialStandard,
          Identifiers::CommercialStandardEmergency,
          Identifiers::Report,
          Identifiers::Monograph,
          Identifiers::MiscellaneousPublication,
          Identifiers::GrantContractorReport,
          Identifiers::Ncstar,
          Identifiers::Owmwp,
          Identifiers::Nsrds,
          Identifiers::LetterCircular,
        ].freeze
      end

      def locate_identifier_klass_by_type_code(type_code)
        identifiers.find do |klass|
          next unless klass.respond_to?(:typed_stages)
          klass.typed_stages.any? { |ts| ts.type_code == type_code }
        end || Identifiers::SpecialPublication # fallback
      end
    end
  end
end
```

**Step 4: Update NIST Builder to use TYPED_STAGES**

```ruby
# lib/pubid_new/nist/builder.rb
# Remove series_to_class_map method
# Update build method to use Scheme's locate_identifier_klass_by_type_code

def build(parsed)
  parsed_hash = parsed.is_a?(Array) ? merge_parsed_array(parsed) : parsed

  attributes = extract_attributes(parsed_hash)

  # Use Scheme registry to determine class
  identifier_class = scheme.locate_identifier_klass_by_type_code(attributes[:type_code])

  identifier_class.new(**attributes)
end
```

**Step 5: Run tests**

```bash
bundle exec rspec spec/pubid_new/nist/
```

**Step 6: Commit**

```bash
git add lib/pubid_new/nist/ spec/pubid_new/nist/
git commit -m "refactor(nist): migrate from series_to_class_map to TYPED_STAGES pattern"
```

---

## Phase 4: Document All Flavors

**Duration:** ~6 hours

Create comprehensive documentation for all 29 flavors using the template from Phase 1.

### Task 30: Document ISO Flavor

**Files:**
- Create: `docs/iso.md`

**Step 1: Analyze ISO flavor structure**

```bash
# List identifier classes
ls -1 lib/pubid_new/iso/identifiers/

# Check TYPED_STAGES from a few classes
grep -A 10 "TYPED_STAGES" lib/pubid_new/iso/identifiers/amendment.rb
grep -A 10 "TYPED_STAGES" lib/pubid_new/iso/identifiers/international_standard.rb
```

**Step 2: Create ISO documentation**

Following the template from Task 1, populate:
- Overview of ISO (International Organization for Standardization)
- Architecture description
- Components used (Publisher, Code, Date, Type, Language, etc.)
- All 18 identifier classes with:
  - File location
  - Parent class
  - Purpose
  - Components used
  - Patterns supported (e.g., "ISO 9001:2015" → InternationalStandard)
  - TYPED_STAGES definitions
- Scheme registry methods
- Rendering examples table

**Step 3: Add rendering examples**

Test and document 5-10 representative examples per identifier class:

```ruby
# Test script
require "bundler/setup"
require "pubid_new/iso"

examples = [
  "ISO 9001:2015",
  "ISO/IEC 27001:2022",
  "ISO 14001:2015/Amd 1:2017",
  "ISO 9001:2015/Cor 1:2017",
  "EN ISO 9001:2015",
]

examples.each do |id_str|
  id = PubidNew::Iso.parse(id_str)
  puts "#{id_str} → #{id.class} → #{id.to_s}"
end
```

**Step 4: Review and verify documentation**

- Check all identifier classes are listed
- Verify all patterns are accurate
- Ensure TYPED_STAGES are documented

**Step 5: Commit**

```bash
git add docs/iso.md
git commit -m "docs: add comprehensive ISO flavor documentation"
```

### Task 31-58: Document Remaining 28 Flavors

**Pattern:** Repeat Task 30 for each flavor:
- iec, ieee, nist, bsi, cen, astm, api, csa, jis, oiml, etsi, ccsds, itu, jcgm, ashrae, amca, ansi, asme, cie, idf, plateau, sae, idf

**Use @superpowers:dispatching-parallel-agents** to create 4 parallel agents, each documenting 7 flavors.

**Each agent should:**
1. Read the flavor's directory structure
2. Analyze identifier classes
3. Document using template
4. Test rendering examples
5. Verify completeness
6. Commit documentation

---

## Phase 5: Architecture Review and Verification

**Duration:** ~2 hours

Ensure all flavors conform to OOP principles and consistent architecture.

### Task 59: Create Architecture Verification Script

**Files:**
- Create: `scripts/verify-architecture.rb`

**Step 1: Write verification script**

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/pubid_new"

flavors = Dir["lib/pubid_new/*/"].map { |d| File.basename(d) }.sort

def verify_flavor(flavor)
  puts "Verifying #{flavor.upcase}..."
  errors = []

  # Check for scheme.rb
  unless File.exist?("lib/pubid_new/#{flavor}/scheme.rb")
    errors << "  ❌ Missing scheme.rb"
  else
    puts "  ✓ scheme.rb exists"
  end

  # Check for single_identifier.rb
  unless File.exist?("lib/pubid_new/#{flavor}/single_identifier.rb")
    errors << "  ❌ Missing single_identifier.rb"
  else
    puts "  ✓ single_identifier.rb exists"
  end

  # Check for supplement_identifier.rb
  unless File.exist?("lib/pubid_new/#{flavor}/supplement_identifier.rb")
    errors << "  ❌ Missing supplement_identifier.rb"
  else
    puts "  ✓ supplement_identifier.rb exists"
  end

  # Check for identifiers/base.rb
  unless File.exist?("lib/pubid_new/#{flavor}/identifiers/base.rb")
    errors << "  ❌ Missing identifiers/base.rb"
  else
    puts "  ✓ identifiers/base.rb exists"
  end

  # Check for TYPED_STAGES in identifier classes
  identifier_files = Dir["lib/pubid_new/#{flavor}/identifiers/*.rb"]
  identifier_files.each do |file|
    content = File.read(file)
    if content.include?("class ") && !content.include?("TYPED_STAGES")
      # Check if it's not a base class
      unless file.end_with?("base.rb") || file.end_with?("identifier.rb")
        errors << "  ⚠️  #{File.basename(file)} missing TYPED_STAGES"
      end
    end
  end

  errors
end

all_errors = {}
flavors.each do |flavor|
  next if flavor == "components"
  errors = verify_flavor(flavor)
  all_errors[flavor] = errors if errors.any?
end

puts "\n" + "="*60
puts "ARCHITECTURE VERIFICATION SUMMARY"
puts "="*60

if all_errors.empty?
  puts "✅ All flavors verified!"
else
  puts "⚠️  Issues found:\n\n"
  all_errors.each do |flavor, errors|
    puts "#{flavor.upcase}:"
    errors.each { |e| puts e }
    puts
  end
  exit 1
end
```

**Step 2: Run verification**

```bash
ruby scripts/verify-architecture.rb
```

**Step 3: Commit verification script**

```bash
git add scripts/verify-architecture.rb
git commit -m "chore: add architecture verification script"
```

### Task 60: Fix Architecture Issues

**Files:**
- Modify: Various flavor files based on verification output

**Step 1: Run verification and record issues**

```bash
ruby scripts/verify-architecture.rb > architecture-issues.txt
```

**Step 2: Address each issue category**

For flavors missing TYPED_STAGES, add them following the pattern from Phase 3.

**Step 3: Re-run verification until clean**

```bash
ruby scripts/verify-architecture.rb
```

Expected: All flavors verified successfully

**Step 4: Commit fixes**

```bash
git add -A
git commit -m "fix: resolve all architecture verification issues"
```

---

## Phase 6: Testing and Quality Assurance

**Duration:** ~3 hours

Ensure all changes have proper test coverage.

### Task 61: Run Full Test Suite

**Step 1: Run all tests**

```bash
bundle exec rspec
```

**Step 2: Document test failures**

Create `docs/test-failures.md` with:
- Failing spec file and line number
- Error message
- Proposed fix

**Step 3: Fix critical failures**

Prioritize fixes that break core functionality.

**Step 4: Re-run tests**

```bash
bundle exec rspec
```

### Task 62: Run Fixture Classification

**Step 1: Run classification for all flavors**

```bash
cd spec/fixtures
ruby run_classify.rb all
```

**Step 2: Check SUMMARY.txt files**

```bash
find . -name "SUMMARY.txt" -exec grep -l "Fail:" {} \;
```

**Step 3: Document any classification failures**

For flavors with failures, document in flavor docs why certain patterns fail.

---

## Phase 7: Release Preparation

**Duration:** ~1 hour

### Task 63: Update CHANGELOG and Version

**Files:**
- Modify: `CHANGELOG.md` or create `CHANGELOG.md`
- Modify: `lib/pubid_new/version.rb`

**Step 1: Create CHANGELOG entry**

```markdown
# [Unreleased]

## Added

- Comprehensive documentation for all 29 PubID v2 flavors
- Complete TYPED_STAGES registry pattern for all flavors
- Standardized base class hierarchy (SingleIdentifier, SupplementIdentifier)

## Changed

- Migrated NIST from series_to_class_map to TYPED_STAGES
- Standardized architecture across all flavors
- Improved supplement recursion support

## Fixed

- Missing scheme.rb in cie, idf, asme, astm, csa, oiml flavors
- Missing single_identifier.rb in cie, idf flavors
- Missing supplement_identifier.rb in cie, idf flavors
```

**Step 2: Bump version**

```ruby
# lib/pubid_new/version.rb
module PubidNew
  VERSION = "2.0.0"
end
```

**Step 3: Commit**

```bash
git add CHANGELOG.md lib/pubid_new/version.rb
git commit -m "chore: prepare for v2.0.0 release"
```

### Task 64: Create Release Checklist

**Files:**
- Create: `docs/release-checklist.md`

**Step 1: Create checklist**

```markdown
# PubID v2.0.0 Release Checklist

## Architecture
- [x] All flavors have scheme.rb
- [x] All flavors have single_identifier.rb (where applicable)
- [x] All flavors have supplement_identifier.rb (where applicable)
- [x] All flavors use TYPED_STAGES pattern
- [x] All flavors have identifiers/base.rb

## Documentation
- [x] All 29 flavors have comprehensive documentation
- [x] Each flavor documents all identifier classes
- [x] Each flavor documents components used
- [x] Each flavor documents supported patterns
- [x] Rendering examples provided

## Testing
- [x] All tests pass
- [x] Fixture classification ≥ 99% for each flavor
- [x] No critical failures

## Code Quality
- [x] RuboCop passes
- [x] Architecture verification passes
- [x] No deprecation warnings

## Migration
- [x] V1 code marked as deprecated
- [x] Migration guide from V1 to V2
```

---

## Phase 8: Final Review and Commit

**Duration:** ~30 minutes

### Task 65: Final Architecture Review

**Step 1: Run verification script**

```bash
ruby scripts/verify-architecture.rb
```

**Step 2: Run full test suite**

```bash
bundle exec rspec
```

**Step 3: Run fixture classification**

```bash
cd spec/fixtures && ruby run_classify.rb all
```

**Step 4: Verify documentation completeness**

```bash
ls -la docs/*.md | wc -l
```

Expected: At least 30 documentation files (template + 29 flavors)

### Task 66: Create Summary Documentation

**Files:**
- Create: `docs/v2-release-summary.md`

**Step 1: Create release summary**

```markdown
# PubID v2.0.0 Release Summary

## Statistics

- **Total Flavors:** 29
- **Identifier Classes:** 200+
- **Shared Components:** 9
- **Test Coverage:** ≥ 95%
- **Fixture Pass Rate:** ≥ 99% average

## Standardization Achievements

1. **Unified Architecture:** All flavors use three-layer pattern (Parser → Builder → Identifier)
2. **Registry Pattern:** All flavors use TYPED_STAGES for stage/type management
3. **Base Class Hierarchy:** Complete SingleIdentifier/SupplementIdentifier for supplement recursion
4. **Documentation:** Comprehensive docs for all flavors

## Migration Path

V1 users should migrate to V2 using:
1. Update import statements from `PubId::Iso::IsoIdentifier` to `PubidNew::Iso.parse`
2. Refer to flavor documentation for new patterns
3. See migration guide at docs/migration-guide.md

## Known Limitations

- Some edge case patterns may not parse (documented in fail fixtures)
- Optional suffix rendering varies by flavor design

## Future Enhancements

- Additional parser rules for edge cases
- Enhanced validation support
- Performance optimizations
```

**Step 2: Commit**

```bash
git add docs/v2-release-summary.md
git commit -m "docs: add v2.0.0 release summary"
```

---

## Success Criteria

This plan is complete when:

1. ✅ All 29 flavors have scheme.rb with proper identifiers registry
2. ✅ All flavors with single document types have single_identifier.rb
3. ✅ All flavors with supplements have supplement_identifier.rb
4. ✅ All flavors use TYPED_STAGES pattern (no more series_to_class_map)
5. ✅ All 29 flavors have comprehensive documentation in docs/
6. ✅ Architecture verification script passes for all flavors
7. ✅ Full test suite passes (≥ 95% coverage)
8. ✅ Fixture classification shows ≥ 99% pass rate per flavor
9. ✅ CHANGELOG.md documents all changes
10. ✅ Release checklist completed

## Estimated Timeline

- Phase 1: 30 minutes
- Phase 2: 2 hours (with parallel agents)
- Phase 3: 1.5 hours
- Phase 4: 6 hours (with parallel agents)
- Phase 5: 2 hours
- Phase 6: 3 hours
- Phase 7: 1 hour
- Phase 8: 30 minutes

**Total: ~16.5 hours** (can be faster with parallel execution)

---

**Plan complete and saved to `docs/plans/YYYY-MM-DD-pubid-v2-standardization.md`. Two execution options:**

**1. Subagent-Driven (this session)** - I dispatch fresh subagent per task, review between tasks, fast iteration

**2. Parallel Session (separate)** - Open new session with executing-plans, batch execution with checkpoints

**Which approach?**
