# ASME flavor notes

ASME index key and MR slug.

These notes were part of the root `CLAUDE.md`. Read them before you change `lib/pubid/asme/` or `spec/pubid/asme/`. The root file keeps the cross-flavor contract that every flavor obeys.

## From the root note "AMCA / ASME / ASTM index key (`root.number`): three flavors, three different shapes"

**(2) ASME — the whole printed code, not a split.** `Asme::Components::Code` is designator+number, so the IEEE split looks right — but **152 of 731 fixture ids are Boiler and Pressure Vessel Code documents whose entire identity IS the designator** (`BPVC COMPLETE CODE BIND`, `BPVC.CC.BPV`) with no numeric part at all; splitting leaves every one of them keyed `""`. So `number` holds the whole code (`"B18.3"`), declared on the leaf `Identifiers::Standard`. **`Asme::Components::Code` is now unused on the identifier path and there is no `#code` reader**: an earlier draft composed one so the renderer and URN generator would not have to change, but since `number` already holds the whole code that Code never carried a designator and `code.to_s` equalled `number` for all 731 ids — a string wrapped in an object whose only job was to unwrap to the same string. Both readers use `number` directly. **Contrast ASTM, which keeps its composed `#code`**: its renderer reads `code.letter`/`code.dual_m` field-by-field, so there the component carries real structure. The test for whether a derived `#code` earns its place is whether any caller reads a *field* of it rather than just `to_s`.

## The trailing year and the BPVC designator (hand-off `asme-bpvc-and-amca-residue`)

**A designator with no number lost its year.** The dash branch of `number_part` (`dash >> [0-9A-Z]+`, there for `BTH-1` and `CA-1`) also matched the year in `BPVC.I-2021`, so `-2021` became the number. For a BPVC code the builder then discarded the number, so all 150 BPVC ids had no year and the 2021, 2023 and 2025 editions of one document had the same hash, `to_s`, URN and slug. For `BPE-2012`, `OM-2017` and `PASE-2019` (13 ids) the year stayed inside `number` (`"BPE-2012"`). The `trailing_year` guard in `lib/pubid/asme/parser.rb` refuses that branch for a dash, a 4-digit or draft year, and no further code character. `BTH-1-2020` still parses as `BTH-1`.

**Two BPVC render corruptions were in the same builder.** The case sub-code kept its leading dot (`BPVC.CC.BPV..I`, 15 ids), and the builder read the SSC sections one level above where the grammar put them (`BPVC.SSC.`, 2 ids). Every BPVC id now renders as it was written.

**`BPVC-CC-BPV` and `BPVC.CC.BPV` are two documents, not two spellings.** The hand-off suggested normalizing one to the other, and a draft of this branch did that. It was reverted: the ASME catalogue (asme.org, "Find codes & standards") lists both as separate documents: `BPVC.CC.BPV` is the code-case book, and `BPVC-CC-BPV` is the designation of each 2019 code-case supplement ("BPVC Code Cases 2019-Boilers and Pressure Vessels, Supplement 7"; the supplement number is only in the title, so pubid cannot tell the supplements apart). Each keeps its own spelling, index key, `to_s` and URN.

**The MR slug writes a literal `-` as `--`.** `mr_sanitize` wrote `.` and `-` both as `-`, so `BPVC.CC.BPV-2019` and `BPVC-CC-BPV-2019` shared `asme.bpvc-cc-bpv.2019`. Now the dash form is `asme.bpvc--cc--bpv.2019`. **`_` was the obvious choice and is wrong:** the MR format reserves `_` for supplement layers, and `Pubid::Parsers::MrString` splits on it first. The change moves only the slug, and only for the 113 corpus ids whose code has a literal dash (`BTH-1` → `bth--1`); `B18.3` stays `b18-3`.

**The SSC codes of the ASME catalogue all parse.** `BPVC.SSC.XI.II.V.IX` (Sections XI, II, V, IX) and `BPVC.SSC.VIII.XII.II.V.IX` (Sections VIII, XII, II, V, IX) are different documents; the spec table carries every SSC code the catalogue lists.

**Measured against a `main` baseline of the 731 fixture ids:** only the 150 BPVC ids and the 13 BPE/OM/PASE ids moved. No id stopped parsing. The `pubid-testsuite` corpus records the old outputs as debt (`tests/asme/_status.yaml` is `clean: false`), so it needs a re-export (hand-off `pubid__pubid-testsuite__asme-amca-reexport`).

**Not fixed, pre-existing:** `ASME PTC 1-2015` renders `ASME PTC1-2015` (the space before a PTC number is lost).
