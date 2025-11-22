# IEEE & NIST Continuation Plan

## Current Status

**Completed: 8/10 Flavors at 100%**
- IEC, JIS, ETSI, ITU, CCSDS, ISO, BSI, CEN: All production-ready

**Remaining: 2/10 Flavors**
- IEEE: 89.1% (7,854/8,817) 
- NIST: 92.3% (~18,000/~19,500)

## IEEE Continuation Tasks

### Created Identifier Classes

1. `lib/pubid_new/ieee/identifiers/adopted_standard.rb` ✅
   - For: "IEEE Std No 18-1968 (ANSI C55.1-1968)"
   - Semantic: IEEE adopted ANSI/ISO/IEC standard

2. `lib/pubid_new/ieee/identifiers/dual_published.rb` ✅
   - For: "ANSI C37.61-1973 and IEEE Std 321-1973"
   - Semantic: Jointly published by two organizations

3. `lib/pubid_new/ieee/identifiers/redlined_standard.rb` ✅
   - For: "IEEE Std 1018-2013 (Revision of IEEE Std 1018-2004) - Redline"
   - Semantic: Standard with revision note and redline flag

### Remaining Failures (963 total)

**Pattern Breakdown:**
- Parenthetical adoptions: 204 cases
- IEC/IEEE copublished: 196 cases  
- Draft version.iteration: 174 cases (e.g., D11.1 = version 11, iteration 1)
- Dual published "and": 16 cases
- IEC edition formats: 11 cases
- Other legacy: 362 cases

### Implementation Steps

**Step 1: Wire DualPublished (Est. 2-3 hours)**
```
# Parser: Detect " and " separator
rule(:dual_and) do
  identifier.as(:first) >> str(" and ") >> identifier.as(:second)
end

rule(:root) { dual_and | identifier }

# Builder: Route to DualPublished
if parsed[:first] && parsed[:second]
  DualPublished.new(
    first_identifier: build(parsed[:first]),
    second_identifier: build(parsed[:second])
  )
end
```

**Step 2: Wire AdoptedStandard (Est. 3-4 hours)**
```
# Parser: Capture parenthetical
rule(:parenthetical) do
  space >> str("(") >> 
  (str(")").absent? >> match(".")).repeat(1).as(:adopted_string) >>
  str(")")
end

# Builder: Parse adopted string and route
if parsed[:parenthetical_string]
  adopted = parse_organization_identifier(parsed[:parenthetical_string])
  AdoptedStandard.new(
    ieee_identifier: base_id,
    adopted_identifier: adopted
  )
end
```

**Step 3: Handle Draft Version.Iteration (Est. 2-3 hours)**
```
# Parser: Capture version and iteration separately
rule(:draft_version) do
  str("D") >> digits.as(:draft_version) >> 
  (dot >> digits.as(:draft_iteration)).maybe
end

# Builder: Store both
draft_version: data[:draft_version],
draft_iteration: data[:draft_iteration]
```

**Step 4: IEC/IEEE Copublished (Est. 4-5 hours)**
```
# Skip pure IEC entries (no IEEE involvement)
if identifier.start_with?('IEC ') && !identifier.include?('IEEE')
  # Don't parse - it's presented IEC with month
  next
end

# Parse IEC/IEEE where IEEE is copublisher
if identifier =~ /^IEC\/IEEE/
  # Route to IeeeVersionOfIec class
end
```

**Step 5: Testing + Iteration (Est. 6-8 hours)**
- Test each change incrementally
- Fix regressions
- Verify comprehensive fixture improves

**Total IEEE: 17-23 hours (2-3 days)**

## NIST Continuation Tasks

### Created Identifier Classes

1. `lib/pubid_new/nist/identifiers/base.rb` ✅
   - 4 output styles: full, abbreviated, short, mr

2. `lib/pubid_new/nist/identifiers/commercial_standard_emergency.rb` ✅
   - For: "NBS CS e104-43"  
   - Format: CS(E) edition-year

3. `lib/pubid_new/nist/identifiers/commercial_standards_monthly.rb` ✅
   - For: "NBS CSM 1"
   - Simple numbered series

4. `lib/pubid_new/nist/identifiers/circular.rb` ✅
   - For: "NBS CIRC 13e2revJune1908"
   - Edition and revision notations

5. `lib/pubid_new/nist/identifiers/circular_supplement.rb` ✅
   - For: "NBS CIRC supJun1925-Jun1927"
   - Date range supplements

6. `lib/pubid_new/nist/identifiers/crpl_report.rb` ✅
   - For: "NBS CRPL 1-2_3-1"
   - Range notation with underscores

### Implementation Steps

**Step 1: Update Parser for NBS Patterns (Est. 3-4 hours)**
```
# Add NBS-specific rules
rule(:cs_emergency_edition) do
  str("e") >> digits.as(:emergency_edition)
end

rule(:circ_revision) do
  str("rev") >> month_name.as(:rev_month) >> year.as(:rev_year)
end

rule(:crpl_range) do
  # Handle underscore ranges: 1-2_3-1
  digits >> dash >> digits >> str("_") >> digits >> dash >> digits
end
```

**Step 2: Update Builder Routing (Est. 2-3 hours)**  
```
def build(data)
  case data[:series]
  when "CSM"
    Identifiers::CommercialStandardsMonthly.new(...)
  when "CS"
    if data[:emergency_edition]
      Identifiers::CommercialStandardEmergency.new(...)
    end
  when "CIRC"
    if data[:supplement]
      Identifiers::CircularSupplement.new(...)
    else
      Identifiers::Circular.new(...)
    end
  when "CRPL"
    Identifiers::CrplReport.new(...)
  end
end
```

**Step 3: Testing (Est. 4-5 hours)**
- Test each NBS series individually
- Verify allrecords fixture improves
- Fix edge cases

**Total NIST: 9-12 hours (1-2 days)**

## Estimated Total Remaining

- IEEE: 2-3 days
- NIST: 1-2 days
- **Total: 3-5 days to 100% on all fixtures**

## Implementation Priority

**Priority 1: NIST (Easier)**
- Classes created
- Parser mostly supports patterns
- Main work: Builder routing + testing

**Priority 2: IEEE (Complex)**
- Parser changes riskier
- More architectural changes needed
- Currently broken, needs recovery

## Success Criteria

**IEEE 100%:**
- All 8,817 identifiers parse
- Proper identifier class for each pattern
- No regressions on existing coverage

**NIST 100%:**
- All 19,488 identifiers parse
- All NBS series handled
- 4 output styles working

---

**Start Here Next Session:**

1. Fix IEEE to working state
2. Wire NIST NBS classes to builder
3. Test and iterate systematically
