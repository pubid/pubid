# Builder Architecture Migration Plan

## Objective

Fix ISO and migrate IEC to use the clean Builder architecture from commit 05581a336fc770796b873e538c058a520d645b12.

## Core Principles (NEVER VIOLATE)

1. **TYPED_STAGE REGISTER** - Single source of truth for all type/stage logic
2. **Builder.new(scheme)** - Builder receives Scheme for register lookups
3. **Single cast() method** - ALL conversions in ONE place
4. **Composite hash returns** - Related values returned together
5. **Components render themselves** - No hardcoded rendering logic

## ISO Migration Tasks

### Phase 1: Fix Builder (IMMEDIATE)

**Current Issues:**
- Reverted to clean version but missing ISO-specific components namespace
- Builder references `Components::` but should use `PubidNew::Iso::Components::`
  OR should move components to shared location

**Actions:**
1. ✅ Check if ISO components should be in `lib/pubid_new/iso/components/` or `lib/pubid_new/components/`
2. Fix Builder requires to match actual component locations
3. Verify Scheme class exists and provides required methods:
   - `locate_typed_stage_by_abbr(string)`
   - `locate_identifier_klass_by_type_code(type_code)`

**Files to check:**
- `lib/pubid_new/iso/builder.rb` - Fix component references
- `lib/pubid_new/iso/scheme.rb` - Ensure exists with required methods
- `lib/pubid_new/iso/components/` - Verify all components exist

### Phase 2: Verify Identifier Classes

**Actions:**
1. Ensure all identifier classes inherit from correct base
2. Verify TYPED_STAGES arrays exist in each class
3. Check rendering methods use `typed_stage.abbreviation`
4. Remove any hardcoded type/stage logic

**Files to check:**
- `lib/pubid_new/iso/single_identifier.rb`
- `lib/pubid_new/iso/supplement_identifier.rb`
- `lib/pubid_new/iso/identifiers/*.rb`

### Phase 3: Test and Fix

**Actions:**
1. Run tests to identify specific failures
2. Fix failures ONLY by:
   - Enhancing TYPED_STAGES register
   - Fixing parser patterns
   - Adding missing components
   - NEVER by adding Builder conditionals

## IEC Migration Tasks

### Phase 1: Audit Current IEC

**Actions:**
1. Read current IEC Builder
2. Identify hardcoded type/stage logic
3. Map to clean architecture patterns
4. Document IEC-specific requirements

**Files to audit:**
- `lib/pubid_new/iec/builder.rb`
- `lib/pubid_new/iec/scheme.rb`
- `lib/pubid_new/iec/components/`
- `lib/pubid_new/iec/identifiers/`

### Phase 2: Create IEC Scheme

**Actions:**
1. Create `lib/pubid_new/iec/scheme.rb` if missing
2. Implement `locate_typed_stage_by_abbr`
3. Implement `locate_identifier_klass_by_type_code`
4. Build TYPED_STAGES_REGISTRY
5. Build IDENTIFIER_CLASS_MAP

### Phase 3: Refactor IEC Builder

**Actions:**
1. Add `initialize(scheme)` method
2. Convert all type/stage logic to use `locate_typed_stage`
3. Consolidate conversions into single `cast()` method
4. Remove hardcoded type/stage checks
5. Ensure composite hash returns for `type_with_stage`

### Phase 4: Update IEC Components

**Actions:**
1. Ensure components exist under `PubidNew::Iec::Components::`
2. Verify Code component has proper API
3. Add any missing components
4. Ensure components render themselves

### Phase 5: Update IEC Identifiers

**Actions:**
1. Add TYPED_STAGES arrays to each class
2. Update rendering to use `typed_stage.abbreviation`
3. Remove hardcoded abbreviation logic
4. Test round-trip parsing

## Testing Strategy

### For Each Migration Step:

1. **Run tests BEFORE changes** - Document baseline
2. **Make ONE focused change** - Single responsibility
3. **Run tests AFTER** - Verify improvement or no regression
4. **Document what worked** - Build success patterns
5. **Commit incrementally** - Atomic, revertible changes

### Success Criteria:

- ✅ Builder has ONLY cast() method for conversions
- ✅ NO hardcoded type/stage checks in Builder
- ✅ Scheme provides all lookups via register
- ✅ Identifiers use typed_stage.abbreviation for rendering
- ✅ All tests passing (or improved from baseline)

## Common Pitfalls to Avoid

❌ **DON'T:**
- Add conditional logic to Builder
- Hardcode type abbreviations
- Duplicate type/stage checks
- Make Builder handle rendering decisions
- Create helper methods that check types

✅ **DO:**
- Use scheme.locate_typed_stage_by_abbr()
- Return composite hashes from cast()
- Let components render themselves
- Add to TYPED_STAGES register
- Trust the architecture

## File Structure Reference

```
lib/pubid_new/{flavor}/
├── scheme.rb               # REQUIRED: Provides register lookups
├── builder.rb              # REQUIRED: Transforms parse tree
├── parser.rb               # Grammar-based parsing
├── identifier.rb           # Base class with parse() method
├── single_identifier.rb    # For base documents
├── supplement_identifier.rb # For amendments
├── components/             # Flavor-specific components
│   ├── publisher.rb
│   ├── code.rb
│   └── ...
└── identifiers/            # Concrete identifier types
    ├── international_standard.rb
    ├── amendment.rb
    └── ...
```

## Next Steps

1. Fix ISO Builder component references
2. Verify ISO Scheme exists and works
3. Run ISO tests and document results
4. Create baseline IEC audit
5. Begin IEC migration following ISO patterns

## References

- Clean architecture: commit 05581a336fc770796b873e538c058a520d645b12
- Memory bank: `.kilocode/rules/memory-bank/architecture.md`
- This plan: `.kilocode/rules/memory-bank/builder-migration-plan.md`
