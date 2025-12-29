# Session 226 Quick Start: CSA Core Identifier Specs

**Read Plan First:** [`docs/SESSION-226-COMPLETE-SPECS-PLAN.md`](SESSION-226-COMPLETE-SPECS-PLAN.md:1)

---

## Pre-Session Checklist

✅ Read comprehensive plan (SESSION-226-COMPLETE-SPECS-PLAN.md)
✅ Read missing specs report (MISSING_SPECS_REPORT.md)
✅ Read architecture principles (.kilocode/rules/memory-bank/architecture.md)

---

## Session 226 Objective

Create 4 core CSA identifier spec files (~100 tests total) in 120 minutes.

**Phase:** 1 of 10 (CSA Complete Coverage)
**Session:** 226 of 260 (Complete Specs Implementation)

---

## Files to Read (5 minutes)

1. `lib/pubid_new/csa/identifiers/standard.rb`
2. `lib/pubid_new/csa/identifiers/series.rb`
3. `lib/pubid_new/csa/identifiers/bundled.rb`
4. `lib/pubid_new/csa/identifiers/combined.rb`
5. `lib/pubid_new/csa/single_identifier.rb`

**Fixture examples:**
- `spec/fixtures/csa/identifiers/pass/standard.txt`
- `spec/fixtures/csa/identifiers/full/identifiers.txt`

---

## Part A: standard_spec.rb (30 min, ~25-30 tests)

**Create:** `spec/pubid_new/csa/identifiers/standard_spec.rb`

**Test coverage:**
- Basic standards (CSA B149.1:20)
- Year formats (colon vs dash preservation)
- HB suffix (CSA C22.1HB-18, 15189HB:25)
- 2-digit year conversion (:25 → 2025)
- NO. notation (CSA C22.2 NO. 286:23)
- Round-trip fidelity

**Template:**
```ruby
require "spec_helper"

RSpec.describe PubidNew::Csa::Identifiers::Standard do
  context "basic standards" do
    describe "CSA B149.1:20" do
      subject { "CSA B149.1:20" }
      let(:parsed) { PubidNew::Csa.parse(subject) }

      it "parses as Standard" do
        expect(parsed).to be_a(described_class)
      end

      it "parses code" do
        expect(parsed.code.value).to eq("B149.1")
      end

      it "parses year" do
        expect(parsed.year).to eq("2020")
      end

      it "uses colon format" do
        expect(parsed.year_format).to eq("colon")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end

  context "HB suffix patterns" do
    # NEW Session 225 fix - pure numeric with HB
    describe "15189HB:25" do
      # ...tests...
    end
  end
end
```

---

## Part B: series_spec.rb (25 min, ~20 tests)

**Create:** `spec/pubid_new/csa/identifiers/series_spec.rb`

**Test coverage:**
- Series format (CSA A23.1-09/A23.2-09, CSA S-S6)
- Multiple formats
- Round-trip rendering

---

## Part C: bundled_spec.rb (30 min, ~25 tests)

**Create:** `spec/pubid_new/csa/identifiers/bundled_spec.rb`

**Test coverage:**
- Comma-separated bundles
- Multiple identifiers
- Year format preservation
- Round-trip rendering

---

##<br Part D: combined_spec.rb (35 min, ~30 tests)

**Create:** `spec/pubid_new/csa/identifiers/combined_spec.rb`

**Test coverage:**
- Plus notation (CSA A23.1-09+A23.2-09)
- Multiple combined identifiers
- Year format preservation
- Complex combinations
- Round-trip rendering

---

## Testing Commands

```bash
# After each spec file
bundle exec rspec spec/pubid_new/csa/identifiers/standard_spec.rb

# Full CSA suite
bundle exec rspec spec/pubid_new/csa/

# Show summary
bundle exec rspec spec/pubid_new/csa/ --format documentation
```

---

## Expected Progress

- After Part A: ~25 tests (Standard)
- After Part B: ~45 tests (Standard + Series)
- After Part C: ~70 tests (Standard + Series + Bundled)
- After Part D: ~100 tests (All 4 core types)

**Target pass rate:** 80-90%

---

## Critical CSA Patterns

### Year Formats (MUST preserve)
```
Colon: CSA B149.1:20   # Modern
Dash:  CSA C22.1-15    # Legacy
```

### HB Suffix (Session 225 fix)
```
CSA C22.1HB-18         # Letter + HB
CSA 15189HB:25         # NEW: Pure number + HB
B651HB-18              # No CSA prefix
```

### 2-Digit Year
```
Input: :25  → Output: :25 (Store: 2025)
Input: -18  → Output: -18 (Store: 2018)
```

---

## Architecture Principles

- ✅ MODEL-DRIVEN: Test real behavior
- ✅ No mocking/stubbing
- ✅ Round-trip validation
- ✅ Fixture-based examples
- ✅ One spec per class

---

## Next Session

**Session 227:** CSA Adopted Specs (3 files, 70 tests, 90 min)

---

**Created:** 2025-12-29
**Timeline:** 120 minutes
**Phase:** 1/10 (CSA Core)
**Overall:** Session 226/260

**Ready to start!** 🚀
