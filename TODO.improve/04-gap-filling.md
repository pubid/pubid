# Task 4: Gap Filling

## Goal
Use the audit results to update the website's `publishers.ts` with missing identifier types, stages, and examples discovered from the library.

## Process
1. Run export task → `website-data.json`
2. Run audit → identify gaps
3. Auto-fill gaps in `publishers.ts`:
   - Add missing identifier types (from library but not in website)
   - Fix stage codes/abbreviations to match library definitions
   - Add missing examples from fixture files
   - Remove types that exist in website but not in library (data entry errors)
   - Update component lists to match actual Lutaml model attributes

## Constraints
- Human-written descriptions are preserved — only structural data is auto-filled
- Manual review required before committing changes
- Build must pass after changes

## Expected Gaps (from plan)
- **BSI**: Library has 22 types, website has 15 → 7 missing
- **NIST**: Different architecture requires special extraction
- **Simpler flavors**: ANSI, ASTM, ASME, CSA, OIML, CIE, API, Plateau, SAE — may have minimal gaps
