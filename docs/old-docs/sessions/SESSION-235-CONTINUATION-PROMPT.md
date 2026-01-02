# Session 235 Quick Start: CSA Parser Enhancement for Baseline

**Read Full Plan:** [`docs/SESSION-235-CONTINUATION-PLAN.md`](SESSION-235-CONTINUATION-PLAN.md:1)

---

## Situation

Session 234 completed French F rendering pattern but discovered baseline gap requires parser work:
- **Current:** 257/362 (71.0%)
- **Baseline:** 267/362 (73.8%)
- **Gap:** +10 tests (parser failures, not rendering)

---

## Objective

Enhance parser to recognize failing patterns and reach 73.8%+ baseline.

**Strategy:** Fix high-impact parser patterns systematically

---

## High-Impact Patterns (Prioritized)

### Priority 1: CAN/CSA- with NO. (~30 tests)
```
CAN/CSA-C22.2 NO. 60079-11:14
CAN/CSA-C22.2 NO. 60601-1-9:15 (R2024)
```
**Issue:** Parser doesn't recognize CAN/CSA- prefix + NO. together
**Expected gain:** +25-30 tests → **77.9%+**

### Priority 2: Bundled/Combined with Prefix (~35 tests)
```
CAN/CSA-B127.1:99 + B127.2:99 (R2014)  # Bundled
CAN/CSA-B138.1-17/CAN/CSA-B138.2-17 (R2022)  # Combined
```
**Issue:** Returns Standard instead of Bundled/Combined
**Expected gain:** +30-35 tests → **86%+**

### Priority 3: NO. with Reaffirmation (~10 tests)
```
CSA C22.2 NO. 1-04 (R2009)
```
**Issue:** NO. normalization + reaffirmation combo fails
**Expected gain:** +8-10 tests → **88%+**

---

## Implementation Phases

### Phase 1: Fix CAN/CSA- NO. Parser (40 min)
**File:** `lib/pubid_new/csa/parser.rb`

Enhance SINGLE_IDENTIFIER rule to handle CAN/CSA- prefix before NO. patterns

### Phase 2: Fix Type Classification (30 min)
**File:** `lib/pubid_new/csa/builder.rb`

Detect bundled/combined BEFORE unwrapping CAN/CSA- prefix

### Phase 3: Fix NO. Reaffirmation (20 min)
**File:** `lib/pubid_new/csa/parser.rb`

Ensure reaffirmation_portion applies after all code patterns

---

## Test Command

```bash
bundle exec rspec spec/pubid_new/csa/ --format progress 2>&1 | grep "examples,"
```

---

## Success Criteria

- ✅ 267+/362 tests (73.8%+) - **Baseline reached**
- ✅ Parser-only changes (no identifier modifications)
- ✅ Clean architecture maintained

---

**Created:** 2025-12-30
**Session:** 235
**Duration:** 90-120 minutes

**Let's reach baseline with parser fixes! 🎯**