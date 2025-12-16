# Session 148 Continuation Prompt

**Session:** 148
**Focus:** ASME BPVC + Multi-Char Designator Implementation
**Duration:** 150-180 minutes
**Prerequisites:** Session 147 analysis complete

---

## Objective

Implement BPVC subdivision parsing and multi-character designator recognition to achieve 77%+ ASME success rate (563+/731).

---

## Quick Start

### Step 1: Read Context (10 min)

**Read these files in order:**
1. `.kilocode/rules/memory-bank/context.md` - Session 147 completion
2. `docs/SESSION-148-CONTINUATION-PLAN.md` - Full implementation plan
3. `/tmp/asme_enhancement_roadmap.md` - Detailed grammar reference
4. `docs/old-docs/sessions/session-147-summary.md` - Analysis results

**Current state:**
- ASME: 395/731 (54.04%)
- BPVC failures: 150 (44% of failures)
- Multi-char failures: 188 (56% of failures)

---

## Step 2: Part A - BPVC Patterns (90-120 min)

**Target:** 525-535/731 (71.8-73.2%)

### Task 2A.1: Add Roman Numeral Rule (10 min)

**File:** `lib/pubid_new/asme/parser.rb`

Add after line 16:
```ruby
# Roman numerals (longest first!)
rule(:roman_numeral) do
  str("XIII") | str("XII") | str("XI") | str("VIII") |
  str("VII") | str("VI") | str("IV") | str("IX") |
  str("III") | str("II") | str("V") | str("I")
end
```

### Task 2A.2: Add BPVC Letter Code Rule (10 min)

Add after roman_numeral:
```ruby
# BPVC letter codes
rule(:bpvc_letter_code) do
  str("NCA") | str("NCD") | str("SSC") | str("BPV") | str("NUC") |
  str("NB") | str("NC") | str("ND") | str("NE") | str("NF") | str("NG") |
  letter
end
```

### Task 2A.3: Add BPVC Subdivision Rule (40 min)

**Critical:** This is the core BPVC parser. See detailed grammar in continuation plan.

Add complete `bpvc_subdivision` rule that handles:
- Dotted notation: `BPVC.I`, `BPVC.III.1.NB`
- Special: `BPVC COMPLETE CODE BIND`
- Dash notation: `BPVC-CC-BPV`
- Case codes: `BPVC.CC.BPV`

### Task 2A.4: Update Designator Rule (5 min)

**Replace current designator rule:**
```ruby
rule(:designator) do
  (
    bpvc_subdivision |  # NEW: Try BPVC first!
    str("ISO") |
    str("CSA") |
    str("API") |
    str("ANS") |
    letters
  ).as(:designator)
end
```

### Task 2A.5: Update Builder (30 min)

**File:** `lib/pubid_new/asme/builder.rb`

Update `build_code` method to handle `bpvc_code` in designator hash.

Build full BPVC string: `"BPVC.III.1.NB"` as designator, empty number.

### Task 2A.6: Test BPVC (20 min)

```bash
# Manual tests
ruby -e "require_relative 'lib/pubid_new'; puts PubidNew::Asme.parse('ASME BPVC.I-2021').to_s"
ruby -e "require_relative 'lib/pubid_new'; puts PubidNew::Asme.parse('ASME BPVC.III.1.NB-2021').to_s"

# Full classification
cd spec/fixtures && ruby run_classify.rb asme
```

**Expected:** 525-535/731 (71.8-73.2%)

---

## Step 3: Part B - Multi-Char Designators (40-60 min)

**Target:** 563-580/731 (77.0-79.3%)

### Task 2B.1: Add Multi-Char Code Rule (15 min)

**File:** `lib/pubid_new/asme/parser.rb`

Add before designator rule:
```ruby
rule(:multi_char_code) do
  str("PVHO") | str("PASE") | str("PTC") | str("PTB") | str("PDS") | str("PCC") |
  str("V&V") | str("TDP") | str("RTP") | str("RT") | str("RA") |
  str("QME") | str("QAI") | str("QEI") | str("NUM") | str("NQA") |
  str("OM") | str("HST") | str("CSD") | str("CA") | str("BTH") | str("BPE") | str("AG")
end
```

### Task 2B.2: Update Designator Rule (5 min)

```ruby
rule(:designator) do
  (
    bpvc_subdivision |
    multi_char_code |   # NEW: Before letters!
    str("ISO") |
    str("CSA") |
    str("API") |
    str("ANS") |
    letters
  ).as(:designator)
end
```

### Task 2B.3: Test Multi-Char (20 min)

```bash
# Manual tests
ruby -e "require_relative 'lib/pubid_new'; puts PubidNew::Asme.parse('ASME PTC-1-2022').to_s"
ruby -e "require_relative 'lib/pubid_new'; puts PubidNew::Asme.parse('ASME V&V-40-2018').to_s"

# Full classification
cd spec/fixtures && ruby run_classify.rb asme
```

**Expected:** 563-580/731 (77.0-79.3%)

---

## Step 4: Documentation (20 min)

1. Create `docs/old-docs/sessions/session-148-summary.md`
2. Document actual results (pass rate, improvement)
3. Note any edge cases for future work
4. Commit changes

---

## Success Criteria

**Minimum (70%):**
- ✅ BPVC basic patterns working
- ✅ 511+/731 passing

**Target (77%):**
- ✅ All BPVC variants working
- ✅ Multi-char codes working
- ✅ 563+/731 passing

**Stretch (80%+):**
- ✅ Edge cases addressed
- ✅ 585+/731 passing

---

## Critical Reminders

1. **Longest-match-first:** BPVC and multi_char MUST come before `letters` in designator rule
2. **Roman numeral ordering:** XIII before I (longest first)
3. **BPVC is special:** Full code becomes designator, number is empty
4. **Test incrementally:** After each part, run classification
5. **Architecture first:** If tests fail but architecture is correct, that's okay - fix tests, not architecture

---

## Test Command Reference

**Manual parse test:**
```bash
ruby -e "require_relative 'lib/pubid_new'; puts PubidNew::Asme.parse('ASME BPVC.III.1.NB-2021').to_s"
```

**Full classification:**
```bash
cd spec/fixtures && ruby run_classify.rb asme
```

**Check specific failures:**
```bash
cd spec/fixtures/asme/identifiers/fail && head -20 *.txt
```

---

## Files to Modify

**Session 148:**
- `lib/pubid_new/asme/parser.rb` - Add BPVC + multi-char rules
- `lib/pubid_new/asme/builder.rb` - Add BPVC handling in build_code

**Do NOT modify:**
- `lib/pubid_new/asme/components/code.rb` - Component API stable
- `lib/pubid_new/asme/identifiers/` - No identifier changes needed

---

**Created:** 2025-12-16
**Ready for:** Session 148 execution
**Estimated Time:** 2.5-3 hours
**Expected Result:** ASME at 77%+ (563+/731)

**Let's implement BPVC support and reach 77%!** 🚀