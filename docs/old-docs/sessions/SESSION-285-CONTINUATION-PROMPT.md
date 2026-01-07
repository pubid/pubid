# Session 285 Quick Start

**Status:** Session 284 complete - V2 release preparation done
**Next:** Comprehensive multi-flavor enhancement (all in ONE session)

## Quick Context

**Session 284 Achievement:**
- ✅ Created RELEASE_NOTES.md for V2.0.0
- ✅ Archived Session 283 documentation
- ✅ Updated memory bank
- ✅ PROJECT MARKED PRODUCTION-READY

**Post-Release Enhancements Identified:**
- BSI ValueAddedPublication architecture fix
- CEN 4 new identifier classes
- SAE flavor (18th organization)
- BSI 3 new identifier classes
- 40+ new test cases

## Session 285 Objectives

**ALL PHASES IN ONE COMPRESSED SESSION (8-10 hours):**

### Phase 1: BSI ValueAddedPublication (120 min)
**Goal:** Replace boolean attributes with wrapper class

**Current (WRONG):**
```ruby
attribute :pdf, :boolean
attribute :tracked_changes, :boolean
```

**Target (CORRECT):**
```ruby
class ValueAddedPublication < Base
  attribute :base_identifier, Base, polymorphic: true
  attribute :format, :string, values: ["PDF", "TC", "BOOK"]
end
```

### Phase 2: CEN New Classes (90 min)
**Goal:** Add 4 new identifier types

1. **EuropeanSpecification (ES)** - `ES 59008-6-1:1999`
2. **CenReport (CR)** - `CR 13933:2000`
3. **CenelecHarmonizationDocument (HD)** - `HD 384.7.711 S1:2003`
4. **EuropeanPrestandard (ENV)** - `ENV ISO 11079:1999`

### Phase 3: SAE Flavor (120 min)
**Goal:** Implement 18th flavor

**Examples:**
- `SAE AMS 7904F:2024`
- `SAE AIR 8466:2024`
- `SAE AMS 2813G:2022`

### Phase 4: BSI New Classes (90 min)
**Goal:** Add 3 new identifier types

1. **Handbook** - `Handbook 17:1963`
2. **PracticeGuide (PP)** - `PP 888:1982`
3. **BritishIndustrialPractice (BIP)** - `BIP 2225:2022`

### Phase 5: Extended Tests (60 min)
**Goal:** Add 40+ new BSI test cases

### Phase 6: Documentation (30 min)
**Goal:** Update README.adoc, archive old docs

---

### Phase 7: BSI Full Fixture Classification (60 min)
**Goal:** Validate all 1,854 BSI identifiers

**Process:**
1. Initial classification with `run_classify.rb bsi`
2. Analyze failure patterns
3. Implement targeted fixes for common patterns
4. Re-classify and validate

**Targets:**
- Minimum: 85%+ (1,576+/1,854)
- Target: 90%+ (1,669+/1,854)
- Stretch: 95%+ (1,761+/1,854)

---

## Key Files to Read First

1. `docs/SESSION-285-CONTINUATION-PLAN.md` - Complete implementation plan
2. `.kilocode/rules/memory-bank/context.md` - Session 284 completion
3. `lib/pubid_new/iec/identifiers/vap_identifier.rb` - Wrapper pattern reference
4. `lib/pubid_new/bsi/identifiers/expert_commentary.rb` - BSI wrapper pattern
5. `spec/fixtures/bsi/identifiers/full.txt` - 1,854 BSI identifiers to validate

## Current State

**Production Ready:**
- 17/17 flavors implemented
- 99%+ success rate
- 88,200+ identifiers validated

**To Implement:**
- BSI ValueAddedPublication wrapper
- 4 CEN classes
- SAE flavor
- 3 BSI classes
- Extended test coverage
- **NEW: BSI full fixture validation (1,854 IDs)**

## Architecture Principles

**CRITICAL - NEVER COMPROMISE:**
1. **MODEL-DRIVEN** - Objects not strings
2. **Wrapper Pattern** - ValueAddedPublication like IEC VapIdentifier
3. **MECE** - Each identifier one type
4. **Architecture correctness > Test pass rate**
5. **Three-layer separation** maintained

## Implementation Order

**MUST follow this sequence:**

1. **Phase 1 FIRST** - ValueAddedPublication (most critical architectural fix)
2. Then Phase 2 - CEN classes
3. Then Phase 3 - SAE flavor
4. Then Phase 4 - BSI classes
5. Then Phase 5 - Tests
6. Finally Phase 6 - Documentation

**Test after each phase!**

## Files to Create (17 total)

### BSI (4 files)
- `lib/pubid_new/bsi/identifiers/value_added_publication.rb`
- `lib/pubid_new/bsi/identifiers/handbook.rb`
- `lib/pubid_new/bsi/identifiers/practice_guide.rb`
- `lib/pubid_new/bsi/identifiers/british_industrial_practice.rb`

### CEN (4 files)
- `lib/pubid_new/cen/identifiers/european_specification.rb`
- `lib/pubid_new/cen/identifiers/cen_report.rb`
- `lib/pubid_new/cen/identifiers/cenelec_harmonization_document.rb`
- `lib/pubid_new/cen/identifiers/european_prestandard.rb`

### SAE (9 files)
- `lib/pubid_new/sae.rb`
- `lib/pubid_new/sae/parser.rb`
- `lib/pubid_new/sae/builder.rb`
- `lib/pubid_new/sae/identifier.rb`
- `lib/pubid_new/sae/single_identifier.rb`
- `lib/pubid_new/sae/components/code.rb`
- `lib/pubid_new/sae/components/date.rb`
- `lib/pubid_new/sae/components/type.rb`
- `lib/pubid_new/sae/identifiers/base.rb`

## Quick Examples

### ValueAddedPublication Pattern
```ruby
# IEC (reference)
VapIdentifier(base: IEC_Standard, vap_suffix: CSV)

# BSI (should match)
ValueAddedPublication(base: BritishStandard, format: "PDF")
```

### SAE Pattern
```ruby
"SAE AMS 7904F:2024"
# Type: AMS (Aerospace Material Specification)
# Number: 7904F (with letter suffix)
# Year: 2024
```

### BIP Pattern
```ruby
"BIP 0009:2020 (PDF)"
# => ValueAddedPublication(
#      base: BritishIndustrialPractice(number: "0009", year: 2020),
#      format: "PDF"
#    )
```

## Common Pitfalls to Avoid

❌ **DON'T:**
- Use boolean attributes for VAP
- Skip testing after each phase
- Compromise architecture for tests
- Create classes without following V2 pattern

✅ **DO:**
- Follow wrapper pattern exactly
- Test incrementally
- Trust architecture correctness
- Use Lutaml::Model for all identifiers

## Success Metrics

**Minimum (80%):**
- ValueAddedPublication working
- New classes created
- SAE basic parsing

**Target (90%):**
- All phases complete
- Tests passing
- Documentation updated

**Stretch (100%):**
- Perfect round-trip fidelity
- Zero regressions
- Complete coverage

## Estimated Timeline

| Phase | Duration | Status |
|-------|----------|--------|
| 1 | 120 min | ⏳ |
| 2 | 90 min | ⏳ |
| 3 | 120 min | ⏳ |
| 4 | 90 min | ⏳ |
| 5 | 60 min | ⏳ |
| 6 | 30 min | ⏳ |
| 7 | 60 min | ⏳ |
| **Total** | **9-11 hrs** | **Compressed** |

---

**Ready to start Session 285!**

**First action:** Read `docs/SESSION-285-CONTINUATION-PLAN.md` for detailed implementation steps.