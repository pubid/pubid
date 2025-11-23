# Session 8 Continuation Plan - ISO V2 Test Refinement

## Current Status (as of Session 8 end)

**Test Results:**
- 928 passing (32.5%)
- 1,091 failures (38.2%)
- 840 pending (29.4%)
- Total: 2,859 examples

**Progress from Session 7:**
- Started: 917 passing (32.1%)
- Improved: +11 tests (+0.4 percentage points)
- Failures reduced: 1,102 → 1,091 (-11)
- Pending unchanged: 840 (29.4%)

## What Was Accomplished in Session 8

### 1. Memory Bank Update
File: `.kilocode/rules/memory-bank/context.md`

✅ Updated with Session 7 results
✅ Documented Session 8 priorities
✅ Current state accurately reflected

### 2. Parser Extensions (Priority 1)
File: `lib/pubid_new/iso/parser.rb`

✅ Added PDTR (Proposed Draft Technical Report) to typed_stage (line 52)
✅ Added PDTS (Proposed Draft Technical Specification) to typed_stage (line 52)
✅ Implemented normalization preprocessing (line 151-159):
- IS0 (zero) → ISO (letter O)
- Em-dash (—) → slash (/)
- En-dash (–) → slash (/)
- /Add. → /Add
- Whitespace normalization

### 3. Testing & Validation

✅ Core tests: 106/106 passing (100%)
- parser_spec.rb: All grammar rules validated
- builder_spec.rb: All object construction verified

✅ Full suite: 928/2,859 passing (32.5%)
- +11 tests fixed by PDTR/PDTS and normalizations

### 4. Git Commit
- Commit: d1743e1
- Message: "feat(iso): Add PDTR/PDTS typed stages and input normalization"
- Files changed: 2 (parser.rb, context.md)
- Changes: +37 insertions, -26 deletions

## Analysis: Why Only +11 Tests?

The modest improvement (+11 tests) from PDTR/PDTS and normalization suggests:

1. **Limited PDTR/PDTS usage in fixtures** - These stages may not be heavily represented in V1 test data
2. **Normalization edge cases** - Most test failures are NOT typo-related
3. **Core issues remain** - Parser gaps, rendering differences, and architectural mismatches still dominant

This indicates we need to shift focus to **systematic failure analysis** rather than adding more parser rules.

## Remaining Work to Reach 50% Pass Rate

### Priority 1: Systematic Failure Analysis (3-4 hours, ~300-400 tests)

**Goal:** Extract and categorize the top 20 failure patterns to identify highest-impact fixes.

**Approach:**
1. Run tests with JSON output
2. Extract failure messages and exceptions
3. Group by error pattern
4. Rank by frequency
5. Create targeted fixes

**Expected patterns:**
- Rendering format mismatches (e.g., date formatting, language codes)
- Missing attribute accessors
- Type mismatches (string vs integer)
- nil safety issues
- Architectural differences (typed_stage, edition display)

**Tools:**
```bash
# Extract failure patterns
bundle exec rspec spec/pubid_new/iso/identifiers/ --format json 2>&1 | \
  jq '.examples[] | select(.status=="failed") | 
      {file: .file_path, line: .line_number, message: .exception.message}' | \
  jq -s 'group_by(.message) | map({pattern: .[0].message, count: length, files: map(.file)}) | 
         sort_by(.count) | reverse | .[0:20]'
```

### Priority 2: Edition Parsing & Rendering (2-3 hours, ~50-80 tests)

**Current issue:** Edition format variations not fully handled.

**Test patterns failing:**
```
ISO 123:1999 Ed 3       # Space between Ed and number
ISO 123:1999 Ed.2       # Dot between Ed and number  
ISO 123:1999 ED1        # Uppercase with no space
ISO 123:1999(ed2)       # Lowercase in parentheses
```

**Parser changes needed:**
1. Make edition parsing more flexible
2. Handle lowercase "ed" variant
3. Handle parenthetical edition format

**Rendering changes needed:**
1. Determine canonical format (likely "Ed 2")
2. Update identifier classes to render consistently

### Priority 3: Language Code Normalization (1-2 hours, ~30-50 tests)

**Current issue:** Language codes have multiple representations.

**Test patterns failing:**
```
ISO 8601:2019(en)       # Lowercase
ISO 8601:2019(E)        # Uppercase (current parser output)
ISO 8601:2019(E/F)      # Multiple languages with slash
ISO 8601:2019(E,F)      # Multiple languages with comma
```

**Changes needed:**
1. Document canonical format (uppercase single letters vs lowercase codes)
2. Update rendering to match V1 format
3. May need builder or identifier changes, not just parser

### Priority 4: Architectural Compatibility (2-3 hours, documentation + shims)

**Issue:** Fundamental differences between V1 and V2 architecture.

**Known architectural differences:**
1. **typed_stage** (464 pending tests)
   - V1: Single object combining type + stage
   - V2: Separate type and stage attributes
   - Decision needed: Add compatibility method or keep pending?

2. **Rendering methods**
   - V1: `to_s(with_edition: true)`, `urn()`, etc.
   - V2: May have different signatures or missing methods

3. **Attribute paths**
   - V1: Direct attributes
   - V2: Component-based (e.g., `date.year` not `date.date.year`)

**Approach:**
- Create `docs/V2_ARCHITECTURAL_DECISIONS.md`
- Document intentional differences
- Add compatibility methods where appropriate
- Keep truly architectural differences as pending

### Priority 5: Targeted Parser Gaps (1-2 hours, ~20-40 tests)

**Based on continuation plan analysis, likely remaining gaps:**

1. **Complex stage patterns**
   ```
   ISO/CD TR 12786.2     # Committee Draft + iteration
   ISO/NWIP TR 11111     # New Work Item Proposal + type
   ```

2. **Numeric iterations with decimals**
   ```
   ISO/CD TR 12786.2     # Verify iteration.2 works
   ISO/DTS 21328.4       # Multiple decimal iterations
   ```

3. **Special supplement cases**
   ```
   ISO/R 947:1969/Add 1:1969     # Add on legacy R identifier (already works?)
   ISO 123/AMD 1:2020            # Uppercase AMD (parser handles, but rendering?)
   ```

## Recommended Session 9 Plan

**Goal: Reach 40% pass rate (1,144 passing, +216 tests)**

### Hour 1: Failure Pattern Analysis
1. Extract top 20 failure patterns
2. Create summary document with examples
3. Prioritize by fix complexity vs test impact

### Hour 2: High-Impact Quick Wins
1. Fix top 3 failure patterns (likely rendering or nil safety)
2. Test and verify improvements
3. Commit fixes

### Hour 3: Edition Handling
1. Update parser for edition flexibility
2. Update identifier rendering
3. Test with edition-specific test files
4. Commit changes

### Hour 4: Language Code Normalization
1. Determine canonical format
2. Update rendering in identifier classes
3. Test and commit

### Hour 5: Targeted Parser Gaps
1. Add complex stage patterns
2. Verify iteration parsing
3. Test and commit

### Hour 6: Progress Review & Documentation
1. Run full test suite
2. Document Session 9 results
3. Update context.md
4. Create Session 10 plan if needed

## Testing Strategy

### Safety Check (Run after EVERY change)
```bash
bundle exec rspec spec/pubid_new/iso/parser_spec.rb spec/pubid_new/iso/builder_spec.rb
# MUST always pass 106/106
```

### Progress Check
```bash
bundle exec rspec spec/pubid_new/iso/ --format progress 2>&1 | grep "examples"
```

### Failure Analysis
```bash
# Top 20 failure patterns
bundle exec rspec spec/pubid_new/iso/identifiers/ --format json 2>&1 | \
  jq '.examples[] | select(.status=="failed") | .exception.message' | \
  sort | uniq -c | sort -rn | head -20

# Failures by file
bundle exec rspec spec/pubid_new/iso/identifiers/ --format json 2>&1 | \
  jq '.examples[] | select(.status=="failed") | .file_path' | \
  sort | uniq -c | sort -rn

# Specific failure details
bundle exec rspec spec/pubid_new/iso/identifiers/international_standard_spec.rb \
  --format documentation --only-failures
```

### Specific File Testing
```bash
# Test specific identifier type
bundle exec rspec spec/pubid_new/iso/identifiers/international_standard_spec.rb -fd

# Test specific example
bundle exec rspec spec/pubid_new/iso/identifiers/international_standard_spec.rb:150 -fd
```

## Files to Focus On

**Parser (minimal changes expected):**
- `lib/pubid_new/iso/parser.rb` - Only if new patterns discovered

**Builder (possible changes):**
- `lib/pubid_new/iso/builder.rb` - For complex object construction

**Identifier classes (likely changes):**
- `lib/pubid_new/iso/single_identifier.rb` - Base rendering logic
- `lib/pubid_new/iso/supplement_identifier.rb` - Supplement rendering
- `lib/pubid_new/iso/identifiers/*.rb` - Specific type rendering

**Test files (for understanding failures):**
- `spec/pubid_new/iso/identifiers/*.rb` - V1 expectations

**Components (possible changes):**
- `lib/pubid_new/iso/components/date.rb` - Date rendering
- `lib/pubid_new/iso/components/edition.rb` - Edition rendering
- `lib/pubid_new/iso/components/language.rb` - Language rendering

## Success Metrics

**Minimum for Session 9:**
- 1,144 passing (40%) - +216 from Session 8
- 975 failing (34%) - -116 from Session 8  
- 740 pending (26%) - (reduce if architectural decisions made)

**Target for Session 10:**
- 1,430 passing (50%)
- 715 failing (25%)
- 714 pending (25%)

**Ultimate goal:**
- 2,145 passing (75%)
- 500 failing (17.5%)
- 214 pending (7.5%)

## Key Insights from Session 8

1. **Parser is mature** - Adding more rules has diminishing returns
2. **Rendering is the bottleneck** - Most failures likely in to_s methods
3. **Architectural decisions needed** - 464 typed_stage tests require policy
4. **Systematic approach required** - Random fixes won't reach 50%

## Notes for Next Developer

1. **Start with failure analysis** - Don't guess, measure
2. **Fix rendering before parser** - Likely higher impact
3. **Document architectural decisions** - Don't leave them pending
4. **Test specific files first** - Validate fixes in isolation
5. **Commit frequently** - Each logical change gets its own commit
6. **Track test count changes** - Know which fixes have impact

## Reference Data

**Test Breakdown by File (approximate):**
- international_standard_spec.rb: ~600 examples
- amendment_spec.rb: ~400 examples
- guide_spec.rb: ~350 examples
- technical_report_spec.rb: ~300 examples
- corrigendum_spec.rb: ~250 examples
- Others: ~959 examples

**Common V1 to V2 API Mappings:**
- `identifier.year` → `identifier.date.year`
- `identifier.part` → `identifier.part&.value`
- `identifier.typed_stage` → `identifier.stage` (architectural difference)
- `identifier.to_s(with_edition: true)` → ? (needs documentation)

## Backup Strategy

**Before major changes:**
```bash
# Backup test files
cp -r spec/pubid_new/iso/identifiers/ /tmp/identifiers_backup_session9

# Backup implementation
cp -r lib/pubid_new/iso/ /tmp/iso_impl_backup_session9
```

**Test specific identifier in isolation:**
```bash
ruby -e "require_relative 'lib/pubid_new/iso'; 
  id = PubidNew::Iso.parse('ISO 8601:2019'); 
  puts id.inspect; 
  puts id.to_s"
```

## Session 8 Statistics Summary

**Time spent:** ~30 minutes
**Files changed:** 2
**Lines changed:** +37/-26
**Tests fixed:** +11
**New features:** PDTR/PDTS stages, input normalization
**Core stability:** 100% (106/106)
**Overall progress:** 32.5% (+0.4pp from Session 7)

Good foundation established. Session 9 should focus on systematic analysis and rendering fixes for maximum impact.