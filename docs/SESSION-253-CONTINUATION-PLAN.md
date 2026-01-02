# Session 253 Continuation Plan: NIST IR Corrections

**Created:** 2026-01-02 (Post-Session 252)
**Status:** Session 252 complete - Critical NIST IR corrections needed
**Priority:** HIGH - Semantic naming error + draft pattern failure
**Timeline:** 90 minutes

---

## Critical Issues Discovered

### Issue 1: Incorrect Class Name ❌

**Current:** `InternalReport` (line 13 of internal_report.rb)
**Correct:** `InteragencyReport`

**Impact:** Semantic error - IR = **Interagency** Report, NOT Internal Report!

### Issue 2: Draft Pattern Not Parsing ❌

**Input:** `NIST IR 8270-draft2`
**Expected output:** `NIST IR 8270 2pd`
**Current status:** Parse failure

**Pattern semantics:**
- `-draft2` = 2nd preliminary draft
- Should render as ` 2pd` (public draft notation)
- This is a **stage representation**, not a suffix

### Issue 3: pd_suffix Rendering

**Current parser** (line 627-628):
```ruby
rule(:pd_suffix) do
  (space >> digits >> str("pd")).as(:public_draft)
end
```

This matches ` 2pd` in input but doesn't handle `-draft2` → ` 2pd` transformation.

---

## Root Cause Analysis

**Parser preprocessing** (line 62):
```ruby
cleaned = cleaned.gsub(/(\d)-draft(\d)/, '\1-draft \2')
```
✅ Converts `-draft2` → `-draft 2` correctly

**Parser draft rule** (line 632-636):
```ruby
rule(:draft) do
  (space >> str("(Draft)") |
   dash >> str("draft") >> (space >> digits | digits).maybe |
   pd_suffix).as(:draft)
end
```
✅ Should match `-draft 2`

**Problem:** Draft rule is checked in `parts.repeat` which comes AFTER `report_number`. The draft portion may be consumed by report_number parsing or skipped entirely.

**Solution:** Need to ensure draft is properly captured and rendered as stage.

---

## Session 253 Implementation Plan

### Part A: Rename Class (20 min)

**Files to modify:**
1. `lib/pubid_new/nist/identifiers/internal_report.rb` (line 8, 13)
2. `lib/pubid_new/nist/scheme.rb` (line 6, 36, 61)

**Actions:**
- Rename class: `InternalReport` → `InteragencyReport`
- Update comments: "Internal Report" → "Interagency Report"
- Update require statements
- Update registry mapping

**Testing:**
```bash
bundle exec rspec spec/pubid_new/nist/identifiers/ -e "IR"
```

---

### Part B: Fix Draft Pattern Parsing (30 min)

**Problem:** `-draft 2` not being captured properly

**Solution:** Enhance draft rule priority and capture

**File:** `lib/pubid_new/nist/parser.rb`

**Update draft rule** (around line 632):
```ruby
# Draft stage - enhanced for -draft{N} → {N}pd transformation
rule(:draft) do
  (
    # Parenthetical draft marker
    space >> str("(Draft)") |
    # Draft with number: -draft 2, -draft2 (after preprocessing becomes -draft 2)
    # Capture the number separately for pd rendering
    dash >> str("draft") >> space >> digits.as(:draft_number) |
    # Draft without number
    dash >> str("draft") |
    # pd suffix (already in input)
    pd_suffix
  ).as(:draft)
end
```

**Update identifier rule** (ensure draft is checked):
- Already in `parts.repeat` - verify it's being reached

---

### Part C: Fix Draft Rendering (30 min)

**Current:** Draft stored as string
**Required:** Draft rendered as `{N}pd` format

**File:** `lib/pubid_new/nist/identifiers/base.rb`

**Update to_s method** to handle draft rendering:
```ruby
def to_s
  # ... existing code ...
  
  # Draft rendering
  if draft
    if draft.is_a?(Hash) && draft[:draft_number]
      parts << "#{draft[:draft_number]}pd"
    elsif draft =~ /^-draft\s+(\d+)$/
      parts << "#{$1}pd"
    else
      parts << draft  # Fallback for other draft formats
    end
  end
  
  # ... rest of code ...
end
```

**Alternative:** Create Stage component with draft_number

---

### Part D: Builder Enhancement (10 min)

**File:** `lib/pubid_new/nist/builder.rb`

**Add draft casting:**
```ruby
when :draft
  return nil if value.nil?
  
  # If draft is a hash with draft_number, extract it
  if value.is_a?(Hash) && value[:draft_number]
    { public_draft: value[:draft_number].to_s }
  else
    # Simple string value
    value.to_s.strip
  end

when :draft_number
  # Captured as part of :draft
  nil
```

---

## Testing Strategy

### Test Cases

**Input:** `NIST IR 8270-draft2`
**Expected:**
```ruby
id = PubidNew::Nist.parse("NIST IR 8270-draft2")
id.class         # => InteragencyReport (renamed!)
id.series.value  # => "IR"
id.number.value  # => "8270"
id.public_draft  # => "2"
id.to_s          # => "NIST IR 8270 2pd"
```

### Regression Tests

Run full NIST test suite to ensure no regressions:
```bash
bundle exec rspec spec/pubid_new/nist/
cd spec/fixtures && ruby run_classify.rb nist
```

**Expected:** 19,822/19,826 maintained or improved (target: 19,823/19,826)

---

## Success Criteria

### Minimum (80%)
- ✅ Class renamed to InteragencyReport
- ✅ `NIST IR 8270-draft2` parses
- ✅ Renders as `NIST IR 8270 2pd`
- ✅ No regressions in existing tests

### Target (90%)
- ✅ All draft patterns working
- ✅ Proper stage representation
- ✅ Clean MODEL-DRIVEN implementation
- ✅ Tests updated with new class name

### Stretch (100%)
- ✅ Comprehensive test coverage
- ✅ Documentation updated
- ✅ NIST at 99.99% (19,823+/19,826)

---

## Files to Modify

1. `lib/pubid_new/nist/identifiers/internal_report.rb` - Rename class
2. `lib/pubid_new/nist/scheme.rb` - Update registry
3. `lib/pubid_new/nist/parser.rb` - Enhance draft rule
4. `lib/pubid_new/nist/builder.rb` - Add draft casting
5. `lib/pubid_new/nist/identifiers/base.rb` - Update rendering

## Files to Create

1. `spec/pubid_new/nist/identifiers/interagency_report_spec.rb` - Update tests

---

## Architecture Principles

**MAINTAIN:**
1. MODEL-DRIVEN - Objects not strings
2. MECE - One class per series type
3. Three-layer - Parser/Builder/Identifier independence
4. Semantic correctness - Names must match reality

**NO COMPROMISES on architecture quality.**

---

## Timeline

| Task | Duration | Deliverable |
|------|----------|-------------|
| Part A: Rename class | 20 min | InteragencyReport |
| Part B: Parser draft | 30 min | -draft{N} parsing |
| Part C: Rendering | 30 min | {N}pd output |
| Part D: Builder | 10 min | Draft casting |
| **Total** | **90 min** | **Complete** |

---

## Next Steps

1. Read this plan
2. Rename InternalReport → InteragencyReport
3. Update parser draft rule
4. Update base.rb rendering
5. Update builder draft casting
6. Test and validate
7. Commit changes

---

**Created:** 2026-01-02
**Priority:** HIGH
**Estimated:** 90 minutes
**Goal:** Fix semantic naming + draft pattern parsing

**Status:** Ready for Session 253 execution! 🚀
