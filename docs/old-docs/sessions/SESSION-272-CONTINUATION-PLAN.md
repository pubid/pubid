# Session 272+ Continuation Plan: NIST Edition Patterns Completion

**Created:** 2026-01-06 (Post-Session 271)
**Status:** CS edition foundation complete, CS-E/CSM corrections needed
**Timeline:** COMPRESSED - Complete in 2-3 sessions (3-4 hours)

---

## Executive Summary

**Session 271 Achievement:** CS edition with 2-digit year expansion (123e2-50 → 123e2.1950) ✅

**Current Status:**
- **Main series:** 259/368 passing (70.4%)
- **CS edition:** Working with year expansion
- **CS-E:** Needs edition format (104-43 → 104e1943)
- **CSM:** Needs v#n# format (not v#pt#)

**Remaining Work:**
1. Fix CS-E to use edition format for 2-digit years
2. Fix CSM to preserve v#n# notation (volume+issue)
3. Implement HB edition patterns
4. Document NIST PubID extensions

---

## SESSION 272: CS-E Edition Format + CSM v#n# (90 min)

### Objective
Fix CS-E and CSM to match corrected spec expectations.

### Part A: CS-E Edition Format (40 min)

**Current behavior:** `e104-43` renders as `CS-E 104-43`
**Required behavior:** `e104-43` renders as `CS-E 104e1943`

**Pattern:** Emergency with 2-digit year should use edition format with expanded year

**Implementation:**

1. **Update Builder** - [`lib/pubid_new/nist/builder.rb`](lib/pubid_new/nist/builder.rb:347)
   - CS Emergency pattern: Extract year if present (e104-43)
   - Convert to edition format: number=104, edition=Edition(e, 1, additional_text: "1943")

2. **Update CS-E Identifier** - [`lib/pubid_new/nist/identifiers/commercial_standard_emergency.rb`](lib/pubid_new/nist/identifiers/commercial_standard_emergency.rb:1)
   - Add edition attribute
   - Render as `NBS CS-E 104e1943` if edition present

**Expected:** CS-E tests 2/3 passing (edition variant working)

### Part B: CSM Volume+Issue Notation (40 min)

**Current behavior:** `v6n1` renders as `CSM v6pt1`
**Required behavior:** `v6n1` renders as `CSM v6n1`

**Pattern:** Volume (#) and issue number (n#) - NOT part notation

**Implementation:**

1. **Update Builder** - [`lib/pubid_new/nist/builder.rb`](lib/pubid_new/nist/builder.rb:260)
   - Current: Treats issue as part
   - Change: Store volume and issue_number separately
   - Return: `{ first_number: Code(number: "v6"), issue_number: IssueNumber(number: "1") }`

2. **Update CSM Identifier** - Create if needed
   - Render: `{publisher} CSM v{volume}n{issue_number.number}`
   - Example: `NBS CSM v6n1`

**Expected:** CSM tests 2/2 passing

### Part C: Testing & Validation (10 min)

```bash
bundle exec rspec spec/pubid_new/nist/identifiers/commercial_standard_spec.rb
```

**Expected:** 28-30/31 passing (CS-E and CSM fixed)

---

## SESSION 273: HB Edition Patterns (120 min)

### Objective
Implement Handbook edition patterns to improve HB pass rate.

### Analysis Phase (20 min)

**Read HB spec:**
```bash
bundle exec rspec spec/pubid_new/nist/identifiers/handbook_spec.rb --format documentation
```

**Identify patterns:**
- Edition with year (similar to CS)
- Revision notation
- Part/volume patterns

### Implementation Phase (80 min)

**Apply CS edition pattern learnings to HB:**

1. **HB Edition with Year**
   - Pattern: `HB 150e2-1966` → `HB 150e2.1966`
   - Use same builder logic as CS

2. **HB Revision**
   - Pattern: `HB 44r1995` → Edition(type: "r", id: "1995")
   - Already in place, validate

3. **HB Edition without Year**
   - Pattern: `HB 44e1` → Edition(type: "e", id: "1")
   - Already in place, validate

### Testing Phase (20 min)

```bash
bundle exec rspec spec/pubid_new/nist/identifiers/handbook_spec.rb
```

**Expected:** 35-40/45 passing (improvement from baseline)

---

## SESSION 274: Documentation + Extensions Doc (90 min)

### Objective
Document NIST PubID extensions and update official documentation.

### Part A: Create NIST Extensions Doc (50 min)

**File:** `docs/NIST-PUBID-EXTENSIONS.adoc`

**Content:**
```asciidoc
= NIST PubID Extensions to Official Specification

== Volume and Issue Number Notation

The official NIST PubID specification defines multiple part identifiers but
does not explicitly cover volume and issue number notation.

**Extension:** We extend the specification to support volume and issue numbers:

* Format: `v{volume}n{issue}`
* Example: `NBS CSM v6n1` (Volume 6, Issue 1)
* Rationale: Commercial Standards Monthly (CSM) series requires issue tracking

**Rendering:**
- Input: `NBS CS v6n1`
- Normalized: `NBS CSM v6n1`
- Components: volume=6, issue_number=1

== Emergency Edition Format

CS Emergency documents with years use edition notation:

* Format: `CS-E {number}e{edition}.{year}`
* Example: `NBS CS-E 104e1.1943`
* 2-digit years expanded to 4-digit: 43 → 1943

== Date IS Edition Principle

When a date appears after an edition marker, it becomes Edition.additional_text:

[source,ruby]
----
Edition.new(type: "e", id: "2", additional_text: "1950")
# Renders: e2.1950
----

**Separator rules:**
- All years (2-digit or 4-digit): DOT separator
- Month+year: DOT separator
- Historical editions with month names: NO separator (-April1909)
```

### Part B: Update README.adoc (30 min)

**File:** [`README.adoc`](../../README.adoc:1)

**Add NIST edition section:**
```asciidoc
==== NIST Edition Formats

* **Edition with year:** `e2.1950` (DOT separator for all years)
* **Revision with year:** `r1963`
* **Historical edition:** `-April1909` (NO separator for month names)
* **2-digit year expansion:** 50 → 1950 (automatic)

See link:docs/NIST-PUBID-EXTENSIONS.adoc[] for complete extensions.
```

### Part C: Move Old Docs (10 min)

```bash
mv docs/SESSION-{269,270,271}-*.md docs/old-docs/sessions/
```

---

## Implementation Status Tracker

### Session 271: CS Edition Foundation ✅
- [x] CS edition with 2-digit year (123e2-50 → 123e2.1950)
- [x] CS edition without year (100e1)
- [x] 2-digit year expansion (50 → 1950)
- [x] Edition.to_s DOT separator for all years
- [x] Context-aware pattern matching
- [x] Tests: 259/368 (70.4%)

### Session 272: CS-E + CSM Corrections (PENDING)
- [ ] CS-E edition format (e104-43 → CS-E 104e1943)
- [ ] CSM volume+issue notation (v6n1 stays as v6n1)
- [ ] Update builder for both patterns
- [ ] Tests: 28-30/31 CS passing

### Session 273: HB Edition Patterns (PENDING)
- [ ] HB edition with year
- [ ] HB revision validation
- [ ] HB edition without year
- [ ] Tests: 35-40/45 HB passing

### Session 274: Documentation (PENDING)
- [ ] Create NIST-PUBID-EXTENSIONS.adoc
- [ ] Update README.adoc NIST section
- [ ] Move old session docs to archive

---

## Architecture Principles (MAINTAIN)

1. **MODEL-DRIVEN** - Edition as Lutaml::Model component
2. **MECE** - Separate classes for CS/CS-E/CSM
3. **Date IS Edition** - When date after edition, use additional_text
4. **Consistent rendering** - DOT separator for all years
5. **Year expansion** - 2-digit → 4-digit (50 → 1950)
6. **Context-aware** - Check parsed_hash for second_number

---

## Success Criteria

### Minimum (Session 272)
- ✅ CS-E renders as 104e1943
- ✅ CSM renders as v6n1
- ✅ CS tests: 28+/31

### Target (Session 273)
- ✅ HB edition patterns working
- ✅ HB tests: 35+/45
- ✅ Main series: 275+/368 (75%+)

### Complete (Session 274)
- ✅ Extensions documented
- ✅ README updated
- ✅ Old docs archived
- ✅ Ready for TN/SP/FIPS work

---

## Timeline Summary

| Session | Focus | Duration | Deliverables |
|---------|-------|----------|--------------|
| 272 | CS-E + CSM | 90 min | Fixed formats |
| 273 | HB edition | 120 min | HB patterns working |
| 274 | Documentation | 90 min | Extensions doc + README |
| **Total** | **All work** | **300 min** | **Complete** |

---

**Created:** 2026-01-06
**Sessions Covered:** 272-274
**Status:** Ready for execution
**Estimated Time:** 5 hours (compressed)

**End Goal:** CS-E/CSM corrected, HB edition working, extensions documented! 📋