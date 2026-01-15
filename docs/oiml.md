# OIML Documentation

## Overview

The OIML flavor handles identifiers for the International Organization of Legal Metrology (OIML) standards and related documents. It supports OIML's complete identifier ecosystem including 7 distinct document types (Recommendation, BasicPublication, Document, ExpertReport, Guide, SeminarReport, Vocabulary) with part and subpart numbering, edition notation, draft stages (WD, CD), language codes, and supplement identifiers (amendments and annexes). The flavor uses single-letter type codes (R, B, D, E, G, S, V) and handles both English/French bilingual rendering.

## Architecture

This flavor follows a simplified PubID v2 architecture without typed stages:

1. **Parser** (`parser.rb`) - Parslet PEG grammar for syntax parsing
   - Converts input strings into structured hash trees
   - Handles single-letter type codes (B, D, E, G, R, S, V)
   - Parses part and subpart numbering (-1, -2-1)
   - Supports edition notation (1st Edition, 6th Edition 2015)
   - Handles draft stages (WD, CD) with iteration numbers
   - Parses language codes ((E), (F), (E/F), (en), (fr))
   - Supports supplement identifiers (amendments, annexes)

2. **Builder** (`builder.rb`) - Transforms parse trees to domain objects
   - Identifies document type by type letter code
   - Constructs base identifier or supplement identifier
   - Casts components to proper types
   - Handles edition format vs year format

3. **Identifier** (`identifiers/`) - Lutaml::Model domain classes with rendering logic
   - Base identifiers (SingleIdentifier) for standalone documents
   - Supplement identifiers (SupplementIdentifier) for amendments/annexes
   - Single rendering format

## Components

### Flavor-Specific Components

| Component | File | Purpose | Attributes |
|-----------|------|---------|------------|
| None | N/A | OIML uses shared components | N/A |

### Shared Components Used

| Component | From | Purpose in this flavor |
|-----------|------|------------------------|
| `Publisher` | `lib/pubid_new/components/publisher.rb` | Organization name (OIML) |
| `Code` | `lib/pubid_new/components/code.rb` | Generic string values (number, part) |
| `Date` | `lib/pubid_new/components/date.rb` | Year-based dates |
| `Type` | Not used | OIML uses single-letter type codes |
| `Language` | `lib/pubid_new/components/language.rb` | Language codes (E, F, E/F, en, fr) |
| `Stage` | Not used | Draft stages handled as prefix |

## Identifier Classes

### Base Identifiers

#### Recommendation

- **File:** `lib/pubid_new/oiml/identifiers/recommendation.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** OIML Recommendations are the primary document type, representing international standards for legal metrology.
- **Components Used:** `publisher`, `number`, `part`, `subpart`, `year`, `languages`
- **Patterns Supported:**
  - `OIML R 106` → Basic recommendation
  - `OIML R 106(E)` → Recommendation with English language
  - `OIML R 106(F)` → Recommendation with French language
  - `OIML R 117-1:2019` → Recommendation with part and year
  - `OIML R 117-2:2019` → Recommendation with part 2
  - `OIML R 49-1:2013(E)` → Recommendation with part, year, and language
  - `OIML R 50:2014` → Recommendation with year only
- **Rendering Formats:** Single format
- **Special Features:**
  - `R` type code for Recommendation
  - Optional part and subpart numbering
  - Optional year (4-digit format)
  - Language codes: (E), (F), (E/F), (en), (fr)

#### BasicPublication

- **File:** `lib/pubid_new/oiml/identifiers/basic_publication.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** OIML Basic Publications provide fundamental metrology information.
- **Components Used:** `publisher`, `number`, `part`, `subpart`, `year`, `languages`
- **Patterns Supported:**
  - `OIML B 1` → Basic publication
  - `OIML B 2:2015` → Basic publication with year
- **Rendering Formats:** Single format
- **Special Features:**
  - `B` type code for Basic Publication

#### Document

- **File:** `lib/pubid_new/oiml/identifiers/document.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** OIML Documents are general publications.
- **Components Used:** `publisher`, `number`, `part`, `subpart`, `year`, `languages`
- **Patterns Supported:**
  - `OIML D 1` → Document
  - `OIML D 2:2015` → Document with year
- **Rendering Formats:** Single format
- **Special Features:**
  - `D` type code for Document

#### ExpertReport

- **File:** `lib/pubid_new/oiml/identifiers/expert_report.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** OIML Expert Reports contain findings from expert groups.
- **Components Used:** `publisher`, `number`, `part`, `subpart`, `year`, `languages`
- **Patterns Supported:**
  - `OIML E 1` → Expert report
  - `OIML E 2:2015` → Expert report with year
- **Rendering Formats:** Single format
- **Special Features:**
  - `E` type code for Expert Report

#### Guide

- **File:** `lib/pubid_new/oiml/identifiers/guide.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** OIML Guides provide guidance on metrology practices.
- **Components Used:** `publisher`, `number`, `part`, `subpart`, `year`, `languages`
- **Patterns Supported:**
  - `OIML G 1` → Guide
  - `OIML G 2:2015` → Guide with year
- **Rendering Formats:** Single format
- **Special Features:**
  - `G` type code for Guide

#### SeminarReport

- **File:** `lib/pubid_new/oiml/identifiers/seminar_report.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** OIML Seminar Reports document proceedings from seminars.
- **Components Used:** `publisher`, `number`, `part`, `subpart`, `year`, `languages`
- **Patterns Supported:**
  - `OIML S 1` → Seminar report
  - `OIML S 2:2015` → Seminar report with year
- **Rendering Formats:** Single format
- **Special Features:**
  - `S` type code for Seminar Report

#### Vocabulary

- **File:** `lib/pubid_new/oiml/identifiers/vocabulary.rb`
- **Parent:** `SingleIdentifier`
- **Purpose:** OIML Vocabularies define metrological terminology.
- **Components Used:** `publisher`, `number`, `part`, `subpart`, `year`, `languages`
- **Patterns Supported:**
  - `OIML V 1` → Vocabulary
  - `OIML V 2:2015` → Vocabulary with year
- **Rendering Formats:** Single format
- **Special Features:**
  - `V` type code for Vocabulary

### Supplement Identifiers

#### Amendment

- **File:** `lib/pubid_new/oiml/identifiers/amendment.rb`
- **Parent:** `SupplementIdentifier`
- **Purpose:** Amendments modify or add to existing OIML documents.
- **Components Used:** `base_identifier`, `number`
- **Patterns Supported:**
  - `OIML R 106/AMENDMENT 1` → Recommendation with amendment
  - `OIML R 106/Amd 1` → Recommendation with amendment (abbreviated)
  - `OIML B 1/AMENDMENT 2` → Basic publication with amendment
- **Rendering Formats:** Single format
- **Recursion:** Not supported (amendments don't amend other amendments)
- **Special Features:**
  - `AMENDMENT` or `Amd` keyword after base identifier
  - Amendment number required (1, 2, etc.)

#### Annex

- **File:** `lib/pubid_new/oiml/identifiers/annex.rb`
- **Parent:** `SupplementIdentifier`
- **Purpose:** Annexes provide additional information for OIML documents.
- **Components Used:** `base_identifier`, `number` (optional)
- **Patterns Supported:**
  - `OIML R 106/ANNEX` → Recommendation with annex
  - `OIML R 106/ANNEX A` → Recommendation with lettered annex
  - `OIML B 1/ANNEX B` → Basic publication with annex
- **Rendering Formats:** Single format
- **Recursion:** Not supported
- **Special Features:**
  - `ANNEX` keyword after base identifier
  - Annex identifier optional (letter or number)

## Scheme Registry

The `Scheme` class (`lib/pubid_new/oiml/scheme.rb`) is minimal for this flavor.

### Registry Methods

- **`identifiers`** - Array of all registered identifier classes
  ```ruby
  def identifiers
    [
      Identifiers::BasicPublication,
      Identifiers::Document,
      Identifiers::ExpertReport,
      Identifiers::Guide,
      Identifiers::Recommendation,
      Identifiers::SeminarReport,
      Identifiers::Vocabulary,
    ]
  end
  ```

- **`supplement_identifiers`** - Array of supplement identifier classes
  ```ruby
  def supplement_identifiers
    [
      Identifiers::Amendment,
      Identifiers::Annex,
    ]
  end
  ```

- **`typed_stages`** - Empty array (OIML doesn't use typed stages)

- **`supplement_typed_stages`** - Empty array

- **`locate_typed_stage_by_abbr(abbr)`** - Raises ArgumentError (OIML doesn't use typed stages)

- **`locate_identifier_klass_by_type_code(type_code)`** - Raises ArgumentError (OIML doesn't use type codes)

## Rendering Examples

### Short Format (default)

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `OIML R 106` | `OIML R 106` |
| `OIML R 106(E)` | `OIML R 106(E)` |
| `OIML R 117-1:2019` | `OIML R 117-1:2019` |
| `OIML R 49-1:2013(E)` | `OIML R 49-1:2013(E)` |
| `OIML G 1` | `OIML G 1` |
| `OIML V 2:2015` | `OIML V 2:2015` |
| `OIML R 106/AMENDMENT 1` | `OIML R 106/AMENDMENT 1` |
| `OIML R 106/ANNEX A` | `OIML R 106/ANNEX A` |

## Parser Rules

### Main Rule

```ruby
rule(:identifier) do
  amendment_identifier | amendment_short | annex_letter_identifier | annex_identifier | base_identifier
end
```

### Component Rules

```ruby
# Publisher - always "OIML"
rule(:publisher) { str("OIML").as(:publisher) >> space }

# Document type - single letter
rule(:doc_type) { match("[BDEGRSVX]").as(:type) >> space }

# Number with optional part and subpart
rule(:number_only) { digits.as(:number) }

rule(:part_number) { dash >> digits.as(:part) }

rule(:subpart_number) { dash >> digits.as(:subpart) }

rule(:full_number) do
  (
    number_only >> part_number >> subpart_number |
    number_only >> part_number |
    number_only
  )
end

# Edition number - ordinal numbers
rule(:edition_number) do
  (
    str("6th") | str("5th") | str("4th") | str("3rd") |
    str("2nd") | str("1st") |
    (digits >> (str("th") | str("nd") | str("rd") | str("st")))
  ).as(:edition)
end

# Edition text - uppercase or lowercase
rule(:edition_text) { str("Edition") | str("edition") }

# Edition portion - handles "6th Edition 2015" or "Edition 2013"
rule(:edition_portion) do
  (
    (str(", ") | space) >>
    edition_number.maybe >> space.maybe >> edition_text >> space.maybe >> year_digits.as(:year)
  ).as(:edition_format)
end

# Date - year after colon OR edition portion
rule(:date) do
  edition_portion | (colon >> space.maybe >> year_digits.as(:year))
end

# Draft stage - WD or CD with optional iteration
rule(:stage_iteration) do
  (
    digits >> str(".") >> digits | # 3.1
    digits # 1, 2, 3
  ).as(:iteration)
end

rule(:stage_abbr) do
  (str("WD") | str("CD")).as(:stage)
end

rule(:draft_stage) do
  space >> stage_iteration.maybe >> stage_abbr
end

# Language codes
rule(:lang_single) do
  match("[EFRX]") # Single letter: E, F, R, X
end

rule(:lang_multi) do
  match("[a-z]").repeat(2, 2) # Two letters: en, fr, etc.
end

rule(:language_code) do
  (
    lang_single >> slash >> lang_single |  # E/F
    lang_single |                          # E, F
    lang_multi                             # en, fr
  ).as(:language)
end

# Amendment
rule(:amendment_identifier) do
  base_identifier.as(:base_identifier) >>
    str("/") >> (str("AMENDMENT") | str("Amd")) >> space >> digits.as(:number)
end

rule(:amendment_short) do
  base_identifier.as(:base_identifier) >>
    str("/") >> str("/") >> digits.as(:number)
end

# Annex
rule(:annex_identifier) do
  base_identifier.as(:base_identifier) >>
    str("/") >> (str("ANNEX") | str("Annex")) >>
    (space >> letter.as(:annex_letter)).maybe
end

rule(:annex_letter_identifier) do
  base_identifier.as(:base_identifier) >>
    str("/") >> letter.as(:annex_letter)
end
```

## Builder Logic

### Identifier Class Selection

The Builder determines which identifier class to instantiate based on:

1. **Supplement patterns** - `/AMENDMENT`, `/Amd`, `//1` → Amendment
2. **Annex patterns** - `/ANNEX`, `/A` → Annex
3. **Type letter code** - R, B, D, E, G, S, V → corresponding class

### Type Code Mappings

| Type Code | Identifier Class |
|-----------|------------------|
| `R` | `Recommendation` |
| `B` | `BasicPublication` |
| `D` | `Document` |
| `E` | `ExpertReport` |
| `G` | `Guide` |
| `S` | `SeminarReport` |
| `V` | `Vocabulary` |

### Component Casting

Special casting logic in Builder:

```ruby
# Type letter (determines class)
when :type
  parsed_hash[:type].to_s  # "R", "B", "D", etc.

# Number
when :number
  parsed_hash[:number].to_s

# Part and subpart
when :part
  parsed_hash[:part].to_s

when :subpart
  parsed_hash[:subpart].to_s

# Year (4-digit)
when :year
  parsed_hash[:year].to_s

# Language code
when :language
  Language.new(code: parsed_hash[:language].to_s.upcase,
               original_code: parsed_hash[:language].to_s)

# Edition format (when Edition keyword used)
when :edition_format
  # Store that edition format was used
  { edition: true, year: parsed_hash[:year].to_s }
```

## Preprocessing

OIML does not use extensive preprocessing. Most normalization happens during parsing and building.

| Pattern | Input | Output | Purpose |
|---------|-------|--------|---------|
| Edition format | `6th Edition 2015` | `edition_format` hash | Preserve edition notation |
| Draft stage | `3.1 WD` | `stage: "WD", iteration: "3.1"` | Parse stage prefix |

## Testing

### Test Coverage

- **Unit tests:** `spec/pubid_new/oiml/components/`
- **Parser tests:** `spec/pubid_new/oiml/parser_spec.rb`
- **Builder tests:** `spec/pubid_new/oiml/builder_spec.rb`
- **Identifier tests:** `spec/pubid_new/oiml/identifiers/`
- **Integration tests:** `spec/integration/oiml_`

### Fixtures

Located in: `spec/fixtures/oiml/identifiers/`

- **Pass tests:** `pass/` - Valid patterns that should parse successfully
  - `recommendation.txt` - Recommendation patterns
  - `basic_publication.txt` - Basic Publication patterns
  - `document.txt` - Document patterns
  - `expert_report.txt` - Expert Report patterns
  - `guide.txt` - Guide patterns
  - `seminar_report.txt` - Seminar Report patterns
  - `vocabulary.txt` - Vocabulary patterns
  - `amendment.txt` - Amendment patterns
  - `annex.txt` - Annex patterns
- **Fail tests:** `fail/` - Invalid patterns that should raise errors

### Coverage Status

The OIML flavor has **100% test coverage** with 59 pass fixtures and 0 failures. All identifier classes are fully covered.

## Migration Notes

### V1 to V2 Changes

**Major architectural changes:**
1. **No typed stages** - OIML uses simple type letter codes, not TYPED_STAGES
2. **Separate identifier classes** - Each document type has its own class
3. **Simplified rendering** - Single format instead of multiple formats
4. **Supplement classes** - Amendment and Annex as separate classes

**Breaking changes:**
- `Pubid::Oiml::Identifier` → `PubidNew::Oiml::Identifiers::*` (specific classes)
- Type letter determines class, not attribute
- Supplements use separate classes

**Migration guide:**
1. Replace `Pubid::Oiml.parse()` with `PubidNew::Oiml.parse()`
2. Use specific identifier classes instead of generic `Identifier`
3. Access type via `type_string` method
4. Supplements accessed via `base_identifier` attribute

## References

- **Specification:** OIML (International Organization of Legal Metrology)
- **Examples:** OIML Publications (https://www.oiml.org/)
- **Related implementations:**
  - ISO flavor (similar structure with multiple document types)
  - BIPM flavor (similar metrology standards)

---

## Appendix: Design Decisions

### No Typed Stages

**Context:** Most PubID flavors (ISO, IEC, JIS) use TYPED_STAGES for stage/type management.

**Decision:** OIML does not use typed stages or type codes.

**Rationale:**
- OIML uses simple single-letter type codes (R, B, D, etc.)
- Type is determined by letter, not stage
- No development stage lifecycle in OIML identifiers
- Simpler architecture for OIML-specific patterns

**Alternatives considered:**
- Use typed stages like ISO - Rejected (OIML has no stage system)
- Use numeric type codes - Rejected (letter codes are standard)

### Type Letter Determines Class

**Context:** OIML has 7 document types distinguished by single letter (R, B, D, E, G, S, V).

**Decision:** Type letter determines which identifier class to instantiate.

**Rationale:**
- Each type letter is semantically distinct
- Clear separation of concerns
- Easy to extend with new types
- Single-letter codes are standard for OIML

**Alternatives considered:**
- Single class with type attribute - Rejected (less clear)
- Use type codes with registry - Rejected (overkill for simple letters)

### Edition Format Preservation

**Context:** OIML identifiers use edition notation (e.g., "6th Edition 2015") in addition to year format.

**Decision:** Parse and preserve edition format information.

**Rationale:**
- Edition format is semantically meaningful
- Different from simple year notation
- Must be preserved for round-trip parsing
- Some OIML documents use edition, some use year

**Alternatives considered:**
- Normalize to year only - Rejected (loses information)
- Store as string - Rejected (loses structure)

### Amendment Short Format

**Context:** OIML amendments can be written as "/AMENDMENT 1" or "//1" (double slash).

**Decision:** Support both formats in parser.

**Rationale:**
- Both formats are used in practice
- Double slash is shorthand for amendment
- Parser normalizes to single representation
- Flexible parsing for user convenience

**Alternatives considered:**
- Support only long format - Rejected (short format is common)
- Support only short format - Rejected (long format is clearer)
