# PubID V2 - Session Continuation Guide

**Session Date:** 2025-01-22 16:04 HKT
**Status:** ISO Loading Issues RESOLVED ✅

## Critical Achievement This Session

### ISO Module Loading - FIXED ✅

Successfully resolved all 16 uninitialized constant errors in ISO specs by:

1. **Fixed Inheritance Chain:**
   - `SingleIdentifier` now correctly inherits from `::PubidNew::Identifier`
   - `SupplementIdentifier` inherits from `SingleIdentifier`
   - `CombinedIdentifier` inherits from `::PubidNew::Identifier`

2. **Fixed Component Namespacing:**
   - All component references now use global namespace: `::PubidNew::Components::`
   - Applied to: `Type`, `TypedStage`, `Code`, `Publisher`
   - Fixed in 18 identifier class files

3. **Added Comprehensive Requires:**
   - `lib/pubid_new/iso.rb` now loads all 18 identifier classes
   - All supporting files (single_identifier, supplement_identifier, combined_identifier)

**Result:** ISO tests now load and execute properly (2726 examples running, 0 loading errors)

## Current Test Status

### ✅ Production Ready (100% Pass Rate)
- **NIST:** 57/57 tests passing
- **IEEE:** 35/35 tests passing

### 🔧 Implementation In Progress
- **ISO:** 2/2726 tests passing (0.07%) - Parser/builder incomplete but loading works
- **CEN:** ~50% passing - Partial implementation
- **IDF:** ~51% passing - Partial implementation
- **IEC:** ~50% passing - Partial implementation
- **JIS:** ~63% passing - Partial implementation

### ❌ No Test Coverage Yet
- **BSI, ITU, ETSI, CCSDS, Plateau** - Implementations exist, need tests

## Quick Start Commands

```bash
# Verify working flavors
bundle exec rspec spec/pubid_new/nist/ spec/pubid_new/ieee/ --format documentation

# Check ISO status (loading now works, parser incomplete)
bundle exec rspec spec/pubid_new/iso/ --format progress | tail -5

# Run all current tests
bundle exec rspec spec/pubid_new/ --format progress
```

## Priority Work Queue

### 🔥 Immediate Next Steps

#### 1. ISO Parser Implementation (HIGH PRIORITY)
**Goal:** Get ISO parser working for common patterns

**Files to work on:**
- `lib/pubid_new/iso/parser.rb` - Grammar needs expansion
- `lib/pubid_new/iso/builder.rb` - Routing to correct identifier classes

**Critical patterns failing:**
```ruby
# These MUST parse:
"ISO/IEC Guide 51:1999(E/F/R)"          # Guide with languages
"ISO 19110:2005/Amd 1:2011"             # Amendment (supplement)
"ISO/IEC/IEEE 8802-3:2021/FDAM 1"       # Staged amendment
"ISO/IEC/IEEE 8802-21:2018/Cor 1:2018"  # Corrigendum
"ISO/IEC 13818-1:2015/Amd 3:2016/Cor 1:2017"  # Multi-level
"ISO/DATA 7:1979"                       # Data identifier
"ISO/IEC TR 29186:2012"                 # Technical Report
"ISO/IEC TS 25011:2017"                 # Technical Specification
"ISO/SAE PAS 22736:2021"                # PAS
"ISO/TTA 5:2007"                        # TTA
"ISO/R 300-3:1968"                      # Recommendation (legacy)
"IWA 14-1:2013"                         # Workshop Agreement
"ISO/IEC ISP 12062-2:2003"              # Standardized Profile
"ISO/IEC DIR 1:2022"                    # Directives
"ISO/IEC DIR 1 ISO SUP:2022"            # Directives Supplement
"ISO/TR 10000:2000/Suppl 1:2005"        # Supplement
"ISO 1101:1983/Ext 1:1983"              # Extract
```

**Approach:**
1. Start with simplest patterns (IS, TR, TS)
2. Add supplement support (/Amd, /Cor, /Suppl, /Ext)
3. Handle multi-level supplements (base/Amd/Cor)
4. Add language codes and other modifiers

**Test to verify:**
```bash
bundle exec rspec spec/pubid_new/iso/identifier_spec.rb --format documentation
```

#### 2. Add BSI Test Coverage (MEDIUM PRIORITY)
**Goal:** Create comprehensive test suite for BSI identifiers

**Reference implementations exist in:**
- `lib/pubid_new/bsi/`
- `gems/pubid-bsi/` (old gem for reference)

**Create tests in:**
- `spec/pubid_new/bsi/identifier_spec.rb`
- `spec/pubid_new/bsi/parser_spec.rb`

**Common BSI patterns to test:**
```ruby
"BS 5950-1:2000"                    # British Standard
"BS EN 1993-1-1:2005"               # Adopted European Norm
"BS EN ISO 9001:2015"               # Double adoption
"PD 6500:2003"                      # Published Document
"PAS 220:2008"                      # Publicly Available Spec
"BS 5950-1:2000+A1:2010"            # With amendment
```

#### 3. Add IEC Test Coverage (MEDIUM PRIORITY)
**Reference:**
- `lib/pubid_new/iec/`
- `gems/pubid-iec/` (old gem for reference)
- `gems/pubid-iec/spec/` (can copy/adapt tests)

**Create tests in:**
- `spec/pubid_new/iec/identifier_spec.rb`
- `spec/pubid_new/iec/parser_spec.rb`

## Implementation Templates

### Adding Test Coverage for a New Flavor

1. **Create spec directory:**
```bash
mkdir -p spec/pubid_new/{flavor}
```

2. **Create identifier_spec.rb:**
```ruby
require "spec_helper"
require_relative "../../../lib/pubid_new"

RSpec.describe PubidNew::{Flavor}::Identifier do
  subject { described_class }

  describe ".parse" do
    context "with valid identifier" do
      let(:id) { described_class.parse(pubid) }

      context "basic pattern" do
        let(:pubid) { "EXAMPLE 123:2020" }

        it "parses correctly" do
          expect(id.to_s).to eq(pubid)
        end

        it "extracts components" do
          expect(id.number).to eq("123")
          expect(id.year).to eq(2020)
        end
      end
    end
  end
end
```

3. **Create parser_spec.rb:**
```ruby
require "spec_helper"
require_relative "../../../lib/pubid_new"

RSpec.describe PubidNew::{Flavor}::Parser do
  describe ".parse" do
    it "parses basic identifier" do
      result = described_class.parse("EXAMPLE 123:2020")
      expect(result[:number]).to eq("123")
      expect(result[:year]).to eq("2020")
    end
  end
end
```

### Fixing Parser Issues

**Common parser problems and solutions:**

1. **Parser fails at specific position:**
```
Failed to match sequence (...) at line 1 char 22
```
→ Add missing grammar rule or make rule optional with `.maybe`

2. **Supplement identifiers not parsing:**
→ Need to add supplement pattern after base identifier:
```ruby
rule(:supplement) do
  str("/") >> (str("Amd") | str("Cor") | str("Suppl") | str("Ext")).as(:supplement_type) >>
  space.maybe >> digits.as(:supplement_number)
end
```

3. **Multi-copublisher not working:**
→ Increase repeat count:
```ruby
rule(:publisher) do
  iso.as(:publisher) >>
  (slash >> copublisher.as(:copublisher)).repeat(0, 3)  # Allow up to 3
end
```

## File Organization Reference

```
lib/pubid_new/
├── {flavor}.rb                    # Main module, loads all subfiles
├── {flavor}/
│   ├── identifier.rb              # Module with .parse() method
│   ├── parser.rb                  # Parslet grammar
│   ├── builder.rb                 # Builds identifier objects from parse tree
│   ├── components/                # Flavor-specific components
│   └── identifiers/               # Specific identifier types
│       ├── base.rb
│       └── *.rb                   # Type-specific identifiers

spec/pubid_new/
├── {flavor}/
│   ├── identifier_spec.rb         # Main integration tests
│   ├── parser_spec.rb             # Parser unit tests
│   └── identifiers/
│       └── *_spec.rb              # Type-specific tests
```

## Common Patterns Across Flavors

### 1. Module Structure (Always)
```ruby
module PubidNew
  module {Flavor}
    def self.parse(identifier)
      Identifier.parse(identifier)
    end
  end
end
```

### 2. Identifier Module (Always)
```ruby
module PubidNew::${Flavor}::Identifier
  def self.parse(input)
    parsed = Parser.parse(input)
    Builder.build(parsed)
  end
end
```

### 3. Inheritance (Follow ISO pattern)
```ruby
class SingleIdentifier < ::PubidNew::Identifier
  # Flavor-specific attributes
end

class SupplementIdentifier < SingleIdentifier
  attribute :base_identifier, ::PubidNew::Identifier, polymorphic: true
end
```

### 4. Component References (Always use global namespace)
```ruby
attribute :type, ::PubidNew::Components::Type
attribute :stage, ::PubidNew::Components::TypedStage
attribute :code, ::PubidNew::Components::Code
```

## Testing Strategy

### Test Coverage Goals
- **Unit tests:** Parser, Builder, Components
- **Integration tests:** Full parse → build → serialize round-trip
- **Edge cases:** Unusual patterns, legacy formats, errors

### Test Pyramid
```
     /\
    /  \    Integration Tests (identifier_spec.rb)
   /____\   5-10 common patterns per identifier type
  /      \
 /        \  Unit Tests (parser_spec.rb, builder_spec.rb)
/__________\ 20-30 specific grammar rules and builder logic
```

### Running Specific Tests
```bash
# Single spec file
bundle exec rspec spec/pubid_new/iso/identifier_spec.rb

# Single example
bundle exec rspec spec/pubid_new/iso/identifier_spec.rb:32

# With documentation
bundle exec rspec spec/pubid_new/iso/ --format documentation

# Fast check
bundle exec rspec spec/pubid_new/iso/ --format progress
```

## Known Good Patterns (Copy from these)

### NIST Parser (Excellent example)
- File: `lib/pubid_new/nist/parser.rb`
- Complex series handling
- Good number pattern matching
- Edition/revision/update handling

### IEEE Parser (Clean example)
- File: `lib/pubid_new/ieee/parser.rb`
- Draft handling
- Adopted standard patterns
- Dual/co-published support

### NIST Builder (Excellent routing)
- File: `lib/pubid_new/nist/builder.rb`
- Clean class determination logic
- Good parameter extraction

## Debugging Tips

### 1. Parser failures
```bash
# Get full error with context
bundle exec rspec spec/pubid_new/iso/identifier_spec.rb:32 --format documentation

# Test parser directly in console
bundle exec irb -r ./lib/pubid_new
PubidNew::Iso::Parser.parse("ISO 19115:2003")
```

### 2. Component errors
```ruby
# Wrong (causes uninitialized constant error)
attribute :type, Components::Type

# Right (uses global namespace)
attribute :type, ::PubidNew::Components::Type
```

### 3. Inheritance errors
```ruby
# Wrong (can't inherit from module)
class SingleIdentifier < Identifier

# Right (inherit from base class)
class SingleIdentifier < ::PubidNew::Identifier
```

## Success Criteria

### ISO Parser Complete ✅
- [ ] All 17 test cases in identifier_spec.rb pass
- [ ] 90%+ of parser_spec.rb examples pass
- [ ] Round-trip works: parse → to_s → parse

### New Flavor Tests Added ✅
- [ ] BSI: 30+ tests covering all identifier types
- [ ] IEC: 50+ tests covering all identifier types
- [ ] ITU: 20+ tests for basic patterns
- [ ] ETSI: 20+ tests for basic patterns
- [ ] JIS: Tests improved from 63% to 90%+

### Overall Metrics ✅
- [ ] Total test count: 3500+
- [ ] Overall pass rate: 90%+
- [ ] Flavors at 100%: 5+ (currently 2)
- [ ] No loading errors (currently achieved for ISO ✅)

## Session Handoff Checklist

After completing work:
1. [ ] Run full test suite: `bundle exec rspec spec/pubid_new/`
2. [ ] Update `IMPLEMENTATION_STATUS.md` with new metrics
3. [ ] Update this file with progress and new learnings
4. [ ] Commit changes with clear messages
5. [ ] Note any blockers or questions for next session

## References

- **Main Status:** `IMPLEMENTATION_STATUS.md`
- **Architecture:** `README.adoc`
- **Old Gems:** `gems/pubid-{flavor}/` for reference implementations
- **Test Fixtures:** `spec/pubid_new/{flavor}/fixtures/` (if present)

---

**Next Session Focus:** Complete ISO parser OR add BSI/IEC test coverage