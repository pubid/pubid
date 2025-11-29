# Session 50: CRITICAL - Comprehensive Spec Audit

**Status:** READY TO BEGIN  
**Priority:** CRITICAL (BLOCKS V1 REMOVAL)  
**Duration:** 60 minutes  
**Goal:** Audit all identifier classes and create complete spec migration plan

---

## CRITICAL DISCOVERY

**Problem:** "100% passing" tests are MISLEADING!

- NIST shows 57/57 (100%) but only has 5 spec files out of 20 V1 specs
- We're testing SOME identifiers but not ALL classes
- **Cannot remove V1 code** without complete per-class spec coverage

**Requirement:** Each identifier class MUST have its own spec file

---

## Session 50 Tasks

### Task 1: Count All Identifier Classes (20 min)

For each production-ready flavor, count classes vs specs:

```bash
for flavor in iso iec ieee nist; do
  echo "=== $flavor ==="
  echo "Identifier classes:"
  ls lib/pubid_new/$flavor/identifiers/*.rb 2>/dev/null | wc -l
  ls lib/pubid_new/$flavor/identifiers/*.rb 2>/dev/null
  echo ""
  echo "V2 spec files:"
  ls spec/pubid_new/$flavor/identifiers/*_spec.rb 2>/dev/null | wc -l
  ls spec/pubid_new/$flavor/identifiers/*_spec.rb 2>/dev/null
  echo ""
  echo "V1 spec files:"
  ls gems/pubid-$flavor/spec/**/*_spec.rb 2>/dev/null | wc -l
  echo "---"
done
```

**Output to:** `docs/spec-audit-results.txt`

---

### Task 2: Create Spec Migration Matrix (30 min)

For each flavor, create detailed mapping:

**docs/SPEC_MIGRATION_MATRIX.md:**

```markdown
# Spec Migration Matrix

## NIST (CRITICAL - 15 missing)

| Class File | V1 Spec | V2 Spec | Status |
|------------|---------|---------|--------|
| base.rb | ✅ | ✅ | DONE |
| special_publication.rb | ✅ | ❌ | MISSING |
| federal_information_processing_standards.rb | ✅ | ❌ | MISSING |
| ... | | | |

**Missing:** 15 spec files
**Priority:** CRITICAL

## IEEE (1 missing)

| Class File | V1 Spec | V2 Spec | Status |
|------------|---------|---------|--------|
| ... | | | |

**Missing:** 1 spec file
**Priority:** MEDIUM

## IEC (3 missing)
... continue for all flavors

## JIS (3 missing)
...

```

---

### Task 3: Create Session-by-Session Plan (10 min)

Break down spec migration into sessions:

**Sessions 51-55: NIST (3 specs/session = 15 total)**
- Session 51: SP, FIPS, IR
- Session 52: GCR, HB, SP variants
- Session 53: TN, OWMWP, AMS
- Session 54: NCSTAR, WPS, BSS  
- Session 55: Remaining types

**Session 56: IEC (3 specs)**
**Session 57: JIS (3 specs)**
**Session 58: IEEE (1 spec)**

**Total:** 9 sessions to complete Phase 0

---

## Deliverables

1. **docs/spec-audit-results.txt**
   - Raw counts per flavor
   - Class vs spec mapping

2. **docs/SPEC_MIGRATION_MATRIX.md**
   - Complete gap analysis
   - Per-class migration status
   - Priority rankings

3. **Updated CONTINUATION_PLAN_V2_COMPLETE.md**
   - Phase 0 details confirmed
   - Session assignments finalized

4. **Updated SESSION_50_PROMPT.md**
   - Document what was found
   - Clear handoff to Session 51

---

## Success Criteria

- ✅ Every identifier class accounted for
- ✅ Exact gap quantified (expecting ~22 missing specs)
- ✅ Migration order established
- ✅ Ready to begin systematic migration in Session 51

---

## Key Commands

```bash
# Count identifier classes
find lib/pubid_new/nist/identifiers -name "*.rb" -type f | wc -l

# Count V2 specs
find spec/pubid_new/nist/identifiers -name "*_spec.rb" -type f | wc -l

# Count V1 specs
find gems/pubid-nist/spec -name "*_spec.rb" -type f | wc -l

# List missing mappings
comm -23 \
  <(ls lib/pubid_new/nist/identifiers/*.rb | xargs -n1 basename | sort) \
  <(ls spec/pubid_new/nist/identifiers/*_spec.rb | xargs -n1 basename | sed 's/_spec//' | sort)
```

---

## After Session 50

**Session 51-58:** Systematic spec migration (22 specs)
**Session 59:** ISO documentation (README URN section)
**Session 60:** V1→V2 migration guide
**Session 61:** Remove V1 code (ONLY after specs complete)

---

## Why This is Critical

1. **NIST "100%" is false confidence** - Only 25% of classes tested
2. **V1 removal would lose coverage** - Missing specs = untested code
3. **Each class needs validation** - Individual spec files ensure completeness
4. **Blocks production deployment** - Cannot ship without full test coverage

**We MUST complete Phase 0 before any V1 removal!**

---

## Quick Start

```bash
# Start audit
cd /Users/mulgogi/src/mn/pubid

# Check NIST specifically
echo "NIST Classes:"
ls lib/pubid_new/nist/identifiers/*.rb | wc -l

echo "NIST V2 Specs:"
ls spec/pubid_new/nist/identifiers/*_spec.rb | wc -l

echo "NIST V1 Specs:"
ls gems/pubid-nist/spec/**/*_spec.rb | wc -l

# The gap should be obvious!
```

Good luck with Session 50! This is CRITICAL work! 🚨