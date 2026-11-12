# ISO historic identifier schemes — old faces, modern counterparts, and the DAM family

**Status: IMPLEMENTED — the owner ruled Option B (decode-to-modern) for the
TYPE-first ballot faces and `Am1` on 2026-11-12 (this branch carries the
ruling). §1–§8 are the study as committed on `study/iso-historic-schemes`
(92befebe); §9 records the implementation, the replay/corpus gates, and the
per-anchor stored-twin verification, and corrects two study findings
(§9.1).** Companion to `data/iec/legacy-notation.md` (the IEC-side study;
that doc owns the ISO/IEC joint rows' cross-check and the IEC-only faces)
and to `data/iec/stage-codes.md` (the house precedent for
committed-provenance reference documents). This document owns the
**pure-ISO** rows of the owner's anchor list and the ISO-wide scheme
history.

## Provenance (all sources local; iso.org serves 403 to non-browser clients and yields no fetchable evidence)

| Source | What it evidences | State used |
|---|---|---|
| `relaton-data-iso` (fresh clone of git@github.com:relaton/relaton-data-iso, main @ `dd368d8de2` "update documents", crawl state 2026-11-12) | the real stored docidentifier faces; 80,202 record files; 200,189 distinct ISO-prefixed docidentifier face strings (primary + `iso-undated` + `iso-reference` variants) | grepped + bulk-probed 2026-11-12 |
| same repo, history deepened to 560 commits (`git fetch --deepen=500`) | whether historic faces EVER occurred in stored docidentifiers; when normalized away | `git log --all -S` 2026-11-12 |
| pubid `main` @ `be6a43c2` (2.0.21) — `data/parg/iso.parg` edition-2 artifact, `typed_stages` (115 rows) and `typed_stages_supplements` (64 rows) tables, builder, live probes | the current decode of every face probed below, and the two-position token split | probed live 2026-11-12 |
| `pubid-iso` **1.15.21** installed gem (the v1 reference implementation; parslet grammar `lib/pubid/iso/parser.rb`, stage ladders in `identifier/{amendment,corrigendum,supplement,addendum}.rb`) | the historical grammar's treatment; the v1 ladder that folded FPDAM into DAM | probed live 2026-11-12 |
| `spec/fixtures/iso/identifiers/{full,pass,fail}` (the 7,650-input corpus; classification identical to `pubid-testsuite/reference-docs/iso/SUMMARY.txt`: 7,647 pass / 3 fail, none DAM-related) | what the curated corpus pins | read 2026-11-12 |
| `data/iso/update_codes.yaml` | the pre-parse normalizations already shipped for legacy faces (`ISO/R 657/IV` → `ISO/R 657-4:1969`; `DIS Amd` → `DAM`; `FDIS Amd` → `FDAM`) | read 2026-11-12 |
| `references/iso-urn-specification.adoc` (house URN spec, RFC 5141-bis draft) | the stage-label table (40.00 = DIS/DAM, 50.00 = FDIS/FDAM per ISO Guide 69:1999) and the "legacy abbreviations accepted on parse, never emitted" rule | read 2026-11-12 |
| iso.org catalogue pages (the plausible origin of the owner-cited TYPE-first ballot faces) | **not locally verifiable** — `https://www.iso.org` returns 403 (curl, 2026-11-12); Wayback not attempted (rate-limited host, and the owner's citations stand in) | — |

## 1. Scheme eras

| Era | Printed face | Evidence |
|---|---|---|
| ISO/R Recommendations (1951–1972) | `ISO/R 185:1961`, parts `ISO/R 105-1`, roman-numeral part `ISO/R 657/IV` | 1,734 `iso-r-*` records in relaton-data-iso, all stored modernized (`ISO/R 185:1961/Amd 1:1969`); the roman-numeral slash-part only survives as an `update_codes.yaml` rewrite (`ISO/R 657/IV` → `ISO/R 657-4:1969`) |
| ISO (1972–) | `ISO 1234`, parts `-N` modern; old printed parts with `/N` (`ISO 9075/1`) | slash-part face: **0 occurrences in any stored docidentifier** (current + 560-commit history), yet the grammar carries it as a first-class branch (`part_legacy_body = slash [space] !supp_stage_abbrev 1*word_digit`, `data/parg/iso.parg:79`) and normalizes: `ISO 9075/1` → `ISO 9075-1`, `ISO/IEC FDIS 9075/1` → `ISO/IEC FDIS 9075-1` |
| Supplement attachment | modern `base/Amd 1:2005` | every stored supplement record — published (3,790 `-amd-N` files) and ballot (835 `-dam`, 313 `-pdam`, 194 `-fdam`) — is base-first with a slash |
| Ballot faces (iso.org pages, not stored) | TYPE-first: `ISO/IEC FDAM 1 14496-12:2004` | owner-cited; **zero** occurrences in relaton-data-iso (current **and** 560-commit history, `git log -S` on all nine owner forms) |

The part separator `/` → `-` and year separator `-` → `:` flips are
accepted-on-parse today ("legacy" branches in the grammar): `ISO 1234-1988`
→ `ISO 1234:1988` (parg `date = (colon / dash)`, comment "legacy dash form");
Unicode dashes (`‑` `‐`) accepted for parts.

## 2. The DAM-family letter ladder

The letters are ISO/JTC1 ballot-stage faces of an amendment project. The
house URN spec (`references/iso-urn-specification.adoc`, per ISO Guide
69:1999) fixes the semantics: the label is a function of (deliverable
type, stage code) — 40.00 is DIS for an IS project and DAM for an
amendment project; 50.00 is FDIS / FDAM / FDTS.

| Letters | Full name | Stage (pubid ladder) | relaton-data-iso records | URN stage codes carried (whole-corpus grep of those records) | Occurs in stored primary docidentifier? |
|---|---|---|---|---|---|
| PDAM | Proposed Draft Amendment | 30.00–30.99 (`pdam`) | 313 files (**308 joint ISO/IEC**, 5 pure-ISO) | 40.00 ×204, 30.00 ×109 | yes — `ISO 8485:1989/PDAM 1`, `ISO/IEC TR 9573-11:2004/PDAM 1` |
| DAM | Draft Amendment | 40.00–40.99 (`damd`) | 835 files (246 joint) | 40.00 ×834, 30.00 ×2 | yes — `ISO 10140-3:2010/DAM 2` |
| FDAM | Final Draft Amendment | 50.00–50.99 (`fdamd`) | 194 files (69 joint) | 50.00 ×194 | yes — `ISO 10328:2006/FDAM 1` |
| FPDAM | Final Proposed Draft Amendment | 50.00–50.99 (`fpdam`) | **0 files** | — | no (appears once, inside one abstract: `iso-iec-21000-14-2007.yaml`) |

- v1 (pubid-iso 1.15.21) folded FPDAM into `damd` as a legacy abbreviation
  (`amendment.rb`: `damd: {abbr: "DAM", legacy_abbr: ["DAmd", "FPDAM"]}`,
  harmonized 40.xx). pubid 2 gives FPDAM its own `fpdam` stage entry at
  50.00–50.99. The drift is v1-only history; no stored record pins either
  choice (FPDAM: zero stored records).
- DAM-family is overwhelmingly joint vocabulary on the PDAM side (98% of
  PDAM records are ISO/IEC); pure-ISO DAM/FDAM records are plentiful.
  *(joint-row cross-check for the IEC study.)*
- `update_codes.yaml` already normalizes the long-form spellings
  (`DIS Amd` → `DAM`, `FDIS Amd` → `FDAM`), i.e. the DAM face IS the
  short form of the DIS/FDIS-stage amendment.

## 3. Historic → current face mapping (ISO)

| # | Historic face | Example | Today's decode | Status today |
|---|---|---|---|---|
| 1 | Old part separator `/` | `ISO 9075/1`, `ISO/R 657/IV` | part `9075-1`; roman → `657-4:1969` (update_codes) | **accepted, normalized on render**; 0 stored occurrences |
| 2 | Old year separator `-` | `ISO 1234-1988` | `ISO 1234:1988` | accepted, normalized; 0 stored occurrences |
| 3 | Undated markers | `ISO 1234:--`, `ISO 1234:—` | `undated` flag | accepted |
| 4 | TYPE-first ballot face | `ISO/IEC FDAM 1 14496-12:2004`, `ISO/PDAM 19973-2` | — | **rejected** (see §5); 0 stored occurrences in 80,202 records / 560 commits |
| 5 | Space supplement face | `ISO 15877-5:2009 FDAM 1` | base 15877-5:2009 + FDAM 1 | **accepted**, renders `ISO 15877-5:2009/FDAM 1` |
| 6 | On-base slash numbered | `ISO 15877-5:2009/Amd 1:2010` | canonical amendment | accepted (canonical) |
| 7 | Glued number | `ISO 19776-2:2005/Amd1:2006`, `/AMD1` | `/Amd 1:2006` | accepted, rendered spaced |
| 8 | Dot spelling (old style) | `ISO 10993-4:2002/Amd.1:2006(E)`, `Cor.1` | `/Amd 1:2006(E)` (dot stored as `TypedStage#original_abbr` facet, not serialized; render emits `abbr.first` — for `Amd.` the facet selects short-vs-long only) | accepted |
| 9 | Uppercase spelling | `/AMD 1:1998`, `/COR 1:1995` | canonical `Amd`/`Cor` | accepted (30 `/AMD n` faces stored) |
| 10 | Legacy draft spellings | `/DAmd 1`, `/FDAmd 1`, `/pDCOR.2`, `/DAD 1`, `/DSuppl 1.2` | `DAM 1`, `FDAM 1`, `CD Cor 2`, DAD (Addendum 40.xx), DSuppl (Supplement 40.xx) | accepted |
| 11 | Long-form draft spellings | `/DIS Amd 1`, `/FDIS Amd 1` | `DAM 1`, `FDAM 1` (update_codes pre-parse) | accepted |
| 12 | `Am` spelling | `/Am1:2006` | — | **rejected** (`Am` absent from the 64-entry supplement table); 0 stored occurrences |
| 13 | ISO/R | `ISO/R 185:1961/Amd 1:1969` | ISO/R prefix + modern supplement | accepted (1,734 records) |
| 14 | ISO/R dash supplement | `ISO/R NNN — STAGE N` | grammar branch `iso_r_supplement_identifier` (separators `/`, ` — `, ` - `) | accepted by rule; **no fixture and no stored record exercises it** |

Where the legacy spellings survive in the corpus: only in **secondary**
positions — `relation → bibitem → formattedref` (DAmd: 600 files, FDAmd:
95 files) and abstract prose (`/Amd.1`: 14 files, e.g.
`ISO/IEC 21000-5:2004/Amd.1:2007`). Primary docidentifiers carry 0
DAmd/FDAmd/FPDAM/`Amd.` faces — the crawler normalized them.

## 4. The no-number rule (DAM-family with no number = Amendment 1)

Owner's rule under verification. Local evidence:

- **Direct stored evidence: none.** Across 80,202 records there is not a
  single numberless DAM-family face (`/(P|F)?DAM` not followed by a
  number: 0 in primary docidentifiers; 0 in relations; every one of the
  5,843 DAM-family docidentifier contents carries a number). Same for the
  fixture corpus: 0 numberless supplement faces in `full/`.
- **The rule is consistent with everything stored**: the owner-cited
  numberless ballots name documents whose FIRST amendment was published —
  `ISO/IEC PDAM 12207` → `ISO/IEC 12207:1995/Amd 1:2002` (stored,
  URN `amd:1`); `ISO/PDAM 19973-2` names a ballot of the undated
  `19973-2` base (the corpus has no published amendment of the 2007
  edition; the amendment path continues on the 2015 edition,
  `iso-19973-2-2015-amd-1-2019.yaml`).
- **Both grammars make the number optional** (parg
  `supplement_identifier_no_third`: the number branch is one of three
  `.maybe` tails; v1: `digits.as(:number).maybe`), and today
  `ISO 19973-2/PDAM` parses with `number` **nil** and renders
  `ISO 19973-2/PDAM` — no implied 1 anywhere.
- **Modeling decision if the rule is adopted**: an implied supplement
  number is identity-bearing (two amendments differ by number), so it
  belongs in the model as **number = "1" at build time** (a builder
  default when a DAM-family token carries no number), NOT as a
  render-time fallback — `to_hash` must agree between parse and
  `from_hash`, and relaton matching treats number as identity.

## 5. The owner-cited anchor forms — decode table

"Decode today?" = parses with `Pubid::Iso.parse` on `main` @ `be6a43c2`
(2.0.21). Joint rows (`ISO/IEC …`) are cross-checked against the IEC
study (`data/iec/legacy-notation.md` §4); pure-ISO rows are owned here.

| # | Input (historic face) | Joint? | Decode today | Historic identity | Stored counterpart (relaton-data-iso, file → primary face) |
|---|---|---|---|---|---|
| 1 | `ISO/IEC FDAM 1 14496-12:2004` | joint | **no** | FDAM **1** of base `14496-12:2004` | `iso-iec-14496-12-2004-fdam-1.yaml` → `ISO/IEC 14496-12:2004/FDAM 1` (URN `stage-50.00:amd:1`); published as `ISO/IEC 14496-12:2005/Amd 1:2007` |
| 2 | `ISO/IEC FDAM 19776-2:2005/Am1:2006` | joint | **no** | FDAM (unnumbered → **1**) of base `19776-2:2005`; `/Am1:2006` = the on-base stamp in the `Am` spelling (amendment 1, year 2006) | `iso-iec-19776-2-2005-amd-1-2008.yaml` → `ISO/IEC 19776-2:2005/Amd 1:2008` |
| 3 | `ISO/IEC FPDAM 10373-6/Amd 9:2001` | joint | **no** | FPDAM (unnumbered) of base `10373-6`; on-base `Amd 9:2001` carries the number → **9** | `iso-iec-10373-6-2001-dam-9.yaml` → `ISO/IEC 10373-6:2001/DAM 9` (URN `stage-40.00:amd:9`) — the same ballot stored as DAM, not FPDAM (website face vs stored face drift) |
| 4 | `ISO/IEC FPDAM 9075/1` | joint | **no** | FPDAM (unnumbered → **1**) of base `9075/1` — old slash-part → `9075-1` | `iso-iec-9075-1-1999-amd-1-2001.yaml` → `ISO/IEC 9075-1:1999/Amd 1:2001` |
| 5 | `ISO/IEC 19772:2009/DAM 1:2019(E)` | joint | **yes** (both flavors) | DAM **1** of base `19772:2009` | `iso-iec-19772-2009-dam-1.yaml` → identical face (URN `stage-40.00:amd:1`); the amendment died in ballot (2020 edition published instead) |
| 6 | `ISO/FDAM 19119:2005/Amd.1` | pure ISO | **no** | FDAM of base `19119:2005`; on-base dot spelling → amendment **1** | `iso-19119-2005-amd-1-2008.yaml` → `ISO 19119:2005/Amd 1:2008` |
| 7 | `ISO/PDAM 19110:2005/Amd.1` | pure ISO | **no** | PDAM of base `19110:2005`; on-base → amendment **1** | `iso-19110-2005-amd-1-2011.yaml` → `ISO 19110:2005/Amd 1:2011` |
| 8 | `ISO 15877-5:2009 FDAM 1` | pure ISO | **yes** | FDAM **1** of base `15877-5:2009`, space attachment | renders `ISO 15877-5:2009/FDAM 1`; published as `ISO 15877-5:2009/Amd 1:2010` (`iso-15877-5-2009-amd-1-2010.yaml`) |
| 9 | `ISO/PDAM 19973-2` | pure ISO | **no** | PDAM, **no number anywhere → Amendment 1** (owner rule), base `19973-2` undated | no amendment record of the 2007 edition; path continues `iso-19973-2-2015-amd-1-2019.yaml` |
| 10 | `ISO/IEC PDAM TR 9573-11/Amd.1` | joint | **no** | PDAM of base `TR 9573-11`; on-base → amendment **1** | `iso-iec-tr-9573-11-2004-pdam-1.yaml` → `ISO/IEC TR 9573-11:2004/PDAM 1` (URN `stage-30.00:amd:1`) |
| 11 | `ISO/IEC PDAM 9541-1/Amd.4` | joint | **no** | PDAM of base `9541-1`; on-base → amendment **4** | `iso-iec-9541-1-1991-amd-4-2009.yaml` → `ISO/IEC 9541-1:1991/Amd 4:2009` |
| 12 | `ISO/IEC PDAM 2 10646:2012` | joint | **no** | PDAM **2** (number on the TYPE token) of base `10646:2012` | `iso-iec-10646-2012-amd-1-2013.yaml` → `ISO/IEC 10646:2012/Amd 1:2013`; the same ballot's FDAM round is stored: `iso-iec-10646-2012-fdam-2.yaml` → `ISO/IEC 10646:2012/FDAM 2` |
| 13 | `ISO/IEC PDAM 12207` | joint | **no** | PDAM, **no number → Amendment 1**, base `12207` undated | `iso-iec-12207-1995-amd-1-2002.yaml` → `ISO/IEC 12207:1995/Amd 1:2002` |

Score: **11 of 13 rejected today** (2, 3, 4 because of BOTH the TYPE-first
face and the on-base stamps; 10, 11 because of the TYPE-first face — their
on-base stamps alone would parse); the two that parse are the
modern-shape rows (5 on-base DAM, 8 space FDAM).

The TYPE-first faces come in three sub-shapes the decode must cover:

- (a) number on the TYPE token: `FDAM 1 14496-12:2004`, `PDAM 2 10646:2012`
- (b) number on the base stamp: `FDAM 19776-2:2005/Am1:2006`,
  `FPDAM 10373-6/Amd 9:2001`, `PDAM TR 9573-11/Amd.1`,
  `PDAM 9541-1/Amd.4`, `FDAM 19119:2005/Amd.1`, `PDAM 19110:2005/Amd.1`
- (c) no number at all: `PDAM 12207`, `PDAM 19973-2` (→ Amendment 1)

In (b) the number rides on-base and the stage token is bare — if the
builder takes the number from the on-base stamp, the DAM-family token
must not double-consume it (the current IEC-flavor behavior for
`IEC/FDAM 60038-1`, where the base's part migrates into the supplement
slot, is the analogous hazard documented in the IEC study §3).

## 6. Which of today's branches serve historic faces, and what today rejects

**Served (parse paths):** DAM-family exists ONLY in the
supplement-position table `typed_stages_supplements` (64 entries — PDAM,
DAM, DAmd, FDAM, FDAmd, FPDAM, Amd/AMD/Amd., Cor/COR/Cor., DAD family,
DSuppl family, pDCOR, Ext). The TYPE-position table `typed_stages`
(115 entries) has **no DAM-family token** — `ISO/FDAM 19119:2005` raises
while `ISO/FDIS 19119:2005` parses. The supplement layer accepts three
number carriers: `[space] supplement_second_part` (numbered, incl. the
space face), `dot (1*digit)` (the `/Amd.1` dot face), and a date tail.
Legacy separators (`part_legacy_body` slash-part, dash-year) and ISO/R
are first-class branches.

**Rejection counts for historic faces (measured):**

- relaton-data-iso bulk probe: **200,188 of 200,189** distinct stored
  docidentifier faces parse with today's ISO flavor; the single failure
  is `ISO/NP TS 6041-_` (a corrupted trailing underscore, a data
  artifact, not a historic face). Today's grammar serves everything the
  crawler ever stored.
- The testsuite corpus (7,650 inputs, classification 2026-10-22): 3
  fails, none historic-DAM (`EN 12643:2014`, `ISO/IEC Directives, JTC 1
  Supplement:2021`, `CEN/TS 15370-1:2006` — misfiled and comma-form
  rows).
- **What history shipped that today rejects is exactly the ballot-page
  set**: the nine TYPE-first forms (zero stored occurrences — the
  rejection blast radius is human-typed input and iso.org page faces,
  not stored records) and the `Am1` spelling (0 stored occurrences).

## 7. Gap list (current grammar/model vs the historic scheme)

1. **TYPE-first DAM-family faces raise**: `[P|F]?DAM [N] BASE(/stamp?)` —
   no rule in `grammars`/parg for either sub-shape (a) or (b), and no
   implied-1 handling for (c). Both flavors raise (iso probed here, iec
   probed in the IEC study).
2. **`Am` spelling** (`/Am1:2006`) is not in the supplement table;
   rejected.
3. **No implied supplement number anywhere**: `ISO 19973-2/PDAM` stores
   `number = nil` and renders `ISO 19973-2/PDAM`; under the owner's rule
   it should decode as Amendment 1.
4. **Slash-part and dash-year** are served as normalizing branches —
   nothing missing, recorded here so the mapping is committed.
5. **v1→v2 FPDAM stage drift** (40.xx vs 50.xx): zero stored records to
   arbitrate; the v2 ladder (50.00–50.99) matches the letters' meaning
   (Final PDAM) and the URN spec's 50.00 = FDAM row.

## 8. Disposition options and recommendation

**Option A — ISO `original_abbr` spelling-facet style**: parse historic
faces, store modern identity, keep input spelling as an
`equality_ignored` facet so `to_s` can reproduce it. Fits when both
spellings live in the wild and round-tripping matters. The house facet
plan (#674/#685) already does exactly this for `Amd.` vs `Amd`.

**Option B — IHO legacy-decode-to-modern style**: decode straight to the
modern canonical identity, no spelling kept; render emits the modern
face. Fits ballot/era artefacts the modern catalogue never stores.

**Option C — drop**: keep raising on TYPE-first faces.

**Recommendation: B for the TYPE-first ballot faces and `Am1`; the
existing facet machinery (A) stays for what it already covers.** The
TYPE-first faces and `Am1` have **zero** stored corpus occurrences
(measured above) — they are ballot-page/human-typed artefacts, so a
spelling facet buys nothing for matching, and decode-to-modern gives one
identity per document (`ISO/IEC FDAM 1 14496-12:2004` and
`ISO/IEC 14496-12:2004/FDAM 1` must be the SAME identifier; the corpus
file for that document already settles the target face). The decode
rule: `[P|F]?DAM [N] BASE [stamp]` → amendment with stage
(P|F)DAM-family, number taken from the TYPE token or the on-base stamp,
defaulting to **1** when neither carries one (owner's rule), base kept
whole. Where the on-base stamp carries the number, the builder must not
let the base's part migrate into the supplement slot (IEC study §3
hazard). Dot-spelling `/Amd.1` and `DAmd`/`FDAmd` stay exactly as they
are — already parsed, already faceted (#685), already rendering
canonical.

**Owner calls needed before any implementation:**
1. The no-number rule → implied number 1 at build time (§4 modeling).
2. Whether the already-accepted space face (`ISO 15877-5:2009 FDAM 1`)
   should keep rendering with the space (current) or normalize to the
   slash face; and whether `ISO/FDIS 9075/1`-style slash-part renders
   modern (`9075-1`, current) — both are normalization choices today,
   consistent with Option B's spirit.
3. FPDAM stage: keep the v2 ladder (50.00–50.99) or restore v1's
   fold-into-DAM (40.xx); the corpus cannot arbitrate (0 records).

## 9. Implementation (owner ruling 2026-11-12: Option B decode-to-modern)

The disposition: the TYPE-first ballot faces and the `Am` spelling decode
straight to the modern canonical identity — no spelling facet, one
identity per document; the existing facet machinery (Option A) stays for
what it already covers (`Amd.`/`AMD`). Option C (drop) is not taken.

### 9.1 Corrections to the study's findings (evidence found while implementing)

1. **The space-attached face does NOT parse today.** §3 row 5 / §5 row 8
   recorded `ISO 15877-5:2009 FDAM 1` as "accepted today"; it RAISES on
   `main` @ `c86928fc` (the grammar has no space-supplement branch for the
   DAM family). The anchor score is therefore **12 of 13 rejected today**,
   not 11 — only §5 row 5 (`ISO/IEC 19772:2009/DAM 1:2019(E)`, the on-base
   DAM face) parses. The space face is now served by the new
   base-first ballot branch.
2. **The 9075/1 ballot HAS a stored ballot record.** §5 row 4 listed only
   the published counterpart (`iso-iec-9075-1-1999-amd-1-2001.yaml` →
   `ISO/IEC 9075-1:1999/Amd 1:2001`). The corpus also holds
   `iso-iec-9075-1-1999-pdam-1.yaml` → `ISO/IEC 9075-1:1999/PDAM 1`
   (stage 30.00:amd:1) — the same amendment's ballot round, so the record
   of record for the FPDAM 9075/1 ballot face is PDAM 1: the website face's
   letters and the stored round disagree, the same drift §5 row 3 names.
3. **Engine observation (parsanol 1.3.126, PG semantics)**: in the
   supplements-table alt, the dot-bearing token (`Amd.`) wins over its
   bare sibling (`Amd`) for a `/Amd.1` stamp, so the dot-form stamp rides
   the number capture (`ballot_stamp_number`), not the dot-number capture —
   the pinned grammar example records the delivered capture.

### 9.2 What was built

- **pubid-grammar** (`grammars/iso.parg` v0.5.0, baked at the CI pin
  parsanol 1.3.126 / ruby 3.4.8; artifact, schema and corpus regenerated,
  iso files only):
  - `ballot_supplement_identifier` — TYPE-first:
    `prefix [slash] ballot-token [ballot_number] [base type_with_stage]
    second_part [ballot_stamp]`. `ballot_number` is space-bounded on both
    sides so `PDAM 19973-2` keeps 19973 in the base (the trailing space is
    mandatory; with no second space the group backtracks). The base is
    kept WHOLE — the legacy slash-part of `FPDAM 9075/1` stays a base part,
    the base's own type token (`PDAM TR 9573-11`) stays the base's; nothing
    migrates into the supplement slot (the §3 hazard of the IEC study).
    The on-base stamp's number/date capture as `ballot_stamp_*` while its
    token letters match uncaptured (decode-away).
  - `ballot_space_supplement_identifier` — base-first space attachment
    (`ISO 15877-5:2009 FDAM 1`). The base front is inlined, not reused from
    `supplement_base_no_third`, whose trailing `base_third_part_edition`
    would consume the separator space.
  - Both branches sit LAST in the identifier alternation — purely additive;
    an input an existing member parses keeps that exact parse.
  - `typed_stages_ballots` carries the ballot token set (PDAM, DAM, DAmd,
    FDAM, FDAmd, FPDAM) so the TYPE-first branch stays scoped to the ballot
    family. `Am` joined `typed_stages_supplements` (after the Amd entries).
- **pubid** (the builder is the decode):
  - `Builder#build_ballot_supplement` — ONE amendment layer over the whole
    base (the stored twins keep one level; never a second supplement
    layer). Stage from the ballot token; number precedence TYPE token →
    on-base stamp → implied **1**; the stamp's date becomes the ballot
    supplement's date.
  - `Builder#apply_implied_amendment_number` — the owner's no-number rule
    on every builder path (parse, URN, bundle members): a numberless
    DAM-family ballot-stage amendment (`typed_stage.code` ∈
    `{pdam, damd, fdamd, fpdam}` — by `#code`, not `#stage_code`) names
    Amendment 1. Identity-bearing: set at build time, serialized, so
    `parse == from_hash(to_hash)`. The published stage (`Amd`) is out of
    scope — a numberless `ISO 1234/Amd` keeps its nil number.
  - `Am` in the published stage's abbr list; `detect_stage_format_long`
    treats an original spelling that is a prefix of the long abbr as the
    long family, so `Am` renders canonical `Amd` while `AMD` keeps its
    short facet and `Amd.` keeps rendering `Amd` (unchanged).
- **pubid fixtures/specs**: `spec/fixtures/iso/identifiers/full/
  iso-pubid-ballot-faces.txt` (the 13 anchors + `Am` alias + numberless
  rows), `spec/pubid/iso/ballot_face_decode_spec.rb` (60 examples).

### 9.3 Gates

| Gate | Result |
|---|---|
| Fixture replay (baseline `c86928fc` vs branch, 15,307 inputs) | **0 diff lines** — `to_s`/`to_urn`/`to_hash`/`to_mr_string` byte-identical for every already-parsing input; pass/raise counts unchanged (15,303 / 4, none ballot-related) |
| Stored-corpus probe (213,414 distinct docidentifier faces greppped from the local relaton-data-iso clone @ dd368d8de2, superset of the §6 count) | **0 diff lines** baseline vs branch; 199,471 parse / 13,943 raise on both (the raise set is this probe's cruder extraction — abstract prose, secondary `formattedref` faces — identical both sides, so 0 changed identities) |
| Ballot faces | 12 raise→parse (all §5 rows but row 5); `Am1` accepted; the 3 pre-existing fail fixtures stay fail |
| Specs | `spec/pubid/iso/` 3,188 examples green, incl. the 60 new |

### 9.4 Per-anchor decode → stored-twin verification

Decode rule applied: stage from the ballot face's letters; number from the
TYPE token, else the on-base stamp, else implied 1; base kept whole. Where
the ballot face's letters and the stored record disagree, the disagreement
is recorded (drift), the stored record stays the identity of record.

| # | Input | Decode (render) | Stored twin (relaton-data-iso) | Verdict |
|---|---|---|---|---|
| 1 | `ISO/IEC FDAM 1 14496-12:2004` | `ISO/IEC 14496-12:2004/FDAM 1` (stage 50.00:amd:1) | `iso-iec-14496-12-2004-fdam-1.yaml` → `ISO/IEC 14496-12:2004/FDAM 1` | **EXACT** — face, stage, number, base+year all match |
| 2 | `ISO/IEC FDAM 19776-2:2005/Am1:2006` | `ISO/IEC 19776-2:2005/FDAM 1:2006` | `iso-iec-19776-2-2005-amd-1-2008.yaml` → `ISO/IEC 19776-2:2005/Amd 1:2008` | number 1 ✓, base ✓, ONE level both ✓; drift: ballot FDAM vs published Amd, ballot date 2006 vs published 2008 |
| 3 | `ISO/IEC FPDAM 10373-6/Amd 9:2001` | `ISO/IEC 10373-6/FPDAM 9:2001` | `iso-iec-10373-6-2001-dam-9.yaml` → `ISO/IEC 10373-6:2001/DAM 9` (stage 40.00:amd:9) | number 9 ✓, base+year ✓; drift: website FPDAM vs stored DAM (§5's named drift) |
| 4 | `ISO/IEC FPDAM 9075/1` | `ISO/IEC 9075-1/FPDAM 1` | ballot `iso-iec-9075-1-1999-pdam-1.yaml` → `ISO/IEC 9075-1:1999/PDAM 1`; published `…/amd-1-2001.yaml` → `ISO/IEC 9075-1:1999/Amd 1:2001` | part-in-base ✓ (9075-1), number 1 ✓; drift: website FPDAM vs stored PDAM ballot round (new evidence, §9.1.2) |
| 5 | `ISO/IEC 19772:2009/DAM 1:2019(E)` | unchanged (parses today) | `iso-iec-19772-2009-dam-1.yaml` → `ISO/IEC 19772:2009/DAM 1` | face matches; stored carries no supplement date/language |
| 6 | `ISO/FDAM 19119:2005/Amd.1` | `ISO 19119:2005/FDAM 1` | `iso-19119-2005-amd-1-2008.yaml` → `ISO 19119:2005/Amd 1:2008` | number 1 ✓, base+year ✓; drift: ballot FDAM vs published Amd, no ballot record stored |
| 7 | `ISO/PDAM 19110:2005/Amd.1` | `ISO 19110:2005/PDAM 1` | `iso-19110-2005-amd-1-2011.yaml` → `ISO 19110:2005/Amd 1:2011` | number 1 ✓, base+year ✓; drift: ballot PDAM vs published Amd |
| 8 | `ISO 15877-5:2009 FDAM 1` | `ISO 15877-5:2009/FDAM 1` | `iso-15877-5-2009-amd-1-2010.yaml` → `ISO 15877-5:2009/Amd 1:2010` (no ballot record stored) | number 1 ✓, base+year ✓; drift: ballot FDAM vs published Amd |
| 9 | `ISO/PDAM 19973-2` | `ISO 19973-2/PDAM 1` | **no twin** — no amendment record of the 2007 edition (path continues `iso-19973-2-2015-amd-1-2019.yaml`) | implied 1 per the owner rule (§4); undated base matches by partial reference |
| 10 | `ISO/IEC PDAM TR 9573-11/Amd.1` | `ISO/IEC TR 9573-11/PDAM 1` (stage 30.00:amd:1) | `iso-iec-tr-9573-11-2004-pdam-1.yaml` → `ISO/IEC TR 9573-11:2004/PDAM 1` | **stage + number + TR base all match**; base undated vs stored 2004 (partial-ref match) |
| 11 | `ISO/IEC PDAM 9541-1/Amd.4` | `ISO/IEC 9541-1/PDAM 4` | `iso-iec-9541-1-1991-amd-4-2009.yaml` → `ISO/IEC 9541-1:1991/Amd 4:2009` | number 4 ✓, base ✓; drift: ballot PDAM vs published Amd |
| 12 | `ISO/IEC PDAM 2 10646:2012` | `ISO/IEC 10646:2012/PDAM 2` | FDAM round stored: `iso-iec-10646-2012-fdam-2.yaml` → `ISO/IEC 10646:2012/FDAM 2` (also published `…/amd-1-2013.yaml` → `Amd 1:2013`) | number 2 ✓, base+year ✓; drift: ballot PDAM round vs stored FDAM round — the owner's §1 example pins the face letters (`/PDAM 2`) |
| 13 | `ISO/IEC PDAM 12207` | `ISO/IEC 12207/PDAM 1` | `iso-iec-12207-1995-amd-1-2002.yaml` → `ISO/IEC 12207:1995/Amd 1:2002` | number 1 ✓; drift: ballot PDAM vs published Amd; undated base matches by partial reference |

Exact stored-face agreement: rows 1 and 10 (plus row 5's already-parsing
face). Every other anchor agrees on everything the ballot face carries
(number, base structure, dated bases) and records the round-letters drift
against the stored record of record.

### 9.5 Released state

One PR per repo: pubid-grammar (grammar + artifact + contracts),
pubid (vendored artifact + builder decode + fixtures/specs + this doc),
pubid-testsuite (corpus round). No version bumps (the parent cuts 2.0.22 /
0.1.38 after the FIPS + IEC + ISO waves merge). The FPDAM stage ladder
stays at 50.00–50.99 (§8 call 3: the v2 ladder stands; zero stored records
arbitrate it).
