# Session 102+ Fixtures Classification Redesign Plan

**Created:** 2025-12-10
**Status:** Design complete, ready for implementation
**Timeline:** COMPRESSED - Complete within 3 sessions (103-105)

---

## Executive Summary

Complete redesign of the fixtures classification system with:
1. **New directory structure**: `identifiers/{full,pass,fail}` instead of `{pass,fail}`
2. **Three syntax formats**: plain, normalized (`!original!rendered`), errored (`#original# error`)
3. **Non-destructive workflow**: Read from `full/`, write to `pass/fail/`
4. **All 13 flavors**: ISO, IEC, IEEE, NIST, IDF, CEN, BSI, JIS, ETSI, CCSDS, ITU, PLATEAU, ANSI

---

## Problem Statement

### Current Architecture Issues
```
spec/fixtures/{flavor}/
├── pass/{identifier-class}.txt
└── fail/{identifier-class}.txt
```

**Problems:**
1. **Destructive**: Classify script deletes and recreates files
2. **No source of truth**: Pass/fail are both inputs and outputs
3. **Limited formats**: Only handles plain and `!original!expected`
4. **No error details**: Parse failures just dropped
5. **Hard to debug**: Lost information on each run

---

## New Architecture Design

### Directory Structure
```
spec/fixtures/{flavor}/
├── identifiers/
│   ├── full/{identifier-class}.txt    # SOURCE OF TRUTH (never deleted)
│   ├── pass/{identifier-class}.txt    # Generated: successful identifiers
│   └── fail/{identifier-class}.txt    # Generated: failed identifiers
└── SUMMARY.txt                         # Classification statistics
```

### Three Syntax Formats

#### 1. Round-Trip (Perfect Match)
**Format:** Plain identifier string  
**Meaning:** Parses and renders identically  
**Example:**
```
ISO 8601:2019
IEC 60050:2013
IEEE Std 802.11-2020
```
**Output location:** `pass/{class}.txt`

#### 2. Normalized (Successful Normalization)
**Format:** `!original!normalized`  
**Meaning:** Parses different input, renders to normalized form  
**Example:**
```
!ISO  8601: 2019!ISO 8601:2019
!IEC 60050-351:2013/Amd 1!IEC 60050-351:2013/AMD1
!IEEE Std  802.11-2020!IEEE Std 802.11-2020
```
**Output location:** `pass/{class}.txt`

#### 3. Errored (Parse Failure)
**Format:** `#original# error_type: "message"`  
**Meaning:** Failed to parse, with error details  
**Example:**
```
#ISO AAABBB:2009:1234# ParseError: "unexpected token at position 5"
#IEC INVALID# Parslet::ParseFailed: "Don't know what to do with INVALID"
#IEEE XYZ# ArgumentError: "Unknown pattern"
```
**Output location:** `fail/{class}.txt`

---

## Classification Workflow

### Step 1: Read Source Data
```ruby
# Read ALL identifiers from full/ directory
def collect_source_identifiers(flavor)
  identifiers = []
  
  Dir.glob("spec/fixtures/#{flavor}/identifiers/full/*.txt").each do |file|
    File.readlines(file).each do |line|
      line = line.strip
      next if line.empty? || line.start_with?("#")
      identifiers << line
    end
  end
  
  identifiers.uniq
end
```

### Step 2: Clear Output Directories
```ruby
# Clear pass/ and fail/ (but NEVER full/)
def prepare_output_directories(flavor)
  pass_dir = "spec/fixtures/#{flavor}/identifiers/pass"
  fail_dir = "spec/fixtures/#{flavor}/identifiers/fail"
  
  FileUtils.rm_rf(pass_dir)
  FileUtils.rm_rf(fail_dir)
  FileUtils.mkdir_p(pass_dir)
  FileUtils.mkdir_p(fail_dir)
end
```

### Step 3: Classify Each Identifier
```ruby
def classify_identifier(entry)
  case entry
  when /^!(.+)!(.+)$/  # Normalized format
    classify_normalized($1, $2)
  when /^#(.+)# (.+)$/  # Already errored (re-validate)
    classify_errored($1, $2)
  else  # Plain identifier
    classify_plain(entry)
  end
end
```

### Step 4: Output Results

**For successful identifiers** (`pass/`):
```ruby
def write_success(class_name, identifier, normalized: false)
  if normalized
    # Write !original!rendered format
    append_to_file("pass", class_name, identifier)
  else
    # Write plain format
    append_to_file("pass", class_name, identifier)
  end
end
```

**For failed identifiers** (`fail/`):
```ruby
def write_failure(class_name, identifier, error)
  # Always write #original# error format
  formatted = "##{identifier}# #{error.class}: #{error.message.inspect}"
  append_to_file("fail", class_name, formatted)
end
```

---

## Implementation Plan

### Task 1: Create Migration Script (60 min)

**File:** `spec/fixtures/migrate_to_new_structure.rb`

**Purpose:** Migrate existing `pass/fail/` to new `identifiers/full/` structure

**Algorithm:**
1. For each flavor:
   - Create `identifiers/full/` directory
   - Collect all identifiers from `pass/*.txt` (keep format)
   - Collect all identifiers from `fail/*.txt` (mark as errored)
   - Group by class
   - Write to `identifiers/full/{class}.txt`
   - Backup old `pass/` and `fail/`
   - Remove old directories

**Code skeleton:**
```ruby
class FixturesMigrator
  FLAVORS = %w[iso iec ieee nist idf cen bsi jis etsi ccsds itu plateau ansi]
  
  def migrate_flavor(flavor)
    puts "Migrating #{flavor.upcase}..."
    
    # 1. Create new structure
    full_dir = "spec/fixtures/#{flavor}/identifiers/full"
    FileUtils.mkdir_p(full_dir)
    
    # 2. Gather all identifiers
    all_identifiers = collect_from_pass_and_fail(flavor)
    
    # 3. Group by class and write
    all_identifiers.group_by { |id| detect_class(id) }.each do |klass, ids|
      write_full_file(flavor, klass, ids.uniq.sort)
    end
    
    # 4. Backup old structure
    backup_old_structure(flavor)
    
    puts "✅ Migrated #{flavor.upcase}"
  end
end
```

### Task 2: Rewrite Classify Script (90 min)

**File:** `spec/fixtures/classify_fixtures.rb`

**Key changes:**
1. Read from `identifiers/full/` ONLY
2. Never delete `full/`
3. Clear and regenerate `pass/` and `fail/`
4. Handle three input syntaxes
5. Output correct format to pass/fail

**Three handlers:**
```ruby
def classify_plain(id_str)
  begin
    parsed = parse_identifier(id_str)
    rendered = parsed.to_s
    
    if rendered == id_str
      # Perfect round-trip
      write_success(detect_class(parsed), id_str, normalized: false)
    else
      # Needs normalization
      write_success(detect_class(parsed), "!#{id_str}!#{rendered}", normalized: true)
    end
  rescue StandardError => e
    write_failure(detect_class_from_string(id_str), id_str, e)
  end
end

def classify_normalized(original, expected)
  begin
    parsed = parse_identifier(original)
    actual_rendered = parsed.to_s
    
    if actual_rendered == expected
      # Success! Normalization works
      write_success(detect_class(parsed), "!#{original}!#{expected}", normalized: true)
    else
      # Mismatch - expected different result
      error_msg = "Expected: #{expected}, Got: #{actual_rendered}"
      write_failure(detect_class(parsed), original, StandardError.new(error_msg))
    end
  rescue StandardError => e
    write_failure(detect_class_from_string(original), original, e)
  end
end

def classify_errored(original, error_msg)
  # Re-validate: maybe it parses now?
  begin
    parsed = parse_identifier(original)
    rendered = parsed.to_s
    # It parses now! Move to pass
    write_success(detect_class(parsed), "!#{original}!#{rendered}", normalized: true)
  rescue StandardError => e
    # Still fails, keep in fail
    write_failure(detect_class_from_string(original), original, e)
  end
end
```

### Task 3: Run Classification (30 min)

```bash
# Test on IDF first (smallest)
ruby spec/fixtures/migrate_to_new_structure.rb idf
ruby spec/fixtures/run_classify.rb idf

# Then run on all
ruby spec/fixtures/run_classify.rb all
```

**Expected output:**
```
Classifying fixtures for ISO...
Found 7688 total identifier entries
Classification complete
Total: 7688
Pass:  7554 (98.26%)
Fail:  134 (1.74%)
```

### Task 4: Validation (30 min)

For each flavor:
1. Verify `pass/` + `fail/` = `full/`
2. Check statistics match Session 102 baseline
3. Spot-check sample identifiers in each format
4. Ensure error messages are preserved

### Task 5: Documentation (30 min)

Update:
- [ `FIXTURES_VALIDATION_STATUS.md`](../../docs/FIXTURES_VALIDATION_STATUS.md)
- Memory bank context.md
- Create MIGRATION_GUIDE.md

---

## File Structure Examples

### ISO Example (After Migration)
```
spec/fixtures/iso/
├── identifiers/
│   ├── full/
│   │   ├── international_standard.txt      # 5,234 identifiers (source)
│   │   ├── amendment.txt                   # 892 identifiers (source)
│   │   ├── corrigendum.txt                 # 456 identifiers (source)
│   │   ├── guide.txt                       # 234 identifiers (source)
│   │   └── ... (12 more classes)
│   ├── pass/
│   │   ├── international_standard.txt      # Generated: round-trip + normalized
│   │   ├── amendment.txt                   # Generated
│   │   └── ...
│   └── fail/
│       ├── international_standard.txt      # Generated: parse errors
│       ├── cyrillic.txt                    # Generated: intentionally unsupported
│       └── ...
└── SUMMARY.txt                              # Classification statistics
```

### Example full/ File Content
```
# ISO International Standard - Full
# Source of truth for all international standard identifiers
# Auto-generated during migration

ISO 8601:2019
!ISO  8601: 2019!ISO 8601:2019
ISO 9001:2015
!ISO/IEC 27001:2013!ISO/IEC 27001:2013
#ISO INVALID123# ParseError: "unknown pattern"
```

### Example pass/ File Content (After Classification)
```
# ISO International Standard - Pass
# Auto-generated by classify_fixtures.rb

ISO 8601:2019
!ISO  8601: 2019!ISO 8601:2019
ISO 9001:2015
!ISO/IEC 27001:2013!ISO/IEC 27001:2013
```

### Example fail/ File Content (After Classification)
```
# ISO International Standard - Fail
# Auto-generated by classify_fixtures.rb

#ISO INVALID123# Parslet::ParseFailed: "Failed to match sequence"
```

---

## Benefits of New Architecture

1. **Non-destructive**: `full/` never deleted, safe to re-run
2. **Reproducible**: Same `full/` → same `pass/fail/` every time
3. **Debuggable**: Error messages preserved, can track over time
4. **Extensible**: Easy to add new syntaxes or validation rules
5. **Testable**: Can diff `pass/fail/` changes between runs
6. **Clear separation**: Source data vs. generated artifacts
7. **Git-friendly**: `full/` tracked, `pass/fail/` can be gitignored if desired

---

## Timeline

| Session | Task | Duration | Deliverable |
|---------|------|----------|-------------|
| 103 | Migration script + new classify | 120 min | IDF tested |
| 104 | Migrate all 13 flavors | 90 min | All migrated |
| 105 | Validation + documentation | 60 min | Complete |
| **Total** | **Complete redesign** | **270 min** | **Production** |

---

## Success Criteria

- ✅ All 13 flavors migrated to new structure
- ✅ `full/` contains all unique identifiers
- ✅ `pass/` + `fail/` = `full/` for each flavor (accounting for uniques)
- ✅ Three syntaxes working correctly
- ✅ Statistics match Session 102 baseline:
  - ISO: 98.26% (7,554/7,688)
  - IEC: 99.93% (13,814/13,824)
  - Others maintained
- ✅ Non-destructive workflow verified
- ✅ Documentation complete

---

## Rollback Plan

If issues arise:
1. Old `pass/fail/` backed up before migration
2. Can restore from backup
3. Git commit after each major step
4. Each flavor migrated independently

---

## Next Steps

1. Create migration script
2. Test on IDF (smallest flavor, 26 identifiers)
3. Verify structure and classify
4. Migrate remaining 12 flavors
5. Run comprehensive validation
6. Update documentation
