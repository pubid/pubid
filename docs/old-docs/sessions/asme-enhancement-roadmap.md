# ASME Parser Enhancement Roadmap

## Session 147 Analysis Complete

**Current Status:**
- Total: 731 identifiers  
- Passing: 395 (54.04%)
- Failing: 336 (45.96%)

**Improvement from Session 146:** +11 identifiers (+1.22pp)
- Session 146: 384/727 (52.82%)
- Session 147: 395/731 (54.04%)
- Fixtures updated removed duplicate "ASME ASME" patterns

---

## Priority 1: BPVC Complex Patterns (150 identifiers, 44% of failures)

### Pattern Categories Identified

**A. BPVC Dotted Subdivision (130+ identifiers)**

Examples:
```
ASME BPVC.I-2021                    # Roman numeral only
ASME BPVC.II.A-2021                 # Roman + letter
ASME BPVC.III.1.NB-2021             # Roman + digit + letter code
ASME BPVC.III.5-2021                # Roman + digit
ASME BPVC.VIII.1-2021               # Roman + digit
ASME BPVC.XI.2-2021                 # Roman + digit
ASME BPVC.CC.BPV-2021               # Special: CC = Case Code
ASME BPVC.CC.NC.XI-2019             # Case Code + letter code + roman
```

**Pattern Structure:**
```
BPVC . {roman} [. {digit|letter|letter_code}] [. {letter_code}] - YYYY
     ^        ^                                ^
     |        |                                |
   Always  Optional subdivisions        Optional sub-sub-division
```

**Roman Numerals:** I, II, III, IV, V, VI, VII, VIII, IX, X, XI, XII, XIII
**Letter Codes:** A, B, C, D, M (for sections) / NB, NC, ND, NE, NF, NG, NCA, NCD (for nuclear codes) / BPV (boiler/pressure vessel) / SSC (stainless steel cladding)

**B. BPVC Special Variants (6 identifiers)**

```
ASME BPVC COMPLETE CODE BIND-2019
ASME BPVC COMPLETE CODE BIND-2021
ASME BPVC COMPLETE CODE BIND-2023
```

**C. BPVC Dash Notation (14 identifiers)**

```
ASME BPVC-CC-BPV-2019               # Dashes instead of dots
ASME BPVC-CC-NUC-2019
```

### Current Parser Limitation

**Problem:**  
Lines 22-31 of parser.rb define `designator` as:
```ruby
rule(:designator) do
  (str("BPVC") | str("ISO") | ... | letters).as(:designator)
end
```

This consumes "BPVC" entirely as designator, leaving ".I-2021" as unparseable.

**Solution Strategy:**

1. **Create BPVC-specific rule** that captures the full BPVC code including subdivisions
2. **Update designator rule** to try BPVC patterns FIRST (longest match first principle)
3. **Handle special variants** (COMPLETE CODE BIND) as edge cases

### Parser Changes Needed

```ruby
# Add roman numeral rule
rule(:roman_numeral) do
  str("XIII") | str("XII") | str("XI") | str("VIII") | 
  str("VII") | str("VI") | str("IV") | str("IX") | 
  str("III") | str("II") | str("V") | str("I")   # Order matters!
end

# Add BPVC special code patterns
rule(:bpvc_letter_code) do
  str("NCA") | str("NCD") | str("SSC") | str("BPV") |
  str("NB") | str("NC") | str("ND") | str("NE") | str("NF") | str("NG") |
  letter  # Single letter for A, B, C, D, M
end

# BPVC complete subdivision
rule(:bpvc_subdivision) do
  str("BPVC") >> 
  (
    # Special: COMPLETE CODE BIND
    (space >> str("COMPLETE CODE BIND")).as(:special) |
    # Standard dotted notation
    (
      dot >> 
      (
        # CC = Case Code
        (str("CC") >> dot >> bpvc_letter_code.as(:case_code) >> 
         (dot >> (roman_numeral | bpvc_letter_code)).maybe.as(:case_sub)) |
        # Standard roman numeral subdivision
        (roman_numeral.as(:section) >> 
         (dot >> (digits | bpvc_letter_code).as(:subsection)).maybe >>
         (dot >> bpvc_letter_code.as(:sub_subsection)).maybe)
      )
    ).as(:subdivision)
  ).as(:bpvc_code)
end

# Also handle dash notation variant (BPVC-CC-BPV)
rule(:bpvc_dash_notation) do
  str("BPVC") >> dash >> str("CC") >> dash >> 
  bpvc_letter_code.as(:case_code)
end

# Update designator to try BPVC patterns first
rule(:designator) do
  (
    bpvc_subdivision |
    bpvc_dash_notation |
    str("ISO") |
    str("CSA") |
    str("API") |
    str("ANS") |
    letters   # Fallback
  ).as(:designator)
end
```

**Builder Changes:**

In `build_code` method, when designator contains bpvc_code:
- Use full BPVC subdivision as designator
- Number becomes empty or subdivision details
- BPVC identifiers don't follow standard designator+number pattern

**Complexity:** Medium-High  
**Estimated Gain:** +130-140 identifiers  
**New Pass Rate:** 525-535/731 (71.8-73.2%)

---

## Priority 2: Multi-Character Designators (188 identifiers, 56% of failures)

### Pattern Analysis

**Distribution:**
- PTC (30) - Performance Test Code
- PVHO (10) - Pressure Vessels for Human Occupancy
- PCC (10) - Post-Construction Code
- RA (6), QME (6), NQA (6), CSD (6), BTH (6), BPE (6)
- And 20+ other codes (4 or fewer each)

**Examples:**
```
ASME PTC-1-2022                    # Performance Test Code
ASME PVHO-1-2019                   # Pressure Vessels Human Occupancy
ASME PCC-1-2022                    # Post-Construction Code
ASME NQA-1-2024                    # Nuclear Quality Assurance
ASME OM-2022                       # Operation & Maintenance
ASME V&V-40-2018                   # Verification & Validation
```

### Current Parser Limitation

**Problem:**  
Line 29: `letters` matches ANY sequence of capital letters, but then line 38 tries to match `match("[0-9A-Z]").repeat(1)` as number, conflicts arise with dash.

**Solution:**

Add explicit multi-character designator codes to the designator rule, BEFORE the generic `letters` fallback.

### Parser Changes Needed

```ruby
# Add multi-char designator rule
rule(:multi_char_code) do
  str("PVHO") | str("PCC") | str("PTC") | str("PTB") | str("PDS") |
  str("PASE") | str("NQA") | str("NUM") | str("QME") | str("QAI") | str("QEI") |
  str("V&V") | str("CSD") | str("BTH") | str("BPE") | str("HST") | str("TDP") |
  str("RTP") | str("RA") | str("RT") | str("OM") | str("CA") | str("AG")
end

# Update designator rule (add multi_char_code before letters)
rule(:designator) do
  (
    bpvc_subdivision |
    bpvc_dash_notation |
    multi_char_code |   # NEW: Try multi-char codes before single letters
    str("ISO") |
    str("CSA") |
    str("API") |
    str("ANS") |
    letters   # Fallback for single-letter designators
  ).as(:designator)
end
```

**Builder Changes:**
- Minimal - just handle multi-char designators same as single-letter ones
- Code component already supports any string designator

**Complexity:** Low  
**Estimated Gain:** +38-45 identifiers (~20-25% of multi-char, as some may have other issues)  
**New Pass Rate:** After Priority 1+2 = 563-580/731 (77.0-79.3%)

---

## Priority 3: Remaining Edge Cases (TBD)

After implementing Priority 1 & 2, re-classify to see what remains.

Likely candidates:
- Complex revision notes
- Unusual CSA patterns
- API patterns (API 579-2/ASME, etc.)
- Draft year edge cases

**Strategy:** Analyze failures after P1+P2 implementation

---

## Implementation Plan

### Session 148 Part 1: BPVC Patterns (90-120 min)

**Tasks:**
1. Add roman_numeral rule (10 min)
2. Add bpvc_letter_code rule (5 min)
3. Add bpvc_subdivision rule (30 min)
4. Add bpvc_dash_notation rule (10 min)
5. Update designator rule (5 min)
6. Update builder for BPVC codes (30 min)
7. Test and validate (20 min)

**Expected:** 525-535/731 (71.8-73.2%)

### Session 148 Part 2: Multi-Character Designators (40-60 min)

**Tasks:**
1. Add multi_char_code rule (15 min)
2. Update designator rule (5 min)
3. Test and validate (20 min)

**Expected:** 563-580/731 (77.0-79.3%)

### Session 148 Part 3 (Optional): Edge Case Analysis (30 min)

Re-classify and analyze remaining ~150 failures.

### Session 149: Documentation (60 min)

Update memory bank, create session summary, archive docs.

---

## Realistic Final Target

**Conservative:** 70-75% (511-548/731)  
**Realistic:** 75-79% (548-577/731)  
**Optimistic:** 79-82% (577-599/731) with edge case fixes

---

## Success Criteria

**Minimum (70%):**
- BPVC basic patterns working (+100 IDs)
- Multi-char designators working (+20 IDs)
- 511+/731 passing

**Target (77%):**
- All BPVC variants working (+130 IDs)
- Most multi-char designators working (+38 IDs)
- 563+/731 passing

**Stretch (80%+):**
- All identified patterns working
- Edge cases addressed
- 585+/731 passing

---

## Key Architectural Principles

**MAINTAIN:**
- MODEL-DRIVEN architecture (no changes)
- Component API stability (Code component unchanged)
- Parser-only enhancements (minimal Builder changes)
- MECE organization
- Round-trip fidelity

**NO architecture changes required** - all fixes are parser pattern enhancements.

---

**Analysis Complete:** Session 147  
**Ready for:** Session 148 implementation  
**Estimated Duration:** 2.5-3 hours for 77%+ success rate
