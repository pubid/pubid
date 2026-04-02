# PubID V2 Fixtures Organization

## Purpose

This directory contains systematically organized test fixtures for PubID V2, separated into passing and failing examples by identifier class. This enables:

1. **Targeted testing** - Test specific identifier types in isolation
2. **Progress tracking** - Measure improvement as parser enhancements are made
3. **Quality assurance** - Distinguish working patterns from gaps
4. **Documentation** - Clear examples of supported vs unsupported patterns

## Directory Structure

```
spec/fixtures/
├── README.md                    # This file
├── extract_fixtures.rb          # Extraction script
│
├── iso/
│   ├── pass/                    # Successfully parsing identifiers
│   │   ├── international_standard.txt
│   │   ├── technical_report.txt
│   │   ├── technical_specification.txt
│   │   ├── guide.txt
│   │   ├── amendment.txt
│   │   ├── corrigendum.txt
│   │   ├── directives.txt
│   │   └── ...
│   └── fail/                    # Failing to parse or mismatch
│       ├── international_standard.txt
│       ├── nsb_format.txt       # Special case: NSB identifiers
│       ├── cyrillic.txt         # Special case: Cyrillic characters
│       └── ...
│
├── iec/
│   ├── pass/
│   │   ├── international_standard.txt
│   │   ├── technical_report.txt
│   │   ├── amendment.txt
│   │   └── ...
│   └── fail/
│       └── ...
│
├── ieee/
│   ├── pass/
│   │   ├── standard.txt
│   │   ├── draft.txt
│   │   └── ...
│   └── fail/
│       ├── missing_std_prefix.txt
│       ├── spacing_issues.txt
│       ├── month_format.txt
│       └── ...
│
└── [other flavors]/
```

## File Format

Each `.txt` file contains one identifier per line:

```
# international_standard.txt
ISO 8601:2019
ISO/IEC 27001:2013
ISO 12345-1:2020
ISO/IEC/IEEE 29119-1:2013
```

Comments (lines starting with `#`) are allowed for organization.

## Extraction Methodology

### Source Data

- **V1 fixture files**: `archived-gems/pubid-{flavor}/spec/fixtures/*.txt`
- **Test execution**: Run fixtures_spec.rb and capture results

### Classification Process

1. **Parse each identifier** using `PubidNew::{Flavor}.parse(id_str)`
2. **Determine class** from parsed object or error pattern
3. **Classify as pass or fail**:
   - **Pass**: `parsed.to_s == original_string`
   - **Fail**: Parse error OR format mismatch
4. **Write to appropriate file** in `pass/` or `fail/` directory

### Identifier Class Detection

For each flavor, detect the identifier class:

**ISO Example:**
- `ISO Guide` → guide.txt
- `ISO TR` → technical_report.txt
- `/Amd` → amendment.txt
- `/Cor` → corrigendum.txt
- `FprISO` → nsb_format.txt (fail)
- Cyrillic → cyrillic.txt (fail)

**IEEE Example:**
- `IEEE Std 123` → standard.txt
- `/D` → draft.txt
- No "Std" → missing_std_prefix.txt (fail)

## Usage Patterns

### For Test Development

Create targeted tests for specific identifier types:

```ruby
RSpec.describe PubidNew::Iso::Identifiers::Amendment do
  let(:passing_fixtures) {
    File.readlines("spec/fixtures/iso/pass/amendment.txt")
        .reject { |l| l.strip.empty? || l.start_with?("#") }
  }
  
  it "parses all passing amendment fixtures" do
    passing_fixtures.each do |fixture|
      expect { PubidNew::Iso.parse(fixture) }.not_to raise_error
    end
  end
end
```

### For Enhancement Work

Identify patterns to fix:

```bash
# See what's failing for amendments
cat spec/fixtures/iso/fail/amendment.txt

# After parser fixes, re-extract
ruby spec/fixtures/extract_fixtures.rb iso

# Check improvements
git diff spec/fixtures/iso/
```

### For Documentation

Generate statistics:

```bash
# Count passing vs failing by type
wc -l spec/fixtures/iso/pass/*.txt
wc -l spec/fixtures/iso/fail/*.txt
```

## Maintenance

### When to Re-extract

- After implementing parser enhancements
- After updating V1 fixture files
- Before creating fix roadmaps
- As part of CI/CD validation

### How to Re-extract

```bash
# Extract for specific flavor
ruby spec/fixtures/extract_fixtures.rb iso

# Extract for all flavors
ruby spec/fixtures/extract_fixtures.rb all

# With detailed output
ruby spec/fixtures/extract_fixtures.rb ieee --verbose
```

## Quality Guidelines

### Pass Criteria

✅ Identifier must:
1. Parse without errors
2. Render back to exact original string
3. Be recognized as correct identifier class

### Fail Categories

Organize failures by reason:

1. **Parser gaps** - Pattern not recognized (e.g., `missing_std_prefix.txt`)
2. **Format issues** - Renders differently (e.g., `spacing_issues.txt`)
3. **Intentional limits** - Out of scope (e.g., `cyrillic.txt`, `nsb_format.txt`)

### Special Cases

Mark intentional limitations clearly:

```
# cyrillic.txt - Intentionally unsupported
# These identifiers contain Cyrillic characters
# V2 focuses on Latin character sets
ISO Руководство 2:2004
...
```

## Integration with Testing

### Unit Tests by Class

```ruby
# spec/pubid_new/iso/identifiers/amendment_spec.rb
RSpec.describe PubidNew::Iso::Identifiers::Amendment do
  describe "fixture validation" do
    let(:pass_fixtures) {
      File.readlines("spec/fixtures/iso/pass/amendment.txt")
          .map(&:strip)
          .reject { |l| l.empty? || l.start_with?("#") }
    }
    
    it "parses and round-trips all passing fixtures" do
      pass_fixtures.each do |id_str|
        parsed = PubidNew::Iso.parse(id_str)
        expect(parsed).to be_a(described_class)
        expect(parsed.to_s).to eq(id_str)
      end
    end
  end
end
```

### Comprehensive Coverage

```ruby
# spec/pubid_new/iso/coverage_spec.rb
RSpec.describe "ISO Fixture Coverage" do
  it "has fixtures for all identifier types" do
    identifier_classes = [
      PubidNew::Iso::Identifiers::InternationalStandard,
      PubidNew::Iso::Identifiers::Amendment,
      # ... all classes
    ]
    
    identifier_classes.each do |klass|
      type_name = klass.name.split("::").last.underscore
      pass_file = "spec/fixtures/iso/pass/#{type_name}.txt"
      expect(File.exist?(pass_file)).to be(true), 
        "Missing pass fixtures for #{klass}"
    end
  end
end
```

## Statistics Tracking

Each extraction generates a summary:

```
# spec/fixtures/iso/SUMMARY.txt (auto-generated)
Flavor: ISO
Extracted: 2025-12-06 11:20:00
Source: archived-gems/pubid-iso/spec/fixtures/*.txt

Total Identifiers: 7,680
Passing: 7,465 (97.2%)
Failing: 215 (2.8%)

By Type:
  international_standard: 5,200 pass, 150 fail
  amendment: 800 pass, 20 fail
  corrigendum: 400 pass, 10 fail
  technical_report: 350 pass, 5 fail
  guide: 250 pass, 10 fail
  nsb_format: 0 pass, 20 fail (intentional)
  ...
```

## Version Control

### Git Tracking

- **Track all files**: Both pass/ and fail/ directories
- **Review changes**: Show improvement in commits
- **Document**: Include statistics in commit messages

### Commit Message Example

```
feat(iso): improve NSB format parser

Fixtures impact:
- spec/fixtures/iso/fail/nsb_format.txt: 20 → 5 (-15)
- spec/fixtures/iso/pass/international_standard.txt: +15

Pass rate: 97.2% → 97.4% (+0.2pp)
```

## Benefits

### For Developers

1. **Targeted testing** - Focus on specific identifier types
2. **Clear organization** - Easy to find examples
3. **Progress tracking** - See improvements as files grow/shrink
4. **Debugging** - Isolated test cases for troubleshooting

### For Documentation

1. **Examples** - Real working identifiers for docs
2. **Coverage** - Understand what's supported
3. **Limitations** - Clear documentation of gaps

### For Project Management

1. **Metrics** - Pass/fail counts by type
2. **Priorities** - Identify high-value fixes
3. **Validation** - Confirm enhancements work

---

**Last Updated**: 2025-12-06  
**Maintained By**: PubID V2 Development Team