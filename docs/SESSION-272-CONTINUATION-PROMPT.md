# Session 272 Quick-Start Prompt

**Context:** Session 271 completed CS edition foundation with 2-digit year expansion. CS-E and CSM specs corrected but implementation needs updates.

**Current State:**
- ✅ CS edition working (123e2-50 → 123e2.1950)
- ⏳ CS-E: Spec expects `104e1943`, implementation renders `104-43`
- ⏳ CSM: Spec expects `v6n1`, implementation renders `v6pt1`
- ⏳ Main series: 259/368 (70.4% passing)

**Your Task:**
Fix CS-E and CSM to match corrected spec expectations.

**Critical Architecture:**
- **Date IS Edition** - 2-digit years expand to 4-digit (43 → 1943)
- **CS-E pattern** - Emergency with year uses edition format
- **CSM pattern** - Volume+issue is v#n#, NOT v#pt#
- **MODEL-DRIVEN** - Components, not strings

**Steps:**

1. **Fix CS-E Edition Format** (40 min):
   Pattern: `e104-43` → `CS-E 104e1943`

   Update [`Builder`](lib/pubid_new/nist/builder.rb:347):
   - Extract year from `e104-43` → number=104, year=43
   - Expand year: 43 → 1943
   - Create Edition: `Edition.new(type: "e", id: "1", additional_text: "1943")`

   Update [`CommercialStandardEmergency`](lib/pubid_new/nist/identifiers/commercial_standard_emergency.rb:1):
   - Add edition attribute
   - Render: `NBS CS-E {number}e{edition.id}.{edition.additional_text}`

2. **Fix CSM Volume+Issue** (40 min):
   Pattern: `v6n1` → `CSM v6n1` (NOT v6pt1)

   Update [`Builder`](lib/pubid_new/nist/builder.rb:260):
   - Change: Don't convert issue to part
   - Return: `{ first_number: Code(number: "v6"), issue_number: IssueNumber(number: "1") }`

   Update [`CommercialStandardsMonthly`](lib/pubid_new/nist/identifiers/commercial_standards_monthly.rb:1):
   - Extract volume from number.value (v6)
   - Render: `{publisher} CSM v{volume}n{issue_number.number}`

3. **Test** (10 min):
   ```bash
   bundle exec rspec spec/pubid_new/nist/identifiers/commercial_standard_spec.rb
   ```
   Expected: 28-30/31 passing

4. **Commit** (10 min):
   ```bash
   git add -A
   git commit -m "feat(nist): Session 272 - CS-E edition format + CSM v#n# notation

   - CS-E: e104-43 → CS-E 104e1943 (edition with expanded year)
   - CSM: v6n1 → CSM v6n1 (volume+issue, not part)
   - Both use 2-digit year expansion

   Results: 28-30/31 CS tests passing

   Architecture: Edition format for emergency years, v#n# preservation"
   ```

**Key Files:**
- Builder: [`lib/pubid_new/nist/builder.rb`](lib/pubid_new/nist/builder.rb:1)
- CS-E: [`lib/pubid_new/nist/identifiers/commercial_standard_emergency.rb`](lib/pubid_new/nist/identifiers/commercial_standard_emergency.rb:1)
- CSM: [`lib/pubid_new/nist/identifiers/commercial_standards_monthly.rb`](lib/pubid_new/nist/identifiers/commercial_standards_monthly.rb:1)
- Spec: [`spec/pubid_new/nist/identifiers/commercial_standard_spec.rb`](spec/pubid_new/nist/identifiers/commercial_standard_spec.rb:1)

**Expected Results:**
- ✅ CS-E renders with edition format
- ✅ CSM preserves v#n# notation
- ✅ CS tests: 28-30/31 passing
- ✅ Ready for HB edition patterns (Session 273)

**Full Plan:** See [`docs/SESSION-272-CONTINUATION-PLAN.md`](docs/SESSION-272-CONTINUATION-PLAN.md:1)