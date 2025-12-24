# Session 195 Continuation Plan: Fix Final 10 NIST SP Patterns

**Created:** 2025-12-24 (Post-Session 194)
**Status:** 10 SP patterns remaining (99.76% → target 99.95%+)
**Timeline:** COMPRESSED - 60-90 minutes total

---

## Current Status

**Session 194 Achievement:** 19,780/19,827 (99.76%)

**Remaining SP Failures:** 10 patterns

1. `NIST SP 260-126rev2013` - Rev with year pattern
2. `NIST SP 500-268v1 1` - Version with space (should be preprocessed)
3. `NIST SP 500-270v1 1` - Version with space (should be preprocessed)
4. `NIST SP 500-280v2 1` - Version with space (should be preprocessed)
5. `NIST SP 800-56ar` - Number-suffix 'a' + revision 'r'
6. `NIST SP 800-63v1 0 1` - Three-part version (should be preprocessed)
7. `NIST SP 800-63v1 0 2` - Three-part version (should be preprocessed)
8. `NIST SP 800-181r1es` - Revision + Spanish language
9. `NIST SP 800-181r1pt` - Revision + Portuguese language
10. `NIST SP 800-27 Revision (r)` - Verbose revision format

---

## Analysis

### Pattern Categories:

**Category A: Preprocessing to Parser Mismatch (7 patterns)**
- Lines 2-4, 6-7: Version patterns with spaces
- These SHOULD be fixed by preprocessing but parser may not be matching

**Category B: Suffix + Revision (1 pattern)**
- Line 5: `800-56ar` = number `56`, suffix `a`, revision `r`
- Need to handle letter suffix followed by revision

**Category C: Revision + Language (2 patterns)**
- Lines 8-9: `r1es`, `r1pt`
- Preprocessing should separate but parser may not match language after revision

**Category D: Verbose Revision (1 pattern)**
- Line 10: ` Revision (r)`
- Preprocessing should convert but may need parser enhancement

---

## Implementation Plan

### Phase 1: Debug Preprocessing (15 min)

Check if preprocessing actually runs on these patterns:

```bash
ruby -e '
tests = [
  "NIST SP 260-126rev2013",
  "NIST SP 500-268v1 1",
  "NIST SP 800-56ar",
  "NIST SP 800-63v1 0 1",
  "NIST SP 800-181r1es",
  "NIST SP 800-27 Revision (r)"
]

tests.each do |test|
  cleaned = test.dup
  # Apply all preprocessing...
  puts "#{test} → #{cleaned}"
end
'
```

### Phase 2: Fix Preprocessing Gaps (20 min)

If preprocessing isn't working, enhance:

1. **Line 27**: Rev with year may need adjustment
2. **Line 60-61**: Multi-space version may need ordering fix
3. **Line 82**: Suffix+revision pattern needs `(\d)([a-z])(r\b)` → `\1\2 \3`
4. **Line 94-97**: Verbose formats may need regex fixes

### Phase 3: Fix Parser Rules (20 min)

If preprocessing works but parser doesn't match:

1. **Revision rule** (line 363): Ensure handles `rev2013`, `rev 2013`, `r` alone
2. **Version rule** (line 381): Ensure handles `v1.0.1`, `v1.0.2`
3. **Language rule** (line 463): Ensure follows revision correctly

### Phase 4: Test & Validate (15 min)

```bash
cd spec/fixtures/nist && ruby ../run_classify.rb nist
# Target: 19,837/19,827 or 19,827/19,827 (100%)
```

---

## Expected Results

**Minimum Success:** 19,820/19,827 (99.96%) - Fix 8/10 patterns
**Target Success:** 19,827/19,827 (100%) - Fix all 10 patterns

---

## Files to Modify

- `lib/pubid_new/nist/parser.rb` - Preprocessing and/or parser rules

---

## Next Steps

1. Debug preprocessing output
2. Fix any preprocessing gaps
3. Enhance parser rules if needed
4. Reclassify and validate
5. Document final achievement
6. Update memory bank and README