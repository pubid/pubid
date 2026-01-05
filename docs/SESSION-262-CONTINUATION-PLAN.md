# Session 262+ Continuation Plan: NIST V1 Spec Alignment

**Created:** 2026-01-05 (Post-Session 261)
**Status:** Edition component spec complete - Ready for V1 alignment
**Timeline:** COMPRESSED - Complete in 2-3 sessions (4-6 hours)

---

## Executive Summary

**Session 261 Achievement:** Edition component spec complete with 40 tests (38 passing, 2 pending) ✅

**Current Status:**
- **Edition spec:** 40 examples, 38 passing, 2 pending (95%)
- **NIST overall:** Many tests failing due to V1→V2 API misalignment
- **Architecture:** Edition.additional_text working, Date component deleted

**Remaining Work:**
- Align NIST identifier specs with V2 Edition component API
- Fix legacy attribute expectations (edition_year, edition_month → Edition object)
- Update round-trip expectations (e2revJune1908 → e2.June1908)

---

## SESSION 262: NIST Spec Alignment - Circular & Basic Series (120 min)

### Objective
Fix Circular and basic series specs to use V2 Edition component API.

### Current Failures Analysis

From Session 261 test run, key failure patterns:

**Pattern 1: Legacy attribute expectations (edition_year, edition_month)**
```ruby
# WRONG (V1 API):
expect(parsed.edition).to eq("2")           # String
expect(parsed.edition_year).to eq("1908")   # Doesn't exist
expect(parsed.edition_month).to eq("June")  # Doesn't exist

# CORRECT (V2 API):
expect(parsed.edition).to be_a(PubidNew::Nist::Components::Edition)
expect(parsed.edition.id).to eq("2")
expect(parsed.edition.additional_text).to eq("June1908")
```

**Pattern 2: Round-trip expectations with legacy format**
```ruby
# WRONG (expects legacy format):
expect(parsed.to_s).to eq("NBS CIRC 13e2revJune1908")

# CORRECT (canonical format):
expect(parsed.to_s).to eq("NBS CIRC 13e2.June1908")
```

### Phase 1: Fix Circular Spec (60 min)

**File:** `spec/pubid_new/nist/identifiers/circular_spec.rb`

**Failures to fix (25):**
- Lines 61, 65: Edition API mismatch
- Lines 82: Edition API mismatch  
- Lines 101, 105, 109, 113: Edition with revision - API + round-trip
- Lines 126, 130, 134: Historical edition format
- Lines 149, 153: Supplement parsing
- Lines 165, 169, 173: Edition + supplement
- Lines 203: Supplement date
- Lines 216, 228: Supplement date range

**Fix strategy:**
1. Replace `edition` string expectations with `edition.id`
2. Remove `edition_year` and `edition_month` expectations
3. Add `edition.additional_text` checks where needed
4. Update round-trip expectations to canonical format
5. Mark parser gaps as pending (e.g., volume, supplement variations)

### Phase 2: Fix CommercialStandard Spec (30 min)

**File:** `spec/pubib_new/nist/identifiers/commercial_standard_spec.rb`

**Failures to fix (10):**
- Emergency variant (e104): Edition API
- Volume variant (v#n#): Parser gap
- Edition with year: Edition API

### Phase 3: Fix Other Basic Series (30 min)

**Files:**
- `spec/pubid_new/nist/identifiers/handbook_spec.rb`
- `spec/pubid_new/nist/identifiers/miscellaneous_publication_spec.rb`
- `spec/pubid_new/nist/identifiers/nsrds_spec.rb`

**Common patterns:**
- Edition API alignment
- Round-trip canonical format
- Parser gap documentation

---

## SESSION 263: NIST Spec Alignment - Modern Series (120 min)

### Objective
Fix IR, TN, and other modern series specs.

### Phase 1: Fix InteragencyReport Spec (45 min)

**File:** `spec/pubid_new/nist/identifiers/interagency_report_spec.rb`

**Failures:** Update patterns, revision patterns, language codes

### Phase 2: Fix TechnicalNote Spec (45 min)

**File:** `spec/pubid_new/nist/identifiers/technical_note_spec.rb`

**Failures:** Edition year parsing, update format

### Phase 3: Fix CRPL & Other Specs (30 min)

**Files:**
- `spec/pubid_new/nist/identifiers/crpl_report_spec.rb`
- `spec/pubid_new/nist/identifiers/grant_contractor_report_spec.rb`
- `spec/pubid_new/nist/identifiers/letter_circular_spec.rb`

---

## SESSION 264: Documentation & Completion (60 min)

### Objective
Update README and mark NIST V2 spec alignment complete.

### Part A: Update README.adoc (30 min)

**Add NIST Edition architecture section:**

```asciidoc
==== Edition Component Architecture

NIST uses a unified Edition component that handles:
- Edition numbers: `e2`, `e2021`
- Revision numbers: `r5`, `r1963`
- Historical editions: `-3`
- Edition with additional text: `e2.June1908`

.Edition Patterns
[source,ruby]
----
# Simple edition
id = PubidNew::Nist.parse("NIST SP 800-53r5")
id.edition.type         # => "r"
id.edition.id           # => "5"
id.edition.to_s         # => "r5"

# Edition with additional text (dotted notation)
id = PubidNew::Nist.parse("NBS CIRC 13e2revJune1908")
id.edition.type              # => "e"
id.edition.id                # => "2"
id.edition.additional_text   # => "June1908"
id.edition.to_s              # => "e2.June1908"
id.to_s                      # => "NBS CIRC 13e2.June1908"
----

**Key Architectural Decisions:**
- NO separate Date component for NIST
- Edition handles ALL date/version information via `additional_text`
- Canonical rendering uses DOT separator (never "rev")
- Legacy "rev" patterns parsed and normalized
```

### Part B: Update Memory Bank (20 min)

**File:** `.kilocode/rules/memory-bank/context.md`

Update Session 261 completion and Session 262-264 planning.

### Part C: Archive Session Docs (10 min)

Move completed session docs to `docs/old-docs/sessions/`.

---

## Implementation Status Tracker

### Session 261: Edition Component Spec ✅
- [x] Create edition_spec.rb with 40 tests
- [x] Test all Edition functionality
- [x] Test all rendering formats
- [x] Test integration with parsing
- [x] Document parser gaps (2 pending)
- [x] Validate architecture quality
- **Result:** 40 examples, 38 passing, 2 pending (95%)

### Session 262: Circular & Basic Series (PENDING)
- [ ] Fix Circular spec (25 failures) - 60 min
- [ ] Fix CommercialStandard spec (10 failures) - 30 min
- [ ] Fix Handbook/MP/NSRDS specs - 30 min
- **Target:** 50-60 tests fixed

### Session 263: Modern Series (PENDING)
- [ ] Fix InteragencyReport spec - 45 min
- [ ] Fix TechnicalNote spec - 45 min
- [ ] Fix CRPL & other specs - 30 min
- **Target:** 40-50 tests fixed

### Session 264: Documentation (PENDING)
- [ ] Update README.adoc NIST section - 30 min
- [ ] Update memory bank - 20 min
- [ ] Archive session docs - 10 min
- **Target:** NIST V2 spec alignment COMPLETE

---

## Success Criteria

### Minimum (80%)
- ✅ Edition component spec complete
- ✅ Circular spec aligned with V2 API
- ✅ Basic series specs aligned
- ✅ Modern series specs aligned

### Target (90%)
- ✅ All identifier specs using Edition component API
- ✅ Round-trip tests expecting canonical format
- ✅ Parser gaps documented as pending
- ✅ README updated with Edition architecture

### Stretch (95%+)
- ✅ All non-parser-gap tests passing
- ✅ Comprehensive documentation
- ✅ NIST V2 architecture fully validated

---

## Key Architectural Principles

**MAINTAIN throughout:**
1. **MODEL-DRIVEN** - Edition as Lutaml::Model, not strings
2. **NO Date component** - NIST doesn't use separate Date
3. **Dotted notation** - Canonical format uses dots, not "rev"
4. **Parse legacy, render canonical** - Accept "rev", output dot
5. **Component API** - Use `.type`, `.id`, `.additional_text`
6. **Test correctness** - Update expectations to match V2 behavior

**NEVER compromise** architecture for test pass rate.

---

## Common Fix Patterns

### Pattern 1: Edition String → Edition Component

**Before (V1):**
```ruby
expect(parsed.edition).to eq("2")
```

**After (V2):**
```ruby
expect(parsed.edition).to be_a(PubidNew::Nist::Components::Edition)
expect(parsed.edition.id).to eq("2")
```

### Pattern 2: Legacy Attributes → Component Attributes

**Before (V1):**
```ruby
expect(parsed.edition_year).to eq("1908")
expect(parsed.edition_month).to eq("June")
```

**After (V2):**
```ruby
expect(parsed.edition.additional_text).to eq("June1908")
```

### Pattern 3: Round-Trip Canonical Format

**Before (V1 legacy):**
```ruby
expect(parsed.to_s).to eq("NBS CIRC 13e2revJune1908")
```

**After (V2 canonical):**
```ruby
expect(parsed.to_s).to eq("NBS CIRC 13e2.June1908")
```

### Pattern 4: Mark Parser Gaps as Pending

**If pattern not yet parsed:**
```ruby
# NOTE: Parser doesn't support this pattern yet
xit "parses volume notation" do
  id = PubidNew::Nist.parse("NBS CIRC 539v10")
  expect(id.volume).to eq("10")
end
```

---

## Timeline Summary

| Session | Focus | Duration | Deliverables |
|---------|-------|----------|--------------|
| 262 | Circular & Basic | 120 min | 50-60 tests fixed |
| 263 | Modern Series | 120 min | 40-50 tests fixed |
| 264 | Documentation | 60 min | README, COMPLETE |
| **Total** | **All work** | **300 min** | **V2 Aligned** |

---

**Created:** 2026-01-05
**Sessions Covered:** 262-264
**Status:** Ready for execution
**Estimated Time:** 5 hours (compressed)

**End Goal:** NIST V2 spec alignment complete with Edition component fully integrated! 🎉