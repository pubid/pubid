# Session 265 Continuation Plan: Modern Series Spec Alignment

**Created:** 2026-01-06 (Post-Session 264)
**Status:** Ready for execution
**Timeline:** COMPRESSED - Complete in 90-120 minutes

---

## Session 264 Achievement Summary

**COMPLETE:** CommercialStandard & Handbook spec alignment with V2 Edition API ✅

**What Was Accomplished:**
- Updated [`spec/pubid_new/nist/identifiers/commercial_standard_spec.rb`](../spec/pubid_new/nist/identifiers/commercial_standard_spec.rb:1)
- Updated [`spec/pubid_new/nist/identifiers/handbook_spec.rb`](../spec/pubid_new/nist/identifiers/handbook_spec.rb:1)
- Replaced all legacy `edition`, `edition_year`, `revision` string checks with V2 Component API
- Test Results: 54/76 passing (71%), 22 parser gaps documented

**Architecture Quality:**
- ✅ MODEL-DRIVEN - Edition as Lutaml::Model component
- ✅ Follows Circular spec pattern exactly
- ✅ MECE - Clear type/id/additional_text separation
- ✅ NO Date component (deleted Session 260)

---

## Session 265 Objective

Align **modern series** identifier specs with V2 Edition component API:
1. SpecialPublication (SP)
2. FIPS
3. InteragencyReport (IR)
4. TechnicalNote (TN)

**Target:** ~150-200 tests aligned, following same pattern as Session 264

---

## Implementation Plan

### Phase 1: Read V1 Specs & Understand Patterns (25 min)

**Read archived V1 specs:**
```bash
# V1 specs don't exist in document/ folder for these series
# Check base_spec.rb for examples instead
```

**Files to read:**
- `archived-gems/pubid-nist/spec/nist_pubid/identifier/base_spec.rb` (lines with SP/FIPS/IR/TN)
- `spec/pubid_new/nist/identifiers/special_publication_spec.rb`
- `spec/pubid_new/nist/identifiers/fips_spec.rb`
- `spec/pubid_new/nist/identifiers/interagency_report_spec.rb`
- `spec/pubid_new/nist/identifiers/technical_note_spec.rb`

**Document edition patterns for each series:**
1. **SP patterns:**
   - Edition with year: `SP 800-53r5` (revision style)
   - Edition notation: `SP 304Ae2017` (e-style with year)
   - Addendum: `SP 800-38A Add.`

2. **FIPS patterns:**
   - Edition with year: `FIPS 107e198503` (e + YYYYMM)
   - Dash year: `FIPS 14-1971` (year only)
   - Month+year: `FIPS 107-Mar1985` → `FIPS 107e198503`

3. **IR patterns:**
   - Edition with year: `IR 8200e2018`
   - Dash year: `IR 8200-2018` → `IR 8200e2018`

4. **TN patterns:**
   - Edition with year: `TN 1297e1993`
   - Dash year: `TN 1297-1993` → `TN 1297e1993`

### Phase 2: Align SpecialPublication Spec (25 min)

**File:** `spec/pubid_new/nist/identifiers/special_publication_spec.rb`

**Pattern to apply:**
```ruby
# ✅ CORRECT - V2 Edition API
expect(parsed.edition).to be_a(PubidNew::Nist::Components::Edition)
expect(parsed.edition.type).to eq("e") # or "r" for revision
expect(parsed.edition.id).to eq("5")
expect(parsed.edition.additional_text).to eq("2017") # when present

# ❌ WRONG - V1 strings (remove)
expect(parsed.revision).to eq("5")
expect(parsed.edition).to eq("2017")
```

**Key updates:**
- Replace `revision` attribute with `edition.type = "r"`, `edition.id = number`
- Replace `edition` string with `edition.type = "e"`, `edition.id = year/number`
- Handle `edition.additional_text` for month/year combinations

### Phase 3: Align FIPS Spec (20 min)

**File:** `spec/pubid_new/nist/identifiers/fips_spec.rb`

**Key patterns:**
- `FIPS 107e198503` - edition.type="e", edition.id="198503" (YYYYMM as id)
- `FIPS 14-1971` - edition.type="e", edition.id="1971" (year normalization)
- `FIPS 107-Mar1985` - edition.type="e", edition.id="198503", edition.additional_text="Mar1985"

**Updates:**
- Replace `edition` string with Edition component
- Replace `edition_year`, `edition_month` with `edition.id` and `edition.additional_text`

### Phase 4: Align InteragencyReport Spec (15 min)

**File:** `spec/pubid_new/nist/identifiers/interagency_report_spec.rb`

**Key patterns:**
- `IR 8200e2018` - edition.type="e", edition.id="2018"
- `IR 8200-2018` - normalized to e2018

**Updates:**
- Replace `edition` string with Edition component
- Handle year normalization (`-YYYY` → `eYYYY`)

### Phase 5: Align TechnicalNote Spec (15 min)

**File:** `spec/pubid_new/nist/identifiers/technical_note_spec.rb`

**Key patterns:**
- `TN 1297e1993` - edition.type="e", edition.id="1993"
- `TN 1297-1993` - normalized to e1993

**Updates:**
- Replace `edition` string with Edition component
- Handle year normalization

### Phase 6: Test All Four Specs (20 min)

**Run tests:**
```bash
bundle exec rspec spec/pubid_new/nist/identifiers/special_publication_spec.rb
bundle exec rspec spec/pubid_new/nist/identifiers/fips_spec.rb
bundle exec rspec spec/pubid_new/nist/identifiers/interagency_report_spec.rb
bundle exec rspec spec/pubid_new/nist/identifiers/technical_note_spec.rb
```

**Expected:**
- 70-80% passing (edition API working where parser supports)
- 20-30% parser gaps (to be documented and marked as pending)

**Verify:**
- ✅ All Edition component API tests passing
- ✅ Round-trip tests passing for supported patterns
- ✅ No legacy `edition`/`revision`/`edition_year` string checks remaining

---

## Success Criteria

### Minimum (70%)
- ✅ All four specs updated with Edition component API
- ✅ Basic edition patterns working
- ✅ No legacy string attribute checks

### Target (80%)
- ✅ All edition types working (e, r, -)
- ✅ Edition.additional_text for month/year
- ✅ Round-trip validation for supported patterns

### Stretch (85%+)
- ✅ All normalization patterns documented
- ✅ Parser gaps clearly marked as pending
- ✅ Architecture principles maintained

---

## Critical Reminders

**Architecture Principles (NEVER COMPROMISE):**
1. **NO Date component** - dates handled via `edition.additional_text`
2. **Edition.type** - "e" (edition), "r" (revision), "-" (historical)
3. **Edition.id** - number OR year (context-dependent)
4. **Dotted notation** - Never "rev" in output, use dots: `e2.June1908`

**V2 API Pattern:**
```ruby
# Edition component structure
edition = PubidNew::Nist::Components::Edition.new(
  type: "e",              # or "r" or "-"
  id: "5",                # number or year
  additional_text: "2017" # month/year/date info
)
```

**From Session 260-263 Learnings:**
- Parser/builder were NOT using Edition component (fixed Session 260)
- Legacy attributes (`edition_year`, `edition_month`) were populated instead
- Dotted notation enforced: `e2revJune1908` → `e2.June1908`
- SupplementIdentifier pattern follows ISO/IEC (Session 263)

---

## Files to Modify

1. `spec/pubid_new/nist/identifiers/special_publication_spec.rb`
2. `spec/pubid_new/nist/identifiers/fips_spec.rb`
3. `spec/pubid_new/nist/identifiers/interagency_report_spec.rb`
4. `spec/pubid_new/nist/identifiers/technical_note_spec.rb`

**NO implementation changes needed** - only test expectations!

---

## Next Steps (Session 266)

After Session 265 completes:
- Session 266: Documentation updates (60 min)
- Session 267: Final validation (60 min, optional)

**Total remaining:** 2-3 hours to complete NIST V2 alignment

---

**Created:** 2026-01-06
**Status:** Ready for execution
**Estimated Time:** 90-120 minutes (compressed)

**End Goal:** Modern series specs aligned with V2 Edition API, following Circular/CS/HB pattern! 🎯