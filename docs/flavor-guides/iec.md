# IEC: TRF format grammars

Ported from the archived `pubid-iec` README, restated against the pubid 2.0
monogem. Test Report Forms (TRFs) are published by the IEC conformity-
assessment systems — IECEE (System for Certification to Standards Relating to
Electrical Equipment) and IECEx (certification for explosive atmospheres).
They parse to `Pubid::Iec::Identifiers::TestReportForm`.

## IECEE TRF format

```
IECEE TRF {number-and-part}{trf-version}[{test-type}][:{year}]
```

Example: `IECEE TRF 60086-1&2A:2017`

`number-and-part`:: the number and part of the underlying IEC standard, e.g.
`61000-3-33`. Multiple parts join with `&`. On parse the `,` separator is
accepted and normalized to `&`: `IECEE TRF 60335-2-4;7F:2012` parses and
renders `IECEE TRF 60335-2-4&7F:2012`.

`trf-version`:: the version letter — `A` first, `B` second, and so on.

Sub-versions:: the version can be `{version-alphabet}{sub-version}`, where the
sub-version is a string: `F_II` (sub-version `_II`) in
`IECEE TRF 61058-1F_II:2019`. The full version is the whole `trf-version`
string, `F_II`.

`test-type`:: optional specialized TRF type suffix: `_EMC`, `_PS`, `_SOF` —
e.g. `IECEE TRF 61000-3-33A_EMC:2019`.

`year`:: optional edition year.

## IECEx TRF format

```
IECEx TRF {number-and-part}{either '_' or 'v'}{std-edition}{trf-version}
```

Example: `IECEx TRF 60079-15v1:2002`

`number-and-part`:: the number and part of the underlying IEC standard, e.g.
`60079-0`. Multiple parts join with `,` here.

`'_'` or `'v'`:: in the IEC Webstore the separator is a `v`
(`IECEx TRF 60079-15v1:2002`); in the official IECEx identifier pattern it is
`_`. Both parse.

`std-edition`:: the edition number of the underlying IEC standard (an
integer).

`trf-version`:: the version letter, as for IECEE; sub-versions occur too —
`A_DS` (sub-version `_DS`) or `Arev4_ds` (sub-version `rev4_ds`). The full
version is the whole string.

## Parsing in pubid 2

```ruby
require "pubid"

id = Pubid.parse("IECEE TRF 61058-1F_II:2019")
id.class  # => Pubid::Iec::Identifiers::TestReportForm
id.to_s   # => "IECEE TRF 61058-1F_II:2019"
id.to_hash
# => {"_type" => "pubid:iec:test-report-form", "year" => "2019",
#     "publisher" => "IECEE", "number" => "61058", "part" => "1F_II"}
```

The `publisher` attribute carries the system (`IECEE`, `IECEx`), `number` the
standard number, and `part` the number-and-part tail (part, sub-version,
test-type glued as parsed).

## General IEC forms

The flavor covers the rest of the IEC family as well: International Standards
with compact supplement faces (`IEC 60050-351:2013/AMD1:2016` — short form
`AMD1` vs long `Amd 1`), consolidated editions
(`IEC 60950-1:2005+AMD1:2009+AMD2:2013 CSV` — a `VapIdentifier`), value-added
suffixes (CSV, CMV, RLV), CISPR designations, and undated references
(`IEC 60050:--`). Languages render in parentheses with editions
(`IEC 1000-1:2023 ED2(en)`); the URN follows the IEC URI model
(`urn:iec:std:iec:1000-1:2023::ed-2:en`).
