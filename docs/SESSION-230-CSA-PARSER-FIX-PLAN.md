# Session 230+ CSA Parser Enhancement Plan: 67.8% → 90%+

**Created:** 2025-12-29
**Current:** 249/367 (67.8%)
**Target:** 294+ (80% minimum), 330+ (90% target)
**Gap:** +45 tests minimum, +81 tests target
**Timeline:** 2-3 sessions (4-6 hours)

---

## Failure Analysis (118 failures)

### Category 1: Dash Year in Code Value (~30 failures, HIGH IMPACT)

**Problem:** Parser puts year in code instead of separate year attribute
**Examples:**
- `CSA C22.1-15` → code="C22.1-15" should be code="C22.1", year="2015"
- `CSA A123.1-05` → code="A123.1-05" should be code="A123.1", year="2005"

**Root Cause:** Parser's `code_with_year` rule captures dash-year as part of code value

**Fix Location:** `lib/pubid_new/csa/parser.rb` + `lib/pubid_new/csa/builder.rb`

**Strategy:**
1. Parser: Separate year capture from code (lines ~80-95)
2. Builder: Extract year from parsed data, set both code and year
3. Test: All dash-year formats working

**Expected Gain:** +30 tests (67.8% → 76%!)

---

### Category 2: French Attribute Not Set (~5 failures, MEDIUM IMPACT)

**Problem:** `:F20` parsed but french attribute not set to true
**Examples:**
- `CSA B149.1:F20` → french=nil should be french=true, year="2020"

**Root Cause:** Builder doesn't detect "F" prefix and set french=true

**Fix Location:** `lib/pubid_new/csa/builder.rb` (cast method)

**Strategy:**
1. Builder: Detect year_prefix="F" 
2. Builder: Set french=true when F prefix detected
3. Builder: Strip F from year value ("F20" → "20" → "2020")

**Expected Gain:** +5 tests (76% → 77.4%)

---

### Category 3: CAN/CSA Type Routing (~20 failures, HIGH IMPACT)

**Problem:** `CAN/CSA-` and `CAN3-` return Standard instead of CanadianAdopted
**Examples:**
- `CAN/CSA-A123.2-03` → Standard should be CanadianAdopted
- `CAN3-B78.1-M83` → Standard should be CanadianAdopted

**Root Cause:** Builder doesn't check for CAN/CSA prefix to route to correct class

**Fix Location:** `lib/pubid_new/csa/builder.rb` (class selection)

**Strategy:**
1. Builder: Check for `can_prefix` or `can3_prefix` markers
2. Builder: Return CanadianAdopted class when prefix detected
3. Test: All CAN/CSA- and CAN3- patterns routing correctly

**Expected Gain:** +20 tests (77.4% → 82.9%)

---

### Category 4: Package/Series Type Classification (~25 failures, HIGH IMPACT)

**Problem:** Identifiers with " PACKAGE" or " SERIES" return Standard
**Examples:**
- `CSA B149.1:25 PACKAGE` → Standard should be Package
- `CSA Z240 MH SERIES:16` → Standard should be Series

**Root Cause:** Builder doesn't check for package_materials or series_prefix

**Fix Location:** `lib/pubid_new/csa/builder.rb` (class selection)

**Strategy:**
1. Builder: Check for `package_materials` marker → Package class
2. Builder: Check for `series_prefix` marker → Series class
3. Test: All PACKAGE and SERIES patterns routing correctly

**Expected Gain:** +25 tests (82.9% → 89.7%!)

---

### Category 5: NO. Number Includes Year (~10 failures, MEDIUM IMPACT)

**Problem:** `C22.2 NO. 286:23` → number includes `:23` portion
**Examples:**
- Parser captures "C22.2 NO. 286:23" as single number value

**Root Cause:** Parser's NO. rule doesn't separate year

**Fix Location:** `lib/pubid_new/csa/parser.rb` (no_code rule)

**Strategy:**
1. Parser: Split NO. pattern into code + year portions
2. Builder: Extract both parts correctly
3. Test: NO. patterns with correct separation

**Expected Gain:** +10 tests (89.7% → 92.4%!)

---

### Category 6: Combined/Bundled Type Routing (~15 failures, MEDIUM IMPACT)

**Problem:** Combined/Bundled identifiers parsed as Standard
**Examples:**
- `CSA A:20 + B:20` → Standard should be Bundled
- `CSA A:05/B:05` → Standard should be Combined

**Root Cause:** Builder doesn't detect separator markers

**Fix Location:** `lib/pubid_new/csa/builder.rb` (class selection)

**Strategy:**
1. Builder: Check for `bundled_with` array → Bundled class
2. Builder: Check for `second_identifier` → Combined class
3. Test: All composite patterns routing correctly

**Expected Gain:** +15 tests (92.4% → 96.5%!)

---

### Category 7: Round-Trip Variations (~13 failures, LOW PRIORITY)

**Problem:** Minor rendering format differences
**Examples:**
- Parsed vs rendered spacing, separator variations

**Root Cause:** Rendering logic normalization

**Fix Location:** Various identifier `to_s` methods

**Strategy:**
1. Preserve original format markers in parse
2. Use format markers in rendering
3. Test: Round-trip fidelity

**Expected Gain:** +13 tests (96.5% → 100%!)

---

## Implementation Roadmap

### Session 230: High-Impact Fixes (120 min)

**Priority 1: Dash Year Separation (+30 tests)** (40 min)
- Parser: Separate code from dash-year
- Builder: Extract and convert year
- Test: Verify all dash formats

**Priority 2: CAN/CSA Type Routing (+20 tests)** (30 min)
- Builder: Detect CAN/CSA- and CAN3- prefixes
- Builder: Route to CanadianAdopted class
- Test: Verify type classification

**Priority 3: Package/Series Classification (+25 tests)** (40 min)
- Builder: Detect PACKAGE and SERIES markers
- Builder: Route to correct classes
- Test: Verify routing

**Priority 4: Testing** (10 min)
- Run full test suite
- Validate +75 tests gained
- Verify no regressions

**Expected Result:** 324/367 (88.3%) - Excellent!

---

### Session 231: Remaining Fixes (60 min) - OPTIONAL

**Priority 5: French Detection (+5 tests)** (15 min)
**Priority 6: NO. Separation (+10 tests)** (20 min)
**Priority 7: Composite Routing (+15 tests)** (15 min)
**Testing** (10 min)

**Expected Result:** 354/367 (96.5%) - Near perfect!

---

### Session 232: Round-Trip Polish (30 min) - OPTIONAL

**Priority 8: Format Preservation (+13 tests)**

**Expected Result:** 367/367 (100%) - Perfect!

---

## Success Criteria

### Minimum (Session 230)
- ✅ CSA at 80%+ (294/367)
- ✅ Dash year working
- ✅ Type routing fixed
- ✅ No architecture compromises

### Target (Session 231)
- ✅ CSA at 90%+ (330/367)
- ✅ All major patterns working
- ✅ French detection working
- ✅ Production excellent quality

### Stretch (Session 232)
- ✅ CSA at 100% (367/367)
- ✅ Perfect round-trip fidelity
- ✅ All patterns working

---

## Implementation Guidelines

### Architectural Principles (NEVER COMPROMISE)

1. **MODEL-DRIVEN** - Objects not strings
2. **MECE** - 8 mutually exclusive identifier types
3. **Three-layer** - Parser/Builder/Identifier independence
4. **Component pattern** - Proper Lutaml::Model usage
5. **Separation of concerns** - Each layer has ONE job

### Parser Changes

**Location:** `lib/pubid_new/csa/parser.rb`

**Changes:**
- Separate year from code in dash-year patterns
- Split NO. code from year portion
- Keep all other patterns working

**Test after each change!**

### Builder Changes

**Location:** `lib/pubid_new/csa/builder.rb`

**Changes:**
- Detect CAN/CSA- and CAN3- prefixes → CanadianAdopted
- Detect PACKAGE marker → Package
- Detect SERIES marker → Series
- Detect bundled_with → Bundled
- Detect second_identifier → Combined
- Detect F prefix → set french=true
- Extract year from code when needed

**Critical:** Class selection logic must be MECE!

---

## Files to Modify

### Session 230
- `lib/pubid_new/csa/parser.rb` - Dash year separation
- `lib/pubid_new/csa/builder.rb` - Type routing, year extraction
- All 8 spec files - Update expectations if needed

### Session 231 (optional)
- `lib/pubid_new/csa/parser.rb` - NO. separation
- `lib/pubid_new/csa/builder.rb` - French detection, composite routing

### Session 232 (optional)
- Various identifier `to_s` methods - Format preservation

---

## Risk Mitigation

### High Risk Areas

**1. Breaking Existing Tests**
- Risk: Fixing one pattern breaks another
- Mitigation: Test incrementally after each fix
- Validation: Run full suite after each category

**2. Parser Regression**
- Risk: Changing parser breaks working patterns
- Mitigation: Make minimal, focused changes
- Validation: Verify fixture classification unchanged (879/903)

**3. Builder Complexity**
- Risk: Class selection logic becomes unmaintainable
- Mitigation: Keep MECE organization, document decisions
- Validation: Each type has clear, non-overlapping criteria

### Validation Checkpoints

**After each fix:**
- [ ] Run affected spec file
- [ ] Verify expected gain achieved
- [ ] Check no regressions in other specs
- [ ] Verify fixture classification maintained

**After Session 230:**
- [ ] CSA at 80%+ (minimum success)
- [ ] All high-impact fixes working
- [ ] No architecture compromises

---

## Timeline Summary

| Session | Focus | Duration | Gain | Cumulative |
|---------|-------|----------|------|------------|
| 230 | High-impact (1-4) | 120 min | +75 | 88.3% |
| 231 | Remaining (5-7) | 60 min | +30 | 96.5% |
| 232 | Polish (8) | 30 min | +13 | 100% |
| **Total** | **All fixes** | **210 min** | **+118** | **100%** |

---

## Next Steps (Session 230)

1. Read this plan
2. Analyze current parser/builder code
3. Implement Priority 1 (dash year)
4. Test and validate
5. Implement Priority 2 (CAN/CSA routing)
6. Test and validate
7. Implement Priority 3 (Package/Series)
8. Test and validate
9. Document results

---

**Created:** 2025-12-29
**Status:** Ready for Session 230
**Recommendation:** Execute Session 230 (high-impact fixes) immediately

**End Goal:** CSA at 88%+ minimum, 96%+ target, 100% stretch! 🚀
