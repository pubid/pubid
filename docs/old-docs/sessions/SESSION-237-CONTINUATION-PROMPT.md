# Session 237 Quick Start: Update Test Expectations for CecIdentifier

**Read Full Plan:** [`docs/SESSION-237-CONTINUATION-PLAN.md`](SESSION-237-CONTINUATION-PLAN.md:1)

---

## Situation

Session 236 successfully implemented CecIdentifier with 26/26 tests passing (100%). However, ~45 existing tests still expect incorrect NO. normalization (e.g., `code="C22.2-286"`). These expectations must be updated to expect CecIdentifier with preserved "NO." notation.

**Current:** 283/388 (72.9%)
**Target:** 286+/388 (73.8%+) baseline with correct architecture

---

## Objective

Update test expectations across all CSA spec files to expect CecIdentifier for C22.x NO. patterns instead of normalized form.

**Strategy:** Systematic test expectation updates (not code changes - architecture is correct)

---

## Test Update Pattern

### Direct CEC Identifiers

**Before (WRONG):**
```ruby
describe "CSA C22.2 NO. 286:23" do
  it "parses code (NO. normalized)" do
    expect(parsed.code.value).to eq("C22.2-286")
  end
end
```

**After (CORRECT):**
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

### Wrapped CEC (CAN/CSA-, CAN3-)

**Before (WRONG):**
```ruby
describe "CAN/CSA-C22.2 NO. 0.16-M92" do
  it "parses code" do
    expect(parsed.code.value).to eq("C22.2-0.16")
  end
end
```

**After (CORRECT):**
```ruby
describe "CAN/CSA-C22.2 NO. 0.16-M92" do
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
end
```

---

## Implementation Phases

### Phase 1: Analyze Failures (30 min)

```bash
bundle exec rspec spec/pubid_new/csa/ --format documentation 2>&1 | \
  grep -A 10 "Failure/Error" > /tmp/csa_failures.txt
```

Identify which tests expect NO. normalization vs CecIdentifier.

### Phase 2: Update base_spec.rb (45 min)

**File:** `spec/pubid_new/csa/identifiers/base_spec.rb`

**Update ~15 tests** that expect NO. normalization to expect CecIdentifier.

### Phase 3: Update canadian_adopted_spec.rb (60 min)

**File:** `spec/pubid_new/csa/identifiers/canadian_adopted_spec.rb`

**Update ~20 tests** for CAN/CSA- and CAN3- wrapped CEC identifiers.

### Phase 4: Update Other Specs (30 min)

**Files:**
- `spec/pubid_new/csa/identifiers/bundled_spec.rb` (~5 updates, ~5 removals)
- `spec/pubid_new/csa/identifiers/combined_spec.rb` (~5 updates)
- `spec/pubid_new/csa/identifiers/series_spec.rb` (~5 updates)

**Note:** Remove invalid bundled NO. test combinations (hallucinated specs).

### Phase 5: Validation (15 min)

```bash
bundle exec rspec spec/pubid_new/csa/ --format progress 2>&1 | grep "examples,"
```

**Expected:** 286+/388 (73.8%+) baseline achieved

---

## Test Commands

```bash
# Run all CSA tests
bundle exec rspec spec/pubid_new/csa/ --format progress

# Run specific spec file
bundle exec rspec spec/pubid_new/csa/identifiers/base_spec.rb

# Run just CEC tests (should stay 100%)
bundle exec rspec spec/pubid_new/csa/identifiers/cec_spec.rb
```

---

## Critical Principles

1. **Architecture is correct** - CecIdentifier implementation is architecturally sound
2. **Tests need updating** - NOT the code
3. **NO. must be preserved** - Never normalize it
4. **Round-trip fidelity** - `parse(x).to_s == x` for all CEC patterns
5. **Remove invalid tests** - Don't update impossible combinations

---

## Success Criteria

- ✅ All NO. tests expect CecIdentifier (not normalized code)
- ✅ 286+/388 tests passing (73.8%+ baseline)
- ✅ "NO." preserved in all expectations
- ✅ Zero architectural compromises
- ✅ CEC tests remain 26/26 (100%)

---

## Files to Update

| File | Updates | Removals | Time |
|------|---------|----------|------|
| base_spec.rb | ~15 | 0 | 45 min |
| canadian_adopted_spec.rb | ~20 | 0 | 60 min |
| bundled_spec.rb | ~5 | ~5 | 15 min |
| combined_spec.rb | ~5 | 0 | 10 min |
| series_spec.rb | ~5 | 0 | 10 min |
| **Total** | **~50** | **~5** | **140 min** |

---

**Created:** 2025-12-30
**Session:** 237
**Duration:** ~3 hours (compressed)

**Let's update test expectations correctly! 🎯**