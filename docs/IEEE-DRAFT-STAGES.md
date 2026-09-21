# IEEE draft stages: native and joint-published (defining spec)

Status: **defining spec** for the IEEE flavor's draft conventions. Every
rule below is grounded in corpus evidence (testsuite `tests/ieee`: 5,145
native draft rows, 115 joint ISO/IEC+IEEE draft rows, ledger re-derived
against pubid#425) and in the reference implementation's behavior. Where
a rule DEFINES a convention rather than reporting observed practice, it
says so explicitly.

## 1. The two draft practices

IEEE documents reach the public in drafts under two distinct regimes:

### 1.1 Native IEEE drafts

An IEEE-owned document circulated as a draft carries the IEEE internal
**draft ordinal**: `IEEE Std 802.3/D2.0`, `IEEE P1003.1/D3`.

- The token after `/D` is an **ordinal** — "draft number 2" — not a stage.
- The ordinal maps onto the IEEE lifecycle by the ladder below (the
  TypedStage registry, `Pubid::Ieee.all_typed_stages`):

  | IEEE ordinal | ISO-equivalent stage | stage_code       |
  |-------------|----------------------|------------------|
  | D1          | WD                   | working_draft    |
  | D2–D3       | CD                   | committee_draft  |
  | D4–D6       | DIS                  | draft_standard   |
  | D7–D9       | FDIS                 | final_draft      |

  The ladder is informational (it classifies a draft's maturity); the
  ordinal itself is what the identifier stores. `D10`, `D37` are legal
  ordinals beyond the ladder.

- A **project marker** `P` before the number (`IEEE P1003.1/D3`) says the
  base document is still a project (not yet published). It prints for
  IEEE-led drafts (`IEEE P1003.1/D3`) and drops on ISO-led joint drafts
  (§2.3).
- **Status words** prefix the type: `IEEE Unapproved Draft Std …`,
  `IEEE Active Unapproved …`, `IEEE Approved …`. A status word suppresses
  the type word in the render (pubid#318): `IEEE Unapproved Draft Std
  P1057/D7.5, June 2007` → `IEEE Unapproved P1057/D7.5, June 2007`.
- **Dates**: a draft may carry its own date (`/D7.5, June 2007`) and/or a
  trailing print date (`/D1 2009, Oct 2009`); IEEE project drafts print
  the long comma date (`/D08, September, 2018`) and the dash year
  (`/D1-2006`); an unapproved draft keeps the pinned single-comma form.

### 1.2 Joint ISO/IEC/IEEE drafts — the `D` prefix is a marker, not an ordinal

When a document is co-published with ISO and/or IEC, its drafts circulate
under the **ISO/IEC stage vocabulary** (PWI, NP, WD, CD, CDV, DIS, FDIS),
not under the IEEE ordinal. The joint spelling prefixes the stage with
`D`:

> **Normative (defined here, matching all 115 joint draft rows):**
> in a joint identifier, `D` immediately followed by an ISO/IEC stage
> token (`DDIS`, `DFDIS`, `DCD`, `DCDV`, `DWD`, `DED`, `DP`) is the
> **draft-of-stage marker**: it reads "a DRAFT of the named stage
> document". It is NOT the IEEE draft ordinal — an IEEE `DIS` ordinal
> would be `D4`–`D6`, never the token `DIS` itself. Mnemonic:
> **`D=DIS` means "this is the DIS, in draft" — the document is the
> ISO/IEC stage document, not an IEEE-native draft.**

Evidence: the joint stage-designator inventory across the corpus is
exclusively `D`+stage — DFDIS ×26, DDIS ×13, DCD ×4, DCDV ×3, DWD,
DED, DP — never a bare stage word after the slash on a draft (a bare
`/DIS` only appears as an alias that normalizes to `/DDIS`), and never
an IEEE ordinal on a joint document.

- **Iteration numerals**: a digit directly after the stage token counts
  drafts of that stage: `DDIS2` = second DIS draft, `DCD2`/`DCD3`/`DCD4`
  = second/third/fourth CD draft, `DFDIS1`. The numeral belongs to the
  stage draft, not to the document.

### 1.3 Both systems on one document — the compound form `D5=DDIS.3`

A joint document can be tracked through BOTH systems at once: the IEEE
internal draft ladder AND the ISO/IEC stage process. The compound form
names both:

> **Normative (defined here; no corpus rows yet):**
> `D<ordinal>=D<STAGE>.<iteration>` — the IEEE draft ordinal, an equals
> sign, then the draft-of-stage token with a dot-separated iteration.
> `D5=DDIS.3` reads: **IEEE draft 5, of the 3rd iteration of the
> ISO/IEC DIS**. The two numerals are independent: `5` counts IEEE
> internal drafts (the §1.1 ladder applies to it), `3` counts drafts of
> the DIS stage document.

- The left side is always the IEEE ordinal (`D<n>`); the right side is
  always `D`+stage (`D=DIS` marker, §1.2). The `=` is the separator
  between the two numbering systems — it reads as "equal to stage".
- The corpus observes the glued aliases `DDIS3`/`DDIS-3` when only the
  stage iteration exists (§1.2); the dot in the compound form exists so
  the two numerals can never be read as one number.
- When only ONE system applies, use its plain form: an IEEE-tracked
  draft is `D5` (§1.1); a stage-tracked draft is `DDIS.3`'s right half
  alone, spelled `DDIS3` (§1.2). The compound form exists precisely for
  the case where dropping either half would lose information.
- **Monthcode**: a dash and four digits (`DCD2-1410`, `DDIS-1404`) is a
  **YYMM monthcode** — the intended publication month of that stage
  draft (1410 = October 2014), not a year. Disambiguation rule: a
  4-digit token after the stage draft is a monthcode unless it matches
  `(19|20)\d\d` AND stands in a dash-date position of a *published*
  joint form (`/CD2-2013-09`); the joint stage repositioning must not
  rewrite monthcodes onto the document number.

## 2. Accepted spellings (grammar)

Each spelling below parses; the corpus row count is given.

| # | Spelling | Example | Rows |
|---|----------|---------|------|
| 1 | **Post-posed stage draft** — `JOINT NUMBER/D+STAGE[iter][-monthcode][, date]` | `ISO/IEC/IEEE 15026-3/DCD, December, 2021` | 52 |
| 2 | **Stage-first** — `JOINT STAGE [P]NUMBER[:year]` | `ISO/IEC/IEEE DIS 29119-2`, `IEC/IEEE FDIS 60079-30-2` | 62 |
| 3 | **Embedded stage** — `JOINT NUMBER[.part].STAGE` | `ISO/IEC/IEEE 12207.CD2.1410, October 2014` | 7 |
| 4 | **Native ordinal draft** — `IEEE [status] [Std] [P]NUMBER/Dn[.rev][letter][, date]` | `IEEE Std 802.3/D2.0` | 5,145 |
| 5 | **Underscore dialects** — `_` as the separator (`…_FDIS`, `…_D3`), pre-normalized to `/` before parsing | `IEC/IEEE P63113 CDV, May 2020` | (aliases) |
| 6 | **Compound (both systems)** — `IEEE [P]NUMBER/D<ordinal>=D<STAGE>.<iter>` | `IEEE P24748-5/D5=DDIS.3` | (defined, none yet) |

Rules:

- **Equivalence (defined here):** spellings 2 and 3 are ALIASES of
  spelling 1 — stage position is spelling, not identity. The canonical
  parse stores the stage on the identifier (`iso_stage`), not its
  position. `ISO/IEC/IEEE 12207.CD2.1410` and `ISO/IEC/IEEE CD 12207/DCD2-1410`
  denote the same stage draft.
- **P retention:** IEEE-led stage drafts keep the project `P`
  (`IEEE P24748-5.CD3`); ISO/IEC-led joint drafts print P-less
  (`ISO/IEC/IEEE 15026-3/DCD`, never `P15026-3`).
- **`D` recovery:** a bare ISO stage after the number (`…/DIS`, `…/CDV`)
  parses and renders with the recovered `D` (`/DDIS`, `/DCDV`) — the
  marker is part of the canonical form.
- **Compound rule (defined here):** `D5=DDIS.3` parses to the IEEE
  ordinal `5` PLUS `iso_stage: DIS` with stage iteration `3`. The glued
  spellings `D5=DDIS3` and `D5=DDIS-3` are accepted aliases of
  `D5=DDIS.3`.
- **The monthcode guard:** `JOINT NUMBER/STAGE-(19|20)dd` is a dash-date
  and repositions onto the number; `STAGE-<other 4 digits>` is a
  monthcode and stays on the draft (`/DCD2-1410`).

## 3. Canonical model

- `publishers` — the joint token split on `/` (`["ISO","IEC","IEEE"]`);
  order-normalized to the corpus spelling (`ISO/IEC/IEEE`).
- `number`, `parts`, `separator` — the document number and its parts.
- `iso_stage` — the bare ISO/IEC stage (`DIS`, `CD`, …) when the joint
  document carries one; `typed_stage` resolves it through the registry
  (`DIS` → stage_code `draft_international_standard`).
- `draft` — the draft designator with its date; on joint drafts the
  designator is the `D`+stage token (`DCD, December, 2021`).
- `lead_party` — the first publisher of the stage-first spelling; the
  stage-less published joint form is lead `ISO`.
- Native drafts instead carry the ordinal in `draft` (`D2.0`) plus the
  ladder-derived `typed_stage`; `type`/`draft_status` carry the status
  words.
- The compound form (§1.3) carries BOTH: the ordinal in `draft` and the
  stage+iteration in `iso_stage`/the stage-draft designator.

## 4. Render rules (each family, pinned)

| Family | Input | Renders |
|---|---|---|
| Native draft | `IEEE Std 802.3/D2.0` | `IEEE Std 802.3/D2.0` |
| Unapproved native | `IEEE Unapproved Draft Std P802.3/D2.0, Mar 2009` | `IEEE Unapproved P802.3/D2.0, Mar 2009` |
| Joint stage draft | `ISO/IEC/IEEE 15026-3/DCD, December, 2021` | `ISO/IEC/IEEE 15026-3/DCD, December, 2021` |
| Joint stage-first | `ISO/IEC/IEEE DIS 29119-2` | `ISO/IEC/IEEE 29119.2` (colon-year when a year is present) |
| Joint printed published | `ISO/IEC/IEEE 21451-7, April 2011` | `ISO/IEC/IEEE 21451-7, April 2011` (Standard; dash-part, comma-date) |
| Joint colon-year published | `ISO/IEEE 11073-20101:2004(E)` | `ISO/IEEE 11073.20101:2004` (JointDevelopment; dot-part) |
| Joint with draft date | `ISO/IEC/IEEE 42010/D8, June 2010` | `ISO/IEC/IEEE 42010/D8, June 2010` (date stays in the draft) |
| Dash-year-month + draft | `ISO/IEC/IEEE 16326-2017-12/D5` | `ISO/IEC/IEEE 16326-2017-12/D5` (date glued to the code) |
| IEC/IEEE comma-date drop | `IEC/IEEE P61886-1/D2, May 2020` | `IEC/IEEE 61886-1/D2` (exactly-IEC/IEEE drops comma dates; wider sets print them) |

## 5. URN rules (pinned) and one defined defect

- Native draft: `IEEE Std 802.3/D2.0` → `urn:ieee:ieee:802.3:draft./D2.0`.
- Unapproved native: `…:draft.std:P802.3:draft./D2.0, Mar 2009:unapproved`.
- Joint stage draft: `ISO/IEC/IEEE 15026-3/DCD, …` →
  `urn:ieee:iso-iec-ieee:15026-3:draft./DCD, December, 2021`.
- Joint published: `ISO/IEC/IEEE 21451-7, April 2011` →
  `urn:ieee:iso-iec-ieee:21451-7:2011:April`.
- **Defined defect (to fix, not a convention):** an IEC/IEEE project
  draft (`IEC/IEEE 61886-1/D2`) currently emits the degenerate
  `urn:ieee:ieee` — the publisher segment collapses and the document
  number is lost. The intended URN is
  `urn:ieee:iec-ieee:61886-1:draft./D2`. Consumers must not depend on
  the degenerate form.

## 6. What this spec defines vs reports

- **Defined here:** the `D`-marker semantics for joint stage drafts
  (§1.2), the compound both-systems form `D5=DDIS.3` (§1.3), the
  equivalence of stage positions (§2), the monthcode rule (§1.2), the
  P-retention asymmetry (§2), the intended IEC/IEEE URN (§5).
- **Reported (observed, pinned by the corpus):** the D-ordinal ladder
  (§1.1 — registry data), every render row in §4, the URN shapes in §5.
