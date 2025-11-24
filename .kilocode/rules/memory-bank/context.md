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

**Latest Session (Session 15 - ISO V2 Parser Enhancement Batch):**
- ✅ **Typed Stage Variants** (minimal impact)
  - Added `FCorr` variant to complement `FCor`/`FCOR`
  - Updated `legacy_part` negative lookahead to include FCorr/FCOR
- ✅ **Enhanced Edition Parsing**
  - Modified edition rule to handle standalone `ED` and `ED` with optional digits
  - Allows patterns like `ED`, `ED1`, `ED2`
- ✅ **Enhanced Year Parsing**
  - Added support for dash-prefixed years (`- 2024` in addition to `: 2024`)
  - Handles both colon and dash separators with optional spaces
- ✅ **Results**: 1,316 passing (46.0%), 797 failing (27.9%), 746 pending (26.1%)
- ✅ **Progress**: +4 tests (+0.1pp), -2 failures, -2 pending from Session 14
- ⚠️ **Limited Impact**: Batch approach had minimal effect because added patterns not heavily represented in test failures
- ✅ **Clean architecture**: All fixes maintain core test suite (106/106 passing)
- ✅ **Single commit**: Parser enhancements with semantic commit message

**Previous Sessions:**
- Session 14: Corrigendum typed stages (FDCor, DCor, pDCOR) + supplement iteration → 1,312 passing (+80)
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

**Immediate Priorities (Session 16):**

1. **Systematic Failure Analysis** (~620 parse failures)
   - Run comprehensive analysis of top failure patterns
   - Identify highest-frequency error types
   - Focus on patterns that affect 20+ tests each
   - Target data-driven improvements instead of speculative additions

2. **Rendering differences** (~180 tests estimated)
   - Multi-level supplement rendering improvements
   - Edition rendering with `with_edition` parameter
   - Continue pattern-based fixes

3. **Session 16 Target**: 48% pass rate (1,372 passing, +56 tests minimum)

### Near-Term Goals:

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

- ISO: 797 test failures (27.9%) - parser gaps + rendering differences
- ISO: 746 pending tests (26.1%) - includes typed_stage architectural differences
- V1 code still exists but not being actively developed
- Migration documentation complete and comprehensive

### Files Changed in Session 15

- Parser: lib/pubid_new/iso/parser.rb (FCorr typed stage, edition enhancements, year dash support)
- Commits: 1 semantic commit (typed stage variants and enhanced parsing patterns)
- Test improvement: 1,312→1,316 passing (+4), 799→797 failing (-2)
- Pass rate: 45.9% → 46.0% (+0.1pp)

### Session 15 Key Learnings

1. **Batch approach requires better targeting**: Adding patterns speculatively without analyzing actual test failures yields minimal results
2. **Need data-driven decisions**: Must analyze failure patterns to identify high-impact improvements
3. **Core stability maintained**: Despite limited progress, no regressions in working tests (106/106 passing)
4. **Parser enhancements completed**: FCorr, enhanced edition, dash-year support now available for future use
5. **Next session strategy**: Focus on systematic failure analysis before implementation
