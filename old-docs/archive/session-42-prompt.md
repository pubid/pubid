# Session 42 Starting Prompt

**Goal:** Investigate edge cases and plan path to 85% milestone

**Current Status:** 83.1% (2,377/2,859 passing tests)  
**Target:** 85% (2,430+ passing tests) - need +53 tests  
**Previous Session:** Session 41 - DAD supplement parsing (Builder workaround, +14 tests, zero regressions)

---

## Session 42 Objectives

### Primary Goal: Edge Case Discovery (60-90 min)

1. **Analyze identifier specs for near-success patterns** (20-30 min)
   - Check all identifier type specs for patterns close to passing
   - Look for similar patterns to DAD that might benefit from Builder workarounds
   - Focus on specs with small failure counts (1-5 failures)

2. **Review parser_spec for opportunities** (15-20 min)
   - Check if any parser patterns are fixable without parser modifications
   - Identify patterns that could use pre-processing approach

3. **Document findings** (15-20 min)
   - List 3-5 highest-value targets
   - Estimate effort and expected test gain for each
   - Prioritize by effort/reward ratio

4. **Create action plan for Sessions 43-44** (10-15 min)
   - Sequence fixes by priority
   - Estimate sessions needed
   - Document approach for each fix

---

## Context from Session 41

### What Worked

**Builder Workaround Pattern (100% success rate):**
```ruby
def self.parse(identifier)
  # 1. Detect special pattern with regex
  if match = identifier.match(/^(.+?)\/(F?DAD)\s+(\d+)(?::(\d{4}))?$/)
    # 2. Parse base identifier separately
    base = parser.parse(base_str) |> builder.build()
    
    # 3. Construct supplement manually
    supplement = Identifiers::Addendum.new
    supplement.base_identifier = base
    supplement.number = Components::Code.new(number: supplement_number)
    supplement.date = PubidNew::Components::Date.new(year: year) if year
    
    # 4. Use register for TypedStage
    typed_stage = Scheme.locate_typed_stage_by_abbr(stage_abbr)
    supplement.typed_stage = typed_stage
    supplement.stage = typed_stage.to_stage
    supplement.type = typed_stage.to_type
    
    return supplement
  end
  
  # Normal parsing
end
```

**Why This Works:**
- Zero parser modifications → zero risk of regressions
- Parser never sees problematic pattern
- Uses existing architecture (Components, register)
- Can handle edge cases explicitly

**Previous Applications:**
- Session 38: Legacy hyphen format (+3 tests, 0 regressions)
- Session 41: DAD supplement parsing (+14 tests, 0 regressions)

### Current Test Status

**Functional Tests:** 2,373 passing (100% of non-pending)  
**Performance Tests:** 4 passing, 2 timing variations (acceptable)  
**Pending Tests:** 480 (URN: 377, V1/V2: 101, other: 2)

**No functional failures remaining** ✅

---

## Investigation Strategy

### Step 1: Quick Survey (15 min)

Run these commands to get overview:

```bash
# Get failure breakdown by spec
cd /Users/mulgogi/src/mn/pubid
bundle exec rspec spec/pubid_new/iso/ --format documentation 2>&1 | \
  grep -E "^\s+\w+.*\(FAILED" | \
  cut -d'(' -f1 | \
  sort | uniq -c | sort -rn

# Check if any identifier specs have failures
for spec in spec/pubid_new/iso/identifiers/*_spec.rb; do
  echo "=== $(basename $spec) ==="
  bundle exec rspec "$spec" --format progress 2>&1 | grep "examples,"
done

# Check parser_spec status
bundle exec rspec spec/pubid_new/iso/parser_spec.rb --format progress 2>&1 | grep "examples,"
```

### Step 2: Deep Dive (30 min)

For each spec with remaining opportunities:

1. **Examine test patterns**
   ```bash
   bundle exec rspec spec/pubid_new/iso/identifiers/SPEC_NAME_spec.rb \
     --format documentation --only-failures
   ```

2. **Check if pattern is detectable**
   - Can we identify it with regex before parser?
   - Is it similar to DAD pattern?
   - Would Builder workaround work?

3. **Estimate complexity**
   - How many test cases?
   - How complex is the pattern?
   - Risk of regressions?

### Step 3: Document Findings (20 min)

Create analysis document with:

```markdown
## Edge Case Analysis

### Opportunity 1: [Pattern Name]
- **Tests affected:** X
- **Pattern:** "example identifier string"
- **Root cause:** Brief explanation
- **Proposed fix:** Builder workaround / Other
- **Estimated effort:** LOW/MEDIUM/HIGH
- **Expected gain:** +X tests
- **Risk level:** LOW/MEDIUM/HIGH
- **Priority:** 1-5 (1=highest)

### Opportunity 2: ...
```

---

## Decision Points

### If 3-5 Good Targets Found
→ **Proceed with Sessions 43-44** implementing fixes  
→ **Expected outcome:** 85% milestone achieved

### If <3 Targets Found
→ **Consider alternative paths:**
- URN generation (377 tests, Phase 5 work)
- Apply patterns to other flavors (IEC, IEEE, NIST)
- Performance test threshold adjustment

### If Any Targets Require Parser Changes
→ **PAUSE and reassess**  
→ Session 40 showed parser changes cause 150+ regressions  
→ Only proceed if absolutely necessary and well-analyzed

---

## Tools and Commands

### Analyze Specific Identifier Type
```bash
# Full output with context
bundle exec rspec spec/pubid_new/iso/identifiers/amendment_spec.rb \
  --format documentation 2>&1 | less

# Just the failures
bundle exec rspec spec/pubid_new/iso/identifiers/amendment_spec.rb \
  --format documentation --only-failures

# Count by failure type
bundle exec rspec spec/pubid_new/iso/identifiers/amendment_spec.rb \
  --format documentation 2>&1 | \
  grep "Failure/Error:" | sort | uniq -c | sort -rn
```

### Check Parser Patterns
```bash
# Parser test overview
bundle exec rspec spec/pubid_new/iso/parser_spec.rb \
  --format documentation 2>&1 | grep -E "^\s+\w+" | head -50

# Non-pending parser tests
bundle exec rspec spec/pubid_new/iso/parser_spec.rb \
  --format progress --tag ~pending 2>&1 | grep "examples,"
```

### Test Specific Pattern
```bash
# Test single example
bundle exec rspec spec/pubid_new/iso/identifiers/SPEC:LINE_NUMBER

# Test with parser trace (for debugging)
PARSLET_DEBUG=1 bundle exec rspec spec/path/SPEC:LINE
```

---

## Success Criteria

By end of Session 42:

1. ✅ Comprehensive analysis of remaining test failures complete
2. ✅ 3-5 edge case targets identified and documented
3. ✅ Each target has:
   - Clear pattern description
   - Proposed fix approach
   - Effort/reward estimate
   - Priority ranking
4. ✅ Action plan for Sessions 43-44 documented
5. ✅ Decision made on path to 85% milestone

---

## Files to Reference

**Must Read:**
- `.kilocode/rules/memory-bank/context.md` - Current status
- `.kilocode/rules/memory-bank/architecture.md` - Architecture principles
- `docs/continuation-plan-session-42.md` - This session's plan
- `docs/implementation-status.md` - Overall status tracker

**Useful References:**
- `docs/session-40-detailed-findings.md` - Parser investigation lessons
- `docs/session-41-prompt.md` - Previous session's approach
- `lib/pubid_new/iso.rb` - Current parse() implementation with DAD workaround

---

## Important Reminders

### DO:
- ✅ Use Builder workarounds when possible (proven pattern)
- ✅ Check TYPED_STAGES register before assuming missing data
- ✅ Test after every change
- ✅ Document patterns discovered
- ✅ Prioritize LOW RISK approaches

### DON'T:
- ❌ Modify parser unless absolutely necessary (Session 40: 150+ regressions)
- ❌ Hardcode logic (use registers and lookups)
- ❌ Make speculative changes without data
- ❌ Skip analysis phase (premature optimization)
- ❌ Compromise architecture for quick gains

---

## Expected Outcomes

### Optimistic (Best Case)
- 5+ high-value targets identified
- Clear path to 85% milestone
- 2 sessions to complete (43-44)
- +53 tests achievable

### Realistic (Expected Case)
- 3-5 targets identified
- Path to 85% viable
- 2-3 sessions to complete
- +40-53 tests achievable

### Conservative (Worst Case)
- 1-2 targets identified
- 85% challenging from edge cases alone
- Need to consider URN generation
- Alternative path planning needed

---

## Next Session Preview

**If Session 42 Succeeds:**
- Session 43: Implement 2-3 highest-priority fixes
- Session 44: Complete remaining fixes, achieve 85%
- Session 45+: Begin URN generation (Phase 5)

**Session 42 is critical for Phase 4 success!**

Good luck! 🚀