# Session 97+ Continuation Plan: ISO/IEC Advanced Rendering Styles

**Created:** 2025-12-09 (Post-Session 96)
**Status:** Fixtures organized, Advanced rendering system needed
**Current:** ISO 98.24%, IEC 99.93% - both production-ready
**Timeline:** COMPRESSED - Complete within 4-6 sessions (Sessions 97-102)

---

## Executive Summary

**Session 96 Achievement:** Fixtures organization complete for all flavors!

**New Requirement:** Implement V1-compatible advanced rendering styles system for ISO and IEC flavors.

Remember ISO single-char langs include EFARDS. The same 6 ISO reference formats also apply to IEC (IEC has different stage codes), but tailor to it.

**Scope:**
1. **Phase 1 (Sessions 97-98):** ISO rendering styles implementation (4 hours)
2. **Phase 2 (Session 99):** IEC rendering styles implementation (2 hours)
3. **Phase 3 (Sessions 100-101):** Testing and validation (4 hours)
4. **Phase 4 (Session 102):** Documentation updates (2 hours)


**End Goal:** ISO and IEC support all 6 V1 reference formats with configurable language codes and stage formats

---

## Current State (Session 96 Complete)

### Fixtures Organization ✅

**Successfully extracted and organized:**
- **ISO**: 7,688 identifiers (98.24% pass, 16 classes)
- **IEC**: 13,824 identifiers (99.93% pass, 14 classes)
- **IEEE**: 10,330 identifiers (49.58% pass, 9 classes)
- **NIST**: 20,348 identifiers (98.03% pass, 17 classes)

**Total:** 52,190 identifiers organized into pass/fail by class

### Amendment Legacy Support ✅

Fixed ISO Amendment to support legacy typed stages:
- **PDAM** (legacy Committee Draft)
- **FPDAM** (legacy Final Proposed Draft)
- **AMD, Amd.** (legacy published forms)
- Modern variants (DAmd, FDAmd) normalize to canonical

**Result:** Amendment pass rate 63.96% → 95.94% (+31.98pp)

---

## PHASE 1: ISO Advanced Rendering Styles (Sessions 97-98)

### Objective

Implement 6 V1-compatible reference formats for ISO identifiers:

| Format | Language | Stage Format | Date | Example |
|--------|----------|--------------|------|---------|
| `:ref_num_short` | 1-char (E) | Short (DAM) | Yes | `ISO 8601:2019(E)/DAM 1` |
| `:ref_num_long` | 2-char (en) | Long (DAmd) | Yes | `ISO 8601:2019(en)/DAmd 1` |
| `:ref_dated` | None | Short (DAM) | Yes | `ISO 8601:2019/DAM 1` |
| `:ref_dated_long` | None | Long (DAmd) | Yes | `ISO 8601:2019/DAmd 1` |
| `:ref_undated` | None | Short (DAM) | No | `ISO 8601/DAM 1` |
| `:ref_undated_long` | None | Long (DAmd) | No | `ISO 8601/DAmd 1` |

### Session 97: ISO Architecture & Components (120 min)

#### Part A: Enhance TypedStage Component (40 min)

**Objective:** Add short/long abbreviation support

**Tasks:**

1. Read current TypedStage implementation
2. Add `short_abbr` and `long_abbr` attributes
3. Enhance `abbreviation()` method to accept `format` parameter
4. Update Amendment and Corrigendum TYPED_STAGES

**Files to modify:**
- [`lib/pubid_new/components/typed_stage.rb`](lib/pubid_new/components/typed_stage.rb:1)

**Implementation:**
```ruby
class TypedStage
  attribute :short_abbr, :string  # DAM, COR, FDAM
  attribute :long_abbr, :string   # DAmd, Cor, FDAmd

  def abbreviation(format_long: true)
    # Return original if set (preserves parsed form)
    return original_abbr if original_abbr

    # Otherwise use format preference
    if format_long && long_abbr
      long_abbr
    elsif !format_long && short_abbr
      short_abbr
    else
      abbr.first  # Fallback to canonical
    end
  end
end
```

#### Part B: Update Amendment TYPED_STAGES (40 min)

**Objective:** Define short/long forms for all stages

**Files to modify:**
- [`lib/pubid_new/iso/identifiers/amendment.rb`](lib/pubid_new/iso/identifiers/amendment.rb:1)

**Implementation:**
```ruby
TYPED_STAGES = [
  Components::TypedStage.new(
    code: :cdamd,
    stage_code: :cd,
    type_code: :amd,
    abbr: ["CD Amd"],
    short_abbr: nil,           # No short form
    long_abbr: "CD Amd",       # Only long form
    name: "Committee Draft for Amendment",
    harmonized_stages: %w[30.00 ...],
  ),
  Components::TypedStage.new(
    code: :damd,
    stage_code: :damd,
    type_code: :amd,
    abbr: ["DAM", "DAmd"],
    short_abbr: "DAM",         # Short form
    long_abbr: "DAmd",         # Long form
    name: "Draft Amendment",
    harmonized_stages: %w[40.00 ...],
  ),
  # ... similar for all stages
]
```

#### Part C: Update Corrigendum TYPED_STAGES (40 min)

**Objective:** Define short/long forms for corrigenda

**Files to modify:**
- [`lib/pubid_new/iso/identifiers/corrigendum.rb`](lib/pubid_new/iso/identifiers/corrigendum.rb:1)

**Implementation:**
```ruby
TYPED_STAGES = [
  Components::TypedStage.new(
    code: :dcor,
    short_abbr: "DCOR",
    long_abbr: "DCor",
    # ...
  ),
  Components::TypedStage.new(
    code: :fdcor,
    short_abbr: "FDCOR",
    longabbr: "FDCor",
    # ...
  ),
]
```

---

### Session 98: ISO Rendering Implementation (120 min)

#### Part A: Add `to_s` Parameters (45 min)

**Objective:** Support format parameter in all identifier classes

**Files to modify:**
- [`lib/pubid_new/iso/identifier.rb`](lib/pubid_new/iso/identifier.rb:1) (base class)
- [`lib/pubid_new/iso/single_identifier.rb`](lib/pubid_new/iso/single_identifier.rb:1)
- [`lib/pubid_new/iso/supplement_identifier.rb`](lib/pubid_new/iso/supplement_identifier.rb:1)

**Current signature:**
```ruby
def to_s(lang: :en, lang_single: false, with_edition: false)
```

**New signature:**
```ruby
def to_s(
  lang: :en,
  lang_single: false,
  with_edition: false,
  format: :ref_dated_long,
  stage_format_long: nil,  # Auto-detect from format if nil
  with_date: nil           # Auto-detect from format if nil
)
```

#### Part B: Implement Format Resolution (30 min)

**Objective:** Convert format symbols to rendering options

**Files to create:**
- `lib/pubid_new/iso/format_resolver.rb`

**Implementation:**
```ruby
module PubidNew
  module Iso
    class FormatResolver
      FORMATS = {
        ref_num_short: {
          with_language_code: :single,      # 1-char: E, F, R
          stage_format_long: false,         # Short: DAM, COR
          with_date: true
        },
        ref_num_long: {
          with_language_code: :iso,         # 2-char: en, fr, ru
          stage_format_long: true,          # Long: DAmd, Cor
          with_date: true
        },
        ref_dated: {
          with_language_code: :none,
          stage_format_long: false,
          with_date: true
        },
        ref_dated_long: {
          with_language_code: :none,
          stage_format_long: true,
          with_date: true
        },
        ref_undated: {
          with_language_code: :none,
          stage_format_long: false,
          with_date: false
        },
        ref_undated_long: {
          with_language_code: :none,
          stage_format_long: true,
          with_date: false
        }
      }.freeze

      def self.resolve(format)
        FORMATS[format] || raise(ArgumentError, "Unknown format: #{format}")
      end
    end
  end
end
```

#### Part C: Update Rendering Logic (45 min)

**Objective:** Apply format options in to_s methods

**Files to modify:**
- [`lib/pubid_new/iso/single_identifier.rb`](lib/pubid_new/iso/single_identifier.rb:1)
- [`lib/pubid_new/iso/supplement_identifier.rb`](lib/pubid_new/iso/supplement_identifier.rb:1)

**Key changes:**

1. Resolve format to options
2. Pass `stage_format_long` to `typed_stage.abbreviation(format_long: ...)`
3. Handle `with_date` option to exclude/include year
4. Handle `with_language_code` option (:single, :iso, :none)

---

## PHASE 2: IEC Advanced Rendering Styles (Session 99)

### Session 99: IEC Rendering Styles (120 min)

#### Objective

Implement same 6 reference formats for IEC identifiers, tailored to IEC stage codes.

#### Part A: IEC TypedStage Enhancement (40 min)

**Files to modify:**
- All IEC identifier classes with TYPED_STAGES

**IEC-specific stages:**
```ruby
# Amendment
CD: short="CDV", long="CD"
FDIS: short="FDIS", long="FDIS" (same)
Published: short="AMD1", long="Amd 1"

# Corrigendum
FDIS: short="FDIS", long="FDIS"
Published: short="COR1", long="Cor 1"
```

#### Part B: IEC Format Resolver (30 min)

**Files to create:**
- `lib/pubid_new/iec/format_resolver.rb`

**Implementation:** Same structure as ISO but with IEC-specific defaults

#### Part C: IEC Rendering Update (50 min)

**Files to modify:**
- [`lib/pubid_new/iec/identifier.rb`](lib/pubid_new/iec/identifier.rb:1)
- [`lib/pubid_new/iec/single_identifier.rb`](lib/pubid_new/iec/single_identifier.rb:1)
- [`lib/pubid_new/iec/supplement_identifier.rb`](lib/pubid_new/iec/supplement_identifier.rb:1)

---

## PHASE 3: Testing and Validation (Sessions 100-101)

### Session 100: ISO Format Testing (120 min)

#### Objective

Create comprehensive tests for all 6 ISO reference formats.

#### Tasks

1. **Create format spec** (60 min)
   - Test each of 6 formats with multiple identifier types
   - Verify language code rendering (1-char vs 2-char)
   - Verify stage format (short vs long)
   - Verify date inclusion/exclusion

**File to create:**
- `spec/pubid_new/iso/format_spec.rb`

2. **Run fixtures tests** (30 min)
   - Verify no regressions
   - Test format parameter on real identifiers

3. **Fix issues** (30 min)
   - Address any test failures
   - Refine implementation

---

### Session 101: IEC Format Testing (120 min)

#### Objective

Create comprehensive tests for all 6 IEC reference formats.

#### Tasks

1. **Create format spec** (60 min)
   - Test each of 6 formats with IEC identifier types
   - Verify IEC-specific stage rendering

**File to create:**
- `spec/pubid_new/iec/format_spec.rb`

2. **Run fixtures tests** (30 min)
3. **Fix issues** (30 min)

---

## PHASE 4: Documentation (Session 102)

### Session 102: Documentation Updates (120 min)

#### Part A: Update Memory Bank (30 min)

**Files to update:**
- `.kilocode/rules/memory-bank/context.md` - Add Session 97-101 progress
- `.kilocode/rules/memory-bank/architecture.md` - Add rendering styles section

#### Part B: Create Rendering Guide (40 min)

**File to create:**
- `docs/RENDERING_GUIDE.md`

**Content:**
- Overview of 6 reference formats
- Examples for each format
- Language code options
- Stage format options
- Usage examples
- API reference

#### Part C: Update README (30 min)

**File to update:**
- `README.adoc`

**Sections to add:**
- Advanced rendering section
- Reference format examples
- Link to rendering guide

#### Part D: Archive Temporary Docs (20 min)

**Move to old-docs/:**
```bash
mkdir -p docs/old-docs/sessions
mv docs/session-*-*.md docs/old-docs/sessions/
mv docs/ieee-implementation-status.md docs/old-docs/
mv docs/SESSION-*.md docs/old-docs/sessions/
```

---

## Implementation Architecture

### Core Principles

1. **MECE Organization**
   - Each format option is mutually exclusive
   - All valid combinations are supported
   - No overlapping functionality

2. **Separation of Concerns**
   - FormatResolver: Format symbol → Options hash
   - TypedStage: Short/long abbreviation logic
   - Identifier: Rendering orchestration
   - Language: 1-char vs 2-char conversion

3. **Open/Closed Principle**
   - New formats added via FormatResolver.FORMATS hash
   - TypedStage extensions don't modify base
   - Identifier classes delegate to components

4. **One Responsibility**
   - FormatResolver: Only format resolution
   - TypedStage: Only abbreviation selection
   - Language: Only language code rendering
   - Date: Date inclusion/exclusion logic

### Component Responsibilities

**FormatResolver:**
- Maps format symbols to options
- Validates format is supported
- Returns options hash

**TypedStage:**
- Stores short_abbr and long_abbr
- Returns appropriate abbreviation based on format_long
- Preserves original_abbr when set

**Identifier:**
- Accepts format parameter
- Resolves format to options
- Delegates to components with options
- Assembles final string

**Language:**
- Renders as 1-char or 2-char based on parameter
- Preserves original_code for round-trip

---

## Testing Strategy

### Unit Tests

**TypedStage Component:**
```ruby
describe Components::TypedStage do
  let(:stage) {
    Components::TypedStage.new(
      abbr: ["DAM", "DAmd"],
      short_abbr: "DAM",
      long_abbr: "DAmd"
    )
  }

  it "returns short abbreviation when format_long is false" do
    expect(stage.abbreviation(format_long: false)).to eq("DAM")
  end

  it "returns long abbreviation when format_long is true" do
    expect(stage.abbreviation(format_long: true)).to eq("DAmd")
  end
end
```

**FormatResolver:**
```ruby
describe Iso::FormatResolver do
  it "resolves ref_num_short format" do
    options = described_class.resolve(:ref_num_short)
    expect(options[:with_language_code]).to eq(:single)
    expect(options[:stage_format_long]).to eq(false)
    expect(options[:with_date]).to eq(true)
  end
end
```

### Integration Tests

**Format Spec:**
```ruby
describe "ISO Reference Formats" do
  let(:amendment) { PubidNew::Iso.parse("ISO 8601:2019/DAM 1") }

  describe ":ref_num_short" do
    it "renders with 1-char lang + short stage + date" do
      expect(amendment.to_s(format: :ref_num_short, lang: :en))
        .to eq("ISO 8601:2019(E)/DAM 1")
    end
  end

  describe ":ref_num_long" do
    it "renders with 2-char lang + long stage + date" do
      expect(amendment.to_s(format: :ref_num_long, lang: :en))
        .to eq("ISO 8601:2019(en)/DAmd 1")
    end
  end

  # ... test all 6 formats
end
```

---

## Success Criteria

### Session 97 (ISO Architecture)
- ✅ TypedStage has short_abbr and long_abbr
- ✅ FormatResolver implemented
- ✅ Amendment and Corrigendum stages defined
- ✅ Basic tests passing

### Session 98 (ISO Rendering)
- ✅ All identifier classes support format parameter
- ✅ 6 formats working correctly
- ✅ Language code options work (1-char, 2-char, none)
- ✅ Date inclusion/exclusion works

### Session 99 (IEC Implementation)
- ✅ IEC FormatResolver created
- ✅ IEC TypedStages updated
- ✅ IEC renderers support format
- ✅ 6 formats working for IEC

### Sessions 100-101 (Testing)
- ✅ Comprehensive format specs created
- ✅ No regressions in fixtures tests
- ✅ Edge cases covered

### Session 102 (Documentation)
- ✅ RENDERING_GUIDE.md created
- ✅ README.adoc updated
- ✅ Memory bank updated
- ✅ Temporary docs archived

---

## File Structure Reference

### Files to Create

```
lib/pubid_new/iso/
├── format_resolver.rb          # NEW - Format symbol to options

lib/pubid_new/iec/
├── format_resolver.rb          # NEW - IEC format resolver

spec/pubid_new/iso/
├── format_spec.rb              # NEW - 6 format tests

spec/pubid_new/iec/
├── format_spec.rb              # NEW - IEC format tests

docs/
├── RENDERING_GUIDE.md          # NEW - User documentation
└── old-docs/                   # NEW - Archived temporary docs
    └── sessions/
```

### Files to Modify

```
lib/pubid_new/components/
├── typed_stage.rb              # ADD short_abbr, long_abbr, format param

lib/pubid_new/iso/
├── identifier.rb               # ADD format parameter
├── single_identifier.rb        # APPLY format options
├── supplement_identifier.rb    # APPLY format options
└── identifiers/
    ├── amendment.rb            # UPDATE TYPED_STAGES with short/long
    └── corrigendum.rb          # UPDATE TYPED_STAGES with short/long

lib/pubid_new/iec/
├── identifier.rb               # ADD format parameter
├── single_identifier.rb        # APPLY format options
├── supplement_identifier.rb    # APPLY format options
└── identifiers/
    ├── amendment.rb            # UPDATE TYPED_STAGES
    └── corrigendum.rb          # UPDATE TYPED_STAGES

README.adoc                     # ADD advanced rendering section
```

---

## Key Implementation Patterns

### Format Resolution Pattern

```ruby
def to_s(format: :ref_dated_long, **opts)
  # Resolve format to options
  format_opts = FormatResolver.resolve(format)

  # Merge with explicit opts (explicit opts override format)
  resolved_opts = format_opts.merge(opts.compact)

  # Use resolved options for rendering
  render_with_options(resolved_opts)
end
```

### Stage Format Pattern

```ruby
# In SupplementIdentifier
abbr = typed_stage.abbreviation(
  format_long: opts[:stage_format_long]
)
```

### Language Code Pattern

```ruby
# In Language component
def to_s(single: false)
  single ? original_code : code
end
```

### Date Inclusion Pattern

```ruby
# In SingleIdentifier
parts << ":#{date.year}" if date && opts[:with_date]
```

---

## Risk Management

### Low Risk
- TypedStage enhancement (well-defined interface)
- FormatResolver (isolated component)
- Format parameter propagation

### Medium Risk
- Extensive changes to rendering logic
- Many identifier classes to update
- Potential for regressions

### Mitigation
- Implement incrementally (one format at a time)
- Test after each change
- Keep fixtures tests running
- Default format maintains current behavior

---

## Timeline Summary

| Session | Focus | Duration | Deliverables |
|---------|-------|----------|--------------|
| 97 | ISO Architecture | 120 min | TypedStage enhanced, TYPED_STAGES updated |
| 98 | ISO Rendering | 120 min | All 6 formats working for ISO |
| 99 | IEC Implementation | 120 min | All 6 formats working for IEC |
| 100 | ISO Testing | 120 min | Comprehensive format specs |
| 101 | IEC Testing | 120 min | IEC format validation |
| 102 | Documentation | 120 min | Guides, README, cleanup |
| **Total** | **All work** | **720 min (12 hours)** | **Complete** |

---

## Session 97 Start Checklist

**Before starting:**
1. ✅ Read this continuation plan
2. ✅ Read [`archived-gems/pubid-iso/lib/pubid/iso/identifier/base.rb:230-257`](archived-gems/pubid-iso/lib/pubid/iso/identifier/base.rb:230)
3. ✅ Read [`lib/pubid_new/components/typed_stage.rb`](lib/pubid_new/components/typed_stage.rb:1)
4. ✅ Read [`lib/pubid_new/iso/identifiers/amendment.rb`](lib/pubid_new/iso/identifiers/amendment.rb:1)

**First task:**
Enhance TypedStage component with short_abbr and long_abbr attributes

**Then:**
Update Amendment TYPED_STAGES with short/long forms

---

## Notes

### Backward Compatibility

- Default format: `:ref_dated_long` (current behavior)
- Existing code continues to work unchanged
- New formats are opt-in

### Stage Format Rules

**ISO Amendment:**
- Short: DAM, FDAM, AMD (all uppercase)
- Long: DAmd, FDAmd, Amd (mixed case)
- No short: CD Amd, NP Amd, WD Amd (use long only)

**ISO Corrigendum:**
- Short: DCOR, FDCOR, COR (all uppercase)
- Long: DCor, FDCor, Cor (mixed case)
- No short: CD Cor, NP Cor, WD Cor (use long only)

**IEC stages follow similar patterns** but with IEC-specific abbreviations.

---

**Good luck with Session 97 - ISO rendering styles enhancement!** 🚀

**Remember:** Architecture correctness > Test pass rate. Fixtures organization is complete, now we're adding advanced features!