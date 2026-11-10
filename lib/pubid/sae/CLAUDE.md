# SAE flavor notes

## Source of the codes: SAE's Crossref deposits

relaton indexes every SAE standard from Crossref (prefix `10.4271`, type
`standard`). The DOI suffix is SAE's own edition code, lower-case and without
hyphens: `10.4271/j3016_202104` is `SAE J3016_202104`, `10.4271/amsqqa250_4b`
is `SAE AMS-QQ-A-250/4B`. relaton upper-cases the suffix and prefixes `SAE `,
so pubid must read the hyphen-free spelling as well as the printed one.

Measured on the full deposit list (2026-11-04, 47,692 DOIs): **46,726
parse**, and every parsed code round-trips through `to_s`, `from_hash` and
the URN, with **0 `to_hash` collisions**. The 966 that do not parse are:

- **791 CP\*** (`CPGM`, `CPFD`, `CPKW`, …): SAE "Certified Power" data
  products — engine power/torque data certified under SAE J1349, one per
  vehicle and level (`CPGM2_15LFXCOCA`: "J1349 Certified Power Engine Data
  for GM as used in 2015 LFX Colorado/Canyon - Level 2"). The letters after
  `CP` name the manufacturer (`GM`, `FD` Ford, `FC` FCA, …). They are data
  products, not standards, and stay out of `TYPES` by decision (pubid#686).
  `SAE CPGM2016` in pubid#686 is not a deposit: it is the synthetic DOI of
  relaton's "reports a record pubid cannot parse" spec
  (`spec/sae/relaton/sae/data_fetcher_spec.rb`), which, with
  `bibliography_spec.rb` and `docs/sae.md`, relies on it failing to parse.
  `spec/pubid/sae/crossref_coverage_spec.rb` pins the rejection.
- **175 one-offs**, none more than 32 of a kind: `SUP1` supplements
  (`AS4468SUP1A`, `ARP4737SUP1`), language tails (`AS9101F_PTBR`,
  `IA9137_DEDE`), `J2534-2/10_5_00`, `_4Q2012`, type-less `SAE6857`,
  `_MMYYYY` dates (`CS1939_042012`, `J2012DA_012013` — the builder's
  month check refuses the J ones, which would otherwise read as year 120,
  month 13), `ISO/SAE21434`, `IEEE/EIA12207`, and ~30 families of 1–8
  documents whose printed form is unknown (`HEB`, `EQB`, `TAHB`, `AMSLP`,
  `AMSHHG`, …). Add a family by adding it to `Components::Type::TYPES` and
  re-baking the grammar (below).

## Model

| attribute | example | `===` |
|---|---|---|
| `type.abbr` (printed form) | `AMS`, `AMS-QQ-A`, `GEIA-STD` | stated |
| `number` | `4121`, `0001`, `1939DA`, `174M`, `1939-71` | stated |
| `part` | `2` of `J2337/2`, `H1025` of `AMS5622/H1025` | strict |
| `revision` | `J` of `AMS4121J`, `6` of `USCAR2-6` | wildcard |
| `amendment` | `1` of `AS5259/7A_A1` | strict |
| `date` (`year`, `month`) | `J3016_202104` | month is a wildcard |

The grammar only segments the code; `builder.rb` decides what each segment
means, because the meaning depends on the family:

- **A one-letter tail is the revision** (`AMS4121J`, `AS22520/45A`), so every
  revision of a document shares one `number` bucket and `SAE AMS4121 ===`
  each of them. relaton then picks the highest revision.
- **Except the `M` of a J or JA report**, which marks the metric document
  (`J174M`) and stays in `number`. AMS revisions do reach `M` (`AMS2400M`),
  so the exception is per family (`Type::METRIC_SUFFIX`).
- **A longer tail is another document** (`J1939DA` digital annex,
  `J2735SET`) and stays in `number`, in its own bucket.
- **A dash number is part of `number`** (`J1939-71`, `EIA649-2`; the DOI
  writes some of them `_1`: `EIA649_1A` → `EIA-649-1A`). For USCAR the dash
  is the revision (`USCAR2-6` is USCAR-2 Revision 6, `Type::DASH_REVISION`).
- **`part` and `amendment` are `subset_strict`**: `SAE J2337` does not match
  `SAE J2337/2`, and `SAE AS5259/7A` does not match `SAE AS5259/7A_A1`.

Rendering follows SAE: no space after the type (`SAE J3016`, the old
`SAE J 3016` still parses), a hyphen after a family that kept a military or
industry series hyphen (`Type::TYPES` holds the separator), `_YYYYMM` when
the month is known and `:YYYY` otherwise. The amendment tail `_A1` has no
known printed form and keeps the DOI's.

## The grammar is baked here from a hand-off source

`data/parg/sae.json` was compiled with the pinned parsanol from the source
recorded in hand-off `pubid__pubid-grammar__sae-crossref-coverage` (the same
text sits in the artifact's `source` field). Until pubid-grammar lands it,
`pubid-grammar/grammars/sae.parg` is the OLD grammar, so `parsanol parg
check` against it reports stale. To change the grammar, extract the source
(`jq -r .source data/parg/sae.json`), edit, and re-bake:

```bash
bundle exec parsanol parg compile sae.parg -o data/parg/sae.json
bundle exec parsanol parg test data/parg/sae.json
```

The `doc_type` alternatives are the `Type::TYPES` keys plus their
hyphen-free spellings, longest first (PEG commits to the first match, so
`AMS` comes after every `AMS…`). `spec/pubid/sae/type_table_spec.rb` fails
when the two lists drift or an alternative shadows a longer one.
