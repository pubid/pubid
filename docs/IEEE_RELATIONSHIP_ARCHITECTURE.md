# IEEE Relationship Identifiers - Architecture Design

**Created:** 2025-12-11 (Session 122)
**Status:** Model Design Complete

---

## Design Overview

IEEE relationship identifiers use a **composition pattern** where an identifier can contain one or more relationships to other identifiers. This is MORE complex than ISO's BundledIdentifier because:

- **ISO Bundle:** Simple "base + supplements" pattern with "+" separator
- **IEEE Relationships:** Complex "base (relationship_type: related_ids)" with recursive parsing and multiple relationship types

---

## Core Architecture Decisions

### Decision 1: Composition Over Wrapper Classes

**Chosen Approach:** Add relationship attributes to Base, create specific relationship metadata classes

**Rationale:**
- Relationships are **metadata about** an identifier, not a different identifier type
- An IEEE Std can have BOTH normal attributes AND relationships
- Example: `IEEE Std C95.1-2019 (Revision of X / Incorporates Y) - Redline`
  - Base: IEEE Std C95.1-2019
  - Relationships: revision_of + incorporates
  - Suffix: Redline flag

**Alternative Rejected:** Create wrapper classes like RelationshipIdentifier
- Would require duplicating all Base attributes
- Would complicate rendering logic
- Relationships are secondary to identifier itself

### Decision 2: Relationship as Separate Model

**Create:** `Relationship` class to encapsulate relationship data

**Structure:**
```ruby
class Relationship < Lutaml::Model::Serializable
  attribute :relationship_type, :string  # "revision_of", "incorporates", etc.
  attribute :related_identifiers, ::PubidNew::Ieee::Identifiers::Base,
            collection: true, polymorphic: true
  attribute :intermediate_amendments, ::PubidNew::Ieee::Identifiers::Base,
            collection: true, polymorphic: true  # For "as amended by" clause
end
```

**Benefits:**
- Clean encapsulation of relationship data
- Supports multiple relationships per identifier
- Reusable across all identifier types
- Easy to serialize/deserialize

### Decision 3: Update Base Class

**Add to Base:**
```ruby
attribute :relationships, Relationship, collection: true
```

**Remove from Base (legacy attributes):**
```ruby
# These will be migrated to Relationship objects
# attribute :revision_of, Base
# attribute :incorporates, Base, collection: true
# attribute :amendment_to, :string
# etc.
```

**Migration Strategy:**
- Keep legacy attributes during transition
- Builder creates Relationship objects
- to_s method uses relationships if present, falls back to legacy

---

## Relationship Class Design

### Core Relationship Class

**File:** `lib/pubid_new/ieee/components/relationship.rb`

```ruby
# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Ieee
    module Components
      # Represents a relationship between IEEE identifiers
      # E.g., "Revision of IEEE Std X, Y" or "incorporates A, B, C"
      class Relationship < Lutaml::Model::Serializable
        # Relationship type constants
        REVISION_OF = "revision_of"
        AMENDMENT_TO = "amendment_to"
        CORRIGENDUM_TO = "corrigendum_to"
        INCORPORATES = "incorporates"
        INCORPORATING = "incorporating"  # Synonym for incorporates
        ADOPTION_OF = "adoption_of"
        SUPPLEMENT_TO = "supplement_to"
        DRAFT_AMENDMENT_TO = "draft_amendment_to"
        DRAFT_REVISION_OF = "draft_revision_of"

        # All valid relationship types
        VALID_TYPES = [
          REVISION_OF,
          AMENDMENT_TO,
          CORRIGENDUM_TO,
          INCORPORATES,
          INCORPORATING,
          ADOPTION_OF,
          SUPPLEMENT_TO,
          DRAFT_AMENDMENT_TO,
          DRAFT_REVISION_OF
        ].freeze

        # Attributes
        attribute :relationship_type, :string
        attribute :related_identifiers, ::PubidNew::Ieee::Identifiers::Base,
                  collection: true, polymorphic: true
        attribute :intermediate_amendments, ::PubidNew::Ieee::Identifiers::Base,
                  collection: true, polymorphic: true

        # Validation
        def initialize(**args)
          super
          validate_relationship_type if relationship_type
        end

        def validate_relationship_type
          unless VALID_TYPES.include?(relationship_type)
            raise ArgumentError, "Invalid relationship type: #{relationship_type}"
          end
        end

        # Rendering
        def to_s
          return "" if related_identifiers.nil? || related_identifiers.empty?

          # Format: "Relationship Type IEEE Std X, IEEE Std Y, and IEEE Std Z"
          prefix = format_relationship_prefix
          ids = format_identifier_list(related_identifiers)

          # Add intermediate amendments if present
          if intermediate_amendments && !intermediate_amendments.empty?
            amendments = format_identifier_list(intermediate_amendments)
            "#{prefix} #{ids} as amended by #{amendments}"
          else
            "#{prefix} #{ids}"
          end
        end

        private

        def format_relationship_prefix
          case relationship_type
          when REVISION_OF then "Revision of"
          when AMENDMENT_TO then "Amendment to"
          when CORRIGENDUM_TO then "Corrigendum to"
          when INCORPORATES, INCORPORATING then "incorporates"
          when ADOPTION_OF then "Adoption of"
          when SUPPLEMENT_TO then "Supplement to"
          when DRAFT_AMENDMENT_TO then "Draft Amendment to"
          when DRAFT_REVISION_OF then "Draft Revision of"
          else relationship_type
          end
        end

        def format_identifier_list(identifiers)
          return "" if identifiers.nil? || identifiers.empty?

          case identifiers.length
          when 1
            identifiers.first.to_s
          when 2
            "#{identifiers.first} and #{identifiers.last}"
          else
            # X, Y, and Z format
            last = identifiers.last
            others = identifiers[0..-2]
            "#{others.join(', ')}, and #{last}"
          end
        end
      end
    end
  end
end
```

---

## Base Class Updates

### Updated Base Attributes

**File:** `lib/pubid_new/ieee/identifiers/base.rb`

**Add:**
```ruby
attribute :relationships, Components::Relationship, collection: true
```

**Keep (for backward compatibility during transition):**
```ruby
attribute :revision_of, Base                       # Legacy - migrate to relationships
attribute :incorporates, Base, collection: true    # Legacy
attribute :supersedes, Base, collection: true      # Legacy
attribute :supplement_to, Base                     # Legacy
attribute :amendment_to, :string                   # Legacy
attribute :adoption, :string                       # Legacy
```

### Updated to_s Method

**Enhance to_s to handle relationships:**

```ruby
def to_s
  # ... existing code for main identifier ...

  # Add relationships if present
  if relationships && !relationships.empty?
    relationship_str = relationships.map(&:to_s).join(" / ")
    result += " (#{relationship_str})"
  elsif parenthetical_content
    # Legacy fallback
    result += " (#{parenthetical_content})"
  elsif revision_of
    # Legacy fallback
    result += " (Revision of #{revision_of})"
  # ... other legacy fallbacks ...
  end

  # Redline suffix
  result += " - Redline" if redline

  result
end
```

---

## Parser Integration

### Relationship Parsing Rules

**File:** `lib/pubid_new/ieee/parser.rb`

**Add new rules:**

```ruby
# Relationship type keywords
rule(:relationship_revision_of) do
  str("Revision of ") | str("Revison of ")  # Handle typo
end

rule(:relationship_amendment_to) do
  str("Amendment to ")
end

rule(:relationship_corrigendum_to) do
  str("Corrigendum to ")
end

rule(:relationship_incorporates) do
  str("incorporates ") | str("Incorporating ")
end

rule(:relationship_adoption_of) do
  str("Adoption of ")
end

rule(:relationship_supplement_to) do
  str("Supplement to ")
end

rule(:relationship_draft_amendment) do
  str("Draft Amendment to ") | str("DRAFT Amendment to ")
end

rule(:relationship_draft_revision) do
  str("Draft Revision of ")
end

# Combined relationship rule
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

# "as amended by" clause
rule(:as_amended_by) do
  str(" as amended by ") >> identifier_list.as(:amendments)
end

# Parse relationship content
rule(:relationship_content) do
  relationship_type >> identifier_list.as(:related_ids) >> as_amended_by.maybe
end

# Parse multiple relationships separated by /
rule(:relationship_clause) do
  str("(") >>
  relationship_content >>
  (str(" / ") >> relationship_content).repeat.as(:additional_relationships) >>
  str(")")
end

# Identifier list (comma/and separated, with recursive parsing)
rule(:identifier_list) do
  # This needs to recursively parse IEEE identifiers
  # Simplified for now - full implementation in builder
  match("[^,)]+").as(:identifier_string) >>
  (
    (str(", and ") | str(" and ") | str(", ")) >>
    match("[^,)]+").as(:identifier_string)
  ).repeat
end
```

---

## Builder Integration

### Relationship Construction

**File:** `lib/pubid_new/ieee/builder.rb`

**Add relationship building logic:**

```ruby
def build_relationships(parsed_hash)
  return [] unless parsed_hash[:relationships]

  relationships = []

  # Handle main relationship
  if parsed_hash[:relationship_type]
    type = extract_relationship_type(parsed_hash[:relationship_type])
    related_ids = parse_identifier_list(parsed_hash[:related_ids])
    amendments = parse_identifier_list(parsed_hash[:amendments]) if parsed_hash[:amendments]

    relationships << Components::Relationship.new(
      relationship_type: type,
      related_identifiers: related_ids,
      intermediate_amendments: amendments
    )
  end

  # Handle additional relationships (separated by /)
  if parsed_hash[:additional_relationships]
    parsed_hash[:additional_relationships].each do |rel|
      type = extract_relationship_type(rel[:relationship_type])
      related_ids = parse_identifier_list(rel[:related_ids])
      amendments = parse_identifier_list(rel[:amendments]) if rel[:amendments]

      relationships << Components::Relationship.new(
        relationship_type: type,
        related_identifiers: related_ids,
        intermediate_amendments: amendments
      )
    end
  end

  relationships
end

def extract_relationship_type(type_hash)
  # type_hash will have key like :revision_of, :amendment_to, etc.
  type_hash.keys.first.to_s
end

def parse_identifier_list(list_data)
  return [] unless list_data

  # Extract identifier strings from parsed data
  identifier_strings = extract_identifier_strings(list_data)

  # Recursively parse each identifier
  identifier_strings.map do |id_str|
    Identifiers::Base.parse(id_str.strip)
  end
end

def extract_identifier_strings(list_data)
  # Parse the comma/and-separated list
  # This is simplified - actual implementation handles complex patterns
  if list_data.is_a?(Array)
    list_data.map { |item| item[:identifier_string] }
  elsif list_data.is_a?(Hash) && list_data[:identifier_string]
    [list_data[:identifier_string]]
  else
    []
  end
end
```

---

## Usage Examples

### Example 1: Simple Revision

**Input:** `"ANSI C37.45-1981(R1992) (Revision of ANSI C37.45-1969)"`

**Parsed Structure:**
```ruby
Base.new(
  publisher: "ANSI",
  code: "C37.45",
  year: "1981",
  relationships: [
    Relationship.new(
      relationship_type: "revision_of",
      related_identifiers: [
        Base.new(publisher: "ANSI", code: "C37.45", year: "1969")
      ]
    )
  ]
)
```

**Renders as:** `"ANSI C37.45-1981(R1992) (Revision of ANSI C37.45-1969)"`

### Example 2: Multiple Related Identifiers

**Input:** `"IEEE Std 1232-2002 (Revision of IEEE Std 1232-1995, IEEE Std 1232.1-1997, IEEE Std 1232.2-1998)"`

**Parsed Structure:**
```ruby
Base.new(
  publisher: "IEEE",
  type: "Std",
  code: "1232",
  year: "2002",
  relationships: [
    Relationship.new(
      relationship_type: "revision_of",
      related_identifiers: [
        Base.new(code: "1232", year: "1995"),
        Base.new(code: "1232.1", year: "1997"),
        Base.new(code: "1232.2", year: "1998")
      ]
    )
  ]
)
```

**Renders as:** `"IEEE Std 1232-2002 (Revision of IEEE Std 1232-1995, IEEE Std 1232.1-1997, and IEEE Std 1232.2-1998)"`

### Example 3: With Intermediate Amendments

**Input:** `"IEEE 802.1Qch-2017 (Amendment to IEEE Std 802.1Q-2014 as amended by IEEE Std 802.1Qca-2015, IEEE Std 802.1Qcd-2015)"`

**Parsed Structure:**
```ruby
Base.new(
  publisher: "IEEE",
  code: "802.1Qch",
  year: "2017",
  relationships: [
    Relationship.new(
      relationship_type: "amendment_to",
      related_identifiers: [
        Base.new(code: "802.1Q", year: "2014")
      ],
      intermediate_amendments: [
        Base.new(code: "802.1Qca", year: "2015"),
        Base.new(code: "802.1Qcd", year: "2015")
      ]
    )
  ]
)
```

**Renders as:** `"IEEE 802.1Qch-2017 (Amendment to IEEE Std 802.1Q-2014 as amended by IEEE Std 802.1Qca-2015 and IEEE Std 802.1Qcd-2015)"`

### Example 4: Multiple Relationship Types

**Input:** `"IEEE Std C95.1-2019 (Revision of IEEE Std C95.1-2005 / Incorporates IEEE Std C95.1-2019/Cor 1-2019)"`

**Parsed Structure:**
```ruby
Base.new(
  publisher: "IEEE",
  type: "Std",
  code: "C95.1",
  year: "2019",
  relationships: [
    Relationship.new(
      relationship_type: "revision_of",
      related_identifiers: [Base.new(code: "C95.1", year: "2005")]
    ),
    Relationship.new(
      relationship_type: "incorporates",
      related_identifiers: [Base.new(code: "C95.1-2019/Cor", number: "1", year: "2019")]
    )
  ]
)
```

**Renders as:** `"IEEE Std C95.1-2019 (Revision of IEEE Std C95.1-2005 / incorporates IEEE Std C95.1-2019/Cor 1-2019)"`

---

## Implementation Checklist

### Phase 1: Component Creation (Session 123)
- [ ] Create `lib/pubid_new/ieee/components/relationship.rb`
- [ ] Add relationship constants
- [ ] Implement initialize with validation
- [ ] Implement to_s with proper formatting
- [ ] Add format_identifier_list method
- [ ] Add unit tests for Relationship class

### Phase 2: Base Integration (Session 123)
- [ ] Add `relationships` attribute to Base
- [ ] Update `to_s` to handle relationships collection
- [ ] Keep legacy attributes for backward compatibility
- [ ] Test relationship rendering

### Phase 3: Parser Enhancement (Session 124)
- [ ] Add relationship type rules
- [ ] Add `as amended by` clause parsing
- [ ] Add identifier_list rule
- [ ] Add relationship_clause rule
- [ ] Test parser with samples

### Phase 4: Builder Enhancement (Session 124)
- [ ] Add `build_relationships` method
- [ ] Add `extract_relationship_type` helper
- [ ] Add `parse_identifier_list` helper
- [ ] Handle multiple relationships (/ separator)
- [ ] Test builder with complex cases

### Phase 5: Testing (Session 125)
- [ ] Create comprehensive RSpec tests
- [ ] Test simple revision relationships
- [ ] Test multiple related identifiers
- [ ] Test intermediate amendments
- [ ] Test multiple relationship types
- [ ] Test round-trip parsing
- [ ] Validate against failure samples

---

## Architecture Validation

✅ **MODEL-DRIVEN**: Relationships are proper objects, not strings
✅ **Composition**: Identifiers contain Relationship objects
✅ **MECE**: Each relationship type is distinct
✅ **Separation of Concerns**: Parser/Builder/Identifier layers independent
✅ **Extensibility**: Easy to add new relationship types
✅ **Backward Compatible**: Legacy attributes preserved during transition

---

**Status:** Architecture design complete ✅
**Next Step:** Begin implementation (Session 123)