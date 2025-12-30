# Session 231+ Continuation Plan: CSA NO. Normalization Fix & Parser Enhancement

**Created:** 2025-12-30 (Post-Session 230 incomplete)
**Status:** NO. normalization attempted, regressions need fixing
**Timeline:** 2-3 sessions (3-4 hours) to recover and enhance

---

## Executive Summary

**Session 230 Achievement:** Implemented 3 high-impact patterns (+22 tests, 73.8%)

**Session 231 Attempt:** Implemented NO. normalization but caused regressions
- NO. tests: 12/12 passing ✅
- Overall: 207/366 (56.6%) - REGRESSED from 271/366 baseline
- Root cause: Overly greedy code_pattern consuming year dashes

**Current Status:**
- NO. normalization preprocessing: ✅ Working
- Parser code_pattern: ❌ Too greedy (intermixed dots/dashes)
- Builder year extraction: ✅ Already implemented
- Test expectations: ⚠️ Mix of old and new

**Recovery Strategy:**
1. Revert greedy code_pattern changes
2. Keep NO. normalization preprocessing
3. Rely on Builder year extraction (already working)
4. Update all test expectations consistently

---

## Session 231: Regression Fix (60 minutes)

### Objective
Recover from regressions while keeping NO. normalization benefits.

### Part A: Revert Problematic Parser Changes (15 min)

**Files to modify:**
- `lib/pubid_new/csa/parser.rb`

**Changes to revert:**
1. ❌ Remove `space.maybe` from dash_year rule (line ~51)
2. ❌ Revert code_pattern to original Pattern 3 (lines ~30-42)

**Original Pattern 3 (restore this):**
```ruby
# Pattern 3: Letter + numbers (original) - e.g., B149.1, C22.2, B149HB
(letter >> match("[0-9]").repeat(1) >>
 (dot >> match("[0-9]").repeat(1)).repeat >>
 (dash >> match("[0-9]").repeat(1) >> letter.maybe).repeat >>
 letter.repeat(2, 6).maybe).as(:code)
```

**Keep these changes:**
- ✅ NO. normalization in parse() method
- ✅ Removed no_keyword, no_number, no_portion rules
- ✅ Removed no_number handling in Builder

### Part B: Update Builder for Normalized Codes (20 min)

**File:** `lib/pubid_new/csa/builder.rb`

The Builder already has year extraction logic (lines 188-203). This will handle normalized codes like "C22.2-286" correctly:
- Code ending with `-NN` (2-digit) extracts year automatically
- Sets `year_format = "dash"`

**No changes needed** - existing logic will work!

### Part C: Update Test Expectations Consistently (20 min)

**Files to update:**
1. `spec/pubid_new/csa/identifiers/base_spec.rb`
2. `spec/pubid_new/csa/identifiers/bundled_spec.rb`
3. `spec/pubid_new/csa/identifiers/canadian_adopted_spec.rb`
4. `spec/pubid_new/csa/identifiers/series_spec.rb`

**Update pattern:**
All NO. tests should expect:
- Code includes full number: "C22.2-286" not "C22.2"
- No `no_number` attribute
- Round-trip produces normalized form (without "NO.")

**Example:**
```ruby
describe "CSA C22.2 NO. 286:23" do
  it "parses code (NO. normalized)" do
    expect(parsed.code.value).to eq("C22.2-286")
  end

  it "round-trips normalized" do
    expect(parsed.to_s).to eq("CSA C22.2-286:23")
  end
end
```

### Part D: Validation (5 min)

**Run tests:**
```bash
bundle exec rspec spec/pubid_new/csa/ --format progress
```

**Expected results:**
- Baseline recovery: 271/366 (73.8%)
- NO. tests: All passing with normalized form
- Zero regressions from original baseline

---

## Session 232: Complete Remaining Patterns (90 minutes)

### Objective
Implement remaining medium-impact patterns from Session 230 plan.

### Priority 4: COMPLETED ✅
Dash year separation already handled by Builder year extraction.

### Priority 5: Package Parser Patterns (40 min)

**Current problem:** Package patterns not parsing

**File:** `lib/pubid_new/csa/parser.rb`

**Enhancement needed:**
```ruby
rule(:package_portion) do
  space >>
  (
    # Full keyword chain with separators
    package_keyword >>
    (
      (comma >> space >> package_keyword) |
      (space >> ampersand >> space >> package_keyword)
    ).repeat
  ).as(:package_portion)
end
```

**Expected gain:** +20 tests (291/366, 79.4%)

### Priority 6: Combined/Bundled Routing (20 min)

**Verify:** Builder routing working for edge cases

**Test:**
```bash
bundle exec rspec spec/pubid_new/csa/identifiers/bundled_spec.rb
bundle exec rspec spec/pubid_new/csa/identifiers/combined_spec.rb
```

### Priority 7: French Rendering Fix (15 min)

**Current issue:** "CSA B149.1:F20" renders as "CSA B149.1:FF20"

**File:** Need to check identifier rendering logic

**Investigation:**
```bash
ruby -e "require './lib/pubid_new'; id = PubidNew::Csa.parse('CSA B149.1:F20'); puts id.to_s"
```

### Validation (15 min)

**Expected final:**
- Tests: 301/366 (82.2%)
- Improvement: +30 from baseline
- Session 230: +22, Session 232: +8

---

## Session 233: Round-Trip & Edge Cases (60 minutes)

### Objective
Polish rendering and handle edge cases for 90%+ target.

### Issues to Address

**1. CAN/CSA- with dash year (multiple failures)**
Pattern: "CAN/CSA-A123.1-05"
Issue: Parser failing to parse

**2. Letter suffix patterns**
Pattern: "CSA C22.1HB-18"
Issue: Parser changes broke HB suffix with dash year

**3. Year prefix rendering**
Pattern: ":F20" rendering as ":FF20"
Issue: Year prefix being doubled

### Expected Outcome
- Tests: 330/366 (90.2%)
- All core patterns working
- Clean architecture maintained

---

## Implementation Status Tracker

### Session 230 (COMPLETE) ✅
- [x] Dash year separation in code
- [x] CAN/CSA type routing
- [x] Package detection framework
- [x] Result: 271/366 (73.8%)

### Session 231 (INCOMPLETE - Regressions) ⚠️
- [x] NO. normalization preprocessing
- [x] Remove NO. parser rules
- [x] Remove NO. builder handling
- [x] Update NO. test expectations (partial)
- [❌] Code pattern changes (TOO GREEDY)
- [❌] dash_year space handling (CAUSED AMBIGUITY)
- Status: 207/366 (56.6%) - REGRESSED

### Session 231 Recovery (PENDING)
- [ ] Revert greedy code_pattern to original
- [ ] Revert dash_year space changes
- [ ] Update all NO. test expectations
- [ ] Validate baseline recovery
- Target: 271/366 (73.8%) restored

### Session 232 (PENDING)
- [ ] Package parser patterns
- [ ] Combined/Bundled verification
- [ ] French rendering fix
- Target: 301/366 (82.2%)

### Session 233 (PENDING)
- [ ] CAN/CSA- dash year fix
- [ ] HB suffix dash year fix
- [ ] Year prefix doubling fix
- Target: 330/366 (90.2%)

---

## Architecture Principles (NEVER COMPROMISE)

1. **NO. Normalization Strategy:**
   - ✅ Preprocessing normalization (clean input)
   - ✅ Builder year extraction (handle "-NN" pattern)
   - ❌ Parser special handling (avoid complexity)

2. **Code Pattern Matching:**
   - ✅ Keep patterns focused and specific
   - ❌ Avoid greedy patterns that consume years
   - ✅ Use Builder intelligence, not parser magic

3. **Test Expectations:**
   - ✅ Tests reflect actual behavior
   - ❌ Never lower standards to pass tests
   - ✅ Normalized form is correct form

---

## Key Learnings

**Session 231 Mistakes:**
1. ❌ Made code_pattern too greedy (intermixed dots/dashes)
2. ❌ Added ambiguity with space in dash_year
3. ❌ Didn't test incrementally after each change

**Recovery Approach:**
1. ✅ Revert parser to known-good state
2. ✅ Keep preprocessing simplification
3. ✅ Trust existing Builder intelligence
4. ✅ Test after each incremental change

---

## Files Modified

### Session 231 (to be partially reverted)
- `lib/pubid_new/csa/parser.rb` - NO. normalization ✅, code_pattern ❌, dash_year ❌
- `lib/pubid_new/csa/builder.rb` - Removed no_number ✅
- `spec/pubid_new/csa/identifiers/standard_spec.rb` - Updated NO. tests ✅

### Session 231 Recovery (planned)
- `lib/pubid_new/csa/parser.rb` - Revert code_pattern and dash_year
- `spec/pubid_new/csa/identifiers/base_spec.rb` - Update NO. tests
- `spec/pubid_new/csa/identifiers/bundled_spec.rb` - Update NO. tests
- `spec/pubid_new/csa/identifiers/canadian_adopted_spec.rb` - Update NO. tests
- `spec/pubid_new/csa/identifiers/series_spec.rb` - Update NO. tests

---

**Created:** 2025-12-30
**Sessions:** 231 Recovery, 232 Enhancement, 233 Polish
**Timeline:** 3 sessions, 3.5 hours
**Target:** 90%+ (330/366)
**Status:** Ready for recovery execution

**Architecture Quality:** MODEL-DRIVEN, MECE, Zero compromises ✅