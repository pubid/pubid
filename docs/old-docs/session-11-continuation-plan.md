# Session 11 Continuation Plan - ISO V2 Test Refinement

## Current Status (as of Session 10 end)

**Test Results:**
- 1,030 passing (36.0%)
- 1,016 failures (35.5%)
- 813 pending (28.4%)
- Total: 2,859 examples

**Progress from Session 9:**
- Started: 945 passing (33.1%)
- Improved: +85 tests (+2.9pp)
- Failures reduced: 1,080 → 1,016 (-64)
- Pending reduced: 834 → 813 (-21)

## What Was Accomplished in Session 10

### 1. Language Code Support (79 tests)
**Changes Made:**
- Updated [`parser.rb:83-87`](lib/pubid_new/iso/parser.rb:83-87) to accept both uppercase and lowercase: `match["A-Za-z"]`
- Added `language.maybe` to all three supplement patterns (lines 101, 103, 105)
- Updated [`builder.rb:210`](lib/pubid_new/iso/builder.rb:210) to preserve language codes using `original_code`

**Impact:**
- Base identifiers: `ISO 1234:2020(en)`, `ISO 5678:2021(E/F)` ✅
- Supplements: `ISO 4037:1979/Add 1:1983(F)`, `ISO 9012:2022/Amd 1:2023(fr)` ✅

### 2. Subpart Parsing (6 tests)
**Changes Made:**
- Updated [`builder.rb:374-378`](lib/pubid_new/iso/builder.rb:374-378) to extract second part as subpart
- Added subpart to identifier construction (lines 71, 103)
- Added subpart rendering in [`base.rb:44`](lib/pubid_new/iso/identifiers/base.rb:44)
- Fixed invalid `require_relative` for non-existent file

**Impact:**
- `ISO 80601-2-61:2019` → part="2", subpart="61" ✅

### 3. Verified DAD Support
- Confirmed DAD (Draft Addendum) already works via typed_stage
- Parser includes DAD on line 49, builder maps to Supplement class (line 170)

## Remaining High-Impact Issues

### Priority 1: Analyze Remaining Parse Failures (~800 tests)

**Action Items:**
1. Run systematic failure analysis like Session 9
2. Extract failure messages and group by pattern
3. Identify top 5-10 highest frequency patterns
4. Create fix plan prioritized by impact

**Commands:**
```bash
# Get detailed failures from a single test file
bundle exec rspec spec/pubid_new/iso/identifiers/international_standard_spec.rb \
  --format documentation --only-failures > failures.txt

# Analyze patterns
grep "expected:" failures.txt | sort | uniq -c | sort -rn | head -20
```

**Expected patterns to investigate:**
- Missing date/year patterns
- Part/iteration combinations
- Stage+type combinations not yet supported
- Publisher variations

### Priority 2: Rendering Differences (~200 tests estimated)

**Known issues:**
- Language code format variations (uppercase vs lowercase)
- Edition rendering with `with_edition` parameter
- Type/stage combination rendering

**Investigation approach:**
1. Find tests with "expected: X, got: Y" where parse succeeds
2. Group by difference type
3. Fix rendering in identifier classes

### Priority 3: Publisher Spacing Edge Cases (~5 tests)

**Pattern:** Space before slash in copublisher
```
ISO /IEC 17030:2003  # Space before /IEC
```

**Fix location:** [`parser.rb`](lib/pubid_new/iso/parser.rb:158-167) normalize method
**Approach:** Adjust normalization to preserve or handle this edge case

### Priority 4: Additional Typed Stages

**Check if these are missing from parser:**
- DAMD (Draft Amendment)
- FDAMD (Final Draft Amendment)
- Any other stage variants

**Fix location:** [`parser.rb:48-53`](lib/pubid_new/iso/parser.rb:48-53) typed_stage rule

## Recommended Session 11 Plan

**Goal: Reach 40% pass rate (1,144 passing, +114 tests)**

### Hour 1: Systematic Failure Analysis
**Target:** Understand the remaining 1,016 failures

1. Extract failure messages from top 5 test files
2. Categorize by type (parse failure, rendering, NoMethodError, etc.)
3. Create frequency table of failure patterns
4. Document top 10 patterns by count

**Commands:**
```bash
# Analyze international_standard failures
bundle exec rspec spec/pubid_new/iso/identifiers/international_standard_spec.rb \
  --format documentation --only-failures | tee is_failures.txt

# Extract patterns
grep "Failed to parse\|expected:" is_failures.txt | head -50
```

### Hour 2-3: Fix Highest Impact Pattern
**Target:** Fix the most frequent failure pattern

Based on analysis, implement fix for #1 pattern. Likely candidates:
- Missing year/date patterns
- Part number variations
- Stage combinations

**Process:**
1. Identify exact pattern from analysis
2. Test pattern manually with ruby -e
3. Update parser or builder as needed
4. Run safety check
5. Check progress
6. Commit if successful

**Safety check:**
```bash
bundle exec rspec spec/pubid_new/iso/parser_spec.rb spec/pubid_new/iso/builder_spec.rb
# MUST pass 106/106
```

### Hour 4: Fix Second Pattern
Repeat process for second highest frequency pattern

### Hour 5: Fix Third Pattern or Edge Cases
Continue with third pattern or tackle smaller edge cases:
- Publisher spacing
- Additional typed stages
- Rendering variations

### Hour 6: Progress Review & Documentation
1. Run full test suite
2. Calculate improvements
3. Update [`context.md`](.kilocode/rules/memory-bank/context.md)
4. Create Session 12 continuation plan if needed
5. Commit documentation

## Testing Strategy

### Safety Check (Run after EVERY change)
```bash
cd /Users/mulgogi/src/mn/pubid
bundle exec rspec spec/pubid_new/iso/parser_spec.rb spec/pubid_new/iso/builder_spec.rb
# MUST always pass 106/106
```

### Progress Check
```bash
bundle exec rspec spec/pubid_new/iso/ --format progress 2>&1 | grep "examples"
```

### Specific Pattern Testing
```bash
# Test specific identifier
ruby -e "require_relative 'lib/pubid_new/iso'; puts PubidNew::Iso.parse('YOUR_TEST_PATTERN').to_s"

# Debug parse output
ruby -e "require_relative 'lib/pubid_new/iso'; p PubidNew::Iso::Parser.parse('YOUR_PATTERN')"
```

### Failure Analysis (detailed)
```bash
# Get failure details from specific file
bundle exec rspec spec/pubid_new/iso/identifiers/international_standard_spec.rb \
  --format documentation --only-failures > detailed_failures.txt

# Count failure types
grep "Failed to parse" detailed_failures.txt | wc -l
grep "expected:" detailed_failures.txt | wc -l
grep "NoMethodError" detailed_failures.txt | wc -l
```

## Files to Focus On

### Parser Changes (likely)
- [`lib/pubid_new/iso/parser.rb`](lib/pubid_new/iso/parser.rb) - Add missing patterns

### Builder Changes (possible)
- [`lib/pubid_new/iso/builder.rb`](lib/pubid_new/iso/builder.rb) - Handle new patterns

### Rendering Changes (possible)
- [`lib/pubid_new/iso/identifiers/base.rb`](lib/pubid_new/iso/identifiers/base.rb) - Fix rendering
- Individual identifier classes if type-specific issues

### Test Files (for understanding)
- `spec/pubid_new/iso/identifiers/*.rb` - V1 expectations

## Key Reminders

1. **ALWAYS run safety check** after each change (106/106 must pass)
2. **Use data-driven approach** - analyze failures systematically, don't guess
3. **Test specific patterns** before running full suite
4. **Commit frequently** - each logical fix gets its own commit
5. **Track test count changes** - know impact of each fix
6. **Document architectural decisions** - explain intentional differences

## Success Metrics

**Minimum for Session 11:**
- 1,144 passing (40%) - +114 from Session 10
- 902 failing (31.6%) - -114 from Session 10
- Maintain core: 106/106 passing

**Stretch for Session 11:**
- 1,287 passing (45%) - +257 from Session 10
- 759 failing (26.5%) - -257 from Session 10

## Known Working Patterns (from Session 10)

These work correctly:
- Language codes: `(E)`, `(F)`, `(en)`, `(fr)`, `(E/F)`, `(E/F/R)`
- Language in supplements: `ISO 4037:1979/Add 1:1983(F)`
- Subparts: `ISO 80601-2-61:2019`
- DAD supplements: `ISO 2631:2020/DAD 1:2021`
- Edition rendering: `ISO 22610:2006 Ed 1` → "ED1" with `with_edition: true`
- Add/Addendum: `ISO/R 91-1970/Addendum 1` → renders as "Add"

## Architecture Notes

**Three-Layer Pattern:**
1. **Parser** (Parslet) - Syntax only, returns hash tree
2. **Builder** - Constructs objects from hash tree  
3. **Identifier** (Lutaml::Model) - Business logic + rendering

**Key patterns:**
- `original_code` for preserving parsed values (language, supplement_type)
- `original_abbr` for supplement rendering
- Longest pattern first in Parslet alternatives
- `typed_stage` includes both type and stage info
- Components are Lutaml::Model classes (not strings)

## Reference Data

**Test file sizes (approximate):**
- international_standard_spec.rb: ~600 examples (largest)
- amendment_spec.rb: ~400 examples
- guide_spec.rb: ~350 examples
- technical_report_spec.rb: ~300 examples
- corrigendum_spec.rb: ~250 examples
- Others: ~959 examples

**Failure distribution (from Session 9 analysis):**
- Parse failures: 77% of all failures (was 840/1,091)
- Rendering mismatches: 4.4%
- NoMethodError: 3.8%
- Other: 14.8%

Expected similar distribution now but with fewer total failures.

## Quick Reference Commands

```bash
# Start session
cd /Users/mulgogi/src/mn/pubid

# Test specific pattern
ruby -e "require_relative 'lib/pubid_new/iso'; puts PubidNew::Iso.parse('PATTERN').to_s"

# Safety check
bundle exec rspec spec/pubid_new/iso/parser_spec.rb spec/pubid_new/iso/builder_spec.rb

# Progress check  
bundle exec rspec spec/pubid_new/iso/ --format progress 2>&1 | grep "examples"

# Detailed failures from one file
bundle exec rspec spec/pubid_new/iso/identifiers/international_standard_spec.rb \
  --format documentation --only-failures | head -100

# Commit changes
git add -A && git commit -m "TYPE(iso): DESCRIPTION"
```

## Notes for Next Developer

1. **Start with systematic analysis** - Don't jump to fixes without understanding patterns
2. **Session 9 approach worked well** - Data-driven failure analysis is key
3. **Language fix was high-impact** - Look for similar single-change, multi-test fixes
4. **Test in isolation first** - Use ruby -e before running full suite
5. **Preserve Session 10 improvements** - Don't break language or subpart functionality
6. **Focus on parse failures** - 77% of failures are parser gaps
7. **Use original_code pattern** - Critical for round-trip rendering accuracy

Good luck with Session 11! The foundation from Sessions 9-10 is solid, and systematic analysis will guide the next improvements.