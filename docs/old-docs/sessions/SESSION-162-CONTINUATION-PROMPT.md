# Session 162 Continuation Prompt: PackageIdentifier Implementation

**Read this FIRST:** [`docs/SESSION-162-CONTINUATION-PLAN.md`](SESSION-162-CONTINUATION-PLAN.md:1)

---

## Quick Context

**Session 161 Complete:** CsaAdoptedIdentifier wrapper (6/6 tests, 100%) ✅
**Session 162 Goal:** PackageIdentifier for CSA packages with materials
**Timeline:** 120 minutes
**Expected Gain:** +20-30 identifiers

---

## Key Pattern

**Package Identifiers:** `CSA {base} PACKAGE {materials}`

Examples:
- `CSA Z662:23 PACKAGE INCLUDES: +1 (PDF & ESA)`
- `CSA B149.1:20 PACKAGE (PDF + PRINT)`
- `CSA C22.2 NO. 60601-1:15 PACKAGE WITH ADDENDUM`

---

## Implementation Tasks (120 min)

### Part A: Create CompositeIdentifier Base (40 min)

**File:** `lib/pubid_new/csa/composite_identifier.rb`

```ruby
class CompositeIdentifier < Lutaml::Model::Serializable
  attr_accessor :base_identifier

  def to_s
    raise NotImplementedError, "Subclasses must implement"
  end
end
```

### Part B: Create PackageIdentifier (50 min)

**File:** `lib/pubid_new/csa/identifiers/package.rb`

```ruby
class Package < CompositeIdentifier
  attribute :package_materials, :string
  attribute :package_keyword, :string

  def to_s
    "#{base_identifier} PACKAGE #{package_materials}"
  end
end
```

### Part C: Update Identifier.parse (25 min)

**File:** `lib/pubid_new/csa/identifier.rb`

Add after CSA adoption detection:

```ruby
if input.match?(/\sPACKAGE\s/i)
  parts = input.split(/\s+PACKAGE\s+/i, 2)
  base_identifier = parse(parts[0])

  result = Identifiers::Package.new
  result.base_identifier = base_identifier
  result.package_materials = parts[1]
  return result
end
```

### Part D: Update Requires (5 min)

**File:** `lib/pubid_new/csa.rb`

Add:
```ruby
require_relative "csa/composite_identifier"
require_relative "csa/identifiers/package"
```

---

## Critical Points

1. **Composite Pattern:** Base class for collections
2. **Recursive Parsing:** Base identifier fully parsed
3. **Materials as Metadata:** Not separate identifiers
4. **MECE:** Package ≠ Bundled (different semantics)
5. **Extensibility:** Easy to add new composite types

---

## Success Criteria

- ✅ 3+ patterns with perfect round-trip
- ✅ Base identifier correctly parsed
- ✅ Package materials preserved
- ✅ Clean object composition
- ✅ No string manipulation

---

## Quick Test

```bash
cd /Users/mulgogi/src/mn/pubid && ruby -e "
require_relative 'lib/pubid_new/csa'

['CSA Z662:23 PACKAGE INCLUDES: +1 (PDF & ESA)',
 'CSA B149.1:20 PACKAGE (PDF + PRINT)'].each do |p|
  r = PubidNew::Csa::Identifier.parse(p)
  puts r ? \"✓ #{p}\" : \"✗ #{p}\"
end
"
```

---

**Next After Session 162:** SeriesIdentifier (Session 163, 60 min)

**GO!** 🚀