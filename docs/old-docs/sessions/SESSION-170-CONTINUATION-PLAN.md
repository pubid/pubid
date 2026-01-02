# Session 170+ Continuation Plan: IEEE 90% Milestone Push

**Created:** 2025-12-17 (Post-Session 169)
**Status:** IEEE at 89.73%, +25 IDs needed for 90%
**Timeline:** 1-2 sessions (60-120 minutes)

---

## Session 169 Summary

**Achievement:** +10 identifiers with safe, targeted enhancements ✅

**Results:**
- **Baseline:** 8,548/9,537 (89.63%)
- **Final:** 8,558/9,537 (89.73%)
- **Improvement:** +10 identifiers (+0.10pp)

**Patterns Implemented:**
1. Semicolon-separated dual published (+2 IDs)
2. Reaffirmed + Revision combined (+8 IDs)
3. Safe typo fixes: /lNT, I99O, .l/, EEE

**Critical Learning:**
- Aggressive preprocessing (paren balancing, space fixes) caused -400 ID regression
- Reverted immediately to safe fixes only
- Success through targeted, proven patterns

---

## Session 170 Objective

**Goal:** Push IEEE from 89.73% to 90%+ (8,583/9,537)
**Gap:** +25 identifiers needed

---

## High-Impact Remaining Patterns

### Priority 1: AIEE Parenthetical Formats (~5-8 IDs)

**Pattern:** `AIEE No 18-1934 (ASA C55 1934)`

**Current issue:** Parser expects IEEE-like parentheticals, but AIEE has ASA references

**Solution:** Handle in Base.parse for AIEE identifiers with ASA parentheticals

### Priority 2: Enhanced Reaffirmed + Revision (~5-8 IDs)

**Additional patterns:**
- `ANSI/IEEE Std 101-1987(R2010) (Revision of IEEE Std 101-1972)`
- `ANSI C50.32-1976 and IEEE Std 117-1974 (Reaffirmed 1984) (Revision of IEEE Std 117-1956)`

**Current:** Basic (R####) (Revision) works
**Missing:** ANSI/IEEE prefix, "and" dual with reaffirmed

### Priority 3: ANSI/IEEE-ANS Hyphenated (~10 IDs)

**Pattern:** `ANSI/IEEE-ANS-7-4.3.2-1982`

**Issue:** Complex hyphenated multi-part numbers
**Solution:** Enhance number rule to handle this specific case

### Priority 4: Amendment/Corrigendum Title Patterns (~5 IDs)

**Patterns:**
- `Amendment to IEEE Std 802.11-2007 as amended by...`
- `Corrigendum to IEEE Std 802.3-2015 as amended by...`

**Issue:** These start with relationship type, not publisher
**Solution:** Special handling in Base.parse

---

## Implementation Strategy

### Conservative Approach (Recommended)

**Session 170 (60 min):**
1. AIEE parenthetical ASA references (20 min) - +5-8 IDs
2. Enhanced Reaffirmed patterns (20 min) - +5-8 IDs
3. Test and validate (20 min)
4. **Expected: 89.88-89.90%** (close to or at 90%)

### Aggressive Approach (If time permits)

**Session 170 (90 min):**
1. All Priority 1-2 patterns (40 min) - +10-16 IDs
2. ANSI/IEEE-ANS hyphenated (30 min) - +10 IDs
3. Test and validate (20 min)
4. **Expected: 90.1-90.3%** (past 90% milestone!)

---

## Files to Modify

### Session 170
- `lib/pubid_new/ieee/identifiers/base.rb` - AIEE ASA parentheticals, enhanced Reaffirmed
- `lib/pubid_new/ieee/parser.rb` (maybe) - ANSI/IEEE-ANS only if needed

---

## Success Criteria

### Minimum (89.9%)
- +15 identifiers from Priority 1-2
- No regressions
- Clean architecture maintained

### Target (90%+)
- +25+ identifiers
- 90% milestone achieved
- All safe patterns implemented

---

## Testing Strategy

1. **After each pattern:** Run classification immediately
2. **On regression:** Revert changes, analyze why
3. **Document gains:** Track which pattern gave which improvement
4. **Incremental commits:** One pattern per commit if possible

---

## Key Reminders

- Only SAFE, PROVEN preprocessing
- Test after EACH change
- Revert IMMEDIATELY on regression
- Architecture correctness > test count
- Document everything

---

**Created:** 2025-12-17
**Status:** Ready for Session 170
**Goal:** IEEE 90%+ (8,583/9,537)
**Current:** IEEE 89.73% (8,558/9,537)
**Gap:** +25 identifiers

**Next session:** Careful, incremental push to 90% milestone! 🎯
