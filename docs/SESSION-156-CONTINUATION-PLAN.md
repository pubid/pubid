# Session 156+ Continuation Plan: CSA Bundled Identifiers & Path to 100%

**Created:** 2025-12-16 (Post-Session 155)
**Status:** API at 100%, CSA at 56.94% with semantic error to fix
**Timeline:** COMPRESSED - Complete CSA in 2-3 sessions (4-6 hours)

---

## CRITICAL: Session 155 Semantic Error

**ISSUE:** ❌ Converting `+` notation to `/` notation loses semantic meaning

**Wrong approach (Session 155):**
```ruby
# INCORRECT - loses semantic distinction
normalized = normalized.gsub(" + ", "/")
```

**Correct semantics:**
- `CSA C22.2 NO. 60601-1:14 + A2:22 (R2022)` = **BUNDLED IDENTIFIER**
  - Base: `CSA C22.2 NO. 60601-1:14`
  - Bundled with: `A2:22` (amendment, base implied)
  - Reaffirmed: 2022
  - Meaning: Document includes the amendment in consolidated form

- `CSA C22.2 NO. 60601-1:14/A2:22 (R2022)` = **BASE WITH AMENDMENT**
  - Different meaning - just a reference to amendment

**Must fix:** Revert `+` preprocessing and create proper BundledIdentifier class

---

## Session 156 Immediate Tasks

### Part A: Revert + Notation Preprocessing (15 min)

**File:** `lib/pubid_new/csa/parser.rb`

Remove the line:
```ruby
normalized = normalized.gsub(" + ", "/")  # REMOVE THIS
```

**Test impact:**
```bash
ruby /tmp/count_csa.rb  # Expect ~527/936 (56.3%)
```

### Part B: Create Bundled Identifier Architecture (90 min)

**1. Create BundledIdentifier class (30 min)**

File: `lib/pubid_new/csa/identifiers/bundled.rb`

```ruby
module PubidNew
  module Csa
    module Identifiers
      class Bundled < Identifier
        attribute :base, Identifier
        attribute :bundled_with, Identifier, collection: true
        attribute :reaffirmed, :string

        def to_s
          parts = [base.to_s]
          parts += bundled_with.map(&:to_s)
          result = parts.join(" + ")
          result += " (R#{reaffirmed})" if reaffirmed
          result
        end
      end
    end
  end
end
```

**2. Add bundled pattern to parser (40 min)**

File: `lib/pubid_new/csa/parser.rb`

```ruby
rule(:plus) { str(" + ") }

# Bundled portion - codes that follow + (implied base)
rule(:bundled_portion) do
  # Just the amendment/supplement notation (e.g., "A2:22")
  str("A") >> digits.as(:amendment_number) >>
  (colon >> year_2digit.as(:amendment_year)).maybe
end

# Bundled identifier with + notation
rule(:bundled_identifier) do
  csa_code.as(:base) >>
  (plus >> bundled_portion.as(:bundled)).repeat(1) >>
  reaffirmation.maybe
end

# Main identifier - add bundled_identifier
rule(:identifier) do
  iso_iec_adoption | bundled_identifier | combined_slash | combined_comma | single_identifier
end
```

**3. Update builder (20 min)**

File: `lib/pubid_new/csa/builder.rb`

```ruby
def build(parsed_hash)
  # Check for bundled identifier
  if parsed_hash[:bundled]
    return build_bundled(parsed_hash)
  end

  # ... existing logic
end

def build_bundled(parsed_hash)
  bundled = Identifiers::Bundled.new
  bundled.base = build(parsed_hash[:base])

  # Build bundled amendments (base is implied)
  bundled.bundled_with = Array(parsed_hash[:bundled]).map do |b|
    # Create amendment with implied base
    # ... build amendment from bundled portion
  end

  bundled.reaffirmed = parsed_hash[:reaffirmation] if parsed_hash[:reaffirmation]
  bundled
end
```

**Expected gain:** +100 identifiers (56.3% → 66.9%)

---

## Remaining CSA Patterns (After Bundled Fix)

### Priority Patterns (~303 IDs remaining)

1. **Amendment after reaffirmation** (~50 IDs)
   - Pattern: `(R2023)/A2:24`
   - Need to handle `/A` after reaffirmation

2. **PACKAGE keyword** (~10 IDs)
   - Pattern: `Code Package`, `Training Package`
   - Need package notation support

3. **2-digit reaffirmation** (~5 IDs)
   - Pattern: `(R98)`, `(R22)`
   - Need 2-digit year support

4. **Other complex patterns** (~238 IDs)
   - Various edge cases to analyze

---

## Timeline

| Session | Focus | Duration | Target |
|---------|-------|----------|--------|
| 156 | Fix bundled + revert error | 120 min | 66.9% |
| 157 | Amendment after reaffirmation + PACKAGE | 90 min | 73.3% |
| 158 | Remaining patterns analysis & implementation | 120 min | 85%+ |
| 159 | Final polish to 100% | 60 min | 100% |

**Total:** 6.5 hours compressed timeline

---

## Success Criteria

### Session 156
- ✅ + notation preprocessing REVERTED
- ✅ BundledIdentifier class created
- ✅ Bundled pattern parsing
- ✅ CSA at 66%+ (target 66.9%)
- ✅ Semantic correctness maintained

### Overall CSA
- ✅ 936/936 (100%)
- ✅ All patterns MODEL-DRIVEN
- ✅ Proper semantic distinction maintained
- ✅ Round-trip fidelity preserved

---

## Key Architectural Principles

**NEVER compromise on semantics:**
- Identifiers have specific meanings
- Preprocessing must preserve semantic distinctions
- `+` ≠ `/` - different document structures
- MODEL-DRIVEN architecture means proper classes for each type

**Created:** 2025-12-16
**Sessions Covered:** 156-159
**Status:** Ready for execution

**Critical Fix:** Revert `+` to `/` conversion and implement proper BundledIdentifier! 🚨