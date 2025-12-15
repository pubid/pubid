# Session 146+ Continuation Plan: ASTM Semantic Enhancements & ASME Flavor

**Created:** 2025-12-15 (Post-Session 145)
**Status:** ASTM at 100% parsing - Ready for semantic model enhancements + ASME new flavor
**Timeline:** COMPRESSED - Complete in 4-6 sessions (8-12 hours total)
**Priority:** HIGH - All identifier types must be implemented correctly

---

## Executive Summary

**Current Status:**
- **ASTM:** 248/248 (100%) parsing ✅
- **Semantic Model:** Needs 3 enhancements for domain accuracy
- **ASME:** 730 identifiers awaiting implementation (17th flavor)

**Remaining Work:**
1. ASTM: IsoDualPublishedIdentifier type (5xxxx standards)
2. ASTM: Proper Adjunct semantic model (base_standard reference)
3. ASTM: ReferenceRadiograph identifier type (RR prefix)
4. ASME: Complete new flavor implementation (730 IDs)

---

## PART 1: ASTM Semantic Enhancements (Sessions 146-148)

### Session 146: IsoDualPublishedIdentifier (90 min)

**Objective:** Implement proper semantic model for ISO/ASTM dual-published standards

**Current Issue:**
- Identifiers like `ASTM 52303-24e1` parsed as digit-only standards
- Actually represent: ASTM version of ISO/ASTM dual-published document
- ISO version: `ISO/ASTM 52303:2024`

**Implementation:**

**1. Create IsoDualPublishedIdentifier class (30 min)**
File: `lib/pubid_new/astm/identifiers/iso_dual_published.rb`
```ruby
class IsoDualPublishedIdentifier < SingleIdentifier
  # Inherits most behavior from SingleIdentifier
  # Semantic meaning: ASTM version of ISO/ASTM dual standard

  def to_s
    # Render as: ASTM 52303-24e1
    # NOT adding implicit "E" prefix
  end
end
```

**2. Update Builder (30 min)**
File: `lib/pubid_new/astm/builder.rb`
- Detect digit-only starting with "5" as IsoDualPublished
- Route to IsoDualPublishedIdentifier class
- Preserve all existing parsing

**3. Add Tests (30 min)**
File: `spec/pubid_new/astm/identifiers/iso_dual_published_spec.rb`
- Test all 6 patterns from Session 145
- Verify round-trip parsing
- Confirm semantic type correct

**Expected:** 6 identifiers properly typed (already parsing)

---

### Session 147: Adjunct Semantic Model (120 min)

**Objective:** Implement proper adjunct semantic model with base_standard reference

**Current Issue:**
- Adjunct designation parsed as single field
- Should parse: base_standard_code + adjunct_designation separately
- Examples:
  - `ADJF3504-EA` → base=F3504, designation=EA
  - `ADJC033501` → base=C335, designation=01

**Implementation:**

**1. Update Adjunct Parser (40 min)**
File: `lib/pubid_new/astm/parser.rb`
```ruby
rule(:adjunct) do
  publisher.maybe >>
  str("ADJ").as(:type) >>
  adjunct_base_code.as(:base_code) >>  # NEW
  adjunct_designation.as(:designation) >>  # UPDATED
  format_suffix_patterns.maybe
end

rule(:adjunct_base_code) do
  # Parse base standard code (letter+digits OR text)
  (letter >> digits | letters)
end

rule(:adjunct_designation) do
  # Parse designation after base code
  (dash >> (letters | digits | (letter >> digits)) |
   (letters | digits))
end
```

**2. Update Adjunct Identifier (40 min)**
File: `lib/pubid_new/astm/identifiers/adjunct.rb`
```ruby
class Adjunct < SingleIdentifier
  attribute :base_code, Code  # NEW: base standard this is adjunct to
  attribute :designation, :string  # Adjunct identifier (EA, 01, etc.)

  def to_s
    parts = [publisher, "ADJ#{base_code}"]
    parts << "-#{designation}" if designation && designation != ""
    # Handle format suffixes...
  end
end
```

**3. Update Builder (20 min)**
- Parse base_code and designation separately
- Create proper Code object for base
- Handle all format variants

**4. Add Comprehensive Tests (20 min)**
- Test all adjunct patterns from Session 145 semantics
- Verify base_code correctly extracted
- Verify designation correctly extracted
- Test round-trip

**Expected:** All 4 adjuncts with correct semantic structure

---

### Session 148: ReferenceRadiograph Type (90 min)

**Objective:** Implement ReferenceRadiograph as 9th ASTM identifier type

**Pattern Analysis:**
```
RRE341903: Reference radiograph for E3419, volume 03
RRE015501: Reference for E155, volume 01
RRE3185: Reference for E3185
RRE303002-A: Reference for E3030, volume 02, part A
RRE2669CS: Adjunct to E2669 reference
RRE266902: Reference for E2669, volume 02
```

**Implementation:**

**1. Create ReferenceRadiograph Class (30 min)**
File: `lib/pubid_new/astm/identifiers/reference_radiograph.rb`
```ruby
class ReferenceRadiograph < SingleIdentifier
  attribute :base_standard, Code  # E3419, E155, etc.
  attribute :volume, :string  # 01, 02, 03
  attribute :part, :string  # A, B (optional)
  attribute :adjunct_indicator, :string  # CS, etc. (optional)

  def to_s
    "RR#{base_standard}#{volume}#{part}#{adjunct_indicator}"
  end
end
```

**2. Update Parser (30 min)**
```ruby
rule(:reference_radiograph) do
  publisher.maybe >>
  str("RR").as(:type) >>
  rr_base_code.as(:base_code) >>
  rr_volume.maybe.as(:volume) >>
  rr_part.maybe.as(:part) >>
  rr_adjunct.maybe.as(:adjunct_indicator)
end
```

**3. Update Builder & Tests (30 min)**
- Add to identifier rule (BEFORE standard)
- Route to ReferenceRadiograph class
- Tests for all 6 patterns

**Expected:** RR type working (would need fixtures to validate)

---

## PART 2: ASME Flavor Implementation (Sessions 149-151)

### Pattern Analysis (730 identifiers)

**Document Types Identified:**

1. **Standard** (primary type, ~650 IDs)
   - Format: `ASME B31.1-2010`
   - Reaffirmed: `ASME Y14.43-2011 (R2020)`
   - Copublished: `ASME A17.1/CSA B44-2007`

2. **Draft** (~6 IDs)
   - Format: `ASME B18.3-20XX [Draft Proposed Revision of ...]`
   - Format: `ASME Y14.43-202X (Revision of ...)`

3. **Handbook** (~5 IDs)
   - Format: `ASME A17.1/CSA B44 Handbook-2019`

4. **Complex BPVC** (Boiler and Pressure Vessel Code, ~70 IDs)
   - Format: `ASME BPVC.III.1.NB-2015`
   - Format: `ASME BPVC COMPLETE CODE BIND-2019`
   - Format: `ASME BPVC-CC-NUC-2019`

**Code Structure:**
- Designator: Letter (A, B, Y, etc.)
- Number: Digits with optional dots (31.1, 16.5, 89.1.10M)
- Year: 4-digit (2010, 2024, 20XX for drafts)
- Reaffirmed: `(R2020)` notation
- Copublisher: `/CSA`, `/ANS`, `/API`, `/ISO`

---

### Session 149: ASME Parser & Basic Structure (120 min)

**Objective:** Create ASME module, parser, and base identifier structure

**Files to Create:**
1. `lib/pubid_new/asme.rb` - Module entry point
2. `lib/pubid_new/asme/parser.rb` - Parslet grammar
3. `lib/pubid_new/asme/builder.rb` - Object construction
4. `lib/pubid_new/asme/identifier.rb` - Base identifier
5. `lib/pubid_new/asme/single_identifier.rb` - Base for most types
6. `lib/pubid_new/asme/components/code.rb` - Code component

**Parser Patterns (60 min):**
```ruby
rule(:designator) { match("[A-Z]").repeat(1).as(:designator) }
rule(:number) {
  digits >>
  (dot >> digits).repeat.maybe >>
  (str("M") | str("S")).maybe
}
rule(:year) { digit.repeat(4,4).as(:year) | str("20XX").as(:draft_year) | str("202X").as(:draft_year) }
rule(:reaffirmed) { str("(R") >> year >> str(")") }
rule(:copublisher) { slash >> (str("CSA") | str("ANS") | str("API") | str("ISO")) }
```

**Identifier Types (30 min):**
- Standard (primary)
- Draft
- Handbook
- BPVCCompleteCode
- BPVCStandard

**Testing Setup (30 min):**
- Basic parse tests
- Round-trip validation

---

### Session 150: ASME Standard & Draft Types (120 min)

**Objective:** Implement Standard and Draft identifier classes

**1. Standard Identifier (60 min)**
File: `lib/pubid_new/asme/identifiers/standard.rb`
- Basic format: `ASME B31.1-2010`
- Reaffirmed: `ASME Y14.43-2011 (R2020)`
- Copublished: `ASME A17.1/CSA B44-2007`
- Tests: 50 representative patterns

**2. Draft Identifier (30 min)**
File: `lib/pubid_new/asme/identifiers/draft.rb`
- Format: `ASME B18.3-20XX [Draft...]`
- Parse bracket notation
- Tests: All 6 draft patterns

**3. Handbook Identifier (30 min)**
File: `lib/pubid_new/asme/identifiers/handbook.rb`
- Format: `ASME A17.1/CSA B44 Handbook-2019`
- Tests: All 5 handbook patterns

---

### Session 151: ASME BPVC Types & Validation (150 min)

**Objective:** Complete BPVC types and validate all 730 identifiers

**1. BPVC Parser Enhancement (60 min)**
- Parse complex BPVC codes: `BPVC.III.1.NB`
- Parse complete code formats
- Parse special formats (`CC.BPV`, `SSC`, etc.)

**2. BPVC Identifier Classes (45 min)**
- BPVCStandard
- BPVCCompleteCode
- Tests for all ~70 BPVC patterns

**3. Fixture Classification (30 min)**
```bash
ruby spec/fixtures/run_classify.rb asme
```
Target: 700+/730 (95%+)

**4. Fix Remaining Issues (15 min)**
- Address any parser gaps
- Fix rendering issues

---

## Implementation Status Tracker

### ASTM Semantic Enhancements

| Item | Files | Status | Tests | Target |
|------|-------|--------|-------|--------|
| **IsoDualPublished** | 1 new class | ⏳ Pending | 0/6 | 6 IDs |
| **Adjunct Semantics** | 2 updated | ⏳ Pending | 0/4 | 4 IDs |
| **ReferenceRadiograph** | 1 new class | ⏳ Pending | 0/6 | 6 IDs |

**Progress:** 0/3 features (0%)

### ASME Flavor Implementation

| Session | Focus | Files | Status | Tests | Validation |
|---------|-------|-------|--------|-------|------------|
| 149 | Parser & Structure | 6 new | ⏳ | 10+ | - |
| 150 | Standard/Draft/Handbook | 3 new | ⏳ | 60+ | - |
| 151 | BPVC & Validation | 2 new | ⏳ | 70+ | 700+/730 |

**Progress:** 0/730 identifiers (0%)

---

## Timeline Summary

| Sessions | Work | Duration | Deliverables |
|----------|------|----------|--------------|
| 146-148 | ASTM Semantic | 5 hours | 3 identifier types |
| 149-151 | ASME Implementation | 6.5 hours | 730 identifiers |
| **Total** | **All Work** | **11.5 hours** | **Complete** |

---

## Success Criteria

### ASTM (Minimum):
- ✅ IsoDualPublished: 6 IDs with correct type
- ✅ Adjunct: base_code + designation separate
- ✅ ReferenceRadiograph: Proper RR type
- ✅ All 248 still at 100%

### ASME (Target):
- ✅ 700+/730 (95%+) validation
- ✅ All document types working
- ✅ BPVC patterns parsing
- ✅ Round-trip fidelity

---

## Key Architectural Principles

**MAINTAIN throughout:**
1. **MODEL-DRIVEN** - Objects not strings
2. **MECE** - Mutually exclusive types
3. **Three-layer** - Parser/Builder/Identifier
4. **Component reuse** - Shared Code, Date
5. **Semantic accuracy** - Domain-correct models

---

## Files to Create/Modify

### ASTM Enhancements:
**New:**
- `lib/pubid_new/astm/identifiers/iso_dual_published.rb`
- `lib/pubid_new/astm/identifiers/reference_radiograph.rb`
- `spec/pubid_new/astm/identifiers/iso_dual_published_spec.rb`
- `spec/pubid_new/astm/identifiers/reference_radiograph_spec.rb`

**Modified:**
- `lib/pubid_new/astm/parser.rb` - Adjunct & RR patterns
- `lib/pubid_new/astm/builder.rb` - Type routing
- `lib/pubid_new/astm/identifiers/adjunct.rb` - Semantic model
- `spec/pubid_new/astm/identifiers/adjunct_spec.rb` - Tests

### ASME Flavor:
**New (11 files):**
- `lib/pubid_new/asme.rb`
- `lib/pubid_new/asme/parser.rb`
- `lib/pubid_new/asme/builder.rb`
- `lib/pubid_new/asme/identifier.rb`
- `lib/pubid_new/asme/single_identifier.rb`
- `lib/pubid_new/asme/components/code.rb`
- `lib/pubid_new/asme/identifiers/standard.rb`
- `lib/pubid_new/asme/identifiers/draft.rb`
- `lib/pubid_new/asme/identifiers/handbook.rb`
- `lib/pubid_new/asme/identifiers/bpvc_standard.rb`
- `lib/pubid_new/asme/identifiers/bpvc_complete_code.rb`

---

**Created:** 2025-12-15
**Sessions Covered:** 146-151
**Status:** Ready for execution
**Estimated Time:** 11.5 hours (compressed)

**End Goal:** ASTM semantically perfect, ASME 17th flavor at 95%+! 🚀