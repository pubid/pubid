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

```ruby
# ✅ CORRECT: Array of TypedStage objects
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