# ISO: usage, rendering formats and stage mapping

Ported from the archived `pubid-iso` README, restated against the pubid 2.0
monogem. The v1 `Identifier.create(...)` constructor is historic — construct
with `Pubid::Iso::Identifier.new(...)`; see `docs/CONSTRUCTION.md`.

Use cases this flavor supports:

. generate the corresponding URN (RFC 5141 for ISO, `#to_urn`) and the
  always-round-tripping `#to_pubid_urn`
. generate updated PubIDs (dated vs undated, edition, language)
. resolve and render ISO harmonized stages and typed stages

## Elements of the ISO PubID

publisher:: publishing organization (`ISO`; under co-publishing agreements
the abbreviations of the other SDOs follow, delimited by `/`: `ISO/IEC`,
`ISO/IEC/IEEE`, `ISO/IEEE`, `ISO/SAE`; an International Workshop Agreement
carries `IWA`)
document stage:: development stage, per the harmonized stage codes (below)
document number:: numeric identifier of the document
update number:: ordinal of an amendment or technical corrigendum
document type:: type of ISO deliverable (TR, TS, PAS, Guide…)
copyright year:: year of publication
language:: language code(s) in parentheses (`(en)`, `(E)`, `(E/F/R)`)

## Rendering options

ISO `to_s` takes these options (the v1 `format:` symbols
`:ref_num_short`/`:ref_num_long`/`:ref_dated`/`:ref_undated` are not a v2 API;
the same dimensions are controlled by explicit keywords):

| v2 option | Effect | Example output for `ISO 1234:2019/Amd 1:2021` |
|-----------|--------|-----------------------------------------------|
| (default) | canonical surface form | `ISO 1234:2019/Amd 1:2021` |
| `lang_single: true` | 1-letter language codes (`E`, `F`, `R`… when the identifier carries languages) + short stage abbreviations | `ISO 1234:2019/AMD 1:2021` |
| `stage_format_long: true` | long stage abbreviations (`Amd`, `DCor`, `FDCor`) | `ISO 1234:2019/Amd 1:2021` |
| `with_date: false` | undated form (drops the year) | `ISO 1234/AMD 1` |
| `with_edition: true` | append the edition portion when the identifier carries one (the edition renders on the base document) | `ISO 1234:2019 ED2/Amd 1:2021` |
| `lang: :french` / `:russian` | **historic (v1)** — v1 rendered localized publisher words (`Guide ISO/CEI…`, `ИСО…`); v2 renders the canonical English words and preserves the language code in parentheses | — |

Equivalent dimension mapping (historic v1 names, for orientation):
`ref_num_short` = single-letter language code + short stage + dated;
`ref_num_long` = ISO 639-1 code + long stage + dated; `ref_dated` /
`ref_dated_long` = no language code + dated; `ref_undated` /
`ref_undated_long` = no language code + undated. The living implementation is
`Pubid::Rendering::RenderingContext` and `Pubid::Iso::SingleIdentifier#build_rendering_context`
(`lib/pubid/rendering/context.rb`, `lib/pubid/iso/single_identifier.rb`).

When nothing is given, the style is detected from the parsed spelling: the
language-code face follows the identifier's own language codes
(1-letter → single, 2-letter → ISO), and the stage-length face follows whether
the input spelled a long abbreviation (`DCor` renders long; `DCOR` renders
short) — parse and render round-trip byte-exactly.

## Supplement stage abbreviations: DAM/FDAM, DCor/FDCor

Amendments and corrigenda carry their own stage abbreviations. v2 parses every
historic spelling and renders one canonical face:

| Stage (harmonized codes) | Parsed spellings | Canonical render |
|--------------------------|------------------|------------------|
| Draft Amendment (40.xx) | `DAM`, `DAmd` | `DAM` |
| Final Draft Amendment (50.xx) | `FDAM`, `FDAmd`, `FPDAM` (legacy) | `FDAM` |
| Draft Corrigendum (40.xx) | `DCor`, `DCOR`, `DIS Cor` | `DCor` (long face) / `DCOR` (short face) |
| Final Draft Corrigendum (50.xx) | `FDCor`, `FDCOR`, `FCOR`, `FDIS Cor` | `FDCor` (long face) / `FDCOR` (short face) |
| Published Amendment (60.xx) | `Amd`, `AMD`, `Amd.` | `Amd` (long) / `AMD` (short) |
| Published Corrigendum (60.xx) | `Cor`, `COR`, `Cor.` | `Cor` |

The render face follows how the identifier was spelled and the options above:
a spelling that starts with the long abbreviation (`DCor`, `FDCor`, `Amd`)
renders the long face, an all-uppercase spelling (`DCOR`, `AMD`) renders the
short one, and the joined legacy spellings (`DIS Cor`, `FCOR`) and the
amendment `DAmd`/`FDAmd` forms canonicalize to the short face (`DCOR`,
`FCOR` — and `DAM`/`FDAM`, for which no long form exists in the registry).

`stage_format_long:` selects the face only for abbreviations that carry a
registered long form (`Amd`, `DCor`, `FDCor`); the amendment drafts
`DAM`/`FDAM` have none and render short in every face — so `DAmd`/`FDAmd` are
accepted on parse but always render as the canonical `DAM`/`FDAM` (pubid v1's
legacy-abbreviation semantics). `lib/pubid/iso/identifiers/amendment.rb` and
`.../corrigendum.rb` are the source tables.

## Language codes

The language face follows the identifier: `(E)` (1-letter) renders single
letters when `lang_single:` is in effect; parsed 2-letter codes (`(en)`,
`(ru)`) render as parsed. A supplement rendered with `with_edition: true`
always uses the 2-letter form.

## Harmonized stage mapping

ISO harmonized stage codes map to abbreviations per document type. The tables
below are the v2 registry — `TYPED_STAGES` on each identifier class
(`lib/pubid/iso/identifiers/`), queryable at runtime with
`Pubid::Iso.locate_stage(name)`.

International Standard (`Identifiers::InternationalStandard`):

| Harmonized codes | Abbreviation | Name |
|------------------|--------------|------|
| `00.00`–`00.99` | `PWI` | Proposed Work Item |
| `10.00`–`10.98` | `NP` / `NWIP` | New Work Item Proposal |
| `10.99`–`20.00` | `AWI` | Approved Work Item |
| `20.20`–`20.99` | `WD` | Working Draft |
| `29.00`–`29.99` | `PreCD` / `preCD` | Pre-Committee Draft (code 29 — not an International Harmonized Code) |
| `30.00`–`30.99` | `CD` | Committee Draft (also `FCD` at the same range) |
| `40.00`–`40.99` | `DIS` / `FPD` | Draft International Standard |
| `50.00`–`50.99` | `FDIS` | Final Draft International Standard |
| `60.00` | `PRF` / `Fpr` | Proof (pre-publication) |
| `60.60` | *(empty)* / `IS` | published — no stage abbreviation is printed |

Technical Report / Technical Specification: the same ladder with the type
appended, and **no DIS/FDIS stage** — TRs and TSs are not International
Standards, so stage 40/50 use the draft typed abbreviations instead:

| Harmonized codes | TR | TS |
|------------------|----|----|
| `00.00`–`00.99` | `PWI TR` | `PWI TS` |
| `10.00`–`10.98` | `NP TR` | `NP TS` |
| `10.99`–`20.00` | `AWI TR` | `AWI TS` |
| `20.20`–`20.99` | `WD TR` | `WD TS` |
| `30.00`–`30.99` | `CD TR`, `PDTR` (legacy) | `CD TS` / `CDTS`, `PDTS` (legacy) |
| `40.00`–`40.99` | `DTR` / `DIS TR` | `DTS` |
| `50.00`–`50.99` | `FDTR` / `FDIS TR` | `FDTS` |
| `60.00` | `PRF TR` | `PRF TS` |
| `60.60` | `TR` | `TS` |

Amendment:

| Harmonized codes | Abbreviation |
|------------------|--------------|
| `00.00`–`00.99` | `{base}/PWI Amd {num}` |
| `10.00`–`10.98` | `{base}/NP Amd {num}` |
| `10.99`–`20.00` | `{base}/AWI Amd {num}` |
| `20.20`–`20.99` | `{base}/WD Amd {num}` |
| `30.00`–`30.99` | `{base}/CD Amd {num}` (legacy `PDAM`) |
| `40.00`–`40.99` | `{base}/DAM {num}` |
| `50.00`–`50.99` | `{base}/FDAM {num}` (legacy `FPDAM`) |
| `60.00` | `{base}/PRF Amd {num}` |
| `60.60` | `{base}/Amd {num}` |

Technical Corrigendum:

| Harmonized codes | Abbreviation |
|------------------|--------------|
| `00.00`–`00.99` | `{base}/PWI Cor {num}` |
| `10.00`–`10.98` | `{base}/NP Cor {num}` |
| `10.99`–`20.00` | `{base}/AWI Cor {num}` |
| `20.20`–`20.99` | `{base}/WD Cor {num}` |
| `30.00`–`30.99` | `{base}/CD Cor {num}` (legacy `pDCOR`) |
| `40.00`–`40.99` | `{base}/DCor {num}` (short `DCOR`) |
| `50.00`–`50.99` | `{base}/FDCor {num}` (short `FDCOR`) |
| `60.00` | `{base}/PRF Cor {num}` |
| `60.60` | `{base}/Cor {num}` |

(The historic v1 spellings `DAmd`, `FDAmd`, `DIS Cor`, `FDCor` parse and
canonicalize — see the section above.)

When the publisher element contains a slash, the separator in front of the
stage becomes a space: `ISO/NP 33333` but `ISO/IEC NP 33333`; `ISO/NP TR
33333` but `ISO/IEC NP TR 33333`.

## Stage iteration

Per ISO Directives Part 1 (11ed), SE.2, successive DIS ballots on the same
subject carry the same number with a numerical suffix. In an ISO PubID the
iteration is applied to the document number — `{stage} {number}` when the
iteration is 1, `{stage} {number}.{iteration}` when larger:

```ruby
Pubid::Iso.parse("ISO/CD TR 10064-2.2").to_s  # => "ISO/CD TR 10064-2.2"
Pubid::Iso.parse("ISO/DIS 80369-3.2").to_s    # => "ISO/DIS 80369-3.2"
```

Once the document is published (stage 60, substage 60) no stage abbreviation
is given and iterations no longer apply.

## Typed stage queries

The v1 read API (`typed_stage_abbrev` / `typed_stage_name` on the
identifier) is historic. In v2 the identifier exposes its `typed_stage`
object, and the registry answers lookups:

```ruby
id = Pubid::Iso.parse("ISO/FDIS 26000:2010")
id.typed_stage.abbreviation  # => "FDIS"
id.typed_stage.name          # => "Final Draft International Standard"

id = Pubid::Iso.parse("ISO/FDTR 26000:2010")
id.typed_stage.abbreviation  # => "FDTR"
id.typed_stage.name          # => "Final Draft Technical Report"

id = Pubid::Iso.parse("ISO/WD TR 26000:2010")
id.typed_stage.abbreviation  # => "WD TR"
id.typed_stage.name          # => "Working Draft Technical Report"

Pubid::Iso.locate_stage("FDTR").harmonized_stages
# => ["50.00", "50.20", "50.60", "50.92", "50.98", "50.99"]
```

## Root identifier

`#root` returns the base document for supplement chains and the identifier
itself for plain documents:

```ruby
Pubid::Iso.parse("ISO/WD TR 26000:2010").root.to_s   # => "ISO/WD TR 26000:2010"
Pubid::Iso.parse("ISO 10231:2003/Amd 1:2015").root.to_s
# => "ISO 10231:2003"
Pubid::Iso.parse("ISO/IEC 13818-1:2015/Amd 3:2016/Cor 1:2017").root.to_s
# => "ISO/IEC 13818-1:2015"
```

## Full PubID patterns

International Standard:
`{publisher} [/{stage}] {number}[-{part}][:{year}][({language})]` —
`ISO/IEEE/FDIS 33333-2`, `ISO/IEEE 33333-2:2030(E)`

Technical Report / Technical Specification (stage abbreviation always carries
the type): `ISO/TR 33333-2:2030(E)`, `ISO/IEC TR 33333-2:2030(E)`

Amendment / Technical Corrigendum (base ID first, supplement after the slash):
`{base document ID}/{stage} {update number}[:{year}][({language})]` —
`ISO 33333-2:2030/DIS Cor 2:2031` (historic spelling; v2 renders
`{base}/DCor 2:2031`), `ISO 33333-2:2030/Cor 2:2032`,
`ISO/IEC 33333-2:2030/Cor 2:2032`
