# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PubID is a Ruby gem for creating interoperable identifiers for standards documents (ISO, IEC, NIST, IEEE, etc.). The codebase lives in a single gem with all flavors under `lib/pubid/{flavor}/`. There are 22+ supported flavors.

## Common Commands

```bash
# Install dependencies
bundle install

# Run all tests
bundle exec rake test:all

# Run integration tests (cross-gem)
bundle exec rake test:integration

# Run all quality checks (tests + rubocop)
bundle exec rake

# Lint all code
bundle exec rake rubocop:all

# Build all gems
bundle exec rake build:all

# Version management
bundle exec rake version:show       # Show master version
bundle exec rake version:check      # Verify all gems synchronized
bundle exec rake version:sync       # Sync master version to all gems
bundle exec rake version:bump[patch|minor|major]  # Bump and sync

# Validation (per-flavor parser accuracy)
bundle exec rake validation:report             # Summary for all flavors
bundle exec rake validation:classify[iso]      # Classify one flavor's results
bundle exec rake validation:classify_all       # Classify all flavors
```

For running specific test files during development, use rspec directly:

```bash
bundle exec rspec spec/pubid/iec/identifiers/technical_report_spec.rb
bundle exec rspec spec/pubid/iso/              # all ISO tests
```

## Architecture

### Parse Pipeline

```
Input String
    │
    ▼
Pre-parser Normalization (data/{flavor}/update_codes.yaml)
    │
    ▼
Parser (Parslet PEG grammar → parse tree)
    │
    ▼
Builder (parse tree → attribute hash)
    │
    ▼
Identifier (Lutaml::Model object → to_s / to_urn / to_h)
```

### Flavor Module Structure

Each flavor under `lib/pubid/{flavor}/` follows:

```
lib/pubid/{flavor}/
├── parser.rb          # Parslet PEG grammar
├── transformer.rb     # AST → attribute hash (some flavors)
├── builder.rb         # Parse tree → identifier object
├── scheme.rb          # Identifier type registry (some flavors)
├── identifier.rb      # Top-level entry point (parse method)
├── identifiers/       # Type-specific classes (e.g., international_standard.rb)
├── renderer/          # Output formatting (some flavors)
├── urn_generator.rb   # URN output (most flavors)
└── urn_parser.rb      # URN input (ISO, IEC)
```

### Key Patterns

- **Parslet PEG parsers**: Each flavor defines grammar rules in `parser.rb`
- **TypedStage**: `Pubid::Components::TypedStage` with attributes: name, type_code, stage_code, abbr, harmonized_stages. Defined as `TYPED_STAGES` arrays on identifier classes.
- **Scheme class**: Some flavors (IEC, ISO) use a `Scheme` class as a registry for identifier types and typed stages
- **Lutaml::Model**: Serialization framework for identifier objects (`to_h`, `to_json`, custom mappings)
- **Pre-parse normalization**: `data/{flavor}/update_codes.yaml` maps malformed/legacy identifiers to canonical form before parsing

### Shared Components

`lib/pubid/components/` holds reusable parts: Code, Date, Edition, Language, Locality, Publisher, Stage, Type, TypedStage.

### Rendering

`lib/pubid/rendering/` provides shared rendering helpers (base, common, context, date, format, language, numbering, publisher, stage, supplement).

## Testing Notes

- RSpec with `--format documentation`
- Full test suite: `bundle exec rake test:all`
- Integration tests in `spec/integration/` verify cross-gem compatibility
- Per-flavor tests in `spec/pubid/{flavor}/`
- Fixture files in `spec/fixtures/` — one identifier per line in `pass/` and `fail/` directories
