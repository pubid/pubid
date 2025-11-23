# PubID V2 - ISO Parser Implementation Continuation Plan

**Last Updated:** 2025-01-22 16:33 HKT  
**Current Status:** Parser/Builder expanded, integration debugging in progress  
**Test Status:** 1/20 ISO identifier tests passing (5%)

---

## Executive Summary

The ISO parser has been significantly expanded with grammar for supplements, special types, and complex patterns. The builder has routing logic for all identifier classes. However, integration issues between parser output structure and builder expectations prevent most tests from passing.

**Critical Path:** Fix parser-to-builder data flow → Fix component initialization → Complete all identifier patterns → Achieve 90%+ test pass rate

---

## Current Architecture

### File Structure
```
lib/pubid_new/iso/
├── identifier.rb              # Module with .parse() entry point
├── parser.rb                  # Parslet grammar (EXPANDED)
├── builder.rb                 # Builds identifier objects (ENHANCED)
├── single_identifier.rb       # Base for single identifiers (FIXED)
├── supplement_identifier.rb   # Base for supplements (NEEDS WORK)
├── combined_identifier.rb     # Base for combined
├── components/
│   ├── publisher.rb          # ISO/IEC/IEEE handling
│   └── code.rb               # Number/part handling
└── identifiers/              # 18 specific identifier classes
    ├── base.rb               # Common base (FIXED to_s signature)
    ├── international_standard.rb
    ├── guide.rb
    ├── technical_report.rb
    ├── technical_specification.rb
    ├── amendment.rb          # Supplement type
    ├── corrigendum.rb        # Supplement type
    ├── supplement.rb         # Supplement type
    ├── extract.rb            # Supplement type
    ├── data.rb               # Special type
    ├── pas.rb                # Special type
    ├── technology_trends_assessments.rb  # Special type (TTA)
    ├── international_workshop_agreement.rb  # Special type (IWA)
    ├── international_standardized_profile.rb  # Special type (ISP)
    ├── directives.rb         # Special type (DIR)
    ├── directives_supplement.rb  # Special pattern
    ├── recommendation.rb     # Legacy type (R)
    └── addendum.rb           # Supplement type
```

### Class Hierarchy
```
::PubidNew::Identifier (parent)
├── attributes: number, part, subpart, stage_iteration, date, edition
├── attributes: languages, publisher, copublishers, type, stage, locality
│
├── SingleIdentifier (ISO-specific, adds typed_stage)
│   ├── InternationalStandard
│   ├── Guide
│   ├── TechnicalReport
│   ├── TechnicalSpecification
│   ├── Data
│   ├── Pas
│   ├── TechnologyTrendsAssessments (TTA)
│   ├── InternationalWorkshopAgreement (IWA)
│   ├── InternationalStandardizedProfile (ISP)
│   ├── Directives (DIR)
│   ├── DirectivesSupplement
│   └── Recommendation (R)
│
└── SupplementIdentifier (extends SingleIdentifier, adds base_identifier)
    ├── Amendment (Amd)
    ├── Corrigendum (Cor)
    ├── Supplement (Suppl)
    ├── Extract (Ext)
    └── Addendum
```

### Data Flow
```
User Input String
    ↓
Parser.parse() → Parse Tree (Hash with nested structures)
    ↓
Builder.build() → Determines class, extracts attributes
    ↓
Identifier Object → to_s() renders back to string
```

---

## Critical Issues Blocking Progress

### Issue #1: Copublisher Array Parsing (Priority: P0)
**Affects:** 10+ tests  
**Symptom:** `TypeError: no implicit conversion of Symbol into Integer`  
**Location:** `builder.rb:191` in `build_publisher`

**Problem:**
Parser returns copublisher in unknown nested structure. Builder tries to access with `data[:copublisher]` but gets type error.

**Debug Steps:**
```ruby
# In builder.rb build_publisher method, add:
puts "=== DEBUG COPUBLISHER ==="
puts "Raw data keys: #{data.keys.inspect}"
puts "Copublisher present?: #{data.key?(:copublisher)}"
puts "Copublisher value: #{data[:copublisher].inspect}"
puts "Copublisher class: #{data[:copublisher].class}" if data[:copublisher]
puts "=== END DEBUG ==="
```

**Test Case:**
```bash
bundle exec rspec spec/pubid_new/iso/identifier_spec.rb:23 -fd
# Test: ISO/IEC 27001:2013
```

**Expected Fix:**
Parser likely returns copublisher as single hash `{copublisher: "IEC"}` instead of in array. Need to handle both single and multiple copublishers correctly.

---

### Issue #2: Supplement typed_stage Initialization (Priority: P0)
**Affects:** 6 tests (all supplements)  
**Symptom:** `NoMethodError: undefined method 'abbreviation' for nil:NilClass`  
**Location:** `supplement_identifier.rb:14` in `to_s`

**Problem:**
Supplements are created without `typed_stage` attribute, but `to_s` assumes it exists.

**Root Cause:**
1. Builder calls `find_typed_stage(supplement_class, stage_str)` but may return nil
2. Published supplements (like "Amd 1") don't have stage, should use default
3. Staged supplements (like "FDAM 1") need proper typed_stage lookup

**Fix Strategy:**
```ruby
# In SupplementIdentifier
def to_s(lang: :en, lang_single: false, with_edition: false)
  [].tap do |parts|
    parts << base_identifier.to_s(lang: lang, lang_single: lang_single, with_edition: with_edition)
    
    # Handle typed_stage - use default if nil
    stage_abbr = if typed_stage && typed_stage.abbreviation
      typed_stage.abbreviation
    else
      # Default for published supplement
      self.class.type[:short]  # "Amd", "Cor", etc.
    end
    
    parts << "/#{stage_abbr}"
    parts << (stage_abbr.end_with?('.') ? '' : ' ')
    parts << number_portion(lang_single: lang_single)
    # ... rest
  end.compact.join('')
end
```

---

### Issue #3: Parser Supplement Pattern Incomplete (Priority: P1)
**Affects:** 2 tests (FDAM patterns)  
**Symptom:** `Failed to match sequence ... at line 1 char 25`  
**Test Case:** `ISO/IEC/IEEE 8802-3:2021/FDAM 1`

**Problem:**
Parser supplement rule requires number after supplement type, but FDAM pattern has:
- Typed stage: FDAM
- No explicit supplement type (Amd is implied)
- Number: 1
- No year

**Current Rule:**
```ruby
rule(:supplement) do
  slash >> 
  (typed_stage >> space.maybe).maybe.as(:typed_stage) >>
  supplement_type >>
  (space >> digits).maybe.as(:supplement_number) >>
  year.maybe
end
```

**Issue:** When typed_stage is present (FDAM), supplement_type becomes optional but parser still requires it.

**Fix:**
```ruby
rule(:supplement) do
  slash >> (
    # Pattern 1: Typed stage (implies type and includes stage)
    (typed_stage.as(:typed_stage) >> space >> digits.as(:supplement_number) >> year.maybe) |
    # Pattern 2: Explicit type with optional stage
    (supplement_type >> space >> digits.as(:supplement_number) >> year.maybe)
  )
end
```

---

### Issue #4: IWA Pattern Not Matching (Priority: P1)
**Affects:** 1 test  
**Test Case:** `IWA 14-1:2013`

**Problem:**
Parser `identifier` rule starts with `publisher`, but IWA identifiers start with type "IWA" directly (no "ISO/" prefix).

**Current Implementation:**
```ruby
rule(:iwa_identifier) do
  str("IWA").as(:type) >> space >>
  number >> parts >>
  year.maybe >>
  language.maybe
end

rule(:identifier) do
  (dir_sup_identifier | iwa_identifier | base_identifier).as(:base) >>
  supplement.repeat(0, 3).as(:supplements)
end
```

**Test:** Rule exists but may have ordering issue or builder not handling IWA publisher correctly.

**Debug:** Check if parser matches IWA, and if builder sets publisher correctly for IWA type.

---

## Implementation Roadmap

### Phase 1: Critical Fixes (2-3 hours)
**Goal:** Get basic patterns (IS, Guide, TR, TS) passing

1. **Fix copublisher parsing** (1 hour)
   - Add comprehensive debug logging
   - Test with `ISO/IEC 27001:2013`
   - Fix `build_publisher` to handle actual structure
   - Test with single, double, triple copublishers

2. **Fix supplement typed_stage** (1 hour)
   - Implement default typed_stage in SupplementIdentifier.to_s
   - Fix find_typed_stage to handle nil gracefully
   - Test with `ISO 19110:2005/Amd 1:2011`

3. **Fix supplement parser pattern** (30 min)
   - Split supplement rule into typed vs untyped
   - Test with `ISO/IEC/IEEE 8802-3:2021/FDAM 1`

4. **Fix IWA pattern** (30 min)
   - Debug parser matching
   - Fix builder to set publisher="ISO" for IWA
   - Test with `IWA 14-1:2013`

**Tests to Pass:** 8-10 / 20

---

### Phase 2: Special Types (1-2 hours)
**Goal:** Get DATA, DIR, ISP, TTA, R, PAS patterns working

5. **Fix DATA/TTA/R patterns** (1 hour)
   - These use SingleIdentifier
   - Problem: `code` attribute reference (should be `number`)
   - Fix: Ensure builder passes number/part correctly
   - Tests: DATA, TTA, R (3 tests)

6. **Fix DIR pattern** (30 min)
   - Normal DIR: `ISO/IEC DIR 1:2022`
   - DIR SUP: `ISO/IEC DIR 1 ISO SUP:2022`
   - Parser has `dir_sup_identifier` rule but needs testing
   - Builder needs DIR SUP routing

7. **Fix ISP and PAS patterns** (30 min)
   - Both follow standard pattern with type prefix
   - Should work once copublisher fixed
   - Tests: ISP, PAS (2 tests)

**Tests to Pass:** 15-17 / 20

---

### Phase 3: Multi-Level Supplements (1 hour)
**Goal:** Handle supplement chains like Amd/Cor

8. **Implement multi-level supplement handling** (1 hour)
   - Current: Only handles first supplement
   - Need: Recursive supplement building
   - Pattern: `ISO/IEC 13818-1:2015/Amd 3:2016/Cor 1:2017`
   - Fix: Builder processes supplements array recursively
   - Test: Multi-level Cor (1 test)

**Tests to Pass:** 17-18 / 20

---

### Phase 4: Edge Cases & Polish (1 hour)

9. **Language codes** (30 min)
   - Pattern: `ISO/IEC Guide 51:1999(E/F/R)`
   - SingleIdentifier handles this
   - Test lang_single parameter works

10. **Review all identifier classes** (30 min)
    - Ensure each has proper to_s implementation
    - Verify typed_stage handling
    - Check component references

**Tests to Pass:** 19-20 / 20

---

## Testing Strategy

### Unit Tests (Per Class)
Each identifier class needs spec file:
```ruby
# spec/pubid_new/iso/identifiers/technical_report_spec.rb
RSpec.describe PubidNew::Iso::Identifiers::TechnicalReport do
  describe ".parse" do
    it "parses basic TR" do
      id = described_class.parse("ISO/IEC TR 29186:2012")
      expect(id.type).to eq("TR")
      expect(id.number.value).to eq("29186")
      expect(id.date.year).to eq(2012)
    end
    
    it "round-trips correctly" do
      input = "ISO/IEC TR 29186:2012"
      expect(described_class.parse(input).to_s).to eq(input)
    end
  end
end
```

### Integration Tests
`spec/pubid_new/iso/identifier_spec.rb` - Tests full parse → build → render cycle

### Parser Tests
`spec/pubid_new/iso/parser_spec.rb` - Tests grammar rules with fixtures

---

## Quality Standards

### Architecture Principles
- **MECE:** Each identifier class handles mutually exclusive patterns
- **OOP:** Model-driven, not serialization-driven
- **Separation of Concerns:**
  - Parser: Grammar only
  - Builder: Object construction only
  - Identifier: Representation and rendering only
- **Open/Closed:** New identifier types added by subclassing, no modification of base
- **Single Responsibility:** Each class represents one identifier type

### Code Standards
- No hardcoded special cases (use polymorphism)
- Component namespace: Always `::PubidNew::Components::`
- Attributes: Use parent class attributes (number, date, languages)
- Tests: Must test actual behavior, no lowering thresholds

### Test Coverage Requirements
- Unit tests for each identifier class
- Parser tests for each grammar rule
- Integration tests for round-trip (parse → render → parse)
- Edge case tests (multi-level, multi-copublisher, etc.)

---

## Documentation Updates Needed

### 1. Update README.adoc
**Section:** Architecture → ISO Module

Add:
```adoc
=== ISO Identifier Architecture

==== Identifier Types

PubID V2 supports all ISO identifier patterns:

* International Standards (IS)
* Guides
* Technical Reports (TR)
* Technical Specifications (TS)
* Amendments (Amd)
* Corrigenda (Cor)
* Supplements (Suppl)
* Extracts (Ext)
* Data identifiers (DATA)
* Publicly Available Specifications (PAS)
* Technology Trend Assessments (TTA)
* International Workshop Agreements (IWA)
* International Standardized Profiles (ISP)
* Directives (DIR)
* Recommendations (R, legacy)

==== Parser Architecture

The ISO parser uses a three-layer architecture:

[source]
----
Parser (Parslet Grammar)
    ↓
Builder (Object Construction)
    ↓
Identifier Classes (Representation)
----

Each identifier type is represented by a dedicated class that inherits from either `SingleIdentifier` (for base identifiers) or `SupplementIdentifier` (for supplements to base identifiers).

==== Example Usage

[source,ruby]
----
# Parse a basic international standard
id = PubidNew::Iso.parse("ISO 19115:2003")
id.class  # => PubidNew::Iso::Identifiers::InternationalStandard
id.number.value  # => "19115"
id.date.year  # => 2003

# Parse with copublishers
id = PubidNew::Iso.parse("ISO/IEC/IEEE 8802-3:2021")
id.publisher.to_s  # => "ISO/IEC/IEEE"

# Parse amendment
id = PubidNew::Iso.parse("ISO 19110:2005/Amd 1:2011")
id.class  # => PubidNew::Iso::Identifiers::Amendment
id.base_identifier.number.value  # => "19110"

# Render back to string
id.to_s  # => "ISO 19110:2005/Amd 1:2011"
----
```

### 2. Create docs/architecture/iso-parser.adoc
New file documenting ISO parser architecture in detail

### 3. Move to old-docs/
- Any temporary debugging docs
- Session notes (move CONTINUATION_PROMPT_NEXT_SESSION.md after completion)
- Outdated implementation notes

---

## Success Criteria

### Minimum Viable (MVP)
- [ ] 17/20 identifier tests passing (85%)
- [ ] All basic patterns work (IS, Guide, TR, TS, PAS)
- [ ] Supplements work (Amd, Cor, Suppl, Ext)
- [ ] Special types work (DATA, IWA, ISP, DIR, TTA, R)
- [ ] Copublisher patterns work (single, double, triple)

### Production Ready
- [ ] 19/20 identifier tests passing (95%)
- [ ] Multi-level supplements work
- [ ] All edge cases handled
- [ ] Documentation complete
- [ ] Unit tests for each identifier class

### Excellence
- [ ] 20/20 identifier tests passing (100%)
- [ ] Parser tests pass (file-based tests)
- [ ] Full test suite integration
- [ ] Performance optimized
- [ ] Code review complete

---

## Next Session Priorities

1. **MUST DO FIRST:** Debug copublisher parsing (blocks 10+ tests)
2. **MUST DO SECOND:** Fix supplement typed_stage (blocks 6 tests)
3. **SHOULD DO:** Fix supplement parser pattern (blocks 2 tests)
4. **NICE TO HAVE:** Complete special types

**Time Estimate:** 4-6 hours for MVP, 8-10 hours for production ready

---

## Session Handoff Checklist

- [x] Parser grammar expanded
- [x] Builder routing logic added
- [x] Component namespaces fixed
- [x] Parent class attributes aligned
- [ ] Integration debugging complete
- [ ] Tests passing
- [ ] Documentation updated
- [ ] Code committed
