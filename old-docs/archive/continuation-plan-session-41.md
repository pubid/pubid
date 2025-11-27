# Session 41+ Continuation Plan: Alternative Approaches for DAD Parsing

**Created:** 2025-11-27  
**Status:** Session 40 Complete - Parser Fix Unsuccessful  
**Current:** 82.7% (2,363/2,859 passing tests)  
**Target:** 86.3%+ (2,379+ passing tests)

---

## Session 40 Results

**Objective:** Fix parser to enable DAD parsing  
**Result:** UNSUCCESSFUL - All parser approaches caused massive regressions

**Attempts Made:**
1. Atomic slash+type (652 failures, +635 regression)
2. Negative lookahead variations (654 failures, +637 regression)
3. Specialized supplement rule (168-207 failures, +151-190 regression)
4. Multiple lookahead combinations (169 failures, +152 regression)

**Key Finding:** ANY modification to `identifier_copublishers_no_third` rule causes 150+ regressions

**Root Cause:** Complex parser interactions between:
- Copublisher parsing (`prefix_with_copublishers` with slash in copublisher list)
- Type parsing (slash before type like "ISO/TR")
- Supplement parsing (slash as supplement separator)

---

## Alternative Approaches for Session 41+

### Priority 1: Builder Workaround (RECOMMENDED - LOW RISK)

**Rationale:** Architecture is correct (DAD in supplement registry), only parsing is problematic

**Strategy:** Enhance Builder to handle DAD patterns specially

**Implementation:**
1. Builder detects when base identifier parse fails with supplement pattern
2. Tries re-parsing with supplement types temporarily added to base registry
3. Or: Builder uses string manipulation to pre-process "ISO 2631/DAD 1" patterns
4. Build proper identifier objects after successful parse

**Estimated Impact:** +16 tests with minimal risk

**Example Approach:**
```ruby
# In Builder.build()
def build(parsed_hash)
  # Normal flow...
rescue ParseError => e
  # If parse failed and string contains supplement type after "/"
  if original_string.match?(/\/#{SUPPLEMENT_TYPES_REGEX}/)
    # Try special handling
    retry_with_supplement_handling(original_string)
  else
    raise e
  end
end
```

**Pros:**
- No parser changes (zero risk to 2,363 passing tests)
- Isolated to Builder layer
- Can handle edge cases explicitly
- Easy to test and debug

**Cons:**
- Slightly less "clean" than parser fix
- Adds special case logic to Builder

**Estimated Time:** 60-90 minutes

---

### Priority 2: Parser Architecture Refactor (HIGH RISK - FUTURE)

**Only attempt if Builder approach fails**

**Problem:** Current `identifier_copublishers_no_third` serves multiple contexts:
1. Base identifiers (standalone "ISO 8601:2019")
2. Base for supplements ("ISO 2631" in "ISO 2631/DAD 1")
3. Base for joint identifiers
4. With type patterns ("ISO/TR 8601")

**Solution:** Create context-specific rules:
```ruby
rule(:base_for_supplement) do
  # No slash/type matching - supplement handles separator
  prefix_with_copublishers.maybe >>
    space.maybe >> second_part >> third_part_edition
end

rule(:base_for_joint) do
  # Similar but for joint identifiers
  ...
end

rule(:standalone_identifier) do
  # Full slash/type matching for standalone
  identifier_copublishers_no_third  # Current implementation
end

rule(:supplement_identifier_no_third) do
  base_for_supplement.as(:base_identifier) >>
    str("/") >> supplement_type_with_stage >>
    space? >> second_part
end
```

**Pros:**
- Architecturally cleaner
- Separates concerns properly
- Each context has appropriate rules

**Cons:**
- Requires comprehensive parser understanding
- High risk of regressions
- Time-consuming to implement correctly
- Must map all rule usages

**Estimated Time:** 3-4 hours minimum

**Prerequisites:**
1. Complete audit of all `identifier_copublishers_no_third` usages
2. Comprehensive test coverage analysis
3. Incremental implementation with rollback plan

---

### Priority 3: IEC Implementation Review (RESEARCH)

**Check IEC flavor:** They likely solved similar problems

**Actions:**
1. Read `lib/pubid_new/iec/parser.rb`
2. Check how IEC handles supplement parsing
3. Identify applicable patterns

**Estimated Time:** 30 minutes research

---

## Session 41 Recommended Plan

### Phase 1: Builder Workaround (60-90 min)

**Step 1: Analyze failing patterns (10 min)**
```bash
bundle exec rspec spec/pubid_new/iso/identifiers/addendum_spec.rb:386 \
  --format documentation 2>&1 | grep "ISO.*DAD"
```

Expected patterns:
- "ISO 2631/DAD 1" (no years)
- "ISO 2553/DAD 1:1987" (supplement has year)
- "ISO/DIS 1151-1/DAD 2" (base has stage)

**Step 2: Implement Builder enhancement (30-40 min)**

Location: `lib/pubid_new/iso/builder.rb`

Approach A - Pre-processing:
```ruby
class Builder
  def self.build_from_string(string, scheme)
    # Detect DAD patterns before parsing
    if string.match?(/^(.*?)\/DAD[F]?\s+(\d+)/)
      return build_dad_supplement(string, scheme)
    end
    
    # Normal parsing
    parser = Parser.new
    parsed = parser.parse(string)
    new(scheme).build(parsed)
  end
  
  private
  
  def self.build_dad_supplement(string, scheme)
    # Extract base and supplement parts
    base_str, supplement_str = string.split("/DAD")
    
    # Parse base normally (without DAD)
    base = build_from_string(base_str.strip, scheme)
    
    # Parse supplement with DAD added to type registry temporarily
    # ... implementation details
  end
end
```

Approach B - Parse retry:
```ruby
def build(parsed_hash)
  identifier = locate_identifier_klass(parsed_hash).new
  # ... existing implementation
rescue => e
  if @original_string&.match?(/\/DAD/)
    retry_with_dad_handling
  else
    raise e
  end
end
```

**Step 3: Test (10 min)**
```bash
bundle exec rspec spec/pubid_new/iso/identifiers/addendum_spec.rb:386
# Should pass all 16 DAD tests

bundle exec rspec spec/pubid_new/iso/ --format progress 2>&1 | grep "examples,"
# Should be 2,379 passing (or close)
```

**Step 4: Fix any regressions (10-20 min)**

**Step 5: Commit (5 min)**

### Phase 2: If Phase 1 Fails - Research IEC (30 min)

### Phase 3: If Both Fail - Document for Future Parser Refactor

---

## Testing Protocol

**Before ANY changes:**
```bash
bundle exec rspec spec/pubid_new/iso/ --format progress 2>&1 | grep "examples,"
# Baseline: 2859 examples, 17 failures, 480 pending
```

**After changes:**
```bash
# Target tests
bundle exec rspec spec/pubid_new/iso/identifiers/addendum_spec.rb:386
# Should: 9 examples, 0 failures (currently 8 failures)

# Full suite
bundle exec rspec spec/pubid_new/iso/ --format progress 2>&1 | grep "examples,"
# Target: 2,379+ passing (2,363 baseline + 16 DAD tests)
# Acceptable: 2,370+ passing (net +7 or more)
```

**Regression threshold:**
- ✅ Acceptable: < 10 new failures
- ⚠️ Caution: 10-25 new failures (analyze and fix)
- ❌ Unacceptable: > 25 new failures (revert immediately)

---

## Success Criteria

**Minimum (Acceptable):**
- DAD tests: 8 → 0 failures (+8 tests)
- Net gain: +5 or more tests
- Pass rate: 82.7% → 82.9%+

**Target (Goal):**
- DAD tests: 8 → 0 failures (+8 tests)
- Other addendum: 8 → 0 failures (+8 tests, total +16)
- Pass rate: 82.7% → 86.3%
- Total passing: 2,379/2,859

**Ideal:**
- All 17 failures fixed
- 90%+ pass rate achieved

---

## Key Principles (NEVER VIOLATE)

1. **Architecture First** - Clean architecture > passing tests
2. **Zero Hardcoding** - Use registers and lookups
3. **Separation of Concerns** - Parser/Builder/Identifier independent
4. **Incremental Changes** - One fix at a time
5. **Quick Revert** - Regression > 25 tests = immediate rollback

---

## Files to Modify

### For Builder Approach (Priority 1):
- `lib/pubid_new/iso/builder.rb` - Add DAD handling
- `lib/pubid_new/iso.rb` - May need to pass original string to Builder

### For Parser Approach (Priority 2 - Future):
- `lib/pubid_new/iso/parser.rb` - Architecture refactor
- ALL identifier specs - Potential fixture updates

### Tests:
- `spec/pubid_new/iso/identifiers/addendum_spec.rb` - Verify fixes

---

## Session 40 Lessons Learned

1. **Parser changes are HIGH RISK** - Even small changes cause 150+ regressions
2. **`.maybe` behavior is tricky** - Parslet's optional matching can still consume input
3. **Lookahead timing matters** - Must check BEFORE consumption, not after
4. **Rule context matters** - Same rule used in different contexts needs different behavior
5. **Specialized rules work better** - Context-specific rules reduce conflicts (but didn't fully solve)

---

## Alternative Research Topics

If Builder workaround proves insufficient:

1. **Parslet Documentation** - Advanced lookahead/backtracking patterns
2. **V1 Implementation** - How did old version handle DAD?
3. **IEC Flavor** - Supplement parsing patterns
4. **IEEE Flavor** - Complex identifier patterns
5. **Parser Debugging** - Parslet trace/debug tools

---

## Commit Message Template

If successful:
```
fix(iso): enable DAD supplement parsing via Builder workaround

- Add special handling in Builder for DAD patterns
- Detects "/DAD" patterns before parsing
- Parses base and supplement separately
- Constructs proper Addendum identifier
- Impact: +X tests (X addendum DAD tests)

Session 41: 82.7%→X.X% (2,363→X,XXX passing)
```

---

## Next Session Prompt

See: `docs/session-41-prompt.md`