# Test Migration Plan: Old Fixtures → PubID v2 Specs

## Context

**Current State**: All 13 flavors have working v2 implementations, tested with sample identifiers.

**Next Phase**: Systematically migrate ALL test fixtures from old gems (`gems/pubid-*/spec/`) to v2 RSpec tests in `spec/`.

**Goal**: Ensure 100% compatibility between old and new implementations through comprehensive test coverage.

---

## Test Migration Inventory

### Flavors with Old Gem Fixtures

| Flavor | Old Fixtures Location | Estimated Test Count | Priority |
|--------|----------------------|---------------------|----------|
| IEC | gems/pubid-iec/spec/fixtures/*.txt | ~15 files, 1000+ cases | High |
| ISO | spec/fixtures/iso/*.txt | ~20 files, 7600+ cases | High |
| NIST | gems/pubid-nist/spec/fixtures/*.txt | ~3 files, 1000+ cases | High |
| BSI | gems/pubid-bsi/spec/ | fixtures + specs | Medium |
| ITU | gems/pubid-itu/spec/fixtures/*.txt | ~1 file, 100+ cases | Medium |
| JIS | gems/pubid-jis/spec/fixtures/*.txt | ~1 file, 50+ cases | Medium |
| CCSDS | gems/pubid-ccsds/spec/ | (check for fixtures) | Low |
| CEN | gems/pubid-cen/spec/ | (check for fixtures) | Low |
| ETSI | gems/pubid-etsi/spec/ | (check for fixtures) | Low |
| IEEE | (v2 only, no old gem) | N/A | N/A |
| ANSI | (v2 only, no old gem) | N/A | N/A |
| IDF | (v2 only, no old gem) | N/A | N/A |
| PLATEAU | (v2 only, no old gem) | N/A | N/A |

---

## Migration Strategy

### Phase 1: Inventory & Analysis (1 hour)

**Task 1.1**: Count fixtures for each flavor
```bash
for flavor in iec iso nist bsi itu jis ccsds cen etsi; do
  echo "=== $flavor ==="
  find gems/pubid-$flavor/spec -name "*.txt" -o -name "*_spec.rb" | wc -l
  echo
done
```

**Task 1.2**: Categorize by fixture type
- **.txt files**: Direct identifier lists (easy migration)
- **_spec.rb files**: RSpec tests with expectations (need adaptation)
- **convert_pubid.rb helpers**: Conversion testing (may need updates)

**Task 1.3**: Identify shared patterns
- Most old gems use `Pubid::FlavorName.parse()` → rename to `PubidNew::FlavorName.parse()`
- Fixture files can be reused as-is
- RSpec tests need module namespace updates

### Phase 2: Create Unified Test Structure (2 hours)

**Goal**: Consistent RSpec structure across all flavors

**Directory Structure**:
```
spec/
├── spec_helper.rb              (Load all v2 modules)
├── integration/
│   ├── iec_spec.rb             (Test with IEC fixtures)
│   ├── iso_spec.rb             (Test with ISO fixtures)
│   ├── nist_spec.rb            (Test with NIST fixtures)
│   ├── bsi_spec.rb
│   ├── itu_spec.rb
│   ├── jis_spec.rb
│   ├── ansi_spec.rb            (New flavor tests)
│   └── ...
└── fixtures/                    (Reuse or symlink from old gems)
    ├── iec/
    ├── iso/
    ├── nist/
    └── ...
```

**Template RSpec File**:
```ruby
# spec/integration/FLAVOR_spec.rb
require 'spec_helper'

RSpec.describe "PubidNew::FlavorName" do
  describe "fixture parsing" do
    Dir.glob("spec/fixtures/flavor/*.txt").each do |fixture_file|
      context "#{File.basename(fixture_file)}" do
        File.readlines(fixture_file).each_with_index do |line, idx|
          line = line.strip
          next if line.empty? || line.start_with?('#')
          
          it "parses and renders: #{line}" do
            identifier = PubidNew::FlavorName.parse(line)
            expect(identifier.to_s).to eq(line)
          end
        end
      end
    end
  end
end
```

### Phase 3: Migrate High-Priority Flavors (4-6 hours)

#### 3.1 IEC Migration (1.5 hours)

**Source**: [`gems/pubid-iec/spec/fixtures/`](gems/pubid-iec/spec/fixtures/)

**Fixtures** (~15 files):
- iec-pubid.txt
- iso-iec-pubid.txt
- tr-pubid.txt
- ts-pubid.txt
- wd-special-groups.txt
- etc.

**Test Count**: ~1,000+ identifiers

**Steps**:
1. Copy fixtures to `spec/fixtures/iec/`
2. Create `spec/integration/iec_spec.rb`
3. Run tests, fix any v2 incompatibilities
4. Document pass rate

**Expected Issues**:
- Working document formats may differ
- TRF (Test Report Form) formats
- URN rendering vs PubID rendering

#### 3.2 ISO Migration (2 hours)

**Source**: [`spec/fixtures/iso/`](spec/fixtures/iso/) (already in place)

**Fixtures** (~20 files):
- iso-international-standard.txt (~6,000 cases)
- iso-technical-report.txt
- iso-technical-specification.txt
- iso-amendment.txt
- iso-corrigendum.txt
- iso-guide.txt
- etc.

**Current Status**: Already tested via [`test_iso_v2.rb`](test_iso_v2.rb) - 98.47%

**Steps**:
1. Convert test_iso_v2.rb to proper RSpec format
2. Create `spec/integration/iso_spec.rb`
3. Exclude `non-iso-identifiers.txt` (contains CEN, IEC, JCGM)
4. Document the 117 edge cases

**Known Issues**:
- GUIDE format variations (5 cases)
- French Guide word order (5 cases)
- Directives bundling spacing (~90 cases)
- Various acceptable aberrations

#### 3.3 NIST Migration (1.5 hours)

**Source**: [`gems/pubid-nist/spec/fixtures/`](gems/pubid-nist/spec/fixtures/)

**Fixtures** (~3 files):
- allrecords.txt (~1,000 cases)
- pubs-export.txt
- sept2024-update.txt

**Current Status**: All edge cases fixed in subtask

**Steps**:
1. Copy fixtures to `spec/fixtures/nist/`
2. Create `spec/integration/nist_spec.rb`
3. Run comprehensive test
4. Verify 100% or document any issues

**Expected Result**: Should be 100% given all edge cases are fixed

#### 3.4 Other Flavors (2 hours total)

**BSI, ITU, JIS, CCSDS, CEN, ETSI**: ~30-60 minutes each

**Process** (per flavor):
1. List fixtures: `find gems/pubid-FLAVOR/spec -name "*.txt"`
2. Count cases: `wc -l gems/pubid-FLAVOR/spec/fixtures/*.txt`
3. Copy to `spec/fixtures/FLAVOR/`
4. Create `spec/integration/FLAVOR_spec.rb`
5. Run test, document results

---

## Detailed Steps

### Step 1: Create Master spec_helper.rb (15 min)

**File**: `spec/spec_helper.rb`

```ruby
require 'bundler/setup'
require_relative '../lib/pubid_new'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.warnings = true
  
  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  config.order = :random
  Kernel.srand config.seed
end
```

### Step 2: Create Fixture Test Template (15 min)

**File**: `spec/support/fixture_test_helper.rb`

```ruby
# Helper for testing fixtures
module FixtureTestHelper
  def self.test_fixtures(flavor_module, fixture_dir)
    Dir.glob("#{fixture_dir}/*.txt").sort.each do |fixture_file|
      context File.basename(fixture_file) do
        lines = File.readlines(fixture_file)
          .map(&:strip)
          .reject { |line| line.empty? || line.start_with?('#') }
        
        lines.each do |identifier_string|
          it "parses and renders: #{identifier_string}" do
            identifier = flavor_module.parse(identifier_string)
            expect(identifier.to_s).to eq(identifier_string)
          end
        end
      end
    end
  end
end
```

### Step 3: Create Individual Flavor Specs (repeat for each)

**Template**: `spec/integration/FLAVOR_spec.rb`

```ruby
require 'spec_helper'

RSpec.describe "PubidNew::FlavorName Integration Tests" do
  describe "fixture compatibility" do
    fixtures_dir = File.expand_path("../../fixtures/flavor", __FILE__)
    
    Dir.glob("#{fixtures_dir}/*.txt").sort.each do |fixture_file|
      context File.basename(fixture_file) do
        File.readlines(fixture_file).each_with_index do |line, idx|
          line = line.strip
          next if line.empty? || line.start_with?('#')
          
          it "line #{idx + 1}: #{line}" do
            identifier = PubidNew::FlavorName.parse(line)
            expect(identifier.to_s).to eq(line)
          end
        end
      end
    end
  end
end
```

### Step 4: Run Full Test Suite

```bash
# Run all integration tests
bundle exec rspec spec/integration/

# Run specific flavor
bundle exec rspec spec/integration/iso_spec.rb

# Run with verbose output
bundle exec rspec spec/integration/ --format documentation

# Generate HTML report
bundle exec rspec spec/integration/ --format html --out spec/report.html
```

---

## Expected Challenges & Solutions

### Challenge 1: Fixture Incompatibilities

**Issue**: Old fixtures may use formats not supported by v2

**Solution**:
1. Document incompatibilities
2. Either: Fix v2 parser to support
3. Or: Mark as "acceptable difference" with explanation

### Challenge 2: Rendering Differences

**Issue**: v2 might render differently than v1 (canonicalization)

**Solution**:
1. Check if difference is semantically equivalent
2. If yes: Document as "intentional normalization"
3. If no: Fix v2 renderer

**Example**:
```
Old: ISO 105/F
New: ISO 105-F
Status: Intentional normalization (slash→dash for parts)
```

### Challenge 3: Performance

**Issue**: 10,000+ test cases may be slow

**Solution**:
1. Use RSpec's `--tag` feature for selective testing
2. Run full suite in CI only
3. Sample testing during development

```ruby
# Tag by flavor
it "parses ISO identifier", :iso do
  # ...
end

# Run specific flavor
bundle exec rspec --tag iso
```

### Challenge 4: Missing Fixtures

**Issue**: Some flavors may not have old fixtures

**Solution**:
1. Create minimal test fixtures from scratch
2. Use real-world examples from documentation
3. Document as "new v2 coverage"

---

## Success Criteria

### Per-Flavor Metrics

**For each flavor, document**:
- Total test cases
- Pass count
- Fail count
- Pass rate %
- Known incompatibilities (with justification)

**Target**: ≥95% pass rate for each flavor

**Acceptable Exceptions**:
- Legacy formats no longer supported (documented)
- Intentional normalization differences (documented)
- Edge cases from aberrant data (documented)

### Overall Project Metrics

**Target**:
- 13/13 flavors with ≥95% compatibility
- All failures documented and justified
- Comprehensive RSpec test suite
- CI-ready test infrastructure

---

## Timeline Estimate

| Phase | Task | Time | Priority |
|-------|------|------|----------|
| 1 | Inventory & analysis | 1h | High |
| 2 | Test infrastructure setup | 2h | High |
| 3.1 | IEC migration | 1.5h | High |
| 3.2 | ISO migration | 2h | High |
| 3.3 | NIST migration | 1.5h | High |
| 3.4 | BSI migration | 0.5h | Medium |
| 3.5 | ITU migration | 0.5h | Medium |
| 3.6 | JIS migration | 0.5h | Medium |
| 3.7 | Others (CCSDS, CEN, ETSI) | 1h | Low |
| 4 | Documentation & reporting | 1h | High |
| **Total** | | **11-12 hours** | |

---

## Quick Start Commands

### Inventory Old Fixtures
```bash
# Count all fixture files
find gems/pubid-*/spec/fixtures -name "*.txt" -type f | wc -l

# Count total test cases  
find gems/pubid-*/spec/fixtures -name "*.txt" -type f -exec wc -l {} + | tail -1

# List by flavor
for flavor in iec iso nist bsi itu jis ccsds cen etsi; do
  echo "=== $flavor ==="
  find gems/pubid-$flavor/spec -name "*.txt" 2>/dev/null | while read f; do
    echo "  $(basename $f): $(wc -l < $f) cases"
  done
done
```

### Create Fixture Directories
```bash
mkdir -p spec/fixtures/{iec,iso,nist,bsi,itu,jis,ccsds,cen,etsi,ansi}
mkdir -p spec/integration
mkdir -p spec/support
```

### Copy Fixtures (Example: IEC)
```bash
cp gems/pubid-iec/spec/fixtures/*.txt spec/fixtures/iec/
```

### Run Specific Tests
```bash
# All integration tests
bundle exec rspec spec/integration/

# Specific flavor
bundle exec rspec spec/integration/iec_spec.rb

# With backtrace on failures
bundle exec rspec spec/integration/iec_spec.rb --backtrace

# Only failures
bundle exec rspec spec/integration/ --only-failures
```

---

## RSpec Structure Best Practices

### Organize by Fixture File
```ruby
RSpec.describe "PubidNew::Iec" do
  describe "iec-pubid.txt" do
    # Tests for that specific fixture
  end
  
  describe "iso-iec-pubid.txt" do
    # Tests for joint identifiers
  end
end
```

### Use Shared Examples
```ruby
# spec/support/shared_examples.rb
RSpec.shared_examples "parseable identifier" do |identifier_string|
  it "parses successfully" do
    expect { described_class.parse(identifier_string) }.not_to raise_error
  end
  
  it "round-trips correctly" do
    identifier = described_class.parse(identifier_string)
    expect(identifier.to_s).to eq(identifier_string)
  end
end

# Usage
RSpec.describe "PubidNew::Iso" do
  include_examples "parseable identifier", "ISO 8601:2019"
end
```

### Handle Expected Failures
```ruby
context "known incompatibilities" do
  it "normalizes slash to dash in legacy parts" do
    input = "ISO 105/F"
    output = "ISO 105-F"
    
    identifier = PubidNew::Iso.parse(input)
    expect(identifier.to_s).to eq(output)
  end
end
```

---

## Reporting Template

### Per-Flavor Report

**File**: `docs/test-reports/FLAVOR-migration-report.md`

```markdown
# FlavorName Test Migration Report

## Source
- Old gem: gems/pubid-flavor/
- Fixtures: X files, Y total test cases

## Results
- Total: Y cases
- Passed: X cases  
- Failed: Z cases
- Pass Rate: XX.X%

## Failures Analysis

### Category 1: Intentional Normalization (N cases)
- `input` → `output` (reason)

### Category 2: Unsupported Legacy Format (N cases)
- `input` → ERROR (justification)

### Category 3: Bugs (N cases)
- `input` → `incorrect output` (action needed)

## Recommendations
- [ ] Accept current pass rate as production-ready
- [ ] Fix identified bugs
- [ ] Document legacy format deprecation
```

### Overall Summary

**File**: `docs/TEST-MIGRATION-SUMMARY.md`

```markdown
# Test Migration Summary

## Overall Statistics
- Total fixtures migrated: X files
- Total test cases: Y
- Overall pass rate: ZZ.Z%

## Per-Flavor Results
| Flavor | Tests | Passed | Failed | Rate |
|--------|-------|--------|--------|------|
| IEC | 1000 | 950 | 50 | 95% |
| ISO | 7600 | 7544 | 56 | 99.2% |
| ... | ... | ... | ... | ... |
```

---

## Implementation Checklist

### Setup Phase
- [ ] Create `spec/` directory structure
- [ ] Create `spec/spec_helper.rb`
- [ ] Create `spec/support/fixture_test_helper.rb`
- [ ] Create `spec/integration/` directory
- [ ] Create `spec/fixtures/` directories for each flavor

### Per-Flavor Migration (repeat for each)
- [ ] Copy fixtures from `gems/pubid-FLAVOR/spec/fixtures/` to `spec/fixtures/FLAVOR/`
- [ ] Create `spec/integration/FLAVOR_spec.rb`
- [ ] Run tests: `bundle exec rspec spec/integration/FLAVOR_spec.rb`
- [ ] Document results in `docs/test-reports/FLAVOR-migration-report.md`
- [ ] Fix critical failures (bugs)
- [ ] Document acceptable failures (normalizations, legacy)

### High Priority (Must Complete)
- [ ] IEC migration
- [ ] ISO migration (formalize existing tests)
- [ ] NIST migration

### Medium Priority (Should Complete)
- [ ] BSI migration
- [ ] ITU migration
- [ ] JIS migration

### Low Priority (Nice to Have)
- [ ] CCSDS migration
- [ ] CEN migration
- [ ] ETSI migration

### New Flavors (Create from scratch)
- [ ] ANSI test fixtures (research real ANSI identifiers)
- [ ] IEEE test fixtures (if old gem exists)
- [ ] IDF test fixtures (if old gem exists)
- [ ] PLATEAU test fixtures (if old gem exists)

### Finalization
- [ ] Create overall summary report
- [ ] Update main README with test statistics
- [ ] Configure CI to run full test suite
- [ ] Document any breaking changes from v1 to v2

---

## Continuation Prompt for Next Session

```
PubID v2 - Comprehensive Test Migration (Session 4)

Branch: rt-new-lutaml-model, PR: #19

Previous Sessions Complete:
✅ Session 2: ISO 0% → 98.47%, original format preservation
✅ Session 3: ANSI created (100%), NIST fixed (100%)

Current Status:
- 13/13 flavors functionally complete
- ISO: 98.47%, NIST: 100%, ANSI: 100%
- All implementations tested with sample identifiers

MISSION: Migrate ALL old test fixtures to v2 RSpec tests

TASKS (10-12 hours):

1. SETUP INFRASTRUCTURE (2h)
   - Create spec/ directory structure
   - Create spec_helper.rb and shared test utilities
   - Set up RSpec configuration

2. HIGH PRIORITY MIGRATIONS (5h)
   - IEC: ~1000 cases from gems/pubid-iec/spec/fixtures/
   - ISO: ~7600 cases (formalize test_iso_v2.rb)  
   - NIST: ~1000 cases from gems/pubid-nist/spec/fixtures/

3. MEDIUM PRIORITY (2h)
   - BSI, ITU, JIS fixtures migration

4. REPORTING (1h)
   - Per-flavor migration reports
   - Overall summary with statistics
   - Document all incompatibilities

Reference: docs/CONTINUATION-PLAN-2025-11-17-TEST-MIGRATION.md

Start with: Inventory all fixtures and create spec/ infrastructure
```

---

## Quick Reference

### Key Files to Create
```
spec/
├── spec_helper.rb
├── support/
│   ├── fixture_test_helper.rb
│   └── shared_examples.rb
├── integration/
│   ├── iec_spec.rb
│   ├── iso_spec.rb
│   ├── nist_spec.rb
│   ├── bsi_spec.rb
│   ├── itu_spec.rb
│   ├── jis_spec.rb
│   ├── ansi_spec.rb
│   └── ... (others)
└── fixtures/
    ├── iec/
    ├── iso/
    ├── nist/
    └── ... (copy from old gems)
```

### Running Specific Tests
```bash
# All specs
bundle exec rspec

# Integration only
bundle exec rspec spec/integration/

# Specific flavor
bundle exec rspec spec/integration/iso_spec.rb

# With documentation format
bundle exec rspec spec/integration/iso_spec.rb --format documentation

# Only failures
bundle exec rspec spec/integration/ --only-failures

# With coverage
bundle exec rspec --require spec_helper
```

---

## Expected Outcomes

### Immediate Benefits
- Comprehensive regression testing
- Confidence in v2 implementations
- Clear documentation of all differences
- CI-ready test infrastructure

### Documentation Artifacts
- Per-flavor migration reports (13 files)
- Overall migration summary (1 file)
- Known incompatibilities list (1 file)
- CI configuration (1 file)

### Success Metrics
Target: ≥95% pass rate across all flavors
- Acceptable: Minor rendering differences (documented)
- Acceptable: Legacy format deprecations (documented)
- Not Acceptable: Functional regressions (must fix)

---

## Risk Mitigation

### Risk 1: Low Pass Rates

**If flavor <90%**:
1. Categorize failures
2. If bugs: Fix v2 implementation  
3. If normalizations: Document and accept
4. If legacy: Mark as deprecated format

### Risk 2: Long-Running Tests

**If test suite >5 minutes**:
1. Use RSpec tags for selective testing
2. Parallelize with `parallel_tests` gem
3. Cache fixture parsing results
4. Run full suite in CI only

### Risk 3: Fixture Data Issues

**If fixtures contain errors**:
1. Cross-reference with official standards
2. Mark questionable fixtures
3. Create "canonical" fixture set
4. Document data quality issues

---

## Future Enhancements

After migration complete:

1. **Property-Based Testing**: Use `rspec-quickcheck` for generated test cases
2. **Performance Benchmarks**: Compare v1 vs v2 parsing speed
3. **Fuzz Testing**: Generate random identifiers to test robustness
4. **Mutation Testing**: Use `mutant` gem to verify test quality

---

This migration ensures v2 is a drop-in replacement for v1 with full backward compatibility verification.