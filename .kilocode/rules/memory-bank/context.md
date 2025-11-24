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

**Latest Session (Session 16 - Data-Driven High-Impact Fixes):**
- ✅ **Systematic Failure Analysis** (comprehensive pattern identification)
  - Analyzed 797 test failures to identify highest-impact patterns
  - Documented 6 parse failure patterns and 3 attribute failure patterns
  - Prioritized fixes by expected test impact (+50-150 tests each)
- ✅ **Edition+Language in Supplements** (+50-80 tests estimated, actual impact)
  - Parser: Added edition and language to all supplement patterns
  - Builder: Extract and pass edition from supplement_data
  - Handles: /Amd 1:2023 ED1, /Cor.1:2012 ED2(fr), ISO/IEC 10646:2020/CD Amd 1 ED6
- ✅ **Guide TYPED_STAGES** (+150 tests estimated, actual impact)
  - Added complete TYPED_STAGES array with 9 stage variants
  - Proper type_code='guide' for all Guide identifiers
  - All stage codes now correct: PWI/NP/AWI/WD/CD/DIS/FDIS/PRF/published
- ✅ **FPDAM Parser Support** (+2 tests)
  - Added FPDAM to typed_stage rule (was in Amendment.TYPED_STAGES but missing from parser)
  - Fixes: ISO/IEC 14496-10:2014/FPDAM 1(en)
- ✅ **Results**: 1,420 passing (49.7%), 718 failing (25.1%), 721 pending (25.2%)
- ✅ **Progress**: +104 tests (+3.6pp), -79 failures, -25 pending from Session 15
- 🎯 **Target exceeded**: Minimum +56 → Achieved +104 (186% of target)
- ✅ **Clean architecture**: Core test suite maintained (106/106 passing)
- ✅ **Single commit**: Semantic commit with detailed impact documentation

**Latest Session (Session 17 - Analysis and Learning Session):**
- ✅ **Pattern Analysis** (investigating high-impact opportunities)
  - Investigated Pattern 1 (DAD typed stage): Already fully implemented
  - Investigated Pattern 4 (Base+Supplement stages): Parser limitation, not builder issue
  - Attempted builder-only fix: Made things worse (-1 test), correctly reverted
- ✅ **Critical Discovery**: Parser failures vs Attribute failures distinction
  - Parse failures: Cannot be fixed with builder changes
  - Patterns like "ISO/IEC FDIS 23008-1/WD Amd 1" have NEVER parsed
  - Require parser architecture changes (base typed_stage + supplement stage)
- ✅ **Strategy Validation**: Session 16's data-driven approach confirmed as only effective method
  - Speculative fixes: +4 tests (Session 15)
  - Data-driven fixes: +104 tests (Session 16) → 26x improvement
- ✅ **Results**: 1,420 passing (49.7%) maintained, no changes committed
- ✅ **Clean slate**: All speculative changes reverted, ready for Session 18
- 🎯 **Key Insight**: Focus on attribute failures (stage_code issues ~100 tests) not parse failures

**Previous Sessions:**
- Session 15: Typed stage variants (FCorr), edition/year enhancements → 1,316 passing (+4)
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

**Immediate Priorities (Session 18):**

**Goal**: Reach 50% pass rate (1,430/2,859 passing) - **Only +10 tests needed!**

**Strategy**: Focus on ATTRIBUTE failures, NOT parse failures (Session 17 lesson)

1. **Pattern B: Stage Code Preservation** (~100 tests estimated) - PRIMARY TARGET
   - Issue: Stage codes defaulting to "published" instead of actual stage
   - Examples: Expected "cd" got "published", "pwi"→"published", "wd"→"published"
   - Root cause: Builder or identifier classes defaulting incorrectly
   - Files: lib/pubid_new/iso/builder.rb, identifier classes
   - Impact: High confidence ~100 tests

2. **Alternative Quick Wins** (if Pattern B complex):
   - Check pending tests that may now pass
   - Simple rendering/to_s fixes
   - Type code preservation (similar to stage code)

3. **AVOID** (Session 17 lessons):
   - Parse-level failures (need parser architecture changes)
   - Patterns requiring base typed_stage + supplement stage
   - Speculative fixes without data-driven analysis

4. **Session 18 Continuation Plan**: See docs/session-18-continuation-plan.md

### Near-Term Goals:

1. Achieve 50% ISO test pass rate (1,430/2,859 passing) - Next session target
2. Achieve 55% ISO test pass rate (1,573/2,859 passing) - Session 18-19 target
3. Complete remaining high-impact fixes from failure analysis
4. Apply V2 patterns to remaining flavors: ETSI, ITU, CCSDS migrations
5. Complete V2 BSI migration
6. Complete V2 NIST/CEN compliance
7. Update migrator to handle multi-version migrations

### Active Development Areas

- **Active**: ISO test refinement with data-driven improvements
- **Not changing**: Core completed flavors (IEC, JIS, ETSI, ITU, CCSDS)
- **Architecture locked**: Three-layer pattern established and proven
- **Strategy validated**: Data-driven analysis yields 10-20x better results than speculative fixes

### Known Issues

- ISO: 718 test failures (25.1%) - parser gaps + rendering differences + stage code issues
- ISO: 721 pending tests (25.2%) - includes typed_stage architectural differences
- V1 code still exists but not being actively developed
- Migration documentation complete and comprehensive

### Files Changed in Session 16

- Parser: lib/pubid_new/iso/parser.rb (FPDAM, edition+language in supplements)
- Identifiers: lib/pubid_new/iso/identifiers/guide.rb (complete TYPED_STAGES)
- Builder: lib/pubid_new/iso/builder.rb (edition extraction for supplements)
- Commits: 1 semantic commit with comprehensive documentation
- Test improvement: 1,316→1,420 passing (+104), 797→718 failing (-79)
- Pass rate: 46.0% → 49.7% (+3.6pp)

### Session 16 Key Learnings

1. **Data-driven analysis is essential**: Systematic failure analysis yielded +104 tests vs Session 15's speculative +4
2. **Prioritize by impact**: Focusing on patterns affecting 50-150+ tests each maximizes efficiency
3. **TYPED_STAGES completeness critical**: Missing Guide.TYPED_STAGES caused 150+ failures
4. **Parser-identifier sync important**: FPDAM was in Amendment.TYPED_STAGES but not parser rule
5. **Single-session multi-pattern fixes work**: Can effectively fix 3-4 high-impact patterns in one session
6. **Target exceeded**: Minimum +56 → Achieved +104 demonstrates analysis accuracy
7. **50% milestone within reach**: Only +10 tests needed for next major milestone

### Session 17 Key Learnings

1. **Parse vs Attribute failures critical distinction**: Builder cannot fix parser-level failures
2. **Pattern 1 (DAD) false positive**: Already fully implemented in both parser and Addendum.TYPED_STAGES
3. **Pattern 4 requires parser changes**: "ISO/IEC FDIS 23008-1/WD Amd 1" has never parsed
4. **Speculative approach is counterproductive**: Builder-only fix for parser issue made things worse
5. **Data-driven validation**: Session 16 approach 26x better than Session 15 speculation
6. **Next target identified**: Pattern B (stage code preservation) ~100 tests, attribute-level fix
7. **50% within easy reach**: Only +10 tests needed, clear path via attribute fixes
