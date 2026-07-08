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

# Run integration tests (cross-flavor)
bundle exec rake test:integration

# Run the default suite (test:all + test:integration)
bundle exec rake

# Lint all code
bundle exec rake rubocop        # rubocop:all is an alias

# Build the gem (into pkg/)
bundle exec rake build

# Version management (version lives in lib/pubid/version.rb)
bundle exec rake version:show                     # Show gem version
bundle exec rake version:bump[patch|minor|major]  # Bump version

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
- **Canonical `to_hash` (no defaults)**: `Pubid::Identifier#to_hash` drops any attribute whose value is empty or equal to its default, so the serialized hash is a pure function of the identifier's values — `parse(s).to_hash`, `from_hash(h).to_hash`, and a manually-built id all agree, and the round-trip is idempotent (`from_hash(x.to_hash).to_hash == x.to_hash`). relaton-index relies on this exact equality to validate stored rows. The canonicalizer **recurses into nested components/identifiers** (`canonicalize_hash`/`canonicalize_nested`), because lutaml serializes a nested `Components::*` via its own transform — not the component's public `to_hash` — so a nested defaulted attribute (e.g. `Components::Supplement#has_revision`, default `false`) would otherwise leak into the parent hash. This works because pubid never consults lutaml's `using_default?` tracking and defines no `render_default: true` mapping; **do not** add a `render_default: true` mapping (it would need a default-valued attribute serialized, which `to_hash` now strips) without revisiting this invariant.
- **`exclude` recurses into nested identifiers**: `Pubid::Identifier#exclude(*attrs)` (and the `:year`→`:date` alias) nils the named attributes and rebuilds, but any attribute value that *is* (or is a collection of) another `Pubid::Identifier` is passed through `exclude_from_nested`, which re-applies the same exclusion to the inner identifier. This is what makes `exclude(:date)` actually drop the publication date on wrapper types (BSI `AdoptedEuropeanNorm`/`ConsolidatedIdentifier`/`ExpertCommentary`, and any flavor that delegates `date` to an inner id) instead of nilling an unused outer attribute. Components and scalars are copied verbatim — only real `Identifier` instances recurse — so flat identifiers (ISO, IEC …) are unaffected. NIST keeps its own `exclude` override (keyword init); mirror the recursion there if NIST ever gains nested identifiers.
- **Matching primitives (`base_document` / structural `exclude` / `matches?`)**: `Pubid::Identifier` exposes the vocabulary relaton uses to match a reference against catalogue hits without regexes. `#base_document` returns the wrapped standard with amendment / corrigendum / Expert-commentary / Flex-version layers peeled recursively (base case returns `self`; wrappers override it, delegating to `base_identifier`/`identifiers.first`). `#exclude` also accepts the **structural** keys `:amendment`/`:supplement` (reduce one supplement layer via `#drop_supplements`, which `ConsolidatedIdentifier`→`identifiers.first` and `Amendment`/`Corrigendum`→`base_identifier` override) alongside attribute keys like `:date`/`:edition`. `#matches?(other, ignore:)` is just `exclude(*ignore) == other.exclude(*ignore)`. BSI `Amendment` and `Corrigendum` share a class-agnostic supplement interface — `supplement_type`/`supplement_number`/`supplement_year` — so callers never special-case corrigenda.
- **One EC representation**: BSI's Expert-commentary suffix is modelled *only* as an outer `Identifiers::ExpertCommentary` wrapper (never a boolean on the inner adopted norm), so `#base_document`/`#base_identifier` peel cleanly. The builder's adopted path (`build_adopted_identifier`) is the single place that wraps supplements + EC; `Builder#build` must **not** re-wrap the adopted branch (that caused a double-`ExpertCommentary` that broke `base_identifier`).
- **Flavor prefix routing (`Pubid::<Flavor>.prefixes`)**: every registered flavor exposes a uniform, static `prefixes` class method returning `Array<String>` of the **leading identifier prefix tokens** it recognizes (the tokens a printed id can start with), used by relaton to route a reference string to the owning SDO. A flavor gets this by `extend Pubid::PrefixesSupport` (`lib/pubid/prefixes_support.rb`) and defining a frozen `PREFIXES` constant holding **only its own** tokens, sourced from the parser grammar/constants (e.g. IEC derives from `Components::Publisher::PUBLISHERS.keys`). Joint/co-publication tokens (`ISO/IEC`, `ISO/IEC/IEEE`, `ANSI/ASHRAE`…) live **only** in the central `Pubid::JOINT_PREFIXES` map in `lib/pubid.rb` and are merged in by the mixin, so a co-published prefix appears **symmetrically** in every co-publisher's list without hand-duplication. Top-level helpers: `Pubid.prefixes(:iso)` and `Pubid.prefix_flavors` (reverse index `{ "ISO/IEC" => [:iec, :iso], … }`, which de-dups the `:cen`/`:cen_cenelec` alias by module identity). **Inclusion policy** (documented in the mixin's YARD): include publisher prefixes and leading series/type tokens that can *begin* a reference (BSI `DD`/`PD`, NIST `FIPS`); **exclude** pure sub-series that never lead a reference and ambiguous single letters (BSI aerospace `A`/`B`/`C`). When adding a new flavor, `extend Pubid::PrefixesSupport` and define `PREFIXES` (the cross-flavor spec `spec/pubid/prefixes_spec.rb` asserts every registered flavor responds).
- **Pre-parse normalization**: `data/{flavor}/update_codes.yaml` maps malformed/legacy identifiers to canonical form before parsing
- **Input-length guard (ReDoS)**: every public `parse` entry point (`Pubid.parse`, `Pubid::{Flavor}.parse`, and the class-level `{Flavor}::Identifier.parse` / `Parser.parse` funnels) rejects strings longer than `Pubid::MAX_INPUT_LENGTH` (1000) with `ArgumentError` **before** they reach the normalization regexes. This is the CodeQL-recommended mitigation for `rb/polynomial-redos`. **Do not** "fix" flagged normalization regexes with possessive (`++`, `*+`) or atomic (`(?>…)`) quantifiers — on Ruby 3.2+ those *disable* MRI's regex memoization and reintroduce O(n²) blow-up. Keep the plain regexes and, when adding a new flavor, add the same inline length guard to its `parse` entry (inline `.length` comparison, not a helper, so CodeQL recognizes the barrier).

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
