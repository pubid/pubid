# Session 62+ Continuation Plan: CEN Refactoring with Native & Adopted Identifiers

**Created:** 2025-11-29  
**Previous Session:** Session 59-61 (ISO docs + V1 removal complete)  
**Current Status:** 5/13 flavors complete (ISO, IEC, IDF, IEEE, NIST) at 95.68%  
**CEN Current:** 13/50 tests passing (26%)
**Strategy:** Compress 3 sessions into 1 for rapid completion  

---

## CRITICAL: Native vs Adopted Identifiers

**CEN and BSI have BOTH native standards AND adopted standards:**

### Native European Standards (EN, CEN, CLC)

```
EN 10077-1:2006              # Native EN standard
CEN TS 1234:2010             # Native CEN Technical Specification  
CLC TR 456:2015              # Native CLC Technical Report
CWA 17145-2:2017             # CEN Workshop Agreement
EN/CLC TS 50131-1:2006       # Copublished EN/CLC
```

**These are NOT adoptions** - They are original European standards.

### Adopted Standards (EN adopts ISO/IEC)

```
EN ISO 8601:2019             # EN adopts ISO 8601
EN IEC 62600:2020            # EN adopts IEC standard
EN ISO/IEC 27001:2013        # EN adopts ISO/IEC jointly
```

**These ARE adoptions** - Use MODEL-DRIVEN wrapper pattern.

### MODEL-DRIVEN Architecture for Adoptions

**✅ CORRECT - Only for explicit adoptions:**
```ruby
class AdoptedEuropeanNorm < EuropeanNorm
  attribute :adopted_identifier, Identifier  # ISO/IEC/IEEE object
  
  def to_s
    "EN #{adopted_identifier}"  # e.g., "EN ISO 8601:2019"
  end
end
```

**❌ WRONG - Native EN standards are NOT adoptions:**
```ruby
# DON'T use adopted_identifier for plain "EN 10077-1:2006"
# That's a native EN standard, use EuropeanNorm directly
```

---

## Current CEN Implementation Analysis

### Test Results (26% pass rate)
- **Passing:** 13/50 tests
- **Failing:** 37/50 tests
- **Key issues:**
  1. Missing Scheme class (european_norm_spec fails)
  2. Builder not using TYPED_STAGES register
  3. Parser gaps (EN/CLC, AC1 corrigendum patterns)
  4. Type rendering (slash vs space: "CEN/T

S" vs "CEN TS")

### Existing Identifier Types

**Already implemented:**
1. `base.rb` - Base CEN identifier (needs refactoring)
2. `european_norm.rb` - EN identifiers
3. `technical_specification.rb` - Has TYPED_STAGES ✅
4. `technical_report.rb` - Needs checking
5. `guide.rb` - Needs checking
6. `cen_workshop_agreement.rb` - Has TYPED_STAGES ✅
7. `harmonization_document.rb` - HD identifiers
8. `amendment.rb` - Wrapper for amendments
9. `corrigendum.rb` - Wrapper for corrigenda
10. `consolidated_identifier.rb` - Wrapper for consolidated

**Missing from implementation:**
11. `adopted_european_norm.rb` - For "EN ISO ..." patterns

### Missing from Specs

**No specs exist for:**
- `technical_report_spec.rb`
- `guide_spec.rb`
- `cen_workshop_agreement_spec.rb`
- `harmonization_document_spec.rb`
- `amendment_spec.rb`
- `corrigendum_spec.rb`
- `consolidated_identifier_spec.rb`
- `adopted_european_norm_spec.rb`

---

## Phase 1: CEN Architecture Refactoring (Session 62)

**Goal:** Apply ISO/IEC TYPED_STAGES patterns while preserving native/adopted distinction

**Timeline:** 2-3 hours

### Part 1: Create Scheme with TYPED_STAGES (30 min)

**File:** `lib/pubid_new/cen/scheme.rb`

```ruby
module PubidNew
  module Cen
    class Scheme
      # EN stages (native EN standards)
      TYPED_STAGES_REGISTRY = [
        TypedStage.new(abbr: ["EN"], stage_code: "published", type_code: "en"),
        TypedStage.new(abbr: ["prEN"], stage_code: "draft", type_code: "en"),
        TypedStage.new(abbr: ["FprEN"], stage_code: "final_draft", type_code: "en"),
        
        # TS stages
        TypedStage.new(abbr: ["TS"], stage_code: "published", type_code: "ts"),
        TypedStage.new(abbr: ["prTS"], stage_code: "draft", type_code: "ts"),
        
        # TR stages
        TypedStage.new(abbr: ["TR"], stage_code: "published", type_code: "tr"),
        
        # CWA
        TypedStage.new(abbr: ["CWA"], stage_code: "published", type_code: "cwa"),
        
        # Guide
        TypedStage.new(abbr: ["Guide"], stage_code: "published", type_code: "guide"),
      ].freeze

      IDENTIFIER_CLASS_MAP = {
        "en" => Identifiers::EuropeanNorm,
        "ts" => Identifiers::TechnicalSpecification,
        "tr" => Identifiers::TechnicalReport,
        "cwa" => Identifiers::CenWorkshopAgreement,
        "guide" => Identifiers::Guide,
        "hd" => Identifiers::HarmonizationDocument,
        "adopted_en" => Identifiers::AdoptedEuropeanNorm,
      }.freeze

      def locate_typed_stage_by_abbr(abbr)
        TYPED_STAGES_REGISTRY.find { |ts| ts.abbr.include?(abbr) } ||
          TypedStage.new(abbr: ["EN"], stage_code: "published", type_code: "en")
      end

      def locate_identifier_klass_by_type_code(type_code)
        IDENTIFIER_CLASS_MAP[type_code] || Identifiers::EuropeanNorm
      end
    end
  end
end
```

### Part 2: Refactor Builder (Clean Cast Pattern) (40 min)

**File:** `lib/pubid_new/cen/builder.rb`

Key changes:
1. `initialize(scheme)` - Receive Scheme
2. Single `cast()` method for all conversions
3. Check for adopted pattern FIRST
4. Use scheme lookups, not hardcoded logic

```ruby
class Builder
  def initialize(scheme)
    @scheme = scheme
  end

  def build(parsed_hash)
    # Check if this is an adopted identifier (has ISO/IEC in adopted_string)
    if parsed_hash[:adopted_string]
      return build_adopted_identifier(parsed_hash)
    end
    
    # Regular native EN/CEN/CLC identifier
    identifier = locate_identifier_klass(parsed_hash).new
    
    parsed_hash.each_pair do |key, value|
      realized = cast(key, value)
      next if realized.nil?
      
      case realized
      when Hash
        realized.each_pair { |k, v| identifier.send("#{k}=", v) if identifier.respond_to?("#{k}=") }
      else
        identifier.send("#{key}=", realized)
      end
    end
    
    identifier
  end

  def locate_identifier_klass(parsed_hash)
    # Use type or stage to determine class
    type_or_stage = parsed_hash[:type] || parsed_hash[:stage]
    typed_stage = @scheme.locate_typed_stage_by_abbr(type_or_stage || "")
    @scheme.locate_identifier_klass_by_type_code(typed_stage.type_code)
  end

  def cast(type, value)
    case type
    when :type_with_stage
      typed_stage = @scheme.locate_typed_stage_by_abbr(value || "")
      { stage: typed_stage.to_stage, type: typed_stage.to_type, typed_stage: typed_stage }
    when :publisher
      value.to_s
    when :number
      value.to_s
    when :parts
      Array(value).map { |p| p[:part].to_s }
    when :year
      value.to_i
    else
      value
    end
  end

  def build_adopted_identifier(parsed_hash)
    # Parse the adopted identifier string
    adopted_str = parsed_hash[:adopted_string].to_s
    
    adopted_id = if adopted_str.start_with?("ISO/IEC")
      require_relative '../iso'
      PubidNew::Iso.parse(adopted_str)
    elsif adopted_str.start_with?("ISO")
      require_relative '../iso'
      PubidNew::Iso.parse(adopted_str)
    elsif adopted_str.start_with?("IEC")
      require_relative '../iec'
      PubidNew::Iec.parse(adopted_str)
    end
    
    Identifiers::AdoptedEuropeanNorm.new(
      adopted_identifier: adopted_id,
      publisher: parsed_hash[:publisher] || ["EN"]
    )
  end
end
```

### Part 3: Create AdoptedEuropeanNorm Class (20 min)

**File:** `lib/pubid_new/cen/identifiers/adopted_european_norm.rb`

```ruby
module PubidNew
  module Cen
    module Identifiers
      class AdoptedEuropeanNorm < EuropeanNorm
        attribute :adopted_identifier, Base, polymorphic: true  # ISO/IEC object
        
        def to_s
          result = publisher.is_a?(Array) ? publisher.join("/") : publisher
          result += " #{adopted_identifier}"
          result
        end
        
        # Delegate to adopted identifier
        def number
          adopted_identifier.number
        end
        
        def year
          adopted_identifier.year if adopted_identifier.respond_to?(:year)
        end
        
        def parts
          adopted_identifier.parts if adopted_identifier.respond_to?(:parts)
        end
      end
    end
  end
end
```

### Part 4: Fix Parser Issues (30 min)

**Key parser fixes needed:**
1. EN/CLC copublisher pattern
2. AC1 corrigendum number pattern
3. Type rendering (space vs slash)

**File:** `lib/pubid_new/cen/parser.rb`

### Part 5: Create Missing Specs (40 min)

**Priority 1: Native Standards (3 specs)**
1. `technical_report_spec.rb` (~25 tests)
2. `guide_spec.rb` (~25 tests)
3. `cen_workshop_agreement_spec.rb` (~25 tests)

**Priority 2: Adopted Standards (1 spec)**
4. `adopted_european_norm_spec.rb` (~30 tests)

### Part 6: Run Tests & Document (20 min)

**Target:** 40%+ pass rate (up from 26%)

---

## Success Criteria for Session 62

- ✅ Scheme created with TYPED_STAGES
- ✅ Builder refactored (cast-only pattern)
- ✅ AdoptedEuropeanNorm class created (for "EN ISO" patterns)
- ✅ 4 new specs created (TR, Guide, CWA, AdoptedEN)
- ✅ Parser fixes for EN/CLC and AC1
- ✅ 40%+ pass rate (up from 26%)
- ✅ Native vs adopted distinction clear

---

## Files to Create/Modify

**Session 62 (CEN):**
- `lib/pubid_new/cen/scheme.rb` (NEW)
- `lib/pubid_new/cen/builder.rb` (REFACTOR)
- `lib/pubid_new/cen/identifiers/adopted_european_norm.rb` (NEW)
- `lib/pubid_new/cen/parser.rb` (FIX)
- `spec/pubid_new/cen/identifiers/technical_report_spec.rb` (NEW)
- `spec/pubid_new/cen/identifiers/guide_spec.rb` (NEW)
- `spec/pubid_new/cen/identifiers/cen_workshop_agreement_spec.rb` (NEW)
- `spec/pubid_new/cen/identifiers/adopted_european_norm_spec.rb` (NEW)

---

## Key Reminders

**Native vs Adopted:**
- "EN 10077-1:2006" = Native EN standard (use EuropeanNorm)
- "EN ISO 8601:2019" = Adopted ISO standard (use AdoptedEuropeanNorm)
- "CEN TS 1234:2010" = Native CEN TS (use TechnicalSpecification)

**Architecture:**
- TYPED_STAGES register for type/stage decisions
- Builder cast-only pattern (no business logic)
- Adopted identifiers use wrapper pattern
- Native identifiers use direct classes

**Testing:**
- Create specs for each identifier type
- Test native patterns separately from adopted
- Target 80%+ for production-ready status

Good luck with Session 62! 🚀