# Session 171+ Continuation Plan: IEEE TODO.IEEE-MUST-DO.txt Completion

**Created:** 2025-12-18 (Post-Session 170)
**Status:** IEEE at 89.75%, MUST complete TODO.IEEE-MUST-DO.txt (46 identifiers)
**Priority:** CRITICAL - These identifiers MUST parse successfully
**Timeline:** COMPRESSED - 1-2 sessions (90-180 minutes)

---

## Critical Context

**File:** [`TODO.IEEE-MUST-DO.txt`](../TODO.IEEE-MUST-DO.txt:1)
**Contains:** 46 IEEE identifiers that MUST be parsed successfully
**Current:** Many are failing due to data quality and parser limitations

---

## Pattern Analysis from TODO File

### Category 1: Data Quality - Space Issues (6 identifiers)
```
IEEE Std C37.101 -2006  # Extra space before dash
IEEE Std C37.102 -2006  # Extra space before dash
IEEE Std C62.35- 2010   # Space after dash
```
**Fix:** Parser preprocessing to normalize `\s+-` and `-\s+`
**Difficulty:** Easy
**Impact:** +6 IDs minimum

### Category 2: HTML Entities (3 identifiers)
```
IEEE Std C57.110&#x2122;-2018  # &#x2122; = ™ trademark
IEEE Std 802.1CS&#x2013;2020   # &#x2013; = – en dash
IEEE Std 91a-1991 &amp; IEEE Std 91-1984  # &amp; = &
```
**Fix:** Parser preprocessing HTML entity decode
**Difficulty:** Easy
**Impact:** +3 IDs

### Category 3: IEEE/ASTM SI/PSI (6 identifiers)
```
IEEE/ASTM PSI 10/D2, October 2015
IEEE/ASTM PSI 10/D3, October 2010
IEEE/ASTM SI 10-1997
IEEE/ASTM SI 10-2002 (Revision of IEEE/ASTM SI 10-1997)
```
**Fix:** Already have parser rule, may need enhancement
**Difficulty:** Medium
**Impact:** +6 IDs

### Category 4: AIEE Variants (5 identifiers)
```
AIEE No 1E -1957         # Space before dash + letter suffix
A.I.E.E. No. 15 May-1928 # Dots in AIEE
AIEE Nos 72 and 73 - 1932 # Plural "Nos" + "and"
```
**Fix:** AIEE parser enhancements for dots and "Nos"
**Difficulty:** Medium
**Impact:** +5 IDs

### Category 5: Wrong Prefix (4 identifiers)
```
!IEEE 1070-1995
!IEEE 278-1967
```
**Fix:** Parser preprocessing `^!IEEE` → `IEEE`
**Difficulty:** Easy
**Impact:** +4 IDs

### Category 6: Semicolon Dual (1 identifier - DONE in Session 169)
```
IEEE Std 120-1955; ASME PTC 19.6-1955
```
**Status:** ✅ Already implemented in Session 169

### Category 7: Complex Relationships (21+ identifiers)
```
IEEE Std 802.11g-2003 (Amendment to IEEE Std 802.11, 1999 Edn. (Reaff 2003) as amended by IEEE Stds 802.11a-1999, ...)
IEEE Std 802.16e-2005 and IEEE Std 802.16-2004/Cor 1-2005 (Amendment and Corrigendum to...)
IEEE Std 1003.5b-1996 (Includes IEEE Std 1003.5-1992)
```
**Fix:** Add "Includes" relationship type, handle "Amendment and Corrigendum"
**Difficulty:** Medium
**Impact:** +21 IDs

### Category 8: Slash Dual Published (2 identifiers)
```
IEEE Std 262-1973 /ANSI C57.12.90-1973 (Supersedes...)
IEEE Std 338-1971/ANSI N41.3
```
**Fix:** Detect `/ANSI` pattern for dual published
**Difficulty:** Medium
**Impact:** +2 IDs

---

## Implementation Plan (Compressed)

### Session 171: High-Impact Data Quality (60 min)

**Phase 1: Data Quality Fixes (20 min) - Expected +13 IDs**

1. **Space normalization** (5 min)
   ```ruby
   # In Parser.parse preprocessing
   cleaned = cleaned.gsub(/\s+-/, '-')  # " -" → "-"
   cleaned = cleaned.gsub(/-\s+/, '-')  # "- " → "-"
   ```

2. **HTML entity decoding** (5 min)
   ```ruby
   cleaned = cleaned.gsub('&#x2122;', '™')  # Already have ™ removal
   cleaned = cleaned.gsub('&#x2013;', '-')  # en dash → hyphen
   cleaned = cleaned.gsub('&amp;', '&')     # Already have this
   ```

3. **Wrong prefix** (5 min)
   ```ruby
   cleaned = cleaned.gsub(/^!IEEE /, 'IEEE ')
   ```

4. **Test** (5 min)
   - Expected: +13 IDs minimum (6 space + 3 entities + 4 prefix)

**Phase 2: AIEE Enhancements (20 min) - Expected +5 IDs**

1. **AIEE parser updates** (15 min)
   - Handle `A.I.E.E.` with dots
   - Handle `Nos` plural
   - Handle space before dash in numbers

2. **Test** (5 min)
   - Expected: +5 IDs

**Phase 3: Relationship Types (15 min) - Expected +2 IDs**

1. **Add "Includes" relationship** (10 min)
   - Parser: `relationship_includes`
   - Component: `INCLUDES = "includes"`

2. **Test** (5 min)
   - Expected: +2 IDs minimum

**Phase 4: Validation (5 min)**
- Run full classification
- Expected total: +20 IDs minimum
- **Target:** 8,579/9,537 (89.96%) close to 90%!

---

### Session 172: Complex Patterns (90 min) - If needed

**Phase 1: IEEE/ASTM SI/PSI** (30 min)
- Verify existing rule works
- Add any missing variants
- Expected: +6 IDs

**Phase 2: Slash Dual Published** (30 min)
- Add `/ANSI` detection in Base.parse
- Handle with/without space before slash
- Expected: +2 IDs

**Phase 3: Complex Relationships** (20 min)
- "Amendment and Corrigendum" combined type
- Multiple amendments in list notation
- Expected: +5-10 IDs

**Phase 4: Final Validation** (10 min)
- Total expected from both sessions: +33-43 IDs
- **Final target:** 90.5-91.0% (8,592-8,602/9,537)

---

## Quick Reference: Pattern Locations

### Parser Preprocessing (Easy wins)
**File:** `lib/pubid_new/ieee/parser.rb` lines ~655-710
- Space normalization
- HTML entities
- Wrong prefix

### AIEE Parser (Medium)
**File:** `lib/pubid_new/ieee/aiee/parser.rb`
- Dots in A.I.E.E.
- Plural Nos
- Space handling

### Relationship Component (Easy)
**File:** `lib/pubid_new/ieee/components/relationship.rb`
- Add INCLUDES constant
- Update RELATIONSHIP_TYPES array

### Relationship Parser (Easy)
**File:** `lib/pubid_new/ieee/parser.rb` lines ~250-280
- Add `relationship_includes` rule

---

## Success Criteria

### Minimum (Session 171 only)
- ✅ +20 identifiers (data quality + AIEE + includes)
- ✅ 8,579/9,537 (89.96%)
- ✅ Zero regressions
- ✅ Clean architecture

### Target (Both sessions)
- ✅ +33+ identifiers
- ✅ 8,592+/9,537 (90.1%+)
- ✅ **90% MILESTONE ACHIEVED**
- ✅ All TODO.IEEE-MUST-DO.txt high priority patterns working

### Stretch (Complete TODO file)
- ✅ All 46 TODO identifiers parsing
- ✅ 91%+ achieved
- ✅ Complex relationships fully working

---

## Testing Strategy

```bash
# After each phase:
cd spec/fixtures && ruby run_classify.rb ieee 2>&1 | tail -10

# Test specific TODO patterns:
cd /Users/mulgogi/src/mn/pubid
ruby -e "
require './lib/pubid_new'
[
  'IEEE Std C37.101 -2006',
  'IEEE Std C57.110&#x2122;-2018',
  '!IEEE 1070-1995',
  'AIEE No 1E -1957',
  'IEEE Std 1003.5b-1996 (Includes IEEE Std 1003.5-1992)'
].each do |id|
  begin
    parsed = PubidNew::Ieee.parse(id)
    puts \"✅ #{id}\"
  rescue => e
    puts \"❌ #{id}: #{e.message}\"
  end
end
"
```

---

## Architecture Principles

**MAINTAIN:**
- ✅ MODEL-DRIVEN - Objects not strings
- ✅ MECE - Clear separation
- ✅ Safe preprocessing - Data quality fixes only in Parser.parse
- ✅ Zero compromises - Correctness over test count

**PRIORITY:**
1. Data quality fixes (highest ROI, lowest risk)
2. Simple relationship types (includes, etc.)
3. AIEE variants (medium complexity)
4. Complex dual published (if time permits)
5. Complex relationships (Session 172 focus)

---

## Files to Modify

### Session 171 (Data Quality Focus)
1. `lib/pubid_new/ieee/parser.rb` - Preprocessing fixes
2. `lib/pubid_new/ieee/aiee/parser.rb` - AIEE variants
3. `lib/pubid_new/ieee/components/relationship.rb` - INCLUDES
4. `lib/pubid_new/ieee/parser.rb` - relationship_includes rule

### Session 172 (Complex Patterns)
1. `lib/pubid_new/ieee/identifiers/base.rb` - Slash dual detection
2. `lib/pubid_new/ieee/parser.rb` - Complex relationship parsing
3. `lib/pubid_new/ieee/builder.rb` - If new components needed

---

**Created:** 2025-12-18
**Priority:** CRITICAL - Complete TODO.IEEE-MUST-DO.txt
**Status:** Ready for Session 171
**Goal:** 90%+ by completing TODO file patterns
**Current:** 8,559/9,537 (89.75%)
**Target:** 8,592/9,537 (90.1%+) after both sessions

**Next session:** Data quality wins first, then AIEE, then relationships! 🎯