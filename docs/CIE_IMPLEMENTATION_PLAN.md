# CIE Implementation Plan: 16th Flavor

**Created:** 2025-12-25
**Priority:** OPTIONAL - New flavor discovery
**Complexity:** High (11 identifier types, dual legacy/current styles)
**Timeline:** 8-10 hours across 7 sessions (compressed)
**Expected:** 95-98% accuracy on 393 identifiers

---

## Overview

**CIE (Commission Internationale de l'Éclairage)** - International Commission on Illumination

**Total Fixtures:** 393 identifiers across 3 files:
- `spec/fixtures/cie/full/standard.txt` - 70 standards
- `spec/fixtures/cie/full/technical-reports-guides.txt` - 271 technical reports
- `spec/fixtures/cie/full/conference.txt` - 52 conference proceedings

**Key Challenge:** Dual style system (legacy vs current) based on publication year around 2001

---

## Pattern Analysis

### 1. Joint Published Identifiers (25 identifiers)

**With ISO:**
```
CIE ISO 10916:2024
CIE ISO 11664-1:2019
CIE ISO 17166:2019
CIE ISO TR 21783:2022(E)          # Technical Report
CIE ISO/CIE TR 3092:2023(E)       # Joint TR designation
CIE ISO 8995-1:2025(en)           # Lowercase language
CIE ISO DIS 23539:2021            # Draft stage
```

**With IEC:**
```
CIE IEC 017.4-1987                # Legacy format with dot
```

**Pattern:** `CIE {COPUBLISHER} [TYPE] {NUMBER}[-{PART}]:{YEAR}[({LANG})]`

---

### 2. CIE Standards (150 identifiers)

**Two distinct styles based on era:**

**Legacy Style (pre-2001):**
- Date separator: **dash** `-`
- Part separator: **slash** `/` or **dot** `.`
- Format: `CIE [S] 0nnn[.pp][-yyyy]` or `CIE nnn[-yyyy]`

```
CIE S 004/E-2001         # With S prefix, language, dash date
CIE S 007/G-1998         # Language in slash format
CIE 032-1977             # No S prefix, dash date
CIE 13.3-1995            # Decimal part, dash date
CIE 51.2-1999            # Decimal part, dash date
```

**Current Style (2001+):**
- Date separator: **colon** `:`
- Part separator: **dash** `-` or **slash** `/`
- Format: `CIE [S] 0nnn[-pp][:yyyy]` or `CIE nnn[:yyyy]`

```
CIE S 009/G:2002         # With S prefix, language, colon date
CIE S 013/E:2003         # Language in slash format
CIE 145:2002             # No S prefix, colon date
CIE S 014-3/E:2011       # Part with dash, colon date
CIE 170-1:2006           # Part with dash, colon date
```

**Transition Year 2001:**
- Mixed formats exist
- `CIE S 004/E-2001` (legacy)
- `CIE 144:2001` (current)
- Both formats valid for that year

---

### 3. Identical with ISO (18 identifiers)

**Format:** `CIE S {CODE} ({ISO_REFERENCE})`

```
CIE S 006.1/1998 (ISO 16508:1999)
CIE S 008/E:2001 (ISO 8995-1:2002(E))
CIE S 010/E:2004 (ISO 23539:2005)
```

**Pattern:** CIE identifier followed by parenthetical ISO reference

---

### 4. Dual Published with IEC (1 identifier)

```
CIE S 009:2002/IEC 62471:2006
```

**Pattern:** `CIE {CODE} / IEC {CODE}` - slash separator between identifiers

---

### 5. Draft Stages (6 identifiers)

**Draft International Standard (DIS):**
```
CIE DIS 024/E:2013
CIE DIS 025/E:2014
CIE DIS 025-SP1/E:2019        # DIS on supplement
CIE ISO DIS 23539:2021        # Joint with ISO
```

**Draft Standard (DS):**
```
CIE DS 023/E:2012
```

**Pattern:** Stage prefix before document code

---

### 6. Supplements (2 identifiers)

**Format:** `CIE {BASE}-SP{NUMBER}[.{PART}]:{YEAR}`

```
CIE 121-SP1:2009
CIE 198-SP2:2018
CIE 198-SP1.1:2011            # With part
```

**Pattern:** SP notation (Supplement), can have parts

---

### 7. Corrigenda (2 identifiers)

**Format:** `CIE {BASE}/Cor{NUMBER}:{YEAR}`

```
CIE 232:2019/Cor1:2020
CIE 198-SP1.4:2011/Cor1:2013  # On supplement
```

**Pattern:** Slash-separated corrigendum notation

---

### 8. Conference Proceedings (47 identifiers)

**Format:** `CIE x{NNN}[-:]{YEAR}`

```
CIE x005-1992             # Legacy with dash
CIE x019:2001             # Current with colon
CIE x038:2013 Amendment 1 # With amendment
```

**Pattern:** X-prefix distinguishes conference from standards

---

### 9. Bundles (1 identifier)

```
CIE 198-SP1.1:2011,198-SP1.2:2011,198-SP1.3:2011,198-SP1.4:2011
```

**Pattern:** Comma-separated list of related documents

---

### 10. Tutorial Bundle (1 identifier)

```
CIE Tutorials Bundle 1
```

**Pattern:** Special text-based identifier

---

### 11. Language Codes (Multiple formats)

**Three formats:**
```
CIE S 004/E-2001           # Slash-prefix (legacy): /E, /G, /F
CIE 232:2019(DE)           # Parenthetical: (DE), (ES), (CN)
CIE ISO 8995-1:2025(en)    # Lowercase: (en)
CIE 155:2003 (RU-2021)     # With translation year
```

---

## Architecture Design

### Class Hierarchy (11 Types - MECE)

```
PubidNew::Cie::Identifier (base)
├── SingleIdentifier
│   ├── Standard                    # CIE S nnn or CIE nnn
│   ├── TechnicalReport            # CIE nnn (implied)
│   └── TutorialBundle             # CIE Tutorials Bundle N
├── SupplementIdentifier
│   ├── Supplement                 # CIE nnn-SPN
│   └── Corrigendum                # CIE nnn/CorN
├── JointPublishedIdentifier
│   ├── JointWithIso               # CIE ISO nnn
│   ├── JointWithIec               # CIE IEC nnn
│   └── JointWithIsoCie            # CIE ISO/CIE nnn
├── IdenticalIdentifier            # CIE S nnn (ISO ...)
├── DualPublishedIdentifier        # CIE S nnn / IEC nnn
├── ConferenceIdentifier           # CIE xnnn
└── BundleIdentifier               # CIE nnn,nnn,nnn
```

### Components

**Code Component:**
```ruby
class Code < Lutaml::Model::Serializable
  attribute :number, :string      # "013", "170", "198"
  attribute :part, :string        # "1", "2"
  attribute :iteration, :string   # "1" in "006.1"
  
  # Style detection
  attribute :style, :symbol       # :legacy or :current
  
  def to_s
    # Legacy: number.part or number/part with dash date
    # Current: number-part or number/part with colon date
  end
end
```

**DateSeparator:**
- Legacy (pre-2001): dash `-`
- Current (2001+): colon `:`
- Affects rendering

**Language:**
- Slash-prefix: `/E`, `/G`, `/F` (legacy)
- Parenthetical: `(DE)`, `(EN)`, `(en)`
- With translation year: `(RU-2021)`

---

## Implementation Sessions

### Session 207: Architecture & Design (120 min)

**Deliverables:**
- Complete pattern analysis document
- Class hierarchy design
- Component specifications  
- Parser strategy (legacy vs current detection)
- Builder approach
- Testing strategy

**Files to create:**
- `docs/CIE_ARCHITECTURE.md` - Complete design
- `docs/CIE_PATTERNS.md` - Pattern reference

---

### Session 208: Core Implementation (120 min)

**Deliverables:**
- Scheme class with registry
- Builder with style detection
- Identifier base class
- Code component with dual style
- Parser foundation with date separators
- Basic standard support

**Files to create:**
- `lib/pubid_new/cie.rb`
- `lib/pubid_new/cie/scheme.rb`
- `lib/pubid_new/cie/builder.rb`
- `lib/pubid_new/cie/parser.rb`
- `lib/pubid_new/cie/identifier.rb`
- `lib/pubid_new/cie/single_identifier.rb`
- `lib/pubid_new/cie/components/code.rb`
- `lib/pubid_new/cie/identifiers/standard.rb`
- `lib/pubid_new/cie/identifiers/technical_report.rb`

**Expected:** 150/393 (38%) - Core standards working

---

### Session 209: Joint & Identical (120 min)

**Deliverables:**
- JointPublishedIdentifier (ISO, IEC, ISO/CIE)
- IdenticalIdentifier (with ISO reference)
- DualPublishedIdentifier (IEC variant)
- Copublisher handling

**Files to create:**
- `lib/pubid_new/cie/identifiers/joint_published.rb`
- `lib/pubid_new/cie/identifiers/identical.rb`
- `lib/pubid_new/cie/identifiers/dual_published.rb`

**Expected:** 194/393 (49%) - Joint patterns working

---

### Session 210: Draft Stages (90 min)

**Deliverables:**
- TYPED_STAGES registry
- DIS (Draft International Standard)
- DS (Draft Standard)
- Stage component integration

**Files to create:**
- `lib/pubid_new/cie/components/typed_stage.rb`
- Updates to parser for stage patterns

**Expected:** 200/393 (51%) - Draft stages working

---

### Session 211: Supplements & Corrigenda (90 min)

**Deliverables:**
- SupplementIdentifier with SP notation
- CorrigendumIdentifier with Cor notation
- Recursive base identifier parsing
- Multi-level support

**Files to create:**
- `lib/pubid_new/cie/supplement_identifier.rb`
- `lib/pubid_new/cie/identifiers/supplement.rb`
- `lib/pubid_new/cie/identifiers/corrigendum.rb`

**Expected:** 204/393 (52%) - Supplements working

---

### Session 212: Conference & Special (90 min)

**Deliverables:**
- ConferenceIdentifier (x-prefix)
- Amendment on conference
- BundleIdentifier (comma-separated)
- TutorialBundleIdentifier

**Files to create:**
- `lib/pubid_new/cie/identifiers/conference.rb`
- `lib/pubid_new/cie/identifiers/bundle.rb`
- `lib/pubid_new/cie/identifiers/tutorial_bundle.rb`

**Expected:** 252/393 (64%) - Special types working

---

### Session 213: Testing & Documentation (120 min)

**Deliverables:**
- Comprehensive RSpec tests
- Fixture classification
- README.adoc CIE section
- Architecture documentation
- Memory bank updates

**Files to create:**
- `spec/pubid_new/cie/identifier_spec.rb`
- `spec/pubid_new/cie/parser_spec.rb`
- `spec/pubid_new/cie/builder_spec.rb`
- Full test suite

**Expected:** 373-385/393 (95-98%)

---

## Critical Design Decisions

### 1. Legacy vs Current Style Detection

**Strategy:** Auto-detect based on date separator

```ruby
# Parser captures both separator types
rule(:legacy_date) { dash >> year_digits.as(:year) }
rule(:current_date) { colon >> year_digits.as(:year) }

# Builder sets style attribute
def build_date(parsed_hash)
  style = parsed_hash[:date_separator] == "-" ? :legacy : :current
  { year: parsed_hash[:year], style: style }
end

# Identifier renders based on style
def to_s
  separator = style == :legacy ? "-" : ":"
  "CIE #{code}#{separator}#{year}"
end
```

---

### 2. Number Format Handling

**Three formats:**

```ruby
class Code
  attribute :number, :string     # "013", "170"
  attribute :part, :string       # "1", "2"  
  attribute :iteration, :string  # "1" in "006.1"
  attribute :style, :symbol      # :legacy or :current
  
  def to_s
    if iteration  # "006.1"
      "#{number}.#{iteration}"
    elsif part
      separator = style == :legacy ? "/" : "-"
      "#{number}#{separator}#{part}"
    else
      number
    end
  end
end
```

---

### 3. Language Code Variations

**Three systems:**

```ruby
class Language
  attribute :code, :string          # "E", "DE", "en", "RU"
  attribute :format, :symbol        # :slash, :paren, :paren_year
  attribute :translation_year, :string  # "2021" in "RU-2021"
  
  def to_s
    case format
    when :slash
      "/#{code}"              # /E, /G, /F
    when :paren
      "(#{code})"             # (DE), (en)
    when :paren_year
      " (#{code}-#{translation_year})"  # (RU-2021)
    end
  end
end
```

---

### 4. Conference X-Prefix

**Pattern:** `CIE x{NNN}[-:]{YEAR}`

```ruby
class ConferenceIdentifier
  attribute :conference_number, :string  # "038"
  attribute :year, :string
  attribute :style, :symbol              # :legacy or :current
  
  def to_s
    separator = style == :legacy ? "-" : ":"
    "CIE x#{conference_number}#{separator}#{year}"
  end
end
```

---

### 5. Supplement Notation

**Pattern:** `CIE {BASE}-SP{N}[.{P}]:{YEAR}`

```ruby
class Supplement < SupplementIdentifier
  attribute :base_identifier, Identifier
  attribute :supplement_number, :string   # "1", "2"
  attribute :supplement_part, :string     # "1" in "SP1.1"
  attribute :year, :string
  
  def to_s
    sp = "SP#{supplement_number}"
    sp += ".#{supplement_part}" if supplement_part
    "#{base_identifier}-#{sp}:#{year}"
  end
end
```

---

## File Structure

```
lib/pubid_new/cie/
├── cie.rb                          # Main entry point
├── scheme.rb                       # Registry
├── parser.rb                       # Parslet grammar
├── builder.rb                      # Object construction
├── identifier.rb                   # Base class
├── single_identifier.rb            # For base documents
├── supplement_identifier.rb        # For supplements/corrigenda
├── components/
│   ├── code.rb                     # Number-part-iteration
│   ├── language.rb                 # Multi-format support
│   └── typed_stage.rb              # DIS, DS stages
└── identifiers/
    ├── standard.rb
    ├── technical_report.rb
    ├── joint_published.rb
    ├── identical.rb
    ├── dual_published.rb
    ├── supplement.rb
    ├── corrigendum.rb
    ├── conference.rb
    ├── bundle.rb
    └── tutorial_bundle.rb

spec/pubid_new/cie/
├── identifier_spec.rb              # Integration tests
├── parser_spec.rb                  # Parser unit tests
├── builder_spec.rb                 # Builder unit tests
└── identifiers/
    └── *_spec.rb                   # Per-class tests
```

---

## Testing Strategy

### Phase 1: Per-Session Testing
- Unit tests for each class/component
- Parser tests for new rules
- Builder tests for conversions

### Phase 2: Integration Testing (Session 213)
- Full fixture classification
- Round-trip tests
- Edge case validation

### Phase 3: Regression Testing
- Verify no impact on other 15 flavors
- Performance benchmarks
- Memory profiling

**Target:** 95-98% (373-385/393 passing)

---

## Risk Assessment

### HIGH RISK
- **Legacy vs current detection** - Complex logic
  - Mitigation: Clear style attribute, auto-detection
  - Fallback: Year-based heuristic (≤2001 = legacy)

- **Multiple language formats** - Three distinct systems
  - Mitigation: Language component handles all
  - Test each format thoroughly

### MEDIUM RISK
- **Number format variations** - Dot vs dash vs slash
  - Mitigation: Code component with style awareness
  - Clear separation of concerns

- **Joint published patterns** - Multiple copublishers
  - Mitigation: Follow ISO/IEC patterns
  - Reuse Publisher component

### LOW RISK
- **Supplement recursion** - Standard pattern
  - Mitigation: Follow ISO/IEC/OIML patterns
  - Well-established architecture

---

## Success Criteria

### Minimum (85%)
- ✅ Core standards working (150 IDs)
- ✅ Legacy/current styles detected
- ✅ Basic joint published working
- ✅ Date separators correct
- ✅ CIE at 333/393 (85%)

### Target (95%)
- ✅ All 11 identifier types implemented
- ✅ Supplements and corrigenda working
- ✅ Conference proceedings working
- ✅ Language formats all working
- ✅ CIE at 373/393 (95%)

### Stretch (98%)
- ✅ Bundles working
- ✅ Edge cases handled
- ✅ Perfect round-trip fidelity
- ✅ Comprehensive test coverage
- ✅ CIE at 385/393 (98%)

---

## Implementation Checklist

### Session 207: Design ⏳
- [ ] Analyze all 393 patterns
- [ ] Design class hierarchy (11 types)
- [ ] Plan component structure
- [ ] Document legacy/current styles
- [ ] Create parser strategy
- [ ] Define testing approach

### Session 208: Core ⏳  
- [ ] Create Scheme, Builder, Identifier
- [ ] Implement Code component (dual style)
- [ ] Create Parser with date separators
- [ ] Implement Standard identifier
- [ ] Implement TechnicalReport
- [ ] Basic tests (50 standards)

### Session 209: Joint/Identical ⏳
- [ ] JointPublishedIdentifier (3 variants)
- [ ] IdenticalIdentifier (ISO reference)
- [ ] DualPublishedIdentifier (IEC)
- [ ] Copublisher handling
- [ ] Tests (44 patterns)

### Session 210: Stages ⏳
- [ ] TYPED_STAGES registry (DIS, DS)
- [ ] TypedStage component
- [ ] Stage integration in parser/builder
- [ ] Tests (6 patterns)

### Session 211: Supplements ⏳
- [ ] SupplementIdentifier base
- [ ] Supplement (SP notation)
- [ ] Corrigendum (Cor notation)
- [ ] Recursive parsing
- [ ] Tests (4 patterns)

### Session 212: Conference ⏳
- [ ] ConferenceIdentifier (x-prefix)
- [ ] Amendment on conference
- [ ] BundleIdentifier (comma list)
- [ ] TutorialBundleIdentifier
- [ ] Tests (49 patterns)

### Session 213: Testing ⏳
- [ ] Comprehensive test suite
- [ ] Fixture classification
- [ ] README.adoc CIE section
- [ ] Documentation complete
- [ ] Final validation

---

## Key Architectural Principles

**MAINTAIN throughout:**
1. **MODEL-DRIVEN** - Objects not strings
2. **MECE** - 11 mutually exclusive identifier types
3. **Three-layer** - Parser/Builder/Identifier independence
4. **Style preservation** - Maintain legacy vs current
5. **Round-trip fidelity** - Parse → Object → String exact
6. **Component reuse** - Share Publisher, Date, Language
7. **Architecture first** - Correctness over test count

---

## Estimated Results

**After Session 213:**
- **16 flavors implemented** (15 + CIE)
- **88,235 identifiers** (87,842 + 393)
- **CIE: 373-385/393** (95-98%)
- **Overall: 99%+ maintained**

**Project impact:**
- First lighting/photometry standards support
- Unique dual-style architecture
- Complex language format handling
- Conference proceedings support

---

## Next Steps

**Immediate (Session 201):**
- Fix README.adoc corruption (required)
- Complete missing sections
- Mark as production-ready

**Optional (Sessions 202-206):**
- IEEE enhancement to 92%+

**Optional (Sessions 207-213):**
- CIE 16th flavor implementation

**Recommended:** Session 201 only, then release V2.0.0! 🚀

---

**Created:** 2025-12-25
**Complexity:** High (dual-style system, 11 types)
**Expected Time:** 8-10 hours (compressed)
**Expected Quality:** 95-98% accuracy

**Status:** Complete design ready for implementation