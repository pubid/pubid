# BSI flavor notes

BSI wrappers, adopted norms and cross-flavor sets.

These notes were part of the root `CLAUDE.md`. Read them before you change `lib/pubid/bsi/` or `spec/pubid/bsi/`. The root file keeps the cross-flavor contract that every flavor obeys.

- **One EC representation**: BSI's Expert-commentary suffix is modelled *only* as an outer `Identifiers::ExpertCommentary` wrapper (never a boolean on the inner adopted norm), so `#base_document`/`#base` peel cleanly. The builder's adopted path (`build_adopted_identifier`) is the single place that wraps supplements + EC; `Builder#build` must **not** re-wrap the adopted branch (that caused a double-`ExpertCommentary` that broke `base`).

## From the root note "`number`/`part`/`subpart` retyped to `:string` — tranche 1 of 3 (ansi, api, bsi, cen_cenelec, idf, jcgm)"

**Hand-off `bsi-set-cross-flavor-type` is closed as a side effect, and a pin on `main` is what proved it.** A `BS ISO 20400 + …` set holds *ISO* identifiers, and BSI declared `number`/`part`/`subpart` as its **own** `Bsi::Components::Code`, so `to_hash` raised `IncorrectModelError` — the cross-flavor attribute-type bug already fixed once on `Ieee::Identifiers::AdoptedStandard`. Retyping the three attributes to `:string` **removes the offending type outright**: there is no longer a BSI-specific component for a foreign identifier to mismatch, so no widening was needed. **74 BSI ids that previously raised on `to_hash` now serialize**, and the set round-trips through `from_hash` to the same class, hash and `to_s`. Merging `main` turned its `expect { id.to_hash }.to raise_error` pin red, which is how this surfaced; it now asserts the repair. Note the set's `#root` still reaches an `Iso::Components::Code` until tranche 3 — `root.number.to_s` is what relaton keys on, so the index contract holds either way.

## From the root note "Wrapper index keys (`root.number`) — the number was already there, one level down"

**The second half of the `number` landmine is a plain method shadowing a real attribute reader**, and `Bsi::Identifiers::AdoptedEuropeanNorm` still has it (`#number`, `#date`, `#part`, `#subpart` all delegate to `adopted_identifier`) — pre-existing, deliberately not removed here because `bsi/urn_generator.rb` reads `identifier.number` generically and had no other source. It now has one: that generator falls back to `identifier.root.number`, which recurses where the one-level delegation did not. That alone repaired **80 identity-free BSI URNs** — every `AddendumDocument`, `SupplementDocument`, `BundledIdentifier`, `Set`, `CommitteeDocument`, `StandaloneAmendment` and `AdoptedEuropeanNorm` in the corpus emitted the bare `urn:bsi:bs` or `urn:bsi:dd`, i.e. one URN per publisher for hundreds of documents. **0 URNs got shorter**; a non-wrapper's `root` is `self`, so ordinary identifiers are untouched. Removing the shadowing delegations themselves is now unblocked but is left to a follow-up (hand-off `bsi-set-cross-flavor-type`), which also records that `AdoptedEuropeanNorm` fails the round-trip on *values* rather than keys.

## From the root note "Parse-failure error contract — uniform across every flavor"

**The unanchored/anchored mismatch that silently returned nil for 49 identifiers.** `Builder#build_adopted_identifier` (`lib/pubid/bsi/builder.rb`) chooses among adoption shapes. Its first branch tested

```ruby
if adopted_str_clean.match?(/EN\s+(ISO\/IEC|IEC|ISO)/)   # UNANCHORED
  iso_iec_str = adopted_str_clean.sub(/^EN\s+/, "")      # ANCHORED
```

`"CEN ISO/TS 12180-1:2007"` **matches** the test — the substring `"EN ISO"` sits inside `"CEN ISO"` — but the anchored `sub` finds no `^EN ` and changes nothing. The branch then asks whether the (unchanged) string starts with `ISO`/`IEC`, which `"CEN …"` does not, so `adopted_id` stayed `nil` and `build` returned `nil` for the whole identifier. Anchoring the test to `/\AEN\s+(ISO\/IEC|IEC|ISO)/` lets a `"CEN …"` string fall through to the `start_with?("EN", "CEN", "CLC", …)` branch, which hands it to `Pubid::CenCenelec.parse` — where it belongs, and which parses it correctly.

**Measured**: 49 `DD CEN ISO/…` / `PD CEN ISO/…` identifiers in BSI's own `pass/` fixtures returned `nil` on `main`. **48 now build**, with `to_s` byte-exact against the input, real URNs (`urn:bsi:dd:12180:-1:2007`), MR slugs and a non-empty `root.number` — so they now key correctly in relaton-index instead of keying `""`. The 49th, `PD CEN ISO/TS 19166:2025 - TC`, now **raises** `Parslet::ParseFailed`; that is the honest outcome, since it never parsed, and reclassification moved it from `pass/` to `fail/`.

**Two lessons worth more than the fix.** (1) An **unanchored test paired with an anchored repair** is a silent-nil generator: the test admits inputs the repair cannot handle, and every branch below then misses. Check that a guard and its remedy use the same anchoring. (2) The classifier had bucketed all 49 into **`spec/fixtures/bsi/identifiers/pass/nil_class.txt`** — a `pass/` file named after the *failure mode*, holding `!input!` lines with an empty rendered half. A fixture bucket named for a failure is a defect report that has been filed and ignored; the file no longer exists after reclassification.

Note the 48 recovered ids raise `IncorrectModelError` on `to_hash` — pre-existing and unrelated: **565 of BSI's 1497 ids already did on `main`**. They join that group rather than forming a new one.
