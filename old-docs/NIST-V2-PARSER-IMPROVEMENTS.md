# NIST V2 Parser Improvements

## Status: ✅ 98.47% (EXCEEDS 95% TARGET)

**Implementation:** [`lib/pubid_new/nist/`](../lib/pubid_new/nist/)

## Overview

The NIST V2 parser has been significantly improved to handle historical NBS (National Bureau of Standards) publication patterns, achieving 98.47% parse success rate on 19,488 test identifiers.

## Metrics

| Metric | Value |
|--------|-------|
| **Target** | 95%+ |
| **Current** | 98.47% |
| **Baseline** | 92.78% |
| **Total Identifiers** | 19,488 |
| **Successfully Parsed** | 19,190 |
| **Failures** | 298 |
| **Improvement** | +1,110 identifiers (+5.69pp) |

## Features Implemented

### 1. LCIRC Series Support (~900 identifiers)

The NBS Letter Circular (LCIRC) series is now fully supported, including revision notation.

**Examples:**
```
NBS LCIRC 1000       # Letter Circular 1000
NBS LCIRC 1019r1963  # Letter Circular 1019, revised 1963
NBS LCIRC 1035r1985  # Letter Circular 1035, revised 1985
```

**Implementation:**
- [`lib/pubid_new/nist/parser.rb:24`](../lib/pubid_new/nist/parser.rb#L24) - Added "NBS LCIRC" to compound_series

### 2. CSM Volume-Number Format (~36 identifiers)

The Commercial Standards Monthly (CSM) series uses a special volume-number format v#n#.

**Examples:**
```
NBS CSM v6n1   # Volume 6, Number 1
NBS CSM v7n12  # Volume 7, Number 12
NBS CSM v9n9   # Volume 9, Number 9
```

**Implementation:**
- [`lib/pubid_new/nist/parser.rb:67`](../lib/pubid_new/nist/parser.rb#L67) - Added v#n# pattern to first_number

### 3. Supplement with Revision (~100 identifiers)

Circular supplements can be combined with revisions in a compact "supprev" notation.

**Examples:**
```
NBS CIRC 154supprev      # Circular 154, supplement with revision
NBS CIRC 25suppJan1924   # Circular 25, supplement January 1924
```

**Implementation:**
- [`lib/pubid_new/nist/parser.rb:70`](../lib/pubid_new/nist/parser.rb#L70) - Added "supprev" pattern
- [`lib/pubid_new/nist/builder.rb:145`](../lib/pubid_new/nist/builder.rb#L145) - Special handling in handle_special_first_number
- [`lib/pubid_new/nist/identifiers/base.rb:280`](../lib/pubid_new/nist/identifiers/base.rb#L280) - Rendering logic

### 4. Edition with Revision and Date (~50 identifiers)

Edition numbers can combine with revision indicators and dates in a single identifier.

**Examples:**
```
NBS CIRC 13e2revJune1908  # Circular 13, edition 2, revision June 1908
NBS CIRC 24e4supp         # Circular 24, edition 4, supplement
```

**Implementation:**
- [`lib/pubid_new/nist/parser.rb`](../lib/pubid_new/nist/parser.rb) - Pattern for number+edition+revision+date
- [`lib/pubid_new/nist/builder.rb`](../lib/pubid_new/nist/builder.rb) - Extraction logic
- [`lib/pubid_new/nist/identifiers/base.rb`](../lib/pubid_new/nist/identifiers/base.rb) - Rendering with "rev" not "-"

### 5. Year Expansion in Editions (~20 identifiers)

2-digit years in edition notation are automatically expanded to 4-digit years.

**Examples:**
```
e104-43 → e104-1943  # 4-digit year expansion
```

**Implementation:**
- [`lib/pubid_new/nist/identifiers/base.rb:266`](../lib/pubid_new/nist/identifiers/base.rb#L266) - Year expansion logic

## Remaining Issues (298 failures, 1.53%)

### 1. CRPL Range Patterns (~12 identifiers)
- **Pattern:** `NBS CRPL 1-2_3-1A`
- **Issue:** Underscore+dash range notation not yet supported

### 2. FIPS Supplement Patterns (~10 identifiers)
- **Pattern:** `NBS FIPS 63-1supp`
- **Issue:** FIPS-specific supplement notation

### 3. Edge Cases (~276 identifiers)
- Various historical notations and data quality issues

## Architecture

The NIST V2 parser follows a clean 3-layer architecture:

1. **Parser** ([`lib/pubid_new/nist/parser.rb`](../lib/pubid_new/nist/parser.rb))
   - Parslet-based grammar
   - Declarative pattern matching
   - ~300 lines

2. **Builder** ([`lib/pubid_new/nist/builder.rb`](../lib/pubid_new/nist/builder.rb))
   - Transform pattern
   - Parse tree → Object conversion
   - Handles special cases
   - ~200 lines

3. **Identifiers** ([`lib/pubid_new/nist/identifiers/`](../lib/pubid_new/nist/identifiers/))
   - Lutaml::Model-based
   - Rendering logic
   - Serialization support

## Testing

**Test Coverage:** 19,488 real-world identifiers from NIST database

**Test Command:**
```bash
cd gems/pubid-nist
ruby -e "
require_relative '../../lib/pubid_new/nist'
total = passes = 0
File.readlines('spec/fixtures/allrecords.txt').each do |line|
  id = line.strip
  next if id.empty?
  total += 1
  passes += 1 if PubidNew::Nist.parse(id).to_s == id rescue nil
end
puts \"NIST: #{passes}/#{total} (#{(passes.to_f/total*100).round(2)}%)\"
"
```

## Usage Examples

```ruby
require 'pubid_new/nist'

# Parse LCIRC series
id = PubidNew::Nist.parse("NBS LCIRC 1019r1963")
id.to_s  # => "NBS LCIRC 1019r1963"

# Parse CSM volume-number
id = PubidNew::Nist.parse("NBS CSM v6n1")
id.to_s  # => "NBS CSM v6n1"

# Parse supplement with revision
id = PubidNew::Nist.parse("NBS CIRC 154supprev")
id.to_s  # => "NBS CIRC 154supprev"

# Parse edition with revision and date
id = PubidNew::Nist.parse("NBS CIRC 13e2revJune1908")
id.to_s  # => "NBS CIRC 13e2revJune1908"
```

## Next Steps

1. ✅ Reach 95%+ target (ACHIEVED: 98.47%)
2. Polish to 99%+ by addressing remaining edge cases (optional)
3. Add comprehensive test suite
4. Performance optimization

---

Last Updated: 2025-11-21
