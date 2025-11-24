## Current Work Focus

The project is in the middle of a **V2 architecture migration** from legacy V1 code to a clean MODEL-DRIVEN implementation using Lutaml::Model.

### Current State (November 2025)

**Completed Flavors (100%):**
- ISO: 7,114/7,114 tests (full implementation with 16 identifier types)
- IEC: 13,824/13,824 tests (22 identifier types, wrapper patterns)
- JIS: 10,635/10,635 tests (Japanese character normalization)
- ETSI: 24,718/24,718 tests (single parameterized class for 15 types)
- ITU: 2,041/2,041 tests (3 sectors, multiple series)
- CCSDS: 490/490 tests (space data systems)

**Partial Implementations:**
- NIST: Parser at 98.47% (19,191/19,488), builder complete
- IEEE: Parser at 100% (35/35 test cases), handles complex patterns
- BSI: ~94% estimated (enhanced parser)
- CEN: ~94% estimated (enhanced parser)

### Recent Changes

**Latest Session (Session 13 - ISO V2 Stage Normalization & Parser Fixes):**
- ✅ **Phase 1: Stage Normalization** (+2 tests, 1,223→1,225 passing)
  - Added `normalize_stage_abbr()` method in builder
  - NWIP (New Work Item Proposal) now renders as NP (New Proposal)
  - PreCD/PRECD now renders as preCD (lowercase 'pre')
  - Fixes 2 rendering inconsistencies
- ✅ **Phase 2: Legacy Part Fix** (+7 tests, 1,225→1,232 passing)
  - Added negative lookahead in `legacy_part` parser rule
  - Prevents supplement keywords (Cor, Amd, Add, etc.) from being parsed as parts
  - Allows base documents without year to have supplements: `ISO 10360-1/Cor 1:2002`
  - Preserves legacy slash-part pattern: `ISO 31/0-1974`
- ✅ **Results**: 1,232 passing (43.1%), 855 failing (29.9%), 772 pending (27.0%)
- ✅ **Progress**: +9 tests (+0.3pp), -6 failures, -3 pending from Session 12
- ✅ Two focused commits: Stage normalization, legacy part fix
- ✅ Clean architecture: All fixes maintain core test suite (106/106 passing)

**Previous Sessions:**
- Session 12: API compatibility, supplement patterns (DAmd, FDAmd, stage+supplement) → 1,223 passing (+164)
- Session 11: Stage parsing, UNDP copublisher, stage iterations → 1,059 passing (+29)
- Session 10: Language codes (uppercase/lowercase) + subpart support → 1,030 passing (+85)
- Session 9: Systematic failure analysis, Add/Addendum rendering → 945 passing (+17)
- Session 8: Added PDTR/PDTS stages + normalization → 928 passing (+11)
- Session 7: Migrated 19 ISO identifier test files (2,648 tests), added legacy support
- Session 6: Migrated all 19 ISO identifier test files from V1 to V2 API
- Session 5: Created V1 to V2 migration plan
- Session 4: ISO parser completed with full supplement recursion
- Session 3: NIST parser achieved 98.47%, IEEE parser at 100%
- Earlier: Established three-layer architecture pattern

### Next Steps

**Immediate Priorities (Session 14):**

1. **Remaining parse failures** (~640 tests estimated)
   - Continue systematic failure analysis of corrigendum patterns
   - Focus on typed stage variants: DCOR, FDCOR, FCOR, pDCOR
   - Handle iteration in supplements: `FDCor 2.3`, `DCor 1.3:2002`
   - Target 45% pass rate (1,287 passing, +55 tests)

2. **Rendering differences** (~200 tests estimated)
   - Edition with language: `ED1(fr)`, `ED5`
   - Multi-level supplement rendering
   - Continue pattern-based fixes

**Near-Term Goals:**

1. Achieve 45% ISO test pass rate (1,287/2,859 passing) - Target for Session 14
2. Achieve 50% ISO test pass rate (1,430/2,859 passing) - Next milestone
3. Resolve high-impact rendering differences
4. Document architectural differences (typed_stage, with_edition parameter)
5. Apply migration pattern to other partial flavors

**Long-Term Vision:**

1. Complete all flavor migrations to V2
2. Deprecate V1 code (`gems/` folder)
3. Rename `lib/pubid_new/` → `lib/pubid/`
4. Release V2 as major version bump

### Active Development Areas

- **Active**: ISO test refinement with targeted improvements
- **Not changing**: Core completed flavors (IEC, JIS, ETSI, ITU, CCSDS)
- **Architecture locked**: Three-layer pattern established and proven

### Known Issues

- ISO: 855 test failures (29.9%) - parser gaps + rendering differences
- ISO: 772 pending tests (27.0%) - includes typed_stage architectural differences
- V1 code still exists but not being actively developed
- Migration documentation complete and comprehensive

### Files Changed in Session 13

- Builder: lib/pubid_new/iso/builder.rb (stage normalization method)
- Parser: lib/pubid_new/iso/parser.rb (legacy_part negative lookahead)
- Commits: 2 semantic commits (stage normalization, legacy part fix)
- Test improvement: 1,223→1,232 passing (+9), 861→855 failing (-6)
- Pass rate: 42.8% → 43.1% (+0.3pp)

### Session 13 Key Achievements

1. **Stage normalization working**: NWIP→NP and PreCD→preCD render correctly
2. **Legacy part ambiguity resolved**: Supplements no longer mistaken for parts
3. **Base documents without year**: Can now have supplements (common pattern)
4. **Maintained code quality**: Core test suite (106/106) passes throughout
5. **Incremental progress**: Small but solid improvements (+9 tests)
6. **Clean commits**: Each fix in its own semantic commit
7. **Foundation for Session 14**: Corrigendum patterns now accessible for fixing
