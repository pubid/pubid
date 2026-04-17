# Task 01: Implement IEC Typed Stages from Excel Reference

## Status: DONE

### Completed
- Added PWI, NP, ANW, WD, PRF to IS TYPED_STAGES
- Added PWI TS, NP TS, ANW TS, WD TS, CD TS to TS
- Added PWI TR, NP TR, ANW TR, WD TR, CD TR to TR
- Added PWI PAS, NP PAS, ANW PAS, WD PAS to PAS (CDPAS harmonized codes corrected to 30.xx)
- Added PWI ISH, NP ISH, ANW ISH, WD ISH to ISH (CDISH stage_code corrected to :cd)
- Added PWI Guide, NP Guide, ANW Guide, WD Guide, CD Guide, PRF Guide to Guide
- Added PWI Amd, NP Amd, ANW Amd, WD Amd, PRF Amd to Amendment
- Added PWI Cor, NP Cor, ANW Cor, WDCor, PRF Cor to Corrigendum
- Published stages now include 90.xx (review) and 95.xx (withdrawal) harmonized codes
- All 6745 tests pass (62 new tests added)
- URN generation verified for all new stages
- locate_typed_stage_by_abbr works for all new abbreviations

### Remaining — Partially Implemented
- **FRAG typed stages**: Implemented. FragmentIdentifier now has 8 TYPED_STAGES (PWI Frag, NP Frag, ANW Frag, WD Frag, CDFRAG, DFRAG, FDFRAG/PRF Frag, FRAG). Registered in Scheme via SUPPLEMENT_IDENTIFIER_TYPES. Fragments have their own typed_stage attribute and stage, no longer delegating to base_identifier. 14 new tests added.
- **Suppl typed stages**: Not applicable. The Excel "Suppl" sheet is a conceptual category grouping amendments and corrigenda. In practice, IEC identifiers always use concrete types (Amd/Cor) with their own TYPED_STAGES. No "Suppl" type appears in any IEC identifier or test fixture. Adding a generic Supplement class would be dead code.

## Context

IEC typed stages are incomplete in V2. The authoritative source is
`20230904-iec-typed-stages-v1.0.xlsx` (from metanorma/pubid-iec#131).

Per ronaldtse's comments in issue #131:
- Only document stage abbreviations appear in identifiers (not project-internal stages)
- Valid document stages are: PWI, NP, WD, CD, CDV, FDIS, and empty string
- "CAN" never appears in identifiers
- Stages without typed stages use the "last abbreviation of the closest lower stage code"
- A separate stages.yaml can describe project-internal stages (not needed for identifiers)

## Source Data

Excel file `20230904-iec-typed-stages-v1.0.xlsx` has 11 sheets:
- Stage descriptions (base harmonized stage codes)
- IS, TS, TR, PAS, ISH, Guide, Amd, Cor, Suppl, FRAG (per-type abbreviations)

## Current State

### What exists (lib/pubid/iec/identifiers/):
Each identifier type has a `TYPED_STAGES` constant with `Pubid::Components::TypedStage` entries.
Most types have only 3-4 stages defined. The Excel defines ~9-10 per type.

### Gaps by document type:

**IS (International Standard):**
- Code has: IS, CD, CDV, FDIS
- Excel has: PWI, NP/ANW, WD/ANW, CD, CDV, FDIS/PRF, [none], [review], [withdrawal]
- Missing: PWI, NP, ANW, WD, PRF

**TS (Technical Specification):**
- Code has: DTS, TS
- Excel has: PWI TS, NP TS/ANW TS, WD TS/ANW TS, CD TS, ?, DTS, TS, TS(review), TS(withdrawal)
- Missing: PWI TS, NP TS, ANW TS, WD TS, CD TS

**TR (Technical Report):**
- Code has: DTR, TR + project stages (ADTR, CDTR, DTRM, NDTR, PRVDTR, TDTR)
- Excel has: PWI TR, NP TR/ANW TR, WD TR/ANW TR, CD TR, ?, DTR, TR, TR(review), TR(withdrawal)
- Missing: PWI TR, NP TR, ANW TR, WD TR, CD TR

**PAS (Publicly Available Specification):**
- Code has: DPAS, CDPAS, PAS
- Excel has: PWI PAS, NP PAS/ANW PAS, WD PAS/ANW PAS, CDPAS, ?, DPAS, PAS
- Missing: PWI PAS, NP PAS, ANW PAS, WD PAS

**ISH (Interpretation Sheet):**
- Code has: CDISH, DISH, ISH
- Excel has: PWI ISH, NP ISH/ANW ISH, WD ISH/ANW ISH, CDISH, ?, DISH, ISH
- Missing: PWI ISH, NP ISH, ANW ISH, WD ISH

**Guide:**
- Code has: DGuide, FDGuide, GUIDE/Guide
- Excel has: PWI Guide, NP Guide/ANW Guide, WD Guide/ANW Guide, CD Guide, DGuide, FD Guide/PRF Guide, Guide
- Missing: PWI Guide, NP Guide, ANW Guide, WD Guide, CD Guide, PRF Guide

**Amd (Amendment):**
- Code has: CDAM, DAM, FDAM, Amd/AMD
- Excel has: PWI Amd, NP Amd/ANW Amd, WD Amd/ANW Amd, CDAM, DAM, FDAM/PRF Amd, AMD
- Missing: PWI Amd, NP Amd, ANW Amd, WD Amd, PRF Amd

**Cor (Corrigendum):**
- Code has: CDCor, DCOR, FDCOR, Cor/COR
- Excel has: PWI Cor, NP Cor/ANW Cor, WDCor/ANW Cor, CDCor, DCOR, FDCOR/PRF Cor, COR
- Missing: PWI Cor, NP Cor, ANW Cor, WDCor, PRF Cor

**Suppl:**
- Code has: no typed stages
- Excel has: PWI Suppl, NP Suppl/ANW Suppl, WDSuppl/ANW Suppl, CD Suppl, DIS Suppl, FDIS Suppl, Suppl
- Missing: ALL typed stages for Supplement

**FRAG (Fragment):**
- Code has: no typed stages (fragment_identifier.rb exists but no TYPED_STAGES)
- Excel has: PWI Frag, NP Frag/ANW Frag, WD Frag/ANW Frag, CDFRAG, DFRAG, FDFRAG/PRF Frag, FRAG
- Missing: ALL typed stages for Fragment

## Implementation Steps

1. For each IEC identifier type, add missing `TYPED_STAGES` entries from the Excel
2. Each TypedStage needs: `code`, `stage_code`, `type_code`, `abbr`, `name`, `harmonized_stages`
3. Map stage codes to harmonized codes from the "Stage descriptions" sheet:
   - 00.xx = PWI stage
   - 10.xx = NP stage
   - 20.xx = WD stage
   - 30.xx = CD stage
   - 40.xx = CDV/DAM/DCOR/etc stage
   - 50.xx = FDIS/FDAM/FDCOR/etc stage
   - 60.xx = published
   - 90.xx = review
   - 95.xx = withdrawal
4. Remove or relocate `PROJECT_STAGES` constants (they are project-internal, not for identifiers)
5. Add tests for each new typed stage parsing/rendering
6. Verify URN generation works for all new stage codes

## Files to Modify

- `lib/pubid/iec/identifiers/international_standard.rb` - add PWI, NP, ANW, WD, PRF
- `lib/pubid/iec/identifiers/technical_specification.rb` - add PWI TS, NP TS, etc
- `lib/pubid/iec/identifiers/technical_report.rb` - add PWI TR, NP TR, etc
- `lib/pubid/iec/identifiers/publicly_available_specification.rb` - add PWI PAS, NP PAS, etc
- `lib/pubid/iec/identifiers/interpretation_sheet.rb` - add PWI ISH, NP ISH, etc
- `lib/pubid/iec/identifiers/guide.rb` - add PWI Guide, NP Guide, etc
- `lib/pubid/iec/identifiers/amendment.rb` - add PWI Amd, NP Amd, etc
- `lib/pubid/iec/identifiers/corrigendum.rb` - add PWI Cor, NP Cor, etc
- `lib/pubid/iec/identifiers/supplement_identifier.rb` - add all typed stages
- `lib/pubid/iec/identifiers/fragment_identifier.rb` - add all typed stages
- `lib/pubid/iec/parser.rb` - ensure parser recognizes new stage abbreviations
- `spec/pubid/iec/` - add tests for new stages

## Acceptance Criteria

- All IEC typed stages from the Excel are defined as `TYPED_STAGES` entries
- Parsing `IEC PWI 12345 ED1` produces correct typed stage
- Rendering round-trips all stage abbreviations
- URN generation includes correct stage codes
- Existing tests continue to pass
