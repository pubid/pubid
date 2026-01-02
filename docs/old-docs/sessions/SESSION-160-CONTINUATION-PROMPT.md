# Session 160 Quick Start: CSA Wrapper Infrastructure

**Read First:** [`docs/SESSION-160-CONTINUATION-PLAN.md`](SESSION-160-CONTINUATION-PLAN.md:1) (comprehensive plan)

---

## CRITICAL Context from Session 159

❌ **Session 159 ARCHITECTURAL FLAW DISCOVERED**

Session 159 implemented CSA features as **string patterns** instead of proper **MODEL-DRIVEN wrapper architecture**.

**Problems:**
1. Combined with package treated as CombinedIdentifier (WRONG - should be PackageIdentifier)
2. CAN/ treated as string prefix (WRONG - should be CanadianAdoptedIdentifier wrapper)
3. CSA adoptions incomplete (need CsaAdoptedIdentifier wrapper)

**Root Cause:** String manipulation instead of object composition

---

## Session 160 Objective

Implement **WrapperIdentifier** base infrastructure with **CanadianAdoptedIdentifier** and **CsaAdoptedIdentifier**.

**Timeline:** 2 hours

---

## Wrapper Pattern Architecture

**Correct MODEL-DRIVEN approach:**

```ruby
# BEFORE (WRONG): "CAN/CSA-C22.2 NO. 60601-1-9:15"
# Treated as: Standard with publisher_prefix string

# AFTER (CORRECT): CanadianAdoptedIdentifier wrapping Standard
CanadianAdoptedIdentifier.new(
  wrapped_identifier: Standard.new(code: "C22.2 NO. 60601-1-9:15"),
  reaffirmation: "2024"
)
# => "CAN/CSA C22.2 NO. 60601-1-9:15 (R2024)"
```

**Key Principle:** Adoptions are **wrappers**, not string prefixes!

---

## Session 160 Tasks (2 hours)

### Task 1: WrapperIdentifier Base (30 min)

**Create:** `lib/pubid_new/csa/wrapper_identifier.rb`

```ruby
module PubidNew
  module Csa
    class WrapperIdentifier < Identifier
      attribute :wrapped_identifier, Identifier
      attribute :reaffirmation, :string

      # Subclasses implement to_s
    end
  end
end
```

### Task 2: CanadianAdoptedIdentifier (45 min)

**Create:** `lib/pubid_new/csa/identifiers/canadian_adopted.rb`

```ruby
class CanadianAdoptedIdentifier < WrapperIdentifier
  def to_s
    result = "CAN/#{wrapped_identifier}"
    result += " (R#{reaffirmation})" if reaffirmation
    result
  end
end
```

**Update Parser:**
- Detect `CAN/` prefix
- Parse everything after as wrapped_identifier
- Mark as `:canadian_adopted`

**Update Builder:**
- Recursively parse wrapped identifier
- Build CanadianAdoptedIdentifier
- Handle reaffirmation

### Task 3: CsaAdoptedIdentifier (45 min)

**Create:** `lib/pubid_new/csa/identifiers/csa_adopted.rb`

For patterns like: `CSA ISO/IEC TR 12785-3:15 (R2019)`

```ruby
class CsaAdoptedIdentifier < WrapperIdentifier
  attribute :source_organization, :string  # "ISO/IEC", "CISPR", etc
  attribute :document_type, :string  # "TR", "TS", etc
  attribute :number, :string
  attribute :year, :string  # 2-digit

  def to_s
    result = "CSA #{source_organization}"
    result += " #{document_type}" if document_type
    result += " #{number}"
    result += ":#{year}" if year
    result += " (R#{reaffirmation})" if reaffirmation
    result
  end
end
```

---

## Expected Results

**After Session 160:**
- ✅ WrapperIdentifier base working
- ✅ CanadianAdoptedIdentifier parsing CAN/ patterns (50-100 IDs)
- ✅ CsaAdoptedIdentifier parsing CSA ISO/IEC patterns (100-150 IDs)
- ✅ CSA: 448 → 598-698 (66-78%)

---

## Test Patterns

```ruby
# Test these patterns work:
test_cases = [
  "CAN/CSA-C22.2 NO. 60601-1-9:15 (R2024)",
  "CAN/CSA-ISO 10993-16-00 (R2014)",
  "CSA ISO/IEC TR 12785-3:15 (R2019)",
  "CAN/CSA-CISPR 12-10 (R2023)"
]
```

---

## Success Criteria

- ✅ Wrapper pattern implemented correctly
- ✅ Recursive identifier parsing working
- ✅ No string prefix hacks
- ✅ MODEL-DRIVEN architecture maintained
- ✅ 150-250 new identifiers passing

---

## Next Steps (Session 161+)

After Session 160 completes wrapper infrastructure:
- Session 161: Package & Bundle identifiers
- Session 162: Series & Historical identifiers
- Session 163+: 60%+ validation target

**Remember:** Architecture correctness > test count!

---

**Created:** 2025-12-17
**Priority:** CRITICAL
**Focus:** Wrapper pattern for adoptions