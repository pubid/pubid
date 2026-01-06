# Session 270 Quick-Start Prompt

**Context:** Session 268 completed NIST V2 spec validation with comprehensive results. Ready for parser enhancement to achieve 85-90%+ pass rate.

**Current State:**
- ✅ All 665 NIST tests validated (425 passing, 63.9%)
- ✅ 100% V2 Edition API compliance
- ✅ 240 parser gaps identified (NOT architecture issues)
- ⏳ Need: Implement missing edition patterns

**Critical Edition Semantics (Session 269 Clarification):**

**Date IS Edition Rule:**
- When ONLY date appears → edition type "e", id = date
- When edition+date appears → edition.additional_text = date
- For supplements+date → supplement.edition = date

**Examples:**
- `e2-1915` → `e2.1915` (edition e2 with additional_text "1915")
- `sup-1924` → `supe1924` (supplement with edition "e1924")
- `supJan1924` → `supe192401` (supplement with edition "e192401" - month normalized)

**Your Task:**
Implement missing edition patterns in NIST parser following the "date IS edition" rule.
Also, there is only one of revision + edition. If there is a revision ID (which
will become an Edition(id:, type: "r")), then place the remaining content as
edition additional_text.

**Critical Architecture (DO NOT COMPROMISE):**
- **Date IS Edition** - When no edition type, date becomes edition
- **Month+Year Normalization** - Convert to YYYYMM (Jan1924 → 192401)
- **Edition.additional_text** - For edition+date patterns
- **MODEL-DRIVEN** - Edition as Lutaml::Model component
- **NO Date component** - Deleted Session 260, never use

**Steps:**

1. **Implement Edition with Year** (60 min):
   ```ruby
   # lib/pubid_new/nist/parser.rb
   rule(:edition_with_year) do
     edition_type >> edition_id >> dash >> year_digits.as(:edition_year)
   end

   # lib/pubid_new/nist/builder.rb
   when :edition_parts
     Components::Edition.new(
       type: type,
       id: id.to_s,
       additional_text: year ? year.to_s : nil
     )
   ```
   Expected: +40-50 identifiers (465-475/665, ~70%)

2. **Implement Date-as-Edition** (45 min):
   ```ruby
   # Parser: When ONLY date, interpret as edition
   rule(:date_as_edition) do
     dash >> (
       month_name.as(:month) >> year_digits.as(:year) |
       year_digits.as(:year)
     ).as(:date_edition)
   end

   # Builder: Normalize month+year to YYYYMM
   when :date_edition
     month_num = month_to_number(value[:month]) if value[:month]
     edition_id = value[:month] ? "#{value[:year]}#{month_num}" : value[:year].to_s

     Components::Edition.new(type: "e", id: edition_id)
   ```
   Expected: +50-60 identifiers (530-550/665, ~80%)

3. **Test Each Pattern** (30 min):
   ```bash
   # Test Circular (should stay 100%)
   bundle exec rspec spec/pubid_new/nist/identifiers/circular_spec.rb

   # Test all series
   bundle exec rspec spec/pubid_new/nist/identifiers/commercial_standard_spec.rb
   bundle exec rspec spec/pubid_new/nist/identifiers/handbook_spec.rb
   bundle exec rspec spec/pubid_new/nist/identifiers/interagency_report_spec.rb
   bundle exec rspec spec/pubid_new/nist/identifiers/technical_note_spec.rb
   bundle exec rspec spec/pubid_new/nist/identifiers/special_publication_spec.rb
   bundle exec rspec spec/pubid_new/nist/identifiers/fips_spec.rb
   ```

4. **Verify Results** (15 min):
   - Expected: 530-550/665 (79.7-82.7%)
   - If lower: Debug most common failure pattern
   - If higher: Celebrate and continue!

5. **Commit Progress** (10 min):
   ```bash
   git add -A
   git commit -m "feat(nist): Session 270 - implement edition patterns following 'date IS edition' rule

   - Implemented edition with year (e2-1915 → e2.1915)
   - Implemented date-as-edition (sup-1924 → supe1924)
   - Month+year normalization (Jan1924 → 192401)

   Architecture:
   - Date IS edition rule followed
   - Edition.additional_text for edition+date
   - MODEL-DRIVEN throughout

   Results: 530-550/665 (79.7-82.7%)
   Improvement: +105-125 identifiers (+16-19pp)"
   ```

**Expected Results:**
- ✅ Edition with year working (e2-1915 → e2.1915)
- ✅ Bare edition working (e2)
- ✅ Date-as-edition working (sup-1924 → supe1924, supJan1924 → supe192401)
- ✅ Pass rate: 79.7-82.7% (530-550/665)
- ✅ Architecture: No compromises

**Key Files:**
- Parser: [`lib/pubid_new/nist/parser.rb`](lib/pubid_new/nist/parser.rb:1)
- Builder: [`lib/pubid_new/nist/builder.rb`](lib/pubid_new/nist/builder.rb:1)
- Edition component: [`lib/pubid_new/nist/components/edition.rb`](lib/pubid_new/nist/components/edition.rb:1)
- All specs: `spec/pubid_new/nist/identifiers/*_spec.rb`

**Success:** NIST at 80%+ with correct edition semantics! 🎉

**Full Plan:** See [`docs/SESSION-270-CONTINUATION-PLAN.md`](docs/SESSION-270-CONTINUATION-PLAN.md:1)