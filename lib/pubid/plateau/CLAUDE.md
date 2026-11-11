# PLATEAU flavor notes

Read this before you change `lib/pubid/plateau/` or `spec/pubid/plateau/`. The
root `CLAUDE.md` keeps the cross-flavor contract that every flavor obeys.

## pubid-scheme URN (issue #656)

`lib/pubid/plateau/pubid_urn_schema.rb`; rulings in `docs/URN-SCHEMES.adoc`
(`[[urn-plateau]]`). PLATEAU is the one flavor whose `number` stays an
Integer, so its core is `:int` (`core: [["number", :int]]`): `#00` is the core
`0`, and `00` in a URN is not canonical. The Annex type has no `number`; it
has no core, its document comes first along `base`, and its `letter` is an
atom. No input makes an Annex today, so the spec builds one by hand.

## Handbook volume label (本編 / 本編＋付録)

MLIT publishes Handbook #00 edition 5.0 twice on one date: `第5.0版　本編`
(main volume) and `第5.0版　本編＋付録` (main volume and appendix, one PDF);
edition 6.0 only as `本編＋付録`. `Identifiers::Handbook#volume` keeps that
label as Japanese text, as `edition` keeps `第X.Y版`. The grammar accepts it
only after an edition, separated by an ASCII or a full-width (U+3000) space,
with `＋` or ASCII `+`; the builder normalizes `+` to `＋`, and `to_s` writes
one ASCII space before it. The renderer prints the volume only after an
edition, so `exclude(:edition)` still renders a string that parses.
`volume` is in `==` and is `subset_strict`, so `#00 第5.0版` matches neither
labelled publication. A nil volume leaves no key in `to_hash`, so the
existing index-v2 rows keep their hash. The pubid-scheme URN carries it as
the `vol-` atom; `to_urn` is unchanged (it has no edition either). Locked by
`spec/pubid/plateau/handbook_volume_spec.rb`.

Known gaps, not caused by this change: a Technical Report drops an edition
and a volume without a diagnostic (the `handbook` rule matches any
`doc_type`), and `to_mr_string` raises for every Handbook with an edition
(the base `mr_edition` calls `edition.number` on a String).

## The grammar is baked here ahead of pubid-grammar

`data/parg/plateau.json` was compiled here from its own embedded `source`
plus the volume rule, at parsanol **1.3.114** (the version of the earlier
bake; force it with `gem "parsanol", "1.3.114"`, as
`pubid-grammar/scripts/bake-one.rb` does, because the binstub resolves the
latest installed gem). Until pubid-grammar takes hand-off
`pubid__pubid-grammar__plateau-handbook-volume`, its `grammars/plateau.parg`
is the OLD grammar. To change the grammar, extract the source with
`jq -j .source data/parg/plateau.json` (`-j`: the source has no trailing
newline, and one extra byte changes the checksum), edit, re-bake, then run
`bundle exec parsanol parg test data/parg/plateau.json`. Read the `.parg`
file as UTF-8: under a US-ASCII locale the parsanol lexer raises on `第`.
