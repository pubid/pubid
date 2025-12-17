# Session 161 Continuation Prompt: CsaAdoptedIdentifier Implementation

**Read this FIRST:** [`docs/SESSION-161-CONTINUATION-PLAN.md`](SESSION-161-CONTINUATION-PLAN.md:1)

---

## Quick Context

**Session 160 Complete:** CanadianAdoptedIdentifier wrapper pattern (10/10 tests, 100%) ✅
**Session 161 Goal:** CsaAdoptedIdentifier for CSA adoptions of ISO/IEC/CISPR standards
**Timeline:** 90 minutes
**Expected Gain:** +100-150 identifiers

---

## Key Distinction

**CanadianAdopted:** `CAN/{CSA standard}` - Canadian adoption wrapper
**CsaAdopted:** `CSA {ISO/IEC/CISPR standard}` - CSA adoption of international standards

Examples:
- `CSA ISO/IEC TR 12785-3:15`
- `CSA ISO/IEC TR 19758:04 (R2024)`
- `CSA CISPR 16-1-1:18`

---

## Implementation Tasks (90 min)

### Part A: Create CsaAdoptedIdentifier (30 min)

**File:** `lib/pubid_new/csa/identifiers/csa_adopted.rb`

```ruby
class CsaAdopted < WrapperIdentifier
  def to_s
    # Convert 4-digit years to 2-digit (ISO format → CSA format)
    base_str = wrapped_identifier.to_s

    if base_str =~ /:(\d{4})\b/
      year = $1
      if year.start_with?("20")
        short_year = year[2..3]
        base_str = base_str.sub(":#{year}", ":#{short_year}")
      end
    end

    result = "CSA #{base_str}"
    result += " (R#{reaffirmation})" if reaffirmation
    result
  end
end
```

### Part B: Update Identifier.parse (40 min)

**File:** `lib/pubid_new/csa/identifier.rb`

Add after CAN/ detection:

```ruby
# Detect CSA adoption of international standards
if input.match?(/^CSA (ISO\/IEC|CISPR|IEC|CEI|ISO)\s/)
  wrapped_input = input.sub(/^CSA\s+/, "")

  # Extract reaffirmation first
  reaffirm_year = nil
  if wrapped_input =~ /\(R(\d{4})\)/
    reaffirm_year = $1
    wrapped_input = wrapped_input.sub(/\s*\(R\d{4}\)/, "")
  end

  # Parse with external parser
  wrapped_identifier = parse_external_standard(wrapped_input)
  return nil unless wrapped_identifier

  require_relative "identifiers/csa_adopted"
  result = Identifiers::CsaAdopted.new
  result.wrapped_identifier = wrapped_identifier
  result.reaffirmation = reaffirm_year if reaffirm_year

  return result
end
```

Add helper method:

```ruby
def self.parse_external_standard(input)
  # Try ISO/IEC first
  if input.match?(/^(ISO\/IEC|ISO|IEC|CEI)\s/)
    require_relative "../iso"
    return PubidNew::Iso.parse(input) rescue nil
  end

  # Try CISPR (uses IEC parser)
  if input.match?(/^CISPR\s/)
    require_relative "../iec"
    return PubidNew::Iec.parse(input) rescue nil
  end

  nil
end
```

### Part C: Update Requires (5 min)

**File:** `lib/pubid_new/csa.rb`

Add:
```ruby
require_relative "csa/identifiers/csa_adopted"
```

### Part D: Test Implementation (15 min)

```ruby
test_patterns = [
  "CSA ISO/IEC TR 12785-3:15",
  "CSA ISO/IEC TR 19758:04 (R2024)",
  "CSA CISPR 16-1-1:18",
  "CSA ISO/IEC 61010-1:14 (R2019)",
  "CSA IEC 60601-1:08",
  "CSA ISO 9001:15"
]

# Test each pattern for round-trip fidelity
```

---

## Critical Points

1. **Year Format:** ISO uses `:2015`, CSA uses `:15` - convert in rendering
2. **External Parsers:** Use PubidNew::Iso and PubidNew::Iec
3. **Reaffirmation:** Extract before parsing wrapped identifier
4. **Error Handling:** Return nil if external parser fails
5. **MECE:** CsaAdopted ≠ CanadianAdopted (different wrapped types)

---

## Success Criteria

- ✅ 6+ patterns with perfect round-trip fidelity
- ✅ Year format correct (2-digit)
- ✅ ISO/IEC TR patterns working
- ✅ CISPR patterns working
- ✅ Reaffirmation working
- ✅ No string manipulation, pure wrapper pattern

---

## Quick Test Command

```bash
cd /Users/mulgogi/src/mn/pubid && ruby -e "
require_relative 'lib/pubid_new/csa'

['CSA ISO/IEC TR 12785-3:15',
 'CSA ISO/IEC TR 19758:04 (R2024)',
 'CSA CISPR 16-1-1:18'].each do |pattern|
  result = PubidNew::Csa::Identifier.parse(pattern)
  puts result ? \"✓ #{pattern}\" : \"✗ #{pattern}\"
  puts \"  Output: #{result.to_s}\" if result
end
"
```

---

**Next After Session 161:** PackageIdentifier + CompositeIdentifier (Session 162, 120 min)

**GO!** 🚀