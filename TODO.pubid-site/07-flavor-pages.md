# 07 — Per-Flavor Pages (23 Publishers)

## Status: COMPLETE
All 23 publishers have dynamically generated pages using VitePress `[flavor].paths.ts`.

Each page contains:
1. **Hero Section** — Publisher icon, name, full name, category badge, description, syntax pattern, website link
2. **Quick Stats Bar** — Doc types count, components count, algebra relations count, stages count
3. **Sticky Section Nav** — Jump links to Document Types, Components, Algebra, Stages, Related
4. **Document Types** — Collapsible cards with abbreviations, descriptions, and styled examples; Expand/Collapse All toggle
5. **Components** — Grid of cards with attribute tags
6. **Algebra** — Modern table with relation type, description, syntax, and example
7. **Stages** — (where applicable) development stage reference table
8. **Related Publishers** — Styled link cards with arrows

## Per-Identifier-Type Pages
Each document type also has its own dedicated page at `/publishers/[flavor]/[type]`:
- Description, examples, components used, algebra relations, stages, URN pattern, related links
- Breadcrumb navigation back to publisher overview
- Generated via `[type].paths.ts` — 184 additional pages

## Flavors with pages:
- [x] ISO (18 types) — /publishers/iso + 18 type pages
- [x] IEC (19 types) — /publishers/iec + 19 type pages
- [x] IEEE (17 types) — /publishers/ieee + 17 type pages
- [x] ITU (4 types) — /publishers/itu + 4 type pages
- [x] NIST (19 types) — /publishers/nist + 19 type pages
- [x] BSI (16 types) — /publishers/bsi + 16 type pages
- [x] CEN (13 types) — /publishers/cen + 13 type pages
- [x] ETSI (4 types) — /publishers/etsi + 4 type pages
- [x] ANSI (2 types) — /publishers/ansi + 2 type pages
- [x] ASTM (9 types) — /publishers/astm + 9 type pages
- [x] ASHRAE (7 types) — /publishers/ashrae + 7 type pages
- [x] ASME (1 type) — /publishers/asme + 1 type page
- [x] CCSDS (2 types) — /publishers/ccsds + 2 type pages
- [x] CIE (9 types) — /publishers/cie + 9 type pages
- [x] CSA (8 types) — /publishers/csa + 8 type pages
- [x] JIS (6 types) — /publishers/jis + 6 type pages
- [x] JCGM (3 types) — /publishers/jcgm + 3 type pages
- [x] OIML (9 types) — /publishers/oiml + 9 type pages
- [x] IDF (4 types) — /publishers/idf + 4 type pages
- [x] API (7 types) — /publishers/api + 7 type pages
- [x] AMCA (3 types) — /publishers/amca + 3 type pages
- [x] Plateau (3 types) — /publishers/plateau + 3 type pages
- [x] SAE (1 type) — /publishers/sae + 1 type page

## Sidebar
Publisher sidebar now uses collapsible sections showing all document types nested under each publisher.
