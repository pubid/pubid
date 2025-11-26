# Session 26+ Continuation Plan: ISO Builder Architecture & Test Improvements

## Critical Context - READ THIS FIRST

**Session 25 successfully improved rendering consistency** achieving 79.5% passing tests (+11 tests). The ISO Builder continues to follow the 5 core principles documented in `.kilocode/rules/memory-bank/architecture.md`.

**IMPORTANT**: The clean architecture uses **TYPED_STAGE REGISTER** as the single source of truth. Builder **NEVER** makes type/stage decisions - it only casts parsed data to domain objects.

## Current State (Session 25 Complete)

### Test Results
- **Total**: 2,859 examples
- **Passing**: 2,269 (79.5%)
- **Failing**: 213 (7.5%)
- **Pending**: 377 (13.2%)

### Session 25 Progress
- Fixed Guide TYPED_STAGES stage_code: +3 tests (79.0% → 79.1%)
- Fixed Supplement canonical abbreviation: +3 tests (79.1% → 79.2%)
- Fixed IWA language_portion: +2 tests (79.2% → 79.3%)
- Fixed Directives canonical abbreviation: +3 tests (79.3% → 79.5%)
- **Total impact**: +11 tests in one session
- **Milestones**: ✅ 75% exceeded, approaching 80% (need +18 tests)

### Specs Now 100% Passing
- ✅ `supplement_spec.rb` (fixed in Session 25)
- ✅ `international_workshop_agreement_spec.rb` (fixed in Session 25)

### Clean Architecture Verified ✅
1. ✅ TYPED_STAGE REGISTER is source of truth
2. ✅ Builder receives Scheme for lookups
3. ✅ Single cast() method for conversions
4. ✅ Composite hash returns for related values
5. ✅ Components render themselves (canonical_abbreviation pattern)

## Session 26 Immediate Priorities and Breakdown

### Priority 1: Analyze Remaining 213 Failures (Est. 20 min)

Run comprehensive failure analysis:

```bash
bundle exec rspec spec/pubid_new/iso/ --format documentation 2>&1 | \
  grep "Failure/Error:" | \
  sort | uniq -c | sort -rn | head -20
```

Current known breakdown:
1. **Parser failures**: ~207 (require grammar changes, risky at 79.5%)
2. **Rendering failures**: ~6 (low-hanging fruit for 80% milestone)

### Priority 2: Target Final Quick Wins for 80% Milestone (+18 tests needed)

Known remaining rendering failures (6 total):
- **Directives spacing**: 2 failures (" + IEC SUP" needs space)
- **DirectivesSupplement**: 2 failures (format + edition rendering)
- **Guide uppercase**: 1 failure ("ISO/GUIDE" vs "ISO/Guide")
- **Addendum legacy**: 1 failure (rare format)

**Strategy**: Fix the 6 rendering failures to get closer to 80% milestone, then assess parser work.

### Priority 3: Document Session 26 and Plan 85% Approach

When 80% is achieved or close:
- Document Session 26 results in memory bank
- Update continuation plan with Session 26 learnings
- Assess whether parser enhancement is worth pursuing for 85%

**Do NOT**:
- Attempt parser refactoring without clear benefit analysis
- Add hardcoded logic to Builder
- Make changes without data-driven analysis

## Remaining Known Issues (213 failures)

### Breakdown by Type:
1. **Parser gaps**: ~207 failures (92 systematic + ~115 scattered)
2. **Rendering fixes**: ~6 failures (achievable quick wins)
   - Directives combined identifier spacing (2)
   - DirectivesSupplement format/edition (2)
   - Guide uppercase inconsistency (1)
   - Addendum legacy format (1)

### Parser Failures

When you see "Failed to parse", it means:
1. Parser grammar doesn't match the pattern
2. Parser rule ordering issue (specific pattern shadowed)
3. New identifier pattern not yet implemented

**Strategy**: At 79.5%, parser fixes have significant diminishing returns. Focus remaining effort on the 6 rendering fixes, then reassess whether parser work is worthwhile.

## Success Metrics

### Session 25 Goals:
- 🎯 **TARGET**: 2,287+ passing (80%+) through targeted rendering fixes
- ✅ **GOOD**: 2,270-2,286 passing (79.4%-79.9%) ← **ACHIEVED 2,269 (79.5%)**
- ⚠️ **MIXED**: <2,270 passing (need different approach)

### Session 26 Goals:
- 🎯 **TARGET**: 2,287+ passing (80%+) by fixing final 6 rendering failures
- ✅ **GOOD**: 2,280-2,286 passing (79.8%-79.9%)
- ⚠️ **MIXED**: <2,280 passing (assess parser work)

### Long-term Targets:
- ✅ **70% (2,001 passing)**: ACHIEVED in Session 23
- ✅ **75% (2,144 passing)**: EXCEEDED in Session 23 (2,216 = 77.5%)
- 🎯 **80% (2,287 passing)**: Current milestone (need +18 tests from 2,269)
- **85% (2,430 passing)**: Long-term goal (requires parser work, ~161 more tests)

## Testing Strategy

### Always Follow This Process:

1. **Before ANY change**: Document baseline test count
2. **Make ONE focused change**: Single responsibility
3. **Run tests**: `bundle exec rspec spec/pubid_new/iso/`
4. **Compare results**: Did it improve or regress?
5. **Commit incrementally**: Semantic message with impact

### Example Workflow:

```bash
# 1. Baseline
bundle exec rspec spec/pubid_new/iso/ | grep "examples,"
# => 2859 examples, 266 failures, 377 pending

# 2. Make focused change
# ... edit one file with one fix

# 3. Test
bundle exec rspec spec/pubid_new/iso/ | grep "examples,"
# => 2859 examples, 240 failures, 377 pending  (+26 tests!)

# 4. Commit
git add -A
git commit -m "fix(iso): handle edition rendering in to_s

Updated identifier rendering to include edition properly.

Impact: +26 tests (77.5% → 78.4%)"
```

## Architecture Reference

### File Structure:
```
lib/pubid_new/iso/
├── scheme.rb               # Registry (NEW in Session 22)
├── builder.rb              # Clean architecture (FIXED in Session 22)
├── parser.rb               # Grammar-based parsing
├── identifier.rb           # Base class with parse()
├── single_identifier.rb    # For base documents
├── supplement_identifier.rb # For amendments
├── components/             # ISO-specific components
│   ├── publisher.rb        # Has .body alias
│   └── code.rb             # Has .value alias
└── identifiers/            # 17 concrete identifier types
    ├── international_standard.rb
    ├── amendment.rb
    └── ...
```

### Component Namespaces:

**ISO-specific** (use these for Publisher and Code):
- `PubidNew::Iso::Components::Publisher`
- `PubidNew::Iso::Components::Code`

**Shared** (use these for other components):
- `PubidNew::Components::Date`
- `PubidNew::Components::Edition`
- `PubidNew::Components::Language`
- `PubidNew::Components::Locality`
- `PubidNew::Components::Type`
- `PubidNew::Components::Stage`
- `PubidNew::Components::TypedStage`

### Key Classes:

**Scheme** ([`lib/pubid_new/iso/scheme.rb`](lib/pubid_new/iso/scheme.rb:1)):
- `locate_typed_stage_by_abbr(abbr)` - Lookup from register
- `locate_identifier_klass_by_type_code(type_code)` - Get identifier class

**Builder** ([`lib/pubid_new/iso/builder.rb`](lib/pubid_new/iso/builder.rb:1)):
- `initialize(scheme)` - Receive scheme for lookups
- `build(parsed_hash)` - Transform parse tree to identifier
- `cast(type, value)` - Convert parsed value to component

## Common Tasks

### To analyze failures:
```bash
bundle exec rspec spec/pubid_new/iso/ --format documentation 2>&1 | \
  grep "Failure/Error:" | \
  sort | uniq -c | sort -rn | head -20
```

### To see actual error messages:
```bash
bundle exec rspec spec/pubid_new/iso/identifier_spec.rb --format documentation 2>&1 | \
  grep -A 5 "Failure/Error:" | head -40
```

### To test a specific identifier type:
```bash
bundle exec rspec spec/pubid_new/iso/identifiers/amendment_spec.rb
```

### To run parser tests only:
```bash
bundle exec rspec spec/pubid_new/iso/parser_spec.rb
```

## Memory Bank Files

**ALWAYS read these first**:
1. `.kilocode/rules/memory-bank/architecture.md` - Full architecture with Builder section
2. `.kilocode/rules/memory-bank/builder-migration-plan.md` - ISO/IEC migration plan
3. `.kilocode/rules/memory-bank/context.md` - Current state and recent changes

## Git Reference

**Clean architecture commit**: `05581a336fc770796b873e538c058a520d645b12`
**Session 22 completion**: `fd3b590` - feat(iso): create Scheme and fix Builder architecture
**Session 23 completion**: `57807ca` - fix(iso): merge copublishers into Publisher object
**Session 24 completion**: `1002ac3` - fix(iso): only render edition when with_edition parameter is true
**Session 25 completion**: `f36daaf` - fix(iso): use canonical abbreviation in Directives rendering

**Session 25 commits**:
- `f03c350` - fix(iso): use Guide-specific stage_code values in TYPED_STAGES (+3 tests)
- `8ba7979` - fix(iso): use canonical abbreviation in SupplementIdentifier (+3 tests)
- `d9450f8` - fix(iso): include language codes in IWA to_s method (+2 tests)
- `f36daaf` - fix(iso): use canonical abbreviation in Directives rendering (+3 tests)

## Key Reminders

1. **Trust the architecture** - It worked before being broken
2. **One fix at a time** - Incremental, atomic changes
3. **Data-driven only** - No speculative changes
4. **Ask before hardcoding** - There's always a register-based solution
5. **Read memory bank first** - All principles are documented

## Example Session Flow

**Good Session Example**:
```
1. Read memory bank files
2. Run baseline tests (2859 examples, 266 failures)
3. Analyze top failure pattern (rendering)
4. Read relevant code (identifier to_s methods)
5. Understand rendering issue
6. Make focused fix (attribute rendering)
7. Test (2859 examples, 240 failures) +26!
8. Commit with semantic message
9. Analyze next pattern
10. Repeat with second fix if time permits
```

**Bad Session Example** (DON'T DO THIS):
```
1. Skip memory bank
2. Make multiple speculative changes
3. Add hardcoded logic to Builder
4. Don't test after each change
5. Make combined commit
6. Tests regress
7. Hard to identify which change broke what
```

## Final Notes

- **Session 22 was successful** because it fixed infrastructure (Scheme) and API compatibility
- **Session 23 was successful** because it understood copublisher data architecture (+238 tests)
- **Session 24 was successful** because it fixed TypedStage rendering with canonical abbreviations (+43 tests)
- **Session 25 was successful** because it applied canonical_abbreviation pattern consistently (+11 tests)
- **The architecture is clean** - all future work should preserve this
- **80% milestone is very close** - only +18 tests needed
- **Parser work assessment needed** - 85% would require ~161 more tests, mostly from parser enhancements

## Session 25 Key Learnings

1. **TypedStage canonical pattern**: Most identifiers should use `canonical_abbreviation` for consistent output
2. **Rendering consistency**: Applied same fix pattern across 3 identifier types (Supplement, Directives, SingleIdentifier)
3. **Missing language_portion**: IWA was the only identifier missing language code rendering
4. **Guide-specific stage codes**: Some identifiers need type-specific stage_code values (e.g., :dguide not :draft)
5. **Incremental wins work**: 4 focused fixes (+3, +3, +2, +3) achieved +11 tests total

## Session 26 Recommended Approach

**Step 1**: Target the 6 remaining rendering failures (40-50 min)
- Fix Directives combined identifier spacing (2 tests)
- Fix DirectivesSupplement format normalization (1 test)
- Fix DirectivesSupplement edition rendering (1 test)
- Fix Guide uppercase issue if solvable (1 test)
- Assess Addendum legacy format (1 test)

**Step 2**: Validate progress toward 80% (5 min)
- Run full test suite
- Document actual improvement
- Update memory bank

**Step 3**: Assess parser work value (10 min)
- If 80% achieved: Celebrate and plan 85% approach
- If 79.8-79.9%: Consider targeted parser fixes
- If <79.8%: Reassess strategy

Good luck with Session 26!