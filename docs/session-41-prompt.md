# Session 41 Prompt: Builder Workaround for DAD Parsing

## Context

You are continuing work on PubID V2 (ISO flavor) - a Ruby gem for parsing standards identifiers.

**Current Status:**
- 2,363 passing (82.7%)
- 17 failures (16 in addendum_spec for DAD parsing)
- Session 40 attempted parser fixes but all caused massive regressions (150-650 failures)

**Read these files FIRST:**
- `.kilocode/rules/memory-bank/architecture.md` - System architecture
- `.kilocode/rules/memory-bank/context.md` - Current state
- `docs/continuation-plan-session-41.md` - This session's detailed plan

## Your Task

Implement Builder workaround to enable parsing of these VALID ISO identifiers:
- "ISO 2631/DAD 1" (8 test failures)
- "ISO 2553/DAD 1:1987" (8 test failures)

**Goal:** +16 tests → 82.7% to 86.3% (2,379 passing) with MINIMAL RISK

## Why Builder Workaround (Not Parser)

Session 40 proved that ANY parser modification to `identifier_copublishers_no_third` causes 150+ regressions because:
- That rule serves multiple contexts (base, supplement base, joint base, with type)
- Complex interactions between copublisher parsing, type parsing, and supplement parsing
- Parslet `.maybe` behavior difficult to control precisely

**Builder approach is LOW RISK** because:
- Zero parser changes (zero risk to 2,363 passing tests)
- Isolated to Builder layer
- Can handle edge cases explicitly
- Easy to test and debug

## The Problem

**Architecture is CORRECT:**
- `DAD` is properly in `TYPED_STAGES_SUPPLEMENTS` (not base `TYPED_STAGES`)
- `Addendum` class has proper `TYPED_STAGES` array with DAD/FDAD

**Parser fails on:**
```
"ISO 2631/DAD 1"
```

Because:
1. `supplement_identifier` rule tries to parse base "ISO 2631" via `identifier_copublishers_no_third`
2. That rule has `str("/").maybe` which consumes "/" thinking it might be for type (like "ISO/TR")
3. Then tries to match "DAD" as `type_with_stage` from base TYPED_STAGES
4. Fails because DAD is NOT in base TYPED_STAGES (correctly only in supplements)

## Solution Strategy

**Add special handling in Builder** to detect and process DAD patterns:

### Approach: Pre-processing Detection

**File:** `lib/pubid_new/iso/builder.rb` and possibly `lib/pubid_new/iso.rb`

**Core Idea:** Detect "/DAD" or "/FDAD" patterns BEFORE normal parsing

```ruby
# In Scheme or Identifier.parse()
def self.parse(string)
  # Detect DAD supplement patterns
  if string.match?(/^(.+?)\/F?DAD\s+/)
    return parse_dad_supplement(string)
  end
  
  # Normal parsing
  parser = Parser.new
  parsed_hash = parser.parse(string)
  Builder.new(scheme).build(parsed_hash)
end

private

def self.parse_dad_supplement(string)
  # Split at /DAD or /FDAD
  if match = string.match(/^(.+?)\/(F?DAD)\s+(.+)$/)
    base_str = match[1]
    dad_type = match[2]
    supplement_str = match[3]
    
    # Parse base normally (it won't have /DAD to confuse parser)
    base = parse(base_str)
    
    # Build supplement manually
    # Parse supplement_str for number and optional :year
    # Create Addendum with proper typed_stage
    ...
  end
end
```

### Alternative: Builder Retry Logic

Add fallback in Builder when parsing fails:

```ruby
class Builder
  attr_reader :original_string
  
  def initialize(scheme, original_string = nil)
    @scheme = scheme
    @original_string = original_string
  end
  
  def build(parsed_hash)
    # ... existing implementation
  rescue => e
    # If original string has DAD pattern, try special handling
    if @original_string&.match?(/\/F?DAD\s+/)
      build_dad_supplement(@original_string)
    else
      raise e
    end
  end
  
  private
  
  def build_dad_supplement(string)
    # Similar logic to parse_dad_supplement above
  end
end
```

## Implementation Steps

### Step 1: Analyze Patterns (10 min)

Look at failing test strings:
```bash
bundle exec rspec spec/pubid_new/iso/identifiers/addendum_spec.rb:386 \
  --format documentation 2>&1 | grep "ISO.*DAD"
```

Expected:
- "ISO 2631/DAD 1" - no year on base or supplement
- "ISO 2553/DAD 1:1987" - no year on base, year on supplement  
- "ISO/DIS 1151-1/DAD 2" - base has stage, no years

### Step 2: Choose Implementation Location (5 min)

Option A: In `lib/pubid_new/iso.rb` (Scheme.parse method)
- Pro: String available before parsing
- Con: May need to duplicate some Builder logic

Option B: In `lib/pubid_new/iso/builder.rb` with retry
- Pro: Access to all Builder methods
- Con: Need to pass original string through

**Recommended: Option A** - cleaner separation

### Step 3: Implement (30-40 min)

Key logic needed:
1. Regex to detect and split "/DAD" or "/FDAD" patterns
2. Parse base string recursively (without DAD part)
3. Parse supplement number and optional year from supplement string
4. Lookup correct TypedStage for DAD/FDAD from register
5. Create Addendum identifier with base, number, date, typed_stage

### Step 4: Test (10 min)

```bash
# Target tests
bundle exec rspec spec/pubid_new/iso/identifiers/addendum_spec.rb:386

# Full suite - check for regressions
bundle exec rspec spec/pubid_new/iso/ --format progress 2>&1 | grep "examples,"
```

### Step 5: Fix Regressions if Any (10-20 min)

**Acceptable:** < 10 new failures
**Must fix:** Any regressions in supplement or addendum specs

### Step 6: Commit (5 min)

## Testing Protocol

**Baseline:**
```bash
bundle exec rspec spec/pubid_new/iso/ --format progress 2>&1 | grep "examples,"
# 2859 examples, 17 failures, 480 pending
```

**After changes:**
```bash
# DAD tests specifically
bundle exec rspec spec/pubid_new/iso/identifiers/addendum_spec.rb:386,428 \
  --format documentation

# Should see:
# ISO 2631/DAD 1 - 8 examples, 0 failures
# ISO 2553/DAD 1:1987 - 8 examples, 0 failures

# Full suite
bundle exec rspec spec/pubid_new/iso/ --format progress 2>&1 | grep "examples,"
# Target: 2,379+ passing (16+ gain)
# Acceptable: 2,370+ passing (7+ gain)
```

## Success Criteria

**Minimum:**
- ✅ "ISO 2631/DAD 1" parses correctly
- ✅ "ISO 2553/DAD 1:1987" parses correctly
- ✅ Net gain: +8 or more tests
- ✅ Regressions: < 10 new failures

**Target:**
- ✅ All 16 DAD tests pass
- ✅ Pass rate: 82.7% → 86.3%
- ✅ Total: 2,379/2,859 passing

## Critical Principles

1. **NO PARSER CHANGES** - Session 40 proved this is too risky
2. **Use existing architecture** - DAD in supplements register is correct
3. **Recursive parsing** - Parse base string by calling parse() again
4. **Register lookups** - Use scheme.locate_typed_stage_by_abbr("DAD")
5. **Test incrementally** - After each implementation step

## Files to Read

**MUST READ:**
1. `lib/pubid_new/iso.rb` - See parse() entry point
2. `lib/pubid_new/iso/builder.rb` - Understand build process
3. `lib/pubid_new/iso/identifiers/addendum.rb` - See TYPED_STAGES for DAD
4. `spec/pubid_new/iso/identifiers/addendum_spec.rb` - Lines 386-514 (DAD tests)

**Reference:**
- `.kilocode/rules/memory-bank/architecture.md` - Builder principles

## Example Implementation Skeleton

```ruby
# lib/pubid_new/iso.rb
module PubidNew
  module Iso
    module_function
    
    def parse(identifier)
      # Special handling for DAD supplements
      if identifier.match?(/^(.+?)\/(F?DAD)\s+(.+)$/)
        return parse_dad_supplement(identifier)
      end
      
      # Normal parsing
      parser = Parser.new.memoize
      parsed_hash = parser.parse(identifier)
      Builder.new(scheme).build(parsed_hash)
    end
    
    def parse_dad_supplement(identifier)
      match = identifier.match(/^(.+?)\/(F?DAD)\s+(\d+)(?::(\d{4}))?/)
      
      base_str = match[1]
      dad_abbr = match[2]
      number = match[3]
      year = match[4]
      
      # Parse base recursively
      base_identifier = parse(base_str)
      
      # Lookup TypedStage from register
      typed_stage = scheme.locate_typed_stage_by_abbr(dad_abbr)
      
      # Build Addendum
      Identifiers::Addendum.new(
        base_identifier: base_identifier,
        number: Components::Code.new(value: number),
        date: year ? Components::Date.new(year: year) : nil,
        typed_stage: typed_stage,
        stage: typed_stage.to_stage,
        type: typed_stage.to_type
      )
    end
    
    def scheme
      @scheme ||= Scheme.new
    end
  end
end
```

## If This Approach Fails

**Fallback 1:** Research IEC implementation (30 min)
- Check `lib/pubid_new/iec/parser.rb`
- See how IEC handles similar patterns

**Fallback 2:** Document for future Parser refactor
- Session 40 findings + Session 41 Builder attempt
- Recommend Priority 2 approach from continuation plan

## Commit Message Template

```
fix(iso): enable DAD supplement parsing via Builder workaround

- Add pre-parsing detection for /DAD and /FDAD patterns
- Parse base and supplement separately to avoid parser conflict
- Use recursive parse() call for base identifier
- Lookup TypedStage from supplement register
- Construct Addendum identifier with complete components
- Impact: +X tests (X DAD addendum tests now passing)

Session 41: 82.7%→X.X% (2,363→X,XXX passing)
```

Good luck with Session 41!