# IEC Migration Analysis

**Date:** 2025-11-17
**Status:** Analysis Complete - Ready for Implementation

## Executive Summary

IEC v1 implementation is nearly identical to ISO, making it the ideal starting point for Lutaml::Model migration. The primary task is converting hash-based TYPED_STAGES to object-based TypedStage components, following the ISO v2 pattern.

## IEC v1 Structure Analysis

### Document Types Identified

From [`gems/pubid-iec/lib/pubid/iec/identifier/`](gems/pubid-iec/lib/pubid/iec/identifier/):

1. **InternationalStandard** - Main type (like ISO IS)
2. **TechnicalReport** - TR documents
3. **TechnicalSpecification** - TS documents
4. **Guide** - IEC Guide documents
5. **PubliclyAvailableSpecification** - PAS documents
6. **TestReportForm** - TRF (IEC-specific)
7. **InterpretationSheet** - ISH (IEC-specific)
8. **ComponentSpecification** - CS (IEC-specific)
9. **OperationalDocument** - OD (IEC-specific)
10. **ConformityAssessment** - CA (IEC-specific)
11. **SystemsReferenceDocument** - SRD (IEC-specific)
12. **TechnologyReport** - Technology reports
13. **SocietalTechnologyTrendReport** - STTR (IEC-specific)
14. **WhitePaper** - White papers
15. **WorkingDocument** - Committee working documents

### TYPED_STAGES Conversion Pattern

**IEC v1 Format (Hash-based):**
```ruby
TYPED_STAGES = {
  dtr: {
    abbr: "DTR",
    name: "Draft Technical Report",
    harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99]
  }
}.freeze
```

**ISO v2 Format (Object-based):**
```ruby
TYPED_STAGES = [
  Components::TypedStage.new(
    code: :dtr,
    stage_code: :draft,
    type_code: :tr,
    abbr: ["DTR"],
    name: "Draft Technical Report",
    harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99]
  )
].freeze
```

**Conversion Rules:**
1. Hash key becomes `code:` parameter
2. `abbr` string becomes array: `["DTR"]`
3. Add `type_code:` from class's `type[:key]`
4. Add `stage_code:` (derive from harmonized_stages or name)
5. Keep `name` and `harmonized_stages` as-is

### Components Needed

**Reuse from ISO/Shared:**
- Date
- Edition
- Part
- Amendment
- Corrigendum
- Supplement

**IEC-Specific to Create:**
1. **Publisher** - IEC, ISO/IEC, CISPR, IECEE, IECEx, IECQ
2. **Code** - IEC number format (60034-1, TR 61000, etc.)
3. **VAPSuffix** - CMV, RLV, SER codes
4. **ConsolidatedAmendment** - Handle +AMD1+AMD2 format
5. **Sheet** - For sheet notation (/)
6. **DecisionSheet** - For decision sheet notation
7. **TRFInfo** - TRF-specific metadata

### Base Class Attributes

From [`gems/pubid-iec/lib/pubid/iec/identifier/base.rb`](gems/pubid-iec/lib/pubid/iec/identifier/base.rb:1):

**IEC-Specific Attributes:**
- `vap` - VAP suffix code
- `database` - Boolean flag
- `fragment` - Fragment identifier
- `version` - Version string
- `decision_sheet` - Decision sheet notation
- `conjuction_part` - Part conjunction
- `part_version` - Part-specific version
- `trf_publisher` - TRF copublisher
- `trf_series` - TRF series
- `trf_version` - TRF version
- `test_type` - Test type classification
- `month`, `day` - Date components
- `sheet` - Sheet notation

**Inherited from ISO:**
- publisher
- number
- part
- subpart
- year
- edition
- amendment
- corrigendum
- copublisher
- language
- stage
- type

## Mapping to ISO v2 Architecture

### Component Classes to Create

**Location:** `lib/pubid_new/iec/components/`

1. **publisher.rb**
   ```ruby
   class Publisher < Lutaml::Model::Serializable
     PUBLISHERS = %w[IEC ISO/IEC CISPR IECEE IECEx IECQ].freeze
     attribute :body, :string
   end
   ```

2. **code.rb**
   ```ruby
   class Code < Lutaml::Model::Serializable
     attribute :prefix, :string  # IEC, TR, TS, etc.
     attribute :number, :string
     attribute :part, :string, default: -> { nil }
   end
   ```

3. **vap_suffix.rb**
   ```ruby
   class VapSuffix < Lutaml::Model::Serializable
     CODES = %w[CMV RLV SER].freeze
     attribute :code, :string
   end
   ```

4. **consolidated_amendment.rb**
   ```ruby
   class ConsolidatedAmendment < Lutaml::Model::Serializable
     attribute :amendments, :string, collection: true
     # For +AMD1+AMD2+AMD3 format
   end
   ```

5. **sheet.rb**
   ```ruby
   class Sheet < Lutaml::Model::Serializable
     attribute :number, :string
   end
   ```

6. **trf_info.rb**
   ```ruby
   class TrfInfo < Lutaml::Model::Serializable
     attribute :publisher, :string
     attribute :series, :string
     attribute :version, :string
   end
   ```

### Identifier Classes Structure

**Location:** `lib/pubid_new/iec/identifiers/`

**Base:** `base.rb` (inherits from [`SingleIdentifier`](lib/pubid_new/iso/single_identifier.rb:7))

**Main Types:**
1. `international_standard.rb` - Convert from v1 InternationalStandard
2. `technical_report.rb` - Convert from v1 TechnicalReport
3. `technical_specification.rb` - Convert from v1 TechnicalSpecification
4. `guide.rb` - Convert from v1 Guide
5. `pas.rb` - Publicly Available Specification
6. `test_report_form.rb` - TRF documents
7. `interpretation_sheet.rb` - ISH documents
8. `component_specification.rb` - CS documents
9. `operational_document.rb` - OD documents
10. `conformity_assessment.rb` - CA documents

**Each class needs:**
- TYPED_STAGES converted from hash to TypedStage objects
- PROJECT_STAGES converted (if applicable)
- type method: `def self.type; { key: :xx, title: "...", short: "XX" }; end`

## Conversion Example

**TechnicalReport v1 → v2:**

**v1 (Hash):**
```ruby
TYPED_STAGES = {
  dtr: {
    abbr: "DTR",
    name: "Draft Technical Report",
    harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99]
  }
}.freeze
```

**v2 (Object):**
```ruby
TYPED_STAGES = [
  Components::TypedStage.new(
    code: :dtr,
    stage_code: :draft,
    type_code: :tr,
    abbr: ["DTR"],
    name: "Draft Technical Report",
    harmonized_stages: %w[50.00 50.20 50.60 50.92 50.98 50.99]
  )
].freeze
```

## IEC-Specific Features

### 1. Consolidated Amendments (+AMD Format)
- Input: `IEC 60034-1:2017+AMD1:2020+AMD2:2022`
- Parser: Must capture chained amendments
- Component: ConsolidatedAmendment with collection of amendments
- Rendering: Reconstruct +AMD chain

### 2. VAP Suffix Codes
- Codes: CMV (Common Modifications and Variations), RLV (Relevant), SER (Serial)
- Position: After main identifier
- Example: `IEC 60034-1:2017 CMV`

### 3. CSV Publications
- Suffix: " CSV" at end
- Example: `IEC 60034-1:2017 CSV`
- Currently 0% pass rate (1,176 cases)

### 4. Test Report Forms (TRF)
- Format: `IEC{number} TRF Ed.{edition}` or with copublisher info
- Special TRF-specific attributes (publisher, series, version)
- Requires dedicated TRF identifier class

### 5. Interpretation Sheets (ISH)
- Format: `IEC{number}ISH{number}:{year}`
- Supplement to base standard
- May need supplement handling

## Differences from ISO

| Aspect | ISO | IEC |
|--------|-----|-----|
| Main type abbr | None (blank) | None (blank) |
| TR/TS format | Same | Same |
| Amendments | AMD | AMD (+ consolidated) |
| VAP suffixes | No | Yes (CMV, RLV, SER) |
| CSV format | No | Yes |
| TRF documents | No | Yes |
| ISH documents | No | Yes |
| Copublishers | Few | Many (CISPR, IECEE, IECEx, IECQ) |

## Implementation Priority

### Phase 1.1 (Foundation - 5-7 days)
1. Create components (2 days)
2. Create base identifier (1 day)
3. Create main types: IS, TR, TS, Guide (2 days)
4. Update builder/scheme (1 day)
5. Test (1 day)

**Goal:** Get basic ISO-like types working (~35% pass rate)

### Phase 1.2 (IEC-Specific - 5-7 days)
1. Add PAS, TRF, ISH types (2 days)
2. Implement consolidated amendments (2 days)
3. Implement VAP suffixes (1 day)
4. Implement CSV publications (1 day)
5. Test (1 day)

**Goal:** Get to 60-70% pass rate

### Phase 1.3 (Working Documents - 3-5 days)
1. Working document parser
2. Committee document types
3. Special group formats

**Goal:** Get to 75-85% pass rate

## Next Steps

✅ **Step 1 Complete**: ISO v2 architecture studied
✅ **Step 2 Complete**: IEC v1 structure analyzed

**Ready for Step 3**: Create IEC component classes

**First Component to Create:** `lib/pubid_new/iec/components/publisher.rb`

## Success Criteria

After full IEC migration:
- ✅ All IEC identifier classes follow ISO v2 pattern
- ✅ TYPED_STAGES converted from hash to object format
- ✅ Scheme uses lookup methods (no TYPE_MAP)
- ✅ Integration tests improve from 22.82% baseline
- ✅ Basic types (IS, TR, TS, Guide) working perfectly
- ✅ IEC-specific features documented even if not fully implemented

---

**Analysis Complete - Ready for Implementation Phase**