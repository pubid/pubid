# ANSI flavor notes

## The trailing year and the open co-publisher list (relaton#45)

relaton routes `ANSI …` through `Pubid::Ansi`: it takes the year for the cache
key and sends `ANSI/<co-publisher> …` to that co-publisher's flavor
(hand-off `pubid__pubid__ansi-year-and-copublishers`).

- **A trailing `-YYYY` (19xx/20xx) is the year, not a part.** The grammar's
  `number_with_part` still captures `X9.62-2005` whole; `Builder#read_dash_year`
  moves a 4-digit 19xx/20xx dash group into `date` and sets
  `date_separator: "-"`, but only when no `:YYYY` follows, so the part of
  `ANSI X9.8-1:2007` stays a part. Before this, all 175 corpus ids stored the
  year in `part` and had no `year`. A real 4-digit part in 19xx/20xx is now
  read as a year; no corpus id has one.
- **`date_separator` is spelling, not identity.** It is `equality_ignored`, so
  `ANSI X9.62-2005 == ANSI X9.62:2005`. nil means the colon, which keeps the
  hash of `ANSI/ISO 9899:1990` unchanged. It is the pubid-URN facet `datesep`.
  `#exclude(:year)` / `#exclude(:date)` also nils it (the sibling-cluster rule
  in the root `CLAUDE.md`), so a year-less copy carries no orphan flag.
- **Any uppercase acronym co-publishes**: `copublisher_item` is
  `"/" [" "] %x41-5A 1*(%x41-5A / %x30-39)` (UL, NISO, INCITS, ASHRAE, HL7,
  ASC, …), in `data/parg/ansi.json`. **The grammar was baked here ahead of
  pubid-grammar** (hand-off `pubid__pubid-grammar__ansi-open-copublishers`):
  the `source` of `data/parg/ansi.json` is the only copy until pubid-grammar
  adopts it. To rebake: `jq -j .source data/parg/ansi.json > ansi.parg`, edit,
  `parsanol _1.5.1.0_ parg compile ansi.parg -o data/parg/ansi.json`,
  `parsanol _1.5.1.0_ parg test data/parg/ansi.json`.
- **The dash after the acronym** (`ANSI/ISA-5.1-2009`, `ANSI/ANS-8.1-2014`,
  `ANSI/ISA-61511-1-2018`, `ANSI/TIA-568.2-D`). Three grammar pieces:
  (1) only `identifier_with_copublishers` takes `"-" as number_separator`
  in place of the space; `number_separator` is `equality_ignored` (nil = the
  space) and the pubid-URN facet `numsep`, so `ANSI/ISA-5.1 == ANSI/ISA 5.1`.
  `#exclude(:year)` keeps it — it belongs to the publisher group, not the year.
  (2) `number_with_part` takes a second dash group, but only a 19xx/20xx year
  not followed by a digit or a colon, so the builder reads a third split group
  as the year with no test, and `X9.8-1-2007:2009` fails instead of silently
  dropping `2007`. The two-group case still goes through `read_dash_year`,
  which skips an id with a revision: in `568-2009-D` the `2009` is a part,
  because the renderer prints the revision before the date. The space form
  gets the second group too (`ANSI X9.8-1-2007`). (3) `revision` is one
  uppercase letter after a dash, not followed by a letter or digit (`-DE`
  fails). It is identity (`revision_of?` reads it), the pubid-URN atom `rev`,
  an official URN segment `rev-D` and an MR-slug suffix
  (`#mr_number_with_part`), so `568.2-C` and `568.2-D` do not collide. Not
  supported: a year after the revision (`568.2-D-2016`) and TIA addenda
  (`568-C.2`). The official `UrnParser` refuses every co-published URN
  (`urn:ansi-isa:…`), as it did before. **Measured** against a `main`
  replay of every ansi/ieee/amca/ashrae fixture id: no `to_s`, `to_hash`,
  `to_urn` or pubid URN moved, and one route is new: `ANSI/IEEE Std
  260-4-1996` failed in every flavor and now routes to ANSI as
  `ANSI/IEEE 260-4-1996`. It loses `Std`, because the ANSI grammar never
  captures `["Std "]` (`ANSI Std A119.1` renders `ANSI A119.1` on `main`
  too).
- **Routing umbrella.** With the open list, ANSI parses `ANSI/AMCA 210-16`
  exactly while AMCA normalizes it (`ANSI/AMCA Standard 210-16`), so plain
  routing would have handed it to ANSI. `Pubid::Ansi.routing_umbrella?` is
  true: `Pubid.parse` tries ANSI last among the prefix owners and returns an
  earlier owner's parse. **The short-cut fires only when ANSI is a prefix
  owner of the string.** A first version fired in the exhaustive pass too,
  where ANSI is 4th in registry order, and it moved 24 unrelated routes
  (`EP 207` went from GB to BSI `BS 207`); `spec/pubid/ansi/
  year_and_copublishers_spec.rb` pins two of them. Measured over every
  ansi/amca/ashrae/ieee fixture id and over a 8,428-id sample of every
  flavor's pass fixtures: no route moved except new parses and
  `ANSI/ASHRAE 90.1-2019`, which went to IEEE before (a non-owner's exact
  parse) and now goes to ASHRAE (rendered `ASHRAE Standard 90.1-2019`).
  `Pubid::Ansi.parse` itself still reads it as ANSI with co-publisher ASHRAE.
- **Type keys are unique**: `AmericanNationalStandard` (never built by the
  builder) has key `:american_national_standard`; `Standard` keeps `:ans`.

**What moved** (replay of all 11,656 ansi/ieee/amca/ashrae fixture ids against
`main`): `to_s` byte-identical for every id that parsed before. `to_hash` and
the pubid URN moved for 174 earlier ANSI ids and 33 IEEE adoptions that nest an ANSI
id (`IEEE 167-1966 (ANSI C16.37-1971)`): `part` became `year` +
`date_separator`. `to_urn` moved for the same 174 ANSI ids (`urn:ansi:802.3:-2012` →
`urn:ansi:802.3:2012`, which `UrnParser` now reads back). An old hash still
deserializes, but it does not `==` a fresh parse, so the relaton-data-ieee rows
that nest an ANSI id need a re-crawl. The 170 moved `tests/ansi/` cases are in
`conformance/pending.yaml` until the pubid-testsuite round (hand-off
`pubid__pubid-testsuite__ansi-year-and-corpus`).
