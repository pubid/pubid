# IEEE Relationship Parser Enhancement Design

**Created:** 2025-12-11 (Session 122)
**Status:** Parser Design Phase

---

## Overview

The parser enhancement must handle relationship identifiers while preserving existing functionality. This is a **high-risk change** that requires careful design to avoid regressions.

---

## Current State Analysis

### Existing Parenthetical Handling

**Current rule in parser.rb:**
```ruby
rule(:additional_parameters) do
  (space.maybe >> str("(") >>
   match("[^)]").repeat(1).as(:parameters) >>
   str(")").maybe).as(:parameters)
end
```

**Problem:**
- Captures ALL parenthetical content as raw string
- No structured parsing
- Builder stores as `parenthetical_content` attribute
- Works but loses semantic information

**Our Goal:**
- Parse relationship content structurally
- Preserve raw fallback for non-relationship parentheticals
- Backward compatible

---

## Parser Enhancement Strategy

### Strategy 1: Specific Before Generic (CHOSEN)

**Approach:**
- Add specific `relationship_clause` rule
- Keep `additional_parameters` as fallback
- Use alternation: `relationship_clause | additional_parameters`

**Benefits:**
- ✅ Backward compatible
- ✅ No breaking changes
- ✅ Structured data for relationships
- ✅ Fallback preserves unknown patterns

**Implementation:**
```ruby
rule(:parenthetical) do
  relationship_clause | additional_parameters
end
```

### Strategy 2: Complete Rewrite (REJECTED)

**Approach:**
- Replace `additional_parameters` entirely
- Parse all parenthetical content structurally

**Rejected because:**
- ❌ High risk of breaking existing patterns
- ❌ May not handle all edge cases
- ❌ No graceful degradation

---

## Relationship Clause Design

### Core Structure

```ruby
rule(:relationship_clause) do
  str("(") >>
  relationship_content >>
  (str(" / ") >> relationship_content).repeat.as(:additional_rels).maybe >>
  str(")")
end

rule(:relationship_content) do
  relationship_type >>
  space >>
  identifier_list >>
  as_amended_by_clause.maybe
end
```

### Relationship Type Detection

```ruby
rule(:rel_revision_of) do
  (str("Revision of ") | str("Revison of ")).as(:type)  # Handle typo
end

rule(:rel_amendment_to) do
  str("Amendment to ").as(:type)
end

rule(:rel_corrigendum_to) do
  str("Corrigendum to ").as(:type)
end

rule(:rel_incorporates) do
  (str("incorporates ") | str("Incorporating ")).as(:type)
end

rule(:rel_adoption_of) do
  str("Adoption of ").as(:type)
end

rule(:rel_supplement_to) do
  str("Supplement to ").as(:type)
end

rule(:rel_draft_amendment) do
  (str("Draft Amendment to ") | str("DRAFT Amendment to ")).as(:type)
end

rule(:rel_draft_revision) do
  str("Draft Revision of ").as(:type)
end

rule(:relationship_type) do
  (
    rel_revision_of.as(:revision_of) |
    rel_amendment_to.as(:amendment_to) |
    rel_corrigendum_to.as(:corrigendum_to) |
    rel_incorporates.as(:incorporates) |
    rel_adoption_of.as(:adoption_of) |
    rel_supplement_to.as(:supplement_to) |
    rel_draft_amendment.as(:draft_amendment_to) |
    rel_draft_revision.as(:draft_revision_of)
  )
end
```

---

## Identifier List Parsing

### Challenge: Recursive Parsing

**Problem:**
- Identifier list contains full IEEE identifiers
- Each identifier may be complex (e.g., "IEEE Std 802.11k-2008")
- Need to parse recursively
- Can't use simple `match("[^,]")` pattern

**Solution: Capture and Parse in Builder**

**Parser Phase:**
```ruby
rule(:identifier_list) do
  # Capture identifier strings, parse later in builder
  identifier_string.as(:id) >>
  (separator >> identifier_string.as(:id)).repeat
end

rule(:identifier_string) do
  # Match until we hit a separator or "as amended by" or close paren
  # This is tricky - need to balance complexity
  match("[^,)]").repeat(1)
end

rule(:separator) do
  (str(", and ") | str(" and ") | str(", "))
end
```

**Builder Phase:**
```ruby
def parse_identifier_list(parsed_list)
  # Extract captured strings
  id_strings = extract_identifier_strings(parsed_list)
  
  # Recursively parse each string using Base.parse
  id_strings.map do |id_str|
    # Clean up the string
    cleaned = id_str.strip
    # Remove leading "IEEE Std " if present (may be captured)
    # Actually, keep it - we need full identifier
    
    # Recursively parse
    Identifiers::Base.parse(cleaned)
  end
end
```

**Key Insight:**
- Parser captures identifier strings as text
- Builder does recursive parsing
- Cleaner separation of concerns

---

## "as amended by" Clause

### Pattern

```
(Amendment to IEEE Std 802.1Q-2014 as amended by IEEE Std 802.1Qca-2015, IEEE Std 802.1Qcd-2015)
                                     ^^^^^^^^^^^^^^^
```

### Parser Rule

```ruby
rule(:as_amended_by_clause) do
  str(" as amended by ") >> identifier_list.as(:amendments)
end
```

**Integration:**
```ruby
rule(:relationship_content) do
  relationship_type >>
  space >>
  identifier_list.as(:related_ids) >>
  as_amended_by_clause.maybe
end
```

**Result:**
```ruby
{
  revision_of: { type: "..." },
  related_ids: [...],
  amendments: [...]  # optional
}
```

---

## Multiple Relationships (Slash Separator)

### Pattern

```
(Revision of IEEE Std C95.1-2005 / Incorporates IEEE Std C95.1-2019/Cor 1-2019)
                                 ^
```

### Parser Rule

```ruby
rule(:relationship_clause) do
  str("(") >>
  relationship_content.as(:primary_rel) >>
  (str(" / ") >> relationship_content).repeat.as(:additional_rels).maybe >>
  str(")")
end
```

**Result:**
```ruby
{
  primary_rel: {
    revision_of: { type: "..." },
    related_ids: [...]
  },
  additional_rels: [
    {
      incorporates: { type: "..." },
      related_ids: [...]
    }
  ]
}
```

---

## Integration Point

### Where to Add Relationship Clause

**Current main rule (simplified):**
```ruby
rule(:ieee_identifier) do
  publishers >>
  code >>
  year.maybe >>
  additional_parameters.maybe  # <-- This is where parenthetical goes
end
```

**Updated:**
```ruby
rule(:ieee_identifier) do
  publishers >>
  code >>
  year.maybe >>
  parenthetical.maybe  # <-- Changed
end

rule(:parenthetical) do
  relationship_clause | additional_parameters  # Try specific first
end
```

**Benefits:**
- Relationship patterns parsed structurally
- Other parentheticals still captured
- Backward compatible
- No changes to other rules needed

---

## Edge Cases to Handle

### Case 1: Nested Parentheses

**Input:** `"IEEE Std 802.11, 1999 Edition (Reaff 2003)"`

**Solution:**
- `additional_parameters` fallback handles this
- Not a relationship pattern
- Captured as raw string

### Case 2: Comma in Identifier

**Input:** `"IEEE Std 1003.1, 2013 Edition (incorporates ...)"`

**Challenge:**
- Main identifier has comma before "Edition"
- Relationship also uses comma

**Solution:**
- Parser matches "Edition" pattern separately
- Relationship pattern starts after Edition
- Comma context is clear

### Case 3: Year Ambiguity

**Input:** `"IEEE Std 802.11-2007 as amended by IEEE Std 802.11k-2008"`

**Challenge:**
- Both identifiers have years
- Need to parse each completely

**Solution:**
- Recursive parsing in builder
- Each identifier parsed independently
- Year context preserved

### Case 4: Typos in Relationship Keywords

**Input:** `"(Revison of ...)"`  (missing 'i')

**Solution:**
- Add common typos to alternation
- `str("Revision of ") | str("Revison of ")`

### Case 5: Complex Amendment Chains

**Input:** `"IEEE Std 802.3-2015 as amended by IEEE Std 802.3bw-2015, IEEE Std 802.3by-2016, IEEE Std 802.3bq-2016, IEEE Std 802.3bp-2016"`

**Solution:**
- Identifier list handles any number of items
- Builder parses list recursively
- Each amendment becomes separate identifier object

---

## Testing Strategy

### Unit Tests for Parser

**Test relationship_type detection:**
```ruby
it "parses Revision of keyword" do
  result = Parser.new.relationship_type.parse("Revision of ")
  expect(result).to be_a(Hash)
  expect(result).to have_key(:revision_of)
end
```

**Test identifier_list parsing:**
```ruby
it "parses single identifier" do
  result = Parser.new.identifier_list.parse("IEEE Std 802.11-2007")
  # Parser just captures, builder will parse
end

it "parses comma-separated list" do
  result = Parser.new.identifier_list.parse("IEEE Std X, IEEE Std Y, and IEEE Std Z")
  # Should capture 3 identifier strings
end
```

**Test as_amended_by clause:**
```ruby
it "parses as amended by clause" do
  result = Parser.new.as_amended_by_clause.parse(" as amended by IEEE Std X")
  expect(result[:amendments]).to be_present
end
```

**Test complete relationship_clause:**
```ruby
it "parses complete relationship with amendments" do
  input = "(Amendment to IEEE Std 802.1Q-2014 as amended by IEEE Std 802.1Qca-2015)"
  result = Parser.new.relationship_clause.parse(input)
  # Verify structure
end
```

### Integration Tests

**Test fallback to additional_parameters:**
```ruby
it "falls back for non-relationship parenthetical" do
  input = "IEEE Std 802.11, 1999 Edition (Reaff 2003)"
  parsed = Parser.parse(input)
  # Should use additional_parameters, not relationship_clause
end
```

**Test round-trip:**
```ruby
it "round-trips relationship identifier" do
  input = "IEEE Std 1232-2002 (Revision of IEEE Std 1232-1995)"
  identifier = Identifiers::Base.parse(input)
  expect(identifier.to_s).to eq(input)
end
```

---

## Risk Mitigation

### High-Risk Areas

1. **Identifier list parsing**
   - Risk: Over-matching or under-matching
   - Mitigation: Builder does actual parsing, parser just captures

2. **Comma separator ambiguity**
   - Risk: Confusing identifier commas with list commas
   - Mitigation: Context-aware rules, capture and parse in builder

3. **Regression in existing patterns**
   - Risk: Breaking non-relationship parentheticals
   - Mitigation: Keep additional_parameters fallback, comprehensive testing

### Validation Plan

**Before implementation:**
- Review all uses of `additional_parameters` in current code
- Check current test suite for parenthetical patterns
- Document edge cases

**During implementation:**
- Add parser rules incrementally
- Test each rule in isolation
- Run full test suite after each change

**After implementation:**
- Run full IEEE test suite
- Run classification on all fixtures
- Verify no regressions

---

## Implementation Order

### Phase 1: Parser Rules (30 min)
1. Add relationship_type rule with all variants
2. Add identifier_list rule (simple capture)
3. Add as_amended_by_clause rule
4. Add relationship_content rule
5. Add relationship_clause rule
6. Update parenthetical rule

### Phase 2: Builder Integration (60 min)
1. Add parse_identifier_list method
2. Add extract_identifier_strings helper
3. Add build_relationships method
4. Test with simple cases
5. Test with complex cases

### Phase 3: Testing (30 min)
1. Unit tests for parser rules
2. Integration tests for parsing
3. Round-trip tests
4. Regression tests

---

## Success Criteria

✅ Relationship patterns parsed structurally
✅ Non-relationship parentheticals still work
✅ All existing tests pass
✅ New relationship tests pass
✅ No regressions in fixture classification
✅ Round-trip fidelity preserved

---

**Status:** Parser design complete ✅
**Next Step:** Begin implementation (Session 123)
**Estimated Time:** Phase 1 (30 min), Phase 2 (60 min), Phase 3 (30 min) = 2 hours total