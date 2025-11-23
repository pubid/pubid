# V1 to V2 API Mapping

**Purpose:** Reference guide for migrating test files from PubID V1 API to V2 API.

**Date:** 2025-11-23  
**Status:** Complete

---

## Overview

PubID V2 uses a MODEL-DRIVEN architecture with proper OOP encapsulation. This means:

- **Publisher is an object** with `publisher` and `copublisher` attributes
- **Components are Lutaml::Model classes** with proper serialization
- **Type and stage combined** into `TypedStage` objects
- **Arrays instead of single values** for abbreviations
- **Nil-safe access** required for optional components

---

## Parse Method

### Parsing Identifiers

**V1:**
```ruby
# V1 used class-specific parsing
Amendment.parse("ISO 8601:2019/Amd 1:2020")
InternationalStandard.parse("ISO 8601:2019")
TechnicalReport.parse("ISO/TR 12345:2020")
```

**V2:**
```ruby
# V2 uses unified scheme-based parsing
PubidNew::Iso.parse("ISO 8601:2019/Amd 1:2020")  # Returns Amendment instance
PubidNew::Iso.parse("ISO 8601:2019")              # Returns InternationalStandard instance
PubidNew::Iso.parse("ISO/TR 12345:2020")         # Returns TechnicalReport instance
```

**Migration:**
- Replace `described_class.parse` with `PubidNew::Iso.parse`
- V2 automatically selects the correct identifier class
- Type checking works via `be_a(PubidNew::Iso::Identifiers::Amendment)`

---

## Publisher Access

### Publisher Name

**V1:**
```ruby
identifier.publisher.body  # => "ISO"
```

**V2:**
```ruby
identifier.publisher.publisher  # => "ISO"
# Or use the to_s method:
identifier.publisher.to_s      # => "ISO" or "ISO/IEC" with copublishers
```

**Migration:**
- Replace `.publisher.body` with `.publisher.publisher`
- Or use `.publisher.to_s` for string representation

### Copublishers

**V1:**
```ruby
identifier.copublishers.first.body  # => "IEC"
identifier.copublishers[1].body     # => "IEEE"
```

**V2:**
```ruby
identifier.publisher.copublisher.first  # => "IEC"
identifier.publisher.copublisher[1]     # => "IEEE"
# Or check the full string:
identifier.publisher.to_s               # => "ISO/IEC/IEEE"
```

**Migration:**
- Replace `.copublishers.first.body` with `.publisher.copublisher.first`
- Copublishers are now nested under `publisher` object
- Access as an array of strings

---

## Number and Part

### Document Number

**V1:**
```ruby
identifier.number  # => "8601" (direct string)
```

**V2:**
```ruby
identifier.number.value  # => "8601" (Code component)
```

**Migration:**
- Replace `.number` with `.number.value`
- Number is now a `Code` component object

### Part Number

**V1:**
```ruby
identifier.part  # => "1" (direct string or number)
```

**V2:**
```ruby
identifier.part.value  # => "1" (Code component)
```

**Migration:**
- Replace `.part` with `.part.value`
- Part is now a `Code` component object

---

## Date/Year

### Publication Year

**V1:**
```ruby
identifier.year  # => 2019 (integer)
```

**V2:**
```ruby
identifier.date.year  # => 2019 (integer from Date component)
```

**Migration:**
- Replace `.year` with `.date.year`
- Date is now a `Date` component object

---

## Type and Stage

### Document Type

**V1:**
```ruby
identifier.type.type_code  # => "TR" for Technical Report
```

**V2 (for documents with typed stages):**
```ruby
identifier.typed_stage.type_code  # => "TR"
```

**V2 (for simple documents):**
```ruby
# InternationalStandard doesn't have a type_code
# The class itself indicates the type
identifier.class  # => PubidNew::Iso::Identifiers::TechnicalReport
```

**Migration:**
- Replace `.type.type_code` with `.typed_stage.type_code`
- Check if the identifier has a `typed_stage` (may be nil)
- For basic standards, type is implicit in the class

### Document Stage

**V1:**
```ruby
identifier.stage.stage_code  # => "DIS" for Draft International Standard
```

**V2:**
```ruby
identifier.typed_stage.stage_code  # => "DIS"
```

**Migration:**
- Replace `.stage.stage_code` with `.typed_stage.stage_code`
- Stage is now part of `TypedStage` component

### TypedStage Abbreviation

**V1:**
```ruby
identifier.typed_stage.abbreviation  # => "FDAM" (single string)
```

**V2:**
```ruby
identifier.typed_stage.abbr.first  # => "FDAM" (array of strings)
# Or check if it's in the array:
identifier.typed_stage.abbr.include?("FDAM")  # => true
```

**Migration:**
- Replace `.typed_stage.abbreviation` with `.typed_stage.abbr.first`
- `abbr` is now an array (a TypedStage can have multiple abbreviations)

---

## Language

### Language Code

**V1:**
```ruby
identifier.language  # => "E" (direct string)
```

**V2:**
```ruby
identifier.language.original_code  # => "E" (Language component)
```

**Migration:**
- Replace `.language` with `.language.original_code`
- Language is now a `Language` component object

---

## Supplements (Amendments, Corrigenda)

### Base Identifier

**V1:**
```ruby
amendment.base  # Base identifier object
amendment.base.number  # => "8601"
```

**V2:**
```ruby
amendment.base_identifier  # Base identifier object
amendment.base_identifier.number.value  # => "8601"
```

**Migration:**
- Replace `.base` with `.base_identifier`
- Then apply nested mappings for the base's attributes

### Amendment/Corrigendum Number

**V1:**
```ruby
amendment.number  # => 1 (integer)
```

**V2:**
```ruby
amendment.number.value  # => "1" (Code component, string)
```

**Migration:**
- Replace `.number` with `.number.value`
- Note: V2 uses strings for consistency

---

## Nil Safety

### Checking for Optional Components

Many components in V2 are optional. Always check for nil before accessing nested attributes.

**Pattern:**
```ruby
# V2: Safe access
if identifier.typed_stage
  expect(identifier.typed_stage.abbr.first).to eq("TR")
end

# Or use safe navigation:
expect(identifier.typed_stage&.abbr&.first).to eq("TR")

# Or check in the expectation:
expect(identifier.typed_stage).not_to be_nil
expect(identifier.typed_stage.abbr.first).to eq("TR")
```

**Common optional components:**
- `typed_stage` (not present on simple standards)
- `part` (only multi-part documents)
- `edition` (not always specified)
- `language` (optional language specification)

---

## URN Generation

### URN Method

**V1:**
```ruby
identifier.urn  # => "urn:iso:std:iso:8601:ed-1:v1"
```

**V2:**
```ruby
# URN generation may not be implemented yet in V2
# Check if the method exists before testing:
if identifier.respond_to?(:urn)
  identifier.urn  # => "urn:iso:std:iso:8601:ed-1:v1"
else
  pending "URN generation not yet implemented in V2"
end
```

**Migration:**
- Mark URN tests as `pending` if not implemented
- Focus on `to_s` for string representation

---

## String Rendering

### To String

**V1:**
```ruby
identifier.to_s  # => "ISO 8601:2019"
identifier.to_s(format: :ref_num_short)  # Various formats
```

**V2:**
```ruby
identifier.to_s  # => "ISO 8601:2019"
# Format parameter may not be implemented yet
```

**Migration:**
- Basic `to_s` works the same
- Format parameters may not be implemented yet
- Test primarily without format parameters

---

## Identifier Creation

### Direct Construction

**V1:**
```ruby
# V1 used Identifier.create factory
base = Pubid::Iso::Identifier.create(number: "123", year: 1999)
amendment = Pubid::Iso::Identifier::Amendment.new(number: 1, base: base)
```

**V2:**
```ruby
# V2 uses direct instantiation
base = PubidNew::Iso::Identifiers::InternationalStandard.new(
  number: PubidNew::Iso::Components::Code.new(value: "123"),
  date: PubidNew::Iso::Components::Date.new(year: 1999),
  publisher: PubidNew::Iso::Components::Publisher.new(publisher: "ISO")
)
amendment = PubidNew::Iso::Identifiers::Amendment.new(
  number: PubidNew::Iso::Components::Code.new(value: "1"),
  base_identifier: base
)
```

**Migration:**
- For parsing tests: Use `PubidNew::Iso.parse(string)` instead
- For construction tests: Create proper component objects
- Most tests should use parsing, not direct construction

---

## Quick Reference Table

| V1 API | V2 API | Type |
|--------|--------|------|
| `ClassName.parse(str)` | `PubidNew::Iso.parse(str)` | Parsing |
| `.publisher.body` | `.publisher.publisher` | Publisher |
| `.copublishers.first.body` | `.publisher.copublisher.first` | Copublisher |
| `.number` | `.number.value` | Number |
| `.part` | `.part.value` | Part |
| `.year` | `.date.year` | Year |
| `.type.type_code` | `.typed_stage.type_code` | Type |
| `.stage.stage_code` | `.typed_stage.stage_code` | Stage |
| `.typed_stage.abbreviation` | `.typed_stage.abbr.first` | TypedStage |
| `.language` | `.language.original_code` | Language |
| `.base` | `.base_identifier` | Base document |
| `.urn` | `.urn` (if implemented) | URN |
| `.to_s` | `.to_s` | String |

---

## Common Migration Patterns

### Pattern 1: Parse and Check Type

**V1:**
```ruby
result = Amendment.parse("ISO 8601:2019/Amd 1:2020")
expect(result).to be_a(Amendment)
```

**V2:**
```ruby
result = PubidNew::Iso.parse("ISO 8601:2019/Amd 1:2020")
expect(result).to be_a(PubidNew::Iso::Identifiers::Amendment)
```

### Pattern 2: Access Nested Attributes

**V1:**
```ruby
expect(identifier.publisher.body).to eq("ISO")
expect(identifier.number).to eq("8601")
expect(identifier.year).to eq(2019)
```

**V2:**
```ruby
expect(identifier.publisher.publisher).to eq("ISO")
expect(identifier.number.value).to eq("8601")
expect(identifier.date.year).to eq(2019)
```

### Pattern 3: Check Optional Components

**V1:**
```ruby
expect(identifier.part).to eq("1")
```

**V2:**
```ruby
expect(identifier.part).not_to be_nil
expect(identifier.part.value).to eq("1")
```

### Pattern 4: Round-Trip Test

**V1:**
```ruby
input = "ISO 8601:2019"
result = InternationalStandard.parse(input)
expect(result.to_s).to eq(input)
```

**V2:**
```ruby
input = "ISO 8601:2019"
result = PubidNew::Iso.parse(input)
expect(result.to_s).to eq(input)
```

---

## sed/awk Commands for Bulk Migration

These commands can be used to automate common replacements:

```bash
# Parse method
sed -i '' 's/described_class\.parse/PubidNew::Iso.parse/g' file.rb

# Publisher
sed -i '' 's/\.publisher\.body/.publisher.publisher/g' file.rb
sed -i '' 's/\.copublishers\.first\.body/.publisher.copublisher.first/g' file.rb

# Number and part
sed -i '' 's/\.number)/.number.value)/g' file.rb
sed -i '' 's/\.part)/.part.value)/g' file.rb

# Year/Date
sed -i '' 's/\.year)/.date.year)/g' file.rb

# Type/Stage
sed -i '' 's/\.type\.type_code/.typed_stage.type_code/g' file.rb
sed -i '' 's/\.stage\.stage_code/.typed_stage.stage_code/g' file.rb
sed -i '' 's/\.typed_stage\.abbreviation/.typed_stage.abbr.first/g' file.rb

# Language
sed -i '' 's/\.language)/.language.original_code)/g' file.rb

# Base identifier
sed -i '' 's/\.base/.base_identifier/g' file.rb
```

**Note:** These are starting points. Manual review is REQUIRED after bulk replacement.

---

## Marking Unsupported Patterns

When a test fails due to parser limitations (not API differences):

```ruby
# Change from 'it' to 'xit' (disabled test)
xit "parses complex pattern" do
  # Test that fails due to parser gap
end

# Add a TODO comment
xit "parses ISO 8601:2019 ED1(E)" do
  # TODO: Parser doesn't support edition+language suffix yet
  # See docs/PARSER_GAPS.md #ISO-EDITION-LANG
end
```

---

## Testing Strategy

### File-by-File Approach

1. **Backup the file:**
   ```bash
   cp spec/pubid_new/iso/identifiers/data_spec.rb \
      old_specs/pubid/iso/v2_before_migration/
   ```

2. **Apply bulk replacements:**
   ```bash
   sed -i '' 's/described_class\.parse/PubidNew::Iso.parse/g' \
     spec/pubid_new/iso/identifiers/data_spec.rb
   sed -i '' 's/\.publisher\.body/.publisher.publisher/g' \
     spec/pubid_new/iso/identifiers/data_spec.rb
   # ... more replacements
   ```

3. **Run the tests:**
   ```bash
   bundle exec rspec spec/pubid_new/iso/identifiers/data_spec.rb
   ```

4. **Fix remaining issues manually:**
   - Check for nil components
   - Mark parser gaps as `xit`
   - Adjust complex expectations

5. **Verify core tests still pass:**
   ```bash
   bundle exec rspec spec/pubid_new/iso/identifier_spec.rb
   ```

---

## Common Pitfalls

### Pitfall 1: String vs Integer
V2 uses strings for numbers consistently:
```ruby
# V1: Mixed types
identifier.number  # => "8601" or 8601

# V2: Always strings
identifier.number.value  # => "8601" (always string)
```

### Pitfall 2: Nil Components
V2 components can be nil:
```ruby
# WRONG: Will error if typed_stage is nil
expect(identifier.typed_stage.abbr.first).to eq("TR")

# RIGHT: Check nil first
expect(identifier.typed_stage).not_to be_nil
expect(identifier.typed_stage.abbr.first).to eq("TR")
```

### Pitfall 3: Array Attributes
Some V2 attributes are arrays:
```ruby
# V1: Single string
identifier.typed_stage.abbreviation  # => "FDAM"

# V2: Array of strings
identifier.typed_stage.abbr  # => ["FDAM"]
identifier.typed_stage.abbr.first  # => "FDAM"
```

### Pitfall 4: Copublisher Structure
Copublishers moved into publisher:
```ruby
# V1: Separate array
identifier.copublishers  # => [#<Publisher body="IEC">]

# V2: Nested in publisher
identifier.publisher.copublisher  # => ["IEC"]
```

---

## Questions & Answers

**Q: Why does V2 use `.number.value` instead of `.number`?**  
A: V2 uses proper component objects (Code, Date, Language) rather than raw strings. This provides better type safety and allows for future extensions.

**Q: What if a test expects a method that doesn't exist in V2?**  
A: Mark it as `pending` with a TODO comment. Document the gap in `docs/PARSER_GAPS.md`.

**Q: Should I fix tests that create identifiers directly?**  
A: For now, focus on parse tests. Direct construction tests can be updated later or marked pending.

**Q: What about URN tests?**  
A: Mark as pending if URN generation isn't implemented yet. Focus on string rendering (`to_s`).

**Q: How do I know if a parser pattern is supported?**  
A: Run the test. If it fails with a parse error (not an API error), mark as `xit` and document the gap.

---

## See Also

- [`V1_TO_V2_MIGRATION_PLAN.md`](../V1_TO_V2_MIGRATION_PLAN.md) - Overall migration strategy
- [`docs/PARSER_GAPS.md`](PARSER_GAPS.md) - Known unsupported patterns (created in Phase 5)
- [`lib/pubid_new/iso/components/`](../lib/pubid_new/iso/components/) - Component implementations
- [`lib/pubid_new/iso/identifiers/`](../lib/pubid_new/iso/identifiers/) - Identifier classes

---

**Last Updated:** 2025-11-23  
**Applies To:** ISO flavor (extend for other flavors)  
**Status:** Complete and ready for use
