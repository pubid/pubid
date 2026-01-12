# Next Steps: PubID V2 Implementation Roadmap

**Last Updated:** January 8, 2026  
**Current Status:** Sessions 291-292 Complete, Session 293 Pending

## Immediate Priority: Session 293 (ASTM Integration Specs)

**Status:** ⏳ Subtask Created, Pending Execution  
**Estimated Time:** 2-3 hours

### Objective
Create comprehensive integration specs for ASTM identifiers to validate the existing V2 implementation.

### Task Details

**Create File:** `spec/pubid_new/astm/identifier_spec.rb`

**Requirements:**
1. Test all 248 ASTM fixtures from `spec/fixtures/astm/*.txt`
2. Verify round-trip fidelity: `parse(str).to_s == str`
3. Validate correct identifier class selection
4. Generate success/failure statistics report

**Expected Patterns:**
```ruby
# Standard identifiers
ASTM E929-02
ASTM E1354-17

# With revision year
ASTM E84-20a
ASTM C39/C39M-21

# Data series
ASTM DS5C
ASTM DS13L

# Adjuncts
ASTM C39/C39M-21/Adjunct1

# ISO dual-published
ISO/ASTM 51649:2015(E)
```

**Success Criteria:**
- ✅ Integration spec file created and executable
- ✅ At least 90% of fixtures parse successfully
- ✅ Round-trip fidelity verified
- ✅ Known issues documented
- ✅ Pass/fail report generated

**Action:** Execute Session 293 subtask immediately.

---

## BSI V2 Implementation Continuation

**Current Status:** 1,077/1,632 (65.99%)  
**Supplement/Addendum:** 59/59 (100%) ✅

### Short Term Goals (Next 3 Sessions)

#### 1. RangeIdentifier Implementation
**Fixtures:** `spec/fixtures/bsi/identifiers/full/range.txt`  
**Patterns:** 40 identifiers  
**Target Coverage:** 1,077 → 1,117 (68.44%)

**Examples:**
```
BS 12-32 to 44:1978
BS 5000-0 to 5000-12
BS EN 50065-1 to -8:2011
```

**Architecture:**
- Create `lib/pubid_new/bsi/identifiers/range_identifier.rb`
- Implement start/end identifier attributes
- Handle various range formats (to, -, etc.)
- Support year on start, end, or both

**Estimated Time:** 2-3 hours

#### 2. BundledIdentifier Enhancement
**Fixtures:** `spec/fixtures/bsi/identifiers/full/bundled.txt`  
**Patterns:** 97 identifiers  
**Target Coverage:** 1,117 → 1,214 (74.39%)

**Examples:**
```
BS 6008 & BS 8004:1986
BS 1474 + BS 7193:1989
BS 5306-1 & -3:1976
```

**Architecture:**
- Enhance existing `lib/pubid_new/bsi/identifiers/bundled_identifier.rb`
- Support multiple bundle operators (&, +, and)
- Handle range references (-3 means same base number)
- Support year on individual or all bundled items

**Estimated Time:** 3-4 hours

#### 3. DraftDocument Enhancement
**Fixtures:** `spec/fixtures/bsi/identifiers/full/draft_for_comment.txt`, `draft_for_development.txt`, `draft_for_public_comment.txt`  
**Current:** 36/103 (35%)  
**Target:** 103/103 (100%)  
**Delta:** +67 identifiers  
**Target Coverage:** 1,214 → 1,281 (78.50%)

**Examples:**
```
DD ENV 1998-1-1:2004
DD 9400:1998
DD CEN/TS 12390-9:2006
```

**Architecture:**
- Enhance `lib/pubid_new/bsi/identifiers/draft_document.rb`
- Support DD (Draft for Development)
- Support various draft types (ENV, CEN/TS, etc.)
- Handle adopted standards in draft format

**Estimated Time:** 2-3 hours

### Medium Term Goals (Next 10 Sessions)

#### 4. PubliclyAvailableSpecification
**Fixture:** `pas.txt`  
**Patterns:** 89 identifiers  
**Examples:** `PAS 7040:2021`, `PAS 555:2013+A1:2017`

#### 5. PublishedDocument
**Fixture:** `pd.txt`  
**Patterns:** 45 identifiers  
**Examples:** `PD 5500:2012`, `PD TR 17603:2003`

#### 6. NationalAnnex Enhancement
**Fixture:** `national_annex.txt`  
**Current:** Some support exists  
**Patterns:** ~25 identifiers  
**Examples:** `BS EN 1990:2002+A1:2005/NA:2010`

#### 7. Consolidated Identifiers
**Fixture:** Various with incorporation notices  
**Patterns:** ~50 identifiers  
**Examples:** `BS 5628-1:2005 incorporating Corrigendum No. 1`

#### 8. ExpertCommentary Enhancement
**Fixture:** `expert_commentary.txt`  
**Patterns:** ~20 identifiers  
**Examples:** `BS 7671:2008+A3:2015 Expert commentary`

### Long Term Goals (To 100% Coverage)

**Remaining Work:**
- Handbook identifiers
- Practice guides
- Value-added publications  
- Various special types
- Historical patterns

**Target:** 1,632/1,632 (100%)  
**Estimated Sessions:** 15-20 more sessions

---

## Architecture Improvements

### 1. Performance Optimization
**Status:** Not yet measured  
**Goal:** Benchmark BSI parser performance

**Actions:**
- Create performance test suite
- Measure parse time per identifier type
- Identify bottlenecks
- Implement parser instance memoization if needed

### 2. Error Message Enhancement
**Status:** Basic Parslet errors only  
**Goal:** User-friendly error messages

**Actions:**
- Enhance Builder error handling
- Provide context for parse failures
- Suggest corrections for common mistakes

### 3. Documentation
**Status:** Partial  
**Goal:** Complete user documentation

**Actions:**
- Create BSI usage guide in README.adoc
- Document all identifier types with examples
- Create BSI-specific architecture diagram
- Update V2_ARCHITECTURE.adoc with BSI lessons

---

## Other Flavors Status

### Completed (100%)
- ✅ ISO (6,890 fixtures)
- ✅ IEC (1,537 fixtures)
- ✅ IEEE (5,267 fixtures)
- ✅ NIST (19,488 fixtures)
- ✅ ITU (2,031 fixtures)
- ✅ JIS (1,034 fixtures)

### In Progress
- 🔄 BSI (1,077/1,632 = 65.99%)
- 🔄 CEN (Partial implementation)
- 🔄 ETSI (Parser exists, needs validation)
- 🔄 CCSDS (Parser exists, needs validation)

### Pending
- ⏳ ASTM (Parser complete, specs pending - Session 293)
- ⏳ PLATEAU (Parser exists, needs validation)
- ⏳ ANSI (Basic implementation)
- ⏳ 10+ more flavors planned

---

## Session Planning

### This Week
- **Session 293:** ASTM Integration Specs (immediate)
- **Session 294:** BSI RangeIdentifier (after 293)
- **Session 295:** BSI BundledIdentifier (after 294)

### Next Week
- **Session 296:** BSI DraftDocument Enhancement
- **Session 297:** BSI PAS Implementation
- **Session 298:** BSI PD Implementation

### Goal: BSI 100% Coverage
**Target Date:** End of January 2026  
**Estimated Sessions:** 15-20 sessions total  
**Current Progress:** 65.99% (on track)

---

## Success Metrics

### Quality Metrics (All Must Be 100%)
- ✅ Round-trip fidelity: 100%
- ✅ Integration tests passing: 100%
- ✅ Zero regressions: Yes
- ✅ Architecture compliance: Yes

### Coverage Metrics
- Overall BSI: 65.99% (target: 100%)
- Supplement/Addendum: 100% ✅
- Adopted Standards: 95.24% ✅
- Draft Documents: 35% (target: 100%)

### Documentation Metrics
- Session summaries: 100% ✅
- Memory bank: Updated ✅
- Architecture docs: 80% (needs BSI-specific additions)
- User guides: 60% (needs BSI examples)

---

## Recommended Actions

### Immediate (Today)
1. ✅ Execute Session 293 (ASTM specs) - **START NOW**
2. Review Session 293 results
3. Plan Session 294 (BSI RangeIdentifier)

### This Week
1. Complete Sessions 293-295
2. Update README.adoc with BSI examples
3. Create BSI architecture diagram

### This Month
1. Reach 85% BSI coverage (1,387/1,632)
2. Complete all major identifier types
3. Begin ETSI/CCSDS validation

### This Quarter
1. Complete BSI 100%
2. Complete CEN 100%
3. Validate all remaining partial flavors
4. Final V2 release preparation

---

**Next Action:** Execute Session 293 - ASTM Integration Specs

**Status:** Ready for immediate execution ✅