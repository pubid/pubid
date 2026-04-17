# Task 03: Fix Missing Referenced Documents

## Status: DONE

## Goal

README.adoc references 4 documentation files that do not exist. Either create them or remove the broken references.

## Missing Files

1. `docs/URN-GENERATION-GUIDE.adoc` — Referenced in README as URN generation guide
2. `docs/RFC-5141-BIS-COMPLIANCE-REPORT.md` — Referenced in README as RFC compliance report
3. `docs/RENDERING_GUIDE.md` — Referenced in README as rendering guide
4. `docs/V2_ARCHITECTURE.adoc` — Referenced in README as V2 architecture doc

## Approach

For each missing file, decide: create stub or remove reference.

### URN-GENERATION-GUIDE.adoc
- Create. URN generation is a key feature and deserves dedicated docs.
- Content: explain `to_urn` method, URN format per flavor, round-trip guarantees, examples.
- Source data: `lib/pubid/*/urn_generator.rb`

### RFC-5141-BIS-COMPLIANCE-REPORT.md
- Create. This documents URN compliance against RFC 5141 bis.
- Content: which RFC requirements are met, test coverage, known deviations.

### RENDERING_GUIDE.md
- Create. Rendering (identifier to string) is the most complex part.
- Content: `to_s` options, annotated output, format variants (ref/short/urn).
- Source: `lib/pubid/core/renderer/`, `lib/pubid/*/renderer/`

### V2_ARCHITECTURE.adoc
- Create. Essential for onboarding new contributors.
- Content: V1 vs V2 layout, flavor module structure, parse pipeline, identifier class hierarchy.

## Files to Create/Modify

- `docs/URN-GENERATION-GUIDE.adoc` — create
- `docs/RFC-5141-BIS-COMPLIANCE-REPORT.md` — create
- `docs/RENDERING_GUIDE.md` — create
- `docs/V2_ARCHITECTURE.adoc` — create
- `README.adoc` — verify links work after creation

## Acceptance Criteria

- All 4 referenced documents exist with substantive content (not just stubs)
- README.adoc links resolve correctly
- Each doc is useful on its own (examples, code snippets, cross-references)
