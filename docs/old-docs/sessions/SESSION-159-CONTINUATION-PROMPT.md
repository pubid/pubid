# Session 159 Quick Start: CSA Enhancement to 60%+

**Read First:** [`docs/SESSION-159-CONTINUATION-PLAN.md`](SESSION-159-CONTINUATION-PLAN.md:1) (comprehensive plan)

---

## CRITICAL Context from Session 158

✅ **Session 158 COMPLETE - CSA at 443/899 (49.28%)**
- Package portions working
- M/F year prefix preservation working
- Publisher prefix preservation (CAN/CSA-, CAN3-, CSA) working
- SERIES keyword rendering working
- **Improvement:** +248 identifiers from Session 157!

**Current:** 443/899 (49.28%)
**Target:** 540+/899 (60%+)

---

## Session 159 Tasks (60-90 minutes)

### Task 1: Combined Comma Package Support (15 min)

**Update parser rule:**

File: `lib/pubid_new/csa/parser.rb` (around line 218)
```ruby
# Combined with comma (CSA B149.1:25, CSA B149.2:25 & Training Package)
rule(:combined_comma) do
  csa_code.as(:first) >>
  comma >> space >>
  csa_code.as(:second) >>
  reaffirmation.maybe >>
  (
    (space >> ampersand >> package_portion) |
    package_portion
  ).as(:package_portion).maybe
end
```

### Task 2: Optional CSA Prefix (30 min)

**Add code_only_identifier rule:**

File: `lib/pubid_new/csa/parser.rb` (around line 232)
```ruby
# Code-only identifier (no CSA prefix)
rule(:code_only_identifier) do
  code_pattern >>
  no_portion.maybe >>
  (colon_year | dash_year).maybe >>
  (space >> str("PACKAGE")).maybe.as(:package_portion)
end

# Update main identifier rule
rule(:identifier) do
  iso_iec_adoption |
  bundled_identifier |
  combined_slash |
  combined_comma |
  single_identifier |
  code_only_identifier  # Try last
end
```

**Update builder if needed** to handle code_only (no publisher_prefix)

### Task 3: Test and Validate (15 min)

```bash
cd /Users/mulgogi/src/mn/pubid
ruby /tmp/count_csa_proper.rb
```

**Expected:** 540+/899 (60%+)

---

## Success Criteria

- ✅ Combined comma with package working
- ✅ Optional CSA prefix working
- ✅ CSA at 540+/899 (60%+)
- ✅ Architecture: MODEL-DRIVEN maintained

---

## Key Points

1. **Combined comma**: Already has basic structure, just need package capture
2. **Code-only**: New rule for identifiers without CSA prefix
3. **Test incrementally**: After each change
4. **Parser-only**: No architecture changes needed

---

**Next:** Implement both patterns, test, and celebrate 60%+! 🎉