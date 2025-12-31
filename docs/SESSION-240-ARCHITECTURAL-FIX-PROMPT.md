# Session 240 Quick Start: CRITICAL - Fix CCSDS, ETSI, PLATEAU MECE Violations

**Read Full Plan:** [`docs/SESSION-240-ARCHITECTURAL-FIX-PLAN.md`](SESSION-240-ARCHITECTURAL-FIX-PLAN.md)

---

## CRITICAL ISSUE DISCOVERED

**Session 239 specs exposed architectural violations in V2 implementations:**

❌ **CCSDS:** Corrigenda as attribute (should be separate Corrigendum class)
❌ **ETSI:** Amendments/Corrigenda as attributes (should be separate classes)
❌ **PLATEAU:** Type as attribute (should be Handbook/TechnicalReport classes)

**ALL VIOLATE MECE PRINCIPLES** - Each identifier type must be a separate class!

---

## Objective

Execute **Session 240: CCSDS Architectural Fix** (2 hours)

Implement proper Corrigendum class following ISO/IEC reference pattern.

---

## Reference Implementation (STUDY FIRST)

**Read these ISO supplement implementations:**
1. `lib/pubid_new/iso/supplement_identifier.rb` - Base pattern
2. `lib/pubid_new/iso/identifiers/corrigendum.rb` - Corrigendum example
3. `lib/pubid_new/iso/identifiers/amendment.rb` - Amendment example

**Key pattern:**
```ruby
class Corrigendum < SupplementIdentifier
  attribute :base_identifier, Base  # ✅ Recursive
  attribute :number, :integer

  def to_s
    "#{base_identifier} Cor. #{number}"
  end
end
```

---

## Execution Plan

### Part A: Read Reference Implementations (20 min)

**Files to read:**
1. `lib/pubid_new/iso/supplement_identifier.rb`
2. `lib/pubid_new/iso/identifiers/corrigendum.rb`
3. `lib/pubid_new/iso/builder.rb` (how to build supplements)
4. `lib/pubid_new/iso/parser.rb` (how to parse supplements)

### Part B: Implement CCSDS Corrigendum (60 min)

**1. Create SupplementIdentifier base (if missing)**

File: `lib/pubid_new/ccsds/supplement_identifier.rb`

**2. Create Corrigendum class**

File: `lib/pubid_new/ccsds/identifiers/corrigendum.rb`

Pattern: Extend SupplementIdentifier, add `base_identifier` and `number`

**3. Remove corrigenda attribute from Base**

File: `lib/pubid_new/ccsds/identifiers/base.rb`

Remove `attribute :corrigenda` and related rendering logic.

### Part C: Update Parser (30 min)

File: `lib/pubid_new/ccsds/parser.rb`

Separate:
- `base_identifier` rule
- `corrigendum_identifier` rule
- Route correctly

### Part D: Update Builder (30 min)

File: `lib/pubid_new/ccsds/builder.rb`

Implement recursive construction:
- Detect corrigendum pattern
- Build base identifier first
- Wrap in Corrigendum with base_identifier

### Part E: Fix Specs (20 min)

File: `spec/pubid_new/ccsds/identifier_spec.rb`

Update expectations:
- Corrigendum tests expect `Identifiers::Corrigendum` class
- Verify `base_identifier` attribute
- Test recursive structure

---

## Success Criteria

- ✅ CCSDS Corrigendum is separate class
- ✅ Extends SupplementIdentifier
- ✅ Has `base_identifier` attribute
- ✅ Recursive parsing works
- ✅ All tests passing
- ✅ MECE principles validated

---

## Architecture Correctness > Test Count

**CRITICAL REMINDER:**

If tests fail after architectural fix, **DO NOT** revert to wrong architecture!

Instead:
1. Update test expectations to match correct architecture
2. Fix parser/builder if needed
3. Trust the MECE principles

**Test failures mean tests are wrong, not architecture.**

---

## After Session 240

**Session 241:** CCSDS validation and testing
**Sessions 242-243:** ETSI architectural fix
**Sessions 244-245:** PLATEAU architectural fix
**Sessions 246-247:** JIS/NIST review

---

**Created:** 2025-12-31
**Session:** 240
**Duration:** 2 hours
**Priority:** CRITICAL

**Fix CCSDS MECE violation - Architecture correctness is paramount! 🎯**