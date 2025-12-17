# Session 168+ Continuation Plan: CSA Fixes, IEEE Relationships, ANS Flavor

**Created:** 2025-12-17 (Post-Session 167)
**Status:** CEN at 100%, ready for remaining work
**Timeline:** COMPRESSED - Complete in 3-4 sessions (6-8 hours)

---

## Executive Summary

**Session 167 Achievement:** CEN enhanced to 100% (71/71) ✅

**Current Status:**
- **CEN:** 71/71 (100%) ✅ PERFECT
- **CSA:** 863/901 (95.78%) - 15 simple fixes needed
- **IEEE:** 8,422/9,537 (88.31%) - Complex relationship patterns
- **Overall:** 87,778/88,924 (98.71%)

**Remaining Work:**
1. CSA: 15 simple pattern fixes (Session 168)
2. IEEE: Complex relationship patterns (Sessions 169-170)
3. ANS: New flavor implementation (Session 171)

---

## SESSION 168: CSA Simple Pattern Fixes (60 min)

### Objective
Fix 15 CSA identifiers with simple patterns to reach 97%+

### Pattern Analysis

**All 15 failures are simple variations:**
```
CSA C22.1:24              # C22.1:24 (no CSA prefix)
CSA 12.2-02               # Dash year format
CSA 12.4:22               # Dotted number, colon year
CSA 15189HB:25            # Letter suffix (HB) + colon year
CSA 2.15:16 (R2021)       # Dotted number with reaffirmation
CSA 3.11:15 (R2020)       # Similar pattern
CSA C22.1:24 Code & Handbook Package  # Package keyword
```

**Pattern types:**
1. **No CSA prefix** (1 ID): `C22.1:24`
2. **Dash year without NO.** (2 IDs): `12.2-02`, `8.3-2015`
3. **Dotted number + colon year** (8 IDs): `12.4:22`, `2.15:16`, etc.
4. **Letter suffix + colon year** (1 ID): `15189HB:25`
5. **Package keyword** (3 IDs): `Code & Handbook Package`, `Code and Handbook Package`

### Implementation

**Phase A: Parser Enhancement (30 min)**

Update [`lib/pubid_new/csa/parser.rb`](lib/pubid_new/csa/parser.rb:1):

```ruby
# Allow optional CSA prefix for special cases
rule(:optional_csa_prefix) { str("CSA").maybe >> space.maybe }

# Dotted number (12.4, 2.15, etc.)
rule(:dotted_number) do
  digits >> dot >> digits
end

# Full code pattern (includes dotted numbers)
rule(:code) do
  (
    dotted_number |          # 12.4, 2.15
    letter_code |            # C22.1
    specialized_code         # B149.1, Z662, etc.
  ).as(:code)
end

# Letter suffix in code (15189HB)
rule(:code_with_suffix) do
  digits >> letters.as(:suffix)
end

# Package keyword
rule(:package_portion) do
  space >> (
    str("Code & Handbook Package") |
    str("Code and Handbook Package") |
    str("PACKAGE") >> (str(" (") >> match("[^)]+") >> str(")")
).maybe
  ).as(:package)
end
```

**Expected gain:** +15 identifiers (95.78% → 97.44%)

---

## SESSION 169-170: IEEE Complex Relationship Patterns (4-5 hours)

### Objective
Handle IEEE complex "Amendment to X as amended by Y, Z" patterns

### Pattern Analysis (from failures)

**Complex amendment patterns** (~100 identifiers):
```
IEEE Std 802.3cc-2017 (Amendment to IEEE Std 802.3-2015 as amended by IEEE's 802.3bw-2015, 802.3by-2016, ...)
IEEE Std 802.1Qbv-2015 (Amendment to IEEE Std 802.1Q-2014 as amended by ... and IEEE Std 802.1Q-2014/Cor 1-2015)
IEEE Std 802.15.4k-2013 (Amendment to IEEE Std 802.15.4-2011 as amended by IEEE Std 802.15.4e-2012, ...)
```

**Incorporates patterns** (~20 identifiers):
```
IEEE Std 802.1Q, 2013 Edition (Incorporates IEEE Std 802.1Q-2011, IEEE Std 802.1Qbe-2011, ...)
IEEE Std 1003.1, 2013 Edition (incorporates IEEE Std 1003.1-2008, and IEEE Std 1003.1-2008/Cor 1-2013)
```

**Nickname patterns** (~10 identifiers):
```
IEEE Std 446-1995 [The Orange Book]
IEEE Std 493-1997 [IEEE Gold Book]
IEEE Std 602-1996 [The White Book]
```

**CSA dual published** (~4 identifiers):
```
IEEE Std 844.1-2017/CSA C22.2 No. 293.1-17
IEEE Std 844.3-2019/CSA C22.2 No. 293.3:19
```

### Architecture Solution

**Extend Pattern 4 Relationship component:**

1. **Add "as_amended_by" clause**
   - Store list of intermediate amendments
   - Render correctly in to_s

2. **Add "nickname" attribute**
   - Store book nicknames like "[The Orange Book]"
   - Optional rendering

3. **Enhance relationship parsing**
   - Handle comma-separated lists
   - Handle "and" separator
   - Handle "IEEE's" prefix variant

**Implementation time:** 4-5 hours split across 2 sessions

---

## SESSION 171: ANS Flavor Implementation (90-120 min)

### Objective
Implement ANS (American National Standards) flavor

### Rationale
ANS is similar to ANSI but distinct - need separate flavor for proper MODEL-DRIVEN architecture.

### Architecture

**Identifier classes** (similar to ANSI):
```
ANS/
├── identifier.rb
├── parser.rb
├── builder.rb
├── scheme.rb
├── single_identifier.rb
└── identifiers/
    ├── base.rb
    └── american_national_standard.rb
```

**Expected fixtures:** ~50-100 identifiers

**Implementation time:** 90-120 min

---

## Success Criteria

### Session 168 (CSA Fixes)
- ✅ CSA: 878+/901 (97.44%+)
- ✅ 15 simple patterns working
- ✅ No regressions

### Sessions 169-170 (IEEE Relationships)
- ✅ IEEE: 8,522+/9,537 (89.36%+)
- ✅ Complex amendment patterns working
- ✅ "as amended by" clause implemented
- ✅ Architecture clean (no hacks)

### Session 171 (ANS Flavor)
- ✅ ANS flavor implemented
- ✅ 20/20 flavors complete (100%)
- ✅ ANS at 90%+ baseline

### Overall Project
- ✅ 88,000+/89,000+ identifiers (98.9%+)
- ✅ 20 flavors production-ready
- ✅ Complete documentation

---

## Timeline Summary

| Session | Focus | Duration | Target |
|---------|-------|----------|--------|
| 168 | CSA simple fixes | 60 min | CSA 97%+ |
| 169 | IEEE patterns (Part 1) | 150 min | IEEE 89%+ |
| 170 | IEEE patterns (Part 2) | 120 min | IEEE 90%+ |
| 171 | ANS flavor | 120 min | ANS 90%+ |
| **Total** | **All work** | **450 min** | **Complete** |

---

## Key Architectural Principles

**M

AINTAIN throughout:**
1. **MODEL-DRIVEN** - Objects not strings
2. **MECE** - Mutually exclusive, collectively exhaustive
3. **Three-layer** - Parser/Builder/Identifier independence
4. **Wrapper pattern** - For complex relationships
5. **Component reuse** - Share across flavors where appropriate
6. **No hacks** - Architecture correctness over test count

---

## Files to Create/Modify

### Session 168 (CSA)
- `lib/pubid_new/csa/parser.rb`
- `lib/pubid_new/csa/single_identifier.rb` (add package attribute)

### Sessions 169-170 (IEEE)
- `lib/pubid_new/ieee/components/relationship.rb`
- `lib/pubid_new/ieee/parser.rb`
- `lib/pubid_new/ieee/identifiers/base.rb` (add nickname)

### Session 171 (ANS)
- `lib/pubid_new/ans.rb` (NEW)
- `lib/pubid_new/ans/identifier.rb` (NEW)
- `lib/pubid_new/ans/parser.rb` (NEW)
- `lib/pubid_new/ans/builder.rb` (NEW)
- Plus 3-4 more files

---

**Created:** 2025-12-17
**Sessions Covered:** 168-171
**Status:** Ready for execution
**Estimated Time:** 7.5 hours (compressed)

**End Goal:** CSA 97%+, IEEE 90%+, ANS implemented, 20 flavors complete! 🚀