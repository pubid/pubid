# Session 143 Continuation Prompt: ASTM Flavor Implementation

**IMPORTANT:** Session 142 had a misunderstanding about IEEE/ASTM SI/PSI identifiers. Session 142 has been fully corrected. This session will implement the ASTM flavor properly as the 16th flavor.

---

## Context

**Session 142 Correction Complete:**
- Deleted incorrect SI/PSI classes
- Reverted parser and builder changes
- Understanding: `IEEE/ASTM SI 10-1997` is just IEEE/ASTM copublished with "SI 10" as number
- ASTM already works as IEEE copublisher

**ASTM Flavor Ready:**
- 289 identifiers analyzed in `spec/fixtures/astm/identifiers/full/identifiers.txt`
- 8 distinct identifier types designed (MECE)
- Complete architecture plan in `docs/SESSION-143-CONTINUATION-PLAN.md`

---

## Objective

Implement ASTM as the **16th production-ready flavor** following the V2 MODEL-DRIVEN architecture used in ISO, IEC, OIML, etc.

**Timeline:** COMPRESSED - Complete in 90-120 minutes

**Success Criteria:**
- ✅ 8 identifier classes (Standard, WorkInProgress, Adjunct, TechnicalReport, Manual, Monograph, DataSeries, ResearchReport)
- ✅ Parser handles all 8 patterns with proper priority
- ✅ Builder routes to correct classes
- ✅ 80%+ pass rate on 289 fixtures (230+ identifiers)
- ✅ MODEL-DRIVEN, MECE architecture

---

## Implementation Steps (Follow Strictly)

### Phase 1: Core Files (40 min)

**Step 1: Module Loader (5 min)**

Create `lib/pubid_new/astm.rb`:

```ruby
# frozen_string_literal: true

require_relative "astm/identifier"

module PubidNew
  module Astm
    def self.parse(input)
      Identifier.parse(input)
    end
  end
end
```

**Step 2: Parser (15 min)**

Create `lib/pubid_new/astm/parser.rb` with these rules (priority order):

1. `research_report` - Pattern: `RR:` + Committee + `-` + Number
2. `work_in_progress` - Pattern: `WK` + Number
3. `adjunct` - Pattern: `ADJ` + Code OR just Code with `ADJ` prefix
4. `manual` - Pattern: `MNL` + Number + Edition + `-EB`
5. `monograph` - Pattern: `MONO` + Number + Edition + `-EB`
6. `data_series` - Pattern: `DS` + Code + `-EB`
7. `technical_report` - Pattern: `TR` + Number + `-EB` OR `ISO/ASTMTR` + Number + `-EB`
8. `standard` - Pattern: Letter A-G + Number + `-` + Year (DEFAULT - least specific)

Important parser patterns:

```ruby
# Standard (DEFAULT - most common)
rule(:standard) do
  (str("ASTM") >> space).maybe.as(:publisher) >>
  match("[A-G]").as(:letter) >>
  digits.as(:number) >>
  # Dual unit: /A36M (metric designation)
  (slash >> match("[A-G]") >> digits >> str("M")).maybe.as(:dual_unit) >>
  # Year: -19 or -95
  (dash >> digit.repeat(2,2).as(:year)).maybe >>
  # Sub-year: a, b, c
  match("[a-z]").maybe.as(:sub_year) >>
  # Reapproval: (2023)
  (str("(") >> digit.repeat(4,4).as(:reapproval) >> str(")")).maybe >>
  # Editorial: e1, e2
  (str("e") >> digits.as(:editorial)).maybe
end

# Research Report (colon is key identifier)
rule(:research_report) do
  (str("ASTM") >> space).maybe >>
  str("RR:") >>
  match("[A-Z]") >> digit.repeat(2,2) >>  # A01, C09
  dash >>
  digits.as(:number)
end
```

**Step 3: Builder (10 min)**

Create `lib/pubid_new/astm/builder.rb`:

```ruby
def build(parsed)
  attributes = extract_attributes(parsed)

  # Route based on type
  klass = case
  when parsed[:rr_type] then Identifiers::ResearchReport
  when parsed[:wk_prefix] then Identifiers::WorkInProgress
  when parsed[:adj_prefix] then Identifiers::Adjunct
  when parsed[:mnl_prefix] then Identifiers::Manual
  when parsed[:mono_prefix] then Identifiers::Monograph
  when parsed[:ds_prefix] then Identifiers::DataSeries
  when parsed[:tr_prefix] then Identifiers::TechnicalReport
  else Identifiers::Standard  # DEFAULT
  end

  klass.new(**attributes)
end
```

**Step 4: Base Identifier (10 min)**

Create `lib/pubid_new/astm/identifier.rb` and `lib/pubid_new/astm/single_identifier.rb`

---

### Phase 2: Identifier Classes (30 min)

Create all 8 classes in `lib/pubid_new/astm/identifiers/`:

1. `standard.rb` - Attributes: letter, number, year, sub_year, dual_unit, reapproval, editorial
2. `work_in_progress.rb` - Attributes: wk_number
3. `adjunct.rb` - Attributes: code
4. `technical_report.rb` - Attributes: number, iso_prefix
5. `manual.rb` - Attributes: number, edition
6. `monograph.rb` - Attributes: number, edition
7. `data_series.rb` - Attributes: code
8. `research_report.rb` - Attributes: committee, number

Each class must:
- Inherit from SingleIdentifier
- Include Lutaml::Model::Serializable
- Define proper `to_s` method
- Handle rendering correctly

**Example Standard class:**

```ruby
class Standard < SingleIdentifier
  attribute :letter, :string
  attribute :number, :string
  attribute :year, :string
  attribute :sub_year, :string
  attribute :dual_unit, :string
  attribute :reapproval, :string
  attribute :editorial, :string

  def to_s
    parts = []
    parts << "ASTM" if publisher

    # Letter + Number
    code = "#{letter}#{number}"

    # Dual unit
    code += "/#{dual_unit}" if dual_unit

    parts << code

    # Year
    result = parts.join(" ")
    result += "-#{year}#{sub_year}" if year

    # Reapproval
    result += "(#{reapproval})" if reapproval

    # Editorial
    result += "e#{editorial}" if editorial

    result
  end
end
```

---

### Phase 3: Components (10 min)

Create `lib/pubid_new/astm/components/`:

1. `code.rb` - For letter+number (E2938, F1862)
2. `dual_unit.rb` - For metric designations (F1862M)

---

### Phase 4: Testing (15 min)

Create `spec/pubid_new/astm/identifier_spec.rb` with test cases for all 8 types:

```ruby
RSpec.describe PubidNew::Astm do
  describe ".parse" do
    # Standard tests (pick 3 examples)
    context "standard identifiers" do
      it "parses simple standard" do
        result = described_class.parse("ASTM E2938-15(2023)")
        expect(result).to be_a(PubidNew::Astm::Identifiers::Standard)
        expect(result.letter).to eq("E")
        expect(result.number).to eq("2938")
        expect(result.year).to eq("15")
        expect(result.reapproval).to eq("2023")
        expect(result.to_s).to eq("ASTM E2938-15(2023)")
      end

      it "parses dual unit standard" do
        result = described_class.parse("ASTM F1862/F1862M-17")
        expect(result.dual_unit).to eq("F1862M")
        expect(result.to_s).to eq("ASTM F1862/F1862M-17")
      end
    end

    # Add similar tests for all 8 types...
  end
end
```

---

### Phase 5: Documentation (15 min)

**Update README.adoc** with ASTM section:

```asciidoc
==== ASTM (American Society for Testing and Materials)
- Status: ✅ Production-ready (16th flavor!)
- Features: 8 document types, dual units, editorial versions
- Architecture: Complete V2

.ASTM Document Types (MECE)
[cols="1,2,3"]
|===
|Type |Description |Example

|Standard
|A-G letter designation
|`ASTM E2938-15(2023)`, `ASTM F1862/F1862M-17`

|WorkInProgress
|WK prefix standards
|`ASTM WK91249`

|Adjunct
|ADJ prefix documents
|`ASTM ADJD2148`

|TechnicalReport
|TR prefix reports
|`TR1-EB`, `ISO/ASTMTR52916-EB`

|Manual
|MNL prefix manuals
|`ASTM MNL1-9TH-EB`

|Monograph
|MONO prefix monographs
|`ASTM MONO1-EB`

|DataSeries
|DS prefix series
|`ASTM DS4B-EB`

|ResearchReport
|RR: committee reports
|`ASTM RR:A01-1001`
|===
```

---

## Critical Architecture Principles

1. **MODEL-DRIVEN** - All identifiers are Lutaml::Model objects
2. **MECE** - 8 mutually exclusive identifier classes
3. **Three-layer** - Parser/Builder/Identifier separation
4. **Default class** - Standard handles A-G prefixes (most common)
5. **Component-based** - Reusable Code and DualUnit components

---

## Success Criteria

**Minimum (80%):**
- 8 classes created
- Parser works for Standard (76 IDs)
- 230+/289 fixtures passing

**Target (90%):**
- All 8 types working
- 260+/289 fixtures passing

**Files to Create:** 16 total
- 4 core files
- 1 base file
- 8 identifier files
- 2 component files
- 1 test file

---

**Reference:**
- Plan: `docs/SESSION-143-CONTINUATION-PLAN.md`
- Fixtures: `spec/fixtures/astm/identifiers/full/identifiers.txt` (289 IDs)
- Architecture: V2 MODEL-DRIVEN (like ISO, IEC, OIML)

**End Goal:** ASTM as 16th production-ready flavor with 80%+ validation! 🎉