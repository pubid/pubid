# Session 131: NESC Identifier Implementation Plan

**Created:** 2025-12-13
**Status:** CRITICAL - SEPARATE IDENTIFIER CLASSES REQUIRED
**Timeline:** 2 hours
**Expected Gain:** +40-50 identifiers

---

## NESC Background

**National Electrical Safety Code (NESC)** is published by IEEE but has distinct characteristics:
- **Purpose:** Electrical safety standards for utilities and communication systems
- **Code:** C2 (standard designation)
- **Format Variations:** Multiple identifier patterns
- **Registered Trademark:** NESC(R) notation
- **Special Types:** Handbooks, redline versions, drafts

**Publishing Authority:** IEEE Standards Association
**First Published:** 1913
**Current Status:** Updated every 5 years

---

## Architecture Design

### Identifier Class Hierarchy

```
PubidNew::Ieee::Identifiers::Nesc::Base
  ├── Standard (C2-YYYY format)
  ├── Handbook (YYYY NESC Handbook)
  ├── Redline (YYYY NESC Redline)
  └── Draft (Draft NESC)
```

### Component Requirements

**Required Components:**
- `code`: Always "C2" or implicit
- `year`: Publication year
- `edition`: Edition notation (e.g., "Premier Edition", "Seventh Edition")
- `variant`: Type of publication (Handbook, Redline, etc.)

---

## Pattern Analysis

### Pattern 1: Standard Format (C2-YYYY)
**Examples:**
- `C2-1997 National Electric Safety Code (NESC)`
- `C2-2012 National Electrical Safety Code`
- `C2-2007, National Electrical Safety Code`

**Format:** `C2-{year} National Electrical Safety Code {optional}`

**Components:**
- code: "C2"
- year: 1997, 2012, 2007
- name: "National Electrical Safety Code"
- Trademark notation optional

---

### Pattern 2: Year-First Format (YYYY NESC)
**Examples:**
- `2017 NESC(R) Handbook, Premier Edition`
- `2017 National Electrical Safety Code(R) (NESC(R))`
- `2012 NESC Handbook, Seventh Edition`

**Format:** `{year} NESC {variant} {edition}`

**Components:**
- year: 2017, 2012
- variant: Handbook, Redline, etc.
- edition: Premier, Seventh, etc.

---

### Pattern 3: Draft Format
**Examples:**
- `Draft National Electrical Safety Code, January 2016`
- `Draft NESC, June 2011`

**Format:** `Draft NESC, {month} {year}`

**Components:**
- draft: true
- month: January, June
- year: 2016, 2011

---

## Implementation Files

### 1. Base Identifier Class
**File:** `lib/pubid_new/ieee/identifiers/nesc/base.rb`

```ruby
# frozen_string_literal: true

module PubidNew
  module Ieee
    module Identifiers
      module Nesc
        class Base < Lutaml::Model::Serializable
          attribute :code, Components::Code        # "C2"
          attribute :year, Components::Date        # Publication year
          attribute :variant, :string              # Handbook, Redline, etc.
          attribute :edition, :string              # Edition notation
          attribute :draft, :boolean               # Draft flag
          attribute :month, :string                # For drafts

          def publisher_portion
            "NESC"
          end

          def to_s
            parts = []
            parts << "#{code.value}-#{year.year}" if code && year
            parts << "National Electrical Safety Code"
            parts.join(" ")
          end
        end
      end
    end
  end
end
```

### 2. Standard Identifier
**File:** `lib/pubid_new/ieee/identifiers/nesc/standard.rb`

```ruby
# frozen_string_literal: true

module PubidNew
  module Ieee
    module Identifiers
      module Nesc
        class Standard < Base
          def to_s
            "C2-#{year.year} National Electrical Safety Code"
          end
        end
      end
    end
  end
end
```

### 3. Handbook Identifier
**File:** `lib/pubid_new/ieee/identifiers/nesc/handbook.rb`

```ruby
# frozen_string_literal: true

module PubidNew
  module Ieee
    module Identifiers
      module Nesc
        class Handbook < Base
          def to_s
            parts = ["#{year.year} NESC Handbook"]
            parts << ", #{edition}" if edition
            parts.join
          end
        end
      end
    end
  end
end
```

### 4. Draft Identifier
**File:** `lib/pubid_new/ieee/identifiers/nesc/draft.rb`

```ruby
# frozen_string_literal: true

module PubidNew
  module Ieee
    module Identifiers
      module Nesc
        class Draft < Base
          def to_s
            parts = ["Draft National Electrical Safety Code"]
            parts << ", #{month} #{year.year}" if month && year
            parts.join
          end
        end
      end
    end
  end
end
```

---

## Parser Rules

### NESC Parser Module
**File:** `lib/pubid_new/ieee/nesc/parser.rb`

```ruby
# frozen_string_literal: true

module PubidNew
  module Ieee
    module Nesc
      class Parser < Parslet::Parser
        root(:nesc_identifier)

        rule(:space) { str(" ") }
        rule(:comma) { str(",") }
        rule(:digit) { match('[0-9]') }
        rule(:year) { digit.repeat(4, 4) }

        # C2 code
        rule(:c2_code) do
          str("C2")
        end

        # NESC variations
        rule(:nesc_name) do
          (
            str("National Electrical Safety Code(R)") |
            str("National Electrical Safety Code") |
            str("National Electric Safety Code") |
            str("NESC(R)") |
            str("NESC")
          )
        end

        # Registered trademark
        rule(:registered) do
          str("(R)").maybe
        end

        # Edition
        rule(:edition) do
          (
            str("Premier Edition") |
            str("First Edition") |
            str("Second Edition") |
            str("Third Edition") |
            str("Fourth Edition") |
            str("Fifth Edition") |
            str("Sixth Edition") |
            str("Seventh Edition") |
            str("Eighth Edition") |
            str("Ninth Edition") |
            str("Tenth Edition")
          ).as(:edition)
        end

        # Variant type
        rule(:variant) do
          (
            str("Handbook") |
            str("Redline")
          ).as(:variant)
        end

        # Month
        rule(:month) do
          (
            str("January") | str("February") | str("March") |
            str("April") | str("May") | str("June") |
            str("July") | str("August") | str("September") |
            str("October") | str("November") | str("December")
          ).as(:month)
        end

        # Pattern 1: C2-YYYY format
        rule(:c2_standard) do
          c2_code.as(:code) >>
          str("-") >>
          year.as(:year) >>
          (comma.maybe >> space).maybe >>
          nesc_name >>
          (space >> str("(NESC)")).maybe
        end

        # Pattern 2: YYYY NESC format
        rule(:year_first) do
          year.as(:year) >>
          space >>
          nesc_name >>
          (space >> registered).maybe >>
          (space >> str("(NESC") >> registered >> str(")")).maybe >>
          (space >> variant).maybe >>
          (comma >> space >> edition).maybe
        end

        # Pattern 3: Draft format
        rule(:draft_nesc) do
          str("Draft").as(:draft) >>
          space >>
          nesc_name >>
          comma >> space >>
          month >> space >> year.as(:year)
        end

        # Main identifier rule
        rule(:nesc_identifier) do
          draft_nesc | c2_standard | year_first
        end
      end
    end
  end
end
```

---

## Builder Implementation

**File:** `lib/pubid_new/ieee/nesc/builder.rb`

```ruby
# frozen_string_literal: true

module PubidNew
  module Ieee
    module Nesc
      class Builder
        def build(parsed_hash)
          # Determine identifier type
          identifier_class = if parsed_hash[:draft]
                              Identifiers::Nesc::Draft
                            elsif parsed_hash[:variant]
                              case parsed_hash[:variant].to_s
                              when "Handbook"
                                Identifiers::Nesc::Handbook
                              when "Redline"
                                Identifiers::Nesc::Redline
                              else
                                Identifiers::Nesc::Base
                              end
                            elsif parsed_hash[:code]
                              Identifiers::Nesc::Standard
                            else
                              Identifiers::Nesc::Base
                            end

          identifier = identifier_class.new

          # Set code if present
          if parsed_hash[:code]
            identifier.code = Components::Code.new(
              value: parsed_hash[:code].to_s
            )
          end

          # Set year
          if parsed_hash[:year]
            identifier.year = Components::Date.new(
              year: parsed_hash[:year].to_s.to_i
            )
          end

          # Set variant
          identifier.variant = parsed_hash[:variant].to_s if parsed_hash[:variant]

          # Set edition
          identifier.edition = parsed_hash[:edition].to_s if parsed_hash[:edition]

          # Set draft flag
          identifier.draft = true if parsed_hash[:draft]

          # Set month for drafts
          identifier.month = parsed_hash[:month].to_s if parsed_hash[:month]

          identifier
        end
      end
    end
  end
end
```

---

## Integration with Main IEEE Parser

**Update:** `lib/pubid_new/ieee/parser.rb`

```ruby
# Add NESC delegation at top level (around line 300)
rule(:identifier) do
  nesc_identifier |
  ieee_identifier |
  # ... other patterns
end

rule(:nesc_identifier) do
  # Detect NESC patterns
  (
    str("C2-") |
    (year >> space >> str("NESC")) |
    str("Draft National Electrical Safety Code")
  ).present? >>
  Nesc::Parser.new.nesc_identifier
end
```

---

## Testing Strategy

### Unit Tests
**File:** `spec/pubid_new/ieee/identifiers/nesc/standard_spec.rb`

```ruby
require "spec_helper"

RSpec.describe PubidNew::Ieee::Identifiers::Nesc::Standard do
  describe "#parse" do
    context "C2-YYYY format" do
      let(:input) { "C2-1997 National Electric Safety Code (NESC)" }
      let(:parsed) { PubidNew::Ieee.parse(input) }

      it "parses as NESC::Standard" do
        expect(parsed).to be_a(described_class)
      end

      it "extracts year" do
        expect(parsed.year.year).to eq(1997)
      end

      it "extracts code" do
        expect(parsed.code.value).to eq("C2")
      end

      it "round-trips correctly" do
        expect(parsed.to_s).to eq("C2-1997 National Electrical Safety Code")
      end
    end
  end
end
```

### Integration Tests
- 15 Standard format tests
- 10 Handbook format tests
- 5 Draft format tests
- 5 Redline format tests
- **Total:** 35 new tests

---

## Expected Results

**Before:**
- IEEE: 8,388/9,537 (87.95%)

**After:**
- IEEE: 8,428-8,438/9,537 (88.37-88.48%)
- Improvement: +40-50 identifiers (+0.42-0.53pp)

---

## Implementation Timeline

| Task | Duration | Cumulative |
|------|----------|------------|
| 1. Create Base class | 15 min | 15 min |
| 2. Create Standard class | 10 min | 25 min |
| 3. Create Handbook class | 10 min | 35 min |
| 4. Create Draft class | 10 min | 45 min |
| 5. Create Parser | 30 min | 75 min |
| 6. Create Builder | 20 min | 95 min |
| 7. Integration | 10 min | 105 min |
| 8. Unit Tests | 15 min | 120 min |
| **Total** | **2 hours** | **120 min** |

---

## Success Criteria

- ✅ NESC as separate identifier classes (not just parser patterns)
- ✅ All 3 major patterns supported (C2, Year-first, Draft)
- ✅ 35+ unit tests passing
- ✅ +40-50 identifiers gained
- ✅ Clean MODEL-DRIVEN architecture
- ✅ Zero regressions

---

## Next Steps (Session 132)

After NESC completion:
- IEC/IEEE Dual Standards implementation
- Expected +80-120 additional identifiers
- Extends Joint Development architecture

---

**Status:** READY FOR IMPLEMENTATION 🚀