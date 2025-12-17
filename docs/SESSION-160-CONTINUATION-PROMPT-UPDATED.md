# Session 160+ Continuation Prompt: CSA Complete Architecture Redesign

**Read this FIRST:** [`docs/SESSION-160-CONTINUATION-PLAN-UPDATED.md`](SESSION-160-CONTINUATION-PLAN-UPDATED.md:1)

---

## Quick Context

**Sessions 160-167:** Complete CSA redesign to proper MODEL-DRIVEN architecture
**Timeline:** 12-15 hours compressed (7 sessions)
**Current:** Session 160 in progress - 60% complete

### Session 160 Status

**Completed ✅:**
- WrapperIdentifier base class created
- CanadianAdoptedIdentifier created
- CAN/ detection working
- Recursive parsing validated

**Current Issues 🔧:**
1. Format preservation: "CSA-" rendering as "CSA "
2. Reaffirmation duplication: (R2024) appearing twice
3. Need to test on 10+ CAN/ patterns

**Time Remaining:** ~30 minutes

---

## Immediate Tasks (Complete Session 160)

### 1. Fix Format Preservation (15 min)

**Problem:** `CAN/CSA-C22.2...` renders as `CAN/CSA C22.2...`

**Solution:** Track original prefix in wrapped identifier

**Files:**
- `lib/pubid_new/csa/identifier.rb` - Preserve CSA- vs CSA format
- `lib/pubid_new/csa/identifiers/canadian_adopted.rb` - Use preserved format

### 2. Fix Reaffirmation Duplication (10 min)

**Problem:** `CAN/CSA-Z662:23 (R2024)` renders as `...  (R2024) (R2024)`

**Solution:** Extract reaffirmation BEFORE recursive parse

**File:** `lib/pubid_new/csa/identifier.rb`

```ruby
# Extract reaffirmation first
reaffirm = input[/\(R(\d{4})\)/, 1]
wrapped_input = input.sub(/\s*\(R\d{4}\)/, "")
# Then parse wrapped_input
```

### 3. Test CAN/ Patterns (5 min)

Test these patterns:
```ruby
test_patterns = [
  "CAN/CSA-C22.2 NO. 60601-1-9:15",
  "CAN/CSA-Z662:23 (R2024)",
  "CAN/CSA-C22.2-05",
  "CAN/CSA-B149.1:25",
  # ... 6+ more
]
```

Verify:
- Correct type (CanadianAdopted)
- Perfect round-trip
- No duplication

---

## Next Session (161): CsaAdoptedIdentifier (90 min)

**Objective:** CSA adoptions of ISO/IEC/CISPR standards

**Create:** `lib/pubid_new/csa/identifiers/csa_adopted.rb`

**Pattern:** `CSA ISO/IEC TR 12785-3:15 (R2019)`

**Key Challenge:** Parse ISO/IEC portion with PubidNew::Iso parser

**Expected Gain:** +100-150 identifiers

---

## Architecture Principles (CRITICAL)

**NEVER compromise on:**
1. MODEL-DRIVEN - Objects not strings
2. Wrapper Pattern - Adoptions wrap identifiers
3. MECE - Mutually exclusive types
4. Recursive Parsing - Full object parsing
5. Semantic Correctness - Architecture > test count

**If tests fail, that's OKAY** - we're building correct architecture

---

## Quick Start Commands

```bash
# Test current implementation
cd /Users/mulgogi/src/mn/pubid
ruby -e "
require_relative 'lib/pubid_new/csa'
result = PubidNew::Csa::Identifier.parse('CAN/CSA-C22.2 NO. 60601-1-9:15')
puts result.class
puts result.to_s
"

# After fixes, run classification
cd spec/fixtures
ruby run_classify.rb csa
```

---

## Files Modified So Far

**Created:**
- `lib/pubid_new/csa/wrapper_identifier.rb`
- `lib/pubid_new/csa/identifiers/canadian_adopted.rb`

**Modified:**
- `lib/pubid_new/csa.rb`
- `lib/pubid_new/csa/identifier.rb`

**Next to Modify:**
- Fix format preservation
- Fix reaffirmation handling
- Then move to Session 161

---

**Total Progress:** Session 160: 60% → Target 100% then Session 161
**Estimated Time:** 30 min to complete Session 160
**Next:** CsaAdoptedIdentifier (Session 161, 90 min)

**GO!** 🚀