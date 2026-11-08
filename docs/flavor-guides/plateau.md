# PLATEAU: the Handbook #11 edition split

Ported from the archived `pubid-plateau` README (the "Handbook 11 update"
rule), restated against the pubid 2.0 monogem. The rule is encoded in the
pre-parse normalization table `data/plateau/update_codes.yaml`.

## The rule

Handbook #11 (第4.0版 onward) combined two earlier handbooks. For editions 1
to 3, Handbook #11 did not exist as a single document — the content was
published as two parts:

* （民間活用編）— was **Handbook #06**, editions 1–3
* （公共活用編）— was **Handbook #04**, editions 1–3

Only from edition 4 were the two combined into Handbook #11. A reference to
"Handbook #11" with edition 1–3 and a part suffix is therefore anachronistic,
and pubid rewrites it to the handbook that actually existed:

| Input | Parsed and rendered as |
|-------|------------------------|
| `PLATEAU Handbook #11 第1.0版（民間活用編）` | `PLATEAU Handbook #06 第1.0版` |
| `PLATEAU Handbook #11 第1.0版（公共活用編）` | `PLATEAU Handbook #04 第1.0版` |
| `PLATEAU Handbook #11 第2.0版（民間活用編）` | `PLATEAU Handbook #06 第2.0版` |
| `PLATEAU Handbook #11 第2.0版（公共活用編）` | `PLATEAU Handbook #04 第2.0版` |
| `PLATEAU Handbook #11 第3.0版（民間活用編）` | `PLATEAU Handbook #06 第3.0版` |
| `PLATEAU Handbook #11 第3.0版（公共活用編）` | `PLATEAU Handbook #04 第3.0版` |

```ruby
require "pubid"

Pubid.parse("PLATEAU Handbook #11 第1.0版（民間活用編）").to_s
# => "PLATEAU Handbook #06 第1.0版"
```

Edition 4 and later have no split — `PLATEAU Handbook #11 第4.0版` parses to
itself.

## General form

PLATEAU identifiers follow `PLATEAU {Type} #{Number}[-{annex}] 第{X.X}版`,
with types Handbook, Technical Report, and Annex. Legacy Latin edition forms
(`v1.0`, `Version 1.0`) parse and normalize to the canonical Japanese
`第X.X版`; an annex joins with `-` (`PLATEAU Handbook #01-1 第1.2版`).
