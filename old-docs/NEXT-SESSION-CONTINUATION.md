# PubID v2 Continuation Plan

## Current Status (2025-11-16)

**Branch:** rt-new-lutaml-model
**PR:** #19
**Progress:** 8/12 flavors complete (66.67%)

### Completed Flavors ✅

1. **ISO** - 99.52% (7,080/7,114 tests) - [`lib/pubid_new/iso/`](../lib/pubid_new/iso/)
2. **IEC** - 100% - [`lib/pubid_new/iec/`](../lib/pubid_new/iec/)
3. **IDF** - 100% - [`lib/pubid_new/idf/`](../lib/pubid_new/idf/)
4. **CEN** - 100% (50 tests) - [`lib/pubid_new/cen/`](../lib/pubid_new/cen/)
5. **CCSDS** - 100% (4 tests) - [`lib/pubid_new/ccsds/`](../lib/pubid_new/ccsds/)
6. **JIS** - 100% (10,635 tests) - [`lib/pubid_new/jis/`](../lib/pubid_new/jis/)
7. **PLATEAU** - 100% (115 tests) - [`lib/pubid_new/plateau/`](../lib/pubid_new/plateau/)
8. **ETSI** - 100% (24,718 tests) - [`lib/pubid_new/etsi/`](../lib/pubid_new/etsi/) ⭐ LARGEST!

**Key Features Working:**
- Three operators: `/` (supplement), `|` (dual), `+` (bundled)
- Smart bundled spacing (CEN: no space, ISO: with spaces)
- lutaml-model architecture established
- Component-based attributes
- Scheme registry pattern

## Remaining Flavors (7 flavors, 130 files)

### 1. JIS (Japanese Industrial Standards) - NEXT

**Priority:** HIGH  
**Complexity:** MEDIUM  
**Files:** 17 files  
**Test Cases:** **10,635 identifiers** in [`gems/pubid-jis/spec/fixtures/jis-pubids.txt`](../gems/pubid-jis/spec/fixtures/jis-pubids.txt)

**Format:** `JIS {series} {number}-{part}:{year}({language})`

**Examples:**
```
JIS A 1234-1:1999(E)
JIS B 7001:2018
JIS C 60068-2-1:2010
JIS X 0208:2012
```

**Unique Features:**
- Series letter + space + number
- Hyphen for parts (like ISO)
- Language codes in parentheses: (E), (jp)
- Document types: TR (Technical Report), TS (Technical Specification)
- Amendments and Explanations

**Old Structure:**
```
gems/pubid-jis/lib/pubid/jis/
├── identifier/
│   ├── base.rb
│   ├── technical_report.rb
│   ├── technical_specification.rb
│   ├── amendment.rb
│   └── explanation.rb
├── renderer/
│   └── base.rb, tr.rb, ts.rb, amendment.rb, explanation.rb
└── parser.rb
```

**Migration Steps:**
1. Create `lib/pubid_new/jis/` structure
2. Analyze old parser for rules
3. Create identifier classes (Base, TR, TS, Amendment, Explanation)
4. Create scheme registry
5. Create parser (similar to ISO pattern)
6. Create builder
7. Test with sample identifiers
8. Create spec that round-trips ALL 10,635 identifiers from fixture file

**Estimated Time:** 3-4 hours

### 2. PLATEAU (Project PLATEAU)

**Priority:** HIGH  
**Complexity:** LOW-MEDIUM  
**Files:** 12 files  
**Test Cases:** TBD (check fixtures)

**Migration:** Analyze structure first

**Estimated Time:** 2-3 hours

### 3. ETSI (European Telecommunications Standards Institute)

**Priority:** MEDIUM  
**Complexity:** MEDIUM  
**Files:** 12 files  
**Test Cases:** Check [`gems/pubid-etsi/spec/fixtures/pubids.txt`](../gems/pubid-etsi/spec/fixtures/pubids.txt)

**Format:** `ETSI TS 102 822-1 V1.1.1 (2003-10)`

**Unique Features:**
- Version numbers: `V1.1.1`
- Month in date: `(2003-10)`
- Multiple types: TS, TR, EN, ES, EG, SR, GS, GR

**Estimated Time:** 3-4 hours

### 4. ITU (International Telecommunication Union)

**Priority:** MEDIUM  
**Complexity:** MEDIUM-HIGH  
**Files:** 25 files  
**Test Cases:** Check [`gems/pubid-itu/spec/fixtures/itu-r.txt`](../gems/pubid-itu/spec/fixtures/itu-r.txt)

**Format:** 
- `ITU-T G.711`
- `ITU-R BT.601-7`

**Unique Features:**
- Two divisions: ITU-T (telecom), ITU-R (radio)
- Series system with series.yaml
- Amendments
- Complex numbering

**Estimated Time:** 4-5 hours

### 5. BSI (British Standards Institution)

**Priority:** MEDIUM  
**Complexity:** HIGH  
**Files:** 29 files

**Format:** `BS EN ISO 9001:2015` (adoption chains)

**Unique Features:**
- Adopts ISO/IEC/EN standards
- Complex adoption chains
- Many document types
- National annexes

**Estimated Time:** 5-6 hours

### 6. NIST (National Institute of Standards and Technology)

**Priority:** LOW (most complex, do last)  
**Complexity:** VERY HIGH  
**Files:** 34 files  
**Test Cases:** ~7,000+ in fixtures directory

**Format:** `NIST SP 800-53 Rev. 5`

**Unique Features:**
- Multiple series (SP, FIPS, etc.)
- Revision system
- Volume/Part structure
- Complex metadata
- Many publishers

**Estimated Time:** 6-8 hours

## Migration Checklist Template

For each flavor, follow this checklist:

- [ ] **Analyze old structure**
  - [ ] Read README.adoc
  - [ ] Check identifier types in old code
  - [ ] Review parser rules
  - [ ] Count test fixtures
  
- [ ] **Create directory structure**
  - [ ] `lib/pubid_new/{flavor}/`
  - [ ] identifier.rb (base class)
  - [ ] single_identifier.rb
  - [ ] supplement_identifier.rb (if needed)
  
- [ ] **Create identifier classes**
  - [ ] One class per document type
  - [ ] TYPED_STAGES for each
  - [ ] self.type method
  - [ ] to_s method with proper formatting
  
- [ ] **Create scheme**
  - [ ] Register all identifier types
  - [ ] typed_stages collection
  - [ ] locate methods
  
- [ ] **Create parser**
  - [ ] Parslet grammar
  - [ ] Handle all document types
  - [ ] Handle supplements if applicable
  - [ ] Handle special features (versions, series, etc.)
  
- [ ] **Create builder**
  - [ ] cast method for all attributes
  - [ ] locate_identifier_klass logic
  - [ ] build method
  
- [ ] **Create main module file**
  - [ ] Require all files
  - [ ] Define {Flavor}.parse method
  
- [ ] **Update lib/pubid_new.rb**
  - [ ] Add require_relative line
  
- [ ] **Test manually**
  - [ ] 5-10 example identifiers
  - [ ] Verify round-trip parsing
  
- [ ] **Create comprehensive tests**
  - [ ] Parser spec
  - [ ] Identifier spec
  - [ ] Individual type specs
  
- [ ] **Create fixture round-trip spec**
  - [ ] Read TXT file
  - [ ] Test each identifier
  - [ ] Report pass rate

## Fixture Files to Test

**Confirmed Fixture Files:**

1. **ISO:** [`TODO.TMP.md`](../TODO.TMP.md) - 7,114 identifiers
2. **JIS:** [`gems/pubid-jis/spec/fixtures/jis-pubids.txt`](../gems/pubid-jis/spec/fixtures/jis-pubids.txt) - 10,635 identifiers
3. **IEC:** Multiple in [`gems/pubid-iec/spec/fixtures/`](../gems/pubid-iec/spec/fixtures/)
4. **ITU:** [`gems/pubid-itu/spec/fixtures/itu-r.txt`](../gems/pubid-itu/spec/fixtures/itu-r.txt)
5. **ETSI:** [`gems/pubid-etsi/spec/fixtures/pubids.txt`](../gems/pubid-etsi/spec/fixtures/pubids.txt)
6. **NIST:** Multiple large files in [`gems/pubid-nist/spec/fixtures/`](../gems/pubid-nist/spec/fixtures/)

## Final Validation Plan

Once all flavors are migrated:

### Step 1: Individual Fixture Tests

Create `spec/pubid_new/{flavor}/fixtures_spec.rb` for each flavor:

```ruby
require "spec_helper"

RSpec.describe "#{Flavor} Fixture Round-trip" do
  let(:fixture_file) { File.join(__dir__, "../../../gems/pubid-#{flavor}/spec/fixtures/#{flavor}-pubids.txt") }
  
  it "round-trips all identifiers from fixture file" do
    identifiers = File.readlines(fixture_file).map(&:strip).reject(&:empty?)
    
    passed = 0
    failed = []
    
    identifiers.each do |pubid|
      begin
        identifier = PubidNew::{Flavor}.parse(pubid)
        rendered = identifier.to_s
        if pubid == rendered
          passed += 1
        else
          failed << { original: pubid, rendered: rendered }
        end
      rescue => e
        failed << { original: pubid, error: e.message }
      end
    end
    
    puts "\n#{Flavor.upcase} Results: #{passed}/#{identifiers.count} passing (#{(passed.to_f/identifiers.count*100).round(2)}%)"
    
    if failed.any?
      puts "\nFirst 10 failures:"
      failed.first(10).each do |f|
        if f[:error]
          puts "  ✗ #{f[:original]} => ERROR: #{f[:error]}"
        else
          puts "  ~ #{f[:original]} => #{f[:rendered]}"
        end
      end
    end
    
    expect(passed.to_f / identifiers.count).to be >= 0.95  # 95% pass rate minimum
  end
end
```

### Step 2: Combined Validation Report

Create `tmp/validate_all_flavors.rb`:

```ruby
#!/usr/bin/env ruby
require_relative '../lib/pubid_new'

flavors = {
  iso: { file: 'TODO.TMP.md', module: PubidNew::Iso },
  jis: { file: 'gems/pub id-jis/spec/fixtures/jis-pubids.txt', module: PubidNew::Jis },
  # ... etc
}

total_tested = 0
total_passed = 0

flavors.each do |name, config|
  identifiers = File.readlines(config[:file]).map(&:strip).reject(&:empty?)
  passed = 0
  
  identifiers.each do |pubid|
    begin
      identifier = config[:module].parse(pubid)
      passed += 1 if pubid == identifier.to_s
    rescue
      # Count as failure
    end
  end
  
  total_tested += identifiers.count
  total_passed += passed
  
  puts "#{name.upcase}: #{passed}/#{identifiers.count} (#{(passed.to_f/identifiers.count*100).round(2)}%)"
end

puts "\nOVERALL: #{total_passed}/#{total_tested} (#{(total_passed.to_f/total_tested*100).round(2)}%)"
```

## Success Criteria

**For Each Flavor:**
- [ ] 95%+ pass rate on fixture files
- [ ] All documented examples working
- [ ] Tests created and passing
- [ ] Architecture consistent with patterns

**Overall:**
- [ ] All 12 flavors migrated
- [ ] 95%+ average pass rate across all fixtures
- [ ] Comprehensive test suite
- [ ] Documentation updated

## Technical Patterns Established

**Reuse These Patterns:**

1. **Directory Structure:**
   ```
   lib/pubid_new/{flavor}/
   ├── identifier.rb
   ├── single_identifier.rb
   ├── supplement_identifier.rb (if supplements exist)
   ├── scheme.rb
   ├── parser.rb
   ├── builder.rb
   └── identifiers/
       ├── {type}_1.rb
       └── {type}_n.rb
   ```

2. **Identifier Class Pattern:**
   ```ruby
   class TypeName < SingleIdentifier
     attribute :type, Components::Type, default: -> { type[:key] }
     
     TYPED_STAGES = [
       Components::TypedStage.new(...)
     ].freeze
     
     def self.type
       { key: :symbol, title: "Title", short: "SHORT" }
     end
   end
   ```

3. **Parser Pattern:**
   - Use Parslet
   - Include CommonParseRules and CommonParseMethods
   - Sort typed stages by length (longest first)
   - Handle supplements with separate rules

4. **Builder Pattern:**
   - Initialize with scheme
   - locate_typed_stage method
   - locate_identifier_klass method
   - build method iterates over parsed_hash
   - cast method for all attribute types

5. **Component Access:**
   - Publisher: `.body`
   - Code: `.value`
   - Date: `.year`
   - Edition: `.number`

## Estimated Timeline

**Conservative Estimate:**
- JIS: 3-4 hours
- PLATEAU: 2-3 hours
- ETSI: 3-4 hours
- ITU: 4-5 hours
- BSI: 5-6 hours
- NIST: 6-8 hours
- Final validation: 2-3 hours

**Total:** 25-33 hours

**Aggressive Estimate:**
- With established patterns: 15-20 hours
- Parallel work on similar flavors
- Reuse components and patterns

## Ready-to-Use Prompt for Next Session

See the continuation prompt at the end of this document.

---

## Continuation Prompt

```
Continue PubID v2 implementation (PR #19, branch: rt-new-lutaml-model)

Session Summary (2025-11-15):
✅ ISO validated (99.52%)
✅ IEC complete (100%)
✅ CEN migrated (100% - 50 tests)
✅ CCSDS migrated (100% - 4 tests)

Progress: 5/12 flavors (42%)

Next Task: Migrate JIS (Japanese Industrial Standards)

JIS Details:
- Location: lib/pubid_new/jis/ (to create)
- Format: JIS {series} {number}-{part}:{year}({language})
- Examples:
  * JIS A 1234-1:1999(E)
  * JIS B 7001:2018
  * JIS C 60068-2-1:2010
- Test Cases: 10,635 identifiers in gems/pubid-jis/spec/fixtures/jis-pubids.txt
- Old Implementation: gems/pubid-jis/lib/pubid/jis/
- Document Types: Base, TR, TS, Amendment, Explanation

Requirements:
1. Follow CEN/CCSDS migration pattern
2. Include ALL 10,635 fixture identifiers in round-trip test
3. Create comprehensive test suite
4. Achieve 95%+ pass rate

Reference Patterns:
- CEN: lib/pubid_new/cen/ (most recent, best practices)
- CCSDS: lib/pubid_new/ccsds/ (simplest example)
- ISO: lib/pubid_new/iso/ (most complete)

Then proceed with: PLATEAU → ETSI → ITU → BSI → NIST

Final Step: Create round-trip validation for ALL fixture files across all flavors.

Documentation:
- docs/NEXT-SESSION-CONTINUATION.md (this file)
- docs/SESSION-2025-11-15-COMPLETE-SUMMARY.md
- docs/remaining-flavors-migration-plan.md
```

---

## Quick Reference Commands

### Run Tests
```bash
# All CEN tests
bundle exec rspec spec/pubid_new/cen/

# All CCSDS tests  
bundle exec rspec spec/pubid_new/ccsds/

# ISO validation
ruby tmp/validate_identifiers.rb
```

### Test Individual Flavor
```bash
# Template
ruby -e "
require_relative 'lib/pubid_new'
test = '{IDENTIFIER}'
identifier = PubidNew::{Flavor}.parse(test)
puts identifier.to_s
"
```

### Check Fixtures
```bash
# Count identifiers in fixture
wc -l gems/pubid-jis/spec/fixtures/jis-pubids.txt

# View first 10
head -10 gems/pubid-jis/spec/fixtures/jis-pubids.txt
```

---

*Ready for systematic completion of remaining 7 flavors*  
*Estimated: 15-33 hours depending on complexity*