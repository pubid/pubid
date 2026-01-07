# Session 276 Continuation Prompt

**Goal:** Fix Part component architecture with type attribute and letter suffix extraction.

## Quick Start

### The Critical Issues

Session 275 completed revision → edition migration, but revealed Part component architectural issues:

1. **Part missing type attribute** ⚠️
   - Current: `Part(value: "1")`
   - Required: `Part(type: "pt", value: "1")`

2. **Letter suffixes in number instead of Part** ⚠️
   - Current: `"800-56A"` → `number="800-56A"`
   - Required: `"800-56A"` → `number="800-56"` + `Part(type: "", value: "A")`

3. **Code.part still exists** ⚠️
   - Must be removed - Part is now separate component

### This Session Tasks (120-150 min)

**SESSION 276: Part Component Architecture Fixes**

1. **Phase A: Add Type to Part Component** (30 min)
   - Add `type` attribute to Part
   - Update to_s to use type ("pt", "n", "")
   - Remove notation parameter dependency

2. **Phase B: Extract Letter Suffixes** (40 min)
   - Pattern: `800-56A` → number + Part(type: "", value: "A")
   - Pattern: `800-56Ar2` → number + Part("", "A") + Edition(r, 2)
   - Add extraction BEFORE existing part patterns

3. **Phase C: Fix Part Type in Extractions** (30 min)
   - `pt1` → Part(type: "pt", value: "1")
   - `n1` → Part(type: "n", value: "1")
   - Update all Part.new calls to include type

4. **Phase D: Remove Code.part** (20 min)
   - Delete part attribute from Code component
   - Remove "pt#{part}" from Code.to_s

5. **Phase E: Test & Validate** (30 min)
   - Test letter suffix extraction
   - Test part notation with type
   - Verify CSM v#n# still works

### Read First

- **Full plan:** [`docs/SESSION-276-CONTINUATION-PLAN.md`](docs/SESSION-276-CONTINUATION-PLAN.md:1)
- **Part component:** [`lib/pubid_new/nist/components/part.rb`](lib/pubid_new/nist/components/part.rb:1)
- **Builder:** [`lib/pubid_new/nist/builder.rb`](lib/pubid_new/nist/builder.rb:1) lines 447-463 (part extraction)
- **Code component:** [`lib/pubid_new/nist/components/code.rb`](lib/pubid_new/nist/components/code.rb:1)

### Key Architecture Principles

1. **MODEL-DRIVEN** - Part is Lutaml::Model with type + value
2. **MECE** - Letter suffixes are Part(type: ""), not part of number
3. **Type-driven rendering** - Part.type determines output format
4. **Component separation** - Number and Part are distinct

### Success Criteria

- ✅ Part component has type attribute
- ✅ Letter suffixes extracted as Part(type: "", value: letter)
- ✅ Part notation uses Part(type: "pt"|"n", value: number)
- ✅ Code.part attribute removed
- ✅ All tests updated with correct expectations

### Example Implementation

**Part component with type:**
```ruby
class Part < Lutaml::Model::Serializable
  attribute :type, :string   # "pt", "n", or ""
  attribute :value, :string

  def to_s(notation = nil)
    return "#{notation}#{value}" if notation
    case type
    when "pt" then "pt#{value}"
    when "n" then "n#{value}"
    else value  # Letter suffix - just "A"
    end
  end
end
```

**Letter suffix extraction:**
```ruby
# Extract letter+revision first (before bare letter)
if str_value =~ /^(.+?)([A-Z])(r\d+[a-z]?)$/
  return {
    type => Components::Code.new(number: $1),
    part: Components::Part.new(type: "", value: $2),
    edition: Components::Edition.new(type: "r", id: $3.sub(/^r/i, ""))
  }
elsif str_value =~ /^(.+?)([A-Z])$/
  return {
    type => Components::Code.new(number: $1),
    part: Components::Part.new(type: "", value: $2)
  }
end
```

**Test expectations:**
```ruby
it "extracts letter suffix as Part" do
  parsed = PubidNew::Nist.parse("NIST SP 800-56A")
  expect(parsed.number.value).to eq("800-56")
  expect(parsed.part.type).to eq("")
  expect(parsed.part.value).to eq("A")
  expect(parsed.to_s).to eq("NIST SP 800-56A")
end

it "handles letter+revision" do
  parsed = PubidNew::Nist.parse("NIST SP 800-56Ar2")
  expect(parsed.number.value).to eq("800-56")
  expect(parsed.part.type).to eq("")
  expect(parsed.part.value).to eq("A")
  expect(parsed.edition.type).to eq("r")
  expect(parsed.edition.id).to eq("2")
  expect(parsed.to_s).to eq("NIST SP 800-56Ar2")
end
```

---

**See full plan for complete implementation details:** [`docs/SESSION-276-CONTINUATION-PLAN.md`](docs/SESSION-276-CONTINUATION-PLAN.md:1)

**Next Session:** 277 (Documentation + completion)