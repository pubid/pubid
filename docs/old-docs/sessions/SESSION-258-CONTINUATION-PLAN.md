# Session 259+ Continuation Plan: NIST Architectural Refactoring

**Created:** 2026-01-05 (Post-Session 258)
**Status:** Session 258 complete - Architectural issue identified
**Timeline:** 6-8 hours across 3 sessions (Sessions 259-261)

---

## Executive Summary

**Session 258 Discovery:** NIST V2 has a FUNDAMENTAL architectural flaw in its data model that conflates Edition and Date components.

**Current Status:**
- **NIST:** 391/606 passing (64.5%)
- **Issue:** Edition and Date are conflated in the data model
- **Root Cause:** `edition_year`, `edition_month` attributes create ambiguity
- **Solution:** Separate Edition and Date as independent components

**Impact:** This is NOT a rendering bug or parser gap - it's an architectural issue requiring major refactoring.

---

## Critical Understanding (from nist-pubid-spec.md + user clarifications)

### Official Spec Format

**Edition component:**
```
<edition> = <edition-type><edition-id>
<edition-type> = "-" | "e" | "r"
<edition-id> = {1-9} | yyyy
```

- `e2` = Edition 2 (number)
- `e2021` = Edition identified by year 2021
- `r5` = Revision 5
- `-3` = Historical hyphen format

**Date component (SEPARATE from edition):**
```
Dates appear after report number as: -{YYYY} or -{YYYYMM} or -{YYYYMMDD}
```

**Key Insight:** Edition and Date are INDEPENDENT and can BOTH exist!

### Corrected Examples

| Input | Components | Output |
|-------|-----------|--------|
| `NBS CIRC 13e2-1908` | number=13, edition=e2, date=1908 | `NBS CIRC 13e2-1908` |
| `NBS CIRC 13e2revJune1908` | number=13, edition=e2, date=190806 | `NBS CIRC 13e2-190806` |
| `NBS CIRC 15-April1909` | number=15, date=190904 | `NBS CIRC 15-190904` |
| `NIST HB 150-1e2021` | number=150-1, edition=e2021 | `NIST HB 150-1e2021` |
| `CS 190-58` | number=190-58, (infer publisher=NBS) | `NBS CS 190-58` |

**From spec Table 1 (page 7):**
- `NIST HB 150-1e2021-upd3 ipd spa` = report `150-1`, edition `e2021`, update `upd3`, stage `ipd`, translation `spa`

### V2's Current Wrong Model

```ruby
# WRONG - Conflates edition ID with document date
attribute :edition, :string          # "2"
attribute :edition_year, :string     # "1908" or "2021" - AMBIGUOUS!
attribute :edition_month, :string    # "June"
```

Problems:
1. `edition_year` could be edition ID (`e2021`) OR document date (`-1908`)
2. Can't have both edition AND date
3. Rendering logic has to guess intent
4. Legacy "rev" notation can't be normalized properly

### V2's Correct Model Should Be

```ruby
# CORRECT - Separate components
attribute :edition, Components::Edition  # Edition(type: "e|r|-", id: "2|2021|5")
attribute :date, Components::Date        # Date(year: "1908", month: "04", day: nil)
```

Benefits:
1. Edition and Date are independent
2. Both can coexist in same identifier
3. Rendering is straightforward
4. Legacy normalization is clean

---

## Session 259: Edition Component Foundation (2 hours)

### Objective
Create proper Edition component and begin Base refactoring

### Phase 1: Create Edition Component (60 min)

**Create** `lib/pubid_new/nist/components/edition.rb`:

```ruby
# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Nist
    module Components
      # NIST Edition Component
      # Spec: <edition> = <edition-type><edition-id>
      # Types: "-" (historical), "e" (edition), "r" (revision)
      # ID: number (e.g., "2", "5") or year (e.g., "2021")
      class Edition < Lutaml::Model::Serializable
        attribute :type, :string  # "-", "e", or "r"
        attribute :id, :string    # "2", "5", "2021", etc.

        def to_s(format = :short)
          case format
          when :long
            case type
            when "e"
              id.match?(/^\d{4}$/) ? "Edition #{id}" : "Edition #{id}"
            when "r"
              "Revision #{id}"
            when "-"
              "-#{id}"
            end
          when :short, :mr
            "#{type}#{id}"
          end
        end
      end
    end
  end
end
```

**Create** `spec/pubid_new/nist/components/edition_spec.rb`:

```ruby
require "spec_helper"

RSpec.describe PubidNew::Nist::Components::Edition do
  describe "#to_s" do
    it "renders edition with number" do
      edition = described_class.new(type: "e", id: "2")
      expect(edition.to_s).to eq("e2")
    end

    it "renders edition with year" do
      edition = described_class.new(type: "e", id: "2021")
      expect(edition.to_s).to eq("e2021")
    end

    it "renders revision" do
      edition = described_class.new(type: "r", id: "5")
      expect(edition.to_s).to eq("r5")
    end

    it "renders historical hyphen format" do
      edition = described_class.new(type: "-", id: "3")
      expect(edition.to_s).to eq("-3")
    end
  end
end
```

**Test:**
```bash
bundle exec rspec spec/pubid_new/nist/components/edition_spec.rb
```

### Phase 2: Begin Base Refactoring (60 min)

**Update** `lib/pubid_new/nist/identifiers/base.rb`:

1. Add require for Edition component (line 12):
```ruby
require_relative "../components/edition"
```

2. Add new attributes (after line 30):
```ruby
# V3 COMPONENTS (CORRECT model)
attribute :edition_component, Components::Edition
attribute :date_component, Components::Date
```

3. Keep old attributes for now (backward compatibility during transition)

4. Add helper method (end of class):
```ruby
# NEW: Alias for backward compatibility
def edition_new
  edition_component
end

def date_new
  date_component
end
```

**DO NOT change rendering yet** - just add the foundation.

**Test:** Ensure existing tests still pass
```bash
bundle exec rspec spec/pubid_new/nist/identifiers/base_spec.rb
```

### Success Criteria
- ✅ Edition component created with tests
- ✅ Base has new attributes added
- ✅ Existing tests still pass (no regressions)
- ✅ Foundation ready for parser/builder work

---

## Session 260: Parser & Builder (3 hours)

### Objective
Update parser and builder to use new Edition and Date components

### Phase 1: Parser Enhancement (90 min)

**Update** `lib/pubid_new/nist/parser.rb`:

**Add edition rules:**
```ruby
rule(:edition_type) { str("e") | str("r") | str("-") }
rule(:edition_id) { match("[0-9]").repeat(1) }  # number or year
rule(:edition) do
  edition_type.as(:edition_type) >> edition_id.as(:edition_id)
end
```

**Add date rules:**
```ruby
rule(:date) do
  dash >>
  (
    # YYYYMMDD
    digits.repeat(4, 4).as(:year) >> digits.repeat(2, 2).as(:month) >> digits.repeat(2, 2).as(:day) |
    # YYYYMM
    digits.repeat(4, 4).as(:year) >> digits.repeat(2, 2).as(:month) |
    # YYYY
    digits.repeat(4, 4).as(:year)
  )
end
```

**Handle legacy "rev" notation:**
```ruby
rule(:legacy_rev) do
  str("rev") >> month_name.as(:month) >> year_digits.as(:year)
end

# In main identifier rule, normalize legacy to modern
```

### Phase 2: Builder Update (90 min)

**Update** `lib/pubid_new/nist/builder.rb`:

```ruby
def build_edition(parsed)
  return nil unless parsed[:edition_type] && parsed[:edition_id]

  Components::Edition.new(
    type: parsed[:edition_type].to_s,
    id: parsed[:edition_id].to_s
  )
end

def build_date(parsed)
  return nil unless parsed[:year]

  # Convert month name to number if needed
  month = parsed[:month]
  if month && month.is_a?(String) && month.match?(/[A-Za-z]/)
    month = month_name_to_number(month)
  end

  Components::Date.new(
    year: parsed[:year].to_s,
    month: month&.to_s,
    day: parsed[:day]&.to_s
  )
end

def month_name_to_number(name)
  {
    "January" => "01", "February" => "02", "March" => "03",
    "April" => "04", "May" => "05", "June" => "06",
    "July" => "07", "August" => "08", "September" => "09",
    "October" => "10", "November" => "11", "December" => "12",
    "Jan" => "01", "Feb" => "02", "Mar" => "03",
    "Apr" => "04", "Jun" => "06", "Jul" => "07",
    "Aug" => "08", "Sep" => "09", "Oct" => "10",
    "Nov" => "11", "Dec" => "12"
  }[name] || name
end
```

### Success Criteria
- ✅ Parser captures edition separately
- ✅ Parser captures date separately
- ✅ Builder constructs Edition objects
- ✅ Builder constructs Date objects
- ✅ Legacy "rev" normalizes to modern format

---

## Session 261: Rendering & Test Updates (2 hours)

### Objective
Update rendering logic and test expectations

### Phase 1: Update Rendering (30 min)

**Update** `lib/pubid_new/nist/identifiers/base.rb` `to_short_style`:

Replace lines 198-213 with:
```ruby
# Edition component (NEW - clean logic)
if edition_component
  result += edition_component.to_s
end

# Date component (NEW - separate from edition)
if date_component
  result += "-"
  result += date_component.year
  result += date_component.month if date_component.month
  result += date_component.day if date_component.day
end
```

### Phase 2: Update Test Expectations (90 min)

**For each failing test:**

1. Identify if it expects old attributes (`edition_year`) or new (`edition_component`)
2. Update expectation to use new component API
3. Verify round-trip correctness

**Pattern:**
```ruby
# OLD (wrong)
expect(parsed.edition).to eq("2")
expect(parsed.edition_year).to eq("1908")

# NEW (correct)
expect(parsed.edition_component.type).to eq("e")
expect(parsed.edition_component.id).to eq("2")
expect(parsed.date_component.year).to eq("1908")
```

### Success Criteria
- ✅ NIST: 85%+ passing (515+/606)
- ✅ All tests use correct component API
- ✅ Legacy patterns normalize correctly
- ✅ Round-trip fidelity maintained

---

## Files to Modify

### New Files (Session 259)
- `lib/pubid_new/nist/components/edition.rb`
- `spec/pubid_new/nist/components/edition_spec.rb`

### Modified Files
**Session 259:**
- `lib/pubid_new/nist/identifiers/base.rb` (add new attributes)

**Session 260:**
- `lib/pubid_new/nist/parser.rb` (edition/date rules)
- `lib/pubid_new/nist/builder.rb` (construct components)

**Session 261:**
- `lib/pubid_new/nist/identifiers/base.rb` (rendering logic)
- All NIST spec files (update expectations)

---

## Success Metrics

### Per Session
**Session 259:**
- Edition component: 100% passing
- Base refactoring: 0 regressions

**Session 260:**
- Parser tests: 80%+ passing
- Builder tests: 80%+ passing

**Session 261:**
- NIST overall: 85%+ passing (515+/606)
- Component API: 100% correct usage

### Overall (Sessions 259-261)
- ✅ Edition and Date are separate components
- ✅ Both can coexist in identifier
- ✅ Legacy normalization works
- ✅ Spec compliance validated
- ✅ 85%+ tests passing

---

## Key Architectural Principles

**MAINTAIN throughout:**
1. **MODEL-DRIVEN** - Edition and Date are Lutaml::Model objects
2. **Separation of Concerns** - Edition ≠ Date
3. **Spec Compliance** - Follow nist-pubid-spec.md exactly
4. **Backward Compatibility** - Keep old attributes during transition
5. **Incremental Testing** - Test after each phase

**NEVER:**
- Conflate edition ID with document date
- Guess whether year is edition or date
- Skip proper component modeling

---

## Next Immediate Steps (Session 259)

1. Read this continuation plan
2. Create Edition component with tests
3. Add new attributes to Base
4. Verify no regressions
5. Commit foundation work

---

**Created:** 2026-01-05
**Sessions Covered:** 259-261
**Status:** Ready for execution
**Estimated Time:** 6-8 hours total (split across 3 sessions)

**End Goal:** NIST with correct Edition/Date architecture, 85%+ tests passing! 🎯