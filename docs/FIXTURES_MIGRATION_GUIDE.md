# Fixtures Migration Guide

## Overview

This guide documents the migration from the old `pass/fail/` structure to the new `identifiers/{full,pass,fail}` architecture implemented in Sessions 103-104.

## New Architecture

### Directory Structure

```
spec/fixtures/{flavor}/
├── identifiers/
│   ├── full/{identifier-class}.txt    # SOURCE OF TRUTH (never deleted)
│   ├── pass/{identifier-class}.txt    # Generated: successful identifiers
│   └── fail/{identifier-class}.txt    # Generated: failed identifiers
└── SUMMARY.txt                         # Classification statistics
```

### Key Principles

1. **Non-destructive**: `full/` directory is **never deleted** by classification scripts
2. **Reproducible**: Same `full/` → same `pass/fail/` every time
3. **Source of truth**: All fixture data lives in `full/`, `pass/fail/` are generated artifacts
4. **Three syntax formats**: Plain, normalized, and errored identifiers

## Three Syntax Formats

### 1. Plain Format (Round-Trip Perfect)

**Format:** Plain identifier string
**Meaning:** Parses and renders identically
**Location:** `pass/{class}.txt`

**Examples:**
```
ISO 8601:2019
IEC 60050:2013
IEEE Std 802.11-2020
NIST SP 800-53r5
```

### 2. Normalized Format (Successful Normalization)

**Format:** `!original!normalized`
**Meaning:** Parses different input, renders to normalized form
**Location:** `pass/{class}.txt`

**Examples:**
```
!ISO  8601: 2019!ISO 8601:2019
!IEC 60050-351:2013/Amd 1!IEC 60050-351:2013/AMD1
!IEEE Std  802.11-2020!IEEE Std 802.11-2020
```

**Use cases:**
- Extra whitespace normalization
- Case normalization (AMD vs Amd)
- Abbreviation expansion/contraction
- Format standardization

### 3. Errored Format (Parse Failure)

**Format:** `#original# error_type: "message"`
**Meaning:** Failed to parse, with error details
**Location:** `fail/{class}.txt`

**Examples:**
```
#ISO AAABBB:2009:1234# Parslet::ParseFailed: "unexpected token at position 5"
#IEC INVALID# Parslet::ParseFailed: "Don't know what to do with INVALID"
#IEEE XYZ# ArgumentError: "Unknown pattern"
```

## Migration Process

### Step 1: Migrate Existing Fixtures

Use the migration script to convert from old structure:

```bash
cd spec/fixtures
ruby migrate_to_new_structure.rb <flavor>
```

**What it does:**
1. Creates `identifiers/full/` directory
2. Collects all identifiers from old `pass/*.txt` (preserves format)
3. Collects all identifiers from old `fail/*.txt` (converts to errored format)
4. Groups by class and writes to `full/{class}.txt`
5. Backs up old structure to `pass_backup_*/` and `fail_backup_*/`
6. Removes old `pass/` and `fail/` directories

### Step 2: Classify Fixtures

Run classification to generate new `pass/fail/` from `full/`:

```bash
cd spec/fixtures
ruby run_classify.rb <flavor>
```

**What it does:**
1. Reads ALL identifiers from `identifiers/full/`
2. Clears `identifiers/pass/` and `identifiers/fail/` (never touches `full/`)
3. Parses each identifier
4. Writes to `pass/` if successful (plain or normalized format)
5. Writes to `fail/` if parse error (errored format)
6. Generates SUMMARY.txt with statistics

## Classification Logic

### Plain Identifier

```ruby
ISO 8601:2019  # Input from full/

# Parse and test
parsed = PubidNew::Iso.parse("ISO 8601:2019")
rendered = parsed.to_s  # => "ISO 8601:2019"

# Perfect match → write as plain to pass/
if rendered == "ISO 8601:2019"
  write_to("pass/international_standard.txt", "ISO 8601:2019")
end
```

### Normalized Identifier

```ruby
!ISO  8601: 2019!ISO 8601:2019  # Input from full/ (from old pass/)

# Parse original
parsed = PubidNew::Iso.parse("ISO  8601: 2019")
rendered = parsed.to_s  # => "ISO 8601:2019"

# Check if matches expected normalization
if rendered == "ISO 8601:2019"
  write_to("pass/international_standard.txt", "!ISO  8601: 2019!ISO 8601:2019")
end
```

### Errored Identifier

```ruby
#ISO INVALID# ParseError: "migrated from fail"  # Input from full/

# Try to parse (re-validate)
begin
  parsed = PubidNew::Iso.parse("ISO INVALID")
  # If successful, move to pass with normalization!
  write_to("pass/...", "!ISO INVALID!#{parsed.to_s}")
rescue StandardError => e
  # Still fails, update error message
  write_to("fail/international_standard.txt", "#ISO INVALID# #{e.class}: #{e.message.inspect}")
end
```

## Migrated Flavors

### Successfully Migrated (4 flavors)

| Flavor | Total IDs | Pass Rate | Status |
|--------|-----------|-----------|--------|
| ISO    | 7,515     | 99.97%    | ✅ Excellent |
| IEC    | 12,276    | 100%      | ✅ Perfect |
| IEEE   | 4,543     | 100%      | ✅ Perfect |
| NIST   | 19,432    | 100%      | ✅ Perfect |

### Not Migrated (9 flavors)

These flavors don't have the old `pass/fail/` structure:
- IDF, CEN, BSI, JIS, ETSI, CCSDS, ITU, PLATEAU, ANSI

They use direct fixture files and don't need migration.

## Workflow Examples

### Adding New Test Identifiers

```bash
# 1. Add to appropriate full/ file
echo "ISO 9001:2024" >> spec/fixtures/iso/identifiers/full/international_standard.txt

# 2. Re-classify
cd spec/fixtures && ruby run_classify.rb iso

# 3. Check results
cat spec/fixtures/iso/SUMMARY.txt
```

### Debugging Parse Failures

```bash
# 1. Check fail/ directory
ls spec/fixtures/iso/identifiers/fail/

# 2. Read error details
cat spec/fixtures/iso/identifiers/fail/international_standard.txt

# 3. Fix parser

# 4. Re-classify to see if fixed
cd spec/fixtures && ruby run_classify.rb iso

# 5. If fixed, identifier moves from fail/ to pass/ automatically!
```

### Validating Round-Trip

```bash
# Check for normalized identifiers (not perfect round-trip)
grep '^!' spec/fixtures/iso/identifiers/pass/*.txt

# These identifiers parse correctly but render differently
# This is usually GOOD (normalization working)
```

## Benefits

1. **Non-destructive**: Can re-run classification without losing data
2. **Reproducible**: Same input → same output
3. **Debuggable**: Error messages preserved and tracked
4. **Extensible**: Easy to add new syntaxes or validation rules
5. **Testable**: Can diff `pass/fail/` changes between parser improvements
6. **Clear separation**: Source data (`full/`) vs. generated artifacts (`pass/fail/`)
7. **Git-friendly**: Only `full/` needs to be tracked

## File Headers

All generated files include headers:

### full/ Files (Created by Migration)
```
# ISO International Standard - Full
# Source of truth for all international standard identifiers
# Auto-generated during migration

<identifiers...>
```

### pass/fail Files (Created by Classification)
```
# ISO International Standard - Pass
# Auto-generated by classify_fixtures.rb

<identifiers...>
```

## Statistics

### Total Identifiers Migrated

- **Total identifiers**: 43,766
- **Unique identifiers**: 43,766
- **Perfect implementations**: 3/4 (IEC, IEEE, NIST at 100%)
- **Near-perfect**: 1/4 (ISO at 99.97%)

### Migration Time

- **Session 103**: 120 minutes (migration + classify scripts)
- **Session 104**: 90 minutes (migrate 4 flavors)
- **Total**: 210 minutes

## Maintenance

### Regular Classification

Run classification periodically to check for improvements:

```bash
# Classify all migrated flavors
for flavor in iso iec ieee nist; do
  ruby spec/fixtures/run_classify.rb $flavor
done
```

### After Parser Changes

After improving parsers, re-classify to see results:

```bash
cd spec/fixtures && ruby run_classify.rb iso

# Check if failures decreased
diff -u spec/fixtures/iso/SUMMARY.txt.old spec/fixtures/iso/SUMMARY.txt
```

### Backup Strategy

- `full/` directory should be Git-tracked (source of truth)
- `pass/fail/` directories can be gitignored (generated artifacts)
- Old `pass_backup_*/` and `fail_backup_*/` can be deleted after verification

## Troubleshooting

### Migration Script Fails

```bash
# Check flavor name
ruby spec/fixtures/migrate_to_new_structure.rb

# Run with valid flavor
ruby spec/fixtures/migrate_to_new_structure.rb iso
```

### Classification Gives Wrong Results

1. Check `full/` file content
2. Verify syntax format is correct
3. Test parser manually
4. Check error messages in `fail/` files

### Lost Data After Migration

Old directories are backed up:
```bash
# Restore from backup if needed
ls spec/fixtures/iso/*_backup_*/

# Copy back if necessary
cp -r spec/fixtures/iso/pass_backup_*/ spec/fixtures/iso/pass
```

## Future Enhancements

Possible future improvements:

1. **Validation modes**: Strict vs. lenient parsing
2. **Performance tracking**: Time each identifier parse
3. **Coverage reports**: Which patterns are tested
4. **Auto-fixes**: Suggest fixes for common patterns
5. **Diff reports**: Show what changed between classifications

---

**Created:** 2025-12-10
**Sessions:** 103-104
**Status:** Production-ready