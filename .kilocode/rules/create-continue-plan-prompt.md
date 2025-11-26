# Session 27+ Continuation Plan: ISO Builder Architecture & Test Improvements

## Critical Context - READ THIS FIRST

**Session 26 implemented correct ISO Guide rendering format** prioritizing **standards compliance over test fixtures**. This is the RIGHT architectural decision even though it caused temporary test regression.

**IMPORTANT**: The clean architecture uses **TYPED_STAGE REGISTER** as the single source of truth. Builder **NEVER** makes type/stage decisions - it only casts parsed data to domain objects.

## Current State (Session 26 Complete)

### Test Results
- **Total**: 2,859 examples
- **Passing**: 2,634 (77.9%)
- **Failing**: 225 (7.9%)
- **Pending**: 377 (13.2%)

### Session 26 Progress
- Fixed BundledIdentifier DirectivesSupplement spacing: +3 tests
- Fixed DirectivesSupplement edition rendering: +1 test
- Fixed Guide canonical abbreviation (mixed-case): +1 test
- **Implemented CORRECT Guide format**: "ISO Guide X" (space, no slash)
- **Test regression intentional**: Fixtures expect wrong format
- **Net change**: -13 tests (standards compliance > fixtures)

### Critical Decision: Guide Rendering Format

**CORRECT ISO Standard** (now implemented):
- **"ISO Guide 1"** - space before Guide, NO slash
- **"ISO/IEC Guide X"** - slash between publishers, space before Guide

**WRONG Format** (what fixtures expect):
- ~~"ISO/Guide 1"~~ - slash before Guide is INCORRECT per ISO standard

**Decision**: Implement the standard correctly. Test fixtures need updating, not the code.

### Specs Now 100% Passing
- ✅ `supplement_spec.rb` (fixed in Session 25)
- ✅ `international_workshop_agreement_spec.rb` (fixed in Session 25)

### Clean Architecture Verified ✅
1. ✅ TYPED_STAGE REGISTER is source of truth
2. ✅ Builder receives Scheme for lookups
3. ✅ Single cast() method for conversions
4. ✅ Composite hash returns for related values
5. ✅ Components render themselves (canonical_abbreviation pattern)

## Session 27 Immediate Priorities

### Priority 1: Update Guide Test Fixtures (Est. 30-40 min)

The Guide fixtures expect wrong format. Update them to expect correct ISO standard format:

```bash
# Find Guide tests expecting wrong format
grep -r "ISO/Guide\|ISO/GUIDE" spec/pubid_new/iso/identifiers/guide_spec.rb

# Update expectations to correct format:
# "ISO/Guide 1" → "ISO Guide 1"
# "ISO/IEC Guide X" stays the same (correct)
```

**Expected impact**: +~20 tests when fixtures corrected

### Priority 2: Continue Rendering Fixes (Est. 20-30 min)

Remaining rendering issues from Session 26 analysis:
- Parser failures: ~207 (require grammar changes)
- Other rendering: Check for any new patterns

### Priority 3: Assess 80% Milestone Path

After Guide fixtures updated:
- If 80%+ achieved: Document and plan 85% approach
- If 79%+: Identify final quick wins
- If <79%: Reassess strategy

**Do NOT**:
- Compromise standards compliance for test convenience
- Add hardcoded logic to Builder
- Make changes without understanding the standard

## Session 26 Key Learnings

1. **Standards compliance > Test fixtures**: When fixtures contradict the standard, implement the standard correctly
2. **BundledIdentifier architecture**: Separate classes for different separator types (` + ` vs ` | `)
3. **DirectivesSupplement special handling**: Needs space before `+` in bundled identifiers
4. **Guide publisher_portion override**: Required to use space instead of slash
5. **Temporary regression acceptable**: When implementing correct standards

## Session 26 Commits

**Session 26 completion**: `d141c4c` - fix(iso): implement correct Guide rendering format

**Session 26 commits**:
- `6bb5bdf` - fix(iso): add space before '+' for ISO DirectivesSupplement in bundled identifiers
- `67b54b9` - fix(iso): revert CombinedIdentifier to use pipe separator (+3 tests)
- `f5353e5` - fix(iso): add edition rendering to DirectivesSupplement (+1 test)
- `1adf211` - fix(iso): use mixed-case 'Guide' as canonical abbreviation (+1 test)
- `d141c4c` - fix(iso): implement correct Guide rendering format (standards > fixtures)

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