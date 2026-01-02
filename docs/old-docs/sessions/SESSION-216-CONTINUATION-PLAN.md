# Session 216+ Continuation Plan: CIE Enhancement to 97%+

**Created:** 2025-12-26 (Post-Session 215 reversal)
**Status:** CIE at 93.59% (321/343) - Enhancement REQUIRED
**Timeline:** COMPRESSED - Complete in 2-3 sessions (3-4 hours)
**Priority:** MANDATORY - Must reach 97%+ before project completion

---

## Executive Summary

**Current Status:**
- **CIE: 93.59%** (321/343 passing)
- **Failing: 22 identifiers** across 6 pattern categories
- **Target: 97%+** (333+/343 passing - need +12 identifiers minimum)

**Failure Analysis from `spec/fixtures/cie/identifiers/fail/all.txt`:**

### Category 1: Language Before ISO Reference (13 identifiers) - HIGH PRIORITY
```
#CIE S 014-4/E2007                                # /E before year (no colon)
#CIE S 008/E:2001 (ISO 8995-1:2002(E))          # /E:YYYY before ISO reference
#CIE S 011/E:2003 (ISO 23603:2005(E))           # /E:YYYY before ISO reference
... (10 more similar patterns)
```

**Issue:** Parser doesn't handle `/E` or `/E:YYYY` language format in Identical identifiers
**Expected gain:** +13 identifiers (CRITICAL)

### Category 2: Bundle with Slash Separator (1 identifier)
```
CIE 146/147:2002                                 # Bundle: CIE 146:2002 + CIE 147:2002
```

**Issue:** Two report numbers with single shared year - needs BundleIdentifier
**Expected gain:** +1 identifier

### Category 3: Additional Language Codes (3 identifiers)
```
#CIE 232:2019(DE)                                # German
#CIE 243:2021(ES)                                # Spanish  
#CIE 243:2021(CN)                                # Chinese
```

**Issue:** Language codes DE, ES, CN not recognized
**Expected gain:** +3 identifiers

### Category 4: Language with Year Suffix (1 identifier)
```
#CIE 155:2003 (RU-2021)                         # Russian with translation year
```

**Issue:** Format `(RU-YYYY)` not parsed
**Expected gain:** +1 identifier

### Category 5: Bundle with Comma Separator (1 identifier)
```
CIE 198-SP1.1:2011,198-SP1.2:2011,198-SP1.3:2011,198-SP1.4:2011
```

**Issue:** Bundle of 4 supplement identifiers - needs BundleIdentifier
**Expected gain:** +1 identifier

### Category 6: Draft Stage with Supplement (1 identifier)
```
#CIE DIS 025-SP1/E:2019                         # Draft International Standard
```

**Issue:** DIS stage + SP suffix + /E language
**Expected gain:** +1 identifier (OPTIONAL - draft stages may be future work)

---

## SESSION 216: Language Format Fixes (90 minutes)

### Objective
Fix Category 1 (language before ISO reference) to gain +13 identifiers

### Part A: Update Parser for /E and /E:YYYY (40 min)

**File:** `lib/pubid_new/cie/parser.rb`

**Current issue:** `identical_with_iso` rule doesn't handle `/E` or `/E:YYYY`

**Implementation:**

```ruby
# Around line 100-120 in parser.rb
rule(:language_with_year_before_iso) do
  slash >> 
  language_code.as(:language) >> 
  (colon >> year_digits.as(:year)).maybe
end

rule(:identical_with_iso) do
  publisher >>
  space >>
  document_code.as(:code) >>
  language_with_year_before_iso.maybe >>  # NEW: Handle /E or /E:YYYY
  space.maybe >>
  str("(") >>
  iso_reference.as(:iso_ref) >>
  str(")")
end
```

**Expected result:** Parse `CIE S 008/E:2001 (ISO 8995-1:2002(E))` correctly

### Part B: Update Builder for Language Handling (30 min)

**File:** `lib/pubid_new/cie/builder.rb`

```ruby
def build_identical(parsed_hash)
  identifier = Identifiers::Identical.new
  
  # Handle code
  identifier.code = build_code(parsed_hash[:code]) if parsed_hash[:code]
  
  # Handle language from /E or /E:YYYY
  if parsed_hash[:language]
    lang_str = parsed_hash[:language].to_s
    identifier.language = Components::Language.new(
      code: lang_str,
      original_code: lang_str
    )
  end
  
  # Handle year (from /E:YYYY format)
  if parsed_hash[:year]
    identifier.year = parsed_hash[:year].to_s
  end
  
  # Handle ISO reference
  if parsed_hash[:iso_ref]
    identifier.iso_reference = parsed_hash[:iso_ref].to_s
  end
  
  identifier
end
```

### Part C: Update Identical Rendering (20 min)

**File:** `lib/pubid_new/cie/identifiers/identical.rb`

```ruby
def to_s
  parts = ["CIE"]
  parts << code.to_s if code
  
  # Render language and year if present
  if language
    if year
      parts << "/#{language.code}:#{year}"
    else
      parts << "/#{language.code}"
    end
  end
  
  # Render ISO reference
  parts << "(#{iso_reference})" if iso_reference
  
  parts.join(" ")
end
```

**Expected gain:** +13 identifiers (93.59% → 97.38%)

---

## SESSION 217: Bundle & Additional Languages (60 minutes)

### Objective
Fix Categories 2, 3, 4, 5 to gain +6 more identifiers

### Part A: Bundle with Slash Separator (20 min)

**File:** `lib/pubid_new/cie/parser.rb`

```ruby
rule(:bundle_with_slash) do
  publisher >>
  space >>
  digits.as(:first_number) >>
  slash >>
  digits.as(:second_number) >>
  colon >>
  year_digits.as(:year)
end
```

**File:** `lib/pubid_new/cie/builder.rb`

```ruby
def build_bundle_slash(parsed_hash)
  # Create two identifiers: CIE 146:2002 and CIE 147:2002
  first = Identifiers::TechnicalReportGuide.new
  first.code = Components::Code.new(number: parsed_hash[:first_number].to_s)
  first.year = parsed_hash[:year].to_s
  
  second = Identifiers::TechnicalReportGuide.new
  second.code = Components::Code.new(number: parsed_hash[:second_number].to_s)
  second.year = parsed_hash[:year].to_s
  
  Identifiers::Bundle.new(identifiers: [first, second])
end
```

**Expected gain:** +1 identifier

### Part B: Additional Language Codes (15 min)

**File:** `lib/pubid_new/cie/parser.rb`

Add to language_code rule:
```ruby
rule(:language_code) do
  (
    str("E") | str("F") | str("DE") | str("ES") | 
    str("CN") | str("RU") | str("FR")  # Add more as needed
  )
end
```

**Expected gain:** +3 identifiers

### Part C: Language with Year Suffix (15 min)

**File:** `lib/pubid_new/cie/parser.rb`

```ruby
rule(:language_with_translation_year) do
  str("(") >>
  language_code.as(:language) >>
  dash >>
  year_digits.as(:translation_year) >>
  str(")")
end
```

**Expected gain:** +1 identifier

### Part D: Bundle with Commas (10 min)

**File:** `lib/pubid_new/cie/parser.rb`

```ruby
rule(:bundle_with_commas) do
  identifier_item >>
  (comma >> identifier_item).repeat(1)
end
```

**Expected gain:** +1 identifier

---

## SESSION 218: Testing & Documentation (60 minutes)

### Part A: Comprehensive Testing (30 min)

```bash
# Run CIE classification
cd spec/fixtures
ruby run_classify_cie.rb

# Verify improvement
cat cie/identifiers/pass/*.txt | wc -l  # Should be 333+
cat cie/identifiers/fail/*.txt | wc -l  # Should be 10 or less
```

**Expected result:** 333-335/343 (97.08-97.67%)

### Part B: Update Documentation (20 min)

**File:** `README.adoc`

Update CIE section with:
- Final validation rate (97%+)
- Document edge cases handled
- Update total identifiers

**File:** `.kilocode/rules/memory-bank/context.md`

Add Session 216-218 completion with final CIE metrics

### Part C: Final Commit (10 min)

```bash
git add -A
git commit -m "feat(cie): complete Sessions 216-218 - CIE 97%+ achieved

Session 216: Language Format Fixes
- Handle /E and /E:YYYY before ISO reference
- Update Identical identifier rendering
- Gain +13 identifiers

Session 217: Bundle & Additional Languages  
- Bundle with slash separator (CIE 146/147:2002)
- Additional language codes (DE, ES, CN)
- Language with year suffix (RU-2021)
- Bundle with comma separators
- Gain +6 identifiers

Session 218: Testing & Documentation
- Final validation: 333-335/343 (97%+)
- Documentation updated
- Project COMPLETE

Overall: CIE 93.59% → 97%+ (+19 identifiers)
Architecture: MODEL-DRIVEN, MECE, Three-layer maintained"
```

---

## Implementation Status Tracker

| Session | Category | Files | Est. Gain | Cumulative | Status |
|---------|----------|-------|-----------|------------|--------|
| 216 | Language /E format | parser, builder, identical | +13 | 97.38% | ⏳ Pending |
| 217 | Bundles & languages | parser, builder, bundle | +6 | 98.54% | ⏳ Pending |
| 218 | Testing & docs | README, context.md | - | 98.54% | ⏳ Pending |

**Total improvement:** +19 identifiers (93.59% → 98.54%)
**Minimum target achieved:** 97%+ ✅

---

## Success Criteria

### Minimum (97%)
- ✅ Category 1: Language /E format fixed (+13)
- ✅ Category 2: Bundle slash separator (+1)
- ✅ 333+/343 passing (97.08%+)

### Target (98%)
- ✅ All Categories 1-5 fixed (+19)
- ✅ 335+/343 passing (97.67%+)
- ✅ Complete documentation

### Stretch (99%)
- ✅ Category 6: Draft stages (+1)
- ✅ 340+/343 passing (99.13%+)

---

## Files to Modify

### Session 216
- `lib/pubid_new/cie/parser.rb` - Language format rules
- `lib/pubid_new/cie/builder.rb` - Identical builder
- `lib/pubid_new/cie/identifiers/identical.rb` - Rendering

### Session 217
- `lib/pubid_new/cie/parser.rb` - Bundle & language rules
- `lib/pubid_new/cie/builder.rb` - Bundle construction
- `lib/pubid_new/cie/identifiers/bundle.rb` - Bundle rendering

### Session 218
- `README.adoc` - Update CIE metrics
- `.kilocode/rules/memory-bank/context.md` - Session completion
- `docs/old-docs/sessions/session-216-218-summary.md` - NEW

---

## Key Architectural Principles

**MAINTAIN throughout:**
1. **MODEL-DRIVEN** - Objects not strings
2. **MECE** - Mutually exclusive, collectively exhaustive
3. **Three-layer** - Parser/Builder/Identifier independence
4. **Round-trip fidelity** - Perfect rendering
5. **No compromises** - Architecture quality first

---

## Next Steps (Session 216)

1. Read this continuation plan
2. Implement Part A: Parser language format (40 min)
3. Implement Part B: Builder updates (30 min)
4. Implement Part C: Rendering fixes (20 min)
5. Test against Category 1 failures
6. Verify +13 identifiers gained

---

**Created:** 2025-12-26
**Sessions Covered:** 216-218
**Status:** Ready for execution
**Estimated Time:** 3-4 hours (compressed timeline)

**End Goal:** CIE 97%+ achieved, project COMPLETE! 🎉
