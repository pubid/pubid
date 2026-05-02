# Task 3: Audit Layer

## Goal
Create an audit tool that compares website publisher data against library-generated metadata, producing a structured report of gaps and mismatches.

## Design
- **Single Responsibility**: Audit checks one dimension at a time (types, stages, attributes, examples)
- **Open/Closed**: New audit checks can be added without modifying existing ones

## Checks

| Check | What to Compare | Library Source | Website Source |
|-------|----------------|---------------|----------------|
| Identifier types | Keys present in each flavor | `Scheme.identifiers` → `type[:key]` | `publishers.ts → docTypes[].key` |
| Type titles | Title for each type key | `def self.type[:title]` | `publishers.ts → docTypes[].title` |
| Type abbreviations | Allowed abbreviations | `define_metadata.abbr` | `publishers.ts → docTypes[].abbr` |
| Typed stages | Stage codes and names | `TYPED_STAGES` | `publishers.ts → stages[]` |
| Fixture examples | Real identifiers per type | `spec/fixtures/{fl}/pass/*.txt` | `publishers.ts → docTypes[].examples` |
| Component attributes | Lutaml model fields | Identifier class attributes | `publishers.ts → components[]` |

## Output
```json
{
  "iso": {
    "missing_types": [],
    "extra_types": [],
    "stage_mismatches": [],
    "attribute_gaps": []
  }
}
```

## Implementation
- Ruby-side: `lib/pubid/export/auditor.rb` — compares library state against imported website JSON
- Can also be a standalone script that reads both sources
- Rake task: `rake export:audit`

## Files to Create
| File | Purpose |
|------|---------|
| `lib/pubid/export/auditor.rb` | Compares library data against website JSON |
| Update `lib/tasks/export.rake` | Add `rake export:audit` task |
