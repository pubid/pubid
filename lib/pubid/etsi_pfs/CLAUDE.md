# EtsiPfs — the PFS-compiled etsi dev alias

This flavor is **generated**, not hand-written: every file here is compiler
output from `pubid-grammar`'s `definitions/etsi.pfs` (pubid/pubid#706
phase 2), reproduce with

```bash
cd ../pubid-grammar
ruby scripts/pfs compile definitions/etsi.pfs --as etsi_pfs \
  --parsanol-version <CI pin> --ruby-out ../pubid/lib
mv ../pubid/lib/etsi_pfs.rb ../pubid/lib/pubid/etsi_pfs.rb   # __dir__ paths assume lib/pubid/
mv ../pubid/lib/etsi_pfs ../pubid/lib/pubid/etsi_pfs
cp artifacts/etsi_pfs.json ../pubid/data/parg/etsi_pfs.json
```

DO NOT EDIT these files by hand — a hand edit is silently overwritten by
the next compile, and the grammar SSOT is the definition, not this module
(the `data/parg/etsi_pfs.json` artifact's freshness envelope and the
definition's source sha pin the lineage).

## The coexistence semantics (read before touching anything)

`etsi_pfs` is the **dev-alias key** of the etsi scheme: it registers beside
the coded `Pubid::Etsi` so the compiled pipeline can be proven against the
coded flavor without cutover. Same rules as `lib/pubid/doi_pfs/CLAUDE.md`:
the definition declares the scheme-canonical wire tag
(`pubid:etsi:etsi-standard`) and the scheme's `to_urn` namespace (`etsi`);
`Pubid.parse` keeps routing `ETSI …` to the coded flavor.

## The parity gate

`spec/pubid/etsi_pfs/parity_spec.rb` is the deliverable: over the FULL
fixture inventory (24,718 pass fixtures — the largest corpus a compiled
flavor is bracketed against) plus constructed edge cases and 23 negatives.
Measured surface (see the spec header for the numbers and their meaning):

- **accept 24,718/24,718** and the same `ParseError` on negatives — the
  language bracket: the compiled grammar accepts exactly the coded surface
  (all 15 type tokens; the four number shapes GSM/dotted/complex/simple;
  minor; the parts run; the /A//C supplement runs; `V`-versions and
  `ed.N`; the `(YYYY-MM)` date).
- **to_hash and to_pubid_urn byte parity: 18,945/24,718** — exactly the
  rows carrying none of the three constructs pfs:1 cannot declare. Each
  gap is pinned per construct in the spec, so compiler progress turns the
  pin red:
  1. **collection bindings** — the coded model stores `["1","0"]` (the
     `part -> parts[].part` binding); the compiled capture is the printed
     dash run `"-1-0"`.
  2. **the edition face** — the coded model folds `ed.N` into
     `Version(version: "N", is_edition: true)`; the compiled hash carries
     `edition: "N"`.
  3. **supplement wrappers** — the coded model wraps `/A1` `/C1` as
     Amendment/Corrigendum classes with an Integer ordinal delegating to
     their base; the compiled row stays a flat etsi-standard carrying the
     printed run `"/A1"`.
- **to_s** renders the canonical CORE face (`ETSI <type> <number>`) —
  pfs:1 render faces cannot render optionals, so every corpus row (all of
  which carry version/ed + date) renders shorter; bare ids agree
  byte-for-byte.
- **to_urn** is a compiler gap (the coded generator is hand-written Ruby
  composing `urn:etsi:{type}:{code}:{version}:{date}`; the generated
  generator pins the namespace only). Note the CODED generator raises
  `ArgumentError` on months 08/09 (`format('%02d', "08")` — the zero-padded
  string reads as an invalid octal); pre-existing on main, pinned by the
  parity spec.
- **to_mr_string** is a compiler gap (the coded slug reads the flavor's
  `mr_*` hooks — type/parts/edition/date segments; the base hooks find
  none of them on the compiled columns).

## Non-obvious facts, learned the hard way

- The generated `--ruby-out` lands at `lib/etsi_pfs.rb`; the autoload and
  the `#{__dir__}` paths require it at `lib/pubid/etsi_pfs.rb` — move both
  the file and the directory (commands above).
- `core: ["number"]` in a `.pfs` urn type row would generate
  `core: [:number]`, which crashes `PubidUrn.define` at load time (the
  generator emits `core.map(&:to_sym)`); only `core: []` round-trips.
  The instance's URNs resolve through the CODED schema anyway (the flavor
  segment of the canonical tag is `etsi`), so the alias rows are the
  future-cutover shape.
- `V1..1` parses in BOTH flavors (`.` is a version_char) and `GS` is a
  real type token — neither is a parity negative.
- `Pubid::EtsiPfs.parse("ETSI …")` never hijacks `Pubid.parse` (registry
  keys sort `"etsi"` first), and `Pubid.from_hash` of an alias hash
  resolves the coded `EtsiStandard` (one scheme, one `_type`).
- The corpus inventory (`spec/fixtures/etsi/identifiers/full/`) is the
  parity source; its bucket split is pinned: plain 18,945 / parts 3,772 /
  edition 1,833 / supplement 168.

## v1 boundaries

Single-type schemes only, `kind: string` fields only, no free-standing
`stages:`/`supplements:` sections, no semantic decode rules — see
`pubid-grammar`'s `definitions/README.md` for the language reference and
the fail-closed validation rules.
