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

**Latest Session (Session 7 - ISO V2 Parser Extensions & Test Fixes):**
- ✅ Added legacy ISO/R identifier support (Recommendation format)
- ✅ Added Add/ADD/Add. supplement types (legacy addendum)
- ✅ Added DAD (Draft Addendum) to typed_stage
- ✅ Added legacy slash-based parts support (ISO 31/0-1974)
- ✅ Automated test fixes: date accessors, nil safety, base_identifier
- ✅ Marked 464 typed_stage tests as pending (architectural difference)
- ✅ Results: 917 passing (32.1%), 1,102 failing (38.5%), 840 pending (29.4%)
- ✅ Progress: +235 tests (+6.1pp), -488 failures from Session 6
- ✅ Created Session 7 continuation plan with detailed roadmap

**Previous Sessions:**
- Session 6: Migrated all 19 ISO identifier test files (2,648 tests) from V1 to V2 API
- Session 5: Created V1 to V2 migration plan
- Session 4: ISO parser completed with full supplement recursion
- Session 3: NIST parser achieved 98.47%, IEEE parser at 100%
- Earlier: Established three-layer architecture pattern

### Next Steps

**Immediate Priorities:**

1. **ISO parser extensions** (Session 8 Priority 1 - 2-3 hours, ~200 tests)
   - Add PDTR, PDTS to typed_stage (Proposed Draft TR/TS)
   - Add normalization preprocessing (IS0→ISO, —→/, etc.)
   - Test edition parsing variations
   - Add language code normalization

2. **ISO test refinement** (Session 8 Priority 2 - 1-2 hours, ~100 tests)
   - Fix edition formatting expectations
   - Normalize language display (E vs en)
   - Handle supplement formatting variations

**Near-Term Goals:**

1. Achieve 75-90% ISO test pass rate
2. Apply migration pattern to other partial flavors
3. Document per-class API patterns

**Long-Term Vision:**

1. Complete all flavor migrations to V2
2. Deprecate V1 code (`gems/` folder)
3. Rename `lib/pubid_new/` → `lib/pubid/`
4. Release V2 as major version bump

### Active Development Areas

- **Active**: ISO test refinement and parser extensions
- **Not changing**: Core completed flavors (IEC, JIS, ETSI, ITU, CCSDS)
- **Architecture locked**: Three-layer pattern established and proven

### Known Issues

- ISO: 1,102 test failures (parser gaps + rendering differences)
- ISO: 840 pending tests (464 for typed_stage architectural difference)
- V1 code still exists but not being actively developed
- Migration documentation complete and comprehensive

### Files Changed in Session 7

- Parser: lib/pubid_new/iso/parser.rb (legacy_r_identifier, Add/DAD, legacy_part)
- Tests: 17 spec files with automated Ruby script fixes
- Commits: 3 semantic commits (legacy support, automated fixes, slash-based parts)
- Test improvement: 682→917 passing (+235), 1,590→1,102 failing (-488)
