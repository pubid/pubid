# Session 158 Quick Start: CSA Pre-Existing Bugs Fix

**Read First:** [`docs/SESSION-158-CONTINUATION-PLAN.md`](SESSION-158-CONTINUATION-PLAN.md:1) (comprehensive plan)

---

## CRITICAL Context from Session 157

✅ **Combined Identifiers COMPLETE and WORKING**
- 9/9 combined identifiers parsing perfectly
- has_publisher flag working
- SERIES keyword support complete
- Architecture: MODEL-DRIVEN, MECE maintained

**Current:** 195/899 (21.69%)
**Target:** 245-250/899 (27-28%) after fixing 3 pre-existing bugs

---

## Session 158 Tasks (60-90 minutes)

### Task 1: Package Portions Support (30 min)

**Add package attribute:**

File: `lib/pubid_new/csa/single_identifier.rb`
```ruby
attribute :package, :string
```

File: `lib/pubid_new/csa/builder.rb` (in build_single):
```ruby
# Package portion
if data[:package_portion]
  identifier.package = data[:package_portion].to_s
end
```

File: `lib/pubid_new/csa/identifiers/base.rb` (in to_s, after reaffirmation):
```ruby
# Package
if package
  result += " #{package}"
end
```

### Task 2: M/F Year Prefix Preservation (20 min)

**Add year_prefix attribute:**

File: `lib/pubid_new/csa/single_identifier.rb`
```ruby
attribute :year_prefix, :string  # "F" or "M"
```

File: `lib/pubid_new/csa/builder.rb` (in build_single):
```ruby
# Year prefix (F or M)
if data[:year_prefix]
  identifier.year_prefix = data[:year_prefix].to_s
end
```

File: `lib/pubid_new/csa/identifiers/base.rb` (in to_s, year section):
```ruby
if year
  separator = (year_format == "dash") ? "-" : ":"
  year_part = separator
  year_part += year_prefix if year_prefix  # NEW: Add M or F
  # ... rest of year logic
end
```

File: `lib/pubid_new/csa/identifiers/combined.rb` (in render_continuation):
```ruby
if identifier.year
  separator = (identifier.year_format == "dash") ? "-" : ":"
  year_part = separator
  year_part += identifier.year_prefix if identifier.year_prefix  # NEW
  # ... rest
end
```

### Task 3: Test and Validate (20 min)

**Test script:**
```ruby
require_relative '/Users/mulgogi/src/mn/pubid/lib/pubid_new/csa'

tests = [
  "CSA A82.30-22 Code, Handbook & Training Package",
  "CAN/CSA-C22.2 NO. 231 SERIES-M89 (R2001)",
  "CSA N285.6:F20"
]

tests.each do |input|
  result = PubidNew::Csa::Identifier.parse(input)
  match = (result.to_s == input) ? "✓" : "✗"
  puts "#{match} #{input}"
  puts "  Output: #{result.to_s}"
end
```

**Then run:**
```bash
ruby /tmp/count_csa_proper.rb
```

**Expected:** 245-250/899 (27-28%)

---

## Success Criteria

- ✅ Package portions rendering
- ✅ M/F prefixes preserved
- ✅ Classification: 245-250/899 (27-28%)
- ✅ Architecture: MODEL-DRIVEN maintained

---

## Key Points

1. **Parser already works** - Just need attributes + rendering
2. **Package is space-separated** - `" Code, Handbook & Training Package"`
3. **Year prefix goes before year** - `-M89`, `:F20`
4. **Test incrementally** - After each change
5. **Round-trip fidelity** - Must preserve exact format

---

**Next:** Session 159 will explore other patterns for additional improvements