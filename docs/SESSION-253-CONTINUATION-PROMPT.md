# Session 253 Quick Start: NIST IR Corrections

**Read Full Plan:** [`docs/SESSION-253-CONTINUATION-PLAN.md`](SESSION-253-CONTINUATION-PLAN.md:1)

---

## Critical Issues

**Issue 1:** Class name wrong - `InternalReport` should be `InteragencyReport`  
**Issue 2:** `NIST IR 8270-draft2` fails to parse  
**Issue 3:** Should render as `NIST IR 8270 2pd`

---

## Quick Fix (90 minutes)

### Part A: Rename Class (20 min)

1. **Rename class** in [`lib/pubid_new/nist/identifiers/internal_report.rb`](lib/pubid_new/nist/identifiers/internal_report.rb:13)
   - Line 13: `class InternalReport` → `class InteragencyReport`
   - Line 8: Update comment "Internal Report" → "Interagency Report"

2. **Update registry** in [`lib/pubid_new/nist/scheme.rb`](lib/pubid_new/nist/scheme.rb:6)
   - Line 6: `require_relative "identifiers/internal_report"` stays same (filename)
   - Line 36: `"IR" => Identifiers::InternalReport,` → `"IR" => Identifiers::InteragencyReport,`
   - Line 61: `Identifiers::InternalReport,` → `Identifiers::InteragencyReport,`

### Part B: Fix Draft Parsing (30 min)

**Update** [`lib/pubid_new/nist/parser.rb`](lib/pubid_new/nist/parser.rb:632) line 632:

```ruby
# Draft stage - enhanced for -draft{N} → {N}pd
rule(:draft) do
  (
    space >> str("(Draft)") |
    dash >> str("draft") >> space >> digits.as(:draft_number) |
    dash >> str("draft") |
    pd_suffix
  ).as(:draft)
end
```

### Part C: Fix Rendering (30 min)

**Update** [`lib/pubid_new/nist/identifiers/base.rb`](lib/pubid_new/nist/identifiers/base.rb:1) to_s method:

Add draft rendering logic to convert `-draft 2` → ` 2pd`

### Part D: Builder Casting (10 min)

**Update** [`lib/pubid_new/nist/builder.rb`](lib/pubid_new/nist/builder.rb:1) cast method:

Add when clause for `:draft` and `:draft_number`

---

## Test

```bash
bundle exec rspec spec/pubid_new/nist/
cd spec/fixtures && ruby run_classify.rb nist
```

**Expected:** `NIST IR 8270-draft2` → `NIST IR 8270 2pd` ✅

---

**Created:** 2026-01-02  
**Timeline:** 90 minutes  
**Status:** Ready to execute!
