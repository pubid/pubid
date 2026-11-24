# IALA flavor notes

IALA (International Organization for Marine Aids to Navigation)
publication identifiers and their MRN URNs.

Read this before you change `lib/pubid/iala/` or `spec/pubid/iala/`. The
root `CLAUDE.md` keeps the cross-flavor contract that every flavor
obeys.

## Identifier space

Most IALA publications carry a coded reference: a series prefix
followed by a number whose shape varies per series. The rest carry no
code at all (see "Codeless publications" below).

| Series | Type | Numbering | Example |
|--------|------|-----------|---------|
| S | Standard | 4 digits, zero-padded | `IALA S1070 Ed 2.0` |
| R | Recommendation | 4 digits, zero-padded | `IALA R0126 Ed 2.0` |
| G | Guideline | 4 digits, zero-padded | `IALA G1015 Ed 2.2` |
| C | Model Course | 4 digits + `-` part | `IALA C0103-1 Ed 3.0` |
| M | Manual (planned) | 4 digits, zero-padded | `IALA M0001 Ed 9.0` |
| GA | General Assembly resolution | dotted, each segment 2 digits (`GA01.01`); legacy A-session form dashed (`A12-01`) | `IALA GA01.01`, `IALA A12-01` |
| L | Letter | dotted + dashed, verbatim | `IALA L2.1.11 Ed 2` |
| X | Report (reserved) | 4 digits | `IALA X0123` |
| P | Resolution/Council publication (reserved) | 4 digits | `IALA P0123` |
| — | Annex wrapper over any base | bare or lettered | `IALA G1128 ANNEX A Ed 1.6` |
| — | Publication (no code) | product-URL slug | `IALA arctic-seminar-report (E)` |

The A letter is GeneralAssembly's legacy session form, not a separate
series: all 11 A-shaped primary docidentifiers in relaton-data-iala
(A12-01, A13-01 through A13-04) are GA resolutions, the covers read
"GA Resolution A12-01", and no Advice-series document exists in the
catalogue. The letter the input used (GA or A) round-trips verbatim
through to_s and the URN; there is no Advice type.

The Annex class has no prefix of its own: it wraps a base identifier of
another series and preserves the annex marker case (`Annex` vs `ANNEX`).
X and P are reserved for future numbered series — today's reports and
Council publications carry no code, and parse as `Publication`.

## Codeless publications (`Identifiers::Publication`)

iala.int lists reports and proceedings, the style guide, history books,
questionnaires and radio plans with no code. relaton-data-iala gives
each one its product-URL slug as docid: `IALA <slug>[ Ed <x.y>][ (E)]`
(162 records, `spec/fixtures/iala/identifiers/pass/iala-publications.txt`).
These used to be "deliberately outside this identifier space".
relaton#604 removed that option: `relaton index` now fails on a document
that no pubid parse covers.

- **The slug is `number`.** It uses the inherited attribute, so
  `root.number` (the relaton-index key) is the slug and `to_hash` is
  `{_type: "pubid:iala:publication", number, edition?, language?}`. No
  padding applies.
- **Grammar**: `slug_identifier` is the last alternative of
  `identifier`, so every typed code keeps priority (`IALA G1164 Ed 1.1`
  stays a Guideline). A typed code starts upper-case and a slug
  lower-case or with a digit. The slug has no space, so it never takes
  ` Ed …` or ` (E)`.
- **A slug is narrow on purpose**: two or more `[a-z0-9]` runs joined by
  single hyphens (all 81 corpus slugs are), and the first run must not
  look like a code (0–2 letters then digits). The first version took any
  `[a-z0-9][a-z0-9-]*`, so `IALA s1070`, `IALA c0103-1` and
  `IALA 1070 Ed 2.0` — typos of typed codes that used to raise — came
  back as a `Publication` with a nil URN and an index key no row has:
  a loud parse error turned into a quiet "no match".
- **The `IALA ` prefix is mandatory for a slug** (it is optional for a
  typed code). Without it, any lower-case word would parse as IALA, and
  `Pubid.parse` routing's `accepts_anything?` probe would then classify
  IALA as an anything-goes flavor and stop trusting its fallback. The
  cost: `to_s(with_publisher: false)` (`arctic-seminar-report (E)`) does
  not parse back, unlike a typed code's (`G1164 Ed 1.1`).
- **`#to_urn` is nil.** `to_urn` is the organization's registered form,
  and IALA assigns no MRN to these documents; an invented
  `urn:mrn:iala:pub:<slug>` would also be ambiguous with the codes in
  `UrnParser` (`guideline-…` against `g1164`). `#to_pubid_urn` names
  them, and it escapes the first character of almost every slug
  (`urn:pubid:iala:pub:~61rctic-seminar-report`): a `<word>-` core value
  looks like an atom to the codec. It round-trips and is path-safe.
- **`to_mr_string` raises** for a Publication, as it already did for
  every IALA id: the base `mr_edition` calls `edition.number` on IALA's
  String edition (the BIPM/ASTM crash).
- **The grammar source is `pubid/pubid-grammar` `grammars/iala.parg`.**
  `data/parg/iala.json` was baked locally from the changed source at
  parsanol 1.5.1.0 under Ruby 3.4.8 (the CI pin: the unicode-table stamp
  carries the baking Ruby, so a bake under another Ruby is not
  byte-identical). A re-bake of the unchanged source under that pin
  reproduced the previous artifact byte for byte.

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
