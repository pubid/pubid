# Session 25+ Continuation Plan: ISO Builder Architecture & Test Improvements

## Critical Context - READ THIS FIRST

**Session 24 successfully fixed canonical TypedStage rendering** achieving 79.0% passing tests (+43 tests in one session). The ISO Builder continues to follow the 5 core principles documented in `.kilocode/rules/memory-bank/architecture.md`.

**IMPORTANT**: The clean architecture uses **TYPED_STAGE REGISTER** as the single source of truth. Builder **NEVER** makes type/stage decisions - it only casts parsed data to domain objects.

## Current State (Session 24 Complete)

### Test Results
- **Total**: 2,859 examples
- **Passing**: 2,258 (79.0%)
- **Failing**: 224 (7.8%)
- **Pending**: 377 (13.2%)

### Session 24 Progress
- Fixed TypedStage canonical abbreviation: +28 tests (77.5% → 78.4%)
- Fixed Edition.number as Code object: +2 tests (78.4% → 78.5%)
- Fixed SingleIdentifier canonical rendering: +9 tests (78.5% → 78.9%)
- Fixed Edition only when with_edition: +4 tests (78.9% → 79.0%)
- **Total impact**: +43 tests in one session!
- **Milestones**: ✅ 75% exceeded, approaching 80% (need +29 tests)

### Clean Architecture Verified ✅
1. ✅ TYPED_STAGE REGISTER is source of truth
2. ✅ Builder receives Scheme for lookups
3. ✅ Single cast() method for conversions
4. ✅ Composite hash returns for related values
5. ✅ Components render themselves

## Session 24/25 Immediate Priorities and Breakdown

### Priority 1: Analyze Remaining 224 Failures (Est. 30 min)

Run comprehensive failure analysis:

```bash
bundle exec rspec spec/pubid_new/iso/ --format documentation 2>&1 | \
  grep "Failure/Error:" | \
  sort | uniq -c | sort -rn | head -20
```

Current known breakdown:
1. **Parser failures**: ~92 (require grammar changes, risky)
2. **Addendum spec**: 81 failures (mostly parser issues)
3. **Scattered rendering**: ~51 failures across multiple specs

### Priority 2: Target Quick Wins for 80% Milestone (+29 tests needed)

Focus on specs with 2-15 failures each:
- `directives_spec.rb`: 4 failures
- `guide_spec.rb`: 15 failures
- `directives_supplement_spec.rb`: 11 failures
- `supplement_spec.rb`: 3 failures
- `technical_specification_spec.rb`: 2 failures
- `international_workshop_agreement_spec.rb`: 2 failures

**Strategy**: Analyze each spec's failures for fixable patterns in rendering or data structure.

### Priority 3: Document Patterns for Future Work

If 80% is achieved:
- Document remaining parser patterns for future enhancement
- Update memory bank with Session 25 results
- Plan approach for 85% milestone

**Do NOT**:
- Attempt major parser refactoring (diminishing returns at 79%)
- Add hardcoded logic to Builder
- Make changes without data analysis

## Remaining Known Issues (224 failures)

### Breakdown by Type:
1. **Parser gaps**: ~92 failures (require grammar enhancements)
2. **Addendum spec**: 81 failures (complex patterns, low priority)
3. **Guide rendering**: 15 failures (TypedStage API + specific patterns)
4. **Directives**: 15 failures total (4 + 11, rendering edge cases)
5. **Other specs**: ~21 failures (scattered patterns)

### Parser Failures

When you see "Failed to parse", it means:
1. Parser grammar doesn't match the pattern
2. Parser rule ordering issue (specific pattern shadowed)
3. New identifier pattern not yet implemented

**Strategy**: At 79%, parser fixes have diminishing returns. Focus on rendering fixes that don't require grammar changes.

## Success Metrics

### Session 24 Goals:
- 🎯 **TARGET**: 2,287+ passing (80%+) through rendering + parser fixes
- ✅ **GOOD**: 2,200-2,287 passing (77%-80%)
- ⚠️ **MIXED**: 2,150-2,200 passing (need different approach)

### Session 25 Goals:
- 🎯 **TARGET**: 2,287+ passing (80%+) through targeted rendering fixes
- ✅ **GOOD**: 2,270-2,286 passing (79.4%-79.9%)
- ⚠️ **MIXED**: <2,270 passing (need different approach)

### Long-term Targets:
- ✅ **70% (2,001 passing)**: ACHIEVED in Session 23
- ✅ **75% (2,144 passing)**: EXCEEDED in Session 23 (2,216 = 77.5%)
- 🎯 **80% (2,287 passing)**: Current milestone (need +29 tests)
- **85% (2,430 passing)**: Long-term goal (+172 from current)

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

**Session 24 commits**:
- `1ab4e15` - fix(iso): use canonical TypedStage abbreviation when normalizing (+28 tests)
- `b69e0b7` - fix(iso): wrap edition.number in Code object for consistency (+2 tests)
- `b311f8c` - fix(iso): use canonical TypedStage abbreviation in SingleIdentifier (+9 tests)
- `1002ac3` - fix(iso): only render edition when with_edition parameter is true (+4 tests)

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
- **Session 23 was successful** because it understood copublisher data architecture
- **Session 24 was successful** because it fixed TypedStage rendering with canonical abbreviations
- **The architecture is clean** - all future work should preserve this
- **80% milestone is very close** - only +29 tests needed
- **IEC migration** should wait until ISO is 80%+ and patterns are clear

## Session 24 Key Learnings

1. **TypedStage architecture discovery**: Need both `abbreviation` (preserves parsed) and `canonical_abbreviation` (normalized) methods
2. **Rendering normalization**: SingleIdentifier always uses canonical, SupplementIdentifier uses canonical only with `with_edition: true`
3. **Edition control**: Only render edition when explicitly requested via `with_edition` parameter
4. **Data-driven approach**: Focused analysis identified 4 fixable patterns that gained +43 tests
5. **Incremental commits work**: Each of 4 commits improved tests without breaking others

Good luck with Session 25!