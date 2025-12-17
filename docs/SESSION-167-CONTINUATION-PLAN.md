# Session 167+ Continuation Plan: CEN Architecture Enhancement

**Created:** 2025-12-17 (Post-Session 166)
**Status:** CSA at 95.78%, ready for CEN enhancement
**Timeline:** COMPRESSED - Complete CEN in 1-2 sessions (90-120 min)

---

## Executive Summary

**Session 166 Achievement:** CSA enhanced from 86.57% to 95.78% (+9.21pp) ✅

**Current Status:**
- **CSA:** 863/901 (95.78%) ✅ TARGET EXCEEDED
- **CEN:** 61/71 (85.92%) - Ready for architecture enhancement
- **Overall:** 87,707/88,924 (98.63%)

**CEN Remaining Issues:** 10 failures requiring proper MODEL-DRIVEN architecture

---

## CEN Architecture Requirements (OBJECT-ORIENTED)

### Issue 1: Special Dash Characters (5 failures)
**Examples:**
```
FprEN 50600‑2‑4  (special dash: ‑ U+2011)
EN 527­2:2016    (soft hyphen: ­ U+00AD)
```

**Solution:** Preprocessing normalization (not architecture change)
```ruby
# In parser.rb preprocessing
normalized = normalized.gsub(/[\u2011\u00AD]/, "-")  # Normalize all dash variants
```

**Expected gain:** +2 identifiers

---

### Issue 2: Amendment Identifier Class (3 failures)
**Examples:**
```
EN 60335-1:2012/A1
EN 60335-1:2012/A14
EN 60335-1:2012/A15
```

**Architecture:** New **AmendmentIdentifier** class (proper supplement pattern)

**Files to create:**
```
lib/pubid_new/cen/identifiers/amendment.rb
```

**Class structure:**
```ruby
class Amendment < SupplementIdentifier
  attribute :base_identifier, Standard
  attribute :number, :string          # "1", "14", "15"

  def to_s
    "#{base_identifier}/A#{number}"
  end
end
```

**Parser enhancement:**
```ruby
rule(:amendment_identifier) do
  base_identifier.as(:base) >>
  slash >> str("A") >> digits.as(:amendment_number)
end
```

**Expected gain:** +3 identifiers

---

### Issue 3: Date Component Enhancement (2 failures)
**Examples:**
```
EN 61375-2-3:2015/AC:2016-11
EN ISO 13485:2016/AC:2016 (first corrigendum)
```

**Architecture:** Enhance **Date component** to support month format

**Files to modify:**
```
lib/pubid_new/components/date.rb (shared component)
lib/pubid_new/cen/parser.rb
```

**Component enhancement:**
```ruby
class Date < Lutaml::Model::Serializable
  attribute :year, :integer
  attribute :month, :integer, default: -> { nil }  # NEW

  def to_s
    month ? "#{year}-#{month.to_s.rjust(2, '0')}" : year.to_s
  end
end
```

**Parser enhancement:**
```ruby
rule(:year_with_month) do
  year_digits.as(:year) >> dash >> month_digits.as(:month)
end

rule(:date) { year_with_month | year_digits.as(:year) }
```

**Expected gain:** +2 identifiers
**Note:** Parenthetical notes like "(first corrigendum)" can be filtered in preprocessing

---

### Issue 4: BundledIdentifier with Plus Sign (1 failure)
**Example:**
```
EN 527­2:2016+A1:2019
```

**Architecture:** Use existing **BundledIdentifier** pattern (already in CEN)

**Parser enhancement:**
```ruby
rule(:bundled_identifier) do
  base_identifier.as(:base) >>
  plus >>
  supplement_portion.as(:bundled_with)
end

rule(:plus) { str("+") >> space.maybe }
```

**Expected gain:** +1 identifier

---

### Issue 5: FragmentIdentifier Class (2 failures)
**Example:**
```
EN 60038 AMD1 FRAG2
```

**Architecture:** New **FragmentIdentifier** class with base as AmendmentIdentifier

**Files to create:**
```
lib/pubid_new/cen/identifiers/fragment.rb
```

**Class structure:**
```ruby
class Fragment < Lutaml::Model::Serializable
  attribute :base_identifier, Amendment  # Base is Amendment!
  attribute :fragment_number, :string     # "2"

  def to_s
    "#{base_identifier} FRAG#{fragment_number}"
  end
end
```

**Parser enhancement:**
```ruby
rule(:fragment_identifier) do
  base_identifier.as(:base) >>
  space >> str("AMD") >> digits.as(:amendment_number) >>
  space >> str("FRAG") >> digits.as(:fragment_number)
end
```

**Builder logic:**
```ruby
def build_fragment(parsed)
  # First build amendment identifier
  amendment = Amendment.new(
    base_identifier: build_base(parsed[:base]),
    number: parsed[:amendment_number]
  )

  # Then wrap in fragment
  Fragment.new(
    base_identifier: amendment,
    fragment_number: parsed[:fragment_number]
  )
end
```

**Expected gain:** +2 identifiers

---

## Implementation Plan

### Session 167: CEN Architecture Enhancement (90 min)

**Phase 1: Preprocessing & Date Component** (25 min)
1. Add dash character normalization (5 min)
2. Enhance Date component with month support (15 min)
3. Test date parsing (5 min)

**Phase 2: Amendment Identifier** (20 min)
1. Create `identifiers/amendment.rb` class (10 min)
2. Add parser rule for amendments (5 min)
3. Update builder routing (5 min)

**Phase 3: BundledIdentifier** (10 min)
1. Add plus sign rule to parser (5 min)
2. Test bundled pattern (5 min)

**Phase 4: Fragment Identifier** (25 min)
1. Create `identifiers/fragment.rb` class (15 min)
2. Add parser rule for fragments (5 min)
3. Update builder routing (5 min)

**Phase 5: Testing & Validation** (10 min)
1. Run CEN classification
2. Verify 100% or near-100%
3. Document results

**Expected Result:** CEN 68-71/71 (95.8-100%)

---

## Success Criteria

### Minimum Success (90%)
- ✅ CEN: 64+/71 (90%+)
- ✅ Dash normalization working
- ✅ Amendment class implemented
- ✅ Date component with month

### Target Success (95%)
- ✅ CEN: 68+/71 (95.8%+)
- ✅ All 5 architecture patterns working
- ✅ Fragment identifier implemented

### Stretch Success (100%)
- ✅ CEN: 71/71 (100%)
- ✅ Complete MODEL-DRIVEN architecture
- ✅ Zero parser hacks

---

## Architecture Quality

**MAINTAINED throughout:**
- ✅ MODEL-DRIVEN: Identifiers as objects (Amendment, Fragment classes)
- ✅ MECE: Each class handles distinct patterns
- ✅ Component pattern: Shared Date component enhanced
- ✅ Wrapper pattern: Fragment wraps Amendment
- ✅ Separation of concerns: Parser/Builder/Identifier independence
- ✅ Open/Closed: Easy to add new types without modifying existing

---

## Key Principles

1. **Amendment = Supplement Pattern**
   - Like ISO/IEC Amendment and Corrigendum
   - Proper class inheritance from SupplementIdentifier
   - NO string manipulation in parser

2. **Fragment = Wrapper Pattern**
   - Wraps Amendment identifier as base
   - Recursive object composition
   - Fragment of an Amendment, not of a Standard

3. **Date = Component Enhancement**
   - Shared component across flavors
   - Month is optional attribute
   - Rendering handles both formats

4. **Bundled = Existing Pattern**
   - Already used in CSA and ISO
   - Just add plus sign variant
   - No new architecture needed

5. **Normalization = Preprocessing Only**
   - Character normalization is NOT architecture
   - Keep in parser preprocessing
   - Filter notes like "(first corrigendum)"

---

## Files to Create

1. `lib/pubid_new/cen/identifiers/amendment.rb`
2. `lib/pubid_new/cen/identifiers/fragment.rb`

## Files to Modify

1. `lib/pubid_new/components/date.rb` - Add month support
2. `lib/pubid_new/cen/parser.rb` - Add rules for all 5 patterns
3. `lib/pubid_new/cen/builder.rb` - Add routing for new classes
4. `lib/pubid_new/cen.rb` - Add requires

---

## Session 168 (Optional): Documentation (30 min)

Only if time permits:

1. Update README.adoc with Session 166-167 results
2. Move old session docs to docs/old-docs/sessions/
3. Update memory bank context.md

---

**Created:** 2025-12-17
**Sessions Covered:** 167-168
**Status:** Ready for execution
**Goal:** CEN 95.8-100% with proper MODEL-DRIVEN architecture

**End Goal:** All quick wins complete, ready for IEEE comprehensive work! 🚀