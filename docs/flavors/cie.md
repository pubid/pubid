# CIE flavor notes

CIE builder attribute assembly.

Read this before you change `lib/pubid/cie/` or `spec/pubid/cie/`. The root
`CLAUDE.md` keeps the cross-flavor contract that every flavor obeys.

- **The builder offered every CIE type the same attribute hash, and the types
  do not share one attribute set.** `Builder#extract_attributes` unconditionally
  set `attributes[:s_prefix]`, but only `Standard`, `DualPublished` and
  `Identical` declare that attribute — `Conference`, `Bundle`, `Proceedings`,
  `Supplement` and `TutorialBundle` do not. lutaml reads only declared
  attribute names out of a constructor hash and reports nothing about the rest,
  so the surplus key was discarded in silence and nothing failed.

  It stopped being silent when `::Pubid::Identifier` began **refusing** an
  unknown constructor key (the cross-flavor contract in the root `CLAUDE.md`):
  **94 CIE identifiers immediately stopped parsing** with
  `ArgumentError: unknown attribute for Pubid::Cie::Identifiers::Conference:
  s_prefix` — every `CIE x005-1992`-style conference paper and every
  comma-list bundle. The fix is one line in `lib/pubid/cie/builder.rb`:
  select the assembled attributes down to those the chosen
  `identifier_class` actually declares, immediately before `new`.

  **The lesson is about where to filter, not about `s_prefix`.** A builder that
  assembles one hash for a family of types must narrow it per type; the
  alternative — letting the constructor drop what it does not recognise — is
  exactly the silence that hid this. `Pubid::Builder::Base#assign_attributes`
  already documents "silently skips unknown attributes" for the same reason,
  but CIE's builder constructs directly and so bypassed it.

  Locked by `spec/pubid/attribute_construction_spec.rb` ("builders offer only
  declared attributes"), which parses a conference paper, a bundle and an
  `s_prefix`-bearing standard, and asserts `Conference` still does **not**
  declare `s_prefix` — so re-adding the attribute to silence the spec would
  turn it red rather than green.

- **All 10 CIE types rendered plain under `to_s(annotated: true)`.** Every
  one composes its own string instead of going through `render`, so none
  reached the shared annotation hook; each now calls
  `annotate_plain_render` on the way out.

  **`Standard` needed more than a wrap.** Its body has three exits — the
  `slash_colon` language form and the legacy bare slash-year form both
  `return` early — and `annotate_plain_render` needs one. The composition
  moved verbatim into a private `render_plain`; `to_s` is two lines. The
  trap is the `private` keyword: written as a **section** it privatises
  every method below it, which swallowed `mr_type` — a public method the
  MR renderer calls. The section goes at the **end** of the class.
  `Bundle` keeps its `return "" unless ids&.any?` guard and wraps only the
  composed value.

  **`Supplement` was a different bug with the same symptom.** It is a
  wrapper: `number` is the supplement ordinal (`"1"`, which does not stand
  alone in `CIE 121-SP1:2009`) and the document's identity — number `121`,
  year `2009` — lives on `base`. Wrapping its `to_s` changed nothing,
  because the annotator only read the wrapper's own attributes. It is fixed
  by `Annotator#emit_tokens` walking `base`, not by anything in CIE.
