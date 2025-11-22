# PubID v2 Continuation Plan - After JIS Migration

**Date:** 2025-11-16  
**Branch:** rt-new-lutaml-model  
**PR:** #19

## Current Progress

**6/12 flavors complete (50%)**

### Completed Flavors ✅

| Flavor | Pass Rate | Test Count | Location |
|--------|-----------|------------|----------|
| ISO | 99.52% | 7,080/7,114 | [`lib/pubid_new/iso/`](../lib/pubid_new/iso/) |
| IEC | 100% | All | [`lib/pubid_new/iec/`](../lib/pubid_new/iec/) |
| IDF | 100% | All | [`lib/pubid_new/idf/`](../lib/pubid_new/idf/) |
| CEN | 100% | 50 | [`lib/pubid_new/cen/`](../lib/pubid_new/cen/) |
| CCSDS | 100% | 4 | [`lib/pubid_new/ccsds/`](../lib/pubid_new/ccsds/) |
| **JIS** | **100%** | **10,635** | [`lib/pubid_new/jis/`](../lib/pubid_new/jis/) |

## Remaining Flavors (6)

### Priority Order

1. **PLATEAU** - Next (HIGH priority)
2. **ETSI** - Medium priority
3. **ITU** - Medium priority
4. **BSI** - Medium priority
5. **NIST** - Low priority (most complex, do last)

Total estimated time: 15-25 hours

---

## 1. PLATEAU Migration (NEXT)

**Priority:** HIGH  
**Complexity:** LOW-MEDIUM  
**Estimated Time:** 2-3 hours

### Overview

Project PLATEAU is a Japanese government initiative for 3D city models.

**Old Implementation:** [`gems/pubid-plateau/`](../gems/pubid-plateau/)

### Format Analysis Required

Before starting, analyze:
1. Check [`gems/pubid-plateau/lib/pubid/plateau/`](../gems/pubid-plateau/lib/pubid/plateau/) structure
2. Review parser in old implementation
3. Identify document types
4. Check for fixture files in [`gems/pubid-plateau/spec/fixtures/`](../gems/pubid-plateau/spec/fixtures/)

### Migration Steps

1. **Analyze Structure** (15 min)
   - Read old README.adoc if exists
   - Check identifier types
   - Review parser patterns
   - Count test fixtures

2. **Create Implementation** (1-1.5 hours)
   - Create `lib/pubid_new/plateau/` directory
   - Create identifier base class
   - Create single_identifier class
   - Create identifier type classes
   - Create scheme registry
   - Create parser (Parslet)
   - Create builder
   - Create main plateau.rb module

3. **Test** (30-45 min)
   - Test with sample identifiers
   - Create fixture round-trip spec
   - Verify 95%+ pass rate

4. **Document** (15 min)
   - Update lib/pubid_new.rb to require PLATEAU
   - Update NEXT-SESSION-CONTINUATION.md
   - Create session summary

### Reference Pattern

Follow JIS migration pattern:
- Simple, clean structure
- Direct attribute mapping
- Proper Parslet captures with `.as(:key)`
- Component-based builder

---

## 2. ETSI Migration

**Priority:** MEDIUM  
**Complexity:** MEDIUM  
**Estimated Time:** 3-4 hours  
**Files:** 12 files

### Format

`ETSI TS 102 822-1 V1.1.1 (2003-10)`

### Unique Features

- Version numbers: `V1.1.1`
- Month in date: `(2003-10)`
- Multiple types: TS, TR, EN, ES, EG, SR, GS, GR

### Key Challenges

1. Version number parsing
2. Month precision in dates
3. Multiple document type variations

### Fixture Reference

[`gems/pubid-etsi/spec/fixtures/pubids.txt`](../gems/pubid-etsi/spec/fixtures/pubids.txt)

---

## 3. ITU Migration

**Priority:** MEDIUM  
**Complexity:** MEDIUM-HIGH  
**Estimated Time:** 4-5 hours  
**Files:** 25 files

### Format

- `ITU-T G.711`
- `ITU-R BT.601-7`

### Unique Features

- Two divisions: ITU-T (telecom), ITU-R (radio)
- Series system with [`gems/pubid-itu/series.yaml`](../gems/pubid-itu/series.yaml)
- Amendments
- Complex numbering with dots

### Key Challenges

1. Division handling (T vs R)
2. Series configuration loading
3. Dot-separated numbering
4. Amendment structure

### Fixture Reference

[`gems/pubid-itu/spec/fixtures/itu-r.txt`](../gems/pubid-itu/spec/fixtures/itu-r.txt)

---

## 4. BSI Migration

**Priority:** MEDIUM  
**Complexity:** HIGH  
**Estimated Time:** 5-6 hours  
**Files:** 29 files

### Format

`BS EN ISO 9001:2015` (adoption chains)

### Unique Features

- Adopts ISO/IEC/EN standards
- Complex adoption chains (BS adopts EN which adopts ISO)
- Many document types
- National annexes

### Key Challenges

1. Adoption chain parsing
2. Multiple co-publishers
3. National annex handling
4. Complex type interactions

### Old Structure

[`gems/pubid-bsi/lib/pubid/bsi/`](../gems/pubid-bsi/lib/pubid/bsi/)

---

## 5. NIST Migration (LAST)

**Priority:** LOW (most complex)  
**Complexity:** VERY HIGH  
**Estimated Time:** 6-8 hours  
**Files:** 34 files

### Format

`NIST SP 800-53 Rev. 5`

### Unique Features

- Multiple series (SP, FIPS, IR, etc.) with [`gems/pubid-nist/series.yaml`](../gems/pubid-nist/series.yaml)
- Revision system
- Volume/Part structure
- Complex metadata
- Multiple publishers with [`gems/pubid-nist/publishers.yaml`](../gems/pubid-nist/publishers.yaml)

### Key Challenges

1. Series configuration loading and management
2. Revision vs Edition handling
3. Volume/Part complex structure
4. Publisher configuration
5. ~7,000+ test fixtures

### Why Last

- Most complex architecture
- Requires all patterns refined
- Benefits from all previous learnings
- Has the most edge cases

---

## Success Patterns Learned from JIS

### What Worked Perfectly

1. **Proper Parslet Captures**
   ```ruby
   number.as(:number)  # NOT just: number
   part.as(:part)      # NOT just: part.maybe
   ```

2. **Component Builder Pattern**
   ```ruby
   when :number
     Components::Code.new(value: value)
   when :part
     Components::Code.new(value: value.to_s.sub(/^-/, ""))
   ```

3. **Simple to_s Method**
   ```ruby
   def to_s(lang: :en, lang_single: false)
     parts = []
     parts << publisher.body if publisher
     parts << "#{series.value} #{number.value}"
     result = parts.join(" ")
     result += "-#{part.value}" if part
     result += ":#{date.year}" if date
     result
   end
   ```

4. **Comprehensive Testing**
   - Test manually with 5-10 samples first
   - Then test ALL fixtures
   - Report progress every 1000 identifiers

### Common Pitfalls to Avoid

1. ❌ Not capturing rules with `.as(:key)`
2. ❌ Using `type[:short]` instead of `self.class.type[:short]`
3. ❌ Complex nested structures without testing
4. ❌ Assuming parser works without verification

---

## Testing Strategy

### For Each Flavor

1. **Initial Manual Test** (5-10 identifiers)
   ```ruby
   test_cases = [
     'Example 1',
     'Example 2',
     # ...
   ]
   test_cases.each { |test| ... }
   ```

2. **Parser Verification**
   ```ruby
   parsed = Parser.new.parse(test)
   puts parsed.inspect  # Verify structure
   ```

3. **Builder Verification**
   ```ruby
   identifier = Builder.new(Scheme).build(parsed)
   puts identifier.inspect  # Verify components
   ```

4. **Round-trip Test**
   ```ruby
   rendered = identifier.to_s
   puts test == rendered ? '✓' : '~'
   ```

5. **Full Fixture Test**
   ```ruby
   identifiers = File.readlines(fixture_file)
   identifiers.each { |pubid| ... }
   ```

### Success Criteria

- ✅ 95%+ pass rate on fixtures (100% is achievable!)
- ✅ All examples from documentation working
- ✅ RSpec test created
- ✅ Architecture consistent with patterns

---

## File Checklist Template

For each flavor, create these files:

```
lib/pubid_new/{flavor}/
├── identifier.rb              # Base class (always needed)
├── single_identifier.rb       # Main identifier class
├── supplement_identifier.rb   # If supplements exist
├── parser.rb                  # Parslet grammar
├── builder.rb                 # Component builder
├── scheme.rb                  # Type registry
└── identifiers/
    ├── {type1}.rb            # One per document type
    ├── {type2}.rb
    └── ...
```

Plus:
- `lib/pubid_new/{flavor}.rb` - Module file
- `spec/pubid_new/{flavor}/fixtures_spec.rb` - Comprehensive test
- Update `lib/pubid_new.rb` to require the flavor

---

## Reference Files

### Best Reference Implementations

1. **Simple Format:** [`lib/pubid_new/ccsds/`](../lib/pubid_new/ccsds/)
2. **Multi-Type:** [`lib/pubid_new/cen/`](../lib/pubid_new/cen/)
3. **Clean Example:** [`lib/pubid_new/jis/`](../lib/pubid_new/jis/) ⭐
4. **Complex Format:** [`lib/pubid_new/iso/`](../lib/pubid_new/iso/)

### Component Files

- [`lib/pubid_new/components/publisher.rb`](../lib/pubid_new/components/publisher.rb)
- [`lib/pubid_new/components/code.rb`](../lib/pubid_new/components/code.rb)
- [`lib/pubid_new/components/date.rb`](../lib/pubid_new/components/date.rb)
- [`lib/pubid_new/components/typed_stage.rb`](../lib/pubid_new/components/typed_stage.rb)
- [`lib/pubid_new/components/type.rb`](../lib/pubid_new/components/type.rb)
- [`lib/pubid_new/components/stage.rb`](../lib/pubid_new/components/stage.rb)

### Parser Utilities

- [`lib/pubid_new/parser/common_parse_rules.rb`](../lib/pubid_new/parser/common_parse_rules.rb)
- [`lib/pubid_new/parser/common_parse_methods.rb`](../lib/pubid_new/parser/common_parse_methods.rb)

---

## Quick Start for Next Flavor (PLATEAU)

```bash
# 1. Analyze old structure
ls -la gems/pubid-plateau/lib/pubid/plateau/

# 2. Check fixtures
wc -l gems/pubid-plateau/spec/fixtures/*.txt
head -20 gems/pubid-plateau/spec/fixtures/*.txt

# 3. Review old parser
cat gems/pubid-plateau/lib/pubid/plateau/parser.rb

# 4. Start implementation
# (Follow the pattern from JIS)
```

---

## Estimated Timeline to Completion

### Conservative Estimate
- PLATEAU: 2-3 hours
- ETSI: 3-4 hours
- ITU: 4-5 hours
- BSI: 5-6 hours
- NIST: 6-8 hours
- **Total:** 20-26 hours

### Aggressive Estimate
- With established patterns: 12-18 hours
- If formats are simpler than expected

### Current Velocity
- JIS: 1 hour for 100% accuracy on 10,635 identifiers
- Pattern is proven and efficient

---

## Success Metrics

### Per Flavor
- [ ] 95%+ pass rate on fixtures
- [ ] All examples working
- [ ] RSpec test created
- [ ] Documentation updated

### Overall Project
- [ ] All 12 flavors migrated
- [ ] 95%+ average pass rate
- [ ] Comprehensive test suite
- [ ] Clean architecture maintained

---

## Next Session Prompt

```
Continue PubID v2 migration (PR #19, branch: rt-new-lutaml-model)

Current Progress: 6/12 flavors complete (50%)

✅ Completed:
- ISO: 99.52% (7,114 tests)
- IEC: 100%
- IDF: 100%
- CEN: 100% (50 tests)
- CCSDS: 100% (4 tests)
- JIS: 100% (10,635 tests) ⭐ JUST COMPLETED

Next Task: Migrate PLATEAU

PLATEAU Details:
- Location: gems/pubid-plateau/
- Priority: HIGH
- Complexity: LOW-MEDIUM
- Create: lib/pubid_new/plateau/

Steps:
1. Analyze old implementation in gems/pubid-plateau/lib/pubid/plateau/
2. Check fixtures in gems/pubid-plateau/spec/fixtures/
3. Follow JIS migration pattern from lib/pubid_new/jis/
4. Create all necessary files (identifier, parser, builder, scheme)
5. Test with samples then full fixtures
6. Achieve 95%+ pass rate

Reference:
- Best Pattern: lib/pubid_new/jis/ (just completed, 100% accuracy)
- CEN Pattern: lib/pubid_new/cen/ (multi-type example)
- Documentation: docs/CONTINUATION-PLAN-AFTER-JIS.md (this file)

Then: ETSI → ITU → BSI → NIST

Goal: Complete all 12 flavors with 95%+ average accuracy
```

---

## Lessons from JIS Migration

### Technical Insights

1. **Parser Capture Rules Are Critical**
   - Every captured value needs `.as(:key)`
   - Missing captures cause silent failures
   - Test parser output before building

2. **Simple Formats Achieve 100%**
   - JIS: straightforward format → 100% accuracy
   - Clear structure → perfect results
   - No edge cases

3. **Component Builder Simplicity**
   - Direct mapping works best
   - Minimal transformation
   - Clear casting logic

4. **Testing Strategy**
   - Start with 5-10 manual tests
   - Then test ALL fixtures
   - Progress reports every 1000

### Architectural Insights

1. **lutaml-model Scales Perfectly**
   - Handles 10,635 identifiers efficiently
   - Clean attribute definitions
   - Simple serialization

2. **Scheme Registry Pattern Works**
   - TypedStage system is flexible
   - Easy to add new types
   - Clear type resolution

3. **Parser/Builder Separation**
   - Parser: pure syntax
   - Builder: semantic interpretation
   - Clean separation of concerns

---

## Final Validation Plan

Once all 12 flavors complete:

### Step 1: Individual Fixture Tests

Each flavor has `spec/pubid_new/{flavor}/fixtures_spec.rb`

### Step 2: Combined Validation Report

Create `tmp/validate_all_flavors_final.rb`:

```ruby
#!/usr/bin/env ruby
require_relative '../lib/pubid_new'

flavors = {
  iso: { file: 'TODO.TMP.md', count: 7114 },
  jis: { file: 'gems/pubid-jis/spec/fixtures/jis-pubids.txt', count: 10635 },
  iec: { file: 'gems/pubid-iec/spec/fixtures/iec-pubid.txt', count: nil },
  # ... add all others
}

total_tested = 0
total_passed = 0

flavors.each do |name, config|
  identifiers = File.readlines(config[:file]).map(&:strip).reject(&:empty?)
  passed = 0
  
  identifiers.each do |pubid|
    begin
      module_name = "PubidNew::#{name.to_s.capitalize}"
      identifier = Object.const_get(module_name).parse(pubid)
      passed += 1 if pubid == identifier.to_s
    rescue
      # Count as failure
    end
  end
  
  total_tested += identifiers.count
  total_passed += passed
  
  rate = (passed.to_f/identifiers.count*100).round(2)
  puts "#{name.upcase}: #{passed}/#{identifiers.count} (#{rate}%)"
end

puts
puts "="*60
overall_rate = (total_passed.to_f/total_tested*100).round(2)
puts "OVERALL: #{total_passed}/#{total_tested} (#{overall_rate}%)"
puts "="*60
```

### Step 3: Final Report

Generate comprehensive report with:
- Pass rates per flavor
- Overall statistics
- Performance metrics
- Known issues/limitations

---

## Git Workflow

### Current Branch

```bash
git status
# On branch rt-new-lutaml-model
# PR #19
```

### Before Each Session
```bash
git pull origin rt-new-lutaml-model
```

### After Each Flavor
```bash
git add lib/pubid_new/{flavor}/
git add spec/pubid_new/{flavor}/
git add docs/SESSION-*.md
git commit -m "feat(pubid): migrate {FLAVOR} to PubID v2, {pass_rate}% accuracy"
```

### Do Not Push
Commits will be pushed manually.

---

## Resources

### Documentation
- [`docs/NEXT-SESSION-CONTINUATION.md`](../docs/NEXT-SESSION-CONTINUATION.md) - Overall plan
- [`docs/SESSION-2025-11-16-JIS-MIGRATION.md`](../docs/SESSION-2025-11-16-JIS-MIGRATION.md) - JIS details
- [`docs/CONTINUATION-PLAN-AFTER-JIS.md`](../docs/CONTINUATION-PLAN-AFTER-JIS.md) - This file

### Code References
- Current implementations: `lib/pubid_new/{iso,iec,idf,cen,ccsds,jis}/`
- Old implementations: `gems/pubid-{flavor}/lib/pubid/{flavor}/`
- Components: `lib/pubid_new/components/`

### Test Fixtures
- ISO: [`TODO.TMP.md`](../TODO.TMP.md) (7,114 identifiers)
- JIS: [`gems/pubid-jis/spec/fixtures/jis-pubids.txt`](../gems/pubid-jis/spec/fixtures/jis-pubids.txt) (10,635 identifiers)
- IEC: [`gems/pubid-iec/spec/fixtures/`](../gems/pubid-iec/spec/fixtures/) (multiple files)
- Others: Check respective `gems/pubid-{flavor}/spec/fixtures/` directories

---

**Ready for PLATEAU migration** 🚀

*Estimated completion of all flavors: 15-25 hours from this point*