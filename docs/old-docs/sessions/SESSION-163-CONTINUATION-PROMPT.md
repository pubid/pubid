# Session 163 Continuation Prompt: CSA Complete Architecture (COMPRESSED)

**Read this FIRST:** [`docs/SESSION-163-CONTINUATION-PLAN.md`](SESSION-163-CONTINUATION-PLAN.md:1)

---

## Quick Context

**Session 162 Complete:** PackageIdentifier (3/3 tests, 100%) ✅  
**Session 163 Goal:** Complete ALL remaining CSA work in ONE session  
**Timeline:** 90-120 minutes (COMPRESSED)  
**Expected Gain:** +35-50 identifiers (to 54-56%)

---

## What's Left to Implement

**SeriesIdentifier only** - SERIES as primary type (not keyword modifier)

Examples:
- `CSA MH SERIES 3.14:20`
- `CSA RV SERIES 1:19`
- `CSA SERIES Z1000:22`

---

## Implementation Tasks (90-120 min)

### Part A: SeriesIdentifier (60 min)

**1. Create Series class** (30 min)

**File:** `lib/pubid_new/csa/identifiers/series.rb`

```ruby
# frozen_string_literal: true

module PubidNew
  module Csa
    module Identifiers
      class Series < Base
        attribute :series_prefix, :string

        def to_s
          result = publisher_prefix_portion
          result += "#{series_prefix} " if series_prefix && !series_prefix.empty?
          result += "SERIES "
          result += code.to_s
          result += year_portion
          result += language_portion
          result += reaffirmation_portion
          result
        end
      end
    end
  end
end
```

**2. Update parser** (15 min)

**File:** `lib/pubid_new/csa/parser.rb`

Add series pattern rule

**3. Update builder** (10 min)

**File:** `lib/pubid_new/csa/builder.rb`

Add series type routing

**4. Update requires** (5 min)

**File:** `lib/pubid_new/csa.rb`

```ruby
require_relative "csa/identifiers/series"
```

---

### Part B: Documentation (20 min)

**File:** `README.adoc`

Add complete CSA section:
- 9 identifier types table
- Architecture patterns (Wrapper, Composite)
- Usage examples
- Year format preservation

See full template in continuation plan.

---

### Part C: Memory Bank & Archival (10 min)

**1. Update context** (5 min)

**File:** `.kilocode/rules/memory-bank/context.md`

Add Sessions 162-163 summary

**2. Archive old docs** (5 min)

Move to `docs/old-docs/sessions/`:
- SESSION-161-*.md
- SESSION-162-*.md

---

## Success Criteria

- ✅ SERIES patterns parsing correctly
- ✅ 9/9 CSA identifier types complete
- ✅ README.adoc updated
- ✅ Memory bank current
- ✅ All docs archived
- ✅ CSA at 54-56%

---

## Quick Test

```bash
cd /Users/mulgogi/src/mn/pubid && ruby -e "
require_relative 'lib/pubid_new/csa'

['CSA MH SERIES 3.14:20',
 'CSA RV SERIES 1:19',
 'CSA SERIES Z1000:22'].each do |p|
  r = PubidNew::Csa::Identifier.parse(p)
  puts r ? \"✓ #{p}\" : \"✗ #{p}\"
end
"
```

---

**After Session 163:** CSA architecture 100% COMPLETE! 🎉

**GO!** 🚀