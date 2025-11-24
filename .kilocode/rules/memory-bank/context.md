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

**Latest Session (Session 11 - ISO V2 Stage Parsing & Component Fixes):**
- ✅ Fixed missing stage parsing: Added DIS, FDIS, FCD, preCD/PreCD/PRECD to stage rule
- ✅ Added UNDP to copublisher list for ISO/UNDP identifiers
- ✅ Implemented stage iteration parsing and rendering (CD2 → "ISO/CD 14065.2:2018")
- ✅ Fixed space before copublisher normalization ("ISO /IEC" → "ISO/IEC")
- ✅ Fixed Stage component API: Changed from .value to .abbr throughout codebase
- ✅ Improved sub-subpart extraction: Multi-level parts now join correctly (5-1-1 → part=5, subpart=1-1)
- ✅ Results: 1,059 passing (37.0%), 987 failing (34.5%), 813 pending (28.4%)
- ✅ Progress: +29 tests (+1.0pp), -29 failures from Session 10
- ✅ Three focused commits: stage parsing (+23), stage iteration (+1), subpart extraction (+5)

**Previous Sessions:**
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

**Immediate Priorities (Session 12):**

1. **Remaining parse failures** (~700 tests estimated)
   - Continue systematic failure analysis
   - Focus on high-frequency patterns
   - Target 40% pass rate (1,144 passing)

2. **Edition API inconsistencies** (identified but not yet fixed)
   - Tests expect `.value` but Edition has `.number`
   - Should be straightforward fix

3. **Legacy date rendering** (1 test identified)
   - "ISO 31/0-1974" should render with colon not dash before year

4. **Rendering differences** (~200 tests estimated)
   - Type/stage combinations
   - Continue pattern-based fixes

**Near-Term Goals:**

1. Achieve 40% ISO test pass rate (1,144/2,859 passing) - Target for Session 12
2. Achieve 45% ISO test pass rate (1,287/2,859 passing) - Next milestone
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

- ISO: 987 test failures (34.5%) - parser gaps + rendering differences
- ISO: 813 pending tests (28.4%) - includes typed_stage architectural differences
- Edition API: Tests expect .value but component uses .number
- Legacy date rendering: Slash-based parts need colon before year
- V1 code still exists but not being actively developed
- Migration documentation complete and comprehensive

### Files Changed in Session 11

- Parser: lib/pubid_new/iso/parser.rb (added stages, UNDP, stage_iteration_prefix, space normalization)
- Builder: lib/pubid_new/iso/builder.rb (Stage.abbr, stage iteration handling, subpart joining, removed invalid require)
- Base: lib/pubid_new/iso/identifiers/base.rb (stage.abbr for rendering)
- Commits: 3 semantic commits (stage parsing, stage iteration, subpart extraction)
- Test improvement: 1,030→1,059 passing (+29), 1,016→987 failing (-29)
- Pass rate: 36.0% → 37.0% (+1.0pp)

### Session 11 Key Achievements

1. **Highest-impact fix**: Stage parsing affected ~23 tests (DIS, FDIS, FCD, preCD, PWI, NP, AWI, WD, CD, PRF)
2. **Architecture fix**: Corrected Stage component API from .value to .abbr
3. **UNDP copublisher**: Enabled ISO/UNDP identifier parsing
4. **Stage iterations**: CD2, PreCD3 now parse and render correctly
5. **Sub-subpart support**: Multi-level parts like 5-1-1 now extract correctly
6. **Clean commits**: Three well-documented semantic commits tracking specific fixes
7. **Steady progress**: +1.0pp improvement maintaining momentum from Session 10
