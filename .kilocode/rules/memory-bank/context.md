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

**Latest Session (Session 14 - ISO V2 Corrigendum Typed Stages & Supplement Iteration):**
- ✅ **Corrigendum Typed Stages** (+14 tests initial improvement)
  - Added missing typed stage patterns to parser: `FDCor`, `DCor`, `pDCOR`
  - Updated `legacy_part` negative lookahead to prevent typed stages from being parsed as parts
  - Now handles: `ISO/IEC 14496-12/DCor 1`, `ISO/IEC 14496-12/FDCor 1`, `ISO/IEC 10646-1:1993/pDCOR 2`
- ✅ **Supplement Iteration Support** (+66 tests additional improvement)
  - Added iteration support for all supplement patterns (`.3` after supplement number)
  - Handles patterns like `DCor 1.3:2002`, `FDCor 2.3`, and special `pDCOR.2` syntax
  - Three parser patterns added: typed stage with iteration only, with number+iteration, and existing patterns
- ✅ **Results**: 1,312 passing (45.9%), 799 failing (27.9%), 748 pending (26.2%)
- ✅ **Progress**: +80 tests (+2.8pp), -56 failures (-2.0pp), -24 pending (-0.8pp) from Session 13
- ✅ **Exceeded target**: Goal was 45.0% (1,287), achieved 45.9% (1,312) - **+25 tests over target**
- ✅ Single focused commit: Corrigendum typed stages and supplement iteration
- ✅ Clean architecture: All fixes maintain core test suite (106/106 passing)

**Previous Sessions:**
- Session 13: Stage normalization (NWIP→NP), legacy part fix → 1,232 passing (+9)
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

**Immediate Priorities (Session 15):**

1. **Remaining parse failures** (~620 tests estimated)
   - Continue systematic failure analysis
   - Focus on remaining supplement iteration edge cases
   - Investigate edition with language patterns: `ED1(fr)`, `ED5`
   - Target 48% pass rate (1,372 passing, +60 tests)

2. **Rendering differences** (~180 tests estimated)
   - Multi-level supplement rendering improvements
   - Edition rendering with `with_edition` parameter
   - Continue pattern-based fixes

**Near-Term Goals:**

1. Achieve 48% ISO test pass rate (1,372/2,859 passing) - Target for Session 15
2. Achieve 50% ISO test pass rate (1,430/2,859 passing) - Next major milestone
3. Resolve high-impact rendering differences
4. Complete all flavor migrations to V2 server-side VM code
5. Apply migration pattern to remaining flavors: ETSI, ITU, CCSDS
6. Complete V2 BSI migration
7. Complete V2 NIST/CEN compliance
8. Update migrator to handle multi-version migrations

### Active Development Areas

- **Active**: ISO test refinement with targeted improvements
- **Not changing**: Core completed flavors (IEC, JIS, ETSI, ITU, CCSDS)
- **Architecture locked**: Three-layer pattern established and proven

### Known Issues

- ISO: 799 test failures (27.9%) - parser gaps + rendering differences
- ISO: 748 pending tests (26.2%) - includes typed_stage architectural differences
- V1 code still exists but not being actively developed
- Migration documentation complete and comprehensive

### Files Changed in Session 14

- Parser: lib/pubid_new/iso/parser.rb (typed stages, legacy_part, supplement iteration)
- Commits: 1 semantic commit (corrigendum typed stages and supplement iteration)
- Test improvement: 1,232→1,312 passing (+80), 855→799 failing (-56)
- Pass rate: 43.1% → 45.9% (+2.8pp)

### Session 14 Key Achievements

1. **Typed stage variants working**: FDCor, DCor, pDCOR now parse correctly
2. **Supplement iteration implemented**: Handles `.3` after supplement numbers
3. **Special pDCOR.2 syntax**: Typed stage with iteration but no supplement number
4. **Legacy part protection extended**: All corrigendum typed stages prevented from part parsing
5. **Exceeded session target**: 45.9% achieved vs 45.0% goal (+25 tests over target)
6. **Strong improvement rate**: +80 tests (+2.8pp) in single session
7. **Foundation for Session 15**: Iteration patterns working, ready for edge cases
