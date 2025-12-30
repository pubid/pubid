# Session 236 Quick Start: CecIdentifier Implementation

**Read Full Plan:** [`docs/SESSION-236-CONTINUATION-PLAN.md`](SESSION-236-CONTINUATION-PLAN.md:1)

---

## Situation

Session 235 discovered that CSA C22.{2,3,4,6} NO. identifiers need a dedicated `CecIdentifier` class (Canadian Electrical Code). Current test expectations that normalize "NO." are WRONG.

**Current:** 258/362 (71.3%)
**Target:** 267+/362 (73.8%+) with proper CecIdentifier

---

## Objective

Implement `CecIdentifier` for Canadian Electrical Code NO. patterns while preserving "NO." notation.

**Strategy:** Create new identifier type, update parser/builder, fix test expectations

---

## CecIdentifier Specification

**Pattern:** `CSA C22.{2,3,4,6} NO. {number}:{year}`

**Examples:**
```
CSA C22.2 NO. 286:23              # CecIdentifier
CSA C22.3 NO. 7:20                # CecIdentifier
CAN/CSA-C22.2 NO. 0.16-M92        # CanadianAdopted(CecIdentifier)
```

**Key Rule:** "NO." must be PRESERVED, not normalized!

---

## Implementation Phases

### Phase 1: Create CecIdentifier Class (60 min)

**File:** `lib/pubid_new/csa/identifiers/cec.rb`

**Components:**
- cec_part (C22.2, C22.3, etc.)
- no_number (number after NO.)
- year, year_format, year_prefix
- reaffirmation, french

**Rendering:** `CSA C22.2 NO. 286:23`

### Phase 2: Update Parser (45 min)

**File:** `lib/pubid_new/csa/parser.rb`

Add `cec_identifier` rule BEFORE `single_identifier`:
```ruby
rule(:cec_identifier) do
  publisher >>
  (str("C22.2") | str("C22.3") | str("C22.4") | str("C22.6")).as(:cec_part) >>
  no_notation >>
  no_number >>
  (colon_year | dash_year) >>
  reaffirmation.maybe
end
```

### Phase 3: Update Builder (15 min)

**File:** `lib/pubid_new/csa/builder.rb`

Add `build_cec` method and route cec_part patterns to CecIdentifier.

---

## Test Commands

```bash
# Test CEC implementation
bundle exec rspec spec/pubid_new/csa/identifiers/cec_spec.rb

# Full CSA test suite
bundle exec rspec spec/pubid_new/csa/ --format progress 2>&1 | grep "examples,"
```

---

## Success Criteria

- ✅ CecIdentifier class created (Lutaml::Model)
- ✅ Parser recognizes C22.x NO. patterns
- ✅ Builder routes to CecIdentifier
- ✅ 15+ new CEC tests passing
- ✅ "NO." preserved in rendering

---

**Created:** 2025-12-30
**Session:** 236
**Duration:** ~120 minutes

**Let's implement CecIdentifier properly! 🎯**