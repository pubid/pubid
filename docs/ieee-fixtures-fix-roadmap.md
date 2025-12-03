# IEEE Fixtures Fix Roadmap

**Created:** 2025-12-03 (Session 96)  
**Current Status:** 3,445/10,332 (33.34%)  
**Target Status:** 6,476/10,332 (62.7%) by Session 100  
**Stretch Goal:** 7,006/10,332 (67.8%) by Session 102

---

## Executive Summary

This roadmap outlines a systematic approach to improving IEEE V2 parser from 33.34% to 62.7%+ pass rate through targeted pattern fixes. Each session focuses on a specific high-impact failure pattern.

**Key Insight:** Architecture is sound. All failures are parser gaps or rendering inconsistencies, not design flaws.

---

## Session-by-Session Plan

### Session 97: Fix Unapproved.txt Month & Draft Spacing (90 min)

**Objective:** Fix 872 unapproved identifiers to 99%+ pass rate

**Current:** 1/874 (0.11%)  
**Target:** 873/874 (99.9%)  
**Impact:** +872 identifiers

#### Problem 1: Month Name Format
```ruby
# Current behavior
Expected: "Feb 2007"
Got:      "February, 2007"  # Expanded + comma

Expected: "Mar 2007"
Got:      "March, 2007"
```

**Root Cause:** Date component always renders full month name with comma

**Fix Strategy:**
1. Add `original_format` attribute to Date component
2. Store whether month was abbreviated during parsing
3. Render based on stored format

**Files to modify:**
- `lib/pubid_new/ieee/components/date.rb` (or equivalent)
- `lib/pubid_new/ieee/builder.rb`

**Implementation:**
```ruby
class Date < Lutaml::Model::Serializable
  attribute :year, :integer
  attribute :month, :integer
  attribute :abbreviated_month, :boolean, default: false
  
  def to_s(format: :default)
    return year.to_s unless month
    
    month_str = if abbreviated_month
                  Date::ABBREV_MONTH_NAMES[month]
                else
                  Date::MONTH_NAMES[month]
                end
    
    # No comma for abbreviated format
    abbreviated_month ? "#{month_str} #{year}" : "#{month_str}, #{year}"
  end
end
```

#### Problem 2: Draft Spacing
```ruby
# Current behavior
Expected: "P1234/D12"
Got:      "P1234 /D12"  # Unwanted space before /
```

**Root Cause:** Draft rendering adds space before "/"

**Fix Strategy:**
1. Remove space in draft rendering
2. Verify no space in parser output
3. Test with both P-numbers and regular numbers

**Files to modify:**
- `lib/pubid_new/ieee/identifiers/base.rb` (or wherever draft is rendered)

**Implementation:**
```ruby
# In to_s method
draft_part = draft ? "/D#{draft.value}" : ""  # No space before /
```

#### Testing (15 min)
```bash
bundle exec rspec spec/pubid_new/ieee/fixtures_spec.rb --format documentation | grep "unapproved"
```

**Expected result:** 873/874 (99.9%)

---

### Session 98: Fix "No." Spacing Pattern (90 min)

**Objective:** Fix 1,500+ spacing mismatches in pubid-parsed.txt

**Current:** 3,383/8,818 (38.36%)  
**Target:** 4,883/8,818 (55.4%)  
**Impact:** +1,500 identifiers

#### Problem: Inconsistent "No." Handling
```ruby
# Pattern 1: "No." followed directly by number
Expected: "AIEE No.1C-1954"
Got:      "AIEE No. 1C-1954"  ❌

# Pattern 2: "No " with space before number
Expected: "IEEE Std No 318-1971"
Got:      "IEEE Std 318-1971"  ❌ (removed "No ")
```

**Two Sub-patterns:**
1. **Compact format:** "No." + number (no space)
2. **Standard format:** "No " + number (with space)

#### Root Cause Analysis (20 min)

Check parser and builder:
```bash
bundle exec rspec spec/pubid_new/ieee/parser_spec.rb --format documentation | grep -i "no\."
```

Likely issues:
- Parser captures "No." separately
- Builder doesn't preserve spacing
- Rendering always adds space

#### Fix Strategy (40 min)

**Option A: Store original format**
```ruby
# In Builder
when :std_number
  {
    number: Components::Code.new(value: value[:number]),
    std_prefix: value[:no_format]  # "No." or "No " or nil
  }
```

**Option B: Detect from parsed data**
```ruby
# In Identifier rendering
def number_with_prefix
  return number.to_s unless std_prefix
  
  case std_prefix
  when "No."
    "No.#{number}"  # Compact
  when "No "
    "No #{number}"  # Standard
  else
    number.to_s
  end
end
```

#### Implementation Steps

1. **Enhance parser** (15 min)
   - Capture "No." vs "No " distinction
   - Store in parse tree

2. **Update builder** (10 min)
   - Pass std_prefix to identifier
   - Store as attribute or in number component

3. **Fix rendering** (10 min)
   - Check std_prefix
   - Render accordingly

4. **Test** (5 min)
   ```bash
   bundle exec rspec --format documentation | grep "AIEE No\."
   ```

**Files to modify:**
- `lib/pubid_new/ieee/parser.rb`
- `lib/pubid_new/ieee/builder.rb`
- `lib/pubid_new/ieee/identifiers/base.rb`

#### Testing (30 min)

Spot check problematic identifiers:
```ruby
PubidNew::Ieee.parse("AIEE No.1C-1954").to_s
# Expected: "AIEE No.1C-1954"

PubidNew::Ieee.parse("IEEE Std No 318-1971").to_s
# Expected: "IEEE Std No 318-1971"
```

Run full suite:
```bash
bundle exec rspec spec/pubid_new/ieee/fixtures_spec.rb
```

**Expected result:** 4,883/8,818 on pubid-parsed.txt

---

### Session 99: Add Missing Publishers (90 min)

**Objective:** Support NESC, IRE, ANSI publishers

**Current:** 3,445/10,332 (33.34%)  
**Target:** 3,525/10,332 (34.1%)  
**Impact:** +80 identifiers

#### Publishers to Add

1. **NESC** - National Electrical Safety Code
   - Format: "2017 NESC(R) Handbook"
   - Count: ~50 identifiers
   
2. **IRE** - Institute of Radio Engineers (historical)
   - Format: "52 IRE 7.S2"
   - Count: ~20 identifiers
   - Note: IRE merged into IEEE in 1963

3. **ANSI** - American National Standards Institute
   - Format: "ANSI C63.4-2014"
   - Count: ~10 identifiers

#### Parser Enhancement (40 min)

**Current parser rule:**
```ruby
rule(:publisher) do
  str("IEEE") | str("AIEE") | str("ISO/IEC/IEEE") | str("IEC/IEEE")
end
```

**Enhanced parser rule:**
```ruby
rule(:publisher) do
  str("ISO/IEC/IEEE") |
  str("IEC/IEEE") |
  str("NESC(R)") | str("NESC") |
  str("IEEE") |
  str("AIEE") |
  str("ANSI") |
  str("IRE")
end
```

**Files to modify:**
- `lib/pubid_new/ieee/parser.rb`

#### Special Handling (30 min)

**NESC patterns:**
```ruby
# Year-first pattern
rule(:nesc_identifier) do
  year.as(:year) >> space >> 
  publisher.as(:publisher) >> space >>
  str("Handbook") >> (comma >> space >> edition)?
end
```

**IRE patterns:**
```ruby
# Historical format: "52 IRE 7.S2"
rule(:ire_identifier) do
  digits.as(:historical_year) >> space >>
  str("IRE").as(:publisher) >> space >>
  (digits >> dot >> str("S") >> digits).as(:number)
end
```

#### Builder Updates (10 min)

Add publisher-specific handling:
```ruby
def build(data)
  case data[:publisher]
  when "NESC", "NESC(R)"
    NescIdentifier.new(...)
  when "IRE"
    IreIdentifier.new(...)
  else
    # Standard IEEE handling
  end
end
```

#### Testing (10 min)

```bash
bundle exec rspec spec/pubid_new/ieee/fixtures_spec.rb --format documentation | grep -E "NESC|IRE|ANSI"
```

**Expected result:** +80 successes

---

### Session 100: Make "Std" Optional (120 min)

**Objective:** Parse identifiers without "Std" prefix

**Current:** ~3,525/10,332 (34.1%)  
**Target:** 4,104/10,332 (39.7%)  
**Impact:** +579 identifiers

#### Problem Examples
```ruby
❌ "IEEE 1076-CONC-I99O"
   Parser expects: "IEEE Std 1076-CONC-I99O"

❌ "267A-1980 IEEE International System of Units Conversion"
   Number-first format not recognized
```

#### Strategy: Add Alternative Parser Rules

**Current top-level rule:**
```ruby
rule(:identifier) do
  publisher >> space >> 
  str("Std").maybe >> space? >>
  number >> ...
end
```

**Enhanced with alternatives:**
```ruby
rule(:identifier) do
  # Pattern 1: Standard format (existing)
  standard_identifier |
  
  # Pattern 2: No "Std" prefix
  no_std_identifier |
  
  # Pattern 3: Number-first format
  number_first_identifier
end

rule(:standard_identifier) do
  publisher >> space >> str("Std") >> space >> number >> ...
end

rule(:no_std_identifier) do
  publisher >> space >> 
  (str("Std") >> space).absent? >>  # Negative lookahead
  number >> ...
end

rule(:number_first_identifier) do
  number >> (dash >> year)? >> space >> publisher >> ...
end
```

#### Implementation (60 min)

1. **Refactor parser rules** (30 min)
   - Split identifier into sub-rules
   - Test each pattern independently
   - Use alternatives operator `|`

2. **Test parser changes** (15 min)
   ```ruby
   # Should parse
   PubidNew::Ieee::Parser.new.parse("IEEE 1076-2019")
   PubidNew::Ieee::Parser.new.parse("1234-2020 IEEE")
   ```

3. **Update builder** (10 min)
   - Handle parse tree from all three patterns
   - Normalize to single structure

4. **Fix rendering** (5 min)
   - Decide when to include "Std"
   - Store original format preference

#### Edge Cases (30 min)

**Ambiguity resolution:**
```ruby
# Is this a number-first or type-word?
"Draft 1234-2020"  # Could be interpreted multiple ways
```

**Solution:** Prioritize patterns:
1. Try standard_identifier first
2. Then no_std_identifier
3. Finally number_first_identifier

**Testing priority:** Most common patterns first

#### Integration Testing (30 min)

```bash
# Run full fixtures suite
bundle exec rspec spec/pubid_new/ieee/fixtures_spec.rb

# Focus on pubid-to-parse.txt (where most failures are)
bundle exec rspec spec/pubid_new/ieee/fixtures_spec.rb --format documentation | head -50
```

**Expected result:**
- pubid-to-parse.txt: 61/640 → 640/640 (100%)
- Overall: 3,525/10,332 → 4,104/10,332 (39.7%)

---

### Session 101: Year-First Pattern & Validation (90 min)

**Objective:** Handle "YEAR Publisher..." format and validate progress

**Current:** 4,104/10,332 (39.7%)  
**Target:** 4,134/10,332 (40.0%)  
**Impact:** +30 identifiers

#### Year-First Pattern (45 min)

**Examples:**
```ruby
"1873-2015 IEEE Standard for Robot Map Data Representation"
"2012 NESC Handbook, Seventh Edition"
```

**Parser rule:**
```ruby
rule(:year_first_identifier) do
  year_digits.as(:year) >> (dash >> number.as(:number))? >> space >>
  publisher.as(:publisher) >> space >>
  (str("Standard") | str("Handbook") | ...).as(:type) >>
  ...
end
```

**Implementation:**
1. Add to alternatives in main identifier rule
2. Builder normalizes to standard structure
3. Rendering preserves original order (store flag)

#### Comprehensive Validation (45 min)

Run all tests and analyze:
```bash
bundle exec rspec spec/pubid_new/ieee/fixtures_spec.rb --format documentation > ieee_session_101_results.txt
```

**Analyze results:**
1. Pass rate by file
2. Remaining failure patterns
3. Quick wins vs hard problems

**Create report:**
- Current vs original metrics
- Improvement by session
- Remaining work assessment

**Expected result:** 4,134/10,332 (40.0%)

---

### Session 102: Documentation & Roadmap Update (90 min)

**Objective:** Document achievements and plan next steps

#### Update All Documentation (60 min)

1. **Update context.md**
   - IEEE fixtures validation complete
   - 33.34% → 40%+ achieved
   - Historical formats remain TODO

2. **Update README.adoc**
   - IEEE status: 40%+ fixtures (needs enhancement)
   - Link to fix roadmap
   - Document known limitations

3. **Create IEEE limitations doc**
   - Historical formats (IRE, pre-1980s)
   - Complex bundled identifiers
   - Rare edge cases

#### Assess Remaining Work (30 min)

**Historical Formats (~500 identifiers):**
- Worth 4.8% improvement
- Requires 2-3 sessions
- Low priority (old data)

**Decision:**
- Document as "out of scope for V2.0"
- May address in V2.1 if needed
- Focus on modern identifiers (95%+ coverage)

---

## Priority Matrix

| Fix | Impact | Effort | Priority | Session |
|-----|--------|--------|----------|---------|
| Month/Draft spacing | 872 (8.4%) | 1 | ⭐⭐⭐ | 97 |
| "No." spacing | 1,500 (14.5%) | 1 | ⭐⭐⭐ | 98 |
| Add publishers | 80 (0.8%) | 1 | ⭐⭐ | 99 |
| Make "Std" optional | 579 (5.6%) | 1.5 | ⭐⭐⭐ | 100 |
| Year-first | 30 (0.3%) | 0.5 | ⭐ | 101 |
| Historical | 500 (4.8%) | 3 | ⚪ | Future |

**Legend:**
- ⭐⭐⭐ High priority (High impact, reasonable effort)
- ⭐⭐ Medium priority
- ⭐ Low priority (Low impact or high effort)
- ⚪ Future work

---

## Success Metrics

### By Session

| Session | Pass Rate | Improvement | Cumulative |
|---------|-----------|-------------|------------|
| 96 (baseline) | 33.34% | - | - |
| 97 | 41.78% | +8.44pp | +872 |
| 98 | 56.3% | +14.52pp | +2,372 |
| 99 | 57.1% | +0.8pp | +2,452 |
| 100 | 62.7% | +5.6pp | +3,031 |
| 101 | 63.0% | +0.3pp | +3,061 |

### Overall Project Impact

**Before Session 96:**
- IEEE: 35/35 unit tests (100%)
- IEEE: 3,445/10,332 fixtures (33.34%)
- **Reality check:** Unit tests don't reflect real-world usage

**After Session 101 (Target):**
- IEEE: 35/35 unit tests (100%)
- IEEE: ~6,500/10,332 fixtures (62.9%)
- **Real validation:** Comprehensive fixture testing validates architecture

---

## Risk Assessment

### Low Risk ✅
- Month format fix (localized change)
- Draft spacing fix (localized change)
- Publisher additions (straightforward)

### Medium Risk ⚠️
- "No." spacing (multiple patterns to handle)
- "Std" optional (affects main parser flow)

### High Risk 🚨
- None identified
- Architecture is sound
- All changes are parser enhancements, not redesigns

---

## Architectural Principles (Maintained)

**All fixes MUST:**
1. ✅ Preserve MODEL-DRIVEN architecture
2. ✅ Maintain three-layer separation (Parser/Builder/Identifier)
3. ✅ Use component-based design
4. ✅ Store original format when ambiguous
5. ✅ No hardcoded rendering logic

**All fixes MUST NOT:**
1. ❌ Break existing passing tests
2. ❌ Compromise architecture for quick wins
3. ❌ Add business logic to Parser
4. ❌ Add parsing logic to Identifier

---

## Testing Strategy

### After Each Session

1. **Run fixtures tests:**
   ```bash
   bundle exec rspec spec/pubid_new/ieee/fixtures_spec.rb --format documentation
   ```

2. **Check for regressions:**
   ```bash
   bundle exec rspec spec/pubid_new/ieee/ --format progress
   ```

3. **Spot check specific patterns:**
   ```ruby
   # Test in console
   require "./lib/pubid_new/ieee"
   id = PubidNew::Ieee.parse("pattern to test")
   puts id.to_s
   ```

### Final Validation (Session 102)

1. Run all IEEE tests
2. Compare to baseline (Session 96)
3. Document improvement
4. Update all relevant docs

---

## Conclusion

**IEEE V2 can realistically achieve 60-65% pass rate within 6 sessions through systematic parser enhancements.**

**Key Insight:** The 66.66% failure rate is NOT due to architectural problems. It's due to:
1. Parser not recognizing legitimate alternate formats
2. Minor rendering inconsistencies
3. Historical formats intentionally out of scope

**Once high-priority fixes are complete, IEEE V2 will be production-ready for modern identifiers (95%+ of active use cases).**

---

## Next Session

**Session 97:** Start with unapproved.txt fixes (month format + draft spacing)

**Target:** 873/874 (99.9%) on unapproved.txt

**Expected:** 1.5 hours