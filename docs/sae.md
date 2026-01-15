# SAE Documentation

## Overview

The SAE flavor handles identifiers for SAE International (formerly Society of Automotive Engineers) technical documents. It supports five primary document types: Aerospace Material Specifications (AMS), Aerospace Information Reports (AIR), Aerospace Recommended Practices (ARP), Aerospace Standards (AS), and Material Advisories (MA). SAE identifiers follow a simple, consistent pattern without stage codes or supplements, using year-based versioning.

## Architecture

This flavor follows a simplified PubID v2 three-layer architecture pattern:

1. **Parser** (`parser.rb`) - Parslet PEG grammar for syntax parsing
   - Converts input strings into structured hash trees
   - Handles syntax validation for SAE identifier format
   - Returns parse tree with component keys
   - Supports five document types: AMS, AIR, ARP, AS, MA

2. **Builder** (`builder.rb`) - Transforms parse trees to domain objects
   - Casts parsed hash values to component objects
   - Instantiates Base identifier class (single class for all SAE types)
   - Handles year-to-date component conversion

3. **Identifier** (`identifiers/base.rb`) - Lutaml::Model domain class with rendering logic
   - Single Base identifier class for all SAE document types
   - Simple string rendering without format variations
   - No supplement support (SAE does not use amendments/corrigenda)

## Components

### Flavor-Specific Components

| Component | File | Purpose | Attributes |
|-----------|------|---------|------------|
| `Code` | `components/code.rb` | SAE document numbers with optional letter suffix | `value` |
| `Date` | `components/date.rb` | Year-based dates (year only) | `year` |
| `Type` | `components/type.rb` | SAE document type abbreviation | `abbr` |

### Shared Components Used

SAE does not use shared components - all components are flavor-specific implementations.

## Identifier Classes

### Base Identifiers

#### Base

- **File:** `lib/pubid_new/sae/identifiers/base.rb`
- **Parent:** `Lutaml::Model::Serializable`
- **Purpose:** The only SAE identifier class, handling all five SAE document types with a simple, unified structure.
- **Components Used:** `publisher`, `type`, `number`, `date`
- **Patterns Supported:**
  - `SAE AMS 1234` → Aerospace Material Specification
  - `SAE AIR 5678` → Aerospace Information Report
  - `SAE ARP 4321` → Aerospace Recommended Practice
  - `SAE AS 9876` → Aerospace Standard
  - `SAE MA 5432` → Material Advisory
  - `SAE AMS 1234:2024` → Document with year
  - `SAE AMS 7904F` → Document with letter suffix
  - `SAE AMS 2813G:2022` → Document with letter suffix and year
- **Rendering:** Simple space-separated format with colon-separated year

## Document Types

| Type Code | Full Name | Description |
|-----------|-----------|-------------|
| `AMS` | Aerospace Material Specification | Material specifications for aerospace applications |
| `AIR` | Aerospace Information Report | Informational documents providing data or guidance |
| `ARP` | Aerospace Recommended Practice | Recommended practices and procedures |
| `AS` | Aerospace Standard | Formal aerospace standards |
| `MA` | Material Advisory | Advisory documents on materials |

## Parser Rules

### Main Rule

```ruby
rule(:identifier) do
  publisher >> space >> doc_type >> space >>
    number >> date.maybe
end
```

### Component Rules

```ruby
# Publisher (constant)
rule(:publisher) { str("SAE").as(:publisher) }

# Document types
rule(:doc_type) do
  (
    str("AMS") |  # Aerospace Material Specification
    str("AIR") |  # Aerospace Information Report
    str("ARP") |  # Aerospace Recommended Practice
    str("AS") |   # Aerospace Standard
    str("MA")     # Material Advisory
  ).as(:type)
end

# Number with optional letter suffix
rule(:number) do
  (digits >> letter.repeat(0, 1)).as(:number)
end

# Year (4 digits)
rule(:year) { digit.repeat(4, 4).as(:year) }

# Date (colon + year)
rule(:date) { colon >> year }
```

### Pattern Examples

| Input | Parse Tree |
|-------|------------|
| `SAE AMS 1234` | `{publisher: "SAE", type: "AMS", number: "1234"}` |
| `SAE AMS 1234:2024` | `{publisher: "SAE", type: "AMS", number: "1234", year: "2024"}` |
| `SAE AMS 7904F` | `{publisher: "SAE", type: "AMS", number: "7904F"}` |

## Builder Logic

### Component Casting

The Builder's `cast()` method handles type conversion:

```ruby
when :publisher
  # SAE publisher is constant
  "SAE"

when :type
  Components::Type.new(abbr: value.to_s)

when :number
  Components::Code.new(value: value.to_s)

when :year
  # Return as hash with :date key for proper attribute mapping
  { date: Components::Date.new(year: value.to_i) }
```

### Identifier Construction

```ruby
# SAE only has one identifier type (Base)
identifier = Identifiers::Base.new

# Assign attributes after casting
data.each_pair do |key, value|
  realized_components = cast(key.to_sym, value)
  # ... attribute assignment logic
end
```

## Rendering Examples

### Standard Format

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `SAE AMS 1234` | `SAE AMS 1234` |
| `SAE AMS 1234:2024` | `SAE AMS 1234:2024` |
| `SAE AIR 5678:2022` | `SAE AIR 5678:2022` |
| `SAE ARP 4321` | `SAE ARP 4321` |
| `SAE AS 9876:2023` | `SAE AS 9876:2023` |
| `SAE MA 5432` | `SAE MA 5432` |
| `SAE AMS 7904F` | `SAE AMS 7904F` |
| `SAE AMS 2813G:2022` | `SAE AMS 2813G:2022` |

**Note:** SAE does not support multiple rendering formats like ISO. Only the standard format is available.

## Usage Examples

### Parsing

```ruby
# Parse basic identifier
id = PubidNew::Sae.parse("SAE AMS 1234:2024")
# => #<PubidNew::Sae::Identifiers::Base>

# Access components
id.publisher  # => "SAE"
id.type.abbr  # => "AMS"
id.number.value  # => "1234"
id.date.year  # => 2024
```

### Rendering

```ruby
# Convert to string
id.to_s  # => "SAE AMS 1234:2024"

# Access year directly
id.year  # => 2024
```

### Construction

```ruby
# Build identifier programmatically
id = PubidNew::Sae::Identifiers::Base.new(
  publisher: "SAE",
  type: PubidNew::Sae::Components::Type.new(abbr: "AMS"),
  number: PubidNew::Sae::Components::Code.new(value: "1234"),
  date: PubidNew::Sae::Components::Date.new(year: 2024)
)
id.to_s  # => "SAE AMS 1234:2024"
```

## Testing

### Test Coverage

- **Unit tests:** `spec/pubid_new/sae/components/`
- **Parser tests:** `spec/pubid_new/sae/parser_spec.rb`
- **Builder tests:** `spec/pubid_new/sae/builder_spec.rb`
- **Identifier tests:** `spec/pubid_new/sae/identifiers/base_spec.rb`
- **Integration tests:** `spec/integration/sae_`

### Fixtures

Located in: `spec/fixtures/sae/identifiers/`

- **Pass tests:** `pass/` - Valid patterns that should parse successfully
  - `base.txt` - Base identifier patterns
- **Fail tests:** `fail/` - Invalid patterns that should raise errors

### Coverage Status

The SAE flavor has basic test coverage for the five document types and rendering patterns.

## Design Characteristics

### Simplicity

SAE uses a simplified architecture compared to ISO:
- No Scheme registry (no complex type/stage lookups)
- Single identifier class for all document types
- No supplement identifiers (no amendments/corrigenda)
- No multiple rendering formats
- No stage codes (WD, CD, DIS, etc.)

### Year-Based Versioning

SAE uses year-based versioning instead of stage codes:
- `SAE AMS 1234:2024` indicates the 2024 revision
- Years are optional in identifiers
- No concept of draft stages in published identifiers

### Letter Suffixes

SAE numbers may include letter suffixes for revisions:
- `SAE AMS 7904F` - F revision of AMS 7904
- `SAE AMS 2813G` - G revision of AMS 2813
- Letter suffixes are treated as part of the number string

## Comparison with ISO

| Feature | SAE | ISO |
|---------|-----|-----|
| Document types | 5 (AMS, AIR, ARP, AS, MA) | 18+ (IS, TR, TS, Guide, PAS, etc.) |
| Stage codes | None | 15+ (PWI, NP, WD, CD, DIS, FDIS, etc.) |
| Supplements | None | 5 types (Amd, Cor, Add, Suppl, Ext) |
| Rendering formats | 1 (standard) | 4 (:short, :long, :abbrev, :mr) |
| Identifier classes | 1 (Base) | 18+ |
| Scheme registry | No | Yes (central registry) |
| URN support | No | Yes (RFC 5141-bis) |

## Migration Notes

### V1 to V2 Changes

**Major architectural changes:**
1. **Lutaml::Model** - Identifiers now use Lutaml::Model serialization
2. **Component-based** - Number, Date, and Type are proper component objects
3. **Three-layer separation** - Parser, Builder, and Identifier are separate
4. **Simplified architecture** - No Scheme registry needed

**API compatibility:**
- `PubidNew::Sae.parse()` replaces V1 parsing methods
- `to_s()` provides string rendering
- Access type via `type.abbr` instead of direct type attribute

## References

- **Specification:** SAE International Technical Standards Board Policies
- **Examples:** SAE Mobility Engineering Database (https://www.sae.org/)
- **Related implementations:**
  - ASTM flavor (similar simple structure)
  - ASME flavor (similar aerospace/industry focus)

---

## Appendix: Design Decisions

### Single Identifier Class

**Context:** SAE has five document types but all follow the same structural pattern.

**Decision:** Use a single Base identifier class for all SAE document types.

**Rationale:**
- All SAE types have identical structure (publisher + type + number + year)
- Type is just a string abbreviation, not a complex classification
- No need for separate classes without behavioral differences
- Simplifies maintenance and reduces code duplication

**Alternatives considered:**
- Separate class per document type - Rejected (no behavioral difference to justify)
- Type-based rendering variations - Rejected (SAE uses uniform rendering)

### No Scheme Registry

**Context:** ISO and other flavors use a Scheme registry for type/stage lookups.

**Decision:** SAE does not use a Scheme registry.

**Rationale:**
- No stage codes to lookup
- Only 5 document types, all handled by same class
- Builder logic is straightforward type casting
- No need for registry complexity

**Alternatives considered:**
- Add Scheme for consistency with ISO - Rejected (unnecessary complexity)
- Use TYPE_MAP hash - Rejected (array-based TYPED_STAGES pattern is preferred)

### Year as Date Component

**Context:** SAE uses year-based versioning (e.g., `:2024`).

**Decision:** Parse year as Date component with year attribute.

**Rationale:**
- Clear semantic meaning (date with year)
- Consistent with other flavors that use Date component
- Extensible if month/day needed in future
- Type-safe (integer year, not string)

**Alternatives considered:**
- Store year as integer attribute - Rejected (less semantic meaning)
- Store year as part of number - Rejected (mixes concerns)
