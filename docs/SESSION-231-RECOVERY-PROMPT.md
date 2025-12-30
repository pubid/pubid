# Session 231 Recovery Quick Start

**Read Full Plan:** [`docs/SESSION-231-CONTINUATION-PLAN.md`](SESSION-231-CONTINUATION-PLAN.md:1)

---

## Situation

Session 231 attempted NO. normalization but caused regressions:
- **Before:** 271/366 (73.8%)
- **After:** 207/366 (56.6%)
- **Regression:** -64 tests

**Root Cause:** Overly greedy code_pattern changes consumed year dashes

---

## Recovery Objective

Restore baseline while keeping NO. normalization benefits.

**Target:** 271/366 (73.8%) with NO. normalized

---

## Part A: Revert Greedy Parser Changes (15 min)

**File:** `lib/pubid_new/csa/parser.rb`

### 1. Fix dash_year rule (line ~51)

**Current (WRONG):**
```ruby
rule(:dash_year) do
  space.maybe >> dash >> year_prefix >> (year_4digit | year_2digit).as(:year) >> str("").as(:dash_format)
end
```

**Correct:**
```ruby
rule(:dash_year) do
  dash >> year_prefix >> (year_4digit | year_2digit).as(:year) >> str("").as(:dash_format)
end
```

### 2. Fix code_pattern Pattern 3 (lines ~30-42)

**Current (WRONG - too greedy):**
```ruby
# Pattern 3: Letter + numbers with intermixed dots and dashes
(letter >> match("[0-9]").repeat(1) >>
 ((dot | dash) >> match("[0-9]").repeat(1) >> letter.maybe).repeat >>
 letter.repeat(2, 6).maybe).as(:code)
```

**Correct (original):**
```ruby
# Pattern 3: Letter + numbers (original) - e.g., B149.1, C22.2, B149HB
(letter >> match("[0-9]").repeat(1) >>
 (dot >> match("[0-9]").repeat(1)).repeat >>
 (dash >> match("[0-9]").repeat(1) >> letter.maybe).repeat >>
 letter.repeat(2, 6).maybe).as(:code)
```

**Keep these (already correct):**
- ✅ NO. normalization preprocessing (lines ~270-274)
- ✅ NO. rules removed (good)
- ✅ Builder no_number handling removed (good)

---

## Part B: Update Test Expectations (40 min)

**Principle:** All NO. tests should expect normalized form.

### Files to Update

1. `spec/pubid_new/csa/identifiers/base_spec.rb`
2. `spec/pubid_new/csa/identifiers/bundled_spec.rb`
3. `spec/pubid_new/csa/identifiers/canadian_adopted_spec.rb`
4. `spec/pubid_new/csa/identifiers/series_spec.rb`

### Pattern to Apply

**For each NO. test:**

```ruby
# OLD (expects NO. preserved):
it "parses NO. number" do
  expect(parsed.no_number).to eq("286")
end

it "round-trips" do
  expect(parsed.to_s).to eq("CSA C22.2 NO. 286:23")
end

# NEW (expects normalization):
it "parses code (NO. normalized)" do
  expect(parsed.code.value).to eq("C22.2-286")
end

it "round-trips normalized" do
  expect(parsed.to_s).to eq("CSA C22.2-286:23")
end
```

**Remove tests for:**
- `no_number` attribute (no longer exists)
- "parses base code" expecting just "C22.2" (now includes full number)

**Update tests to expect:**
- Full code including NO. number: "C22.2-286"
- Normalized rendering: "CSA C22.2-286:23"

---

## Part C: Validation (5 min)

```bash
# Run full CSA suite
bundle exec rspec spec/pubid_new/csa/ --format progress

# Expected result:
# 271 examples, 0 failures (baseline recovered!)
```

---

## Success Criteria

- ✅ Baseline restored: 271/366 (73.8%)
- ✅ NO. tests passing with normalized form
- ✅ Zero regressions from Session 230
- ✅ Architecture clean (no compromises)

---

## If Tests Still Failing

**Common issues:**

1. **Parser still greedy?**
   - Check code_pattern has separate `(dot...)` and `(dash...)` sections
   - NOT combined `((dot | dash)...)`

2. **Year extracted incorrectly?**
   - Builder already handles "-NN" extraction (lines 188-203)
   - Check code doesn't end with "-NN" after extraction

3. **Test expectations wrong?**
   - NO. tests should expect code="C22.2-286", not "C22.2"
   - Round-trip should produce normalized form

---

## Next Steps

After recovery:
- Session 232: Implement Priority 5-7 patterns (+30 tests → 82%)
- Session 233: Polish and edge cases (+29 tests → 90%)

---

**Created:** 2025-12-30
**Session:** 231 Recovery
**Duration:** 60 minutes
**Target:** Restore 271/366 baseline with NO. normalized

**Ready to recover! 🚀**