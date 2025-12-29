# Session 224 Continuation Prompt

**Read this file to continue IEEE TODO Quick Wins implementation.**

## Quick Start

1. Read the comprehensive plan: [`docs/SESSION-224-CONTINUATION-PLAN.md`](SESSION-224-CONTINUATION-PLAN.md:1)
2. Read memory bank files (automatically done by system)
3. Begin Session 224 implementation

## What to Do

**Session 224 Goal:** Implement preprocessing enhancements for 8 patterns + test 2 complex amendments

**User requested these 16 patterns be fixed:**

```
IEEE/EIA 12207.0-1996
IEEE/EIA 12207.1-1997
IEEE/EIA 12207.2-1997
IEEE/ASTM SI 10-1997
IEEE/ASTM SI 10-2002 (Revision of IEEE/ASTM SI 10-1997)
IEEE/ASTM SI 10-2016 (Revision of IEEE/ASTM SI 10-2010)
IEEE Std. 1244.2-2000
IEEE Std. C62.21-2003/Cor 1-2008 (Corrigendum to IEEE Std C62.21-2003)
IEEE Std C37.101 -2006 (...) - Redline
IEEE Std C37.102 -2006 (...) - Redline
IEEE Std C37.20.3-2001 - IEEE Standard for metal-enclosed interrupter switchgear
IEEE Std C57.110™-2018 (Revision of IEEE Std C57.110-2008)
IEEE Std C57.13-1993(R2003) (Revision of IEEE Std C57.13-1978
IEEE Std C62.35- 2010 (Revision of IEEE Std C62.35-1987)
IEEE Std 802.11g-2003 (Amendment to IEEE Std 802.11, 1999 Edn. ...)
IEEE Std 802.11h-2003 (Amendment to IEEE Std 802.11, 1999 Edn. ...)
```

## Session 224 Tasks

**Phase 1: Preprocessing Enhancements (30 min)**

Add to `lib/pubid_new/ieee/parser.rb` preprocessing block (around line 851):

1. Period after Std: `Std.` → `Std`
2. Trademark symbols: `™` and `&x2122;` removal
3. Space normalization: ` -` and `- ` → `-`
4. Redline suffix: ` - Redline` removal
5. Title portion: ` - IEEE Standard for...` removal
6. Unbalanced parentheses: Auto-close

**Phase 2: Test Complex Amendments (10 min)**

Test if Pattern 4 already handles:
- `IEEE Std 802.11g-2003 (Amendment to...)`
- `IEEE Std 802.11h-2003 (Amendment to...)`

**Phase 3: Validation (20 min)**

Run tests and verify improvement.

## Expected Results

- **TODO:** 32/115 → 40/115 (34.8%) minimum
- **Real fixtures:** 8,409/9,537 maintained
- **No regressions**

## Files to Modify

- `lib/pubid_new/ieee/parser.rb` - Preprocessing only

## Architecture Principles

- **MODEL-DRIVEN** - No compromises
- **Parser-only changes** - Preprocessing enhancements
- **Zero regressions** - Maintain production quality

---

**Estimated Time:** 60 minutes
**Target:** +8-10 identifiers (Session 224 only)
**Total Target:** +16 identifiers across Sessions 224-225

**Let's implement the quick wins!** 🎯
