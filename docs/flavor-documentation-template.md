# [Flavor Name] Documentation

## Overview

[2-3 sentences about what this flavor handles, which organization's standards it supports, and any unique characteristics]

## Architecture

This flavor follows the PubID v2 three-layer architecture pattern:

1. **Parser** (`parser.rb`) - Parslet PEG grammar for syntax parsing
   - Converts input strings into structured hash trees
   - Handles syntax validation and lenient parsing
   - Returns parse tree with component keys

2. **Builder** (`builder.rb`) - Transforms parse trees to domain objects via Scheme registry
   - Casts parsed hash values to component objects
   - Uses Scheme registry for type/stage lookups
   - Instantiates appropriate identifier class

3. **Identifier** (`identifiers/`) - Lutaml::Model domain classes with rendering logic
   - Base identifiers (SingleIdentifier) for standalone documents
   - Supplement identifiers (SupplementIdentifier) for amendments/corrigenda
   - Multi-format rendering support (:short, :long, :abbrev, :mr)

## Components

### Flavor-Specific Components

| Component | File | Purpose | Attributes |
|-----------|------|---------|------------|
| [ComponentName] | `components/[component_name].rb` | [What it represents] | `[attr1]`, `[attr2]` |
| [ComponentName] | `components/[component_name].rb` | [What it represents] | `[attr1]`, `[attr2]` |

### Shared Components Used

| Component | From | Purpose in this flavor |
|-----------|------|------------------------|
| `Publisher` | `lib/pubid_new/components/publisher.rb` | Organization name and copublishers |
| `Code` | `lib/pubid_new/components/code.rb` | Generic string values (number, part, iteration) |
| `Date` | `lib/pubid_new/components/date.rb` | Year-based dates |
| `Type` | `lib/pubid_new/components/type.rb` | Document type |
| `Language` | `lib/pubid_new/components/language.rb` | Language codes with original_code preservation |
| `Stage` | `lib/pubid_new/components/stage.rb` | Development stage |
| `TypedStage` | `lib/pubid_new/components/typed_stage.rb` | Combined stage+type with rendering format support |

## Identifier Classes

### Base Identifiers

#### [ClassName]

- **File:** `lib/pubid_new/[flavor]/identifiers/[class_name].rb`
- **Parent:** `SingleIdentifier` or custom base
- **Purpose:** [What this identifier represents, which document types it handles]
- **Components Used:** [List all components this identifier uses]
- **Patterns Supported:**
  - `[Pattern 1]` → `[Example output]`
  - `[Pattern 2]` → `[Example output]`
  - `[Pattern 3]` → `[Example output]`
- **TYPED_STAGES:** [Array of TypedStage objects, if applicable]
- **Rendering Formats:** [List which formats are supported and any special handling]

#### [ClassName]

[Repeat structure for each base identifier class]

### Supplement Identifiers

#### [ClassName]

- **File:** `lib/pubid_new/[flavor]/identifiers/[class_name].rb`
- **Parent:** `SupplementIdentifier` or custom base
- **Purpose:** [What this supplement represents, relationship to base]
- **Components Used:** [List all components, including base_identifier]
- **Patterns Supported:**
  - `[Pattern 1]` → `[Example output]`
  - `[Pattern 2]` → `[Example output]`
- **TYPED_STAGES:** [Array of TypedStage objects, if applicable]
- **Recursion:** [Whether multi-level supplements are supported]
- **Rendering Formats:** [List which formats are supported]

#### [ClassName]

[Repeat structure for each supplement identifier class]

## Scheme Registry

The `Scheme` class (`lib/pubid_new/[flavor]/scheme.rb`) is the central registry for this flavor.

### Registry Methods

- **`identifiers`** - Array of all registered identifier classes
  ```ruby
  IDENTIFIERS = [
    [IdentifierClass1],
    [IdentifierClass2],
    # ...
  ].freeze
  ```

- **`typed_stages`** - Aggregate TYPED_STAGES from all identifier classes
  ```ruby
  def typed_stages
    @typed_stages ||= IDENTIFIERS.flat_map do |klass|
      klass.const_defined?(:TYPED_STAGES) ? klass::TYPED_STAGES : []
    end
  end
  ```

- **`locate_typed_stage_by_abbr(abbr)`** - Find stage by abbreviation
  - Returns `TypedStage` object or raises error
  - Searches through all registered TYPED_STAGES
  - Supports abbreviation arrays

- **`locate_identifier_klass_by_type_code(type_code)`** - Select class by type code
  - Returns identifier class based on type_code from parsed data
  - Used by Builder to determine which class to instantiate

### Parser Instance

```ruby
def parser
  @parser ||= Parser.new  # Memoized for performance
end
```

## Rendering Examples

### Short Format (`:short`)

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| [Pattern] | [Output] |
| [Pattern] | [Output] |

### MR Format (`:mr`)

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| [Pattern] | [Output] |
| [Pattern] | [Output] |

### Long Format (`:long`)

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| [Pattern] | [Output] |
| [Pattern] | [Output] |

### Abbreviated Format (`:abbrev`)

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| [Pattern] | [Output] |
| [Pattern] | [Output] |

## Parser Rules

### Main Rule

```ruby
rule(:identifier) do
  [Main pattern structure]
end
```

### Component Rules

```ruby
# [Component name]
rule(:[component_name]) do
  [Pattern definition]
end
```

[Document any special parsing patterns or edge cases]

## Builder Logic

### Identifier Class Selection

The Builder determines which identifier class to instantiate based on:

1. **Publisher/Series combination** - [Describe how this affects selection]
2. **Type code** - [List type codes and their mappings]
3. **Component presence** - [Which components trigger specific classes]

### Component Casting

Special casting logic for this flavor:

```ruby
# [Component name]
when :[component_key]
  [Casting logic]
```

## Preprocessing

This flavor uses preprocessing to normalize input before parsing:

| Pattern | Input | Output | Purpose |
|---------|-------|--------|---------|
| [Pattern name] | `[Input]` | `[Output]` | [Why this normalization] |
| [Pattern name] | `[Input]` | `[Output]` | [Why this normalization] |

[Add notes about preprocessing approach: explicit, format-preserving, progressive enhancement]

## Testing

### Test Coverage

- **Unit tests:** `[spec/pubid_new/[flavor]/components/]`
- **Parser tests:** `[spec/pubid_new/[flavor]/parser_spec.rb]`
- **Builder tests:** `[spec/pubid_new/[flavor]/builder_spec.rb]`
- **Identifier tests:** `[spec/pubid_new/[flavor]/identifiers/]`
- **Integration tests:** `[spec/integration/[flavor]_]`

### Fixtures

Located in: `spec/fixtures/[flavor]/identifiers/`

- **Pass tests:** `pass/` - Valid patterns that should parse successfully
- **Fail tests:** `fail/` - Invalid patterns that should raise errors

### Coverage Status

[Document current test coverage percentage, any gaps]

## Migration Notes (if applicable)

[If this flavor was migrated from V1, document key differences and migration path]

- **V1 to V2 changes:** [List major architectural changes]
- **Breaking changes:** [Any API changes]
- **Migration guide:** [Steps for users to migrate]

## References

- **Specification:** [Link to official specification if available]
- **Examples:** [Link to example documents or identifier listings]
- **Related implementations:** [Other flavors with similar patterns]

---

## Appendix: Design Decisions

### [Decision 1: Title]

**Context:** [What problem was being solved]

**Decision:** [What was chosen]

**Rationale:** [Why this approach was taken]

**Alternatives considered:**
- [Alternative 1] - [Why it wasn't chosen]
- [Alternative 2] - [Why it wasn't chosen]

### [Decision 2: Title]

[Repeat structure for other significant design decisions]
