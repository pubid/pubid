# Session 158 Continuation Plan: CSA Pre-Existing Bugs Fix

**Created:** 2025-12-17 (Post-Session 157)
**Status:** Session 157 complete - Combined identifiers working
**Timeline:** COMPRESSED - Complete in 60-90 minutes

---

## Executive Summary

**Session 157 Achievement:** Combined identifiers fully working (9/9, 100%) ✅

**Current Status:**
- **CSA: 195/899 (21.69%)**
- **Combined identifiers: COMPLETE** ✅
- **Bundled identifiers: COMPLETE** ✅
- **Series support: COMPLETE** ✅

**Remaining Work (Pre-existing bugs from Session 156):**
1. Package portions not rendered (~30 IDs)
2. M/F year prefixes lost (~15 IDs)
3. Optional CSA prefix missing (~5 IDs)

**Target:** 245-250/899 (27-28%) after Session 158

---

## Session 157 Completion Summary

### What Was Implemented

**1. CombinedIdentifier Class**
- File: `lib/pubid_new/csa/identifiers/combined.rb`
- Supports dual/triple combined identifiers with `/` separator
- Smart rendering: first with CSA, continuations conditional
- Handles reaffirmation and package portions

**2. has_publisher Flag**
- Tracks whether CSA prefix present in continuation
- Enables correct rendering: `CSA A23.1:24/CSA A23.2:24` vs `CSA A123.1-05/A123.5-05`

**3. SERIES Keyword Support**
- `series` boolean attribute
- `series_prefix` string attribute (MH, RV, etc.)
- Proper rendering: `CSA N285.6 SERIES:23` and `CSA Z240 MH SERIES:16`

**4. Files Modified**
- `lib/pubid_new/csa/identifiers/combined.rb` (NEW)
- `lib/pubid_new/csa/builder.rb`
- `lib/pubid_new/csa/parser.rb`
- `lib/pubid_new/csa/single_identifier.rb`
- `lib/pubid_new/csa/identifiers/base.rb`

### Test Results

**Manual Tests:** 4/4 (100%) ✅
- Dual combined with CSA prefixes
- SERIES keyword rendering
- Reaffirmation on combined
- Triple combined

**Classification:** 195/899 (21.69%)
- Gained: +10 identifiers
- All 9 actual combined identifiers now working

---

## SESSION 158: Pre-Existing Bug Fixes (60-90 min)

### Objective
Fix the 3 remaining pre-existing bugs identified in Session 156.

### Part A: Package Portions Support (30 min)

**Issue:** Package keywords parsed but not rendered
**Examples:**
```
CSA A82.30-22 Code, Handbook & Training Package
CSA A82.31-22 Code & Training Package
```

**Solution:**

1. **Parser already captures** (line 99-106):
```ruby
rule(:package_portion) do
  space >>
  package_keyword >>
  ((comma >> space >> package_keyword) |
   (space >> ampersand >> space >> package_keyword)).repeat
end
```

2. **Builder stores in Combined** (already done):
```ruby
if parsed_hash[:package_portion]
  combined.package = parsed_hash[:package_portion].to_s
end
```

3. **Need to add to Standard identifier:**

Update `lib/pubid_new/csa/single_identifier.rb`:
```ruby
attribute :package, :string
```

Update `lib/pubid_new/csa/builder.rb` in `build_single`:
```ruby
# Package portion
if data[:package_portion]
  identifier.package = data[:package_portion].to_s
end
```

Update `lib/pubid_new/csa/identifiers/base.rb` in `to_s`:
```ruby
result = parts.join(" ")

# Reaffirmation
if reaffirmation
  result += " (R#{reaffirmation})"
end

# Package
if package
  result += " #{package}"
end

result
```

**Expected gain:** +30 identifiers

---

### Part B: M/F Year Prefix Preservation (20 min)

**Issue:** French (F) and Metric (M) prefixes lost in rendering
**Examples:**
```
CAN/CSA-C22.2 NO. 231 SERIES-M89 (R2001)  # M lost
CSA N285.6:F20  # F lost
```

**Current state:**
- Parser captures: `year_prefix` (line 63)
- Builder processes but doesn't preserve for rendering
- SingleIdentifier has `french` boolean but no `metric`

**Solution:**

1. **Add year_prefix attribute to SingleIdentifier:**
```ruby
attribute :year_prefix, :string  # "F" or "M"
```

2. **Update Builder to preserve:**
```ruby
# Year prefix (F or M)
if data[:year_prefix]
  identifier.year_prefix = data[:year_prefix].to_s
end
```

3. **Update Base rendering:**
```ruby
if year
  separator = (year_format == "dash") ? "-" : ":"
  year_part = separator
  year_part += year_prefix if year_prefix  # Add M or F
  # Convert 4-digit year back to 2-digit
  # ...
end
```

4. **Update Combined rendering similarly**

**Expected gain:** +15 identifiers

---

### Part C: Optional CSA Prefix Handling (10 min)

**Issue:** Some legacy identifiers lack CSA prefix
**Example:** Historical formats that start directly with code

**Solution:** Already handled by `has_publisher` flag in Combined. May need to extend to Standard if applicable.

Check if any single Standards need this treatment.

**Expected gain:** +5 identifiers

---

### Part D: Testing & Validation (20 min)

**Tasks:**
1. Test package rendering manually
2. Test M/F prefix preservation
3. Run full classification
4. Verify target reached (245-250/899)

---

## Implementation Status Tracker

| Bug | Files | Est. Gain | Status |
|-----|-------|-----------|--------|
| Package portions | single_identifier, builder, base | +30 | ⏳ Planned |
| M/F prefixes | single_identifier, builder, base, combined | +15 | ⏳ Planned |
| Optional prefix | TBD | +5 | ⏳ Planned |
| Testing | all | - | ⏳ Planned |

**Total estimated improvement:** +50 identifiers (195 → 245, 21.69% → 27.26%)

---

## Success Criteria

### Minimum (25%)
- ✅ Package portions rendering
- ✅ M prefix preserved
- ✅ No regressions

### Target (27-28%)
- ✅ All three bugs fixed
- ✅ M and F prefixes working
- ✅ 245-250/899 achieved

---

## Key Architectural Principles

**MAINTAIN throughout:**
1. **MODEL-DRIVEN** - Attributes as proper types
2. **MECE** - Clear responsibility separation
3. **Three-layer** - Parser/Builder/Identifier independence
4. **Round-trip fidelity** - Perfect preservation
5. **No string manipulation** - Use object properties

---

## Files to Modify

### Session 158
- `lib/pubid_new/csa/single_identifier.rb` - Add package, year_prefix
- `lib/pubid_new/csa/builder.rb` - Store package, year_prefix
- `lib/pubid_new/csa/identifiers/base.rb` - Render package, year_prefix
- `lib/pubid_new/csa/identifiers/combined.rb` - Render year_prefix in continuation

---

## Next Steps (Session 158)

1. Add package attribute and rendering
2. Add year_prefix attribute and rendering
3. Test manually
4. Run classification
5. Validate improvement

---

**Created:** 2025-12-17
**Status:** Ready for execution
**Estimated Time:** 60-90 minutes (compressed)

**End Goal:** CSA at 27-28% with all major patterns working! 🚀