# Task 2: Website Data Loader (VitePress)

## Goal
Create a VitePress data layer that imports the generated JSON from the Ruby export and merges it with hand-curated website data, keeping human-written descriptions/examples while using library data as the source of truth for structural metadata.

## Location
Files in `/Users/mulgogi/src/pubid/pubid.github.io/.vitepress/data/`

## Architecture

### Merge Strategy
| Data Element | Source of Truth | Notes |
|-------------|----------------|-------|
| Type keys (is, tr, ts, etc.) | Library | Authoritative from Scheme.identifiers |
| Type titles | Library | From `def self.type` |
| Type abbreviations | Library | From `define_metadata` |
| Typed stages | Library | From `TYPED_STAGES` constants |
| Doc type descriptions | Website | Human-written, curated |
| Doc type examples | Merged | Library fixtures + website curated |
| Components/attributes | Library | From Lutaml model attributes |
| Algebra, styles, URN patterns | Website | Curated content |
| Logo paths | Website | Curated |

### Files to Create
| File | Purpose |
|------|---------|
| `.vitepress/data/generated/` | Directory for imported JSON |
| `.vitepress/data/loader.ts` | Loads generated JSON, merges with curated data |
| `.vitepress/data/audit.ts` | Dev-only: compares generated vs curated, reports gaps |

### Loader Implementation
```typescript
// loader.ts
import generatedData from './generated/website-data.json'
import { publishers } from './publishers'
import type { Publisher } from './types'

export function loadMergedPublishers(): Publisher[] {
  // For each publisher, merge generated metadata with curated data
  return publishers.map(p => mergePublisher(p, generatedData[p.flavor]))
}

function mergePublisher(curated: Publisher, generated: GeneratedFlavorData | undefined): Publisher {
  if (!generated) return curated
  return {
    ...curated,
    // Use library data to validate/enrich doc types
    docTypes: mergeDocTypes(curated.docTypes, generated.identifier_types),
  }
}
```

## Constraints
- Generated JSON committed to website repo as a build artifact
- Manual step: run `rake export:website_data` in pubid gem, copy JSON to website
- Website must still build without generated data (graceful degradation)
