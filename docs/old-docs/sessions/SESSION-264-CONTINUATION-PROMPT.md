# Session 264 Quick-Start Prompt

**Context:** Session 263 achieved Circular 100% (50/50) with SupplementIdentifier architecture implemented.

**Current State:**
- ✅ Circular spec complete with proper V2 Edition API
- ✅ SupplementIdentifier pattern following ISO/IEC
- ✅ All 14 CIRC parser patterns working
- ⏳ Other series need V2 alignment

**Your Task:**
Align CommercialStandard and Handbook identifier specs with V2 Edition component API.

**Critical Architecture:**
- Edition component API: `edition.type`, `edition.id`, `edition.additional_text`
- SupplementIdentifier pattern: Supplements wrap base identifiers
- NO Date component in NIST (deleted Session 260)
- Edition.additional_text handles all month/year info

**Steps:**

1. **Read V1 CommercialStandard Spec** (20 min)
   ```bash
   cat archived-gems/pubid-nist/spec/nist_pubid/document/commercial_standard_spec.rb
   ```
   Document: edition patterns, Emergency patterns (e-prefix), supplement patterns

2. **Align CS Spec** (40 min) in `spec/pubid_new/nist/identifiers/commercial_standard_spec.rb`:
   - Replace `edition` string with `edition.id`
   - Add `edition.type` checks
   - Handle CS Emergency (e-prefix numbers)
   - Expected: ~35 tests

3. **Read V1 Handbook Spec** (20 min)
   ```bash
   cat archived-gems/pubid-nist/spec/nist_pubid/document/handbook_spec.rb
   ```
   Document: edition patterns (e2021), revision patterns (r1), part patterns

4. **Align HB Spec** (40 min) in `spec/pubid_new/nist/identifiers/handbook_spec.rb`:
   - Replace `edition` string with `edition.id`
   - Add `edition.type` checks (e vs r)
   - Handle edition years vs revision numbers
   - Expected: ~35 tests

5. **Test Both** (10 min):
   ```bash
   bundle exec rspec spec/pubid_new/nist/identifiers/commercial_standard_spec.rb
   bundle exec rspec spec/pubid_new/nist/identifiers/handbook_spec.rb
   ```

**Expected Result:** ~70 tests aligned, following Circular pattern

**V2 API Pattern (from Session 262/263):**
```ruby
# ✅ CORRECT - V2 Edition API
expect(parsed.edition).to be_a(PubidNew::Nist::Components::Edition)
expect(parsed.edition.type).to eq("e")   # or "r" or "-"
expect(parsed.edition.id).to eq("2")     # or year like "2021"
expect(parsed.edition.additional_text).to eq("June1908")  # if present

# ❌ WRONG - V1 strings
expect(parsed.edition).to eq("2")        # Don't do this!
expect(parsed.edition_year).to eq(2021)  # Legacy attribute
```

**Key Files:**
- V1 CS: `archived-gems/pubid-nist/spec/nist_pubid/document/commercial_standard_spec.rb`
- V1 HB: `archived-gems/pubid-nist/spec/nist_pubid/document/handbook_spec.rb`
- V2 CS: `spec/pubid_new/nist/identifiers/commercial_standard_spec.rb`
- V2 HB: `spec/pubid_new/nist/identifiers/handbook_spec.rb`
- Reference: `spec/pubid_new/nist/identifiers/circular_spec.rb` (perfect example)

**Success:** CS and HB specs aligned, ready for modern series in Session 265!

**Full Plan:** See [`docs/SESSION-264-CONTINUATION-PLAN.md`](SESSION-264-CONTINUATION-PLAN.md)
