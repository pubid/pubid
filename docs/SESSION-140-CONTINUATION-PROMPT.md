# Session 140 Continuation Prompt

**Status:** Session 139 complete - Ready for Corrigendum recursive base parsing
**Estimated Time:** 90 minutes
**Priority:** OPTIONAL (project is production-ready as-is)

---

## Context

Session 139 created comprehensive unit tests for Session 138 features. Testing revealed that the Corrigendum class needs **recursive base identifier parsing** in the Builder, similar to how ISO/IEC Amendment works.

**Current implementation:**
- ✅ Corrigendum class exists ([`lib/pubid_new/ieee/identifiers/corrigendum.rb`](lib/pubid_new/ieee/identifiers/corrigendum.rb:1))
- ✅ Parser pattern captures corrigendum ([`lib/pubid_new/ieee/parser.rb`](lib/pubid_new/ieee/parser.rb:209))
- ✅ Builder routes to Corrigendum ([`lib/pubid_new/ieee/builder.rb`](lib/pubid_new/ieee/builder.rb:203))
- ⏳ **Missing:** Base identifier recursive parsing

**What needs to happen:**
```ruby
# Input: "IEEE Std 535-2013/Cor. 1-2017"

# Current: Parses as Base with cor_* attributes
Base.new(code: "535", year: "2013", cor_number: "1", cor_year: "2017")

# Needed: Parse base recursively, wrap in Corrigendum
Corrigendum.new(
  base_identifier: Base.parse("IEEE Std 535-2013"),  # Recursive!
  cor_number: "1",
  cor_year: "2017"
)
```

---

## Objective

Implement recursive base identifier parsing for IEEE Corrigendum to achieve architectural consistency with ISO/IEC Amendment pattern.

**Success criteria:**
- ✅ 7/7 corrigendum tests passing
- ✅ Base identifier recursively parsed
- ✅ Round-trip fidelity maintained  
- ✅ No regressions in existing tests
- ✅ Architecture clean (MODEL-DRIVEN)

---

## Implementation Plan (90 minutes)

### Phase 1: Study Reference Implementation (15 min)

**Read ISO Amendment pattern:**
```bash
# Read these files to understand the pattern
```

Read:
1. `lib/pubid_new/iso/parser.rb` - Look for amendment_identifier rule
2. `lib/pubid_new/iso/builder.rb` - Look for amendment building logic
3. `lib/pubid_new/iec/parser.rb` - Alternative reference (similar pattern)

**Key concepts to understand:**
- How parser splits base from supplement
- How builder recursively parses base string
- How supplement wraps parsed base object

### Phase 2: Parser Enhancement (30 min)

**File:** [`lib/pubid_new/ieee/parser.rb`](lib/pubid_new/ieee/parser.rb:1)

**Add corrigendum_identifier rule** (before main identifier rule, around line 500):

```ruby
# Corrigendum identifier with recursive base parsing
rule(:corrigendum_identifier) do
  # Capture base identifier as string (everything before /Cor)
  (
    publisher.maybe >>
    space.maybe >>
    (type_word.as(:type) >> space?).maybe >>
    number >>
    (part_subpart_year | edition).maybe
  ).as(:base_parts) >>
  
  # Corrigendum portion
  (slash | dash | space) >>
  str("Cor") >>
  (dash | dot | space).maybe >>
  digits.as(:cor_number) >>
  ((dash | str(":") | space) >> year_digits.as(:cor_year)).maybe >>
  
  # Optional parenthetical
  parenthetical.maybe
end
```

**Update main identifier rule** (add corrigendum_identifier before existing rules):
```ruby
rule(:identifier) do
  aiee_identifier |
  ire_identifier |
  nesc_identifier |
  corrigendum_identifier |  # NEW: Try corrigendum first
  joint_development_ieee_format |
  # ... rest
end
```

### Phase 3: Builder Recursive Parsing (30 min)

**File:** [`lib/pubid_new/ieee/builder.rb`](lib/pubid_new/ieee/builder.rb:1)

**Add method to build corrigendum** (around line 200, before determine_identifier_class):

```ruby
# Build corrigendum supplement with recursive base parsing
# @param parsed_hash [Hash] parsed data with base and supplement info
# @return [Identifiers::Corrigendum] corrigendum identifier
def build_corrigendum_supplement(parsed_hash)
  # Reconstruct base identifier string from captured parts
  base_parts = []
  
  if parsed_hash[:base_parts]
    # Extract each component from base_parts hash
    base_data = parsed_hash[:base_parts]
    
    base_parts << extract_value(base_data[:publisher]) if base_data[:publisher]
    base_parts << extract_value(base_data[:type]) if base_data[:type]
    base_parts << extract_value(base_data[:number]) if base_data[:number]
    
    # Handle year if present
    if base_data[:year]
      base_parts.last << "-#{extract_value(base_data[:year])}"
    end
  end
  
  base_string = base_parts.join(" ")
  
  # Recursively parse base identifier
  base_identifier = Identifiers::Base.parse(base_string)
  
  # Create Corrigendum with parsed base
  require_relative "identifiers/corrigendum"
  Identifiers::Corrigendum.new(
    base_identifier: base_identifier,
    cor_number: extract_value(parsed_hash[:cor_number]),
    cor_year: extract_value(parsed_hash[:cor_year])
  )
end
```

**Update `build_single_identifier`** (add check at beginning):

```ruby
def build_single_identifier(parsed)
  parsed_hash = parsed.is_a?(Array) ? merge_parsed_array(parsed) : parsed
  
  # Handle corrigendum supplements (check for base_parts + cor_number)
  if parsed_hash[:base_parts] && parsed_hash[:cor_number]
    return build_corrigendum_supplement(parsed_hash)
  end
  
  # ... rest of existing logic
end
```

### Phase 4: Testing & Validation (15 min)

**Run corrigendum tests:**
```bash
bundle exec rspec spec/pubid_new/ieee/identifiers/corrigendum_spec.rb --format documentation
```

**Expected:** 7/7 tests passing

**Verify no regressions:**
```bash
bundle exec rspec spec/pubid_new/ieee/ --format progress
```

**Test round-trip manually:**
```ruby
cor = PubidNew::Ieee.parse("IEEE Std 535-2013/Cor. 1-2017")
puts cor.class.name  # Should be Corrigendum
puts cor.base_identifier.to_s  # Should be "IEEE Std 535-2013"
puts cor.to_s  # Should be "IEEE Std 535-2013/Cor. 1-2017"
```

---

## Critical Reminders

### Architecture Principles (NEVER VIOLATE)

1. **Recursive Parsing:** Base identifier must be parsed as full object
2. **MODEL-DRIVEN:** Corrigendum wraps Base, doesn't inherit attributes
3. **Three-layer Separation:** Parser captures, Builder constructs, Identifier renders
4. **No Hardcoding:** Use recursive parsing, not string manipulation

### Reference Pattern

**ISO/IEC Amendment does this correctly:**
```ruby
# Parser splits base from supplement
# Builder recursively parses base
# Amendment wraps parsed base object
```

Apply exact same pattern to IEEE Corrigendum.

### Common Pitfalls to Avoid

❌ **DON'T parse in Builder:**
```ruby
# Wrong approach
base_string = "#{code}-#{year}"
```

✅ **DO recursive parsing:**
```ruby
# Right approach
base_identifier = Identifiers::Base.parse(base_string)
```

---

## Success Metrics

### Minimum (80%)
- ✅ Parser splits base correctly
- ✅ Builder constructs Corrigendum object
- ✅ 5/7 tests passing
- ✅ No regressions

### Target (100%)
- ✅ All parser patterns working
- ✅ 7/7 tests passing
- ✅ Perfect round-trip fidelity
- ✅ Clean implementation

---

## Files to Read

**Before starting:**
1. [`docs/SESSION-140-CONTINUATION-PLAN.md`](docs/SESSION-140-CONTINUATION-PLAN.md:1) - Complete plan
2. [`.kilocode/rules/memory-bank/context.md`](.kilocode/rules/memory-bank/context.md:1) - Current status
3. [`.kilocode/rules/memory-bank/architecture.md`](.kilocode/rules/memory-bank/architecture.md:1) - Architecture principles

**For implementation:**
1. `lib/pubid_new/iso/parser.rb` - Amendment pattern reference
2. `lib/pubid_new/iso/builder.rb` - Recursive parsing reference
3. `lib/pubid_new/ieee/identifiers/corrigendum.rb` - Current class
4. `spec/pubid_new/ieee/identifiers/corrigendum_spec.rb` - Tests to pass

---

## Timeline

| Phase | Focus | Time | Checkpoint |
|-------|-------|------|------------|
| 1 | Study references | 15 min | Understand pattern |
| 2 | Parser enhancement | 30 min | Base splitting works |
| 3 | Builder recursive parsing | 30 min | Object construction works |
| 4 | Testing & validation | 15 min | 7/7 tests passing |
| **Total** | **All work** | **90 min** | **Complete** |

---

## Expected Outcome

**After Session 140:**
- IEEE Corrigendum fully functional
- 7/7 corrigendum tests passing
- Architectural consistency with ISO/IEC
- Production-ready implementation

**Then:**
- Either Session 141 for IEEE 90%+ enhancement
- OR mark project COMPLETE (recommended)

---

**Created:** 2025-12-14
**Status:** Ready for execution
**Priority:** OPTIONAL but recommended for architectural completeness