# Session 43 Starting Prompt

**Goal:** Begin URN generation implementation - Foundation phase

**Current Status:** 83.1% (2,377/2,859 passing tests)  
**Target for Session 43:** 85%+ (2,430+ passing tests) - need +53 tests  
**Previous Session:** Session 42 - Edge case analysis (discovered 100% functional completion, path to 85% is URN generation)

---

## Session 43 Objectives

### Primary Goal: Implement Basic URN Generation (90 min)

**Expected Gain:** +35-50 tests → 85% milestone achieved

1. **Understand URN Format** (15 min)
   - Read RFC 5141 specification
   - Review V1 implementation: `gems/pubid-iso/lib/pubid/iso/renderer/urn.rb`
   - Document conversion rules

2. **Implement InternationalStandard.to_urn** (45 min)
   - Add `to_urn` method to InternationalStandard class
   - Handle basic conversion (publisher, number, parts)
   - Test with examples from spec
   - Expected: +20-30 tests passing

3. **Extend to Other SingleIdentifier Types** (20 min)
   - Implement `to_urn` in TechnicalReport
   - Implement `to_urn` in TechnicalSpecification
   - Apply same pattern
   - Expected: +15-20 tests passing

4. **Validate and Document** (10 min)
   - Run full test suite
   - Confirm 85% milestone achieved
   - Document patterns discovered
   - Update memory bank

---

## Context from Session 42

### Key Discovery: 100% Functional Completion! 🎉

**All functional tests are passing:**
- ✅ Zero failures in any identifier_spec
- ✅ Zero failures in parser logic
- ✅ Zero failures in builder logic
- ✅ Zero failures in rendering
- ✅ Phase 3 (Legacy Formats) complete
- ✅ Phase 4 (Edge Cases) complete - no work needed!

**Only remaining work:** URN generation (377 pending tests)

### Test Breakdown

| Category | Count | Status |
|----------|-------|--------|
| Functional | 2,373 | ✅ 100% passing |
| Performance | 4 | ✅ Passing (2 timing variations) |
| URN generation | 377 | 📋 Not implemented |
| V1/V2 compat | 101 | 📋 Intentional difference |
| Other pending | 2 | 📋 Low priority |

### Path to Milestones

| Milestone | Tests Needed | Available Work | Strategy |
|-----------|--------------|----------------|----------|
| 85% | +53 | URN: 377 | Session 43 |
| 90% | +197 | URN: 377 | Sessions 43-46 |
| 95% | +340 | URN: 377 | Sessions 43-50 |

---

## URN Format Specification (RFC 5141)

### Basic Pattern

```
urn:iso:std:{publisher}:{number}[:{elements}]
```

### Components

**Publisher:**
- `ISO` → `iso`
- `ISO/IEC` → `iso-iec`
- `ISO/IEEE` → `iso-ieee`
- `ISO/IEC/IEEE` → `iso-iec-ieee`
- Other copublishers: `iso-{copub}` (lowercase, hyphen-separated)

**Number:**
- Simple: `8601` → `8601`
- With part: `8601-1` → `8601:-1` (dash becomes colon-dash)
- With subpart: `80601-2-61` → `80601:-2-61`
- Alphabetical part: `105-C06` → `105:-C06`

**Optional Elements:**
- Stage: `:stage-{code}` (e.g., `:stage-30.00` for CD)
- Edition: `:ed-{number}` (e.g., `:ed-1`)
- Language: `:{lang}` (e.g., `:en,fr`)
- Stage iteration: `:stage-{code}.v{n}` (e.g., `:stage-50.00.v2`)

### Examples from Specs

```ruby
# Basic
"ISO 19135:2025" → "urn:iso:std:iso:19135"

# With copublisher
"ISO/IEC 27001:2013" → "urn:iso:std:iso-iec:27001"

# With part
"ISO 8601-1:2019" → "urn:iso:std:iso:8601:-1"

# With subpart
"ISO 80601-2-61:2019" → "urn:iso:std:iso:80601:-2-61"

# With sub-subpart
"ISO/IEC 29110-5-1-1:2025" → "urn:iso:std:iso-iec:29110:-5-1-1"

# With stage
"ISO/IEC CD 29110-5-1-1" → "urn:iso:std:iso-iec:29110:-5-1-1:stage-30.00"

# With edition
"ISO 22610:2006 Ed 1" → "urn:iso:std:iso:22610:ed-1"

# Multiple copublishers
"ISO/IEC/IEEE 26512" → "urn:iso:std:iso-iec-ieee:26512"
```

---

## Implementation Strategy

### Step 1: Read V1 Implementation (15 min)

**File:** `gems/pubid-iso/lib/pubid/iso/renderer/urn.rb`

**Key points to understand:**
- How publisher is converted
- How parts are formatted
- How stages are mapped
- How editions are handled

### Step 2: Implement InternationalStandard.to_urn (45 min)

**File:** `lib/pubid_new/iso/identifiers/international_standard.rb`

**Method signature:**
```ruby
def to_urn
  # Build URN string
end
```

**Implementation approach:**
```ruby
def to_urn
  parts = ["urn", "iso", "std"]
  
  # Publisher (lowercase, hyphen-separated)
  parts << publisher_urn
  
  # Number
  parts << number.value
  
  # Part (with colon-dash prefix)
  parts << ":-#{part.value}" if part
  
  # Subpart (append to part)
  # ... handle subpart
  
  # Optional elements
  parts << stage_urn if staged?
  parts << edition_urn if edition
  parts << language_urn if languages
  
  parts.join(":")
end

private

def publisher_urn
  # Convert "ISO/IEC" to "iso-iec"
  copubs = publisher.copublisher || []
  ([publisher.publisher] + copubs).map(&:downcase).join("-")
end
```

**Helper methods might include:**
- `publisher_urn` - Convert publisher format
- `stage_urn` - Convert stage to stage-XX.YY format
- `edition_urn` - Convert edition to ed-N format
- `language_urn` - Convert languages to comma-separated

**Testing approach:**
1. Start with simplest case: `ISO 19135:2025`
2. Add part handling: `ISO 8601-1:2019`
3. Add copublisher: `ISO/IEC 27001:2013`
4. Add complex parts: `ISO 80601-2-61:2019`
5. Run spec to see which tests pass

### Step 3: Extend to TechnicalReport and TechnicalSpecification (20 min)

**Strategy:** Most logic can be inherited or shared

**Option A: Inherit from InternationalStandard**
```ruby
class TechnicalReport < SingleIdentifier
  # Use inherited to_urn with TR-specific handling if needed
end
```

**Option B: Extract to SingleIdentifier base class**
```ruby
class SingleIdentifier
  def to_urn
    # Common implementation
  end
end
```

**Option B is preferred** - DRY principle, all SingleIdentifier types benefit

### Step 4: Validate Results (10 min)

**Run tests:**
```bash
bundle exec rspec spec/pubid_new/iso/identifiers/international_standard_spec.rb --tag ~pending
bundle exec rspec spec/pubid_new/iso/identifiers/technical_report_spec.rb --tag ~pending
bundle exec rspec spec/pubid_new/iso/ --format progress 2>&1 | grep "examples,"
```

**Check:**
- How many URN tests now passing?
- Any unexpected failures?
- Are we at 85%?

---

## Expected Challenges

### Challenge 1: Stage Mapping

**Issue:** Stage abbreviations (CD, DIS) need to map to stage codes (30.00, 40.00)

**V1 approach:** Uses stage mapping in configuration

**V2 approach:** TypedStage already has stage_code!

```ruby
def stage_urn
  stage = typed_stage.to_stage
  "stage-#{stage.code}"  # e.g., "stage-30.00"
end
```

### Challenge 2: Subpart Handling

**Issue:** Multiple levels of parts need proper formatting

**Examples:**
- Part: `8601-1` → `8601:-1`
- Subpart: `80601-2-61` → `80601:-2-61`
- Sub-subpart: `29110-5-1-1` → `29110:-5-1-1`

**Strategy:** Build recursively or concatenate

```ruby
def part_urn
  return unless part
  
  parts = [":-#{part.value}"]
  parts << "-#{subpart.value}" if subpart
  parts.join
end
```

### Challenge 3: Date Components

**Issue:** URN doesn't include year in published standards

**Rule:** Year is implicit, not in URN (except for stages)

```ruby
# Both produce same URN
"ISO 8601:2019" → "urn:iso:std:iso:8601"
"ISO 8601" → "urn:iso:std:iso:8601"
```

---

## Success Criteria

By end of Session 43:

1. ✅ `to_urn` method implemented in InternationalStandard (or SingleIdentifier base)
2. ✅ Basic URN generation working (publisher, number, parts)
3. ✅ At least +30 tests passing (URN tests now enabled)
4. ✅ **85% milestone achieved** (2,430+ passing tests)
5. ✅ Pattern documented for Session 44 (supplements)

---

## Files to Read

**Must Read:**
- `gems/pubid-iso/lib/pubid/iso/renderer/urn.rb` - V1 implementation
- `spec/pubid_new/iso/identifiers/international_standard_spec.rb:65-1532` - URN test examples
- RFC 5141 (if time permits)

**Must Modify:**
- `lib/pubid_new/iso/identifiers/international_standard.rb` - Add `to_urn` method
- OR `lib/pubid_new/iso/single_identifier.rb` - If implementing in base class

**May Need:**
- `lib/pubid_new/components/stage.rb` - For stage code access
- `lib/pubid_new/components/typed_stage.rb` - For combined stage access

---

## Important Reminders

### DO:
- ✅ Start simple (basic cases first)
- ✅ Test incrementally (one feature at a time)
- ✅ Use existing components (TypedStage has stage_code!)
- ✅ Follow RFC 5141 specification
- ✅ DRY principle (extract to base if shared)

### DON'T:
- ❌ Try to implement all URN features at once
- ❌ Duplicate V1 implementation bugs
- ❌ Hardcode stage mappings (use TypedStage)
- ❌ Forget about multiple copublishers
- ❌ Skip testing after each change

---

## Testing Commands

```bash
# Run single spec to focus
bundle exec rspec spec/pubid_new/iso/identifiers/international_standard_spec.rb

# Check URN tests specifically (they're marked with xit)
grep -n "xit.*urn" spec/pubid_new/iso/identifiers/international_standard_spec.rb

# After implementing, run full suite
bundle exec rspec spec/pubid_new/iso/ --format progress 2>&1 | grep "examples,"

# Check progress
bundle exec rspec spec/pubid_new/iso/ --format documentation 2>&1 | \
  tail -20
```

---

## Next Session Preview

**If Session 43 Succeeds:**
- Session 44: Supplement URN (Amendment, Corrigendum)
- Session 45-46: Advanced URN (stages, editions, languages)
- Session 47-50: Complete URN implementation

**If Session 43 Encounters Issues:**
- Debug and resolve blocking issues
- May need parser_urn implementation as well
- Adjust approach based on learnings

---

## Key Insight from Session 42

**This is NOT bug-fixing work, this is FEATURE implementation!**

The V2 architecture has achieved **100% functional completeness** for parsing and rendering. URN generation is a new feature being added to complete the API.

This validates our architectural decisions and proves the MODEL-DRIVEN approach works perfectly! 🎉

Good luck with Session 43! 🚀