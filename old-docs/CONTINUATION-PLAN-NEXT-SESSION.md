# PubID v2 Continuation Plan - After BSI & NIST

**Date:** 2025-11-16  
**Branch:** rt-new-lutaml-model  
**PR:** #19  
**Status:** 11/12 flavors migrated, refinement phase needed

---

## Current Progress: 11/12 Flavors (92%)

### ✅ Completed Migrations

| Flavor | Pass Rate | Test Count | Status | Location |
|--------|-----------|------------|--------|----------|
| ISO | 99.52% | 7,114 | ⚠️ Needs 100% | [`lib/pubid_new/iso/`](../lib/pubid_new/iso/) |
| IEC | 100% | ~2,000 | ✅ Complete | [`lib/pubid_new/iec/`](../lib/pubid_new/iec/) |
| IDF | 100% | ~50 | ✅ Complete | [`lib/pubid_new/idf/`](../lib/pubid_new/idf/) |
| CEN | 100% | 50 | ✅ Complete | [`lib/pubid_new/cen/`](../lib/pubid_new/cen/) |
| CCSDS | 100% | 4 | ✅ Complete | [`lib/pubid_new/ccsds/`](../lib/pubid_new/ccsds/) |
| JIS | 100% | 10,635 | ✅ Complete | [`lib/pubid_new/jis/`](../lib/pubid_new/jis/) |
| PLATEAU | 100% | 115 | ✅ Complete | [`lib/pubid_new/plateau/`](../lib/pubid_new/plateau/) |
| ETSI | 100% | 24,718 | ✅ Complete | [`lib/pubid_new/etsi/`](../lib/pubid_new/etsi/) |
| ITU | 100% | 2,041 | ✅ Complete | [`lib/pubid_new/itu/`](../lib/pubid_new/itu/) |
| BSI | 100% | ~500 | ✅ Complete | [`lib/pubid_new/bsi/`](../lib/pubid_new/bsi/) |
| NIST | 97.8% | 1,000 | ⚠️ Needs 100% | [`lib/pubid_new/nist/`](../lib/pubid_new/nist/) |

**Tested:** 46,177+ identifiers  
**Average:** 99.9%+ accuracy

### ❌ Remaining: IEEE (1/12)

**Priority:** HIGH - Last flavor  
**Complexity:** HIGH  
**Estimated Time:** 4-6 hours  
**Test Fixtures:** 10,332 identifiers

**Old Location:** [`gems/pubid-ieee/lib/pubid/ieee/`](../gems/pubid-ieee/lib/pubid/ieee/)

**Fixture Files:**
- [`gems/pubid-ieee/spec/fixtures/pubid-to-parse.txt`](../gems/pubid-ieee/spec/fixtures/pubid-to-parse.txt) - 640 identifiers
- [`gems/pubid-ieee/spec/fixtures/pubid-parsed.txt`](../gems/pubid-ieee/spec/fixtures/pubid-parsed.txt) - 8,818 identifiers  
- [`gems/pubid-ieee/spec/fixtures/unapproved.txt`](../gems/pubid-ieee/spec/fixtures/unapproved.txt) - 874 identifiers

**Format Examples:**
```
IEEE 802.11-2020
IEEE 1076-1993
IEEE 1873-2015
IEEE Std 802.3-2018
IEEE/ISO/IEC 15288-2008
```

**Unique Features:**
- Multiple numbering schemes (802.x, 4-digit, mixed)
- Joint standards with ISO/IEC
- Multiple publishers (IEEE, AIEE, IRE)
- Amendment/revision patterns
- Unapproved/draft versions
- Very complex historical formats

---

## Immediate Tasks (Priority Order)

### 1. MIGRATE IEEE (4-6 hours) - NEXT

**Steps:**
1. Analyze old IEEE parser and identifier structure (30 min)
2. Create parser with proper numbering patterns (2 hours)
3. Create scheme supporting all components (1 hour)
4. Create builder (45 min)
5. Test incrementally: 100 → 500 → full (1-2 hours)
6. Target: 95%+ pass rate (100% achievable)

**IEEE Challenges:**
- Multiple numbering schemes (802.11 vs 1234)
- Joint ISO/IEC standards parsing
- Historical publishers (AIEE, IRE)
- Complex amendment patterns
- Large fixture count (10,332)

### 2. FIX ISO to 100% (2-3 hours)

**Current:** 99.52% (7,114 tests)  
**Gap:** ~34 failing identifiers

**Approach:**
1. Extract the 34 failing cases
2. Identify failure patterns
3. Update ISO parser/scheme/builder as needed
4. Retest until 100%

**ISO Issues to Address:**
- Remaining edge cases from initial migration
- Ensure all ISO formats properly handled
- Joint ISO/IEC standards

### 3. FIX NIST to 100% (2 hours)

**Current:** 97.8% (1,000 tests)  
**Gap:** 22 failing identifiers (historical NBS)

**Known Issues:**
1. "sup" vs "supp" (14 cases) - Add "sup" alternative
2. Edition-date patterns (4 cases) - "e2-1915"
3. Supplement-month (4 cases) - "supJan1924"

**Files to Update:**
- [`lib/pubid_new/nist/parser.rb`](../lib/pubid_new/nist/parser.rb) - Add alternative patterns
- [`lib/pubid_new/nist/scheme.rb`](../lib/pubid_new/nist/scheme.rb) - Handle date combinations

### 4. CREATE COMPREHENSIVE SPEC FILES (6-8 hours)

**For EACH flavor, create:**
```
spec/pubid_new/{flavor}/
├── parser_spec.rb        # Test parsing patterns
├── scheme_spec.rb        # Test data model
├── builder_spec.rb       # Test transformation
└── configuration_spec.rb # Test config loading (if applicable)
```

**Testing Principles (from rules):**
- Minimal and focused (one behavior per test)
- MECE (Mutually Exclusive, Collectively Exhaustive)
- No mocks or stubs
- Test actual behavior, not implementation
- Use fixtures for serialization tests

**Priority Flavors for Specs:**
1. IEEE (new migration)
2. NIST (complex)
3. BSI (complex)
4. ITU, ETSI, JIS (medium complexity)
5. ISO, IEC (if not already comprehensive)
6. Simple flavors (CEN, CCSDS, IDF, PLATEAU)

### 5. MIGRATE ALL SPECS & FIXTURES (4-6 hours)

**For EACH gem (`gems/pubid-{flavor}`):**

1. **Copy fixtures to spec directory:**
   ```bash
   cp gems/pubid-{flavor}/spec/fixtures/* spec/fixtures/pubid_{flavor}/
   ```

2. **Migrate existing specs:**
   - Review `gems/pubid-{flavor}/spec/**/*_spec.rb`
   - Adapt to v2 architecture
   - Update assertions for new API
   - Ensure proper fixture usage

3. **Validate:**
   - Run all specs: `bundle exec rspec spec/pubid_new/{flavor}/`
   - Ensure 100% passing
   - Fix any failures

**Estimated per flavor:** 30-60 minutes  
**Total for 12 flavors:** 6-12 hours

---

## Quality Requirements

### Code Standards

✅ **Architecture:**
- Fully object-oriented (SOLID principles)
- Single Responsibility per class
- Open/Closed principle (configuration over code)
- Dependency Inversion (YAML configs)
- MECE (Mutually Exclusive, Collectively Exhaustive)
- DRY (Don't Repeat Yourself)

✅ **Testing:**
- Every class has corresponding spec file
- Minimal, focused tests (one behavior each)
- MECE test coverage
- No mocks or stubs
- Test behavior, not implementation
- Use fixtures for complex data

✅ **Documentation:**
- Clear inline comments
- Method documentation with @param and @return
- README.adoc for each component
- Architecture diagrams
- Usage examples

### Pass Rate Requirements

- **Minimum:** 95% on fixture tests
- **Target:** 100% (proven achievable on 10 flavors)
- **Current gaps:**
  - ISO: 99.52% → 100% (34 cases)
  - NIST: 97.8% → 100% (22 cases)
  - IEEE: 0% → 95%+ (to be migrated)

---

## Next Session Prompt

```
PubID v2 - REFINEMENT & COMPLETION PHASE

Branch: rt-new-lutaml-model
PR: #19

Current Status: 11/12 flavors migrated (92%)

✅ Complete at 100%:
IEC, IDF, CEN, CCSDS, JIS, PLATEAU, ETSI, ITU, BSI (9 flavors)

⚠️ Complete but needs 100%:
- ISO: 99.52% → needs 100% (34 failing cases)
- NIST: 97.8% → needs 100% (22 failing historical cases)

❌ Not migrated:
- IEEE: 0% → needs migration (640 main + 8,818 parsed + 874 unapproved)

Recent Completions (2025-11-16):
✅ BSI: 100% (adoption chains, national annexes)
✅ NIST: 97.8% (50+ series, most complex architecture)

NEXT TASKS (in priority order):

Task 1: MIGRATE IEEE (HIGHEST PRIORITY, 4-6 hours)
Location: gems/pubid-ieee/ → lib/pubid_new/ieee/
Fixtures: 10,332 identifiers total
Format: IEEE 802.11-2020, IEEE 1873-2015, IEEE/ISO/IEC 15288-2008
Challenges:
- Multiple numbering schemes (802.x vs regular)
- Joint ISO/IEC standards
- Historical publishers (AIEE, IRE)  
- Complex amendment patterns
Steps:
1. Analyze gems/pubid-ieee/lib/pubid/ieee/ structure
2. Review fixtures: pubid-to-parse.txt (640 identifiers)
3. Create parser handling all numbering schemes
4. Create scheme with all components
5. Create builder
6. Test: 100 → 500 → full
7. Target: 95%+ (100% achievable)

Task 2: FIX ISO TO 100% (2-3 hours)
Current: 99.52% (7,114 tests, 34 failures)
Steps:
1. Extract 34 failing cases
2. Identify patterns
3. Fix lib/pubid_new/iso/ as needed
4. Retest until 100%

Task 3: FIX NIST TO 100% (2 hours)
Current: 97.8% (1,000 tests, 22 failures)
Known issues:
- "sup" vs "supp" (14 cases)
- Edition-date "e2-1915" (4 cases)
- Supplement-month "supJan1924" (4 cases)
Files: lib/pubid_new/nist/parser.rb, lib/pubid_new/nist/scheme.rb

Task 4: CREATE SPEC FILES (6-8 hours)
For each flavor, create:
- spec/pubid_new/{flavor}/parser_spec.rb
- spec/pubid_new/{flavor}/scheme_spec.rb  
- spec/pubid_new/{flavor}/builder_spec.rb
- spec/pubid_new/{flavor}/configuration_spec.rb (if applicable)

Rules:
- Minimal, focused (one behavior per test)
- MECE coverage
- No mocks/stubs
- Test behavior, not implementation
- Use fixtures from gems/pubid-{flavor}/spec/fixtures/

Priority: IEEE, NIST, BSI first (most complex/recent)

Task 5: MIGRATE ALL SPECS & FIXTURES (4-6 hours)
For each gem:
1. Copy fixtures: gems/pubid-{flavor}/spec/fixtures/ → spec/fixtures/pubid_{flavor}/
2. Review old specs: gems/pubid-{flavor}/spec/**/*_spec.rb
3. Adapt to v2 API
4. Run and fix until 100% passing
5. Validate all edge cases

Quality Requirements:
- ✅ 100% pass rate on all flavors (no exceptions)
- ✅ Every class has spec file  
- ✅ All fixtures migrated and tested
- ✅ SOLID principles throughout
- ✅ Configuration over hardcoding
- ✅ MECE compliance
- ✅ No shortcuts or threshold lowering

Documentation:
- docs/CONTINUATION-PLAN-NEXT-SESSION.md (this file)
- docs/SESSION-2025-11-16-*.md (5 migration reports)

Start with: IEEE migration
Then: ISO fixes
Then: NIST fixes
Then: Comprehensive spec creation
Then: Full spec/fixture migration

Goal: 12/12 flavors at 100%, all specs passing, production-ready
```

---

## IEEE Migration Plan (Detailed)

### Analysis Phase (30 min)

```bash
# Check structure
ls -la gems/pubid-ieee/lib/pubid/ieee/

# Count fixtures
wc -l gems/pubid-ieee/spec/fixtures/*.txt

# Sample formats
head -50 gems/pubid-ieee/spec/fixtures/pubid-to-parse.txt

# Review parser
cat gems/pubid-ieee/lib/pubid/ieee/parser.rb
```

### Implementation Phase (3-4 hours)

**Files to Create:**
1. `lib/pubid_new/ieee/parser.rb` - Parslet grammar
   - Handle 802.x format (dots)
   - Handle regular number format
   - Joint ISO/IEC prefixes
   - Amendment/revision patterns
   
2. `lib/pubid_new/ieee/scheme.rb` - Lutaml::Model
   - Number attribute (flexible for both formats)
   - Joint standard support
   - Amendment structure
   - Title/description handling

3. `lib/pubid_new/ieee/builder.rb` - Transformer
   - Extract number (handle dots)
   - Handle joint standards
   - Process amendments

4. `lib/pubid_new/ieee.rb` - Entry point
   - parse() method
   - Module structure

5. Update `lib/pubid_new.rb` - Add require

### Testing Phase (1-2 hours)

**Test Sequence:**
```ruby
# Test 1: Manual samples (10 identifiers)
test_cases = [
  'IEEE 802.11-2020',
  'IEEE 1873-2015',
  'IEEE Std 802.3-2018',
  # ... more samples
]

# Test 2: First 100 from pubid-to-parse.txt
# Test 3: First 500  
# Test 4: Full 640
# Test 5: Sample from pubid-parsed.txt (8,818)
# Test 6: Sample from unapproved.txt (874)
```

**Debug Strategy:**
1. Capture first 10 failures
2. Identify patterns
3. Fix parser (order matters!)
4. Retest until 95%+
5. Push for 100%

---

## ISO 100% Fix Plan (Detailed)

### Identify Failures (30 min)

```ruby
# Extract failing cases
require_relative 'lib/pubid_new'

File.read('TODO.TMP.md').split("\n").each do |test|
  next if test.strip.empty?
  begin
    id = PubidNew::Iso.parse(test)
    puts "✗ #{test}" if test != id.to_s
  rescue => e
    puts "✗ #{test} => ERROR"
  end
end
```

Save failures to file for analysis.

### Fix & Retest (1.5-2 hours)

1. Group failures by pattern
2. Update [`lib/pubid_new/iso/parser.rb`](../lib/pubid_new/iso/parser.rb)
3. Update [`lib/pubid_new/iso/builder.rb`](../lib/pubid_new/iso/builder.rb) if needed
4. Test incrementally
5. Verify 100%

---

## NIST 100% Fix Plan (Detailed)

### Known Issue Categories

**1. "sup" vs "supp" (14 cases)**
```ruby
# In parser.rb
rule(:supplement) do
  # Accept both "sup" and "supp"
  (str("supp") | str("sup")) >> match("[A-Z0-9]").repeat.as(:supplement)
end

# In scheme.rb - normalize to "supp"
def build_supplement_string
  if supplement && supplement.length > 0
    "supp#{supplement}"
  else
    "supp"
  end
end
```

**2. Edition-Date (4 cases)**
```ruby
# Add to parser.rb edition rule:
rule(:edition) do
  # ... existing patterns ...
  (str("e") >> digits.as(:edition) >> dash >> digits.as(:edition_year))
end
```

**3. Supplement-Month (4 cases)**
```ruby
# Add to parser.rb:
rule(:supplement) do
  (str("supp") | str("sup")) >> 
    (match("[A-Z0-9]").repeat | month_letters).as(:supplement)
end
```

### Test & Validate (30 min)

Test the 22 known failures until all pass.

---

## Spec File Creation Plan

### Template Structure

For each class, create spec following Ruby testing rules:

```ruby
# spec/pubid_new/{flavor}/parser_spec.rb
require "spec_helper"

RSpec.describe PubidNew::{Flavor}::Parser do
  let(:parser) { described_class.new }
  
  describe "#parse" do
    context "with basic format" do
      let(:input) { "BASIC FORMAT" }
      
      it "parses correctly" do
        result = parser.parse(input)
        expect(result[:key]).to eq("value")
      end
    end
    
    # More focused tests...
  end
end
```

### Coverage Requirements

**Parser Specs:**
- Test each rule individually where possible
- Test complex patterns
- Test edge cases
- Test failure cases

**Scheme Specs:**
- Test initialization with various attributes
- Test #to_s rendering
- Test attribute defaults
- Test edge cases

**Builder Specs:**
- Test simple transformations
- Test complex transformations
- Test array handling
- Test nil/empty handling

**Configuration Specs (if applicable):**
- Test YAML loading
- Test series lookup
- Test validation
- Test error handling

---

## Fixture Migration Plan

### Directory Structure

```
spec/
└── fixtures/
    ├── pubid_iso/
    ├── pubid_iec/
    ├── pubid_idf/
    ├── pubid_cen/
    ├── pubid_ccsds/
    ├── pubid_jis/
    ├── pubid_plateau/
    ├── pubid_etsi/
    ├── pubid_itu/
    ├── pubid_bsi/
    ├── pubid_nist/
    └── pubid_ieee/
```

### Migration Strategy

For each flavor:

```bash
# 1. Create fixture directory
mkdir -p spec/fixtures/pubid_{flavor}

# 2. Copy fixtures
cp gems/pubid-{flavor}/spec/fixtures/* spec/fixtures/pubid_{flavor}/

# 3. Update spec files to reference new paths
# In spec files: 'spec/fixtures/pubid_{flavor}/file.txt'
```

### Validation

After migration, ensure:
- All fixtures accessible
- All specs reference correct paths
- Specs run successfully
- No missing files
- Proper .gitignore if needed

---

## Success Criteria (STRICT)

### Migration Complete When:

✅ **All 12 flavors at 100%** (no exceptions, no threshold lowering)
- ISO: 100.00% (currently 99.52%)
- IEC through BSI: 100.00% ✅
- NIST: 100.00% (currently 97.8%)
- IEEE: 100.00% (to be migrated)

✅ **Every class has spec file**
- parser_spec.rb for each parser
- scheme_spec.rb for each scheme
- builder_spec.rb for each builder
- configuration_spec.rb where applicable

✅ **All specs passing**
- Run `bundle exec rspec` → 100% passing
- No pending tests
- No skipped tests
- Full coverage of behaviors

✅ **All fixtures migrated**
- spec/fixtures/pubid_{flavor}/ for each
- All old fixtures copied
- Spec files updated to new paths
- No broken references

✅ **Architecture validated**
- SOLID principles
- Configuration over code
- MECE compliance
- Separation of concerns
- No shortcuts taken

---

## Estimated Timeline

### Remaining Work

| Task | Time | Priority |
|------|------|----------|
| IEEE migration | 4-6 hours | CRITICAL |
| ISO 100% fix | 2-3 hours | HIGH |
| NIST 100% fix | 2 hours | HIGH |
| Create spec files (12 flavors) | 6-8 hours | HIGH |
| Migrate specs & fixtures | 4-6 hours | MEDIUM |
| Final validation | 1-2 hours | HIGH |

**Total Estimated:** 19-27 hours

### Aggressive Timeline
- If IEEE is straightforward: 15-20 hours
- If patterns established: 18-24 hours

### Conservative Timeline
- If IEEE is complex: 25-30 hours
- With thorough testing: 22-28 hours

---

## Git Workflow

### Current State
```bash
git status
# On branch: rt-new-lutaml-model
# New: lib/pubid_new/bsi/, lib/pubid_new/nist/
# Modified: lib/pubid_new.rb
# New docs: docs/SESSION-2025-11-16-*.md
```

### Recommended Approach

**After each major task:**
```bash
# IEEE migration
git add lib/pubid_new/ieee/
git commit -m "feat(pubid): migrate IEEE to v2, {X}% on {N} identifiers"

# ISO 100%
git add lib/pubid_new/iso/
git commit -m "fix(pubid): achieve 100% on ISO (was 99.52%)"

# NIST 100%
git add lib/pubid_new/nist/
git commit -m "fix(pubid): achieve 100% on NIST (was 97.8%)"

# Spec files
git add spec/pubid_new/
git commit -m "test(pubid): add comprehensive specs for all v2 classes"

# Fixture migration
git add spec/fixtures/
git commit -m "test(pubid): migrate all fixtures from gems/*"
```

**Do NOT push** - will be done manually

---

## Reference Materials

### Best Implementations
- **Simple:** [`lib/pubid_new/ccsds/`](../lib/pubid_new/ccsds/)
- **Medium:** [`lib/pubid_new/itu/`](../lib/pubid_new/itu/)
- **Complex:** [`lib/pubid_new/etsi/`](../lib/pubid_new/etsi/)
- **Config-driven:** [`lib/pubid_new/nist/`](../lib/pubid_new/nist/) (newest)
- **Adoption chains:** [`lib/pubid_new/bsi/`](../lib/pubid_new/bsi/) (newest)

### Testing Examples
- Existing specs: `gems/pubid-{flavor}/spec/`
- Fixture patterns: `gems/pubid-{flavor}/spec/fixtures/`

### Documentation
- Session reports: `docs/SESSION-2025-11-16-*.md`
- This plan: `docs/CONTINUATION-PLAN-NEXT-SESSION.md`

---

## Final Notes

**Quality over speed:** We must achieve 100% on all flavors, not settle for 95%.

**Testing required:** Every class needs comprehensive specs.

**No shortcuts:** Follow SOLID, MECE, and all architectural principles strictly.

**The goal:** Production-ready v2 architecture with 100% pass rates and full test coverage.

---

**Ready to continue with IEEE migration as the immediate next task!** 🚀