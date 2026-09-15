# IALA flavor notes

IALA (International Organization for Marine Aids to Navigation)
publication identifiers and their MRN URNs.

Read this before you change `lib/pubid/iala/` or `spec/pubid/iala/`. The
root `CLAUDE.md` keeps the cross-flavor contract that every flavor
obeys.

## Identifier space

Every IALA publication carries a coded reference: a series prefix
followed by a number whose shape varies per series.

| Series | Type | Numbering | Example |
|--------|------|-----------|---------|
| S | Standard | 4 digits, zero-padded | `IALA S1070 Ed 2.0` |
| R | Recommendation | 4 digits, zero-padded | `IALA R0126 Ed 2.0` |
| G | Guideline | 4 digits, zero-padded | `IALA G1015 Ed 2.2` |
| C | Model Course | 4 digits + `-` part | `IALA C0103-1 Ed 3.0` |
| M | Manual (planned) | 4 digits, zero-padded | `IALA M0001 Ed 9.0` |
| A | Advice | dashed, no edition in the corpus | `IALA A12-01` |
| GA | General Assembly resolution | dotted, each segment 2 digits | `IALA GA01.01` |
| L | Letter | dotted + dashed, verbatim | `IALA L2.1.11 Ed 2` |
| X | Report (reserved) | 4 digits | `IALA X0123` |
| P | Resolution/Council publication (reserved) | 4 digits | `IALA P0123` |
| — | Annex wrapper over any base | bare or lettered | `IALA G1128 ANNEX A Ed 1.6` |

The Annex class has no prefix of its own: it wraps a base identifier of
another series and preserves the annex marker case (`Annex` vs `ANNEX`).
X and P are reserved for future numbered series — today's reports and
Council publications carry no code; unnumbered report/symposium
documents exist in relaton-data-iala only as slug-form bibliographic
records, deliberately outside this identifier space.

## MRN URN scheme

IALA publications are named in the `mrn` URN tree as assigning
authority `iala`, sub-namespace `pub`:

```
urn:mrn:iala:pub:<code>[:annex[-<letter>]][:ed<x.x>][:<lang>]
```

- `<code>` — the lowercased series prefix + number (`s1070`,
  `c0103-1`, `ga01.01`, `l2.1.11`, `a12-01`, and the reserved `x0123`,
  `p0123`)
- `annex` / `annex-<letter>` — the Annex wrapper (lettered form for
  `ANNEX A`-style, bare for `Annex` without a letter)
- `ed<x.x>` — edition, lowercase marker, no separator dot
- `<lang>` — single lowercase language letter

The authoritative pattern for published documents is the IALA Style
Guide (G1115, Ed 1.0 January 2021) document-reference clause:
`urn:mrn:iala:pub:[p][nnnn]` with p ∈ {S, R, G, C} — printed on the
cover and footers. URNs for the other series (M, A, GA, L, X, P) are a
pattern-consistent extension: no such URN has been observed in a
published document yet, but every series round-trips through the same
generator/parser pair.

## Parsing and normalization

- The umbrella `Pubid.parse` routes URN-form input by assigning
  authority (`urn:mrn:iala:…` → the IALA flavor), not by the literal
  `mrn` namespace; unknown MRN authorities fail loudly.
- `Pubid::Iala.parse` dispatches URN-form input to `UrnParser` via
  `FormatDetector`, so both entry points accept both forms.
- The edition marker matches case-insensitively with an optional
  separator dot. Both malformed variants printed in the published R1026
  PDF (`…r1026:Ed1.0`, `…r1026:ed.1.0`) parse and normalize to the
  canonical `ed1.0`.
- Short inputs are zero-padded to the canonical form (`M1` → `M0001`,
  `GA1.1` → `GA01.01`); L-series numbering is preserved verbatim.

## Conformance

Ground truth lives in the shared suite
(pubid/pubid-testsuite `reference-docs/iala`): 701 coded identifiers
from relaton-data-iala primary docidentifiers plus the 15 MRN URNs
transcribed from the published PDFs in metanorma/mn-samples-iala
`reference-docs/` (including the two malformed R1026 spellings, kept
byte-identical as normalization aliases).
