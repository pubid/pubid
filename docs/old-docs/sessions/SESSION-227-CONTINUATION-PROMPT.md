# Session 227 Quick Start: CSA Adopted Identifier Specs

**Read Plan First:** [`docs/SESSION-227-CONTINUATION-PLAN.md`](SESSION-227-CONTINUATION-PLAN.md:1)

---

## Pre-Session Checklist

✅ Read comprehensive plan (SESSION-227-CONTINUATION-PLAN.md)
✅ Read Session 226 results (4 core specs created, 213 tests, 74% pass)
✅ Review CSA identifier implementations

---

## Session 227 Objective

Create 3 adopted CSA identifier spec files (~70 tests total) in 90 minutes.

**Phase:** 2 of 3 (CSA Adopted Coverage)
**Session:** 227 of 260 (Complete Specs Implementation)

---

## Files to Read (5 minutes)

1. `lib/pubid_new/csa/identifiers/base.rb`
2. `lib/pubid_new/csa/identifiers/canadian_adopted.rb`
3. `lib/pubid_new/csa/identifiers/csa_adopted.rb`

**Fixture examples:**
- `spec/fixtures/csa/identifiers/full/identifiers.txt` (lines 221-965)

---

## Part A: base_spec.rb (30 min, ~25 tests)

**Create:** `spec/pubid_new/csa/identifiers/base_spec.rb`

**Test coverage:**
- Publisher variants (CSA, CAN/CSA-, CAN3-)
- Code handling
- Year formats (colon vs dash)
- 2-digit year conversion
- NO. notation
- Reaffirmation patterns
- Round-trip validation

**Template:**
```ruby
require "spec_helper"

RSpec.describe PubidNew::Csa::Identifiers::Base do
  describe ".parse" do
    context "publisher variants" do
      describe "CSA B149.1:20" do
        subject { "CSA B149.1:20" }
        let(:parsed) { PubidNew::Csa.parse(subject) }

        it "parses as Base or subclass" do
          expect(parsed).to be_a(PubidNew::Csa::SingleIdentifier)
        end

        it "parses code" do
          expect(parsed.code.value).to eq("B149.1")
        end

        # ...more tests...
      end
    end
  end
end
```

---

## Part B: canadian_adopted_spec.rb (30 min, ~20 tests)

**Create:** `spec/pubid_new/csa/identifiers/canadian_adopted_spec.rb`

**Test coverage:**
- CAN/CSA- prefix patterns
- CAN3- legacy prefix patterns
- SERIES with Canadian prefix
- NO. notation with Canadian prefix
- Reaffirmation handling
- Round-trip preservation

**Key patterns:**
```
CAN/CSA-A123.2-03 (R2023)
CAN/CSA-A220 SERIES-06 (R2021)
CAN3-A451.1-M86 (R2001)
```

---

## Part C: csa_adopted_spec.rb (30 min, ~25 tests)

**Create:** `spec/pubid_new/csa/identifiers/csa_adopted_spec.rb`

**Test coverage:**
- CSA ISO/IEC patterns
- CSA IEC patterns
- CSA ISO patterns
- Amendment notation (/A1, /A2)
- Technical Reports (TR)
- Reaffirmation with adopted
- Round-trip validation

**Key patterns:**
```
CSA ISO/IEC 8824-1:22
CSA ISO/IEC 9594-2:21/A1:22
CSA ISO/IEC TR 19758:04 (R2024)
CAN/CSA-ISO 10012:03 (R2023)
```

---

## Testing Commands

```bash
# After each spec file
bundle exec rspec spec/pubid_new/csa/identifiers/base_spec.rb
bundle exec rspec spec/pubid_new/csa/identifiers/canadian_adopted_spec.rb
bundle exec rspec spec/pubid_new/csa/identifiers/csa_adopted_spec.rb

# Full CSA suite
bundle exec rspec spec/pubid_new/csa/

# Show summary
bundle exec rspec spec/pubid_new/csa/ --format documentation
```

---

## Expected Progress

- After Part A: ~25 tests (Base)
- After Part B: ~45 tests (Base + CanadianAdopted)
- After Part C: ~70 tests (All 3 adopted types)

**Target pass rate:** 70-80% (parser limitations expected)

---

## Critical CSA Patterns

### Publisher Prefixes
```
CSA             # Standard
CAN/CSA-        # Canadian adopted (dash required)
CAN3-           # Legacy Canadian (dash required)
```

### Year Format Preservation
```
:25  → :25 (Store as 2025)
-18  → -18 (Store as 2018)
```

### NO. Notation
```
CSA C22.2 NO. 286:23
CAN/CSA-C22.2 NO. 60601-1:14
```

### Adopted Format
```
CSA ISO/IEC 8824-1:22
CAN/CSA-ISO 10012:03 (R2023)
```

---

## Architecture Principles

- ✅ MODEL-DRIVEN: Test real behavior
- ✅ No mocking/stubbing
- ✅ Round-trip validation
- ✅ Fixture-based examples
- ✅ One spec per class

---

## Known Parser Limitations (Acceptable)

From Session 226:
- Series parsed as Standard (not architecture issue)
- Dash year in code value (parser normalization)
- CAN/CSA returns CanadianAdopted type
- French boolean might not be set

**Note:** These are PARSER issues, not SPEC issues. Write specs correctly per architecture.

---

## Next Session

**Session 228:** CSA Package + Components (2 files, 25 tests, 30 min)

---

**Created:** 2025-12-29
**Timeline:** 90 minutes
**Phase:** 2/3 (CSA Adopted)
**Overall:** Session 227/260

**Ready to start!** 🚀