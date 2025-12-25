# CIE Architecture Design Document

**Created:** 2025-12-25 (Session 207)
**Flavor:** CIE (Commission Internationale de l'Éclairage)
**Total Fixtures:** 393 identifiers
**Complexity:** High (dual-style system, 11 identifier types)
**Expected Accuracy:** 95-98%

---

## Executive Summary

CIE is the **16th flavor** for PubID V2, representing the International Commission on Illumination. It has unique characteristics:

1. **Dual style system** - Legacy (pre-2001) vs Current (2001+)
2. **Two date separators** - Dash for legacy, colon for current
3. **Three language formats** - Slash-prefix, parenthetical, translation-year
4. **11 identifier types** - From standards to conference to bundles

**Key Challenge:** Auto-detecting legacy vs current style for round-trip fidelity.

---

## Fixture Analysis Results

### Distribution by Type

| Type | Count | Percentage | Example |
|------|-------|------------|---------|
| Standards (no S) | ~225 | 57% | `CIE 145:2002` |
| Joint Published | 25 | 6% | `CIE ISO 11664-1:2019` |
| S-Prefixed Standards | 18 | 5% | `CIE S 013/E:2003` |
| Identical with ISO | 18 | 5% | `CIE S 006.1/1998 (ISO 16508:1999)` |
| Conference (x-prefix) | 47 | 12% | `CIE x038:2013` |
| Draft Stages | 6 | 2% | `CIE DIS 024/E:2013` |
| Supplements | ~35 | 9% | `CIE 121-SP1:2009` |
| Corrigenda | 2 | <1% | `CIE 232:2019/Cor1:2020` |
| Special | 17 | 4% | Bundles, tutorials, ranges |

---

## Class Hierarchy (MECE Design)

```
PubidNew::Cie::Identifier (ultimate parent)
    │
    ├─ PubidNew::Cie::SingleIdentifier (base documents)
    │   ├─ Standard                          # CIE [S] nnn (most common)
    │   ├─ TechnicalReport                   # Implied type (no explicit marker)
    │   └─ TutorialBundle                    # Special text format
    │
    ├─ PubidNew::Cie::SupplementIdentifier (amendments to base)
    │   ├─ Supplement                        # -SPN notation
    │   └─ Corrigendum                       # /CorN notation
    │
    ├─ PubidNew::Cie::JointPublishedIdentifier (copublisher patterns)
    │   ├─ JointWithIso                      # CIE ISO nnn
    │   ├─ JointWithIec                      # CIE IEC nnn
    │   └─ JointWithIsoCie                   # CIE ISO/CIE TR nnn
    │
    ├─ IdenticalIdentifier                   # With ISO reference
    ├─ DualPublishedIdentifier               # Slash-separated IEC
    ├─ ConferenceIdentifier                  # X-prefix
    └─ BundleIdentifier                      # Comma-separated list
```

**Total:** 11 mutually exclusive identifier types (MECE)

---

## Component Architecture

### 1. Code Component (Critical)

Handles three number formats with style awareness:

```ruby
module PubidNew
  module Cie
    module Components
      class Code < Lutaml::Model::Serializable
        attribute :number, :string        # "013", "170", "198"
        attribute :part, :string          # "1", "2", "3"
        attribute :iteration, :string     # "1" in "006.1"
        attribute :style, :symbol         # :legacy or :current
        
        def to_s
          result = number
          
          # Handle iteration (always dot separator)
          if iteration
            result += ".#{iteration}"
          # Handle part (separator depends on style)
          elsif part
            # Legacy uses slash or dot, current uses dash
            separator = style == :legacy ? "/" : "-"
            result += "#{separator}#{part}"
          end
          
          result
        end
        
        # Parse code string
        def self.parse(code_str, style: :current)
          # Detect format and extract parts
          # ...
        end
      end
    end
  end
end
```

**Examples:**
- `006.1` → number=006, iteration=1 (dot always)
- `170-1` → number=170, part=1, style=:current (dash)
- `170/1` → number=170, part=1, style=:legacy (slash)
- `13.3` → number=13, iteration=3 (dot for decimal)

---

### 2. Date Component with Style

```ruby
module Components
  class Date < Lutaml::Model::Serializable
    attribute :year, :string
    attribute :separator, :symbol   # :dash or :colon
    
    def to_s(separator_override = nil)
      sep = separator_override || (separator == :dash ? "-" : ":")
      "#{sep}#{year}"
    end
    
    # Detect style from separator
    def style
      separator == :dash ? :legacy : :current
    end
  end
end
```

---

### 3. Language Component (Multi-Format)

```ruby
module Components
  class Language < Lutaml::Model::Serializable
    attribute :code, :string              # "E", "DE", "RU", "en"
    attribute :format, :symbol            # :slash, :paren, :paren_year
    attribute :translation_year, :string  # "2021" in "RU-2021"
    
    def to_s
      case format
      when :slash
        "/#{code}"                         # /E, /F, /G (legacy)
      when :paren
        "(#{code})"                        # (DE), (ES), (en)
      when :paren_year
        " (#{code}-#{translation_year})"  # (RU-2021)
      end
    end
  end
end
```

---

### 4. TypedStage (for Draft Stages)

```ruby
TYPED_STAGES = [
  Components::TypedStage.new(
    abbr: ["DIS"],
    stage_code: "draft_international_standard",
    type_code: "standard"
  ),
  Components::TypedStage.new(
    abbr: ["DS"],
    stage_code: "draft_standard",
    type_code: "standard"
  ),
].freeze
```

---

## Parser Strategy

### Date Separator Detection (Critical)

```ruby
# Two distinct date rules
rule(:legacy_date) do
  dash >> year_digits.as(:year) >> str("-").as(:separator)
end

rule(:current_date) do
  colon >> year_digits.as(:year) >> str(":").as(:separator)
end

rule(:date) do
  current_date | legacy_date
end
```

**Builder extracts separator:**
```ruby
def build_date(parsed)
  {
    year: extract_value(parsed[:year]),
    separator: parsed[:separator] == "-" ? :dash : :colon
  }
end
```

---

### Number Format Parsing

```ruby
rule(:code_with_iteration) do
  # "006.1" - iteration format (digit.digit)
  digits.as(:number) >> dot >> digits.as(:iteration)
end

rule(:code_with_part_legacy) do
  # "170/1" - legacy slash separator
  digits.as(:number) >> slash >> digits.as(:part) >> str("/").as(:part_sep)
end

rule(:code_with_part_current) do
  # "170-1" - current dash separator
  digits.as(:number) >> dash >> digits.as(:part) >> str("-").as(:part_sep)
end

rule(:code_simple) do
  digits.as(:number)
end

rule(:code) do
  code_with_iteration | code_with_part_legacy | code_with_part_current | code_simple
end
```

---

### Language Format Parsing

```ruby
rule(:language_slash) do
  # /E, /F, /G (legacy format)
  slash >> upper.as(:lang_code) >> str("/").as(:lang_format)
end

rule(:language_paren) do
  # (DE), (ES), (CN), (en)
  str("(") >> match("[A-Za-z]").repeat(2).as(:lang_code) >> str(")") >> str("(").as(:lang_format)
end

rule(:language_paren_year) do
  # (RU-2021) - translation year
  space >> str("(") >> upper.repeat(2).as(:lang_code) >> dash >> 
  year_digits.as(:trans_year) >> str(")")
end

rule(:language) do
  language_paren_year | language_paren | language_slash
end
```

---

### S-Prefix Detection

```ruby
rule(:s_prefix) do
  str("S") >> space  # Explicit "S" for Standard
end

rule(:standard_identifier) do
  str("CIE") >> space >>
  s_prefix.maybe.as(:s_prefix) >>
  code >>
  language.maybe >>
  date
end
```

---

### Conference X-Prefix

```ruby
rule(:conference_identifier) do
  str("CIE") >> space >>
  str("x").as(:conference) >>
  digits.as(:number) >>
  date >>
  # Optional amendment
  (space >> str("Amendment") >> space >> digits.as(:amd_number)).maybe
end
```

---

## Builder Strategy

### Style Detection Logic

```ruby
class Builder
  def build(parsed_hash)
    # Detect style from date separator
    style = detect_style(parsed_hash)
    
    # Pass style to all components
    attributes = extract_attributes(parsed_hash, style: style)
    
    # Select identifier class
    identifier_class = determine_class(parsed_hash)
    identifier_class.new(**attributes)
  end
  
  private
  
  def detect_style(parsed_hash)
    # Check date separator
    if parsed_hash[:separator] == "-"
      :legacy
    elsif parsed_hash[:separator] == ":"
      :current
    else
      # Fallback: year-based heuristic
      year = extract_value(parsed_hash[:year]).to_i
      year <= 2001 ? :legacy : :current
    end
  end
  
  def determine_class(parsed_hash)
    # Joint published (check first - most specific)
    return JointWithIso if parsed_hash[:copublisher] == "ISO"
    return JointWithIec if parsed_hash[:copublisher] == "IEC"
    return JointWithIsoCie if parsed_hash[:joint_iso_cie]
    
    # Identical (has ISO reference in parentheses)
    return IdenticalIdentifier if parsed_hash[:iso_reference]
    
    # Dual published (slash separator with IEC)
    return DualPublishedIdentifier if parsed_hash[:iec_dual]
    
    # Conference (x-prefix)
    return ConferenceIdentifier if parsed_hash[:conference]
    
    # Bundle (comma-separated)
    return BundleIdentifier if parsed_hash[:bundle_list]
    
    # Tutorial Bundle
    return TutorialBundle if parsed_hash[:tutorial_bundle]
    
    # Supplement (-SPN notation)
    return Supplement if parsed_hash[:supplement_number]
    
    # Corrigendum (/CorN notation)
    return Corrigendum if parsed_hash[:corrigendum_number]
    
    # Draft stages
    return Standard if parsed_hash[:typed_stage]
    
    # Standard (default)
    Standard
  end
end
```

---

## Identifier Implementations

### Standard Identifier

```ruby
module Identifiers
  class Standard < SingleIdentifier
    attribute :s_prefix, :boolean, default: -> { false }
    attribute :code, Components::Code
    attribute :date, Components::Date
    attribute :language, Components::Language
    attribute :typed_stage, Components::TypedStage  # For DIS/DS
    
    def to_s
      parts = ["CIE"]
      parts << "S" if s_prefix
      
      # Stage (DIS/DS) before code
      parts << typed_stage.abbr.first if typed_stage
      
      # Code
      parts << code.to_s
      
      # Language (slash format comes before date for legacy)
      if language && language.format == :slash
        parts << language.to_s.delete("/")  # Add without slash
      end
      
      # Date
      parts << date.to_s
      
      # Language (parenthetical comes after date)
      if language && language.format != :slash
        result parts.join(" ") + language.to_s
      else
        parts.join(" ")
      end
    end
  end
end
```

---

### Conference Identifier

```ruby
module Identifiers
  class Conference < Identifier
    attribute :conference_number, Components::Code
    attribute :date, Components::Date
    attribute :amendment_number, :string  # Optional
    
    def to_s
      result = "CIE x#{conference_number}#{date}"
      result += " Amendment #{amendment_number}" if amendment_number
      result
    end
  end
end
```

---

### Supplement Identifier

```ruby
module Identifiers
  class Supplement < SupplementIdentifier
    attribute :base_identifier, Identifier  # Recursive
    attribute :supplement_number, :string   # "1", "2"
    attribute :supplement_part, :string     # "1" in "SP1.1"
    attribute :year, :string
    
    def to_s
      sp = "SP#{supplement_number}"
      sp += ".#{supplement_part}" if supplement_part
      "#{base_identifier}-#{sp}:#{year}"
    end
  end
end
```

---

### Joint Published Identifier

```ruby
module Identifiers
  class JointWithIso < Identifier
    attribute :copublisher, :string, default: -> { "ISO" }
    attribute :code, Components::Code
    attribute :date, Components::Date
    attribute :language, Components::Language
    attribute :type, :string  # "TR" for Technical Report
    
    def to_s
      parts = ["CIE", copublisher]
      parts << type if type  # TR, etc.
      parts << code.to_s
      result = parts.join(" ") + date.to_s
      result += language.to_s if language
      result
    end
  end
end
```

---

## Parser Architecture

### Main Identifier Rule

```ruby
rule(:identifier) do
  # Longest/most specific patterns first
  joint_published_identifier |
  identical_identifier |
  dual_published_identifier |
  bundle_identifier |
  tutorial_bundle_identifier |
  conference_identifier |
  supplement_identifier |
  corrigendum_identifier |
  standard_identifier  # Most generic, last
end
```

---

### Example Parsing Flows

**1. Legacy Standard:** `CIE 032-1977`
```
Parser: { number: "032", separator: "-", year: "1977" }
  ↓
Builder: { code: Code(number="032"), date: Date(year="1977", separator=:dash), style: :legacy }
  ↓
Standard.new(code: ..., date: ..., style: :legacy)
  ↓
to_s → "CIE 032-1977"
```

**2. Current Standard:** `CIE 145:2002`
```
Parser: { number: "145", separator: ":", year: "2002" }
  ↓
Builder: { code: Code(number="145"), date: Date(year="2002", separator=:colon), style: :current }
  ↓
Standard.new(code: ..., date: ..., style: :current)
  ↓
to_s → "CIE 145:2002"
```

**3. With S Prefix & Language:** `CIE S 013/E:2003`
```
Parser: { s_prefix: true, number: "013", lang_code: "E", lang_format: "/", separator: ":", year: "2003" }
  ↓
Builder: { s_prefix: true, code: Code("013"), language: Language(code="E", format=:slash), date: Date(year="2003", separator=:colon) }
  ↓
Standard.new(s_prefix: true, code: ..., language: ..., date: ...)
  ↓
to_s → "CIE S 013/E:2003"
```

**4. Conference:** `CIE x038:2013`
```
Parser: { conference: true, number: "038", separator: ":", year: "2013" }
  ↓
Builder: { conference_number: Code("038"), date: Date(year="2013", separator=:colon) }
  ↓
Conference.new(conference_number: ..., date: ...)
  ↓
to_s → "CIE x038:2013"
```

---

## Critical Implementation Details

### 1. Year 2001 Transition Handling

**Problem:** 2001 has BOTH legacy and current formats

**Solution:** Preserve separator from original parse

```ruby
# Parser captures actual separator used
# Builder doesn't assume based on year alone
# Identifier renders using captured format

# Examples from fixtures:
"CIE S 004/E-2001"  # Legacy format (dash)
"CIE 144:2001"      # Current format (colon)
```

---

### 2. Range Handling

**Pattern:** `CIE 146/147:2002`

**Two approaches:**

**Option A: Bundle** (treat as bundle of two)
```ruby
BundleIdentifier.new(
  identifiers: [
    Standard.new(code: "146", year: "2002"),
    Standard.new(code: "147", year: "2002")
  ]
)
```

**Option B: Code range** (simpler)
```ruby
Standard.new(
  code: Code.new(number: "146/147"),  # Store as single code
  date: Date.new(year: "2002", separator: :colon)
)
```

**Recommendation:** Option B (simpler, cleaner)

---

### 3. Supplement Part Notation

**Pattern:** `CIE 198-SP1.4:2011`

**Structure:**
- Base: `CIE 198`
- Supplement: `SP1.4` (supplement 1, part 4)
- Year: `2011`

```ruby
Supplement.new(
  base_identifier: Standard.parse("CIE 198"),
  supplement_number: "1",
  supplement_part: "4",
  year: "2011"
)
```

---

### 4. Corrigendum on Supplement

**Pattern:** `CIE 198-SP1.4:2011/Cor1:2013`

**Recursive structure:**
```ruby
Corrigendum.new(
  base_identifier: Supplement.new(
    base_identifier: Standard.parse("CIE 198"),
    supplement_number: "1",
    supplement_part: "4",
    year: "2011"
  ),
  corrigendum_number: "1",
  year: "2013"
)
```

---

## Testing Strategy

### Unit Tests per Component

**Code Component: (10 tests)**
- Simple number
- With part (legacy slash)
- With part (current dash)
- With iteration (dot)
- Style detection

**Date Component: (6 tests)**
- Legacy dash separator
- Current colon separator
- Style property
- Round-trip

**Language Component: (10 tests)**
- Slash format (/E)
- Paren format (DE)
- Paren with year (RU-2021)
- Lowercase (en)
- Format detection

### Integration Tests per Identifier

**Standard: (30 tests)**
- Simple (no S, no date)
- With S prefix
- With year (legacy dash)
- With year (current colon)
- With part
- With iteration
- With language (slash)
- With language (paren)
- Round-trip all formats

**Conference: (10 tests)**
- Simple x-prefix
- With amendment
- Legacy vs current
- Round-trip

**Supplement: (8 tests)**
- Simple supplement
- With part (SP1.4)
- On base identifier
- Round-trip

**Total Expected: 150+ unit/integration tests**

---

## Performance Targets

**Based on other flavors:**
- Parse time: <1ms per identifier
- Memory: <1KB per parsed object
- Classification: All 393 fixtures in <1 second

---

## Risk Mitigation

### Risk 1: Legacy/Current Detection Failure

**Symptom:** Wrong separator in rendered output
**Mitigation:** 
- Parser explicitly captures separator
- Builder preserves exact separator
- Test round-trip on all styles

**Fallback:** Year-based heuristic (<=2001 = legacy)

---

### Risk 2: Language Format Confusion

**Symptom:** Wrong language rendering
**Mitigation:**
- Language component stores format type
- Parser detects format from structure
- Separate rules for each format

**Test Coverage:** All 3 formats explicitly tested

---

### Risk 3: Number Part Ambiguity

**Symptom:** "13.3" vs "006.1" confusion
**Mitigation:**
- Leading zeros indicate document (006)
- No leading zeros = possible iteration
- Parser distinguishes with lookahead

---

## Implementation Timeline

| Session | Focus | Files | Tests | Cumulative |
|---------|-------|-------|-------|------------|
| 207 | **Architecture** | Design docs | - | Design ✅ |
| 208 | **Core** | 9 files | 50 | ~38% |
| 209 | **Joint/Identical** | 3 files | 44 | ~49% |
| 210 | **Stages** | 2 files | 6 | ~51% |
| 211 | **Supplements** | 3 files | 16 | ~55% |
| 212 | **Conference** | 4 files | 49 | ~67% |
| 213 | **Testing** | Test suite | 150+ | **95-98%** |

**Total:** 8-10 hours, 24 files, 200+ tests

---

## Success Metrics

### Per Session
- Clear objectives achieved
- Tests passing for new code
- No regressions in other flavors
- Documentation updated

### Final (Session 213)
- ✅ 11 identifier types implemented
- ✅ 373-385/393 passing (95-98%)
- ✅ Round-trip fidelity on all styles
- ✅ Comprehensive test coverage
- ✅ Complete documentation

---

## Next Steps (Session 208)

1. Create directory structure
2. Implement Scheme class
3. Create Code component with dual style
4. Create Date component with separator
5. Create Parser foundation
6. Implement Standard identifier
7. Basic tests (30-40 tests)
8. Validate with ~50 fixtures

**Timeline:** 120 minutes
**Expected:** ~150/393 (38%) working

---

**Created:** 2025-12-25 (Session 207)
**Status:** Architecture design COMPLETE ✅
**Ready for:** Session 208 implementation

**Key Innovation:** Dual-style system with automatic detection and preservation
