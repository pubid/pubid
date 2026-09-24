# Identifier relations

How identifiers relate to each other, as a concept — independent of any API.
The predicates that implement these relations, with worked code examples, are
in the [API reference](API.md).

## Documents, editions, and states

An identifier names a **document**. A document can live through time without
changing its identity: `ISO 9001:2008` and `ISO 9001:2015` are two **editions**
of one document. The year on an ordinary standard says *which edition you
hold*, and a later edition replaces the earlier one, which is then withdrawn.

A **supplement** — an amendment, corrigendum, or similar — behaves
differently. It does not replace the document it modifies; it alters it, and
the two remain current **together**. `BS 7273-4:2015/A1:2021` is amendment 1
of BS 7273-4:2015: a document that exists alongside the base, not instead of
it.

## The composite: a document *as of* a supplement state

Publishers print consolidated forms — `BS 7273-4:2015+A1:2021`,
`EN 196-3:2005+A1:2008` — that read the base document together with its
amendment. A composite identifier names a **state of the document**, not a
separate publication: "BS 7273-4:2015, as amended by A1 (2021)".

## The supplement's year is part of its identity

An amendment is published once under its ordinal. `A1` of BS 7273-4:2015 was
published in 2021; there is no `A1:2022`. A different year under the same
ordinal can only mean the same document or a mistake — never a later edition
of the amendment. Systems therefore treat the supplement year as **identity,
not as a progressing date**: unlike a base standard's year, it never steps
forward while everything else stays fixed.

## Composites are editions of the consolidated document

Because amendments are cumulative — `+A2:2023` incorporates A1 as well — the
consolidated document has successive states, and each state is an **edition**
of it:

> `BS 7273-4:2015+A1:2021` is the prior edition of `BS 7273-4:2015+A2:2023`.

Two composites of one base differ by what they incorporate — by content, not
merely by date — so they relate as editions of one document, not as "the same
identifier with a different year".

## Supersession is not edition

The full chain — `BS 7273-4:2015` → `BS 7273-4:2015+A1:2021` →
`BS 7273-4:2015+A2:2023` — is a **supersession series**: each state is
succeeded, over time, by the next as the current version of BS 7273-4. But
the links are not edition links:

- The composite does not supersede the bare base. `BS 7273-4:2015` remains a
  current, valid reference; readers combine it with the amendment.
- An edition, by contrast, does supersede: when `ISO 9001:2015` arrived,
  `ISO 9001:2008` was withdrawn.

Keeping the two apart matters wherever systems merge catalogues, resolve
"latest version" requests, or validate citations: a superseded edition may be
replaced in a reference list; a supplemented base may not.

## Summary

| Relation | Meaning | Example |
|----------|---------|---------|
| Edition | Same document re-issued; the earlier is withdrawn | `ISO 9001:2008` → `ISO 9001:2015` |
| Supplement | One document modifies another; both stay current | `BS 7273-4:2015` with `BS 7273-4:2015/A1:2021` |
| Composite state | The document read together with its supplements | `BS 7273-4:2015+A1:2021` |
| Consolidated editions | Successive composite states of one base | `+A1:2021` → `+A2:2023` |
| Supersession series | States of one document ordered over time | `:2015` → `+A1:2021` → `+A2:2023` |
