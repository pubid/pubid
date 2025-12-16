# Session 147 Continuation Prompt

**Session:** 147
**Focus:** ASME Parser Enhancement - Failure Analysis
**Duration:** 60-90 minutes
**Prerequisites:** Session 146 complete (ASME at 52.82%)

---

## Objective

Analyze ASME failure patterns systematically to plan targeted parser enhancements.

**Current Status:**
- ASME: 384/727 (52.82%)
- Architecture: Complete and validated
- Strategy: Parser-only enhancements (no architecture changes)

---

## Quick Start

### Step 1: Read Context (5 min)

**Read memory bank:**
- `.kilocode/rules/memory-bank/context.md` - Session 146 completion
- `.kilocode/rules/memory-bank/architecture.md` - V2 architecture
- `docs/SESSION-147-CONTINUATION-PLAN.md` - Full enhancement plan

**Current implementation:**
- `lib/pubid_new/asme/parser.rb` - What patterns work now
- `lib/pubid_new/asme/builder.rb` - How objects are built
- `spec/fixtures/asme/identifiers/pass/standard.txt` - 384 passing patterns

---

### Step 2: Extract Failure Samples (10 min)

```bash
cd /Users/mulgogi/src/mn/pubid/spec/fixtures/asme/identifiers/fail
cat *.txt | grep "^#" | sed 's/#\([^#]*\)#.*/\1/' > /tmp/asme_failures.txt

# Get pattern frequency
head -200 /tmp/asme_failures.txt | cut -d' ' -f2-3 | sort | uniq -c | sort -rn | head -20
```

**Look for:**
- Common prefixes (BPVC, ISO/ASME, double ASME)
- Pattern clusters
- Complex number formats

---

### Step 3: Detailed Pattern Analysis (25 min)

**For each major pattern found:**

**A. BPVC Patterns** (estimate ~200 IDs)
```bash
grep "BPVC" /tmp/asme_failures.txt | head -30
```

**Document:**
- How many variants (BPVC.I, BPVC.VIII.1, BPVC.CC.BPV, etc.)
- Example identifiers (pick 5-10 representative ones)
- Current parser limitation (what rule is missing)
- Complexity (simple/medium/complex to implement)

**B. Multiple ASME Prefix** (estimate ~53 IDs)
```bash
grep "ASME ASME" /tmp/asme_failures.txt | head -20
```

**Document:**
- Pattern variants ("ASME ASME A112..." vs "ASME ASME/ANS...")
- Example identifiers
- Parser change needed
- Complexity

**C. ISO/ASME Joint** (estimate ~20 IDs)
```bash
grep "ISO/ASME" /tmp/asme_failures.txt | head -20
```

**Document:**
- Format ("ISO/ASME 14414-2015")
- Example identifiers
- Parser change needed

**D. Other Patterns** (estimate ~70 IDs)
- Group remaining failures
- Identify if there are any other significant patterns

---

### Step 4: Create Enhancement Roadmap (20 min)

**Write to:** `/tmp/asme_enhancement_roadmap.md`

**Template:**
```markdown
# ASME Parser Enhancement Roadmap

## Session 146 Baseline
- Total: 727 identifiers
- Passing: 384 (52.82%)
- Failing: 343 (47.18%)

## Priority 1: BPVC Patterns (~XXX identifiers)

**Examples:**
1. ASME BPVC.VIII.1-2019
2. ASME BPVC.CC.BPV.I-2021
3. ASME BPVC COMPLETE CODE BIND-2023

**Current Limitation:**
Parser only recognizes single-letter designators, not complex BPVC dotted notation.

**Parser Changes Needed:**
- Add bpvc_subdivision rule with roman numerals
- Add BPVC special variants (COMPLETE CODE BIND, SSC)
- Update designator rule to try BPVC patterns first

**Builder Changes:**
- Handle bpvc_code separately in build_code method
- BPVC uses full code as designator

**Complexity:** Medium
**Estimated Gain:** +150-180 identifiers
**New Pass Rate:** ~73-77%

## Priority 2: Multiple ASME Prefix (~XX identifiers)

[Same template]

## Implementation Order
1. Session 148 Part 1: BPVC patterns (60 min) → 73-77%
2. Session 148 Part 2: Multiple ASME (40 min) → 79-82%
3. Session 148 Part 3: ISO/ASME (30 min) → 81-83%
4. Session 149: Documentation (60 min)

**Realistic Final Target:** 78-82% (570-600/727)
```

---

### Step 5: Document Findings (10 min)

**Create:** `docs/old-docs/sessions/session-147-summary.md`

Include:
- Analysis completed
- Top 3-4 patterns identified
- Impact estimates
- Roadmap created
- Ready for Session 148

---

## Expected Outcomes

**Minimum Success:**
- Top 3 patterns identified with counts
- Clear parser changes specified
- Realistic gain estimates
- Ready to implement in Session 148

**Target Success:**
- All major patterns categorized
- Detailed roadmap with code examples
- 70-80% path clearly defined
- Edge cases documented

**Stretch Success:**
- Complete pattern taxonomy
- 85%+ path identified
- Alternative approaches documented

---

## Test Command Reference

**Check passing patterns:**
```bash
cat spec/fixtures/asme/identifiers/pass/standard.txt | head -20
```

**Sample parsing test:**
```bash
ruby -e "require_relative 'lib/pubid_new'; puts PubidNew::Asme.parse('ASME B16.5-2020').to_s"
```

**Full classification:**
```bash
cd spec/fixtures && ruby run_classify.rb asme
```

---

## Key Architectural Principles

**REMEMBER - NO compromises:**
1. **MODEL-DRIVEN** - Objects not strings
2. **Parser-only** - Changes should be in parser.rb, minimal builder changes
3. **Component stability** - Code component API must remain stable
4. **MECE** - Clear type separation
5. **Round-trip** - Preserve fidelity

**If a failure requires architecture changes, document it separately and discuss before implementing.**

---

## Files to Reference

**Failure analysis:**
- `spec/fixtures/asme/identifiers/fail/unknown.txt` - All failures

**Working patterns:**
- `spec/fixtures/asme/identifiers/pass/standard.txt` - 384 successes
- `spec/fixtures/asme/identifiers/full/identifiers.txt` - All 727 patterns

**Implementation:**
- `lib/pubid_new/asme/parser.rb` - Parser to enhance
- `lib/pubid_new/asme/builder.rb` - Builder (minimal changes)

---

**Created:** 2025-12-15
**Ready for:** Session 147 execution
**Estimated Time:** 60-90 minutes

**Goal:** Systematic analysis to enable 70-80% ASME pass rate! 📊
