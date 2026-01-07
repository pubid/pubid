# Session 259 Continuation Prompt

## Critical Context - READ THIS FIRST

**Session 258 completed architectural analysis** of NIST V2 and discovered a FUNDAMENTAL DATA MODEL ISSUE that requires major refactoring.

**Critical Discovery:**

NIST V2 currently conflates Edition and Date components, but they are SEPARATE and can BOTH exist according to the official NIST spec.

## Current State (Session 258 Complete)

### NIST Test Results
- **Total:** 606 examples
- **Passing:** 391 (64.5%)
- **Failing:** 215 (35.5%)
- **Issue:** V2 data model is architecturally wrong

### Critical Architectural Problem Identified

**Current WRONG data model:**
```ruby
attribute :edition, :string          # "2"
attribute :edition_year, :string     # "1908"
attribute :edition_month, :string    # "June"
```

This conflates:
- Edition ID (which CAN be a year like `e2021`)
- Document date (which is SEPARATE like `-1908`)

**CORRECT data model should be:**
```ruby
attribute :edition, Components::Edition  # Edition(type: "e", id: "2" or "2021")
attribute :date, Components::Date        # Date(value: "1908" or "190904")
```

### Official Spec Rules (nist-pubid-spec.md)

**Edition component:**
- Format: `<edition-type><edition-id>`
- Types: `-` (historical), `e` (edition), `r` (revision)
- Edition ID can be: number (`e2`) OR year (`e2021`)

**Date component:**
- Format: `-{YYYY}` or `-{YYYYMM}` or `-{YYYYMMDD}`
- Separate from edition
- NO "e" prefix!

**BOTH can exist:**
- `NIST HB 150-1e2021-upd3` = number `150-1`, edition `e2021`, update `upd3`
- `NBS CIRC 13e2-1908` = number `13`, edition `e2`, date `1908`

### Corrected Examples

| Legacy Input | Components | Modern Rendering |
|--------------|-----------|------------------|
| `NBS CIRC 13e2-1908` | edition=e2, date=1908 | `NBS CIRC 13e2-1908` |
| `NBS CIRC 13e2revJune1908` | edition=e2, date=190806 | `NBS CIRC 13e2-190806` |
| `NBS CIRC 15-April1909` | date=190904 | `NBS CIRC 15-190904` |
| `NIST HB 150-1e2021` | edition=e2021 | `NIST HB 150-1e2021` |
| `NBS CIRC 25sup-1924` | supplement, date=1924 | `NBS CIRC 25sup-1924` |

### V2 Current Behavior

V2 incorrectly parses `e2-1908` as:
- `edition = "2"`
- `edition_year = "1908"`

Then renders it incorrectly as `e2e1908` or has broken logic.

## Session 259 Objectives

### Primary Goal
Implement proper Edition and Date components as separate entities

### Success Criteria
- ✅ Edition component properly models `e{id}` or `r{id}`
- ✅ Date component properly models `-{YYYY[MM[DD]]}`
- ✅ Both can coexist in same identifier
- ✅ Legacy `revJune1908` normalizes to `-190806`
- ✅ 85%+ NIST tests passing (515+/606)

## Implementation Roadmap (6-8 hours across multiple sessions)

### Session 259: Edition Component Foundation (2 hours)

**Phase 1: Create Edition Component (60 min)**
1. Create `lib/pubid_new/nist/components/edition.rb`
2. Implement `Edition(type, id)` with proper to_s
3. Add unit tests

**Phase 2: Update Base Identifier (60 min)**
1. Update `lib/pubid_new/nist/identifiers/base.rb`
2. Replace `edition_year`, `edition_month` attributes
3. Add proper `edition` and `date` components
4. Update rendering logic

**Deliverable:** Foundation for proper Edition/Date separation

### Session 260: Parser & Builder (3 hours)

**Phase 1: Parser Enhancement (90 min)**
1. Update parser to capture edition separately
2. Update parser to capture date separately
3. Handle legacy "rev" notation normalization

**Phase 2: Builder Update (90 min)**
1. Construct proper Edition objects
2. Construct proper Date objects
3. Handle all edge cases

**Deliverable:** Parser and Builder working with new model

### Session 261: Test Updates & Validation (2 hours)

**Phase 1: Update Test Expectations (90 min)**
1. Update all test expectations for new attributes
2. Fix API mismatch issues
3. Document remaining parser gaps

**Phase 2: Validation (30 min)**
1. Run full NIST test suite
2. Validate 85%+ passing rate
3. Document remaining issues

**Deliverable:** NIST at 85%+ with correct architecture

## Files to Modify

### New Files
- `lib/pubid_new/nist/components/edition.rb` (new Edition component)

### Modified Files
- `lib/pubid_new/nist/identifiers/base.rb` (data model changes)
- `lib/pubid_new/nist/parser.rb` (parse edition/date separately)
- `lib/pubid_new/nist/builder.rb` (construct components)
- All NIST spec files (update expectations)

## Key Architectural Principles

**MAINTAIN throughout:**
1. **MODEL-DRIVEN** - Edition and Date are objects, not strings
2. **MECE** - Edition and Date are mutually exclusive types
3. **Three-layer** - Parser/Builder/Identifier independence
4. **Spec compliance** - Follow nist-pubid-spec.md exactly
5. **No conflation** - Edition ID ≠ Edition year ≠ Document date

## Critical Reminders

- **Edition ID can be a year** (e.g., `e2021`)
- **Date is separate** (e.g., `-1908`)
- **Both can coexist** (e.g., `e2-1908`)
- **Legacy "rev" normalizes** (`revJune1908` → `-190806`)
- **"r" is revision type**, not "rev"

---

## Next Steps (Session 259)

1. Read this continuation prompt
2. Create Edition component
3. Begin Base identifier refactoring
4. Test foundation incrementally

---

**Created:** 2026-01-05
**Sessions Covered:** 259-261
**Status:** Ready for execution
**Estimated Time:** 6-8 hours total

**End Goal:** NIST V2 with correct Edition/Date architecture, 85%+ tests passing! 🎯