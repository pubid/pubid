# Session 249+ Quick Start: NIST Phase 2 & PLATEAU Expansion

**Read Full Plan:** [`docs/SESSION-249-CONTINUATION-PLAN.md`](SESSION-249-CONTINUATION-PLAN.md)

---

## Situation

Session 248 completed:
- ✅ NIST parser enhancement: +17 tests (58.7% → 61.4%)
- ✅ IssueNumber component: Proper v#n# semantics (Volume 6, Number 12)

**Current NIST:** 372/606 (61.4%)
**Target:** 450+/606 (74%+) with ~78 more tests

---

## Next Work (Sessions 249-252)

### Session 249-250: NIST Parser Phase 2 (4-5h)

**Priority fixes for 74%+ pass rate:**

1. **Revision Year Preservation** (+20-25 tests expected)
   - Pattern: "NBS LC 1019r1963" loses "r1963"
   - Fix: Preserve full revision with year in Builder and rendering

2. **Supplement Date Patterns** (+15-20 tests)
   - Pattern: "NBS LCIRC 118supp3/1926", "NBS CIRC 25suppJan1924"
   - Fix: Preserve supplement dates in Builder/rendering

3. **Edition Date Preservation** (+10-15 tests)
   - Pattern: "NBS CIRC 13e2revJune1908" rendering issues
   - Fix: Ensure all edition+date components preserved

4. **Complex Number Patterns** (+10-15 tests)
   - Pattern: "NBS MONO 25e5", "NBS BMS 140C"
   - Fix: Verify parsing and rendering

5. **Update Format Consistency** (+5-10 tests)
   - Pattern: Various "-upd" and "/upd" notations
   - Fix: Ensure consistent rendering

**Files to modify:**
- `lib/pubid_new/nist/builder.rb`
- `lib/pubid_new/nist/identifiers/base.rb`
- `lib/pubid_new/nist/identifiers/letter_circular.rb`

---

### Session 251: PLATEAU Standard + Annex (2h)

**User request:** PLATEAU has Standard and Annex identifiers

**Tasks:**
1. Analyze PLATEAU patterns (30 min)
2. Implement Standard class (45 min)  
3. Implement Annex class (45 min)
4. Create specs and test

---

### Session 252: Documentation (1-2h)

**Cleanup and complete:**
- Archive completed session docs
- Update README.adoc (NIST + PLATEAU)
- Create memory bank summary

---

## Quick Start

**For Session 249:**
1. Read continuation plan
2. Start with revision year preservation (highest impact)
3. Test incrementally
4. Commit after each fix

**Architecture Principles:**
- Correctness > pass rate
- MODEL-DRIVEN always
- MECE organization
- No compromises

---

**Created:** 2025-12-31
**Status:** Ready to continue
**Session 248:** +17 tests, IssueNumber component ✅
**Target:** 74%+ NIST, PLATEAU complete, full docs

**Let's finish the enhancements!** 🚀
