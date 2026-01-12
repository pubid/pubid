# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

### Testing
```bash
# Run all V2 tests (primary development workflow)
bundle exec rspec spec/pubid_new/

# Run tests for a specific flavor
bundle exec rspec spec/pubid_new/iso/
bundle exec rspec spec/pubid_new/iec/
bundle exec rspec spec/pubid_new/nist/

# Run a single test file
bundle exec rspec spec/pubid_new/iso/identifier_spec.rb

# Run integration tests
bundle exec rspec spec/integration

# Validate fixtures against parsers (generate coverage reports)
cd spec/fixtures && ruby run_classify.rb all
cd spec/fixtures && ruby run_classify.rb bsi
```

### Linting
```bash
# Run RuboCop with auto-correction
bundle exec rubocop -A --auto-gen-config

# Run RuboCop for V2 code only
bundle exec rubocop -A lib/pubid_new/
```

### Version Management
```bash
# Check version synchronization across all gems
rake version:check

# Sync master version to all gems
rake version:sync

# Bump version (major, minor, or patch)
rake version:bump[patch]
```

### Release Tasks
```bash
# Show release readiness status
rake release:status

# Generate gem release order
rake release:generate_order

# Validate release order
rake release:validate_order
```

## Architecture Overview

### V2 Implementation (Active)

The V2 implementation is located in `lib/pubid_new/` and is the active development area. The V1 code in `gems/` is deprecated and will be removed.

### Three-Layer Architecture Pattern

Every V2 flavor follows the same three-layer separation:

1. **Parser Layer** (`parser.rb`) - Parslet PEG grammar, syntax only, returns hash tree
2. **Builder Layer** (`builder.rb`) - Transforms parse tree to domain objects, NO business logic
3. **Identifier Layer** (`identifiers/`) - Lutaml::Model classes with rendering logic

**Critical Rule:** The Builder ONLY casts types. All type/stage decisions come from the Scheme's register lookup methods. Never hardcode type/stage logic in the Builder.

### Registry-Based Architecture (Scheme Pattern)

The `Scheme` class is the central registry for each flavor. Key methods:

```ruby
# lib/pubid_new/{flavor}/scheme.rb
class Scheme
  def locate_typed_stage_by_abbr(abbr)
    # Returns TypedStage from register, never nil
  end

  def locate_identifier_klass_by_type_code(type_code)
    # Returns identifier class from register
  end
end
```

**Architecture Rule:** When adding new identifier types:
1. Define `TYPED_STAGES` constant in the identifier class (array of TypedStage objects)
2. Add the identifier class to the Scheme's `identifiers` array
3. The Builder will automatically find it via `locate_identifier_klass_by_type_code`

### TYPED_STAGES Pattern (ISO, IEC, CEN, BSI only)

These flavors use an array-based TYPED_STAGES pattern, NOT hash-based TYPE_MAP:

```ruby
# CORRECT
class Amendment < SupplementIdentifier
  TYPED_STAGES = [
    TypedStage.new(abbr: ["Amd"], stage_code: "published", type_code: "amd"),
    TypedStage.new(abbr: ["FDAM"], stage_code: "fdamd", type_code: "amd"),
  ].freeze
end

# WRONG - Never use hash-based TYPE_MAP
TYPE_MAP = { "FDAM" => "fdamd" }  # V1 anti-pattern
```

### Component Reuse

Shared components in `lib/pubid_new/components/`:

- `Publisher` - Organization name + copublishers
- `Code` - Generic string values (number, part, iteration)
- `Date` - Year-based dates
- `Type` - Document type
- `Language` - Language codes with original_code preservation
- `Stage` - Development stage
- `TypedStage` - Combined stage+type with rendering format support

### Flavor Structure

Each V2 flavor has:
```
lib/pubid_new/{flavor}/
├── {flavor}.rb              # Entry point (parses to Identifier)
├── scheme.rb                # Registry of identifier types and typed stages
├── parser.rb                # Parslet grammar (syntax rules)
├── builder.rb               # Object construction from parse tree
├── identifier.rb            # Base identifier class
├── single_identifier.rb     # Base for base documents
├── supplement_identifier.rb # Base for amendments/corrigenda
├── components/              # Flavor-specific components
└── identifiers/             # Concrete identifier classes
    ├── base.rb              # Shared base logic
    ├── international_standard.rb
    ├── amendment.rb
    └── ...
```

### Supplement Recursion

Multi-level supplements build recursively:
```ruby
"ISO/IEC 13818-1:2015/Amd 3:2016/Cor 1:2017"

# Builds as:
Corrigendum(
  base: Amendment(
    base: InternationalStandard("ISO/IEC 13818-1:2015"),
    number: "3",
    year: 2016
  ),
  number: "1",
  year: 2017
)
```

Each supplement has a `base_identifier` attribute that references the wrapped identifier.

### MECE Design Principle

Each identifier class handles mutually exclusive patterns:
- No pattern overlap between classes
- Parser rules are collectively exhaustive
- Builder selects exactly one class per pattern

### Identifier Class Structure

All identifiers inherit from `PubidNew::Identifier` (via flavor-specific base classes):

```ruby
class InternationalStandard < SingleIdentifier
  TYPED_STAGES = [...]  # Register of typed stages for this class

  def self.type
    { key: :is, title: "International Standard", short: nil }
  end

  def to_s
    # Rendering logic here
  end
end
```

### Parser Performance Optimization

Parser instances should be memoized in the Scheme for 5-6x speedup:

```ruby
def parser
  @parser ||= Parser.new
end
```

### Testing Patterns

Integration tests use fixtures from `spec/fixtures/{flavor}/`:

```ruby
it "parses ISO identifier with amendment" do
  id = PubidNew::Iso.parse("ISO 19110:2005/Amd 1:2011")
  expect(id.class).to eq(PubidNew::Iso::Identifiers::Amendment)
  expect(id.to_s).to eq("ISO 19110:2005/Amd 1:2011")  # Round-trip check
end
```

### Active V2 Flavors

Production-ready (100% or near-100%):
- ISO, IEC, IEEE, NIST, JIS, ETSI, CCSDS, ITU, PLATEAU, ANSI, CEN, BSI, IDF
- Plus: JCGM, OIML, CIE, SAE (newer additions)

### Memory Bank

The `.kilocode/rules/memory-bank/` directory contains project context that should be read at the start of each task for continuity between sessions.

### Key Files to Read When Adding New Features

1. `lib/pubid_new/scheme.rb` - Base Scheme class with registry methods
2. `lib/pubid_new/iso/scheme.rb` - Example of a complete Scheme implementation
3. `lib/pubid_new/iso/builder.rb` - Example of proper Builder with `cast()` method
4. `lib/pubid_new/components/typed_stage.rb` - TypedStage component
5. `README.adoc` - User-facing documentation with examples

### Critical Implementation Constraints

1. **MODEL-DRIVEN:** Identifiers contain object instances, NOT strings
2. **No TYPE_MAP or STAGE_MAP:** Use TYPED_STAGES array instead
3. **Builder never makes business logic decisions:** Only casts types via register lookup
4. **Single `cast()` method in Builder:** All conversions happen in one place
5. **No parent class modifications:** All extensions through inheritance
