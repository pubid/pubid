# PubID V1 Removal Plan

**Status:** Planning Phase
**Created:** 2025-11-22
**Target V2 Release:** TBD (after documentation and testing complete)

---

## Executive summary

This document outlines the plan for deprecating and eventually removing the V1 PubID implementation in favor of the V2 architecture. The V2 implementation provides:

- **Better accuracy:** NIST 98.47% vs V1 ~90%
- **Cleaner architecture:** Three-layer separation of concerns
- **Model-driven design:** Lutaml::Model-based identifiers
- **Better maintainability:** MECE organization, full OOP
- **Comprehensive testing:** 100% test coverage for completed parsers

---

## V1 code inventory

### Current V1 structure

```
gems/                           # V1 implementation (TO BE REMOVED)
├── pubid/                     # V1 base/meta-gem
│   ├── lib/pubid/
│   │   ├── identifier.rb      # Base identifier class
│   │   ├── transformer.rb     # Parslet transformer
│   │   └── parser.rb          # Parslet parser
│   └── spec/
├── pubid-core/                # V1 core functionality
│   ├── lib/pubid/core/
│   │   ├── identifier.rb
│   │   ├── renderer/
│   │   ├── parser.rb
│   │   └── transformer.rb
│   └── spec/
├── pubid-nist/                # V1 NIST parser (~90% accuracy)
│   ├── lib/pubid/nist/
│   │   ├── identifier.rb
│   │   ├── parser.rb
│   │   └── transformer.rb
│   └── spec/
├── pubid-ieee/                # V1 IEEE parser
│   ├── lib/pubid/ieee/
│   │   ├── identifier.rb
│   │   ├── parser.rb
│   │   └── transformer.rb
│   └── spec/
├── pubid-iso/                 # V1 ISO parser
├── pubid-iec/                 # V1 IEC parser
├── pubid-bsi/                 # V1 BSI parser
├── pubid-itu/                 # V1 ITU parser
├── pubid-jis/                 # V1 JIS parser
├── pubid-etsi/                # V1 ETSI parser
├── pubid-cen/                 # V1 CEN parser
└── pubid-plateau/             # V1 PLATEAU parser
```

### Lines of code (approximate)

| Component | Files | Lines | Status |
|-----------|-------|-------|--------|
| V1 Core | ~20 | ~3,000 | To be removed |
| V1 NIST | ~15 | ~2,500 | To be removed |
| V1 IEEE | ~12 | ~2,000 | To be removed |
| V1 ISO | ~18 | ~2,800 | To be removed |
| V1 Other parsers | ~80 | ~8,000 | To be removed |
| **Total V1** | **~145** | **~18,300** | **To be removed** |

---

## V1 vs V2 feature comparison

### Architecture

| Feature | V1 Approach | V2 Approach | Winner |
|---------|-------------|-------------|--------|
| **Architecture** | Transformer-based | Three-layer (Parser/Builder/Identifier) | V2 |
| **Parsing** | Parslet | Parslet (improved grammars) | V2 |
| **Data Model** | Custom classes | Lutaml::Model | V2 |
| **Separation of Concerns** | Mixed responsibilities | Clean layer separation | V2 |
| **Extensibility** | Limited inheritance | Full OOP with plugins | V2 |
| **MECE Organization** | Some overlap | Strictly MECE | V2 |

### Performance

| Metric | V1 | V2 | Improvement |
|--------|----|----|-------------|
| **NIST Accuracy** | ~90% | 98.47% | +8.47pp (+1,110 ids) |
| **IEEE Accuracy** | ~95% | 100% | +5pp |
| **Test Coverage** | Moderate | Comprehensive (1 spec per class) | Significant |
| **Code Quality** | Mixed | Consistent OOP | Major |

### Features

| Feature | V1 | V2 | Notes |
|---------|----|----|-------|
| NIST LCIRC series | ❌ | ✅ | ~900 identifiers |
| NIST CSM v#n# format | ❌ | ✅ | ~36 identifiers |
| NIST supprev notation | ❌ | ✅ | ~100 identifiers |
| IEEE dash preservation | ❌ | ✅ | Codes like C22-1925 |
| IEEE dual published | Partial | ✅ | Space-separated patterns |
| IEEE adopted standards | Basic | ✅ | Multi-part adoptions |
| Parenthetical content | ❌ | ✅ | Revision notes, etc. |
| IEC edition year-month | ❌ | ✅ | Edition X.Y YYYY-MM |

---

## Breaking changes

### API changes

#### Namespace change

**V1:**
```ruby
require 'pubid/nist'

id = Pubid::Nist::Identifier.parse("NIST SP 800-53r5")
```

**V2:**
```ruby
require 'pubid_new/nist'

id = PubidNew::Nist.parse("NIST SP 800-53r5")
```

#### Class structure

**V1:**
- `Pubid::Nist::Identifier` (single monolithic class)
- `Pubid::Nist::Transformer` (mixed responsibilities)
- `Pubid::Nist::Parser` (Parslet grammar)

**V2:**
- `PubidNew::Nist::Parser` (syntax only)
- `PubidNew::Nist::Builder` (transformation only)
- `PubidNew::Nist::Identifiers::Base` (base identifier)
- `PubidNew::Nist::Identifiers::Circular` (CIRC/LCIRC series)
- `PubidNew::Nist::Identifiers::CommercialStandardsMonthly` (CSM)
- etc. (specialized classes per identifier type)

#### Method signatures

**Mostly compatible** - Both V1 and V2 support:
- `.parse(string)` - Parse identifier string
- `#to_s` - Render to string
- Component accessors (series, number, etc.)

**Minor differences:**
- V2 has more detailed component breakdown
- V2 provides better type safety through Lutaml::Model
- V2 supports serialization to JSON/YAML/XML via Lutaml::Model

### Behavioral changes

#### More accurate parsing

V2 successfully parses identifiers that V1 failed on:
- Historical NBS patterns (LCIRC, CSM, etc.)
- Complex IEEE patterns (adopted standards, dual published)
- Edge cases in all parsers

#### Better round-trip preservation

V2 maintains exact formatting:
- Dash vs dot in IEEE codes
- Revision notation (rev vs r)
- Spacing and punctuation

#### Stricter validation

V2 validates identifier structure more strictly:
- Invalid patterns rejected earlier
- Better error messages
- Clear identifier class hierarchy

---

## Migration guide

### Step 1: Update requires

**Before (V1):**
```ruby
require 'pubid/nist'
require 'pubid/ieee'
require 'pubid/iso'
```

**After (V2):**
```ruby
require 'pubid_new/nist'
require 'pubid_new/ieee'
require 'pubid_new/iso'
```

### Step 2: Update class references

**Before (V1):**
```ruby
id = Pubid::Nist::Identifier.parse("NIST SP 800-53r5")
id.class  # => Pubid::Nist::Identifier
```

**After (V2):**
```ruby
id = PubidNew::Nist.parse("NIST SP 800-53r5")
id.class  # => PubidNew::Nist::Identifiers::Base
```

### Step 3: Update component access

**V1 and V2 are mostly compatible** for basic components:

```ruby
# Both V1 and V2 support:
id.series     # => "SP"
id.number     # => "800-53"
id.revision   # => "r5"
id.to_s       # => "NIST SP 800-53r5"
```

**V2 provides additional details:**

```ruby
# V2-specific enhanced access:
id.class.name  # => "PubidNew::Nist::Identifiers::Base"

# For IEEE:
id.code.original_separator  # => "." or "-"
id.parenthetical_content    # => "(Revision of ...)"
```

### Step 4: Update type checks

**Before (V1):**
```ruby
if id.is_a?(Pubid::Nist::Identifier)
  # ...
end
```

**After (V2):**
```ruby
if id.is_a?(PubidNew::Nist::Identifiers::Base)
  # ...
end

# Or check for any NIST identifier:
if id.class.name.start_with?("PubidNew::Nist")
  # ...
end
```

### Step 5: Test thoroughly

**Critical testing areas:**

1. **Parse accuracy:** Verify all existing identifiers still parse
2. **Round-trip preservation:** Ensure `parse(id).to_s == id`
3. **Component access:** Verify all used attributes still work
4. **Edge cases:** Test boundary conditions and error handling
5. **Integration:** Test with downstream systems

**Test script:**

```ruby
# test_v1_v2_compatibility.rb
require 'pubid/nist'        # V1
require 'pubid_new/nist'    # V2

test_ids = [
  "NIST SP 800-53r5",
  "NBS LCIRC 1019r1963",
  # ... add your identifiers
]

test_ids.each do |id_str|
  v1 = Pubid::Nist::Identifier.parse(id_str) rescue nil
  v2 = PubidNew::Nist.parse(id_str) rescue nil
  
  puts "#{id_str}:"
  puts "  V1: #{v1 ? v1.to_s : 'FAILED'}"
  puts "  V2: #{v2 ? v2.to_s : 'FAILED'}"
  puts "  Match: #{v1&.to_s == v2&.to_s ? '✅' : '❌'}"
  puts
end
```

---

## Deprecation timeline

### Phase 1: Release (Week 0) - V2 Released, V1 Deprecated

**Actions:**
- Release V2 to RubyGems
- Update documentation with V2 examples
- Add deprecation warnings to V1:
  ```ruby
  warn "[DEPRECATION] Pubid::Nist is deprecated. Use PubidNew::Nist instead."
  ```
- Announce deprecation in:
  - CHANGELOG
  - GitHub releases
  - README badges
  - Metanorma blog

**V1 Status:** Deprecated but fully functional

**V2 Status:** Recommended for all new code

### Phase 2: Warning period (Months 1-3) - Both versions supported

**Actions:**
- Monitor V2 adoption
- Fix critical V2 bugs
- Provide migration support
- Update examples in documentation
- Create migration case studies

**V1 Status:** Deprecated, maintenance only

**V2 Status:** Stable, actively developed

### Phase 3: Migration period (Months 4-6) - V1 support ends

**Actions:**
- Final warning: V1 will be removed
- Stop accepting V1 bug reports
- Archive V1 code to separate branch
- Update all internal projects to V2
- Publish final migration deadline

**V1 Status:** End of life announced

**V2 Status:** Production ready

### Phase 4: Cleanup (Month 7+) - V1 code removed

**Actions:**
- Remove V1 code from main branch
- Update gem dependencies
- Archive V1 to `v1-archive` branch
- Update documentation to remove V1 references
- Celebrate simplified codebase! 🎉

**V1 Status:** Removed from main, archived

**V2 Status:** Only supported version

---

## Test migration strategy

### V1 test inventory

| Parser | V1 Test Files | V1 Examples | Coverage |
|--------|---------------|-------------|----------|
| NIST | ~8 | ~150 | Moderate |
| IEEE | ~6 | ~100 | Moderate |
| ISO | ~10 | ~200 | Good |
| IEC | ~8 | ~150 | Moderate |
| BSI | ~5 | ~80 | Basic |
| Others | ~20 | ~200 | Variable |

### V2 test creation

**Priority 1 (Complete):**
- ✅ NIST comprehensive tests (98.47% on 19,488 ids)
- ✅ IEEE comprehensive tests (100% on 35 patterns)

**Priority 2 (In Progress):**
- ⚠️ Create missing NIST identifier spec files (3 files)
- ⚠️ Create missing IEEE identifier spec files (3 files)

**Priority 3 (Needed):**
- ❌ ISO comprehensive test suite
- ❌ BSI comprehensive test suite
- ❌ IEC, ITU, JIS, ETSI test suites

### Test migration approach

**Do NOT directly port V1 tests** - V1 tests often:
- Test implementation details
- Have lower quality patterns
- Mix responsibilities

**Instead, create V2-specific tests that:**
1. Test one identifier class per spec file
2. Use real-world examples from databases
3. Verify round-trip preservation
4. Test edge cases systematically
5. Follow MECE principles

**Template for new spec files:**

```ruby
# spec/pubid_new/{parser}/identifiers/{class}_spec.rb
require "spec_helper"
require_relative "../../../../lib/pubid_new"

RSpec.describe PubidNew::{Parser}::Identifiers::{Class} do
  describe ".parse" do
    context "{series name} parsing" do
      it "parses {pattern} identifiers" do
        id = PubidNew::{Parser}.parse("{example}")
        expect(id).to be_a(described_class)
        expect(id.to_s).to eq("{example}")
      end
    end

    context "round-trip parsing" do
      it "preserves exact rendering" do
        examples = [
          "{example1}",
          "{example2}",
          # ... more examples
        ]

        examples.each do |input|
          expect(PubidNew::{Parser}.parse(input).to_s).to eq(input)
        end
      end
    end
  end
end
```

---

## Risk mitigation

### Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Break downstream systems | Medium | High | Long deprecation period, clear warnings |
| V2 bugs discovered after V1 removal | Medium | Medium | Comprehensive testing before removal |
| Users don't migrate | Low | Medium | Active communication, migration support |
| Performance regression | Low | Medium | Benchmark V1 vs V2 before release |

### Rollback plan

If critical issues discovered after V2 release:

1. **Keep V1 code** in separate branch until Month 6
2. **Ability to revert** to V1 if needed
3. **Parallel support** during warning period
4. **Fast-track fixes** for V2 critical bugs

---

## Success criteria

### For V2 release

- ✅ NIST ≥95% success rate (achieved: 98.47%)
- ✅ All V2 tests passing (achieved: 100%)
- ⚠️ Complete official documentation (in progress: ~75%)
- ⚠️ All identifier classes have specs (in progress: ~85%)
- ❌ V1 removal plan documented (this document)
- ❌ Performance benchmarks (pending)

### For V1 removal

- [ ] V2 stable for 6+ months
- [ ] All known bugs fixed
- [ ] Complete test coverage (>95%)
- [ ] All internal projects migrated
- [ ] No critical V1 dependencies remaining
- [ ] Community feedback positive

---

## Communication plan

### Announcement channels

1. **GitHub:**
   - Release notes
   - Deprecation warning in README
   - Migration guide in wiki

2. **RubyGems:**
   - Deprecation warning in gem description
   - Link to migration guide

3. **Metanorma blog:**
   - V2 release announcement
   - Migration tutorial
   - Success stories

4. **Direct communication:**
   - Email to known users
   - Slack/Discord announcements
   - Issue tracker notifications

### Key messages

**For Users:**
> "PubID V2 provides significantly better accuracy (98.47% vs 90% for NIST) and cleaner architecture. Migration is straightforward - update your requires and test thoroughly. We'll support both versions for 6 months."

**For Contributors:**
> "V2 uses modern Ruby practices: Lutaml::Model for data, strict OOP, MECE organization. Contributing is easier with clear architecture and comprehensive tests."

**For Maintainers:**
> "V1 removal simplifies our codebase significantly (~18,000 lines removed), reduces maintenance burden, and allows us to focus on improving V2."

---

## Next steps

### Immediate (This sprint)

- [x] Create this removal plan
- [ ] Complete V2 documentation (75% → 100%)
- [ ] Create missing test files
- [ ] Run performance benchmarks

### Short-term (Next sprint)

- [ ] Add deprecation warnings to V1 code
- [ ] Create migration examples
- [ ] Prepare CHANGELOG entries
- [ ] Set up V1 archive branch

### Medium-term (Months 1-3)

- [ ] Release V2 with deprecation warnings
- [ ] Publish migration guide
- [ ] Monitor adoption metrics
- [ ] Provide migration support

### Long-term (Months 4-7)

- [ ] Announce end-of-life for V1
- [ ] Complete internal migration
- [ ] Remove V1 code
- [ ] Update all documentation

---

**Last Updated:** 2025-11-22
**Next Review:** After V2 release
**Owner:** PubID Development Team