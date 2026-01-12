# BSI V2 Complete Implementation Design

**Date:** 2026-01-12
**Status:** Ready for Implementation
**Approach:** Incremental with Tests (Class by Class)
**Current Coverage:** 1,294/1,632 patterns (79.29%)

## Executive Summary

Complete the BSI V2 implementation by systematically implementing all missing identifier classes one-by-one with full test coverage. Each class is implemented end-to-end (fixtures → class → scheme → parser → tests → validation) before moving to the next.

**Goal:** 1,632/1,632 patterns (100% coverage)
**Approach:** Architectural Completeness - all classes in place before edge cases

## Architecture Overview

### New Identifier Classes

```
lib/pubid_new/bsi/identifiers/
├── electronic_book.rb           # NEW - Wave 1
├── index.rb                     # NEW - Wave 1
├── method.rb                    # NEW - Wave 1
├── detailed_specification.rb    # NEW - Wave 2
├── section.rb                   # NEW - Wave 2
├── disc.rb                      # NEW - Wave 2
├── standalone_amendment.rb      # NEW - Wave 3
├── amendment.rb                 # VERIFY/ENHANCE - Wave 3
├── consolidated_identifier.rb   # EXISTING - no changes
└── ... (smaller types - Wave 4)
```

### Three Distinct Amendment Patterns

1. **Amendment** (verify/enhance)
   - Pattern: `BS 5839-6:2019/AMD:2020` or `BS 1234:2020/A1:2021`
   - Purpose: Supplement identifier wrapping a base
   - Syntax: `/AMD:` or `/A<number>:`
   - Has base_identifier reference

2. **ConsolidatedIdentifier** (existing, no changes)
   - Pattern: `BS 1234:2020+A1:2021`
   - Purpose: Bundle of separate identifiers as one publication
   - Syntax: `+` combines base + amendment(s)
   - Represents: `BS 1234:2020` + `BS 1234:2020/A1:2021` sold together

3. **StandaloneAmendment** (new)
   - Pattern: `AMD 11015` or `(AMD 10971)`
   - Purpose: Amendment without base identifier reference
   - Examples: `(AMD 10971)`, `(AMD Corrigendum 14716)`, `(AMD 15600)`
   - NO base_identifier

## Implementation Waves

### Wave 1: Simple Suffix Types (47 patterns)

Establishes the foundational pattern for all simple suffix types.

| Class | Patterns | Suffix | Purpose |
|-------|----------|--------|---------|
| Electronic Book | 20 | `EBOOK` | Electronic format |
| Method | 14 | `METHOD` | Test method documents |
| Index | 13 | `INDEX` | Index documents |

**Template:**
```ruby
# frozen_string_literal: true

require_relative "../single_identifier"

module PubidNew
  module Bsi
    module Identifiers
      class ElectronicBook < SingleIdentifier
        def self.type
          { key: :electronic_book, title: "Electronic Book", short: "EBOOK" }
        end

        def to_s
          base = super
          "#{base} EBOOK"
        end
      end
    end
  end
end
```

### Wave 2: Suffix with Number (37 patterns)

Suffix types that include additional numbers or parameters.

| Class | Patterns | Pattern | Purpose |
|-------|----------|---------|---------|
| Detailed Specification | 16 | `DETAILED SPEC` | Detailed specs |
| Section | 11 | `SEC <num>` | Section divisions |
| Disc | 10 | `DISC` | Disc format |

**Section Template (with number):**
```ruby
# frozen_string_literal: true

require_relative "../single_identifier"

module PubidNew
  module Bsi
    module Identifiers
      class Section < SingleIdentifier
        attribute :section_number, Components::Code

        def self.type
          { key: :section, title: "Section", short: "SEC" }
        end

        def to_s
          base = super
          section_number ? "#{base} SEC #{section_number}" : base
        end
      end
    end
  end
end
```

### Wave 3: Amendment Verification & Standalone (11+ patterns)

Verify existing Amendment class, create StandaloneAmendment for patterns without base.

**Tasks:**
1. Read `lib/pubid_new/bsi/identifiers/amendment.rb`
2. Verify it handles `BS 5839-6:2019/AMD:2020` correctly
3. Ensure no overlap with ConsolidatedIdentifier
4. Create `standalone_amendment.rb` for `AMD 11015` patterns

**StandaloneAmendment Template:**
```ruby
# frozen_string_literal: true

require_relative "../single_identifier"

module PubidNew
  module Bsi
    module Identifiers
      class StandaloneAmendment < SingleIdentifier
        attribute :amendment_number, Components::Code
        attribute :corrigendum, :boolean, default: false

        def self.type
          { key: :standalone_amendment, title: "Amendment", short: "AMD" }
        end

        def to_s
          base = "AMD #{amendment_number}"
          corrigendum ? "#{base} Corrigendum" : base
        end
      end
    end
  end
end
```

### Wave 4: Remaining Types (~30 patterns)

Smaller types with 1-6 patterns each:
- Committee Document (6)
- Test Method (6)
- Explanatory Supplement (1)
- Set (1)
- Supplementary Index (1)
- And others

## Implementation Cycle Per Class

Each class follows this complete cycle:

### Step 1: Analyze Fixtures (5-10 min)

```bash
# Read fixture file
cat spec/fixtures/bsi/identifiers/full/<type>.txt

# Document all patterns
# - Base format variations
# - With/without dates
# - With/without parts
# - Adoption formats (BS EN ISO...)
# - Amendment combinations
```

### Step 2: Create Identifier Class (15-30 min)

```bash
# Create file
touch lib/pubid_new/bsi/identifiers/<class_name>.rb
```

**Class Requirements:**
- Inherit from `SingleIdentifier` or `Identifiers::Base`
- Use Lutaml::Model::Serializable
- Add `type` class method
- Implement custom `to_s` for rendering
- Add attributes for any special fields

### Step 3: Update Scheme Registry (5 min)

**File:** `lib/pubid_new/bsi/scheme.rb`

```ruby
IDENTIFIER_CLASS_MAP = {
  # ... existing mappings
  "electronic_book" => ElectronicBook,
  "method" => Method,
  "index" => Index,
  # Add new type here
}.freeze
```

### Step 4: Update Parser (if needed) (5-15 min)

**File:** `lib/pubid_new/bsi/parser.rb`

Add type abbreviation recognition:
```ruby
rule(:type) do
  str("EBOOK") | str("METHOD") | str("INDEX") | # ... others
end
```

### Step 5: Write Tests (15-20 min)

```bash
# Create spec file
touch spec/pubid_new/bsi/identifiers/<class_name>_spec.rb
```

**Test Structure:**
```ruby
RSpec.describe PubidNew::Bsi::Identifiers::ClassName do
  describe "parsing" do
    it "parses simple pattern" do
      id = PubidNew::Bsi.parse("BS 1234:2020 TYPE")
      expect(id.class).to eq(described_class)
    end

    it "parses with part" do
      id = PubidNew::Bsi.parse("BS 1234-1:2020 TYPE")
      expect(id.part.value).to eq("1")
    end

    it "parses adoption format" do
      id = PubidNew::Bsi.parse("BS EN ISO 9001:2015 TYPE")
      expect(id.adopted_identifier).to be_a(PubidNew::Iso::Identifier)
    end
  end

  describe "rendering" do
    it "renders correctly" do
      id = PubidNew::Bsi.parse("BS 1234:2020 TYPE")
      expect(id.to_s).to eq("BS 1234:2020 TYPE")
    end

    it "maintains round-trip fidelity" do
      original = "BS 1234-1:2020 TYPE"
      id = PubidNew::Bsi.parse(original)
      expect(id.to_s).to eq(original)
    end
  end
end
```

### Step 6: Validate (5 min)

```bash
# Run integration tests
bundle exec rspec spec/pubid_new/bsi/

# Run fixture classification
cd spec/fixtures && ruby run_classify.rb bsi

# Run coverage test
ruby test_bsi_full_coverage.rb | grep -A 5 "<type>"

# Check for regressions
bundle exec rspec spec/pubid_new/bsi/identifiers/
```

**Expected Results:**
- 100% of patterns for this class passing
- Zero regressions in existing tests
- Round-trip fidelity maintained

## Testing Strategy

### Multi-Level Validation

1. **Unit Tests** - Per-class spec files
2. **Integration Tests** - Full BSI test suite (47/47 passing)
3. **Fixture Classification** - Real-world fixture validation
4. **Coverage Tests** - Pattern-by-pattern validation

### Fixture Classification

```bash
cd spec/fixtures
ruby run_classify.rb bsi
```

This generates:
- Classification of all fixtures by type
- Pass/fail counts per type
- SUMMARY.txt with detailed results

### Progress Tracking

| Class | Patterns | Before | After | Status |
|-------|----------|--------|-------|--------|
| Expert Commentary | 25 | 11/25 | 25/25 | ✅ Session 298 |
| Electronic Book | 20 | 0/20 | ?/20 | Wave 1.1 |
| Method | 14 | 0/14 | ?/14 | Wave 1.2 |
| Index | 13 | 0/13 | ?/13 | Wave 1.3 |
| Detailed Specification | 16 | 0/16 | ?/16 | Wave 2.1 |
| Section | 11 | 0/11 | ?/11 | Wave 2.2 |
| Disc | 10 | 0/10 | ?/10 | Wave 2.3 |
| Amendment | ? | verify | fixed | Wave 3.1 |
| StandaloneAmendment | 11 | 0/11 | ?/11 | Wave 3.2 |
| ... | ... | ... | ... | ... |

## Error Handling

### Parser Errors

- Unknown type abbreviations → clear error message
- Malformed patterns → fail gracefully with explanation
- Missing required fields → validation error

### Builder Errors

- Invalid type code → raise ArgumentError via scheme lookup
- Missing attributes → use sensible defaults
- Type mismatches → clear error

### Rendering Errors

- Missing required attributes → render partial or raise
- Invalid combinations → validation before render

## Quality Gates

Each class must pass these gates before proceeding:

1. ✅ All fixture patterns for this class parse correctly
2. ✅ Round-trip fidelity: `parse(str).to_s == str`
3. ✅ Zero regressions in 47 integration tests
4. ✅ Zero regressions in 174 unit tests
5. ✅ RuboCop clean: `bundle exec rubocop -A`
6. ✅ Architecture principles maintained (MODEL-DRIVEN, MECE, three-layer)

## Success Criteria

### Coverage Targets
- Wave 1: 1,294 → 1,341+ (82.2%+)
- Wave 2: 1,341 → 1,378+ (84.5%+)
- Wave 3: 1,378 → 1,389+ (85.1%+)
- Wave 4: 1,389 → 1,419+ (87.0%+)
- Final: 1,632/1,632 (100%)

### Quality Targets
- Integration Tests: 47/47 passing (maintain)
- Unit Tests: 174/174 passing (maintain)
- Round-trip Fidelity: 100% on all implemented patterns
- Architecture Compliance: 100% MODEL-DRIVEN

## Files Modified/Created

### Created
- `lib/pubid_new/bsi/identifiers/electronic_book.rb`
- `lib/pubid_new/bsi/identifiers/index.rb`
- `lib/pubid_new/bsi/identifiers/method.rb`
- `lib/pubid_new/bsi/identifiers/detailed_specification.rb`
- `lib/pubid_new/bsi/identifiers/section.rb`
- `lib/pubid_new/bsi/identifiers/disc.rb`
- `lib/pubid_new/bsi/identifiers/standalone_amendment.rb`
- `spec/pubid_new/bsi/identifiers/*_spec.rb` (matching spec files)

### Modified
- `lib/pubid_new/bsi/scheme.rb` (IDENTIFIER_CLASS_MAP)
- `lib/pubid_new/bsi/parser.rb` (type rules)
- `lib/pubid_new/bsi/identifiers/amendment.rb` (verification/enhancement)

### Updated
- `docs/BSI-IMPLEMENTATION-STATUS.md`
- `.kilocode/rules/memory-bank/context.md`

## Next Steps

1. **Review this design** - Confirm architectural approach
2. **Start Wave 1.1** - Electronic Book implementation
3. **Continue incrementally** - One class at a time with full validation
4. **Track progress** - Update progress table after each class
5. **Document learnings** - Update design if patterns emerge

---

**Design Status:** Complete and approved
**Ready for Implementation:** Yes
**First Task:** Wave 1.1 - Electronic Book (20 patterns)
