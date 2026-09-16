# EVS Identifier Patterns

EVS (Eesti Standardimiskeskond / Estonian Centre for Standardisation and Accreditation)

## Entry Point

```ruby
require 'pubid/evs'
id = Pubid::Evs.parse("...")
```

## Identifier Types

EVS identifiers are national adoptions of European Standards. The national
prefix wraps a CEN/CENELEC identifier parsed by the real CEN grammar
(`Pubid::CenCenelec::Parser` is embedded in the EVS grammar, the same
composition ISO uses for IDF joint identifiers).

| Pattern | Example | Wrapped CEN identifier |
|---|---|---|
| EVS-EN \<n\>:\<year\> | `EVS-EN 18216:2026` | `EN 18216:2026` (EuropeanNorm) |
| EVS-EN ISO \<n\>:\<year\> | `EVS-EN ISO 14001:2026` | `EN ISO 14001:2026` (AdoptedEuropeanNorm) |
| EVS-EN ISO/IEC \<n\>:\<year\> | `EVS-EN ISO/IEC 27017:2026` | `EN ISO/IEC 27017:2026` |
| EVS-EN ISO \<n\>:\<year\>/A\<m\>:\<year\> | `EVS-EN ISO 9001:2015/A1:2024` | `EN ISO 9001:2015/A1:2024` (Amendment) |
| EVS EN … (space separator) | `EVS EN 18216:2026` | separator preserved on render |

SIST is **not** an EVS-related prefix — Slovenian adoptions belong to their
own scheme and are out of scope for this flavor.

## Rendering

`to_s` renders `EVS{separator}{adopted CEN identifier}`. The separator is
captured from the input (`-` or space) and defaults to `-`, so both printed
forms survive a round trip.

## URN

The URN mirrors the CEN adoption namespace with the national-body prefix —
generation delegates to the adopted identifier's URN and swaps
`urn:cen:` for `urn:evs:`:

| Identifier | URN |
|---|---|
| `EVS-EN 18216:2026` | `urn:evs:en:18216:2026` |
| `EVS-EN ISO 14001:2026` | `urn:evs:en:iso:14001:2026` |
| `EVS-EN ISO/IEC 27017:2026` | `urn:evs:en:iso-iec:27017:2026` |
| `EVS-EN ISO 9001:2015/A1:2024` | `urn:evs:en:iso:9001:2015:amd:1:2024` |

URN parsing reassembles the adopted identifier's human form and delegates
to the real grammar (the same approach `Pubid::CenCenelec::UrnParser` uses).

## References

Fixtures in `spec/fixtures/evs/identifiers/pass/` are drawn from the
purchased EVS reference PDFs in the private repository
`metanorma/mn-samples-evs-private`.
