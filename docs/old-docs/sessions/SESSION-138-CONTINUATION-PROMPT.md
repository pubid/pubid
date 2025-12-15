# Session 138 CONTINUATION PROMPT

**Created:** 2025-12-14 (Post-Session 137)
**Objective:** Begin IEEE advanced patterns implementation with data cleaning preprocessing
**Timeline:** 60 minutes (Phase 1)
**Status:** Ready for execution

---

## Context

Session 137 discovered that the continuation plan from Session 128 was outdated - Sessions 129-133 already implemented most simple patterns (+178 IDs total, reaching 88.17%).

**Current Status:**
- **IEEE:** 8,409/9,537 (88.17%) - Ready for advanced enhancement
- **Remaining:** 1,128 failures require architectural enhancements
- **User provided:** 50+ specific failing patterns with clear requirements

**Comprehensive Plan:** `.kilocode/rules/memory-bank/session-138-continuation-plan.md`

---

## Session 138 Tasks: Data Cleaning Enhancement (60 min)

### Objective
Implement preprocessing enhancements to handle data quality issues.

### Part A: Enhanced Preprocessing (30 min)

**Update** `lib/pubid_new/ieee/parser.rb` class method `Parser.parse`:

1. **Remove extra spaces in numbers** (10 min)
   ```ruby
   # Fix: "C57.1 2.25" → "C57.12.25", "C63.022-1 996" → "C63.022-1996"
   cleaned = cleaned.gsub(/(\d+\.\d+)\s+(\d+)/, '\1\2')
   cleaned = cleaned.gsub(/(\d+)-(\d)\s+(\d{3})/, '\1-\2\3')
   ```

2. **Remove trailing commas** (5 min)
   ```ruby
   # Fix: "ANSI N42.43-2006, Standard" → "ANSI N42.43-2006"
   cleaned = cleaned.gsub(/,\s*(Standard|Std)\s*$/, '')
   ```

3. **Enhanced HTML entity cleanup** (10 min)
   ```ruby
   # Already has &amp; cleanup, add more
   cleaned = cleaned.gsub(/&x2122;/, '™')  # Trademark symbol
   cleaned = cleaned.gsub(/&x2019;/, "'")   # Apostrophe
   cleaned = cleaned.gsub(/&#x[0-9A-Fa-f]+;/, '')  # Remove other entities
   ```

4. **Remove duplicate/extra spaces** (5 min)
   ```ruby
   # Normalize multiple spaces to single space
   cleaned = cleaned.gsub(/\s+/, ' ')
   ```

### Part B: Testing (20 min)

**Run tests:**
```bash
# IEEE tests
bundle exec rspec spec/pubid_new/ieee/ --format progress

# Classification
cd spec/fixtures && ruby run_classify.rb ieee

# Check regressions
bundle exec rspec spec/pubid_new/iso/identifier_spec.rb --format progress
bundle exec rspec spec/pubid_new/iec/identifier_spec.rb --format progress
```

**Expected:**
- IEEE: 8,459-8,489/9,537 (88.7-89.0%)
- Gain: +50-80 identifiers
- Zero regressions

### Part C: Documentation (10 min)

**Commit changes:**
```bash
git add -A
git commit -m "feat(ieee): add preprocessing for data quality issues

Session 138 Phase 1: Data cleaning preprocessing

Enhancements:
- Remove extra spaces in numbers (C57.1 2.25)
- Remove trailing commas (, Standard)
- Enhanced HTML entity cleanup (&x2122;, &x2019;)
- Normalize multiple spaces

Expected gain: +50-80 identifiers

Architecture: Parser preprocessing only, zero architectural changes"
```

---

## User-Provided Failing Patterns

For reference, these are the actual patterns from users that need support:

**Data Quality (Session 138):**
- `ANSI C57.1 2.25-1990` → extra space
- `ANSI C63.022-1 996` → space in year
- `ANSI N42.43-2006, Standard` → trailing comma
- `IEEE Std C57.110&x2122;-2018` → HTML trademark
- `IEEE Std 802&x2019;s` → HTML apostrophe

**Future Sessions:**
- Missing prefix: `IEEE 1070-1995`, `IEEE 278-1967`
- Copublishers: `IEEE/ASTM SI 10-1997`, `IEEE/CSA P844.1/293.1/D2`
- Corrigenda: `IEEE Std 535-2013/Cor. 1-2017`
- Equivalence: `AIEE No 18-1934 (ASA C55 1934)`
- Amendment chains: `as amended by IEEE 802.15.4n-2016, ...`

---

## Reference Files

**Continuation Plan:** `.kilocode/rules/memory-bank/session-138-continuation-plan.md`
**Current Parser:** `lib/pubid_new/ieee/parser.rb` (lines 500-518 for preprocessing)
**Memory Bank:** `.kilocode/rules/memory-bank/context.md`

---

## Implementation Notes

**Preprocessing location:**
- In `Parser.parse` class method (around lines 500-518)
- Add new cleaning rules AFTER existing PDF/underscore fixes
- BEFORE `new.parse(cleaned)` call

**Testing strategy:**
- Test incrementally after each cleanup rule
- Verify no regressions with ISO/IEC
- Use fixture classification for actual gain measurement

---

## Expected Results

**After Session 138:**
- IEEE: 8,459-8,489/9,537 (88.7-89.0%)
- Clean preprocessing implementation
- Zero architectural changes
- Ready for Session 139 (missing prefix patterns)

---

## Key Reminders

1. **Parser preprocessing only** - No architecture changes
2. **Test incrementally** - After each regex addition
3. **Verify regressions** - Check ISO/IEC remain at 100%
4. **Document gains** - Track actual improvement
5. **Commit atomically** - Clear semantic message

---

**Next Steps:** Read continuation plan, implement preprocessing enhancements, test, commit! 🚀