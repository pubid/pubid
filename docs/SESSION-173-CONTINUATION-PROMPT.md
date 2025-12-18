# Session 173 Continuation Prompt: TODO.IEEE-MUST-DO.txt Implementation

**Session:** 173
**Previous:** Session 172 complete - IEEE at 90.02%
**Focus:** Implement all 46 TODO.IEEE-MUST-DO.txt patterns
**Timeline:** 90 minutes (preprocessing enhancements)

---

## Quick Start

**Read these files first:**
1. [`docs/SESSION-173-CONTINUATION-PLAN.md`](SESSION-173-CONTINUATION-PLAN.md:1) - Complete implementation plan
2. [`TODO.IEEE-MUST-DO.txt`](../TODO.IEEE-MUST-DO.txt:1) - Target patterns (46 identifiers)
3. [`.kilocode/rules/memory-bank/context.md`](../.kilocode/rules/memory-bank/context.md:1) - Current status

**Current metrics:**
- IEEE: 8,599/9,552 (90.02%)
- TODO patterns: 21/46 already working
- Need implementation: 25 patterns

---

## Session 173 Objectives

### Part A: Simple Normalizations (30 min)

**File:** [`lib/pubid_new/ieee/parser.rb`](../lib/pubid_new/ieee/parser.rb:658) lines 658-745 (Parser.parse method)

**Add preprocessing fixes:**

1. **Missing dash before year**
   ```ruby
   # "802.16g 2007" → "802.16g-2007"
   cleaned = cleaned.gsub(/(\d)\s+(\d{4})\b/, '\1-\2')
   ```

2. **Space-dash-space before year**
   ```ruby
   # "802.1ag - 2007" → "802.1ag-2007"
   cleaned = cleaned.gsub(/\s+-\s+(\d{4})\b/, '-\1')
   ```

3. **Add missing "Std"**
   ```ruby
   # "IEEE 1070-1995" → "IEEE Std 1070-1995"
   cleaned = cleaned.gsub(/^IEEE\s+(\d)/, 'IEEE Std \1')
   ```

4. **Space before slash**
   ```ruby
   # "262-1973 /ANSI" → "262-1973/ANSI"
   cleaned = cleaned.gsub(/\s+\//, '/')
   ```

5. **Comma before Edition**
   ```ruby
   # ", 1998 Edition" → "-1998"
   cleaned = cleaned.gsub(/,\s+(\d{4})\s+Edition/, '-\1')
   ```

6. **ISO/IEC number spacing**
   ```ruby
   # "ISO/IEC15802" → "ISO/IEC 15802"
   cleaned = cleaned.gsub(/(ISO\/IEC)(\d)/, '\1 \2')
   ```

### Part B: Publisher Order (20 min)

```ruby
# "IEEE Std ANSI/IEEE" → "ANSI/IEEE Std"
cleaned = cleaned.gsub(/^IEEE\s+Std\s+(ANSI\/IEEE)/, '\1 Std')
```

### Part C: Dual Published Formats (20 min)

```ruby
# Semicolon to parenthetical: "120-1955; ASME PTC" → "120-1955 (ASME PTC)"
if cleaned.match?(/;\s+[A-Z]+\s+/)
  cleaned = cleaned.sub(/;\s+([A-Z][^;]+)$/, ' (\1)')
end

# Comma dual: "960-1989, Std 1177" → "960-1989 and Std 1177"
cleaned = cleaned.gsub(/(\d{4}),\s+(Std\s+\d)/, '\1 and \2')
```

### Part D: Testing (20 min)

```bash
cd spec/fixtures && ruby run_classify.rb ieee
```

**Expected result:**
- IEEE: 8,607-8,612/9,552 (90.10-90.15%)
- +8-13 identifiers from preprocessing

---

## Implementation Guidelines

**Critical rules:**
1. **Add to existing preprocessing** - Don't remove existing fixes
2. **Order matters** - Place new fixes in logical groups
3. **Test incrementally** - Test after each major group
4. **No parser changes** - Only modify Parser.parse preprocessing
5. **Conservative patterns** - Avoid overly broad substitutions

**Insert location:** After line 743 (before `new.parse(cleaned)`)

---

## Success Criteria

### Minimum (80%)
- ✅ 6+ new patterns working
- ✅ IEEE at 90.10%+ (8,607+/9,552)
- ✅ No regressions

### Target (90%)
- ✅ 10+ new patterns working
- ✅ IEEE at 90.13%+ (8,610+/9,552)
- ✅ All preprocessing clean

### Stretch (100%)
- ✅ 13+ new patterns working
- ✅ IEEE at 90.15%+ (8,612+/9,552)
- ✅ Ready for Session 174

---

## Next Steps After Session 173

**Session 174:** Edition abbreviation & IRE parenthetical (90 min)
**Session 175:** AIEE dual numbers (60 min)
**Session 176:** Testing & documentation (60 min)

**Total remaining:** 210 minutes to complete all TODO patterns

---

## Troubleshooting

**If gain is lower than expected:**
- Check TODO.IEEE-MUST-DO.txt patterns individually
- Some may need parser changes (Sessions 174-175)
- Preprocessing may need refinement

**If regressions occur:**
- Check pattern specificity (too broad?)
- Verify order of substitutions
- May need more conservative patterns

---

**Created:** 2025-12-18
**Status:** Ready for execution
**Current:** 8,599/9,552 (90.02%)
**Target:** 8,607-8,612/9,552 (90.10-90.15%)

**Start:** Read continuation plan, implement preprocessing, test, commit!