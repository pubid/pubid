# Session 267 Quick-Start Prompt

**Context:** Session 266 completed documentation and archival. Ready for final NIST series alignment.

**Current State:**
- ✅ Circular: 50/50 (100%)
- ✅ CS & HB: 54/76 (71%)
- ✅ IR & TN: 78/140 (55.7%)
- ⏳ SP & FIPS: Need V2 alignment

**Your Task:**
Align SpecialPublication and FIPS identifier specs with V2 Edition component API, completing modern series alignment.

**Critical Architecture:**
- Edition component API: `edition.type`, `edition.id`, `edition.additional_text`
- NO Date component in NIST (deleted Session 260)
- Edition types: "e" (edition), "r" (revision), "-" (historical)
- Dotted notation: `e2revJune1908` → `e2.June1908`

**Steps:**

1. **Read Current Specs** (15 min):
   ```bash
   # Read V2 specs
   cat spec/pubid_new/nist/identifiers/special_publication_spec.rb
   cat spec/pubid_new/nist/identifiers/fips_spec.rb
   ```

2. **Align SpecialPublication** (50 min):
   - Replace `revision` attribute with `edition.type = "r"`, `edition.id`
   - Replace `edition` string with `edition.type = "e"`, `edition.id`  
   - Pattern: `SP 800-53r5` → edition.type="r", edition.id="5"
   - Pattern: `SP 304Ae2017` → edition.type="e", edition.id="2017"
   - Test after changes:
     ```bash
     bundle exec rspec spec/pubid_new/nist/identifiers/special_publication_spec.rb --format progress
     ```

3. **Align FIPS** (40 min):
   - Replace `edition`, `edition_year`, `edition_month` with Edition component
   - Pattern: `FIPS 107e198503` → edition.type="e", edition.id="198503"
   - Pattern: `FIPS 14-1971` → edition.type="e", edition.id="1971"
   - Pattern: `FIPS 107-Mar1985` → edition with additional_text
   - Test after changes:
     ```bash
     bundle exec rspec spec/pubid_new/nist/identifiers/fips_spec.rb --format progress
     ```

4. **Validate Both** (15 min):
   ```bash
   bundle exec rspec spec/pubid_new/nist/identifiers/special_publication_spec.rb spec/pubid_new/nist/identifiers/fips_spec.rb --format progress
   ```

**Expected Result:** ~100-120 tests aligned, ~60-70% passing, architecture validated

**V2 API Pattern (from Sessions 262-265):**
```ruby
# ✅ CORRECT - V2 Edition API for revision
expect(parsed.edition).to be_a(PubidNew::Nist::Components::Edition)
expect(parsed.edition.type).to eq("r")
expect(parsed.edition.id).to eq("5")

# ✅ CORRECT - V2 Edition API for edition with month+year
expect(parsed.edition.type).to eq("e")
expect(parsed.edition.id).to eq("198503")  # YYYYMM format
expect(parsed.edition.additional_text).to eq("Mar1985")  # optional

# ❌ WRONG - V1 strings
expect(parsed.revision).to eq("5")           # Don't do this!
expect(parsed.edition).to eq("198503")       # Legacy attribute
expect(parsed.edition_year).to eq(1985)      # Legacy attribute  
expect(parsed.edition_month).to eq(3)        # Legacy attribute
```

**Key Files:**
- Reference: `spec/pubid_new/nist/identifiers/circular_spec.rb` (100% example)
- Reference: `spec/pubid_new/nist/identifiers/interagency_report_spec.rb` (Session 265)
- Update: `spec/pubid_new/nist/identifiers/special_publication_spec.rb`
- Update: `spec/pubid_new/nist/identifiers/fips_spec.rb`

**Success:** SP & FIPS specs aligned, ready for final validation in Session 268!

**Full Plan:** See [`docs/SESSION-267-CONTINUATION-PLAN.md`](SESSION-267-CONTINUATION-PLAN.md)