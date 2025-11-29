# V1→V2 Spec Migration Plan

**CRITICAL:** Every identifier class MUST have its own spec file before V1 removal!

---

## Current Spec Coverage Gap

| Flavor | V1 Specs | V2 Specs | Missing | Status |
|--------|----------|----------|---------|--------|
| **NIST** | 20 | 5 | **-15** | ⚠️ CRITICAL GAP |
| ISO | 14 | 26 | +12 | ✅ OVER-COVERED |
| **IEC** | 6 | 3 | **-3** | ⚠️ GAP |
| **JIS** | 4 | 1 | **-3** | ⚠️ GAP |
| **IEEE** | 5 | 4 | **-1** | ⚠️ MINOR GAP |
| CEN | 3 | 3 | 0 | ✅ EQUAL |
| BSI | 2 | 0 | **-2** | ⚠️ NOT STARTED |
| CCSDS | 2 | 0 | **-2** | ⚠️ NOT STARTED |
| ETSI | 2 | 0 | **-2** | ⚠️ NOT STARTED |
| ITU | 2 | 0 | **-2** | ⚠️ NOT STARTED |
| PLATEAU | 2 | 0 | **-2** | ⚠️ NOT STARTED |

**Total Gap:** -34 spec files need creation/migration

---

## The Problem

**Current "100% passing" is MISLEADING**:
- NIST shows 57/57 tests (100%) but only has 5 spec files out of 20!
- IEEE shows 35/35 tests (100%) but missing identifier-specific specs
- We're testing SOME identifiers but not ALL classes

**Requirement:** 
- Each identifier CLASS in `lib/pubid_new/{flavor}/identifiers/*.rb` MUST have a corresponding spec in `spec/pubid_new/{flavor}/identifiers/*_spec.rb`

---

## Phase 0: SPEC AUDIT & MIGRATION (BEFORE Phase 1!)

### Session 50: Comprehensive Spec Audit (NEW PRIORITY)

**Task 1: Count All Identifier Classes (20 min)**

For each flavor, list all identifier classes:

```bash
for flavor in iso iec ieee nist itu jis ccsds bsi cen etsi plateau; do
  echo "=== $flavor ==="
  if [ -d "lib/pubid_new/$flavor/identifiers" ]; then
    echo "Identifier classes:"
    ls lib/pubid_new/$flavor/identifiers/*.rb 2>/dev/null | wc -l
    echo "V2 spec files:"
    ls spec/pubid_new/$flavor/identifiers/*_spec.rb 2>/dev/null | wc -l
  fi
done
```

**Task 2: Create Spec Migration Matrix (20 min)**

For each flavor, create a mapping:

```
Flavor: NIST
├── lib/pubid_new/nist/identifiers/
│   ├── base.rb → ✅ spec exists
│   ├── special_publication.rb → ❌ MISSING SPEC
│   ├── federal_information_processing_standards.rb → ❌ MISSING SPEC
│   └── ... (list ALL classes)
└── Missing specs: 15 files
```

**Task 3: Prioritize Migration (20 min)**

Order by impact:
1. **CRITICAL:** NIST (15 missing) - Claims 100% but undertested
2. **HIGH:** IEC (3 missing), JIS (3 missing)
3. **MEDIUM:** IEEE (1 missing)
4. **DEFER:** BSI, CCSDS, ETSI, ITU, PLATEAU (no V2 yet)

**Deliverable:** `docs/SPEC_MIGRATION_MATRIX.md`

---

### Sessions 51-55: NIST Spec Migration (CRITICAL)

**Goal:** Create 15 missing NIST spec files

**Each Session: ~3 specs**

**Process per spec file:**

1. **Analyze V1 spec** (5 min)
   - Read gems/pubid-nist/spec/pubid_nist/*_spec.rb
   - Extract test cases
   - Understand identifier patterns

2. **Create V2 spec** (20 min)
   - Create spec/pubid_new/nist/identifiers/{class}_spec.rb
   - Migrate test cases to V2 API
   - Add parsing tests (parse → object → to_s round-trip)
   - Add rendering tests
   - Add URN tests if applicable

3. **Verify** (5 min)
   - Run new spec: `bundle exec rspec spec/pubid_new/nist/identifiers/{class}_spec.rb`
   - Fix any failures
   - Ensure 90%+ pass rate per spec

**Session Breakdown:**

- **Session 51:** NIST Special Publication, FIPS, IR (3 specs)
- **Session 52:** NIST GCR, HB, SP series variants (3 specs)
- **Session 53:** NIST TN, OWMWP, AMS (3 specs)
- **Session 54:** NIST NCSTAR, WPS, BSS (3 specs)
- **Session 55:** NIST remaining types (3 specs)

**Success Criteria:**
- ✅ 20/20 NIST spec files exist
- ✅ Each tests its specific identifier class
- ✅ Overall NIST pass rate maintains 90%+

---

### Sessions 56-58: IEC, JIS, IEEE Spec Migration

**Session 56: IEC (3 missing specs)**
- Migrate V1 IEC specs to V2 structure
- Create per-identifier-class specs
- Target: 3 new spec files

**Session 57: JIS (3 missing specs)**
- Migrate V1 JIS specs to V2 structure
- Create per-identifier-class specs
- Target: 3 new spec files

**Session 58: IEEE (1 missing spec)**
- Identify missing IEEE identifier spec
- Create comprehensive spec file
- Target: 1 new spec file

**Success Criteria:**
- ✅ All "100%" flavors have complete spec coverage
- ✅ No misleading pass rates
- ✅ Every class tested individually

---

### Session 59: ISO Documentation (MOVED FROM Session 50)

**Now that specs are complete, document:**
- README URN section
- V2 features summary
- Known limitations

**This was originally Session 50, now Session 59 after spec migration**

---

## Updated V1 Removal Timeline

### Phase 0: Spec Migration (Sessions 50-58) - NEW!
**Goal:** Complete all spec files for production-ready flavors

- Session 50: Spec audit
- Sessions 51-55: NIST specs (15 files)
- Sessions 56-58: IEC, JIS, IEEE specs (7 files)
- **Total:** 22 new spec files created

### Phase 1: Documentation + V1 Removal (Sessions 59-61)
**Goal:** Document and remove V1 for complete flavors

- Session 59: ISO documentation (README URN section)
- Session 60: V1→V2 migration guide
- Session 61: Remove ISO/IEEE/NIST V1 code (ONLY after specs complete!)

### Phase 2-8: Continue as planned
(Sessions 62+)

---

## Spec Migration Template

### Per-Identifier Spec Structure

```ruby
# spec/pubid_new/{flavor}/identifiers/{identifier}_spec.rb

RSpec.describe PubidNew::{Flavor}::Identifiers::{Identifier} do
  describe ".parse" do
    context "basic parsing" do
      it "parses simple identifier" do
        parsed = described_class.parse("...")
        expect(parsed).to be_a(described_class)
        expect(parsed.to_s).to eq("...")
      end
    end
    
    context "with parts" do
      # Test multi-part identifiers
    end
    
    context "with stages" do
      # Test draft stages if applicable
    end
    
    context "with editions" do
      # Test edition handling
    end
    
    # ... more contexts as needed
  end
  
  describe "#to_s" do
    context "rendering" do
      # Test string rendering
    end
    
    context "with language" do
      # Test language variants
    end
  end
  
  describe "#to_urn" do
    context "basic URN" do
      # Test URN generation if applicable
    end
    
    context "with stage" do
      # Test URN with harmonized codes
    end
  end
end
```

---

## Success Metrics (UPDATED)

### Spec Coverage Metrics

| Metric | Target | Current | Gap |
|--------|--------|---------|-----|
| ISO classes w/ specs | 26/26 | 26/26 | ✅ 0 |
| NIST classes w/ specs | 20/20 | 5/20 | ⚠️ -15 |
| IEEE classes w/ specs | 5/5 | 4/5 | ⚠️ -1 |
| IEC classes w/ specs | 6/6 | 3/6 | ⚠️ -3 |
| JIS classes w/ specs | 4/4 | 1/4 | ⚠️ -3 |
| CEN classes w/ specs | 3/3 | 3/3 | ✅ 0 |

**Overall Target:** 64/64 identifier classes have individual spec files

**Current:** 42/64 (65.6%)

**Gap:** 22 spec files missing

---

## Critical Realizations

1. **"100% passing" is misleading** without complete spec coverage
2. **NIST is undertested** - Only 25% of classes have specs (5/20)
3. **Cannot remove V1 code** until ALL identifier classes have V2 specs
4. **Spec migration is PHASE 0** - Must happen before documentation

---

## Updated Timeline

| Phase | Sessions | Duration | Deliverable |
|-------|----------|----------|-------------|
| **Phase 0** | 50-58 | 2.5 weeks | Complete spec coverage |
| **Phase 1** | 59-61 | 1 week | Documentation + V1 removal |
| **Phase 2+** | 62+ | 8 weeks | Remaining flavors |

**New Total:** ~50 sessions (~10-12 weeks)

---

## Immediate Actions

**Session 50 (NOW - CHANGED):**
1. Audit all identifier classes in lib/pubid_new/
2. Count existing spec files in spec/pubid_new/
3. Create SPEC_MIGRATION_MATRIX.md with complete gap analysis
4. Prioritize migration order

**Sessions 51-55 (CRITICAL):**
1. Migrate 15 NIST specs (3 per session)
2. Each identifier class gets its own spec file
3. Maintain 90%+ pass rate
4. Follow MODEL-DRIVEN testing principles

**Sessions 56-58 (HIGH PRIORITY):**
1. Migrate remaining IEC, JIS, IEEE specs
2. Verify complete coverage
3. Run full test suites

**Session 59+ (AFTER SPECS COMPLETE):**
1. NOW we can document (ISO README URN section)
2. NOW we can remove V1 code safely
3. Then continue with remaining flavors

---

## Conclusion

**CRITICAL FINDING:** We cannot remove V1 code until ALL identifier classes have V2 specs.

**Action:** Spec migration is now PHASE 0, happening BEFORE documentation and V1 removal.

**Impact:** Timeline extended by 9 sessions (2.5 weeks) but ensures quality and completeness.

**Benefit:** True production-ready status with comprehensive test coverage.