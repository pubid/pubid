# Session 40 Prompt: Fix DAD Parsing

## Context

You are continuing work on PubID V2 (ISO flavor) - a Ruby gem for parsing standards identifiers.

**Current Status:**
- 2,363 passing (82.7%)
- 16 failures in addendum_spec (all DAD parsing)
- Session 39 fixed 3 test config issues (+3 tests, zero regressions)

**Read these files FIRST:**
- `.kilocode/rules/memory-bank/architecture.md` - System architecture
- `.kilocode/rules/memory-bank/context.md` - Current state
- `docs/continuation-plan-session-40.md` - This session's plan

## Your Task

Fix parser grammar to enable parsing of these VALID ISO identifiers:
- "ISO 2631/DAD 1" (8 test failures)
- "ISO 2553/DAD 1:1987" (8 test failures)

**Goal:** +16 tests → 82.7% to 86.3% (2,379 passing)

## The Problem

**File:** `lib/pubid_new/iso/parser.rb:207`

```ruby
identifier_copublishers_no_third:
  prefix_with_copublishers.maybe >> space? >> str("/").maybe >> type_with_stage.maybe
```

The `str("/").maybe` INDEPENDENTLY from `type_with_stage.maybe` causes "/" to be consumed when parsing "ISO 2631/DAD 1":
1. Parser reads "ISO 2631/"
2. Consumes "/" (thinking it might be for type like "ISO/TS")
3. Can't match "DAD" in base TYPED_STAGES
4. Fails (DAD is correctly in TYPED_STAGES_SUPPLEMENTS, not base)

**Architecture is CORRECT** - only parser grammar needs fixing.

## Solution to Implement

**Recommended: Make type REQUIRED when "/" present**

Change line 207-208 from:
```ruby
prefix_with_copublishers.maybe >> space? >> str("/").maybe >> type_with_stage.maybe
```

To:
```ruby
prefix_with_copublishers.maybe >>
  # Slash and type are ATOMIC: both present or both absent
  # This prevents consuming "/" alone in "ISO 2631/DAD 1"
  (space? >> str("/") >> type_with_stage).maybe >>
  space? >>
  second_part >> third_part_edition
```

**Key:** The `.maybe` wraps the ENTIRE `(slash >> type)` group, not each separately.

## Testing Protocol

```bash
# 1. Record baseline
bundle exec rspec spec/pubid_new/iso/ --format progress 2>&1 | grep "examples,"
# Expected: 2859 examples, 16 failures, 480 pending

# 2. Make the change

# 3. Test immediately
bundle exec rspec spec/pubid_new/iso/ --format progress 2>&1 | grep "examples,"

# 4. Evaluate:
# - If failures < 25: SUCCESS! Analyze specific failures
# - If failures 25-50: CAUTION, analyze carefully
# - If failures > 50: REVERT IMMEDIATELY
git checkout HEAD -- lib/pubid_new/iso/parser.rb
```

## Expected Outcomes

**Best Case:**
- addendum_spec: 16 → 0 failures
- Minor regressions in other specs (< 10)
- Net gain: +10 or more tests

**Acceptable:**
- addendum_spec: 16 → 0 failures  
- Some regressions (10-25 failures)
- Net gain: +0 to +10 tests
- Requires fixing regressions in follow-up

**Unacceptable:**
- >50 failures total
- Must revert and try alternative approach

## Alternative Approaches (If Recommended Fails)

### Option 2: Negative Lookahead
```ruby
prefix_with_copublishers.maybe >>
  (space? >> 
    str("/") >> 
    # NOT followed by supplement type
    array_to_str(TYPED_STAGES_SUPPLEMENTS).absent? >>
    type_with_stage
  ).maybe >>
  space? >>
  second_part >> third_part_edition
```

### Option 3: More Specific Type Matching
Make type_with_stage more specific about when it can match after "/"

## Critical Rules

1. **ONE change at a time** - Test after each modification
2. **Revert quickly** - If regression > 50, revert immediately  
3. **Trust the architecture** - DAD in TYPED_STAGES_SUPPLEMENTS is correct
4. **No hardcoding** - Don't add special case handling for DAD
5. **Document regressions** - If any, list what broke and why

## Success Criteria

✅ "ISO 2631/DAD 1" parses successfully  
✅ "ISO 2553/DAD 1:1987" parses successfully  
✅ Net test gain > 0
✅ Architecture principles maintained
✅ Clear understanding of any regressions

## Commit Message Format

If successful:
```
fix(iso): enable DAD supplement parsing without year in base

- Make slash and type atomic in identifier_copublishers_no_third
- Prevents "/" consumption when used as supplement separator
- Enables "ISO 2631/DAD 1" and "ISO 2553/DAD 1:1987"
- Impact: +X tests (16 addendum, -Y regressions)

Session 40: 82.7%→X.X% (2,363→X passing)
```

## Files to Read

**MUST READ:**
1. `.kilocode/rules/memory-bank/architecture.md`
2. `lib/pubid_new/iso/parser.rb` (lines 200-215)
3. `lib/pubid_new/iso/identifiers/addendum.rb` (TYPED_STAGES)

**Test:**
- `spec/pubid_new/iso/identifiers/addendum_spec.rb` (lines 380-470)

Good luck with Session 40!