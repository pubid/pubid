# Known Parser Gaps - ISO

**Date:** 2025-11-23  
**Session:** 6 (V1 to V2 Migration)  
**Status:** Initial documentation after bulk migration

---

## Overview

This document catalogs known patterns that V1 supported but V2 parser does not yet handle.

**Current Test Status:**
- **Total tests**: 2,648
- **Passing**: 682 (26%)
- **Failures**: 1,590 (60%)
- **Pending**: 376 (14%)

**Note**: Core V2 tests remain at **166 passing, 0 failures** - the foundation is solid.

---

## Gap Categories

### 1. Legacy Recommendation Prefix (`/R`)

**Pattern**: `ISO/R 947:1969/Add 1:1969`

**Error**: Failed to parse - `/R` prefix not recognized

**Status**: Not supported  
**Priority**: Medium  
**Affected Tests**: ~50-100 tests

**Solution Path**: Extend parser BASE_IDENTIFIER rule

### 2. Type/Stage Architecture Differences

**Issue**: V2 architecture varies by identifier class (typed_stage vs type vs implicit)

**Status**: API difference, not parser gap  
**Priority**: Low (tests need adjustment)  
**Affected Tests**: ~200-300 tests

### 3. String vs Integer Expectations

**Pattern**: Tests expecting integer years, V2 returns strings

**Status**: API difference  
**Priority**: Low (simple fix)  
**Affected Tests**: ~100-200 tests

### 4. Nil Component Access

**Pattern**: Tests accessing optional components without nil checks

**Status**: Test issue  
**Priority**: Low  
**Affected Tests**: ~200-300 tests

---

## Estimated Timeline to 80%+ Pass Rate

- **Current**: 26% passing (682/2648)
- **After fixing mismatches**: ~50-60% passing
- **After parser extensions**: ~70-80% passing
- **After architecture decisions**: ~85-95% passing

**Total estimated effort**: 10-16 hours

---

**Last Updated:** 2025-11-23
