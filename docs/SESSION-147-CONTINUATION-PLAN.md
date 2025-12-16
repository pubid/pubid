# Session 147+ Continuation Plan: ASME Parser Enhancement

**Created:** 2025-12-15 (Post-Session 146)
**Status:** ASME at 52.82% - Ready for enhancement
**Timeline:** COMPRESSED - Complete in 2-3 sessions (4-6 hours)

---

## Executive Summary

**Session 146 Achievement:** ASME (17th flavor) implemented with MODEL-DRIVEN architecture at 52.82% baseline! 🎉

**Current Status:**
- **ASME:** 384/727 (52.82%)
- **Architecture:** Complete V2 with CSA dual-publishing
- **Ready for:** Parser enhancements to reach 70-80%

**Remaining Work:**
- Session 147: Analyze failure patterns (1 hour)
- Session 148: Parser enhancements (2-3 hours)
- Session 149: Documentation & completion (1 hour)

---

## Current ASME Implementation Status

### Completed Features ✅
- Standard identifier (B16.5, Y14.43, etc.)
- CSA dual-published (A17.1/CSA B44)
- Reaffirmation notation ((R2020))
- Language codes ((SPANISH))
- Draft years (20XX, 202X)
- Revision notes ([Draft Proposed...])

### Known Limitations
- BPVC complex patterns (BPVC.VIII.1, BPVC.CC.BPV, etc.) - ~200 identifiers
- Nested designators (ASME ASME..., ISO/ASME...) - ~50 identifiers
- Complex handbook notation - ~30 identifiers
- Special characters/encoding - ~30 identifiers
- Multiple ASME prefixes - ~53 identifiers

**Total Improvement Potential:** ~343 identifiers (47.18% → 70-80% achievable)

---

## SESSION 147: Failure Pattern Analysis (60 minutes)

### Objective
Systematic analysis of all 343 failures to identify high-impact parser patterns.

### Part A: Extract Failure Samples (15 min)

```bash
cd spec/fixtures/asme/identifiers/fail
cat *.txt | grep "^#" | sed 's/#\([^#]*\)#.*/\1/' > /tmp/asme_failures.txt
head -100 /tmp/asme_failures.txt > /tmp/asme_failures_sample.txt
```

**Action:** Categorize failures by pattern type

### Part B: Pattern Grouping (25 min)

**Group failures into categories:**

1. **BPVC Patterns** (Priority 1 - ~200 IDs)
   - `BPVC.VIII.1-2019` - dotted subdivision
   - `BPVC.CC.BPV.I-2021` - multi-level hierarchy
   - `BPVC COMPLETE CODE BIND-2019` - special BPVC variants

2. **Multiple ASME Prefixes** (Priority 2 - ~53 IDs)
   - `ASME ASME A112.18.1/CSA B125.1-2012`
   - `ASME ASME A17.1/CSA B44 Handbook-2019`

3. **ISO/ASME Patterns** (Priority 3 - ~20 IDs)
   - `ASME ISO/ASME 14414-2015`

4. **Other Patterns** (Priority 4 - ~70 IDs)
   - Handbook variations
   - Special characters
   - Complex combinations

### Part C: Impact Estimation (10 min)

**Estimate gains per pattern:**
- Priority 1 (BPVC): +150-180 IDs → ~73-77%
- Priority 2 (Multiple ASME): +40-50 IDs → ~79-82%
- Priority 3 (ISO/ASME): +15-20 IDs → ~81-83%
- Priority 4 (Other): +30-50 IDs → ~85-90%

### Part D: Create Enhancement Roadmap (10 min)

Document findings in `/tmp/asme_enhancement_roadmap.md`

---

## SESSION 148: Parser Enhancement Implementation (120-180 minutes)

### Objective
Implement Priority 1-2 patterns to achieve 70-80% pass rate.

### Phase 1: BPVC Pattern Support (60 min)

**File:** `lib/pubid_new/asme/parser.rb`

**Add BPVC subdivision parsing:**
```ruby
# BPVC patterns use multi-level dotted notation
rule(:bpvc_subdivision) do
  (
    # BPVC.VIII.1 format
    str("BPVC") >> dot >> 
    match("[IVX]").repeat(1) >> dot >>  # Roman numerals
    match("[0-9A-Z]").repeat(1) |
    
    # BPVC.CC.BPV.I format  
    str("BPVC") >> dot >>
    letters >> dot >>
    letters >> (dot >> match("[IVX]").repeat(1)).maybe |
    
    # BPVC COMPLETE CODE BIND format
    str("BPVC") >> space >> 
    (str("COMPLETE CODE BIND") | str("SSC"))
  ).as(:bpvc_code)
end

# Update designator rule to handle BPVC specially
rule(:designator) do
  (
    bpvc_subdivision |
    str("ISO") |
    str("CSA") |
    str("API") |
    str("ANS") |
    letters
  ).as(:designator)
end
```

**Builder enhancement:**
```ruby
def build_code(parsed_hash)
  code = Components::Code.new
  
  if parsed_hash[:bpvc_code]
    # BPVC uses full code as designator, no separate number
    code.designator = parsed_hash[:bpvc_code].to_s
    code.number = ""
  else
    code.designator = parsed_hash[:designator].to_s
    code.number = parsed_hash[:number].to_s if parsed_hash[:number]
  end
  
  code
end
```

**Expected gain:** +150-180 identifiers → ~73-77%

### Phase 2: Multiple ASME Prefix (40 min)

**Parser enhancement for double ASME:**
```ruby
rule(:double_asme_prefix) do
  publisher >> publisher  # ASME ASME
end

rule(:standard) do
  (double_asme_prefix | publisher) >>
  # ... rest of rules
end
```

**Expected gain:** +40-50 identifiers → ~79-82%

### Phase 3: Testing & Validation (20 min)

```bash
# Test with samples
ruby -e "require_relative 'lib/pubid_new'; puts PubidNew::Asme.parse('ASME BPVC.VIII.1-2019').to_s"

# Run classification
cd spec/fixtures && ruby run_classify.rb asme
```

**Target:** 570-600/727 (78-82%)

---

## SESSION 149: Documentation & Completion (60 minutes)

### Objective
Update all documentation and mark ASME as production-ready.

### Part A: Update README.adoc (30 min)

**File:** `README.adoc`

Add ASME section after ASTM:
```asciidoc
==== ASME (American Society of Mechanical Engineers)
- Status: ✅ 570-600/727 (78-82%)
- Features: BPVC subdivisions, CSA dual-publishing, reaffirmation
- Architecture: Complete V2

.ASME Identifier Patterns
[source,ruby]
----
# Simple standard
asme = PubidNew::Asme.parse("ASME B16.5-2020")
asme.to_s  # => "ASME B16.5-2020"

# CSA dual-published
dual = PubidNew::Asme.parse("ASME A17.1/CSA B44-2022")
dual.csa_number  # => "B44"

# BPVC subdivisions
bpvc = PubidNew::Asme.parse("ASME BPVC.VIII.1-2023")
bpvc.code.designator  # => "BPVC.VIII.1"

# Reaffirmation
reaf = PubidNew::Asme.parse("ASME Y14.43-2011 (R2020)")
reaf.reaffirmation  # => "R2020"
----
```

### Part B: Update Memory Bank (20 min)

**File:** `.kilocode/rules/memory-bank/context.md`

Add Session 147-149 summary at the top.

### Part C: Archive Old Docs (10 min)

Move to `docs/old-docs/sessions/`:
- Session 145-146 continuation prompts
- Create final session summary

---

## Implementation Status Tracker

### ASME Features Implementation

| Feature | Files | Status | Pass Rate | Notes |
|---------|-------|--------|-----------|-------|
| **Base Standard** | Standard | ✅ Complete | 52.82% | B, Y, A series |
| **CSA Dual** | Parser/Base | ✅ Complete | - | A17.1/CSA B44 |
| **BPVC Patterns** | Parser | ⏳ Ready | - | Priority 1 |
| **Multiple ASME** | Parser | ⏳ Ready | - | Priority 2 |
| **ISO/ASME** | Parser | ⏳ Ready | - | Priority 3 |

### Session Progress

| Session | Focus | Duration | Deliverables | Status |
|---------|-------|----------|--------------|--------|
| 146 | Base implementation | 90 min | 8 files, 52.82% | ✅ Complete |
| 147 | Failure analysis | 60 min | Roadmap, patterns | ⏳ Pending |
| 148 | Parser enhancement | 120 min | BPVC, double ASME | ⏳ Pending |
| 149 | Documentation | 60 min | README, memory bank | ⏳ Pending |

---

## Success Criteria

### Minimum (70%)
- ✅ BPVC basic patterns working
- ✅ 509+/727 identifiers passing
- ✅ Architecture maintained

### Target (78-82%)
- ✅ BPVC complete patterns
- ✅ Multiple ASME prefix
- ✅ 570-600/727 identifiers
- ✅ Production-ready

### Stretch (85%+)
- ✅ ISO/ASME patterns
- ✅ Special cases handled
- ✅ 618+/727 identifiers

---

## Key Architectural Principles

**MAINTAIN throughout:**
1. **MODEL-DRIVEN** - Objects not strings
2. **MECE** - Mutually exclusive types
3. **Three-layer** - Parser/Builder/Identifier independence
4. **Component pattern** - Code component with proper API
5. **Parser-only changes** - No Builder rewrites needed

---

## Files to Modify

### Session 148
- `lib/pubid_new/asme/parser.rb` - BPVC and double ASME patterns
- `lib/pubid_new/asme/builder.rb` - BPVC code handling

### Session 149
- `README.adoc` - ASME section
- `.kilocode/rules/memory-bank/context.md` - Sessions 146-149

---

## Next Immediate Steps (Session 147)

1. Read this continuation plan
2. Extract failure samples from spec/fixtures/asme/identifiers/fail/
3. Group by pattern type (BPVC, double ASME, ISO/ASME, other)
4. Estimate impact of each pattern
5. Create enhancement roadmap
6. Document findings

---

**Created:** 2025-12-15
**Sessions Covered:** 147-149
**Status:** Ready for execution
**Estimated Time:** 4-6 hours (compressed)

**End Goal:** ASME 78-82% with production-ready BPVC support! 🚀
