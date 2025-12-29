# Session 224+ Continuation Plan: IEEE TODO Quick Wins

**Created:** 2025-12-28 (Post-Session 223)
**Status:** User-requested enhancements for 16 specific identifiers
**Timeline:** COMPRESSED - Complete in 2-3 sessions (3-4 hours)

---

## Executive Summary

**User identified 16 parseable patterns from TODO file** that can be fixed with focused enhancements.

**Current Status:**
- IEEE: 84.76% (8,409/9,537) on real fixtures
- TODO: 32/115 (27.8%)
- **Target:** +16 identifiers → 48/115 (41.7%)

**Estimated Effort:** 3-4 hours for 16 high-value patterns

---

## User-Requested Patterns (16 Identifiers)

### Category 1: EIA Copublisher (3 identifiers) - 30 min
```
IEEE/EIA 12207.0-1996
IEEE/EIA 12207.1-1997
IEEE/EIA 12207.2-1997
```

**Fix:** Add EIA to copublisher list
**File:** `lib/pubid_new/ieee/parser.rb`
**Complexity:** LOW - Just add to existing copublisher rule

### Category 2: ASTM SI/PSI Patterns (3 identifiers) - 60 min
```
IEEE/ASTM SI 10-1997
IEEE/ASTM SI 10-2002 (Revision of IEEE/ASTM SI 10-1997)
IEEE/ASTM SI 10-2016 (Revision of IEEE/ASTM SI 10-2010)
```

**Fix:** Add SI as document type indicator, ASTM copublisher support
**Files:** 
- `lib/pubid_new/ieee/parser.rb` - Add SI pattern after copublisher
- `lib/pubid_new/ieee/builder.rb` - Handle SI type
**Complexity:** MEDIUM - New pattern but straightforward

### Category 3: Data Quality Preprocessing (8 identifiers) - 30 min
```
IEEE Std. 1244.2-2000                           # Period after Std
IEEE Std. C62.21-2003/Cor 1-2008 (...)         # Period + Cor
IEEE Std C37.101 -2006 (...) - Redline         # Space before dash + Redline
IEEE Std C37.102 -2006 (...) - Redline         # Space before dash + Redline
IEEE Std C57.110™-2018 (...)                   # Trademark (™ not (TM))
IEEE Std C57.13-1993(R2003) (Revision of ...   # Missing closing paren
IEEE Std C62.35- 2010 (...)                    # Space after dash
IEEE Std C37.20.3-2001 - IEEE Standard for...  # Title after dash
```

**Fix:** Enhance preprocessing in Parser.parse
**File:** `lib/pubid_new/ieee/parser.rb` lines 851-899
**Additions:**
- Period removal: `Std.` → `Std`
- Space normalization: ` -` → `-`, `- ` → `-`
- Trademark symbol: `™` → `` (empty)
- Missing paren: Add closing `)` if unbalanced
- Redline suffix: ` - Redline` → `` (remove)
- Title portion: Remove ` - {text}` after year

**Complexity:** LOW - All preprocessing

### Category 4: Complex Amendments (2 identifiers) - 30 min
```
IEEE Std 802.11g-2003 (Amendment to IEEE Std 802.11, 1999 Edn. (Reaff 2003) as amended by IEEE Stds 802.11a-1999, 802.11b-1999, 802.11b-1999/Cor 1-2001, and 802.11d-2001)
IEEE Std 802.11h-2003 (Amendment to IEEE Std 802.11, 1999 Edn. (Reaff 2003))
```

**Fix:** Test if already working with Pattern 4 relationships
**If not:** Enhance relationship parser to handle:
- Edition notation: `1999 Edn.`
- Reaffirmation: `(Reaff 2003)`
- Multiple identifiers with "and": `802.11a-1999, 802.11b-1999, and 802.11d-2001`

**Files:** `lib/pubid_new/ieee/parser.rb`
**Complexity:** MEDIUM - May already work

---

## SESSION 224: Quick Preprocessing Wins (60 minutes)

### Objective
Fix all 8 preprocessing patterns + test 2 complex amendments

### Phase 1: Preprocessing Enhancements (30 min)

**File:** `lib/pubid_new/ieee/parser.rb`

**Add to preprocessing block (around line 851):**

```ruby
# Period after Std/Stad
cleaned = cleaned.gsub(/\bStd\.\s+/, 'Std ')
cleaned = cleaned.gsub(/\bStad\.\s+/, 'Std ')

# Trademark symbol variants
cleaned = cleaned.gsub(/™/, '')
cleaned = cleaned.gsub(/&x2122;/, '')

# Space normalization around dashes (comprehensive)
cleaned = cleaned.gsub(/\s+-/, '-')      # Before dash
cleaned = cleaned.gsub(/-\s+/, '-')      # After dash

# Redline suffix removal
cleaned = cleaned.gsub(/\s+-\s+Redline.*$/, '')

# Title portion after dash-year pattern
# Match: "2001 - IEEE Standard for..." and remove " - ..." part
cleaned = cleaned.gsub(/(\d{4})\s+-\s+[A-Z].*$/, '\1')

# Fix unbalanced parentheses
open_count = cleaned.count('(')
close_count = cleaned.count(')')
if open_count > close_count
  cleaned += ')' * (open_count - close_count)
end
```

**Expected gain:** +8 identifiers

### Phase 2: Test Complex Amendments (10 min)

Test if these already work:
```ruby
require 'pubid_new/ieee'

id1 = PubidNew::Ieee.parse('IEEE Std 802.11g-2003 (Amendment to IEEE Std 802.11, 1999 Edn. (Reaff 2003) as amended by IEEE Stds 802.11a-1999, 802.11b-1999, 802.11b-1999/Cor 1-2001, and 802.11d-2001)')

id2 = PubidNew::Ieee.parse('IEEE Std 802.11h-2003 (Amendment to IEEE Std 802.11, 1999 Edn. (Reaff 2003))')
```

If they parse successfully, no changes needed (+2 identifiers).

### Phase 3: Validation (20 min)

```bash
# Test on TODO file
ruby analyze_all_ieee_todo.rb

# Verify no regressions on real fixtures
cd spec/fixtures && ruby run_classify.rb ieee
```

**Expected results:**
- TODO: 32/115 → 40/115 (34.8%) minimum
- Real fixtures: 8,409/9,537 maintained or improved

---

## SESSION 225: EIA Copublisher + ASTM SI (90 minutes)

### Objective
Add EIA copublisher support + ASTM SI document type

### Phase 1: EIA Copublisher (20 min)

**File:** `lib/pubid_new/ieee/parser.rb`

**Update copublisher rule (around line 150):**

```ruby
rule(:copublisher) do
  (
    str("IEC") | str("ISO") | str("ANSI") | 
    str("ASTM") | str("CSA") | str("EIA")  # NEW: Add EIA
  ).as(:copublisher)
end
```

**Expected gain:** +3 identifiers

### Phase 2: ASTM SI Support (60 min)

**Challenge:** SI appears after copublisher but before number

**Pattern:** `IEEE/ASTM SI 10-1997`

**Strategy:** Add SI as optional type indicator after copublisher

**Parser enhancement:**
```ruby
rule(:si_indicator) do
  str("SI").as(:si_type)
end

rule(:ieee_identifier) do
  publisher >>
  (slash >> copublisher).maybe >>
  space.maybe >>
  si_indicator.maybe >>  # NEW: Optional SI
  space.maybe >>
  (type_word.as(:type) >> space?).maybe >>
  number >>
  # ... rest of pattern
end
```

**Builder update:**
```ruby
# In build method
if attributes[:si_type]
  # SI documents are standards with special type
  identifier.type = "SI"
end
```

**Expected gain:** +3 identifiers

### Phase 3: Testing & Validation (10 min)

Run comprehensive tests and validate improvement.

---

## SESSION 226: Complex Amendment Enhancement (OPTIONAL - 30 min)

**Only if Session 224 Phase 2 shows they don't parse**

Enhance relationship parser to handle:
- Edition notation patterns
- Reaffirmation in parentheses
- Multiple identifiers with "and" conjunction

---

## Implementation Status Tracker

| Session | Category | IDs | Time | Status |
|---------|----------|-----|------|--------|
| 224 | Preprocessing | 8 | 30 min | ⏳ Pending |
| 224 | Test complex amds | 2 | 10 min | ⏳ Pending |
| 225 | EIA copublisher | 3 | 20 min | ⏳ Pending |
| 225 | ASTM SI | 3 | 60 min | ⏳ Pending |
| 226 | Complex amds (opt) | 2 | 30 min | ⏳ Optional |
| **Total** | **All patterns** | **16** | **150-180 min** | **2-3 sessions** |

---

## Success Criteria

### Minimum (224 only)
- ✅ 8 preprocessing patterns working
- ✅ 2 complex amendments tested
- ✅ TODO: 40/115 (34.8%)
- ✅ No regressions

### Target (224-225)
- ✅ All 16 user-requested patterns working
- ✅ TODO: 48/115 (41.7%)
- ✅ Architecture quality maintained

### Stretch (224-226)
- ✅ Additional patterns discovered
- ✅ TODO: 50+/115 (43%+)

---

## Key Principles

**Maintain throughout:**
- ✅ MODEL-DRIVEN architecture
- ✅ MECE organization
- ✅ Three-layer separation
- ✅ Parser-only changes (preprocessing + pattern additions)
- ✅ Zero architectural compromises

---

## Files to Modify

- `lib/pubid_new/ieee/parser.rb` - Preprocessing + copublisher + SI
- `lib/pubid_new/ieee/builder.rb` - SI type handling (if needed)

---

## Next Steps (Session 224)

1. Read this continuation plan
2. Implement preprocessing enhancements (8 patterns)
3. Test complex amendments (2 patterns)
4. Validate on TODO file
5. Verify no regressions
6. Commit progress

---

**Created:** 2025-12-28
**Status:** Ready for Session 224
**Estimated Time:** 150-180 minutes (compressed to 2-3 sessions)
**Target:** +16 identifiers (27.8% → 41.7%)

**End Goal:** User-requested patterns working, maintaining production quality! 🎯
