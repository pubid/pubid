// ... create new file ...
# Session 129 Continuation Plan: IEEE Parser Enhancement - Implement Patterns 1-5

**Created:** 2025-12-13 (Post-Session 128)
**Scope:** Implement TOP 5 priority parser patterns
**Timeline:** 90 minutes COMPRESSED
**Status:** Ready for execution

---

## Executive Summary

**Session 128 Achievement:** Complete failure analysis with 1,309 failures categorized into 10 patterns

**Session 129 Objective:** Implement highest-impact parser patterns to achieve 96-98% (target: 90%+)

**Current State:**
- IEEE: 8,231/9,537 (86.31%)
- Failures analyzed: 1,309 identifiers
- TOP 5 patterns selected
- Implementation specs ready

**Expected Results:**
- Conservative: +930-1,116 identifiers → 96.1-98.0%
- Optimistic: +1,330-1,594 identifiers → 100.2-103.3%
- Target 90%+ SIGNIFICANTLY EXCEEDED

---

## Session 129 Implementation Order

### Pattern 1: Text Month Format (25 min) ⭐⭐⭐

**Priority:** HIGHEST - 831 identifiers (63.5% of all failures!)

**File:** `lib/pubid_new/ieee/parser.rb`

**Implementation:**
```ruby
# Add after existing year rule (around line 200)
rule(:year) { match('[0-9]').repeat(4, 4) }

rule(:month_text_full) do
  str("January") | str("February") | str("March") |
  str("April") | str("May") | str("June") |
  str("July") | str("August") | str("September") |
  str("October") | str("November") | str("December")
end

rule(:month_text_abbr) do
  str("Jan") | str("Feb") | str("Mar") | str("Apr") |
  str("May") | str("Jun") | str("Jul") | str("Aug") |
  str("Sep") | str("Sept") | str("Oct") | str("Nov") | str("Dec")
end

rule(:month_text) { month_text_full | month_text_abbr }

rule(:month_numeric) do
  match('[0-1]') >> match('[0-9]')
end

rule(:date_with_month_text) do
  month_text.as(:month) >> space >> year.as(:year)
end

rule(:date_with_month_numeric) do
  year.as(:year) >> str("-") >> month_numeric.as(:month)
end

# Replace existing date rule
rule(:date) do
  date_with_month_text | date_with_month_numeric | year.as(:year)
end
```

**Testing:**
```bash
cd spec/fixtures
ruby run_classify.rb ieee
# Expected: 8,981-9,062/9,537 (94.2-95.0%)
```

**Expected Gain:** +750-831 identifiers
**Risk:** Low (pure parser addition)

---

### Pattern 2: ISO/IEC/IEEE Copublisher (15 min)

**Priority:** HIGH - 241 identifiers

**File:** `lib/pubid_new/ieee/parser.rb` (around line 65)

**Implementation:**
```ruby
# Find and update copublisher rule
rule(:copublisher) do
  (
    str("/ISO/IEC") |        # Three-way (longest first)
    str("/IEC/ISO") |        # Reverse order
    str("/ISO") |            # Two-way
    str("/IEC") |            # Two-way
    str("/ANSI")             # ANSI variation
  ).as(:copublisher)
end
```

**Testing:**
```bash
# Spot test
echo ISO/IEC/IEEE FDIS 8802-1AB/Amd4, March 2017 | \
  ruby -I lib -r pubid_new/ieee -e "puts PubidNew::Ieee.parse(STDIN.read).to_s"
```

**Expected Gain:** +200-241 identifiers
**Risk:** Low
**Dependencies:** Builder may need updates for three copublishers

---

### Pattern 3: IEEE P Prefix Complex (20 min)

**Priority:** HIGH - 272 identifiers

**File:** `lib/pubid_new/ieee/parser.rb` (around line 85)

**Implementation:**
```ruby
# Update P prefix to make space optional
rule(:ieee_p_prefix) do
  str("IEEE P") >> space.maybe
end

# Find and update draft_version rule
rule(:draft_version) do
  (
    # D3.1 format (decimal)
    str("D") >> match('[0-9]').repeat(1, 2) >>
    (str(".") >> match('[0-9]').repeat(1, 2)).maybe |

    # Draft 3 format (text)
    str("Draft ") >> match('[0-9]').repeat(1, 2) |

    # D[0-9] basic
    str("D") >> match('[0-9]').repeat(1, 2)
  ).as(:draft)
end

# Add new revision_notation rule (if not exists)
rule(:revision_notation) do
  (
    str("_Rev") | str("-rev") | str("/D")
  ) >> match('[0-9]').repeat(0, 2)
end
```

**Testing:**
```bash
# Test D3.1 format
ruby -I lib -r pubid_new/ieee -e \
  "puts PubidNew::Ieee.parse('IEEE P1588/D1.4V4, September 2018').to_s"
```

**Expected Gain:** +200-272 identifiers (includes Pattern 5)
**Risk:** Low

---

### Pattern 4: Missing "IEEE Std" Prefix (15 min)

**Priority:** HIGH - ~250 identifiers

**File:** `lib/pubid_new/ieee/parser.rb` (around line 55)

**Implementation:**
```ruby
# Find and update prefix rules
rule(:ieee_prefix) do
  (
    str("IEEE Std") >> space |
    str("IEEE") >> space |
    str("").as(:no_prefix)  # Allow no prefix
  ).maybe.as(:prefix)
end

# Update main identifier rule to use ieee_prefix
rule(:identifier) do
  ieee_prefix >> number >> ...  # Update primary pattern
end
```

**CAUTION:**
- This is MEDIUM RISK - could match too broadly
- Test incrementally
- May need to add guards to number patterns

**Testing:**
```bash
# Test without prefix
ruby -I lib -r pubid_new/ieee -e \
  "puts PubidNew::Ieee.parse('802.11ba').to_s"

# Verify doesn't break existing
bundle exec rspec spec/pubid_new/ieee/identifiers/base_spec.rb
```

**Expected Gain:** +180-250 identifiers
**Risk:** Medium

---

### Pattern 5: Draft D3.1 Format

**Note:** Already covered in Pattern 3 (draft_version rule)
**Expected Gain:** Included in Pattern 3 total
**No additional work needed**

---

## Testing & Validation (15 min)

### Step 1: Quick Validation After Each Pattern (3 min each)

After EACH pattern implementation:
```bash
cd spec/fixtures
ruby run_classify.rb ieee | tail -5
```

Watch for:
- Passing count increase
- No major regressions
- Error messages

### Step 2: Comprehensive Testing (15 min at end)

```bash
# Full IEEE fixtures classification
cd spec/fixtures
ruby run_classify.rb ieee

# Unit tests
cd ../..
bundle exec rspec spec/pubid_new/ieee/

# Verify no regressions in other flavors
cd spec/fixtures
ruby run_classify.rb iso | tail -3
ruby run_classify.rb iec | tail -3
```

**Success Criteria:**
- IEEE: 9,161-9,448/9,537 (96.1-99.0%)
- All unit tests passing (28/28 expected)
- Zero regressions in ISO/IEC

---

## Implementation Timeline

| Step | Task | Duration | Cumulative | Expected Gain |
|------|------|----------|------------|---------------|
| 1 | Pattern 1: Month Format | 25 min | 25 min | +750-831 |
| 2 | Test Pattern 1 | 3 min | 28 min | - |
| 3 | Pattern 2: Copublisher | 15 min | 43 min | +200-241 |
| 4 | Test Pattern 2 | 3 min | 46 min | - |
| 5 | Pattern 3: P Complex | 20 min | 66 min | +200-272 |
| 6 | Test Pattern 3 | 3 min | 69 min | - |
| 7 | Pattern 4: Optional Prefix | 15 min | 84 min | +180-250 |
| 8 | Test Pattern 4 | 3 min | 87 min | - |
| 9 | Final Comprehensive Testing | 15 min | 102 min | - |
| 10 | Commit & Document | 8 min | 110 min | - |

**Target:** 90 minutes compressed to fit in session
**Actual:** 110 minutes with buffers (20 min over - acceptable)

---

## Commit Message Template

```bash
git add lib/pubid_new/ieee/parser.rb
git commit -m "feat(ieee): implement parser patterns 1-4 - Session 129

Pattern 1: Text Month Format (+XXX identifiers)
- Add support for full month names (January, February, etc.)
- Add support for month abbreviations (Jan, Feb, etc.)
- Add support for numeric month format (YYYY-MM)

Pattern 2: ISO/IEC/IEEE Copublisher (+XXX identifiers)
- Add support for three-way copublisher
- Handle both ISO/IEC/IEEE and IEC/ISO/IEEE orders

Pattern 3: IEEE P Prefix Complex (+XXX identifiers)
- Support D3.1 decimal draft format
- Support revision notations (_Rev, -rev)
- Make space after P optional

Pattern 4: Optional IEEE Prefix (+XXX identifiers)
- Make 'IEEE Std' prefix optional
- Allow identifiers without IEEE prefix
- Maintain specificity to avoid false matches

Pattern 5: Draft D3.1 (included in Pattern 3)

IEEE: X,XXX/9,537 (XX.XX%) - was 8,231/9,537 (86.31%)
Improvement: +XXX identifiers (+X.XXpp)

Architecture: Parser patterns only, no structural changes
Testing: All unit tests passing, no regressions in ISO/IEC
Target: 90%+ achieved (actual: XX.XX%)

Analysis: session-128-continuation-plan.md
Specs: /tmp/ieee_pattern_analysis.md"
```

---

## Success Criteria

### Minimum Success (90%)
- ✅ IEEE at 90%+ (8,583+/9,537)
- ✅ All 4 patterns implemented
- ✅ No regressions in other flavors
- ✅ Unit tests passing

### Target Success (96%)
- ✅ IEEE at 96%+ (9,155+/9,537)
- ✅ All patterns working correctly
- ✅ Round-trip fidelity maintained
- ✅ Clean architecture preserved

### Stretch Success (98%)
- ✅ IEEE at 98%+ (9,346+/9,537)
- ✅ Patterns optimized
- ✅ Comprehensive testing complete
- ✅ Ready for Session 130

---

## Risk Mitigation

**Pattern 4 (Optional Prefix) - MEDIUM RISK:**
- Could match too broadly without IEEE prefix
- **Mitigation:** Test after implementation, add guards if needed
- **Rollback:** Comment out optional prefix if issues arise

**All Patterns - LOW RISK:**
- Pure parser additions
- No structural changes
- Incremental testing catches issues early

**Other Flavors - ZERO RISK:**
- No changes to ISO, IEC, NIST, etc.
- Verify with quick classification check

---

## Architecture Principles

**MAINTAIN throughout:**
1. **MODEL-DRIVEN** - Parser layer only
2. **MECE** - Each pattern mutually exclusive
3. **Three-layer separation** - No Builder/Identifier changes
4. **Incremental** - Test after each pattern
5. **No regressions** - Other flavors unchanged
6. **Architecture first** - Correctness over test count

---

## Next Steps After Session 129

**If 96%+ achieved:**
- Optional: Session 130 for Patterns 6-8 (could reach 99%)
- Alternative: Move to documentation (Sessions 134-135)
- Alternative: Start Phase 2 (Historical AIEE/IRE patterns)

**If 90-96% achieved:**
- Continue to Session 130 as planned
- Patterns 6-8 will close the gap

**If <90% achieved:**
- Analyze why patterns didn't work as expected
- Debug and fix issues
- May need to reassess pattern estimates

---

## Files to Modify

**Primary:**
- `lib/pubid_new/ieee/parser.rb` - All 4 pattern implementations

**Testing:**
- Run classification: `spec/fixtures/run_classify.rb ieee`
- Run unit tests: `spec/pubid_new/ieee/`

**Documentation (after Session 129):**
- `.kilocode/rules/memory-bank/context.md` - Update IEEE metrics
- Optional: Create `docs/IEEE_PARSER_ENHANCEMENTS.md`

---

## Reference Files

**Analysis Document:** `/tmp/ieee_pattern_analysis.md` (Session 128 output)
**Session 128 Plan:** `.kilocode/rules/memory-bank/session-128-continuation-plan.md`
**Memory Bank:** `.kilocode/rules/memory-bank/context.md`

---

**Created:** 2025-12-13
**Session:** 129
**Status:** Ready for execution
**Timeline:** 90-110 minutes compressed

**Expected Result:** IEEE at 96%+ (target: 90%+) - SIGNIFICANTLY EXCEEDED! 🚀