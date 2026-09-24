# GOST flavor notes

Foreign-adoption routing: the slash-attached prefix boundary that let another
flavor win the routing race.

These notes were part of the root `CLAUDE.md`. Read them before you change `lib/pubid/gost/` or `spec/pubid/gost/`. The root file keeps the cross-flavor contract that every flavor obeys.

## Foreign-adoption routing must use a token-boundary prefix check, not a literal-space check

`Gost::Builder#parse_foreign` (`lib/pubid/gost/builder.rb`) resolves the
foreign standard a GOST document adopts (`"GOST 58904-2020/ISO/TR
25901-1:2016"` → the adopted `"ISO/TR 25901-1:2016"`) by routing through
`Pubid.prefix_flavors` first — the same "registered prefix, not load order"
mechanism the earlier `gost-adoption-prefix-routing` fix introduced for
`"GOST 1437-2024 (ASTM D129-18)"` — and falling back to an exhaustive,
alphabetically-sorted try-every-flavor loop only when no registered prefix
matches.

`prefix_owner`'s boundary check used to require a **literal space** after the
matched prefix (`raw.start_with?("#{p} ")`). That misses a form where the
type token is attached to the publisher with a **slash** instead of a space —
`"ISO/TR 25901-1:2016"`, `"ISO/TS 10303-1:2014"` — because the character
after `"ISO"` is `/`, not a space. Those strings therefore matched no
registered owner and fell through to the exhaustive fallback loop, racing
every registered flavor's grammar alphabetically.

**The race was real, not theoretical: `Pubid::Iec`'s own grammar also accepts
a bare `"ISO/TR 25901-1:2016"`** (as its own identifier, not as a delegation
to ISO), and renders it `"ISO TR 25901-1:2016"` — a space, IEC's own
convention, not ISO's. `Pubid::Bsi` also accepts the string and correctly
delegates to `Pubid::Iso::Identifiers::TechnicalReport`, and normally wins the
race because `"bsi"` sorts alphabetically before `"iec"` — which is exactly
why the wrong render (`GOST R 58904-2020/ISO TR 25901-1:2016` instead of
`.../ISO/TR 25901-1:2016`) was rare and reproduced only intermittently, and
only under full-suite load (hand-off
`metanorma__pubid__gost-idt-order-dependent-render.md`; the hand-off chased
GC/allocation timing and `RenderingContext` memoization as candidate causes —
neither was it, and neither needed to be pinned down, since routing this
deterministically by prefix removes the race regardless of what let `bsi`
occasionally lose it).

**Fix**: `prefix_owner` now uses the same token-boundary rule the top-level
router already uses (`Pubid.prefix_match?` in `lib/pubid.rb` — a non-word
character, not specifically a space, ends the prefix). That method used to be
`@api private`; it is now public for exactly this reason — a second,
hand-copied boundary check in `Gost::Builder` would be the same
duplicated-logic-drifts-out-of-sync hazard this file documents elsewhere for
other flavors (found in code review, not the first pass: the initial fix
duplicated the regex locally instead of calling the shared method). **Do
not** re-duplicate this boundary check in a flavor's own builder; call
`::Pubid.prefix_match?(string, prefix)`.

**Not affected**: a jointly-owned prefix (`"ISO/IEC"`, `"ISO/IEC TR"`) already
falls through to the exhaustive fallback by design (`owners.one?` is false),
and every owner renders it identically — verified for both the bare and the
type-attached compound forms. Only the single-owner, slash-attached-type
shape (`"ISO/TR"`, `"ISO/TS"`, and by the same rule `"IEC/TR"` etc.) was
broken.

Locked by `spec/pubid/gost/foreign_adoption_routing_spec.rb`, which includes
a deterministic reproduction of the race (not a reliance on catching the rare
full-suite failure): it temporarily `Registry.unregister(:bsi)`s the usual
race winner and asserts routing still resolves to `Pubid::Iso` correctly —
proving the fix is prefix routing, not a lucky alphabetical ordering.
