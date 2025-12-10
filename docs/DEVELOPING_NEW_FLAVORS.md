# Developing New Flavors in PubID V2

**Version:** 2.0
**Last Updated:** 2025-12-10
**Architecture:** MODEL-DRIVEN, MECE, Three-layer separation

---

## Overview

This guide walks you through creating a new flavor (standards organization) implementation in PubID V2. We'll use examples from existing implementations to show best practices.

**Key Principle:** Follow the MODEL-DRIVEN architecture - identifiers contain **objects**, not strings.

---

## Prerequisites

Before starting, you should:

1. **Understand the organization's identifier format** - Get official documentation
2. **Collect sample identifiers** - Real examples from the organization
3. **Identify identifier types** - What types of documents do they publish?
4. **Know the architecture** - Read [`V2_ARCHITECTURE.adoc`](V2_ARCHITECTURE.adoc)

---

## Step-by-Step Implementation

### Step 1: Create Directory Structure

Create the flavor directory under `lib/pubid_new/`:

```
lib/pubid_new/{flavor}/
├── {flavor}.rb              # Entry point with parse() method
├── parser.rb                # Parslet grammar
├── builder.rb               # Transform parse tree to objects
├── identifier.rb            # Base identifier class
├── components/              # Reusable components (optional)
│   └── ...
└── identifiers/             # Concrete identifier types
    ├── base.rb              # Shared logic
    └── ...
```

**Example for ACME flavor:**

```bash
mkdir -p lib/pubid_new/acme/{components,identifiers}
touch lib/pubid_new/acme/{acme.rb,parser.rb,builder.rb,identifier.rb}
touch lib/pubid_new/acme/identifiers/base.rb
```

### Step 2: Create Entry Point

**File:** `lib/pubid_new/acme/acme.rb`

```ruby
# frozen_string_literal: true

module PubidNew
  module Acme
    def self.parse(identifier_string)
      parser = Parser.new
      parsed_hash = parser.parse(identifier_string)
      builder = Builder.new
      builder.build(parsed_hash)
    end
  end
end

require_relative "parser"
require_relative "builder"
require_relative "identifier"
```

**Key points:**
- Module name: `PubidNew::Acme`
- Single `parse()` method as entry point
- Delegates to Parser → Builder
- Requires other files at end

### Step 3: Implement Parser (Parslet Grammar)

**File:** `lib/pubid_new/acme/parser.rb`

```ruby
# frozen_string_literal: true

require "parslet"

module PubidNew
  module Acme
    class Parser < Parslet::Parser
      # Basic building blocks
      rule(:space) { str(" ") }
      rule(:dash) { str("-") }
      rule(:digit) { match("[0-9]") }
      rule(:digits) { digit.repeat(1) }

      # Publisher
      rule(:publisher) { str("ACME").as(:publisher) }

      # Document type
      rule(:type) do
        str("Standard") | str("Guide") | str("Report")
      end

      # Number
      rule(:number) { digits.as(:number) }

      # Optional part
      rule(:part) { (dash >> digits.as(:part)).maybe }

      # Optional year
      rule(:year) { (str(":") >> digits.as(:year)).maybe }

      # Main rule - ORDER MATTERS (longest first)
      rule(:identifier) do
        publisher >> space >>
        type.as(:type).maybe >> space.maybe >>
        number >> part >> year
      end

      root(:identifier)
    end
  end
end
```

**Parslet Best Practices:**

1. **Longest patterns first** - Put specific before general
2. **Use `.as(:name)`** - Name captured data
3. **Use `.maybe`** - For optional parts
4. **Use `.repeat(min, max)`** - For repeated elements
5. **Break into sub-rules** - Keep rules readable
6. **Test incrementally** - Start simple, add complexity

**Example patterns:**

```ruby
# Alternatives
rule(:type) { str("TR") | str("TS") }

# Optional with default
rule(:edition) { (str("Ed. ") >> digits.as(:edition)).maybe }

# Repeated elements
rule(:publishers) do
  publisher >> (str("/") >> publisher).repeat(0)
end

# Capture groups
rule(:dated) do
  (str(":") >> digits.as(:year))
end
```

### Step 4: Implement Builder

**File:** `lib/pubid_new/acme/builder.rb`

```ruby
# frozen_string_literal: true

module PubidNew
  module Acme
    class Builder
      def build(parsed_hash)
        # Determine identifier type
        identifier_class = detect_identifier_class(parsed_hash)

        # Create instance
        identifier = identifier_class.new

        # Populate attributes
        parsed_hash.each do |key, value|
          next if key == :type # Handled by class selection

          # Convert value to appropriate type
          converted_value = cast(key, value)
          identifier.send("#{key}=", converted_value) if converted_value
        end

        identifier
      end

      private

      def detect_identifier_class(parsed_hash)
        type = parsed_hash[:type]&.to_s

        case type
        when "Standard" then Identifiers::Standard
        when "Guide" then Identifiers::Guide
        when "Report" then Identifiers::Report
        else Identifiers::Base
        end
      end

      def cast(type, value)
        case type
        when :publisher
          value.to_s
        when :number
          value.to_s
        when :part
          value.to_s
        when :year
          value.to_s.to_i
        else
          value
        end
      end
    end
  end
end
```

**Builder Principles:**

1. **No business logic** - Only transform data
2. **Type conversion** - Cast strings to proper types
3. **Class selection** - Choose correct identifier class
4. **Simple mapping** - Hash → Object attributes

### Step 5: Create Base Identifier Class

**File:** `lib/pubid_new/acme/identifier.rb`

```ruby
# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Acme
    class Identifier < Lutaml::Model::Serializable
      attribute :publisher, :string
      attribute :number, :string
      attribute :part, :string
      attribute :year, :integer

      def to_s
        parts = [publisher, number]
        parts << "-#{part}" if part
        parts << ":#{year}" if year
        parts.join(" ")
      end
    end
  end
end
```

**For more complex identifiers with type/stage:**

```ruby
class Identifier < Lutaml::Model::Serializable
  attribute :publisher, :string
  attribute :type, :string
  attribute :number, :string
  attribute :year, :integer

  def to_s
    [publisher, type, number, year].compact.join(" ")
  end
end
```

### Step 6: Create Specific Identifier Classes

**File:** `lib/pubid_new/acme/identifiers/standard.rb`

```ruby
# frozen_string_literal: true

require_relative "../identifier"

module PubidNew
  module Acme
    module Identifiers
      class Standard < Identifier
        # Standard-specific logic

        def to_s
          # Custom rendering for standards
          "#{publisher} Standard #{number}:#{year}"
        end
      end
    end
  end
end
```

**Pattern for inheritance:**

```
Identifier (base)
    ├── Standard (type-specific)
    ├── Guide (type-specific)
    └── Report (type-specific)
```

### Step 7: Add Components (If Needed)

For reusable attributes, create components:

**File:** `lib/pubid_new/acme/components/code.rb`

```ruby
# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Acme
    module Components
      class Code < Lutaml::Model::Serializable
        attribute :value, :string

        def to_s
          value
        end
      end
    end
  end
end
```

**Use in identifier:**

```ruby
class Identifier < Lutaml::Model::Serializable
  attribute :number, Code

  def to_s
    number.value  # Or just number.to_s
  end
end
```

### Step 8: Create Test Structure

**Directory:** `spec/pubid_new/acme/`

```
spec/pubid_new/acme/
├── parser_spec.rb           # Parser tests
├── builder_spec.rb          # Builder tests
├── identifier_spec.rb       # Integration tests
└── identifiers/
    ├── standard_spec.rb
    └── ...
```

**Example integration test:**

```ruby
# spec/pubid_new/acme/identifier_spec.rb
require "spec_helper"

RSpec.describe PubidNew::Acme do
  describe ".parse" do
    context "simple standard" do
      subject { "ACME Standard 100:2020" }
      let(:parsed) { described_class.parse(subject) }

      it "parses correctly" do
        expect(parsed).to be_a(PubidNew::Acme::Identifiers::Standard)
        expect(parsed.publisher).to eq("ACME")
        expect(parsed.number).to eq("100")
        expect(parsed.year).to eq(2020)
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end
end
```

### Step 9: Add Fixtures (NEW Architecture)

Create fixture structure:

```
spec/fixtures/acme/
├── identifiers/
│   └── full/
│       ├── standard.txt
│       ├── guide.txt
│       └── report.txt
└── SUMMARY.txt (generated)
```

**Add real identifiers to full/ files:**

```bash
# spec/fixtures/acme/identifiers/full/standard.txt
# ACME Standard - Full
# Source of truth for all standard identifiers

ACME Standard 100:2020
ACME Standard 200-1:2021
ACME Standard 300:2019
```

**Run classification:**

```bash
cd spec/fixtures
ruby run_classify.rb acme
```

**Results go to:**
- `identifiers/pass/{class}.txt` - Successful parses
- `identifiers/fail/{class}.txt` - Parse failures with errors
- `SUMMARY.txt` - Statistics

---

## Advanced Patterns

### Pattern 1: TYPED_STAGES (ISO, IEC, CEN, BSI)

For flavors with complex type/stage combinations:

**Create Scheme:**

```ruby
# lib/pubid_new/acme/scheme.rb
module PubidNew
  module Acme
    class Scheme
      TYPED_STAGES = [
        TypedStage.new(
          abbr: ["DStandard"],
          harmonized_code: "draft",
          stage: "draft",
          type: "standard"
        ),
        TypedStage.new(
          abbr: ["Standard"],
          harmonized_code: "published",
          stage: "published",
          type: "standard"
        ),
      ].freeze

      def locate_typed_stage_by_abbr(abbr)
        TYPED_STAGES.find { |ts| ts.abbr.include?(abbr) }
      end
    end
  end
end
```

**Use in Builder:**

```ruby
class Builder
  def initialize(scheme = Scheme.new)
    @scheme = scheme
  end

  def build(parsed_hash)
    typed_stage = @scheme.locate_typed_stage_by_abbr(
      parsed_hash[:type_with_stage]
    )
    # ... use typed_stage
  end
end
```

### Pattern 2: Supplement Recursion (ISO, IEC)

For amendments/corrigenda:

```ruby
class Amendment < Identifier
  attribute :base_identifier, Identifier
  attribute :amendment_number, :string

  def to_s
    "#{base_identifier}/Amd #{amendment_number}"
  end
end
```

**Parser for supplements:**

```ruby
rule(:amendment) do
  base.as(:base) >> str("/Amd ") >> digits.as(:amendment_number)
end
```

### Pattern 3: Wrapper Identifiers (IEC VAP, ITU Combined)

For identifiers that wrap other identifiers:

```ruby
class VapIdentifier < Identifier
  attribute :base_identifier, Identifier
  attribute :vap_suffix, :string

  def to_s
    "#{base_identifier} VAP #{vap_suffix}"
  end
end
```

### Pattern 4: Multiple Publishers (ISO/IEC)

```ruby
class Identifier < Lutaml::Model::Serializable
  attribute :publisher, :string
  attribute :copublisher, :string, collection: true

  def to_s
    publishers = [publisher, *copublisher].compact.join("/")
    # ...
  end
end
```

---

## Testing Strategy

### 1. Parser Tests

Test each grammar rule:

```ruby
RSpec.describe PubidNew::Acme::Parser do
  let(:parser) { described_class.new }

  describe "publisher rule" do
    it "parses ACME" do
      result = parser.publisher.parse("ACME")
      expect(result).to eq("ACME")
    end
  end
end
```

### 2. Builder Tests

Test object construction:

```ruby
RSpec.describe PubidNew::Acme::Builder do
  let(:builder) { described_class.new }

  it "builds standard identifier" do
    hash = { publisher: "ACME", number: "100", year: 2020 }
    result = builder.build(hash)
    expect(result).to be_a(PubidNew::Acme::Identifiers::Standard)
  end
end
```

### 3. Integration Tests

Test full parse → render cycle:

```ruby
RSpec.describe PubidNew::Acme do
  it "round-trips standard identifier" do
    input = "ACME Standard 100:2020"
    parsed = described_class.parse(input)
    expect(parsed.to_s).to eq(input)
  end
end
```

### 4. Fixtures Tests

Test with real data:

```ruby
RSpec.describe "ACME Fixtures" do
  Dir.glob("spec/fixtures/acme/identifiers/full/*.txt").each do |file|
    context File.basename(file, ".txt") do
      File.readlines(file).each do |line|
        line = line.strip
        next if line.empty? || line.start_with?("#")

        it "parses #{line}" do
          expect { PubidNew::Acme.parse(line) }.not_to raise_error
        end
      end
    end
  end
end
```

---

## Performance Optimization

### 1. Memoize Parser Instance

```ruby
module PubidNew
  module Acme
    @parser = nil

    def self.parse(identifier_string)
      @parser ||= Parser.new
      parsed_hash = @parser.parse(identifier_string)
      # ...
    end
  end
end
```

**Benefit:** 5-6x speedup on repeated parses

### 2. Use Efficient String Operations

```ruby
# ❌ SLOW
parts = []
parts << publisher
parts << number
parts.join(" ")

# ✅ FAST
[publisher, number].compact.join(" ")
```

### 3. Avoid Unnecessary Object Creation

```ruby
# ❌ Creates intermediate arrays
components = []
components << publisher
components << type
result = components.join(" ")

# ✅ Direct string building
"#{publisher} #{type}"
```

---

## Common Pitfalls

### ❌ DON'T: Store Strings in Model

```ruby
# BAD
class Identifier < Lutaml::Model::Serializable
  attribute :publisher, :string
  attribute :number_string, :string  # ❌ Should be object
end
```

### ✅ DO: Use Component Objects

```ruby
# GOOD
class Identifier < Lutaml::Model::Serializable
  attribute :publisher, Publisher     # ✅ Object
  attribute :number, Code             # ✅ Object
end
```

### ❌ DON'T: Put Business Logic in Builder

```ruby
# BAD
class Builder
  def build(hash)
    id = Identifier.new
    # ❌ Business logic - format decision
    id.formatted_number = "#{hash[:prefix]}-#{hash[:number]}"
    id
  end
end
```

### ✅ DO: Let Identifier Handle Logic

```ruby
# GOOD
class Identifier
  attribute :prefix, :string
  attribute :number, :string

  def formatted_number
    "#{prefix}-#{number}"  # ✅ Business logic in model
  end
end
```

### ❌ DON'T: Use Hash for Type Mappings

```ruby
# BAD - V1 anti-pattern
TYPE_MAP = {
  "Standard" => "STD",
  "Guide" => "G"
}
```

### ✅ DO: Use TYPED_STAGES Array

```ruby
# GOOD - V2 pattern
TYPED_STAGES = [
  TypedStage.new(abbr: ["Standard"], type_code: "std"),
  TypedStage.new(abbr: ["Guide"], type_code: "guide")
].freeze
```

---

## Validation Checklist

Before considering your flavor complete:

- [ ] **Parser works** - Handles 80%+ of identifiers
- [ ] **Round-trip works** - `parse(id).to_s == id`
- [ ] **Tests pass** - RSpec green
- [ ] **Fixtures exist** - Real identifiers in `spec/fixtures/{flavor}/identifiers/full/`
- [ ] **Classification works** - `ruby spec/fixtures/run_classify.rb {flavor}`
- [ ] **Documentation exists** - README updated
- [ ] **Architecture clean** - MODEL-DRIVEN, MECE, Three-layer
- [ ] **Components proper** - Objects not strings
- [ ] **No hardcoding** - Use registers/arrays
- [ ] **Pass rate ≥80%** - Production-ready

---

## Example: Complete Minimal Implementation

**See:** Real implementations in:
- **Simple:** [`lib/pubid_new/idf/`](../lib/pubid_new/idf/) - 26 identifiers, perfect
- **Medium:** [`lib/pubid_new/ccsds/`](../lib/pubid_new/ccsds/) - 490 identifiers, perfect
- **Complex:** [`lib/pubid_new/iso/`](../lib/pubid_new/iso/) - 7,515 identifiers, 99.97%

---

## Getting Help

1. **Read existing flavors** - Learn from working code
2. **Check architecture docs** - [`V2_ARCHITECTURE.adoc`](V2_ARCHITECTURE.adoc)
3. **Review memory bank** - [`.kilocode/rules/memory-bank/`](../.kilocode/rules/memory-bank/)
4. **Ask questions** - Clarify requirements before coding

---

## Summary

**Workflow:**
1. Create directory structure
2. Implement Parser (Parslet grammar)
3. Implement Builder (transform to objects)
4. Create Identifier classes (Lutaml::Model)
5. Add fixtures (real identifiers)
6. Test and validate (aim for 80%+)
7. Document and commit

**Key Principles:**
- **MODEL-DRIVEN** - Objects, not strings
- **MECE** - One type per identifier
- **Three layers** - Parser/Builder/Identifier
- **Fixtures-first** - Test with real data
- **80% is production** - Perfect is optional

**Success Metrics:**
- ✅ 80%+ pass rate on fixtures
- ✅ Round-trip works
- ✅ Clean architecture
- ✅ Comprehensive tests
- ✅ Documentation complete

---

**Created:** 2025-12-10
**Architecture Version:** V2
**Status:** Production guide for new flavor development