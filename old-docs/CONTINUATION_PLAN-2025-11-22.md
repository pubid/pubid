# PubID V2 Parser - Continuation Plan

## Quick Reference

**Current Status:** Test Infrastructure Complete ✅
**Branch:** rt-new-lutaml-model
**Last Session:** 2025-11-22

---

## Phase 1: Core Parser Quality (HIGH PRIORITY)

### 1.1 IEEE Edge Cases - Dash Preservation

**Issue:** Recursive parsing loses dash separators in adopted standards

**Current Behavior:**
```ruby
input:  "AIEE No 14-1925 (AESC C22-1925)"
output: "AIEE No 14-1925 (AESC C22.1925)"  # C22-1925 → C22.1925
```

**Root Cause:**
[`lib/pubid_new/ieee/components/code.rb`](lib/pubid_new/ieee/components/code.rb) - Smart separator logic doesn't preserve original separator during recursive parsing

**Solution:**
1. Store original separator when parsing code
2. Add `original_separator` attribute to Code component
3. Preserve it during recursive parsing in adopted standards
4. Update rendering to use stored separator

**Files to Modify:**
- `lib/pubid_new/ieee/components/code.rb` - Add separator storage
- `lib/pubid_new/ieee/builder.rb` - Capture original separator
- `lib/pubid_new/ieee/identifiers/adopted_standard.rb` - Preserve separator in recursion

**Tests to Update:**
- `spec/pubid_new/ieee/identifiers/adopted_standard_spec.rb` - Update expected outputs

**Success Criteria:**
- `AIEE No 14-1925 (AESC C22-1925)` round-trips correctly
- All existing tests still pass

### 1.2 IEEE Edge Cases - Dual Identifiers

**Issue:** Space-separated dual identifiers not supported

**Pattern:** `IEC 62014-5 IEEE Std 1734-2011`

**Solution:**
1. Add space-separated dual pattern to parser
2. Create `DualIdentifier` class or extend existing
3. Handle rendering with space separator

**Files to Create/Modify:**
- `lib/pubid_new/ieee/parser.rb` - Add dual pattern
- `lib/pubid_new/ieee/builder.rb` - Handle dual construction
- `lib/pubid_new/ieee/identifiers/dual_identifier.rb` - Check/update class
- `spec/pubid_new/ieee/identifiers/dual_identifier_spec.rb` - Add tests

**Success Criteria:**
- `IEC 62014-5 IEEE Std 1734-2011` parses and renders correctly
- Comprehensive test coverage for dual patterns

### 1.3 IEEE Edge Cases - ISO/IEC/IEEE Multi-Publisher

**Issue:** Three-way published standards rendering

**Pattern:** `ISO/IEC/IEEE P90003, February 2018 (E)`

**Solution:**
1. Improve multi-publisher rendering logic
2. Handle comma and language code placement
3. Ensure correct slash separator count

**Files to Modify:**
- `lib/pubid_new/ieee/identifiers/base.rb` - Publisher rendering
- `lib/pubid_new/ieee/builder.rb` - Multi-publisher parsing

**Tests:**
- Create `spec/pubid_new/ieee/identifiers/multi_publisher_spec.rb`

### 1.4 NIST Edge Cases - Optional Improvements

**Patterns to Consider:**
- CRPL range patterns (`NBS CRPL 1-2_3-1A`)
- FIPS supplement patterns (`NBS FIPS 63-1supp`)
- Additional edge cases from remaining 1.53% failures

**Priority:** Medium (98.47% is already excellent)

---

## Phase 2: Documentation Updates (HIGH PRIORITY)

### 2.1 Update Main README.adoc

**Location:** [`README.adoc`](README.adoc)

**Sections to Add:**

#### Architecture Overview
```adoc
== Architecture

This library implements parsers for publication identifiers using a modern, model-driven architecture.

=== V2 Implementation (lib/pubid_new/)

The V2 parsers use a clean 3-layer architecture:

1. **Parser Layer** (`lib/pubid_new/*/parser.rb`)
   - Parslet-based grammars for identifier syntax
   - Declarative pattern matching
   - Composable rules

2. **Builder Layer** (`lib/pubid_new/*/builder.rb`)
   - Transforms parse trees into objects
   - Handles special cases and transformations
   - Maintains separation from parsing logic

3. **Identifier Layer** (`lib/pubid_new/*/identifiers/`)
   - Lutaml::Model-based classes
   - Serialization support (JSON, YAML, XML)
   - Rendering logic for output format

[source]
----
┌─────────────┐
│   Parser    │  Parslet grammar
│ (Syntax)    │  Pattern matching
└─────┬───────┘
      │
      ▼
┌─────────────┐
│  Builder    │  Parse tree → Objects
│(Transform)  │  Special case handling
└─────┬───────┘
      │
     ▼
┌─────────────┐
│ Identifiers │  Lutaml::Model classes
│  (Objects)  │  Rendering & serialization
└─────────────┘
----
```

#### Performance Metrics
```adoc
=== Parser Performance

[cols="1,1,1,1"]
|===
|Parser |Success Rate |Test Identifiers |Notes

|NIST
|98.47%
|19,488
|Comprehensive NBS historical support

|IEEE
|100% (basic)
|Coverage complete
|IEC copublished, adoptions

|ISO
|[to be measured]
|[fixtures needed]
|

|BSI
|[to be measured]
|[fixtures needed]
|
|===
```

#### Usage Examples
```adoc
=== Usage Examples

==== NIST Identifiers

[source,ruby]
----
require 'pubid_new/nist'

# Modern NIST
id = PubidNew::Nist.parse("NIST SP 800-53r5")
id.to_s  # => "NIST SP 800-53r5"

# Historical NBS
id = PubidNew::Nist.parse("NBS LCIRC 1019r1963")
id.to_s  # => "NBS LCIRC 1019r1963"

# CSM volume-number
id = PubidNew::Nist.parse("NBS CSM v6n1")
id.to_s  # => "NBS CSM v6n1"
----

==== IEEE Identifiers

[source,ruby]
----
require 'pubid_new/ieee'

# IEEE Standard
id = PubidNew::Ieee.parse("IEEE Std C37.111-2013")
id.to_s  # => "IEEE Std C37.111-2013"

# IEC with edition
id = PubidNew::Ieee.parse("IEC 61523-4 Edition 1.0 2015-03")
id.to_s  # => "IEC 61523-4 Edition 1.0 2015-03"

# Adopted standards
id = PubidNew::Ieee.parse("IEEE Std 623-1976 (ANSI Y32.21-1976, NCTA 006-0975)")
id.to_s  # => "IEEE Std 623-1976 (ANSI Y32.21-1976, NCTA 006-0975)"
----
```

### 2.2 Update Individual Parser READMEs

**NIST README:** [`gems/pubid-nist/README.adoc`](gems/pubid-nist/README.adoc)
- Add V2 parser features from [`docs/NIST-V2-PARSER-IMPROVEMENTS.md`](docs/NIST-V2-PARSER-IMPROVEMENTS.md)
- Update usage examples
- Document all identifier classes

**IEEE README:** [`gems/pubid-ieee/README.adoc`](gems/pubid-ieee/README.adoc)
- Add V2 parser features from [`docs/IEEE-V2-PARSER-IMPROVEMENTS.md`](docs/IEEE-V2-PARSER-IMPROVEMENTS.md)
- Update usage examples
- Document identifier class hierarchy

### 2.3 Move Temporary Documentation

**Move to old-docs/:**
- `CONTINUATION-PROMPT.md` → `old-docs/2025-11-22-continuation-prompt.md`
- `SESSION-2025-11-22-SUMMARY.md` → `old-docs/2025-11-22-session-summary.md`
- Any other temporary planning documents

**Keep:**
- `CONTINUATION_PLAN.md` (this file, updated regularly)
- `IMPLEMENTATION_STATUS.md` (tracker)
- `docs/NIST-V2-PARSER-IMPROVEMENTS.md` (reference)
- `docs/IEEE-V2-PARSER-IMPROVEMENTS.md` (reference)

---

## Phase 3: V1 Migration & Removal (MEDIUM PRIORITY)

### 3.1 Create V1 Removal Plan

**Document:** `V1-REMOVAL-PLAN.md`

**Contents:**
1. Inventory of V1 code in `gems/`
2. Mapping of V1 → V2 equivalents
3. Test migration checklist
4. Breaking changes documentation
5. Migration timeline

### 3.2 Test Migration

**Process:**
1. Identify V1 tests worth preserving
2. Convert to V2 test format
3. Ensure no test coverage loss
4. Document any V1-specific features dropped

### 3.3 Import Path Updates

**Find and replace:**
```bash
# Old V1 imports
require 'pubid/nist'
require 'pubid/ieee'

# New V2 imports
require 'pubid_new/nist'
require 'pubid_new/ieee'
```

**Files to check:**
- All spec files
- Integration tests
- Example code
- Documentation

### 3.4 gems/ Directory Removal

**Only after:**
- All tests migrated
- Documentation updated
- No dependencies on V1 code
- User migration guide published

---

## Phase 4: Additional Parser Coverage (MEDIUM PRIORITY)

### 4.1 Complete Missing Identifier Classes

**NIST Missing Classes:**
Check if these need dedicated classes or if Base handles them:
- CRPL Report
- Commercial Standard Emergency
- Circular Supplement

**Create specs for each:**
- `spec/pubid_new/nist/identifiers/crpl_report_spec.rb`
- `spec/pubid_new/nist/identifiers/commercial_standard_emergency_spec.rb`
- `spec/pubid_new/nist/identifiers/circular_supplement_spec.rb`

**IEEE Missing Class Tests:**
- `spec/pubid_new/ieee/identifiers/dual_published_spec.rb`
- `spec/pubid_new/ieee/identifiers/iec_ieee_copublished_spec.rb`
- `spec/pubid_new/ieee/identifiers/parenthetical_identifier_spec.rb`
- `spec/pubid_new/ieee/identifiers/redlined_standard_spec.rb`

### 4.2 Other Parsers

**ISO Parser:**
- Review current V2 implementation
- Create comprehensive test suite
- Measure success rate on fixtures

**BSI Parser:**
- Review current V2 implementation
- Create comprehensive test suite
- Measure success rate

**IEC/ITU/JIS/etc:**
- Assess V2 status
- Create test infrastructure
- Document features

---

## Phase 5: Advanced Features (LOW PRIORITY)

### 5.1 Performance Optimization

**Profiling:**
```bash
bundle exec ruby -r ruby-prof -e "
require_relative 'lib/pubid_new/nist'
RubyProf.start
# Parse 1000 identifiers
result = RubyProf.stop
printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT)
"
```

**Optimization Targets:**
- Parser caching for repeated patterns
- Memoization of common transformations
- Lazy loading of identifier classes

### 5.2 Advanced Caching

**Parse result caching:**
```ruby
module PubidNew
  module Nist
    @cache = {}

    def self.parse(string)
      @cache[string] ||= Parser.new.parse(string)
    end
  end
end
```

### 5.3 Serialization Formats

**Add support for:**
- MessagePack
- CBOR
- Protocol Buffers

**Each identifier should serialize to:**
- JSON (current)
- YAML (current)
- XML (via Lutaml::Model)
- Additional formats

### 5.4 Query API

**Advanced querying:**
```ruby
# Find all NIST SP 800 series
PubidNew::Nist::Collection.where(series: "SP", number: /^800/)

# Find all IEEE standards from 2013
PubidNew::Ieee::Collection.where(year: 2013)
```

---

## Phase 6: Developer Experience (LOW PRIORITY)

### 6.1 CLI Tools

**Command-line interface:**
```bash
pubid parse "NIST SP 800-53r5"
pubid validate fixtures.txt
pubid convert --from nist --to json input.txt
```

### 6.2 Web Service

**REST API:**
```
POST /parse
{
  "identifier": "IEEE Std C37.111-2013",
  "format": "json"
}
```

### 6.3 Documentation Site

**Static site with:**
- Interactive parser playground
- Comprehensive API docs
- Usage examples
- Migration guides

### 6.4 Video Documentation

**Screen recordings:**
- "Getting started with PubID V2"
- "Migrating from V1 to V2"
- "Understanding the architecture"
- "Advanced parsing techniques"

---

## Testing Requirements

### Test Coverage Standards

**Each class MUST have:**
- Dedicated spec file
- Round-trip parsing tests
- Edge case coverage
- Known limitation documentation

**No Exceptions:**
- No lowering pass thresholds
- No cutting corners on correctness
- Tests must verify actual behavior
- Fix code to match specs, not vice versa

### Test Organization

```
spec/pubid_new/
├── <parser>/
│   ├── parser_spec.rb           # Parser interface
│   ├── identifier_spec.rb       # General identifier tests
│   └── identifiers/
│       ├── base_spec.rb         # Base class tests
│       └── <type>_spec.rb       # Each specific class
```

---

## Architecture Principles

### Object-Oriented Design

1. **Single Responsibility:** Each class has one clear purpose
2. **Open/Closed:** Extend via inheritance, not modification
3. **Liskov Substitution:** Subclasses must be substitutable
4. **Interface Segregation:** Small, focused interfaces
5. **Dependency Inversion:** Depend on abstractions

### MECE Organization

**Mutually Exclusive, Collectively Exhaustive:**
- No overlapping responsibilities
- Full coverage of problem space
- Clear boundaries between components

### Separation of Concerns

**3-Layer Architecture:**
1. **Parser:** Syntax only, no business logic
2. **Builder:** Transformation only, no parsing or rendering
3. **Identifier:** Rendering and serialization only

### Extensibility

**Plugin Architecture:**
```ruby
module PubidNew
  class Registry
    def self.register(name, parser_class)
      @parsers ||= {}
      @parsers[name] = parser_class
    end

    def self.get(name)
      @parsers[name]
    end
  end
end

# Register new parser
PubidNew::Registry.register(:custom, CustomParser)
```

---

## Success Criteria

### Must Complete Before V2 Release

- [ ] All edge cases addressed (IEEE dash preservation, dual identifiers)
- [ ] Official documentation updated (README.adoc, parser READMEs)
- [ ] Temporary docs moved to old-docs/
- [ ] V1 removal plan created
- [ ] All identifier classes have test coverage
- [ ] No failing tests
- [ ] Performance acceptable (< 1ms per parse)

### Should Complete Before V2 Release

- [ ] V1 migration guide published
- [ ] ISO/BSI parser test coverage
- [ ] Comprehensive usage examples
- [ ] Architecture documentation complete

### Nice to Have

- [ ] CLI tools
- [ ] Performance optimization
- [ ] Advanced caching
- [ ] Video documentation

---

## File Organization

### Current Structure

```
lib/pubid_new/           # V2 implementation
├── nist/
│   ├── parser.rb
│   ├── builder.rb
│   └── identifiers/
│       ├── base.rb
│       ├── circular.rb
│       └── ...
├── ieee/
│   ├── parser.rb
│   ├── builder.rb
│   ├── components/
│   │   └── code.rb
│   └── identifiers/
│       ├── base.rb
│       ├── adopted_standard.rb
│       └── ...
└── ...

gems/                    # V1 implementation (to be removed)
├── pubid-nist/
├── pubid-ieee/
└── ...

spec/pubid_new/          # V2 tests
├── nist/
│   ├── parser_spec.rb
│   ├── identifier_spec.rb
│   └── identifiers/
│       ├── base_spec.rb
│       └── ...
└── ieee/
    └── ...

docs/                    # Official documentation
├── NIST-V2-PARSER-IMPROVEMENTS.md
├── IEEE-V2-PARSER-IMPROVEMENTS.md
└── ...

old-docs/                # Archived/temporary docs
├── 2025-11-21-*.txt
└── ...
```

---

## Quick Start for Next Session

```bash
# 1. Check test status
bundle exec rspec spec/pubid_new/ --format progress

# 2. Work on next priority (IEEE dash preservation)
# Edit: lib/pubid_new/ieee/components/code.rb

# 3. Run affected tests
bundle exec rspec spec/pubid_new/ieee/identifiers/adopted_standard_spec.rb

# 4. Update documentation
# Edit: README.adoc, gems/pubid-ieee/README.adoc

# 5. Move temporary docs
mv CONTINUATION-PROMPT.md old-docs/2025-11-22-continuation-prompt.md
mv SESSION-2025-11-22-SUMMARY.md old-docs/2025-11-22-session-summary.md
```

---

Last Updated: 2025-11-22
Branch: rt-new-lutaml-model
Status: Test Infrastructure Complete, Ready for Edge Cases
