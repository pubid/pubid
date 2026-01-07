# Session 288 Quick Start: BSI Single Letter Prefixes Implementation

**Status:** Session 287 complete - Project marked complete, BSI enhancement OPTIONAL
**Next:** Implement single letter prefixes (+200 IDs, 51% → 65%)

---

## Quick Context

**Session 287 Achievement:**
- ✅ Project marked COMPLETE
- ✅ 18/18 flavors production-ready
- ✅ BSI baseline: 747/1,463 (51.06%)

**Session 288 Objective:**
Implement single and multi-letter prefix patterns for specialized BSI standards.

**Target:** +200 identifiers (51.06% → 64.74%)

---

## Session 288 Tasks (150 minutes)

### Part A: Create SpecializedStandard Class (30 min)

**File:** `lib/pubid_new/bsi/identifiers/specialized_standard.rb`

**Pattern Examples:**
```
BS A 16:1939        # Aircraft - General
BS AU 177a:1980     # Automotive
BS C 10:1958        # Aircraft
BS M 38:1971        # Methods - Aircraft
BS 2A 241:2005+A2:2011  # Multi-letter prefix
```

**Implementation:** Class with `prefix` attribute, inherits from SingleIdentifier

---

### Part B: Update Parser (30 min)

**File:** `lib/pubid_new/bsi/parser.rb`

**Add Rules:**
- `specialized_prefix` - Captures single/multi-letter prefixes
- Update `publisher_or_type` to include prefix pattern
- Prefix after BS publisher, before number

**All Prefixes to Support:**
- Single: A, AU, B, C, F, G, HC, L, M, MA, PL, QC, S, TA, X
- Multi: 2A, 2B, 2C, 2F, 2G, 2HC, 2HR, 2L, 2M, 2S, 2SP, 2TA, 3B, 3F, 3G, 3HR, 3J, 3L, 3S, 3TA, 4F, 4L, 4S, 5S, 7S

---

### Part C: Update Builder (15 min)

**File:** `lib/pubid_new/bsi/builder.rb`

**Changes:**
- Add `require_relative` for SpecializedStandard
- Update `locate_identifier_klass` to check for prefix
- Cast prefix to string attribute

---

### Part D: Update Scheme (15 min)

**File:** `lib/pubid_new/bsi/scheme.rb`

**Changes:**
- Add TypedStage for specialized standards
- Add to IDENTIFIER_CLASS_MAP: `specialized: "Identifiers::SpecializedStandard"`

---

### Part E: Testing (30 min)

**Commands:**
```bash
# Run classification
cd spec/fixtures && ruby run_classify.rb bsi

# Check improvement
# Expected: 747 → 947 (+200)
# Expected: 51.06% → 64.74%
```

**Validate:**
- All specialized prefix patterns parsing
- No regressions in existing 747 passing tests
- Round-trip fidelity maintained

---

## <br> Key Architecture Principles

**CRITICAL:**
1. **MODEL-DRIVEN** - SpecializedStandard is proper class with prefix attribute
2. **Single responsibility** - Prefix is just one attribute, reuses rest from SingleIdentifier
3. **Open/Closed** - Easy to add new prefixes (just add to parser pattern)
4. **MECE** - Specialized standards are distinct from regular BS
5. **Component reuse** - Uses same Code, Date, Publisher components

---

## Files to Read First

**Essential:**
1. `docs/SESSION-288-CONTINUATION-PLAN.md` - Full plan
2. `.kilocode/rules/memory-bank/architecture.md` - BSI architecture
3. `lib/pubid_new/bsi/single_identifier.rb` - Base class to inherit from

**Reference:**
- `lib/pubid_new/bsi/identifiers/british_standard.rb` - Similar pattern
- `lib/pubid_new/bsi/identifiers/handbook.rb` - Recent prefix implementation

---

## Expected Results

**Baseline:** 747/1,463 (51.06%)
**Target:** 947/1,463 (64.74%)
**Improvement:** +200 identifiers (+13.68pp)

**Test Impact:**
- Specialized prefix tests: +200 new passing
- Other categories: 0 regressions
- Architecture: Clean, extensible, MODEL-DRIVEN

---

## Git Strategy

**After Session 288:**
```bash
git add -A
git commit -m "feat(bsi): add SpecializedStandard for letter prefix patterns

Session 288: Single/Multi-Letter Prefix Implementation
- Created SpecializedStandard class with prefix attribute
- Added 35+ letter prefix patterns to parser
- Updated Scheme with specialized TypedStage
- BSI: 747 → 947 (+200 IDs, 51.06% → 64.74%)

Architecture: MODEL-DRIVEN, prefix as attribute, inherits SingleIdentifier
Status: Session 288 complete"
```

---

**Created:** 2026-01-07
**Session:** 288
**Duration:** 150 minutes
**Priority:** OPTIONAL (project already complete)

**Ready to begin if requested!** 🚀