# Session 51 Prompt - IEC Component Specifications

**Status:** READY TO BEGIN  
**Priority:** CRITICAL (BLOCKS V1 REMOVAL)  
**Duration:** 60 minutes  
**Goal:** Create 3 IEC identifier spec files (component specs)

---

## Context from Session 50

Session 50 completed comprehensive spec audit revealing **27 missing spec files** across 4 flavors that BLOCK V1 removal.

**Critical Finding:** IEC has 20 missing specs (9% coverage) - the largest blocker.

**Overall Gap:**
- IEC: 20 missing (9% coverage) - CRITICAL
- IEEE: 4 missing (43% coverage) - HIGH
- NIST: 3 missing + test migration (50% coverage) - SPECIAL CASE
- ISO: 0 missing (105% coverage) - COMPLETE ✅

**References:**
- [`docs/SPEC_MIGRATION_MATRIX.md`](docs/SPEC_MIGRATION_MATRIX.md:1) - Complete gap analysis
- [`docs/CONTINUATION_PLAN_V2_COMPLETE.md`](docs/CONTINUATION_PLAN_V2_COMPLETE.md:1) - 8-session roadmap
- [`docs/SESSION_50_SUMMARY.md`](docs/SESSION_50_SUMMARY.md:1) - Audit findings

---

## Session 51 Goal

**Create 3 IEC identifier spec files:**

1. **component_specification_spec.rb** - Component specifications (IEC 60050 series)
2. **conformity_assessment_spec.rb** - Conformity assessment documents
3. **consolidated_identifier_spec.rb** - Consolidated amendments (wrapper type)

**Expected:** ~150-200 test cases total (50-70 per spec)

---

## Implementation Strategy

### Step 1: Read Implementation Files (15 min)

Read the 3 identifier classes to understand their structure:

```bash
<read_file>
<args>
<file><path>lib/pubid_new/iec/identifiers/component_specification.rb</path></file>
<file><path>lib/pubid_new/iec/identifiers/conformity_assessment.rb</path></file>
<file><path>lib/pubid_new/iec/identifiers/consolidated_identifier.rb</path></file>
</args>
</read_file>
```

**Understand:**
- Class inheritance (probably from Base or InternationalStandard)
- TYPED_STAGES arrays
- Specialized attributes
- to_s rendering logic

### Step 2: Check V1 Coverage (10 min)

Search V1 tests for examples:

```bash
# Search V1 fixtures for component, conformity, consolidated patterns
grep -r "component\|conformity\|consolidated" gems/pubid-iec/spec/ | head -20
```

**Look for:**
- V1 test patterns to migrate
- Edge cases to include
- Known parsing challenges

### Step 3: Create Spec Files (25 min)

For each identifier, create comprehensive spec with:

**Standard Structure:**
```ruby
require "spec_helper"
require_relative "../../../../lib/pubid_new"

RSpec.describe PubidNew::Iec::Identifiers::{ClassName} do
  describe ".parse" do
    context "basic patterns" do
      # Simple identifiers
    end

    context "with stages" do
      # Draft stages, iterations
    end

    context "with parts" do
      # Part numbers, subparts
    end

    context "edge cases" do
      # Complex patterns
    end

    context "round-trip parsing" do
      # Parse → to_s verification
    end
  end

  describe "#to_s" do
    # Rendering tests
  end
end
```

**Test Coverage:**
- Basic parsing (15-20 cases)
- Stage variations (10-15 cases)
- Parts/versions (10-15 cases)
- Edge cases (10-15 cases)
- Round-trip (10-15 cases)

### Step 4: Run and Fix (10 min)

Run each spec as you create it:

```bash
bundle exec rspec spec/pubid_new/iec/identifiers/component_specification_spec.rb
bundle exec rspec spec/pubid_new/iec/identifiers/conformity_assessment_spec.rb
bundle exec rspec spec/pubid_new/iec/identifiers/consolidated_identifier_spec.rb
```

**Fix issues:**
- Parser patterns
- Builder logic
- Identifier rendering

---

## Test Pattern Examples

### Example 1: Basic Parsing

```ruby
it "parses basic component specification" do
  id = PubidNew::Iec.parse("IEC 60050-102:2007")
  expect(id).to be_a(PubidNew::Iec::Identifiers::ComponentSpecification)
  expect(id.number.value).to eq("60050")
  expect(id.part.value).to eq("102")
  expect(id.to_s).to eq("IEC 60050-102:2007")
end
```

### Example 2: Stage Variations

```ruby
it "parses draft component specification" do
  id = PubidNew::Iec.parse("IEC/CD 60050-102")
  expect(id.typed_stage.abbreviation).to eq("CD")
  expect(id.to_s).to eq("IEC/CD 60050-102")
end
```

### Example 3: Consolidated Amendments

```ruby
it "parses consolidated identifier with amendments" do
  id = PubidNew::Iec.parse("IEC 60050:2007+AMD1:2010 CSV")
  expect(id).to be_a(PubidNew::Iec::Identifiers::ConsolidatedIdentifier)
  expect(id.to_s).to eq("IEC 60050:2007+AMD1:2010 CSV")
end
```

---

## Success Criteria

✅ 3 spec files created in `spec/pubid_new/iec/identifiers/`  
✅ Each spec has 50-70 test cases minimum  
✅ All tests passing (or failures documented)  
✅ Round-trip parsing verified  
✅ Edge cases covered

---

## Expected Outcomes

**After Session 51:**
- IEC coverage: 9% → 23% (5/22 classes)
- 3 new spec files created
- ~150-200 test cases added
- Progress toward IEC completion: 15% (3/20 missing)

**Remaining for IEC:**
- Sessions 52-56: 17 more specs (85% of IEC work)
- Total IEC effort: 6 sessions

---

## Common Pitfalls to Avoid

❌ Don't copy ISO tests directly - IEC has different patterns  
❌ Don't skip edge cases - they catch most bugs  
❌ Don't create specs without reading implementation first  
❌ Don't assume parser works - verify with real examples  
❌ Don't commit failing tests - fix or document first

✅ Do read implementation classes thoroughly  
✅ Do check V1 fixtures for patterns  
✅ Do create comprehensive test coverage  
✅ Do verify round-trip parsing  
✅ Do document known limitations

---

## Quick Start Commands

```bash
# Navigate to project
cd /Users/mulgogi/src/mn/pubid

# Read implementation files
<read_file>
<args>
<file><path>lib/pubid_new/iec/identifiers/component_specification.rb</path></file>
<file><path>lib/pubid_new/iec/identifiers/conformity_assessment.rb</path></file>
<file><path>lib/pubid_new/iec/identifiers/consolidated_identifier.rb</path></file>
</args>
</read_file>

# Check V1 for patterns
grep -r "60050\|component" gems/pubid-iec/spec/ | head -10

# Create first spec
# (Use write_to_file after drafting content)

# Run specs
bundle exec rspec spec/pubid_new/iec/identifiers/component_specification_spec.rb
```

---

## After Session 51

**Document progress:**
1. Update [`docs/SPEC_MIGRATION_MATRIX.md`](docs/SPEC_MIGRATION_MATRIX.md:1) - Mark 3 specs complete
2. Create `docs/SESSION_51_SUMMARY.md` - Document findings
3. Update coverage percentages

**Plan Session 52:**
- Next 3 IEC specs: corrigendum, fragment_identifier, guide
- Target: ~150-200 more test cases
- Continue systematic IEC migration

---

## Key Reminders

1. **Each spec is critical** - These fill gaps that BLOCK V1 removal
2. **IEC is the largest blocker** - 20 missing specs must be completed
3. **Quality over speed** - Comprehensive coverage prevents future issues
4. **Document as you go** - Unknown patterns should be noted
5. **Round-trip is mandatory** - Parse → Object → String must work

Good luck with Session 51! 🚀

---

## Reference Links

- Implementation: `lib/pubid_new/iec/identifiers/`
- Existing specs: `spec/pubid_new/iec/identifiers/` (amendment, international_standard)
- V1 fixtures: `gems/pubid-iec/spec/`
- Architecture docs: `.kilocode/rules/memory-bank/architecture.md`