# Next Session Continuation Prompt

## Quick Start

Use this prompt to continue PubID v2 work:

---

**Continue PubID v2 implementation (PR #19) on branch `rt-new-lutaml-model`**

**Previous Session Completed (2025-11-15):**
- ✅ Debug output cleanup (4 files)
- ✅ ISO Directives handling (114/114 tests passing)
- ✅ ISO Directives Supplement parsing (87/97 tests, 85% improvement)
- ✅ SAE copublisher support verified
- ✅ **Combined bundle operator (`+`) IMPLEMENTED** - New [`BundledIdentifier`](../lib/pubid_new/bundled_identifier.rb) class

**Three Operators:**
- ✅ `/` (supplement) via [`SupplementIdentifier`](../lib/pubid_new/iso/supplement_identifier.rb)
- ✅ `|` (dual-published) via [`CombinedIdentifier`](../lib/pubid_new/iso/combined_identifier.rb)
- ✅ `+` (combined bundle) via [`BundledIdentifier`](../lib/pubid_new/bundled_identifier.rb)

**Current ISO Flavor Status:** ~99% complete
- Only 10 DirectivesSupplement edge case failures remain

**Immediate Next Tasks:**

1. **Migrate CEN flavor to v2** - Create `lib/pubid_new/cen/`
   - Reference: Old CEN in `gems/pubid-cen/lib/pubid/cen/`
   - Pattern: Follow ISO/IDF structure
   - Use new `BundledIdentifier` for EN identifiers like `EN 10077-1:2006+AC:2009+AC2:2009`

2. **Run validation tests** - Measure implementation quality
   - 7,171 ISO identifiers in [`TODO.TMP.md`](../TODO.TMP.md)
   - 147 corrigendum cases in [`TODO.TMP2.md`](../TODO.TMP2.md)

**Reference Docs:**
- [`docs/session-2025-11-15-progress.md`](session-2025-11-15-progress.md) - This session's work
- [`docs/pubid-v2-continuation-plan.md`](pubid-v2-continuation-plan.md) - Overall plan
- [`docs/CONTINUATION-PROMPT.md`](CONTINUATION-PROMPT.md) - Original prompts

**Testing:**
```bash
# Directives tests
bundle exec rspec spec/pubid_new/iso/identifiers/directives_spec.rb

# Bundled identifier test
ruby tmp/test_bundled.rb

# All ISO tests
bundle exec rspec spec/pubid_new/iso/
```

Which task should we tackle first?

---

## Alternative Prompts

### Migrate CEN Flavor 

```
Migrate CEN (European standards) flavor to PubID v2 architecture.

Current old architecture: gems/pubid-cen/lib/pubid/cen/
New v2 location: lib/pubid_new/cen/

Reference implementations:
- ISO: lib/pubid_new/iso/ (most complete)
- IDF: lib/pubid_new/idf/ (simplest)

Key CEN features to migrate:
1. EuropeanNorm identifier (EN)
2. CEN Workshop Agreement (CWA)
3. Technical Specification (TS)
4. Technical Report (TR)
5. Amendment and Corrigendum supplements
6. Use new BundledIdentifier for combined bundles

Example identifiers:
- EN 10077-1:2006
- EN 10077-1:2006+AC:2009+AC2:2009 (combined bundle)
- prEN 15316-1:2020
- CWA 17145-2:2017

Note: Old CEN has CombinedBundle class that we've now replaced with 
the general BundledIdentifier class.

Follow the lutaml-model pattern with:
- attribute declarations (not attr_accessor)
- Components for typed data
- Scheme-based type registry
- Parser/Builder separation
```

### Run Validation Tests

```
Run validation tests for PubID v2 ISO implementation.

Test against:
1. TODO.TMP.md - 7,171 ISO identifier test cases
2. TODO.TMP2.md - 147 corrigendum test cases

For each identifier:
- Parse using PubidNew::Iso::Parser
- Build using PubidNew::Iso::Builder
- Render with .to_s
- Compare with original
- Record pass/fail

Create a report showing:
- Total identifiers tested
- Successful parses
- Failed parses (with examples)
- Round-trip mismatches
- Pass rate percentage

Working directory: /Users/mulgogi/src/mn/pubid
Branch: rt-new-lutaml-model
```

### Fix Remaining DirectivesSupplement Edge Case

```
Fix the remaining 10 DirectivesSupplement test failures in PubID v2.

All failures are from: "ISO/IEC Directives, Part 1 -- Consolidated ISO Supplement"

This is a rare historical format with:
- "Directives," (with comma)
- "Part" spelled out  
- "-- Consolidated" prefix
- Full "Supplement" word

Current parser doesn't handle this format. Add parsing rules to:
lib/pubid_new/iso/parser.rb

Reference existing directives parsing for patterns.

Test file: spec/pubid_new/iso/identifiers/directives_supplement_spec.rb:382
```

## Command Reference

### Git
```bash
# Current branch
git branch  # Should show: rt-new-lutaml-model

# View changes
git status
git diff

# Commit work
git add .
git commit -m "feat(pubid-v2): implement combined bundle operator (+)"
```

### Testing
```bash
# ISO Directives
bundle exec rspec spec/pubid_new/iso/identifiers/directives_spec.rb

# ISO Directives Supplements  
bundle exec rspec spec/pubid_new/iso/identifiers/directives_supplement_spec.rb

# All ISO
bundle exec rspec spec/pubid_new/iso/

# All v2
bundle exec rspec spec/pubid_new/

# Interactive console
bundle exec bin/console
```

### Code Quality
```bash
# Run rubocop
bundle exec rubocop lib/pubid_new/

# Auto-fix
bundle exec rubocop -A lib/pubid_new/
```

## Key Implementation Patterns

### Creating a New Identifier Type

1. **Create identifier class** (inherit from S ingleIdentifier or SupplementIdentifier):
```ruby
class MyType < SingleIdentifier
  attribute :type, Components::Type, default: -> { type[:key] }
  
  TYPED_STAGES = [
    Components::TypedStage.new(
      code: :pubmytype,
      stage_code: :published,
      type_code: :mytype,
      abbr: ["MT", "MyType"],
      name: "My Type",
      harmonized_stages: %w[60.00 60.60],
    ),
  ].freeze
  
  def self.type
    { key: :mytype, title: "My Type", short: "MT" }
  end
end
```

2. **Add to scheme** in flavor module file:
```ruby
IDENTIFIER_TYPES = [
  Identifiers::MyType,
  # ...
].freeze

Scheme = PubidNew::Scheme.new(
  identifiers: IDENTIFIER_TYPES,
  supplement_identifiers: SUPPLEMENT_IDENTIFIER_TYPES,
)
```

3. **Add parser rule**:
```parslet
TYPED_STAGES = Scheme.typed_stages.map(&:abbr).flatten.sort_by(&:length).reverse

rule(:type_with_stage) do
  array_to_str(TYPED_STAGES).as(:type_with_stage)
end
```

4. **Builder automatically handles it** via scheme lookup

### Using the Three Operators

**Supplement (`/`):**
```ruby
# ISO 8601-1:2019/Amd 1:2024
PubidNew::Iso::SupplementIdentifier
  base_identifier: ISO 8601-1:2019
  typed_stage: AMD
  number, date, etc.
```

**Dual-Published (`|`):**
```ruby
# ISO 4214:2022 | IDF 254:2022
PubidNew::Iso::CombinedIdentifier
  base_identifier: ISO 4214:2022
  additional_identifiers: [IDF 254:2022]
```

**Combined Bundle (`+`):**
```ruby
# ISO/IEC DIR 1 + IEC SUP:2016-05
PubidNew::BundledIdentifier
  base_document: ISO/IEC DIR 1
  supplements: [IEC SUP:2016-05]
```

---

*Ready for next development session*
*All three operators now functional!*