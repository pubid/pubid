# Session 146 Continuation Prompt

**Session:** 146
**Focus:** ASTM IsoDualPublishedIdentifier Implementation
**Duration:** 90 minutes
**Prerequisites:** Session 145 complete (ASTM at 100% parsing)

---

## Objective

Implement IsoDualPublishedIdentifier as a proper semantic type for ASTM standards that are dual-published with ISO (5xxxx series).

Then finish ASME identifiers!

**Current Issue:**
- Standards like `ASTM 52303-24e1` are parsed as generic digit-only standards
- These are actually ASTM's version of ISO/ASTM dual-published documents
- ISO publishes them as `ISO/ASTM 52303:2024`

---

## Implementation Steps

### Step 1: Read Context (5 min)

**Read memory bank:**
- `.kilocode/rules/memory-bank/context.md` - Session 145 completion
- `.kilocode/rules/memory-bank/architecture.md` - V2 architecture
- `docs/SESSION-146-CONTINUATION-PLAN.md` - Full plan

**Read current implementation:**
- `lib/pubid_new/astm/parser.rb` - Lines 173-189 (digit-only pattern)
- `lib/pubid_new/astm/builder.rb` - Type routing logic
- `lib/pubid_new/astm/identifiers/standard.rb` - Current standard class

---

### Step 2: Create IsoDualPublishedIdentifier Class (30 min)

**File:** `lib/pubid_new/astm/identifiers/iso_dual_published.rb`

**Template:**
```ruby
# frozen_string_literal: true

module PubidNew
  module Astm
    module Identifiers
      class IsoDualPublished < SingleIdentifier
        # SEMANTIC NOTE: ISO/ASTM dual-published standards
        # ASTM version: ASTM 52303-24e1 (e1 = edition 1, not "E" prefix)
        # ISO version: ISO/ASTM 52303:2024
        # Distinguishing feature: Starts with digit (typically 5xxxx series)

        def to_s
          parts = []
          parts << publisher.to_s if publisher
          parts << code.number

          if date
            parts << "-#{date}"
            parts << sub_year if sub_year
            parts << "(#{reapproval.year})" if reapproval
            parts << "e#{editorial}" if editorial
          end

          parts.join
        end
      end
    end
  end
end
```

**Actions:**
1. Create file with proper structure
2. Inherit from SingleIdentifier
3. Add semantic comment documenting ISO/ASTM relationship
4. Implement to_s for rendering (same as Standard currently)
5. Don't add implicit "E" - preserve digit-only

---

### Step 3: Update Builder Type Routing (30 min)

**File:** `lib/pubid_new/astm/builder.rb`

**Find determine_identifier_class method** (around line 10-30)

**Add routing logic:**
```ruby
def determine_identifier_class(attributes)
  type = attributes[:type]&.to_s&.upcase

  # Check digit-only for ISO/ASTM dual-published (5xxxx series)
  if attributes[:number] && attributes[:number].to_s.match?(/^\d+$/)
    # If starts with 5, likely ISO/ASTM dual-published
    if attributes[:number].to_s.start_with?("5")
      return Identifiers::IsoDualPublished
    end
    # Other digit-only might still be Standard
    return Identifiers::Standard
  end

  case type
  when "RR" then Identifiers::ResearchReport
  when "TR" then Identifiers::TechnicalReport
  when "MNL" then Identifiers::Manual
  when "MONO" then Identifiers::Monograph
  when "DS" then Identifiers::DataSeries
  when "WK" then Identifiers::WorkInProgress
  when "ADJ" then Identifiers::Adjunct
  else
    Identifiers::Standard
  end
end
```

**Actions:**
1. Add IsoDualPublished routing for 5xxxx patterns
2. Keep Standard as fallback for other digit-only
3. Test with sample inputs

---

### Step 4: Add Tests (25 min)

**File:** `spec/pubid_new/astm/identifiers/iso_dual_published_spec.rb`

**Test all 6 patterns:**
```ruby
require "spec_helper"

RSpec.describe PubidNew::Astm::Identifiers::IsoDualPublished do
  subject { described_class }

  describe "ISO/ASTM dual-published standards" do
    context "ASTM 52303-24e1" do
      subject { "ASTM 52303-24e1" }
      let(:parsed) { PubidNew::Astm.parse(subject) }

      it "parses as IsoDualPublished" do
        expect(parsed).to be_a(described_class)
      end

      it "parses number" do
        expect(parsed.code.number).to eq("52303")
      end

      it "parses year" do
        expect(parsed.date.to_s).to eq("24")
      end

      it "parses edition" do
        expect(parsed.editorial).to eq("1")
      end

      it "round-trips" do
        expect(parsed.to_s).to eq(subject)
      end
    end

    # Test remaining 5 patterns...
  end
end
```

**Actions:**
1. Create spec file
2. Add test for each of 6 dual-published patterns
3. Verify round-trip
4. Run tests: `bundle exec rspec spec/pubid_new/astm/identifiers/iso_dual_published_spec.rb`

---

### Step 5: Validate (5 min)

**Run full test suite:**
```bash
bundle exec rspec spec/pubid_new/astm/identifier_spec.rb
cd spec/fixtures && ruby run_classify.rb astm
```

**Expected:**
- All tests passing
- 248/248 still at 100%
- 6 identifiers now properly typed as IsoDualPublished

---

## Success Criteria

- ✅ IsoDualPublishedIdentifier class created
- ✅ Builder routes 5xxxx patterns correctly
- ✅ 6 tests passing for all dual-published patterns
- ✅ Round-trip fidelity maintained
- ✅ Zero regression (still 248/248)
- ✅ Semantic model now domain-accurate

---

## Next Session Preview

**Session 147** will implement Adjunct semantic model with proper base_standard reference and designation separation.

---

**Created:** 2025-12-15
**Ready for:** Session 146 execution
**Estimated Time:** 90 minutes