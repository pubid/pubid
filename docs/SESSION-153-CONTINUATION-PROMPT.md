# Session 153 Quick Start: CSA to 50%+ & API Implementation

**Read First:** `docs/SESSION-153-CONTINUATION-PLAN.md` (comprehensive plan)

---

## Session 153 Goal: CSA 50%+ & API Baseline (150 minutes)

### Context
Session 152 completed:
- **CSA:** 405/936 (43.3%) - Need +63 for 50%
- **Enhancements:** Year detection, ISO/IEC adoption, letter suffix, 4-digit years

---

## Part A: CSA Quick Wins (60 min)

### Step 1: CAN3- Prefix Support (20 min)

**File:** `lib/pubid_new/csa/identifier.rb`

Add after CAN/CSA- normalization:
```ruby
normalized = input.gsub(/CAN\/CSA-/, "CSA ")
normalized = normalized.gsub(/CAN3-/, "CSA ")  # NEW
```

**Expected:** +21 IDs

### Step 2: SERIES Keyword Fixes (15 min)

**File:** `lib/pubid_new/csa/parser.rb`

Update series_keyword rule:
```ruby
rule(:series_keyword) do
  space >> str("SERIES") >> 
  (space.maybe >> (colon | dash) | (colon | dash))
end
```

**Expected:** +16 IDs

### Step 3: Specialized Code Patterns (25 min)

Allow HB/CIICHB/SP suffixes in codes:
```ruby
rule(:code_pattern) do
  (
    letter >> match("[0-9]").repeat(1) >>
    (dot >> match("[0-9]").repeat(1)).repeat >>
    (dash >> match("[0-9]").repeat(1) >> letter).maybe >>
    (letters.repeat(2, 6)).maybe  # Allow HB, CIICHB, etc.
  ).as(:code)
end
```

**Expected:** +20-30 IDs

**Target after Part A:** 462-472/936 (49.4-50.4%) ✅

---

## Part B: API Base Implementation (90 min)

### Files to Create (13 files):

**Core (4 files):**
- `lib/pubid_new/api.rb`
- `lib/pubid_new/api/identifier.rb`
- `lib/pubid_new/api/parser.rb`
- `lib/pubid_new/api/builder.rb`

**Structure (2 files):**
- `lib/pubid_new/api/single_identifier.rb`
- `lib/pubid_new/api/components/code.rb`

**Identifiers (10 files):**
- `lib/pubid_new/api/identifiers/base.rb`
- `lib/pubid_new/api/identifiers/bulletin.rb`
- `lib/pubid_new/api/identifiers/mpms.rb`
- `lib/pubid_new/api/identifiers/recommended_practice.rb`
- `lib/pubid_new/api/identifiers/specification.rb`
- `lib/pubid_new/api/identifiers/standard.rb`
- `lib/pubid_new/api/identifiers/technical_report.rb`
- `lib/pubid_new/api/identifiers/continuous_operations_standard.rb`
- `lib/pubid_new/api/identifiers/publication.rb`
- `lib/pubid_new/api/identifiers/typeless_standard.rb`

### Parser Pattern:
```ruby
rule(:doc_type) do
  str("MPMS") | str("BULL") | str("SPEC") | str("STD") |
  str("RP") | str("TR") | str("COS") | str("PUBL")
end

rule(:mpms_chapter) { space >> str("CH") >> space >> digits }
```

**Target:** 150-170/198 (76-86%)

---

## Testing

```bash
# CSA validation
ruby -I lib /tmp/test_csa_full.rb

# API validation (create similar script)
ruby -I lib /tmp/test_api_full.rb
```

---

Good luck with Session 153! 🚀