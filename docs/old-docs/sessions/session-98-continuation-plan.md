After this work, update the fixtures.

# Session 98+ Continuation Plan: ISO/IEC Advanced Rendering Implementation

**Created:** 2025-12-09 (Post-Session 97)
**Status:** TypedStage enhanced, Rendering implementation needed
**Current:** ISO 968/997 (97.1%), 29 expected failures for format tests
**Timeline:** COMPRESSED - Complete within 5 sessions (Sessions 98-102)

---

## Executive Summary

**Session 97 Achievement:** TypedStage enhanced with short/long abbreviation support!

**Remaining Work:**
1. **Session 98:** ISO FormatResolver + Rendering (120 min)
2. **Session 99:** IEC Rendering Styles (120 min)
3. **Sessions 100-101:** Testing and validation (240 min)
4. **Session 102:** Documentation updates (120 min)

**End Goal:** ISO and IEC support all 6 V1-compatible reference formats with configurable language codes and stage formats

---

## Current State (Session 97 Complete)

### TypedStage Enhancement ✅

**Component updated:** [`lib/pubid_new/components/typed_stage.rb`](lib/pubid_new/components/typed_stage.rb:1)
- Added `short_abbr` and `long_abbr` attributes
- Enhanced `abbreviation(format_long:)` method
- Preserves `original_abbr` for round-trip fidelity

### TYPED_STAGES Updated ✅

**Amendment:** [`lib/pubid_new/iso/identifiers/amendment.rb`](lib/pubid_new/iso/identifiers/amendment.rb:1)
- All 11 stages have short/long forms defined
- Modern stages: DAM/DAmd, FDAM/FDAmd, AMD/Amd

**Corrigendum:** [`lib/pubid_new/iso/identifiers/corrigendum.rb`](lib/pubid_new/iso/identifiers/corrigendum.rb:1)
- All 9 stages have short/long forms defined
- Modern stages: DCOR/DCor, FDCOR/FDCor, COR/Cor

### Test Results

- **Total:** 997 examples
- **Passing:** 968 (97.1%)
- **Failing:** 29 (2.9% - expected format failures)
- **Status:** Architecture complete, rendering needed

---

## SESSION 98: ISO FormatResolver + Rendering (120 minutes)

### Objective

Implement FormatResolver class and update rendering logic to support all 6 ISO reference formats.

### Part A: Create FormatResolver Class (30 min)

**File to create:** `lib/pubid_new/iso/format_resolver.rb`

**Implementation:**
```ruby
module PubidNew
  module Iso
    class FormatResolver
      FORMATS = {
        ref_num_short: {
          with_language_code: :single,      # 1-char: E, F, R, A, S, D
          stage_format_long: false,         # Short: DAM, COR
          with_date: true
        },
        ref_num_long: {
          with_language_code: :iso,         # 2-char: en, fr, ru, ar, es, de
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

### Part B: Update Identifier Base Class (30 min)

**File to modify:** [`lib/pubid_new/iso/identifier.rb`](lib/pubid_new/iso/identifier.rb:1)

**Add format parameter to to_s:**
```ruby
def to_s(
  lang: :en,
  lang_single: false,
  with_edition: false,
  format: :ref_dated_long,
  stage_format_long: nil,  # Auto-detect from format if nil
  with_date: nil           # Auto-detect from format if nil
)
  # Resolve format if provided
  if format
    format_opts = FormatResolver.resolve(format)
    stage_format_long = format_opts[:stage_format_long] if stage_format_long.nil?
    with_date = format_opts[:with_date] if with_date.nil?
    with_language_code = format_opts[:with_language_code]
  end

  # Delegate to rendering
  render_identifier(
    lang: lang,
    lang_single: lang_single || with_language_code == :single,
    with_edition: with_edition,
    stage_format_long: stage_format_long,
    with_date: with_date,
    with_language_code: with_language_code
  )
end
```

### Part C: Update SupplementIdentifier Rendering (30 min)

**File to modify:** [`lib/pubid_new/iso/supplement_identifier.rb`](lib/pubid_new/iso/supplement_identifier.rb:1)

**Update supplement rendering to use typed_stage.abbreviation:**
```ruby
def supplement_portion(stage_format_long: true)
  return "" unless typed_stage

  abbr = typed_stage.abbreviation(format_long: stage_format_long)
  "/#{abbr} #{number.value}"
end
```

### Part D: Test and Verify (30 min)

**Run tests:**
```bash
bundle exec rspec spec/pubid_new/iso/identifiers/amendment_spec.rb \
                  spec/pubid_new/iso/identifiers/corrigendum_spec.rb \
                  --format progress
```

**Expected:** 997/997 (100%) - all format failures fixed!

---

## SESSION 99: IEC Rendering Styles (120 minutes)

### Objective

Implement same 6 reference formats for IEC identifiers with IEC-specific stage codes.

### Part A: IEC TypedStage Enhancement (40 min)

Update all IEC identifier TYPED_STAGES with short/long forms:

**Amendment:**
- Published: short="AMD1", long="Amd 1"
- CDV: short="CDV", long="CD" (or both same?)
- FDIS: short="FDIS", long="FDIS"

**Corrigendum:**
- Published: short="COR1", long="Cor 1"
- FDIS: short="FDIS", long="FDIS"

### Part B: IEC FormatResolver (30 min)

**File to create:** `lib/pubid_new/iec/format_resolver.rb`

Same structure as ISO, tailored for IEC patterns.

### Part C: IEC Rendering Update (50 min)

**Files to modify:**
- [`lib/pubid_new/iec/identifier.rb`](lib/pubid_new/iec/identifier.rb:1)
- [`lib/pubid_new/iec/single_identifier.rb`](lib/pubid_new/iec/single_identifier.rb:1)
- [`lib/pubid_new/iec/supplement_identifier.rb`](lib/pubid_new/iec/supplement_identifier.rb:1)

Apply same format parameter pattern as ISO.

---

## SESSIONS 100-101: Testing and Validation (240 minutes)

### Session 100: ISO Format Testing (120 min)

**Create:** `spec/pubid_new/iso/format_spec.rb`

**Test coverage:**
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

  describe ":ref_dated" do
    it "renders with no lang + short stage + date" do
      expect(amendment.to_s(format: :ref_dated))
        .to eq("ISO 8601:2019/DAM 1")
    end
  end

  # ... test all 6 formats for Amendment, Corrigendum, etc.
end
```

### Session 101: IEC Format Testing (120 min)

**Create:** `spec/pubid_new/iec/format_spec.rb`

Same pattern as ISO but with IEC-specific identifiers and stages.

---

## SESSION 102: Documentation Updates (120 minutes)

### Part A: Update Memory Bank (30 min)

**Files to update:**
- `.kilocode/rules/memory-bank/context.md` - Add Sessions 97-101 progress
- `.kilocode/rules/memory-bank/architecture.md` - Add rendering styles section

### Part B: Create Rendering Guide (40 min)

**File to create:** `docs/RENDERING_GUIDE.md`

**Content:**
```markdown
# PubID Advanced Rendering Styles Guide

## Overview

ISO and IEC identifiers support 6 reference formats for different use cases.

## Reference Formats

| Format | Language | Stage | Date | Example |
|--------|----------|-------|------|---------|
| :ref_num_short | 1-char (E) | Short (DAM) | Yes | `ISO 8601:2019(E)/DAM 1` |
| :ref_num_long | 2-char (en) | Long (DAmd) | Yes | `ISO 8601:2019(en)/DAmd 1` |
| :ref_dated | None | Short (DAM) | Yes | `ISO 8601:2019/DAM 1` |
| :ref_dated_long | None | Long (DAmd) | Yes | `ISO 8601:2019/DAmd 1` |
| :ref_undated | None | Short (DAM) | No | `ISO 8601/DAM 1` |
| :ref_undated_long | None | Long (DAmd) | No | `ISO 8601/DAmd 1` |

## Usage Examples

### ISO Identifiers

```ruby
# Parse identifier
id = PubidNew::Iso.parse("ISO 8601:2019/DAM 1")

# Render with different formats
id.to_s(format: :ref_num_short, lang: :en)
# => "ISO 8601:2019(E)/DAM 1"

id.to_s(format: :ref_num_long, lang: :en)
# => "ISO 8601:2019(en)/DAmd 1"

id.to_s(format: :ref_undated)
# => "ISO 8601/DAM 1"
```

### Language Codes

**Single-char (EFARDS):**
- E = English
- F = French (Français)
- R = Russian
- A = Arabic
- S = Spanish
- D = German (Deutsch)

**Two-char (ISO 639-1):**
- en = English
- fr = French
- ru = Russian
- ar = Arabic
- es = Spanish
- de = German

## Stage Abbreviations

### Amendment Stages

**Short forms (uppercase):**
- DAM, FDAM, AMD

**Long forms (mixed case):**
- DAmd, FDAmd, Amd

### Corrigendum Stages

**Short forms (uppercase):**
- DCOR, FDCOR, COR

**Long forms (mixed case):**
- DCor, FDCor, Cor

## IEC Identifiers

IEC follows the same pattern but with IEC-specific stage codes.

```ruby
# IEC example
id = PubidNew::Iec.parse("IEC 60050-351:2013/AMD1:2016")

id.to_s(format: :ref_num_short, lang: :en)
# => "IEC 60050-351:2013(E)/AMD1:2016"
```

## API Reference

### Identifier#to_s Parameters

- `format` - Format symbol (default: `:ref_dated_long`)
- `lang` - Language code (default: `:en`)
- `lang_single` - Force single-char language (default: `false`)
- `with_edition` - Include edition (default: `false`)
- `stage_format_long` - Override stage format (default: from `format`)
- `with_date` - Override date inclusion (default: from `format`)

### FormatResolver

Internal class that maps format symbols to rendering options.

**Do not use directly** - use the `format` parameter instead.
```

### Part C: Update README (30 min)

**File to update:** `README.adoc`

Add section on advanced rendering:
```asciidoc
=== Advanced Rendering Styles

ISO and IEC identifiers support multiple reference formats for different documentation needs:

[source,ruby]
----
id = PubidNew::Iso.parse("ISO 8601:2019/DAM 1")

# Instance reference with language
id.to_s(format: :ref_num_short, lang: :en)
# => "ISO 8601:2019(E)/DAM 1"

# Reference undated
id.to_s(format: :ref_undated)
# => "ISO 8601/DAM 1"
----

See link:docs/RENDERING_GUIDE.md[Rendering Guide] for complete details.
```

### Part D: Archive Temporary Docs (20 min)

```bash
mkdir -p docs/old-docs/sessions
mv .kilocode/rules/memory-bank/session-*-continuation-plan.md docs/old-docs/sessions/
mv docs/session-*-*.md docs/old-docs/sessions/ 2>/dev/null || true
```

---

## Success Criteria

### Session 98 (ISO Rendering)
- ✅ FormatResolver created
- ✅ Identifier to_s supports format parameter
- ✅ All 6 formats working
- ✅ 997/997 tests passing (100%)

### Session 99 (IEC Rendering)
- ✅ IEC FormatResolver created
- ✅ IEC TYPED_STAGES updated
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
lib/pubid_new/iso/
├── identifier.rb               # ADD format parameter
├── single_identifier.rb        # APPLY format options (if needed)
├── supplement_identifier.rb    # APPLY format options

lib/pubid_new/iec/
├── identifier.rb               # ADD format parameter
├── single_identifier.rb        # APPLY format options (if needed)
├── supplement_identifier.rb    # APPLY format options
└── identifiers/
    ├── amendment.rb            # UPDATE TYPED_STAGES
    └── corrigendum.rb          # UPDATE TYPED_STAGES

README.adoc                     # ADD advanced rendering section
```

---

## Testing Commands

```bash
# Test ISO rendering
bundle exec rspec spec/pubid_new/iso/identifiers/amendment_spec.rb \
                  spec/pubid_new/iso/identifiers/corrigendum_spec.rb

# Test IEC rendering
bundle exec rspec spec/pubid_new/iec/identifiers/amendment_spec.rb \
                  spec/pubid_new/iec/identifiers/corrigendum_spec.rb

# Test format specs
bundle exec rspec spec/pubid_new/iso/format_spec.rb
bundle exec rspec spec/pubid_new/iec/format_spec.rb
```

---

## Timeline Summary

| Session | Focus | Duration | Deliverables |
|---------|-------|----------|--------------|
| 98 | ISO Rendering | 120 min | FormatResolver + all fixes |
| 99 | IEC Rendering | 120 min | IEC format support |
| 100 | ISO Testing | 120 min | Comprehensive format specs |
| 101 | IEC Testing | 120 min | IEC format validation |
| 102 | Documentation | 120 min | Guides, README, cleanup |
| **Total** | **All work** | **600 min (10 hours)** | **Complete** |

---

## Session 98 Start Checklist

**Before starting:**
1. ✅ Read this continuation plan
2. ✅ Read Session 97 summary
3. ✅ Read V1 resolve_format implementation at [`archived-gems/pubid-iso/lib/pubid/iso/identifier/base.rb:230-257`](archived-gems/pubid-iso/lib/pubid/iso/identifier/base.rb:230)
4. ✅ Run baseline tests to confirm current state

**First task:**
Create FormatResolver class in `lib/pubid_new/iso/format_resolver.rb`

**Then:**
Update Identifier#to_s to use FormatResolver

---

**Good luck with Session 98 - ISO rendering implementation!** 🚀

**Remember:** Architecture correctness > Test pass rate. Session 97 foundation is solid!