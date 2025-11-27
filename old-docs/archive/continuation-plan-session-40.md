# Session 40+ Continuation Plan: Fix DAD Parsing & Path to 90%

**Created:** 2025-11-27  
**Status:** Session 39 Complete - Ready for Session 40  
**Current:** 82.7% (2,363/2,859 passing tests)  
**Target:** 90%+ (2,574+ passing tests)

---

## Session 39 Results

✅ **Completed:**
- Fixed 3 parser_spec error tests (+3 tests)
- Test configuration only, zero regressions
- Pass rate: 82.6% → 82.7%
- Commit: 6d127bb

**Remaining:** 16 failures in addendum_spec (DAD parsing issue)

---

## Session 40 Goal: Fix DAD Parsing

**Objective:** Enable parsing of "ISO 2631/DAD 1" and "ISO 2553/DAD 1:1987" (+16 tests)

**Target:** 82.7% → 86.3% (2,379 passing tests)

### Problem Analysis

**Valid Identifiers That Must Parse:**
- "ISO 2631/DAD 1" - base without year, supplement without year
- "ISO 2553/DAD 1:1987" - base without year, supplement with year

**Root Cause:**
File: `lib/pubid_new/iso/parser.rb:207`

```ruby
identifier_copublishers_no_third:
  prefix_with_copublishers.maybe >> space? >> str("/").maybe >> type_with_stage.maybe
```

The `str("/").maybe` consumes "/" independently from `type_with_stage.maybe`, causing:
1. Parser sees "ISO 2631/"
2. Consumes "/" thinking it might be for type (like "ISO/TS")
3. Tries to match "DAD" as type_with_stage from base TYPED_STAGES
4. "DAD" is NOT in base TYPED_STAGES (correctly in TYPED_STAGES_SUPPLEMENTS)
5. Parser fails

**Architecture is CORRECT:**
- ✅ DAD in TYPED_STAGES_SUPPLEMENTS (not base TYPED_STAGES) is proper design
- ✅ Supplement types separate from base types is clean architecture
- ✅ Only parser grammar needs fixing

### Solution Approach

**Constraint:** Parser changes are HIGH RISK
- Session 39 attempts caused 131-653 failures
- Need careful ordering and negative lookahead

**Strategy:**

#### Option 1: Negative Lookahead (RECOMMENDED)
Make "/" in `identifier_copublishers_no_third` NOT match when followed by supplement types:

```ruby
# Only consume "/" when followed by actual base type, not supplement type
(space? >> 
  str("/") >> 
  type_with_stage.repeat(1)  # Must have type after slash
).maybe
```

Key: Change `.maybe` on type to `.repeat(1)` - type is REQUIRED if "/" present

#### Option 2: Rule Ordering
Move `supplement_identifier` rule BEFORE `identifier_copublishers` in root identifier:

```ruby
rule(:identifier) do
  directives_identifiers |
    iso_r_supplement_identifier |
    iso_r_identifier |
    supplement_supplement_identifier |
    supplement_identifier |          # Try supplement parsing first
    joint_identifier |
    identifier_copublishers           # Then base identifier
end
```

But THIS IS ALREADY THE CURRENT ORDER! So this won't help.

#### Option 3: Explicit Exclusion
Add negative lookahead to exclude supplement types:

```ruby
# In identifier_copublishers_no_third
prefix_with_copublishers.maybe >>
  (space? >> 
    str("/") >> 
    # NOT followed by supplement type abbreviations
    array_to_str(TYPED_STAGES_SUPPLEMENTS).absent? >>
    type_with_stage
  ).maybe >>
  space? >>
  second_part >> third_part_edition
```

### Implementation Plan

**Phase 1: Test Option 1 (RECOMMENDED)** (30 min)
1. Change line 207-208 to make type REQUIRED when "/" present
2. Test full suite
3. If regressions < 50: analyze and fix
4. If regressions > 50: revert, try Option 3

**Phase 2: If Option 1 fails, try Option 3** (30 min)
1. Add negative lookahead for supplement types
2. Test full suite
3. Analyze regressions

**Phase 3: Fix Any Regressions** (30 min)
1. Identify what broke
2. Add special cases if needed
3. Re-test

**Success Criteria:**
- DAD parsing works: 16 → 0 failures in addendum_spec
- Regressions < 25 in other specs
- Overall gain: net +5 or more tests

---

## Session 41+: Path to 90%

### Remaining Work After Session 40

**If Session 40 succeeds (+16 tests):**
- Status: 86.3% (2,379 passing)
- Need: +195 tests to reach 90% (2,574 passing)

**Likely Remaining Issues:**
1. Edge cases in identifier_spec
2. Complex multi-level supplements
3. Legacy format variations
4. Special character handling

### Strategy for 90%

**Use same proven approach:**
- LOW RISK first: test configurations, fixture updates
- Builder fixes: normalization and special cases  
- Parser fixes: only when necessary and well-analyzed
- ONE change at a time with immediate testing
- Revert quickly if regression > 50 tests

---

## Key Principles (NEVER VIOLATE)

### Architecture
1. **TYPED_STAGE REGISTER** - Single source of truth
2. **Builder.new(scheme)** - Receive Scheme for lookups
3. **Single cast() method** - ALL conversions in ONE place
4. **Components render themselves** - No hardcoded logic
5. **Separation of concerns** - Parser/Builder/Identifier independent

### Testing Protocol
```bash
# Before change
bundle exec rspec spec/pubid_new/iso/ --format progress 2>&1 | grep "examples,"

# After change
bundle exec rspec spec/pubid_new/iso/ --format progress 2>&1 | grep "examples,"

# If regression > 50: REVERT IMMEDIATELY
git checkout HEAD -- lib/pubid_new/iso/parser.rb
```

### Risk Levels
- **LOW RISK**: Test config, fixtures, Builder normalization
- **MEDIUM RISK**: Builder restructuring, Component changes
- **HIGH RISK**: Parser grammar changes (current task)

---

## Files to Monitor

### Critical (Do Not Break)
- `lib/pubid_new/iso/builder.rb` - Default typed_stage
- `lib/pubid_new/iso/scheme.rb` - TYPED_STAGES registry
- `lib/pubid_new/iso/identifiers/addendum.rb` - DAD definitions

### Target for Session 40
- `lib/pubid_new/iso/parser.rb:207` - Fix slash consumption

### Test Files
- `spec/pubid_new/iso/identifiers/addendum_spec.rb` - 16 failures to fix
- Full suite regression testing required

---

## Session Success Tracking

| Session | Tests Passing | Change | Approach | Risk |
|---------|---------------|--------|----------|------|
| 30 | 2,287 (80.0%) | +9 | Parser spacing | LOW |
| 31 | 2,289 (80.07%) | +2 | Malformed IDs | LOW |
| 32 | 2,298 (80.38%) | +9 | Consolidated | MED |
| 33 | 2,295 (80.28%) | -3 | Infrastructure | LOW |
| 38 | 2,360 (82.6%) | +3 | Builder year | LOW |
| 39 | 2,363 (82.7%) | +3 | Test config | LOW |
| **40** | **2,379 (86.3%)** | **+16** | **Parser DAD** | **HIGH** |

---

## Next Session Prompt

See: `docs/session-40-prompt.md`