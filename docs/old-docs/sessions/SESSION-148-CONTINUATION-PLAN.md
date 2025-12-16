# Session 148+ Continuation Plan: ASME Parser Enhancement Implementation

**Created:** 2025-12-16 (Post-Session 147)
**Status:** Session 147 analysis complete - Ready for implementation
**Timeline:** COMPRESSED - Complete in 2-3 sessions (4-6 hours total)

---

## Executive Summary

**Session 147 Achievement:** Comprehensive failure analysis complete with enhancement roadmap

**Current Status:**
- **ASME:** 395/731 (54.04%)
- **Analysis:** 336 failures categorized into 2 major patterns
- **Roadmap:** Complete parser grammar designed
- **Ready for:** Implementation

**Remaining Work:**
- Session 148: BPVC patterns + Multi-char designators (2.5-3 hours)
- Session 149: Documentation updates (1 hour)

**Target:** 77%+ (563+/731) - Conservative estimate

---

## SESSION 148: Parser Enhancement Implementation (150-180 min)

### Objective
Implement BPVC subdivision parsing and multi-character designator recognition to reach 77%+ success rate.

### Part A: BPVC Pattern Implementation (90-120 min)

**Objective:** Add BPVC subdivision parsing for `BPVC.I`, `BPVC.III.1.NB`, `BPVC.CC.BPV` patterns

**Expected Gain:** +130-140 identifiers (71.8-73.2%)

#### Task 1: Add Roman Numeral Rule (10 min)

**File:** `lib/pubid_new/asme/parser.rb`

**Add after line 16 (after letters rule):**
```ruby
# Roman numerals (longest first for proper matching)
rule(:roman_numeral) do
  str("XIII") | str("XII") | str("XI") | str("VIII") |
  str("VII") | str("VI") | str("IV") | str("IX") |
  str("III") | str("II") | str("V") | str("I")
end
```

**Testing:** Try parsing "XIII", "VIII", "III", "I" individually

#### Task 2: Add BPVC Letter Code Rule (10 min)

**Add after roman_numeral:**
```ruby
# BPVC special letter codes
rule(:bpvc_letter_code) do
  str("NCA") | str("NCD") | str("SSC") | str("BPV") | str("NUC") |
  str("NB") | str("NC") | str("ND") | str("NE") | str("NF") | str("NG") |
  letter  # Single letter for A, B, C, D, M
end
```

**Testing:** Try "NCA", "NB", "A", "M"

#### Task 3: Add BPVC Subdivision Rule (40 min)

**Add after bpvc_letter_code:**
```ruby
# BPVC complete subdivision
rule(:bpvc_subdivision) do
  str("BPVC") >>
  (
    # Special: COMPLETE CODE BIND
    (space >> str("COMPLETE CODE BIND")).as(:special) |
    # Dash notation: BPVC-CC-BPV
    (dash >> str("CC") >> dash >> bpvc_letter_code.as(:case_code)) |
    # Standard dotted notation
    (
      dot >>
      (
        # CC = Case Code: BPVC.CC.BPV or BPVC.CC.NC.XI
        (str("CC") >> dot >> bpvc_letter_code.as(:case_code) >>
         (dot >> (roman_numeral | bpvc_letter_code)).maybe.as(:case_sub)) |
        # Standard roman numeral subdivision: BPVC.I or BPVC.III.1.NB
        (roman_numeral.as(:section) >>
         (dot >> (digits | bpvc_letter_code).as(:subsection)).maybe >>
         (dot >> bpvc_letter_code.as(:sub_subsection)).maybe)
      )
    ).as(:subdivision)
  ).as(:bpvc_code)
end
```

**Testing:**
- `ASME BPVC.I-2021`
- `ASME BPVC.III.1.NB-2021`
- `ASME BPVC.CC.BPV-2021`
- `ASME BPVC COMPLETE CODE BIND-2019`
- `ASME BPVC-CC-BPV-2019`

#### Task 4: Update Designator Rule (5 min)

**Replace lines 22-31:**
```ruby
# Designator (longest match first!)
rule(:designator) do
  (
    bpvc_subdivision |      # Try BPVC patterns first
    str("ISO") |
    str("CSA") |
    str("API") |
    str("ANS") |
    letters                 # Fallback for single-letter
  ).as(:designator)
end
```

**Critical:** BPVC must come BEFORE generic letters!

#### Task 5: Update Builder for BPVC (30 min)

**File:** `lib/pubid_new/asme/builder.rb`

**Update `build_code` method:**
```ruby
def build_code(parsed_hash)
  # Handle BPVC subdivision
  if parsed_hash[:designator][:bpvc_code]
    bpvc_data = parsed_hash[:designator][:bpvc_code]

    # Build BPVC designator string
    designator_str = "BPVC"

    if bpvc_data[:special]
      # BPVC COMPLETE CODE BIND
      designator_str = "BPVC COMPLETE CODE BIND"
      number_str = ""
    elsif bpvc_data[:case_code]
      # BPVC.CC.BPV or BPVC-CC-BPV
      cc = bpvc_data[:case_code].to_s
      case_sub = bpvc_data[:case_sub]&.to_s

      # Detect format (dot or dash)
      if parsed_hash[:designator][:bpvc_code].to_s.include?("-")
        designator_str = "BPVC-CC-#{cc}"
      else
        designator_str = case_sub ? "BPVC.CC.#{cc}.#{case_sub}" : "BPVC.CC.#{cc}"
      end
      number_str = ""
    else
      # Standard subdivision
      section = bpvc_data[:subdivision][:section]&.to_s || ""
      subsection = bpvc_data[:subdivision][:subsection]&.to_s || ""
      sub_subsection = bpvc_data[:subdivision][:sub_subsection]&.to_s || ""

      parts = [section, subsection, sub_subsection].compact.reject(&:empty?)
      designator_str = "BPVC.#{parts.join('.')}"
      number_str = ""
    end

    return Components::Code.new(designator: designator_str, number: number_str)
  end

  # Existing code for non-BPVC designators...
  designator_str = parsed_hash[:designator].to_s
  number_str = parsed_hash[:number]&.to_s || ""

  Components::Code.new(designator: designator_str, number: number_str)
end
```

#### Task 6: Test BPVC Patterns (20 min)

**Test samples:**
```bash
ruby -e "require_relative 'lib/pubid_new'; puts PubidNew::Asme.parse('ASME BPVC.I-2021').to_s"
ruby -e "require_relative 'lib/pubid_new'; puts PubidNew::Asme.parse('ASME BPVC.III.1.NB-2021').to_s"
ruby -e "require_relative 'lib/pubid_new'; puts PubidNew::Asme.parse('ASME BPVC.CC.BPV-2021').to_s"
```

**Run classification:**
```bash
cd spec/fixtures && ruby run_classify.rb asme
```

**Expected:** 525-535/731 (71.8-73.2%)

---

### Part B: Multi-Character Designators (40-60 min)

**Objective:** Add explicit recognition for 25+ multi-character designator codes

**Expected Gain:** +38-45 identifiers (77.0-79.3%)

#### Task 1: Add Multi-Char Code Rule (15 min)

**File:** `lib/pubid_new/asme/parser.rb`

**Add before designator rule:**
```ruby
# Multi-character designator codes (alphabetical for maintainability)
rule(:multi_char_code) do
  str("PVHO") | str("PASE") | str("PTC") | str("PTB") | str("PDS") | str("PCC") |
  str("V&V") |  # Special: ampersand symbol
  str("TDP") | str("RTP") | str("RT") | str("RA") |
  str("QME") | str("QAI") | str("QEI") |
  str("NUM") | str("NQA") |
  str("OM") |
  str("HST") |
  str("CSD") | str("CA") |
  str("BTH") | str("BPE") |
  str("AG")
end
```

**Note:** Order alphabetically for maintainability, not by length

#### Task 2: Update Designator Rule (5 min)

**Update designator rule:**
```ruby
rule(:designator) do
  (
    bpvc_subdivision |      # BPVC patterns first
    multi_char_code |       # Multi-char codes BEFORE letters
    str("ISO") |
    str("CSA") |
    str("API") |
    str("ANS") |
    letters                 # Fallback for single-letter
  ).as(:designator)
end
```

**Critical:** multi_char_code must come BEFORE letters!

#### Task 3: Test Multi-Char Patterns (20 min)

**Test samples:**
```bash
ruby -e "require_relative 'lib/pubid_new'; puts PubidNew::Asme.parse('ASME PTC-1-2022').to_s"
ruby -e "require_relative 'lib/pubid_new'; puts PubidNew::Asme.parse('ASME PVHO-1-2019').to_s"
ruby -e "require_relative 'lib/pubid_new'; puts PubidNew::Asme.parse('ASME V&V-40-2018').to_s"
```

**Run classification:**
```bash
cd spec/fixtures && ruby run_classify.rb asme
```

**Expected:** 563-580/731 (77.0-79.3%)

---

### Part C: Validation & Edge Cases (20 min)

**If time permits, analyze remaining failures:**

1. Run classification
2. Extract top 20 failure patterns
3. Document for Session 149
4. Implement if simple (<10 min fixes)

---

## SESSION 149: Documentation & Completion (60 min)

### Objective
Complete ASME documentation and mark implementation complete.

### Part A: Update README.adoc (30 min)

**File:** `README.adoc`

**Add ASME section after ASTM:**
```asciidoc
==== ASME (American Society of Mechanical Engineers)
- Status: ✅ 563-580/731 (77.0-79.3%)
- Features: Standard codes, BPVC subdivisions, CSA dual-publishing
- Architecture: Complete V2 with MODEL-DRIVEN design

.ASME Code Structure
ASME uses a designator + number system with special BPVC handling:

**Standard Format:**
[source]
----
ASME {DESIGNATOR}{NUMBER}-{YEAR}

Examples:
ASME B16.5-2020                    # Single-letter designator
ASME PTC-1-2022                    # Multi-char designator
ASME Y14.43-2011                   # Alphanumeric number
----

**BPVC (Boiler & Pressure Vessel Code) Format:**
[source]
----
ASME BPVC.{SECTION}[.{SUBSECTION}][.{CODE}]-{YEAR}

Examples:
ASME BPVC.I-2021                   # Section I only
ASME BPVC.III.1.NB-2021            # Section III, Subsection 1, Code NB
ASME BPVC.CC.BPV-2021              # Case Code BPV
ASME BPVC COMPLETE CODE BIND-2019  # Complete code set
----

**Multi-Character Designators:**
- PTC: Performance Test Code
- PVHO: Pressure Vessels for Human Occupancy
- PCC: Post-Construction Code
- NQA: Nuclear Quality Assurance
- V&V: Verification & Validation
- And 20+ other codes

**CSA Dual-Publishing:**
[source]
----
ASME A17.1/CSA B44-2022            # Dual-published identifier
----

**Additional Features:**
- Reaffirmation notation: `(R2020)`
- Language codes: `(SPANISH)`
- Draft years: `20XX`, `202X`
- Revision notes: `[Draft Proposed Revision of...]`

.Usage Example
[source,ruby]
----
require 'pubid_new/asme'

# Parse standard code
id = PubidNew::Asme.parse("ASME B16.5-2020")
id.code.designator  # => "B"
id.code.number      # => "16.5"
id.year             # => "2020"

# Parse BPVC subdivision
bpvc = PubidNew::Asme.parse("ASME BPVC.III.1.NB-2021")
bpvc.code.designator  # => "BPVC.III.1.NB"
bpvc.year             # => "2021"

# Parse multi-char designator
ptc = PubidNew::Asme.parse("ASME PTC-1-2022")
ptc.code.designator   # => "PTC"
ptc.code.number       # => "1"

# Parse CSA dual
dual = PubidNew::Asme.parse("ASME A17.1/CSA B44-2022")
dual.code.designator  # => "A"
dual.code.number      # => "17.1"
dual.csa_number       # => "B44"
----
```

### Part B: Move Temporary Documentation (15 min)

**Move to `docs/old-docs/sessions/`:**
```bash
mv docs/SESSION-147-CONTINUATION-PROMPT.md docs/old-docs/sessions/
mv /tmp/asme_enhancement_roadmap.md docs/old-docs/sessions/asme-enhancement-roadmap.md
```

**Create session summary:**
- `docs/old-docs/sessions/session-148-summary.md`

### Part C: Update Memory Bank (15 min)

**File:** `.kilocode/rules/memory-bank/context.md`

**Add Session 148 completion:**
```markdown
## Current Status (Session 148 Complete)

**Session 148 ACHIEVEMENT - ASME 77%+ Enhancement Complete!** ✅

### Session 148: ASME BPVC + Multi-Char Implementation

**Duration:** ~150 minutes
**Status:** ASME at 77%+ ✅

**What Was Accomplished:**
1. ✅ BPVC subdivision parsing (roman numerals + letter codes)
2. ✅ BPVC special variants (COMPLETE CODE BIND, dash notation)
3. ✅ Multi-character designator recognition (25 codes)
4. ✅ Builder enhanced for BPVC code construction
5. ✅ Validated 563-580/731 identifiers (77.0-79.3%)

**BPVC Features Implemented:**
- Dotted subdivision: `BPVC.I`, `BPVC.III.1.NB`, `BPVC.CC.BPV`
- Special variants: `BPVC COMPLETE CODE BIND`
- Dash notation: `BPVC-CC-BPV`
- Roman numerals: I through XIII
- Letter codes: NB, NC, ND, NE, NF, NG, NCA, NCD, BPV, SSC

**Multi-Char Designators:**
PTC, PVHO, PCC, NQA, V&V, and 20+ other codes

**Architecture Quality:**
- ✅ MODEL-DRIVEN: No architecture changes
- ✅ Parser-only: Builder changes minimal
- ✅ Component stability: Code API unchanged
- ✅ MECE: Longest-match-first principle
- ✅ Round-trip fidelity: Preserved

**Results:**
- **Baseline:** 395/731 (54.04%)
- **Final:** 563-580/731 (77.0-79.3%)
- **Improvement:** +168-185 identifiers (+23pp!)

**Project Status:**
- **17/17 flavors implemented** (100%) 🎉
- **ASME: 77%+** - Excellent! ✅
- **Total: 88,900+ identifiers** ✅
- **Overall: 99%+ success** ✅

**Status:** ASME enhancement COMPLETE at 77%+! 🚀
```

---

## Implementation Status Tracker

### Session 147: Failure Analysis ✅
- [x] Re-classify fixtures (395/731)
- [x] Extract failure samples (336 identifiers)
- [x] Identify BPVC patterns (150 IDs, 3 variants)
- [x] Identify multi-char codes (188 IDs, 25 codes)
- [x] Create enhancement roadmap
- [x] Document parser limitations
- [x] Create session summary

### Session 148: Implementation (IN PROGRESS)
- [ ] Part A: BPVC patterns (90-120 min)
  - [ ] Add roman_numeral rule
  - [ ] Add bpvc_letter_code rule
  - [ ] Add bpvc_subdivision rule
  - [ ] Update designator rule
  - [ ] Update builder for BPVC
  - [ ] Test and validate
- [ ] Part B: Multi-char designators (40-60 min)
  - [ ] Add multi_char_code rule
  - [ ] Update designator rule
  - [ ] Test and validate
- [ ] Expected: 563-580/731 (77.0-79.3%)

### Session 149: Documentation (PENDING)
- [ ] Update README.adoc with ASME section
- [ ] Move temporary docs to old-docs/
- [ ] Create session-148-summary.md
- [ ] Update memory bank context.md
- [ ] Mark ASME COMPLETE

---

## Success Criteria

### Minimum (70%)
- ✅ BPVC basic patterns working (+100 IDs)
- ✅ Multi-char basic codes working (+20 IDs)
- ✅ 511+/731 passing

### Target (77%)
- ✅ All BPVC variants working (+130 IDs)
- ✅ Most multi-char codes working (+38 IDs)
- ✅ 563+/731 passing

### Stretch (80%+)
- ✅ All identified patterns working
- ✅ Edge cases addressed
- ✅ 585+/731 passing

---

## Key Architectural Principles

**MAINTAIN throughout ALL sessions:**
1. **MODEL-DRIVEN** - Objects not strings
2. **MECE** - Mutually exclusive, collectively exhaustive
3. **Three-layer** - Parser/Builder/Identifier independence
4. **Component stability** - Code API unchanged
5. **Longest-match-first** - Parser rule ordering critical
6. **Round-trip fidelity** - Perfect preservation
7. **Open/closed** - Extend via new rules, don't modify existing

**NEVER compromise** on architecture quality for test pass rate.

---

## Files to Modify

### Session 148
- `lib/pubid_new/asme/parser.rb` - Add BPVC + multi-char rules
- `lib/pubid_new/asme/builder.rb` - Add BPVC handling

### Session 149
- `README.adoc` - Add ASME section
- `.kilocode/rules/memory-bank/context.md` - Update status
- `docs/old-docs/sessions/session-148-summary.md` - NEW

---

## Timeline Summary

| Session | Focus | Duration | Deliverables |
|---------|-------|----------|--------------|
| 147 | Failure analysis | 60 min | Roadmap, patterns | ✅ |
| 148 | Implementation | 150-180 min | 77%+ pass rate | ⏳ |
| 149 | Documentation | 60 min | README, COMPLETE | ⏳ |
| **Total** | **All work** | **270-300 min** | **ASME 77%+** |

---

## Next Immediate Steps (Session 148)

1. Read this continuation plan
2. Read `/tmp/asme_enhancement_roadmap.md` (detailed reference)
3. Implement Part A: BPVC patterns (90-120 min)
4. Test and validate (expect 71-73%)
5. Implement Part B: Multi-char designators (40-60 min)
6. Test and validate (expect 77%+)
7. Document results
8. Move to Session 149 documentation

---

**Created:** 2025-12-16
**Sessions Covered:** 148-149
**Status:** Ready for execution
**Estimated Time:** 4-5 hours (compressed)

**End Goal:** ASME 77%+ with complete BPVC support and multi-char designators! 🚀