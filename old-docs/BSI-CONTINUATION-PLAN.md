# BSI PubID v2 Migration - Continuation Plan

## Current Status: Phase 1 Complete ✓

**Completed:** Basic BSI infrastructure (100% on 12 tests)
**Next:** Phase 2 - Adopted Documents (most complex feature)

---

## Phase 1 Results ✓

### Infrastructure
- Parser: 120 lines (Parslet-based)
- Scheme: 139 lines (transformation)
- Model: 193 lines (Lutaml::Model)
- Builder: 148 lines (construction)
- Entry: 23 lines (parse method)

### Test Pass Rate: 100% (12/12)
```
✓ BS 0
✓ BS 7121-3:2017
✓ PAS 1192-2:2014  
✓ PD 19650-0:2019
✓ DD 240-1:1997
✓ BSI Flex 8670:2021-04
✓ BS 4592-0:2006+A1:2012
✓ PD 5500:2021+A2:2022
✓ PAS 3002:2018+C1:2018
✓ BS 5250:2021 ExComm
✓ PAS 96:2017 - TC
✓ PAS 2035/2030:2019+A1:2022
```

---

## Phase 2: Adopted Documents (CRITICAL)

### What Are Adopted Documents?

BSI adopts standards from other organizations (ISO, IEC, CEN, CISPR). These form "adoption chains" where one standard references another.

### Complexity Levels

#### Level 1: Single Adoption (MEDIUM)
BSI directly adopts another standard:
- `BS EN 15154-5:2019` → BS adopts EN 15154-5:2019
- `BS ISO 13485:2012` → BS adopts ISO 13485:2012
- `PD IEC/TR 80002-3:2014` → PD adopts IEC TR 80002-3:2014
- `DD CEN/TS 1992-4-2:2009` → DD adopts CEN TS 1992-4-2:2009

#### Level 2: Chain Adoption (HIGH)
Multiple adoption levels:
- `BS EN ISO 13485:2016` → BS adopts (EN adopts ISO 13485:2016)
- `BS EN IEC 62368-1:2020` → BS adopts (EN adopts IEC 62368-1:2020)
- `BS EN ISO/IEC 80079-34:2020 ED2` → BS adopts (EN adopts ISO/IEC 80079-34:2020 ED2)
- `PD CISPR TR 16-4-5:2006` → PD adopts CISPR TR 16-4-5:2006

#### Level 3: Chain + Supplements (VERY HIGH)
Adoption chains with amendments:
- `BS EN ISO 13485:2016+A11:2021`
- `BS EN IEC 62368-1:2020+A11:2020`
- `PD CISPR TR 16-4-5:2006+A2:2021`

### Critical Challenge: Year Attribution

The year can belong to:
1. The BSI document: `BS EN ISO 13485:2016` (year = 2016 for adoption)
2. A supplement: `BS EN ISO 13485:2016+A11:2021` (year 2021 for amendment)
3. Both levels in the chain

When rendering, must suppress year from inner adopted documents if outer BSI document has its own year!

---

## Step-by-Step Implementation Plan

### Step 1: Extract Test Cases (15 min)

Read and catalog test cases from:
```ruby
gems/pubid-bsi/spec/pubid_bsi/identifier_spec.rb
# Lines 104-199: adopted documents section
```

Create batches:
- Batch A: 10 simple BS EN cases
- Batch B: 10 simple BS ISO cases  
- Batch C: 10 multi-level BS EN ISO cases
- Batch D: 10 adopted + supplement cases
- Batch E: Special cases (CISPR, stages, etc.)

### Step 2: Test Current Parser (10 min)

Test what works already:
```ruby
test_cases = [
  'BS EN 15154-5:2019',
  'BS ISO 13485:2012',
  'BS EN ISO 13485:2016',
]

test_cases.each do |test|
  begin
    identifier = PubidNew::Bsi.parse(test)
    puts "✓ #{test} => #{identifier.to_s}"
  rescue => e
    puts "✗ #{test} => #{e.message}"
  end
end
```

Expect: Parser already has `adopted_content` rule, but may not fully work.

### Step 3: Fix Parser (30 min)

Current parser has:
```ruby
rule(:adopted_content) do
  (expert_commentary.absent? >> translation.absent? >> pdf.absent? >> 
   tracked_changes.absent? >> match["[^+ ]"].repeat(1)).repeat(1).as(:adopted)
end
```

Needs enhancement to:
1. Properly match adopted document formats
2. Distinguish from regular numbers
3. Handle all adoption patterns

### Step 4: Fix Scheme (20 min)

Current scheme calls:
```ruby
def self.parse_adopted(adopted_str)
  begin
    return { flavor: "iec", identifier: PubidNew::Iec.parse(adopted_str) }
  rescue
    # Try ISO, then CEN
  end
end
```

Needs:
1. Proper error handling
2. Order of attempts (IEC → ISO → CEN)
3. Year extraction and attribution

### Step 5: Fix Model Rendering (20 min)

Current model has:
```ruby
if adopted
  adopted_str = adopted.to_s
  if year && adopted.respond_to?(:year)
    # Remove year from adopted if we have our own
    adopted_str = adopted_str.sub(/:#{adopted.year}/, "")
  end
  result += adopted_str
end
```

Needs:
1. Proper year suppression logic
2. Handle nested adoptions (BS EN ISO)
3. Handle supplements on adopted documents

### Step 6: Test Incrementally (40 min)

Test each batch:
```ruby
# Batch A: Simple BS EN
PubidNew::Bsi.parse('BS EN 15154-5:2019')
# Should render: BS EN 15154-5:2019

# Batch B: Simple BS ISO  
PubidNew::Bsi.parse('BS ISO 13485:2012')
# Should render: BS ISO 13485:2012

# Batch C: Multi-level
PubidNew::Bsi.parse('BS EN ISO 13485:2016')
# Should render: BS EN ISO 13485:2016

# Batch D: With supplements
PubidNew::Bsi.parse('BS EN ISO 13485:2016+A11:2021')
# Should render: BS EN ISO 13485:2016+A11:2021
```

Fix issues as discovered.

### Step 7: National Annexes (30 min)

Test cases:
```
NA to BS EN 1999-1-2:2007
NA+A1:2012 to BS EN 1993-5:2007
NA+A1:15 to BS EN 1993-1-4:2006+A1:2015
```

Parser already has `national_annex` rule. Test and fix rendering.

### Step 8: Translations & PDF (15 min)

Test cases:
```
BS 25999-1:2006 (German)
PAS 99:2006 (Italian)
PD 5500:2018+A3:2020 PDF
```

Parser has rules, just need to test.

### Step 9: Full Test Suite (60 min)

Run against all fixtures:
```bash
# Extract from spec files
grep -E "context|let\(:pubid\)" gems/pubid-bsi/spec/pubid_bsi/identifier_spec.rb

# Count total test cases
wc -l gems/pubid-bsi/spec/pubid_bsi/identifier_spec.rb
```

Target: 95%+ pass rate

---

## Key Technical Details

### Original Parser Approach (for reference)

Line 57-58 of `gems/pubid-bsi/lib/pubid/bsi/parser.rb`:
```ruby
(expert_commentary.absent? >> translation.absent? >> space? >>
  match("[^+ ]").repeat(1)).repeat.as(:adopted)
```

This matches "everything that's not a supplement/commentary/translation" as adopted content.

### Original Transformer Approach

Lines 25-33 of `gems/pubid-bsi/lib/pubid/bsi/transformer.rb`:
```ruby
rule(adopted: subtree(:adopted)) do |context|
  { adopted: Pubid::Iec::Identifier.parse(context[:adopted].to_s) }
rescue Pubid::Core::Errors::ParseError
  begin
  { adopted: Pubid::Iso::Identifier.parse(context[:adopted].to_s) }
  rescue Pubid::Core::Errors::ParseError
    { adopted: Pubid::Cen::Identifier.parse(context[:adopted].to_s) }
  end
end
```

Try IEC first, then ISO, then CEN. This is the fallback chain.

### Year Suppression Logic

Lines 8-14 of `gems/pubid-bsi/lib/pubid/bsi/renderer/base.rb`:
```ruby
unless params[:year].empty?
  params[:adopted].year = nil
  # ignore year for adopted identifier assigned to adopted identifier
  if params[:adopted].respond_to?(:adopted) && params[:adopted].adopted
    params[:adopted].adopted.year = nil
  end
end
```

When BSI document has a year, suppress years from ALL levels of adopted chain!

---

## Expected Challenges

### 1. Parser Ambiguity
How to distinguish:
- `BS 1234:2020` (BSI number)
- `BS EN 1234:2020` (adopted EN)

Solution: Parse type after doc_type more carefully.

### 2. Year Propagation
In `BS EN ISO 13485:2016`:
- Parse as: BS adopts "EN ISO 13485:2016"
- EN ISO 13485:2016 parses as: EN adopts ISO 13485:2016
- When rendering BSI, year 2016 goes to BSI level
- Must suppress from EN and ISO levels

### 3. Supplement Attribution
In `BS EN ISO 13485:2016+A11:2021`:
- Is A11:2021 an amendment to:
  a) The BSI document?
  b) The ISO standard?
  c) The adoption itself?

Answer: It's to the whole chain. Treat as BSI supplement.

---

## Testing Strategy

### Incremental Testing
1. Test simpler cases first (BS EN, BS ISO)
2. Then multi-level (BS EN ISO)
3. Then with supplements
4. Then special cases (national annexes, translations)

### Debug Method
For each failing case:
```ruby
test = "BS EN ISO 13485:2016"

# 1. Parse
parsed = PubidNew::Bsi::Parser.new.parse(test)
puts "Parsed: #{parsed.inspect}"

# 2. Transform
transformed = PubidNew::Bsi::Scheme.transform(parsed)
puts "Transformed: #{transformed.inspect}"

# 3. Build
identifier = PubidNew::Bsi::Builder.new(PubidNew::Bsi::Scheme).build(transformed)
puts "Built: #{identifier.inspect}"

# 4. Render
rendered = identifier.to_s
puts "Rendered: #{rendered}"
puts "Expected: #{test}"
```

---

## Success Criteria

### Phase 2A: Adopted Documents
- [ ] 100% on simple BS EN (10 cases)
- [ ] 100% on simple BS ISO (10 cases)
- [ ] 95%+ on multi-level chains (10 cases)
- [ ] 95%+ on adopted + supplements (10 cases)

### Phase 2B: National Annexes
- [ ] 100% on NA prefix cases (5 cases)
- [ ] Year expansion working (15 → 2015)

### Phase 2C: Complete
- [ ] 95%+ on full spec suite (~100 cases)
- [ ] Document any edge cases that fail

---

## Files to Modify

### High Priority:
1. `lib/pubid_new/bsi/parser.rb` - Enhance adopted_content rule
2. `lib/pubid_new/bsi/scheme.rb` - Fix adopted parsing logic
3. `lib/pubid_new/bsi/model.rb` - Fix year suppression in rendering

### Medium Priority:
4. `lib/pubid_new/bsi/builder.rb` - Ensure proper adopted building

### Test When Ready:
5. Create test script with all fixtures

---

## Continuation Prompt

```
Continue BSI PubID v2 migration (Phase 2: Adopted Documents)

Current Status: Phase 1 Complete ✓
- Core infrastructure created (parser/scheme/model/builder)
- 100% pass rate on 12 basic test cases
- Simple BSI documents working (BS, PAS, PD, DD, Flex)
- Supplements, ExComm, TC, Collections all working

Critical Next Task: Implement adopted document support

BSI adopts standards from ISO, IEC, and CEN, creating adoption chains:
- Single-level: BS EN 15154-5:2019, BS ISO 13485:2012
- Multi-level: BS EN ISO 13485:2016, BS EN IEC 62368-1:2020
- With supplements: BS EN ISO 13485:2016+A11:2021

Challenge: Year attribution across adoption chains

Steps:
1. Read gems/pubid-bsi/spec/pubid_bsi/identifier_spec.rb (lines 104-199)
2. Extract 10 simple adopted cases (BS EN, BS ISO)
3. Test with PubidNew::Bsi.parse()
4. Debug parser/scheme/model as needed
5. Expand to 20, then 50 cases
6. Target: 95%+ on adopted documents

Files to modify:
- lib/pubid_new/bsi/parser.rb (adopted_content rule)
- lib/pubid_new/bsi/scheme.rb (parse_adopted method)
- lib/pubid_new/bsi/model.rb (year suppression logic)

Reference implementations:
- Original: gems/pubid-bsi/lib/pubid/bsi/transformer.rb (lines 25-33)
- CEN adoption: lib/pubid_new/cen/ (similar patterns)

Session doc: docs/SESSION-2025-11-16-BSI-INITIAL-MIGRATION.md
Full plan: docs/BSI-CONTINUATION-PLAN.md

Goal: Enable parsing and rendering of adoption chains like "BS EN ISO 13485:2016+A11:2021"
```

---

END OF CONTINUATION PLAN
