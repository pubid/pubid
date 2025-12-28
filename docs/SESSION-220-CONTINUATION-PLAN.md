# Session 220+ Continuation Plan: NIST Complete Pattern Coverage

**Created:** 2025-12-28 (Post-Session 219)
**Status:** Session 219 complete at 99.97% - Ready for comprehensive pattern implementation
**Timeline:** 3-4 sessions (6-8 hours) for complete coverage
**Goal:** Implement all patterns from TODO.NIST-MUST-FIX.md

---

## Executive Summary

**Session 219 Achievement:** NIST at 99.97% (19,821/19,826)

**Remaining Work:** Implement ~88 additional patterns from TODO.NIST-MUST-FIX.md

**Current Failures (3):**
1. `NISTPUB 0413171251` - Data quality (invalid series)
2. `NIST IR 8270-draft2` - Draft with number
3. `NIST.IR.8286C-upd1` - MR format with letter + update

**TODO Patterns Analysis (88 total):**
- Already working: ~20 patterns (tested automatically)
- Need implementation: ~68 patterns across 6 categories

---

## Pattern Categories from TODO.NIST-MUST-FIX.md

### Category 1: Volume Patterns (6 patterns)
```
NBS SP 535v2a-l      # Volume with letter range
NBS SP 535v2m-z      # Volume with letter range
NIST SP 500-268v1.1  # Dotted version
NIST SP 500-270v1.1  # Dotted version
NIST SP 500-280v2.1  # Dotted version
NIST SP 500-281-v1.0 # Dash before version
```

**Status:** Partial - dotted versions working, letter ranges need implementation

### Category 2: Complex Part Patterns (8 patterns)
```
NIST SP 1011-I-2.0   # Roman numeral part
NIST SP 1011-II-1.0  # Roman numeral part
NIST SP 800-57Pt3r1  # Part+revision combo
NIST SP 800-60ver2v1 # Version+volume combo
NIST SP 800-60ver2v2 # Version+volume combo
NIST SP 984.4        # Dot as separator
NBS TN 467p1adde1    # Part+addendum+edition
NBS.TN.467p1adde1    # MR format
```

**Status:** Partial - Roman numerals working, combos need fixes

### Category 3: Revision/Edition Patterns (12 patterns)
```
NIST SP 260-126rev2013      # Revision with year
NIST SP 800-22r1a           # Revision+letter
NIST SP 800-27ra            # Revision letter only
NIST SP 800-28ver2          # Version number
NIST SP 800-40ver2          # Version number
NIST SP 800-44ver2          # Version number
NIST SP 800-45ver2          # Version number
NIST SP 800-67ver1          # Version number
NIST SP 800-87ver1          # Version number
NIST SP 800-87ver1e2006     # Version+edition+year
NIST SP 800-87ver1e2007     # Version+edition+year
NIST.HB.135e2022-upd1       # Edition+year+update
```

**Status:** Mostly working, some edge cases

### Category 4: Draft/Stage Patterns (3 patterns)
```
NIST SP 800-140Br1 2pd  # Letter suffix + revision + stage
NIST SP 800-90C 3pd     # Letter suffix + stage
NIST SP 800-188 3pd     # Stage only
```

**Status:** Needs space handling for pd suffix

### Category 5: Update Patterns (13 patterns)
```
NIST SP 500-300-upd         # Dash before update
NIST.SP.500-300-upd         # MR format
NIST AMS 300-8r1/upd        # Revision + update
NIST IR 8170-upd            # Simple update
NIST TN 2150-upd            # Simple update
NIST IR 8211-upd            # Simple update
NIST IR 8115r1-upd          # Revision + update
NIST.AMS.300-8r1/upd        # MR format
NIST.IR.8115r1-upd          # MR format
NIST.IR.8170-upd            # MR format
NIST.IR.8211-upd            # MR format
NIST.TN.2150-upd            # MR format
NIST.HB.135e2022-upd1       # Edition+year+update
```

**Status:** Update patterns mostly working, some edge cases

### Category 6: Special Number Patterns (14 patterns)
```
NBS CRPL 1-2_3-1A           # Complex CRPL range
NBS LCIRC 1088sp            # SP suffix
NBS LCIRC 118supp3/1926     # Supplement with year
NBS LCIRC 118supp12/1926    # Supplement with year
NBS LCIRC 145r6/1925        # Revision with year
NBS LCIRC 145r11/1925       # Revision with year
NBS LCIRC 59r5/1924         # Revision with year
NBS LCIRC 59r11/1924        # Revision with year
NIST LCIRC 1128r1995        # Revision year
NIST LCIRC 1136             # Simple number
NBS TN 100-A                # Letter suffix
NBS TN 262-A                # Letter suffix
NIST IR 5443-A              # Letter suffix (uppercase)
NIST IR 7297-B              # Letter suffix (uppercase)
```

**Status:** Most working, some LCIRC patterns need verification

### Category 7: Letter Suffix Patterns (5 patterns)
```
NIST IR 7356-CAS  # Multi-letter suffix
NIST IR 7356-FRA  # Multi-letter suffix
NIST GCR 21-917-48v3B  # Volume+letter combo
NIST GCR 21-917-48v1B  # Volume+letter combo
... (6 total GCR patterns with volume+letter)
```

**Status:** Need multi-letter suffix support

### Category 8: RPT Month Patterns (11 patterns)
```
NBS RPT 4817-A       # Number-Letter
NBS RPT ADHOC        # Text pattern
NBS RPT Apr-Jun1948  # Month range
NBS RPT Apr-Jun1949
NBS RPT Apr-Jun1950
NBS RPT Apr-Jun1951
NBS RPT div9         # Division pattern
NBS RPT Jan-Jun1971
NBS RPT Jan-Mar1948
...
```

**Status:** Most working, verification needed

### Category 9: MR Format Patterns (7 patterns)
```
NIST.SP.500-281-v1.0       # MR with dash-version
NIST.TN.1648_2009          # MR with underscore edition
NIST.VTS.100-2sup1         # MR with supplement
NIST.hb.150-1-2017         # MR with lowercase series
nist ir 8011-4             # All lowercase
nbs.tn.671                 # All lowercase
```

**Status:** Lowercase normalization working, other patterns need verification

---

## Implementation Plan

### SESSION 220: Priority Patterns (120 min)

**Part A: Volume Letter Ranges (30 min)**
File: `lib/pubid_new/nist/parser.rb`

Add support for `v2a-l` and `v2m-z` patterns in volume rule:
```ruby
rule(:volume) do
  (space.maybe >> (str("v") | str(" Vol. "))) >>
  (digits >>
   (str("a-l") | str("m-z") | str("A-Z")).maybe >>  # Add letter ranges
   upper_letter.repeat(0, 2)).as(:volume)
end
```

**Part B: Multi-letter Suffixes (30 min)**

Update `second_number` to support multi-letter suffixes (CAS, FRA, etc.):
```ruby
# Multi-letter suffix patterns (e.g., CAS, FRA)
(digits >> dash >> upper_letter.repeat(2, 3)).as(:second_number)
```

**Part C: Volume+Letter Combos (30 min)**

Support patterns like `v3B` (volume + uppercase letter):
```ruby
rule(:volume) do
  (space.maybe >> str("v")) >>
  (digits >>
   upper_letter.maybe >>  # Volume letter: v3B
   (str("a-l") | str("m-z")).maybe).as(:volume)
end
```

**Part D: Testing (30 min)**

Test all patterns and verify improvement.

### SESSION 221: Stage and Update Patterns (90 min)

**Part A: PD with Space (20 min)**

Fix patterns like `800-140Br1 2pd`:
```ruby
rule(:pd_suffix) do
  (space >> digits.maybe >> space >> str("pd")).as(:public_draft)
end
```

**Part B: Complex Update Patterns (40 min)**

Handle revision+update combos like `300-8r1/upd`:
- Already preprocessed correctly
- Verify builder handles properly

**Part C: MR Format Edition Patterns (30 min)**

Support `_YYYY` edition in MR format (`1648_2009`):
- Already in parser at line 553
- Verify it works

### SESSION 222: Validation & Documentation (120 min)

**Part A: Comprehensive Testing (60 min)**

Run classification and verify all TODO patterns:
```bash
cd spec/fixtures && ruby run_classify.rb nist
```

**Part B: Update Documentation (40 min)**

Update README.adoc with:
- NIST pattern coverage summary
- Examples of complex patterns
- Known limitations

**Part C: Archive Session Docs (20 min)**

Move Session 219-222 docs to `docs/old-docs/sessions/`

---

## Implementation Status Tracker

| Category | Patterns | Working | Need Fix | Sessions |
|----------|----------|---------|----------|----------|
| Volume patterns | 6 | 2 | 4 | 220 |
| Complex parts | 8 | 4 | 4 | 220 |
| Revision/edition | 12 | 10 | 2 | 221 |
| Draft/stage | 3 | 0 | 3 | 221 |
| Updates | 13 | 10 | 3 | 221 |
| Special numbers | 14 | 12 | 2 | 220 |
| Letter suffixes | 11 | 6 | 5 | 220 |
| RPT months | 11 | 11 | 0 | ✅ |
| MR formats | 7 | 5 | 2 | 221 |
| **Total** | **88** | **60** | **25** | **3 sessions** |

---

## Success Criteria

### Minimum (95%)
- Implement top 15 most common patterns
- NIST at 95%+ validation
- Clean architecture maintained

### Target (98%)
- Implement all 88 TODO patterns
- NIST at 98%+ validation
- Comprehensive documentation

### Stretch (99%+)
- All patterns working
- Edge cases handled
- Production-ready quality

---

## Key Principles

**MAINTAIN throughout:**
1. **MODEL-DRIVEN** - Objects not strings
2. **MECE** - Mutually exclusive patterns
3. **Three-layer** - Parser/Builder/Identifier separation
4. **NIST spec compliance** - Follow official spec
5. **No compromises** - Architecture quality first

---

**Created:** 2025-12-28
**Status:** Ready for Session 220
**Timeline:** 3-4 sessions (6-8 hours)

**End Goal:** Complete NIST pattern coverage with 98%+ validation! 🎯