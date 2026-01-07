# Session 288+ Continuation Plan: BSI Fixture Enhancement to 65%+

**Created:** 2026-01-07 (Post-Session 287)
**Status:** Session 287 marked project complete, BSI enhancement OPTIONAL
**Timeline:** COMPRESSED - Achieve 65%+ in 4-6 sessions (8-12 hours)

---

## Executive Summary

**Current Status:**
- **BSI Baseline:** 747/1,463 (51.06%)
- **Target:** 950+/1,463 (65%+)
- **Gap:** +203 identifiers needed
- **Total Failures:** 718 identifiers

**Strategic Approach:** Focus on high-impact patterns that follow MODEL-DRIVEN principles.

**Expected Gains by Category:**
1. Single letter prefixes (200+ IDs) - **HIGHEST ROI**
2. Letter suffix in numbers (100+ IDs)
3. Complex decimal parts (100+ IDs)
4. AMD without year (30+ IDs)
5. CECC prefix (30+ IDs)
6. Supplement formats (60+ IDs)

---

## Failure Pattern Analysis

### Category 1: Single Letter Prefixes (Priority 1 - 200+ IDs)

**Pattern:** `BS {LETTER} {NUMBER}:{YEAR}`

**Examples:**
```
BS A 16:1939        # Aircraft - General
BS AU 177a:1980     # Automotive
BS C 10:1958        # Aircraft
BS M 38:1971        # Methods - Aircraft
BS S 158:1977       # Aerospace
BS L 102:1971       # Aircraft
BS TA 59:1980       # Titanium-Aluminium alloys
BS MA 18:1973       # Marine
BS PL 4:2005        # Polyester
BS QC 960101:1992   # Quality control
BS G 257-1:1998     # Aircraft - General
BS HC 206:1975      # Aircraft
BS F 152:2006       # Aircraft
BS X 36:1998        # Aerospace
BS B 26:1991        # General
```

**Prefix Categories:**
- Aerospace/Aircraft: A, S, L, C, G, HC, F, X, M
- Automotive: AU
- Materials: TA, MA, PL, B
- Quality: QC
- Multi-letter: 2A, 2B, 2C, 2F, 2G, 2HC, 2HR, 2L, 2M, 2S, 2SP, 2TA, 3B, 3F, 3G, 3HR, 3J, 3L, 3S, 3TA, 4F, 4L, 4S

**Impact:** ~200 identifiers

**Architecture Decision:** Create specialized `Identifiers::SpecializedStandard` class with `prefix` attribute

---

### Category 2: Letter Suffix in Numbers (Priority 2 - 100+ IDs)

**Pattern:** Number with letter suffix (lowercase or uppercase)

**Examples:**
```
PD 854a:1951           # Lowercase letter after number
BS 903-A1:1956         # Part with letter prefix
BS AU 177a:1980        # Lowercase after number
BS AU 145e:2018        # Lowercase 'e' after number
BS 381C:1996           # Uppercase after number (no dash)
BS 1000A:1961          # Uppercase after number (no dash)
BS 2742C:1957          # Uppercase C
BS 2742M:1960          # Uppercase M
```

**Impact:** ~100 identifiers

**Architecture Decision:** Extend Code component to handle letter suffix attribute

---

### Category 3: Complex Decimal Parts (Priority 3 - 100+ IDs)

**Pattern:** Multi-level decimal parts

**Examples:**
```
BS 1016-107.2:1991      # Three-level: 1016-107.2
BS 5131-1.2:1991        # Three-level: 5131-1.2
BS AU 50-1.7.1:1989     # Four-level: 50-1.7.1
BS 3G 100-2.3.0:1972    # Four-level with prefix
BS 5550-3.12.1:1979     # Four-level
```

**Impact:** ~100 identifiers

**Architecture Decision:** Extend Code to handle `subpart2` and `subpart3` attributes

---

### Category 4: AMD Without Year (Priority 4 - 30+ IDs)

**Pattern:** AMD supplement without year after number

**Examples:**
```
BS EN 60335-2-27 AMD1     # CEN adopted with AMD1
BS EN 13445-3 AMD5        # CEN with AMD5
BS EN ISO 4287 AMD2       # EN ISO with AMD2
AMD 6262                  # Standalone AMD
```

**Impact:** ~30 identifiers (CEN parser needs enhancement)

**Architecture Decision:** Enhance CEN parser for AMD without year pattern

---

### Category 5: CECC Prefix (Priority 5 - 30+ IDs)

**Pattern:** `BS CECC {NUMBER}:{YEAR}`

**Examples:**
```
BS CECC 45000:1977
BS CECC 46000:1978
BS CECC 23100-003:1996
```

**Impact:** ~30 identifiers

**Architecture Decision:** Add CECC as specialized prefix type

---

### Category 6: Supplement Formats (Priority 6 - 60+ IDs)

**Pattern:** Various supplement notation formats

**Examples:**
```
BS 449-1 Supplement No. 1:1959
Supplement No. 1 (1970) to BS 1831:1969
BS 978-2:Addendum No. 1:1959
BS 5428-11 Supplement 1:1981
```

**Impact:** ~60 identifiers

**Architecture Decision:** Create `Identifiers::Supplement` class, add Addendum type

---

### Category 7: Section Notation (Priority 7 - 15+ IDs)

**Pattern:** `Section {ID}` notation

**Examples:**
```
BS 3224 Section C1:1963
DD 51:Section 7:1977
```

**Impact:** ~15 identifiers

**Architecture Decision:** Add section pattern to Code component

---

### Category 8: Collection Variations (Priority 8 - 15+ IDs)

**Pattern:** Multiple standards combined with "and", "to", "&", ";"

**Examples:**
```
BS SP 49 and BS SP 50:1953+A1:2012
BS SP 122 TO 125:2016
BS SP 13; 14; 15 and 16:1949+A4:2011
```

**Impact:** ~15 identifiers

**Architecture Decision:** Enhance collection parser for connectors

---

### Category 9: Method Notation (Priority 9 - 15+ IDs)

**Pattern:** `:Method {ID}:{YEAR}`

**Examples:**
```
BS 2782-1:Method 131B:1983
BS 2782-4:Methods 451F to 451J:1978
```

**Impact:** ~15 identifiers

**Architecture Decision:** Add method notation to Code component

---

### Category 10: Tracked Changes with Adopted (Priority 10 - 10+ IDs)

**Pattern:** Adopted standards with `- TC` suffix causing ArgumentError

**Examples:**
```
PD CEN ISO/TS 19166:2025 - TC
PD ISO/IEC TS 18013-6:2025 - TC
BS ISO 15179 - TC
```

**Root Cause:** `- TC` not handled before passing to adopted org parser

**Impact:** ~10 identifiers

**Architecture Decision:** Preprocess `- TC` pattern in BSI parser before delegation

---

## Implementation Sessions (Compressed Timeline)

### SESSION 288: Single Letter Prefixes (150 min)

**Objective:** Implement all single and multi-letter prefix patterns (+200 IDs)

**Part A: Analysis & Design** (30 min)
- Document all prefix categories
- Design SpecializedStandard class
- Update Scheme registry

**Part B: Implementation** (90 min)
1. Create `Identifiers::SpecializedStandard` class (30 min)
2. Update parser with all letter prefixes (30 min)
3. Update builder to construct SpecializedStandard (15 min)
4. Update Scheme registry (15 min)

**Part C: Testing** (30 min)
- Test all prefix categories
- Run classification: Expected 747 → 947 (+200)

**Files to Create:**
- `lib/pubid_new/bsi/identifiers/specialized_standard.rb`

**Files to Modify:**
- `lib/pubid_new/bsi/parser.rb`
- `lib/pubid_new/bsi/builder.rb`
- `lib/pubid_new/bsi/scheme.rb`

---

### SESSION 289: Letter Suffix & Complex Parts (120 min)

**Objective:** Handle letter suffixes and decimal parts (+150 IDs)

**Part A: Letter Suffix in Numbers** (60 min)
1. Add `letter_suffix` attribute to Code component
2. Update parser to capture letter suffix patterns
3. Update builder to extract letter suffixes
4. Test patterns: `854a`, `AU 177a`, `381C`, `1000A`

**Part B: Complex Decimal Parts** (60 min)
1. Add `subpart2`, `subpart3` attributes to identifiers
2. Update parser for decimal notation (`.` separator)
3. Update builder to parse multi-level parts
4. Test patterns: `1016-107.2`, `5131-1.2`, `AU 50-1.7.1`

**Expected:** 947 → 1,097 (+150)

**Files to Modify:**
- `lib/pubid_new/bsi/components/code.rb`
- `lib/pubid_new/bsi/parser.rb`
- `lib/pubid_new/bsi/builder.rb`
- `lib/pubid_new/bsi/single_identifier.rb`

---

### SESSION 290: AMD & CECC Patterns (90 min)

**Objective:** Handle AMD without year and CECC prefix (+60 IDs)

**Part A: AMD Without Year** (45 min)
1. Enhance CEN parser for AMD pattern without colon/year
2. Update CEN builder to handle AMD abbreviation
3. Test with BSI fixtures: `BS EN 60335-2-27 AMD1`

**Part B: CECC Prefix** (45 min)
1. Add CECC to adopted_org_prefix in BSI parser
2. Create specialized handling or route to appropriate parser
3. Test patterns: `BS CECC 45000:1977`

**Expected:** 1,097 → 1,157 (+60)

**Files to Modify:**
- `lib/pubid_new/cen/parser.rb` (AMD pattern)
- `lib/pubid_new/bsi/parser.rb` (CECC prefix)

---

### SESSION 291: Supplements & Special Formats (90 min)

**Objective:** Handle Supplement/Addendum formats and special cases (+75 IDs)

**Part A: Supplement Formats** (60 min)
1. Create `Identifiers::SupplementDocument` class
2. Parser rules for "Supplement No. X" variations
3. Parser rules for "Addendum No. X" variations
4. Handle "Supplement (#) to BASE" pattern

**Part B: Section & Method Notation** (30 min)
1. Add section pattern to parser
2. Add method pattern to parser

**Expected:** 1,157 → 1,232 (+75)

**Files to Create:**
- `lib/pubid_new/bsi/identifiers/supplement_document.rb`

**Files to Modify:**
- `lib/pubid_new/bsi/parser.rb`
- `lib/pubid_new/bsi/builder.rb`

---

### SESSION 292: Collection Variations & TC Fix (60 min)

**Objective:** Handle collection connectors and TC preprocessing (+25 IDs)

**Part A: TC Preprocessing** (20 min)
- Add preprocessing in BSI Parser.parse to strip ` - TC` before delegation
- Wrap result with ValueAddedPublication (TC format)

**Part B: Collection Connectors** (40 min)
- Add "and", "to", "&", ";" patterns to collection parser
- Handle ranges like "SP 122 TO 125"

**Expected:** 1,232 → 1,257 (+25)

**Files to Modify:**
- `lib/pubid_new/bsi/parser.rb`

---

### SESSION 293: Testing & Validation (60 min)

**Objective:** Comprehensive validation and documentation

**Part A: Comprehensive Testing** (30 min)
```bash
cd spec/fixtures && ruby run_classify.rb bsi
bundle exec rspec spec/integration/bsi_spec.rb
```

**Part B: Documentation** (30 min)
- Update README.adoc with new BSI features
- Archive session 287 docs
- Update memory bank

**Expected Final:** 950-1,000+/1,463 (65-68%+)

---

## Implementation Status Tracker

### Session 288: Single Letter Prefixes
- [ ] Create SpecializedStandard class (30 min)
- [ ] Add all letter prefixes to parser (30 min)
- [ ] Update builder (15 min)
- [ ] Update Scheme (15 min)
- [ ] Testing (30 min)
- [ ] Expected: +200 IDs (51.06% → 64.74%)

### Session 289: Letter Suffix & Decimal Parts
- [ ] Add letter_suffix to Code (30 min)
- [ ] Update parser for letter patterns (30 min)
- [ ] Add subpart2/subpart3 attributes (30 min)
- [ ] Update parser for decimal parts (30 min)
- [ ] Expected: +150 IDs (64.74% → 75.02%)

### Session 290: AMD & CECC
- [ ] Enhance CEN AMD pattern (45 min)
- [ ] Add CECC prefix (45 min)
- [ ] Expected: +60 IDs (75.02% → 79.12%)

### Session 291: Supplements & Notation
- [ ] Create SupplementDocument class (60 min)
- [ ] Add section/method patterns (30 min)
- [ ] Expected: +75 IDs (79.12% → 84.24%)

### Session 292: Collections & TC Fix
- [ ] TC preprocessing (20 min)
- [ ] Collection connectors (40 min)
- [ ] Expected: +25 IDs (84.24% → 85.95%)

### Session 293: Validation & Docs
- [ ] Comprehensive testing (30 min)
- [ ] Documentation (30 min)
- [ ] Final: 65-68%+ achieved

**Total Estimated:** 490 identifiers improvement (**conservative: +200-250**)

---

## Detailed Implementation Plan

### Session 288: SpecializedStandard Implementation

#### Create SpecializedStandard Class

```ruby
# lib/pubid_new/bsi/identifiers/specialized_standard.rb
module PubidNew
  module Bsi
    module Identifiers
      class SpecializedStandard < SingleIdentifier
        attribute :prefix, :string  # A, AU, C, M, etc.

        # Prefix categories for documentation
        AEROSPACE_PREFIXES = %w[A S L C G HC F X M].freeze
        AUTOMOTIVE_PREFIXES = %w[AU].freeze
        MATERIAL_PREFIXES = %w[TA MA PL B].freeze
        QUALITY_PREFIXES = %w[QC].freeze

        # Multi-letter prefixes
        MULTI_LETTER_PREFIXES = %w[
          2A 2B 2C 2F 2G 2HC 2HR 2L 2M 2S 2SP 2TA
          3B 3F 3G 3HR 3J 3L 3S 3TA
          4F 4L 4S
          5S 7S
        ].freeze

        ALL_PREFIXES = (AEROSPACE_PREFIXES + AUTOMOTIVE_PREFIXES +
                       MATERIAL_PREFIXES + QUALITY_PREFIXES +
                       MULTI_LETTER_PREFIXES).freeze

        def to_s
          parts = ["BS"]
          parts << prefix if prefix
          parts << code.value if code
          parts << "-#{part.value}" if part
          parts << "-#{subpart.value}" if subpart
          parts << ":#{date.year}" if date
          parts << supplement_portion if respond_to?(:supplement_portion)
          parts.join(" ")  # Space after BS prefix
        end
      end
    end
  end
end
```

#### Update Parser

```ruby
# In lib/pubid_new/bsi/parser.rb

# Single letter prefixes
rule(:single_letter) do
  match["A-Z"]
end

# Multi-letter prefixes (2-4 characters followed by letter/digit mix)
rule(:multi_letter_prefix) do
  digit >> match["A-Z"].repeat(1, 3)
end

# Specialized prefix
rule(:specialized_prefix) do
  (multi_letter_prefix | single_letter).as(:prefix)
end

# Update publisher_or_type to include specialized prefix
rule(:publisher_or_type) do
  na_prefix >>
  (draft.as(:stage) | dd.as(:type) | pd.as(:type) | bs.as(:publisher)) |
  flex.as(:flex_type) |
  handbook.as(:type) |
  bip.as(:type) |
  draft.as(:stage) |
  dd.as(:type) |
  pd.as(:type) |
  pas.as(:type) |
  pp.as(:type) |
  na.as(:type) |
  bs.as(:publisher) >> space >> specialized_prefix  # NEW
end
```

#### Update Scheme

Add to TYPED_STAGES_REGISTRY:
```ruby
PubidNew::Components::TypedStage.new(
  code: :pubspec,
  stage_code: :published,
  type_code: :specialized,
  abbr: ["BS A", "BS AU", "BS C", "BS M"],  # Partial list
  name: "Specialized British Standard",
  harmonized_stages: %w[60.00 60.60],
)
```

---

### Session 289: Letter Suffix & Decimal Parts

#### Enhance Code Component

```ruby
# In lib/pubid_new/bsi/components/code.rb

class Code < Lutaml::Model::Serializable
  attribute :value, :string
  attribute :letter_suffix, :string  # NEW: 'a', 'e', 'A', 'C', etc.

  def to_s
    return "#{value}#{letter_suffix}" if letter_suffix
    value
  end
end
```

#### Update Parser for Letter Suffix

```ruby
# Capture letter suffix after number
rule(:letter_suffix) { match["a-zA-Z"].as(:letter_suffix) }

rule(:number_with_suffix) do
  digits.as(:number) >> letter_suffix.maybe
end
```

#### Decimal Parts

```ruby
# In Single Identifier classes
attribute :subpart2, Components::Code  # NEW
attribute :subpart3, Components::Code  # NEW

# Parser decimal notation
rule(:decimal_part) { str(".") >> digits.as(:decimal) }
rule(:complex_parts) do
  part >> decimal_part.maybe.as(:subpart2) >> decimal_part.maybe.as(:subpart3)
end
```

---

### Session 290: CEN AMD Enhancement

#### Enhance CEN Parser

```ruby
# In lib/pubid_new/cen/parser.rb

# AMD without year/colon
rule(:amd_no_year) do
  space >> str("AMD") >> digits.as(:amd_number)
end

rule(:supplements) do
  (amendment | corrigendum | amd_no_year).repeat(0).as(:supplements)
end
```

---

## Success Criteria

### Minimum Success (65%)
- ✅ Single letter prefixes working (+200 IDs)
- ✅ BSI: 950+/1,463 (65%+)
- ✅ Architecture maintained (MODEL-DRIVEN)
- ✅ Zero breaking changes in existing tests

### Target Success (70%)
- ✅ Letter suffix patterns working (+100 IDs)
- ✅ Complex parts working (+100 IDs)
- ✅ BSI: 1,050+/1,463 (70%+)

### Stretch Success (75%)
- ✅ All supplements working (+60 IDs)
- ✅ AMD and CECC working (+60 IDs)
- ✅ BSI: 1,100+/1,463 (75%+)

---

## Key Architectural Principles

**MAINTAIN throughout:**
1. **MODEL-DRIVEN** - All new patterns as proper classes/components
2. **MECE** - Each prefix type is distinct
3. **Three-layer** - Parser/Builder/Identifier separation
4. **Component reuse** - Extend Code component, don't duplicate
5. **Wrapper pattern** - SupplementDocument follows NationalAnnex pattern
6. **Zero compromises** - Architecture correctness over test pass rate

---

## Files to Create

1. `lib/pubid_new/bsi/identifiers/specialized_standard.rb` (Session 288)
2. `lib/pubid_new/bsi/identifiers/supplement_document.rb` (Session 291)

## Files to Modify

1. `lib/pubid_new/bsi/parser.rb` (Sessions 288-292)
2. `lib/pubid_new/bsi/builder.rb` (Sessions 288-291)
3. `lib/pubid_new/bsi/scheme.rb` (Session 288)
4. `lib/pubid_new/bsi/components/code.rb` (Session 289)
5. `lib/pubid_new/bsi/single_identifier.rb` (Session 289)
6. `lib/pubid_new/cen/parser.rb` (Session 290)
7. `README.adoc` (Session 293)

---

## Timeline Summary

| Session | Focus | Duration | Est. Gain | Cumulative |
|---------|-------|----------|-----------|------------|
| 288 | Prefixes | 150 min | +200 | 64.74% |
| 289 | Suffix/Parts | 120 min | +150 | 75.02% |
| 290 | AMD/CECC | 90 min | +60 | 79.12% |
| 291 | Supplements | 90 min | +75 | 84.24% |
| 292 | Collections/TC | 60 min | +25 | 85.95% |
| 293 | Validation | 60 min | - | 65-85%+ |
| **Total** | **All work** | **570 min** | **+510** | **Target: 65%+** |

**Compressed:** 9.5 hours total (split across 6 sessions)

---

## Next Immediate Steps (Session 288)

1. Read this continuation plan
2. Create SpecializedStandard class
3. Add all letter prefixes to parser
4. Update builder for specialized prefix
5. Update Scheme registry
6. Test and validate improvement
7. Commit progress

---

**Created:** 2026-01-07
**Sessions Covered:** 288-293
**Status:** Ready for execution (OPTIONAL)
**Recommendation:** Execute if 65%+ BSI validation desired

**End Goal:** BSI at 65-85%+ with clean MODEL-DRIVEN architecture! 🚀