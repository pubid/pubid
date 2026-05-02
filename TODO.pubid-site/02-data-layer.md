# 02 — Data Layer (publishers.ts + types.ts)

## Status: COMPLETE
- [x] .vitepress/data/types.ts — TypeScript interfaces
- [x] .vitepress/data/publishers.ts — all 23 publishers with full metadata
- Each publisher: flavor, name, fullName, category, description, website, syntaxNotes, urnPattern, relatedFlavors
- Each publisher: docTypes[] with key, title, abbr[], description, examples[]
- Each publisher: components[] with name, description, attribute
- Each publisher: algebra[] with type, description, syntax, example
- Publishers with stages: stages[] with code, abbr, name
