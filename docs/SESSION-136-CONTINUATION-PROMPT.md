# Session 136 CONTINUATION PROMPT

**Created:** 2025-12-13 (Post-Session 135)
**Objective:** Complete OIML supplement implementation (edition/amendment/annex patterns)
**Timeline:** 90-120 minutes (compressed)
**Status:** Ready for execution

---

## Context

Session 135 completed OIML base document implementation with proper MECE architecture.

**Current Status:**
- **OIML base documents:** 51/51 tests (100%) ✅
- **Architecture:** 9 identifier classes (7 base + 2 supplements) ✅
- **Supplements:** Amendment/Annex classes ready, parser not implemented ⏳

**Remaining Work:**
- Edition patterns (11 identifiers)
- Amendment patterns (3 identifiers)
- Annex patterns (3 identifiers)

---

## Session 136 Tasks

### Task 1: Enhance Parser for Edition Support (25 min)

**Goal:** Parse "6th Edition 2015" and "Edition 2013" formats

**Files to modify:**
- `lib/pubid_new/oiml/parser.rb`

**Add rules for:**
- `edition_number`: "6th", "5th", etc.
- `edition_text`: "Edition" or "edition"
- `edition_portion`: Full edition pattern with year
- Update `date` rule to handle both `:YYYY` and `Edition YYYY`

**Test patterns:**
- `OIML E 5 6th Edition 2015 (E)` - edition=6, year=2015
- `OIML R 144-1 Edition 2013 (E)` - year=2013 (no edition number)
- `OIML R 76-1, edition 1992 (E)` - comma variant

### Task 2: Implement Amendment Parsing (20 min)

**Goal:** Parse `Amendment (YYYY) to BASE` format

**Add to parser:**
```ruby
rule(:amendment_identifier) do
  str("Amendment") >> space >> lparen >> year_digits.as(:year) >> rparen >>
  space >> str("to") >> space >>
  base_identifier.as(:base_identifier) >>
  language_portion.maybe
end
```

**Update identifier rule order:**
```ruby
rule(:identifier) do
  amendment_identifier | annex_identifier | base_identifier
end
```

**Test patterns:**
- `Amendment (2009) to OIML R 138 Edition 2007 (E)`
- `Amendment (2009) to OIML R 138:2007 (E)`

### Task 3: Implement Annex Parsing (15 min)

**Goal:** Parse "Annexes" and "Annex A" formats

**Add to parser:**
```ruby
rule(:annex_identifier) do
  base_identifier.as(:base_identifier) >>
  space >> str("Annexes") >> 
  (edition_portion | (colon >> year_digits.as(:year))) >>
  language_portion.maybe
end
```

**Test patterns:**
- `OIML R 60 Annexes Edition 2021 (E)`
- `OIML R 60 Annexes:2021 (E)`
- `OIML R 60-Annex A Edition 2013 (E)` (embedded pattern)

### Task 4: Update Builder for Supplements (30 min)

**Goal:** Construct Amendment/Annex objects with recursive base parsing

**Add to builder:**
1. `build_supplement(parsed_hash)` method
2. Supplement type detection
3. Recursive base_identifier parsing
4. Edition attribute handling in base construction

---

## Reference Files

**Continuation Plan:** `.kilocode/rules/memory-bank/session-136-continuation-plan.md`
**OIML Fixtures:** `spec/fixtures/oiml/identifiers/full/identifiers.txt` (59 identifiers)
**Memory Bank:** `.kilocode/rules/memory-bank/context.md`
**Architecture Guide:** `docs/V2_ARCHITECTURE.adoc`

**Current Implementation:**
- `lib/pubid_new/oiml/parser.rb` - Parser (base patterns only)
- `lib/pubid_new/oiml/builder.rb` - Builder (base documents only)
- `lib/pubid_new/oiml/single_identifier.rb` - Base for 7 document types
- `lib/pubid_new/oiml/supplement_identifier.rb` - Base for supplements
- `lib/pubid_new/oiml/identifiers/amendment.rb` - Amendment class (ready)
- `lib/pubid_new/oiml/identifiers/annex.rb` - Annex class (ready)

---

## Expected Results

**After Session 136:**
- All 59 OIML fixtures parsing (100%)
- Edition support working
- Amendment parsing working
- Annex parsing working (at least plural form)
- Zero regressions in 51 base tests

---

## Key Reminders

1. **Edition formats:** "6th Edition 2015" vs "Edition 2013" (no number)
2. **Amendment canonical:** `Amendment (YYYY) to BASE_ID (lang)`
3. **Annex plural:** `BASE_ID Annexes:YYYY (lang)`
4. **Recursive parsing:** Base identifiers in supplements must be fully parsed
5. **MECE maintained:** All 9 classes remain distinct

---

**Next Steps:** Read continuation plan, implement parser enhancements, test thoroughly! 🚀