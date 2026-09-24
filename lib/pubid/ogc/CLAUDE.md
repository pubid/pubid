# OGC flavor notes

OGC `all_parts_edition_keys`: `year` is core identity, not an edition marker.

These notes were part of the root `CLAUDE.md`. Read them before you change `lib/pubid/ogc/` or `spec/pubid/ogc/`. The root file keeps the cross-flavor contract that every flavor obeys.

- **`all_parts_edition_keys` needed `revision` added AND `year` kept OUT — the
  hand-off's own suggested override was wrong about the second half.**
  `Identifier.all_parts_edition_keys` defaults to `%i[date year edition
  version]`. OGC's real edition/version discriminator is `revision`
  ("r19" in "12-128r19"), which that list never covered, so
  `"12-128r19".to_all_parts` did not collapse onto another revision of
  the same document. But `year` is **also** in the default list, and for
  OGC `year` is NOT an edition marker — it is the document's core
  `"<yy>"` identity token, the first half of the `"12-128"` core that
  `Renderer#render` requires (`"#{id.year}-#{id.number}"`). Stripping it
  (as the default list does, and as the hand-off's suggested override
  `%i[date year edition version revision]` would have kept doing) drops
  the prefix: `to_all_parts.to_s` rendered `"-128r19 (all parts)"`
  instead of `"12-128 (all parts)"`. The two symptoms — the missing
  prefix and the un-stripped revision — are the SAME root cause
  (`year` wrongly treated as a stripped key), not two separate issues,
  despite looking that way in the original repro. The correct override
  replaces the list entirely rather than extending it:
  ```ruby
  def self.all_parts_edition_keys
    %i[revision]
  end
  ```
  `date`/`edition`/`version` are harmless to omit — OGC declares none of
  them as attributes, and `#exclude` (which `without_parts` is built on)
  silently skips a name a class doesn't declare. Locked by
  `spec/pubid/ogc/all_parts_spec.rb` and
  `spec/pubid/all_parts_edition_keys_audit_spec.rb`.
