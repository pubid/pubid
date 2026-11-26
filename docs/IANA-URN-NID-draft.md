# IANA URN Namespace Registration Draft: `urn:pubid:`

**Status: DRAFT — version 1, not yet submitted.** Issue pubid/pubid#789, part of
the SOTA 2027 credibility pillar (pubid#790).

This document is the NID application, authored from the codec as the source of
truth: the shared `urn:pubid:` codec in `lib/pubid/pubid_urn/`, the per-flavor
schemas in `lib/pubid/<flavor>/pubid_urn_schema.rb`, the design in
`docs/URN-SCHEMES.adoc` and the per-flavor scheme files
(`lib/pubid/<flavor>/urn.adoc`), the parity fixtures of
`spec/pubid/pubid_urn_contract_spec.rb`, and the grammars of
[pubid/pubid-grammar](https://github.com/pubid/pubid-grammar).

**Governing document — a correction to the issue text.** Issue #789 (and the
mission brief) cite "RFC 8865 (the formal NID process + the template)" and
check the result against "RFC 8848". Both citations are wrong, verified against
the IETF Datatracker (2026-11-26):

- **RFC 8865** is *"T.140 Real-Time Text Conversation over WebRTC Data
  Channels"* (Holmberg & Hellström, January 2021) — it defines no URN
  registration procedure.
- **RFC 8848** is *Session Signaling for Controlling Multiple Streams for
  Telepresence (CLUE)* (Kyzivat et al., January 2021) — likewise unrelated.

The operative document is **RFC 8141, "Uniform Resource Names (URNs)"
(Saint-Andre & Klensin, April 2017)**, which carries the whole process: the
registration template in **Appendix A**, the template guidance in **Section
6.4**, the Expert Review process in **Section 6.2** (with the standards-body
fast track in Section 6.3), and the discussion-list replacement in **Section
7.3**. This draft follows RFC 8141 exclusively. The template of RFC 3406 (the
predecessor, obsoleted by RFC 8141) carried two extra fields, *URN
Completeness* and *URN Specificity*; RFC 8141 folds both into *Purpose* and
*Syntax*. This draft makes the equivalent statements under those sections and
marks the mapping in the checklist at the end.

## 1. Registration information (RFC 8141 Appendix A template)

### Namespace Identifier

Request **`pubid`** of IANA (formal namespace).

- Valid NID syntax: `NID = (alphanum) 0*30(ldh) (alphanum)` (RFC 8141
  Section 2) — five lowercase alphanumerics.
- Case-insensitive per RFC 8141 Section 2.1; this document uses lowercase
  throughout.
- Free in the registry: `pubid` appears in neither the Formal nor the Informal
  URN Namespaces sections of the IANA registry (checked against
  <https://www.iana.org/assignments/urn-namespaces/urn-namespaces.xml>,
  registry `updated 2026-10-28`). The nearest registered NID,
  **`publicid`** (RFC 3151, SGML/XML formal public identifiers), is distinct
  (see Interoperability).

### Version

1

### Date

2026-11-26

### Registrant

Ribose Inc., author and maintainer of the PubID project
(<https://github.com/pubid/pubid>, the `pubid` gem on RubyGems).

Designated contact: `open.source@ribose.com` (the contact named in the gem
specification), on behalf of the PubID maintainers.

> **Owner decision before submission:** confirm the registrant name of record
> and the designated contact person (name, email, phone or postal address, as
> Appendix A requires) — the gemspec contact is used here as the default.

`pubid` is not a recognized standards development organization and this
application does not request the Section 6.3 fast track; it proceeds under the
Expert Review of Section 6.2.

### Purpose

1. **Kinds of resources identified.** `urn:pubid:` URNs identify **standards
   publications and their component documents** — international standards,
   technical reports and specifications, guides, amendments, corrigenda,
   drafts, consolidated editions, adoptions and bundles — whose identities are
   already expressed as *PubIDs*, the publication identifiers printed by
   standards development organizations (SDOs). One flavor exists per SDO or
   identifier family; at this draft's revision the codec carries **52
   registered flavors** (ISO, IEC, IEEE, ITU, NIST, IETF, ETSI, BSI, CEN/
   CENELEC, JIS, IHO, WMO, OASIS, OGC, W3C, ASTM, ASME, ANSI, GOST, and
   others), each declared by a schema in the codec.

2. **Scope and applicability.** Public, global use on the open Internet, by
   the bibliographic tooling that consumes PubIDs: the relaton family
   (bibliographic crawls and indexes, where the URN is the canonical slug
   source for HTTP paths — relaton/relaton#441), the Metanorma document
   pipeline, and language mirrors (pubid-rs in Rust, pubid-ts in TypeScript).
   The URNs name *documents* (works, versions, and supplements of standards),
   never persons or network endpoints.

3. **Benefit to the intended community.** Today each SDO's identifiers exist
   in dozens of spelling and stage variants, and the organizations' own URN
   namespaces are faithful only to what their registered grammars carry — for
   example the ISO namespace (`urn:iso:std:`, RFC 5141) has no year slot, so
   `ISO 4507:2007` encodes as `urn:iso:std:iso:4507`. The `pubid` namespace
   gives every flavor **one persistent, lossless, canonical URN** that
   round-trips through the full typed model
   (`Pubid.parse_urn(id.to_pubid_urn).to_hash == id.to_hash`, corpus-wide),
   so software can cite, store, compare and resolve publication identity
   without re-parsing printed strings.

4. **Relationship to existing namespaces and schemes.** The `pubid` namespace
   is a **parallel, complementary encoding** alongside the organizations'
   registered NIDs (`iso`, `ietf`, `itu`, `ieee`, `etsi`, `isbn`, `doi`,
   `issn`, `ogc`, `oasis`, `wmo`, `mrn`, and others). It does not replace any
   of them: the outward-facing render of each flavor stays the organization's
   own form (`Identifier#to_urn`), while `urn:pubid:` is the lossless
   interchange and machine form. No existing URI scheme conflict: the URNs are
   ordinary names under the `urn:` scheme (RFC 8141).

5. **Kinds of software that can use or resolve them.** Any RFC 8141-conformant
   URN parser can validate them (the strings are pure ASCII and need no
   percent-encoding); the codec implementations — the Ruby gem `pubid`
   (RubyGems), pubid-rs (Rust, with resolver and CLI), pubid-ts (TypeScript,
   npm) — decode them back to the full typed identifier model; the
   <https://www.pubid.com> playground renders and round-trips them
   interactively.

6. **Resolution services.** No global resolution infrastructure is implied
   (see Resolution).

7. **Standards constituent.** Not a constituent part of an IETF or other
   recognized standards body's standard at this time. Should that change, the
   registrant will say so in a revised registration and the Section 6.3
   fast-track procedure may be invoked.

### Syntax

#### Overall form

`urn:pubid:` URNs use the plain `assigned-name` form of RFC 8141 Section 2 —
`"urn" ":" NID ":" NSS` — with **no r-components, q-components, or
f-components**. Per the template's rule, their semantics are therefore
undefined in this namespace. In particular the segment `f` inside the NSS is a
namespace-specific facet marker and is **not** the RFC 8141 f-component (which
follows a `#`).

#### ABNF (declared URN syntax)

The ABNF below is the codec's real grammar, implemented in
`lib/pubid/pubid_urn/` (encoder, decoder, escape, schema, paths) and published
in `docs/URN-SCHEMES.adoc`:

```
namestring   = "urn:pubid:" pubid-urn          ; RFC 8141 §2 frame, NID = "pubid"
pubid-urn    = flavor ":" node *(":" node) [ ":f" 1*(":" facet) ]
flavor       = name                            ; the flavor segment of the
                                               ; identifier's "_type" ("iso",
                                               ; "cencenelec", "3gpp", ...)
node         = type-token *( ":" core ) *( ":" atom )
type-token   = name / flavor "." name          ; qualified when the node is of
                                               ; another flavor
core         = value / "~"                     ; "~" = absent, only before a
                                               ; present core value
atom         = name "-" atom-value
atom-value   = value / list / nested / nested *( "," nested )
list         = item *( "," item )              ; item = value / "~"
nested       = "(" flavor ":" node *( ":" node ) [ ":f" 1*(":" facet) ] ")"
facet        = node-index "." name "-" ( value / list )
name         = ALPHA-LOWER *( ALPHA-LOWER / DIGIT )
value        = *( ALPHA / DIGIT / "." / "_" / "-" / escape )
escape       = "~" 2HEXDIG-UPPER               ; one UTF-8 byte
```

Constraints the grammar carries in prose form (all enforced by the codec):

- **Type tokens, atom prefixes and facet names** match `name` — a lowercase
  first letter, then lowercase letters and digits — so none can contain the
  `-` that ends an atom prefix, the `.` that qualifies a foreign-flavor token,
  or read as a value. The tokens `f` and `type` are **reserved** (`type`
  already names types, not documents, as `urn:pubid:iso:type:technical-report`).
- **Nodes go root first** along the `base` chain: a supplement (`amd`, `cor`,
  ...) is a node after the node it modifies, so all supplements of a document
  share that document's path prefix.
- **Positional core.** A value a type always has (normally the document
  number) is a bare positional segment; the flavor's schema fixes its order.
  A core value absent in the middle of the core is `~`; absent ones at the end
  are dropped. No `:` segment is ever empty — no `::` can occur (which would
  collapse to `//` in the HTTP-path slug form).
- **Prefixed atoms.** A value that can be absent is an atom `prefix-value`,
  found by its prefix and not by position; an absent atom leaves no segment.
  Each type's atoms have one canonical schema-declared order; the parser
  refuses an atom out of order, repeated, or unknown.
- **Typed values.** Schemas give each atom and facet a kind — `:string`,
  `:bool` (`true`/`false`), `:int` (decimal, so `01` is not canonical),
  `:list` (`,`-separated strings), `:bools`, and `:id`/`:ids` (nested bodies in
  brackets) — and the parser casts by kind.
- **Length.** Both sides bound URNs at 16,000 characters (escapes reach 9
  characters per CJK character, so the printed identifier's 1,000-character
  bound is too small). The parser is linear-time (anchored, non-backtracking
  patterns).

#### Conformance with the fundamental URN syntax (RFC 8141 Section 2)

Every emitted URN is **pure ASCII** and every character of its NSS is drawn
from RFC 3986 `pchar` as incorporated by RFC 8141 — `unreserved`
(`ALPHA / DIGIT / "-" / "." / "_" / "~"`), the sub-delims `(`, `)`, `,`, and
`:` — so the *entire* namespace needs **no percent-encoding at all**, and no
`?`, `#` or raw `/` occurs. Non-ASCII (including CJK) never appears raw: the
escape `~XX` encodes one UTF-8 byte as uppercase hex.

#### Special character-encoding rules

- The escape sequence is **`~XX`** (uppercase hex, one UTF-8 byte). The
  namespace deliberately does **not** use RFC 3986 percent-encoding for its
  internal escape: `%` would invite servers and proxies to decode `%2F`
  (and friends) *before* routing, which the URN's second life as an HTTP path
  slug forbids. `~` is RFC 3986 unreserved and carries no path semantics.
  A conformant processor treats `~XX` as an opaque value character: it is a
  namespace-internal rule, not URI-level escaping.
- An absent core value is the single `~` (twice the length of an escape's
  minimum, so it can never be confused with one).
- A **core value whose shape reads as structure** gets its first character
  escaped: the structural shape test matches a lowercase-letter-led token
  (a type token, `f`, an atom prefix) or a `<name>.<name>` two-part token (a
  foreign-flavor type token). So the document number `amd` encodes as
  `~61md` and `iec.is` as `~69ec.is`, while `9001`, `802.11`, `800-53` and
  `G.711` stay bare. The test reads **only the shape of the segment**, never
  the set of schemas that exist, so published URNs keep their meaning when a
  flavor, a type token or an atom is added later.

#### URN-equivalence rules

- The NID is case-insensitive (RFC 8141 Section 2.1); the NSS is
  **case-sensitive**, with no additional equivalences between spellings
  (no case folding, no hyphen equivalences, no quote equivalences).
- **One identifier has exactly one URN.** The namespace defines its
  canonicalization as *re-encode and compare*: a parser decodes the NSS,
  rebuilds the identifier, re-encodes it, and refuses the input with a
  `UrnParseError` unless the re-encoded string is byte-identical (so a
  needless escape, an atom out of schema order, or a trailing `~` is a syntax
  error, not a variant). Consequence: URN-equivalence is exact byte equality
  after the mandatory canonicalization — the comparison eliminates false
  negatives by refusing non-canonical forms rather than by normalizing them.
- Spelling-only data (e.g. `original_code` "E" for "en", an edition printed
  "Ed 13") is carried in the trailing `f` facet group and is **ignored by
  identity**: with every `f` group cut, the URN still decodes to an identifier
  equal (`==`, hash-equal, `===`) to the full one. A consumer may cut `f` to
  get one slug per document at the cost of the full round trip; the registered
  slug form (`to_slug`) keeps it.

#### Non-URN identifier system input

PubIDs arrive as printed strings full of characters the URN syntax would
reserve (`/`, spaces, non-ASCII, ...). Translation into the namespace is
performed **only by the codec** (never by naive string placement): the typed
model is parsed first, then encoded through the schema, so every reserved
character is escaped per the rules above and the result conforms to RFC 8141.

### Assignment

- **Mechanism and authority.** Assignment is **closed and grammar-driven**.
  Only identifiers built by the codec mint URNs. A URN begins with a *flavor*
  segment; flavors are declared by the registrant when a flavor lands, as a
  **declarative schema** (`Pubid::<Flavor>::PubidUrnSchema`,
  `lib/pubid/<flavor>/pubid_urn_schema.rb`) that names the flavor's type
  tokens, its positional core, and its atoms, and is derived from the same
  declarative grammar layer (PFS — the PubID Format Schema) that defines the
  flavor's parsing, maintained in the
  [pubid-grammar](https://github.com/pubid/pubid-grammar) repository. There is
  no open, first-come, first-served or delegated assignment of flavor
  segments; a third party requests assignment from the registrant.
- **Uniqueness.** Uniqueness is structural, not allocated: the encoding is
  **injective over the typed model** (two different identifiers never share a
  URN) and canonical (one identifier never has two URNs). Both properties are
  machine-checked corpus-wide by
  `spec/pubid/pubid_urn_contract_spec.rb`, gate (c) and the canonical-form
  gate. Within a flavor, type tokens and atom prefixes must be unique (the
  schema layer refuses duplicates at declaration time).
- **Stability of the syntax under growth.** Adding a flavor, type token or
  atom cannot change the meaning of an already-published URN, because the
  structure test reads segment *shapes* only (see Syntax). A change that
  would move a published slug fails the corpus contract until a person
  approves it (the wire-format lock recorded in `docs/URN-SCHEMES.adoc`).

### Security and Privacy

- **Low-profile public declarations.** The URNs declare public information —
  the identity of standards publications. No personal data, no private
  information, nothing enumerable that invites directory harvesting.
- **Comparison safety.** The security issues of identifier comparison
  (RFC 6943) are mitigated by the mandatory canonicalization: a non-canonical
  spelling does not silently compare equal or unequal — it is rejected — so
  two processors can only ever disagree by failing loudly, never by silently
  aliasing two distinct documents. Case sensitivity is fixed (NSS
  case-sensitive, NID case-insensitive per RFC 8141).
- **Untrusted input handling.** `Pubid.parse_urn` bounds input at 16,000
  characters before parsing; the parser is linear-time and anchored (no
  catastrophic backtracking surface); every failure — malformed body, unknown
  flavor or token, value that decodes but cannot be cast into the typed model,
  unbalanced brackets — surfaces as a single typed error class
  (`Pubid::Errors::UrnParseError`), with the original error as its cause. No
  input shape causes a silent drop or a partial identifier.
- **Path safety.** The URN is simultaneously an HTTP path slug (each `:`
  segment a `/` segment, bijectively). The character set forbids `/`, `%`,
  `?`, `#` and empty segments by construction, so the form cannot smuggle
  path traversal, query or fragment syntax, or rely on server-specific
  percent-decoding behavior.
- **Spoofing (RFC 8141 Section 8).** Flavor segments and type tokens are
  assigned only by the registrant's schema registry; the IANA registry entry
  for the NID names the registrant, so the namespace's authority chain is
  checkable. Information in this declaration is advisory per RFC 8141.

### Interoperability

- **`pubid` vs `publicid`.** The registered NID `publicid` (RFC 3151) encodes
  SGML/XML *formal public identifiers* — it is the closest registered neighbor
  in spirit, and distinct in name, syntax and scope: RFC 3151 carries
  SGML-public-id escaping (`+`, `/`, `:` transliterations) and no typed
  document model, while `urn:pubid:` carries the flavor/type/atom structure
  declared here. A `urn:publicid:` URN is never valid in this namespace and
  vice versa. The PWID namespace (`pwid`, archived web resources) is likewise
  unrelated.
- **Relationship to organization NIDs.** The flavors mirror namespaces owned
  by the organizations themselves (`iso`, `ietf`, `itu`, `ieee`, `etsi`,
  `isbn`, `doi`, `issn`, `ogc`, `oasis`, `wmo`, `mrn`, ...). Overlap is by
  design and safe by construction: the organization's NID carries that
  organization's *official* form (which may be lossy — the ISO namespace per
  RFC 5141 has no year slot), while `urn:pubid:` carries the complete typed
  identity. A consumer that resolves both for one document compares them
  through the decoded typed model, not as strings. The namespace defines no
  mapping table; the codec implements the correspondence per flavor.
- **Generic URN processing.** The URNs are processable by any RFC 8141
  parser: ASCII only, no percent-encoding required, no r/q/f-components, no
  reserved-character edge cases beyond the `~XX` value escape, which is
  invisible to a generic parser (every `~XX` string is a legal NSS character
  sequence).
- **The `f` segment.** A generic parser must not read the NSS segment `f` as
  the RFC 8141 f-component: the f-component follows `#`, and `urn:pubid:` URNs
  use no fragments.
- **Case.** Mixed-case NID spellings (`URN:PUBID:...`) are legal RFC 8141 and
  resolve to this namespace; the NSS is case-sensitive and the canonical form
  is lowercase-NID.

### Resolution

**No global resolution mechanism is currently intended or anticipated** —
this namespace declares no r-component semantics and registers no resolution
service in the RFC 2276 / RFC 2483 sense.

Consumer-side resolution exists and is the deployment path:

- **relaton / relaton-api**: the URN (via its bijective slug transform) is the
  HTTP path slug of every indexed document — resolution is ordinary HTTP on
  the consumer's own service (relaton/relaton#441).
- **pubid-rs** (Rust): resolver and CLI (pubid-rs#23), with the WASM build
  powering browser-side playgrounds (pubid-rs#22).
- **pubid-ts** (TypeScript/npm): the parse surface mirrors the codec, with
  corpus byte-parity against the Ruby gem.
- **<https://www.pubid.com>**: the documentation site and interactive
  playground.

If the registrant later introduces a publicly advertised resolution service,
the requirements for advertisement will be added to a revised registration
(version 2), per RFC 8141 Section 6.4.6.

### Documentation

- **The codec (normative implementation):** `lib/pubid/pubid_urn/` in
  <https://github.com/pubid/pubid> — encoder, decoder, escape, schema, paths;
  the Ruby gem `pubid` on RubyGems.
- **The design document:** `docs/URN-SCHEMES.adoc` (the index) plus one
  per-flavor scheme file `lib/pubid/<flavor>/urn.adoc` (51+ files; IHO and
  IALA are the full formal exemplars).
- **The grammars:** <https://github.com/pubid/pubid-grammar> — the declarative
  PFS layer and parsanol-syntax formal grammars shared by the Ruby, TypeScript
  and Rust implementations.
- **The corpus:** <https://github.com/pubid/pubid-testsuite> and the pass
  fixtures under `spec/fixtures/` in the gem, gated by
  `spec/pubid/pubid_urn_contract_spec.rb`.

### Additional Information

- **The two-URN design.** Every flavor exposes two URN forms: the
  organization's registered form (`#to_urn`, faithful to that namespace's own
  grammar, possibly lossy) and this namespace's lossless form
  (`#to_pubid_urn`). The table in `docs/URN-SCHEMES.adoc` records the split.
- **Roadmap context.** The namespace is the credential layer of the PubID
  program's URN story (pubid#790, credibility pillar): the same codec is
  mirrored in Rust (resolver, CLI, WASM playground) and TypeScript (npm), with
  cross-implementation parity gates.
- **No known conflicting registration** in the Formal or Informal URN
  Namespaces sections of the IANA registry, and no conflicting URI scheme.

### Revision Information

Not applicable — version 1, first registration.

## 2. Submission path (RFC 8141 Section 6.2 — Expert Review)

1. **Finalize this template** — in particular confirm the registrant
   name of record and designated contact (marked above as an owner decision).
2. **Send the completed template for review.** RFC 8141 Section 6.2 step 2 and
   Section 7.3 name the list: **urn@ietf.org**. (The issue text says
   *urn-nb@ietf.org* — the URN Namespace Board address of the RFC 3406 era;
   RFC 8141 Section 7.3 discontinued the RFC 3406 discussion list
   (`urn-nid@apps.ietf.org`) and replaced it with `urn@ietf.org`, which is the
   list this draft uses. Verified against the RFC text, 2026-11-26.)
3. **Iterate with the Designated Experts** until approval. The IANA registry
   currently names the expert team: Peter Saint-Andre (team leader), Dale
   Worley, Juha Hakala, Stephanie Nitsche, Lars Svensson. Expect iterations;
   RFC 8141 repeats steps 1–2 to address comments. Long lead time is normal —
   months, as issue #789 anticipates.
4. **IANA records the NID.** On the Designated Experts' approval (no
   standardization action involved), IANA adds `pubid` to the *"Uniform
   Resource Names (URN) Namespace Definitions"* registry, Formal URN
   Namespaces section (registration rule: Expert Review per RFC 8141
   Section 6), pointing at this document.
5. **Revisions** repeat the same steps; any revised registration MUST describe
   the differences from prior versions (RFC 8141 Section 6.2).

**Status of this draft:** pre-submission. Nothing has been sent to the review
list; the template above is the material for step 2.

**Follow-ups after IANA acceptance:**

- the registry entry appears in the IANA "Formal URN Namespaces" list — cite
  it from `docs/URN-SCHEMES.adoc` and the per-flavor scheme files;
- add the registration-status line to the site's URN scheme docs
  (pubid.github.io / www.pubid.com) — not done in this change, which lands the
  pointer in the issue only;
- update the mirrors' documentation (pubid-rs, pubid-ts) to cite the formal
  registration.

## 3. Evidence appendix

### 3.1 Corpus attestation (the syntax evidence)

The namespace's declared syntax is exercised over the full pass-fixture corpus
by `spec/pubid/pubid_urn_contract_spec.rb` (registry-driven, one example per
flavor), which machine-checks, for **every** corpus identifier:

| gate | assertion |
|---|---|
| (a) emit | every identifier emits a URN — a schema gap is a loud error, never a silent drop |
| (b) round-trip | `Pubid.parse_urn(id.to_pubid_urn).to_hash == id.to_hash` |
| (c) injective | two different identifiers never share a URN |
| (d) path-safe | `/\Aurn:pubid:[A-Za-z0-9._~,()\-:]+\z/`, no `::`, no trailing `:` |
| (e) facet-cut | with every `f` group cut, the decoded identifier is `==`, hash-equal and `===` to the full one |

**Measured at this draft's revision** (pubid `main` @ `64250fab`,
2026-11-26, by the contract spec's input-counting method): **101,917 unique
pass-corpus identifiers across 52 flavors**, each of which emits, round-trips,
collides with nothing and stays path-safe. (The program figure quoted in issue
#789, 100,081, is the same attestation at its writing date; the corpus grows
with every classification round.) adobe and sae, which have no fixture corpus,
are exercised over a fixed literal list. Reproduce with:

```
bundle exec rspec spec/pubid/pubid_urn_contract_spec.rb
```

### 3.2 Parity gates

The same corpus is the cross-implementation parity evidence: the TypeScript
mirror (pubid-ts) regenerates its fixtures from the corpus and is gated to
**byte-identical URNs against the Ruby gem** (pubid-ts#162: 99,686-row byte
parity at its landing; the stage-slot gaps found then — 30.20/50.00/dcor/dish
— were closed gem- and mirror-side by pubid#787, which regenerated the parity
fixtures). The Rust mirror (pubid-rs) follows the same testsuite corpus. The
grammars themselves are language-independent artifacts shared by all three
implementations (pubid-grammar).

### 3.3 Five-series examples

Real corpus identifiers, encoded and verified round-trip by the codec at this
draft's revision:

| printed identifier | `urn:pubid:` form |
|---|---|
| `ISO/IEC 13818-1:2015/Amd 3:2016` | `urn:pubid:iso:is:13818:co-IEC:part-1:year-2015:amd:3:co-IEC:year-2016` |
| `IEEE Std 802.11-2012/Amd 1` | `urn:pubid:ieee:std:802:part-11:year-2012:stage-Std:amd:1:f:0.sep-.` |
| `ITU-T G.711 (11/1988)` | `urn:pubid:itu:rec:711:sector-T:series-G:year-1988:month-11` |
| `NIST SP 800-53 Rev. 5` | `urn:pubid:nist:sp:800-53:pub-NIST:series-SP:subseries-800:edtype-r:ed-5:f:0.edprefix-~20Rev.~20` |
| `IHO B-1 1.0.0` | `urn:pubid:iho:b:1:ed-1.0.0` |

Notes the examples demonstrate: the copublisher atom appears twice at two
chain depths (ISO, `co-IEC` on the base and on the amendment); the spelling
facet `f:0.sep-.` records the IEEE separator spellings while identity ignores
them; the `f:0.edprefix-~20Rev.~20` facet carries the printed "Rev." spelling
of the NIST edition; the IHO flavor's dotted edition encodes losslessly where
its official MRN form (`urn:mrn:iho:pub:bathy:b1:1.0.0`) is the organization's
own parallel namespace; `~20` is the escape of one space byte.

## 4. Template-completeness checklist (RFC 8141 Appendix A)

| Appendix A field | section of this document |
|---|---|
| Namespace Identifier | §1 Namespace Identifier |
| Version | §1 Version |
| Date | §1 Date |
| Registrant | §1 Registrant (contact confirmation pending) |
| Purpose | §1 Purpose (RFC 3406's *URN Completeness* → items 1–3; *URN Specificity* → items 1–2; *Community* → items 2, 5; *Ensemble* — field withdrawn by RFC 8141, not used) |
| Syntax | §1 Syntax (structure, encoding rules, equivalence, conformance, non-URN input) |
| Assignment | §1 Assignment |
| Security and Privacy | §1 Security and Privacy |
| Interoperability | §1 Interoperability |
| Resolution | §1 Resolution |
| Documentation | §1 Documentation |
| Additional Information | §1 Additional Information |
| Revision Information | §1 Revision Information (n/a, version 1) |
| Process steps (Section 6.2/7.3) | §2 Submission path |
