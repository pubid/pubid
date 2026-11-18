# arXiv flavor notes

- **Origin (relaton#42)**: relaton's `Relaton::Arxiv` keys its `Db` cache with
  `Pubid::Arxiv::Identifier`, routes by `Pubid::Arxiv.prefixes` (`["arXiv"]`)
  and calls `GET https://export.arxiv.org/api/query?id_list=<id>` with
  `to_s(with_publisher: false)`. Source of the forms:
  https://info.arxiv.org/help/arxiv_identifier_for_services.html
- **Grammar**: `data/parg/arxiv.json`, baked from `grammars/arxiv.parg` with
  the gem's pinned engine (`bundle exec parsanol parg compile …`). The source
  was written here and handed to pubid-grammar to adopt byte-identical
  (hand-off `metanorma__pubid-grammar__arxiv-grammar`); until it lands there,
  the embedded `source` of the artifact is the only copy. Rebake from the
  pubid-grammar copy once it exists.
- **The grammar checks shape, the Builder checks ranges.** The grammar takes
  any `YYMM.NNNN[N]` and `archive[.SC]/YYMMNNN`; `Builder` rejects a month
  outside 01–12, a 4-digit number outside 0704–1412, a 5-digit number before
  1501, an old id outside 9108–0703, `v0` and a version with a leading zero
  (`v01` would render `v1`, so `to_s` would not be exact). It raises
  `ArgumentError`, which `Identifier.build_identifier` turns into
  `Pubid::Errors::ParseError` — the ISBN shape, with the input guards kept
  outside that rescue.
- **Components**: `archive`/`subject_class` (old ids only), `year` (4 digits;
  old ids 91–99 → 19xx, else 20xx; new ids always 20xx), `month`, `number`
  (the inherited `:string`, sequence only, leading zeros kept: `00001`,
  `001`) and `version` (Integer, nil when absent). `root.number` is the
  sequence number: it is never empty, but it narrows the index less than a
  full `2301.00001` would.
- **Rendering**: always the canonical colon form `arXiv:<id>`, whatever
  prefix the input used (`arxiv 2301.00001` → `arXiv:2301.00001`; the classify
  run records these as `!input!rendered`). `with_publisher: false` is handled
  in the renderer, not by `Renderers::PublisherStripper`, because the stripper
  cuts only before a space, `-`, `/` or `.`, never before `:`;
  `publisher_prefixes` is `[]` for that reason. No `publisher` component is
  stored: the token is constant and every surface prints it.
- **Matching**: `subset_strict :archive, :subject_class, :year, :month,
  :number`, so the version is the only `===` wildcard — `arXiv:2301.00001`
  matches `…v1` and `…v2`, a new id never matches an old one, `math/…` does
  not match `math.GT/…`, and an empty hand-built reference matches nothing.
  `==` stays exact.
- **`year` is identity, not an edition.** The shared `#exclude` treats
  `:year`/`:date` as the edition wildcard, which would turn `2301.00001`
  into `0001.00001` and make `matches?(…, ignore: [:year])` match a paper of
  another month. `Identifier#exclude` therefore ignores `:year`, `:date` and
  `:month`; ignore `:version` to match across versions.
- **`to_urn` returns `to_pubid_urn`.** arXiv has no official namespace, and
  the base fallback `urn:arxiv:<number>:<year>` collided (`2301.00001` and
  `2302.00001` shared one URN).
- **Known, left open**: `from_hash`/`parse_urn` do not run the builder's
  range checks (a hand-made `month: 13` renders `2313.…`); the grammar is
  looser than the real archive list (`a/9901001` parses); a new-form id in the
  2090s is accepted; the MR string is the bare number (ISBN's is empty);
  annotated rendering adds a span only to a version-less new id, because the
  number is glued to `v` or to YYMM.
- **Routing**: `Pubid.parse` matches prefixes case-sensitively, so it routes
  `arXiv:…` and `arXiv …` only; `Pubid::Arxiv.parse` accepts every spelling,
  and bare ids.
- **URN**: `#to_pubid_urn` only (`docs/URN-SCHEMES.adoc` `[[urn-arxiv]]`);
  arXiv registers no official URN namespace.
