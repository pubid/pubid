# ASME Documentation

## Overview

The ASME flavor handles identifiers for American Society of Mechanical Engineers standards and related documents. It supports ASME's comprehensive standard catalog including BPVC (Boiler and Pressure Vessel Code) subdivisions, multi-character designator codes (PTC, QME, etc.), joint publications with CSA, API, ISO, and ANSI, and complex notation patterns for roman numerals and language suffixes.

## Architecture

This flavor follows the PubID v2 three-layer architecture pattern:

1. **Parser** (`parser.rb`) - Parslet PEG grammar for syntax parsing
   - Converts input strings into structured hash trees
   - Handles BPVC complex subdivision patterns (roman numerals, case codes)
   - Supports joint publisher patterns (CSA/ASME, API/ASME, ISO/ASME, ASME/ANS)
   - Returns parse tree with component keys

2. **Builder** (`builder.rb`) - Transforms parse trees to domain objects
   - Casts parsed hash values to component objects
   - Handles complex BPVC subdivision parsing
   - Instantiates Standard identifier class

3. **Identifier** (`identifiers/`) - Base domain class with rendering logic
   - Standard class for all ASME documents
   - Uses custom Base class with complex rendering

## Components

### Flavor-Specific Components

| Component | File | Purpose | Attributes |
|-----------|------|---------|------------|
| N/A | N/A | ASME uses hash-based storage in Base class | N/A |

### Shared Components Used

| Component | From | Purpose in this flavor |
|-----------|------|------------------------|
| N/A | N/A | ASME does not use shared components (custom implementation) | N/A |

## Identifier Classes

### Base Identifiers

#### Standard

- **File:** `lib/pubid_new/asme/identifiers/standard.rb`
- **Publisher:** `Base` (custom ASME base class)
- **Purpose:** ASME Standard documents including BPVC, PTC, and all designator codes
- **Components Used:** Hash-based attributes (parsed data stored as-is)
- **Patterns Supported:**
  - `ASME BPVC.I-2017` → BPVC Section I
  - `ASME BPVC.II.D.2017` → BPVC Section II, Subsection D
  - `ASME BPVC.III.1.NB.2017` → BPVC Section III, NB
  - `ASME BPVC.SSC.XI.II.V.IX-2015` → BPVC SSC complex subdivision
  - `ASME BPVC-CC-BPV` → BPVC Case Code
  - `ASME BPVC.CC.NC.XI` → BPVC Case Code with subdivision
  - `ASME PTC 19.3-2016` → Performance Test Code
  - `ASME QME-1-2020` → Qualification of Mechanical Equipment
  - `ASME B16.5-2020` → B series standard
  - `ASME Y14.5-2018` → Y series standard
  - `ASME NM.1-2019` → NM series with dot notation
  - `ASME/ANSI B16.5-2020` → Joint published with ANSI
  - `CSA Z662-15/ASME B31.4-2016` → Joint published with CSA first
  - `API 5L-2012/ASME B31.4-2012` → Joint published with API first
  - `ISO/ASME 14449-2016` → Joint published with ISO
- **TYPED_STAGES:** Not applicable (ASME does not use typed stages)
- **Rendering Formats:** Standard format only

### Supplement Identifiers

None - ASME flavor does not support supplements.

## Scheme Registry

The `Scheme` class (`lib/pubid_new/asme/scheme.rb`) is the central registry for this flavor.

### Registry Methods

- **`identifiers`** - Array of all registered identifier classes
  ```ruby
  def identifiers
    @identifiers ||= [
      Identifiers::Standard,
    ].freeze
  end
  ```

- **`supplement_identifiers`** - Empty array (no supplements)

- **`typed_stages`** - Empty array (ASME does not use typed stages)

- **`locate_typed_stage_by_abbr(abbr)`** - Raises ArgumentError (ASME does not use typed stages)

- **`locate_identifier_klass_by_type_code(type_code)`** - Raises ArgumentError (ASME does not use type codes)

### Parser Instance

```ruby
# Parser instance is created on-demand (not memoized in Scheme)
```

## Rendering Examples

### Standard Format

| Identifier Pattern | Rendered Output |
|-------------------|-----------------|
| `ASME BPVC.I-2017` | `ASME BPVC.I-2017` |
| `ASME PTC 19.3-2016` | `ASME PTC 19.3-2016` |
| `ASME/ANSI B16.5-2020` | `ASME/ANSI B16.5-2020` |
| `CSA Z662-15/ASME B31.4-2016` | `CSA Z662-15/ASME B31.4-2016` |

### Other Formats

| Format | Rendered Output |
|--------|-----------------|
| Not applicable for ASME | N/A |

## Parser Rules

### Main Rule

```ruby
rule(:identifier) do
  csa_asme_identifier |
    api_asme_identifier |
    iso_asme_identifier |
    asme_ans_identifier |
    standard
end
```

### Component Rules

```ruby
# Roman numerals (longest first for proper matching)
rule(:roman_numeral) do
  str("XIII") | str("XII") | str("XI") | str("VIII") |
    str("VII") | str("VI") | str("IV") | str("IX") | str("X") |
    str("III") | str("II") | str("V") | str("I")
end

# BPVC special letter codes
rule(:bpvc_letter_code) do
  str("NCA") | str("NCD") | str("SSC") | str("BPV") | str("NUC") |
    str("NB") | str("NC") | str("ND") | str("NE") | str("NF") | str("NG") |
    letter # Single letter for A, B, C, D, M
end

# BPVC complete subdivision
rule(:bpvc_subdivision) do
  str("BPVC") >> (
    # COMPLETE CODE BIND
    (space >> str("COMPLETE CODE BIND")) |
    # Dash notation: BPVC-CC-BPV
    (dash >> str("CC") >> dash >> bpvc_letter_code) |
    # Standard dotted notation
    (dot >> (
      # SSC with complex subdivision: BPVC.SSC.XI.II.V.IX
      (str("SSC") >> (dot >> roman_numeral).repeat(1)) |
      # CC = Case Code: BPVC.CC.BPV
      (str("CC") >> dot >> bpvc_letter_code >>
       (dot >> (roman_numeral | bpvc_letter_code)).maybe) |
      # Standard roman numeral subdivision: BPVC.I or BPVC.III.1.NB
      (roman_numeral >>
       (dot >> (digits | bpvc_letter_code)).maybe >>
       (dot >> bpvc_letter_code).maybe >>
       (underscore >> letters).maybe)
    ))
  )
end

# Multi-character designator codes
rule(:multi_char_code) do
  str("PVHO") | str("PASE") | str("PTC") | str("PTB") | str("PDS") | str("PCC") |
    str("V&V") | str("V V") | str("VVUQ") | str("TDP") | str("RTP") | str("RT") |
    str("RA-S") | str("RA") | str("QME") | str("QAI") | str("QEI") |
    str("NUM") | str("NQA") | str("NML") | str("OM") | str("HST") | str("HRT") |
    str("FFS") | str("TES") | str("TR") | str("STS") | str("CSD") | str("CA") |
    str("BTH") | str("BPE") | str("ANDE") | str("AED") | str("AG") | str("NM") |
    str("EA")
end
```

### Special Patterns

```ruby
# PTC special: space-separated number with optional suffix
rule(:ptc_number) do
  space >>
    (match("[0-9]").repeat(1) >> (dot >> match("[0-9]").repeat(1)).repeat) >>
    (space >> letters).maybe
end

# TR special: space-separated number
rule(:tr_number) do
  space >>
    (match("[A-Z0-9]").repeat(1) >>
     (dot >> match("[0-9A-Z]").repeat(1)).repeat >>
     (dash >> match("[0-9]").repeat(1) >>
      (dot >> match("[0-9]").repeat(1)).repeat).maybe)
end

# Number part - can start with dot (NM.1), dotted (16.5), or dash-separated (BTH-1)
rule(:number_part) do
  # Starting with dot
  (dot >> match("[0-9A-Z]").repeat(1) >>
   (dot >> match("[0-9A-Z]").repeat(1)).repeat) |
  # Dash-separated
  (dash >> match("[0-9A-Z]").repeat(1) >>
   (dot >> match("[0-9A-Z]").repeat(1)).repeat) |
  # Regular dotted numbers
  (match("[0-9A-Z]").repeat(1) >>
   (dot >> match("[0-9A-Z]").repeat(1)).repeat)
end
```

## Builder Logic

### Identifier Class Selection

The Builder uses a simple approach - all ASME identifiers use the Standard class. Complex parsing is handled in the parser, not the builder.

### Component Casting

Uses custom builder logic to extract and store attributes as hash:

```ruby
# Store all parsed attributes as-is
# No component casting - uses hash-based storage
# Complex rendering logic in Base class
```

## Preprocessing

This flavor uses minimal preprocessing:

| Pattern | Input | Output | Purpose |
|---------|-------|--------|---------|
| Dash normalization | `ASME BPVC–I` | `ASME BPVC-I` | Normalize Unicode dashes |

## Testing

### Test Coverage

- **Unit tests:** `spec/pubid_new/asme/`
- **Parser tests:** `spec/pubid_new/asme/parser_spec.rb`
- **Builder tests:** `spec/pubid_new/asme/builder_spec.rb`
- **Identifier tests:** `spec/pubid_new/asme/identifiers/`
- **Integration tests:** `spec/integration/asme_`

### Fixtures

Located in: `spec/fixtures/asme/identifiers/`

- **Pass tests:** `pass/` - Valid patterns that should parse successfully
  - Various BPVC patterns
  - Joint publisher patterns
  - Multi-character designator codes
- **Fail tests:** `fail/` - Invalid patterns that should raise errors

### Coverage Status

The ASME flavor has good test coverage for BPVC subdivisions and joint publisher patterns.

## Migration Notes

### V1 to V2 Changes

**Major architectural changes:**
1. **Three-layer separation** - Parser, Builder, and Identifier are completely separate
2. **Hash-based storage** - Uses custom Base class instead of Lutaml::Model
3. **No typed stages** - ASME explicitly does not use typed stage system

**Breaking changes:**
- `Pubid::Asme::Identifier` → `PubidNew::Asme::Identifiers::Standard`
- Hash-based attribute storage instead of component objects

**Migration guide:**
1. Replace `Pubid::Asme.parse()` with `PubidNew::Asme.parse()`
2. Use Standard class for all ASME identifiers

## References

- **Specification:** ASME Standards (https://www.asme.org/)
- **Examples:** ASME Digital Collection (https://asmedigitalcollection.asme.org/)
- **Related implementations:**
  - ANSI flavor (joint publisher support)
  - CSA flavor (dual publisher patterns)

---

## Appendix: Design Decisions

### No Typed Stages

**Context:** ASME explicitly does not use typed stages like ISO or IEC.

**Decision:** Scheme raises ArgumentError when typed stage methods are called.

**Rationale:**
- ASME standards don't have formal development stage codes
- Prevents accidental use of typed stage logic
- Explicit API contract

**Alternatives considered:**
- Return nil for typed stages - Rejected (less clear)
- Add stub typed stages - Rejected (unnecessary)

### BPVC Complex Subdivision

**Context:** BPVC (Boiler and Pressure Vessel Code) has complex subdivision notation with roman numerals, case codes, and SSC sections.

**Decision:** Parser uses explicit rules for each BPVC subdivision pattern.

**Rationale:**
- BPVC subdivisions are structurally different from other ASME codes
- Roman numerals, case codes, and SSC sections need explicit parsing
- Order matters (longest match first)

**Alternatives considered:**
- Generic pattern matching - Rejected (too ambiguous)
- Separate parsers for BPVC - Rejected (over-complication)

### Joint Publisher First-Publisher Variants

**Context:** ASME has multiple joint publisher patterns where either ASME or the other organization can appear first (CSA/ASME, API/ASME, ISO/ASME).

**Decision:** Parser has separate rules for each joint publisher pattern.

**Rationale:**
- First publisher determines parsing order
- Different organizations have different code formats
- Clear separation of patterns

**Alternatives considered:**
- Single generic joint publisher rule - Rejected (ambiguous)
- Publisher-agnostic parsing - Rejected (loses structure)
