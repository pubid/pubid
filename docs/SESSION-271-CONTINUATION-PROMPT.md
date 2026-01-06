# Session 271 Quick-Start Prompt

**Context:** Session 270 completed edition foundation + CS variants. CommercialStandard now 100% (31/31). Ready to implement remaining edition patterns.

**Current State:**
- ✅ Edition architecture complete (edition_component, edition_year)
- ✅ TN edition working (NIST TN 1297-1993 → e1993)
- ✅ CS-E complete (e104 → CS-E 104)
- ✅ CSM complete with Part component (v6n1 → v6pt1)
- ⏳ Main series: 368 examples, 117 failures (68.2% passing)

**Your Task:**
Implement CS edition with year pattern and validate CS is 100% complete.

**Critical Architecture:**
- **Date IS Edition** - When date after edition, use additional_text
- **Part component** - CSM uses number.part (v6 + pt1)
- **MODEL-DRIVEN** - Edition as Lutaml::Model component
- **MECE** - Separate classes for CS/CS-E/CSM

**Steps:**

1. **Implement CS Edition with Year** (30 min):
   Pattern: `NBS CS 123e2-50`
   - first_number="123e2", second_number="50"
   - Extract: number=123, edition=Edition(e, 2, additional_text: "50")
   - Render: "NBS CS 123e2-50" (dash for 2-digit year)

2. **Fix Edition Rendering** (20 min):
   Update [`Edition.to_s`](lib/pubid_new/nist/components/edition.rb:37):
   - 4-digit additional_text → dot (e2.1915)
   - 2-digit additional_text → dash (e2-50)
   - Month+year → dot (e2.June1908)

3. **Test CS Complete** (10 min):
   ```bash
   bundle exec rspec spec/pubid_new/nist/identifiers/commercial_standard_spec.rb
   ```
   Expected: 31/31 (100%)

4. **Test All Series** (10 min):
   ```bash
   bundle exec rspec spec/pubid_new/nist/identifiers/*.rb --format progress
   ```
   Expected: 257-260/368 (69.8-70.7%)

5. **Commit** (10 min):
   ```bash
   git add -A
   git commit -m "feat(nist): Session 271 - CS edition with year patterns

   - Implemented CS edition with 2-digit year (123e2-50)
   - Enhanced Edition.to_s for dash/dot logic
   - Fixed CS edition round-trip

   Results: 257-260/368 (69.8-70.7%)
   CS: 31/31 (100%)

   Architecture: 2-digit year uses dash, 4-digit uses dot"
   ```

**Key Files:**
- Builder: [`lib/pubid_new/nist/builder.rb`](lib/pubid_new/nist/builder.rb:275)
- Edition: [`lib/pubid_new/nist/components/edition.rb`](lib/pubid_new/nist/components/edition.rb:1)
- CS spec: [`spec/pubid_new/nist/identifiers/commercial_standard_spec.rb`](spec/pubid_new/nist/identifiers/commercial_standard_spec.rb:1)

**Expected Results:**
- ✅ CS edition with year working
- ✅ CS 100% complete (31/31)
- ✅ Main series at ~70%
- ✅ Ready for HB edition patterns (Session 272)

**Full Plan:** See [`docs/SESSION-271-CONTINUATION-PLAN.md`](docs/SESSION-271-CONTINUATION-PLAN.md:1)