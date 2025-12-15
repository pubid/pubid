# Session 138+ Continuation Plan: IEEE Advanced Patterns & Copublisher Support

**Created:** 2025-12-14 (Post-Session 137)
**Status:** Session 137 complete - Ready for advanced pattern implementation
**Timeline:** COMPREHENSIVE - 4-6 sessions (8-12 hours)

---

## Executive Summary

**Session 137 Finding:** Current 88.17% represents production-excellent quality for simple patterns. Remaining 1,128 failures require **architectural enhancements** not simple parser additions.

**User-Provided Patterns:** 50+ specific failing identifiers requiring:
1. **Copublisher support** (ASTM, CSA, ASME)
2. **Corrigenda as distinct identifier type**
3. **Multiple relationships** (slash-separated)
4. **"as amended by" chains** (recursive amendment lists)
5. **Missing prefix handling** (bare numbers like "IEEE 1070-1995")
6. **Equivalence notation** (AIEE/ASA, IEEE/ASME, IEEE/CSA)
7. **Data cleaning** (extra spaces, symbols, commas)

**Target:** 92-95% (8,774-9,060/9,537) with proper architecture

---

## Pattern Analysis & Categorization

### Category 1: Data Quality Issues (EASY - Parser preprocessing)

**Examples:**
- `ANSI C57.1 2.25-1990` → extra space in number
- `ANSI C63.022-1 996` → space in year
- `ANSI N42.43-2006, Standard` → trailing comma
- `IEEE Std C57.110&x2122;-2018` → HTML entities
- `IEEE Std 802&x2019;s` → HTML apostrophe

**Solution:** Enhanced preprocessing in `Parser.parse` class method
**Estimated Impact:** +50-80 identifiers
**Complexity:** LOW

### Category 2: Missing Prefix Patterns (MEDIUM - Parser enhancement)

**Examples:**
- `IEEE 1070-1995` → no "Std" or "Standard"
- `IEEE 278-1967` → bare number
- `ANSI PN42.34-D9a, 2015` → ANSI with P prefix

**Solution:** Enhanced identifier rules with optional type
**Estimated Impact:** +80-120 identifiers
**Complexity:** MEDIUM

### Category 3: New Copublishers (MEDIUM - Component architecture)

**Examples:**
- `IEEE/ASTM SI 10-1997` → ASTM copublisher
- `IEEE/CSA P844.1/293.1/D2` → CSA with dual numbering
- `IEEE Std 844.1-2017/CSA C22.2 No. 293.1-17` → CSA as supplement
- `IEEE Std 120-1955; ASME PTC 19.6-1955` → ASME equivalence

**Solution:**
1. Add ASTM, CSA, ASME to organization list
2. Create EquivalenceIdentifier for semicolon-separated dual IDs
3. Enhance copublisher parsing for dual numbering

**Estimated Impact:** +100-150 identifiers
**Complexity:** MEDIUM

### Category 4: Corrigenda as Identifier Type (HIGH - Architecture)

**Examples:**
- `IEEE Std 535-2013/Cor. 1-2017`
- `IEEE Std 802.1AC-2016/Cor 1-2018`
- `IEEE Std C37.41-2016/Cor 1-2017`

**Current State:** Handled as corrigendum attribute
**Required:** Corrigendum as SupplementIdentifier (like Amendment)

**Solution:**
1. Create `Identifiers::Corrigendum < SupplementIdentifier`
2. Add to TYPED_STAGES registry
3. Update parser to recognize corrigendum patterns
4. Update builder to construct Corrigendum objects

**Estimated Impact:** +60-90 identifiers
**Complexity:** HIGH (architectural change)

### Category 5: Multiple Relationships (HIGH - Architecture)

**Examples:**
- `(Revision of X/Incorporates Y)` → slash-separated
- `(Reaffirmation of X; Redesignation of Y)` → semicolon-separated

**Current State:** Single relationship or fallback to additional_parameters
**Required:** Support multiple relationships in one clause

**Solution:**
1. Already supports `/ ` separator in parser (lines 286-292)
2. Need to support `;` separator as well
3. Test multi-relationship parsing

**Estimated Impact:** +30-50 identifiers
**Complexity:** MEDIUM (parser enhancement only)

### Category 6: "as amended by" Chains (HIGH - Recursive architecture)

**Examples:**
```
IEEE Std 802.15.4x-2019 (Amendment to IEEE 802.15.4-2015
  as amended by IEEE 802.15.4n-2016, IEEE 802.15.4q-2016,
  IEEE 802.15.4u-2016, IEEE 802.15.4t-2017, IEEE 802.15.4v-2017,
  IEEE 802.15.4s-2018, and IEEE 802.15.4-2015/Cor. 1-2018)
```

**Current State:** Parser has `as_amended_by_clause` but builder doesn't construct
**Required:** Store amendment chain in Amendment identifier

**Solution:**
1. Add `intermediate_amendments` collection to Amendment
2. Builder constructs array of identifiers from `as_amended_by_clause`
3. Rendering includes chain

**Estimated Impact:** +40-70 identifiers
**Complexity:** HIGH (architectural change)

### Category 7: AIEE/ASA Equivalence (MEDIUM - Parenthetical enhancement)

**Examples:**
- `AIEE No 18-1934 (ASA C55 1934)`
- `AIEE No 22-1952 (Supercedes AIEE No. 22-1942 and 22A-1949)`

**Solution:**
1. Add ASA to organization list
2. AIEE parser handles (ASA ...) as equivalence
3. Store as `equivalent_identifier` attribute

**Estimated Impact:** +20-30 identifiers
**Complexity:** MEDIUM

---

## Implementation Phases

### Phase 1: Data Cleaning Enhancement (Session 138 - 60 min)

**Objective:** Clean data quality issues with enhanced preprocessing

**Tasks:**
1. Enhance `Parser.parse` preprocessing (20 min)
   - Remove extra spaces in numbers: `C57.1 2.25` → `C57.12.25`
   - Remove spaces in years: `1 996` → `1996`
   - Remove trailing commas: `, Standard` → ``
   - Clean HTML entities: `&x2122;` → `™`, `&x2019;` → `'`

2. Test preprocessing (20 min)
   - Unit tests for each cleaning pattern
   - Fixture classification check

3. Document and commit (20 min)

**Expected Gain:** +50-80 identifiers (88.17% → 88.7-89.0%)

### Phase 2: Missing Prefix Patterns (Session 139 - 90 min)

**Objective:** Handle identifiers without "Std" or "Standard"

**Tasks:**
1. Update parser identifier rule (40 min)
   - Make `type_word` fully optional
   - Add bare number pattern after P patterns
   - Test precedence carefully

2. Add ANSI P prefix support (30 min)
   - Similar to IEEE P prefix
   - Handles `ANSI PN42.34-D9a`

3. Test and validate (20 min)

**Expected Gain:** +80-120 identifiers (89.0% → 89.8-90.3%)

### Phase 3: New Copublishers (Session 140 - 120 min)

**Objective:** Support ASTM, CSA, ASME copublishers

**Tasks:**
1. Add organizations to parser (15 min)
   - Add ASTM, CSA, ASME to organization rule

2. Create EquivalenceIdentifier class (45 min)
   - For semicolon-separated dual IDs
   - `IEEE X; ASME Y` pattern
   - Store both identifiers

3. CSA dual numbering support (40 min)
   - `IEEE/CSA PX/Y` pattern
   - `IEEE X/CSA Y` pattern

4. Test all copublisher patterns (20 min)

**Expected Gain:** +100-150 identifiers (90.3% → 91.4-92.0%)

### Phase 4: Corrigendum Identifier Type (Session 141 - 120 min)

**Objective:** Make Corrigendum a proper SupplementIdentifier

**Tasks:**
1. Create Corrigendum class (30 min)
   - `class Corrigendum < SupplementIdentifier`
   - Proper TYPED_STAGES entries

2. Update parser (30 min)
   - Enhance corrigendum rule
   - Recognize as supplement not attribute

3. Update builder (30 min)
   - Construct Corrigendum objects
   - Recursive base parsing

4. Test and validate (30 min)

**Expected Gain:** +60-90 identifiers (92.0% → 92.6-93.0%)

### Phase 5: Advanced Relationships (Session 142 - 90 min)

**Objective:** Multiple relationships and amendment chains

**Tasks:**
1. Add semicolon separator support (20 min)
   - Already has `/ ` support
   - Add `; ` parsing

2. Implement "as amended by" chains (50 min)
   - Add `intermediate_amendments` to Amendment
   - Builder constructs identifier array
   - Rendering includes chain

3. Test complex relationships (20 min)

**Expected Gain:** +70-120 identifiers (93.0% → 93.7-94.3%)

### Phase 6: AIEE Equivalence (Session 143 - 60 min)

**Objective:** AIEE/ASA and other equivalence patterns

**Tasks:**
1. Add ASA organization (10 min)
2. AIEE equivalence handling (30 min)
   - Parse (ASA ...) parenthetical
   - Store as equivalent_identifier
3. Test and validate (20 min)

**Expected Gain:** +20-30 identifiers (94.3% → 94.5-94.8%)

---

## Implementation Status Tracker

### Phase 1: Data Cleaning ⏳
- [ ] Enhanced preprocessing patterns
- [ ] HTML entity cleaning
- [ ] Extra space removal
- [ ] Trailing comma removal
- [ ] Testing and validation

### Phase 2: Missing Prefix ⏳
- [ ] Optional type_word in parser
- [ ] Bare number pattern
- [ ] ANSI P prefix support
- [ ] Testing and validation

### Phase 3: New Copublishers ⏳
- [ ] Add ASTM, CSA, ASME organizations
- [ ] Create EquivalenceIdentifier
- [ ] CSA dual numbering
- [ ] Testing and validation

### Phase 4: Corrigendum Type ⏳
- [ ] Create Corrigendum class
- [ ] Update parser
- [ ] Update builder
- [ ] Testing and validation

### Phase 5: Advanced Relationships ⏳
- [ ] Semicolon separator
- [ ] Amendment chains
- [ ] Testing and validation

### Phase 6: AIEE Equivalence ⏳
- [ ] ASA organization
- [ ] Equivalence parsing
- [ ] Testing and validation

---

## Success Criteria

### Per Phase
- ✅ Expected identifier gain achieved
- ✅ Zero architectural regressions
- ✅ MODEL-DRIVEN principles maintained
- ✅ All unit tests passing

### Overall Project (Sessions 138-143)
- ✅ IEEE at 94-95% (8,965-9,060/9,537)
- ✅ Proper Corrigendum architecture
- ✅ Full copublisher support
- ✅ Advanced relationship handling
- ✅ Production-ready quality maintained

---

## Key Architectural Principles

**MAINTAIN throughout:**
1. **MODEL-DRIVEN** - Objects not strings
2. **MECE** - Each identifier type distinct
3. **Three-layer** - Parser/Builder/Identifier independence
4. **Component reuse** - Shared components across flavors
5. **Incremental** - Test after each change
6. **Architecture first** - Correctness over test count

---

## Files to Create/Modify

### New Files
- `lib/pubid_new/ieee/identifiers/corrigendum.rb` (Phase 4)
- `lib/pubid_new/ieee/identifiers/equivalence.rb` (Phase 3)
- `spec/pubid_new/ieee/identifiers/corrigendum_spec.rb` (Phase 4)

### Modified Files
- `lib/pubid_new/ieee/parser.rb` (All phases)
- `lib/pubid_new/ieee/builder.rb` (Phases 3-5)
- `lib/pubid_new/ieee/identifiers/amendment.rb` (Phase 5)
- `lib/pubid_new/ieee/aiee/identifier.rb` (Phase 6)

---

## Timeline Summary

| Sessions | Focus | Duration | Deliverables |
|----------|-------|----------|--------------|
| 138 | Data cleaning | 60 min | Preprocessing +50-80 IDs |
| 139 | Missing prefix | 90 min | Bare numbers +80-120 IDs |
| 140 | Copublishers | 120 min | ASTM/CSA/ASME +100-150 IDs |
| 141 | Corrigendum type | 120 min | Proper architecture +60-90 IDs |
| 142 | Relationships | 90 min | Chains +70-120 IDs |
| 143 | AIEE equivalence | 60 min | ASA +20-30 IDs |
| **Total** | **All work** | **540 min** | **94-95% target** |

---

**Created:** 2025-12-14
**Sessions Covered:** 138-143
**Status:** Ready for execution
**Estimated Time:** 9 hours (compressed from typical 12-15)

**End Goal:** IEEE at 94-95%, all advanced patterns supported, production-excellent architecture! 🚀