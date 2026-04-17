# Task 07: Contributing Guide

## Status: DONE

## Goal

Create `CONTRIBUTING.md` with step-by-step instructions for adding a new flavor, modifying existing parsers, and running tests.

## Content Outline

### 1. Development Setup

```bash
git clone https://github.com/metanorma/pubid.git
cd pubid
bundle install
bundle exec rake          # run all tests + lint
bundle exec rspec         # run tests only
bundle exec rubocop       # lint only
```

### 2. Project Structure

```
lib/pubid/
├── core/           # Shared base classes
│   ├── identifier.rb
│   ├── parser.rb
│   ├── renderer/
│   └── update_codes.rb
├── iso/            # Flavor: ISO
│   ├── parser.rb   # Parslet grammar
│   ├── transformer.rb
│   ├── identifier.rb
│   ├── renderer/
│   ├── identifiers/  # Type-specific classes
│   └── urn_generator.rb
├── iec/            # Flavor: IEC
...
data/
├── iso/update_codes.yaml
├── iec/update_codes.yaml
...
spec/
├── pubid/iso/
│   ├── fixtures/
│   │   ├── pass/    # Valid identifiers (one per line)
│   │   └── fail/    # Invalid identifiers
│   └── identifiers/
└── integration/
```

### 3. Adding a New Flavor

Step-by-step checklist:
1. Create `lib/pubid/{flavor}/` directory with: parser.rb, transformer.rb, identifier.rb
2. Add flavor module to `lib/pubid.rb` (autoload)
3. Create `data/{flavor}/update_codes.yaml`
4. Add test fixtures in `spec/fixtures/{flavor}/pass/` and `fail/`
5. Write specs in `spec/pubid/{flavor}/`
6. Add URN generator if applicable
7. Register flavor in `lib/pubid/core/scheme.rb` (if needed)

### 4. Adding a New Identifier Type

Within an existing flavor:
1. Create `lib/pubid/{flavor}/identifiers/{type}.rb`
2. Define `TYPED_STAGES` if the type has stages
3. Update parser grammar to recognize the new type
4. Update transformer to map parsed output to new class
5. Add fixtures and tests

### 5. Modifying Parser Grammar

- Parser uses Parslet PEG
- Test grammar changes with `bundle exec rspec spec/pubid/{flavor}/`
- Use `binding.pry` in transformer for debugging
- Keep parser rules small and composable

### 6. Pre-parse Normalization

- Add entries to `data/{flavor}/update_codes.yaml`
- Supports exact match and regex patterns
- Test that normalize-then-parse round-trips correctly

### 7. Code Quality

- Rubocop enforced, run `bundle exec rubocop`
- Test coverage: aim for >90% on new code
- All tests must pass before PR

## Files to Create

- `CONTRIBUTING.md`

## Acceptance Criteria

- New contributor can add a flavor by following the guide
- All code examples are tested and copy-pasteable
- Links to related docs (architecture, API) are included
