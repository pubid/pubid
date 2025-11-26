# Session 28+ Continuation Plan: ISO Builder Architecture & Test Improvements

## Critical Context - READ THIS FIRST

**Session 27 completed the Guide fixture updates** that validated Session 26's architectural decision to prioritize **standards compliance over test fixtures**. This recovered all +13 regressed tests and gained +5 more from cumulative improvements.

**IMPORTANT**: The clean architecture uses **TYPED_STAGE REGISTER** as the single source of truth. Builder **NEVER** makes type/stage decisions - it only casts parsed data to domain objects.

## Current State (Session 27 Complete)

### Test Results
- **Total**: 2,859 examples
- **Passing**: 2,275 (79.6%)
- **Failing**: 207 (7.2%)
- **Pending**: 377 (13.2%)

### Session 27 Progress
- Updated Guide test fixtures to expect correct ISO standard format: +13 tests recovered
- Gained additional +5 tests from cumulative improvements
- **Total impact**: +18 tests in one session
- Progress: 78.9% → 79.6% (+0.7pp)
- **80% milestone is VERY CLOSE**: Only +12 tests needed!

### Session 27 Achievement

**Phase 1: Update Guide Test Fixtures** (40 minutes)
- Updated all Guide spec expectations to use correct ISO standard format
- "ISO Guide X" (space, no slash) for single publisher ✅
- "ISO/IEC Guide X" (slash between publishers only) ✅
- Stage prefixes use space: "ISO NP Guide", "ISO DGuide", etc. ✅
- Recovered all +13 tests that regressed in Session 26
- File: [`spec/pubid_new/iso/identifiers/guide_spec.rb`](spec/pubid_new/iso/identifiers/guide_spec.rb:1)

**Phase 2: Cumulative Improvements** (automatic)
- Other specs gained +5 tests from previous sessions' fixes
- Total: +18 tests

### Critical Validation: Standards-First Architecture

**Session 26**: Implemented correct "ISO Guide 1" format (space, no slash)
**Session 27**: Updated fixtures to expect correct format
**Result**: Architecture validated, all tests recovered + bonus improvements

### Specs Now 100% Passing
- ✅ `supplement_spec.rb` (fixed in Session 25)
- ✅ `international_workshop_agreement_spec.rb` (fixed in Session 25)

### Clean Architecture Verified ✅
1. ✅ TYPED_STAGE REGISTER is source of truth
2. ✅ Builder receives Scheme for lookups
3. ✅ Single cast() method for conversions
4. ✅ Composite hash returns for related values
5. ✅ Components render themselves (canonical_abbreviation pattern)

## Session 28 Immediate Priorities

### Priority 1: Analyze Remaining 207 Failures (Est. 15-20 min)

Get breakdown of failure types:
```bash
bundle exec rspec spec/pubid_new/iso/ --format documentation 2>&1 | \
  grep "Failure/Error:" | \
  sort | uniq -c | sort -rn | head -20
```

Focus areas:
- Guide spec: 7 failures (parser issue with "FD Guide" spacing)
- Other identifier specs: ~200 failures
- Identify quick wins vs parser work

### Priority 2: Target Quick Wins for 80% Milestone (Est. 30-40 min)

**Goal**: Find +12 tests to reach 80% (2,287 passing)

**Strategy**:
1. Look for specs with 2-10 failures
2. Focus on rendering issues (not parser)
3. Apply canonical_abbreviation pattern where applicable
4. One fix at a time, test after each

**Candidate specs** (from previous analysis):
- `directives_spec.rb`: Check for any remaining issues
- `technical_specification_spec.rb`: 2 failures
- Other small-failure specs

### Priority 3: Celebrate 80% or Reassess (Est. 5-10 min)

After fixes:
- If 80%+ achieved: 🎉 Document milestone, plan 85% strategy
- If 79.8-79.9%: One more focused fix
- If <79.8%: Reassess approach

**Do NOT**:
- Compromise architecture for quick wins
- Add hardcoded logic to Builder
- Make speculative changes without analysis

## Session 27 Key Learnings

1. **Fixture validation works**: Updating fixtures to match correct implementation recovered all tests
2. **Cumulative improvements**: Previous fixes continue to provide value (+5 bonus tests)
3. **Standards-first validated**: Architecture approach of prioritizing standards over fixtures proven correct
4. **Guide format finalized**: Space before Guide for single publisher, slash only between copublishers
5. **Parser vs rendering**: 7 Guide failures are legitimate parser enhancements (space between "FD" and "Guide")

## Session 27 Commits

**Session 27 completion**: `ce3a282` - fix(iso): update Guide test fixtures to expect correct ISO standard format

**Impact**: +18 tests (207 failures, was 225)
- Guide spec: 7 failures (was 20) - fixed +13 tests
- Other specs: gained +5 tests
- Pass rate: 79.6% (was 78.9%)
- Total passing: 2,275/2,859 (was 2,257/2,859)

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