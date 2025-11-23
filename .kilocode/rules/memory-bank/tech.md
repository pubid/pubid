## Technologies Used

### Primary Language

- **Ruby 3.1+** - Modern Ruby with frozen string literals
- **Target compatibility**: Ruby 3.1, 3.2, 3.3

### Core Dependencies

- **Parslet** (~2.0) - PEG parser library for grammar-based parsing
- **Lutaml::Model** (~0.7) - Model serialization framework (Lutaml::Model::Serializable)

### Development Dependencies

- **RSpec** - Testing framework
- **RuboCop** - Ruby linter and style enforcer
  - rubocop-performance
  - rubocop-rake
  - rubocop-rspec
- **Rake** - Task automation
- **Bundler** - Dependency management

### Project Structure

**Monorepo Organization**:
- `gems/` - V1 legacy implementations (10 gems, deprecated)
- `lib/pubid_new/` - V2 active implementations (eventual rename to `lib/pubid/`)
- `spec/` - Centralized integration tests
- `docs/` - Architecture documentation

**Individual Gems** (in gems/ folder):
- pubid-core - Foundation (deprecated)
- pubid-iso - ISO identifiers (deprecated)
- pubid-iec - IEC identifiers (deprecated)
- pubid-{flavor} - Other flavors (deprecated)

### Development Setup

#### Initial Setup

```bash
# Clone repository
git clone <repository-url>
cd pubid

# Install dependencies
bundle install

# Run all tests
bundle exec rake test:all

# Run specific flavor tests (V2)
bundle exec rspec spec/pubid_new/iso/
bundle exec rspec spec/pubid_new/nist/
```

#### Common Tasks

```bash
# Run linter
bundle exec rubocop -A --auto-gen-config

# Run specific integration tests
bundle exec rspec spec/pubid_new/iso/identifier_spec.rb

# Run parser tests
bundle exec rspec spec/pubid_new/iso/parser_spec.rb

# Run builder tests
bundle exec rspec spec/pubid_new/iso/builder_spec.rb
```

### Technical Constraints

#### Architecture Constraints

1. **MODEL-DRIVEN**: Identifiers contain object instances, NOT strings
2. **Three-layer separation**: Parser, Builder, Identifier must be independent
3. **No parent modification**: All extensions through inheritance
4. **MECE organization**: Each class handles mutually exclusive patterns
5. **TYPED_STAGES**: Array-based, not hash-based

#### Ruby Constraints

1. **Frozen string literals**: All files use `# frozen_string_literal: true`
2. **RuboCop compliance**: Code must pass linter
3. **Double-quoted strings**: Prefer `"string"` over `'string'`
4. **No Hash anti-patterns**: No TYPE_MAP, STAGE_MAP, etc.

#### Testing Constraints

1. **No mocking/stubbing**: Test real behavior
2. **Fixture-based**: Use actual identifier strings from V1 fixtures
3. **Round-trip testing**: Parse → Object → String must match original
4. **Performance targets**: <1ms per parse operation

### Design Patterns in Use

1. **Parser pattern**: Parslet PEG grammars
2. **Builder pattern**: Transform tree to objects
3. **Component pattern**: Reusable attribute objects
4. **Template method**: Base classes with override points
5. **Wrapper pattern**: Identifiers wrap identifiers
6. **Registry pattern**: Scheme registers identifier types

### Tool Usage Patterns

#### Parslet Grammar Writing

```ruby
# Basic building blocks
rule(:space) { str(" ") }
rule(:digit) { match("[0-9]") }
rule(:digits) { digit.repeat(1) }

# Capture with naming
rule(:number) { digits.as(:number) }

# Optional elements
rule(:part) { (dash >> digits.as(:part)).maybe }

# Alternatives (longest first)
rule(:type) do
  str("TR") | str("TS") | str("PAS")
end

# Combinators
rule(:identifier) do
  publisher >> space >> type >> number >> part
end
```

#### Lutaml::Model Usage

```ruby
class Publisher < Lutaml::Model::Serializable
  attribute :publisher, :string
  attribute :copublisher, :string, collection: true

  def to_s
    copublisher&.any? ? "#{publisher}/#{copublisher.join("/")}" : publisher
  end
end
```

#### Testing Pattern

```ruby
RSpec.describe PubidNew::Iso do
  describe ".parse" do
    it "parses simple ISO identifier" do
      result = described_class.parse("ISO 8601:2019")

      expect(result).to be_a(PubidNew::Iso::Identifiers::InternationalStandard)
      expect(result.number.value).to eq("8601")
      expect(result.date.year).to eq(2019)
      expect(result.to_s).to eq("ISO 8601:2019")
    end
  end
end
```

### CI/CD

**GitHub Actions**:
- `.github/workflows/rake.yml` - Run tests for all gems
- Individual gem testing ensures isolation
- RuboCop style checking

**Release Process**:
- Synchronized versioning across all gems
- Dependency-ordered releases
- Rate-limited publishing to RubyGems

### Version Control

**Branching**:
- `main` - Production code
- Feature branches for new work
- No direct commits to main

**Commit Standards**:
- Semantic commit messages: `type(scope): description`
- Types: feat, fix, docs, style, refactor, test, chore
- Link issues: `fixes #123` or reference `#123`

### Documentation Standards

**Code Documentation**:
- YARD-style comments for public APIs
- Inline comments for complex logic
- README.adoc for user-facing docs

**Architecture Documentation**:
- docs/ folder for design decisions
- Keep continuation plans for session resumption
- Update README.adoc with usage examples

### Performance Optimization

**Parser Optimization**:
- Memoize parser instances (5-6x speedup)
- Put longest patterns first
- Use specific patterns before general

**Memory Management**:
- Frozen string literals reduce allocations
- Component reuse reduces object count
- Minimal parse tree depth

### Development Workflow

1. **Read V1 implementation** to understand patterns
2. **Design V2 architecture** - classes and hierarchy
3. **Implement parser** - Parslet grammar
4. **Implement builder** - Object construction
5. **Implement identifiers** - Business logic + rendering
6. **Test with fixtures** - Use V1 test data
7. **Iterate until 100%** - Fix failures systematically
8. **Document patterns** - Update README

This workflow has proven effective for 6/10 completed flavors.