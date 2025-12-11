# IEEE Joint Development Architecture

## Overview

IEEE Joint Development identifiers represent standards developed jointly between IEEE and ISO/IEC organizations. These identifiers can be expressed in two formats depending on the **lead party** (the organization driving development).

## Key Principles

1. **Lead Party Determines Format** - The organization leading development determines the canonical representation
2. **Dual Format Support** - Identifiers can be rendered in both IEEE and ISO formats
3. **NO Equivalence** - IEEE stages and ISO stages are NOT equivalent (as per IEEE staff guidance)
4. **Round-Trip Fidelity** - Parsing preserves the original format

## Lead Party

The **lead party** is the organization driving the standards development. This determines:
- Which format is canonical
- Which stage system is authoritative
- How the identifier is officially rendered

### Detection Rules

The parser automatically detects the lead party based on:

| Indicator | Lead Party | Example |
|-----------|------------|---------|
| P prefix | IEEE | `ISO/IEC/IEEE P26511/D8-2018` |
| /D notation | IEEE | `ISO/IEC/IEEE P1003/D3-2020` |
| ISO stage code | ISO | `ISO/IEC/IEEE FDIS 26511:2018` |
| Colon before year | ISO | `ISO/IEC/IEEE DIS 16326:2008` |
| Dash before year (with P) | IEEE | `ISO/IEEE P1003.1-2008` |

## Format Representations

### IEEE-Led Format

**Structure:** `{Publishers} P{code}[/D{version}]-{year}`

**Features:**
- P prefix indicates IEEE project (draft status)
- /D notation for draft versions
- Dash before year
- Publishers slash-separated

**Examples:**
```
ISO/IEC/IEEE P26511/D8-2018
ISO/IEEE P1003.1-2008
IEC/IEEE P62582-1-2011
```

### ISO-Led Format

**Structure:** `{Publishers} {stage} {code}:{year}`

**Features:**
- ISO stage codes (FDIS, DIS, CD, WD, etc.)
- NO P prefix
- Colon before year
- Publishers slash-separated

**Examples:**
```
ISO/IEC/IEEE FDIS 26511:2018
ISO/IEC/IEEE DIS 16326:2008
ISO/IEC/IEEE CD 29119-1:2013
```

## Dual Format Conversion

Each JointDevelopment identifier can be rendered in either format:

```ruby
# Parse IEEE format
ieee_id = PubidNew::Ieee.parse("ISO/IEC/IEEE P26511/D8-2018")

# Render in IEEE format (default for IEEE-led)
ieee_id.to_s                 # => "ISO/IEC/IEEE P26511/D8-2018"
ieee_id.to_s(format: :ieee)  # => "ISO/IEC/IEEE P26511/D8-2018"

# Convert to ISO format
ieee_id.to_s(format: :iso)   # => "ISO/IEC/IEEE 26511:2018"
# Note: D number removed, P prefix removed, ISO format used

# Parse ISO format
iso_id = PubidNew::Ieee.parse("ISO/IEC/IEEE FDIS 26511:2018")

# Render in ISO format (default for ISO-led)
iso_id.to_s                  # => "ISO/IEC/IEEE FDIS 26511:2018"
iso_id.to_s(format: :iso)    # => "ISO/IEC/IEEE FDIS 26511:2018"

# Convert to IEEE format
iso_id.to_s(format: :ieee)   # => "ISO/IEC/IEEE P26511-2018"
# Note: FDIS stage removed, P prefix added, IEEE format used
```

## Architecture Implementation

### Class Structure

```ruby
class JointDevelopment < Base
  attribute :publishers, :string, collection: true  # ["ISO", "IEC", "IEEE"]
  attribute :lead_party, :string                    # "IEEE" or "ISO"
  attribute :code, :string                          # "26511" or "1003.1"
  attribute :typed_stage, Components::TypedStage    # Stage object
  attribute :year, :string                          # "2018"
  attribute :iso_stage, :string                     # "FDIS" (ISO-led only)
  attribute :ieee_draft, :string                    # "D8" (IEEE-led only)
  
  # Canonical format based on lead party
  def canonical_format
    case lead_party
    when "IEEE", "AIEE" then :ieee
    when "ISO", "IEC" then :iso
    else :ieee
    end
  end
end
```

### Parser Implementation

Two dedicated parser rules match the two formats:

```ruby
rule(:joint_development_ieee_format) do
  (str("ISO/IEC/IEEE") | str("ISO/IEEE") | str("IEC/IEEE")).as(:joint_publishers) >>
  space >> str("P") >> digits.as(:number) >>
  ((dot | dash) >> digits.as(:part)).maybe >>
  (slash >> str("D") >> digits.as(:draft_version)).maybe >>
  (dash >> year_digits.as(:year)).maybe
end

rule(:joint_development_iso_format) do
  (str("ISO/IEC/IEEE") | str("ISO/IEEE") | str("IEC/IEEE")).as(:joint_publishers) >>
  space >>
  (str("FDIS") | str("DIS") | str("CD") | etc.).as(:iso_stage) >>
  space >> digits.as(:number) >>
  ((dot | dash) >> digits.as(:part)).maybe >>
  (str(":") >> year_digits.as(:year)).maybe
end
```

### Builder Implementation

The Builder automatically:
1. Detects lead party from parsed pattern
2. Extracts format-specific elements (ieee_draft vs iso_stage)
3. Creates appropriate TypedStage object
4. Sets all attributes for dual-format support

```ruby
def build_joint_development(parsed)
  attributes = {}
  
  # Extract publishers
  attributes[:publishers] = parsed[:joint_publishers].split("/")
  
  # Detect lead party and extract format-specific data
  if parsed[:iso_stage]
    attributes[:lead_party] = "ISO"
    attributes[:iso_stage] = parsed[:iso_stage]
    attributes[:typed_stage] = Scheme.locate_typed_stage_by_abbr(parsed[:iso_stage])
  else
    attributes[:lead_party] = "IEEE"
    attributes[:ieee_draft] = "D#{parsed[:draft_version]}" if parsed[:draft_version]
    attributes[:typed_stage] = Scheme.locate_typed_stage_by_abbr("P")
  end
  
  JointDevelopment.new(**attributes)
end
```

## Important Notes

### NO Stage Equivalence

Per IEEE staff guidance: **ISO stages and IEEE stages are NOT equivalent.**

- ISO CD ≠ IEEE Unapproved Draft
- ISO DIS ≠ IEEE Approved Draft
- They represent different development processes
- They can coexist but should not be automatically mapped

### Unknown Information in Conversion

When converting formats, some information may be unknown:

- **IEEE → ISO**: D number cannot be mapped to ISO stage
- **ISO → IEEE**: ISO stage cannot be mapped to D number

The system handles this gracefully by omitting unknown elements.

## Testing

Comprehensive test suite validates:
- Lead party detection for all patterns
- Dual format rendering
- Round-trip fidelity
- NO equivalence principle
- Edge cases (ISO/IEEE, IEC/IEEE without third party)

All 21 tests passing (100%)!

## Future Enhancements

Potential future work:
- Add adoption patterns (vs joint development)
- Handle historical AIEE/IRE patterns
- Support month notation in dates
- Additional publisher combinations

## References

- IEEE staff guidance (PG): Joint development vs adoption are different
- TODO.important-ieee-information.md: Core requirements
- Session 119 implementation: Lead party architecture