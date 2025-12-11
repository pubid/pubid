# Session 124 Continuation Plan: IEEE Pattern 4 COMPLETE Implementation (COMPRESSED)

**Created:** 2025-12-11 (Post-Session 123)
**Status:** Session 123 complete - Component & Base ready
**Timeline:** COMPRESSED - Complete ALL remaining work in 1 session (2-3 hours maximum)

---

## Executive Summary

**Session 123 Achievement:** Relationship component + Base integration complete with 100% tests passing ✅

**Session 124 Goal:** Implement Parser + Builder + Comprehensive Testing + Documentation in ONE session

**Current Status:**
- ✅ Relationship component working (16/16 tests)
- ✅ Base integration working (3/3 tests)
- ✅ Zero regressions (95/95 unit tests passing)
- ⏳ Parser enhancement (0/8 relationship rules)
- ⏳ Builder enhancement (0/4 helper methods)
- ⏳ Comprehensive testing (0/50+ integration tests)

**Target:** IEEE 86.94-87.21% (8,291-8,317/9,537) - Gain +60-86 identifiers

---

## COMPRESSED Implementation Plan (2-3 hours)

### Phase 1: Parser Enhancement (45 minutes)

**File:** [`lib/pubid_new/ieee/parser.rb`](lib/pubid_new/ieee/parser.rb:1)

**Add 8 relationship type rules (15 min):**

```ruby
# Relationship type keywords
rule(:relationship_revision_of) { str("Revision of ") | str("Revison of ") }
rule(:relationship_amendment_to) { str("Amendment to ") }
rule(:relationship_corrigendum_to) { str("Corrigendum to ") }
rule(:relationship_incorporates) { str("incorporates ") | str("Incorporating ") }
rule(:relationship_adoption_of) { str("Adoption of ") }
rule(:relationship_supplement_to) { str("Supplement to ") }
rule(:relationship_draft_amendment) { str("Draft Amendment to ") | str("DRAFT Amendment to ") }
rule(:relationship_draft_revision) { str("Draft Revision of ") }

# Combined relationship type
rule(:relationship_type) do
  (
    relationship_revision_of.as(:revision_of) |
    relationship_amendment_to.as(:amendment_to) |
    relationship_corrigendum_to.as(:corrigendum_to) |
    relationship_incorporates.as(:incorporates) |
    relationship_adoption_of.as(:adoption_of) |
    relationship_supplement_to.as(:supplement_to) |
    relationship_draft_amendment.as(:draft_amendment_to) |
    relationship_draft_revision.as(:draft_revision_of)
  )
end
```

**Add identifier list parsing (15 min):**

```ruby
# Identifier list (comma/and separated)
rule(:identifier_list) do
  identifier_string.as(:id) >>
  (
    (str(", and ") | str(" and ") | str(", ")) >>
    identifier_string.as(:id)
  ).repeat
end

rule(:identifier_string) do
  # Capture everything except comma, closing paren, or "as amended by"
  match("[^,)]+(?! as amended by)").repeat(1)
end
```

**Add "as amended by" clause (10 min):**

```ruby
rule(:as_amended_by_clause) do
  str(" as amended by ") >> identifier_list.as(:amendments)
end
```

**Add relationship clause (5 min):**

```ruby
rule(:relationship_clause) do
  str("(") >>
  relationship_type >>
  identifier_list.as(:related_ids) >>
  as_amended_by_clause.maybe >>
  (str(" / ") >> relationship_type >> identifier_list >> as_amended_by_clause.maybe).repeat.as(:additional_rels) >>
  str(")")
end

# Update parenthetical rule to try relationship_clause first
rule(:parenthetical) do
  relationship_clause | additional_parameters
end
```

### Phase 2: Builder Enhancement (45 minutes)

**File:** [`lib/pubid_new/ieee/builder.rb`](lib/pubid_new/ieee/builder.rb:1)

**Add in build() method (15 min):**

```ruby
# In build() method, add after handling other attributes:
if parsed_hash[:relationship_type] || parsed_hash[:relationship_clause]
  identifier.relationships = build_relationships(parsed_hash)
end
```

**Add helper methods (30 min):**

```ruby
def build_relationships(parsed_hash)
  return [] unless parsed_hash[:relationship_type] || parsed_hash[:relationship_clause]

  relationships = []

  # Main relationship
  if parsed_hash[:relationship_type]
    rel_type = extract_relationship_type(parsed_hash[:relationship_type])
    related = parse_identifier_list(parsed_hash[:related_ids])
    amendments = parse_identifier_list(parsed_hash[:amendments]) if parsed_hash[:amendments]

    relationships << Components::Relationship.new(
      relationship_type: rel_type,
      related_identifiers: related,
      intermediate_amendments: amendments
    )
  end

  # Additional relationships (separated by /)
  if parsed_hash[:additional_rels]
    parsed_hash[:additional_rels].each do |rel_data|
      rel_type = extract_relationship_type(rel_data[:relationship_type])
      related = parse_identifier_list(rel_data[:related_ids])
      amendments = parse_identifier_list(rel_data[:amendments]) if rel_data[:amendments]

      relationships << Components::Relationship.new(
        relationship_type: rel_type,
        related_identifiers: related,
        intermediate_amendments: amendments
      )
    end
  end

  relationships
end

def extract_relationship_type(type_hash)
  # type_hash has key like :revision_of, :amendment_to, etc.
  type_hash.keys.first.to_s
end

def parse_identifier_list(list_data)
  return [] unless list_data

  # Extract identifier strings
  id_strings = if list_data.is_a?(Array)
    list_data.map { |item| item[:id].to_s.strip }
  elsif list_data[:id]
    [list_data[:id].to_s.strip]
  else
    []
  end

  # Recursively parse each identifier
  id_strings.map do |id_str|
    begin
      Identifiers::Base.parse(id_str)
    rescue Parslet::ParseFailed
      # If parsing fails, create minimal identifier with just the string
      Identifiers::Base.new(parenthetical_content: id_str)
    end
  end
end
```

### Phase 3: Comprehensive Testing (30 minutes)

**Create:** `spec/pubid_new/ieee/identifiers/relationship_integration_spec.rb`

**Test all 7 relationship types with real examples (30 min):**

```ruby
RSpec.describe "IEEE Relationship Identifiers Integration" do
  # Test each relationship type
  # Test single vs multiple related identifiers
  # Test intermediate amendments
  # Test multiple relationship types
  # Test round-trip parsing
  # ~30-40 examples
end
```

### Phase 4: Validation & Documentation (30 minutes)

**Run tests (10 min):**
```bash
bundle exec rspec spec/pubid_new/ieee/
cd spec/fixtures && ruby run_classify.rb ieee
```

**Update documentation (20 min):**
1. Update [`.kilocode/rules/memory-bank/context.md`](.kilocode/rules/memory-bank/context.md:1)
2. Move Session 122-123 docs to `docs/old-docs/sessions/`
3. Create session summary

---

## Implementation Checklist

### Parser (45 min)
- [ ] Add 8 relationship type rules
- [ ] Add identifier_list rule
- [ ] Add as_amended_by_clause rule
- [ ] Add relationship_clause rule
- [ ] Update parenthetical rule
- [ ] Test parser with samples

### Builder (45 min)
- [ ] Add build_relationships method
- [ ] Add extract_relationship_type helper
- [ ] Add parse_identifier_list helper
- [ ] Handle multiple relationships
- [ ] Test builder with complex cases

### Testing (30 min)
- [ ] Create relationship_integration_spec.rb
- [ ] Test all 7 relationship types
- [ ] Test multiple identifiers
- [ ] Test intermediate amendments
- [ ] Test multiple relationships
- [ ] Run full IEEE test suite

### Documentation (30 min)
- [ ] Update context.md
- [ ] Move old docs to archive
- [ ] Create session summary
- [ ] Commit all changes

---

## Success Criteria

### Minimum (85%)
- ✅ Parser rules working
- ✅ Builder constructing relationships
- ✅ Simple relationships parsing
- ✅ No regressions
- ✅ IEEE at 86.5%+ (gain +20 IDs)

### Target (90%)
- ✅ All relationship types working
- ✅ Multiple relationships supported
- ✅ "as amended by" clause working
- ✅ 30+ integration tests passing
- ✅ IEEE at 86.94%+ (gain +60 IDs)

### Stretch (100%)
- ✅ All patterns working
- ✅ Edge cases handled
- ✅ 50+ comprehensive tests
- ✅ Complete documentation
- ✅ IEEE at 87.21%+ (gain +86 IDs)

---

## Risk Mitigation

**Parser complexity:** Start with simple patterns, add complexity incrementally
**Recursive parsing:** Handle failures gracefully, fallback to string storage
**Testing time:** Focus on critical paths first, comprehensive later if time

---

## Next Immediate Steps

1. Read parser.rb and builder.rb
2. Add relationship type rules to parser
3. Add identifier_list parsing
4. Add relationship_clause rule
5. Test parser incrementally
6. Add build_relationships to builder
7. Add helper methods
8. Test builder
9. Create integration tests
10. Run full test suite
11. Update documentation
12. Commit

---

**Created:** 2025-12-11
**Status:** Ready for execution
**Timeline:** 2-3 hours COMPRESSED
**Goal:** Complete ALL Pattern 4 work in ONE session! 🚀