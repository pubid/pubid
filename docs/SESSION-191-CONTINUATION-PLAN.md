# Session 191+ Continuation Plan: NIST V2 Completion to 85-93%+

**Created:** 2025-12-23 (Post-Session 190)
**Status:** Session 190 complete - 65/91 (71.4%)
**Timeline:** COMPRESSED - Complete remaining 26 patterns in 2-3 sessions (3-5 hours MAX)
**Priority:** HIGH - Push to 85%+ minimum, 93%+ target

---

## Executive Summary

**Current Progress:** 65/91 (71.4%)
**Remaining:** 26 patterns (28.6%)
**Target:** 91/91 (100%) ideal, 85/91 (93%+) minimum acceptable

**Session 190 Achievements:**
- ✅ Fixed revision spacing order with proper negative lookahead
- ✅ Added letter-only revision support (Revision A, etc.)
- ✅ Laid foundation for r1-upd patterns
- ✅ Architecture quality maintained: MODEL-DRIVEN, MECE, Three-layer

**Remaining Work Categorized by Complexity:**
1. **Update patterns (11 patterns)** - Builder work needed
2. **LCIRC patterns (4 patterns)** - Parser matching issue
3. **Complex parts (3 patterns)** - Pt3r1, p1adde1 handling
4. **Edge cases (8 patterns)** - Various special formats

---

## SESSION 191: Update Patterns & LCIRC Debug (120 min)

**Target:** 65/91 → 75/91 (82.4%) - Gain +10 patterns

### Phase 1: Fix Update Patterns Without Numbers (40 min)

**Issue:** Patterns like `NIST SP 500-300-upd` have no update number after `-upd`

**Current state:**
- Preprocessing works: `500-300-upd` → `500-300 -upd`
- Parser update rule has `update_number` as optional (Session 189)
- But something still fails

**Action 1: Test current state** (10 min)
```bash
bundle exec ruby -e "
require_relative 'lib/pubid_new/nist/parser'
tests = ['NIST SP 500-300-upd', 'NIST IR 8170-upd', 'NIST TN 2150-upd']
tests.each do |test|
  puts test
  begin
    result = PubidNew::Nist::Parser.parse(test)
    puts '  Success!'
  rescue => e
    puts '  Failed'
  end
end
"
```

**Action 2: Debug why failing** (15 min)
- Check if preprocessed strings parse
- Verify update rule actually matches space + `-upd` pattern
- Check if builder handles update without number

**Action 3: Fix identified issues** (15 min)
- If parser issue: enhance update rule
- If builder issue: update builder to handle nil update_number

**Expected gain:** +6 patterns (all simple -upd patterns)

---

### Phase 2: Fix r1-upd Combined Patterns (30 min)

**Patterns:** `NIST IR 8115r1-upd`, `NIST.IR.8115r1-upd`

**Current state:**
- Preprocessing should work: `8115r1-upd` → `8115 r1-upd` (via line 50-51) → `8115 r1 -upd` (via line 56)
- Parser should match revision then update

**Action 1: Test preprocessing** (10 min)
```bash
bundle exec ruby -e "
input = 'NIST IR 8115r1-upd'
# Simulate preprocessing
cleaned = input.gsub(/(\d)(r\d+)(?=-|$)/, '\1 \2')
puts 'After r spacing: ' + cleaned
cleaned = cleaned.gsub(/([a-z]\d+)-upd/, '\1 -upd')
puts 'After upd spacing: ' + cleaned
"
```

**Action 2: Test parser** (10 min)
```bash
bundle exec ruby -e "
require_relative 'lib/pubid_new/nist/parser'
PubidNew::Nist::Parser.parse('NIST IR 8115r1-upd')
"
```

**Action 3: Fix issues** (10 min)
- Likely needs parts rule ordering adjustment
- revision and update must both be in parts array

**Expected gain:** +5 patterns (all r1-upd variants)

---

### Phase 3: Debug LCIRC Compound Series Matching (50 min)

**Patterns:** `NIST LCIRC 1136`, `NIST LCIRC 1128r1995`, `NBS LCIRC 118supp3/1926`, `NBS LCIRC 118supp12/1926`

**Issue:** "NIST LCIRC" and "NBS LCIRC" are in compound_series (line 173) but not matching

**Investigation strategy:**

**Step 1: Test if compound_series rule works** (15 min)
```bash
bundle exec ruby -e "
require_relative 'lib/pubid_new/nist/parser'
parser = PubidNew::Nist::Parser.new

# Test compound_series rule directly
puts 'Testing compound_series patterns:'
['NIST LCIRC', 'NBS LCIRC', 'NBS RPT'].each do |pattern|
  begin
    result = parser.compound_series.parse(pattern)
    puts pattern + ': matches'
  rescue
    puts pattern + ': FAILS'
  end
end
"
```

**Step 2: Check identifier rule order** (15 min)

The identifier rule tries patterns in this order:
1. MR identifier (dot-separated)
2. Compound series + space/dot + ...
3. Publisher + simple series + space/dot + ...
4. Simple series only + space/dot + ...

Check if pattern #3 or #4 is matching "NIST" or "NBS" before #2 gets tried.

**Solution A: If order issue** (10 min)
- Ensure compound_series is tried BEFORE publisher + simple_series
- Verify "LCIRC" is NOT in simple_series (it shouldn't be)

**Solution B: If pattern issue** (10 min)
- Check if space after "LCIRC" is required
- Verify report_number.maybe allows no number

**Expected gain:** +4 patterns (all LCIRC)

---

## SESSION 192: Complex Parts & Edge Cases (90 min)

**Target:** 75/91 → 85/91 (93.4%) - Gain +10 patterns

### Phase 1: Fix Complex Part Patterns (35 min)

**Patterns:** `NIST SP 800-57Pt3r1`, `NBS TN 467p1adde1`, `NBS.TN.467p1adde1`

**Issue 1: Pt3r1 pattern** (20 min)

Current preprocessing (line 36):
```ruby
cleaned = cleaned.gsub(/(\d)Pt(\d+)(r\d+)/, '\1 pt\2 \3')
```
Produces: `800-57 pt3 r1`

Need to verify:
- part rule accepts `pt3` format
- revision follows part correctly in parts array

**Issue 2: p1adde1 pattern** (15 min)

Current preprocessing (line 69):
```ruby
cleaned = cleaned.gsub(/(\d)([pP]\d+)/, '\1 \2')
```
Produces: `467 p1adde1`

Part rule (line 329-332):
```ruby
rule(:part) do
  (str("pt") | str("p") | str("P") | str(" Part ")) >>
    (digits >>
     (str("add") >> (str("e") >> digits).maybe).maybe >>
     (dash >> digits).maybe).as(:part)
end
```

This should match: `p1adde1` = p + 1 + add + e + 1

Test if parsing works.

**Expected gain:** +3 patterns

---

### Phase 2: Edge Case Fixes (55 min)

**Pattern 1: Dot in number** (15 min)
- `NIST SP 984.4`
- Preprocessing line 78 should handle: `984 4` → `984_4`
- But input has dot already: `984.4`
- Need to add: `cleaned = cleaned.gsub(/(\d{3,})\.(\d{1,2})/, '\1_\2')`

**Pattern 2: CRPL range** (10 min)
- `NBS CRPL 1-2_3-1A`
- Check if crpl_range rule (line 310-312) matches
- Test second_number rule with underscore pattern

**Pattern 3: Month in revision** (10 min)
- `NIST IR 4743rJun1992`
- Need preprocessing: `rJun1992` → `r Jun1992`?
- Or enhance revision rule to accept month

**Pattern 4: Lowercase suffix** (10 min)
- `NIST IR 6529-a`
- Should work with digits_with_suffix rule
- Test if lowercase 'a' accepted

**Pattern 5: MR underscore** (10 min)
- `NIST.TN.1648_2009`
- MR format with underscore in number
- Check if first_number accepts underscore

**Expected gain:** +5 patterns

---

### Phase 3: Data Quality Issues - Document (10 min)

**Corrupt/Invalid patterns (do NOT fix these):**
1. `NISTPUB 0413171251` - "PUB" is not a valid series
2. `NIST CSWP 9NIST.HB.135e2022-upd1` - Malformed (two IDs concatenated)

**Action:** Add comments to TODO file documenting these as data quality issues, not parser issues.

---

## SESSION 193: Final Validation & Documentation (60 min)

**Target:** Document completion, update README if 85%+ achieved

### Part A: Comprehensive Testing (20 min)

```bash
# Run full TODO test
bundle exec ruby test_nist_todo.rb 2>&1 | tee test_results.txt

# Check specific pattern categories
grep "LCIRC" test_results.txt
grep "upd" test_results.txt
grep "p1adde1" test_results.txt
```

### Part B: Update README.adoc (20 min)

If 85%+ achieved, add NIST section to README.adoc:

```asciidoc
==== NIST (National Institute of Standards and Technology)
- Status: ✅ XX/91 (XX%)
- Features: Multiple series (SP, FIPS, IR, etc.), revisions, updates, supplements
- Architecture: Complete V2 with comprehensive pattern support

**Pattern support:**
- Standard identifiers: SP, FIPS, IR, TN, HB, etc.
- Historical: NBS identifiers (1900s-1980s)
- Revisions: r1, ra, rev2013, r6/1925 formats
- Updates: -upd, -upd1, /upd patterns
- Supplements: supp, sup with numbers/dates
- Parts: pt, p patterns with add/e suffixes
- Editions: e2, e2020, e2revJune1908 formats
- Addenda: -add, .add patterns
- Translations: (spa), (por) language codes
- Stages: ipd, fpd, 2pd, wd patterns
```

### Part C: Create Final Session Summary (20 min)

Create `docs/SESSION-191-193-SUMMARY.md` with:
- Overall progress from 65/91 to final
- All patterns fixed by category
- Architecture decisions made
- Remaining known issues
- Future enhancement opportunities

---

## Implementation Status Tracker

### Session 190 Complete ✅
- [x] Revision spacing order fix
- [x] Letter-only revision support  
- [x] LCIRC preprocessing patterns added
- [x] Documentation created
- Result: 64/91 → 65/91 (71.4%)

### Session 191 (Target: 75/91, 82.4%)
- [ ] Fix update patterns without numbers (+6)
- [ ] Fix r1-upd combined patterns (+5)
- [ ] Debug LCIRC matching (+4)
- [ ] Total expected: +15 patterns

### Session 192 (Target: 85/91, 93.4%)
- [ ] Fix Pt3r1 pattern (+1)
- [ ] Fix p1adde1 patterns (+2)
- [ ] Fix dot in number (+1)
- [ ] Fix CRPL range (+1)
- [ ] Fix month in revision (+1)
- [ ] Fix lowercase suffix (+1)
- [ ] Fix MR underscore (+1)
- [ ] Document data quality issues (+2 marked)
- [ ] Total expected: +10 patterns

### Session 193 (Documentation & Validation)
- [ ] Comprehensive testing
- [ ] Update README.adoc if 85%+
- [ ] Create final summary
- [ ] Mark complete

---

## Success Criteria

### Minimum (85%+)
- ✅ 77+/91 patterns passing (85%+)
- ✅ All categorized fixable patterns addressed
- ✅ Architecture clean and documented
- ✅ Comprehensive test results

### Target (93%+)
- ✅ 85+/91 patterns passing (93%+)
- ✅ All LCIRC, update, complex part patterns working
- ✅ Edge cases handled
- ✅ Data quality issues documented

### Stretch (97%+)
- ✅ 89+/91 patterns passing (97%+)
- ✅ Only 2 data quality issues remaining
- ✅ README updated with NIST status
- ✅ Production-ready quality

---

## Critical Reminders

**Architecture Preservation (NEVER COMPROMISE):**
1. **MODEL-DRIVEN** - Objects not strings
2. **MECE** - Mutually exclusive, collectively exhaustive
3. **Three-layer** - Parser/Builder/Identifier independence
4. **One change at a time** - Test after each modification
5. **Preprocessing coordinates with parser** - Order matters!

**Key Insights from Session 190:**
- Preprocessing order is CRITICAL: revision BEFORE update
- Negative lookahead essential for preserving patterns
- Letter-only revisions need explicit support
- LCIRC has deeper matching issues requiring investigation

---

## Files to Modify

**Primary:**
- `lib/pubid_new/nist/parser.rb` - All pattern fixes
- `lib/pubid_new/nist/builder.rb` - Update handling (if needed)

**Documentation:**
- `docs/SESSION-191-RESULTS.md` - Create after Session 191
- `docs/SESSION-192-RESULTS.md` - Create after Session 192
- `docs/SESSION-191-193-SUMMARY.md` - Final summary
- `README.adoc` - Update NIST section if 85%+

**Testing:**
- `test_nist_todo.rb` - Monitor results (already exists)

---

**Created:** 2025-12-23
**Sessions Covered:** 191-193
**Status:** Ready for execution
**Compressed Timeline:** 3-5 hours total for 85-93%+ completion

**End Goal:** 85-91/91 patterns (93-100%), NIST V2 production-ready! 🚀
