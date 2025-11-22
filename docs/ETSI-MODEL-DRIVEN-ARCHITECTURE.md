# ETSI PubID v2 - MODEL-DRIVEN Architecture

## Overview

ETSI (European Telecommunications Standards Institute) implementation following the proven MODEL-DRIVEN architecture.

**Completion Target**: 24,718 test cases at 100%

## Architecture Summary

### Identifier Types (15 Types, 3 Classes)

All ETSI types share identical structure - only type prefix differs.

| # | Type | Prefix | Full Name |
|---|------|--------|-----------|
| 1 | EN | EN | European Standard |
| 2 | ES | ES | ETSI Standard |
| 3 | EG | EG | ETSI Guide |
| 4 | TS | TS | Technical Specification |
| 5 | ETR | ETR | European Telecommunications Report |
| 6 | ETS | ETS | European Telecommunications Standard |
| 7 | I-ETS | I-ETS | Provisional ETS |
| 8 | TBR | TBR | Technical Basis for Regulation |
| 9 | TCRTR | TCRTR | Technical Committee Report - Technical Report |
| 10 | NET | NET | Norme Européenne de Télécommunication |
| 11 | GR | GR | Group Report |
| 12 | GS | GS | Group Specification |
| 13 | SR | SR | Special Report |
| 14 | TR | TR | Technical Report |
| 15 | GTS | GTS | GSM Technical Specification |

**Classes**:
- `EtsiStandard` (base, with type parameter)
- `Amendment` (supplement)
- `Corrigendum` (supplement)

### Components (3 Total)

| Component | Class | Attributes | Purpose |
|-----------|-------|------------|---------|
| Code | `Components::Code` | number, minor, parts | Complex number with variants |
| Version | `Components::Version` | version | V1.2.3 notation |
| Date | `PubidNew::Components::Date` | year, month | (YYYY-MM) notation |

### Inheritance Hierarchy

```
Identifier (base)
├── EtsiStandard (single class, type parameter)
│   All 15 types use this class with different type values
└── SupplementIdentifier (for supplements)
    ├── Amendment (/A{n})
    └── Corrigendum (/C{n})
```

## Format Pattern

### Standard Format
```
ETSI TYPE NUMBER[-PART] V{version} ({date})
```

### Examples
```
ETSI GS ZSM 012 V1.1.1 (2022-12)         # Basic
ETSI GR ZSM 009-3 V1.1.1 (2023-08)       # With part
ETSI GTS GSM 02.01 V5.5.0 (1999-01)      # GSM format
ETSI EN 123-ABC V2.0.0 (2020-05)         # Complex number
ETSI EN 300 123/A1 V1.2.0 (2021-03)      # With amendment
ETSI TS 102 456/C2 V3.1.0 (2022-06)      # With corrigendum
```

## Component Architecture

### Code Component

Complex number handling with three variants:

**Variant 1: Simple Number**
```
001, 123, 456
```

**Variant 2: GSM Format**
```
GSM 02.01 => "GSM 02.01" or just "02.01"
```

**Variant 3: Complex Format**
```
ABC 123        => prefix + space + number
ABC-DEF 123    => prefix + dash + prefix + space + number
```

```ruby
class Components::Code < Lutaml::Model::Serializable
  attribute :number, :string        # Main number (can be GSM 02.01, ABC 123, etc.)
  attribute :minor, :string         # Optional minor part
  attribute :parts, :string, collection: true  # Parts like -1, -3

  def to_s
    result = number.to_s
    result += " #{minor}" if minor
    result += parts.map { |p| "-#{p}" }.join if parts&.any?
    result
  end
end
```

### Version Component

```ruby
class Components::Version < Lutaml::Model::Serializable
  attribute :version, :string  # e.g., "1.1.1", "2.0.0"

  def to_s
    "V#{version}"
  end
end
```

## Identifier Details

### EtsiStandard

**Attributes**:
- `type`: String (EN, ES, EG, TS, ETR, ETS, I-ETS, TBR, TCRTR, NET, GR, GS, SR, TR, GTS)
- `code`: Code object
- `version`: Version object (mandatory)
- `date`: Date object (mandatory, year + month)

**Rendering**:
```
ETSI {type} {code} {version} ({date})
```

### Amendment

**Attributes**:
- `base`: EtsiStandard object
- `number`: Integer (amendment number)

**Rendering**:
```
{base}/A{number}
```

### Corrigendum

**Attributes**:
- `base`: EtsiStandard object
- `number`: Integer (corrigendum number)

**Rendering**:
```
{base}/C{number}
```

## Parser Grammar

```
identifier = ETSI type space code version space date supplements?

type = EN | ES | EG | TS | ETR | ETS | I-ETS | TBR | TCRTR | NET | GR | GS | SR | TR | GTS

code = gsm_number | complex_number | simple_number

gsm_number = GSM? dd.dd

complex_number = letters (dash letters)? space digits

simple_number = digits

parts = (-part)+

version = V version_string

date = (YYYY-MM)

amendment = /A digits

corrigendum = /C digits
```

## Directory Structure

```
lib/pubid_new/etsi/
├── components/
│   ├── code.rb
│   └── version.rb
├── identifiers/
│   ├── base.rb
│   ├── etsi_standard.rb
│   ├── amendment.rb
│   └── corrigendum.rb
├── identifier.rb
├── single_identifier.rb
├── supplement_identifier.rb
├── parser.rb
└── builder.rb
```

## Implementation Phases

### Phase 1: Architecture Planning ✅
### Phase 2: Components (Code, Version)
### Phase 3: Base Infrastructure
### Phase 4: Identifier Types (EtsiStandard, Amendment, Corrigendum)
### Phase 5: Parser
### Phase 6: Builder
### Phase 7: Testing (24,718 tests)
### Phase 8: Documentation

## Key Differences from JIS

- **Simpler type system**: Single class with type parameter vs multiple classes
- **Mandatory attributes**: Version and date are required (not optional)
- **Complex number formats**: GSM notation, letter prefixes
- **No all-parts logic**: Straightforward comparison
- **No Japanese characters**: Standard ASCII only

## Success Criteria

- ✅ All 24,718 tests pass
- ✅ MODEL-DRIVEN architecture
- ✅ Single EtsiStandard class handles all 15 types
- ✅ Complex number parsing works
- ✅ Version and date components
- ✅ Clean supplement pattern

Starting implementation now.