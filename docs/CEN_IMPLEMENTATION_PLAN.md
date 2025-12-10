# CEN/CENELEC Implementation Plan

**Created:** 2025-12-10
**Status:** Planning Phase
**Complexity:** HIGH - Multiple publishers, adopted standards, stage codes

---

## Overview

CEN (European Committee for Standardization) and CENELEC (European Committee for Electrotechnical Standardization) publish European Standards (EN) and related documents.

### Key Organizations

- **CEN**: European standardization for most sectors (like ISO for EU)
- **CLC** (CENELEC): European electrotechnical standardization (like IEC for EU)
- **ETSI**: European Telecommunications Standards Institute

### Document Publishers

ENs can be published by:
1. CEN only
2. CLC only
3. CEN/CLC (copublished)

---

## Document Types

### 1. European Norms (EN)
**Pattern:** `EN {number}:{year}`

Examples:
- `EN 228` (undated)
- `EN 228:2008` (dated)
- `EN 1177:2008`
- `EN 12464-1:2011` (with part)
- `EN 16602-60-15:2014` (multi-level part)

**Stages:**
- `prEN` - Draft EN (proposal)
- `FprEN` - Final Draft EN

Examples:
- `prEN 12464-1:2019`
- `prEN 13241-1`
- `FprEN 16114:2011`
- `FprEN 16798-3`

### 2. Guides (CG)
**Patterns:**
- `CEN Guide {number}`
- `CLC GUIDE {number}`
- `CEN/CLC Guide {number}`
- `CEN-CLC Guide {number}` (alternative notation)

Examples:
- `CEN Guide 1`
- `CEN Guide 18:2021`
- `CLC GUIDE 1:2022`
- `CEN/CLC Guide 25:2023`
- `CEN-CLC Guide 32:2016`

### 3. Technical Reports (TR)
**Patterns:**
- `CEN/TR {number}:{year}`
- `CLC/TR {number}:{year}`
- `CEN/CLC/TR {number}:{year}`

Examples:
- `CEN/TR 16411:2022`
- `CLC/TR 62125:2008`
- `CEN/CLC/TR 17602-80-12:2021`

### 4. Technical Specifications (TS)
**Patterns:**
- `CEN/TS {number}`
- `CLC/TS {number}`
- `CEN/CLC/TS {number}`

Examples:
- `CEN/TS 14972`
- `CLC/TS 50701:2021`
- `CEN/CLC/TS 17880:2022`

### 5. Harmonization Documents (HD)
**Pattern:** `HD {number}:{year}`

Status: Examples needed

### 6. CEN Workshop Agreements (CWA)
**Pattern:** `CWA {number}:{year}`

Status: Examples needed

---

## Adopted Standards

CEN/CENELEC adopts ISO and IEC standards with EN prefix:

### ISO Adoptions
**Pattern:** `EN ISO {number}:{year}`

Examples:
- `EN ISO 13485:2016/AC:2016`
- `EN ISO 14090:2019`
- `EN ISO 17292:2004`
- `EN ISO 10077-1:2006+AC:2009+AC2:2009`

### IEC Adoptions
**Pattern:** `EN IEC {number}:{year}`

Examples:
- `EN IEC 55014-2:2021`
- `EN IEC 62115:2020`
- `EN IEC 62368-1:2020`
- `EN IEC 62368-1:2020+A11:2020`

**Important:** Adopted identifiers maintain ISO/IEC supplement format

---

## Supplements

### Amendments

**Three notations:**

1. **Separate Amendment** (`/A{n}`)
   - Pattern: `{base}/A{number}`
   - Example: `EN 60335-1:2012/A1`
   - Example: `EN 60335-1:2012/A2:2019`

2. **Bundled Amendment** (`+A{n}`)
   - Pattern: `{base}+A{number}:{year}`
   - Meaning: Document INCORPORATES the amendment
   - Example: `EN 196-3:2005+A1:2008`
   - Example: `EN 527­2:2016+A1:2019`

3. **Multiple Bundled** (chain with `+`)
   - Example: `EN IEC 62368-1:2020+A11:2020`

### Corrigenda

**Important:** No sequential numbering for corrigenda!

**Notations:**

1. **Separate Corrigendum** (`/AC`)
   - Pattern: `{base}/AC:{year}`
   - No number - identified by year only!
   - First: `EN ISO 13485:2016/AC:2016`
   - Second: `EN ISO 13485:2016/AC:2017`
   - Third: `EN ISO 13485:2016/AC:2018`

2. **Alternative notation** (`/AC{n}`)
   - Some use: `/AC2`, `/AC1`
   - Examples:
     - `EN 14891:2007/AC2:2009`
     - `EN 196-1:1987/AC2:1989`

3. **Bundled Corrigendum** (`+AC`)
   - Pattern: `{base}+AC:{year}`
   - Example: `EN ISO 10077-1:2006+AC:2009+AC2:2009`

4. **Month notation** (some corrigenda)
   - Example: `EN 61375-2-3:2015/AC:2016-11`

### Versions

**Pattern:** `{base} V{n}/AC{n}`

Examples:
- `EN 13445-2 V1/AC1`
- `EN 13445-5 V1/AC1`
- `EN 13445-2 V2/AC2`

### Fragments

**Pattern:** `{base} AMD{n} FRAG{n}`

Example:
- `EN 60038 AMD1 FRAG2`

---

## Stage Codes

CEN/CLC uses detailed stage codes:

| Stage | Description |
|-------|-------------|
| 00.60.0000 | Completion of Proposal/Preliminary stage |
| 10.98.0000 | Decision on WI proposal - Reject |
| 10.99.0000 | Decision on WI proposal - Accept |
| 20.60.0979 | Circulation of 1st Working Document |
| 30.99.0979 | Dispatch of ENQ draft to CCMC |
| 40.20.0000 | Submission to enquiry |
| 40.60.0000 | Closure of enquiry |
| 43.20.0000 | Submission to COCOR |
| 43.60.0000 | Closure of COCOR |
| 45.99.0979 | Dispatch of FV draft to CCMC |
| 50.20.0000 | Submission to Vote |
| 50.60.0000 | Closure of Vote |
| 60.55.0000 | Ratification completed (DOR) |
| 60.60.0000 | Definitive text made available (DAV) |
| 65.31.0000 | Announcement (DOA) |
| 65.51.0000 | Completion of mandatory publication (DOP) |
| 65.62.0000 | Completion of withdrawal of conflicting national standards (DOW) |
| 90.00.0000 | Start of review/2 Year Review Enquiry |
| 90.92.0000 | Decision - revise |
| 90.93.0000 | Decision - confirm |
| 90.98.0000 | Decision - withdraw |
| 99.60.0000 | Withdrawal effective |

---

## Architecture Design

### Class Hierarchy

```
PubidNew::Cen::Identifier (base)
├── EuropeanNorm (EN, prEN, FprEN)
├── Guide (CEN Guide, CLC Guide, CEN/CLC Guide)
├── TechnicalReport (CEN/TR, CLC/TR, CEN/CLC/TR)
├── TechnicalSpecification (CEN/TS, CLC/TS, CEN/CLC/TS)
├── HarmonizationDocument (HD)
├── WorkshopAgreement (CWA)
├── AdoptedIso (EN ISO {number})
├── AdoptedIec (EN IEC {number})
└── Supplements:
    ├── Amendment (/A{n} notation)
    ├── Corrigendum (/AC notation)
    ├── BundledIdentifier (+A, +AC notation)
    ├── VersionedIdentifier (V{n})
    └── FragmentIdentifier (FRAG{n})
```

### Publisher Component

```ruby
class Publisher
  attribute :primary, :string    # "CEN", "CLC", "EN"
  attribute :copublisher, :string, collection: true  # ["CLC"] for CEN/CLC

  VALID_PRIMARY = ["CEN", "CLC", "EN"].freeze

  def to_s
    return primary unless copublisher&.any?
    [primary, *copublisher].join("/")
  end
end
```

### TypedStage Component

Need to support:
- Draft stages: `pr`, `Fpr`
- Published stage: (no prefix)
- Full stage codes: `40.60.0000`

---

## Implementation Phases

### Phase 1: Core EN Documents (2-3 sessions)
- [ ] European Norm (EN) - basic, dated, with parts
- [ ] Draft EN (prEN, FprEN)
- [ ] Parser for basic EN patterns
- [ ] Builder for EN identifiers
- [ ] Tests with ~20 examples

**Target:** EN 228, EN 1177:2008, prEN 12464-1:2019

### Phase 2: Guides (1 session)
- [ ] CEN Guide
- [ ] CLC Guide (uppercase "GUIDE")
- [ ] CEN/CLC Guide
- [ ] CEN-CLC Guide (alternative notation)
- [ ] Parser updates
- [ ] Tests with Guide examples

**Target:** CEN Guide 1, CLC GUIDE 1:2022

### Phase 3: TR/TS Documents (1 session)
- [ ] Technical Report (CEN/TR, CLC/TR, CEN/CLC/TR)
- [ ] Technical Specification (CEN/TS, CLC/TS, CEN/CLC/TS)
- [ ] Multi-level part support (e.g., 17602-80-12)
- [ ] Parser updates
- [ ] Tests

**Target:** CEN/TR 16411:2022, CEN/TS 14972

### Phase 4: Amendments (1-2 sessions)
- [ ] Separate Amendment (/A{n})
- [ ] Amendment with year (/A{n}:{year})
- [ ] Bundled Amendment (+A{n})
- [ ] Multiple bundled (+A1+A2)
- [ ] Parser updates for all notations
- [ ] Round-trip tests

**Target:** EN 60335-1:2012/A1, EN 196-3:2005+A1:2008

### Phase 5: Corrigenda (1-2 sessions)
- [ ] Separate Corrigendum (/AC)
- [ ] Corrigendum with year (/AC:{year})
- [ ] Numbered corrigenda (/AC2)
- [ ] Bundled Corrigendum (+AC)
- [ ] Month notation (/AC:2016-11)
- [ ] Multiple sequential AC (year-based tracking)
- [ ] Parser updates
- [ ] Round-trip tests

**Target:** EN ISO 13485:2016/AC:2016, EN 14891:2007/AC2:2009

### Phase 6: Adopted Standards (2 sessions)
- [ ] AdoptedIso class (EN ISO pattern)
- [ ] AdoptedIec class (EN IEC pattern)
- [ ] Maintain ISO/IEC supplement format
- [ ] Handle bundled supplements
- [ ] Parser updates
- [ ] Tests with adopted examples

**Target:** EN ISO 13485:2016/AC:2016, EN IEC 62368-1:2020+A11:2020

### Phase 7: Advanced Features (1-2 sessions)
- [ ] Versioned identifiers (V{n})
- [ ] Fragment identifiers (FRAG{n})
- [ ] HarmonizationDocument (HD)
- [ ] WorkshopAgreement (CWA)
- [ ] Parser updates
- [ ] Tests

**Target:** EN 13445-2 V1/AC1, EN 60038 AMD1 FRAG2

### Phase 8: Stage Codes (optional)
- [ ] Map stage codes to stages
- [ ] Support full stage code format
- [ ] Integration with TypedStage

---

## Testing Strategy

### Fixture Organization

```
spec/fixtures/cen/identifiers/full/
├── european_norm.txt         # Basic EN
├── guide.txt                 # CEN/CLC Guides
├── technical_report.txt      # TR documents
├── technical_specification.txt # TS documents
├── adopted_iso.txt           # EN ISO documents
├── adopted_iec.txt           # EN IEC documents
├── amendment.txt             # All amendment types
├── corrigendum.txt           # All corrigendum types
├── bundled.txt               # Bundled identifiers
└── advanced.txt              # Versions, fragments
```

### Test Coverage Target

- **Minimum:** 95% of provided examples
- **Goal:** 100% round-trip fidelity
- **Performance:** <1ms per parse

---

## Critical Implementation Notes

1. **Corrigendum uniqueness:** Track by year, not number
   - `/AC:2016`, `/AC:2017`, `/AC:2018` are THREE different corrigenda
   - Some use `/AC2` notation - handle both

2. **Bundled notation:**
   - `+` means INCORPORATED
   - `/` means SEPARATE
   - Can chain: `+A1+A2+AC`

3. **Adopted standards:**
   - Keep ISO/IEC format for supplements
   - Don't convert to EN format
   - Example: `EN ISO 13485:2016/Amd 1` (if it exists) not `/A1`

4. **Publisher combinations:**
   - `CEN Guide` = CEN only
   - `CLC GUIDE` = CLC only (uppercase!)
   - `CEN/CLC Guide` = copublished
   - `CEN-CLC Guide` = copublished (alternative)

5. **Stage prefixes:**
   - `prEN` = draft
   - `FprEN` = final draft
   - `EN` = published

---

## Estimated Timeline

**Total:** 10-14 sessions (10-14 hours)

**Breakdown:**
- Core implementation: 8-10 sessions
- Testing & validation: 2-3 sessions
- Documentation: 1 session

**Dependencies:**
- None (CEN is independent flavor)

**Risks:**
- HIGH: Complex supplement notation system
- MEDIUM: Adopted standard format preservation
- LOW: Basic EN parsing

---

## Success Criteria

✅ Parse all 60+ provided examples
✅ 95%+ accuracy on real-world dataset
✅ Round-trip fidelity maintained
✅ Clean MODEL-DRIVEN architecture
✅ Comprehensive test coverage

---

## Next Steps

1. Complete current session (113) with IDF
2. Update project status documentation
3. Prioritize CEN implementation in roadmap
4. Begin Phase 1 when ready

**Recommendation:** Implement CEN after completing IEEE enhancement to maintain momentum with complex parsers.