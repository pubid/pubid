# Session 157+ Continuation Plan: CSA Pre-Existing Issues Fix

**Created:** 2025-12-17 (Post-Session 156)
**Status:** Bundled identifier semantic fix COMPLETE, pre-existing bugs identified
**Timeline:** COMPRESSED - Complete in 2-3 sessions (4-6 hours)

---

## Executive Summary

**Session 156 Achievement:** Fixed critical semantic error by implementing proper BundledIdentifier class for `+` notation ✅

**Current Challenge:** Session 155's `+` to `/` preprocessing was masking 4 pre-existing bugs:
1. Combined identifiers (`/`) - Builder incomplete
2. Package portions - Not parsed/rendered
3. M/F year prefixes - Lost in rendering
4. Missing CSA prefix - Some identifiers lack prefix

**Current Status:** 185/899 (20.58%)
**Session 154 Baseline:** 471/936 (50.32%)
**Regression Cause:** Pre-existing bugs now exposed, not the bundled fix itself

---

## Critical Understanding

### Bundled Fix is Semantically CORRECT ✅

**Session 156 implemented proper semantics:**
- `+` = BundledIdentifier (consolidated document)
- `/` = Combined/Referenced documents (different meaning)
- Architecture: MODEL-DRIVEN, MECE, proper class hierarchy
- Tests: 3/3 passing with perfect round-trip

**The regression is from exposing pre-existing bugs, NOT from the fix.**

---

## Pre-Existing Bugs to Fix

### Bug 1: Combined Identifiers - Builder Incomplete (HIGH IMPACT: ~286 IDs)

**Pattern:** `CSA A23.1:24/CSA A23.2:24`
**Current:** Builder returns only first identifier
**Expected:** Return both identifiers properly

**Issue in** [`lib/pubid_new/csa/builder.rb`](lib/pubid_new/csa/builder.rb:15):
```ruby
# Handle combined identifiers
if parsed_hash[:first] && parsed_hash[:second]
  # For now, just build the first one
  # TODO: Implement combined identifier support  # ← BUG HERE
  return build_single(parsed_hash[:first])
end
```

**Fix needed:**
- Create CombinedIdentifier class (like BundledIdentifier)
- Build both first and second
- Handle optional third
- Proper rendering with `/` separator

**Expected gain:** +200-250 IDs

---

### Bug 2: Package Portions Not Parsed/Rendered (MEDIUM IMPACT: ~30 IDs)

**Patterns:**
- `CSA B149.1:25 Code, Handbook & Training Package`
- `CSA C22.1:24 Code & Handbook Package`

**Current:** Package portion parsed but not stored/rendered
**Expected:** Store and render package keywords

**Parser already has rules** ([`lib/pubid_new/csa/parser.rb`](lib/pubid_new/csa/parser.rb:90)):
```ruby
rule(:package_portion) do
  space >>
  package_keyword >>
  (comma >> space >> package_keyword |
   space >> ampersand >> space >> package_keyword).repeat
end
```

**Fix needed:**
- Add `package` attribute to SingleIdentifier
- Builder should extract package_portion
- Base#to_s should render package

**Expected gain:** +20-30 IDs

---

### Bug 3: M/F Year Prefix Lost in Rendering (LOW IMPACT: ~15 IDs)

**Pattern:** `CSA C22.2 NO. 125-M1984 (R2004)`
**Current Output:** `CSA C22.2 NO. 125-1984 (R2004)` (M prefix lost)
**Expected:** Preserve M/F prefix

**Issue:** Builder detects and converts 2→4 digits but doesn't preserve prefix flag

**Fix needed:**
- Add `metric` boolean attribute to SingleIdentifier
- Builder sets metric=true when year_prefix is "M"
- Base#to_s renders M prefix when metric=true and year_format="dash"

**Expected gain:** +10-15 IDs

---

### Bug 4: Identifiers Without CSA Prefix (LOW IMPACT: ~5 IDs)

**Patterns:**
- `C22.1-15 PACKAGE`
- `C22.10-10 PACKAGE`

**Current:** Parser requires "CSA " prefix
**Expected:** Allow optional prefix for some legacy formats

**Fix needed:**
- Make publisher.maybe in parser
- Identifier.parse adds CSA prefix if missing in normalization
- Document this as legacy support

**Expected gain:** +5 IDs

---

## Implementation Plan

### Session 157: Combined Identifiers (90 min)

**Priority 1** - Highest impact

**Tasks:**
1. Create [`lib/pubid_new/csa/identifiers/combined.rb`](lib/pubid_new/csa/identifiers/combined.rb:1) (30 min)
   - Inherit from Lutaml::Model::Serializable
   - Attributes: first, second, third (all Standard type)
   - to_s: Join with `/` separator

2. Update Builder (30 min)
   - Replace TODO with build_combined method
   - Build all parts (first, second, optional third)
   - Handle reaffirmation and package properly

3. Test and validate (30 min)
   - Manual tests on combined patterns
   - Run classification
   - Expected: 385-435/899 (43-48%)

**Deliverables:**
- CombinedIdentifier class
- Complete builder implementation
- CSA at 43-48%

---

### Session 158: Package Support + M/F Prefix (60 min)

**Priority 2 & 3** - Medium + Low impact combined

**Part A: Package Support (35 min)**
1. Add package attribute to SingleIdentifier
2. Builder extracts package_portion
3. Base#to_s renders package
4. Test: `CSA B149.1:25 Code, Handbook & Training Package`

**Part B: M/F Prefix (25 min)**
1. Add metric boolean to SingleIdentifier
2. Builder sets metric when year_prefix="M"
3. Base#to_s renders M when metric=true
4. Test: `CSA C22.2 NO. 125-M1984 (R2004)`

**Expected:** 430-480/899 (48-53%)

---

### Session 159: Optional Prefix + Validation (60 min)

**Priority 4** - Low impact + Final validation

**Part A: Optional Prefix (20 min)**
1. Make publisher.maybe in parser
2. Identifier.parse normalizes missing prefix
3. Test edge cases

**Part B: Comprehensive Validation (40 min)**
1. Run full classification
2. Analyze remaining failures
3. Document patterns for future work
4. Update memory bank

**Expected:** 450-500/899 (50-55%+)

---

## Success Criteria

### Minimum Success (50%)
- ✅ Combined identifiers working (+200 IDs)
- ✅ Package support (+20 IDs)
- ✅ M/F prefix preserved (+10 IDs)
- ✅ CSA at 450+/899 (50%+)

### Target Success (60%)
- ✅ All 4 bugs fixed
- ✅ Comprehensive testing
- ✅ CSA at 540+/899 (60%+)
- ✅ Architecture remains MODEL-DRIVEN

### Stretch Success (70%+)
- ✅ Additional patterns identified and fixed
- ✅ CSA at 630+/899 (70%+)
- ✅ Ready for final push to 100%

---

## Architecture Principles

**NEVER compromise:**
1. **MODEL-DRIVEN** - Objects not strings
2. **MECE** - Clear semantic distinctions
3. **Semantic correctness** - `+` ≠ `/` distinction preserved
4. **Component pattern** - Reusable Lutaml::Model classes
5. **Round-trip fidelity** - Perfect preservation

**Session 156 proved:** Semantic correctness > Test pass rate

---

## Files to Create

1. `lib/pubid_new/csa/identifiers/combined.rb` - CombinedIdentifier class

## Files to Modify

1. `lib/pubid_new/csa/builder.rb` - Fix combined, add package/metric
2. `lib/pubid_new/csa/single_identifier.rb` - Add package, metric attributes
3. `lib/pubid_new/csa/identifiers/base.rb` - Render package, M prefix
4. `lib/pubid_new/csa/parser.rb` - Optional publisher (Session 159)

---

## Timeline Summary

| Session | Focus | Duration | Target |
|---------|-------|----------|--------|
| 157 | Combined identifiers | 90 min | 43-48% |
| 158 | Package + M/F prefix | 60 min | 48-53% |
| 159 | Optional prefix + validation | 60 min | 50-55%+ |
| **Total** | **All fixes** | **210 min** | **50-60%** |

---

## Key Reminders

1. **Bundled fix was correct** - Don't second-guess the architecture
2. **Pre-existing bugs exposed** - Not caused by Session 156
3. **Combined identifiers** - Biggest impact (200+ IDs)
4. **Test after each fix** - Incremental validation
5. **Document as you go** - Update memory bank

---

**Created:** 2025-12-17
**Sessions Covered:** 157-159
**Status:** Ready for execution
**Priority:** Fix combined identifiers first (highest impact)

**End Goal:** CSA at 50-60% with all pre-existing bugs fixed, semantic correctness preserved! 🚀