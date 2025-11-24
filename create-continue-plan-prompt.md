# Session 16 Continuation Plan - ISO V2 Data-Driven Test Completion

## Current Status (Session 15 Complete)

**Test Results:**
- 1,316 passing (46.0%)
- 797 failures (27.9%)
- 746 pending (26.1%)
- Total: 2,859 examples
- Core tests: 106/106 passing ✅

**Recent Progress:**
- Session 13: +9 tests (0.3pp)
- Session 14: +80 tests (2.8pp) ⚡
- Session 15: +4 tests (0.1pp) ⚠️

## Session 15 Key Lesson

**CRITICAL INSIGHT:** Speculative pattern additions yield minimal results (+4 tests).

The batch approach from the compressed continuation plan had limited impact because:
- FCorr, enhanced edition, dash-year patterns are valid but not frequently failing
- Without failure analysis, we fixed patterns that weren't causing failures
- Must analyze actual test failures BEFORE implementing fixes

**New Strategy:** Data-driven improvements based on failure pattern analysis

## Session 16 Strategy - FAILURE ANALYSIS FIRST

### Phase 1: Systematic Failure Analysis (30 minutes)

**Before writing ANY code**, analyze the 797 failing tests:

1. **Run comprehensive failure pattern analysis**
   ```bash
   bundle exec rspec spec/pubid_new/iso/ --format documentation 2>&1 | \
     grep -A 5 "Failure/Error" | \
     head -n 200 > /tmp/iso_failures.txt
   ```

2. **Categorize failures by type:**
   - Parse failures (Parslet::ParseFailed)
   - Rendering mismatches (expected X, got Y)
   - Missing attributes
   - Wrong identifier class selection

3. **Identify top 10 highest-frequency patterns** (affecting 20+ tests each)
   - Count similar error messages
   - Group by pattern (e.g., "stage+suffix", "multi-part", "language+edition")
   - Prioritize fixes with highest test impact

4. **Document findings** before coding:
   - Pattern 1: [description] - affects X tests
   - Pattern 2: [description] - affects Y tests
   - etc.

### Phase 2: Targeted Implementation (60 minutes)

**Only after analysis**, implement fixes for top 3-5 patterns:

**Example patterns to look for:**
- Edition with language: `ED1(fr)`, `ED2(en)`
- Stage suffix parsing: `CD Amd 1`, `WD Cor 2`
- Multi-part rendering: `ISO 1234-1-2:2020`
- Language positioning in supplements
- Typed stage variations not yet covered

**Implementation Strategy:**
```ruby
# For each high-impact pattern:
# 1. Read relevant parser/builder/identifier files
# 2. Identify exact fix needed
# 3. Implement fix
# 4. Run safety check (106/106 must pass)
# 5. Move to next pattern

# Do NOT test full suite until all fixes complete
```

### Phase 3: Validation (20 minutes)

1. **Safety check**: Run core tests
2. **Full test**: Measure improvement
3. **Single commit**: Document all fixes
4. **Update memory bank**: Record results

## Success Metrics

**Minimum Target:** 1,372 passing (48.0%) - **+56 tests**
- Based on fixing patterns that affect 20+ tests each
- More realistic than speculative +283

**Stretch Target:** 1,430 passing (50.0%) - **+114 tests**
- If analysis reveals very high-impact patterns
- Achievable if rendering fixes are major contributors

**Pass/Fail Criteria:**
- ✅ PASS: +40 tests minimum (data-driven improvements working)
- ⚠️ MIXED: +20-39 tests (some patterns fixed, need more analysis)
- ❌ FAIL: <20 tests (analysis insufficient, need deeper investigation)

## Time Budget

**Total: 2 hours maximum**
- Analysis: 30 minutes (MANDATORY)
- Implementation: 60 minutes
- Validation: 20 minutes
- Documentation: 10 minutes

## Analysis Template

Use this template to document findings before coding:

```markdown
## Failure Pattern Analysis (Session 16)

### Pattern 1: [Name]
- Frequency: X tests affected
- Example: [identifier string]
- Error: [exact error message]
- Root cause: [parser/builder/identifier issue]
- Fix location: [file and line number]
- Estimated impact: +X tests

### Pattern 2: [Name]
...

### Implementation Priority:
1. [Highest impact pattern] - +X tests
2. [Second highest] - +Y tests
3. [Third highest] - +Z tests

### Expected Total: +ABC tests
```

## Common Failure Patterns to Check

Based on previous sessions, likely high-impact patterns:

1. **Edition with language**: `ED1(fr)`, `ED5(en)`
   - Builder may not handle edition_language capture
   - Check [`lib/pubid_new/iso/builder.rb`](lib/pubid_new/iso/builder.rb)

2. **Stage prefix on supplements**: `CD Amd 1`, `PWI Cor 2`
   - Parser handles, but builder may not extract correctly
   - Check stage extraction logic

3. **Multi-level supplement rendering**: `ISO/Amd1/Cor2`
   - Recursive rendering may have issues
   - Check [`lib/pubid_new/iso/identifiers/amendment.rb`](lib/pubid_new/iso/identifiers/amendment.rb)

4. **Typed stage with multiple abbreviations**: Same stage, different text
   - May need TYPED_STAGES entries
   - Check identifier classes

5. **Language codes in various positions**: Before/after edition, with supplements
   - Parser captures, builder may not position correctly
   - Check language handling in builder

## Key Principle

**"FIX WHAT'S ACTUALLY FAILING, NOT WHAT MIGHT BE FAILING"**

- Analysis BEFORE implementation
- Measure expected impact BEFORE coding
- Validate assumptions with actual test data
- Prioritize highest-impact fixes

## Next Developer Actions

1. ✅ Read this plan
2. ✅ Run failure analysis (30 minutes)
3. ✅ Document top patterns with impact estimates
4. ✅ Implement top 3-5 patterns only
5. ✅ Run safety check after each major change
6. ✅ Full test once at end
7. ✅ Single commit with detailed message
8. ✅ Update memory bank

**DO NOT skip the analysis phase!** Session 15 proved that speculative fixes are inefficient. Data-driven improvements will have 10-20x better results per time invested.
