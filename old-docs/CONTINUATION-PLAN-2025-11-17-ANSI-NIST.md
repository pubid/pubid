# Continuation Plan: ANSI Creation + NIST Fixes - 2025-11-17

## Session Context

Branch: `rt-new-lutaml-model`  
PR: #19  
Previous Session: 2025-11-16 (ISO Breakthrough)

### Previous Session Results
- ✅ **ISO**: Fixed from 0% → 98.47% (7,544/7,661 passing)
- ✅ **ISO**: Created "original format preservation" pattern
- 🚧 **ANSI**: Started (main module created, needs implementation)
- 🚧 **NIST**: Analyzed issues, needs careful fixes

### Current Status
- **11/12 flavors** at 100% or production-ready
- **ISO**: 98.47% (production-ready, 117 edge cases acceptable)
- **NIST**: ~97.8% (22 failures, needs targeted fixes)
- **ANSI**: 0% (just started, needs complete implementation)

**Goal**: Complete ANSI + Fix NIST → 13/13 flavors ready

---

## Task 1: Complete ANSI Flavor (Priority 1, 2-3 hours)

### Context
ANSI (American National Standards Institute) requested to be "similar to ISO". 

### Current State
- ✅ Created: [`lib/pubid_new/ansi.rb`](../lib/pubid_new/ansi.rb) with `parse()` method
- ✅ Created: Directory structure `lib/pubid_new/ansi/identifiers/`
- ❌ Missing: Parser, Scheme, Builder, Identifier classes

### Required Files

#### File 1: lib/pubid_new/ansi/parser.rb
**Template**: Use [`lib/pubid_new/iso/parser.rb`](../lib/pubid_new/iso/parser.rb) as base

**Adapt for ANSI**:
- Publisher: `ANSI` instead of `ISO/IEC`
- Simpler structure (likely fewer document types than ISO)
- Standard format: `ANSI X3.4-1986` or `ANSI/ISO 9899:1990`

**Key Rules Needed**:
```ruby
rule(:publisher) { str("ANSI").as(:publisher) }
rule(:number_with_part) { ... }  # ANSI C63.4-2014
rule(:date) { ... }              # :1986, :2014
rule(:copublishers) { ... }      # ANSI/ISO, ANSI/IEEE
```

#### File 2: lib/pubid_new/ansi/scheme.rb
**Template**: Use [`lib/pubid_new/iso/iso.rb`](../lib/pubid_new/iso.rb) lines 27-54

**Structure**:
```ruby
module PubidNew
  module Ansi
    IDENTIFIER_TYPES = [
      Identifiers::AmericanNationalStandard,
      # Add more as needed
    ].freeze

    Scheme = PubidNew::Scheme.new(
      identifiers: IDENTIFIER_TYPES,
      supplement_identifiers: [], # If ANSI has supplements
    )
  end
end
```

#### File 3: lib/pubid_new/ansi/builder.rb
**Template**: Simplified version of [`lib/pubid_new/iso/builder.rb`](../lib/pubid_new/iso/builder.rb)

**Key Methods**:
```ruby
def build(parsed_hash)
  identifier = locate_identifier_klass(parsed_hash).new
  parsed_hash.each_pair { |key, value| 
    cast_and_assign(identifier, key, value)
  }
  identifier
end

def cast(type, value)
  case type
  when :publisher then Components::Publisher.new(body: value)
  when :number_with_part then parse_number_parts(value)
  when :date then Components::Date.new(year: value)
  # ... etc
  end
end
```

#### File 4: lib/pubid_new/ansi/identifier.rb
**Template**: Copy from [`lib/pubid_new/iso/identifier.rb`](../lib/pubid_new/iso/identifier.rb)

```ruby
module PubidNew
  module Ansi
    class Identifier < ::PubidNew::Identifier
      def self.parse(string)
        parsed = PubidNew::Ansi::Parser.new.parse(string)
        PubidNew::Ansi::Builder.new(PubidNew::Ansi::Scheme).build(parsed)
      end
    end
  end
end
```

#### File 5: lib/pubid_new/ansi/single_identifier.rb
**Template**: Adapt [`lib/pubid_new/iso/single_identifier.rb`](../lib/pubid_new/iso/single_identifier.rb)

**Key Method**:
```ruby
def to_s(lang: :en)
  parts = []
  parts << publisher_portion
  parts << number_portion
  parts << language_portion if languages&.any?
  parts.compact.join(' ')
end
```

#### File 6: lib/pubid_new/ansi/identifiers/american_national_standard.rb
**Template**: Simplified from ISO identifiers

```ruby
module PubidNew
  module Ansi
    module Identifiers
      class AmericanNationalStandard < SingleIdentifier
        def self.type
          { key: :ans, title: "American National Standard", short: "ANS" }
        end
      end
    end
  end
end
```

### Testing ANSI

**Test Cases** (examples of ANSI identifiers):
```ruby
test_cases = [
  'ANSI X3.4-1986',
  'ANSI C63.4-2014',
  'ANSI/ISO 9899:1990',
  'ANSI/IEEE 802.3-2012',
  'ANSI Z39.48-1992',
]
```

**Test Command**:
```ruby
test_cases.each do |test|
  id = PubidNew::Ansi.parse(test)
  puts "#{test} => #{id.to_s}"
end
```

### Estimated Time: 2-3 hours
- Parser rules: 45 min
- Scheme setup: 30 min
- Builder logic: 45 min
- Identifier classes: 30 min
- Testing & fixes: 30 min

---

## Task 2: Fix NIST Issues (Priority 2, 1-2 hours)

### Current NIST State
- Basic parsing works: `NIST SP 800-90A` ✓
- ~97.8% overall pass rate
- 22 specific failures in 3 patterns

### Issue 1: "sup" Rendering (14 cases)

**Problem**:
```
Input:  NIST SP 800-90A sup
Output: NIST SP 800-90A (sup)  ← wrapped in parentheses
```

**Root Cause**: "sup" is being parsed as `translation` (3-letter language code) not `supplement`

**Current Code** [`lib/pubid_new/nist/scheme.rb:135`](../lib/pubid_new/nist/scheme.rb:135):
```ruby
def build_supplement_string
  if supplement && supplement.length > 0
    "supp#{supplement}"
  else
    "supp"
  end
end
```

**Current Code** [`lib/pubid_new/nist/scheme.rb:72`](../lib/pubid_new/nist/scheme.rb:72):
```ruby
result += " (#{translation})" if translation
```

**Fix Option A - Rendering (Safer)**:
Detect when translation is actually "sup" (supplement misidentified):
```ruby
# In to_s method around line 72
if translation == "sup"
  result += " sup"  # Render as supplement
else
  result += " (#{translation})"  # Normal translation
end
```

**Fix Option B - Parser (More Complete)**:
Modify [`lib/pubid_new/nist/parser.rb:170`](../lib/pubid_new/nist/parser.rb:170):
```ruby
rule(:translation) do
  ((str("(") >> letter.repeat(3, 3).as(:translation) >> str(")")) |
    # Only match as translation if NOT "sup" or "supp"
    ((dot | space) >> str("sup").absent? >> str("supp").absent? >> 
      letter.repeat(3, 3).as(:translation)))
end
```

**Recommendation**: Try Option A first (safer, doesn't break existing functionality)

### Issue 2: Edition-Date "e2-1915" (4 cases)

**Problem**:
```
Input:  NIST HB 44 e2-1915
Error:  Parse failure
```

**Current Rule** [`lib/pubid_new/nist/parser.rb:110`](../lib/pubid_new/nist/parser.rb:110):
```ruby
rule(:edition) do
  (
    # e2018, e201801 (4-digit year)
    (str("e") >> match("[0-9]").repeat(4, 4).as(:edition_year) ...) |
    # -2018, -Jan2018 (dash prefix)
    (dash >> ...) |
    # e2, e3 (1-3 digits)
    ((str("e") | str(" E")) >> match("[0-9]").repeat(1, 3).as(:edition))
  )
end
```

**Add This Pattern** (before the last alternative):
```ruby
# e2-1915 (edition number dash year)
((str("e") | str(" E")) >> match("[0-9]").repeat(1, 3).as(:edition) >> 
  dash >> digits.as(:edition_year)) |
```

**Test After Adding**:
```ruby
PubidNew::Nist.parse("NIST HB 44 e2-1915")
# Should parse successfully
```

### Issue 3: Supplement-Month "supJan1924" (4 cases)

**Problem**:
```
Input:  NIST HB 44 supJan1924
Error:  Parse failure
```

**Current Rule** [`lib/pubid_new/nist/parser.rb:141`](../lib/pubid_new/nist/parser.rb:141):
```ruby
rule(:supplement) do
  (str("supp") | str("sup")) >> match("[A-Z0-9]").repeat.as(:supplement)
end
```

**Issue**: `[A-Z0-9]` matches uppercase only, but "Jan" has lowercase letters

**Fix**:
```ruby
rule(:supplement) do
  (str("supp") | str("sup")) >> match("[A-Za-z0-9]").repeat.as(:supplement)
end
```

**Test After Fixing**:
```ruby
PubidNew::Nist.parse("NIST HB 44 supJan1924")
# Should parse successfully with supplement="Jan1924"
```

### Testing Strategy

**Incremental Testing** (critical!):
1. Fix one issue at a time
2. Test basic parsing after each fix
3. Test the specific failure case
4. Only proceed if both pass

**Test Script**:
```ruby
# Always test these basics after each change
basics = [
  'NIST SP 800-90A',
  'NIST HB 44',
 'NIST FIPS 140-2',
]

# Then test the specific fix
specifics = [
  'NIST SP 800-90A sup',        # Issue 1
  'NIST HB 44 e2-1915',         # Issue 2  
  'NIST HB 44 supJan1924',      # Issue 3
]
```

### Estimated Time: 1-2 hours
- Issue 1 (rendering): 30 min
- Issue 2 (edition-date): 30 min
- Issue 3 (supplement-month): 15 min
- Comprehensive testing: 30 min

---

## Success Criteria

### ANSI
- ✅ All 6 core files created
- ✅ Can parse basic ANSI identifiers
- ✅ Renders identifiers correctly
- ✅ Test suite passes (create sample fixtures)

### NIST
- ✅ "sup" renders correctly: ` sup` not `(sup)`
- ✅ "e2-1915" parses and renders correctly
- ✅ "supJan1924" parses and renders correctly
- ✅ Basic parsing still works (no regressions)
- ✅ Comprehensive test shows 100% or near-100%

### Overall
- ✅ 13/13 flavors functional
- ✅ Documentation updated
- ✅ All changes committed with semantic commit messages

---

## Reference Materials

### Implementation References
- **ISO** (most similar): [`lib/pubid_new/iso/`](../lib/pubid_new/iso/)
- **IEEE** (clean implementation): [`lib/pubid_new/ieee/`](../lib/pubid_new/ieee/)
- **CEN** (minimal example): [`lib/pubid_new/cen/`](../lib/pubid_new/cen/)

### Documentation
- **This Session**: [`docs/SESSION-SUMMARY-2025-11-16-ISO-BREAKTHROUGH.md`](SESSION-SUMMARY-2025-11-16-ISO-BREAKTHROUGH.md)
- **Status**: [`docs/ISO-NIST-FIX-STATUS-2025-11-16.md`](ISO-NIST-FIX-STATUS-2025-11-16.md)
- **IEEE Migration**: [`docs/SESSION-2025-11-16-IEEE-MIGRATION.md`](SESSION-2025-11-16-IEEE-MIGRATION.md)

### Test Infrastructure
- **ISO Test**: [`test_iso_v2.rb`](../test_iso_v2.rb)
- **ISO Fixtures**: `spec/fixtures/iso/*.txt`
- **NIST Fixtures**: `gems/pubid-nist/spec/fixtures/*.txt`

---

## Detailed Action Steps

### Step 1: Create ANSI Parser (45 min)

**File**: `lib/pubid_new/ansi/parser.rb`

**Start by copying ISO parser structure**:
```bash
# Reference ISO parser
code lib/pubid_new/iso/parser.rb
```

**Simplify for ANSI**:
1. Remove ISO-specific rules (directives, supplements if not needed)
2. Change publisher rule: `str("ANSI")`
3. Adjust copublishers: `ISO`, `IEEE`, `IEC` (ANSI co-publishes with these)
4. Keep: number_with_part, date, language rules

**Key ANSI Patterns**:
```
ANSI X3.4-1986         (simple format)
ANSI C63.4-2014        (with part)
ANSI/ISO 9899:1990     (joint standard)
ANSI/IEEE 802.3-2012   (joint with IEEE)
```

### Step 2: Create ANSI Scheme (30 min)

**File**: `lib/pubid_new/ansi/scheme.rb`

**Copy from ISO** ([`lib/pubid_new/iso.rb:27-54`](../lib/pubid_new/iso.rb)):
```ruby
module PubidNew
  module Ansi
    IDENTIFIER_TYPES = [
      Identifiers::AmericanNationalStandard,
    ].freeze

    Scheme = PubidNew::Scheme.new(
      identifiers: IDENTIFIER_TYPES,
      supplement_identifiers: [],  # Add if needed
    )
  end
end
```

### Step 3: Create ANSI Builder (45 min)

**File**: `lib/pubid_new/ansi/builder.rb`

**Simpler than ISO**: ANSI likely doesn't need supplement handling

**Copy core logic from** [`lib/pubid_new/iso/builder.rb`](../lib/pubid_new/iso/builder.rb):
- `initialize(scheme)`
- `build(parsed_hash)`
- `cast(type, value)` for: publisher, number_with_part, date, copublishers

### Step 4: Create ANSI Identifiers (30 min)

**Files**:
- `lib/pubid_new/ansi/identifier.rb` (base class)
- `lib/pubid_new/ansi/single_identifier.rb` (rendering)
- `lib/pubid_new/ansi/identifiers/american_national_standard.rb` (specific type)

**Copy from ISO equivalents**, simplify as needed.

### Step 5: Test ANSI (30 min)

**Create test script**:
```ruby
require_relative 'lib/pubid_new'

test_cases = [
  'ANSI X3.4-1986',
  'ANSI C63.4-2014',
  'ANSI/ISO 9899:1990',
  'ANSI/IEEE 802.3-2012',
  'ANSI Z39.48-1992',
]

test_cases.each do |test|
  id = PubidNew::Ansi.parse(test)
  puts "#{test} => #{id.to_s}"
  puts "✓" if test == id.to_s
end
```

---

## Step-by-Step NIST Fixes

### Phase 1: Fix "sup" Rendering (30 min)

**File**: [`lib/pubid_new/nist/scheme.rb:72`](../lib/pubid_new/nist/scheme.rb)

**Current**:
```ruby
result += " (#{translation})" if translation
```

**Change to**:
```ruby
# Handle "sup" which is actually a supplement, not translation
if translation == "sup"
  result += " sup"
elsif translation
  result += " (#{translation})"
end
```

**Test**:
```ruby
PubidNew::Nist.parse("NIST SP 800-90A sup").to_s
# Should output: "NIST SP 800-90A sup" (not "(sup)")
```

### Phase 2: Add Edition-Date Pattern (30 min)

**File**: [`lib/pubid_new/nist/parser.rb:110`](../lib/pubid_new/nist/parser.rb)

**Insert BEFORE line 123** (the simple edition rule):
```ruby
# Edition number with dash and year: e2-1915
((str("e") | str(" E")) >> match("[0-9]").repeat(1, 3).as(:edition) >> 
  dash >> digits.as(:edition_year)) |
```

**Test**:
```ruby
PubidNew::Nist.parse("NIST HB 44 e2-1915")
# Should parse successfully
```

### Phase 3: Fix Supplement-Month Pattern (15 min)

**File**: [`lib/pubid_new/nist/parser.rb:141`](../lib/pubid_new/nist/parser.rb)

**Change**:
```ruby
rule(:supplement) do
  (str("supp") | str("sup")) >> match("[A-Za-z0-9]").repeat.as(:supplement)
                                    #  ^^^ Add lowercase
end
```

**Test**:
```ruby
PubidNew::Nist.parse("NIST HB 44 supJan1924")
# Should parse successfully with supplement="Jan1924"
```

### Phase 4: Comprehensive NIST Test (30 min)

**Run full test suite**:
```bash
cd gems/pubid-nist
bundle exec rspec
```

**Or create test script**:
```ruby
# Test all fixtures
Dir.glob("gems/pubid-nist/spec/fixtures/*.txt").each do |file|
  File.readlines(file).each do |line|
    # Test each identifier
  end
end
```

---

## Verification Checklist

### Before Committing

- [ ] ISO still at 98.47% (no regressions)
- [ ] ANSI can parse sample identifiers
- [ ] ANSI renders correctly
- [ ] NIST " sup" renders correctly
- [ ] NIST "e2-1915" parses correctly
- [ ] NIST "supJan1924" parses correctly
- [ ] NIST basic parsing still works
- [ ] All modified files follow Ruby style guide
- [ ] No debug statements (`puts`, `p`, etc.) in production code

### Documentation to Update

- [ ] Update this continuation plan with results
- [ ] Create ANSI-specific documentation if needed
- [ ] Update main README if ANSI is added to flavor list

---

## Potential Issues & Solutions

### ANSI Parser Issues

**If ANSI identifiers don't match ISO patterns**:
- Research actual ANSI identifier format rules
- May need different parser rules
- Consider: Are there ANSI test fixtures available?

**Solution**: Start with simple cases, expand as needed

### NIST Parser Issues

**If changes break basic parsing** (like last attempt):
- Revert immediately
- Test more incrementally
- Use Parslet's `.absent?` predicate carefully
- Consider rule ordering implications

**Solution**: Test after EVERY single change

### Integration Issues

**If ANSI/NIST changes affect other flavors**:
- Shared components (TypedStage, Language, Edition) are used by all flavors
- Changes must be backward compatible
- Run quick tests on ISO, IEEE, CEN after component changes

**Solution**: Test cross-flavor after component modifications

---

## Continuation Prompt for Next Session

```
PubID v2 - ANSI Creation + NIST Fixes (Day 3)

Branch: rt-new-lutaml-model, PR: #19

Previous Session Achievement:
✅ ISO: Fixed from 0% → 98.47% (7,544/7,661 passing)
✅ Created "original format preservation" pattern
✅ Started ANSI flavor (main module created)

Current Status: 11/12 flavors ready, ISO at 98.47%

IMMEDIATE TASKS (4-5 hours):

1. COMPLETE ANSI FLAVOR (2-3 hours)
   - Create parser based on ISO template
   - Create scheme, builder, identifier classes
   - Test with: ANSI X3.4-1986, ANSI C63.4-2014, ANSI/ISO 9899:1990
   - Reference: lib/pubid_new/iso/ and lib/pubid_new/ieee/

2. FIX NIST (1-2 hours)  
   - Fix "sup" rendering: ` sup` not `(sup)` (14 cases)
   - Add "e2-1915" edition-date pattern (4 cases)
   - Fix "supJan1924" supplement-month (4 cases)
   - Test incrementally to avoid breaking basic parsing
   - Files: lib/pubid_new/nist/scheme.rb:72,135 and parser.rb:110,141

3. VERIFICATION
   - ANSI: Sample test cases pass
   - NIST: 22 failures → 0 failures
   - ISO: Still at 98.47% (no regressions)

Reference:
- docs/CONTINUATION-PLAN-2025-11-17-ANSI-NIST.md (this file)
- docs/SESSION-SUMMARY-2025-11-16-ISO-BREAKTHROUGH.md
- docs/ISO-NIST-FIX-STATUS-2025-11-16.md

Start with: ANSI parser creation using ISO as template
```

---

## Quick Wins

If time is limited, prioritize:
1. **NIST Fix #1** (sup rendering) - 5 minutes, fixes 14 cases
2. **NIST Fix #3** (supplement lowercase) - 2 minutes, fixes 4 cases  
3. **ANSI basic parser** - 45 minutes, unlocks ANSI flavor

This gets you quick progress on both tasks.

---

## Files Modified This Session (Summary)

```
lib/pubid_new/iso.rb                              # Added parse()
lib/pubid_new/components/typed_stage.rb           # +original_abbr
lib/pubid_new/components/language.rb              # +original_code
lib/pubid_new/components/edition.rb               # +original_text, +to_s()
lib/pubid_new/iso/builder.rb                      # Capture originals
lib/pubid_new/iso/parser.rb                       # Edition capture
lib/pubid_new/iso/single_identifier.rb            # Edition rendering
lib/pubid_new/iso/supplement_identifier.rb        # Smart spacing
lib/pubid_new/ansi.rb                             # ANSI main (new)
lib/pubid_new/nist/parser.rb                      # Attempted fixes (rolled back)

test_iso_v2.rb                                    # Test harness (new)
docs/ISO-NIST-FIX-STATUS-2025-11-16.md           # Status doc (new)
docs/SESSION-SUMMARY-2025-11-16-ISO-BREAKTHROUGH.md  # Summary (new)
docs/CONTINUATION-PLAN-2025-11-17-ANSI-NIST.md   # This file (new)
```

**Total**: 10 modified + 4 created = 14 files

---

## Expected Outcome

After completing this continuation plan:

| Flavor | Target | Confidence |
|--------|--------|------------|
| ISO | 98.47% | ✅ Already achieved |
| NIST | 100% | 🎯 High (targeted fixes) |
| ANSI | 100% | 🎯 High (simple structure) |
| **Overall** | **13/13** | **🎯 Achievable in 4-5 hours** |

Success means: All 13 flavors at 97%+ pass rate, production-ready for PR merge.