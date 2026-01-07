# NIST Parser Enhancements Needed

**Created:** 2026-01-06 (Post-Session 276)
**Status:** Documentation of future parser work

---

## Overview

The NIST V2 architecture is COMPLETE and MODEL-DRIVEN. The remaining test failures are due to parser patterns not yet implemented, NOT architectural issues.

**Current Status:**
- Architecture: ✅ COMPLETE (Part.type, Edition, Update components)
- Parser coverage: ~65% (34/52 tests passing)
- Remaining: Parser pattern enhancements

---

## Enhancement 1: Edition Year Normalization

**Pattern:** `-YYYY` format should normalize to `eYYYY` per spec

**NIST Spec Reference:** Lines 228-229, Table 1

**Affected Tests:** 9 tests

**Examples:**
```
Input: "NIST SP 330-2019"
Expected: "NIST SP 330e2019"

Input: "NIST SP 304a-2017"
Expected: "NIST SP 304Ae2017"

Input: "NIST SP 260-162 2006ed."
Expected: "NIST SP 260-162e2006"
```

**Implementation Notes:**
- Parser needs to recognize `-YYYY` as edition year (not part of number)
- Builder should create Edition(type: "e", id: "YYYY")
- Requires distinguishing `-YYYY` (edition) from `-XXX` (part of number like 800-53)

**File to modify:** `lib/pubid_new/nist/parser.rb`

---

## Enhancement 2: Version Normalization

**Pattern:** `v1.1` or `Ver. 2.0` should normalize to `ver1.1`, `ver2.0`

**NIST Spec Reference:** Line 138 (versions use "revision" edition-type in spec)

**Affected Tests:** 6 tests

**Examples:**
```
Input: "NIST SP 500-268v1.1"
Expected: "NIST SP 500-268ver1.1"

Input: "NIST SP 800-60 Ver. 2.0"
Expected: "NIST SP 800-60ver2.0"
```

**Implementation Notes:**
- Parser currently captures `v1.1` but doesn't normalize to `ver`
- May need Version component or use Edition with special handling
- `Ver.` with period needs normalization

**Files to modify:**
- `lib/pubid_new/nist/parser.rb` - Capture version patterns
- `lib/pubid_new/nist/identifiers/base.rb` - Rendering logic

---

## Priority Assessment

**High Priority (for 90%+ coverage):**
1. Edition year normalization (9 tests) - Spec-compliant behavior
2. Version normalization (6 tests) - Common pattern

**Low Priority:**
- Additional edge cases as discovered

---

## Session 277 Actions

**What was done:**
- ✅ Fixed Update test expectations to match spec (`-upd1` not `/Upd1-202105`)
- ✅ Documented parser enhancements needed (this file)

**What was NOT done (intentionally):**
- Parser implementations - These are future enhancements
- Test expectations remain as-is for version/edition patterns

**Rationale:**
- Test expectations reflect CORRECT spec behavior
- Parser work is separate from architecture work
- Architecture is COMPLETE ✅

---

## Estimated Effort

**Enhancement 1 (Edition Year):** 60-90 minutes
- Parser pattern recognition
- Builder logic update
- Testing and validation

**Enhancement 2 (Version):** 45-60 minutes
- Parser pattern recognition
- Rendering normalization
- Testing and validation

**Total:** 105-150 minutes (2-2.5 hours) for 90%+ coverage

---

**Status:** DOCUMENTED - Ready for future implementation when needed