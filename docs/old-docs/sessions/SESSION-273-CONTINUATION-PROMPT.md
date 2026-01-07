# Session 273 Continuation Prompt

**Goal:** Implement proper NIST Volume and Part Lutaml::Model components to fix CSM `v6n1` architecture.

## Quick Start

### The Problem

NIST currently violates MODEL-DRIVEN architecture by embedding Volume and Part into `Code` component:

```ruby
# ❌ CURRENT (WRONG):
code.number = "v6"  # Volume embedded
code.part = "1"     # Issue embedded
# Renders: "NBS CSM v6pt1" (forced pt notation)

# ✅ REQUIRED (CORRECT):
volume.value = "6"  # Proper Volume component
part.value = "1"    # Proper Part component
# Renders: "NBS CSM v6n1" (correct notation)
```

### This Session Tasks (120 min)

**SESSION 273: Create Volume & Part Components**

1. **Phase 1: Volume Component** (30 min)
   - Create [`lib/pubid_new/nist/components/volume.rb`](lib/pubid_new/nist/components/volume.rb:1)
   - Create [`spec/pubid_new/nist/components/volume_spec.rb`](spec/pubid_new/nist/components/volume_spec.rb:1)
   - Lutaml::Model with `value` attribute
   - `to_s` renders as `"v#{value}"`

2. **Phase 2: Part Component** (30 min)
   - Create [`lib/pubid_new/nist/components/part.rb`](lib/pubid_new/nist/components/part.rb:1)
   - Create [`spec/pubid_new/nist/components/part_spec.rb`](spec/pubid_new/nist/components/part_spec.rb:1)
   - Lutaml::Model with `value` attribute
   - `to_s(notation)` supports `:n_notation` ("n1") and `:pt_notation` ("pt1")

3. **Phase 3: Update Builder** (40 min)
   - Add requires for Volume and Part
   - Update `cast(:volume_number)` → return Volume component
   - Update `cast(:issue_number)` → return Part component
   - Update `cast(:first_number)` v#n# pattern → return Volume and Part

4. **Phase 4: Update CSM Identifier** (20 min)
   - [`lib/pubid_new/nist/identifiers/commercial_standards_monthly.rb`](lib/pubid_new/nist/identifiers/commercial_standards_monthly.rb:1)
   - Use Volume and Part components
   - Render as `"#{volume}#{part.to_s(:n_notation)}"`

### Read First

- **Full plan:** [`docs/SESSION-273-CONTINUATION-PLAN.md`](docs/SESSION-273-CONTINUATION-PLAN.md:1)
- **Edition component:** [`lib/pubid_new/nist/components/edition.rb`](lib/pubid_new/nist/components/edition.rb:1) (follow this pattern!)
- **NIST spec:** [`nist-pubid-spec.md`](nist-pubid-spec.md:1)

### Key Architecture Principles

1. **MODEL-DRIVEN** - Each semantic concept = One Lutaml::Model component
2. **MECE** - Volume, Part, Edition, Number are mutually exclusive
3. **Component rendering** - Each component knows how to render itself
4. **Identifier composition** - Identifiers compose components, don't embed

### Success Criteria

- ✅ Volume component tests: 100% passing
- ✅ Part component tests: 100% passing
- ✅ CSM parses `v6n1` with proper components
- ✅ CSM renders `v6n1` correctly (not `v6pt1`)
- ✅ Zero regressions in other NIST tests

### Example Implementation

**Volume Component:**
```ruby
class Volume < Lutaml::Model::Serializable
  attribute :value, :string

  def to_s
    "v#{value}"
  end
end
```

**Part Component:**
```ruby
class Part < Lutaml::Model::Serializable
  attribute :value, :string

  def to_s(notation = :n_notation)
    notation == :pt_notation ? "pt#{value}" : "n#{value}"
  end
end
```

---

**See full plan for complete implementation details:** [`docs/SESSION-273-CONTINUATION-PLAN.md`](docs/SESSION-273-CONTINUATION-PLAN.md:1)

**Next Sessions:** 274 (SP migration), 275 (testing & docs)