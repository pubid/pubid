# PubID V2 ISO - Session 6 Continuation Prompt

**Date:** 2025-11-23
**Previous Session:** Session 5 (V1 to V2 Migration Planning)
**This Session:** Session 6 - V1 to V2 Migration Execution
**Status:** Migration plan complete, ready for execution

---

## Quick Context

Session 5 assessed the V2 status and discovered that while the core V2 parser is production-ready (166 tests passing), the identifier tests (2,859 examples) are using V1 API and failing. A comprehensive migration plan was created to systematically transition from V1 to V2 architecture.

---

## Commands to Resume

```bash
# Navigate to project
cd /Users/mulgogi/src/mn/pubid

# Verify core tests still passing (should be 166, 0 failures)
bundle exec rspec spec/pubid_new/iso/identifier_spec.rb \
  spec/pubid_new/iso/parser_spec.rb \
  spec/pubid_new/iso/builder_spec.rb \
  spec/pubid_new/iso/components/ \
  spec/pubid_new/iso/performance_spec.rb --format progress

# Review migration plan
cat V1_TO_V2_MIGRATION_PLAN.md

# Check current identifier test status
bundle exec rspec spec/pubid_new/iso/identifiers/ --format progress 2>&1 | tail -10
```

---

## Session 5 Accomplishments

### ✅ Assessment Complete

**Core V2 Status:**
- 166 tests passing (integration, parser, builder, components, performance)
- Production-ready parser with 0.2-0.7ms performance
- Clean OOP architecture validated

**Identifier Tests Status:**
- 2,859 tests in `spec/pubid_new/iso/identifiers/` (19 files)
- 2,321 failures due to V1 API usage
- Tests need systematic API migration

**V1 vs V2 Structure:**
- V1: `gems/pubid-{flavor}/spec/` (deprecated, still exists)
- V2: `spec/pubid_new/{flavor}/` (active)
- Fixtures already migrated to `spec/fixtures/{flavor}/`

### ✅ Migration Plan Created

**Document:** [`V1_TO_V2_MIGRATION_PLAN.md`](V1_TO_V2_MIGRATION_PLAN.md)

**5 Phases Defined:**

1. **Archive V1 Code** (1 hour)
   - Move V1 specs to `old_specs/pubid/{flavor}/v1_specs/`
   - Preserve as reference without interference

2. **Document API Mapping** (30 min)
   - Create `docs/V1_TO_V2_API_MAPPING.md`
   - Define all V1 → V2 API translations

3. **Migrate ISO Tests** (4-6 hours)
   - 19 identifier test files
   - Replace V1 API calls with V2 equivalents
   - Mark unsupported patterns as `pending`

4. **Consolidate Fixtures** (1 hour)
   - Merge any missing V1 fixtures

5. **Verify & Document** (1 hour)
   - Run full test suite
   - Document results and gaps

**Timeline:** 7.5-9.5 hours for ISO, 4-8 hours per additional flavor

### ✅ API Mapping Documented

**Key V1 → V2 Changes:**

| V1 API | V2 API | Notes |
|--------|--------|-------|
| `ClassName.parse(str)` | `PubidNew::Iso.parse(str)` | Use scheme |
| `publisher.body` | `publisher.publisher` | Renamed |
| `copublishers.first.body` | `publisher.copublisher.first` | Nested |
| `type.type_code` | `typed_stage.type_code` | Moved |
| `stage.stage_code` | `typed_stage.stage_code` | Moved |
| `typed_stage.abbreviation` | `typed_stage.abbr.first` | Now array |

---

## Session 6 Objectives

**Total Estimated Time:** 8-12 hours

### Phase 1: Archive V1 Code (1 hour) 🟢 HIGH PRIORITY

**Objective:** Clean separation of V1 and V2 code

**Tasks:**
1. Create archive directory structure:
   ```bash
   mkdir -p old_specs/pubid/{iso,iec,nist,ieee,itu,jis,etsi,bsi,cen,ccsds}
   mkdir -p old_specs/pubid/iso/v2_before_migration
   ```

2. Move V1 specs:
   ```bash
   mv gems/pubid-iso/spec old_specs/pubid/iso/v1_specs
   # Repeat for other flavors as needed
   ```

3. Verify V2 tests unaffected:
   ```bash
   bundle exec rspec spec/pubid_new/iso/identifier_spec.rb \
     spec/pubid_new/iso/parser_spec.rb \
     spec/pubid_new/iso/builder_spec.rb \
     --format progress
   ```

**Success Criteria:**
- V1 specs archived
- Core 166 tests still passing
- Clear file organization

### Phase 2: Create API Mapping Doc (30 min) 🟢 HIGH PRIORITY

**Objective:** Reference guide for migration

**Tasks:**
1. Create `docs/V1_TO_V2_API_MAPPING.md`
2. Document all API translations with examples
3. Include migration patterns

**File Location:** `docs/V1_TO_V2_API_MAPPING.md`

**Template:**
```markdown
# V1 to V2 API Mapping

## Parse Method
**V1:** `ClassName.parse(string)`
**V2:** `PubidNew::Iso.parse(string)`

## Publisher Access
**V1:** `identifier.publisher.body`
**V2:** `identifier.publisher.publisher`

[etc.]
```

### Phase 3: Migrate ISO Identifier Tests (4-6 hours) 🟡 CORE WORK

**Objective:** Update 19 test files to V2 API

**Files in `spec/pubid_new/iso/identifiers/`:**
1. addendum_spec.rb
2. amendment_spec.rb (LARGEST - hundreds of tests)
3. corrigendum_spec.rb
4. data_spec.rb
5. directives_spec.rb
6. directives_supplement_spec.rb
7. extract_spec.rb
8. guide_spec.rb
9. international_standard_spec.rb
10. international_standardized_profile_spec.rb
11. international_workshop_agreement_spec.rb
12. pas_spec.rb
13. recommendation_spec.rb
14. supplement_spec.rb
15. tc_document_spec.rb
16. tc_spec.rb
17. technical_report_spec.rb
18. technical_specification_spec.rb
19. technology_trends_assessment_spec.rb

**Priority Order:**

**A. Start with smallest files (1-2 hours):**
- data_spec.rb (~50 tests)
- extract_spec.rb (~30 tests)
- tc_spec.rb (~40 tests)

**B. Then medium files (1-2 hours):**
- guide_spec.rb (~200 tests)
- technical_report_spec.rb (~150 tests)
- technical_specification_spec.rb (~150 tests)

**C. Finally large files (2-3 hours):**
- amendment_spec.rb (~800 tests) 
- corrigendum_spec.rb (~600 tests)
- international_standard_spec.rb (~400 tests)

**Per-File Process:**

1. **Backup:**
   ```bash
   cp spec/pubid_new/iso/identifiers/data_spec.rb \
      old_specs/pubid/iso/v2_before_migration/
   ```

2. **Update API calls** (use search/replace):
   ```ruby
   # Parse
   s/described_class\.parse/PubidNew::Iso.parse/g
   
   # Publisher
   s/\.publisher\.body/.publisher.publisher/g
   s/\.copublishers\.first\.body/.publisher.copublisher.first/g
   
   # Type/Stage
   s/\.type\.type_code/.typed_stage.type_code/g
   s/\.stage\.stage_code/.typed_stage.stage_code/g
   s/\.typed_stage\.abbreviation/.typed_stage.abbr.first/g
   ```

3. **Run tests:**
   ```bash
   bundle exec rspec spec/pubid_new/iso/identifiers/data_spec.rb
   ```

4. **Handle failures:**
   - **API errors** → Fix remaining API mappings
   - **Parser errors** → Mark as `pending` if unsupported:
     ```ruby
     xit "parses unsupported pattern" do
       # TODO: Parser doesn't support this yet
       # See docs/PARSER_GAPS.md #ISO-123
     end
     ```
   - **Logic errors** → Investigate and fix

5. **Verify core tests still pass:**
   ```bash
   bundle exec rspec spec/pubid_new/iso/identifier_spec.rb --format progress
   ```

6. **Document patterns in PARSER_GAPS.md**

**Success Criteria Per File:**
- No V1 API calls remain
- Supported patterns pass
- Unsupported patterns marked `pending` with explanation
- Core tests still passing

### Phase 4: Consolidate Fixtures (1 hour) 🔵 LOW PRIORITY

**Objective:** Ensure all fixtures accessible

**Tasks:**
1. Compare V1 vs V2 fixtures:
   ```bash
   ls old_specs/pubid/iso/v1_specs/fixtures/
   ls spec/fixtures/iso/
   ```

2. Copy missing fixtures:
   ```bash
   for file in old_specs/pubid/iso/v1_specs/fixtures/*.txt; do
     basename=$(basename $file)
     [ ! -f spec/fixtures/iso/$basename ] && cp $file spec/fixtures/iso/
   done
   ```

3. Update test references if needed

**Success Criteria:**
- All V1 fixtures preserved in V2 location
- Tests reference correct paths

### Phase 5: Verify & Document (1 hour) 🟢 HIGH PRIORITY

**Objective:** Validate migration completeness

**Tasks:**

1. **Run full ISO test suite:**
   ```bash
   bundle exec rspec spec/pubid_new/iso/ --format documentation \
     | tee migration_results.txt
   ```

2. **Analyze results:**
   - Count passing tests
   - Count pending tests (with reasons)
   - Count failures (categorize by cause)

3. **Create documentation:**
   
   **A. Update IMPLEMENTATION_STATUS.md:**
   ```markdown
   ## ISO Test Status (After V1→V2 Migration)
   
   **Core Tests:** 166 passing ✅
   
   **Identifier Tests:**
   - Total: 2,859 tests
   - Passing: X tests
   - Pending: Y tests (parser gaps)
   - Failures: Z tests (need investigation)
   
   **Migration Status:** Phase 3 complete
   ```
   
   **B. Create docs/PARSER_GAPS.md:**
   ```markdown
   # Known Parser Gaps
   
   ## ISO
   
   ### Gap: Edition in Certain Positions
   **Pattern:** `ISO 8601-1:2019/Amd 1:2023 ED1(en)`
   **Status:** Unsupported
   **Tests affected:** 12 tests
   **Priority:** Medium
   **Notes:** V1 supported this, need to extend parser
   
   [Additional gaps...]
   ```
   
   **C. Create docs/V1_TO_V2_MIGRATION_GUIDE.md:**
   - Summary of migration approach
   - API mapping reference
   - Common issues and solutions
   - Guide for other contributors

4. **Commit work:**
   ```bash
   git add -A
   git commit -m "feat(iso): Complete V1 to V2 test migration
   
   - Archived V1 specs to old_specs/
   - Migrated 19 identifier test files to V2 API
   - Documented parser gaps
   - Created migration guide
   
   Test status:
   - Core: 166 passing
   - Identifiers: X passing, Y pending, Z failures"
   ```

**Success Criteria:**
- Full test results documented
- Parser gaps cataloged
- Migration guide created
- Work committed to git

---

## Architecture Principles (CRITICAL)

**These MUST be maintained during migration:**

### 1. Object-Oriented Design
- NO parent class modifications
- Extend only, never modify
- Proper encapsulation
- Single responsibility

### 2. MECE Organization
- Each class handles mutually exclusive patterns
- No pattern overlap
- Collectively exhaustive

### 3. Component Usage
- Use [`Type.abbr`](lib/pubid_new/iso/components/type.rb:8) not `Type.value`
- Use [`Language.original_code`](lib/pubid_new/iso/components/language.rb:10) not `Language.value`  
- Use [`Publisher.to_s`](lib/pubid_new/iso/components/publisher.rb:25) not `Publisher.body`
- **Always check nil** before accessing

### 4. Testing Rules
- NEVER lower test thresholds
- NEVER skip tests without justification
- Test behavior, not implementation
- Run full suite after each file

---

## Key Files Reference

### Migration Plan
- [`V1_TO_V2_MIGRATION_PLAN.md`](V1_TO_V2_MIGRATION_PLAN.md) - Master plan

### Implementation (DO NOT MODIFY)
- [`lib/pubid_new/iso/parser.rb`](lib/pubid_new/iso/parser.rb) - Grammar
- [`lib/pubid_new/iso/builder.rb`](lib/pubid_new/iso/builder.rb) - Construction
- [`lib/pubid_new/iso/identifiers/*.rb`](lib/pubid_new/iso/identifiers/) - 16 classes

### Tests (TO BE MIGRATED)
- `spec/pubid_new/iso/identifiers/*.rb` - 19 files, 2,859 tests

### Documentation (TO BE CREATED)
- `docs/V1_TO_V2_API_MAPPING.md` - API translation guide
- `docs/PARSER_GAPS.md` - Unsupported patterns
- `docs/V1_TO_V2_MIGRATION_GUIDE.md` - Contributor guide

---

## Common Commands

### Testing
```bash
# Single file
bundle exec rspec spec/pubid_new/iso/identifiers/data_spec.rb --format documentation

# All identifiers
bundle exec rspec spec/pubid_new/iso/identifiers/ --format progress

# Core tests only
bundle exec rspec spec/pubid_new/iso/identifier_spec.rb \
  spec/pubid_new/iso/parser_spec.rb \
  spec/pubid_new/iso/builder_spec.rb

# Full suite
bundle exec rspec spec/pubid_new/iso/ --format documentation
```

### Search & Replace (in identifier tests)
```bash
# Parse method
sed -i '' 's/described_class\.parse/PubidNew::Iso.parse/g' \
  spec/pubid_new/iso/identifiers/data_spec.rb

# Publisher
sed -i '' 's/\.publisher\.body/.publisher.publisher/g' \
  spec/pubid_new/iso/identifiers/data_spec.rb

# Type/stage
sed -i '' 's/\.type\.type_code/.typed_stage.type_code/g' \
  spec/pubid_new/iso/identifiers/data_spec.rb
```

---

## Decision Framework

### If Time Limited (<4 hours)
**Focus:** Phase 1-2 + small files in Phase 3
- Archive V1 code
- Create API mapping doc
- Migrate 3-5 smallest files
- Document what remains

### If Normal Timeline (8-12 hours)
**Focus:** Complete all phases for ISO
- Execute Phases 1-5 fully
- Migrate all 19 files
- Complete documentation

### If Extended Timeline (>12 hours)
**Focus:** ISO + start other flavors
- Complete ISO migration
- Apply to IEC or NIST
- Create reusable patterns

---

## Success Metrics

### Minimum Success (ISO)
- [ ] V1 code archived
- [ ] API mapping documented
- [ ] 50%+ identifier tests migrated
- [ ] Core 166 tests still passing

### Target Success (ISO)
- [ ] All 19 files migrated
- [ ] 80%+ tests passing/pending properly
- [ ] Parser gaps documented
- [ ] Migration guide created

### Ideal Success (ISO)
- [ ] 90%+ tests passing/pending
- [ ] Parser extensions identified
- [ ] Ready to apply to other flavors

---

## Next Session Preview (Session 7)

### If ISO Migration Complete
**Focus:** Apply to other flavors
- IEC migration
- NIST migration
- ITU migration

### If ISO Migration Incomplete  
**Focus:** Complete ISO
- Finish remaining files
- Resolve parser gaps
- Finalize documentation

---

## Important Notes

### Performance Context
- Core parser is production-ready (0.2-0.7ms)
- No performance work needed
- Focus is test migration only

### Testing Context
- 166 core tests provide solid foundation
- Identifier tests add comprehensive coverage
- Not all patterns may be supported yet

### Migration Context
- This is a **code migration**, not a rewrite
- Parser/builder remain unchanged
- Only test API calls being updated

---

**Status:** Ready to Execute Migration  
**Expected Duration:** 8-12 hours  
**Next Milestone:** ISO Migration Complete  

**Key Focus:** Systematically migrate identifier tests from V1 to V2 API while preserving test coverage and documenting gaps.

---

**Last Updated:** 2025-11-23  
**Sessions Completed:** 1-5 (Parser, Builder, Tests, Performance, Planning)  
**Current Status:** Migration Ready  
**Confidence Level:** High (plan validated, core tests passing)
