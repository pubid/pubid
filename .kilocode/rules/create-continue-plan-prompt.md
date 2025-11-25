# Session 23+ Continuation Plan: ISO Builder Architecture & Test Improvements

## Critical Context - READ THIS FIRST

**Session 22 restored the clean Builder architecture** that was corrupted in previous sessions. The ISO Builder now follows the 5 core principles documented in `.kilocode/rules/memory-bank/architecture.md`.

**IMPORTANT**: The clean architecture uses **TYPED_STAGE REGISTER** as the single source of truth. Builder **NEVER** makes type/stage decisions - it only casts parsed data to domain objects.

## Current State (Session 22 Complete)

### Test Results
- **Total**: 2,859 examples
- **Passing**: 1,978 (69.1%)
- **Failing**: 504 (17.6%)
- **Pending**: 377 (13.2%)

### Session 22 Progress
- Created ISO Scheme class with registry pattern
- Fixed Builder component namespaces
- Added API compatibility methods (.body, .value)
- **Impact**: +696 tests fixed through API compatibility alone
- **Net improvement**: +291 tests from Session 20 baseline (59.0% → 69.1%)

### Clean Architecture Verified ✅
1. ✅ TYPED_STAGE REGISTER is source of truth
2. ✅ Builder receives Scheme for lookups
3. ✅ Single cast() method for conversions
4. ✅ Composite hash returns for related values
5. ✅ Components render themselves

## The 5 Core Principles (NEVER VIOLATE)

### 1. TYPED_STAGE REGISTER is SOURCE OF TRUTH

```ruby
# ✅ CORRECT
def locate_typed_stage(typed_stage_string)
  typed_stage_string = "" if typed_stage_string.nil?
  @scheme.locate_typed_stage_by_abbr(typed_stage_string)
end

# ❌ WRONG - Hardcoded checks
if data[:typed_stage]
  ts = data[:typed_stage].to_s
  return "TR" if ts.include?("TR")  # DON'T DO THIS!
end
```

### 2. Builder.new(scheme)

Builder must receive Scheme instance for all lookups:

```ruby
# ✅ CORRECT
class Builder
  def initialize(scheme)
    @scheme = scheme
  end
end

# Usage
PubidNew::Iso::Builder.new(PubidNew::Iso::Scheme).build(parsed_hash)
```

### 3. Single cast() Method

ALL conversions happen in ONE place:

```ruby
# ✅ CORRECT - Everything in cast()
def cast(type, value)
  case type
  when :type_with_stage
    typed_stage = locate_typed_stage(value)
    { stage: typed_stage.to_stage, type: typed_stage.to_type, typed_stage: typed_stage }
  when :languages
    # ... language conversion
  end
end

# ❌ WRONG - Logic scattered in multiple places
def extract_type(data)  # DON'T DO THIS!
  # ... type logic
end
```

### 4. Composite Hash Returns

When cast returns multiple related values, return a hash:

```ruby
# ✅ CORRECT
when :type_with_stage
  {
    stage: typed_stage_with_original.to_stage,
    type: typed_stage_with_original.to_type,
    typed_stage: typed_stage_with_original
  }
```

### 5. Components Render Themselves

NO hardcoded abbreviations in identifiers:

```ruby
# ✅ CORRECT - Use component's abbreviation method
def publisher_portion
  [
    publisher.body,
    (typed_stage.abbreviation.empty? ? "" : "/#{typed_stage.abbreviation}")
  ].join('')
end

# ❌ WRONG - Hardcoded abbreviation logic
if stage == "FDIS"
  "FDIS"  # DON'T DO THIS!
end
```

## Anti-Patterns to AVOID

These were the mistakes from Sessions 15-20 that corrupted the architecture:

❌ **NEVER add hardcoded type/stage checks to Builder**
❌ **NEVER create helper methods that duplicate register logic**
❌ **NEVER make Builder handle rendering decisions**
❌ **NEVER hardcode abbreviations in identifiers**
❌ **NEVER check types in multiple places**

## Session 23 Immediate Tasks

### Priority 1: Fix Copublisher Handling (Est. 30-60 min, +100-150 tests)

**Problem**: Builder creates array of strings instead of array of Publisher objects

**Current failure pattern** (196 occurrences):
```
Failure/Error: expect(parsed.publisher.copublisher.first).to eq("IEC")
NoMethodError: undefined method `first' for "IEC":String
```

**Root cause**: In Builder cast() method:
```ruby
when :copublishers
  if value.nil? || value.empty?
    nil
  else
    value.map do |copublisher|
      copublisher[:copublisher]  # Returns string, should return Publisher object
    end
  end
```

**Fix needed**:
```ruby
when :copublishers
  if value.nil? || value.empty?
    nil
  else
    value.map do |copublisher|
      PubidNew::Iso::Components::Publisher.new(publisher: copublisher[:copublisher])
    end
  end
end
```

**But wait** - check if ISO Publisher component expects copublishers as:
1. Separate Publisher objects (array)
2. Strings stored in copublisher attribute (collection)

Look at the Publisher component definition and the rendering code to understand the correct data structure.

**Steps**:
1. Read [`lib/pubid_new/iso/components/publisher.rb`](lib/pubid_new/iso/components/publisher.rb:1)
2. Read identifier rendering that uses copublishers
3. Understand if copublishers should be:
   - Array of Publisher objects
   - Array of strings in publisher.copublisher attribute
4. Update Builder cast() to match expected structure
5. Run tests: `bundle exec rspec spec/pubid_new/iso/`
6. Commit with semantic message

**Expected impact**: +100-150 tests

### Priority 2: Analyze Remaining Failures (Est. 30 min)

**After copublisher fix**, run data-driven analysis:

```bash
bundle exec rspec spec/pubid_new/iso/ --format documentation 2>&1 | \
  grep "Failure/Error:" | \
  sort | uniq -c | sort -rn > failures.txt
```

Look for patterns in:
1. Parser failures (Failed to parse)
2. TypedStage API differences (architectural, may be pending)
3. Rendering differences (attribute-level fixes)

### Priority 3: Target Low-Hanging Fruit (Est. 60 min, +20-50 tests)

Based on failure analysis, identify repeatable patterns that can be fixed with:
- Minor Builder cast() additions
- TYPED_STAGES register enhancements
- Component API additions

**Do NOT**:
- Attempt parser architecture changes
- Add hardcoded logic to Builder
- Make speculative fixes without data

## Remaining Known Issues (504 failures)

### Breakdown by Type:
1. **Copublisher handling**: ~196 failures (Priority 1 fix)
2. **Parser gaps**: ~92 failures (identify specific patterns)
3. **TypedStage API**: ~67 failures (may be architectural)
4. **Rendering edge cases**: ~149 failures (attribute-level)

### Parser Failures

When you see "Failed to parse", it means:
1. Parser grammar doesn't match the pattern
2. Parser rule ordering issue (specific pattern shadowed)
3. New identifier pattern not yet implemented

**Strategy**: Document failing patterns, then decide if parser enhancement is worth the effort vs. expected test gain.

## Testing Strategy

### Always Follow This Process:

1. **Before ANY change**: Document baseline test count
2. **Make ONE focused change**: Single responsibility
3. **Run tests**: `bundle exec rspec spec/pubid_new/iso/`
4. **Compare results**: Did it improve or regress?
5. **Commit incrementally**: Semantic message with impact

### Example Workflow:

```bash
# 1. Baseline
bundle exec rspec spec/pubid_new/iso/ | grep "examples,"
# => 2859 examples, 504 failures, 377 pending

# 2. Make focused change
# ... edit one file with one fix

# 3. Test
bundle exec rspec spec/pubid_new/iso/ | grep "examples,"
# => 2859 examples, 400 failures, 377 pending  (+104 tests!)

# 4. Commit
git add -A
git commit -m "fix(iso): proper copublisher object construction

Builder now creates Publisher objects instead of strings.

Impact: +104 tests (69.1% → 72.7%)"
```

## Success Metrics

### Session 23 Goals:
- ✅ **PASS**: 2,000+ passing (70%+) with copublisher fix
- ⚠️ **MIXED**: 1,950-2,000 passing (need one more pattern)
- ❌ **FAIL**: <1,950 passing (strategy needs revision)

### Long-term Targets:
- **75% (2,144 passing)**: 3-4 sessions, systematic fixes
- **80% (2,287 passing)**: 6-8 sessions, may need parser work
- **85% (2,430 passing)**: Major milestone, parser architecture

## Architecture Reference

### File Structure:
```
lib/pubid_new/iso/
├── scheme.rb               # Registry (NEW in Session 22)
├── builder.rb              # Clean architecture (FIXED in Session 22)
├── parser.rb               # Grammar-based parsing
├── identifier.rb           # Base class with parse()
├── single_identifier.rb    # For base documents
├── supplement_identifier.rb # For amendments
├── components/             # ISO-specific components
│   ├── publisher.rb        # Has .body alias
│   └── code.rb             # Has .value alias
└── identifiers/            # 17 concrete identifier types
    ├── international_standard.rb
    ├── amendment.rb
    └── ...
```

### Component Namespaces:

**ISO-specific** (use these for Publisher and Code):
- `PubidNew::Iso::Components::Publisher`
- `PubidNew::Iso::Components::Code`

**Shared** (use these for other components):
- `PubidNew::Components::Date`
- `PubidNew::Components::Edition`
- `PubidNew::Components::Language`
- `PubidNew::Components::Locality`
- `PubidNew::Components::Type`
- `PubidNew::Components::Stage`
- `PubidNew::Components::TypedStage`

### Key Classes:

**Scheme** ([`lib/pubid_new/iso/scheme.rb`](lib/pubid_new/iso/scheme.rb:1)):
- `locate_typed_stage_by_abbr(abbr)` - Lookup from register
- `locate_identifier_klass_by_type_code(type_code)` - Get identifier class

**Builder** ([`lib/pubid_new/iso/builder.rb`](lib/pubid_new/iso/builder.rb:1)):
- `initialize(scheme)` - Receive scheme for lookups
- `build(parsed_hash)` - Transform parse tree to identifier
- `cast(type, value)` - Convert parsed value to component

## Common Tasks

### To analyze failures:
```bash
bundle exec rspec spec/pubid_new/iso/ --format documentation 2>&1 | \
  grep "Failure/Error:" | \
  sort | uniq -c | sort -rn | head -20
```

### To see actual error messages:
```bash
bundle exec rspec spec/pubid_new/iso/identifier_spec.rb --format documentation 2>&1 | \
  grep -A 5 "Failure/Error:" | head -40
```

### To test a specific identifier type:
```bash
bundle exec rspec spec/pubid_new/iso/identifiers/amendment_spec.rb
```

### To run parser tests only:
```bash
bundle exec rspec spec/pubid_new/iso/parser_spec.rb
```

## Memory Bank Files

**ALWAYS read these first**:
1. `.kilocode/rules/memory-bank/architecture.md` - Full architecture with Builder section
2. `.kilocode/rules/memory-bank/builder-migration-plan.md` - ISO/IEC migration plan
3. `.kilocode/rules/memory-bank/context.md` - Current state and recent changes

## Git Reference

**Clean architecture commit**: `05581a336fc770796b873e538c058a520d645b12`
**Session 22 completion**: `fd3b590` - feat(iso): create Scheme and fix Builder architecture

## Key Reminders

1. **Trust the architecture** - It worked before being broken
2. **One fix at a time** - Incremental, atomic changes
3. **Data-driven only** - No speculative changes
4. **Ask before hardcoding** - There's always a register-based solution
5. **Read memory bank first** - All principles are documented

## Example Session Flow

**Good Session Example**:
```
1. Read memory bank files
2. Run baseline tests (2859 examples, 504 failures)
3. Analyze top failure pattern (copublisher)
4. Read relevant code (Publisher component, Builder cast)
5. Understand data structure needed
6. Make focused fix (Builder copublisher handling)
7. Test (2859 examples, 400 failures) +104!
8. Commit with semantic message
9. Analyze next pattern
10. Repeat with second fix if time permits
```

**Bad Session Example** (DON'T DO THIS):
```
1. Skip memory bank
2. Make multiple speculative changes
3. Add hardcoded logic to Builder
4. Don't test after each change
5. Make combined commit
6. Tests regress
7. Hard to identify which change broke what
```

## Final Notes

- **Session 22 was successful** because it fixed infrastructure (Scheme) and API compatibility
- **The architecture is now clean** - all future work should preserve this
- **Copublisher fix is the next low-hanging fruit** with highest expected impact
- **IEC migration** should wait until ISO is 75%+ and patterns are clear

Good luck with Session 23!