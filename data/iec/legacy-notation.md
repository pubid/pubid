# IEC legacy notation — old faces, modern counterparts, and the DAM family

**Status: DRAFT for the owner's ruling (2026-11-12). Research only — no
grammar, builder, or fixture change is proposed here.** Companion to
`data/iec/stage-codes.md` (same precedent: provenance, sources, tables,
reconciliation with the pubid registry).

The owner's refined ruling holds that the base-less publisher-slash input
`IEC/FDAM 60038-1` is not garbage to reject: it is the **old face** of
`IEC 60038-1/FDAM 1`, the way old ISO printed parts with a slash and years
with a dash before the modern `-part` / `:year` convention settled. This
document collects the evidence for that mapping, the exact behaviour of the
current model, the gaps, and the disposition options.

## Sources (all local; the IEC site is WAF-gated and yields no identifier-format examples)

| Source | What it evidences | Freshest state used |
|---|---|---|
| `pubid-iec` **1.15.21** installed gem (the v1 reference implementation; parslet grammar `lib/pubid/iec/parser.rb`) | the historical grammar's treatment of every face probed below | probed live 2026-11-12 |
| `relaton-data-iec` (33k records; local clone, main @ `04a8dc449` "update documents") | the real stored docidentifiers and the serialized shapes the consumer reads | 2026-11-12 |
| `relaton-data-iso` (local clone) | the modern stored docidentifiers of the joint (ISO/IEC) documents behind the owner-cited forms | 2026-11-12 |
| pubid `main` @ `be6a43c2` (2.0.21) — `grammars/iec.parg` edition-2 artifact, builder, `SupplementIdentifier#ensure_base` | the current decode of every face probed below | probed live 2026-11-12 |
| `spec/fixtures/iec/**` (full 12,534 inputs, pass/ and fail/ mined raw) | what the corpus pins | 2026-11-12 |
| `IEC-ISO Harmonized APIs` v0.0.8 (2023-06) / v0.0.7 (2021-05) PDFs | stage codes only (see `stage-codes.md`); **no identifier-format examples** | 2026-10-22 extract |

Historical background (not locally citable — needs the owner's citation if
this doc ships): IEC moved onto the 60000–69999 namespace in 1997 under the
ISO/IEC agreement; old `IEC 68` became `IEC 60068` (number += 60000, parts
unchanged).

## 1. Old IEC numbering (the 60000-namespace move)

- **Fixtures:** `spec/fixtures/iec/**` carries **zero** old-number inputs
  (`IEC 68`, `IEC 65`, `IEC 68-1` … appear nowhere in full/, pass/ or fail/).
  The only sub-1000 numbers in the fixtures are joint ISO/IEC documents
  (`ISO/IEC 9594-*`, `ISO/IEC 9075-*`, `ISO/IEC 9899`, `ISO/IEC 8825-*`),
  which are ISO-side numbers and were never IEC-old numbers.
- **v1 gem:** old numbers parse and render round-trip: `IEC 68:1980` →
  `IEC 68:1980`, `IEC 68-1:1988` → number `68`, part `1`.
- **pubid 2 (current):** identical — `IEC 68:1980` → number `68`,
  `IEC 68-1:1988` → number `68` part `1`. Old numbers still parse; there is
  no 60000-offset inference anywhere in either implementation.
- **relaton-data-iec:** the crawler stores the **modern** number even for
  pre-1997 editions — `data/iec-60068-1-1960.yaml` is stored as
  `IEC 60068-1:1960` (1960 edition, modern number). Exactly one short-number
  file exists (`iec-112-2021.yaml`, a genuinely modern number). **No record
  carries an old number; the old→new mapping is never encoded in the corpus** —
  the crawler resolved designations to the modern namespace at crawl time.
- Parts: old `IEC 68-1` style == modern `IEC 60068-1` style; the part
  separator was already `-` on both sides of 1997. No `IEC 68/1` slash-part
  face exists in any local source.

## 2. The old supplement faces and the DAM family

### 2.1 The JTC1/ISO-style prefix face (the DAM family)

The letters **DAM / PDAM / FDAM / FPDAM** (Draft / Proposed Draft / Final
Draft / Final Proposed Draft Amendment) are JTC1 ballot faces: the type
token (with its amendment number) is printed **before** the base
designation.

Owner's rule under verification: **DAM/PDAM/FDAM/FPDAM without a number
means Amendment 1.**

Evidence:

- **relaton-data-iec, exhaustive scan:** across all 32,835 records the
  letters PDAM/FPDAM/FDAM appear in **exactly one file**
  (`iso-iec-21000-14-2007.yaml`) — a **joint** record, and only inside an
  abstract that cites sibling drafts (`ISO/IEC 21000-4:2006/FPDAM 1`,
  `ISO/IEC 21000-5:2004/FDAM 2`) — never in a docidentifier. Word-bounded
  bare `DAM`: **zero occurrences**. **IEC-only records never use the DAM
  letters.** The DAM family is JTC1/ISO ballot vocabulary that rides only on
  joint (and pure-ISO) work; IEC's own catalogue never printed it.
- **"No number means Amendment 1":** consistent with the joint corpus —
  `ISO/IEC PDAM 12207` names the ballot that became
  `ISO/IEC 12207:1995/Amd 1:2002` (the first amendment; stored docidentifier
  in relaton-data-iso). Every one of the 7,366 published supplement records
  in relaton-data-iec (4,923 AMD + 2,306 COR + 137 ISH) carries its **own
  number** (`number: '1'` …), so the published corpus never contradicts the
  rule; the numberless face exists only at ballot time.
- **v1 gem:** the prefix face was never decoded — `IEC/FDAM 1 60038-1:2004`
  raised, and the joint forms "parsed" only by the catch-all number rule
  swallowing the tokens whole (`ISO/IEC FDAM 1 14496-12:2004` → number
  `"FDAM 1 14496-12"`, type `:is`) — a mangle, not a decode.
- **pubid 2 (current):** the prefix face raises in both the iec and iso
  flavors (see the coverage table).

### 2.2 IEC's own historical amendment faces

The stored docidentifiers of real IEC amendments are uniformly the modern
on-base slash form, with the base designation whole and the supplement
numbered: `IEC 60038:1983/AMD1:1994`, `IEC 60038:2009/AMD1:2021`,
`CISPR 1:1961/AMD1:1967`, chained `ISO/IEC 9075-1:1999/Amd 1:2001/Cor 1:2003`
(relaton-data-iso), consolidated `+AMD1:1994+AMD2:1997` (file
`iec-60038-1983+amd1-1994+amd2-1997-csv.yaml`), titles "Amendment 1".
**No IEC-only record carries a numberless supplement** (checked across all
7,366 supplement rows).

### 2.3 The publisher-slash face `IEC/FDAM 60038-1`

- **v1 gem (1.15.21):** the face **did not parse at all** —
  `IEC/FDAM 60038-1`, `IEC/DCOR 60038-1`, `IEC/DISH 60038-1`,
  `IEC/CD 60038`, `IEC/FDIS 60038` all raised `ParseError`. v1's
  `std_document_body` accepted `( "/" | space ) >> type` for **types**
  (TS/TR/PAS/GUIDE: `IEC/TS 80000-1` parsed, `IEC CD 60038` parsed), but
  FDAM/DCOR/DISH/CD are **stage** abbreviations, not types, so the slash
  forms never reached a rule. The space-stage forms were mangled in v1
  (`IEC FDAM 60038-1` → number `"FDAM 60038-1"`, type `:is`;
  `IEC DISH 60038-1` → `/DISH60038`).
- **pubid 2 (current):** the `standalone_supplement` grammar rule accepts
  `publisher / TYPE number` for **any** table token and `#ensure_base`
  resolves it. See §3 for the resolution — which is the load-bearing finding.
- **relaton-data-iec:** **zero** docidentifiers of this shape (the pattern
  `IEC/FDAM`-family or any `ORG/STAGE number` face: 0 of 32,835). The face
  exists in no real record.

### 2.4 The old dotted on-base spelling `/Amd.1`

`IEC 60068-1:1988/Amd.1:1992` raises in **both** v1 and pubid 2. The dotted
spelling (real on ISO covers, and inside IEC abstracts citing joint work,
e.g. `ISO/IEC 21000-5:2004/Amd.1:2007`) was never accepted by the IEC
flavor. ISO flavor accepts it; IEC does not. Recorded as a gap, not chased
here.

## 3. How the current model resolves the old face (the load-bearing answer)

Probed on `main` @ `be6a43c2` (2.0.21):

| Input | base in to_hash | supplement own fields | to_s |
|---|---|---|---|
| `IEC/FDAM 60038-1` | `{"number" => "60038"}` | `{"stage"=>"fdamd", "number"=>"1"}` | `IEC FDAM 60038-1` |
| `IEC FDAM 60038-1` | `{"number" => "60038"}` | `{"stage"=>"fdamd", "number"=>"1"}` | `IEC FDAM 60038-1` |
| `IEC 60038-1/FDAM 1` (modern) | `{"number" => "60038", "part" => "1"}` | `{"stage"=>"fdamd", "number"=>"1"}` | `IEC 60038-1/FDAM1` |
| `IEC 60038-1/FDAM1:2021` | `{"number" => "60038", "part" => "1"}` | `stage fdamd, number 1, year 2021` | `IEC 60038-1/FDAM1:2021` |
| `IEC 60038:2009/AMD1:2014` | `{"number" => "60038", "year" => "2009"}` | `number 1, year 2014` | unchanged |

**The current model resolves the old form to "base 60038 with FDAM number
1": the bound hash captures `supp_number_with_part = "60038-1"`, the
builder splits it into number `60038` + part `1` on the supplement, and
`SupplementIdentifier#ensure_base` moves `@number` onto the synthetic base
while `@part` becomes the supplement's own number.** The base loses its
part; the "1" migrates into the supplement slot.

**Under the owner's reading this is wrong.** The old face names **FDAM of
60038-1**: the whole `60038-1` is the base designation, the type token is
unnumbered (→ Amendment 1 per the DAM rule), and the modern counterpart is
`IEC 60038-1/FDAM 1` — where the printed "1" after FDAM is the supplement
number the old face left implicit. The two faces must decode to the same
identifier, and today they do not (the space form of the old face and the
modern on-base form disagree on where the `1` lives — `{"number" => "60038"}`
vs `{"number" => "60038", "part" => "1"}`).

Note this correction touches the **space form too** (`IEC FDAM 60038-1`
would re-resolve to base 60038-1), and with it the #693-era equality work
and the six fixtures in `full/iec-pubid.txt` (rows 2195–2200) plus the
three normalization pairs the testsuite mirror carries (`FDAM/DCOR/DISH
60038-1`). The render would move from `IEC FDAM 60038-1` to the modern
on-base face (`IEC 60038-1/FDAM…` spelling per the ruling) or keep the old
render as a facet — an owner call (see §5).

## 4. Coverage table — the owner-cited forms (I own the ISO/IEC joint rows)

"Decode" = parses today under the current grammar, either flavor
(`Pubid::Iec.parse` / `Pubid::Iso.parse`; `ISO/IEC` routes to both via
`JOINT_PREFIXES`). Modern target = the stored docidentifier of the same
document in the joint corpus, where one exists.

| Input (historic face) | Decode today? | Historic identity (owner scheme) | Modern counterpart (evidence) |
|---|---|---|---|
| `ISO/IEC FDAM 1 14496-12:2004` | **no** (raises, both flavors) | FDAM **1** of base `14496-12:2004` | `ISO/IEC 14496-12:2005/Amd 1:2007` (corpus; the ballot predates the final edition year) |
| `ISO/IEC FDAM 19776-2:2005/Am1:2006` | **no** | FDAM (unnumbered → **1**) of base `19776-2:2005`, amendment already stamped `/Am1` on the base | `ISO/IEC 19776-2:2005/Amd 1:2008` (corpus) |
| `ISO/IEC FPDAM 10373-6/Amd 9:2001` | **no** | FPDAM (unnumbered → **9**, stated on-base) of base `10373-6` | `ISO/IEC 10373-6:2001/Amd N` family (corpus stores amd-1…7 of the 2001 edition) |
| `ISO/IEC FPDAM 9075/1` | **no** | FPDAM (unnumbered → **1**) of base `9075/1` — old slash-part spelling → base `9075-1` | `ISO/IEC 9075-1:1999/Amd 1:2001` (corpus) |
| `ISO/IEC 19772:2009/DAM 1:2019(E)` | **yes** (both flavors; on-base DAM) | DAM **1** of base `19772:2009` | none — the amendment died in ballot (corpus has only `Cor 1:2014`, then the 2020 edition) |
| `ISO/IEC PDAM 2 10646:2012` | **no** | PDAM **2** of base `10646:2012` | `ISO/IEC 10646:2012/Amd 1:2013` (corpus; Amd 2 followed) |
| `ISO/IEC PDAM TR 9573-11/Amd.1` | **no** | PDAM (unnumbered → **1**) of base `TR 9573-11`, amendment stamped on-base | TR amendment family (corpus: `iso-iec-tr-9573-11-*`) |
| `ISO/IEC PDAM 9541-1/Amd.4` | **no** | PDAM (unnumbered → **4**, stated on-base) of base `9541-1` | `ISO/IEC 9541-1:1991/Amd 4:2009` (corpus) |
| `ISO/IEC PDAM 12207` | **no** | PDAM (unnumbered → **1**) of base `12207` | `ISO/IEC 12207:1995/Amd 1:2002` (corpus) |

Pure-ISO rows of the owner's list (`ISO/FDAM 19119:2005/Amd.1`,
`ISO/PDAM 19110:2005/Amd.1`, `ISO 15877-5:2009 FDAM 1`, `ISO/PDAM 19973-2`)
belong to the ISO-side study; the DAM-letter evidence in §2.1 covers them
symmetrically (zero IEC-only usage).

Cross-cutting: the **on-base** DAM form already decodes (`19772` row) via
the same grammar branch as `/AMD1` — only the **prefix** (type-before-base)
faces and the old slash-part spelling are gaps.

## 5. Gap list (current grammar/model vs the historic scheme)

1. **Prefix supplement faces raise**: `[P|F]?DAM [N] BASE` — no rule in
   `grammars/iec.parg` (joint or IEC-only; both flavors raise). Historic
   face per the owner's scheme; zero published corpus occurrences
   (ballot-time only), so the blast radius is inputs typed by humans, not
   stored records.
2. **The old publisher-slash face mis-resolves**: `IEC/FDAM 60038-1` /
   `IEC FDAM 60038-1` put the base's part into the supplement's number
   (§3). The modern and old faces disagree on the same document's identity.
3. **Old slash-part spelling** (`9075/1`): never handled by either
   implementation; the owner's ISO analogy places it in the same
   historic-notation family.
4. **Dotted on-base `/Amd.1`**: raises in the IEC flavor (both
   implementations); ISO accepts it. Abstracts of joint records cite the
   dotted spelling.
5. **No old-number ↔ 60000-mapping knowledge** in either implementation:
   old numbers parse as opaque numbers (`IEC 68` stays `68`); the corpus
   never needs the mapping (crawler resolved at crawl time).

## 6. Disposition options (two house precedents) and recommendation

**Option A — ISO `original_abbr` spelling-facet style** (root CLAUDE.md,
"Spelling is not identity"): parse the historic face, store the modern
identity, keep the input's spelling as an `equality_ignored` facet so
`to_s` can reproduce it. Fits when both spellings live in the wild and
round-tripping the input spelling matters. Cost: a facet on
`TypedStage`/supplement components plus render plumbing in both flavors.

**Option B — IHO legacy-decode-to-modern style** (the IHO edition ruling):
decode the legacy face straight to the modern canonical identity, no
spelling kept. Fits when the legacy face is a ballot/era artefact that the
modern catalogue never stores. Cost: grammar decode + the identity
correction of §3; render emits the modern face.

**Option C — drop**: keep raising on the prefix faces and leave the
publisher-slash face as #693 left it. Contradicts the refined ruling.

**Recommendation: B, with one owner call.** The DAM-family faces and the
old slash-part spelling are ballot-era artefacts with **zero** published
corpus occurrences (measured above), so a spelling facet (A) buys nothing
for matching; decode-to-modern gives one identity per document. The decode
rule: `[P|F]?DAM [N] BASE` → supplement (P|F)DAM, number `N` defaulting to
**1** (the owner's rule), base designation kept **whole** (parts and
slash-parts resolved per the modern separator convention). The owner call:
whether the already-accepted faces (`IEC/FDAM 60038-1`, the on-base
`/AMD1`, the dotted `/Amd.1`) also move to the corrected base-whole
resolution — §3 shows the space form shares the defect, so the correction
cannot be scoped to the slash form alone. This doc records the evidence
for that decision; no implementation is proposed until the owner rules.
