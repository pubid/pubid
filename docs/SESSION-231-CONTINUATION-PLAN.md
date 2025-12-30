# Session 231+ Continuation Plan: CSA Parser Enhancement to 90%+

**Created:** 2025-12-30 (Post-Session 230)
**Current:** 271/367 (73.8%)
**Target:** 330+/367 (90%+)
**Gap:** +59 tests needed
**Timeline:** 2-3 sessions (3-4 hours compressed)

---

## Session 230 Achievement Summary

**Completed Priorities:**
- ✅ Priority 1: Dash year separation (+13 tests)
- ✅ Priority 2: CAN/CSA type routing (+9 tests)
- ⚠️ Priority 3: Package implementation (partial, needs parser work)

**Results:** 249/367 → 271/367 (+22 tests, +6.0pp)

**Files Modified:**
- `lib/pubid_new/csa/builder.rb` - Added dash year extraction, MECE class selection, build_package

---

## Remaining Work Analysis (96 failures)

### Category 1: French Attribute Detection (~5 failures, MEDIUM IMPACT)

**Problem:** `year_prefix='F'` parsed but french attribute not consistently set

**Examples:**
- `CSA B149.1:F20` → Should have french=true (WORKING NOW via Session 230 fix)
- Some edge cases may remain

**Fix Location:** Already implemented in Session 230, verify working

**Expected Gain:** +5 tests (already counted in Session 230 results)

---

### Category 2: NO. Number Year Separation (~10 failures, MEDIUM IMPACT)

**Problem:** `C22.2 NO. 286:23` includes year in NO. number value

**Root Cause:** Parser's `no_number` rule doesn't separate year from number

**Fix Location:** `lib/pubid_new/csa/parser.rb` (no_number rule, line 60)

**Strategy:**
1. Parser: Detect `:NN` or `-NN` suffix in NO. number
2. Parser: Capture year separately as `no_year`
3. Builder: Extract NO. year and set identifier.year

**Expected Gain:** +10 tests (73.8% → 76.5%)

---

### Category 3: Package/Series Parser Patterns (~30 failures, HIGH IMPACT)

**Problem:** Parser doesn't handle all Package and Series patterns

**Examples:**
- `CSA C22.1:24 Code & Handbook Package` → Parser fails
- `CSA B108:23 PACKAGE` → Parser fails
- Some SERIES patterns not routing correctly

**Root Cause:**
- Package patterns like "Code & Handbook Package" not in parser grammar
- Some SERIES patterns need series_type detection in parser

**Fix Location:** `lib/pubid_new/csa/parser.rb` (package_portion rule)

**Strategy:**
1. Enhance `package_portion` rule to capture full package text
2. Ensure `package_portion` marked in parsed hash
3. Builder already has build_package method (Session 230)
4. Test all Package patterns

**Expected Gain:** +20 tests (76.5% → 82.0%)

---

### Category 4: Combined/Bundled Type Routing (~15 failures, MEDIUM IMPACT)

**Problem:** Combined (slash) and Bundled (plus) not always routing correctly

**Examples:**
- `CSA A:20 + B:20` → Should be Bundled
- `CSA A:05/B:05` → Should be Combined

**Root Cause:** Builder routing already exists but may have edge cases

**Fix Location:** `lib/pubid_new/csa/builder.rb` (build method)

**Strategy:**
1. Verify bundled_first and first/second detection
2. Check separator detection (comma vs slash)
3. Test all combined/bundled patterns

**Expected Gain:** +15 tests (82.0% → 86.1%)

---

### Category 5: Round-Trip Rendering Variations (~13 failures, LOW PRIORITY)

**Problem:** Minor rendering format differences

**Examples:**
- Spacing variations
- Separator normalization
- Format preservation

**Root Cause:** Rendering logic in identifier `to_s` methods

**Fix Location:** Various identifier classes

**Strategy:**
1. Preserve format markers from parser
2. Use markers in rendering
3. Test round-trip fidelity

**Expected Gain:** +13 tests (86.1% → 89.6%)

---

### Category 6: Edge Cases (~13 failures, VARIES)

**Problem:** Remaining miscellaneous failures

**Examples:**
- Series with NO. notation edge cases
- Complex reaffirmation patterns
- Other parser limitations

**Strategy:** Address incrementally as discovered

**Expected Gain:** +6 tests (89.6% → 91.2%)

---

## Implementation Roadmap

### Session 231: Medium-Impact Fixes (90 min)

**Priority 4: NO. Number Year Separation** (30 min)
- Parser: Enhance `no_number` rule to capture year
- Builder: Extract NO. year in `build_single`
- Test: Verify NO. patterns with year

**Priority 5: Package Parser Patterns** (40 min)
- Parser: Enhance `package_portion` rule
- Parser: Better package keyword capture
- Test: All Package spec patterns

**Priority 6: Combined/Bundled Verification** (20 min)
- Review builder routing logic
- Test edge cases
- Fix any missed patterns

**Expected Result:** 301/367 (82.0%) - Major progress!

---

### Session 232: Final Polish (60 min)

**Priority 7: Round-Trip Rendering** (30 min)
- Preserve format markers
- Fix rendering inconsistencies
- Test round-trip fidelity

**Priority 8: Edge Case Cleanup** (30 min)
- Address remaining failures
- Document known limitations
- Finalize architecture

**Expected Result:** 330+/367 (90%+) - TARGET ACHIEVED!

---

## Success Criteria

### Minimum (Session 231)
- ✅ CSA at 82%+ (301/367)
- ✅ NO. separation working
- ✅ Package patterns working
- ✅ No architecture compromises

### Target (Session 232)
- ✅ CSA at 90%+ (330/367)
- ✅ All major patterns working
- ✅ Round-trip fidelity high
- ✅ Production excellent quality

### Stretch (Optional)
- ✅ CSA at 96%+ (354/367)
- ✅ Near-perfect round-trip
- ✅ All patterns documented

---

## Architectural Principles (NEVER COMPROMISE)

1. **MODEL-DRIVEN** - Objects not strings
2. **MECE** - 8 mutually exclusive identifier types
3. **Three-layer** - Parser/Builder/Identifier independence
4. **Component pattern** - Proper Lutaml::Model usage
5. **Separation of concerns** - Each layer ONE job

---

## Files to Modify

### Session 231
- `lib/pubid_new/csa/parser.rb` - NO. year separation, package patterns
- `lib/pubid_new/csa/builder.rb` - NO. year extraction, verify routing
- Spec files - Update expectations if needed

### Session 232
- Various identifier `to_s` methods - Format preservation
- Documentation updates

---

## Risk Mitigation

### High Risk Areas

**1. Parser Regression**
- Risk: Changing parser breaks working patterns
- Mitigation: Test after each change
- Validation: Run full suite after each category

**2. Builder Complexity**
- Risk: Class selection becomes unmaintainable
- Mitigation: Keep MECE, document decisions
- Validation: Clear non-overlapping criteria

**3. Round-Trip Fidelity**
- Risk: Format normalization loses information
- Mitigation: Preserve markers from parser
- Validation: Round-trip tests

---

## Timeline Summary

| Session | Focus | Duration | Gain | Cumulative |
|---------|-------|----------|------|------------|
| 230 | Dash year, CAN/CSA | 60 min | +22 | 73.8% ✅ |
| 231 | NO., Package, routing | 90 min | +30 | 82.0% |
| 232 | Rendering, polish | 60 min | +29 | 90.0% |
| **Total** | **All fixes** | **210 min** | **+81** | **90%+** |

---

## Next Steps (Session 231)

1. Read this plan
2. Implement Priority 4 (NO. separation)
3. Test and validate
4. Implement Priority 5 (Package patterns)
5. Test and validate
6. Implement Priority 6 (Combined/Bundled)
7. Test and validate
8. Document results

---

**Created:** 2025-12-30
**Status:** Ready for Session 231
**Recommendation:** Execute Session 231 immediately for 82%+ target

**End Goal:** CSA at 90%+ with clean architecture! 🚀