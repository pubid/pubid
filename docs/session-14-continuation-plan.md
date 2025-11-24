# Session 14 Continuation Plan - ISO V2 Test Refinement

## Current Status (as of Session 13 end)

**Test Results:**
- 1,232 passing (43.1%)
- 855 failures (29.9%)
- 772 pending (27.0%)
- Total: 2,859 examples

**Progress from Session 12:**
- Started: 1,223 passing (42.8%)
- Improved: +9 tests (+0.3pp)
- Failures reduced: 861 → 855 (-6)
- Pending reduced: 775 → 772 (-3)

## What Was Accomplished in Session 13

### 1. Phase 1: Stage Normalization (+2 tests)

**Changes Made:**
- Added `normalize_stage_abbr()` method in `lib/pubid_new/iso/builder.rb`
- Maps legacy stage names to canonical forms:
  - NWIP → NP (New Work Item Proposal → New Proposal)
  - PreCD → preCD (normalize case)
  - PRECD → preCD (normalize case)

**Impact:**
- Fixes 2 rendering inconsistencies where parser captured legacy names but needed normalized output
- Examples: `ISO/NWIP 19144-4` → `ISO/NP 19144-4`, `ISO/PreCD3 17301-1` → `ISO/preCD 17301-1.3`

### 2. Phase 2: Legacy Part Fix (+7 tests)

**Changes Made:**
- Added negative lookahead in `legacy_part` parser rule in `lib/pubid_new/iso/parser.rb`
- Prevents supplement keywords (Cor, Amd, Add, Suppl, Ext) from being parsed as parts
- Used `.absent?` pattern: `(str("Amd") | str("Cor") | ...).absent?`

**Impact:**
- Allows base documents without year to have supplements: `ISO 10360-1/Cor 1:2002`
- Preserves legacy slash-part pattern: `ISO 31/0-1974`
- Resolves parser ambiguity that was causing ~10 failures

## Remaining High-Impact Issues

### Priority 1: Corrigendum Typed Stage Patterns (~100+ tests estimated)

**Analysis from Session 13:**
From corrigendum failure analysis, the highest-frequency patterns are:

1. **DCOR (Draft Corrigendum)** - ~10 occurrences
   - Examples: `ISO/IEC 14496-12/DCOR 1`, `ISO 17301-1:2016/DCor 1.3:2002`
   - Issue: DCOR typed stage not in parser

2. **FDCOR (Final Draft Corrigendum)** - ~10 occurrences  
   - Examples: `ISO 17301-1:2016/FDCOR 1.3:2022`, `ISO 17301-1:2016/FDCor 1.3:2022`
   - Issue: FDCOR already in parser but FDCor (mixed case) variant missing

3. **FCOR (Final Corrigendum)** - ~10 occurrences
   - Example: `ISO 17301-1:2016/FCOR 2.3`
   - Issue: FCOR typed stage not in parser

4. **pDCOR (preliminary Draft Corrigendum)** - ~10 occurrences
   - Examples: `ISO/IEC 10646-1:1993/pDCOR.2`
   - Issue: pDCOR typed stage not in parser, also has dot before number

5. **Iteration in supplement numbers** - ~30 occurrences
   - Examples: `FDCor 2.3`, `DCor 1.3:2002`, `pDCOR.2`
   - Issue: Parser doesn't handle supplement iteration (`.3` after supplement number)

**Investigation approach:**
```bash
# Get detailed corrigendum failures
bundle exec rspec spec/pubid_new/iso/identifiers/corrigendum_spec.rb \
  --format documentation 2>&1 | grep "Failed to parse" | cut -d"'" -f2 | \
  sort | uniq -c | sort -rn | head -30 > cor_failures.txt

# Analyze patterns
cat cor_failures.txt | grep -E "DCOR|FDCOR|FCOR|pDCOR|FDCor" | wc -l
```

### Priority 2: Edition with Language Rendering (~20-30 tests estimated)

**Patterns identified:**
- `ED1(fr)`, `ED2(fr)` - Edition number with language in parentheses
- `ED5` - Edition number without language following

**Current behavior**: Likely not rendering edition in these contexts
**Expected behavior**: Should render with `with_edition: true` parameter

### Priority 3: Multi-Level Supplement Rendering (~20-30 tests estimated)

**Pattern**: `ISO/IEC 13818-1:2015/Amd 3:2016/Cor 1:2017 ED5`
**Issues**:
- Edition number at end of multi-level supplement
- Proper rendering of supplement chain

## Recommended Session 14 Plan

**Goal: Reach 45% pass rate (1,287 passing, +55 tests)**

### Phase 1: Add DCOR/FDCOR/FCOR Typed Stages (45 minutes)

1. **Add missing typed stage patterns to parser** (~40 tests)
   - Update `lib/pubid_new/iso/parser.rb` typed_stage rule
   - Add: DCOR, FCOR, pDCOR
   - Add mixed-case variants: FDCor, DCor (already have FDAmd, DAmd)
   - Test in isolation
   - Run safety check
   - Commit

2. **Add corresponding TypedStage entries** 
   - Update `lib/pubid_new/iso/identifiers/corrigendum.rb` TYPED_STAGES
   - Add stage codes for new typed stages
   - Verify builder can find them

**Expected: ~40 tests fixed, total 1,272 passing**

### Phase 2: Handle Supplement Iteration (30 minutes)

3. **Add iteration support in supplement patterns**
   - Update supplement rule in parser to allow optional `.` + digits after supplement_number
   - Handle both `Cor 1.3` and `pDCOR.2` patterns
   - Test in isolation
   - Run safety check
   - Commit

**Expected: ~15 tests fixed, total 1,287 passing**

### Phase 3: Documentation & Analysis (30 minutes)

4. **Run Full Test Suite**
   - Document final results
   - Update context.md
   - Create Session 15 continuation plan if needed
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
# Get failure details from corrigendum tests
bundle exec rspec spec/pubid_new/iso/identifiers/corrigendum_spec.rb \
  --format documentation --only-failures > detailed_failures.txt

# Count failure types
grep "Failed to parse" detailed_failures.txt | wc -l
grep "expected:" detailed_failures.txt | wc -l
```

## Files to Focus On

### For Typed Stage Additions
- `lib/pubid_new/iso/parser.rb` - Add DCOR, FCOR, pDCOR, mixed-case variants
- `lib/pubid_new/iso/identifiers/corrigendum.rb` - Add TYPED_STAGES entries

### For Supplement Iteration
- `lib/pubid_new/iso/parser.rb` - Update supplement rule to capture iteration
- `lib/pubid_new/iso/builder.rb` - Handle iteration in supplement building (may already work)

### For Builder Logic (if needed)
- `lib/pubid_new/iso/builder.rb` - Extract and use iteration for supplements

## Key Reminders

1. **ALWAYS run safety check** after each change (106/106 must pass)
2. **Use data-driven approach** - test exact failing patterns first
3. **Test specific patterns** before running full suite
4. **Commit frequently** - each logical fix gets its own commit
5. **Track test count changes** - know impact of each fix
6. **Follow Session 13 pattern** - incremental, focused improvements

## Success Metrics

**Minimum for Session 14:**
- 1,287 passing (45.0%) - +55 from Session 13
- 800 failing (28.0%) - -55 from Session 13
- Maintain core: 106/106 passing

**Stretch for Session 14:**
- 1,330 passing (46.5%) - +98 from Session 13  
- 757 failing (26.5%) - -98 from Session 13

## Known Working Patterns (from Session 12-13)

These work correctly:
- All stages: PWI, NP, NWIP→NP, AWI, WD, CD, DIS, FDIS, PRF, FCD, preCD (normalized)
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
- Base without year + supplement: `ISO 10360-1/Cor 1:2002`

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
- Normalization happens in Builder, not Parser

## Code Change Template

When adding typed stages:

```ruby
# In lib/pubid_new/iso/parser.rb
rule(:typed_stage) do
  (str("FDAM") | str("FDAmd") | str("FDAMD") |
   str("PDAM") | str("PDAmd") |
   str("DAM") | str("DAmd") | str("DAMD") | str("DAD") |
   str("FDCOR") | str("FDCor") |      # Add FDCor variant
   str("DCOR") | str("DCor") |        # Add DCor variant  
   str("FCOR") | str("FCor") |        # NEW: FCOR variants
   str("pDCOR") |                      # NEW: preliminary DCOR
   str("DTR") | str("DTS") | str("DIS") | str("FDIS") | str("FDTR") | str("FDTS") |
   str("PDTR") | str("PDTS")).as(:typed_stage)
end
```

```ruby
# In lib/pubid_new/iso/identifiers/corrigendum.rb
TYPED_STAGES = [
  TypedStage.new(abbr: ["Cor"], stage_code: "published"),
  TypedStage.new(abbr: ["FDCOR", "FDCor"], stage_code: "fdcor"),
  TypedStage.new(abbr: ["DCOR", "DCor"], stage_code: "dcor"),
  TypedStage.new(abbr: ["FCOR", "FCor"], stage_code: "fcor"),      # NEW
  TypedStage.new(abbr: ["pDCOR"], stage_code: "pdcor"),           # NEW
].freeze
```

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

# Detailed corrigendum failures
bundle exec rspec spec/pubid_new/iso/identifiers/corrigendum_spec.rb \
  --format documentation --only-failures | head -100

# Commit changes
git add -A && git commit -m "TYPE(iso): DESCRIPTION"
```

## Notes for Next Developer

1. **Start with typed stages** - DCOR, FCOR, pDCOR additions are straightforward
2. **Then handle iteration** - Supplement iteration pattern `Cor 1.3`, `pDCOR.2`
3. **Session 13 maintained quality** - Small incremental improvements (+9 tests)
4. **Test in isolation first** - Use ruby -e before running full suite
5. **Follow the template** - Both parser and TYPED_STAGES need updates
6. **Prioritize data-driven** - Test exact failing patterns from analysis
7. **Document as you go** - Update context.md with findings

Good luck with Session 14! The path to 45% is clear with corrigendum typed stages.
