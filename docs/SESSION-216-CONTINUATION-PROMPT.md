# Session 216 Continuation Prompt

**Read this file to continue CIE enhancement work.**

## Quick Start

1. Read the comprehensive plan: `docs/SESSION-216-CONTINUATION-PLAN.md`
2. Read memory bank files (automatically done by system)
3. Begin Session 216: Language Format Fixes (90 minutes)

## Current Status

- **CIE:** 93.59% (321/343 passing)
- **Target:** 97%+ (333+/343 passing)
- **Sessions planned:** 216-218 (3-4 hours total)

## Session 216 Focus

**Objective:** Fix Category 1 - Language before ISO reference (+13 identifiers)

**Files to modify:**
- `lib/pubid_new/cie/parser.rb` - Add language_with_year_before_iso rule
- `lib/pubid_new/cie/builder.rb` - Update build_identical method
- `lib/pubid_new/cie/identifiers/identical.rb` - Update to_s rendering

**Expected gain:** +13 identifiers (93.59% → 97.38%)

## Architecture Principles

- MODEL-DRIVEN: Objects not strings
- MECE: Mutually exclusive, collectively exhaustive
- Three-layer: Parser/Builder/Identifier independence
- No compromises on architecture quality

## Key Patterns to Fix

**Category 1 (HIGH PRIORITY):** 13 identifiers
```
#CIE S 014-4/E2007                    # /E before year
#CIE S 008/E:2001 (ISO 8995-1:2002(E))  # /E:YYYY before ISO ref
```

**Pattern:** Language code `/E` or `/E:YYYY` before ISO reference in parentheses

**Solution:** Update identical_with_iso rule to parse language before ISO reference

## Next Actions

1. Implement Part A: Parser language format (40 min)
2. Implement Part B: Builder updates (30 min)  
3. Implement Part C: Rendering fixes (20 min)
4. Test and verify +13 identifiers gained

## Documentation

Full implementation details in: `docs/SESSION-216-CONTINUATION-PLAN.md`

**Status:** READY FOR EXECUTION
**Priority:** MANDATORY
**Timeline:** 3-4 hours total (Sessions 216-218)
