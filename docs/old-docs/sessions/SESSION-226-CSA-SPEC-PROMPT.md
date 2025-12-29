# Session 226 Quick Start: CSA Core Identifier Specs

**Read these files FIRST:**
1. `docs/SESSION-226-CSA-SPEC-PLAN.md` - Comprehensive plan
2. `.kilocode/rules/memory-bank/architecture.md` - Architecture principles
3. `.kilocode/rules/memory-bank/context.md` - Current status

---

## Session 226 Objective

Create 4 core CSA identifier spec files (~100 tests total).

**Timeline:** 120 minutes

---

## Pre-Session Checklist

✅ Read continuation plan
✅ Read 3-5 CSA identifier implementation files:
   - `lib/pubid_new/csa/identifiers/standard.rb`
   - `lib/pubid_new/csa/identifiers/series.rb` 
   - `lib/pubid_new/csa/identifiers/bundled.rb`
   - `lib/pubid_new/csa/identifiers/combined.rb`
   - `lib/pubid_new/csa/single_identifier.rb`

✅ Review CSA fixtures for test examples:
   - `spec/fixtures/csa/identifiers/pass/standard.txt`
   - `spec/fixtures/csa/identifiers/full/identifiers.txt`

---

## Tasks (4 parts)

**Part A:** `standard_spec.rb` (30 min, ~25-30 tests)
**Part B:** `series_spec.rb` (25 min, ~20 tests)
**Part C:** `bundled_spec.rb` (30 min, ~25 tests)
**Part D:** `combined_spec.rb` (35 min, ~30 tests)

---

## Critical CSA-Specific Patterns

### 1. Year Formats (MUST preserve)
```
Colon: CSA B149.1:20  # Modern format
Dash:  CSA C22.1-15   # Legacy format
```

### 2. HB (Handbook) Suffix (NEW Session 225 fix)
```
CSA C22.1HB-18        # Letter + number + HB
CSA C22.1CIICHB-18    # Multi-letter suffix
CSA B149HB:15         # HB with colon year
CSA 15189HB:25        # Pure number + HB (NEW!)
B651HB-18             # No CSA prefix
```

### 3. 2-Digit Year Conversion
```
Input:  :25    Output: :25   (Stored internally: 2025)
Input:  -18    Output: -18   (Stored internally: 2018)
```

### 4. NO. Notation
```
CSA C22.2 NO. 286:23          # Code + NO. + number + year
CSA C22.2 NO. 60601-1:14      # Complex NO. number
```

---

## Test Template Pattern

```ruby
require "spec_helper"

RSpec.describe PubidNew::Csa::Identifiers::Standard do
  context "basic standards" do
    describe "CSA B149.1:20" do
      subject { "CSA B149.1:20" }
      let(:parsed) { PubidNew::Csa.parse(subject) }

      it "parses as Standard" do
        expect(parsed).to be_a(described_class)
      end

      it "parses code" do
        expect(parsed.code.value).to eq("B149.1")
      end

      it "parses year" do
        expect(parsed.year).to eq("2020")
      end

      it "uses colon format" do
        expect(parsed.year_format).to eq("colon")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end
  end
end
```

---

## Directory Setup

**First create directories:**
```bash
mkdir -p spec/pubid_new/csa/identifiers
mkdir -p spec/pubid_new/csa/components
```

---

## Testing After Each File

```bash
# After each spec file creation
bundle exec rspec spec/pubid_new/csa/identifiers/standard_spec.rb

# Full CSA suite
bundle exec rspec spec/pubid_new/csa/

# Show summary
bundle exec rspec spec/pubid_new/csa/ --format documentation
```

---

## Expected Progress

**After Part A:** ~25 tests (Standard)
**After Part B:** ~45 tests (Standard + Series)
**After Part C:** ~70 tests (Standard + Series + Bundled)
**After Part D:** ~100 tests (All 4 core types)

**Target pass rate:** 80-90%

---

## Critical Reminders

1. **No mocking/stubbing** - Test real behavior
2. **Use actual fixture examples** - From pass/ directories
3. **Test round-trip** - Parse → render must match
4. **One spec at a time** - Test after each file
5. **Architecture first** - Correctness over test count

---

## Ready to Start?

1. Create spec directories
2. Start with Part A: standard_spec.rb
3. Follow test template pattern
4. Test after each file
5. Commit progress

**Go!** 🚀
