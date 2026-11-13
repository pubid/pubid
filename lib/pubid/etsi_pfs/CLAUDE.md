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
- **to_hash and to_pubid_urn byte parity: 24,718/24,718** (phase 3
  closed all three constructs; the former per-construct pins are now
  parity rows):
  1. **collection bindings** (3,772 rows) — `parts` is a `kind: list`
     field binding its `part` item per repetition; the compiled model
     stores the coded `["1","0"]` array, dropped when empty.
  2. **the edition face** (1,833 rows) — the `ed.N` capture folds onto
     `version` + `is_edition: true` (the coded Version component shape).
  3. **supplement wrappers** (168 rows) — the `supplements:` declaration
     folds the printed run into SYNTHESIZED Amendment/Corrigendum classes
     over the base standard, outermost last ("/A1/C1" is Corrigendum over
     Amendment over the standard).
  Trajectory: 18,945 → 22,717 (collections) → 24,718 (fold + wrappers).
- **to_s** renders the full printed face — the canonical template's
  presence-guarded optionals and the V/ed alternated tail render what
  the input carried (the conditional-render segment feature).
- **to_urn** is DECLARED (`urn.official`): type lowercased, the composed
  code (number + minor + prefix-glued parts), the v/ed version face
  (the edition affix under the fold flag), the year-month date group —
  byte-identical with the coded generator everywhere the coded one
  renders at all. The CODED generator raises `ArgumentError` on months
  08/09 (`format('%02d', "08")` — the zero-padded string reads as an
  invalid octal); pre-existing on main, pinned by the parity spec — the
  compiled generator renders the captured month verbatim and does not
  share the defect.
- **to_mr_string** is DECLARED (`mr:`): the coded mr_type /
  mr_number_with_part / mr_year / mr_edition hooks over the columns,
  byte-identical slugs (`etsi.eg.200-053.2004-06.1-5-1`), with the
  wrapper's supplement suffix (`…_a1.1`) carried by the synthesized
  classes.

## Non-obvious facts, learned the hard way

- The generated `--ruby-out` lands at `lib/etsi_pfs.rb`; the autoload and
  the `#{__dir__}` paths require it at `lib/pubid/etsi_pfs.rb` — move both
  the file and the directory (commands above).
- The instance's URNs resolve through the CODED schema anyway (the
  flavor segment of the canonical tag is `etsi`), so the alias's schema
  rows are the future-cutover shape; the wrapper rows now carry the
  coded `core: [["number", :int]]` ordinals (the phase-3 int-kind
  cores).
- `V1..1` parses in BOTH flavors (`.` is a version_char) and `GS` is a
  real type token — neither is a parity negative.
- `Pubid::EtsiPfs.parse("ETSI …")` never hijacks `Pubid.parse` (registry
  keys sort `"etsi"` first), and `Pubid.from_hash` of an alias hash
  resolves the coded `EtsiStandard` (one scheme, one `_type`).
- The corpus inventory (`spec/fixtures/etsi/identifiers/full/`) is the
  parity source; its former bucket split (plain 18,945 / parts 3,772 /
  edition 1,833 / supplement 168) is now the per-gap parity trajectory —
  all 24,718 rows agree on to_hash, to_pubid_urn, to_s, to_urn and
  to_mr_string.
- The run's internal captures (`supplement_kind` / `supplement_number`)
  bind only through the run's item rows, and unbound captures arrive as
  raw `Parsanol::Slice` leaves — the generated builder unwraps
  `Slice#content` (the cen_cenelec precedent).

## v1 boundaries (still)

Single declared type per scheme (the `supplements:` wrappers are the one
multi-class shape), no free-standing `stages:` maps, no semantic decode
rules — see `pubid-grammar`'s `definitions/README.md` for the language
reference and the fail-closed validation rules.
