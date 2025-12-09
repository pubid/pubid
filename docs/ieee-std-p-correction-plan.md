# IEEE "Std P" Pattern Correction Plan

**Created:** 2025-12-04  
**Issue:** "IEEE Std P..." pattern is incorrect - "P" means "project" (draft), not published standard  
**Fix:** Change to "IEEE Draft Std P..." using `!old-id!corrected-id` syntax

---

## Problem Statement

The fixtures contain identifiers like "IEEE Std P1234/D5" which is semantically WRONG:

- **"P" prefix** = Project (draft/unapproved standard)
- **"Std"** = Standard (published, approved)
- **Contradiction**: Can't be both "Standard" and "Project" simultaneously

**Correct form**: "IEEE Draft Std P1234/D5"

---

## Scope of Impact

### Files Affected
1. `archived-gems/pubid-ieee/spec/fixtures/pubid-parsed.txt` (8,817 lines)
2. `archived-gems/pubid-ieee/spec/fixtures/pubid-to-parse.txt` (640 lines)

### Pattern Categories to Fix

Based on search results, the patterns include:

#### Category 1: Simple Draft Standards
```
IEEE Std P1010/D10
IEEE Std P1609.1/D12
IEEE Std P802.11v/D10.0
```
**Fix to:**
```
IEEE Draft Std P1010/D10
IEEE Draft Std P1609.1/D12
IEEE Draft Std P802.11v/D10.0
```

#### Category 2: With Dates
```
IEEE Std P1015/D5, Feb 2006
IEEE Std P1547.1/D7.0, Apr 2005
```
**Fix to:**
```
IEEE Draft Std P1015/D5, Feb 2006
IEEE Draft Std P1547.1/D7.0, Apr 2005
```

#### Category 3: Committee Drafts (PC prefix)
```
IEEE Std PC37.011/D13
IEEE Std PC57.106/D5 Dec
```
**Fix to:**
```
IEEE Draft Std PC37.011/D13
IEEE Draft Std PC57.106/D5 Dec
```

#### Category 4: Unapproved Drafts (already marked as draft in prefix)
```
IEEE Unapproved Draft Std P11073-10471/D02, Feb 2008
IEEE Unapproved Draft Std P1003.1/D3, Jun 07
```
**Keep as is** - Already has "Draft" designation

#### Category 5: Already Corrected (with ! markers)
```
!IEEE Std P802.11z_D8.0_Apr2010!IEEE Std P802.11z/D8.0_Apr2010
!IEEE Std P269a_D5!IEEE Std P269a/D5
```
**These need NEW corrections:**
```
!IEEE Std P802.11z_D8.0_Apr2010!IEEE Draft Std P802.11z/D8.0_Apr2010
!IEEE Std P269a_D5!IEEE Draft Std P269a/D5
```

#### Category 6: Approved Drafts (keep approval marker)
```
IEEE Approved Draft Std PC37.101-2006/Cor 1/D2, 07
IEEE Approved Draft Std P1234/D12, Feb 2007
```
**Fix to:**
```
IEEE Approved Draft Std PC37.101-2006/Cor 1/D2, 07
IEEE Approved Draft Std P1234/D12, Feb 2007
```
**Keep as is** - "Approved Draft Std" is correct (approved to advance, still draft)

#### Category 7: Without Draft Designation
```
IEEE Std P14764, Nov 2004
IEEE Std P16085-2006
```
**Fix to:**
```
IEEE Draft Std P14764, Nov 2004
IEEE Draft Std P16085-2006
```

---

## Search Pattern Analysis

### Patterns to Search For

1. **Base pattern (not already corrected):**
   - `^IEEE Std P[0-9]` - Simple case
   - `^IEEE Std PC[0-9]` - Committee draft case
   
2. **Already corrected but needs update:**
   - `!IEEE Std P[0-9].*!IEEE Std P[0-9]` - Corrections that still say "Std P"
   - `!IEEE Std PC[0-9].*!IEEE Std PC[0-9]` - Committee corrections

3. **Exclude (don't touch):**
   - Lines starting with `IEEE Unapproved Draft Std P` - Already correct
   - Lines starting with `IEEE Approved Draft Std P` - Approved drafts are OK
   - Lines starting with `IEEE Active Unapproved Draft Std P` - Already correct
   - Lines NOT containing "P" in the number (e.g., "IEEE Std 1234-2020" - published standard)

---

## Estimation

### Total Occurrences (Rough Count)

From search results, approximately:
- **pubid-parsed.txt**: ~155 occurrences
- **pubid-to-parse.txt**: ~35 occurrences
- **Total**: ~190 lines need correction

### Breakdown by File Section

**pubid-parsed.txt:**
- Lines 1023, 1946-1947: 3 occurrences
- Lines 4656-4870: ~80 occurrences
- Lines 5070-5078: ~8 occurrences
- Lines 5535-5541: ~7 occurrences (already marked, need update)
- Lines 5636-5646: ~10 occurrences
- Lines 6057-6125: ~68 occurrences
- Lines 8102-8107: ~6 occurrences
- Lines 8637-8638: ~2 occurrences
- Lines 8707-8711: ~5 occurrences
- Lines 8752-8764: ~13 occurrences

**pubid-to-parse.txt:**
- Lines 475-505: ~31 occurrences
- Lines 484-485: ~2 with corrections needed
- Lines 493-497: ~5 with corrections needed

---

## Implementation Approach

### Option A: Automated Ruby Script (Recommended)

**Advantages:**
- Fast and accurate
- Consistent application
- Reversible (can test on copy first)
- Can handle all patterns systematically

**Implementation:**
```ruby
#!/usr/bin/env ruby
# Script: fix_ieee_std_p_patterns.rb

FILES = [
  'archived-gems/pubid-ieee/spec/fixtures/pubid-parsed.txt',
  'archived-gems/pubid-ieee/spec/fixtures/pubid-to-parse.txt'
]

EXCLUSIONS = [
  /^IEEE (Unapproved|Active Unapproved|Approved) Draft Std P/,
  /^!IEEE (Unapproved|Active Unapproved|Approved) Draft Std P/
]

def should_exclude?(line)
  EXCLUSIONS.any? { |pattern| line.match?(pattern) }
end

def correct_line(line)
  return line if should_exclude?(line)
  
  # Pattern 1: Simple "IEEE Std P..." → "IEEE Draft Std P..."
  if line.match?(/^IEEE Std P[0-9C]/)
    corrected = line.sub(/^IEEE Std P/, 'IEEE Draft Std P')
    return "!#{line}!#{corrected}"
  end
  
  # Pattern 2: Already corrected but wrong - update RHS
  if line.match?(/^!.*!IEEE Std P[0-9C]/)
    line.sub(/(!.*!)IEEE Std P/, '\1IEEE Draft Std P')
  else
    line
  end
end

FILES.each do |filepath|
  puts "Processing #{filepath}..."
  
  lines = File.readlines(filepath)
  changes = 0
  
  corrected_lines = lines.map.with_index do |line, idx|
    original = line.chomp
    corrected = correct_line(original)
    
    if original != corrected
      changes += 1
      puts "  Line #{idx + 1}: Changed"
    end
    
    corrected + "\n"
  end
  
  # Write to new file for review
  output_file = filepath.sub('.txt', '-corrected.txt')
  File.write(output_file, corrected_lines.join)
  
  puts "  Total changes: #{changes}"
  puts "  Output: #{output_file}"
  puts
end

puts "Done! Review *-corrected.txt files before replacing originals."
```

**Execution Plan:**
1. Create script in project root
2. Run script to generate `-corrected.txt` files
3. Review changes (diff old vs new)
4. If correct, replace original files
5. Delete temporary `-corrected.txt` files

**Estimated Time:** 30-45 minutes

---

### Option B: Manual Editing (Not Recommended)

**Disadvantages:**
- Error-prone for ~190 lines
- Tedious and time-consuming
- Risk of missing occurrences
- Harder to verify completeness

**Estimated Time:** 4-6 hours

---

## Detailed Pattern Matching Strategy

### Regex Patterns for Script

```ruby
# Match lines to correct
PATTERNS_TO_FIX = [
  # Simple case: "IEEE Std P{number}"
  /^IEEE Std P[0-9]/,
  
  # Committee draft: "IEEE Std PC{number}"
  /^IEEE Std PC[0-9]/,
  
  # Already corrected but still wrong (RHS has "Std P")
  /^!.*!IEEE Std P[0-9]/
]

# Exclusions (do NOT touch these)
EXCLUSIONS = [
  # Already have "Draft" designation
  /^IEEE (Unapproved|Active Unapproved|Approved) Draft Std P/,
  /^!IEEE (Unapproved|Active Unapproved|Approved) Draft Std P/,
  
  # Published standards (no P prefix in actual number)
  /^IEEE Std [0-9]/,  # "IEEE Std 1234-2020" - OK
  /^IEEE Std C[0-9]/, # "IEEE Std C37.111-2013" - OK
]
```

---

## Validation Strategy

### Pre-Correction Checks
1. Count total lines matching pattern
2. Verify exclusions working correctly
3. Sample 10 random corrections for manual review

### Post-Correction Verification
1. Count corrected lines = expected count
2. Verify no "IEEE Std P" patterns remain (except exclusions)
3. Verify all corrections follow `!old!new` format
4. Run fixture tests to ensure parsing still works

---

## Risk Assessment

### LOW RISK
- Script is simple and testable
- Creates backup files (-corrected.txt)
- Reversible if issues found
- Clear pattern matching rules

### MEDIUM RISK
- May need manual review of edge cases
- Some already-corrected lines need updates

### MITIGATION
- Test on small subset first
- Review all changes before committing
- Keep original files until validated
- Run full test suite after changes

---

## Expected Outcomes

### Files Modified
- `pubid-parsed.txt`: ~155 lines corrected
- `pubid-to-parse.txt`: ~35 lines corrected

### Changes Format
All corrections will use the syntax:
```
!IEEE Std P1234/D5!IEEE Draft Std P1234/D5
```

### Test Impact
**IMPORTANT**: This is a FIXTURE FILE correction, not code changes.
- **Should NOT affect** existing passing tests
- **Will improve** parser accuracy by providing correct input format
- **May reduce** failure count if parser already handles "Draft Std" correctly

---

## Implementation Timeline

### Phase 1: Script Creation (20 min)
- Write Ruby script with pattern matching
- Add validation logic
- Test on small sample

###<br> Phase 2: Execution (10 min)
- Run script on both files
- Generate -corrected.txt files
- Review automated changes

### Phase 3: Validation (15 min)
- Manual spot-check 20-30 corrections
- Verify patterns all match expected format
- Check exclusions worked correctly

### Phase 4: Integration (10 min)
- Replace original files with corrected versions
- Run fixture tests to verify
- Commit changes

**Total Estimated Time:** 55 minutes

---

## Next Steps

1. **Get user approval** on automated script approach
2. Create and test Ruby script
3. Run on fixture files
4. Review output
5. Apply corrections
6. Validate with tests
7. Commit with semantic message

---

## Questions for User

1. **Approve automated approach?** Script will be faster and more accurate than manual
2. **Exclusions correct?** Should keep "Approved Draft Std P" unchanged?
3. **Format preference?** All corrections as `!old!new` or direct replacement?
