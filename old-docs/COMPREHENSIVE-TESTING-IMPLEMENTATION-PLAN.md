# PubID v2 Comprehensive Testing Implementation Plan

## Current Status

**Date:** 2025-11-17  
**Branch:** rt-new-lutaml-model  
**PR:** #19

### Completed Work

✅ Test infrastructure fully operational:
- [`spec/spec_helper.rb`](../spec/spec_helper.rb:1) - v2 module loading
- [`spec/support/fixture_loader.rb`](../spec/support/fixture_loader.rb:1) - Fixture loading with result tracking
- [`spec/integration/ccsds_spec.rb`](../spec/integration/ccsds_spec.rb:1) - CCSDS tests (490 cases, 100%)
- [`spec/integration/itu_spec.rb`](../spec/integration/itu_spec.rb:1) - ITU tests (2,041 cases, 100%)

### Test Results So Far

| Flavor | Cases | Pass Rate | Status |
|--------|-------|-----------|--------|
| CCSDS  | 490   | 100.0%    | ✅ Complete |
| ITU    | 2,041 | 100.0%    | ✅ Complete |

**Progress:** 2,531 / 90,264 total cases (2.8%) - 100% pass rate

---

## Fixture File Inventory

All fixture files have been verified and are available:

### JIS (10,635 cases total)
```
gems/pubid-jis/spec/fixtures/
└── jis-pubids.txt (10,635 lines)
```

### IEEE (10,332 cases total)
```
gems/pubid-ieee/spec/fixtures/
├── pubid-to-parse.txt      (primary test file)
├── pubid-parsed.txt
├── unapproved.txt
└── grouped.md
```

### ISO (7,689 cases total - 13 fixture files)
```
gems/pubid-iso/spec/fixtures/
├── iso-pubid-basic.txt
├── iso-pubid-cd.txt
├── iso-pubid-coramd.txt
├── iso-pubid-directives.txt
├── iso-pubid-draft-amd-cor.txt
├── iso-pubid-french.txt
├── iso-pubid-languages.txt
├── iso-pubid-legacy-tr-ts.txt
├── iso-pubid-nsb.txt
├── iso-pubid-russian.txt
├── iso-pubid-supplement-iteration.txt
├── iwa-pubid.txt
└── non-iso-identifiers.txt
```

### IEC (13,889 cases total - 14 fixture files)
```
gems/pubid-iec/spec/fixtures/
├── csv-pubid.txt
├── iec-pubid.txt
├── iecee-trf-pubid.txt
├── iecex-trf-pubid.txt
├── iecq-pubid.txt
├── ish-pubid.txt
├── iso-iec-pubid.txt
├── sheets-pubid.txt
├── tc1-pubid.txt
├── tr-pubid.txt
├── ts-pubid.txt
├── vap-pubid.txt
├── wd-special-groups.txt
├── working-documents.txt
└── working-programmes.txt
```

### NIST (20,349 cases total - 3 fixture files)
```
gems/pubid-nist/spec/fixtures/
├── allrecords.txt
├── pubs-export.txt
└── sept2024-update.txt
```

### ETSI (24,718 cases total)
```
gems/pubid-etsi/spec/fixtures/
└── pubids.txt (24,718 lines)
```

---

## Implementation Plan

### Phase 1: Create Test Specifications (Est. 1-2 hours)

Create RSpec test files following the established pattern from [`ccsds_spec.rb`](../spec/integration/ccsds_spec.rb:1) and [`itu_spec.rb`](../spec/integration/itu_spec.rb:1).

#### Task 1.1: Create JIS Test Spec
**File:** `spec/integration/jis_spec.rb`  
**Fixtures:** 1 file (10,635 cases)  
**Pattern:**

```ruby
RSpec.describe "JIS v2 Implementation" do
  include FixtureLoader
  let(:results) { FixtureLoader::TestResults.new }

  describe "comprehensive fixture tests" do
    context "JIS publications" do
      let(:test_cases) { load_gem_fixture(:jis, "jis-pubids.txt") }
      
      it "parses and renders all JIS publications correctly" do
        # Test implementation
        expect(summary[:pass_rate]).to be >= 95.0
      end
    end
  end
end
```

#### Task 1.2: Create IEEE Test Spec
**File:** `spec/integration/ieee_spec.rb`  
**Fixtures:** 1 primary file (10,332 cases)  
**Notes:** Use `pubid-to-parse.txt` as primary test file

#### Task 1.3: Create ISO Test Spec
**File:** `spec/integration/iso_spec.rb`  
**Fixtures:** 13 files (7,689 total cases)  
**Pattern:** Multiple contexts, one per fixture file:

```ruby
RSpec.describe "ISO v2 Implementation" do
  describe "comprehensive fixture tests" do
    context "basic ISO identifiers" do
      let(:test_cases) { load_gem_fixture(:iso, "iso-pubid-basic.txt") }
      # ...
    end
    
    context "committee draft identifiers" do
      let(:test_cases) { load_gem_fixture(:iso, "iso-pubid-cd.txt") }
      # ...
    end
    
    # ... 11 more contexts for remaining fixtures
  end
end
```

#### Task 1.4: Create IEC Test Spec
**File:** `spec/integration/iec_spec.rb`  
**Fixtures:** 14 files (13,889 total cases)  
**Pattern:** Multiple contexts, organized by document type:

```ruby
RSpec.describe "IEC v2 Implementation" do
  describe "comprehensive fixture tests" do
    # Context for each fixture file:
    # - IEC publications
    # - ISO/IEC joint publications  
    # - Test report forms (TRF)
    # - Working documents
    # - Technical specifications
    # - Technical reports
    # etc.
  end
end
```

#### Task 1.5: Create NIST Test Spec
**File:** `spec/integration/nist_spec.rb`  
**Fixtures:** 3 files (20,349 total cases)  
**Pattern:** Three contexts:

```ruby
RSpec.describe "NIST v2 Implementation" do
  describe "comprehensive fixture tests" do
    context "all records" do
      let(:test_cases) { load_gem_fixture(:nist, "allrecords.txt") }
      # ...
    end
    
    context "publication exports" do
      let(:test_cases) { load_gem_fixture(:nist, "pubs-export.txt") }
      # ...
    end
    
    context "September 2024 updates" do
      let(:test_cases) { load_gem_fixture(:nist, "sept2024-update.txt") }
      # ...
    end
  end
end
```

#### Task 1.6: Create ETSI Test Spec
**File:** `spec/integration/etsi_spec.rb`  
**Fixtures:** 1 file (24,718 cases - LARGEST SET)  
**Pattern:** Single context with all ETSI identifiers

---

### Phase 2: Execute Comprehensive Tests (Est. 2-3 hours)

Run all tests sequentially to collect results.

#### Execution Strategy

1. **Run individual specs first** to verify each works correctly:
   ```bash
   bundle exec rspec spec/integration/jis_spec.rb --format documentation
   bundle exec rspec spec/integration/ieee_spec.rb --format documentation
   # ... etc for each spec
   ```

2. **Run full suite** to get overall results:
   ```bash
   time bundle exec rspec spec/integration/ --format documentation > test_results.txt 2>&1
   ```

3. **Collect results** for each flavor:
   - Total cases tested
   - Pass count  
   - Fail count
   - Pass rate %
   - First 20 failures for analysis

#### Expected Execution Times

Based on current performance:
- JIS (10,635): ~3-5 seconds
- IEEE (10,332): ~3-5 seconds
- ISO (7,689): ~2-3 seconds
- IEC (13,889): ~4-6 seconds
- NIST (20,349): ~8-12 seconds
- ETSI (24,718): ~10-15 seconds

**Total estimated runtime:** 2-3 minutes for 90,264 test cases

---

### Phase 3: Results Analysis & Reporting (Est. 1-2 hours)

#### Task 3.1: Generate Per-Flavor Reports

Create individual markdown reports for each flavor:

**Template:** `docs/test-reports/FLAVOR-TEST-RESULTS.md`

```markdown
# {FLAVOR} v2 Test Results

## Summary

- Total Cases: {total}
- Passed: {passed}
- Failed: {failed}
- Pass Rate: {pass_rate}%

## Sample Cases Tested

{show first 10-20 test cases}

## Failure Analysis

### Top Failure Patterns

{categorize failures by type}

### Sample Failures

{show representative failures with expected vs actual}

## Recommendations

{actionable items for failures}
```

#### Task 3.2: Create Comprehensive Migration Report

**File:** `docs/COMPREHENSIVE-TEST-RESULTS-2025-11-17.md`

Content:
- Executive summary
- Overall statistics table
- Per-flavor breakdown
- Failure pattern analysis
- Migration compatibility assessment
- Recommendations for v2 adoption

#### Task 3.3: Failure Pattern Analysis

Categorize all failures into:

1. **Parsing failures** - Input not recognized
2. **Rendering mismatches** - Parse succeeds but render differs
3. **Edge cases** - Unusual or boundary condition identifiers
4. **Deprecations** - V1 formats no longer supported in v2
5. **Improvements** - Intentional v2 changes that improve output

Document each category with:
- Count of occurrences
- Representative examples
- Root cause analysis
- Recommended actions

---

### Phase 4: CI/CD Setup (Est. 30-60 minutes)

#### Task 4.1: Create .rspec Configuration

**File:** `.rspec`

```
--require spec_helper
--format documentation
--color
--order random
```

#### Task 4.2: Create GitHub Actions Workflow

**File:** `.github/workflows/comprehensive-tests.yml`

```yaml
name: Comprehensive Integration Tests

on:
  push:
    branches: [ rt-new-lutaml-model ]
  pull_request:
    branches: [ rt-new-lutaml-model ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
          bundler-cache: true
      
      - name: Run comprehensive tests
        run: bundle exec rspec spec/integration/
      
      - name: Generate test report
        if: always()
        run: |
          echo "## Test Results" >> $GITHUB_STEP_SUMMARY
          # Add summary output
```

#### Task 4.3: Documentation

**File:** `docs/TEST-EXECUTION-GUIDE.md`

Content:
- How to run tests locally
- How to interpret results  
- How to add new test fixtures
- CI/CD integration details
- Troubleshooting common issues

---

## Success Criteria

### Primary Goals

1. ✅ **≥95% pass rate** for each flavor
2. ✅ All 90,264 test cases executed
3. ✅ Comprehensive reports generated
4. ✅ All failures documented and categorized
5. ✅ CI/CD pipeline operational

### Documentation Deliverables

1. Per-flavor test result reports (6 files)
2. Comprehensive migration report (1 file)
3. Test execution guide (1 file)
4. Failure analysis document (1 file)
5. CI/CD workflow configuration (1 file)

### Quality Gates

- No regressions from CCSDS/ITU (maintain 100%)
- Clear categorization of all failures
- Actionable recommendations for each failure type
- Repeatable test execution via CI/CD

---

## Risk Assessment

### Known Risks

1. **Large fixture files** - ETSI (24,718 cases) may take longer than estimated
   - Mitigation: Can split into multiple contexts if needed

2. **Parser/renderer changes** - Some v1 formats may not be supported in v2
   - Mitigation: Document as intentional incompatibilities

3. **Fixture data quality** - Some v1 fixtures may contain invalid test cases
   - Mitigation: Filter and document problematic cases

### Contingency Plans

- If pass rate < 95%: Analyze top failure patterns and create targeted fixes
- If execution time > 5 minutes: Optimize test framework or use parallel execution
- If CI fails: Debug locally first, then update workflow

---

## Next Steps for Code Mode

When switching to Code mode for implementation:

1. **Start with Task 1.1** - Create JIS test spec
2. **Follow the pattern** from existing CCSDS/ITU specs exactly
3. **Test incrementally** - Run each spec as it's created
4. **Document issues** - Note any unexpected failures immediately
5. **Request clarification** if fixture structure differs from expectations

The test pattern is proven and working. The main task is replicating the pattern across the remaining 6 flavors, being careful with multi-fixture flavors (ISO, IEC, NIST).

---

## Timeline Estimate

| Phase | Tasks | Est. Time |
|-------|-------|-----------|
| Phase 1: Create specs | 6 test files | 1-2 hours |
| Phase 2: Execute tests | Run & collect | 2-3 hours |
| Phase 3: Analysis | Reports & docs | 1-2 hours |
| Phase 4: CI/CD setup | Config & docs | 0.5-1 hour |
| **Total** | | **4.5-8 hours** |

---

## References

- [Continuation Prompt](CONTINUATION-PROMPT-COMPREHENSIVE-TESTING.md:1)
- [Fixture Inventory](FIXTURE-INVENTORY-2025-11-16.md:1)
- [Test Migration Progress](TEST-MIGRATION-PROGRESS-2025-11-16.md:1)
- [Existing CCSDS Spec](../spec/integration/ccsds_spec.rb:1)
- [Existing ITU Spec](../spec/integration/itu_spec.rb:1)
- [FixtureLoader Utility](../spec/support/fixture_loader.rb:1)