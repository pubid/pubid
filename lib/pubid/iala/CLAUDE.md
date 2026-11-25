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
| S-2xx | Product Specification | the IHO-granted S-201..S-299 range, hyphenated (`S-201`), dotted x.y.z edition, bare face | `S-201 2.0.0` |
| R | Recommendation | 4 digits, zero-padded | `IALA R0126 Ed 2.0` |
| G | Guideline | 4 digits, zero-padded | `IALA G1015 Ed 2.2` |
| C | Model Course | 4 digits + `-` part | `IALA C0103-1 Ed 3.0` |
| M | Manual (planned) | 4 digits, zero-padded | `IALA M0001 Ed 9.0` |
| GA | General Assembly resolution | dotted, each segment 2 digits (`GA01.01`); legacy A-session form dashed (`A12-01`) | `IALA GA01.01`, `IALA A12-01` |
| L | Letter | dotted + dashed, verbatim | `IALA L2.1.11 Ed 2` |
| X | Report (reserved) | 4 digits | `IALA X0123` |
| P | Resolution/Council publication (reserved) | 4 digits | `IALA P0123` |
| — | Annex wrapper over any base | bare or lettered (letter takes a sub-number, `ANNEX B2`) | `IALA G1128 ANNEX A Ed 1.6`, `S-201 ANNEX B2` |
| — | Publication (no code) | product-URL slug | `IALA arctic-seminar-report (E)` |

The A letter is GeneralAssembly's legacy session form, not a separate
series: all 11 A-shaped primary docidentifiers in relaton-data-iala
(A12-01, A13-01 through A13-04) are GA resolutions, the covers read
"GA Resolution A12-01", and no Advice-series document exists in the
catalogue. The letter the input used (GA or A) round-trips verbatim
through to_s and the URN; there is no Advice type.

The Annex class has no prefix of its own: it wraps a base identifier of
another series and preserves the annex marker case (`Annex` vs `ANNEX`).
Its letter takes an optional trailing digit (the S-201 package's
sub-numbered annexes "Annex B2"/"Annex D1" on iala.int).
X and P are reserved for future numbered series — today's reports and
Council publications carry no code, and parse as `Publication`.

## S-100-family product specifications (`Identifiers::ProductSpecification`)

IHO granted IALA the S-200 domain's product-spec numbering, S-201 to
S-299 (iala.int, "IALA S-200 Product Specification and Development
Status": compliant with the IHO S-100 standard; the dev-status pages
name S-201, S-210, S-211, S-212, S-230, S-240, S-245, S-246, S-247).

- **The lexical form is hyphenated** (`S-201`) — unlike the legacy
  zero-padded S series (`S1010`), and the edition is the S-100 dotted
  x.y.z on the **bare face** (`S-201 2.0.0`, iala.int's own citation
  form). `IALA S-201 2.0.0`, `Ed 2.0.0`, `:ed2.0.0` and the lower-case
  code spelling are normalizing aliases.
- **The designation carries no publisher token** (`publisher_prefixes`
  is `[]`, the WMO S-100 rule), so `to_s(with_publisher:)` is the
  identity. The `publisher` attribute stays "IALA" (the default) for
  the hash.
- **The grant bounds the grammar**: the hundreds digit is fixed to 2
  and `S-200` is excluded ("spans from S-201"), so WMO's S-4xx and
  IHO's S-1xx never parse here. Routing reclaims the bare S-2xx strings
  the WMO flavor's generic S-rule used to capture (`S-201 2.0.0` was
  `urn:mrn:wmo:pub:s-201:ed2.0.0` on pubid 2.0.51) via the exact
  round trip; WMO keeps S-411/S-412. This is the pubid#469/#763
  dual-perspective law: the lexical form leads no prefix, each org
  assigns its own identifier.
- **The annex wrapper rides the same class** (`S-201 ANNEX B2` → Annex
  over ProductSpecification); the annex edition face follows the base's
  family (bare for S-100, `Ed` for the legacy series).
- `type[:short]` is nil (no letter table entry — "S" would collide with
  Standard's); the renderer and the URN generator branch on the class.

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
authority `iala`, sub-namespace `pub`. The scheme is the official MRN
of IALA Recommendation R1023 (Maritime Resource Names; its own cover
prints `urn:mrn:iala:pub:r1023:ed1.0`), Guideline G1143 (Unique
Identifiers for Maritime Resources — the ABNF, the lowercase
case-insensitive face, Annex A4's `urn:mrn:iala:pub:<managed name
spaces>`) and Guideline G1164 (Management of MRN Organisation
Identifiers — IALA's org id and the OID rules); all three are on the
MRN portal (https://www.iala.int/technical/data-modelling-mrn/). The
full per-flavor URN record, with the segment table and the divergence
audit, is `lib/pubid/iala/urn.adoc`.

```
urn:mrn:iala:pub:<code>[:annex[-<letter>]][:ed<edition>][:<lang>]
```

- `<code>` — the lowercased series prefix + number (`s1070`,
  `c0103-1`, `ga01.01`, `l2.1.11`, `a12-01`, and the reserved `x0123`,
  `p0123`), plus the S-100-family codes hyphenated (`s-201` … `s-299`)
- `annex` / `annex-<letter>` — the Annex wrapper (lettered form for
  `ANNEX A`-style, bare for `Annex` without a letter; the letter takes
  a sub-number, `annex-b2`)
- `ed<x.y>` — edition, lowercase marker, no separator dot; the digits
  are verbatim, so an S-100-family edition carries all three segments
  (`ed2.0.0`, the form of IALA S-201 Edition 2.0.0)
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
- The S-100-family faces normalize: the prefixed spellings (`IALA
  S-201 2.0.0`, `Ed 2.0.0`, the compact `:ed2.0.0`) and the lower-case
  code (`s-201`) all render as the bare `S-201 2.0.0`; the URN round
  goes through the grammar's `Ed` alias and restores the bare face.
- Short inputs are zero-padded to the canonical form (`M1` → `M0001`,
  `GA1.1` → `GA01.01`); L-series numbering is preserved verbatim.

## Conformance

Ground truth lives in the shared suite
(pubid/pubid-testsuite `reference-docs/iala`): 701 coded identifiers
from relaton-data-iala primary docidentifiers plus the 15 MRN URNs
transcribed from the published PDFs in metanorma/mn-samples-iala
`reference-docs/` (including the two malformed R1026 spellings, kept
byte-identical as normalization aliases).
