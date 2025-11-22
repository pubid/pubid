# Continuation Prompt for Next Session

## Copy-Paste This to Start:

```
PubID v2 - ANSI Creation + NIST Fixes (Session 3)

Branch: rt-new-lutaml-model, PR: #19

Previous Session (2025-11-16):
✅ ISO: 0% → 98.47% (7,544/7,661 passing) - MAJOR BREAKTHROUGH
✅ Fixed parse() method + original format preservation pattern
✅ Started ANSI flavor (module created, needs implementation)

Current Status:
- 11/12 flavors at 100% or 97%+
- ISO: 98.47% (production-ready)
- NIST: ~97.8% (22 failures in 3 patterns)
- ANSI: 0% (just started)

TASKS FOR THIS SESSION (4-5 hours):

1. COMPLETE ANSI FLAVOR (2-3 hours) - Priority 1
   Files needed:
   - lib/pubid_new/ansi/parser.rb (use ISO as template)
   - lib/pubid_new/ansi/scheme.rb
   - lib/pubid_new/ansi/builder.rb
   - lib/pubid_new/ansi/identifier.rb
   - lib/pubid_new/ansi/single_identifier.rb
   - lib/pubid_new/ansi/identifiers/american_national_standard.rb
   
   Test with:
   - ANSI X3.4-1986
   - ANSI C63.4-2014
   - ANSI/ISO 9899:1990
   - ANSI/IEEE 802.3-2012

2. FIX NIST (1-2 hours) - Priority 2
   Three targeted fixes:
   a) "sup" renders as (sup) → should be " sup" (14 cases)
      File: lib/pubid_new/nist/scheme.rb:72
   b) "e2-1915" doesn't parse (4 cases)
      File: lib/pubid_new/nist/parser.rb:110-125
   c) "supJan1924" doesn't parse (4 cases)
      File: lib/pubid_new/nist/parser.rb:141
   
   IMPORTANT: Test incrementally! Last attempt broke basic parsing.

3. VERIFY (30 min)
   - ANSI: Sample cases pass
   - NIST: All 22 failures fixed
   - ISO: Still at 98.47%

Reference Documentation:
- docs/CONTINUATION-PLAN-2025-11-17-ANSI-NIST.md (detailed plan)
- docs/SESSION-SUMMARY-2025-11-16-ISO-BREAKTHROUGH.md (what we did)
- docs/ISO-NIST-FIX-STATUS-2025-11-16.md (technical details)

Templates:
- lib/pubid_new/iso/ (ANSI template)
- lib/pubid_new/ieee/ (clean reference)

Start with: Create lib/pubid_new/ansi/parser.rb using ISO parser as template
```

## Quick Reference

### ANSI Parser Skeleton
```ruby
require "parslet"
require_relative "../parser/common_parse_rules"

module PubidNew
  module Ansi
    class Parser < Parslet::Parser
      include ::PubidNew::Parser::CommonParseRules
      
      root :identifier
      
      rule(:publisher) { str("ANSI").as(:publisher) }
      rule(:copublishers) { 
        (str("/") >> (str("ISO") | str("IEEE") | str("IEC")).as(:copublisher)).repeat
      }
      rule(:number_with_part) { ... }
      rule(:date) { str(":") >> year_digits.as(:date) }
      rule(:identifier) { 
        publisher >> copublishers.maybe >> space >> number_with_part >> date.maybe
      }
    end
  end
end
```

### NIST Quick Fixes

**Fix 1 - "sup" rendering** (lib/pubid_new/nist/scheme.rb:72):
```ruby
# Change from:
result += " (#{translation})" if translation

# To:
if translation == "sup"
  result += " sup"
elsif translation
  result += " (#{translation})"
end
```

**Fix 2 - "e2-1915"** (lib/pubid_new/nist/parser.rb, add before line 123):
```ruby
# Edition number with dash and year
((str("e") | str(" E")) >> match("[0-9]").repeat(1, 3).as(:edition) >> 
  dash >> digits.as(:edition_year)) |
```

**Fix 3 - "supJan1924"** (lib/pubid_new/nist/parser.rb:141):
```ruby
# Change match("[A-Z0-9]") to match("[A-Za-z0-9]")
```

---

## Session Goal

**Target**: 13/13 flavors at 97%+ pass rate

**Timeline**: 4-5 hours

**Success Criteria**:
- ANSI parses and renders sample identifiers correctly
- NIST passes all 22 previously failing test cases  
- ISO remains at 98.47% (no regressions)
- All code follows Ruby style guide
- Documentation updated

Ready to proceed!