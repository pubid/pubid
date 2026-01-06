# Session 265 Quick-Start Prompt

**Context:** Session 264 achieved CommercialStandard & Handbook spec alignment with V2 Edition API.

**Current State:**
- ✅ Circular spec complete (Session 262-263)
- ✅ CS & HB specs aligned (Session 264)
- ⏳ Modern series need V2 alignment

**Your Task:**
Align modern series identifier specs (SP, FIPS, IR, TN) with V2 Edition component API.

**Critical Architecture:**
- Edition component API: `edition.type`, `edition.id`, `edition.additional_text`
- NO Date component in NIST (deleted Session 260)
- Edition types: "e" (edition), "r" (revision), "-" (historical)
- Dotted notation: `e2revJune1908` → `e2.June1908`

**Steps:**

1. **Read V2 Specs** (20 min):
   ```bash
   # Read current V2 specs to understand patterns
   cat spec/pubid_new/nist/identifiers/special_publication_spec.rb
   cat spec/pubid_new/nist/identifiers/fips_spec.rb
   cat spec/pubid_new/nist/identifiers/interagency_report_spec.rb
   cat spec/pubid_new/nist/identifiers/technical_note_spec.rb
   ```

2. **Align SpecialPublication** (25 min):
   - Replace `revision` attribute with `edition.type = "r"`, `edition.id`
   - Replace `edition` string with `edition.type = "e"`, `edition.id`
   - Pattern: `SP 800-53r5` → edition.type="r", edition.id="5"

3. **Align FIPS** (20 min):
   - Replace `edition`, `edition_year`, `edition_month` with Edition component
   - Pattern: `FIPS 107e198503` → edition.type="e", edition.id="198503"

4. **Align InteragencyReport** (15 min):
   - Replace `edition` string with Edition component
   - Pattern: `IR 8200e2018` → edition.type="e", edition.id="2018"

5. **Align TechnicalNote** (15 min):
   - Replace `edition` string with Edition component
   - Pattern: `TN 1297e1993` → edition.type="e", edition.id="1993"

6. **Test All** (20 min):
   ```bash
   bundle exec rspec spec/pubid_new/nist/identifiers/special_publication_spec.rb
   bundle exec rspec spec/pubid_new/nist/identifiers/fips_spec.rb
   bundle exec rspec spec/pubid_new/nist/identifiers/interagency_report_spec.rb
   bundle exec rspec spec/pubid_new/nist/identifiers/technical_note_spec.rb
   ```

**Expected Result:** ~70-80% tests passing, 20-30% parser gaps

**V2 API Pattern (from Session 262/264):**
```ruby
# ✅ CORRECT - V2 Edition API
expect(parsed.edition).to be_a(PubidNew::Nist::Components::Edition)
expect(parsed.edition.type).to eq("e")   # or "r" or "-"
expect(parsed.edition.id).to eq("5")     # or year like "2021"
expect(parsed.edition.additional_text).to eq("June1908")  # if present

# ❌ WRONG - V1 strings
expect(parsed.revision).to eq("5")       # Don't do this!
expect(parsed.edition).to eq("2021")     # Legacy attribute
expect(parsed.edition_year).to eq(2021)  # Legacy attribute
```

**Key Files:**
- Reference: `spec/pubid_new/nist/identifiers/circular_spec.rb` (perfect example)
- Reference: `spec/pubid_new/nist/identifiers/handbook_spec.rb` (Session 264)
- Update: `spec/pubid_new/nist/identifiers/special_publication_spec.rb`
- Update: `spec/pubid_new/nist/identifiers/fips_spec.rb`
- Update: `spec/pubid_new/nist/identifiers/interagency_report_spec.rb`
- Update: `spec/pubid_new/nist/identifiers/technical_note_spec.rb`

**Success:** 4 modern series specs aligned, ready for documentation in Session 266!

**Full Plan:** See [`docs/SESSION-265-CONTINUATION-PLAN.md`](SESSION-265-CONTINUATION-PLAN.md)