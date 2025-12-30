# Session 230 Quick Start: CSA Parser Enhancement

**Read Plan First:** [`docs/SESSION-230-CSA-PARSER-FIX-PLAN.md`](SESSION-230-CSA-PARSER-FIX-PLAN.md:1)

---

## Pre-Session Checklist

✅ Read comprehensive plan (SESSION-230-CSA-PARSER-FIX-PLAN.md)
✅ Review Session 228 results (8/8 specs, 367 tests, 67.8% pass)
✅ Understand 118 failures breakdown (7 categories)

---

## Session 230 Objective

Fix high-impact parser/builder issues for 88%+ pass rate in 120 minutes.

**Phase:** Parser & Builder Enhancement
**Session:** 230 of compressed roadmap

---

## Part A: Dash Year Separation (40 min)

**Current Problem:**
```ruby
# Wrong:
parsed.code.number  # => "C22.1-15" (includes year!)
parsed.year         # => nil

# Correct:
parsed.code.number  # => "C22.1"
parsed.year         # => "2015"
```

**Fix in:** `lib/pubid_new/csa/parser.rb` (lines ~80-95)

**Parser change:**
```ruby
rule(:code_with_year) do
  # Separate captures for code and year
  code_pattern.as(:code) >> dash >> two_digit_year.as(:year)
end
```

**Builder change:** `lib/pubid_new/csa/builder.rb`
```ruby
def cast(type, value)
  when :code
    # If code has dash-year, extract it
    if value.to_s =~ /^([A-Z]?[\d.]+)-(\d{2})$/
      { code: $1, year: convert_two_digit_year($2) }
    else
      Components::Code.new(number: value.to_s)
    end
end
```

**Test:**
```bash
bundle exec rspec spec/pubid_new/csa/identifiers/standard_spec.rb -e "C22.1-15"
```

**Expected:** +30 tests passing

---

## Part B: CAN/CSA Type Routing (30 min)

**Current Problem:**
```ruby
# Wrong:
parsed = PubidNew::Csa.parse("CAN/CSA-A123.2-03")
parsed.class  # => Standard (WRONG!)

# Correct:
parsed.class  # => CanadianAdopted
```

**Fix in:** `lib/pubid_new/csa/builder.rb` (class selection logic)

**Builder change:**
```ruby
def select_identifier_class(parsed_hash)
  # Check for CAN/CSA- or CAN3- prefix FIRST
  return Identifiers::CanadianAdopted if parsed_hash[:can_prefix] || parsed_hash[:can3_prefix]
  
  # Then other checks...
  # ... existing logic
end
```

**Test:**
```bash
bundle exec rspec spec/pubid_new/csa/identifiers/canadian_adopted_spec.rb
```

**Expected:** +20 tests passing (cumulative: 299/367, 81.5%)

---

## Part C: Package/Series Classification (40 min)

**Current Problem:**
```ruby
# Wrong:
parsed = PubidNew::Csa.parse("CSA B149.1:25 PACKAGE")
parsed.class  # => Standard (WRONG!)

# Correct:
parsed.class  # => Package
```

**Fix in:** `lib/pubid_new/csa/builder.rb` (class selection logic)

**Builder change:**
```ruby
def select_identifier_class(parsed_hash)
  # Check for PACKAGE/SERIES markers
  return Identifiers::Package if parsed_hash[:package_materials]
  return Identifiers::Series if parsed_hash[:series_prefix]
  
  # Check for CAN/CSA- or CAN3- prefix
  return Identifiers::CanadianAdopted if parsed_hash[:can_prefix] || parsed_hash[:can3_prefix]
  
  # Default to Standard
  Identifiers::Standard
end
```

**Test:**
```bash
bundle exec rspec spec/pubid_new/csa/identifiers/package_spec.rb
bundle exec rspec spec/pubid_new/csa/identifiers/series_spec.rb
```

**Expected:** +25 tests passing (cumulative: 324/367, 88.3%!)

---

## Part D: Final Validation (10 min)

**Run full test suite:**
```bash
bundle exec rspec spec/pubid_new/csa/
```

**Expected Results:**
- **Before:** 249/367 (67.8%)
- **After:** 324/367 (88.3%)
- **Gain:** +75 tests (+20.5pp)

**Verify:**
- ✅ No regressions in passing tests
- ✅ Fixture classification maintained (879/903)
- ✅ Architecture integrity preserved

---

## Testing Strategy

**After each fix:**
1. Run affected spec file
2. Verify expected gain
3. Check no new failures
4. Commit if successful

**Incremental commits:**
- After Priority 1: "fix(csa): separate dash-year in code parsing"
- After Priority 2: "fix(csa): route CAN/CSA to CanadianAdopted"
- After Priority 3: "fix(csa): classify Package and Series types"

---

## Critical Reminders

**MECE Class Selection:**
```ruby
def select_identifier_class(parsed_hash)
  # Order matters - most specific first!
  return Package if parsed_hash[:package_materials]
  return Series if parsed_hash[:series_prefix]
  return CanadianAdopted if parsed_hash[:can_prefix] || parsed_hash[:can3_prefix]
  return CsaAdopted if parsed_hash[:iso_prefix]
  return Bundled if parsed_hash[:bundled_with]
  return Combined if parsed_hash[:second_identifier]
  
  Standard  # Default
end
```

**Year Conversion:**
```ruby
def convert_two_digit_year(yy)
  year = yy.to_i
  year < 50 ? (2000 + year).to_s : (1900 + year).to_s
end
```

**Architecture:**
- ✅ MODEL-DRIVEN throughout
- ✅ Parser handles syntax only
- ✅ Builder handles transformation only
- ✅ Identifiers handle rendering only

---

## Expected Progress

| Priority | Tests | Cumulative | Pass Rate |
|----------|-------|------------|-----------|
| Baseline | 249 | 249/367 | 67.8% |
| Priority 1 (+30) | 279 | 279/367 | 76.0% |
| Priority 2 (+20) | 299 | 299/367 | 81.5% |
| Priority 3 (+25) | 324 | 324/367 | 88.3% |

**Target achieved:** 88.3% > 80% minimum ✅

---

## Next Session Preview

**Session 231** (optional) will focus on:
- French detection (+5 tests)
- NO. separation (+10 tests)
- Composite routing (+15 tests)
- Target: 96.5% (354/367)

---

## Files to Read

**Before starting:**
1. `lib/pubid_new/csa/parser.rb` - Understand current parsing
2. `lib/pubid_new/csa/builder.rb` - Understand class selection
3. `spec/pubid_new/csa/identifiers/standard_spec.rb` - See failing patterns

---

**Created:** 2025-12-29
**Timeline:** 120 minutes
**Phase:** High-impact fixes
**Target:** 88.3% (324/367 tests)

**Ready to fix CSA test failures!** 🚀
