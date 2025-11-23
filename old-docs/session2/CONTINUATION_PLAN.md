# PubID V2 - ISO Parser Continuation Plan

**Last Updated:** 2025-11-22 17:41 HKT
**Current Status:** 70% Complete (14/20 tests passing)
**Remaining Work:** 6 tests, estimated 2-3 hours

---

## Quick Start for Next Session

```bash
cd /Users/mulgogi/src/mn/pubid

# Check current status
bundle exec rspec spec/pubid_new/iso/identifier_spec.rb --format progress

# Run specific failing test
bundle exec rspec spec/pubid_new/iso/identifier_spec.rb:64 --format documentation
```

---

## Completed Work (70%)

### 1. Core Architecture ✅
- Fixed array-to-hash conversion in builder for parser output
- Migrated all identifier classes to inherit from `::PubidNew::Identifier`
- Fixed component attribute usage (Type.abbr, Language.original_code)

### 2. Publisher & Copublisher System ✅
- Single copublisher patterns working (ISO/IEC, ISO/SAE)
- Publisher component properly handles copublisher arrays
- All basic copublisher tests passing

### 3. Type Display System ✅
- Type component using correct `abbr` attribute
- SingleIdentifier and Base classes display types correctly
- All type tests passing (TR, TS, PAS, DATA, TTA, R, ISP, DIR)

### 4. Supplement System ✅
- Default typed_stage lookup implemented
- Supplements display correct abbreviations (Amd, Cor, Suppl, Ext)
- Spacing issues resolved in supplement output

---

## Remaining Work (30%)

### Phase 1: Fix Multiple Copublishers (Priority: HIGH)

**Affected Tests:** 2
- `ISO/IEC/IEEE 8802-21:2018/Cor 1:2018` - outputs "ISO/IEEE" missing "IEC"
- `ISO/IEC/IEEE 8802-3:2021/FDAM 1` - parser fails

**Root Cause:** Publisher component may only handle single copublisher

**Solution Approach:**
1. Check [`Publisher`](lib/pubid_new/iso/components/publisher.rb) component structure
2. Verify parser creates proper data structure for 2+ copublishers
3. Update [`Publisher.to_s`](lib/pubid_new/iso/components/publisher.rb) to handle multiple copublishers
4. Test pattern: "ISO/IEC/IEEE" should output all three

**Files to Modify:**
- `lib/pubid_new/iso/components/publisher.rb`
- Possibly `lib/pubid_new/iso/parser.rb` if parser structure is wrong

**Test Command:**
```bash
bundle exec rspec spec/pubid_new/iso/identifier_spec.rb:64 -fd
```

---

### Phase 2: Fix FDAM Parser Pattern (Priority: HIGH)

**Affected Tests:** 1
- `ISO/IEC/IEEE 8802-3:2021/FDAM 1` - parser fails at char 25

**Root Cause:** Parser supplement rule doesn't handle typed_stage without supplement_type

**Current Parser Issue:**
```ruby
# Current rule requires both typed_stage AND supplement_type
rule(:supplement) do
  supplement_type >> typed_stage.maybe >> ...
end
```

**Solution:**
```ruby
# Fix to allow typed_stage alone (implies Amd type)
rule(:supplement) do
  slash >> (
    # Pattern 1: Typed stage alone (FDAM, PDAM, etc.)
    (typed_stage.as(:typed_stage) >> space >> digits.as(:supplement_number) >> year.maybe) |
    # Pattern 2: Supplement type with optional stage
    (supplement_type >> (space >> digits).maybe.as(:supplement_number) >> year.maybe)
  )
end
```

**Files to Modify:**
- `lib/pubid_new/iso/parser.rb`

**Test Command:**
```bash
bundle exec rspec spec/pubid_new/iso/identifier_spec.rb:56 -fd
```

---

### Phase 3: Fix IWA Typed Stage (Priority: MEDIUM)

**Affected Tests:** 1
- `IWA 14-1:2013` - nil typed_stage.abbreviation call

**Root Cause:** InternationalWorkshopAgreement calls typed_stage.abbreviation without nil check

**Solution:** Apply same pattern as SupplementIdentifier
```ruby
# In lib/pubid_new/iso/identifiers/international_workshop_agreement.rb
def to_s(...)
  # Use typed_stage if present, else use class default
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

**Files to Modify:**
- `lib/pubid_new/iso/identifiers/international_workshop_agreement.rb`

**Test Command:**
```bash
bundle exec rspec spec/pubid_new/iso/identifier_spec.rb:128 -fd
```

---

### Phase 4: Fix Directives Issues (Priority: MEDIUM)

**Affected Tests:** 2
- `ISO/IEC DIR 1:2022` - Publisher.body method doesn't exist
- `ISO/IEC DIR 1 ISO SUP:2022` - Wrong class (Directives instead of DirectivesSupplement)

**Issue 1: Publisher.body Method**

Root cause: Directives class calls non-existent `publisher.body` method

Solution: Check what `body` should be - likely the main publisher name
```ruby
# In lib/pubid_new/iso/identifiers/directives.rb
def publisher_portion(...)
  # Replace publisher.body with publisher.publisher or appropriate method
  result = publisher.to_s  # or publisher.publisher
  # ... rest of method
end
```

**Issue 2: DirectivesSupplement Class Selection**

Root cause: Parser or builder not recognizing DIR SUP pattern

Solution: Update parser to match DIR + SUP pattern, or update builder logic
```ruby
# In builder.rb
def determine_identifier_class(type_str)
  case type_str&.upcase
  when "DIR"
    # Check if it's a supplement to directives
    if data[:sup_type] || data[:sup_publisher]
      Identifiers::DirectivesSupplement
    else
      Identifiers::Directives
    end
  # ... rest
end
```

**Files to Modify:**
- `lib/pubid_new/iso/identifiers/directives.rb`
- `lib/pubid_new/iso/identifiers/directives_supplement.rb`
- `lib/pubid_new/iso/builder.rb`
- Possibly `lib/pubid_new/iso/parser.rb`

**Test Commands:**
```bash
bundle exec rspec spec/pubid_new/iso/identifier_spec.rb:144 -fd
bundle exec rspec spec/pubid_new/iso/identifier_spec.rb:152 -fd
```

---

### Phase 5: Multi-Level Supplements (Priority: LOW)

**Affected Tests:** 1
- `ISO/IEC 13818-1:2015/Amd 3:2016/Cor 1:2017` - Returns Amendment instead of Corrigendum

**Root Cause:** Builder only handles first supplement, ignores nested supplements

**Solution:** Implement recursive supplement building
```ruby
# In builder.rb
def build_supplement_identifier(data)
  # Build base
  base_data = data[:base] || data
  base_identifier = build(base_data)

  # Handle all supplements recursively
  data[:supplements].reduce(base_identifier) do |base, supp_data|
    # Build supplement with base as its base_identifier
    build_single_supplement(base, supp_data)
  end
end

def build_single_supplement(base, supplement_data)
  # Extract and build single supplement
  # ... existing logic
end
```

**Files to Modify:**
- `lib/pubid_new/iso/builder.rb`

**Test Command:**
```bash
bundle exec rspec spec/pubid_new/iso/identifier_spec.rb:72 -fd
```

---

## Documentation Updates Required

### 1. Update README.adoc

Add section describing ISO parser architecture:
```adoc
== ISO Identifier Architecture

=== Overview
The ISO parser implements a model-driven architecture with 18 specialized identifier classes.

=== Class Hierarchy
[source]
----
::PubidNew::Identifier (parent)
  └── Iso::SingleIdentifier
      └── Iso::SupplementIdentifier
          ├── Amendment
          ├── Corrigendum
          ├── Supplement
          └── Extract
  └── Iso::Identifiers::Base
      ├── InternationalStandard
      ├── Guide
      ├── TechnicalReport
      └── ... (15 total)
----

=== Components
- Publisher: Handles single or multiple copublishers
- Type: Resource type with abbreviation
- Code: Number and part components
- Date: Publication date
- Language: Language codes with original format
- TypedStage: Stage with type-specific abbreviation
```

### 2. Create docs/architecture/iso-parser.adoc

Detailed architecture documentation including:
- Parser grammar rules
- Builder routing logic
- Component structure
- Identifier class responsibilities
- Extension points for new types

### 3. Update IMPLEMENTATION_STATUS.md

Current metrics and completion status.

---

## Architectural Principles to Maintain

### 1. Model-Driven Design
- Never manipulate serialization formats directly
- Always work with model objects
- Use polymorphism for type-specific behavior

### 2. MECE (Mutually Exclusive, Collectively Exhaustive)
- Each identifier class handles distinct patterns
- No overlap in responsibilities
- All patterns covered

### 3. Separation of Concerns
- Parser: Grammar and data extraction
- Builder: Model construction and routing
- Identifier: Representation and rendering
- Components: Reusable data structures

### 4. Open/Closed Principle
- New identifier types by adding classes, not modifying existing
- Extension through inheritance and composition
- Type registry pattern for discoverability

### 5. Single Responsibility
- Each class has one clear purpose
- Methods focused on single task
- No god objects or utility classes

---

## Testing Strategy

### Unit Tests Required
Each identifier class needs comprehensive specs:
- `spec/pubid_new/iso/identifiers/amendment_spec.rb`
- `spec/pubid_new/iso/identifiers/corrigendum_spec.rb`
- etc.

### Integration Tests
- `spec/pubid_new/iso/identifier_spec.rb` (current)
- Parser-to-builder integration
- Component collaboration

### Test Coverage Goals
- 100% of identifier classes
- 100% of public methods
- All edge cases and error paths

---

## Performance Considerations

### Optimization Opportunities
1. **TypedStage Lookup:** Cache typed_stage lookups by abbreviation
2. **Component Creation:** Pool frequently used components
3. **Parser Memoization:** Cache parse results for repeated identifiers

### Profiling Points
- Parser grammar matching
- Builder class selection
- Component to_s methods

---

## Future Enhancements

### 1. Language Support
- Full French/Russian identifier rendering
- Language-dependent type names
- Copublisher name translation (IEC ↔ CEI)

### 2. Validation
- Validate identifier structure before parsing
- Check valid combinations (type + stage)
- Verify harmonized stage codes

### 3. Serialization
- XML/JSON output formats
- URN generation
- Structured data export

---

## Common Pitfalls to Avoid

1. **Don't modify parent classes** - Extend through inheritance
2. **Don't use hardcoded values** - Use constants and registries
3. **Don't skip nil checks** - All optional attributes must be guarded
4. **Don't break tests to make them pass** - Fix behavior, not thresholds
5. **Don't create utility methods** - Use proper OOP encapsulation

---

## Completion Checklist

### Code
- [ ] All 20 identifier tests passing
- [ ] Parser tests updated for new patterns
- [ ] Component tests for Publisher, Type, Date, Language
- [ ] Builder unit tests
- [ ] No debug code remaining
- [ ] All methods documented

### Documentation
- [ ] README.adoc updated with ISO section
- [ ] Architecture documentation created
- [ ] IMPLEMENTATION_STATUS.md current
- [ ] Old documentation moved to old-docs/
- [ ] Code comments for complex logic

### Quality
- [ ] Rubocop passes without warnings
- [ ] No unused requires or variables
- [ ] Consistent naming conventions
- [ ] MECE and OOP principles followed
- [ ] Performance acceptable (< 100ms per parse)

---

## Estimated Timeline

- **Session 1 (completed):** Core fixes - 3 hours ✅
- **Session 2 (next):** Remaining 6 tests - 2-3 hours
- **Session 3:** Unit tests and documentation - 2 hours
- **Session 4:** Review, polish, performance - 1 hour

**Total remaining:** 5-6 hours to completion

---

## Session Handoff Notes

### Key Decisions Made
1. Supplements default to published typed_stage if none provided
2. Type component uses `abbr` attribute, not `value`
3. Language uses `original_code` to preserve parsed format
4. Builder converts all array-of-hashes to single hash

### Known Issues
1. IEEE multiple copublisher pattern not fully working
2. Parser supplement rule needs typed_stage support
3. IWA and Directives need same nil-safety as SupplementIdentifier

### Files with Changes
- `lib/pubid_new/iso/builder.rb` - Core conversion and routing logic
- `lib/pubid_new/iso/identifiers/base.rb` - Type and language rendering
- `lib/pubid_new/iso/identifiers/guide.rb` - Modernized attributes
- `lib/pubid_new/iso/single_identifier.rb` - Type display in publisher_portion
- `lib/pubid_new/iso/supplement_identifier.rb` - Default typed_stage logic

---

**Next Steps:** Start with Phase 1 (IEEE copublisher), then Phase 2 (FDAM parser).