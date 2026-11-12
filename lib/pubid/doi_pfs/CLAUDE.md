# DoiPfs — the PFS-compiled doi dev alias

This flavor is **generated**, not hand-written: every file here is compiler
output from `pubid-grammar`'s `definitions/doi.pfs` (pubid/pubid#706),
reproduce with

```bash
cd ../pubid-grammar
ruby scripts/pfs compile definitions/doi.pfs --as doi_pfs \
  --parsanol-version <CI pin> --ruby-out ../pubid/lib
cp artifacts/doi_pfs.json ../pubid/data/parg/doi_pfs.json
```

DO NOT EDIT these files by hand — a hand edit is silently overwritten by
the next compile, and the grammar SSOT is the definition, not this module
(the `data/parg/doi_pfs.json` artifact's freshness envelope and the
definition's source sha pin the lineage).

## The coexistence semantics (read before touching anything)

`doi_pfs` is the **dev-alias key** of the doi scheme: it registers beside
the coded `Pubid::Doi` so the compiled pipeline can be proven against the
coded flavor without cutover (cutover — replacing `doi` with the compiled
flavor — is a separate, later decision).

- **Wire tag**: the definition declares `tag: "pubid:doi:resource"` — the
  SCHEME's canonical tag — so `to_hash` is byte-identical with the coded
  flavor. `Resource.polymorphic_name` overrides the class-name-derived
  tag for exactly this reason. Consequence: a GLOBAL `Pubid.from_hash` of
  a doi_pfs hash resolves the coded class (one scheme, one `_type`, one
  global resolution); the alias's own `DoiPfs::Identifier.from_hash`
  routes the tag back to `DoiPfs::Identifiers::Resource` through its
  `DOI_TYPE_MAP`.
- **URN namespace**: the definition declares `urn.namespace: doi`, so the
  generated `UrnGenerator` pins `urn_namespace` to `"doi"` and `to_urn`
  is byte-identical (`"urn:doi"`). The pubid-scheme schema registers
  under the FLAVOR key (`PubidUrn.define("doi_pfs")`) — never re-register
  under `"doi"`, that would overwrite the coded flavor's registration.
- **Routing**: `Pubid.parse` keeps routing `doi:`-faced strings to the
  coded flavor (registry keys sort `"doi"` first; both flavors claim the
  same prefixes). The alias is reached through `Pubid::DoiPfs.parse`.

## The parity gate

`spec/pubid/doi_pfs/parity_spec.rb` is the spike's whole point: over the
full doi inventory (coded fixtures + corpus rows + aliases + constructed
edge cases), both flavors must agree byte-for-byte on `to_s`, `to_hash`,
`to_urn`, `to_mr_string`, `to_pubid_urn` and fail on the same inputs with
`Pubid::Errors::ParseError`. Drift is a defect in the definition or the
compiler — never relax an expectation here.

Non-obvious inventory facts, learned the hard way:

- The combined faces (`https://doi.org/doi:10.1000/182`) are rejected by
  the CODED flavor too (the optional faces compose non-backtracking), so
  they are negatives.
- `Pubid.parse("10.1000/182")` routes to **UN** on main, pre-existing:
  the bare `10.` form is not a doi prefix-owner claim at a token
  boundary (`10.` followed by a digit), and un's token run accepts it.
  Only the scheme-faced form routes to Doi.
- The coded builder re-adds `"10."` to the registrar digits its grammar
  captures; the doi.pfs pattern captures the whole `10.` face, so the
  doi_pfs builder binds `prefix` directly. Model-level outputs are
  identical; only the bound wire map differs (`prefix: "1000"` vs
  `"10.1000"` in the artifact's corpus).

## v1 boundaries

Single-type schemes only, `kind: string` fields only, no free-standing
`stages:`/`supplements:` sections, no semantic decode rules (the
DAM-family problem) — see `pubid-grammar`'s `definitions/README.md` for
the language reference and the fail-closed validation rules.
