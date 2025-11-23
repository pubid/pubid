# PubID V2 ISO Parser - Session Continuation Prompt

**Date:** 2025-11-22 17:43 HKT
**Session:** 2 of 4
**Progress:** 70% (14/20 tests passing)

---

## Quick Context

You're continuing work on the PubID V2 ISO parser implementation. The core architecture is complete and 70% of tests are passing. Six tests remain that need specific fixes for edge cases.

## Commands to Resume

```bash
# Navigate to project
cd /Users/mulgogi/src/mn/pubid

# Check current status (should show 14/20 passing)
bundle exec rspec spec/pubid_new/iso/identifier_spec.rb --format progress

# Review detailed plan
cat CONTINUATION_PLAN.md

# Check implementation status
cat IMPLEMENTATION_STATUS.md
```

---

## What's Working (14 tests) ✅

### Core Systems
1. **Parser & Builder Integration** - Converts parser output to identifier objects
2. **Single Copublisher** - ISO/IEC, ISO/SAE patterns work
3. **All Basic Types** - InternationalStandard, Guide, TR, TS, PAS, DATA, TTA, R, ISP
4. **Basic Supplements** - Amd, Cor, Suppl, Ext with default typed_stage
5. **Component System** - Type.abbr, Language.original_code, proper inheritance

### Key Architecture Decisions
- All identifiers inherit from [`::PubidNew::Identifier`](lib/pubid_new/identifier.rb)
- Supplements default to published typed_stage if none specified
- Builder converts array-of-hashes to single hash at both levels
- Type component uses `abbr` attribute, Language uses `original_code`

---

## What Needs Fixing (6 tests) ❌

### 1. IEEE Multiple Copublishers (2 tests) 🔴 HIGH PRIORITY

**Problem:** "ISO/IEC/IEEE" outputs as "ISO/IEEE" - missing middle copublisher

**Files to Check:**
```bash
lib/pubid_new/iso/components/publisher.rb  # Likely only handles 1 copublisher
lib/pubid_new/iso/parser.rb                # Check copublisher parsing
```

**Test:**
```bash
bundle exec rspec spec/pubid_new/iso/identifier_spec.rb:64 -fd
```

**Expected Fix:** Publisher component needs to handle array of 2+ copublishers

---

### 2. FDAM Parser Pattern (1 test) 🔴 HIGH PRIORITY

**Problem:** Parser fails for "ISO/IEC/IEEE 8802-3:2021/FDAM 1" at char 25

**File to Modify:** [`lib/pubid_new/iso/parser.rb`](lib/pubid_new/iso/parser.rb)

**Current Issue:** Supplement rule requires supplement_type even when typed_stage present

**Fix:**
```ruby
rule(:supplement) do
  slash >> (
    # Pattern 1: Typed stage alone (FDAM implies Amd)
    (typed_stage.as(:typed_stage) >> space >> digits.as(:supplement_number) >> year.maybe) |
    # Pattern 2: Supplement type with optional number
    (supplement_type >> (space >> digits).maybe.as(:supplement_number) >> year.maybe)
  )
end
```

**Test:**
```bash
bundle exec rspec spec/pubid_new/iso/identifier_spec.rb:56 -fd
```

---

### 3. IWA Typed Stage (1 test) 🟡 MEDIUM PRIORITY

**Problem:** InternationalWorkshopAgreement calls `typed_stage.abbreviation` when nil

**File:** [`lib/pubid_new/iso/identifiers/international_workshop_agreement.rb`](lib/pubid_new/iso/identifiers/international_workshop_agreement.rb)

**Fix:** Add same nil-safe pattern as SupplementIdentifier:
```ruby
def to_s(...)
  stage_abbr = if typed_stage && typed_stage.abbreviation
    typed_stage.abbreviation
  elsif self.class.respond_to?(:type)
    self.class.type[:short]
  else
    "IWA"
  end
  # Use stage_abbr in output
end
```

**Test:**
```bash
bundle exec rspec spec/pubid_new/iso/identifier_spec.rb:128 -fd
```

---

### 4. Directives Publisher (1 test) 🟡 MEDIUM PRIORITY

**Problem:** Calls non-existent `publisher.body` method

**File:** [`lib/pubid_new/iso/identifiers/directives.rb`](lib/pubid_new/iso/identifiers/directives.rb)

**Fix:** Replace `publisher.body` with `publisher.publisher` or `publisher.to_s`

**Test:**
```bash
bundle exec rspec spec/pubid_new/iso/identifier_spec.rb:144 -fd
```

---

### 5. Directives Supplement (1 test) 🟡 MEDIUM PRIORITY

**Problem:** Returns Directives class instead of DirectivesSupplement

**Files:**
- [`lib/pubid_new/iso/builder.rb`](lib/pubid_new/iso/builder.rb) - Builder logic
- [`lib/pubid_new/iso/parser.rb`](lib/pubid_new/iso/parser.rb) - Parser pattern

**Fix:** Update builder to detect DIR SUP pattern:
```ruby
def determine_identifier_class(type_str)
  case type_str&.upcase
  when "DIR"
    if data[:sup_type] || data[:sup_publisher]
      Identifiers::DirectivesSupplement
    else
      Identifiers::Directives
    end
```

**Test:**
```bash
bundle exec rspec spec/pubid_new/iso/identifier_spec.rb:152 -fd
```

---

### 6. Multi-Level Supplements (1 test) 🟢 LOW PRIORITY

**Problem:** "ISO/IEC 13818-1:2015/Amd 3:2016/Cor 1:2017" returns Amendment instead of Corrigendum

**File:** [`lib/pubid_new/iso/builder.rb`](lib/pubid_new/iso/builder.rb)

**Fix:** Implement recursive supplement building (builder currently only handles first supplement)

**Test:**
```bash
bundle exec rspec spec/pubid_new/iso/identifier_spec.rb:72 -fd
```

---

## Recommended Work Order

### Session 2 (This Session)
1. **IEEE copublisher** (1 hour) - Fixes 2 tests
2. **FDAM parser** (30 min) - Fixes 1 test
3. **IWA nil check** (15 min) - Fixes 1 test
4. **Directives** (30 min) - Fixes 2 tests

**Target:** 19/20 tests passing (95%)

### Session 3 (Next)
1. Multi-level supplements (1 hour)
2. Unit tests for all identifier classes (3 hours)
3. Documentation updates (1 hour)

### Session 4 (Final)
1. Remove debug code
2. Rubocop cleanup
3. Performance check
4. Final review

---

## Critical Files Reference

### Core Files
- [`lib/pubid_new/identifier.rb`](lib/pubid_new/identifier.rb) - Parent class with base attributes
- [`lib/pubid_new/iso/parser.rb`](lib/pubid_new/iso/parser.rb) - Grammar rules
- [`lib/pubid_new/iso/builder.rb`](lib/pubid_new/iso/builder.rb) - Object construction
- [`lib/pubid_new/iso/single_identifier.rb`](lib/pubid_new/iso/single_identifier.rb) - Single ID rendering
- [`lib/pubid_new/iso/supplement_identifier.rb`](lib/pubid_new/iso/supplement_identifier.rb) - Supplement wrapping

### Components
- [`lib/pubid_new/iso/components/publisher.rb`](lib/pubid_new/iso/components/publisher.rb) - Publisher with copublishers
- [`lib/pubid_new/components/type.rb`](lib/pubid_new/components/type.rb) - Type with abbr
- [`lib/pubid_new/components/language.rb`](lib/pubid_new/components/language.rb) - Language with original_code

### Test File
- [`spec/pubid_new/iso/identifier_spec.rb`](spec/pubid_new/iso/identifier_spec.rb) - Integration tests

---

## Key Architectural Rules (DO NOT VIOLATE)

### 1. Object-Oriented Design
- **NEVER modify parent classes** - Extend through inheritance
- **NO hardcoded values** - Use constants and polymorphism
- **NO utility/helper classes** - Proper OOP encapsulation

### 2. MECE Principles
- Each class handles **mutually exclusive** patterns
- All patterns must be **collectively exhaustive**
- No overlap in responsibilities

### 3. Component Usage
- Type uses **`abbr`** attribute (not `value`)
- Language uses **`original_code`** attribute (not `value`)
- Always check for nil before accessing component methods

### 4. Testing
- **NEVER lower test thresholds** - Fix behavior, not tests
- Each public method must have tests
- Test edge cases and error paths

### 5. Code Quality
- Use `bundle exec` for all Ruby commands
- Max 80 characters per line
- No debug code in commits
- Rubocop must pass

---

## Common Pitfalls to Avoid

1. **Using raw `ruby`** - Always use `bundle exec ruby` or `bundle exec rspec`
2. **Modifying parent Identifier** - Extend, don't modify
3. **Missing nil checks** - All optional attributes must be guarded
4. **Wrong component attributes** - Type.abbr and Language.original_code
5. **Breaking tests to pass** - Fix behavior, never adjust expectations

---

## Debugging Tips

### Check Parser Output
```ruby
require_relative 'lib/pubid_new/iso/parser'
result = PubidNew::Iso::Parser.parse("ISO/IEC/IEEE 8802-21:2018")
puts result.inspect
```

### Check Component Structure
```ruby
require_relative 'lib/pubid_new/iso/identifier'
id = PubidNew::Iso::Identifier.parse("ISO/IEC TR 29186:2012")
puts "Type: #{id.type.inspect}"
puts "Type.abbr: #{id.type.abbr}" if id.type
```

### Run Single Test with Details
```bash
bundle exec rspec spec/pubid_new/iso/identifier_spec.rb:64 --format documentation
```

---

## Documentation Status

### Complete ✅
- [`CONTINUATION_PLAN.md`](CONTINUATION_PLAN.md) - Detailed implementation plan
- [`IMPLEMENTATION_STATUS.md`](IMPLEMENTATION_STATUS.md) - Current metrics and status
- This prompt (CONTINUATION_PROMPT.md)

### Needs Update 📝
- README.adoc - Add ISO parser architecture section
- Create docs/architecture/iso-parser.adoc - Detailed design docs

### To Move to old-docs/ 📦
- Any SESSION_SUMMARY_*.md files from previous session
- Any temporary NOTES_*.md files
- Old CONTINUATION_PROMPT files after this session complete

---

## Success Metrics for This Session

✅ **Minimum Goal:** 19/20 tests passing (one multi-level supplement can wait)
✅ **Stretch Goal:** 20/20 tests passing (all issues resolved)
✅ **Documentation:** Start README.adoc updates

---

## When You Get Stuck

1. **Check working examples** - NIST and IEEE parsers are production-ready
2. **Read parent classes** - Many attributes inherited from ::PubidNew::Identifier
3. **Check old implementation** - `gems/pubid-iso/` has reference code
4. **Add debug logging** - Use `puts` to inspect data structures
5. **Test incrementally** - One test at a time, understand each failure

---

## Environment Info

- **Ruby:** Use `bundle exec` for all commands
- **Working Directory:** `/Users/mulgogi/src/mn/pubid`
- **Test Framework:** RSpec
- **Linter:** Rubocop (will run in Session 4)

---

## Final Reminders

- 🎯 **Focus on IEEE copublisher first** - Quick win, fixes 2 tests
- 🎯 **Use bundle exec** - Don't use raw ruby command
- 🎯 **Test after each change** - Incremental validation
- 🎯 **Follow OOP principles** - No shortcuts or hacks
- 🎯 **Document decisions** - Update this prompt with new insights

---

**Status:** Ready to resume. Start with Phase 1 (IEEE copublisher) in CONTINUATION_PLAN.md.

**Last Commit Message Suggestion:**
```
feat(iso): complete core parser architecture (70% tests passing)

- Fix copublisher array-to-hash conversion
- Migrate all classes to proper parent inheritance
- Fix Type.abbr and Language.original_code usage
- Implement supplement default typed_stage system
- Modernize Guide class to use parent attributes

Remaining: 6 edge case fixes for 100% test coverage
```
