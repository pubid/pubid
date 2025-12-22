# Session 184+ Continuation Prompt: NIST V2 Testing & Format Completion

**Context:** Session 183 completed Parser Migration (Phase 3) and Builder Updates (Phase 4). Parser now supports V1 stage, translation, version, and update patterns. Builder casts to V2 components. Base identifier has V2 component attributes.

**Critical User Requirements:**
1. Parse all V1 identifiers mentioned in [`docs/NIST_V1_FEATURES.md`](NIST_V1_FEATURES.md:1)
2. All 4 format types (short, mr, long, abbrev) must work
3. Cross-conversion between formats must work

---

## What to Do

**READ FIRST:**
1. [`docs/SESSION-184-CONTINUATION-PLAN.md`](SESSION-184-CONTINUATION-PLAN.md:1) - Complete plan (Phases 5-6)
2. [`docs/NIST_V1_FEATURES.md`](NIST_V1_FEATURES.md:1) - Critical V1 examples to test

**DO NOT:**
- Skip testing critical V1 identifiers
- Implement only 2-3 formats (need all 4!)
- Assume cross-conversion works without testing

**DO:**
- Follow the plan EXACTLY (Session 184 Part A-C)
- Test EVERY critical V1 identifier from docs
- Implement ALL 4 formats (short, mr, long, abbrev)
- Verify cross-conversion works
- Fix failures incrementally

---

## Session 184 Immediate Goals

### Part A: Complete 4-Format Rendering (60 min)

**Current Status:**
- ✅ `to_short_style` - Working with V2 components
- ⚠️ `to_mr_style` - Needs V2 component integration
- ⚠️ `to_full_style` (long) - Needs V2 component support
- ⚠️ `to_abbreviated_style` (abbrev) - Needs V2 component support

**Task 1: Enhance to_mr_style (15 min)**

File: [`lib/pubid_new/nist/identifiers/base.rb`](../lib/pubid_new/nist/identifiers/base.rb:229) lines 229-237

Add V2 components: version_component, update_component, stage, translation_component
Use `.to_s(:mr)` format for each component

**Task 2: Enhance to_full_style (long) (20 min)**

File: [`lib/pubid_new/nist/identifiers/base.rb`](../lib/pubid_new/nist/identifiers/base.rb:111) lines 111-121

Add V2 components with `.to_s(:long)` format
Add `publisher_full_name` helper method for "National Institute of Standards and Technology"

**Task 3: Enhance to_abbreviated_style (abbrev) (25 min)**

File: [`lib/pubid_new/nist/identifiers/base.rb`](../lib/pubid_new/nist/identifiers/base.rb:123) lines 123-131

Add V2 components with `.to_s(:abbrev)` format
Add `publisher_abbreviated_name` helper for "Natl. Inst. Stand. Technol."

---

### Part B: Critical V1 Identifier Testing (60 min)

**Test these patterns from NIST_V1_FEATURES.md:**

**Stage Examples:**
```ruby
"NIST SP(IPD) 800-53r5"        # Old style → to_s(:short) = "NIST SP 800-53r5 ipd"
"NIST SP 800-66r2 ipd"         # New style → to_s(:mr) = "NIST.SP.800-66r2.ipd"
"NIST.SP.800-66r2.ipd"         # MR format → to_s(:short) = "NIST SP 800-66r2 ipd"
```

**Translation Examples:**
```ruby
"NIST SP 1262es"               # Transform es→spa → to_s(:short) = "NIST SP 1262 spa"
"NIST SP 800-189 IPD spa"      # Stage + translation → both work
"NIST SP 1262(spa)"            # Parenthetical → to_s(:short) = "NIST SP 1262 spa"
```

**Edition Examples:**
```ruby
"NBS FIPS 107-Mar1985"         # Month-year → edition.year=1985, month=3
"NBS FIPS 11-1-Sep30/1977"     # Month-day-year → year=1977, month=9, day=30
"NIST SP 800-53e2019"          # e-prefix → edition.year=2019
```

**Update Examples:**
```ruby
"NIST SP 800-53r4/Upd3-2015"   # Update → number=3, year=2015
"NIST AMS 300-8r1/Upd1-202102" # With month → number=1, year=2021, month=2
```

**Version Examples:**
```ruby
"NIST SP 800-63v1.0.2"         # Dotted → version.value="1.0.2"
"NIST SP 1011v1ver2.0"         # Volume + version
```

**Action:** Parse each, verify components, test all 4 formats, verify round-trip

---

### Part C: Format Cross-Conversion Testing (30 min)

**Create test file:** `spec/pubid_new/nist/format_conversion_spec.rb`

Test matrix:
1. Parse identifier in any format (short/mr/old style)
2. Convert to all 4 formats
3. Re-parse each format
4. Verify components match

**Example test:**
```ruby
examples = [
  "NIST SP 800-53r5 ipd",      # short
  "NIST.SP.800-53r5.ipd",      # mr
  "NIST SP(IPD) 800-53r5"      # old style
]

examples.each do |input|
  parsed = PubidNew::Nist.parse(input)

  short = parsed.to_s(:short)
  mr = parsed.to_s(:mr)
  long = parsed.to_s(:long)
  abbrev = parsed.to_s(:abbrev)

  # Re-parse and verify
  expect(PubidNew::Nist.parse(short).stage.id).to eq("i")
  expect(PubidNew::Nist.parse(mr).stage.id).to eq("i")
end
```

---

## Success Metrics

**Minimum (Session 184):**
- ✅ All 4 formats implemented and tested
- ✅ 10+ critical V1 identifiers parsing correctly
- ✅ Cross-conversion working for stage/translation
- ✅ Components rendering in all formats

**Target (Sessions 184-185):**
- ✅ All critical V1 identifiers parsing (20+)
- ✅ Cross-conversion working for all patterns
- ✅ Comprehensive specs (30+ tests)
- ✅ Documentation complete

---

## Quick Start (Session 184)

```bash
# 1. Read the continuation plan
open docs/SESSION-184-CONTINUATION-PLAN.md

# 2. Read V1 features reference
open docs/NIST_V1_FEATURES.md

# 3. Start Part A: Complete 4-format rendering
# Enhance to_mr_style, to_full_style, to_abbreviated_style

# 4. Start Part B: Test critical V1 identifiers
# Parse each example, verify components, test all 4 formats

# 5. Start Part C: Cross-conversion testing
# Create format_conversion_spec.rb, test matrix
```

---

## Timeline (COMPRESSED)

| Session | Tasks | Duration | Deliverables |
|---------|-------|----------|--------------|
| 184 | Parts A-C | 150 min | 4 formats + tests |
| 185 | Specs + docs | 120 min | Complete |
| **Total** | **All** | **4.5 hrs** | **100% parity** |

---

**Status:** Ready to begin Session 184
**Priority:** CRITICAL - Complete 4-format rendering and V1 parity
**Approach:** Systematic testing of V1 patterns, all formats working

Let's complete NIST V2 properly! 🎯