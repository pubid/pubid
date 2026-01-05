# Session 263 Quick-Start Prompt

**Context:** Session 262 updated Circular spec to V2 Edition API. 50 tests, 0 failures, 14 pending (parser gaps).

**Current State:**
- ✅ Circular spec aligned with V2 Edition API
- ✅ Architecture validated (e2revJune1908 → e2.June1908)
- ⏳ 14 parser patterns need implementation (V1 has them, V2 doesn't)

**Your Task:**
Implement the 14 missing parser patterns to make ALL 50 Circular tests pass (100%, 0 pending).

**Critical Finding:**
V1 DOES parse all 14 patterns. This isn't about "marking gaps" - it's about implementing missing V2 parser functionality to achieve V1 parity.

**Steps:**

1. **Analyze V1 Implementation** (30 min)
   ```bash
   # Read V1 parser to understand patterns
   cat archived-gems/pubid-nist/lib/pubid/nist/parsers/circ.rb
   cat archived-gems/pubid-nist/spec/nist_pubid/document/circ_spec.rb
   ```

2. **Implement Missing Patterns** (120 min) in `lib/pubid_new/nist/parser.rb`:

   **Pattern 1: Volume** (`NBS CIRC 539v10`)
   - Add `volume` rule: `str("v") >> digits.as(:volume)`

   **Pattern 2: Edition with year** (`NBS CIRC 11e2-1915`)
   - V1 converts to: `NBS CIRC 11-1915e2`
   - Add pattern for `e2-1915` format

   **Pattern 3: Bare edition** (`NBS CIRC e2`)
   - V1 converts to: `NBS CIRC 2e2`
   - Handle edition without number prefix

   **Pattern 4: Historical edition+month** (`NBS CIRC 15-April1909`)
   - V1 converts to: `NBS CIRC 15e190904`
   - Pattern: `-MonthYYYY` → Edition(type: "-", additional_text: "MonthYYYY")

   **Pattern 5: Supplement variants**
   - `sup-1924` → supplement with year
   - `e2sup` → edition + supplement
   - `supJan1924` → supplement with month+year
   - `supprev` → supplement with revision

   **Pattern 6: Supplement date range** (`supJun1925-Jun1926`)
   - V1 converts to: `NBS CIRC 24e7sup2`
   - Handle month range in supplements

3. **Update Builder** (20 min) in `lib/pubid_new/nist/builder.rb`:
   ```ruby
   when :volume
     value.to_s
   when :edition_with_year
     # Separate edition from year
   when :historical_edition
     Edition.new(type: "-", additional_text: "#{month}#{year}")
   # etc.
   ```

4. **Test** (10 min):
   ```bash
   bundle exec rspec spec/pubid_new/nist/identifiers/circular_spec.rb --format doc
   ```

   **Expected:** 50 examples, 50 passing, 0 pending ✅

**V1 Reference Patterns:**
- `NBS CIRC 11e2-1915` → `NBS CIRC 11-1915e2`
- `NBS CIRC e2` → `NBS CIRC 2e2`
- `NBS CIRC 15-April1909` → `NBS CIRC 15e190904`
- `NBS CIRC 13e2revJune1908` → `NBS CIRC 13e2rJune1908` (V2 uses dot: `e2.June1908`)
- `NBS CIRC 24supJan1924` → `NBS CIRC 24e192401sup`
- `NBS CIRC 539v10` → `NBS CIRC 539v10` (preserved)

**Key Files:**
- Parser: `lib/pubid_new/nist/parser.rb`
- Builder: `lib/pubid_new/nist/builder.rb`
- V1 reference: `archived-gems/pubid-nist/lib/pubid/nist/parsers/circ.rb`
- Spec: `spec/pubid_new/nist/identifiers/circular_spec.rb`

**Architecture Notes:**
- **NO Date component** - NIST doesn't use separate Date (deleted in Session 260)
- **Edition.additional_text** - Handles all month/year info
- **Dotted notation** - V2 canonical format uses dots (e2.June1908)
- **Parse legacy, render canonical** - Accept "rev", output dot

**Success:** All 50 Circular tests passing, ready for CommercialStandard/Handbook in Session 264!

**Full Plan:** See [`docs/SESSION-263-CONTINUATION-PLAN.md`](SESSION-263-CONTINUATION-PLAN.md)