# Session 142 Correction Plan: IEEE/ASTM & ASTM Flavor

**Created:** 2025-12-15
**Status:** Correction needed - Previous SI/PSI implementation was based on misunderstanding
**Timeline:** COMPRESSED - Complete in 2-3 hours (Sessions 142-144)

---

## Misunderstanding Clarification

### What I Got Wrong ❌
- Treated "IEEE/ASTM SI 10-1997" as a special "SI Standard" type
- Created separate SiStandard and PsiStandard classes
- Thought PSI was "Proposed SI" (separate document type)

### What It Actually Is ✅
- "IEEE/ASTM SI 10-1997" is a **regular IEEE/ASTM copublished standard**
- "SI" (Système International) is just part of the standard number/designation
- "PSI 10/D2" means "Proposed SI 10, Draft 2" - IEEE-style draft notation:
  - P = Proposed/Project (IEEE draft prefix)
  - SI 10 = Base standard designation
  - D2 = Draft version 2
- ASTM is simply another **copublisher** like IEC, ISO, ANSI

---

## Correction Tasks

### Phase 1: Rollback Incorrect Implementation (30 min)

**Delete files:**
- `lib/pubid_new/ieee/identifiers/si_standard.rb`
- `lib/pubid_new/ieee/identifiers/psi_standard.rb`

**Revert changes in:**
- `lib/pubid_new/ieee/parser.rb` - Remove ieee_astm_si_psi rule
- `lib/pubid_new/ieee/builder.rb` - Remove build_si_psi_identifier method
- `.kilocode/rules/memory-bank/context.md` - Remove Session 142 entry

### Phase 2: Add ASTM as IEEE Copublisher (15 min)

**Update:**
- `lib/pubid_new/ieee/parser.rb` - Add ASTM to organization rule (line 72)
- Already present in publishers list (line 127)

**Test:**
```ruby
PubidNew::Ieee.parse("IEEE/ASTM SI 10-1997")
# Should return Base with copublisher=["ASTM"], code="SI 10"

PubidNew::Ieee.parse("IEEE/ASTM PSI 10/D2, October 2015")
# Should return Base with copublisher=["ASTM"], code="PSI 10", draft="D2"
```

---

## ASTM Flavor Development (Sessions 143-144)

### ASTM Identifier Patterns (289 fixtures)

**From `spec/fixtures/astm/identifiers/full/identifiers.txt`:**

**1. Standard Designations (~76 identifiers)**
```
ASTM E2938-15(2023)          # Letter-Number-Year(Reapproved)
ASTM D2148-22                # Letter-Number-Year
ASTM C483-95(2000)           # Letter-Number-Year(Reapproved)
ASTM C1028-07e1              # Letter-Number-Year + editorial revision
ASTM F1862/F1862M-17         # Dual unit designation (inch/metric)
ASTM D5994/D5994M-10(2021)   # Dual + reapproval
ASTM A36/A36M-19             # Just dual, no reapproval
```

**Pattern components:**
- Letter prefix: A-G (material classification, see lines 3-19)
- Sequential number: 1-9999
- Year: 2 or 4 digits (last revision year)
- Sub-year revision: a, b, c, etc. (e.g., "-01a" for second revision in 2001)
- Dual unit: /F1862M (M suffix for metric)
- Reapproval: (YYYY) in parentheses
- Editorial: e1, e2, etc. (epsilon notation)

**2. Work in Progress (~3 identifiers)**
```
ASTM WK91249
ASTM WK95199
ASTM WK94200
```

**3. Adjuncts (~4 identifiers)**
```
ASTM ADJD2148
ADJF3504-EA
ADJG0088DVD
ADJC062702
```

**4. Technical Reports (~13 identifiers)**
```
ISO/ASTMTR52916-EB           # ISO/ASTM copublished
TR1-EB                       # ASTM-only
```

**5. Manuals (~74 identifiers)**
```
ASTM MNL1-9TH-EB             # Manual number-edition-format
ASTM MNL20-2ND-SUP-EB        # With supplement
```

**6. Monographs (~11 identifiers)**
```
ASTM MONO1-EB
ASTM MONO12-4TH-EB
```

**7. Data Series (~34 identifiers)**
```
ASTM DS4B-EB
ASTM DS55S1-EB               # With subseries
```

**8. Research Reports (~74 identifiers)**
```
ASTM RR:A01-1001             # Committee:number
ASTM RR:C09-2005
```

---

## ASTM Architecture Design (MECE)

### Identifier Class Hierarchy

```
PubidNew::Astm::Identifier (base)
├── SingleIdentifier (base documents)
│   ├── Standard (A-G letter prefix)
│   ├── WorkInProgress (WK prefix)
│   ├── TechnicalReport (TR prefix)
│   ├── Manual (MNL prefix)
│   ├── Monograph (MONO prefix)
│   ├── DataSeries (DS prefix)
│   └── ResearchReport (RR: prefix)
└── Adjunct (ADJ prefix)
```

### Components Needed

1. **Code** - Letter + number (e.g., "E2938", "C483")
2. **DualUnit** - Metric designation (e.g., "F1862M")
3. **Year** - Publication year (2-digit or 4-digit)
4. **SubYearRevision** - Letter suffix (a, b, c)
5. **Reapproval** - Year in parentheses
6. **Editorial** - Epsilon notation (e1, e2)
7. **Edition** - For manuals/monographs (9TH, 2ND)
8. **Format** - EB (electronic book)

---

## Implementation Timeline

### Session 142: Correction & ASTM Foundation (90 min)
- Delete SI/PSI files
- Revert parser/builder
- Add ASTM copublisher
- Create ASTM flavor structure
- Implement Standard class (most common)

### Session 143: ASTM Complete Implementation (120 min)
- Implement remaining 7 identifier classes
- Parser for all patterns
- Builder routing
- Comprehensive testing

### Session 144: Documentation & Validation (30 min)
- Test against all 289 fixtures
- Update README.adoc
- Archive old docs
- Mark Session 142 as corrected

---

## Success Criteria

### IEEE/ASTM (Session 142)
- ✅ IEEE can parse IEEE/ASTM copublished standards
- ✅ "SI 10" recognized as standard number, not special type
- ✅ PSI 10/D2 parsed as draft with code="PSI 10", draft="D2"
- ✅ Zero regressions in IEEE tests

### ASTM Flavor (Sessions 143-144)
- ✅ 16th flavor production-ready
- ✅ 8 identifier classes (MECE)
- ✅ 289 fixtures parsed successfully
- ✅ MODEL-DRIVEN architecture
- ✅ Round-trip fidelity

---

## Files to Create

**ASTM flavor:**
1. `lib/pubid_new/astm.rb`
2. `lib/pubid_new/astm/identifier.rb`
3. `lib/pubid_new/astm/parser.rb`
4. `lib/pubid_new/astm/builder.rb`
5. `lib/pubid_new/astm/single_identifier.rb`
6. `lib/pubid_new/astm/components/code.rb`
7. `lib/pubid_new/astm/components/dual_unit.rb`
8. `lib/pubid_new/astm/identifiers/*.rb` (8 classes)
9. `spec/pubid_new/astm/identifier_spec.rb`

## Files to Delete

1. `lib/pubid_new/ieee/identifiers/si_standard.rb`
2. `lib/pubid_new/ieee/identifiers/psi_standard.rb`

## Files to Revert

1. `lib/pubid_new/ieee/parser.rb` - Remove ieee_astm_si_psi rule
2. `lib/pubid_new/ieee/builder.rb` - Remove build_si_psi_identifier
3. `.kilocode/rules/memory-bank/context.md` - Remove Session 142 entry

---

**Status:** Plan complete, ready for execution
**Recommendation:** Execute all correction in one compressed session (Session 142-corrected)