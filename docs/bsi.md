# BSI Documentation

## Overview

The BSI flavor handles identifiers for British Standards Institution (BSI) standards and publications. BSI identifiers include multiple document types (BS, DD, PD, PAS, TS, NA, Handbook, etc.), specialized prefixes (AU, HC, MA, PL, QC, TA, etc.), supplements (+A1, /AC1), amendments, corrigenda, set notation (+), bundled identifiers, adopted standards (ISO, IEC), and value-added publications. The flavor uses complex preprocessing and ordered parser rules to handle BSI's extensive identifier patterns.

## Architecture

This flavor follows the PubID v2 three-layer architecture pattern:

1. **Parser** (`parser.rb`) - Parslet PEG grammar for syntax parsing
   - Uses ordered rules (most specific first)
   - Handles specialized prefixes (AU, HC, MA, PL, QC, TA, etc.)
   - Supports multiple document types (DD, PD, PAS, TS, NA, Handbook, etc.)
   - Parses set notation (+ for sets)
   - Handles amendments (+A1:2008, /A2:2019)
   - Supports corrigenda (+AC:2009, /AC1:2005, +C1:2018)
   - Parses bundling (and, to, &, semicolon, comma)
   - Handles adopted standards (ISO, IEC, CISPR)
   - Supports National Annexes (NA to BS...)
   - Parses supplement documents
   - Handles value-added publications (PDF, BOOK, TC)

2. **Builder** (`builder.rb`) - Transforms parse trees to domain objects
   - Handles complex BSI patterns
   - Constructs appropriate identifier classes

3. **Identifier** (`identifiers/`) - Lutaml::Model domain classes with rendering logic

## Document Types

| Type | Full Name | Description |
|------|-----------|-------------|
| BS | British Standard | Standard |
| DD | Draft for Development | Consultative document |
| PD | Published Document | Guidance document |
| PAS | Publicly Available Specification | Fast-track standard |
| TS | Technical Specification | Technical specification |
| NA | National Annex | Annex to adopted standard |
| Handbook | Handbook | Guidance document |
| BIP | British Industry Publication | Industry publication |
| PP | Public Procedure | Public procedure |
| Flex | BSI Flex | Fast-track standard |
| Draft BS | Draft British Standard | Draft standard |
| DBS | Draft British Standard | Draft standard (alt) |

## Specialized Prefixes

BSI has specialized prefixes for specific industries:

| Prefix | Industry | Description |
|--------|----------|-------------|
| AU | Automotive | Automotive standards |
| HC | Hovercraft | Hovercraft standards |
| MA | Marine | Marine standards |
| PL | Plumbing | Plumbing standards |
| QC | Quality | Quality assurance |
| TA | Telecommunications | Telecom standards |
| A | Aerospace | Aerospace standards |
| B | General | General standards |
| C | Ceramics | Ceramics/ground rules |
| F | Firearms | Firearms standards |
| G | Gas | Gas standards |
| L | Lighting | Lighting standards |
| M | Road | Road standards |
| S | Soil | Soil standards |
| X | Miscellaneous | Miscellaneous |

## Supplement Notation

BSI supports multiple supplement notations:

### Amendments
- `+A1:2008` - Plus separator, amendment 1, year 2008
- `/A2:2019` - Slash separator, amendment 2, year 2019
- `+A1:15` - Short year format

### Corrigenda
- `+AC:2009` - Plus separator, corrigendum
- `+AC1:2008` - Plus separator, corrigendum 1
- `/AC1:2005` - Slash separator, corrigendum 1
- `+C1:2018` - Plus separator, corrigendum 1 (C notation)
- `/C1` - Without year

## Set and Bundle Notation

BSI supports set and bundle notation:

### Sets (+ separator)
- `BS 13+14+15:1949` - Set of 3 standards
- `BS 1000[9]+1001:1973` - Set with iteration

### Bundles
- `BS 13 and 14:1949` - "and" separator
- `BS 2SP 68 to BS 2SP 71` - "to" separator (range)
- `BS 13 & 14:1949` - Ampersand separator
- `BS 13; 14; 15:1949` - Semicolon separator
- `BS 13, 14, 15:1949` - Comma separator

## National Annexes

BSI supports National Annexes:
- `NA to BS EN 196-1:1995` - National Annex to BS EN 196-1
- `NA+A1:2012 to BS EN 196-1:1995` - National Annex with amendment

## Special Document Suffixes

BSI supports various document suffixes:
- `:Index:1981` - Index document
- `:Supplement No. 1:1970` - Supplement document
- `:Explanatory Supplement` - Explanatory supplement
- `:Method 131B:1983` - Method identifier
- `Section 0:1977` - Section identifier
- `N002:1974` - Detailed specification (N notation)
- `C155-168:1971` - Detailed specification (C notation, range)
- `Expert Commentary` - Expert commentary suffix
- `ExComm (Fire)` - Expert commentary (abbreviated)
- `- TC` - Tracked changes
- `PDF` - PDF format
- `SPANISH TRANSLATION` - Translation

## Value-Added Publications

BSI supports value-added publication formats:
- `PDF` - PDF format
- `BOOK` - Book format
- `TC` - Tracked changes

## Amendment Notation

BSI standalone amendments:
- `AMD 11015` - Amendment 11015
- `(AMD 10971)` - Parenthesized amendment
- `AMD Corrigendum 14716` - Corrigendum amendment

## Testing

### Test Coverage

- **Unit tests:** `spec/pubid_new/bsi/`
- **Parser tests:** `spec/pubid_new/bsi/parser_spec.rb`
- **Builder tests:** `spec/pubid_new/bsi/builder_spec.rb`
- **Identifier tests:** `spec/pubid_new/bsi/identifiers/`

### Fixtures

Located in: `spec/fixtures/bsi/identifiers/`

- **Pass tests:** `pass/` - Valid patterns
- **Fail tests:** `fail/` - Invalid patterns

## Design Characteristics

### Preprocessing

BSI uses preprocessing normalization:
- `BSI` → `BS` (except for "BSI Flex")
- `CEN-CLC` → `CEN/CLC`
- `GUIDE` → `Guide`

### Ordered Parser Rules

BSI uses ordered parser rules to handle specific patterns:
1. Standalone Amendment (starts with "AMD")
2. Committee Document (starts with YY/NNNNNNNN)
3. Index identifier
4. Supplementary Index identifier
5. Explanatory Supplement identifier
6. Method identifier
7. Test Method identifier
8. Section identifier
9. Detailed Specification identifier
10. DISC identifier
11. Supplement Document (reverse)
12. Supplement Document (forward)
13. Addendum Document
14. Set identifier
15. Bundled Identifiers
16. Bare adopted identifier
17. Flex identifier
18. Regular BSI identifier

### Adopted Standards

BSI adopts ISO, IEC, CISPR, and CEN standards:
- `EN ISO 9001` - Adopted ISO standard
- `EN IEC 62600` - Adopted IEC standard
- `EN 10077-1:2006` - Adopted EN standard

Adopted standards are parsed as opaque strings.

## Comparison with ISO

| Feature | BSI | ISO |
|---------|-----|-----|
| Publisher | BS (with specialized prefixes) | ISO (with copublishers) |
| Document types | 10+ (BS, DD, PD, PAS, etc.) | 18+ (IS, TR, TS, etc.) |
| Stage codes | Draft BS, DBS | 15+ (PWI, NP, WD, CD, DIS, FDIS) |
| Supplements | Amd, Cor (AC) | Amd, Cor, Add, Suppl, Ext |
| Set notation | + (plus) | None |
| Bundle notation | and, to, &, ;, , | None |
| Supplement separator | + or / | / only |
| Date format | :YYYY | :YYYY or (YYYY) |
| National Annexes | NA to BS... | None |

## References

- **Specification:** BSI (British Standards Institution)
- **Examples:** BSI Shop (https://shop.bsigroup.com/)
- **Related implementations:**
  - CEN flavor (European harmonization)
  - ISO flavor (adopted standards)

---

## Appendix: Design Decisions

### Specialized Prefixes

**Context:** BSI has many specialized prefixes (AU, HC, MA, PL, etc.).

**Decision:** Parse specialized prefixes before single-letter prefixes.

**Rationale:**
- Multi-letter prefixes must match first (longest match)
- Order matters in parser rules
- Avoids ambiguous matches

**Alternatives considered:**
- Single prefix rule - Rejected (ambiguous)
- Use negative lookahead - Rejected (complex)

### Set and Bundle Notation

**Context:** BSI uses various separators for sets and bundles.

**Decision:** Parse as separate set and bundle patterns.

**Rationale:**
- Sets use + (and)
- Bundles use and, to, &, ;, ,
- Different semantics (sets vs bundles)
- Cleaner parsing

**Alternatives considered:**
- Single separator rule - Rejected (loses semantics)
- Rejection - Rejected (common practice)

### National Annex Patterns

**Context:** National Annexes have complex patterns (NA+A1 to BS...).

**Decision:** Create dedicated NA prefix patterns.

**Rationale:**
- NA patterns are unique
- Forward and reverse formats
- Supplements in prefix

**Alternatives considered:**
- Parse as supplements - Rejected (different format)
- Rejection - Rejected (common BSI practice)

### Value-Added Suffixes

**Context:** BSI has various value-added publication formats.

**Decision:** Parse as wrapper suffixes, not core identifier.

**Rationale:**
- PDF, BOOK, TC are formats, not identifiers
- Should not affect identifier matching
- Preserved for rendering

**Alternatives considered:**
- Include in identifier class - Rejected (mixes concerns)
- Strip during parsing - Rejected (loses information)

### Complex Special Suffixes

**Context:** BSI has many special suffixes (Index, Method, Section, etc.).

**Decision:** Create dedicated rules for each suffix type.

**Rationale:**
- Each suffix has unique format
- Order matters (most specific first)
- Clean semantic separation

**Alternatives considered:**
- Generic suffix rule - Rejected (too permissive)
- Rejection - Rejected (common BSI practice)
