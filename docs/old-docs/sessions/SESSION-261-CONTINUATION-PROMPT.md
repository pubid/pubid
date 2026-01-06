# Session 261 Quick-Start Prompt

**Context:** Session 260 completed NIST Edition.additional_text architecture with 18/18 tests passing. Date component was DELETED (no separate Date component in NIST).

**Current State:**
- ✅ Edition component working with dotted notation (e2.June1908)
- ✅ Date component deleted from NIST
- ✅ All Date references removed from builder and identifiers
- ⏳ Need V1 spec alignment

**Your Task:**
Align NIST V2 test expectations with V1 specs following the IEC pattern (Sessions 254-255).

**Steps:**

1. **Read V1 specs** (20 min)
   ```bash
   # Read archived V1 NIST specs
   cat archived-gems/pubid-nist/spec/nist_pubid/identifier_spec.rb
   ```

2. **Create component spec** (60 min)
   - File: `spec/pubid_new/nist/components/edition_spec.rb`
   - Test patterns: e2, r5, e2021, r1963, e2.June1908, e2.1908
   - Test formats: :short, :long, :mr
   - NO Date component tests (deleted)

3. **Validate** (10 min)
   ```bash
   bundle exec rspec spec/pubid_new/nist/
   ```

**Architecture Notes:**

- **NO Date component** - Deleted in Session 260b
- Edition handles ALL patterns via `additional_text`
- Dotted notation: `e2.June1908` (DOT, not "rev")
- Legacy input: `e2revJune1908` → canonical: `e2.June1908`

**Key Files:**
- `lib/pubid_new/nist/components/edition.rb` - Edition with additional_text
- `lib/pubid_new/nist/builder.rb` - Handles e2rev patterns
- `lib/pubid_new/nist/identifiers/base.rb` - Renders edition (no date)

**Success:** 40-50 tests, 100% passing

**Full Plan:** See `docs/SESSION-261-CONTINUATION-PLAN.md`