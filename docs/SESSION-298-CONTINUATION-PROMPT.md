# Session 298: BSI Expert Commentary Quick Win

**Date:** January 9, 2026  
**Status:** Ready to Execute  
**Estimated Time:** 45 minutes

## Context

**BSI V2 Progress:**
- Overall: 1,294/1,632 (79.29%)
- Integration Tests: 47/47 passing (100%) ✅
- Unit Tests: 174/174 passing (100%) ✅

**Previous Sessions:**
- Session 294: Documentation + 78.74% coverage
- Session 295: Integration test fixes (47/47 passing)
- Session 296: CEN CR discovery (already implemented)
- Session 297: Continuation plan created

## Objective

Fix Expert Commentary identifier to achieve 100% coverage (11/25 → 25/25 patterns).

**Impact:** +14 patterns (+0.86% overall coverage)

## Task Details

### Step 1: Read Expert Commentary Fixture (5 min)

```bash
cat spec/fixtures/bsi/identifiers/full/expert_commentary.txt
```

**Understand Patterns:**
- Standard format: `BS 7671:2008 Expert commentary`
- Adoption format: `BS EN ISO/IEC 80079-34:2020 Expert commentary`
- With amendment: `BS EN 13445:2001+A1:2004 Expert commentary`
- Year variations

### Step 2: Analyze Current Implementation (10 min)

Read existing ExpertCommentary class:
```bash
cat lib/pubid_new/bsi/identifiers/expert_commentary.rb
```

**Identify:**
- Current rendering logic
- Missing patterns
- Architecture gaps

### Step 3: Fix Expert Commentary Rendering (20 min)

**File:** `lib/pubid_new/bsi/identifiers/expert_commentary.rb`

**Expected Changes:**
```ruby
class ExpertCommentary < Identifiers::Base
  def to_s
    result = super  # Get base rendering
    result += " Expert commentary"  # Add suffix
    result
  end
end
```

**Key Requirements:**
- Add "Expert commentary" suffix to all patterns
- Handle adoption patterns (BS EN ISO/IEC)
- Support amendments in expert commentary
- Maintain round-trip fidelity

### Step 4: Validate (10 min)

```bash
# Test expert commentary patterns
ruby -I lib -r pubid_new/bsi -e '
expert_txt = File.read("spec/fixtures/bsi/identifiers/full/expert_commentary.txt")
expert_txt.each_line do |line|
  line = line.strip
  next if line.empty?
  
  result = PubidNew::Bsi.parse(line)
  if result.to_s == line
    puts "✓ #{line}"
  else
    puts "✗ #{line}"
    puts "  Expected: #{line}"
    puts "  Got:      #{result.to_s}"
  end
rescue => e
  puts "✗ #{line} - #{e.message}"
end
'

# Run integration tests
bundle exec rspec spec/pubid_new/bsi/identifier_spec.rb
```

## Expected Patterns to Fix

```
BS 7671:2008 Expert commentary
BS EN ISO/IEC 80079-34:2020 Expert commentary
BS EN 13445:2001+A1:2004 Expert commentary
BS EN 13445:2001+A1:2004+A2:2005 Expert commentary
BS 5306-1:1999 Expert commentary
BS 8888:2016 Expert commentary
```

## Architecture Requirements

✅ **MODEL-DRIVEN:** Inherits from Identifiers::Base
✅ **Lutaml::Model:** Full serialization support
✅ **Three-layer:** Parser/Builder/Identifier separation
✅ **Component-based:** Uses existing components
✅ **MECE:** All patterns handled correctly
✅ **Round-trip:** Perfect fidelity in both directions

## Quality Gates

1. ✅ All 25 expert commentary patterns parse correctly
2. ✅ Round-trip fidelity: `parse(str).to_s == str`
3. ✅ Zero regressions in 47 integration tests
4. ✅ Zero regressions in 174 unit tests
5. ✅ Architecture principles maintained

## Success Criteria

- **Expert Commentary Coverage:** 11/25 → 25/25 (100%)
- **Overall BSI Coverage:** 1,294 → 1,308 (80.15%)
- **Integration Tests:** 47/47 passing
- **Unit Tests:** 174/174 passing

## Files to Modify

**Primary:**
- `lib/pubid_new/bsi/identifiers/expert_commentary.rb` - Fix rendering

**Optional (if needed):**
- `lib/pubid_new/bsi/parser.rb` - Check if parsing needs fixes
- `lib/pubid_new/bsi/builder.rb` - Check if construction needs fixes

## After Completion

1. Update memory bank with Session 298 achievement
2. Create session-298-summary.md
3. Update BSI-IMPLEMENTATION-STATUS.md
4. Prepare Session 299: Electronic Book implementation

## Important Notes

**From create-continue-plan-prompt.md:**

- **Architecture correctness is paramount** - even if specs regress, ensure implementation is architecturally sound
- **MECE organization** - each pattern has one handling path
- **Separation of concerns** - Parser/Builder/Identifier layers independent
- **Open/closed principle** - extend through inheritance, not modification
- **Deadline focus** - compress phases to finish as soon as possible

**Quick Win Strategy:**
- This is a quick win - simple rendering fix
- Should complete in 45 minutes
- High ROI for time invested
- Builds momentum for more complex tasks

---

**Ready to Execute:** Session 298 - Expert Commentary Quick Win