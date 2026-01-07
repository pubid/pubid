# Session 273+ Continuation Plan: NIST Volume & Part Components Implementation

**Created:** 2026-01-06 (Post-Session 272)
**Status:** CSM architecture requires Volume and Part as separate Lutaml::Model components
**Timeline:** COMPRESSED - Complete in 2-3 sessions (4-6 hours total)

---

## Executive Summary

**Architectural Issue Discovered:** NIST currently embeds Volume and Part into Code component, violating MODEL-DRIVEN and MECE principles.

**Current (INCORRECT):**
```ruby
# CSM v6n1 stored as:
code.number = "v6"  # Volume embedded in number
code.part = "1"     # Issue embedded in part
# Renders: "NBS CSM v6pt1"
```

**Required (CORRECT):**
```ruby
# CSM v6n1 should be:
volume.value = "6"  # Proper Volume component
part.value = "1"    # Proper Part component
# Renders: "NBS CSM v6n1"
```

**Scope:** This affects CSM series primarily, but Volume and Part are semantic concepts that should be separate components across ALL NIST series for proper extensibility.

---

## Architectural Violations

### Current Problems

1. **Code component overloaded** - Stores Volume AND Part values
2. **Lost semantics** - "v6" is a Volume, not a generic number
3. **Rendering hardcoded** - Code.to_s forces "pt" notation
4. **Not extensible** - Cannot distinguish Volume from regular numbers

### Required Architecture (MODEL-DRIVEN)

**Each semantic concept = One Lutaml::Model component:**

| Concept | Component Class | Example Value | Rendering |
|---------|----------------|---------------|-----------|
| Volume | Components::Volume | value="6" | `v6` |
| Part | Components::Part | value="1" | `n1` |
| Edition | Components::Edition | type="e", id="2" | `e2` |
| Number | Components::Code | number="800-53" | `800-53` |

---

## SESSION 273: Create Volume & Part Components (120 minutes)

### Objective
Implement proper Volume and Part Lutaml::Model components with full rendering support.

### Phase 1: Create Volume Component (30 min)

**File:** `lib/pubid_new/nist/components/volume.rb` (NEW)

```ruby
# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Nist
    module Components
      # Volume component for NIST publications
      # Format: v{NUMBER} where NUMBER is the volume number
      #
      # Examples:
      #   Volume.new(value: "6").to_s => "v6"
      #   Volume.new(value: "12").to_s => "v12"
      #
      # Used in:
      #   - CSM (Commercial Standards Monthly): Volume 6, Issue 1
      #   - CIRC (Circular): Volume 539
      class Volume < Lutaml::Model::Serializable
        attribute :value, :string

        def to_s
          "v#{value}"
        end

        # Alias for numeric comparison
        def to_i
          value.to_i
        end
      end
    end
  end
end
```

**Test file:** `spec/pubid_new/nist/components/volume_spec.rb` (NEW)

```ruby
require "spec_helper"

RSpec.describe PubidNew::Nist::Components::Volume do
  describe "#to_s" do
    it "renders with v prefix" do
      volume = described_class.new(value: "6")
      expect(volume.to_s).to eq("v6")
    end

    it "handles multi-digit volumes" do
      volume = described_class.new(value: "12")
      expect(volume.to_s).to eq("v12")
    end
  end

  describe "#to_i" do
    it "converts to integer for comparison" do
      volume = described_class.new(value: "6")
      expect(volume.to_i).to eq(6)
    end
  end
end
```

### Phase 2: Create Part Component (30 min)

**File:** `lib/pubid_new/nist/components/part.rb` (NEW)

```ruby
# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Nist
    module Components
      # Part component for NIST publications
      # Format: n{NUMBER} or pt{NUMBER} depending on context
      #
      # Rendering modes:
      #   - :n_notation => "n1" (CSM issue notation)
      #   - :pt_notation => "pt1" (SP part notation)
      #
      # Examples:
      #   Part.new(value: "1").to_s(:n_notation) => "n1"
      #   Part.new(value: "1").to_s(:pt_notation) => "pt1"
      #
      # Used in:
      #   - CSM: Issue number (n1)
      #   - SP: Part number (pt1)
      #   - Other series with part subdivisions
      class Part < Lutaml::Model::Serializable
        attribute :value, :string

        # Render part with specified notation
        # @param notation [:n_notation, :pt_notation] The notation style
        # @return [String] The formatted part representation
        def to_s(notation = :n_notation)
          case notation
          when :n_notation
            "n#{value}"
          when :pt_notation
            "pt#{value}"
          else
            "n#{value}"
          end
        end

        # Alias for numeric comparison
        def to_i
          value.to_i
        end
      end
    end
  end
end
```

**Test file:** `spec/pubid_new/nist/components/part_spec.rb` (NEW)

```ruby
require "spec_helper"

RSpec.describe PubidNew::Nist::Components::Part do
  describe "#to_s" do
    context "with n_notation (default)" do
      it "renders with n prefix" do
        part = described_class.new(value: "1")
        expect(part.to_s).to eq("n1")
        expect(part.to_s(:n_notation)).to eq("n1")
      end
    end

    context "with pt_notation" do
      it "renders with pt prefix" do
        part = described_class.new(value: "1")
        expect(part.to_s(:pt_notation)).to eq("pt1")
      end
    end

    it "handles multi-digit parts" do
      part = described_class.new(value: "12")
      expect(part.to_s(:n_notation)).to eq("n12")
      expect(part.to_s(:pt_notation)).to eq("pt12")
    end
  end

  describe "#to_i" do
    it "converts to integer for comparison" do
      part = described_class.new(value: "1")
      expect(part.to_i).to eq(1)
    end
  end
end
```

### Phase 3: Update Builder (40 min)

**File:** `lib/pubid_new/nist/builder.rb`

**Add requires:**
```ruby
require_relative "components/volume"
require_relative "components/part"
```

**Update cast method (around line 260-270):**

```ruby
when :volume_number
  # Volume from v#n# pattern - return Volume component
  return nil if value.nil? || value.to_s.strip.empty?
  { volume: Components::Volume.new(value: value.to_s) }

when :issue_number
  # Issue number from v#n# pattern - return Part component
  return nil if value.nil? || value.to_s.strip.empty?
  { part: Components::Part.new(value: value.to_s) }

when :first_number, :second_number
  return nil if value.nil? || value.to_s.strip.empty?

  # Handle v#n# pattern (CSM series) - comes as hash from parser
  # Return Volume and Part components separately
  if value.is_a?(Hash) && value[:volume_number] && value[:issue_number]
    volume_num = value[:volume_number].to_s
    issue_num = value[:issue_number].to_s
    return {
      volume: Components::Volume.new(value: volume_num),
      part: Components::Part.new(value: issue_num)
    }
  end
```

### Phase 4: Update CommercialStandardsMonthly (20 min)

**File:** `lib/pubid_new/nist/identifiers/commercial_standards_monthly.rb`

**Update attributes and rendering:**

```ruby
class CommercialStandardsMonthly < Base
  def publisher
    "NBS"
  end

  def series
    "CSM"
  end

  def to_s
    result = "#{publisher} #{series}"

    # Proper Volume and Part components
    if volume && part
      result += " #{volume}#{part.to_s(:n_notation)}"
    # Legacy: Code-based number
    elsif number
      result += " #{number}"
    end

    result
  end
end
```

---

## SESSION 274: Update Other NIST Series for Part Component (90 minutes)

### Objective
Migrate Special Publication and other series to use proper Part component instead of Code.part.

### Phase 1: Update SpecialPublication (40 min)

**File:** `lib/pubid_new/nist/identifiers/special_publication.rb`

Currently uses Code.part for patterns like `SP 800-57pt1r5`.

**Update to use Part component:**
```ruby
def to_s
  result = "#{publisher} #{series}"

  # Number (e.g., "800-57")
  result += " #{number.number}" if number

  # Part component with pt notation
  result += "#{part.to_s(:pt_notation)}" if part

  # Edition (revision)
  result += "#{edition.to_s}" if edition

  result
end
```

### Phase 2: Audit Other Series (30 min)

**Check these identifier classes for Code.part usage:**
1. InteragencyReport
2. TechnicalNote
3. FIPS
4. Others

**Update each to use Part component with appropriate notation.**

### Phase 3: Update Builder Part Handling (20 min)

**File:** `lib/pubid_new/nist/builder.rb`

**Update part extraction logic (around line 754-769):**

```ruby
when :part
  # Special handling for :part - extract part number
  return nil if value.nil? || value.to_s.strip.empty?

  str_value = value.to_s.strip

  # Pattern: "1adde1" → part="1", addendum=true
  if str_value =~ /^(\d+)add/
    {
      part: Components::Part.new(value: $1),
      addendum: "true"
    }
  else
    # Just a part number - return Part component
    { part: Components::Part.new(value: str_value) }
  end
```

---

## SESSION 275: Testing & Documentation (90 minutes)

### Objective
Comprehensive testing and documentation updates.

### Phase 1: Update Test Expectations (40 min)

**Files to update:**

1. **CSM tests** - Expect Volume and Part components
```ruby
# spec/pubid_new/nist/identifiers/commercial_standards_monthly_spec.rb
it "parses v6n1 with Volume and Part components" do
  csm = described_class.parse("NBS CSM v6n1")
  expect(csm.volume).to be_a(PubidNew::Nist::Components::Volume)
  expect(csm.volume.value).to eq("6")
  expect(csm.part).to be_a(PubidNew::Nist::Components::Part)
  expect(csm.part.value).to eq("1")
  expect(csm.to_s).to eq("NBS CSM v6n1")
end
```

2. **SP tests** - Expect Part component with pt notation
3. **Other series tests** - Update as needed

### Phase 2: Update README.adoc (30 min)

**File:** `README.adoc`

**Add CSM architecture section:**

```asciidoc
===== CSM Volume-Issue Architecture ✨

Commercial Standards Monthly uses separate Volume and Part components:

.CSM Component Structure
[source,ruby]
----
csm = PubidNew::Nist.parse("NBS CSM v6n1")

# Components (MODEL-DRIVEN):
csm.volume.value  # => "6" (Volume component)
csm.part.value    # => "1" (Part component)

# Rendering:
csm.to_s          # => "NBS CSM v6n1"
----

**Architecture:**
- **Volume component** - Dedicated Lutaml::Model class for volume numbers
- **Part component** - Dedicated Lutaml::Model class with dual notation
  * `:n_notation` => "n1" (CSM issue format)
  * `:pt_notation` => "pt1" (SP part format)
- **MECE separation** - Volume, Part, Edition are distinct components
- **Series-specific rendering** - CSM uses n-notation, SP uses pt-notation

.Part Notation Across NIST Series
[cols="2,2,2"]
|===
|Series |Part Component |Notation

|CSM
|Issue number
|n-notation (`v6n1`)

|SP
|Part number
|pt-notation (`800-57pt1r5`)

|Other
|Part subdivision
|pt-notation (default)
|===
```

### Phase 3: Update Memory Bank (20 min)

**File:** `.kilocode/rules/memory-bank/context.md`

Add Session 273-275 completion summary.

---

## Implementation Status Tracker

### Session 273: Component Creation ✅ (after execution)
- [ ] Create Volume component (`lib/pubid_new/nist/components/volume.rb`)
- [ ] Create Part component (`lib/pubid_new/nist/components/part.rb`)
- [ ] Create Volume spec (`spec/pubid_new/nist/components/volume_spec.rb`)
- [ ] Create Part spec (`spec/pubid_new/nist/components/part_spec.rb`)
- [ ] Update Builder requires
- [ ] Update Builder cast for volume_number
- [ ] Update Builder cast for issue_number
- [ ] Update Builder cast for first_number v#n# pattern
- [ ] Update CommercialStandardsMonthly to use Volume/Part
- [ ] Tests: Volume spec, Part spec passing

### Session 274: Series Migration ✅ (after execution)
- [ ] Update SpecialPublication to use Part component
- [ ] Update InteragencyReport (if uses parts)
- [ ] Update TechnicalNote (if uses parts)
- [ ] Update FIPS (if uses parts)
- [ ] Update Base identifier (if has part attribute)
- [ ] Update Builder part cast to return Part component
- [ ] Tests: All series tests passing

### Session 275: Testing & Documentation ✅ (after execution)
- [ ] Update CSM test expectations (Volume/Part components)
- [ ] Update SP test expectations (Part component)
- [ ] Update other series test expectations
- [ ] Update README.adoc with CSM architecture
- [ ] Update memory bank with Sessions 273-275
- [ ] Archive Session 272 documentation
- [ ] Final validation

---

## Architecture Principles

### MECE Component Separation

**Each semantic concept gets its own component:**

```ruby
# ✅ CORRECT - Separate components
class CommercialStandardsMonthly < Base
  attribute :volume, Components::Volume
  attribute :part, Components::Part
  attribute :edition, Components::Edition
end

# ❌ WRONG - Overloaded Code component
class CommercialStandardsMonthly < Base
  attribute :number, Components::Code  # Contains volume AND part!
end
```

### Component Rendering Responsibilities

**Each component knows how to render itself:**

```ruby
# Volume component
class Volume
  def to_s
    "v#{value}"  # Always renders with v prefix
  end
end

# Part component
class Part
  def to_s(notation = :n_notation)
    notation == :pt_notation ? "pt#{value}" : "n#{value}"
  end
end
```

### Identifier Composition

**Identifiers compose components:**

```ruby
class CommercialStandardsMonthly < Base
  def to_s
    result = "#{publisher} #{series}"
    result += " #{volume}#{part.to_s(:n_notation)}" if volume && part
    result
  end
end

class SpecialPublication < Base
  def to_s
    result = "#{publisher} #{series}"
    result += " #{number.number}" if number
    result += "#{part.to_s(:pt_notation)}" if part  # SP uses pt-notation
    result += "#{edition}" if edition
    result
  end
end
```

---

## Success Criteria

### Session 273 (Components)
- ✅ Volume component created with tests (100% passing)
- ✅ Part component created with tests (100% passing)
- ✅ Builder updated to return Volume/Part components
- ✅ CSM uses Volume/Part components
- ✅ CSM renders `v6n1` correctly
- ✅ Zero regressions in other tests

### Session 274 (Migration)
- ✅ SP uses Part component with pt-notation
- ✅ Other series migrated as needed
- ✅ All series tests passing or documented
- ✅ Architecture clean and MECE
- ✅ No Code.part usage remaining

### Session 275 (Documentation)
- ✅ All test expectations updated
- ✅ README.adoc comprehensively documents architecture
- ✅ Memory bank updated
- ✅ Old docs archived
- ✅ Project documentation complete

---

## Files to Create

### Session 273
1. `lib/pubid_new/nist/components/volume.rb` (NEW)
2. `lib/pubid_new/nist/components/part.rb` (NEW)
3. `spec/pubid_new/nist/components/volume_spec.rb` (NEW)
4. `spec/pubid_new/nist/components/part_spec.rb` (NEW)

### Session 275
1. `docs/old-docs/sessions/session-272-summary.md` (NEW)

## Files to Modify

### Session 273
1. `lib/pubid_new/nist/builder.rb` - Add Volume/Part component casting
2. `lib/pubid_new/nist/identifiers/commercial_standards_monthly.rb` - Use Volume/Part
3. `lib/pubid_new/nist/identifiers/base.rb` - Add Volume/Part attributes (if needed)

### Session 274
1. `lib/pubid_new/nist/identifiers/special_publication.rb` - Use Part component
2. `lib/pubid_new/nist/builder.rb` - Update part cast
3. Other identifier classes as needed

### Session 275
1. `spec/pubid_new/nist/identifiers/commercial_standards_monthly_spec.rb` - Update expectations
2. `spec/pubid_new/nist/identifiers/special_publication_spec.rb` - Update expectations
3. `README.adoc` - Add CSM architecture documentation
4. `.kilocode/rules/memory-bank/context.md` - Update with Sessions 273-275

---

## Key Architectural Insights

### Why Separate Components Matter

**1. Semantic Clarity:**
- Volume ≠ Number ≠ Part
- Each has distinct meaning in standards domain
- Proper modeling enables correct processing

**2. Extensibility:**
- Easy to add Volume to other series (CIRC has volumes)
- Part notation can vary by series (n vs pt)
- Components can evolve independently

**3. MECE Compliance:**
- No overlap between Volume/Part/Number/Edition
- Each component handles exactly one responsibility
- Collectively exhaustive for all NIST patterns

**4. Rendering Flexibility:**
- Part component supports multiple notations
- Series can choose appropriate notation
- No hardcoded rendering logic in identifiers

---

## Example Usage (After Implementation)

```ruby
# CSM with Volume and Part
csm = PubidNew::Nist.parse("NBS CSM v6n1")
csm.volume        # => <Volume value="6">
csm.part          # => <Part value="1">
csm.volume.value  # => "6"
csm.part.value    # => "1"
csm.to_s          # => "NBS CSM v6n1"

# SP with Part (pt notation)
sp = PubidNew::Nist.parse("NIST SP 800-57pt1r5")
sp.number.number  # => "800-57"
sp.part           # => <Part value="1">
sp.part.to_s(:pt_notation)  # => "pt1"
sp.edition.type   # => "r"
sp.edition.id     # => "5"
sp.to_s           # => "NIST SP 800-57pt1r5"

# CIRC with Volume (if used)
circ = PubidNew::Nist.parse("NBS CIRC 539v10")
circ.number.number  # => "539"
circ.volume         # => <Volume value="10">
circ.to_s           # => "NBS CIRC 539v10"
```

---

## Risk Mitigation

### Low Risk
- Component creation (follow Edition pattern)
- Basic testing (proven pattern)

### Medium Risk
- Builder changes affecting other series
- Test regressions during migration

### Mitigation Strategy
1. **Incremental implementation** - One component at a time
2. **Test after each change** - Immediate regression detection
3. **Component specs first** - Validate components work before integration
4. **Limited scope** - Start with CSM, expand gradually

---

## Timeline Summary

| Session | Focus | Duration | Deliverables |
|---------|-------|----------|--------------|
| 273 | Volume & Part components | 120 min | 2 components, CSM updated |
| 274 | Series migration | 90 min | SP + others using Part |
| 275 | Testing & docs | 90 min | Complete, documented |
| **Total** | **All work** | **300 min (5 hrs)** | **Complete** |

---

## Next Immediate Steps (Session 273)

1. Read this continuation plan fully
2. Create Volume component with tests (Phase 1)
3. Create Part component with tests (Phase 2)
4. Update Builder for Volume/Part (Phase 3)
5. Update CommercialStandardsMonthly (Phase 4)
6. Test CSM parsing and rendering
7. Commit progress with semantic message

---

**Created:** 2026-01-06
**Sessions Covered:** 273-275
**Status:** Ready for execution
**Estimated Time:** 5 hours (compressed, 3 sessions)

**End Goal:** Proper MODEL-DRIVEN architecture with Volume, Part, Edition as separate Lutaml::Model components! 🎯