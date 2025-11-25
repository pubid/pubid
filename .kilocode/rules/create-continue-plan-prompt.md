# Session 21-22 Continuation Plan: Builder Architecture Cleanup

## Critical Context

**IMPORTANT**: Session 21 discovered that the ISO Builder had been corrupted with anti-patterns. The user reverted ISO files to commit `05581a336fc770796b873e538c058a520d645b12` which contains the CLEAN architecture that must be followed.

## What Happened in Session 21

### The Problem Discovered

1. Previous sessions (Sessions 15-20) had been adding hardcoded logic to Builder
2. This violated the core architectural principle: **Builder's ONLY job is to CAST parsed data**
3. The clean architecture uses **TYPED_STAGE REGISTER** as single source of truth
4. All type/stage decisions come from `scheme.locate_typed_stage_by_abbr()`, never from hardcoded checks

### Actions Taken

1. **Git reverted** ISO files to clean commit `05581a336fc770796b873e538c058a520d645b12`
2. **Updated memory bank** with comprehensive Builder architecture documentation
3. **Created migration plan** at `.kilocode/rules/memory-bank/builder-migration-plan.md`
4. **Documented anti-patterns** to never repeat the mistakes

### Memory Bank Updates (Commit 4fcd50f, 8f0fe77)

**New Section in `.kilocode/rules/memory-bank/architecture.md`:**
- "Builder Architecture (CRITICAL - NEVER VIOLATE)"
- 5 core principles from clean architecture
- Clean Builder code structure
- Anti-patterns with concrete examples
- Scheme requirements

**New File `.kilocode/rules/memory-bank/builder-migration-plan.md`:**
- ISO fix plan (3 phases)
- IEC migration plan (5 phases)
- Testing strategy
- Success criteria

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

```ruby
# ✅ CORRECT
class Builder
  def initialize(scheme)
    @scheme = scheme
  end
end

# Usage
Builder.new(PubidNew::Iso::Scheme).build(parsed_hash)
```

### 3. Single cast() Method

```ruby
# ✅ CORRECT - ALL conversions in ONE place
def cast(type, value)
  case type
  when :type_with_stage
    typed_stage = locate_typed_stage(value)
    { stage: typed_stage.to_stage, type: typed_stage.to_type, typed_stage: typed_stage }
  when :languages
    # ... language conversion
  # ... other types
  end
end
```

### 4. Composite Hash Returns

```ruby
# ✅ CORRECT - Return related values together
when :type_with_stage
  {
    stage: typed_stage_with_original.to_stage,
    type: typed_stage_with_original.to_type,
    typed_stage: typed_stage_with_original
  }

# Then Builder assigns each:
realized_components.each_pair do |k, v|
  identifier.send("#{k}=", v)
end
```

### 5. Components Render Themselves

```ruby
# ✅ CORRECT - Identifier uses typed_stage.abbreviation
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

## Current State After Session 21

### ISO Files Reverted to Clean Architecture

**Working clean structure:**
- `lib/pubid_new/iso/builder.rb` - Clean Builder with single cast() method
- `lib/pubid_new/iso/identifier.rb` - Calls `Builder.new(Scheme).build()`
- `lib/pubid_new/iso/single_identifier.rb` - Renders using `typed_stage.abbreviation`
- `lib/pubid_new/iso/supplement_identifier.rb` - Same pattern

**Known Issues:**
- ISO components namespace mismatch (Builder references `Components::` but they're in `PubidNew::Iso::Components::`)
- Missing or incomplete Scheme class
- Tests currently failing due to namespace issues

## Next Session Tasks (Session 22)

### Phase 1: Fix ISO Component References (30 min)

**Goal**: Get ISO tests running again

1. **Check component location** (5 min)
   ```bash
   ls -la lib/pubid_new/iso/components/
   ls -la lib/pubid_new/components/
   ```

2. **Fix Builder requires** (10 min)
   - Update `require_relative` statements in `builder.rb`
   - Use correct namespace in cast() method
   - Either move components or fix references

3. **Verify Scheme exists** (10 min)
   ```bash
   cat lib/pubid_new/iso/scheme.rb
   ```
   
   Must have:
   ```ruby
   class Scheme
     def locate_typed_stage_by_abbr(abbr)
       # Returns TypedStage from register
     end
     
     def locate_identifier_klass_by_type_code(type_code)
       # Returns identifier class
     end
   end
   ```

4. **Run tests** (5 min)
   ```bash
   bundle exec rspec spec/pubid_new/iso/ --format progress
   ```

**Success Criteria:**
- Tests run without LoadError
- Baseline test count documented

### Phase 2: Verify Identifier TYPED_STAGES (30 min)

**Goal**: Ensure all identifier classes have proper TYPED_STAGES arrays

1. **Check each identifier class** (20 min)
   ```bash
   grep -r "TYPED_STAGES" lib/pubid_new/iso/identifiers/
   ```
   
   Each should have:
   ```ruby
   TYPED_STAGES = [
     Components::TypedStage.new(
       abbr: ["Amd"],
       stage_code: "published",
       type_code: :amd
     ),
     # ... more stages
   ].freeze
   ```

2. **Verify rendering** (10 min)
   - Check `to_s` methods use `typed_stage.abbreviation`
   - NO hardcoded stage/type strings
   - ALL use component methods

**Success Criteria:**
- All identifier classes have TYPED_STAGES
- All rendering uses component methods
- No hardcoded logic

### Phase 3: Run Tests and Document Baseline (30 min)

1. **Full test run**
   ```bash
   bundle exec rspec spec/pubid_new/iso/ --format progress 2>&1 | tee iso_baseline.txt
   ```

2. **Document results**
   - Total examples
   - Passing count
   - Failure types (parser vs builder vs rendering)
   - Identify top 3 failure patterns

3. **Create next steps plan**
   - Based on failure analysis
   - Prioritize fixes
   - Estimate effort

**Success Criteria:**
- Baseline documented
- Clean architecture verified
- Next priorities clear

## IEC Migration (Session 23+)

**NOT to start until ISO is working!**

Follow the plan in `.kilocode/rules/memory-bank/builder-migration-plan.md`:

1. Audit current IEC Builder
2. Create IEC Scheme with register
3. Refactor IEC Builder to clean pattern
4. Update IEC Components
5. Update IEC Identifiers

## Critical Reminders

### What NOT to Do (Anti-Patterns)

❌ **NEVER add hardcoded type/stage checks to Builder**
❌ **NEVER create helper methods that duplicate register logic**
❌ **NEVER make Builder handle rendering decisions**
❌ **NEVER hardcode abbreviations in identifiers**
❌ **NEVER check types in multiple places**

### What TO Do (Clean Patterns)

✅ **ALWAYS use scheme.locate_typed_stage_by_abbr()**
✅ **ALWAYS return composite hashes from cast()**
✅ **ALWAYS let components render themselves**
✅ **ALWAYS add to TYPED_STAGES register for new patterns**
✅ **ALWAYS trust the architecture**

## Testing Strategy

1. **Before ANY change**: Document baseline with test count
2. **After EVERY change**: Run tests and compare
3. **NO speculative changes**: Data-driven only
4. **One change at a time**: Atomic, focused
5. **Commit incrementally**: Each improvement separately

## Success Metrics

**Session 22 Goals:**
- ISO tests running (no LoadError)
- Baseline documented
- Clean architecture verified
- Next priorities identified

**Post-Session 22:**
- Fix top failure patterns using ONLY:
  - Register enhancements
  - Parser fixes
  - Component additions
- NEVER Builder conditionals
- NEVER hardcoded logic

## Architecture Reference

**Always consult:**
- `.kilocode/rules/memory-bank/architecture.md` - Full architecture
- `.kilocode/rules/memory-bank/builder-migration-plan.md` - Migration steps
- Commit `05581a336fc770796b873e538c058a520d645b12` - Clean reference

**Key principle:**
> The Builder's ONLY job is to CAST parsed data to domain objects.
> It NEVER makes business logic decisions.
> ALL type/stage decisions come from the TYPED_STAGE REGISTER.

## Notes for Future Sessions

1. **Read memory bank FIRST** - Architecture principles are documented
2. **Check git log** - See if any reverts happened
3. **Trust the architecture** - It worked before being broken
4. **Ask before hardcoding** - There's always a register-based solution
5. **One fix at a time** - Incremental progress is better than big rewrites
