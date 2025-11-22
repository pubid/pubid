# PubID v2 Lutaml::Model Migration - Continuation Plan

## Mission Statement

Complete the migration of ALL PubID flavors (ISO, IEC, JIS, ETSI, ITU, IEEE, NIST, CCSDS, BSI, CEN) to proper Lutaml::Model architecture following MODEL-DRIVEN design principles.

## Current Status (2025-11-19)

### ✅ COMPLETED: IEC (100%)
- **Test Results:** 13,824/13,824 (100.0%)
- **Files Created:** 30 files (22 identifier types + infrastructure)
- **Architecture:** Full MODEL-DRIVEN implementation with proper separation of concerns
- **Documentation:** Comprehensive architecture guide in old-docs/

### 🎯 PRIORITY ORDER

1. **JIS** (Next Priority - Estimated 3-4 days)
   - Simple structure, good starting point after IEC
   - Fewer identifier types than IEC
   - Well-defined test fixtures

2. **ETSI** (Estimated 3-4 days)
   - Medium complexity
   - Telecom standards organization
   - Clear structure

3. **ITU** (Estimated 4-5 days)
   - International telecom union
   - Multiple series (ITU-T, ITU-R)
   - Complex stage system

4. **IEEE** (Estimated 4-5 days)
   - Professional organization standards
   - Unapproved drafts handling
   - Amendment patterns

5. **NIST** (Estimated 5-6 days)
   - US NIST publications
   - Multiple series types
   - Version handling

6. **CCSDS** (Estimated 2-3 days)
   - Space data systems
   - Simpler than others

7. **ISO** (Defer - Most Complex)
   - Largest scope, most identifier types
   - Joint publications (ISO/IEC)
   - Complex stage system
   - Save for after gaining experience with others

8. **BSI, CEN** (Defer - Lower Priority)
   - Regional standards
   - Can leverage patterns from ISO/IEC

## Core Principles (Non-Negotiable)

### 1. MODEL-DRIVEN Architecture
- Identifiers contain **actual object instances**, NOT strings
- ConsolidatedIdentifier stores array of identifier objects
- VapIdentifier/SheetIdentifier wrap other identifiers
- No string-based rendering in object attributes

### 2. MECE (Mutually Exclusive, Collectively Exhaustive)
- Each identifier is EXACTLY ONE type
- No overlapping responsibilities
- Complete coverage of all cases

### 3. Separation of Concerns
- **Parser:** Syntax parsing only (Parslet rules)
- **Builder:** Object construction (parsed data → objects)
- **Components:** Reusable attributes (Publisher, Code, Date, Edition)
- **Identifiers:** Business logic specific to identifier types
- **Scheme:** Registry and lookup

### 4. TYPED_STAGES Pattern
- **NEVER** use TYPE_MAP hash anti-pattern
- Always use `TYPED_STAGES = [TypedStage.new(...)]` array
- Each identifier class defines its own stages

### 5. Open/Closed Principle
- New types via classes, not modification
- Inheritance for shared behavior
- Wrapper pattern for augmentation

## Standard Implementation Checklist

For each flavor, follow these steps:

### Phase 1: Architecture Planning (1 day)
- [ ] Read v1 flavor code to understand identifier types
- [ ] List all identifier types (IS, TR, TS, AMD, COR, etc.)
- [ ] Identify inheritance hierarchy (SingleIdentifier vs SupplementIdentifier)
- [ ] Identify wrapper types (Consolidated, VAP-like, etc.)
- [ ] Plan component requirements (Publisher, Code, special components)

### Phase 2: Components (0.5 days)
- [ ] Create `lib/pubid_new/{flavor}/components/` directory
- [ ] Implement Publisher component with all variants
- [ ] Implement Code component if needed (number/part structure)
- [ ] Implement any flavor-specific components

### Phase 3: Base Infrastructure (1 day)
- [ ] Create `lib/pubid_new/{flavor}/identifier.rb` (base class)
- [ ] Create `lib/pubid_new/{flavor}/single_identifier.rb` (for base docs)
- [ ] Create `lib/pubid_new/{flavor}/supplement_identifier.rb` (for amendments)
- [ ] Create `lib/pubid_new/{flavor}.rb` (Scheme with registry)

### Phase 4: Identifier Types (2-3 days)
- [ ] Create `lib/pubid_new/{flavor}/identifiers/base.rb` with shared logic
- [ ] Implement each identifier type:
  - [ ] InternationalStandard (or equivalent)
  - [ ] TechnicalReport
  - [ ] TechnicalSpecification
  - [ ] Amendment
  - [ ] Corrigendum
  - [ ] (flavor-specific types...)
- [ ] Define TYPED_STAGES for each type
- [ ] Implement `to_s` rendering for each type

### Phase 5: Parser (1-2 days)
- [ ] Create `lib/pubid_new/{flavor}/parser.rb`
- [ ] Define all Parslet rules for format variations
- [ ] Handle copublishers if applicable
- [ ] Handle supplements and consolidation
- [ ] Handle special characters and formats

### Phase 6: Builder (1-2 days)
- [ ] Create `lib/pubid_new/{flavor}/builder.rb`
- [ ] Implement `build()` method
- [ ] Implement `cast()` for all parameter types
- [ ] Implement wrapper methods (consolidated, vap, etc.)
- [ ] Handle special cases (fragments, sheets, etc.)

### Phase 7: Testing & Iteration (1-2 days)
- [ ] Run integration tests
- [ ] Analyze failures by category
- [ ] Fix parser patterns
- [ ] Fix builder logic
- [ ] Fix identifier rendering
- [ ] Iterate until 100%

### Phase 8: Documentation (0.5 days)
- [ ] Update README.adoc with flavor features
- [ ] Document special patterns
- [ ] Add usage examples

## Key Lessons from IEC

### Architecture Successes
1. **MODEL-DRIVEN works perfectly** - objects compose naturally
2. **TYPED_STAGES is clean** - no hash lookups needed
3. **Wrapper pattern is elegant** - VapIdentifier, SheetIdentifier, FragmentIdentifier
4. **Separation of concerns** - Parser/Builder/Identifier split is clear

### Common Pitfalls Fixed
1. **Edition placement** - In VAP/CSV, edition goes AFTER suffix, not before
2. **Nil handling** - Always check for nil dates/editions before rendering
3. **Space formatting** - Careful with join(' ') and parts that have spaces
4. **Double wrapping** - Parser rules can accidentally double-wrap data
5. **Roman numerals** - Single "X" is often literal, not roman 10
6. **Fragment types** - FRAG vs FRAGC need different handling

### Parser Patterns Learned
1. Try longest matches first (sort by length)
2. Use `str()` for exact strings, `match()` for patterns
3. `.maybe` for optional elements
4. `.repeat(1)` for one-or-more
5. `.as(:symbol)` to capture in hash
6. Organize rules hierarchically (identifier → second_part → date)

### Builder Patterns Learned
1. Extract wrapper data BEFORE building base identifier
2. Build base identifier first, THEN wrap
3. Use `cast()` method for type conversion
4. Return early for special cases (FRAG, WD)
5. Always require classes at usage point

## File Structure Template

```
lib/pubid_new/{flavor}/
├── identifier.rb                    # Base Identifier class
├── single_identifier.rb             # For base documents
├── supplement_identifier.rb         # For amendments/corrigenda
├── parser.rb                        # Parslet parser
├── builder.rb                       # Object builder
├── components/
│   ├── publisher.rb                 # Publisher component
│   ├── code.rb                      # Number/part component (if needed)
│   └── {flavor}_specific.rb         # Any special components
├── identifiers/
│   ├── base.rb                      # Shared identifier logic
│   ├── international_standard.rb    # Or equivalent
│   ├── technical_report.rb
│   ├── technical_specification.rb
│   ├── amendment.rb
│   ├── corrigendum.rb
│   ├── consolidated_identifier.rb   # If needed
│   └── {other_types}.rb
└── renderers/                       # Optional, if complex rendering
    └── base.rb
```

## Next Session Start

```ruby
# Continuation prompt for next AI session:
Continue PubID Lutaml::Model Migration - JIS Implementation

IEC is now 100% complete (13,824/13,824 tests).

NEXT TASK: Implement JIS flavor following the IEC model-driven pattern.

REFERENCE FILES:
- gems/pubid-jis/lib/pubid/jis/ (v1 implementation)
- old-docs/IEC-MODEL-DRIVEN-ARCHITECTURE.md (architecture guide)
- docs/MIGRATION-CONTINUATION-PLAN.md (this file - implementation checklist)

START WITH:
1. Read v1 JIS code to understand identifier types
2. Create lib/pubid_new/jis/ directory structure
3. Follow Phase 1-8 checklist from MIGRATION-CONTINUATION-PLAN.md

MAINTAIN OO PRINCIPLES throughout all work.
```

## Success Criteria

For each flavor to be considered complete:
- ✅ 100% test pass rate
- ✅ All identifier types implemented
- ✅ MODEL-DRIVEN architecture (objects, not strings)
- ✅ TYPED_STAGES pattern used
- ✅ Proper separation of concerns
- ✅ No anti-patterns (TYPE_MAP, hardcoded handling)
- ✅ Documentation updated

## Estimated Timeline

- **JIS:** 3-4 days
- **ETSI:** 3-4 days  
- **ITU:** 4-5 days
- **IEEE:** 4-5 days
- **NIST:** 5-6 days
- **CCSDS:** 2-3 days
- **ISO:** 10-15 days (defer to end)
- **BSI/CEN:** 3-4 days each

**Total Estimated:** 35-50 days for all flavors

## End Goal

All PubID flavors migrated to v2 with:
- Clean MODEL-DRIVEN architecture
- 100% test coverage
- Proper Lutaml::Model usage
- No legacy anti-patterns
- Production-ready code
