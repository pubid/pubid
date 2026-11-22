# WMO flavor notes

WMO (World Meteorological Organization) publication identifiers and
their MRN URNs (pubid#763, widened): the WMO-No. series, the
technical-document series (WMO/TD, JCOMM Technical Report, GAW Report)
and, since the JCOMM dissolution, the WMO-published S-100-family
product specifications (consumer: metanorma/S-411-Product-Specification,
authored `mn-document-class: wmo` in the metanorma-taste `data/wmo`
flavor).

Read this before you change `lib/pubid/wmo/` or `spec/pubid/wmo/`. The
root `CLAUDE.md` keeps the cross-flavor contract that every flavor
obeys.

## The type assignment (the #763 ruling)

The S-100 type assignment follows the fleet's own precedent: IALA's
`S-201` is the S-100-family lexical form under the publishing org's
flavor (`Pubid::Iala`, `urn:mrn:iala:pub:s-201:ed2.0.0`). WMO-published
`S-411` is the same shape, so it is a **Pubid::Wmo** type — the
S-lexical form as a WMO type, publisher-parameterised, not a Pubid::Iho
identifier. The bare `S-411` string alone still names two documents
(IHO's and WMO's — each org assigns its own identifier), so like the
pubid#469 dual-perspective shapes the lexical form leads NO prefix and
`PREFIXES` carries only the series heads; the umbrella router reaches
WMO's S-411 through the exact-round-trip preference, never through a
claimed prefix.

## The prefix law (the widening ruling)

"Clearly we need a PREFIX — can't just accept 'TD-No.' and assume it's
WMO, maybe it's another publisher." Every publication series head names
its publisher, and the head is what the grammar matches:

| Head | series key | MRN slug |
|------|------------|----------|
| `WMO-No.` | nil (the default) | `wmo-<n>` |
| `WMO/TD-No.` | `TD` | `wmo-td-<n>` |
| `JCOMM Technical Report No.` | `JCOMM` | `jcomm-tr-<n>` |
| `GAW Report No.` | `GAW` | `gaw-<n>` |

- The four heads are this flavor's OWN `PREFIXES` entries (routing
  tokens), NOT `JOINT_PREFIXES` rows: `WMO/TD-No.` is WMO's own
  technical-document series, not a co-publication.
- The rejects and WHY they reject: `TD-No. 1265` / `TD No. 196` (no
  publisher named — no flavor owns them), `IMO/TD-No. 259` (no IMO TD
  series exists; the wild string is an OCR misread), `WMO/GAW Report
  No. 285` (third-party citation only — WMO's own records and covers
  use bare GAW). The spaced cover variant `WMO/TD - No. 1469`
  (GAW-183 cover at gml.noaa.gov) was examined for natural fall-out
  and deliberately rejected: only the glued library-serial head
  `WMO/TD-No.` is defined.
- `WMO/TD-No.` is the canonical glued form (library serial "TECHNICAL
  DOCUMENT / WMO/TD-No.", typhooncommittee.org TCP-23 PDFs,
  library.wmo.int `wmo-td_NNNN_en` viewers). The JCOMM Technical
  Reports are self-identifying joint WMO/IOC documents cross-referenced
  to TD numbers (TR 14 = TD 1086, TR 24 = TD 1215, TR 47 = TD 1466).

## Identifier space

| Type | Shape | Edition face | Example |
|------|-------|--------------|---------|
| Publication | `<head> <n>` | calendar year: `, 2025 edition` | `WMO-No. 1364, 2025 edition` |
| Standard | `S-<n>` | dotted x.y.z: ` 1.2.1` | `S-411 1.2.1` |
| Annex | `S-<n> Annex <L>` (wrapper over Standard) | dotted, on the annex | `S-411 Annex A` |

- **Editions are one string attribute with a type-driven face.** The
  issue's semantics: WMO editions are calendar years (`2025 edition`)
  on the publication series, the S-100 shapes carry the dotted
  `ed1.2.1` MRN form. The grammar binds both into the one
  `edition_value` capture; the renderer and the MRN generator key the
  face off the resolved type. There is no Components::Edition.
- **The compound faces widen the same capture** (the widening ruling):
  the year pair ("2021/2018" — the IMOP wording, primary year first)
  rides the ONE edition string — the pair IS the identity face, the
  dotted-x.y.z law of the S-100 side applied to years; the status word
  (`Provisional`, the IMOP Knowledge-Hub form) and the updated-in year
  (record 69478's "updated in 2025") are their own attributes
  (`edition_status`, `updated_in`), printed inside/after the edition
  face. The NIST `revised_date` atom is the sibling precedent for
  `updated_in`.
- **The volume face is its own attribute, printed BEFORE the edition**
  (the widening ruling's face order; both faces individually attested
  on record 35713's Volume I.1 and the 2020-edition rows). The values
  are roman numerals (I..V attested, the grammar takes the standard
  longest-first set through X), dotted-roman sub-volumes (I.1/I.2/I.3)
  and letter volumes (D). Arabic volumes reject.
- **Parse-only alternates**: the cover-stack year face
  (`WMO-No. 1364 2025 edition`), the compact aliases
  (`WMO-No. 1364:ed2025`, `S-411:ed1.2.1` — the compact year alias
  also takes the pair, `:ed2021/2018`) and the uppercase `ANNEX`
  marker all parse and normalize; the canonical faces are the
  repository forms (`S-411 1.2.1`, `S-411 Annex A`) and the WMO catalog
  citations (`WMO-No. 1364, 2025 edition`, `WMO/TD-No. 196`).
- **The dotted S-100 edition requires a dot** (`S-411 1.2` parses,
  `S-411 1234` rejects): a bare digit run after the code is not an
  edition face in either series, and the year face (4 digits) is
  publication-only. `WMO-No. 1364:ed1.2.1` rejects for the same reason.

## The faces carry no publisher token

The series heads are designations, not publisher tokens (the GB/GOST
rule) and the S-number prints bare — the repository's docidentifiers
are `S-411 Annex A` and `S-411 1.2.1`, never `WMO S-411`.
`publisher_prefixes` is `[]`, so `to_s(with_publisher:)` is the
identity on every type.

## MR slug (issue #142 distinctness)

The widening rows would collide without their discriminators, so
`mr_type` (the series: `wmo.td.196` vs `wmo.196`), `mr_volume`
(`wmo.8.vol-i` vs `wmo.8.vol-ii`, the ECMA law) and `mr_edition`
(`ed2021-2018`, `ed2026-provisional`, `ed2023-updated2025`) all carry
the compound faces. The year pair keeps its slash out of the slug
charset as a hyphen.

## MRN URN scheme

The `mrn` URN tree with WMO as assigning authority, sub-namespace
`pub`, following the IALA pattern:

```
urn:mrn:wmo:pub:wmo-<number>[:vol-<v>][:status-<s>][:ed<year>][:updated-<y>]
urn:mrn:wmo:pub:wmo-td-<number> / jcomm-tr-<number> / gaw-<number>
urn:mrn:wmo:pub:s-<number>[:annex[-<letter>]][:ed<x.y.z>]
```

- The publication series code via their SERIES slugs; the segment order
  mirrors the human face order (volume, status, edition, updated-in).
  Volume and status segment values are caseless (downcased like the
  annex letter, re-cased by the parser). The year pair keeps its slash
  out of the NSS (RFC 2141 has no slash in the trans set) as a hyphen
  (`ed2021-2018`).
- **No authoritative rule exists yet.** The issue asked for a search
  before assuming the shape: neither the S-411 repository nor any local
  checkout carries a `urn:mrn:wmo:` spelling, so this generator/parser
  pair IS the namespace extension, recorded as the issue's proposed
  form (the #763 ruling keeps `urn:mrn:wmo:` as the fleet's recorded
  extension). If WMO publishes a rule, that rule wins and this pair
  moves.
- The parser rebuilds the human forms and delegates to the text parser
  (one construction path). The MRN annex segment is caseless
  (`annex-a`), so the rebuild picks the attested face `Annex` — the
  uppercase `ANNEX` human form stays a parse-only alias whose URN
  re-renders to the attested face. Unknown/duplicate segments raise
  `Pubid::Errors::UrnParseError` (the ISO urn_parser strictness); the
  td slug wins over the bare wmo- code by longest-match-first.

## pubid-scheme URN (docs/URN-SCHEMES.adoc, `[[urn-wmo]]`)

`lib/pubid/wmo/pubid_urn_schema.rb`: atoms `series-`, `vol-`, `ed-`
(`edition`), `status-` (`edition_status`), `updated-` (`updated_in`),
`annexform-` (`annex_form`), `letter-` (`letter`); types
`pub`/`std`/`annex` over the default `number` core. The year pair
escapes through the codec (`ed-2021~2F2018`). `series` is nil on the
WMO-No. default, so every pre-widening URN is unchanged. The annex
rides the root-first chain
(`urn:pubid:wmo:std:411:annex:annexform-Annex:letter-A`), so the base
standard is the slug prefix. `annex_form` is an atom (identity) per
the iala schema — "Annex" and "ANNEX" are two identifiers.

## Corpus ground truth (attested only)

`spec/fixtures/wmo/identifiers/full/identifiers.txt`, regenerated by
`rake "validation:classify[wmo]"`. The widening rounds add, with
provenance in the header comment: the A-set rows (which parse on the
#763 grammar unchanged), the volume rows (IMOP Guide page I..V, record
35631's Volume III, Resolution 10 (SERCOM-1)'s Volume D, record
35713's Volume I.1), the compound rows (the IMOP wording, record
69478, the IMOP Knowledge-Hub), the TD/JCOMM/GAW rows (library serial
+ records 37163/55084/69472) and the prefix-law rejects
(`TD-No. 1265`, `IMO/TD-No. 259`, `TD No. 196`, `WMO/GAW Report No.
285`, the spaced `WMO/TD - No. 1469`). The MRN rows over the new
shapes follow the same proposed form.

## relaton-side follow-ups (not this repo)

bibdata carries the plain string `S-411` today; a relaton-side ask for
docidentifier types and MRN URNs is to be filed in the relaton monogem
and cross-linked on #763. metanorma-taste's `data/wmo` flavor registers
its URN generator the way `Metanorma::Taste::UrnGenerator.register`
does for the other flavors, so S-411 documents mint the publication
URN from fields instead of hand-pinning a `:urn:` attribute.
