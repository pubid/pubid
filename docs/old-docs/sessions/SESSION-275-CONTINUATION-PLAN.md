# Session 275 Continuation Plan: NIST Revision → Edition & Part Component Completion

**Created:** 2026-01-06 (Post-Session 274)
**Status:** Part component partially complete, Revision needs Edition migration
**Timeline:** COMPRESSED - Complete in 2-3 sessions (4-6 hours total)

---

## Executive Summary

**Session 274 Achievement:** Part component migration implemented for SP series with pt-notation ✅

**Current Issue:** Revision is stored as STRING, not Edition component ⚠️

**Critical Architectural Requirement:**
- `revision` attribute must be migrated to `edition` component
- Edition component already exists and works for "e" and "-" types
- Need to ensure "r" type (revision) also uses Edition component

**Sessions Needed:**
- Session 275: Revision → Edition migration (120 min)
- Session 276: Complete Part migration + cleanup (90 min)
- Session 277: Documentation + validation (60 min)

---

## SESSION 275: Revision → Edition Component Migration (120 min)

### Objective
Ensure ALL revision patterns create Edition components, not legacy string attributes.

### Current State Analysis

**Problem:** Builder creates Edition for some patterns but not others

**Working patterns** (create Edition):
```ruby
# In first_number/second_number extraction (lines 465-505)
"53r5" → Edition(type: "r", id: "5")  ✅
"1019r1963" → Edition(type: "r", id: "1963")  ✅
"4743rJun1992" → handled as revision_month/revision_year ❌ (legacy)
```

**Broken patterns** (create string):
```ruby
# Parser captures :revision separately - Builder doesn't convert to Edition
"800-53r4" → revision="4" (string) ❌ WRONG
"800-90r" → revision="" (string) ❌ WRONG
```

### Part A: Audit All Revision Patterns (20 min)

**Search for revision handling:**
```bash
# Find all revision-related code
grep -n "revision" lib/pubid_new/nist/builder.rb
grep -n "revision" lib/pubid_new/nist/parser.rb
grep -n "edition.*r" lib/pubid_new/nist/identifiers/base.rb
```

**Document:**
1. Where revision is captured by parser
2. Where revision is cast by builder
3. Where revision is rendered by identifier

### Part B: Fix Builder Revision Cast (40 min)

**File:** [`lib/pubid_new/nist/builder.rb`](lib/pubid_new/nist/builder.rb:1)

**Current cast (lines 584-614):**
```ruby
when :revision
  # Currently returns STRING or nil
  str_value
```

**Required fix:**
```ruby
when :revision
  # Revision MUST be Edition component with type "r"
  return nil if value.nil? || value.to_s.strip.empty?

  str_value = value.to_s.strip

  # Handle bare "r" → normalize to "r1"
  if str_value.empty? || str_value == "r"
    revision_id = "1"
  # Handle "r4", "R5", etc.
  elsif str_value =~ /^[rR]?(\d+[a-z]?)$/
    revision_id = $1
  else
    revision_id = str_value
  end

  # Return Edition component
  {
    edition: Components::Edition.new(type: "r", id: revision_id)
  }
```

**Also update revision_year cast (lines 595-614):**
```ruby
when :revision_year
  # If revision_month also present, keep as legacy
  # Otherwise create Edition component
  return nil if value.nil? || value.to_s.strip.empty?
  year_value = value.to_s.strip

  if parsed_hash[:revision_month]
    # Legacy: keep as revision_year for "rJun1992" pattern
    year_value
  else
    # V2: Create Edition component for "r1963" pattern
    {
      edition: Components::Edition.new(type: "r", id: year_value)
    }
  end
```

### Part C: Remove Legacy Revision Rendering (30 min)

**File:** [`lib/pubid_new/nist/identifiers/base.rb`](lib/pubid_new/nist/identifiers/base.rb:1)

**Current rendering (lines 215-228):**
```ruby
# Add revision
if revision
  # Check if revision already has prefix
  if revision.match?(/^(Rev\.|Revision|r)/)
    result += "#{revision}"
  elsif revision.match?(/^[0-9]/)
    # Just digits - add short prefix with no space
    result += "r#{revision}"
  else
    # Already has some prefix - use as-is with no space
    result += "#{revision}"
  end
end
```

**Should be removed** - Edition component handles this now.

**Verification:**
- Edition component already renders correctly: `edition.to_s` → "r4", "r1963", etc.
- No need for separate revision rendering

### Part D: Test Revision Patterns (30 min)

**Test cases to verify:**
```ruby
describe "revision → edition migration" do
  it "parses simple revision" do
    parsed = PubidNew::Nist.parse("NIST SP 800-53r4")
    expect(parsed.edition).to be_a(Components::Edition)
    expect(parsed.edition.type).to eq("r")
    expect(parsed.edition.id).to eq("4")
    expect(parsed.revision).to be_nil  # Legacy attribute should be nil
  end

  it "parses bare revision" do
    parsed = PubidNew::Nist.parse("NIST SP 800-90r")
    expect(parsed.edition).to be_a(Components::Edition)
    expect(parsed.edition.type).to eq("r")
    expect(parsed.edition.id).to eq("1")  # Normalized
  end

  it "parses revision year" do
    parsed = PubidNew::Nist.parse("NIST SP 260-126 rev 2013")
    expect(parsed.edition).to be_a(Components::Edition)
    expect(parsed.edition.type).to eq("r")
    expect(parsed.edition.id).to eq("2013")
  end
end
```

**Expected results:**
- All revision patterns create Edition components ✅
- Legacy `revision` attribute is nil (or removed) ✅
- Round-trip rendering works ✅

---

## SESSION 276: Complete Part Migration + Cleanup (90 min)

### Objective
Finish Part component migration for remaining series and remove legacy Code.part.

### Part A: Audit Other Series (30 min)

**Check these series for part usage:**
1. InteragencyReport (IR)
2. TechnicalNote (TN)
3. FIPS
4. Handbook (HB)

**For each series:**
```bash
# Find part usage in specs
grep -n "\.part" spec/pubid_new/nist/identifiers/interagency_report_spec.rb
grep -n "\.part" spec/pubid_new/nist/identifiers/technical_note_spec.rb
grep -n "\.part" spec/pubid_new/nist/identifiers/fips_spec.rb
grep -n "\.part" spec/pubid_new/nist/identifiers/handbook_spec.rb
```

**Expected:** Most series don't use parts, only SP and possibly IR

### Part B: Migrate Any Part Usage Found (30 min)

**If IR, TN, FIPS, or HB use parts:**
1. Update tests to use `parsed.part.value` instead of `parsed.number.part`
2. Ensure part extraction works in builder
3. Verify rendering uses Part component

**Note:** Based on NIST spec, parts are mainly used in SP series.

### Part C: Remove Code.part Attribute (30 min)

**File:** [`lib/pubid_new/nist/components/code.rb`](lib/pubid_new/nist/components/code.rb:1)

**Current (lines 11-18):**
```ruby
attribute :number, :string
attribute :part, :string        # ← REMOVE THIS
attribute :subpart, :string

def to_s
  result = number.to_s
  result += "pt#{part}" if part  # ← REMOVE THIS
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

**Rationale:** Part is now a separate Component, not a Code attribute.

---

## SESSION 277: Documentation + Validation (60 min)

### Objective
Update official documentation and validate all changes.

### Part A: Update README.adoc (30 min)

**File:** `README.adoc`

**Add/update NIST section:**
```asciidoc
==== NIST (National Institute of Standards and Technology)

Status: ✅ Complete V2 architecture
Tests: 19,432/19,432 (100%)

**V2 Component Architecture:**

Edition Component - Unified handling of all temporal markers:
- Type "e" (edition): `NIST SP 330e2019`
- Type "r" (revision): `NIST SP 800-53r4`
- Type "-" (historical): `NBS CIRC -April1909`

Part Component - Series-specific part notation:
- CSM series: `n` notation (issue number)
  `NBS CSM v6n1` → Volume(6) + Part(1, :n_notation)
- SP series: `pt` notation (part number)
  `NIST SP 800-57pt1r4` → Part(1, :pt_notation) + Edition(r, 4)

Volume Component - Volume subdivision:
- `NBS CSM v6` → Volume(6)
- Combined with Part for issue: `v6n1`

**Examples:**

[source,ruby]
----
# Special Publication with part and revision
sp = PubidNew::Nist.parse("NIST SP 800-57pt1r4")
sp.number.value         # => "800-57"
sp.part.value           # => "1"
sp.part.to_s(:pt_notation)  # => "pt1"
sp.edition.type         # => "r"
sp.edition.id           # => "4"
sp.to_s                 # => "NIST SP 800-57pt1r4"

# Commercial Standards Monthly with volume and issue
csm = PubidNew::Nist.parse("NBS CSM v6n1")
csm.volume.value        # => "6"
csm.part.value          # => "1"
csm.part.to_s(:n_notation)  # => "n1"
csm.to_s                # => "NBS CSM v6n1"

# Circular with edition
circ = PubidNew::Nist.parse("NBS CIRC 13e2.June1908")
circ.edition.type       # => "e"
circ.edition.id         # => "2"
circ.edition.additional_text  # => "June1908"
----
```

### Part B: Archive Old Documentation (15 min)

**Move to old-docs/sessions/:**
```bash
mv docs/SESSION-273-CONTINUATION-PLAN.md docs/old-docs/sessions/
mv docs/SESSION-273-CONTINUATION-PROMPT.md docs/old-docs/sessions/
mv docs/SESSION-274-CONTINUATION-PLAN.md docs/old-docs/sessions/
mv docs/SESSION-274-CONTINUATION-PROMPT.md docs/old-docs/sessions/
```

**Create session summary:**
- `docs/old-docs/sessions/session-274-summary.md`

### Part C: Final Validation (15 min)

**Run comprehensive tests:**
```bash
# Test all NIST identifier types
bundle exec rspec spec/pubid_new/nist/identifiers/ -fd

# Test components
bundle exec rspec spec/pubid_new/nist/components/ -fd
```

**Verify:**
- All Edition component tests passing ✅
- All Part component tests passing ✅
- No legacy revision strings ✅
- Round-trip fidelity maintained ✅

---

## Success Criteria

### Session 275 (Revision → Edition)
- ✅ All revision patterns create Edition components
- ✅ Legacy `revision` attribute removed from rendering
- ✅ Builder `:revision` cast returns Edition
- ✅ Tests updated to expect edition.type == "r"

### Session 276 (Part Completion)
- ✅ All series audited for part usage
- ✅ Code.part attribute removed
- ✅ Only Part component used for parts
- ✅ Zero regressions

### Session 277 (Documentation)
- ✅ README.adoc updated with V2 architecture
- ✅ Old docs archived
- ✅ All tests passing
- ✅ Architecture principles maintained

---

## Key Architectural Principles

**MAINTAIN throughout:**
1. **MODEL-DRIVEN** - Edition and Part are Lutaml::Model components
2. **MECE** - Edition handles e/r/- types exclusively
3. **Component rendering** - Each component renders itself
4. **No legacy attributes** - Remove revision string once Edition works
5. **Series-specific notation** - Part supports :n_notation and :pt_notation

---

## Timeline Summary

| Session | Focus | Duration | Deliverables |
|---------|-------|----------|--------------|
| 275 | Revision → Edition | 120 min | All revisions use Edition |
| 276 | Part completion | 90 min | Code.part removed |
| 277 | Documentation | 60 min | Complete docs, DONE |
| **Total** | **All work** | **270 min** | **Complete** |

---

## Files to Modify

### Session 275
- `lib/pubid_new/nist/builder.rb` - Fix :revision and :revision_year casts
- `lib/pubid_new/nist/identifiers/base.rb` - Remove legacy revision rendering
- `spec/pubid_new/nist/identifiers/special_publication_spec.rb` - Update tests

### Session 276
- `lib/pubid_new/nist/components/code.rb` - Remove part attribute
- Any series specs that use parts

### Session 277
- `README.adoc` - Update NIST section
- `docs/old-docs/sessions/session-274-summary.md` - NEW

---

**Created:** 2026-01-06
**Status:** Ready for Session 275 execution
**Priority:** HIGH - Architectural correctness required

**End Goal:** Complete V2 NIST architecture with proper Edition and Part components! 🎯