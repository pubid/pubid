# BSI V2 Complete Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement all missing BSI V2 identifier classes to achieve 100% pattern coverage (1,632/1,632)

**Architecture:** MODEL-DRIVEN three-layer architecture (Parser → Builder → Identifier). Each class inherits from `SingleIdentifier` or `Base`, uses Lutaml::Model::Serializable, implements custom `to_s` rendering.

**Tech Stack:** Ruby 3.1+, Parslet (~2.0), Lutaml::Model (~0.7), RSpec

---

## Pre-Implementation Setup

### Task 0: Verify Current State

**Files:**
- Check: `lib/pubid_new/bsi/identifiers/`
- Check: `spec/pubid_new/bsi/`

**Step 1: List existing identifier classes**

```bash
ls -la lib/pubid_new/bsi/identifiers/*.rb
```

Expected: 22 files including electronic_book.rb (already exists for EP patterns)

**Step 2: Run integration tests baseline**

```bash
bundle exec rspec spec/pubid_new/bsi/ --format progress
```

Expected: 47/47 passing (current baseline)

**Step 3: Run fixture classification**

```bash
cd spec/fixtures && ruby run_classify.rb bsi
```

Expected: SUMMARY.txt shows current coverage ~79%

**Step 4: Commit baseline**

```bash
git add -A && git status
git commit -m "chore: establish baseline before BSI implementation
- 47/47 integration tests passing
- 1,294/1,632 patterns (79.29%)
- Ready to implement missing classes"
```

---

## Wave 1: Index Class (13 patterns)

### Task 1.1: Analyze Index Fixtures

**Files:**
- Read: `spec/fixtures/bsi/identifiers/full/index.txt`

**Step 1: Read fixture file**

```bash
cat spec/fixtures/bsi/identifiers/full/index.txt
```

Document patterns observed:
- `BS 5000:Index:1981` - colon format
- `BS 185 Index:1964` - space format
- `BS 5000 Index Issue 4:1980` - with issue number

**Step 2: Commit analysis**

```bash
echo "Index patterns:
- Base: BS <number>:Index:<year>
- Space variant: BS <number> Index:<year>
- With issue: BS <number> Index Issue <n>:<year>" > docs/index-pattern-analysis.txt
git add docs/index-pattern-analysis.txt
git commit -m "docs: analyze Index fixture patterns"
```

### Task 1.2: Create Index Identifier Class

**Files:**
- Create: `lib/pubid_new/bsi/identifiers/index.rb`

**Step 1: Write the failing test**

Create: `spec/pubid_new/bsi/identifiers/index_spec.rb`

```ruby
# frozen_string_literal: true

require_relative "../../../../lib/pubid_new/bsi"

RSpec.describe PubidNew::Bsi::Identifiers::Index do
  describe "parsing" do
    it "parses BS 5000:Index:1981" do
      id = PubidNew::Bsi.parse("BS 5000:Index:1981")
      expect(id.class).to eq(PubidNew::Bsi::Identifiers::Index)
    end

    it "parses BS 185 Index:1964" do
      id = PubidNew::Bsi.parse("BS 185 Index:1964")
      expect(id.class).to eq(PubidNew::Bsi::Identifiers::Index)
    end

    it "parses BS 5000 Index Issue 4:1980" do
      id = PubidNew::Bsi.parse("BS 5000 Index Issue 4:1980")
      expect(id.class).to eq(PubidNew::Bsi::Identifiers::Index)
    end
  end

  describe "rendering" do
    it "renders BS 5000:Index:1981 correctly" do
      id = PubidNew::Bsi.parse("BS 5000:Index:1981")
      expect(id.to_s).to eq("BS 5000:Index:1981")
    end

    it "maintains round-trip fidelity" do
      original = "BS 5000 Index Issue 4:1980"
      id = PubidNew::Bsi.parse(original)
      expect(id.to_s).to eq(original)
    end
  end
end
```

**Step 2: Run test to verify it fails**

```bash
bundle exec rspec spec/pubid_new/bsi/identifiers/index_spec.rb
```

Expected: FAIL with "uninitialized constant PubidNew::Bsi::Identifiers::Index"

**Step 3: Write minimal implementation**

Create: `lib/pubid_new/bsi/identifiers/index.rb`

```ruby
# frozen_string_literal: true

require_relative "../single_identifier"

module PubidNew
  module Bsi
    module Identifiers
      # Index document identifier
      # Examples: "BS 5000:Index:1981", "BS 185 Index:1964"
      class Index < SingleIdentifier
        attribute :issue_number, Components::Code

        def self.type
          { key: :index, title: "Index", short: "Index" }
        end

        def to_s(lang: :en, lang_single: false)
          parts = []

          # Publisher prefix
          parts << "BS"

          # Number with part
          if number
            number_str = number.respond_to?(:value) ? number.value.to_s : number.to_s
            if part
              part_val = part.respond_to?(:value) ? part.value : part
              number_str += "-#{part_val.to_s.strip}"
            end
            parts << number_str
          end

          # Index suffix (preserves original format from parser)
          # The parser will set :index_format to "colon" or "space"
          base = parts.join(" ")
          if issue_number
            issue_val = issue_number.respond_to?(:value) ? issue_number.value : issue_number
            "#{base} Index Issue #{issue_val}"
          else
            # Format will be determined by parser's captured format
            base
          end
        end
      end
    end
  end
end
```

**Step 4: Run test to verify it passes**

```bash
bundle exec rspec spec/pubid_new/bsi/identifiers/index_spec.rb
```

Expected: FAIL (parser doesn't recognize Index yet)

**Step 5: Update Scheme Registry**

**File:** `lib/pubid_new/bsi/scheme.rb`

Add to IDENTIFIER_CLASS_MAP:

```ruby
IDENTIFIER_CLASS_MAP = {
  # ... existing mappings
  index: "Identifiers::Index",
}.freeze
```

**Step 6: Update Parser**

**File:** `lib/pubid_new/bsi/parser.rb`

Add Index pattern recognition (find the type rule and add):

```ruby
# Add Index suffix pattern
rule(:index_suffix) do
  (str(":") >> str("Index")) |
  (str(" ") >> str("Index") >> (str(" ") >> str("Issue") >> str(" ") >> number).maybe)
end
```

**Step 7: Run tests again**

```bash
bundle exec rspec spec/pubid_new/bsi/identifiers/index_spec.rb
```

Expected: PASS

**Step 8: Run full integration tests**

```bash
bundle exec rspec spec/pubid_new/bsi/
```

Expected: 47/47 + new Index tests passing

**Step 9: Run fixture classification**

```bash
cd spec/fixtures && ruby run_classify.rb bsi
```

Expected: Index coverage 0% → 100%

**Step 10: Commit**

```bash
git add lib/pubid_new/bsi/identifiers/index.rb \
        lib/pubid_new/bsi/scheme.rb \
        lib/pubid_new/bsi/parser.rb \
        spec/pubid_new/bsi/identifiers/index_spec.rb
git commit -m "feat(bsi): add Index identifier class

- Handles BS <number>:Index:<year> and BS <number> Index:<year> formats
- Supports Issue number variant
- 13 patterns now covered
- 100% round-trip fidelity"
```

---

## Wave 2: Method Class (14 patterns)

### Task 2.1: Analyze Method Fixtures

**Files:**
- Read: `spec/fixtures/bsi/identifiers/full/method.txt`

**Step 1: Read fixture file**

```bash
cat spec/fixtures/bsi/identifiers/full/method.txt
```

Document patterns:
- `BS 2782-1:Method 131B:1983` - base format
- `BS 2782-4:Methods 451F to 451J:1978` - range format
- `BS 2782-8:Methods 823A and 823B:1978` - and format

### Task 2.2: Create Method Identifier Class

**Files:**
- Create: `lib/pubid_new/bsi/identifiers/method.rb`
- Create: `spec/pubid_new/bsi/identifiers/method_spec.rb`

**Step 1: Write the failing test**

```ruby
# frozen_string_literal: true

require_relative "../../../../lib/pubid_new/bsi"

RSpec.describe PubidNew::Bsi::Identifiers::Method do
  describe "parsing" do
    it "parses BS 2782-1:Method 131B:1983" do
      id = PubidNew::Bsi.parse("BS 2782-1:Method 131B:1983")
      expect(id.class).to eq(PubidNew::Bsi::Identifiers::Method)
    end

    it "parses BS 2782-4:Methods 451F to 451J:1978" do
      id = PubidNew::Bsi.parse("BS 2782-4:Methods 451F to 451J:1978")
      expect(id.class).to eq(PubidNew::Bsi::Identifiers::Method)
    end
  end

  describe "rendering" do
    it "renders BS 2782-1:Method 131B:1983 correctly" do
      id = PubidNew::Bsi.parse("BS 2782-1:Method 131B:1983")
      expect(id.to_s).to eq("BS 2782-1:Method 131B:1983")
    end

    it "maintains round-trip fidelity" do
      original = "BS 2782-4:Methods 451F to 451J:1978"
      id = PubidNew::Bsi.parse(original)
      expect(id.to_s).to eq(original)
    end
  end
end
```

**Step 2: Run test to verify it fails**

```bash
bundle exec rspec spec/pubid_new/bsi/identifiers/method_spec.rb
```

Expected: FAIL with "uninitialized constant"

**Step 3: Write minimal implementation**

```ruby
# frozen_string_literal: true

require_relative "../single_identifier"

module PubidNew
  module Bsi
    module Identifiers
      # Method test identifier
      # Examples: "BS 2782-1:Method 131B:1983"
      class Method < SingleIdentifier
        attribute :method_code, Components::Code
        attribute :method_to, Components::Code
        attribute :method_and, Components::Code
        attribute :is_plural, :boolean, default: false

        def self.type
          { key: :method, title: "Method", short: "Method" }
        end

        def to_s(lang: :en, lang_single: false)
          parts = []

          # Publisher prefix
          parts << "BS"

          # Number with part
          if number
            number_str = number.respond_to?(:value) ? number.value.to_s : number.to_s
            if part
              part_val = part.respond_to?(:value) ? part.value : part
              number_str += "-#{part_val.to_s.strip}"
            end
            parts << number_str
          end

          # Method suffix
          method_str = is_plural ? "Methods" : "Method"
          if method_code
            code_val = method_code.respond_to?(:value) ? method_code.value : method_code
            if method_to
              to_val = method_to.respond_to?(:value) ? method_to.value : method_to
              "#{parts.join("-")}:#{method_str} #{code_val} to #{to_val}"
            elsif method_and
              and_val = method_and.respond_to?(:value) ? method_and.value : method_and
              "#{parts.join("-")}:#{method_str}s #{code_val} and #{and_val}"
            else
              "#{parts.join("-")}:#{method_str} #{code_val}"
            end
          else
            "#{parts.join("-")}:#{method_str}"
          end
        end
      end
    end
  end
end
```

**Step 4: Update Scheme and Parser, run tests, commit**

(Same pattern as Index - update IDENTIFIER_CLASS_MAP, parser rules, validate, commit)

**Step 5: Commit**

```bash
git add lib/pubid_new/bsi/identifiers/method.rb \
        lib/pubid_new/bsi/scheme.rb \
        lib/pubid_new/bsi/parser.rb \
        spec/pubid_new/bsi/identifiers/method_spec.rb
git commit -m "feat(bsi): add Method identifier class

- Handles BS <part>:Method <code>:<year> format
- Supports range format (Methods X to Y)
- Supports and format (Methods X and Y)
- 14 patterns now covered"
```

---

## Wave 3: Section Class (11 patterns)

### Task 3.1: Analyze Section Fixtures

**Files:**
- Read: `spec/fixtures/bsi/identifiers/full/section.txt`

**Step 1: Read fixture file**

```bash
cat spec/fixtures/bsi/identifiers/full/section.txt
```

Document patterns:
- `DD 51:Section 0:1977` - base format
- `BS 3224 Section B2:1970` - letter section

### Task 3.2: Create Section Identifier Class

**Files:**
- Create: `lib/pubid_new/bsi/identifiers/section.rb`
- Create: `spec/pubid_new/bsi/identifiers/section_spec.rb`

**Step 1: Write test, implementation, update scheme/parser**

(Same TDD pattern as Index and Method)

**Template Implementation:**

```ruby
# frozen_string_literal: true

require_relative "../single_identifier"

module PubidNew
  module Bsi
    module Identifiers
      # Section identifier
      # Examples: "DD 51:Section 0:1977", "BS 3224 Section B2:1970"
      class Section < SingleIdentifier
        attribute :section_id, Components::Code

        def self.type
          { key: :section, title: "Section", short: "Section" }
        end

        def to_s(lang: :en, lang_single: false)
          parts = []

          # Publisher prefix
          parts << "BS"

          # Number with part
          if number
            number_str = number.respond_to?(:value) ? number.value.to_s : number.to_s
            if part
              part_val = part.respond_to?(:value) ? part.value : part
              number_str += "-#{part_val.to_s.strip}"
            end
            parts << number_str
          end

          # Section suffix
          if section_id
            section_val = section_id.respond_to?(:value) ? section_id.value : section_id
            "#{parts.join("-")}:Section #{section_val}"
          else
            parts.join("-")
          end
        end
      end
    end
  end
end
```

**Step 2: Commit**

```bash
git add lib/pubid_new/bsi/identifiers/section.rb \
        lib/pubid_new/bsi/scheme.rb \
        lib/pubid_new/bsi/parser.rb \
        spec/pubid_new/bsi/identifiers/section_spec.rb
git commit -m "feat(bsi): add Section identifier class

- Handles <type> <number>:Section <id>:<year> format
- Supports both numeric and letter section IDs
- 11 patterns now covered"
```

---

## Wave 4: DISC Class (10 patterns)

### Task 4.1: Analyze DISC Fixtures

**Files:**
- Read: `spec/fixtures/bsi/identifiers/full/disc.txt`

**Step 1: Read fixture file**

```bash
cat spec/fixtures/bsi/identifiers/full/disc.txt
```

Document patterns:
- `DISC PD 2000-2:1997` - DISC prefix + PD type
- DISC = "Delivering Information Solutions to Customers"

### Task 4.2: Create DISC Identifier Class

**Files:**
- Create: `lib/pubid_new/bsi/identifiers/disc.rb`
- Create: `spec/pubid_new/bsi/identifiers/disc_spec.rb`

**Template Implementation:**

```ruby
# frozen_string_literal: true

require_relative "../single_identifier"

module PubidNew
  module Bsi
    module Identifiers
      # DISC (Delivering Information Solutions to Customers) identifier
      # Examples: "DISC PD 2000-2:1997"
      class Disc < SingleIdentifier
        def self.type
          { key: :disc, title: "DISC", short: "DISC" }
        end

        def to_s(lang: :en, lang_single: false)
          parts = []

          # DISC prefix
          parts << "DISC"

          # Type (PD) + number
          if number
            number_str = number.respond_to?(:value) ? number.value.to_s : number.to_s
            if part
              part_val = part.respond_to?(:value) ? part.value : part
              number_str += "-#{part_val.to_s.strip}"
            end
            parts << "PD #{number_str}"
          end

          result = parts.join(" ")
          result += ":#{date.year}" if date
          result
        end
      end
    end
  end
end
```

**Step 2: Commit**

```bash
git add lib/pubid_new/bsi/identifiers/disc.rb \
        lib/pubid_new/bsi/scheme.rb \
        lib/pubid_new/bsi/parser.rb \
        spec/pubid_new/bsi/identifiers/disc_spec.rb
git commit -m "feat(bsi): add DISC identifier class

- Handles DISC PD <number>:<year> format
- DISC = Delivering Information Solutions to Customers
- 10 patterns now covered"
```

---

## Wave 5: DetailedSpecification Class (16 patterns)

### Task 5.1: Analyze DetailedSpecification Fixtures

**Files:**
- Read: `spec/fixtures/bsi/identifiers/full/detailed_specification.txt`

**Step 1: Read fixture file**

```bash
cat spec/fixtures/bsi/identifiers/full/detailed_specification.txt
```

Document patterns:
- `BS 9074 N002:1974` - N prefix notation
- `BS 9210 N0009-1:1978` - with part
- `BS 9300 C155-168:1971` - C prefix (range)

### Task 5.2: Create DetailedSpecification Identifier Class

**Files:**
- Create: `lib/pubid_new/bsi/identifiers/detailed_specification.rb`
- Create: `spec/pubid_new/bsi/identifiers/detailed_specification_spec.rb`

**Template Implementation:**

```ruby
# frozen_string_literal: true

require_relative "../single_identifier"

module PubidNew
  module Bsi
    module Identifiers
      # Detailed Specification identifier
      # Uses special notation: N<number> or C<range>
      # Examples: "BS 9074 N002:1974", "BS 9300 C155-168:1971"
      class DetailedSpecification < SingleIdentifier
        attribute :spec_code, Components::Code  # N002 or C155-168
        attribute :spec_type, :string  # "N" or "C"

        def self.type
          { key: :detailed_specification, title: "Detailed Specification", short: "N" }
        end

        def to_s(lang: :en, lang_single: false)
          parts = []

          # Publisher prefix
          parts << "BS"

          # Base number
          if number
            number_str = number.respond_to?(:value) ? number.value.to_s : number.to_s
            parts << number_str
          end

          # Spec notation (N002 or C155-168)
          if spec_code
            code_val = spec_code.respond_to?(:value) ? spec_code.value : spec_code
            "#{parts.join(" ")} #{code_val}"
          else
            parts.join(" ")
          end
        end
      end
    end
  end
end
```

**Step 2: Commit**

```bash
git add lib/pubid_new/bsi/identifiers/detailed_specification.rb \
        lib/pubid_new/bsi/scheme.rb \
        lib/pubid_new/bsi/parser.rb \
        spec/pubid_new/bsi/identifiers/detailed_specification_spec.rb
git commit -m "feat(bsi): add DetailedSpecification identifier class

- Handles BS <number> N<code>:<year> format
- Supports C prefix for range notation
- 16 patterns now covered"
```

---

## Wave 6: Amendment Verification and StandaloneAmendment

### Task 6.1: Verify Existing Amendment Class

**Files:**
- Read: `lib/pubid_new/bsi/identifiers/amendment.rb`
- Read: `spec/fixtures/bsi/identifiers/full/amendment.txt`

**Step 1: Read existing Amendment implementation**

```bash
cat lib/pubid_new/bsi/identifiers/amendment.rb
```

**Step 2: Read Amendment fixtures**

```bash
cat spec/fixtures/bsi/identifiers/full/amendment.txt
```

**Step 3: Verify Amendment handles correct patterns**

Pattern should handle:
- `BS 5839-6:2019/AMD:2020` - with base identifier
- `BS 1234:2020/A1:2021` - supplement format

Should NOT overlap with ConsolidatedIdentifier (`+` syntax).

**Step 4: Write verification test**

```ruby
# Add to existing spec or create amendment_verification_spec.rb

RSpec.describe "Amendment vs ConsolidatedIdentifier separation" do
  it "parses BS 1234:2020+A1:2021 as ConsolidatedIdentifier" do
    id = PubidNew::Bsi.parse("BS 1234:2020+A1:2021")
    expect(id.class).to eq(PubidNew::Bsi::Identifiers::ConsolidatedIdentifier)
  end

  it "parses BS 5839-6:2019/AMD:2020 as Amendment" do
    id = PubidNew::Bsi.parse("BS 5839-6:2019/AMD:2020")
    expect(id.class).to eq(PubidNew::Bsi::Identifiers::Amendment)
  end
end
```

**Step 5: Run verification**

```bash
bundle exec rspec spec/pubid_new/bsi/identifiers/amendment_verification_spec.rb
```

If tests pass → Amendment is correct, commit verification.

If tests fail → Fix Amendment or parser to correctly separate patterns.

### Task 6.2: Create StandaloneAmendment Class

**Patterns:** `AMD 11015`, `(AMD 10971)`, `(AMD Corrigendum 14716)`

**Files:**
- Create: `lib/pubid_new/bsi/identifiers/standalone_amendment.rb`
- Create: `spec/pubid_new/bsi/identifiers/standalone_amendment_spec.rb`

**Implementation:**

```ruby
# frozen_string_literal: true

require_relative "../single_identifier"

module PubidNew
  module Bsi
    module Identifiers
      # Standalone Amendment (no base identifier reference)
      # Examples: "AMD 11015", "(AMD 10971)", "(AMD Corrigendum 14716)"
      class StandaloneAmendment < SingleIdentifier
        attribute :amendment_number, Components::Code
        attribute :corrigendum, :boolean, default: false
        attribute :has_parens, :boolean, default: false

        def self.type
          { key: :standalone_amendment, title: "Amendment", short: "AMD" }
        end

        def to_s(lang: :en, lang_single: false)
          base = "AMD #{amendment_number}"
          if corrigendum
            base = "AMD Corrigendum #{amendment_number}"
          end

          has_parens ? "(#{base})" : base
        end
      end
    end
  end
end
```

**Step 3: Commit**

```bash
git add lib/pubid_new/bsi/identifiers/standalone_amendment.rb \
        lib/pubid_new/bsi/scheme.rb \
        lib/pubid_new/bsi/parser.rb \
        spec/pubid_new/bsi/identifiers/standalone_amendment_spec.rb
git commit -m "feat(bsi): add StandaloneAmendment identifier class

- Handles AMD <number> format without base identifier
- Supports corrigendum variant
- Supports parenthesized format
- Separates from Amendment (with base) and ConsolidatedIdentifier (+ syntax)"
```

---

## Wave 7: Smaller Types (Batch Implementation)

### Task 7.1-7.6: Implement Remaining Types

For each type below, follow the same TDD cycle:

**Types:**
1. CommitteeDocument (6 patterns)
2. TestMethod (6 patterns)
3. ExplanatorySupplement (1 pattern)
4. Set (1 pattern)
5. SupplementaryIndex (1 pattern)
6. Tickit (3 patterns)

**Per-Type Cycle (repeat for each):**

**Step 1: Read fixtures**
```bash
cat spec/fixtures/bsi/identifiers/full/<type>.txt
```

**Step 2: Write test**
```bash
# Create spec/pubid_new/bsi/identifiers/<type>_spec.rb
# Follow template from Index/Method tests
```

**Step 3: Run failing test**
```bash
bundle exec rspec spec/pubid_new/bsi/identifiers/<type>_spec.rb
```

**Step 4: Implement class**
```bash
# Create lib/pubid_new/bsi/identifiers/<type>.rb
# Follow template from Index/Method implementations
```

**Step 5: Update scheme and parser**
```bash
# Add to IDENTIFIER_CLASS_MAP in scheme.rb
# Add parser rules if needed
```

**Step 6: Run tests**
```bash
bundle exec rspec spec/pubid_new/bsi/identifiers/<type>_spec.rb
```

**Step 7: Commit**
```bash
git add lib/pubid_new/bsi/identifiers/<type>.rb \
        lib/pubid_new/bsi/scheme.rb \
        lib/pubid_new/bsi/parser.rb \
        spec/pubid_new/bsi/identifiers/<type>_spec.rb
git commit -m "feat(bsi): add <Type> identifier class

- Handles <pattern description>
- <count> patterns now covered"
```

---

## Final Validation

### Task 8.1: Run Complete Test Suite

**Step 1: Run all BSI tests**

```bash
bundle exec rspec spec/pubid_new/bsi/
```

Expected: All tests passing (47 + new tests)

**Step 2: Run fixture classification**

```bash
cd spec/fixtures && ruby run_classify.rb bsi
```

Expected: 100% coverage for all implemented types

**Step 3: Check SUMMARY.txt**

```bash
cat spec/fixtures/bsi/SUMMARY.txt
```

Expected: Total coverage > 95%

**Step 4: Run RuboCop**

```bash
bundle exec rubocop -A lib/pubid_new/bsi/identifiers/
```

Expected: No offenses

**Step 5: Run coverage script**

```bash
ruby test_bsi_full_coverage.rb
```

Expected: Show improved coverage numbers

### Task 8.2: Update Documentation

**Files:**
- Update: `docs/BSI-IMPLEMENTATION-STATUS.md`
- Update: `.kilocode/rules/memory-bank/context.md`

**Step 1: Update implementation status**

Add coverage numbers, new classes implemented, architectural notes.

**Step 2: Commit documentation**

```bash
git add docs/BSI-IMPLEMENTATION-STATUS.md \
        .kilocode/rules/memory-bank/context.md
git commit -m "docs(bsi): update implementation status

- Coverage: X/Y (Z%)
- New classes: Index, Method, Section, DISC, DetailedSpecification, StandaloneAmendment
- Architecture: MODEL-DRIVEN, three-layer maintained"
```

### Task 8.3: Final Commit

```bash
git add -A
git commit -m "chore(bsi): complete BSI V2 implementation

- Implemented X new identifier classes
- Coverage: 1,294 → 1,632/X (Z%)
- All tests passing
- Architecture principles maintained

Remaining tasks:
- Edge case fixes for <types>
- Performance optimization if needed"
```

---

## Progress Tracking

Track after each wave:

| Wave | Class | Patterns | Before | After | Status |
|------|-------|----------|--------|-------|--------|
| 0 | Baseline | - | 1,294/1,632 | - | ✅ |
| 1 | Index | 13 | 1,294 | 1,307 | Pending |
| 2 | Method | 14 | 1,307 | 1,321 | Pending |
| 3 | Section | 11 | 1,321 | 1,332 | Pending |
| 4 | DISC | 10 | 1,332 | 1,342 | Pending |
| 5 | DetailedSpecification | 16 | 1,342 | 1,358 | Pending |
| 6 | StandaloneAmendment | 11 | 1,358 | 1,369 | Pending |
| 7 | Smaller types | ~30 | 1,369 | 1,399+ | Pending |
| 8 | Validation | - | 1,399+ | Target | Pending |

---

## Quality Gates

Before proceeding to next wave, ensure:

- [ ] All tests passing (integration + new class tests)
- [ ] Fixture classification shows 100% for implemented types
- [ ] Round-trip fidelity maintained
- [ ] Zero regressions in baseline tests
- [ ] RuboCop clean
- [ ] Git commit after each class

---

## Troubleshooting

**If fixture classification shows < 100% for a type:**

1. Check parser rules - is the pattern being captured?
2. Check builder - is the correct class being selected?
3. Check to_s - is rendering correct?
4. Add failing pattern to tests for visibility

**If round-trip fails:**

1. Check if parser captures original format
2. Store original format in attribute if needed (e.g., `original_abbr`)
3. Use conditional rendering based on captured data

**If tests regress:**

1. Run `bundle exec rspec spec/pubid_new/bsi/ --format documentation`
2. Identify failing test
3. Check if new code affects existing patterns
4. Fix and re-run all tests

---

**End of Implementation Plan**
