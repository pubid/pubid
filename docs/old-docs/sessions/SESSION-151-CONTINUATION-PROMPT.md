# Session 151 Quick Start: CSA & API Flavor Implementation

**Read First:** `docs/SESSION-151-CONTINUATION-PLAN.md` (comprehensive plan)

---

## Session 151 Goal: Implement CSA Flavor (90 minutes)

### Context
Session 150 enhanced ASME to **94.8%** (693/731) with comprehensive joint development support. Now implementing CSA and API as standalone flavors.

**Fixture counts:**
- CSA: 24 identifiers (~16-18 valid after filtering)
- API: 198 identifiers

---

## Quick Implementation Steps

### Part A: CSA Pattern Analysis (15 min)

**Read fixtures:**
```ruby
require 'pubid_new'
File.readlines('spec/fixtures/csa/identifiers/full/identifiers.txt').grep_v(/^(CSA (Communities|Group|Learning|OnDemand|Update))/)
```

**Key patterns to support:**
- Basic: `CSA B149.1:20`
- French year: `CSA B149.1:F20`
- Reaffirmed: `CSA A123.17-05 (R2019)`
- Combined: `CSA A123.1-05/A123.5-05 (R2015)`
- With NO.: `CSA C22.2 NO. 286:23`
- Packages: `CSA B149.1:25 Code, Handbook & Training Package`
- Series: `CSA N285.0:23/CSA N285.6 SERIES:23`

### Part B: Create CSA Structure (30 min)

**Files to create (8 files):**
1. `lib/pubid_new/csa.rb`
2. `lib/pubid_new/csa/identifier.rb`
3. `lib/pubid_new/csa/parser.rb`
4. `lib/pubid_new/csa/builder.rb`
5. `lib/pubid_new/csa/single_identifier.rb`
6. `lib/pubid_new/csa/components/code.rb`
7. `lib/pubid_new/csa/identifiers/base.rb`
8. `lib/pubid_new/csa/identifiers/standard.rb`

**Use ASME as template** - Similar structure, adapt for CSA patterns

### Part C: Implement CSA Parser (25 min)

**Key rules:**
```ruby
rule(:publisher) { str("CSA") >> space }
rule(:no_keyword) { space >> str("NO") >> dot >> space }
rule(:year_prefix) { str("F").maybe }  # French
rule(:year) { str(":") >> year_prefix >> digit.repeat(2) }
rule(:package_keywords) { ... }
```

### Part D: Test & Validate (20 min)

```bash
cd spec/fixtures && ruby run_classify.rb csa
```

**Expected:** 16-18/24 (67-75%)

---

## Architecture Reference

**ASME files to copy/adapt:**
- `lib/pubid_new/asme/parser.rb` → CSA parser structure
- `lib/pubid_new/asme/builder.rb` → CSA builder structure
- `lib/pubid_new/asme/identifiers/base.rb` → CSA base

**Key differences:**
- Year: `:` not `-`
- F prefix on year (French edition)
- "NO." keyword
- Package keywords
- SERIES keyword

---

## Key Reminders

1. **Filter non-standards** - "CSA Group", "CSA Communities", etc.
2. **MODEL-DRIVEN** - Objects not strings
3. **MECE** - One identifier type (Standard)
4. **Three-layer** - Parser/Builder/Identifier
5. **Test after creation** - Verify before moving to API

---

## Success Metrics

**Minimum (60%):** 14-15/24 identifiers
**Target (70%):** 16-17/24 identifiers
**Stretch (80%):** 19-20/24 identifiers

---

**Next:** Session 152 (API Implementation - 120 min)

Good luck with CSA implementation! 🚀