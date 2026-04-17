# Task 04: README Refresh

## Status: DONE

## Goal

README.adoc contains stale V1 references, internal dev session notes, and outdated structure information. Refresh it for the V2 single-gem layout.

## Issues Found

1. **V1 `gems/` references**: README describes `gems/pubid-{name}/` directory structure that was removed in V2
2. **Dev session notes**: Contains "Session 138 Enhancements", "Session 129" internal notes that don't belong in user-facing docs
3. **Broken links**: References 4 docs that don't exist (addressed in Task 03)
4. **No Quick Start**: Missing a "parse an identifier in 30 seconds" section
5. **Outdated architecture diagram**: Shows V1 monorepo structure instead of V2 flat layout
6. **Missing flavor list**: No complete list of all 22 supported flavors with examples

## Proposed Structure

```asciidoc
= PubID

== Quick Start
  3-line example: install, parse, render

== Supported Flavors
  Table of 22 flavors with example identifiers

== Usage
  === Parsing
  === Rendering
  === URN Generation
  === Round-trip Guarantees
  === Annotated Output

== Architecture
  === Parse Pipeline
  === Identifier Class Hierarchy
  === Pre-parse Normalization

== Development
  === Running Tests
  === Adding a New Flavor
  === Code Quality

== Links
  API Docs | Contributing Guide | Changelog
```

## Files to Modify

- `README.adoc` — complete rewrite preserving any valid content

## Acceptance Criteria

- No references to V1 `gems/` structure
- No internal dev session notes
- Quick Start section works for a new user
- All 22 flavors listed with examples
- All links resolve
- Code examples are tested (copy-pasteable and correct)
