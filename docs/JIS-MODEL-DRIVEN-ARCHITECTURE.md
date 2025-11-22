# JIS PubID v2 - MODEL-DRIVEN Architecture

## Overview

JIS (Japanese Industrial Standards) implementation following the proven MODEL-DRIVEN architecture from IEC.

**Completion Target**: 10,635 test cases at 100%

## Architecture Summary

### Identifier Types (5 Total)

| # | Type | Class | Base Class | Key Attributes |
|---|------|-------|------------|----------------|
| 1 | Standard | `JapaneseIndustrialStandard` | `SingleIdentifier` | code, year, language, all_parts |
| 2 | Technical Report | `TechnicalReport` | `SingleIdentifier` | code, year, language |
| 3 | Technical Specification | `TechnicalSpecification` | `SingleIdentifier` | code, year, language |
| 4 | Amendment | `Amendment` | `SupplementIdentifier` | base, number, year |
| 5 | Explanation | `Explanation` | `SupplementIdentifier` | base, number, year |

### Components (2 Total)

| Component | Class | Attributes | Purpose |
|-----------|-------|------------|---------|
| Code | `Components::Code` | series, number, parts | Series+number+parts structure |
| Publisher | Always "JIS" | N/A | Fixed publisher |

### Inheritance Hierarchy

```
Identifier (base)
├── SingleIdentifier (for regular published documents)
│   ├── JapaneseIndustrialStandard (default, no type prefix)
│   ├── TechnicalReport (TR prefix)
│   └── TechnicalSpecification (TS prefix)
└── SupplementIdentifier (for supplements)
    ├── Amendment (/AMD N:YYYY)
    └── Explanation (/EXPL N)
```

## Format Patterns

### Standard Formats

```
JIS SERIES NUMBER:YEAR
JIS SERIES NUMBER-PART:YEAR
JIS SERIES NUMBER-PART-SUBPART:YEAR
JIS SERIES NUMBER:YEAR(LANG)
JIS SERIES NUMBER（規格群）
```

### Type-Specific Formats

```
JIS TR SERIES NUMBER:YEAR          # Technical Report
JIS TS SERIES NUMBER:YEAR          # Technical Specification
```

### Supplement Formats

```
JIS SERIES NUMBER:YEAR/AMD N:YEAR  # Amendment
JIS SERIES NUMBER:YEAR/EXPL        # Explanation (no number)
JIS SERIES NUMBER:YEAR/EXPL N      # Explanation (with number)
```

### Examples

```
JIS A 0001:1999                     # Basic standard
JIS B 0060-1:2015                   # With part
JIS C 61000-3-2:2019                # Multi-level parts
JIS Z 8301:2019(E)                  # With language
JIS C 0617（規格群）                 # All parts
JIS TR Z 8301:2019                  # Technical report
JIS TS Z 0030-1:2017                # Technical specification
JIS A 0001:1999/AMD 1:2000          # Amendment
JIS K 2151:2004/EXPL                # Explanation
```

## Component Architecture

### Code Component

```ruby
class Components::Code < Lutaml::Model::Serializable
  attribute :series, :string      # A-Z
  attribute :number, :integer     # Required
  attribute :parts, :integer, collection: true  # Optional multi-level

  def to_s
    result = "#{series} #{number}"
    result += parts.map { |p| "-#{p}" }.join if parts&.any?
    result
  end
end
```

**Rendering Logic**:
- Series: Single letter A-Z
- Number: Integer
- Parts: Array of integers, rendered as `-PART[-SUBPART[-...]]`

## Identifier Type Details

### 1. JapaneseIndustrialStandard (Base/Default)

**Attributes**:
- `code`: Code object (series + number + parts)
- `year`: Integer (optional)
- `language`: String ("E" or "J", optional)
- `all_parts`: Boolean (default false)

**Rendering**:
```
JIS {code}[:{year}][(language)][（規格群）]
```

**Examples**:
- `JIS A 0001:1999`
- `JIS C 61000-3-2:2019(E)`
- `JIS B 0060（規格群）`

### 2. TechnicalReport

**Type Prefix**: `TR`

**Rendering**:
```
JIS TR {code}[:{year}]
```

**Examples**:
- `JIS TR Z 8301:2019`
- `JIS TR B 0035:2019`

### 3. TechnicalSpecification

**Type Prefix**: `TS`

**Rendering**:
```
JIS TS {code}[:{year}]
```

**Examples**:
- `JIS TS Z 8301:2019`
- `JIS TS Z 0030-1:2017`

### 4. Amendment

**Attributes**:
- `base`: Identifier object (base document)
- `number`: Integer (amendment number)
- `year`: Integer (amendment year)

**Rendering**:
```
{base}/AMD {number}:{year}
```

**Examples**:
- `JIS A 0001:1999/AMD 1:2000`
- `JIS X 0208:1997/AMD 1:2012`

**Note**: Parser accepts both `/AMD` and `/AMENDMENT`, normalizes to `/AMD`

### 5. Explanation

**Attributes**:
- `base`: Identifier object (base document)
- `number`: Integer (optional explanation number)
- `year`: Integer (optional, from base)

**Rendering**:
```
{base}/EXPL[ {number}]
```

**Examples**:
- `JIS K 2151:2004/EXPL`
- `JIS K 2249-4:2011/EXPL 4`

**Note**: Parser accepts both `/EXPL` and `/EXPLANATION`, normalizes to `/EXPL`

## Special Features

### Japanese Character Normalization

Parser must handle full-width Japanese characters and normalize to ASCII:

| Japanese | ASCII | Usage |
|----------|-------|-------|
| ｰ (full-width dash) | - | Part separator |
| 　(full-width space) | (space) | Token separator |
| ： (full-width colon) | : | Year separator |
| （ ） | ( ) | Language/all-parts |

### All-Parts Logic

When `all_parts = true`:
- Comparison ignores year, part, and all_parts attributes
- Matches any identifier with same series and number
- Example: `JIS C 0617（規格群）` matches `JIS C 0617-2:2017`

### Identifier Comparison

```ruby
def ==(other)
  if all_parts? || other.all_parts?
    # Compare only series and number
    return to_h.reject { |k, _| [:year, :part, :all_parts].include?(k) } ==
           other.to_h.reject { |k, _| [:year, :part, :all_parts].include?(k) }
  end
  super # Normal comparison
end
```

## Parse<br Flow

```
Input String
    ↓
[Japanese char normalization]
    ↓
Parser (Parslet)
    ↓
Hash tree
    ↓
Builder
    ↓
Identifier Objects
```

### Parser Grammar

```
identifier = [JIS] [space] [type] [space] series [space] number parts* [:year] [(language)] [all_parts] [supplements]

type = TR | TS
series = [A-Z]
number = digits
parts = (-digits)+
year = :YYYY
language = (E) | (J)
all_parts = （規格群） | (規格群)
supplements = (amendment | explanation)+

amendment = /AMD digits :YYYY
explanation = /EXPL [digits]
```

### Builder Logic

1. Normalize Japanese characters first
2. Extract type from prefix (TR/TS or default)
3. Build Code object from series + number + parts
4. Check for supplements
5. If supplements, recursively build base document
6. Return appropriate identifier type

## Directory Structure

```
lib/pubid_new/jis/
├── components/
│   └── code.rb
├── identifiers/
│   ├── base.rb
│   ├── japanese_industrial_standard.rb
│   ├── technical_report.rb
│   ├── technical_specification.rb
│   ├── amendment.rb
│   └── explanation.rb
├── identifier.rb
├── single_identifier.rb
├── supplement_identifier.rb
├── parser.rb
└── builder.rb
```

## Implementation Phases

### Phase 1: Architecture Planning ✅
- Document types, components, hierarchy
- Plan parser grammar
- Define rendering rules

### Phase 2: Components (0.5 days)
- `Components::Code` with series, number, parts

### Phase 3: Base Infrastructure (1 day)
- `Identifier` (base class)
- `SingleIdentifier` (for regular documents)
- `SupplementIdentifier` (for AMD/EXPL)

### Phase 4: Identifier Types (1 day)
- `JapaneseIndustrialStandard`
- `TechnicalReport`
- `TechnicalSpecification`
- `Amendment`
- `Explanation`

### Phase 5: Parser (1 day)
- Parslet grammar with Japanese char support
- Type detection
- Supplement parsing

### Phase 6: Builder (1 day)
- Object construction from parsed data
- Recursive supplement building
- Type resolution

### Phase 7: Testing & Iteration (1 day)
- Run against 10,635 test cases
- Fix failures iteratively
- Achieve 100% pass rate

### Phase 8: Documentation (0.5 days)
- Update README
- Document architecture
- Update status tracker

## Key Differences from IEC

### Simpler Structure
- Only 5 types vs IEC's 22
- No draft stages (no TYPED_STAGES)
- No copublishers (always JIS)
- No wrapper types (no VAP, Sheet, Fragment, Consolidated)

### Unique Features
- Japanese character normalization
- All-parts notation with special comparison logic
- Series letter (A-Z) as part of code

### Same Patterns
- MODEL-DRIVEN architecture (objects, not strings)
- Supplement pattern (base + supplement identifier)
- Separation of concerns (Parser/Builder/Identifier)
- MECE principle

## Success Criteria

- ✅ All 10,635 tests pass
- ✅ MODEL-DRIVEN architecture (no strings in attributes)
- ✅ Clean separation of concerns
- ✅ Japanese character normalization works
- ✅ All-parts comparison logic correct
- ✅ Supplement recursive structure works
- ✅ No anti-patterns (TYPE_MAP, hardcoded rendering)

## Test Categories

From jis-pubids.txt:
- Basic standards: `JIS A 0001:1999`
- With parts: `JIS B 0060-1:2015`
- Multi-level parts: `JIS C 61000-3-2:2019`
- With language: `JIS Z 8301:2019(E)`
- All-parts: `JIS C 0617（規格群）`
- Technical reports: `JIS TR Z 8301:2019`
- Technical specifications: `JIS TS Z 0030-1:2017`
- Amendments: `JIS A 0001:1999/AMD 1:2000`
- Explanations: `JIS K 2151:2004/EXPL`
- Japanese characters: `JISX0902-1:2019` → `JIS X 0902-1:2019`

## Implementation Start

Ready to proceed with Phase 2: Components.