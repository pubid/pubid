## System Architecture

PubID V2 uses a **three-layer MODEL-DRIVEN architecture** with strict separation of concerns.

### Three-Layer Design

```
Input String ("ISO/IEC 27001:2013")
    ↓
┌──────────────────────────┐
│    Parser Layer          │  Grammar-based parsing (Parslet)
│  (Syntax → Parse Tree)   │  - Pattern matching
└────────┬─────────────────┘  - Tokenization
         │ Hash tree          - No business logic
         ↓
┌──────────────────────────┐
│    Builder Layer         │  Object construction
│  (Tree → Attributes)     │  - Type selection
└────────┬─────────────────┘  - Component creation
         │ Model objects      - Special handling
         ↓
┌──────────────────────────┐
│    Identifier Layer      │  Lutaml::Model classes
│  (Attributes → String)   │  - Business logic
└────────┬─────────────────┘  - Rendering (#to_s)
         │
         ↓
Output String ("ISO/IEC 27001:2013")
```

**Key Principle**: Each layer has ONE responsibility and doesn't know about implementation details of other layers.

### Source Code Organization

```
lib/pubid_new/{flavor}/
├── {flavor}.rb              # Scheme (registry, parse entry point)
├── parser.rb                # Parslet grammar (syntax only)
├── builder.rb               # Object construction
├── identifier.rb            # Base identifier class
├── single_identifier.rb     # For base documents
├── supplement_identifier.rb # For amendments/corrigenda
├── components/              # Reusable components
│   ├── publisher.rb
│   ├── code.rb
│   └── {flavor}_specific.rb
└── identifiers/             # Concrete identifier types
    ├── base.rb              # Shared logic
    ├── international_standard.rb
    ├── technical_report.rb
    ├── amendment.rb
    └── ...

spec/pubid_new/{flavor}/
├── identifier_spec.rb       # Integration tests
├── parser_spec.rb           # Parser unit tests
├── builder_spec.rb          # Builder unit tests
└── identifiers/
    └── *_spec.rb            # Per-class tests
```

### Component Architecture

All identifiers use shared components for common attributes:

| Component | Purpose | Example |
|-----------|---------|---------|
| `Publisher` | Organization name + copublishers | ISO/IEC/IEEE |
| `Code` | Generic string values | Number, part, iteration |
| `Date` | Year-based dates | 2013, 2024 |
| `Type` | Document type | TR, TS, PAS, Guide |
| `Language` | Language codes | E/F/R (English/French/Russian) |
| `Stage` | Development stage | WD, CD, DIS, FDIS |
| `TypedStage` | Combined stage+type | FDAM, PDAM, DTR, DTS |

**Key Design**: Components are Lutaml::Model classes with proper serialization

### Class Hierarchies

#### ISO Example

```
PubidNew::Identifier (ultimate parent)
    │
    ├─ PubidNew::Iso::Identifier (flavor base)
    │   │
    │   ├─ SingleIdentifier (base documents)
    │   │   ├─ InternationalStandard (default)
    │   │   ├─ Guide
    │   │   ├─ TechnicalReport (TR)
    │   │   ├─ TechnicalSpecification (TS)
    │   │   ├─ Data (DATA)
    │   │   ├─ Pas (PAS)
    │   │   ├─ TechnologyTrendsAssessments (TTA)
    │   │   ├─ InternationalWorkshopAgreement (IWA)
    │   │   ├─ InternationalStandardizedProfile (ISP)
    │   │   ├─ Recommendation (R - legacy)
    │   │   └─ Directives (DIR)
    │   │
    │   └─ SupplementIdentifier (amendments to base)
    │       ├─ Amendment (Amd, FDAM, PDAM, DAM)
    │       ├─ Corrigendum (Cor, FDCOR, DCOR)
    │       ├─ Supplement (Suppl)
    │       ├─ Extract (Ext)
    │       └─ DirectivesSupplement (DIR SUP)
```

Each flavor follows similar patterns adapted to its needs.

### Key Design Patterns

#### 1. MECE (Mutually Exclusive, Collectively Exhaustive)

- Each identifier is EXACTLY ONE type
- No pattern overlaps between classes
- Parser rules collectively exhaustive
- Builder selects exactly one class per pattern

#### 2. TYPED_STAGES Pattern

**NOTE**: This pattern is used by **ISO, IEC, CEN (EN), and BSI flavors ONLY**. Other flavors (NIST, IEEE, JIS, ITU, CCSDS, etc.) use different type/stage systems appropriate to their standards.

```ruby
# ✅ CORRECT: Array of TypedStage objects (ISO, IEC, CEN, BSI)
class Amendment < SupplementIdentifier
  TYPED_STAGES = [
    TypedStage.new(abbr: ["Amd"], stage_code: "published"),
    TypedStage.new(abbr: ["FDAM"], stage_code: "fdamd"),
    TypedStage.new(abbr: ["PDAM"], stage_code: "pdam"),
    TypedStage.new(abbr: ["DAM"], stage_code: "damd"),
  ].freeze
end

# ❌ WRONG: Hash-based TYPE_MAP (V1 anti-pattern)
TYPE_MAP = { "FDAM" => "fdamd", "PDAM" => "pdam" }  # Don't do this!
```

#### 3. Wrapper Pattern

Some identifiers wrap other identifiers:

```ruby
# IEC VAP identifier wraps another identifier
class VapIdentifier < Identifier
  attribute :identifier, Identifier  # Wrapped identifier
  attribute :suffix, VapSuffix       # VAP-specific data

  def to_s
    "#{identifier} VAP #{suffix}"
  end
end
```

Examples: VapIdentifier, SheetIdentifier, FragmentIdentifier, ConsolidatedIdentifier

#### 4. Supplement Recursion

Multi-level supplements build recursively:

```ruby
"ISO/IEC 13818-1:2015/Amd 3:2016/Cor 1:2017"

# Builds as:
Corrigendum(
  base: Amendment(
    base: InternationalStandard("ISO/IEC 13818-1:2015"),
    number: "3",
    year: 2016
  ),
  number: "1",
  year: 2017
)

# Renders via recursive to_s calls:
# => "ISO/IEC 13818-1:2015/Amd 3:2016/Cor 1:2017"
```

### Parser Strategy

**Parslet-based grammars** with careful rule ordering:

1. **Longest match first**: Put specific patterns before general ones
2. **Hierarchy**: Break complex patterns into sub-rules
3. **Capture semantics**: Use `.as(:symbol)` to name captured data
4. **Optional elements**: Use `.maybe` for optional parts
5. **Repetition**: Use `.repeat(min, max)` for lists

**Performance**: Parser instance memoization provides 5-6x speedup

### Builder Strategy

**Transforms parse tree to domain objects**:

1. Extract wrapper data first (VAP, sheets, etc.)
2. Build base identifier
3. Apply wrappers/supplements
4. Handle special cases explicitly
5. Use `cast()` method for type conversions

**Key**: Builder never modifies parsed data, only transforms it

### Builder Architecture (CRITICAL - NEVER VIOLATE)

**The Builder's ONLY job is to CAST parsed data to domain objects. It NEVER makes business logic decisions.**

#### Core Principles (from clean architecture at commit 05581a336fc770796b873e538c058a520d645b12)

1. **TYPED_STAGE REGISTER is the SOURCE OF TRUTH**
   - Builder receives Scheme: `Builder.new(scheme)`
   - Scheme provides register lookup: `scheme.locate_typed_stage_by_abbr(string)`
   - NEVER hardcode type/stage logic in Builder
   - NEVER duplicate type/stage checks
   - ALL type/stage decisions come from the register

2. **Single cast() Method**
   - ALL conversions happen in ONE place
   - No scattered conditional logic
   - No duplication of conversion code
   - Each parameter type has exactly ONE cast implementation

3. **Composite Hash Returns**
   - When cast returns multiple related values, return a hash
   - Example: `type_with_stage` returns `{ stage:, type:, typed_stage: }`
   - Builder then assigns each component to the identifier
   - This preserves the relationship between components

4. **Rendering Uses Components Directly**
   - Identifiers use `typed_stage.abbreviation` for rendering
   - NO hardcoded abbreviation logic in identifiers
   - Trust the component to provide correct format

5. **Language Handling**
   - Builder has `LANG_CHAR_MAP` for single→multi-char conversion
   - Sets BOTH `code` and `original_code` on Language objects
   - Language.to_s handles rendering based on `lang_single` parameter

#### Clean Builder Structure

```ruby
class Builder
  LANG_CHAR_MAP = {
    "R" => "ru", "F" => "fr", "E" => "en",
    "A" => "ar", "S" => "es", "D" => "de"
  }.freeze

  def initialize(scheme)
    @scheme = scheme
  end

  # Lookup typed_stage from register
  def locate_typed_stage(typed_stage_string)
    typed_stage_string = "" if typed_stage_string.nil?
    @scheme.locate_typed_stage_by_abbr(typed_stage_string)
  end

  # Lookup identifier class from register
  def locate_identifier_klass(parsed_hash)
    # Special cases: CombinedIdentifier, BundledIdentifier
    # Otherwise: use typed_stage to get type_code
    typed_stage = locate_typed_stage(parsed_hash[:type_with_stage])
    @scheme.locate_identifier_klass_by_type_code(typed_stage.type_code)
  end

  # Build identifier from parsed hash
  def build(parsed_hash)
    identifier = locate_identifier_klass(parsed_hash).new

    parsed_hash.each_pair do |key, value|
      realized_components = cast(key.to_sym, value)
      next if realized_components.nil?

      # Assign components to identifier
      case realized_components
      when Hash
        realized_components.each_pair do |k, v|
          identifier.send("#{k}=", v) if identifier.respond_to?("#{k}=")
        end
      else
        identifier.send("#{key}=", realized_components)
      end
    end

    identifier
  end

  # ALL conversions happen here
  def cast(type, value)
    case type
    when :type_with_stage
      # Parse iteration from original value
      original_value = value.to_s
      iteration = original_value.match(/(\d+)$/)
      normalized_value = original_value.sub(iteration.to_s, "")

      # Lookup from register
      typed_stage = locate_typed_stage(normalized_value || "")

      # Preserve original abbreviation
      typed_stage_with_original = typed_stage.dup
      typed_stage_with_original.original_abbr = original_value.strip

      # Return composite hash
      {
        stage: typed_stage_with_original.to_stage,
        type: typed_stage_with_original.to_type,
        typed_stage: typed_stage_with_original
      }

    when :languages
      # Convert single-char to multi-char, preserve original
      original_value = value.to_s
      normalized_value = original_value.gsub("/", ",")

      normalized_value.split(",").map do |lang|
        lang = lang.strip
        original_lang = lang
        lang = LANG_CHAR_MAP[lang] if lang.length == 1
        Components::Language.new(code: lang, original_code: original_lang)
      end

    # ... other cast implementations
    end
  end
end
```

#### What NOT to Do (Common Mistakes)

❌ **WRONG: Hardcoded type/stage checks in Builder**
```ruby
# DON'T DO THIS!
if data[:typed_stage]
  ts = data[:typed_stage].to_s
  return "TR" if ts.include?("TR")
  return "TS" if ts.include?("TS")
end
```

❌ **WRONG: Multiple places checking same thing**
```ruby
# DON'T DO THIS!
type_str = extract_type(base_data)
stage_str = extract_stage(base_data)
# ... later ...
if type_str&.upcase == "GUIDE"
  # do something
end
```

❌ **WRONG: Builder making rendering decisions**
```ruby
# DON'T DO THIS!
if stage_str && base_data[:stage_iteration_prefix]
  iteration_value = base_data[:stage_iteration_prefix]
else
  iteration_value = base_data[:iteration]
end
```

✅ **CORRECT: Single cast() handles it**
```ruby
# Use the register!
when :type_with_stage
  typed_stage = locate_typed_stage(value)
  {
    stage: typed_stage.to_stage,
    type: typed_stage.to_type,
    typed_stage: typed_stage
  }
```

#### Scheme Requirements

Every flavor's Scheme must provide:

1. `locate_typed_stage_by_abbr(string)` - Returns TypedStage from register
2. `locate_identifier_klass_by_type_code(type_code)` - Returns identifier class

Example:
```ruby
module Iso
  class Scheme
    def locate_typed_stage_by_abbr(abbr)
      TYPED_STAGES_REGISTRY.find { |ts| ts.abbr.include?(abbr) } ||
        DEFAULT_TYPED_STAGE
    end

    def locate_identifier_klass_by_type_code(type_code)
      IDENTIFIER_CLASS_MAP[type_code] || InternationalStandard
    end
  end
end
```

### Critical Implementation Paths

#### Parsing Flow

```
User calls: PubidNew::Iso.parse("ISO 8601:2019")
    ↓
Scheme.parse(string)
    ↓
Parser.new.parse(string) → hash tree
    ↓
Builder.build(hash) → Identifier object
    ↓
Returns typed identifier instance
```

#### Rendering Flow

```
User calls: identifier.to_s
    ↓
Identifier#to_s (may call super or override)
    ↓
Assembles parts in correct order
    ↓
Returns formatted string
```

### Testing Strategy

**Three levels of tests**:

1. **Integration tests**: Parse → render round-trip with real identifiers
2. **Unit tests**: Parser rules, Builder logic, Component behavior
3. **Performance tests**: Benchmarking parsing speed and memory

**Coverage target**: 100% for critical paths, comprehensive edge case coverage

### Performance Characteristics

**ISO Parser (representative)**:

- Simple identifiers: 0.20ms (5,000/sec)
- Complex identifiers: 0.46ms (2,174/sec)
- Multi-level supplements: 0.74ms (1,351/sec)
- Memory growth: 720 KB per 20k parses (minimal)

**NIST Parser**: 98.47% success rate on 19,488 real identifiers

**IEEE Parser**: 100% success rate on complex edge cases

All completed parsers are production-ready.