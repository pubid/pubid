# Session 236+ Continuation Plan: CecIdentifier Implementation for CSA

**Created:** 2025-12-30 (Post-Session 235)
**Status:** 258/362 tests (71.3%)
**Target:** CecIdentifier + baseline 73.8%+
**Timeline:** COMPRESSED - 3-4 sessions (6-8 hours)

---

## Executive Summary

Session 235 discovered that CSA C22.{2,3,4,6} NO. identifiers require a dedicated `CecIdentifier` type (Canadian Electrical Code). The current test expectations that normalize "NO." away are INCORRECT and must be updated.

**Architecture Principle:** "NO." is a semantic component indicating a numbered standard within the C22.x series, NOT a notation to be normalized.

---

## Current State

**Session 235 Results:**
- 258/362 tests (71.3%)
- NO. parser rules added but not fully integrated
- Tests still expect NO. normalization (incorrect)
- Architecture remains MODEL-DRIVEN ✅

**Baseline Gap:** +9 tests needed to reach 267/362 (73.8%)

---

## CecIdentifier Specification

### Pattern Analysis

**C22.x Series (Canadian Electrical Code Parts):**
- C22.2 = Part II (most common)
- C22.3 = Part III
- C22.4 = Part IV
- C22.6 = Part VI
- Note: C22.1 = Part I (does NOT use NO.)
- Note: C22.5 does NOT exist

**Examples:**
```
CSA C22.2 NO. 286:23          # CecIdentifier
CSA C22.2 NO. 0:20            # CecIdentifier
CSA C22.3 NO. 7:20            # CecIdentifier
CAN/CSA-C22.2 NO. 0.16-M92    # CanadianAdopted(CecIdentifier)
```

**Key Pattern:** CecIdentifier = C22.{2,3,4,6} + NO. + number + year

### Component Structure

```ruby
class CecIdentifier < Identifier
  attribute :cec_part, Code          # C22.2, C22.3, etc.
  attribute :no_number, Code         # The number after NO.
  attribute :year, :string
  attribute :year_format, :string    # colon or dash
  attribute :year_prefix, :string    # M or F
  attribute :reaffirmation, :string
  attribute :french, :boolean

  def to_s
    parts = ["CSA"]
    parts << cec_part.value
    parts << "NO."
    parts << no_number.value
    # ... year rendering
  end
end
```

---

## Implementation Plan

### SESSION 236: CecIdentifier Core (2 hours)

#### Phase 1: Create CecIdentifier Class (60 min)

**File:** `lib/pubid_new/csa/identifiers/cec.rb`

**Implementation:**
```ruby
# frozen_string_literal: true

require_relative "../identifier"
require_relative "../components/code"

module PubidNew
  module Csa
    module Identifiers
      # Canadian Electrical Code (CEC) identifier
      # Pattern: CSA C22.{2,3,4,6} NO. {number}:{year}
      # Examples: CSA C22.2 NO. 286:23, CSA C22.3 NO. 7:20
      class Cec < Identifier
        attribute :cec_part, Components::Code      # C22.2, C22.3, etc.
        attribute :no_number, Components::Code     # Number after NO.
        attribute :year, :string
        attribute :year_format, :string
        attribute :year_prefix, :string
        attribute :reaffirmation, :string
        attribute :french, :boolean

        def to_s
          parts = []

          # Publisher (CSA, never CAN/CSA- because that wraps this)
          parts << "CSA"

          # CEC Part (C22.2, C22.3, etc.)
          parts << cec_part.value

          # NO. notation
          parts << "NO."

          # Number
          parts << no_number.value

          # Year
          year_part = render_year
          parts << year_part if year_part

          # Reaffirmation
          parts << "(R#{reaffirmation})" if reaffirmation

          parts.join(" ")
        end

        private

        def render_year
          return nil unless year

          sep = year_format == "dash" ? "-" : ":"
          prefix = year_prefix || ""
          "#{sep}#{prefix}#{year}"
        end
      end
    end
  end
end
```

**Testing:** Create `spec/pubid_new/csa/identifiers/cec_spec.rb` (15 tests minimum)

#### Phase 2: Update Parser (45 min)

**File:** `lib/pubid_new/csa/parser.rb`

**Add CEC pattern recognition:**
```ruby
# CEC (Canadian Electrical Code) identifier
# Pattern: CSA C22.{2,3,4,6} NO. {number}:{year}
rule(:cec_identifier) do
  publisher >>
  (str("C22.2") | str("C22.3") | str("C22.4") | str("C22.6")).as(:cec_part) >>
  no_notation >>
  no_number >>
  (colon_year | dash_year) >>
  reaffirmation.maybe
end

# Update main identifier rule (CEC before single_identifier)
rule(:identifier) do
  iso_iec_adoption |
  series_identifier |
  cec_identifier |      # NEW: Add CEC before single_identifier
  bundled_identifier |
  combined_slash |
  combined_comma |
  single_identifier |
  code_only_identifier
end
```

#### Phase 3: Update Builder (15 min)

**File:** `lib/pubid_new/csa/builder.rb`

**Add CEC building:**
```ruby
def build(parsed_hash)
  # Handle CEC identifiers (C22.x NO. patterns)
  if parsed_hash.key?(:cec_part)
    return build_cec(parsed_hash)
  end

  # ... existing logic
end

def build_cec(parsed_hash)
  require_relative "identifiers/cec"
  cec = Identifiers::Cec.new

  # CEC part
  cec.cec_part = Components::Code.new(value: parsed_hash[:cec_part].to_s)

  # NO. number
  cec.no_number = Components::Code.new(value: parsed_hash[:no_number].to_s)

  # Year format and year
  year_format = parsed_hash[:dash_format] ? "dash" : "colon"
  cec.year = convert_year(parsed_hash[:year], parsed_hash[:year_prefix])
  cec.year_format = year_format
  cec.year_prefix = parsed_hash[:year_prefix].to_s if parsed_hash[:year_prefix]

  # French flag
  cec.french = true if parsed_hash[:year_prefix]&.to_s == "F"

  # Reaffirmation
  cec.reaffirmation = parsed_hash[:reaffirmation].to_s if parsed_hash[:reaffirmation]

  cec
end
```

---

### SESSION 237: Test Expectations Update (2-3 hours)

#### Phase 1: Update Base Spec (45 min)

**File:** `spec/pubid_new/csa/identifiers/base_spec.rb`

**Change all NO. test expectations:**

Before:
```ruby
it "parses code (NO. normalized to dash)" do
  expect(parsed.code.value).to eq("C22.2-286")
end
```

After:
```ruby
it "parses as CecIdentifier" do
  expect(parsed).to be_a(PubidNew::Csa::Identifiers::Cec)
end

it "parses CEC part" do
  expect(parsed.cec_part.value).to eq("C22.2")
end

it "parses NO. number" do
  expect(parsed.no_number.value).to eq("286")
end
```

**Estimated:** ~15 test updates

#### Phase 2: Update CanadianAdopted Spec (60 min)

**File:** `spec/pubid_new/csa/identifiers/canadian_adopted_spec.rb`

**Update for wrapped CEC:**
```ruby
describe "CAN/CSA-C22.2 NO. 0.16-M92 (R2001)" do
  it "parses as CanadianAdopted" do
    expect(parsed).to be_a(PubidNew::Csa::Identifiers::CanadianAdopted)
  end

  it "wraps CecIdentifier" do
    expect(parsed.identifier).to be_a(PubidNew::Csa::Identifiers::Cec)
  end

  it "parses CEC part" do
    expect(parsed.identifier.cec_part.value).to eq("C22.2")
  end

  it "parses NO. number" do
    expect(parsed.identifier.no_number.value).to eq("0.16")
  end
end
```

**Estimated:** ~20 test updates

#### Phase 3: Update Other Specs (45 min)

**Files:**
- `spec/pubid_new/csa/identifiers/bundled_spec.rb`
- `spec/pubid_new/csa/identifiers/combined_spec.rb`
- `spec/pubid_new/csa/identifiers/series_spec.rb`

**Remove invalid bundled NO. tests** (as noted by user - hallucinated specs)

**Estimated:** ~10 test updates

---

### SESSION 238: CanadianAdopted Integration (2 hours)

#### Phase 1: Update CanadianAdopted (45 min)

**File:** `lib/pubid_new/csa/identifiers/canadian_adopted.rb`

**Handle hyphen vs space:**
```ruby
def to_s
  parts = []
  parts << prefix  # "CAN/CSA-" or "CAN3-"

  # Render inner identifier
  inner = identifier.to_s

  # Replace "CSA " with "CSA-" for CAN/CSA- prefix
  # "CSA C22.2" → "CSA-C22.2"
  if prefix == "CAN/CSA-" && inner.start_with?("CSA ")
    inner = inner.sub("CSA ", "CSA-")
  end

  parts << inner.sub(/^CSA\s*/, "")  # Remove "CSA" or "CSA-" from inner

  parts.join
end
```

#### Phase 2: Integration Testing (60 min)

**Test all patterns:**
- CSA C22.2 NO. 286:23 → CecIdentifier
- CAN/CSA-C22.2 NO. 286:23 → CanadianAdopted(CecIdentifier)
- Round-trip fidelity
- Year formats (colon vs dash)
- M/F prefixes
- Reaffirmation

#### Phase 3: Validation (15 min)

Run full test suite - expect 73.8%+ with proper CEC implementation.

---

## Architecture Principles

**MAINTAIN throughout:**
1. **MODEL-DRIVEN** - CecIdentifier is an object, NO. is preserved
2. **MECE** - CecIdentifier is distinct from Standard
3. **Separation of Concerns** - Parser recognizes, Builder constructs, Identifier renders
4. **Open/Closed** - Extensible for other Cx.x patterns if needed
5. **Single Responsibility** - CecIdentifier handles ONLY C22.x NO. patterns

**Pattern:** C22.x detection → CecIdentifier → Preserved NO. notation

---

## Testing Strategy

### Test Coverage Goals

1. **CecIdentifier Direct (15 tests):**
   - C22.2, C22.3, C22.4, C22.6 patterns
   - NO. number variations (simple, dotted, dashed)
   - Year formats (colon, dash)
   - M/F prefixes
   - Reaffirmation

2. **CanadianAdopted Wrapping (10 tests):**
   - CAN/CSA- with CEC
   - CAN3- with CEC
   - Hyphen vs space rendering
   - Round-trip fidelity

3. **Edge Cases (5 tests):**
   - Invalid C22.x (C22.1, C22.5)
   - Missing NO.
   - Complex NO. numbers

**Total NEW tests:** ~30
**Updated tests:** ~45

---

## Success Criteria

### Minimum (80%)
- ✅ CecIdentifier class implemented
- ✅ Parser recognizes C22.x NO. patterns
- ✅ Builder routes to CecIdentifier
- ✅ 15+ CEC tests passing
- ✅ 267+/362 (73.8%+) baseline achieved

### Target (85%)
- ✅ CanadianAdopted wrapping working
- ✅ All test expectations updated correctly
- ✅ Round-trip fidelity 100%
- ✅ 280+/362 (77.3%+)

### Stretch (90%)
- ✅ Complete integration
- ✅ All edge cases handled
- ✅ 310+/362 (85.6%+)

---

## Files to Create/Modify

### New Files
1. `lib/pubid_new/csa/identifiers/cec.rb`
2. `spec/pubid_new/csa/identifiers/cec_spec.rb`

### Modified Files
1. `lib/pubid_new/csa/parser.rb` - Add cec_identifier rule
2. `lib/pubid_new/csa/builder.rb` - Add build_cec method
3. `lib/pubid_new/csa/identifiers/canadian_adopted.rb` - Handle CEC hyphen
4. `spec/pubid_new/csa/identifiers/base_spec.rb` - Update NO. expectations
5. `spec/pubid_new/csa/identifiers/canadian_adopted_spec.rb` - Update NO. expectations
6. `spec/pubid_new/csa/identifiers/bundled_spec.rb` - Remove invalid tests
7. `spec/pubid_new/csa/identifiers/combined_spec.rb` - Remove invalid tests
8. `spec/pubid_new/csa/identifiers/series_spec.rb` - Update NO. expectations

---

## Timeline Summary

| Session | Focus | Duration | Deliverables |
|---------|-------|----------|--------------|
| 236 | CecIdentifier class + parser | 120 min | Core implementation |
| 237 | Test expectations update | 150 min | All specs corrected |
| 238 | CanadianAdopted integration | 120 min | Complete + baseline |
| **Total** | **CEC implementation** | **390 min** | **73.8%+** |

---

## Next Steps (Session 236)

1. Create CecIdentifier class
2. Add cec_identifier parser rule
3. Update Builder with build_cec
4. Create cec_spec.rb with 15 tests
5. Validate core functionality

---

**Created:** 2025-12-30
**Sessions Covered:** 236-238
**Status:** Ready for execution
**Estimated Time:** 6.5 hours (compressed)

**End Goal:** CecIdentifier implemented correctly, "NO." preserved, baseline 73.8%+ achieved! 🎯