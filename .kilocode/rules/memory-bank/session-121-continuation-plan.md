# Session 121+ Continuation Plan: IEEE Parser Enhancement to 90%+

**Created:** 2025-12-11 (Post-Session 120)
**Status:** IEEE at 84.76% (8,084/9,537) - Target 90%+ (8,583+)
**Timeline:** COMPRESSED - 2-3 sessions maximum
**Gap to Close:** +499 identifiers (5.24 percentage points)

---

## Executive Summary

**Current State:**
- IEEE: 8,084/9,537 passing (84.76%)
- Architecture: Perfect (TYPED_STAGE, Joint Development complete)
- Gap: 1,453 failures → need +499 to reach 90%

**Strategy:** Systematic parser enhancement focusing on highest-impact patterns

**Target:** 90%+ (8,583+/9,537) within 2-3 sessions

---

## SESSION 121: Failure Analysis & Top Patterns (60 min)

### Objective
Analyze all 1,453 failures, identify top patterns, prioritize fixes

### Phase 1: Extract and Categorize Failures (20 min)

**Action 1: Extract all failures**
```bash
cd spec/fixtures/ieee/identifiers
cat fail/*.txt | sed 's/#\([^#]*\)#.*/\1/' > /tmp/ieee_all_failures.txt
wc -l /tmp/ieee_all_failures.txt  # Should be ~1,453
```

**Action 2: Sample and categorize**
```bash
# Take first 500 for detailed analysis
head -500 /tmp/ieee_all_failures.txt > /tmp/ieee_sample_500.txt

# Group by pattern
cat /tmp/ieee_sample_500.txt | \
  sed 's/IEEE Std //' | \
  sed 's/IEEE //' | \
  sed 's/P[0-9].*/P{NUMBER}/' | \
  sed 's/D[0-9].*/D{NUM}/' | \
  sed 's/[0-9]\{4\}/YEAR/' | \
  sort | uniq -c | sort -rn | head -30
```

**Action 3: Classify pattern types**

Document each pattern type with:
- Pattern description
- Example identifiers (2-3)
- Estimated count in failures
- Complexity (Low/Medium/High)
- Impact (High/Medium/Low)

**Expected pattern types:**
1. Missing "IEEE Std" prefix variations
2. Draft notation edge cases (D3.1, Draft 3, etc.)
3. Month format in dates (2013-06, June 2013)
4. Historical patterns (AIEE, IRE prefixes)
5. Complex parenthetical notations
6. Adoption format variations
7. Multiple copublisher formats
8. Special committee patterns
9. Revision notation variations
10. Code format edge cases

### Phase 2: Prioritize & Select Top 5 (15 min)

**Prioritization Matrix:**

| Pattern | Count | Complexity | Impact | Priority |
|---------|-------|------------|--------|----------|
| Pattern 1 | Est. | Low/Med/High | High/Med/Low | Score |
| ... | ... | ... | ... | ... |

**Priority Formula:** `Priority = (Count * 2) + (Impact * 10) - (Complexity * 5)`

**Select top 5 patterns** for implementation based on:
1. Highest count (most failures)
2. Lowest complexity (fastest to fix)
3. Highest impact (enables other patterns)

### Phase 3: Create Implementation Plan (25 min)

**For each of top 5 patterns, document:**

1. **Pattern Name**
2. **Current Parser Behavior** (what fails)
3. **Required Parser Change** (specific rule update)
4. **Expected Gain** (estimated identifiers fixed)
5. **Implementation Time** (15-30 min estimate)
6. **Test Strategy** (how to verify)

**Example Template:**

```markdown
### Pattern 1: Missing "IEEE Std" Prefix

**Current Behavior:** Parser requires "IEEE Std" or "IEEE"
**Failing Examples:**
- C37.111-2013
- P1234/D5
- 802.11-2020

**Required Change:**
lib/pubid_new/ieee/parser.rb line XX:
rule(:ieee_prefix) do
  str("IEEE Std") | str("IEEE")
end

CHANGE TO:
rule(:ieee_prefix) do
  (str("IEEE Std") | str("IEEE")).maybe
end

**Expected Gain:** +200-300 identifiers
**Time:** 15 minutes
**Testing:** Run classification, verify no regressions
```

### Deliverables
- `/tmp/ieee_failure_analysis.md` - Complete analysis
- Top 5 patterns with implementation specs
- Estimated total gain (should be 500-700+ identifiers)

---

## SESSION 122: Implement Top 3 Patterns (90 min)

### Objective
Implement highest-priority patterns to achieve 87-88%

### Pre-Implementation Checklist
- [ ] Read current parser: `lib/pubid_new/ieee/parser.rb`
- [ ] Backup current state: `git stash`
- [ ] Baseline test: `cd spec/fixtures && ruby run_classify.rb ieee`

### Pattern Implementation (3 x 25 min = 75 min)

**For EACH pattern:**

**Step 1: Understand Current Code (5 min)**
- Read relevant parser rules
- Understand why pattern fails
- Check for side effects

**Step 2: Implement Fix (15 min)**
- Modify parser rule(s)
- Follow Parslet patterns
- Maintain MECE principles
- Add inline comments

**Step 3: Test & Verify (5 min)**
```bash
cd spec/fixtures
ruby run_classify.rb ieee

# Check improvement
# Expected: +150-250 per pattern
```

### Pattern 1: [Name from Analysis]
**Implementation:** [Specific code changes]
**Testing:** [Verification steps]
**Expected:** +200-300 identifiers

### Pattern 2: [Name from Analysis]
**Implementation:** [Specific code changes]
**Testing:** [Verification steps]
**Expected:** +150-250 identifiers

### Pattern 3: [Name from Analysis]
**Implementation:** [Specific code changes]
**Testing:** [Verification steps]
**Expected:** +100-200 identifiers

### Post-Implementation (15 min)

**Comprehensive Testing:**
```bash
# Full classification
cd spec/fixtures
ruby run_classify.rb ieee

# Verify other flavors not affected
ruby run_classify.rb iso
ruby run_classify.rb iec
ruby run_classify.rb nist

# Run IEEE unit tests
cd ../..
bundle exec rspec spec/pubid_new/ieee/
```

**Expected Result:**
- IEEE: 8,534/9,537 (89.5%) or better
- No regressions in other flavors
- All unit tests passing

**Commit:**
```bash
git add lib/pubid_new/ieee/parser.rb
git commit -m "feat(ieee): implement top 3 parser patterns - Session 122

Pattern 1: [Description] (+XXX identifiers)
Pattern 2: [Description] (+XXX identifiers)
Pattern 3: [Description] (+XXX identifiers)

IEEE: X,XXX/9,537 (XX.XX%) - was 8,084/9,537 (84.76%)
Improvement: +XXX identifiers (+X.XXpp)

Architecture: No changes, parser patterns only
Testing: All unit tests passing, no regressions"
```

---

## SESSION 123: Implement Patterns 4-5 & Achieve 90%+ (90 min)

### Objective
Complete remaining high-priority patterns to exceed 90%

### Implementation (2 x 30 min = 60 min)

**Pattern 4 Implementation (30 min)**
- Same process as Session 122
- Expected: +100-150 identifiers

**Pattern 5 Implementation (30 min)**
- Same process as Session 122
- Expected: +50-100 identifiers

### Final Validation (20 min)

**Comprehensive Testing:**
```bash
# IEEE classification
cd spec/fixtures
ruby run_classify.rb ieee

# All flavors regression check
for flavor in iso iec jcgm nist; do
  echo "=== $flavor ==="
  ruby run_classify.rb $flavor | tail -3
done

# Unit tests
cd ../..
bundle exec rspec spec/pubid_new/ieee/
```

**Target Metrics:**
- IEEE: 8,583+/9,537 (90%+)
- All other flavors: No regressions
- Unit tests: All passing

### Documentation Update (10 min)

**Update files:**
1. `.kilocode/rules/memory-bank/context.md` - IEEE metrics
2. `docs/PROJECT_STATUS.md` - Session 123 completion
3. `docs/IEEE_ARCHITECTURE.md` (create if needed)

**Final Commit:**
```bash
git add -A
git commit -m "feat(ieee): achieve 90%+ parser rate - Sessions 121-123 COMPLETE

Pattern 4: [Description] (+XXX identifiers)
Pattern 5: [Description] (+XXX identifiers)

Final Results:
- IEEE: X,XXX/9,537 (XX.XX%)
- Improvement from Session 120: +XXX identifiers (+X.XXpp)
- Total improvement from baseline: +XXX identifiers

All Patterns Implemented:
1. Pattern 1: [Name] (+XXX)
2. Pattern 2: [Name] (+XXX)
3. Pattern 3: [Name] (+XXX)
4. Pattern 4: [Name] (+XXX)
5. Pattern 5: [Name] (+XXX)

Architecture: Clean parser enhancements only
Testing: All tests passing, no regressions
Status: IEEE 90%+ ACHIEVED"
```

---

## Implementation Status Tracker

### Session 121: Analysis ⏳
- [ ] Extract all 1,453 failures
- [ ] Categorize into pattern types
- [ ] Create prioritization matrix
- [ ] Select top 5 patterns
- [ ] Document implementation specs
- [ ] Estimate total gain (500-700+)

### Session 122: Top 3 Patterns ⏳
- [ ] Pattern 1 implementation (+200-300)
- [ ] Pattern 2 implementation (+150-250)
- [ ] Pattern 3 implementation (+100-200)
- [ ] Testing & validation
- [ ] Target: 87-88% achieved
- [ ] Commit & document

### Session 123: Patterns 4-5 & 90%+ ⏳
- [ ] Pattern 4 implementation (+100-150)
- [ ] Pattern 5 implementation (+50-100)
- [ ] Final validation
- [ ] Documentation updates
- [ ] Target: 90%+ ACHIEVED

---

## Expected Pattern Examples (To Be Confirmed in Session 121)

### Likely High-Impact Patterns

**1. Optional "IEEE Std" Prefix (~200-300 IDs)**
```ruby
# Current
rule(:ieee_prefix) { str("IEEE Std") | str("IEEE") }

# Enhanced
rule(:ieee_prefix) { (str("IEEE Std") | str("IEEE")).maybe }
```

**2. Draft Notation Variations (~150-250 IDs)**
```ruby
# Current
rule(:draft) { str("D") >> match('[0-9]').repeat(1) }

# Enhanced
rule(:draft) do
  (
    str("Draft ") >> match('[0-9]').repeat(1, 2) |
    str("D") >> match('[0-9]').repeat(1, 2) >> (str(".") >> match('[0-9]')).maybe
  ).as(:draft)
end
```

**3. Month Format Support (~100-200 IDs)**
```ruby
# Add month rule
rule(:month) do
  str("01") | str("02") | str("03") | str("04") |
  str("05") | str("06") | str("07") | str("08") |
  str("09") | str("10") | str("11") | str("12")
end

rule(:date_with_month) { year >> str("-") >> month }
rule(:date) { date_with_month | year }
```

**4. Parenthetical Flexibility (~100-150 IDs)**
```ruby
# Current: Strict parenthetical parsing
# Enhanced: More flexible adoption patterns
```

**5. Copublisher Variations (~50-100 IDs)**
```ruby
# Current: Limited copublisher support
# Enhanced: More copublisher combinations (IEEE/ISO, IEEE/IEC/ISO, etc.)
```

---

## Success Criteria

### Minimum (Sessions 121-122)
- ✅ Top 3 patterns implemented
- ✅ IEEE at 87-88% (8,284+/9,537)
- ✅ +200-700 identifiers gained
- ✅ No regressions in other flavors
- ✅ All unit tests passing

### Target (Sessions 121-123)
- ✅ Top 5 patterns implemented
- ✅ IEEE at 90%+ (8,583+/9,537)
- ✅ +499+ identifiers gained
- ✅ Clean architecture maintained
- ✅ Documentation updated

### Stretch (If time permits)
- ✅ IEEE at 92%+ (8,774+/9,537)
- ✅ 6-7 patterns implemented
- ✅ +690+ identifiers gained
- ✅ Historical patterns (AIEE/IRE) working

---

## Critical Architectural Principles

**MAINTAIN throughout ALL sessions:**

1. **Parser patterns only** - No builder/identifier changes
2. **MECE organization** - Each pattern mutually exclusive
3. **Longest match first** - Specific before general
4. **No hardcoding** - Use register-based solutions
5. **Incremental testing** - Test after each pattern
6. **No regressions** - Other flavors unaffected
7. **Architecture first** - Correctness over test count

**NO COMPROMISES on clean architecture.**

---

## Risk Mitigation

### Known Risks
1. **Pattern interaction** - New rules may conflict
2. **Over-generalization** - Too permissive patterns
3. **Regression** - Breaking existing working patterns
4. **Time estimates** - Patterns may be more complex

### Mitigation Strategies
1. **Test after each pattern** - Isolate issues
2. **Use `.maybe` carefully** - Don't make everything optional
3. **Run full test suite** - Catch regressions early
4. **Conservative estimates** - Better to under-promise

---

## Files to Modify

### Primary
- `lib/pubid_new/ieee/parser.rb` - All pattern implementations

### Documentation
- `.kilocode/rules/memory-bank/context.md` - Metrics update
- `docs/PROJECT_STATUS.md` - Session summaries
- `docs/IEEE_ARCHITECTURE.md` (optional) - Parser patterns

### No Changes To
- `lib/pubid_new/ieee/builder.rb` - Builder logic stays same
- `lib/pubid_new/ieee/identifiers/` - Identifier classes unchanged
- `lib/pubid_new/ieee/scheme.rb` - Registry unchanged
- Other flavor files - No cross-flavor changes

---

## Next Immediate Steps (Session 121)

1. Read this continuation plan
2. Extract all 1,453 IEEE failures to file
3. Sample and categorize failure patterns
4. Create prioritization matrix
5. Select top 5 patterns with implementation specs
6. Document expected gains and time estimates
7. Ready to begin Session 122 implementation

---

**Created:** 2025-12-11
**Sessions Covered:** 121-123
**Status:** Ready for execution
**Timeline:** 2-3 sessions (4.5 hours compressed)
**Goal:** IEEE 90%+ (8,583+/9,537)

**End Goal:** IEEE parser at production-ready 90%+ validation rate! 🚀