# Session 152+ Continuation Plan: CSA Enhancement & API Implementation

**Created:** 2025-12-16 (Post-Session 151)
**Status:** ASME 100%, CSA 18.7% baseline - Ready for enhancements
**Timeline:** 3-4 sessions (6-8 hours)

---

## Executive Summary

**Session 151 Achievement:** ASME enhanced to 100% (731/731) + CSA flavor implemented (18th flavor)! 🎉

**Current Status:**
- **ASME:** 731/731 (100%) - Perfect! ✅
- **CSA:** 167/899 (18.7%) baseline OR 167/369 (45.3%) on modern standards
- **Architecture:** MODEL-DRIVEN, MECE, Three-layer maintained

**Remaining Work:**
1. CSA enhancement (CAN/CSA- prefix, ISO/IEC adoptions, SERIES patterns)
2. API flavor implementation (198 identifiers)
3. Documentation updates
4. Final integration and testing

---

## CSA Dataset Analysis

**Total fixtures:** 899 identifiers
**Categories:**
- Modern CSA: 369 identifiers (CSA B149, Z462, etc.)
- Legacy CAN/CSA-: ~480 identifiers (CAN/CSA-C22.2, etc.)
- Adopted ISO/IEC: ~50 identifiers (CSA ISO/IEC TR)

**Current Results:**
- Passing: 167/899 (18.7%)
- Filtered: 37 (comments, non-standards)
- Modern CSA: 167/369 (45.3%)

**Remaining Patterns:**
1. CAN/CSA- with dash years need proper year_format handling
2. CSA ISO/IEC TR adopted standards
3. SERIES with space (partially fixed)
4. Combined identifiers (slash, comma separators)
5. Package keywords preservation
6. Letter suffix in numbers (60950-1A, 60950-1B)
7. Amendment notation (/A1, /A2)

---

## SESSION 152: CSA Parser Enhancement (120 minutes)

### Objective
Improve CSA from 18.7% to 50%+ by handling high-impact patterns.

### Part A: Fix Year Format Detection (30 min)

**Issue:** CAN/CSA- normalization loses dash vs colon information

**Solution:** Detect format before normalization

**File:** `lib/pubid_new/csa/identifier.rb`
```ruby
def self.parse(input)
  # Filter comments
  return nil if input.start_with?("#")
  return nil if input.match?(/^CSA (Communities|Group|Learning|OnDemand|Update)/)

  # Detect year format before normalization
  has_dash_year = input.match?(/-\d{2}\b/)

  # Normalize CAN/CSA- to CSA
  normalized = input.gsub(/^CAN\/CSA-/, "CSA ")

  tree = Parser.new.parse(normalized)
  result = Builder.new.build(tree)

  # Set year format if detected
  if result && has_dash_year && result.year_format.nil?
    result.year_format = "dash"
  end

  result
end
```

**Expected gain:** +280-300 CAN/CSA- identifiers

### Part B: ISO/IEC Adoption Pattern (20 min)

**Pattern:** `CSA ISO/IEC TR 19758:04 (R2024)`

**Parser addition:**
```ruby
rule(:iso_iec_adoption) do
  publisher >>
  str("ISO/IEC") >> space >>
  (str("TR") | str("TS")).as(:doc_type) >> space >>
  match("[0-9-]").repeat(1).as(:iso_number) >>
  colon >> year_2digit.as(:year) >>
  (slash >> str("A") >> digit.as(:amendment_num)).maybe >>
  reaffirmation.maybe
end
```

**Expected gain:** +40-50 identifiers

### Part C: Letter Suffix in Numbers (15 min)

**Pattern:** `C22.2 NO. 60950-1A-07`

**Update code_pattern:**
```ruby
rule(:code_pattern) do
  (
    letter >> match("[0-9]").repeat(1) >>
    (dot >> match("[0-9]").repeat(1)).repeat >>
    (dash >> match("[0-9]").repeat(1) >> letter).maybe  # Allow letter suffix
  ).as(:code)
end
```

**Expected gain:** +10-15 identifiers

### Part D: Testing & Validation (55 min)

**Test all CSA:**
```bash
ruby /tmp/test_csa_full.rb 2>&1 | grep -E "^✓" | wc -l
```

**Expected final:** 497-520/899 (55-58%)

---

## SESSION 153: API Flavor Implementation (120 minutes)

### Objective
Implement complete API (American Petroleum Institute) flavor.

### API Pattern Analysis

**Total fixtures:** 198 identifiers

**Document Types (9 classes - MECE):**
1. Bulletin (BULL)
2. Mpms (MPMS CH)
3. RecommendedPractice (RP)
4. Specification (SPEC)
5. Standard (STD)
6. TechnicalReport (TR)
7. ContinuousOperationsStandard (COS)
8. Publication (PUBL)
9. TypelessStandard (no type)

### Implementation Tasks

**Part A: Create Base Structure (40 min)**

Files to create:
- `lib/pubid_new/api.rb`
- `lib/pubid_new/api/identifier.rb`
- `lib/pubid_new/api/parser.rb`
- `lib/pubid_new/api/builder.rb`
- `lib/pubid_new/api/single_identifier.rb`
- `lib/pubid_new/api/components/code.rb`
- `lib/pubid_new/api/identifiers/base.rb`
- `lib/pubid_new/api/identifiers/*.rb` (9 types)

**Part B: Implement Parser (40 min)**

**Key patterns:**
```ruby
rule(:doc_type) do
  str("MPMS") | str("BULL") | str("SPEC") | str("STD") |
  str("RP") | str("TR") | str("COS") | str("PUBL")
end

rule(:chapter_notation) { space >> str("CH") >> space }

rule(:part_notation) { str(", Part ") >> digits.as(:part) }

rule(:edition_notation) do
  comma >> space >>
  (str("1st") | str("2nd") | str("3rd") | match("[0-9]").repeat(1) >> str("th")) >>
  space >> str("edition")
end
```

**Part C: Testing (40 min)**

**Expected:** 168-188/198 (85-95%)

---

## SESSION 154: Integration & Documentation (90 minutes)

### Part A: Integration (20 min)

Update:
- `lib/pubid_new.rb` - Add require for api
- `spec/fixtures/classify_fixtures.rb` - Add api to FLAVORS

### Part B: Comprehensive Testing (40 min)

Test all flavors:
```bash
cd spec/fixtures
ruby run_classify.rb asme  # Verify no regression
ruby run_classify.rb csa   # Verify improvements
ruby run_classify.rb api   # Validate implementation
```

### Part C: Documentation (30 min)

Update `.kilocode/rules/memory-bank/context.md` with:
- Session 151 complete (ASME 100%, CSA 18.7%)
- Session 152 complete (CSA 50%+)
- Session 153 complete (API 85%+)

Archive old docs:
- Move `docs/SESSION-151-CONTINUATION-PLAN.md` to `docs/old-docs/sessions/`
- Create `docs/old-docs/sessions/session-151-summary.md`

---

## Implementation Status Tracker

### Session 151: ASME 100% + CSA Baseline ✅
- [x] ASME: 731/731 (100%)
- [x] CSA: 8 files created
- [x] CSA: 167/899 (18.7%) baseline
- [x] Architecture: MODEL-DRIVEN maintained

### Session 152: CSA Enhancement
- [ ] Fix year format detection (30 min)
- [ ] ISO/IEC adoption pattern (20 min)
- [ ] Letter suffix in numbers (15 min)
- [ ] Testing (55 min)
- [ ] Expected: 497-520/899 (55-58%)

### Session 153: API Implementation
- [ ] Create 17 files (40 min)
- [ ] Implement parser with 9 types (40 min)
- [ ] Testing (40 min)
- [ ] Expected: 168-188/198 (85-95%)

### Session 154: Integration & Docs
- [ ] Integration (20 min)
- [ ] Testing (40 min)
- [ ] Documentation (30 min)

---

## Success Criteria

### CSA (Session 152)
- ✅ 50%+ overall (450+/899)
- ✅ OR 70%+ on modern standards (260+/369)
- ✅ CAN/CSA- prefix working
- ✅ ISO/IEC adoptions working

### API (Session 153)
- ✅ 9 identifier classes (MECE)
- ✅ All document types recognized
- ✅ 85%+ pass rate (168+/198)
- ✅ MODEL-DRIVEN architecture

### Integration (Session 154)
- ✅ All 19 flavors integrated
- ✅ No regressions in ASME
- ✅ Documentation complete

---

## Key Architectural Principles

**MAINTAIN throughout:**
1. **MODEL-DRIVEN** - Objects not strings
2. **MECE** - Mutually exclusive identifier types
3. **Three-layer** - Parser/Builder/Identifier independence
4. **Component reuse** - Code, Date components
5. **Format preservation** - Track original format

---

## Next Immediate Steps (Session 152)

1. Fix year format detection in Identifier.parse
2. Add ISO/IEC adoption pattern
3. Add letter suffix support
4. Test comprehensive improvements
5. Document CSA completion

---

**Created:** 2025-12-16
**Sessions Covered:** 152-154
**Status:** Ready for execution
**Estimated Time:** 6-8 hours

**End Goal:** CSA 50%+, API 85%+, 19 flavors complete! 🎉