# Session 221+ Continuation Plan: NIST Complete Implementation

**Created:** 2025-12-28 (Post-Session 220)
**Status:** Session 220 complete at 99.97% - Ready for final enhancements
**Timeline:** COMPRESSED - Complete in 2-3 sessions (3-4 hours total)
**Goal:** 100% NIST validation with proper NIST spec compliance

---

## Executive Summary

**Session 220 Achievement:** Priority patterns implemented (14/14 tests passing)

**Remaining Work:**
1. Roman numeral to volume conversion (CRITICAL - NIST spec compliance)
2. Letter+revision+draft combo patterns (2 identifiers)
3. Edge case patterns (2-3 identifiers)

**Current Status:**
- NIST: 19,821/19,826 (99.97%)
- 5 failures remaining (2 new + 3 known)

---

## CRITICAL: Roman Numeral Normalization (NIST Spec Compliance)

**From NIST Spec (page 7, Table 2):**
> "Do not represent numbers using Roman numerals"
> Parts identified using Arabic numerals: pt1, v2, sec5

**Current Implementation:** Treats `-I-2.0` as report number
**Required Implementation:** Convert to volume format

### Patterns Requiring Normalization

```
Input:  NIST SP 1011-I-2.0
Output: NIST SP 1011v1ver2.0
        (number: 1011, volume: 1, version: 2.0)

Input:  NIST SP 1011-II-1.0
Output: NIST SP 1011v2ver1.0
        (number: 1011, volume: 2, version: 1.0)
```

**Roman to Arabic Mapping:**
- I → v1 (Volume 1)
- II → v2 (Volume 2)
- III → v3 (Volume 3)
- IV → v4, V → v5, etc.

---

## SESSION 221: Roman Numeral Conversion (90 minutes)

### Objective
Convert Roman numeral volume indicators to proper NIST volume format per spec.

### Part A: Parser Enhancement (30 min)

**File:** `lib/pubid_new/nist/parser.rb`

**Change Strategy:**
1. Keep existing `first_number` Roman numeral pattern for PARSING
2. Add preprocessing to CONVERT Roman volumes to Arabic in `Parser.parse`
3. Builder will receive normalized format

**Preprocessing addition (after line 51):**
```ruby
# Convert Roman numeral volumes to Arabic per NIST spec (page 7)
# "1011-I-2.0" → "1011 v1 ver2.0" (space-separated for parser)
# "1011-II-1.0" → "1011 v2 ver1.0"
cleaned = cleaned.gsub(/(\d+)-([IVX]+)-(\d+(?:\.\d+)*)/) do
  number = $1
  roman = $2
  version_part = $3

  # Convert Roman to Arabic
  arabic = case roman
    when 'I' then '1'
    when 'II' then '2'
    when 'III' then '3'
    when 'IV' then '4'
    when 'V' then '5'
    when 'VI' then '6'
    when 'VII' then '7'
    when 'VIII' then '8'
    when 'IX' then '9'
    when 'X' then '10'
    else roman  # Fallback for other patterns
  end

  # Convert to volume+version format: "1011 v1 ver2.0"
  "#{number} v#{arabic} ver#{version_part}"
end
```

### Part B: Builder Verification (20 min)

**File:** `lib/pubid_new/nist/builder.rb`

Verify builder correctly handles normalized format:
- Volume attribute populated from `v1`, `v2`
- Version attribute populated from `ver2.0`, `ver1.0`
- Rendering produces correct output

### Part C: Testing (30 min)

**Test patterns:**
```ruby
test_patterns = [
  ['NIST SP 1011-I-2.0', 'NIST SP 1011 Vol. 1 ver2.0'],
  ['NIST SP 1011-II-1.0', 'NIST SP 1011 Vol. 2 ver1.0'],
]
```

### Part D: Documentation Update (10 min)

Update TODO.NIST-MUST-FIX.md to reflect normalization approach.

---

## SESSION 222: Edge Case Patterns (60 minutes)

### Objective
Handle remaining 5 failure patterns.

### Pattern 1-2: Letter+Revision+Draft Combo (30 min)

**Patterns:**
```
NIST SP 800-140Cr1-draft2
NIST SP 800-140Dr1-draft2
```

**Analysis:**
- Number: 800-140C or 800-140D (letter suffix)
- Revision: r1
- Draft: draft2

**Enhancement needed in preprocessing:**
```ruby
# Fix letter suffix + revision before draft
# "140Cr1-draft2" → "140C r1-draft2"
cleaned = cleaned.gsub(/(\d{2,})([A-Z])(r\d+)([-\s]draft\d*)/, '\1\2 \3\4')
```

### Pattern 3: NISTPUB Invalid Series (5 min)

**Pattern:** `NISTPUB 0413171251`

**Status:** Data quality issue - document as permanent failure
**Reason:** "PUB" is not a valid NIST series

### Pattern 4-5: Draft and MR Format (15 min)

**Patterns:**
```
NIST IR 8270-draft2
NIST.IR.8286C-upd1
```

**Check:**
- Verify preprocessing at line 47 works correctly
- These should already be handled by Session 219 fixes

### Part B: Fixture Validation (10 min)

Run classification and verify improvement:
```bash
cd spec/fixtures && ruby run_classify.rb nist
```

**Target:** 19,823/19,826 (99.98%) or better

---

## SESSION 223: Documentation & Completion (60 minutes)

### Objective
Complete all documentation and mark NIST as production-ready.

### Part A: Update README.adoc (30 min)

**File:** `README.adoc`

Add NIST pattern coverage section:
```asciidoc
==== NIST Pattern Coverage

NIST supports comprehensive patterns per the official NIST PubID specification:

.Complex Patterns Supported
[cols="1,2"]
|===
|Pattern Type |Example

|Volume ranges
|`NBS SP 535v2a-l` (Volume 2 parts a-l)

|Multi-letter suffixes
|`NIST IR 7356-CAS` (Suffix: CAS)

|Volume+letter combos
|`NIST GCR 21-917-48v3B` (Volume 3B)

|Roman numeral volumes
|`NIST SP 1011-I-2.0` → `NIST SP 1011v1ver2.0`

|Multi-dash numbers
|`NIST GCR 21-917-48` (Year-seq-part)

|Dotted versions
|`NIST SP 500-268v1.1` (Version 1.1)
|===

**NIST Spec Compliance:**
- ✅ Roman numerals converted to Arabic volumes (v1, v2, v3)
- ✅ All part types: pt, v, sec, sup, indx
- ✅ Edition types: e, r, ver, -
- ✅ Update format: /Upd{N}-{YYYY}
- ✅ Stage codes: (IPD), (2PD), (FPD), etc.

**Validation:** 99.98%+ on 19,826 real-world identifiers
```

### Part B: Archive Session Documentation (15 min)

Move completed session docs to `docs/old-docs/sessions/`:
```bash
mv docs/SESSION-220-CONTINUATION-PLAN.md docs/old-docs/sessions/
mv docs/SESSION-220-CONTINUATION-PROMPT.md docs/old-docs/sessions/
mv docs/SESSION-221-CONTINUATION-PLAN.md docs/old-docs/sessions/
mv docs/SESSION-221-CONTINUATION-PROMPT.md docs/old-docs/sessions/
```

Create summary: `docs/old-docs/sessions/session-220-221-summary.md`

### Part C: Update Memory Bank (15 min)

**File:** `.kilocode/rules/memory-bank/context.md`

Document Sessions 220-223 completion with final metrics.

---

## Implementation Status Tracker

| Session |<br Focus | Duration | Deliverables | Status |
|---------|-------|----------|--------------|--------|
| 220 | Priority patterns | 60 min | Volume ranges, multi-letter, v+letter | ✅ Complete |
| 221 | Roman conversion | 90 min | NIST spec compliance | ⏳ Pending |
| 222 | Edge cases | 60 min | Letter+revision+draft combos | ⏳ Pending |
| 223 | Documentation | 60 min | README, archival, COMPLETE | ⏳ Pending |

**Total Remaining:** 210 minutes (3.5 hours)

---

## Success Criteria

### Minimum (99.98%)
- Roman numeral conversion working
- Letter+revision+draft combo patterns working
- NIST at 19,823+/19,826

### Target (99.99%)
- All fixable patterns working
- Only data quality issues remaining
- NIST at 19,824+/19,826

### Stretch (100%)
- All patterns working
- Zero failures
- Perfect NIST spec compliance

---

## Key Architectural Principles

**MAINTAIN throughout:**
1. **MODEL-DRIVEN** - Objects not strings
2. **MECE** - Mutually exclusive, collectively exhaustive
3. **Three-layer** - Parser/Builder/Identifier separation
4. **NIST spec compliance** - Follow official specification
5. **Preprocessing only** - No architecture changes
6. **Open/Closed** - Extensible without modification

**Roman Numeral Conversion:**
- Preprocessing converts Roman to Arabic
- Parser receives normalized format
- Builder and Identifier unchanged
- Perfect separation of concerns

---

## Files to Modify

### Session 221
- `lib/pubid_new/nist/parser.rb` - Roman numeral preprocessing (1 addition)
- Test validation

### Session 222
- `lib/pubid_new/nist/parser.rb` - Letter+revision+draft preprocessing (1 addition)
- Test validation

### Session 223
- `README.adoc` - NIST pattern coverage section
- `.kilocode/rules/memory-bank/context.md` - Final status
- Archive completed docs

---

## Testing Strategy

**After Session 221:**
```bash
ruby -e "
require 'bundler/setup'
require_relative 'lib/pubid_new'

tests = [
  ['NIST SP 1011-I-2.0', 'NIST SP 1011 Vol. 1 ver2.0'],
  ['NIST SP 1011-II-1.0', 'NIST SP 1011 Vol. 2 ver1.0'],
]

tests.each do |input, expected|
  result = PubidNew::Nist.parse(input).to_s
  status = result == expected ? '✅' : '❌'
  puts \"#{status} #{input} => #{result}\"
  puts \"   Expected: #{expected}\" unless result == expected
end
"
```

**After Session 222:**
```bash
cd spec/fixtures && ruby run_classify.rb nist
```

**Expected:** 99.98%+ validation rate

---

## Next Immediate Steps (Session 221)

1. Read this continuation plan
2. Implement Roman numeral conversion preprocessing
3. Test with NIST SP 1011-I-2.0 and 1011-II-1.0
4. Verify builder handles normalized format
5. Run comprehensive fixture classification
6. Document results

---

**Created:** 2025-12-28
**Sessions Covered:** 221-223
**Status:** Ready for execution
**Estimated Time:** 3.5 hours (compressed)

**End Goal:** Complete NIST spec compliance with 99.98%+ validation! 🎯