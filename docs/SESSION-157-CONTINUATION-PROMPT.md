# Session 157 Quick Start: CSA Combined Identifiers Fix

**Read First:** [`docs/SESSION-157-CONTINUATION-PLAN.md`](SESSION-157-CONTINUATION-PLAN.md:1) (comprehensive plan)

---

## CRITICAL Context from Session 156

✅ **Bundled Identifier Fix COMPLETE and CORRECT**
- Semantically correct: `+` = BundledIdentifier, `/` = Combined
- Round-trip perfect: 3/3 tests passing
- Architecture: MODEL-DRIVEN, MECE maintained

❌ **Regression NOT from bundled fix** - Pre-existing bugs exposed:
1. **Combined identifiers** - Builder incomplete (HIGHEST IMPACT: ~250 IDs)
2. Package portions - Not rendered
3. M/F prefixes - Lost in output
4. Missing CSA prefix - Some legacy formats

**Current:** 185/899 (20.58%)
**Baseline:** 471/936 (50.32%) from Session 154
**Target:** 385-435/899 (43-48%) after fixing combined identifiers

---

## Session 157 Tasks (90 minutes)

### Task 1: Create CombinedIdentifier Class (30 min)

**File:** `lib/pubid_new/csa/identifiers/combined.rb`

```ruby
# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Csa
    module Identifiers
      class Combined < Lutaml::Model::Serializable
        attribute :first, Standard
        attribute :second, Standard
        attribute :third, Standard
        attribute :reaffirmation, :string
        attribute :package, :string

        def to_s
          parts = [first.to_s, second.to_s]
          parts << third.to_s if third

          result = parts.join("/")
          result += " (R#{reaffirmation})" if reaffirmation
          result += " #{package}" if package
          result
        end
      end
    end
  end
end
```

### Task 2: Fix Builder (30 min)

**File:** `lib/pubid_new/csa/builder.rb`

**Add require:**
```ruby
require_relative "identifiers/combined"
```

**Replace the TODO section (lines 15-18):**
```ruby
def build(parsed_hash)
  # Handle bundled identifiers (with + notation)
  if parsed_hash.key?(:bundled_first)
    return build_bundled(parsed_hash)
  end

  # Handle combined identifiers (with / notation)
  if parsed_hash[:first] && parsed_hash[:second]
    return build_combined(parsed_hash)
  end

  build_single(parsed_hash)
end

# Add after build_bundled method:
def build_combined(parsed_hash)
  combined = Identifiers::Combined.new

  # Build each part
  combined.first = build_single(parsed_hash[:first])
  combined.second = build_single(parsed_hash[:second])
  combined.third = build_single(parsed_hash[:third]) if parsed_hash[:third]

  # Handle reaffirmation
  if parsed_hash[:reaffirmation]
    combined.reaffirmation = parsed_hash[:reaffirmation].to_s
  end

  # Handle package portion if present
  if parsed_hash[:package_portion]
    combined.package = parsed_hash[:package_portion].to_s
  end

  combined
end
```

### Task 3: Test and Validate (30 min)

**Create test script:**
```ruby
require_relative '/Users/mulgogi/src/mn/pubid/lib/pubid_new/csa'

tests = [
  "CSA A23.1:24/CSA A23.2:24",
  "CSA N285.0:23/CSA N285.6 SERIES:23",
  "CSA A123.1-05/A123.5-05 (R2015)",
  "CSA B44:19/B44.1:19/B44.2:19"  # Triple
]

tests.each do |input|
  result = PubidNew::Csa::Identifier.parse(input)
  match = (result.to_s == input) ? "✓" : "✗"
  puts "#{match} #{input}"
  puts "  Output: #{result.to_s}" if result
  puts "  Class: #{result.class}" if result
end
```

**Then run full validation:**
```bash
ruby /tmp/count_csa_proper.rb
```

**Expected:** 385-435/899 (43-48%)

---

## Success Criteria

- ✅ CombinedIdentifier class created
- ✅ Builder build_combined method working
- ✅ Manual tests passing (4/4)
- ✅ Classification: 43-48% (gain +200-250 IDs)
- ✅ Architecture: MODEL-DRIVEN maintained

---

## Key Points

1. **Don't question bundled fix** - It was semantically correct
2. **Combined ≠ Bundled** - Different semantic meaning
3. **Focus on builder** - Parser already works
4. **Test incrementally** - After each change
5. **Round-trip fidelity** - Must preserve exact format

---

**Next:** Session 158 will add Package + M/F prefix support (60 min, +30-40 IDs)