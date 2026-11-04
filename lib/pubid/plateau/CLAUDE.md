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
