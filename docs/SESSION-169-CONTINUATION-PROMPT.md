# Session 169 Continuation Prompt: IEEE 90%+ with InterpretationIdentifier

**Read First:** [`docs/SESSION-169-CONTINUATION-PLAN.md`](SESSION-169-CONTINUATION-PLAN.md:1)

---

## Quick Context

**Session 168 Complete:** IEEE at 89.63% after +126 ID breakthrough! ✅

**Current Status:**
- IEEE: 8,548/9,537 (89.63%)
- Gap to 90%: Only +37 identifiers
- Overall: 87,917/88,924 (98.87%)

**Session 169 Goal:** IEEE 90%+ focusing on IEEE Std and AIEE patterns

**Priority Order:** IEEE Std > AIEE > IEC-first > ANSI

---

## Critical Task: InterpretationIdentifier Architecture (30 min)

**Issue:** /INT currently handled as boolean flag (incorrect architecture)
**Solution:** InterpretationIdentifier as SupplementIdentifier (like Amendment/Corrigendum)

### Step 1: Create Interpretation Class

**File:** `lib/pubid_new/ieee/identifiers/interpretation.rb` (NEW)

```ruby
# frozen_string_literal: true

require "lutaml/model"
require_relative "base"

module PubidNew
  module Ieee
    module Identifiers
      # Interpretation identifier - supplements a base standard with interpretation
      # Example: IEEE Std 1003.1-2008/INT
      class Interpretation < Lutaml::Model::Serializable
        attribute :base_identifier, Base
        attribute :year, :string

        def to_s
          result = base_identifier.to_s
          result += "/INT"
          result += "-#{year}" if year
          result
        end

        def self.parse(string)
          Base.parse(string)
        end
      end
    end
  end
end
```

### Step 2: Update Parser

**File:** `lib/pubid_new/ieee/parser.rb`

**Add preprocessing for /lNT typo** (around line 598):
```ruby
# Fix /lNT typo (lowercase L as 1)
cleaned = cleaned.gsub(/\/lNT/, '/INT')

# Fix I99O typo -> 1990
cleaned = cleaned.gsub(/\bI99O\b/, '1990')
```

**Add interpretation_identifier rule** (around line 560):
```ruby
# Interpretation identifier with recursive base parsing
rule(:interpretation_identifier) do
  # Capture complete base identifier
  (
    ((publisher >> (copublisher.repeat).as(:copublishers)).as(:publishers) >> space).maybe >>
    (type_word.as(:type) >> space?).maybe >>
    number >>
    (part_subpart_year | edition).maybe
  ).as(:base_identifier) >>
  slash >> str("INT") >>
  (dash >> year_digits.as(:interpretation_year) |
   (comma >> space >> month_name >> space >> year_digits.as(:interpretation_year)) |
   (space >> month_name >> space >> year_digits.as(:interpretation_year))).maybe >>
  (comma >> space >> year_digits >> space >> str("Edition")).maybe
end
```

**Add to identifier rule** (around line 620, BEFORE corrigendum_identifier):
```ruby
rule(:identifier) do
  aiee_identifier |
  ire_identifier |
  nesc_identifier |
  interpretation_identifier |  # NEW - HIGH PRIORITY
  csa_dual_published |
  corrigendum_identifier |
  # ... rest
end
```

### Step 3: Update Builder

**File:** `lib/pubid_new/ieee/builder.rb`

**Add interpretation handling** (around line 135):
```ruby
# Handle interpretation supplements (check for base_identifier + /INT)
if parsed_hash[:base_identifier] && parsed_hash[:interpretation_year]
  return build_interpretation_supplement(parsed_hash)
end
```

**Add method** (around line 230):
```ruby
# Build interpretation supplement with recursive base parsing
def build_interpretation_supplement(parsed_hash)
  # Reconstruct and parse base identifier
  base_string = reconstruct_base_string(parsed_hash[:base_identifier])
  base_identifier = Identifiers::Base.parse(base_string)

  # Extract interpretation attributes
  interpretation_year = extract_value(parsed_hash[:interpretation_year])

  require_relative "identifiers/interpretation"
  Identifiers::Interpretation.new(
    base_identifier: base_identifier,
    year: interpretation_year
  )
end

# Helper: reconstruct base identifier string from parsed components
def reconstruct_base_string(base_data)
  # Similar to corrigendum logic
  parts = []

  if base_data[:publishers]
    pub_data = base_data[:publishers]
    publisher_str = extract_value(pub_data[:publisher])
    if pub_data[:copublishers] && !pub_data[:copublishers].empty?
      copubs = pub_data[:copublishers]
      copubs = [copubs] unless copubs.is_a?(Array)
      copub_strs = copubs.map { |cp| extract_value(cp[:copublisher]) }.compact
      publisher_str += "/" + copub_strs.join("/") unless copub_strs.empty?
    end
    parts << publisher_str
  end

  parts << extract_value(base_data[:type]) if base_data[:type]

  number_str = extract_value(base_data[:number])
  number_str += ".#{extract_value(base_data[:part])}" if base_data[:part]
  number_str += "-#{extract_value(base_data[:year])}" if base_data[:year]

  parts << number_str
  parts.join(" ")
end
```

**Expected:** Proper MODEL-DRIVEN architecture for /INT patterns

---

## Priority 2: Reaffirmed + Revision Sequential (20 min)

**Pattern (~10 IEEE Std IDs):**
```
IEEE Std 117-1974 (Reaffirmed 1984) (Revision of IEEE Std 117-1956)
ANSI/IEEE Std 101-1987(R2010) (Revision of IEEE Std 101-1972)
```

**Parser:** Already captures both - no change needed
**Base rendering:** Handle both reaffirmed AND relationships

---

## Priority 3: Data Quality (10 min)

Quick typo fixes already added in Step 2 preprocessing.

---

## Expected Results

- After InterpretationIdentifier: 8,548/9,537 (architecture improved)
- After Sequential Parenthetical: 8,558+/9,537 (89.74%+)
- After IEC-first (if time): 8,585+/9,537 (90%+) ✅

---

**Start:** Create Interpretation class → Update parser → Update builder → Test!