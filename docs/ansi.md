# ANSI Documentation

## Overview

The ANSI flavor handles identifiers for American National Standards Institute standards and related documents. It supports ANSI standards with optional copublishers (ISO, IEEE, IEC, SAE, ASME, ASTM) and various number formats including letter prefixes with dotted parts, letter suffixes, and year dates separated by colons.

## Architecture

This flavor follows the PubID v2 three-layer architecture pattern:

1. **Parser** (`parser.rb`) - Parslet PEG grammar for syntax parsing
   - Converts input strings into structured hash trees
   - Handles copublisher patterns with slash separators
   - Supports optional "Std" keyword
   - Returns parse tree with component keys

2. **Builder** (`builder.rb`) - Transforms parse trees to domain objects via shared base builder
   - Uses common parse methods from shared library
   - Casts parsed hash values to component objects
   - Instantiates Standard identifier class

3. **Identifier** (`identifiers/`) - Lutaml::Model domain classes with rendering logic
   - Standard class for American National Standards
   - Uses shared SingleIdentifier base class

## Components

### Flavor-Specific Components

| Component | File | Purpose | Attributes |
|-----------|------|---------|------------|
| N/A | N/A | ANSI uses shared components only | N/A |

### Shared Components Used

| Component | From | Purpose in this flavor |
|-----------|------|------------------------|
| `Code` | `lib/pubid_new/components/code.rb` | Generic string values with number and parts |
| `Date` | `lib/pubid_new/components/date.rb` | Year-based dates |
| `Type` | `lib/pubid_new/components/type.rb` | Document type |
| `Language` | `lib/pubid_new/components/language.rb` | Language codes |
| `Publisher` | `lib/pubid_new/components/publisher.rb` | Organization name and copublishers |

## Identifier Classes

### Base Identifiers

#### Standard

- **File:** `lib/pubid_new/ansi/identifiers/standard.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** American National Standard documents
- **Components Used:** `publisher`, `copublishers`, `number`, `part`, `date`, `languages`
- **Patterns Supported:**
  - `ANSI X3.4-1986` → Letter prefix with dot and year
  - `ANSI C63.4-2014` → Letter prefix with one dot
  - `ANSI C37.06.1-2000` → Letter prefix with two dots
  - `ANSI C57.12.10-1988` → Letter prefix with three dots
  - `ANSI N323A-1997` → Letter prefix with letter suffix
  - `ANSI N42.49A-2011` → Letter prefix, dot, number, letter suffix, year
  - `ANSI 9899` → Just digits (no prefix, no year)
  - `ANSI 802.3-2012` → Digits with dot and year
  - `ANSI 802.1b-1995` → Digits, dot, digits, letter, year
  - `ANSI/ISO 9899:1990` → With ISO copublisher and colon date
  - `ANSI/IEEE Std 1-1986` → With IEEE copublisher and "Std" keyword
- **TYPED_STAGES:** Not applicable (ANSI does not use typed stages)
- **Rendering Formats:** Standard format only

### Supplement Identifiers

None - ANSI flavor does not support supplements.

## Scheme Registry

The `Scheme` class (`lib/pubid_new/ansi/scheme.rb`) is the central registry for this flavor.

### Registry Methods

- **`identifiers`** - Array of all registered identifier classes
  ```ruby
  IDENTIFIER_TYPES = [
    Identifiers::Standard,
  ].freeze

  Scheme = PubidNew::Scheme.new(
    identifiers: IDENTIFIER_TYPES,
    supplement_identifiers: [],
  )
  ```

- **`typed_stages`** - Empty array (ANSI does not use typed stages)

- **`locate_typed_stage_by_abbr(abbr)`** - Uses base Scheme method (raises error for ANSI)

- **`locate_identifier_klass_by_type_code(type_code)`** - Uses base Scheme method

### Parser Instance

```ruby
# Parser instance is created on-demand (not memoized in base Scheme)
```

## Rendering Examples

### Standard Format

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `ANSI X3.4-1986` | `ANSI X3.4-1986` |
| `ANSI C63.4-2014` | `ANSI C63.4-2014` |
| `ANSI/ISO 9899:1990` | `ANSI/ISO 9899:1990` |
| `ANSI/IEEE Std 1-1986` | `ANSI/IEEE Std 1-1986` |

### Other Formats

| Format | Rendered Output |
|--------|-----------------|
| Not applicable for ANSI | N/A |

## Parser Rules

### Main Rule

```ruby
rule(:identifier) do
  identifier_with_copublishers | identifier_sole
end
```

### Component Rules

```ruby
# Publisher (ANSI as sole publisher)
rule(:publisher) do
  str("ANSI").as(:publisher)
end

# Copublishers: ISO, IEEE, IEC, SAE, ASME, ASTM
rule(:copublishers) do
  (str("/") >> space? >> array_to_str(ORGANIZATIONS).as(:copublisher)).repeat(1)
end

# Optional "Std" keyword
rule(:std_keyword) do
  (str("Std") >> space).maybe
end

# Number with optional parts and letter suffix
rule(:number_with_part) do
  # Letter prefix pattern: C37.06.1, C57.12.10, N323A
  (match["A-Z"].repeat(1) >> digits >>
   (str(".") >> digits).repeat(0, 3) >>
   match["A-Z"].maybe >>
   (str("-") >> digits).maybe) |
  # Just digits pattern: 9899, 802.3-2012, 802.1b-1995
  (digits >> (str(".") >> digits >> match["a-z"].maybe).repeat(0, 2) >>
   (str("-") >> digits).maybe)
end

# Date - year only with colon separator
rule(:date) do
  str(":") >> year_digits.as(:date)
end
```

### Special Patterns

```ruby
# Identifier with copublishers (ANSI/ISO, ANSI/IEEE, etc.)
rule(:identifier_with_copublishers) do
  publisher >> copublishers >>
    space >> std_keyword >>
    number_with_part >>
    date.maybe >> language.maybe
end

# Sole ANSI identifier
rule(:identifier_sole) do
  publisher >> space >>
    std_keyword >>
    number_with_part >>
    date.maybe >> language.maybe
end
```

## Builder Logic

### Identifier Class Selection

The Builder uses the base Scheme class which determines identifier class via `locate_identifier_klass_by_type_code()`. For ANSI, this always returns `Identifiers::Standard`.

### Component Casting

Uses shared common parse methods from `lib/pubid_new/parser/common_parse_methods.rb`:

```ruby
# Standard number parsing
- number_with_part → extracts number, parts, iteration
- publisher → extracts "ANSI"
- copublishers → extracts array of copublisher organizations
- date → extracts year (with colon separator)
- language → extracts language codes
```

## Preprocessing

This flavor uses minimal preprocessing (inherited from shared parser):

| Pattern | Input | Output | Purpose |
|---------|-------|--------|---------|
| Space trimming | `ANSI   X3.4` | `ANSI X3.4` | Normalize spaces |

## Testing

### Test Coverage

- **Unit tests:** `spec/pubid_new/ansi/`
- **Parser tests:** `spec/pubid_new/ansi/parser_spec.rb`
- **Builder tests:** `spec/pubid_new/ansi/builder_spec.rb`
- **Identifier tests:** `spec/pubid_new/ansi/identifiers/`
- **Integration tests:** `spec/integration/ansi_`

### Fixtures

Located in: `spec/fixtures/ansi/identifiers/`

- **Pass tests:** `pass/` - Valid patterns that should parse successfully
- **Fail tests:** `fail/` - Invalid patterns that should raise errors

### Coverage Status

The ANSI flavor has good test coverage for standard patterns with copublishers.

## Migration Notes

### V1 to V2 Changes

**Major architectural changes:**
1. **Three-layer separation** - Parser, Builder, and Identifier are completely separate
2. **Shared components** - Uses Code, Date, Type, Language, Publisher from shared library
3. **Base Scheme class** - Inherits from `PubidNew::Scheme` for common functionality

**Breaking changes:**
- `Pubid::Ansi::Identifier` → `PubidNew::Ansi::Identifiers::Standard`

**Migration guide:**
1. Replace `Pubid::Ansi.parse()` with `PubidNew::Ansi.parse()`
2. Use Standard class instead of generic Identifier

## References

- **Specification:** ANSI Essential Requirements (https://www.ansi.org/)
- **Examples:** ANSI Standards Store (https://webstore.ansi.org/)
- **Related implementations:**
  - ISO flavor (copublisher patterns)
  - IEEE flavor (copublisher support)

---

## Appendix: Design Decisions

### No Supplement Support

**Context:** ANSI standards typically use revision and amendment codes within the base standard rather than separate supplement identifiers.

**Decision:** ANSI flavor does not include supplement identifier classes.

**Rationale:**
- ANSI supplements are typically embedded in the base identifier
- Simpler architecture without supplement complexity
- Matches real-world usage patterns

**Alternatives considered:**
- Add supplement classes - Rejected (unnecessary for ANSI)

### Letter Prefix Number Pattern

**Context:** ANSI uses complex letter prefix patterns (X3.4, C63.4, N323A, etc.) with variable numbers of dots and letter suffixes.

**Decision:** Parser uses explicit pattern matching for all letter prefix variants.

**Rationale:**
- Letter prefixes are specific to ANSI
- Multiple dot levels (0-3) and letter suffixes need explicit handling
- Clear pattern matching is more maintainable than complex regex

**Alternatives considered:**
- Single generic pattern - Rejected (too ambiguous)
- Separate parsing for each prefix - Rejected (too many rules)
