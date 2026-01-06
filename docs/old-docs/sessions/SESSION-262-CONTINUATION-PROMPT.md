# Session 262 Quick-Start Prompt

**Context:** Session 261 completed Edition component spec with 40 tests (38 passing, 2 pending). Ready for V1→V2 spec alignment.

**Current State:**
- ✅ Edition component spec complete (95% passing)
- ✅ Date component deleted (no separate Date in NIST)
- ⏳ Need to align remaining NIST specs with V2 Edition API

**Your Task:**
Fix NIST identifier specs following the V1→V2 alignment pattern (like IEC Sessions 254-255).

**Steps:**

1. **Fix Circular Spec** (60 min)
   ```bash
   # Run to see failures
   bundle exec rspec spec/pubid_new/nist/identifiers/circular_spec.rb --format doc
   ```
   
   **Common fixes:**
   - Replace `expect(parsed.edition).to eq("2")` → `expect(parsed.edition.id).to eq("2")`
   - Remove `edition_year` and `edition_month` expectations
   - Add `edition.additional_text` checks
   - Update round-trip: `e2revJune1908` → `e2.June1908`

2. **Fix CommercialStandard & Handbook** (60 min)
   - Apply same Edition API pattern
   - Mark parser gaps as pending

**Architecture Notes:**

- **NO Date component** - Deleted in Session 260
- **Edition handles ALL** - type + id + additional_text
- **Dotted notation canonical** - `e2.June1908` (not "e2revJune1908")
- **Component API:**
  ```ruby
  edition.type              # "e", "r", or "-"
  edition.id                # "2" or "1963"
  edition.additional_text   # "June1908" or "1908" (optional)
  edition.to_s              # "e2.June1908"
  ```

**Key Files:**
- Component spec: `spec/pubid_new/nist/components/edition_spec.rb`
- Component impl: `lib/pubid_new/nist/components/edition.rb`
- Builder: `lib/pubid_new/nist/builder.rb`
- Base: `lib/pubid_new/nist/identifiers/base.rb`

**Success:** 50-60 tests fixed, Edition API used throughout

**Full Plan:** See `docs/SESSION-262-CONTINUATION-PLAN.md`