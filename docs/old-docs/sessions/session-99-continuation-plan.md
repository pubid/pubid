# Session 99+ Continuation Plan: Complete ISO + Start IEC Rendering

**Created:** 2025-12-09 (Post-Session 98)  
**Status:** ISO 98.48%, need final cleanup then IEC  
**Current:** Rendering style system working, fixtures need refinement  
**Timeline:** 2-3 sessions to complete ISO + IEC

---

## Current State (Session 98 Complete)

### Achievement
- TypedStage short/long abbreviation system implemented
- Builder auto-detects rendering style from parsed format
- Classification system created for iterative testing
- **ISO: 98.48% (7,532/7,648)**

### Remaining ISO Issues

**Issue 1: Corrigendum period handling (12 entries in fail)**
```
# Currently in fail but should be in PASS:
!ISO 14687-1:1999/Cor.1:2001(fr)!ISO 14687-1:1999/Cor 1:2001(fr)
!ISO 10993-4:2002/Amd.1:2006(E)!ISO 10993-4:2002/Amd 1:2006(E)
```

These parse successfully and render correctly (period removed). They are PASSES showing successful normalization.

**Issue 2: Mysterious duplicate parse errors**
```
# Parse error: Parslet::ParseFailed
ISO/CEI 10164-5:1993/Amd.1:1995/Cor.1:1996(fr)
# Parse error: Parslet::ParseFailed
ISO/CEI 10164-5:1993/Amd.1:1995/Cor.1:1996(fr)
```

Duplicate entries suggest collection logic issue.

**Issue 3: Directives identifiers** 
Check spec/fixtures/iso/fail/directives.txt for issues.

---

## SESSION 99 TASKS

### Part A: Fix Corrigendum Period Detection (30 min)

**Problem:** Parser doesn't recognize "Cor.1" (with period+number)

**Solution:** Add parser pattern for period-number format

**Files to modify:**
- lib/pubid_new/iso/parser.rb (add Cor.\d+ pattern)

**Expected:** All "Cor.1" entries move to pass (12+ identifiers)

### Part B: Fix Duplicate Collection (15 min)

**Problem:** collect_all_identifiers may be reading same file twice or not properly deduplicating

**Solution:** Debug collect logic, ensure .uniq works

**Files to check:**
- spec/fixtures/classify_fixtures.rb (collect_all_identifiers method)

### Part C: Review Directives Failures (15 min)

**Files to check:**
- spec/fixtures/iso/fail/directives.txt

**Action:** Identify patterns and fix if architectural

### Part D: Run Final Classification (10 min)

```bash
bundle exec ruby spec/fixtures/run_classify.rb iso
```

**Expected:** ISO 99%+ (only legitimate parser gaps in fail)

---

## SESSION 100: IEC Rendering Styles (120 min)

### Objective
Apply same rendering style pattern to IEC

### Part A: IEC TypedStage Enhancement (40 min)

**Current IEC stages:**
- Amendment: Published (AMD1, Amd 1), CDV, FDIS
- Corrigendum: Published (COR1, Cor 1), FDIS

**Tasks:**
1. Read IEC Amendment/Corrigendum TYPED_STAGES
2. Add short_abbr and long_abbr to each stage
3. Follow ISO pattern:
   - SHORT: AMD1, CDV, FDIS, COR1 (uppercase or as-is)
   - LONG: Amd 1, CD, FDIS, Cor 1 (title case with space)

**Files to modify:**
- lib/pubid_new/iec/identifiers/amendment.rb
- lib/pubid_new/iec/identifiers/corrigendum.rb

### Part B: IEC Builder Detection (30 min)

**Tasks:**
1. Add rendering_style detection to IEC Builder
2. Follow ISO pattern exactly
3. Detect long/short from original_abbr.start_with?()
4. Detect language format
5. Set with_date

**Files to modify:**
- lib/pubid_new/iec/builder.rb

### Part C: IEC RenderingStyle Classes (30 min)

**Tasks:**
1. Create lib/pubid_new/iec/rendering_style.rb
2. Copy ISO pattern
3. Adapt for IEC-specific needs

**Files to create:**
- lib/pubid_new/iec/rendering_style.rb

### Part D: Test and Validate (20 min)

**Run:**
```bash
bundle exec ruby spec/fixtures/run_extraction.rb iec
bundle exec ruby spec/fixtures/run_classify.rb iec
```

**Expected:** IEC 99%+ (already at 99.93%)

---

## SESSION 101: Documentation Updates (90 min)

### Part A: Update Memory Bank (20 min)

**Files to update:**
- .kilocode/rules/memory-bank/context.md
- .kilocode/rules/memory-bank/architecture.md (add rendering styles section)

### Part B: Create Rendering Guide (40 min)

**File to create:**
- docs/RENDERING_GUIDE.md

**Content:**
- Overview of rendering styles
- SHORT vs LONG forms (AMD/Amd, DAM/DAmd, etc.)
- Language code options (E vs en)
- Date inclusion
- Usage examples
- API reference

### Part C: Archive Temporary Docs (30 min)

**Move to docs/old-docs/sessions/:**
- All session-*-continuation-plan.md files
- All session-*-summary.md files
- All SESSION-*.md files

**Keep in docs/:**
- V2_ARCHITECTURE.adoc
- RENDERING_GUIDE.md (new)
- URN-GENERATION-GUIDE.adoc
- RFC-5141-BIS.adoc

---

## CRITICAL CORRECTIONS FROM SESSION 98

### Short vs Long Forms (FINAL TRUTH)

**SHORT forms (uppercase or canonical):**
- AMD, DAM, FDAM (draft amendments)
- COR, DCOR, FDCOR (draft corrigenda)

**LONG forms (title/mixed case, may have space/suffix):**
- Amd, DAmd, FDAmd (amendments)
- Cor, DCor, FDCor (corrigenda)

### Rendering Options (INDEPENDENT)

Rendering options set individually based on parsed format:
- `stage_format_long`: true/false (Amd vs AMD)
- `with_language_code`: :none/:single/:iso (none, E, en)
- `with_date`: true/false (show year or not)

These are NOT predefined profiles but individual options!

### Classification Rules

**!original!rendered format:**
1. If rendered == expected → **PASS** (successful normalization!)
2. If rendered != expected → **FAIL** (update with actual)
3. Parse error → FAIL with comment

**Example PASSES:**
```
!ISO 105-B01:1994/AMD 1:1998!ISO 105-B01:1994/Amd 1:1998  # Variant normalized
!ISO 10993-4:2002/Amd.1:2006(E)!ISO 10993-4:2002/Amd 1:2006(E)  # Period removed 
```

---

## KEY FILES

### Implementation
- lib/pubid_new/components/typed_stage.rb
- lib/pubid_new/iso/builder.rb
- lib/pubid_new/iso/rendering_style.rb
- lib/pubid_new/iso/identifiers/amendment.rb
- lib/pubid_new/iso/identifiers/corrigendum.rb

### Tools
- spec/fixtures/extract_fixtures.rb (initial extraction)
- spec/fixtures/classify_fixtures.rb (reclassification)
- spec/fixtures/run_extraction.rb (runner)
- spec/fixtures/run_classify.rb (runner)

### Documentation
- .kilocode/rules/memory-bank/session-98-continuation-plan.md
- .kilocode/rules/memory-bank/session-99-continuation-plan.md (this file)

---

## SESSION 99 START CHECKLIST

1. ✅ Read this continuation plan
2. ✅ Fix Corrigendum period parsing
3. ✅ Fix duplicate collection
4. ✅ Review directives failures
5. ✅ Run final ISO classification
6. ✅ Verify ISO 99%+

**Then proceed to Session 100 for IEC rendering styles**

---

## Success Criteria

### Session 99  
- ✅ ISO 99%+ (7,600+/7,688)
- ✅ Only legitimate parser gaps in fail
- ✅ All normalizations in pass with !...!... format
- ✅ No duplicates

### Session 100
- ✅ IEC rendering styles implemented
- ✅ IEC 99%+ maintained
- ✅ Same pattern as ISO

### Session 101
- ✅ Documentation complete
- ✅ Temporary docs archived
- ✅ Project ready

---

Good luck with Session 99!