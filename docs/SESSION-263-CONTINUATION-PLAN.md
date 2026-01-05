# Session 263+ Continuation Plan: NIST Parser Enhancement & Spec Completion

**Created:** 2026-01-05 (Post-Session 262)
**Status:** Circular spec aligned with V2 API - Ready for parser implementation
**Timeline:** COMPRESSED - Complete in 3-4 sessions (6-8 hours total)

---

## Executive Summary

**Session 262 Achievement:** Circular spec updated to V2 Edition component API ✅

**Current Status:**
- **Circular spec:** 50 examples, 0 failures, 14 pending (parser gaps)
- **Architecture:** V2 Edition component working perfectly (e2revJune1908 → e2.June1908)
- **Critical finding:** V1 parses ALL 14 patterns, V2 parser needs enhancement

**Remaining Work:**
1. Implement 14 missing parser patterns to match V1 functionality
2. Make all 50 Circular tests pass (100%, 0 pending)
3. Continue with CommercialStandard, Handbook, and other NIST specs

---

## SESSION 263: NIST Circular Parser Enhancement (180 min)

### Objective
Implement missing parser patterns to make ALL 50 Circular tests pass.

### Phase 1: Analyze V1 Parser Implementation (30 min)

**Read V1 implementation to understand patterns:**
- `archived-gems/pubid-nist/lib/pubid/nist/parsers/circ.rb`
- `archived-gems/pubid-nist/lib/pubid/nist/transformer.rb`

**Document how V1 handles:**
1. Volume notation (`v10`)
2. Edition with separate year (`e2-1915`)
3. Bare edition without number (`NBS CIRC e2`)
4. Historical edition with month+year (`-April1909`)
5. Supplement patterns (`sup-1924`, `e2sup`, `supJan1924`)
6. Supplement date ranges (`supJun1925-Jun1926`)

### Phase 2: Implement Parser Patterns (120 min)

**File:** `lib/pubid_new/nist/parser.rb`

**Pattern 1: Volume notation (15 min)**
```ruby
# Add to parser
rule(:volume) do
  str("v") >> digits.as(:volume)
end

# Update identifier_content to include volume
rule(:identifier_content) do
  # ... existing rules ...
  volume.maybe >>
  # ... rest of rules
end
```

**Pattern 2: Edition with separate year (20 min)**
```ruby
# Add pattern for e2-1915 format
rule(:edition_with_year) do
  edition_type >> digits.as(:edition_id) >>
  dash >> year_digits.as(:year)
end

# Update edition rule to support both formats
rule(:edition) do
  edition_with_year.as(:edition_with_year) |
  edition_with_additional_text |
  simple_edition
end
```

**Pattern 3: Bare edition without number (15 min)**
```ruby
# Add pattern for "NBS CIRC e2" (no number before edition)
rule(:bare_edition_identifier) do
  publisher >> space >>
  series >> space >>
  edition.as(:edition) >>
  # No number!
  language_portion.maybe
end

# Update main identifier rule
rule(:identifier) do
  bare_edition_identifier |
  normal_identifier
end
```

**Pattern 4: Historical edition with month+year (20 min)**
```ruby
# Add pattern for -April1909 format
rule(:historical_edition_with_month_year) do
  dash >> month_name.as(:month) >> year_digits.as(:year)
end

# Update identifier_content
rule(:identifier_content) do
  # ... existing ...
  historical_edition_with_month_year.maybe.as(:historical_edition) >>
  # ... rest
end
```

**Pattern 5: Supplement patterns (30 min)**
```ruby
# Enhanced supplement patterns
rule(:supplement) do
  str("sup") >>
  (
    # sup-1924 (supplement with year)
    (dash >> year_digits.as(:supplement_year)) |
    # supJan1924 (supplement with month+year)
    (month_name.as(:supplement_month) >> year_digits.as(supplement_year)) |
    # supprev (supplement with revision)
    str("rev").as(:supplement_revision) |
    # sup (bare supplement)
    str("").as(:bare_supplement)
  ).maybe
end
```

**Pattern 6: Supplement date ranges (20 min)**
```ruby
# supJun1925-Jun1926 format
rule(:supplement_date_range) do
  str("sup") >>
  month_name.as(:start_month) >> year_digits.as(:start_year) >>
  dash >>
  month_name.as(:end_month) >> year_digits.as(:end_year)
end

# Handle supplement without number prefix
rule(:supplement_only_identifier) do
  publisher >> space >>
  series >> space >>
  supplement_date_range.as(:supplement_range)
end
```

### Phase 3: Update Builder (20 min)

**File:** `lib/pubid_new/nist/builder.rb`

**Add casting for new parsed data:**
```ruby
def cast(type, value)
  case type
  when :volume
    value.to_s

  when :edition_with_year
    # Build Edition with year separated
    Edition.new(
      type: extract_edition_type(value),
      id: value[:edition_id].to_s
    )
    # Year goes to identifier's year attribute

  when :historical_edition
    # -April1909 → Edition(type: "-", additional_text: "April1909")
    Edition.new(
      type: "-",
      additional_text: "#{value[:month]}#{value[:year]}"
    )

  when :supplement_year, :supplement_month
    # Build supplement attributes

  when :supplement_range
    # Build date range attributes

  # ... existing cases
  end
end
```

### Phase 4: Testing & Validation (10 min)

**Run tests:**
```bash
bundle exec rspec spec/pubid_new/nist/identifiers/circular_spec.rb --format doc
```

**Expected result:**
- 50 examples, 50 passing, 0 pending ✅

**If any failures:** Iterate on parser/builder until all pass.

---

## SESSION 264: NIST CommercialStandard & Handbook Specs (120 min)

### Objective
Fix CommercialStandard and Handbook specs using V2 Edition API (same pattern as Circular).

### Phase 1: Fix CommercialStandard Spec (60 min)

**File:** `spec/pubid_new/nist/identifiers/commercial_standard_spec.rb`

**Expected patterns similar to Circular:**
- Edition API updates
- Parser gaps documentation
- Round-trip canonical format

**Strategy:**
1. Read V1 spec to understand expected behavior
2. Update to V2 Edition component API
3. Document any V2 parser gaps
4. Implement missing patterns if needed

### Phase 2: Fix Handbook Spec (60 min)

**File:** `spec/pubid_new/nist/identifiers/handbook_spec.rb`

Follow same approach as CommercialStandard.

---

## SESSION 265: NIST Modern Series Specs (120 min)

### Objective
Fix SpecialPublication, InteragencyReport, TechnicalNote specs.

**Files:**
- `spec/pubid_new/nist/identifiers/special_publication_spec.rb`
- `spec/pubid_new/nist/identifiers/interagency_report_spec.rb`
- `spec/pubid_new/nist/identifiers/technical_note_spec.rb`

**Strategy:**
1. Modern series likely have fewer legacy patterns
2. Focus on Edition API alignment
3. Update expectations (r5, e2021, etc.)

---

## SESSION 266: Documentation & Completion (60 min)

### Objective
Update README and mark NIST V2 spec alignment complete.

### Part A: Update README.adoc (30 min)

Add NIST Edition architecture section with examples showing:
- V2 Edition component usage
- Dotted notation rendering
- Legacy pattern parsing

### Part B: Update Memory Bank (20 min)

Document Sessions 262-266 completion in `.kilocode/rules/memory-bank/context.md`.

### Part C: Archive Session Docs (10 min)

Move SESSION-262-CONTINUATION-PLAN.md to `docs/old-docs/sessions/`.

---

## Implementation Status Tracker

### Session 262: Circular Spec V2 API Alignment ✅
- [x] Update all Edition expectations to V2 API
- [x] Update round-trip expectations (dotted notation)
- [x] Document 14 parser gaps
- **Result:** 50 examples, 0 failures, 14 pending

### Session 263: Circular Parser Enhancement (PENDING)
- [ ] Phase 1: Analyze V1 parser (30 min)
- [ ] Phase 2: Implement 14 missing patterns (120 min)
  - [ ] Volume notation (v10)
  - [ ] Edition with year (e2-1915)
  - [ ] Bare edition (NBS CIRC e2)
  - [ ] Historical edition+month (-April1909)
  - [ ] Supplement patterns (sup variants)
  - [ ] Supplement date ranges
- [ ] Phase 3: Update builder (20 min)
- [ ] Phase 4: Testing (10 min)
- **Target:** 50/50 passing (100%, 0 pending)

### Session 264: CommercialStandard & Handbook (PENDING)
- [ ] Fix CommercialStandard spec (60 min)
- [ ] Fix Handbook spec (60 min)
- **Target:** Both specs V2 API aligned

### Session 265: Modern Series Specs (PENDING)
- [ ] Fix SpecialPublication spec (40 min)
- [ ] Fix InteragencyReport spec (40 min)
- [ ] Fix TechnicalNote spec (40 min)
- **Target:** All modern series V2 aligned

### Session 266: Documentation (PENDING)
- [ ] Update README.adoc (30 min)
- [ ] Update memory bank (20 min)
- [ ] Archive session docs (10 min)
- **Target:** NIST V2 spec alignment COMPLETE

---

## Success Criteria

### Minimum (80%)
- ✅ Circular spec 100% passing (no pending)
- ✅ CommercialStandard & Handbook V2 aligned
- ✅ Modern series specs V2 aligned

### Target (90%)
- ✅ All parser patterns from V1 implemented
- ✅ Zero pending tests across all NIST specs
- ✅ Complete V1 parity for core identifier types

### Stretch (95%+)
- ✅ All NIST identifier specs 100% passing
- ✅ Comprehensive documentation
- ✅ NIST V2 architecture fully validated

---

## Key Architectural Principles

**MAINTAIN throughout:**
1. **MODEL-DRIVEN** - Edition as Lutaml::Model, not strings
2. **V1 PARITY** - Implement ALL patterns V1 supports
3. **Canonical rendering** - Dotted notation for additional_text
4. **Parse legacy, render canonical** - Accept "rev", output dot
5. **Component API** - Use `.type`, `.id`, `.additional_text`
6. **Architecture correctness** - Over test pass rate

**NEVER compromise architecture for shortcuts.**

---

## Critical Implementation Notes

### V1 Pattern Analysis Required

Before implementing each pattern, MUST:
1. Read V1 parser code
2. Read V1 transformer code
3. Understand V1 normalization rules
4. Document V1 → V2 mapping

### Parser Enhancement Strategy

1. **Longest match first** - Specific patterns before general
2. **Backward compatible** - Don't break existing patterns
3. **Test incrementally** - One pattern at a time
4. **Validate against V1** - Cross-reference V1 behavior

### Builder Enhancement Strategy

1. **Proper edition construction** - Use Edition component correctly
2. **Handle hybrid patterns** - Edition+year, edition+supplement
3. **Preserve information** - Don't lose parsed data
4. **Cast appropriately** - Type checking for components

---

## Files to Create/Modify

### Session 263
- `lib/pubid_new/nist/parser.rb` - Add 14 missing patterns
- `lib/pubid_new/nist/builder.rb` - Cast new parsed data
- Possibly: `lib/pubid_new/nist/identifiers/base.rb` - Handle new attributes

### Session 264
- `spec/pubid_new/nist/identifiers/commercial_standard_spec.rb` - V2 API
- `spec/pubid_new/nist/identifiers/handbook_spec.rb` - V2 API

### Session 265
- `spec/pubid_new/nist/identifiers/special_publication_spec.rb` - V2 API
- `spec/pubid_new/nist/identifiers/interagency_report_spec.rb` - V2 API
- `spec/pubid_new/nist/identifiers/technical_note_spec.rb` - V2 API

### Session 266
- `README.adoc` - NIST Edition architecture section
- `.kilocode/rules/memory-bank/context.md` - Update completion

---

## Timeline Summary

| Session | Focus | Duration | Deliverables |
|---------|-------|----------|--------------|
| 263 | Circular parser enhancement | 180 min | 50/50 tests passing |
| 264 | CommercialStandard & Handbook | 120 min | V2 API aligned |
| 265 | Modern series specs | 120 min | V2 API aligned |
| 266 | Documentation | 60 min | README, COMPLETE |
| **Total** | **All work** | **480 min** | **NIST V2 done** |

---

## V1 Reference Files

**Must read before implementing:**
- `archived-gems/pubid-nist/lib/pubid/nist/parsers/circ.rb`
- `archived-gems/pubid-nist/lib/pubid/nist/transformer.rb`
- `archived-gems/pubid-nist/spec/nist_pubid/document/circ_spec.rb`

---

**Created:** 2026-01-05
**Sessions Covered:** 263-266
**Status:** Ready for execution
**Estimated Time:** 8 hours (compressed)

**End Goal:** NIST V2 complete with full V1 parity - ALL tests passing! 🎉