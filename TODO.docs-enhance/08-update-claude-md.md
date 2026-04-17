# Task 08: Update CLAUDE.md for V2 Structure

## Status: DONE

## Goal

CLAUDE.md still describes the V1 monorepo structure with `gems/` directory. Update it to reflect the V2 single-gem layout and current architecture.

## Issues

1. **References `gems/` structure**: Architecture section shows `gems/pubid-{name}/` layout
2. **Rake tasks**: Some listed commands may not exist (e.g., `test:all`, `test:integration`, `test:pubid_core`)
3. **Dependency hierarchy**: May be outdated — verify against actual gemspec/runtime dependencies
4. **Missing V2 patterns**: No mention of `data/` normalization files, `Scheme#parse`, or unified entry point

## Content to Update

### Architecture Section
- Show V2 flat layout: `lib/pubid/{flavor}/`
- Document the parse pipeline: entry point → UpdateCodes → Parser → Transformer → Builder → Identifier
- Document `data/{flavor}/update_codes.yaml` normalization layer

### Commands Section
- Verify all listed rake tasks actually exist
- Add `rake docs:patterns` once Task 05 is implemented
- Update test commands for V2 (single `bundle exec rspec` runs everything)

### Testing Notes
- V2 has unified test suite, not per-gem
- Document fixture format (one identifier per line in pass/fail dirs)
- Document fixtures_spec.rb pattern for bulk testing

## Files to Modify

- `CLAUDE.md` — update for V2

## Acceptance Criteria

- No references to V1 `gems/` structure
- All listed commands work when run
- Architecture accurately describes current code
- Dependency hierarchy is verified against gemspec
