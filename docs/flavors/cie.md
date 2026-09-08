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
