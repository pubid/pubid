# Session 289+ Continuation Plan: BSI Fixture-Based Implementation

**Created:** 2026-01-07 (Post-Session 288 - SpecializedStandard deleted)
**Status:** Session 288 complete - Need fixture-based approach
**Timeline:** 3-4 sessions (6-8 hours) to reach 65%+

---

## Critical Context Update

**Session 288 Issue:** Created `SpecializedStandard` class without following fixture structure ❌

**Correction Applied:**
- ✅ Deleted `lib/pubid_new/bsi/identifiers/specialized_standard.rb`
- ✅ Now following actual fixture file structure in `spec/fixtures/bsi/identifiers/full/`

**Current Metrics:**
- **Total fixtures:** 1,622 identifiers (31 fixture files)
- **Currently passing:** ~750 (46.2%) - after SpecializedStandard deletion
- **Target:** 1,054+ (65%+) - Need +304 identifiers

---

## Fixture Structure Analysis (31 Files)

### ✅ Already Implemented (10 classes, ~750 IDs)

| Class | Fixture File | Count | Status |
|-------|--------------|-------|--------|
| BritishStandard | british_standard.txt | 591 | ✅ Implemented |
| PublishedDocument | published_document.txt | 169 | ✅ Implemented |
| DraftDocument | draft_document.txt | 111 | ✅ Implemented |
| ConsolidatedIdentifier | bundle.txt | 98 | ✅ Implemented |
| PubliclyAvailableSpecification | publicly_available_specification.txt | 59 | ✅ Implemented |
| ValueAddedPublication | value_added_publication.txt | 37 | ✅ Implemented |
| ExpertCommentary | expert_commentary.txt | 29 | ✅ Implemented |
| Flex | flex.txt | 28 | ✅ Implemented |
| NationalAnnex | national_annex.txt | 21 | ✅ Implemented |
| Handbook | handbook.txt | 16 | ✅ Implemented |

**Subtotal:** ~1,159 fixtures (but only ~750 passing due to parser gaps)

### ⏳ High Priority for 65% (5 classes, 429 IDs)

| Class | Fixture File | Count | Effort | Priority |
|-------|--------------|-------|--------|----------|
| **AerospaceStandard** | aerospace_standard.txt | 294 | 2h | **HIGH** ✨ |
| RangeIdentifier | range.txt | 40 | 1h | **QUICK WIN** |
| AutomotiveStandard | automotive_standard.txt | 34 | 45min | Medium |
| SupplementDocument | supplement.txt | 32 | 45min | Medium |
| AddendumDocument | addendum.txt | 29 | 30min | Low |

**Total available:** +429 identifiers (if all implemented would reach 72%+)

### 📋 Lower Priority (16 classes, remaining IDs)

- amendment.txt, corrigendum.txt
- committee_document.txt, detailed_specification.txt
- disc.txt, electronic_book.txt, explanatory_supplement.txt
- index.txt, issue.txt, method.txt
- practice_guide.txt, quality_control.txt
- section.txt, set.txt, supplementary_index.txt
- test_method.txt, tickit.txt

---

## Recommended Implementation Strategy

### SESSION 289: AerospaceStandard (120 min) - HIGHEST IMPACT

**Target:** +294 identifiers → 46% → 64%+ (18pp gain!)

**Why AerospaceStandard first:**
1. **Largest single class** (294 IDs = 18% of total fixtures)
2. **Clear patterns:** Letter prefixes (A, AU, C, M, etc.) + multi-letter (2A, 2B, etc.)
3. **Already in one fixture file** - well organized
4. **Architecture validated** - similar to SpecializedStandard but properly named

#### Part A: Create AerospaceStandard Class (40 min)

**File:** `lib/pubid_new/bsi/identifiers/aerospace_standard.rb`

```ruby
# frozen_string_literal: true

module PubidNew
  module Bsi
    module Identifiers
      # AerospaceStandard handles BSI aerospace/specialized standards
      # with letter prefixes indicating domain categorization
      #
      # Examples:
      #   BS A 109:2024       # Aircraft (A prefix)
      #   BS AU 145e:2018     # Automotive (AU prefix)
      #   BS C 10:1958        # Aircraft (C prefix)
      #   BS M 38:1971        # Methods (M prefix)
      #   BS 2A 293:2005      # Multi-letter prefix (2A)
      class AerospaceStandard < SingleIdentifier
        attribute :prefix, :string

        # Single-letter aerospace/specialized prefixes
        AEROSPACE_PREFIXES = %w[A B C F G HC L M MA PL S SP TA X].freeze

        # Multi-letter prefixes (number + letter combination)
        MULTI_LETTER_PREFIXES = %w[
          2A 2B 2C 2F 2G 2HC 2HR 2L 2M 2S 2SP 2TA 2X
          3A 3B 3F 3G 3HR 3J 3L 3S 3TA
          4F 4L 4S
          5S 7S
        ].freeze

        ALL_PREFIXES = (AEROSPACE_PREFIXES + MULTI_LETTER_PREFIXES).freeze

        def to_s
          parts = []
          parts << publisher.body if publisher
          parts << prefix if prefix
          parts << code.number if code
          # Handle letter suffixes like "145e" or "177a"
          parts << "-#{part.value}" if part
          parts << "-#{subpart.value}" if subpart
          parts << ":#{date.year}" if date
          parts << supplements_portion if respond_to?(:supplements_portion) && supplements_portion
          parts.join(" ")
        end
      end
    end
  end
end
```

#### Part B: Update Parser (50 min)

**File:** `lib/pubid_new/bsi/parser.rb`

Add aerospace prefix patterns:

```ruby
# Aerospace/Specialized prefixes
rule(:aerospace_single_letter) do
  str("A") | str("B") | str("C") | str("F") | str("G") |
  str("HC") | str("L") | str("M") | str("MA") | str("PL") |
  str("S") | str("SP") | str("TA") | str("X")
end

rule(:aerospace_multi_letter) do
  (
    str("2A") | str("2B") | str("2C") | str("2F") | str("2G") |
    str("2HC") | str("2HR") | str("2L") | str("2M") | str("2S") |
    str("2SP") | str("2TA") | str("2X") |
    str("3A") | str("3B") | str("3F") | str("3G") | str("3HR") |
    str("3J") | str("3L") | str("3S") | str("3TA") |
    str("4F") | str("4L") | str("4S") |
    str("5S") | str("7S")
  )
end

rule(:aerospace_prefix) do
  (aerospace_multi_letter | aerospace_single_letter).as(:prefix)
end

# Update identifier rule (add before british_standard rule)
rule(:identifier) do
  aerospace_standard |
  british_standard |
  # ... other patterns
end

rule(:aerospace_standard) do
  publisher >> space >>
  aerospace_prefix >> space >>
  number >>
  # Handle letter suffixes (e.g., "145e", "177a")
  match("[a-z]").maybe.as(:letter_suffix) >>
  (colon >> year).maybe >>
  supplements_portion.maybe
end
```

#### Part C: Update Builder (20 min)

**File:** `lib/pubid_new/bsi/builder.rb`

```ruby
def locate_identifier_klass(parsed_hash)
  # Check for aerospace prefix first
  return Identifiers::AerospaceStandard if parsed_hash[:prefix]

  # ... existing logic
end

# In cast method:
when :prefix
  value.to_s
when :letter_suffix
  value.to_s if value
```

#### Part D: Test & Validate (10 min)

```bash
cd spec/fixtures
ruby run_classify.rb bsi
# Expected: ~750 → ~1,044 (64.4%)
```

---

### SESSION 290: RangeIdentifier (60 min) - QUICK WIN

**Target:** +40 identifiers → 64% → 66.5%

**Patterns:** Multiple connectors for ranges:
- `BS SP 10 & 11:1949` (ampersand)
- `BS SP 115 to 117:1956` (to/TO)
- `BS SP 139 and SP 140:1969` (and)
- `BS SP 13; 14; 15 and 16:1949` (semicolon + and)

#### Implementation

**File:** `lib/pubid_new/bsi/identifiers/range_identifier.rb`

```ruby
class RangeIdentifier < Lutaml::Model::Serializable
  attribute :identifiers, SingleIdentifier, collection: true
  attribute :connectors, :string, collection: true

  def to_s
    # Reconstruct using original connectors
    result = identifiers.first.to_s
    identifiers[1..-1].each_with_index do |id, idx|
      connector = connectors[idx] || " and "
      result += "#{connector}#{id}"
    end
    result
  end
end
```

**Parser enhancement:** Add connector rules and range parsing.

**Expected gain:** +40 IDs (64.4% → 66.9%)

---

### SESSION 291: Supplement/Addendum (75 min) - OPTIONAL

Implement SupplementDocument and AddendumDocument for additional +61 IDs.

**Only proceed if not yet at 65% target.**

---

## Architecture Notes (CRITICAL)

### ValueAddedPublication Wrapper Pattern

**Current implementation should follow IEC VapIdentifier pattern:**

```ruby
# Similar to IEC's VapIdentifier
class ValueAddedPublication < Lutaml::Model::Serializable
  attribute :base_identifier, Identifier  # Wrapped document
  attribute :suffix, :string              # "PDF", "TC", "BOOK", etc.

  def to_s
    "#{base_identifier} #{suffix}"
  end
end
```

**Examples:**
- `PD 5500:2018+A3:2020 PDF` = ValueAddedPublication(base: ConsolidatedIdentifier, suffix: "PDF")
- `BS 7870-2:2022 - TC` = ValueAddedPublication(base: BritishStandard, suffix: "TC")

### ExpertCommentary Wrapper Pattern

**Structure:**
```ruby
class ExpertCommentary < Lutaml::Model::Serializable
  attribute :base_identifier, Identifier
  attribute :topic, :string  # Optional: "(Fire)", etc.

  def to_s
    parts = [base_identifier.to_s, "ExComm"]
    parts << topic if topic
    parts.join(" ")
  end
end
```

**Example structure for `BS EN ISO/IEC 80079-34:2020 ExComm`:**
```
ExpertCommentary {
  base_identifier: BritishStandard {
    adopted_identifier: AdoptedEuropeanNorm {
      adopted_identifier: Iso::InternationalStandard("ISO/IEC 80079-34:2020")
    }
  },
  topic: nil
}
```

**Rendering:** `BS EN ISO/IEC 80079-34:2020 ExComm`

---

## Success Metrics

### Minimum (65%)
- ✅ AerospaceStandard implemented (294 IDs)
- ✅ 1,044+/1,622 (64.4%+)
- ✅ Close to target with one class

### Target (66-67%)
- ✅ AerospaceStandard + RangeIdentifier
- ✅ 1,084+/1,622 (66.9%+)
- ✅ 2 new classes, exceeds 65% target

### Stretch (70%+)
- ✅ Add Supplement/Addendum/Automotive
- ✅ 1,179+/1,622 (72.7%+)
- ✅ 5 new classes

---

## Key Architectural Principles

**MAINTAIN throughout:**
1. **MODEL-DRIVEN** - Each class is proper Lutaml::Model
2. **MECE** - Fixture-based classes are mutually exclusive
3. **Wrapper Pattern** - ValueAddedPublication/ExpertCommentary wrap base identifiers
4. **Component Reuse** - Use existing Code, Date, Publisher components
5. **Follow Fixtures** - Class names MUST match fixture file names
6. **No Arbitrary Classes** - Only create what fixtures show

---

## Files to Create

### Session 289
1. `lib/pubid_new/bsi/identifiers/aerospace_standard.rb`

### Session 290 (if needed)
2. `lib/pubid_new/bsi/identifiers/range_identifier.rb`

### Session 291 (optional)
3. `lib/pubid_new/bsi/identifiers/supplement_document.rb`
4. `lib/pubid_new/bsi/identifiers/addendum_document.rb`

## Files to Modify

**All sessions:**
- `lib/pubid_new/bsi/parser.rb`
- `lib/pubid_new/bsi/builder.rb`
- `lib/pubid_new/bsi/scheme.rb`

---

## Next Immediate Steps (Session 289)

1. ✅ Read this updated continuation plan
2. Create AerospaceStandard class (40 min)
3. Update parser with aerospace patterns (50 min)
4. Update builder for aerospace support (20 min)
5. Test and validate (10 min)
6. Expected: ~750 → ~1,044 (64.4%+)
7. If 65%+ achieved: CELEBRATE! 🎉
8. If <65%: Proceed to Session 290 (RangeIdentifier)

---

**Created:** 2026-01-07
**Current:** ~750/1,622 (46.2%) after SpecializedStandard deletion
**Target:** 1,054/1,622 (65%+) - Need +304 IDs
**Available:** +294 IDs (AerospaceStandard alone!)

**Recommendation:** Implement AerospaceStandard first - likely achieves 64%+ alone! (2h effort)