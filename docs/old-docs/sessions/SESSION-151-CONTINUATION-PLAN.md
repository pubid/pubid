# Session 151+ Continuation Plan: CSA & API Flavor Implementation

**Created:** 2025-12-16 (Post-Session 150)
**Status:** ASME at 94.8% complete - Ready for CSA and API implementation
**Timeline:** COMPRESSED - Complete in 3-4 sessions (6-8 hours)

---

## Executive Summary

**Session 150 Achievement:** ASME enhanced to 94.8% (693/731) with joint development support! ✅

**New Task:** Implement CSA and API flavors using knowledge from ASME joint development patterns

**Fixture Counts:**
- **CSA:** 24 identifiers
- **API:** 198 identifiers
- **Total new:** 222 identifiers

**Note:** ANS identifiers are already handled through ANSI flavor (178 identifiers already passing)

---

## SESSION 151: CSA Flavor Implementation (90 minutes)

### Objective
Implement complete CSA (Canadian Standards Association) flavor with all patterns.

### CSA Pattern Analysis (from fixtures)

**Basic Patterns:**
```
CSA B149.1:20                    # Standard with year
CSA B149.1:F20                   # F prefix on year (French?)
CSA A123.17-05 (R2019)           # Reaffirmation
CSA A123.1-05/A123.5-05 (R2015)  # Combined standards
```

**Complex Patterns:**
```
CSA B149.1:25 Code, Handbook & Training Package
CSA B149.1:25, CSA B149.2:25 & Training Package
CSA C22.1:24 Code & Handbook Package
CSA C22.2 NO. 286:23
CSA N285.0:23/CSA N285.6 SERIES:23
```

**Joint Published (already in ASME):**
```
CSA B44.10/ASME A17.10-2024
```

**Non-Standards (filter out):**
```
CSA Communities
CSA Group
CSA Group logo, links to home
CSA Group(5172)
CSA Learning
CSA OnDemand™
CSA Update Service
```

### Implementation Tasks

#### Part A: Create CSA Base Structure (30 min)

**Files to create:**
1. `lib/pubid_new/csa.rb` - Main module
2. `lib/pubid_new/csa/identifier.rb` - Entry point
3. `lib/pubid_new/csa/parser.rb` - Parslet parser
4. `lib/pubid_new/csa/builder.rb` - Object builder
5. `lib/pubid_new/csa/single_identifier.rb` - Base serializable
6. `lib/pubid_new/csa/components/code.rb` - Code component
7. `lib/pubid_new/csa/identifiers/base.rb` - Base identifier
8. `lib/pubid_new/csa/identifiers/standard.rb` - Standard type

**Pattern analysis from fixtures:**
- Publisher: "CSA"
- Code format: Letter + numbers with dots (B149.1, C22.2, A123.1)
- Year format: Colon separator `:20`, `:F20`
- Reaffirmation: `(R2019)`
- Combined: Slash `/` for series, comma `,` for packages
- "NO." keyword: `C22.2 NO. 286`
- Package keywords: "Code", "Handbook", "Training Package", "SERIES"

#### Part B: Implement CSA Parser (30 min)

**Key patterns:**
```ruby
rule(:publisher) { str("CSA") >> space }

rule(:year_format) do
  # F prefix (French?) optional
  (str("F").maybe >> digit.repeat(2)).as(:year)
end

rule(:no_keyword) { space >> str("NO") >> dot >> space }

rule(:code_pattern) do
  letter >> match("[0-9.]").repeat(1)
end

rule(:package_keywords) do
  (
    str("Code") | str("Handbook") | str("Training Package") |
    str("SERIES") | str("Package")
  ).as(:package)
end

rule(:combined_standards) do
  # CSA A123.1-05/A123.5-05 or CSA N285.0:23/CSA N285.6 SERIES:23
  standard >> slash >> (publisher.maybe >> code >> year_portion.maybe >> package_keywords.maybe)
end
```

#### Part C: Testing & Validation (30 min)

**Filter out non-standards:**
- "CSA Communities"
- "CSA Group"
- "CSA Learning"
- etc.

**Expected valid identifiers:** ~16-18 (from 24 total)

**Expected success rate:** 80-90% on valid identifiers

---

## SESSION 152: API Flavor Implementation (120 minutes)

### Objective
Implement complete API (American Petroleum Institute) flavor with all patterns.

### API Pattern Analysis

**Document Types (from fixtures):**
- **BULL** (Bulletin): `API BULL 11L2`, `API BULL 5100`
- **MPMS** (Manual of Petroleum Measurement Standards): `API MPMS CH 10.10`
- **RP** (Recommended Practice): `API RP 1637`, `API RP 934-A`
- **SPEC** (Specification): `API SPEC 11P`, `API SPEC 5CT`
- **STD** (Standard): `API STD 1104`, `API STD 2CCU`
- **TR** (Technical Report): `API TR 21C`, `API TR 2WSIM`
- **COS** (Continuous Operations Standard): `API COS 1-07/RP 75, 4th edition`
- **PUBL** (Publication): `API PUBL 1628B`, `API PUBL 4527`

**Code Patterns:**
```
API RP 1637              # Simple number
API RP 79-2              # Dash-separated
API RP 934-A             # Letter suffix
API MPMS CH 10.10        # Chapter with dotted number
API RP 554, Part 2       # Part notation
API COS 1-07/RP 75, 4th edition  # Complex combined with edition
API 579-2                # Type-less (just number)
```

**Joint Published (already in ASME):**
```
API 579-2/ASME PTB-14-2023
```

### Implementation Tasks

#### Part A: Create API Base Structure (40 min)

**Files to create:**
1. `lib/pubid_new/api.rb` - Main module
2. `lib/pubid_new/api/identifier.rb` - Entry point
3. `lib/pubid_new/api/parser.rb` - Parslet parser
4. `lib/pubid_new/api/builder.rb` - Object builder
5. `lib/pubid_new/api/single_identifier.rb` - Base serializable
6. `lib/pubid_new/api/components/code.rb` - Code component
7. `lib/pubid_new/api/identifiers/base.rb` - Base identifier
8. `lib/pubid_new/api/identifiers/*.rb` - 8 document types

**Identifier Classes (MECE):**
1. Bulletin (BULL)
2. Mpms (Manual - MPMS CH)
3. RecommendedPractice (RP)
4. Specification (SPEC)
5. Standard (STD)
6. TechnicalReport (TR)
7. ContinuousOperationsStandard (COS)
8. Publication (PUBL)
9. TypelessStandard (no type keyword)

#### Part B: Implement API Parser (40 min)

**Key patterns:**
```ruby
rule(:publisher) { str("API") >> space }

rule(:doc_type) do
  (
    str("BULL") | str("MPMS") | str("RP") | str("SPEC") |
    str("STD") | str("TR") | str("COS") | str("PUBL")
  ).as(:type)
end

rule(:chapter_keyword) { space >> str("CH") >> space }

rule(:code_pattern) do
  (
    # Complex codes with letters and numbers
    match("[0-9A-Z]").repeat(1) >>
    (dash | dot).maybe >>
    match("[0-9A-Z]").repeat
  ).as(:code)
end

rule(:part_notation) do
  str(", Part ") >> digits.as(:part)
end

rule(:edition_notation) do
  str(", ") >> match("[0-9]").repeat(1).as(:edition_ord) >>
  (str("st") | str("nd") | str("rd") | str("th")) >>
  space >> str("edition")
end

rule(:mpms_identifier) do
  publisher >> str("MPMS") >> chapter_keyword >> code_pattern
end

rule(:cos_combined) do
  publisher >> str("COS") >> space >> code_pattern >>
  slash >> str("RP") >> space >> code_pattern >>
  edition_notation.maybe
end
```

#### Part C: Builder & Testing (40 min)

**Builder responsibilities:**
- Route to correct identifier class by type
- Handle MPMS chapter notation
- Handle COS combined format
- Handle part notation
- Handle edition notation

**Expected success rate:** 85-95% (168-188/198 identifiers)

---

## SESSION 153: Integration & Testing (90 minutes)

### Objective
Integrate CSA and API into main module, comprehensive testing, and validation.

### Part A: Integration (20 min)

**Update files:**
1. `lib/pubid_new.rb` - Add requires for csa and api
2. `spec/fixtures/classify_fixtures.rb` - Add csa and api to FLAVORS

### Part B: Comprehensive Testing (40 min)

**Test CSA:**
```bash
cd spec/fixtures && ruby run_classify.rb csa
```

**Test API:**
```bash
cd spec/fixtures && ruby run_classify.rb api
```

**Test ASME (regression check):**
```bash
cd spec/fixtures && ruby run_classify.rb asme
```

### Part C: Documentation Updates (30 min)

**Update memory bank:**
- `.kilocode/rules/memory-bank/context.md` - Add Sessions 151-153
- `.kilocode/rules/memory-bank/architecture.md` - If needed

**Archive old docs:**
- Move `docs/SESSION-150-CONTINUATION-PLAN.md` to `docs/old-docs/sessions/`
- Create `docs/old-docs/sessions/session-150-summary.md`

---

## SESSION 154: README & Project Status Update (60 minutes)

### Objective
Update all official documentation to reflect new flavors.

### Part A: Update README.adoc (40 min)

**Add CSA section:**
```asciidoc
==== CSA (Canadian Standards Association)
- Status: ✅ 16-18/24 (67-75%)
- Features: Standard codes, reaffirmation, combined standards, packages
- Architecture: Complete V2 implementation

.CSA Document Types
- Standard: `CSA B149.1:20`
- With reaffirmation: `CSA A123.17-05 (R2019)`
- Combined: `CSA A123.1-05/A123.5-05 (R2015)`
- With package: `CSA B149.1:25 Code, Handbook & Training Package`

.CSA Joint Published
- With ASME: `CSA B44.10/ASME A17.10-2024`
```

**Add API section:**
```asciidoc
==== API (American Petroleum Institute)
- Status: ✅ 168-188/198 (85-95%)
- Features: 9 document types, chapter notation, parts, editions
- Architecture: Complete V2 implementation

.API Document Types (MECE)
[cols="1,2,3"]
|===
|Type |Full Name |Example

|BULL
|Bulletin
|`API BULL 11L2`

|MPMS
|Manual of Petroleum Measurement Standards
|`API MPMS CH 10.10`

|RP
|Recommended Practice
|`API RP 1637`

|SPEC
|Specification
|`API SPEC 5CT`

|STD
|Standard
|`API STD 1104`

|TR
|Technical Report
|`API TR 21C`

|COS
|Continuous Operations Standard
|`API COS 1-07/RP 75, 4th edition`

|PUBL
|Publication
|`API PUBL 4527`
|===

.API Joint Published
- With ASME: `API 579-2/ASME PTB-14-2023`
```

### Part B: Update PROJECT_STATUS.md (20 min)

Add CSA and API to flavor table and update totals.

---

## Implementation Status Tracker

### Session 150: ASME Enhancement ✅
- [x] Joint published identifiers (CSA, API, ISO, ANS)
- [x] V&V spacing normalization
- [x] Multi-char codes (STS, NM, EA, VVUQ)
- [x] Parenthetical revisions
- [x] BPVC.X and BPVC.SSC
- [x] Em-dash normalization
- [x] PTC space-separated
- [x] Result: 693/731 (94.8%)

### Session 151: CSA Implementation
- [ ] Create 8 base files (30 min)
- [ ] Implement parser with CSA patterns (30 min)
- [ ] Testing and validation (30 min)
- [ ] Expected: 16-18/24 (67-75%)

### Session 152: API Implementation<br>- [ ] Create base structure with 9 identifier types (40 min)
- [ ] Implement parser with all doc types (40 min)
- [ ] Builder and testing (40 min)
- [ ] Expected: 168-188/198 (85-95%)

### Session 153: Integration & Testing
- [ ] Integrate into main module (20 min)
- [ ] Comprehensive testing (40 min)
- [ ] Documentation updates (30 min)

### Session 154: Final Documentation
- [ ] Update README.adoc (40 min)
- [ ] Update PROJECT_STATUS.md (20 min)

---

## Success Criteria

### CSA (Session 151)
- ✅ 8 files created
- ✅ Parser handles all patterns
- ✅ 16-18/24 passing (67-75%)
- ✅ MODEL-DRIVEN architecture

### API (Session 152)
- ✅ 9 identifier classes (MECE)
- ✅ Parser recognizes all types
- ✅ 168-188/198 passing (85-95%)
- ✅ MODEL-DRIVEN architecture

### Integration (Session 153)
- ✅ Both flavors integrated
- ✅ Zero regressions in ASME
- ✅ Documentation updated

### Final (Session 154)
- ✅ README.adoc includes CSA and API
- ✅ PROJECT_STATUS.md updated
- ✅ 19/19 flavors production-ready

---

## CSA Implementation Details

### Code Patterns
- Letter prefix: A, B, C, N, W, Z
- Dotted numbers: 149.1, 22.1, 285.0
- "NO." keyword: `C22.2 NO. 286`

### Year Patterns
- Colon separator: `:20`, `:24`
- F prefix: `:F20` (French edition?)
- Dash separator (older): `-05`

### Special Features
- Reaffirmation: `(R2019)`
- Combined standards: `/` separator
- Package keywords: "Code", "Handbook", "Training Package", "& Training Package"
- SERIES keyword: `N285.6 SERIES`

### Components Needed
- Code (letter + dotted number)
- Date (year with colon)
- Package (array of keywords)
- Reaffirmation (R + year)

---

## API Implementation Details

### Document Types (9 classes - MECE)

**1. Bulletin (BULL)**
- Simple numbers: `API BULL 11L2`
- Numbers with letters: `API BULL 5100`

**2. MPMS (Manual)**
- Chapter notation: `API MPMS CH 10.10`
- Complex chapter numbers: `CH 17.10.2`, `CH 6.4A`

**3. Recommended Practice (RP)**
- Simple: `API RP 1637`
- Dash-separated: `API RP 79-2`
- Letter suffix: `API RP 934-A`
- Complex: `API RP 6AF3`, `API RP 10B-2`
- With part: `API RP 554, Part 2`

**4. Specification (SPEC)**
- Simple: `API SPEC 11P`
- Letter codes: `API SPEC 5CT`, `API SPEC Q1`

**5. Standard (STD)**
- Numbers: `API STD 1104`
- Letter codes: `API STD 2CCU`, `API STD 5L8`

**6. Technical Report (TR)**
- Simple: `API TR 21C`
- Complex codes: `API TR 2WSIM`, `API TR 5DCB`

**7. COS (Continuous Operations Standard)**
- Combined: `API COS 1-07/RP 75, 4th edition`

**8. Publication (PUBL)**
- Simple: `API PUBL 4527`
- Letter suffix: `API PUBL 1628B`

**9. Typeless Standard**
- No type keyword: `API 1509`, `API 579-2`
- Complex: `API 17B`, `API 17J`, `API 17U`

### Components Needed
- Code (flexible format)
- Type (9 values)
- Part (integer)
- Edition (ordinal)
- Chapter (for MPMS)

---

## Key Architectural Principles

**MAINTAIN throughout ALL work:**
1. **MODEL-DRIVEN** - Objects not strings
2. **MECE** - Mutually exclusive identifier types
3. **Three-layer** - Parser/Builder/Identifier independence
4. **Component reuse** - Code, Date components
5. **No hardcoding** - Use proper class hierarchies

---

## Timeline Summary

| Session | Flavor | Duration | Deliverables |
|---------|--------|----------|--------------|
| 151 | CSA | 90 min | 8 files, 67-75% pass |
| 152 | API | 120 min | 9 types, 85-95% pass |
| 153 | Integration | 90 min | Testing, docs |
| 154 | Final docs | 60 min | README, status |
| **Total** | **Both** | **6 hours** | **19 flavors** |

---

## Files to Create

### CSA (Session 151)
- `lib/pubid_new/csa.rb`
- `lib/pubid_new/csa/identifier.rb`
- `lib/pubid_new/csa/parser.rb`
- `lib/pubid_new/csa/builder.rb`
- `lib/pubid_new/csa/single_identifier.rb`
- `lib/pubid_new/csa/components/code.rb`
- `lib/pubid_new/csa/identifiers/base.rb`
- `lib/pubid_new/csa/identifiers/standard.rb`

### API (Session 152)
- `lib/pubid_new/api.rb`
- `lib/pubid_new/api/identifier.rb`
- `lib/pubid_new/api/parser.rb`
- `lib/pubid_new/api/builder.rb`
- `lib/pubid_new/api/single_identifier.rb`
- `lib/pubid_new/api/components/code.rb`
- `lib/pubid_new/api/identifiers/base.rb`
- `lib/pubid_new/api/identifiers/bulletin.rb`
- `lib/pubid_new/api/identifiers/mpms.rb`
- `lib/pubid_new/api/identifiers/recommended_practice.rb`
- `lib/pubid_new/api/identifiers/specification.rb`
- `lib/pubid_new/api/identifiers/standard.rb`
- `lib/pubid_new/api/identifiers/technical_report.rb`
- `lib/pubid_new/api/identifiers/continuous_operations_standard.rb`
- `lib/pubid_new/api/identifiers/publication.rb`
- `lib/pubid_new/api/identifiers/typeless_standard.rb`

### Integration (Session 153)
- `lib/pubid_new.rb` (modify)
- `spec/fixtures/classify_fixtures.rb` (modify)

### Documentation (Session 154)
- `README.adoc` (modify)
- `docs/PROJECT_STATUS.md` (modify)
- `docs/old-docs/sessions/session-150-summary.md` (new)

---

## Next Immediate Steps (Session 151)

1. Read this continuation plan
2<br>. Analyze CSA fixtures thoroughly
3. Create 8 CSA base files
4. Implement CSA parser
5. Test with fixtures
6. Document CSA completion

---

**Created:** 2025-12-16
**Sessions Covered:** 151-154
**Status:** Ready for execution
**Estimated Time:** 6 hours (compressed)

**End Goal:** 19 flavors production-ready, CSA and API complete, comprehensive documentation! 🎉