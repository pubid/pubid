# Session 152 Quick Start: CSA Enhancement & API Implementation

**Read First:** `docs/SESSION-152-CONTINUATION-PLAN.md` (comprehensive plan)

---

## Session 152 Goal: Enhance CSA to 50%+ (120 minutes)

### Context
Session 151 completed:
- **ASME:** 731/731 (100%) ✅
- **CSA:** 167/899 (18.7%) baseline created

**Current CSA stats:**
- Modern standards (CSA X): 167/369 (45.3%)
- Legacy standards (CAN/CSA-X): 0/480 (0%)
- Adopted (CSA ISO/IEC): 0/50 (0%)

---

## Quick Enhancement Steps

### Part A: Year Format Detection Fix (30 min)

**File:** `lib/pubid_new/csa/identifier.rb`

Detect dash vs colon before CAN/CSA- normalization:
```ruby
has_dash_year = input.match?(/-\d{2}\b/)
# ... normalize ...
# After build:
if result && has_dash_year
  result.year_format = "dash"
end
```

**Expected:** +280 CAN/CSA- identifiers

### Part B: ISO/IEC Adoption Pattern (30 min)

**File:** `lib/pubid_new/csa/parser.rb`

Add before single_identifier:
```ruby
rule(:iso_iec_adoption) do
  publisher >>
  str("ISO/IEC") >> space >>
  (str("TR") | str("TS")).as(:iso_type) >> space >>
  # ... pattern
end
```

**Expected:** +40-50 identifiers

### Part C: Testing (60 min)

```bash
ruby /tmp/test_csa_full.rb 2>&1 | grep -E "^✓" | wc -l
```

**Target:** 487+/899 (54%+)

---

## Architecture Reminder

**CSA Current:**
- Publisher: "CSA"
- Code: Letter + dotted numbers
- Year: Colon or dash format
- M prefix: Metric (older CAN/CSA- standards)
- F prefix: French edition

**Next:** Session 153 (API Implementation - 120 min)

---

Good luck enhancing CSA! 🚀