# Session 275 Continuation Prompt

**Goal:** Fix revision handling to use Edition component instead of legacy string attribute.

## Quick Start

### The Current Issue

Session 274 completed Part component migration, but revealed that **revision is stored as STRING, not Edition component**:

```ruby
parsed = PubidNew::Nist.parse('NIST SP 800-53r4')
parsed.revision  # => "4" (STRING) ❌ WRONG
parsed.edition   # => nil ❌ WRONG

# SHOULD BE:
parsed.edition   # => Edition(type: "r", id: "4") ✅ CORRECT
parsed.revision  # => nil (legacy attribute unused)
```

### This Session Tasks (120 min)

**SESSION 275: Revision → Edition Component Migration**

1. **Phase 1: Audit Revision Handling** (20 min)
   - Find where revision is captured in parser
   - Find where revision is cast in builder
   - Document all revision patterns

2. **Phase 2: Fix Builder Revision Cast** (40 min)
   - Update `:revision` cast to return Edition component
   - Update `:revision_year` cast to return Edition
   - Handle bare "r" → normalize to "r1"

3. **Phase 3: Remove Legacy Rendering** (30 min)
   - Remove revision rendering from Base (lines 215-228)
   - Edition component already handles rendering
   - Verify round-trip works

4. **Phase 4: Test All Patterns** (30 min)
   - Test "800-53r4" → Edition(r, 4)
   - Test "800-90r" → Edition(r, 1)
   - Test "260-126 rev 2013" → Edition(r, 2013)

### Read First

- **Full plan:** [`docs/SESSION-275-CONTINUATION-PLAN.md`](docs/SESSION-275-CONTINUATION-PLAN.md:1)
- **Builder:** [`lib/pubid_new/nist/builder.rb`](lib/pubid_new/nist/builder.rb:1) lines 584-614
- **Base:** [`lib/pubid_new/nist/identifiers/base.rb`](lib/pubid_new/nist/identifiers/base.rb:1) lines 215-228
- **Edition component:** [`lib/pubid_new/nist/components/edition.rb`](lib/pubid_new/nist/components/edition.rb:1)

### Key Architecture Principles

1. **MODEL-DRIVEN** - Edition is Lutaml::Model, not string
2. **MECE** - Edition handles e/r/- types exclusively
3. **Component rendering** - Edition.to_s handles all formatting
4. **No legacy attributes** - Remove revision once Edition works

### Success Criteria

- ✅ All revision patterns create Edition(type: "r")
- ✅ Legacy `revision` rendering removed
- ✅ Builder `:revision` cast returns Edition
- ✅ Tests pass with edition.type == "r"

### Example Implementation

**Builder revision cast:**
```ruby
when :revision
  return nil if value.nil? || value.to_s.strip.empty?

  str_value = value.to_s.strip
  # Handle bare "r" → normalize to "r1"
  revision_id = if str_value.empty? || str_value == "r"
    "1"
  elsif str_value =~ /^[rR]?(\d+[a-z]?)$/
    $1
  else
    str_value
  end

  # Return Edition component
  {
    edition: Components::Edition.new(type: "r", id: revision_id)
  }
```

**Test expectations:**
```ruby
it "parses revision as edition" do
  parsed = PubidNew::Nist.parse("NIST SP 800-53r4")
  expect(parsed.edition).to be_a(PubidNew::Nist::Components::Edition)
  expect(parsed.edition.type).to eq("r")
  expect(parsed.edition.id).to eq("4")
  expect(parsed.to_s).to eq("NIST SP 800-53r4") # Round-trip
end
```

---

**See full plan for complete implementation details:** [`docs/SESSION-275-CONTINUATION-PLAN.md`](docs/SESSION-275-CONTINUATION-PLAN.md:1)

**Next Session:** 276 (Part completion + Code.part removal)