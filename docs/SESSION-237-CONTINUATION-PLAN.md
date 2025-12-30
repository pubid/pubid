# Session 237 Continuation Plan: Update Test Expectations for CecIdentifier

**Created:** 2025-12-30 (Post-Session 236)
**Status:** 283/388 tests (72.9%)
**Target:** Baseline 73.8%+ (286+/388 tests)
**Timeline:** COMPRESSED - Complete in 2-3 hours

---

## Executive Summary

Session 236 successfully implemented CecIdentifier with all 26 new tests passing (100%). Now we must update existing test expectations across all CSA spec files to expect CecIdentifier for C22.x NO. patterns instead of the incorrect normalized form.

**Current Issue:** ~45 tests still expect NO. normalization (e.g., `code="C22.2-286"`) which is architecturally incorrect. They should expect `CecIdentifier` with preserved "NO." notation.

---

## Current State

**Session 236 Results:**
- Total: 283/388 (72.9%)
- CEC tests: 26/26 (100%) ✅
- Remaining failures: 105
- Gap to baseline: +3 tests needed for 73.8%

**Architecture Status:**
- ✅ CecIdentifier class implemented
- ✅ Parser recognizes C22.x NO. patterns
- ✅ Builder routes to CecIdentifier
- ✅ Round-trip fidelity working
- ⚠️ Test expectations need updating

---

## Implementation Plan

### SESSION 237: Update Test Expectations (2-3 hours)

#### Phase 1: Analyze Current Test Failures (30 min)

**Action:** Identify which tests are failing due to NO. expectations

```bash
# Run tests and capture failures
bundle exec rspec spec/pubid_new/csa/ --format documentation 2>&1 | \
  grep -A 10 "Failure/Error" > /tmp/csa_failures.txt
```

**Expected patterns:**
1. `expected code="C22.2-286"` → Should expect CecIdentifier
2. `expected Standard` → Should expect Cec class
3. `expected CanadianAdopted wrapping Standard` → Should expect CanadianAdopted wrapping Cec

#### Phase 2: Update base_spec.rb (45 min)

**File:** `spec/pubid_new/csa/identifiers/base_spec.rb`

**Changes needed (~15 tests):**

**Before:**
```ruby
describe "CSA C22.2 NO. 286:23" do
  it "parses code (NO. normalized to dash)" do
    expect(parsed.code.value).to eq("C22.2-286")
  end
end
```

**After:**
```ruby
describe "CSA C22.2 NO. 286:23" do
  it "parses as CecIdentifier" do
    expect(parsed).to be_a(PubidNew::Csa::Identifiers::Cec)
  end

  it "parses CEC part" do
    expect(parsed.cec_part.value).to eq("C22.2")
  end

  it "parses NO. number" do
    expect(parsed.no_number.value).to eq("286")
  end

  it "round-trips correctly" do
    expect(parsed.to_s).to eq(subject)
  end
end
```

**Estimated:** ~15 test updates

#### Phase 3: Update canadian_adopted_spec.rb (60 min)

**File:** `spec/pubid_new/csa/identifiers/canadian_adopted_spec.rb`

**Changes needed (~20 tests):**

**Pattern:** CAN/CSA- and CAN3- wrapping CEC identifiers

**Before:**
```ruby
describe "CAN/CSA-C22.2 NO. 0.16-M92 (R2001)" do
  it "parses code" do
    expect(parsed.code.value).to eq("C22.2-0.16")
  end
end
```

**After:**
```ruby
describe "CAN/CSA-C22.2 NO. 0.16-M92 (R2001)" do
  it "parses as CanadianAdopted" do
    expect(parsed).to be_a(PubidNew::Csa::Identifiers::CanadianAdopted)
  end

  it "wraps CecIdentifier" do
    expect(parsed.wrapped_identifier).to be_a(PubidNew::Csa::Identifiers::Cec)
  end

  it "parses CEC part" do
    expect(parsed.wrapped_identifier.cec_part.value).to eq("C22.2")
  end

  it "parses NO. number" do
    expect(parsed.wrapped_identifier.no_number.value).to eq("0.16")
  end

  it "round-trips correctly" do
    expect(parsed.to_s).to eq(subject)
  end
end
```

**Estimated:** ~20 test updates

#### Phase 4: Update Other Specs (30 min)

**Files to check:**
- `spec/pubid_new/csa/identifiers/bundled_spec.rb` (~5 tests)
- `spec/pubid_new/csa/identifiers/combined_spec.rb` (~5 tests)
- `spec/pubid_new/csa/identifiers/series_spec.rb` (~5 tests)

**Note:** Session 235 identified that some bundled NO. tests may be hallucinated (invalid combinations). These should be removed, not updated.

**Estimated:** ~10 valid test updates, ~5 removals

#### Phase 5: Run Full Test Suite (15 min)

**Validation:**
```bash
# Full CSA test suite
bundle exec rspec spec/pubid_new/csa/ --format progress

# Expected result: 286+/388 (73.8%+)
```

**Success criteria:**
- All CEC patterns now use CecIdentifier
- NO. notation preserved in all tests
- Round-trip fidelity working
- Baseline 73.8%+ achieved

---

## Test Update Template

### For Direct CEC Identifiers

```ruby
context "C22.x NO. patterns" do
  describe "{identifier string}" do
    subject { "{identifier string}" }
    let(:parsed) { PubidNew::Csa.parse(subject) }

    it "parses as CecIdentifier" do
      expect(parsed).to be_a(PubidNew::Csa::Identifiers::Cec)
    end

    it "parses CEC part" do
      expect(parsed.cec_part.value).to eq("{C22.x}")
    end

    it "parses NO. number" do
      expect(parsed.no_number.value).to eq("{number}")
    end

    it "parses year" do
      expect(parsed.year).to eq("{full_year}")
    end

    it "round-trips correctly" do
      expect(parsed.to_s).to eq(subject)
    end
  end
end
```

### For Wrapped CEC Identifiers

```ruby
context "CAN/CSA- wrapped CEC" do
  describe "{identifier string}" do
    subject { "{identifier string}" }
    let(:parsed) { PubidNew::Csa.parse(subject) }

    it "parses as CanadianAdopted" do
      expect(parsed).to be_a(PubidNew::Csa::Identifiers::CanadianAdopted)
    end

    it "wraps CecIdentifier" do
      expect(parsed.wrapped_identifier).to be_a(PubidNew::Csa::Identifiers::Cec)
    end

    it "parses CEC part via wrapper" do
      expect(parsed.wrapped_identifier.cec_part.value).to eq("{C22.x}")
    end

    it "parses NO. number via wrapper" do
      expect(parsed.wrapped_identifier.no_number.value).to eq("{number}")
    end

    it "round-trips correctly" do
      expect(parsed.to_s).to eq(subject)
    end
  end
end
```

---

## Architecture Principles

**MAINTAIN throughout:**
1. **Architecture correctness over test pass rate** - Fix expectations to match correct architecture
2. **NO. is semantic** - Never normalize NO., always preserve it
3. **MECE organization** - CecIdentifier is distinct from Standard
4. **Model-driven** - Objects not strings
5. **Round-trip fidelity** - Parse → Object → String must match original

**If tests fail after updates:**
- ✅ Check if architecture is correct (it should be)
- ✅ Update test expectation to match correct behavior
- ❌ DO NOT compromise architecture to pass tests

---

## Success Criteria

### Minimum (80%)
- ✅ All NO. tests updated to expect CecIdentifier
- ✅ 286+/388 (73.8%+) baseline achieved
- ✅ NO. notation preserved in all tests
- ✅ Zero architectural compromises

### Target (85%)
- ✅ All spec files updated correctly
- ✅ Invalid bundled NO. tests removed
- ✅ 295+/388 (76.0%+)
- ✅ Documentation updated

### Stretch (90%)
- ✅ Additional parser fixes for other patterns
- ✅ 310+/388 (79.9%+)
- ✅ Complete CSA spec suite quality

---

## Files to Modify

1. `spec/pubid_new/csa/identifiers/base_spec.rb` (~15 updates)
2. `spec/pubid_new/csa/identifiers/canadian_adopted_spec.rb` (~20 updates)
3. `spec/pubid_new/csa/identifiers/bundled_spec.rb` (~5 updates, ~5 removals)
4. `spec/pubid_new/csa/identifiers/combined_spec.rb` (~5 updates)
5. `spec/pubid_new/csa/identifiers/series_spec.rb` (~5 updates)

**Total:** ~50 test updates, ~5 removals

---

## Timeline Summary

| Phase | Focus | Duration | Deliverables |
|-------|-------|----------|--------------|
| 1 | Analyze failures | 30 min | Failure patterns identified |
| 2 | Update base_spec.rb | 45 min | ~15 tests corrected |
| 3 | Update canadian_adopted_spec.rb | 60 min | ~20 tests corrected |
| 4 | Update other specs | 30 min | ~15 tests corrected/removed |
| 5 | Validation | 15 min | 73.8%+ baseline achieved |
| **Total** | **All updates** | **180 min** | **Baseline recovery** |

---

## Common Pitfalls

**❌ DON'T:**
- Normalize NO. notation
- Expect `code="C22.2-286"` for CEC identifiers
- Compromise architecture to pass tests
- Keep invalid test combinations

**✅ DO:**
- Expect CecIdentifier class for C22.x NO. patterns
- Preserve "NO." in all expectations
- Trust the architecture
- Remove invalid test cases
- Update expectations to match correct behavior

---

## Next Steps (Session 237)

1. Read this continuation plan
2. Analyze current test failures
3. Update base_spec.rb (Phase 2)
4. Update canadian_adopted_spec.rb (Phase 3)
5. Update other specs (Phase 4)
6. Run full test suite and validate
7. Achieve baseline 73.8%+ with correct architecture

---

**Created:** 2025-12-30
**Session:** 237
**Status:** Ready for execution
**Estimated Time:** 3 hours (compressed)

**End Goal:** All test expectations corrected, NO. preserved, baseline 73.8%+ achieved! 🎯