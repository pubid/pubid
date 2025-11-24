# Session 13 Continuation Plan - ISO V2 Test Refinement

## Current Status (as of Session 12 end)

**Test Results:**
- 1,223 passing (42.8%)
- 861 failures (30.1%)
- 775 pending (27.1%)
- Total: 2,859 examples

**Progress from Session 11:**
- Started: 1,059 passing (37.0%)
- Improved: +164 tests (+5.8pp)
- Failures reduced: 987 → 861 (-126)

## What Was Accomplished in Session 12

### 1. Phase 1: Quick Wins (+10 tests)

**Changes Made:**
- Added `.value` alias to Edition component in `lib/pubid_new/components/edition.rb`
- Added `.copublishers` convenience method to Base identifier in `lib/pubid_new/iso/identifiers/base.rb`
- Fixed parser part rule in `lib/pubid_new/iso/parser.rb` to exclude 4-digit years from being captured as parts

**Impact:**
- Legacy date patterns now work: `ISO 31/0-1974` → `ISO 31-0:1974`
- V1 API compatibility restored for edition and copublisher access

### 2. Phase 2: Supplement Pattern Fixes (+154 tests)

**Changes Made:**
- Added lowercase typed stage variants in `lib/pubid_new/iso/parser.rb:51-56`:
  - `DAmd`, `FDAmd`, `PDAmd` (alongside uppercase `DAM`, `FDAM`, `PDAM`)
- Added stage+space+supplement pattern in `lib/pubid_new/iso/parser.rb:115`:
  - `CD Amd`, `PWI Amd`, `AWI Amd`, `WD Amd`, `PRF Amd`
- Fixed `Amd.` parsing in `lib/pubid_new/iso/parser.rb:118`:
  - Changed to `space.maybe` to handle `Amd.1` (no space) and `Amd. 1` (with space)

**Impact:**
- All identified supplement patterns from amendment test failures now parse correctly
- Examples: `ISO 3245:2015/FDAmd 1`, `ISO/IEC 14496-10:2020/CD Amd 1`, `ISO 10993-4:2002/Amd.1:2006(E)`

## Remaining High-Impact Issues

### Priority 1: Rendering Inconsistencies (~100-150 tests estimated)

**Patterns identified but not yet investigated:**

1. **NWIP vs NP rendering**
   - Example: Input `ISO/NWIP 19144-4` should render as `ISO/NP 19144-4`
   - Issue: Parser captures `NWIP` but should normalize to `NP` for rendering

2. **PreCD vs preCD case**
   - Example: Input `ISO/PreCD3 17301-1` should render as `ISO/preCD 17301-1.3`
   - Issue: Case normalization needed for legacy stage names

**Investigation approach:**
```bash
# Get rendering failures (where parse succeeds but output differs)
bundle exec rspec spec/pubid_new/iso/identifiers/international_standard_spec.rb \
  --format documentation 2>&1 | grep -A 3 "expected:" | head -100 > rendering_failures.txt
```

### Priority 2: Remaining Parse Failures (~650 tests estimated)

**Approach:** Systematic failure analysis like Session 12

**Commands to run:**
```bash
# Get detailed failures from multiple test files
bundle exec rspec spec/pubid_new/iso/identifiers/corrigendum_spec.rb \
  --format documentation 2>&1 | grep -A 5 "Failed to parse" | head -150 > cor_failures.txt

bundle exec rspec spec/pubid_new/iso/identifiers/guide_spec.rb \
  --format documentation 2>&1 | grep -A 5 "Failed to parse" | head -150 > guide_failures.txt

# Analyze patterns
grep "Failed to parse" *.txt | cut -d"'" -f2 | sort | uniq -c | sort -rn | head -20
```

**Focus areas:**
- Corrigendum patterns (similar to amendment patterns)
- Guide-specific patterns
- Type/stage combinations not yet supported
- Year/date edge cases

### Priority 3: Pending Tests Review (~775 tests)

**Categories to investigate:**
- Tests marked pending due to architectural differences (typed_stage)
- Tests pending due to with_edition parameter differences
- Tests pending for unknown reasons (may be false positives)

**Investigation approach:**
```bash
# Find pending test reasons
bundle exec rspec spec/pubid_new/iso/ --format documentation 2>&1 | \
  grep -B 2 "pending" | grep -A 2 "skip\|pending" | head -50
```

## Recommended Session 13 Plan

**Goal: Reach 45% pass rate (1,287 passing, +64 tests)**

### Phase 1: Rendering Fixes (30 minutes)

1. **Fix NWIP → NP normalization** (~50 tests)
   - Investigate Stage component rendering logic
   - Add normalization map for legacy stage names
   - Test in isolation
   - Run safety check
   - Commit

2. **Fix PreCD case normalization** (~10 tests)
   - Add case normalization for PreCD variants
   - Test in isolation
   - Run safety check
   - Commit

**Expected: ~60 tests fixed, total 1,283 passing**

### Phase 2: Corrigendum Pattern Analysis (60 minutes)

3. **Analyze Corrigendum Failures**
   - Extract failure patterns from corrigendum tests
   - Create frequency table
   - Document top 5 patterns by count

4. **Fix Highest Frequency Corrigendum Pattern** (~20-30 tests)
   - Implement fix
   - Test in isolation
   - Run safety check
   - Commit

**Expected: ~20-30 tests fixed, total 1,303-1,313 passing**

### Phase 3: Documentation & Progress (30 minutes)

5. **Run Full Test Suite**
   - Document final results
   - Update context.md
   - Create Session 14 continuation plan if needed
   - Commit documentation

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
bundle exec rspec spec/pubid_new/iso/identifiers/FILE_spec.rb \
  --format documentation --only-failures > detailed_failures.txt

# Count failure types
grep "Failed to parse" detailed_failures.txt | wc -l
grep "expected:" detailed_failures.txt | wc -l
```

## Files to Focus On

### For Rendering Fixes
- `lib/pubid_new/components/stage.rb` - May need stage normalization
- `lib/pubid_new/iso/identifiers/base.rb` - Rendering logic

### For Parser Changes (if needed)
- `lib/pubid_new/iso/parser.rb` - Add missing patterns from analysis

### For Builder Changes (if needed)
- `lib/pubid_new/iso/builder.rb` - Handle new patterns

## Key Reminders

1. **ALWAYS run safety check** after each change (106/106 must pass)
2. **Use data-driven approach** - analyze failures systematically
3. **Test specific patterns** before running full suite
4. **Commit frequently** - each logical fix gets its own commit
5. **Track test count changes** - know impact of each fix
6. **Document architectural decisions** - explain intentional differences

## Success Metrics

**Minimum for Session 13:**
- 1,287 passing (45.0%) - +64 from Session 12
- 798 failing (27.9%) - -63 from Session 12
- Maintain core: 106/106 passing

**Stretch for Session 13:**
- 1,430 passing (50.0%) - +207 from Session 12
- 654 failing (22.9%) - -207 from Session 12

## Known Working Patterns (from Session 12)

These work correctly:
- All stages: PWI, NP, NWIP, AWI, WD, CD, DIS, FDIS, PRF, FCD, preCD/PreCD/PRECD
- UNDP copublisher: `ISO/UNDP 53001:2025`
- Space normalization: `ISO /IEC` → `ISO/IEC`
- Stage iterations: `ISO/CD2 14065:2018` → `ISO/CD 14065.2:2018`
- Sub-subparts: `ISO/IEC 29110-5-1-1:2025` → part=5, subpart=1-1
- Language codes: `(E)`, `(F)`, `(en)`, `(fr)`, `(E/F)`, in supplements
- DAD supplements: `ISO 2631:2020/DAD 1:2021`
- Add/Addendum: `ISO/R 91-1970/Addendum 1` → renders as "Add"
- Lowercase typed stages: `DAmd`, `FDAmd`, `PDAmd`
- Stage+supplement: `CD Amd`, `PWI Amd`, `AWI Amd`, `WD Amd`, `PRF Amd`
- Amd. without space: `Amd.1`, `Amd.2`
- Legacy dates: `ISO 31/0-1974` → `ISO 31-0:1974`

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
- Stage component uses `.abbr` not `.value`
- Edition component has both `.number` and `.value` (alias)

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
bundle exec rspec spec/pubid_new/iso/identifiers/FILE_spec.rb \
  --format documentation --only-failures | head -100

# Commit changes
git add -A && git commit -m "TYPE(iso): DESCRIPTION"
```

## Notes for Next Developer

1. **Start with rendering fixes** - NWIP/PreCD normalization likely affects many tests
2. **Then analyze corrigendum** - Similar patterns to amendments
3. **Session 12 maintained strong momentum** - +5.8pp with focused fixes
4. **Test in isolation first** - Use ruby -e before running full suite
5. **Preserve Session 12 improvements** - Don't break supplement parsing
6. **Focus on systematic analysis** - Data-driven approach yields best results
7. **Document as you go** - Update context.md with findings

Good luck with Session 13! The foundation from Sessions 9-12 is solid, and we're approaching the 45% milestone.
