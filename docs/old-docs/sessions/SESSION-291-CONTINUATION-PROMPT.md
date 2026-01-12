# Session 291 Continuation Prompt

**Task:** Complete BSI Implementation & ASTM Rspec Creation

**Status:** Ready to execute - Follow SESSION-291-CONTINUATION-PLAN.md

---

## Context

**User Request:** "Fix ALL bsi issues, and also update astm rspecs so that it runs"

**Current State:**
- BSI: 1,044/1,579 (66.12%) - 535 "unknown" failures remain
- ASTM: 248 fixtures ready, no integration specs

**Session 290 Completed:**
- ✅ Documentation updates
- ✅ Session 289 archived
- ✅ Memory bank updated
- ✅ README.adoc updated

---

## Session 291 Objectives

### Primary Goal: Supplement & Addendum (+61 IDs)

Implement two new BSI identifier classes:

1. **SupplementDocument** (32 IDs from `supplement.txt`)
2. **AddendumDocument** (29 IDs from `addendum.txt`)

**Target:** 1,044 → 1,105 (66.12% → 69.98%)

### Architecture Requirements

**CRITICAL - Follow Session 288 Lesson:**
- ✅ **ALWAYS read fixture files FIRST**
- ✅ **Create class matching fixture filename**
- ✅ **Implement patterns exactly as in fixtures**
- ❌ **NEVER create arbitrary classes**

**MODEL-DRIVEN Architecture:**
- Lutaml::Model::Serializable throughout
- Three-layer pattern (Parser/Builder/Identifier)
- MECE organization
- Component-based attributes
- Round-trip fidelity

---

## Execution Steps

### Step 1: Analyze Supplement Patterns (15 min)

Read and analyze:
```bash
cat spec/fixtures/bsi/identifiers/full/supplement.txt
```

Identify patterns:
- `BS NUMBER:Supplement No. N:YEAR`
- `Supplement No. N (YEAR) to BS NUMBER:YEAR`
- `BS NUMBER Supplement N:YEAR`

### Step 2: Create SupplementDocument Class (45 min)

**File:** `lib/pubid_new/bsi/identifiers/supplement_document.rb`

**Template:**
```ruby
class SupplementDocument < Identifiers::Base
  attribute :base_identifier, Identifier, polymorphic: true
  attribute :supplement_number, Components::Code
  attribute :supplement_year, Components::Date

  def to_s
    # Implement rendering logic
  end
end
```

**Update Files:**
1. `lib/pubid_new/bsi/parser.rb` - Add supplement patterns
2. `lib/pubid_new/bsi/builder.rb` - Add supplement construction
3. `lib/pubid_new/bsi/scheme.rb` - Add to IDENTIFIER_CLASS_MAP

### Step 3: Analyze Addendum Patterns (15 min)

Read and analyze:
```bash
cat spec/fixtures/bsi/identifiers/full/addendum.txt
```

Identify patterns:
- `BS NUMBER Addendum No. N:YEAR`
- `BS NUMBER:Addendum No. N:YEAR`
- `BS NUMBER:YEAR:Addendum No. N:YEAR`

### Step 4: Create AddendumDocument Class (45 min)

**File:** `lib/pubid_new/bsi/identifiers/addendum_document.rb`

Similar structure to SupplementDocument.

### Step 5: Validate Results (15 min)

```bash
# Run BSI fixture validation
ruby capture_failures.rb bsi

# Check results
cat spec/fixtures/bsi/SUMMARY.txt
```

**Expected:**
- Previous: 1,044/1,579 (66.12%)
- New: 1,105/1,579 (69.98%)
- Gain: +61 identifiers

---

## Key Patterns to Implement

### Supplement Patterns

```
# Standard format
BS 1000[9]:Supplement No. 1:1972
BS 449-1 Supplement No. 1:1959
BS 5258-1 Supplement 1:1983

# Reverse format (supplement first)
Supplement No. 1 (1970) to BS 1831:1969
Supplement No. 2 (1970) to BS 1831:1969

# With base having supplement
BS 2011-3A & B:Supplement No. 1:1980
```

### Addendum Patterns

```
# Standard format
BS 1501-2 Addendum No. 1:1973
BS 2000-0:Addendum 1:1983
BS 449-1 Addendum No. 1:1961

# With year on base
BS 6034:1981:Addendum No. 1:1986
BS 449-2:1969 Addendum No. 1:1975
```

---

## Success Criteria

### Mandatory Requirements

1. ✅ Both classes inherit from `Identifiers::Base`
2. ✅ Use Lutaml::Model::Serializable
3. ✅ Parser handles all patterns from fixtures
4. ✅ Builder constructs objects correctly
5. ✅ Round-trip fidelity: `parse(str).to_s == str`
6. ✅ At least +61 IDs passing
7. ✅ Zero regression in existing tests

### Quality Gates

- **Architecture:** MODEL-DRIVEN principles maintained
- **Testing:** All new patterns have tests
- **Documentation:** Code is self-documenting
- **Performance:** No degradation

---

## After Session 291

### Update Progress

1. Update memory bank with Session 291 achievement
2. Create session-291-summary.md
3. Update SESSION-291-CONTINUATION-PLAN.md status

### Prepare Session 292

Focus: RangeIdentifier implementation (+40 IDs)

---

## Important Reminders

### From Session 288 Correction

**WRONG APPROACH:**
```
❌ Create SpecializedStandard without checking fixtures
❌ Arbitrary class names not matching fixtures
❌ Implementing patterns not in fixtures
```

**CORRECT APPROACH:**
```
✅ Read fixture file first: supplement.txt → SupplementDocument
✅ Analyze all patterns in fixture
✅ Implement exactly what's in the fixture
✅ Test incrementally
```

### Architecture Principles

1. **MECE:** Mutually Exclusive, Collectively Exhaustive
2. **Three-Layer:** Parser → Builder → Identifier
3. **Component-Based:** Use Components::Code, Components::Date
4. **Polymorphic:** `attribute :base_identifier, Identifier, polymorphic: true`
5. **Round-Trip:** Perfect fidelity in parse → render

### Never Compromise

- ❌ Don't lower test thresholds
- ❌ Don't skip architecture review
- ❌ Don't cut corners for speed
- ❌ Don't create hardcoded solutions

✅ **Better to take longer and do it RIGHT**

---

**Ready to Execute:** Session 291: BSI Supplement & Addendum Implementation

**Next Action:** Read `spec/fixtures/bsi/identifiers/full/supplement.txt`