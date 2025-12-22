# Session 185 Continuation Plan: NIST V2 TODO Pattern Completion

**Created:** 2025-12-22 (Post-Session 184 - Scope Extended)
**Status:** Session 184 complete (basic patterns) - Need to complete TODO.NIST-MUST-FIX.md
**Timeline:** COMPRESSED - Complete in 4-6 hours (multiple sessions)
**Priority:** HIGH - 24/27 TODO patterns currently failing (11% pass rate)

---

## Session 184 Summary

**Achievement:** NIST V2 with clean architecture and basic patterns ✅
- ✅ 4-format rendering (short, mr, long, abbrev)
- ✅ Stage system (old-style + new-style)
- ✅ Translation normalization
- ✅ Basic revision patterns (r5, r1)
- ✅ Cross-conversion validated

**Scope Gap Identified:** TODO.NIST-MUST-FIX.md shows 24/27 patterns failing

---

## TODO.NIST-MUST-FIX.md Analysis

**Current Status:** 3/27 passing (11%)
- ✅ NIST GCR 21-917-48v3B
- ✅ NIST CSWP 9
- ✅ NIST HB 135e2022
- ✗ 24 patterns failing

**Failing Pattern Categories:**

### 1. Volume Patterns (2 patterns)
```
NBS SP 535v2a-l          # Volume 2, parts a through l
NBS SP 535v2m-z          # Volume 2, parts m through z
```

### 2. Dotted Version Patterns (3 patterns)
```
NIST SP 500-268v1.1      # Version 1.1
NIST SP 800-63v1.0.2     # Version 1.0.2
NIST SP 1011-I-2.0       # Roman numeral + dotted version
NIST SP 1011-II-1.0      # Roman numeral + dotted version
```

### 3. Complex Part Patterns (2 patterns)
```
NBS TN 467p1adde1        # Part 1 addition edition 1
NIST SP 800-57Pt3r1      # Part 3 revision 1
```

### 4. Revision Patterns (3 patterns)
```
NIST SP 260-126rev2013   # Revision with year
NIST SP 800-22r1a        # Revision with letter
NIST SP 800-27ra         # Revision letter only
```

### 5. Version+Edition Patterns (3 patterns)
```
NIST SP 800-28ver2       # Version 2
NIST SP 800-60ver2v1     # Version 2 volume 1
NIST SP 800-87ver1e2006  # Version 1 edition 2006
```

### 6. Update Patterns (6 patterns)
```
NIST SP 500-300-upd      # Update without number
NIST AMS 300-8r1/upd     # Update with revision
NIST.SP.500-300-upd      # MR format update
NIST IR 8170-upd
NIST TN 2150-upd
```

### 7. Missing Series (4 patterns)
```
NIST AMS 300-8r1/upd     # Advanced Manufacturing Series
NIST VTS 100-2sup1       # Voting Technology Series
NBS LCIRC 1088sp         # Letter for Circulation
NBS RPT 4817-A           # Report
```

### 8. Other Patterns (1 pattern)
```
nist ir 8011-4           # Lowercase input
```

---

## SESSION 185-187: Complete Pattern Implementation (Compressed)

### Session 185: Parser Enhancement Phase 1 (120 min)

**Part A: Add Missing Series (30 min)**

Update `lib/pubid_new/nist/parser.rb` simple_series rule:

```ruby
rule(:simple_series) do
  (
    # Existing
    str("AMS") | str("BSS") | str("BMS") | str("BH") |
    str("FIPS") | str("GCR") | str("HB") | str("MONO") |
    str("MP") | str("NCSTAR") | str("NSRDS") | str("IR") |
    str("SP") | str("TN") | str("CSWP") | str("VTS") |
    str("AI") | str("CIRC") | str("CS") | str("CSM") |
    str("CRPL") | str("OWMWP") | str("PC") | str("RPT") |
    str("SIBS") | str("TIBM") | str("TTB") | str("EAB") |
    str("JPCRD") | str("JRES") |

    # NEW: Add missing series
    str("LCIRC")  # Letter for Circulation (NBS LCIRC)
  ).as(:series)
end
```

**Part B: Enhance Volume Rule (20 min)**

```ruby
rule(:volume) do
  (str("v") | str(" Vol. ")) >>
  (
    # Range patterns: v2a-l, v2m-z
    (digits >> (str("a-l") | str("m-z"))) |
    # Single letter: v3B, v1A
    (digits >> upper_letter.repeat(0, 2)) |
    # Just digits: v1, v2
    digits
  ).as(:volume)
end
```

**Part B: Enhance Version Rule (30 min)**

```ruby
rule(:version) do
  (
    # Verbose forms: "ver", " Ver. ", " Version "
    ((str("ver") | str(" Ver. ") | str(" Version ")) >>
      (digits >> (dot >> digits).repeat).as(:version)) |
    # Short form "v" with mandatory dots (v1.0, v1.0.2)
    (str("v") >>
      (digits >> dot >> digits >> (dot >> digits).repeat).as(:version))
  )
end
```

**Part C: Enhance Part Rule (20 min)**

```ruby
rule(:part) do
  (str("pt") | str("p") | str("P") | str(" Part ") | str("Pt")) >>
  (
    # Complex: p1adde1 (part 1 addition edition 1)
    (digits >> str("add") >> (str("e") >> digits).maybe) |
    # Simple: pt3, p1, Part 1
    (digits >> (dash >> digits).maybe)
  ).as(:part)
end
```

**Part D: Enhance Revision Rule (20 min)**

```ruby
rule(:revision) do
  (
    # With year: rev2013
    (str("rev") >> digits.as(:revision_year)) |
    # With letter: r1a, ra
    ((str(" rev ") | str("rev") | str("r") | str(" Rev. ") | str(" Revision (r)")) >>
      (digits.maybe >> lower_letter.maybe).as(:revision))
  )
end
```

---

### Session 186: Parser Enhancement Phase 2 (90 min)

**Part A: Enhanced Update Pattern (30 min)**

```ruby
rule(:update) do
  (
    # Full format: /Upd{N}-{YYYY}{MM}
    (str("/Upd") | str("/upd")) >>
    (
      digits.as(:update_number) >>
      (dash >>
        match("[0-9]").repeat(4, 4).as(:update_year) >>
        match("[0-9]").repeat(2, 2).as(:update_month).maybe
      ).maybe
    ) |
    # Short format without number: -upd
    (dash >> str("upd"))
  ).as(:update)
end
```

**Part B: Test All Patterns (40 min)**

Run comprehensive test against TODO.NIST-MUST-FIX.md:
```bash
ruby test_nist_todo.rb
```

Target: 22+/27 passing (80%+)

**Part C: Fix Identified Issues (20 min)**

Iterate on failing patterns based on test results.

---

### Session 187: Builder & Testing (60 min)

**Part A: Builder Enhancements (20 min)**

Update `lib/pubid_new/nist/builder.rb` to handle:
- Volume ranges (v2a-l → volume="2a-l")
- Complex parts (p1adde1 → part="1", addition=true, edition="1")
- Revision with year (rev2013 → revision="", revision_year="2013")
- Version+edition (ver1e2006 → version="1", edition_year="2006")

**Part B: Comprehensive Testing (30 min)**

Create `spec/pubid_new/nist/todo_patterns_spec.rb`:
- Test all 27 patterns from TODO.NIST-MUST-FIX.md
- Verify parsing
- Verify rendering in all 4 formats
- Target: 27/27 passing

**Part C: Documentation (10 min)**

Update SESSION-185-CONTINUATION-PLAN.md with results.

---

## Success Criteria

### Minimum (80% - Sessions 185-186)
- ✅ 22+/27 TODO patterns parsing
- ✅ All series types recognized
- ✅ All major pattern categories working

### Target (95% - Sessions 185-187)
- ✅ 26+/27 TODO patterns parsing
- ✅ Comprehensive test suite
- ✅ Clean architecture maintained

### Stretch (100%)
- ✅ 27/27 TODO patterns parsing
- ✅ All edge cases handled
- ✅ Production-ready quality

---

## Implementation Status

### Session 184: Basic Patterns ✅
- [x] 4-format rendering
- [x] Stage system
- [x] Translation normalization
- [x] Basic patterns (3/27 TODO passing)

### Session 185: Parser Phase 1
- [ ] Add missing series (LCIRC, etc.)
- [ ] Enhance volume rule (ranges)
- [ ] Enhance version rule (dotted)
- [ ] Enhance part rule (complex)
- [ ] Enhance revision rule (with year/letter)

### Session 186: Parser Phase 2
- [ ] Enhanced update pattern
- [ ] Test all TODO patterns
- [ ] Fix identified issues
- [ ] Target: 22+/27 passing

### Session 187: Final Testing
- [ ] Builder enhancements
- [ ] Comprehensive test suite
- [ ] Documentation
- [ ] Target: 27/27 passing

---

## Key Architectural Principles

**NEVER COMPROMISE:**
1. **MODEL-DRIVEN** - All concepts as Lutaml::Model
2. **MECE** - Parser patterns mutually exclusive
3. **Three-layer** - Parser/Builder/Identifier independence
4. **Pattern Priority** - Longest/most specific first
5. **Backward Compatibility** - Maintain Session 184 functionality

---

**Created:** 2025-12-22
**Timeline:** Sessions 185-187 (4-6 hours compressed)
**Target:** 27/27 TODO patterns passing
**Status:** Ready for comprehensive pattern implementation