# Task 02: Identifier Pattern Reference Documentation

## Status: DONE

## Goal

Create auto-generated reference documentation for every identifier pattern
across all 22 flavors. This is the single highest-leverage documentation
improvement because the library has 178 identifier types with 244k+ test
fixtures and the parser grammars are unreadable without a human-readable guide.

## Proposed Structure

```
docs/identifier-patterns/
├── README.md              # Index page with cross-flavor comparison table
├── iso.md                 # ISO identifier patterns
├── iec.md                 # IEC identifier patterns
├── ieee.md                # IEEE identifier patterns
├── nist.md                # NIST/NBS identifier patterns
├── bsi.md                 # BSI identifier patterns
├── cen.md                 # CEN/CENELEC identifier patterns
├── itu.md                 # ITU identifier patterns
├── etsi.md                # ETSI identifier patterns
├── jis.md                 # JIS identifier patterns
├── ccsds.md               # CCSDS identifier patterns
├── plateau.md             # PLATEAU identifier patterns
├── asme.md                # ASME identifier patterns
├── astm.md                # ASTM identifier patterns
├── ashrae.md              # ASHRAE identifier patterns
├── api.md                 # API identifier patterns
├── cie.md                 # CIE identifier patterns
├── csa.md                 # CSA identifier patterns
├── idf.md                 # IDF identifier patterns
└── ...                    # Additional flavors
```

## Per-Flavor File Content

Each flavor's `.md` file must contain:

### 1. Overview Section
- Flavor name and description
- Entry point: `Pubid::{Flavor}.parse("...")`
- Top-level module location

### 2. Identifier Type Catalog

For EVERY type in `lib/pubid/{flavor}/identifiers/`:

```
## International Standard (IS)

**Class:** `Pubid::Iso::Identifiers::InternationalStandard`
**Pattern:** `ISO [{copublisher}/] {number}[-{part}][:YYYY]`
**URN:** `urn:iso:std:iso[-{copub}]:{number}[-{part}]`

| Input | Output | URN |
|-------|--------|-----|
| ISO 9001:2015 | ISO 9001:2015 | urn:iso:std:iso:9001 |
| ISO/IEC 27001:2013 | ISO/IEC 27001:2013 | urn:iso:std:iso-iec:27001 |

**Stages:** PWI, NP, WD, CD, DIS, FDIS, IS (see stage table below)

**Stage Table:**

| Abbr | Name | Harmonized Codes |
|------|------|-----------------|
| PWI | Preliminary Work Item | 00.00-00.99 |
| NP | New Proposal | 10.00-10.99 |
| ... | ... | ... |
```

### 3. Cross-Flavor Comparison Table (in README.md)

```
| Component    | ISO      | IEC      | IEEE     | NIST     |
|-------------|----------|----------|----------|----------|
| Publisher    | ISO/IEC  | IEC      | IEEE     | NIST/NBS |
| Parts        | -1       | -1       | -1       | -1       |
| Year         | :YYYY    | :YYYY    | -YYYY    | -YYYY    |
| Supplements  | /Amd/Cor | /AMD/COR | /Cor.    | /Upd     |
| URN support  | yes      | yes      | yes      | yes      |
| Typed stages | 14       | ?        | 0        | 0        |
| Fixture pass | 90.0%    | 84.6%    | 88.0%    | 98.5%    |
```

### 4. Pre-parse Normalization Reference

Link to `data/{flavor}/update_codes.yaml` with summary of categories:
- Typos and OCR errors
- Legacy format migrations (NBS -> NIST, AIEE -> IEEE)
- Stage code reformatting

## Auto-Generation

Create `lib/tasks/docs.rake` with:

```ruby
namespace :docs do
  desc "Generate identifier pattern reference docs"
  task :patterns do
    # For each flavor:
    # 1. List identifier types from identifiers/ directory
    # 2. Extract TYPED_STAGES, stage_codes, abbreviations
    # 3. Sample 5 passing fixtures per type
    # 4. Generate markdown with pattern tables
    # 5. Generate cross-flavor comparison table
  end
end
```

This keeps docs in sync with code changes. Run via `bundle exec rake docs:patterns`.

## Data Sources

- Identifier types: `lib/pubid/{flavor}/identifiers/*.rb` (class names, TYPED_STAGES)
- Stage definitions: `TYPED_STAGES` constants in each identifier class
- Real examples: `spec/fixtures/{flavor}/pass/*.txt` (sampled)
- Parser grammar: `lib/pubid/{flavor}/parser.rb` (pattern extraction)
- URN formats: `lib/pubid/{flavor}/urn_generator.rb`
- Update codes: `data/{flavor}/update_codes.yaml`

## Acceptance Criteria

- Every flavor has a pattern reference file
- Every identifier type in every flavor is documented with pattern, examples, stages
- Cross-flavor comparison table exists
- Docs are auto-generatable from code via `rake docs:patterns`
- README.adoc links to the generated docs
