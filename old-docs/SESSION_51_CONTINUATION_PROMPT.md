# Session 51+ Continuation Prompt

**Goal:** Complete MODEL-DRIVEN refactoring for ALL flavors with 100% per-class spec coverage  
**Reference:** [`docs/ARCHITECTURE_REFACTORING_PLAN.md`](docs/ARCHITECTURE_REFACTORING_PLAN.md:1)

---

## Critical Principle: ONE CLASS PER TYPE

**✅ CORRECT:** One identifier class per series/document type (like ISO/NIST)  
**❌ WRONG:** One base class handling all types via string attributes

---

## Status Overview

**Complete:**
- ISO: 18 classes, 19 specs, 92.84% passing
- NIST: 11 classes, 3 specs, 100% passing

**Needs Specs:**
- IEC: 22 classes, 2 specs → **20 missing**
- IEEE: 7 classes, 3 specs → **4 missing**
- NIST: Needs 8 per-series specs

**Needs Refactoring:**
- JIS, ITU, CCSDS, BSI, CEN, PLATEAU, ETSI, ANSI, IDF

---

## Next Steps

### Option A: IEC Specs (Sessions 51-56)
Create 20 missing identifier specs, 3-4 per session

### Option B: NIST Specs (Session 51)
Create 8 series-specific specs (SP, FIPS, IR, HB, TN, etc.)

### Option C: Audit Other Flavors
Verify architecture, plan refactoring

---

## Quick Reference

**Architecture Pattern:**
1. Scheme class with registry
2. Builder with cast() method
3. One identifier class per type
4. Components are shared attributes

**Spec Pattern:**
- 50-70 tests per identifier class
- Test basic, stages, parts, edges, round-trip

**Files:** See [`ARCHITECTURE_REFACTORING_PLAN.md`](docs/ARCHITECTURE_REFACTORING_PLAN.md:1) for complete details