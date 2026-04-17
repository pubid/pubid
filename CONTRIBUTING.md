# Contributing to PubID

Thank you for your interest in contributing to PubID! This guide covers setting up your development environment, project structure, and common development tasks.

## Development Setup

```bash
git clone https://github.com/metanorma/pubid.git
cd pubid
bundle install
bundle exec rake          # run all tests + lint
bundle exec rspec         # run tests only
bundle exec rubocop       # lint only
```

## Project Structure

```
lib/pubid/
├── core/               # Shared base classes
│   ├── identifier.rb   # Base Identifier (Lutaml::Model)
│   ├── parser.rb       # Base parser (Parslet)
│   ├── update_codes.rb # Pre-parse normalization engine
│   └── scheme.rb       # Type registry
├── components/         # Shared value objects
│   ├── typed_stage.rb  # TypedStage (stage + type)
│   ├── publisher.rb    # Publisher
│   └── ...             # Code, Date, Edition, Language, Stage, Type
├── rendering/          # Shared rendering helpers
├── iso/                # ISO flavor
│   ├── parser.rb       # Parslet PEG grammar
│   ├── builder.rb      # Parse tree → attributes
│   ├── scheme.rb       # Type registry
│   ├── identifiers/    # Type-specific classes (IS, TR, TS, etc.)
│   ├── urn_generator.rb
│   └── urn_parser.rb
├── iec/                # IEC flavor
├── nist/               # NIST flavor
├── ieee/               # IEEE flavor
└── ...                 # 22+ flavors total

data/                   # Pre-parse normalization data
├── iso/update_codes.yaml
├── iec/update_codes.yaml
└── ...

spec/
├── pubid/              # Per-flavor tests
│   ├── iso/
│   │   ├── identifiers/    # Type-specific specs
│   │   ├── parser_spec.rb  # Grammar tests
│   │   └── urn_spec.rb     # URN round-trip tests
│   ├── iec/
│   └── ...
├── fixtures/           # Bulk test fixtures (one ID per line)
│   ├── iso/pass/       # Valid identifiers
│   └── iso/fail/       # Invalid identifiers
└── integration/        # Cross-gem compatibility tests
```

## Adding a New Flavor

### Step 1: Create the flavor module

Create `lib/pubid/{flavor}.rb`:

```ruby
# frozen_string_literal: true

require "pubid"

module Pubid
  module Myflavor
    class Error < StandardError; end
  end
end

require_relative "myflavor/parser"
require_relative "myflavor/identifier"
```

### Step 2: Create the directory structure

```
lib/pubid/myflavor/
├── parser.rb           # Parslet PEG grammar (required)
├── identifier.rb       # Parse entry point (required)
├── identifiers/        # Type-specific classes
│   └── base.rb         # Base identifier type
└── urn_generator.rb    # URN output (optional)
```

### Step 3: Define the parser

Create `lib/pubid/myflavor/parser.rb`:

```ruby
# frozen_string_literal: true

require "pubid/core/parser"

module Pubid
  module Myflavor
    class Parser < Pubid::Core::Parser
      # Define grammar rules using Parslet
      rule(:myflavor_identifier) do
        str("MYFLAVOR") >> space >> number_part
      end

      root(:myflavor_identifier)
    end
  end
end
```

### Step 4: Define identifier classes

Create `lib/pubid/myflavor/identifier.rb`:

```ruby
# frozen_string_literal: true

module Pubid
  module Myflavor
    module Identifiers
      class Base < Pubid::Identifier
        # Define typed stages if applicable
        TYPED_STAGES = [].freeze
      end
    end
  end
end
```

### Step 5: Add normalization data

Create `data/myflavor/update_codes.yaml`:

```yaml
# Maps malformed/legacy identifiers to canonical form
# Exact match
"MYFLAVOR OLD 123": "MYFLAVOR 123"
# Regex match
!ruby/regexp '/MYFLAVOR\s+NO\.\s+(\d+)/': "MYFLAVOR \\1"
```

### Step 6: Write tests

Create `spec/pubid/myflavor/identifier_spec.rb`:

```ruby
require "spec_helper"

RSpec.describe Pubid::Myflavor do
  describe "parsing" do
    it "parses basic identifier" do
      id = described_class.parse("MYFLAVOR 123")
      expect(id.number.number).to eq("123")
    end

    it "round-trips" do
      original = "MYFLAVOR 123"
      expect(described_class.parse(original).to_s).to eq(original)
    end
  end
end
```

### Step 7: Register the flavor

Add autoload to `lib/pubid.rb`:

```ruby
autoload :Myflavor, "pubid/myflavor"
```

## Adding a New Identifier Type

Within an existing flavor:

1. Create `lib/pubid/{flavor}/identifiers/{type}.rb`
2. Define `TYPED_STAGES` if the type has lifecycle stages
3. Update `parser.rb` grammar to recognize the new type abbreviation
4. Update `builder.rb` or `transformer.rb` to map parsed output to new class
5. Update `scheme.rb` (if the flavor uses one) to register the type
6. Add tests in `spec/pubid/{flavor}/identifiers/{type}_spec.rb`

## Adding a New Typed Stage

1. Add a `TypedStage` entry to the appropriate identifier class's `TYPED_STAGES` array:

```ruby
Pubid::Components::TypedStage.new(
  name: "Working Draft",
  stage_code: :wd,
  type_code: "is",
  abbr: ["WD"],
  harmonized_stages: ["20.00"]
)
```

2. The parser automatically picks up new abbreviations from `TYPED_STAGES`
3. Add tests for parsing and round-tripping

## Modifying Parser Grammar

- Parser uses Parslet PEG — rules are composable and deterministic
- Keep rules small and composable
- Compound abbreviations with spaces (e.g., "PWI TS") work because Parslet's `str()` matches multi-character strings
- Test grammar changes with `bundle exec rspec spec/pubid/{flavor}/`
- Use `binding.irb` in the builder for debugging

## Pre-parse Normalization

Add entries to `data/{flavor}/update_codes.yaml`:

```yaml
# Exact match - key is the input, value is the replacement
"ISO/R 657/IV": "ISO/R 657-4:1969"

# Regex match - use YAML !ruby/regexp tag
!ruby/regexp '/NBS\s+CIRC\s+sup\b/': "NBS CIRC 24e7sup"
```

Test that normalize-then-parse round-trips correctly.

## Running Tests

```bash
# All tests
bundle exec rake test:all

# Specific flavor
bundle exec rspec spec/pubid/iec/

# Specific test file
bundle exec rspec spec/pubid/iso/identifiers/international_standard_spec.rb

# Integration tests
bundle exec rake test:integration

# Validation (parser accuracy against real-world data)
bundle exec rake validation:report
bundle exec rake validation:classify[iso]
```

## Code Quality

- Rubocop is enforced (inherits from shared Ribose config)
- Target Ruby version: 3.1
- Run `bundle exec rubocop` before submitting PRs
- All tests must pass: `bundle exec rake`

## Pull Request Process

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass (`bundle exec rake`)
5. Submit PR with a clear description of changes
