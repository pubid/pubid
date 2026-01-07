# Session 276 Continuation Plan: NIST Part Component Architecture Completion

**Created:** 2026-01-06 (Post-Session 275)
**Status:** Revision → Edition migration complete, Part architecture corrections needed
**Timeline:** COMPRESSED - Complete in 2-3 hours (120-180 min)

---

## Executive Summary

**Session 275 Achievement:** Revision → Edition migration complete ✅

**Critical Architectural Issues Identified:**

1. **Part component missing `type` attribute** ⚠️
   - Current: Part(value: "1")
   - Required: Part(type: "pt", value: "1")

2. **Letter suffixes stored in number instead of Part** ⚠️
   - Current: `800-56A` → number="800-56A"
   - Required: `800-56A` → number="800-56" + Part(type: "", id: "A")

3. **Code.part attribute still exists** ⚠️
   - Must be removed - Part is now separate component

**Sessions Needed:**
- Session 276: Part.type + letter suffix extraction (120-150 min)
- Session 277: Documentation + validation (60 min)

---

## SESSION 276: Part Component Architecture Fixes (120-150 min)

### Objective
Fix Part component architecture to properly handle type attribute and letter suffixes as Part components.

### Part A: Add Type Attribute to Part Component (30 min)

**File:** [`lib/pubid_new/nist/components/part.rb`](lib/pubid_new/nist/components/part.rb:1)

**Current structure:**
```ruby
class Part < Lutaml::Model::Serializable
  attribute :value, :string

  def to_s(notation = :pt_notation)
    case notation
    when :pt_notation
      "pt#{value}"
    when :n_notation
      "n#{value}"
    else
      value
    end
  end
end
```

**Required changes:**
```ruby
class Part < Lutaml::Model::Serializable
  attribute :type, :string   # NEW: "pt" for part notation, "" for letter suffixes
  attribute :value, :string  # Part number or letter (1, 2, A, B, etc.)

  def to_s(notation = nil)
    # If notation explicitly provided, use it
    return "#{notation}#{value}" if notation

    # Otherwise use type attribute
    case type
    when "pt"
      "pt#{value}"
    when "n"
      "n#{value}"
    when ""
      # Letter suffix - just the letter
      value
    else
      # Fallback
      value
    end
  end
end
```

### Part B: Extract Letter Suffixes as Part Components (40 min)

**File:** [`lib/pubid_new/nist/builder.rb`](lib/pubid_new/nist/builder.rb:1)

**Current pattern** (embedded in number):
```ruby
# "800-56A" → number="800-56A"
# "800-56Ar2" → number="800-56A" + revision
```

**Required pattern** (extract letter as Part):
```ruby
# Add after part+revision extraction (around line 447):
# Extract letter suffix as Part component (e.g., "800-56A" → number + Part)
if str_value =~ /^(.+?)([A-Z])$/
  number_part = $1
  letter_part = $2
  return {
    type => Components::Code.new(number: number_part),
    part: Components::Part.new(type: "", value: letter_part)
  }
end
```

**Handle letter+revision combinations:**
```ruby
# "800-56Ar2" → number + Part(letter) + Edition(r, 2)
if str_value =~ /^(.+?)([A-Z])(r\d+[a-z]?)$/
  number_part = $1
  letter_part = $2
  revision_part = $3.sub(/^r/i, "")
  return {
    type => Components::Code.new(number: number_part),
    part: Components::Part.new(type: "", value: letter_part),
    edition: Components::Edition.new(type: "r", id: revision_part)
  }
end
```

### Part C: Fix Part Extraction to Include Type (30 min)

**File:** [`lib/pubid_new/nist/builder.rb`](lib/pubid_new/nist/builder.rb:1)

**Update pt+revision pattern** (around line 447):
```ruby
if str_value =~ /^(.+?)pt(\d+)r(\d+[a-z]?)$/
  number_part = $1
  part_value = $2
  revision_value = $3
  return {
    type => Components::Code.new(number: number_part),
    part: Components::Part.new(type: "pt", value: part_value),
    edition: Components::Edition.new(type: "r", id: revision_value)
  }
elsif str_value =~ /^(.+?)pt(\d+)$/
  number_part = $1
  part_value = $2
  return {
    type => Components::Code.new(number: number_part),
    part: Components::Part.new(type: "pt", value: part_value)
  }
end
```

**Update CSM v#n# pattern** (around line 257):
```ruby
if value.is_a?(Hash) && value[:volume_number] && value[:issue_number]
  volume_num = value[:volume_number].to_s
  issue_num = value[:issue_number].to_s
  return {
    volume: Components::Volume.new(value: volume_num),
    part: Components::Part.new(type: "n", value: issue_num)
  }
end
```

### Part D: Remove Code.part Attribute (20 min)

**File:** [`lib/pubid_new/nist/components/code.rb`](lib/pubid_new/nist/components/code.rb:1)

**Current:**
```ruby
attribute :number, :string
attribute :part, :string        # ← REMOVE
attribute :subpart, :string

def to_s
  result = number.to_s
  result += "pt#{part}" if part  # ← REMOVE
  result += ".#{subpart}" if subpart
  result
end
```

**After removal:**
```ruby
attribute :number, :string
attribute :subpart, :string

def to_s
  result = number.to_s
  result += ".#{subpart}" if subpart
  result
end
```

### Part E: Testing & Validation (30 min)

**Test patterns:**
```ruby
# Letter suffix extraction
"NIST SP 800-56A" → number="800-56" + Part(type: "", value: "A")
"NIST SP 800-56Ar2" → number="800-56" + Part("", "A") + Edition(r, 2)

# Part notation with type
"NIST SP 800-57pt1" → number="800-57" + Part(type: "pt", value: "1")
"NIST SP 800-57pt1r4" → number="800-57" + Part("pt", "1") + Edition(r, 4)

# Issue number with type
"NBS CSM v6n1" → Volume(6) + Part(type: "n", value: "1")
```

**Run tests:**
```bash
bundle exec rspec spec/pubid_new/nist/identifiers/special_publication_spec.rb
bundle exec rspec spec/pubid_new/nist/identifiers/commercial_standards_monthly_spec.rb
```

---

## SESSION 277: Documentation & Completion (60 min)

### Part A: Update README.adoc (40 min)

**File:** `README.adoc`

Add NIST Part component documentation:
```asciidoc
==== Part Component Architecture

The Part component represents sub-divisions with type-specific notation:

.Part Types
[cols="1,2,3"]
|===
|Type |Use Case |Example

|"pt"
|Special Publication parts
|`NIST SP 800-57pt1` → Part(type: "pt", value: "1")

|"n"
|Commercial Standards Monthly issues
|`NBS CSM v6n1` → Part(type: "n", value: "1")

|""
|Letter suffixes (A, B, C, etc.)
|`NIST SP 800-56A` → Part(type: "", value: "A")
|===

.Part Component Examples
[source,ruby]
----
# Letter suffix as Part
sp = PubidNew::Nist.parse("NIST SP 800-56Ar2")
sp.number.value         # => "800-56"
sp.part.type            # => ""
sp.part.value           # => "A"
sp.edition.type         # => "r"
sp.edition.id           # => "2"
sp.to_s                 # => "NIST SP 800-56Ar2"

# Part notation
sp = PubidNew::Nist.parse("NIST SP 800-57pt1r4")
sp.number.value         # => "800-57"
sp.part.type            # => "pt"
sp.part.value           # => "1"
sp.part.to_s            # => "pt1"
sp.edition.type         # => "r"
sp.edition.id           # => "4"
----
```

### Part B: Archive Session Docs (20 min)

Move completed docs to `docs/old-docs/sessions/`:
```bash
mv docs/SESSION-274-CONTINUATION-PLAN.md docs/old-docs/sessions/
mv docs/SESSION-274-CONTINUATION-PROMPT.md docs/old-docs/sessions/
mv docs/SESSION-275-CONTINUATION-PLAN.md docs/old-docs/sessions/
mv docs/SESSION-275-CONTINUATION-PROMPT.md docs/old-docs/sessions/
```

Create session summaries:
- `docs/old-docs/sessions/session-275-summary.md`
- `docs/old-docs/sessions/session-276-summary.md`

---

## Success Criteria

### Session 276
- ✅ Part component has `type` attribute
- ✅ Letter suffixes extracted as Part(type: "", value: letter)
- ✅ Part notation uses Part(type: "pt", value: number)
- ✅ CSM issues use Part(type: "n", value: number)
- ✅ Code.part attribute removed
- ✅ All tests updated to new expectations

### Session 277
- ✅ README.adoc updated with Part architecture
- ✅ Old session docs archived
- ✅ All tests passing with correct architecture

---

## Key Architectural Principles

**MAINTAIN throughout:**
1. **MODEL-DRIVEN** - Part is Lutaml::Model with type + value
2. **MECE** - Letter suffixes are Part components, not part of number
3. **Type-specific notation** - Part.type determines rendering ("pt", "n", "")
4. **Component separation** - Number, Part, Edition are distinct components
5. **Open/Closed** - Easy to add new part types without changing Number

---

## Files to Modify

### Session 276
- `lib/pubid_new/nist/components/part.rb` - Add type attribute
- `lib/pubid_new/nist/builder.rb` - Extract letter suffixes, add type to Part
- `lib/pubid_new/nist/components/code.rb` - Remove part attribute
- `spec/pubid_new/nist/identifiers/special_publication_spec.rb` - Update tests

### Session 277
- `README.adoc` - Add Part component documentation
- `docs/old-docs/sessions/session-275-summary.md` - NEW
- `docs/old-docs/sessions/session-276-summary.md` - NEW

---

**Created:** 2026-01-06
**Status:** Ready for Session 276 execution
**Priority:** HIGH - Architectural correctness required

**End Goal:** Complete V2 NIST Part architecture with proper type handling! 🎯