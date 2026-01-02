# Session 160+ Continuation Plan: CSA Architecture Redesign

**Created:** 2025-12-17 (Post-Session 159)
**Status:** Session 159 complete - Architecture redesign needed
**Timeline:** 8-10 sessions (16-20 hours) for proper MODEL-DRIVEN architecture
**Priority:** CRITICAL - Session 159 implementation is architecturally incorrect

---

## Executive Summary

**Session 159 Problem:** Implemented CSA features as simple string patterns instead of proper MODEL-DRIVEN architecture with wrapper classes.

**Critical Feedback:**
1. Combined with package is NOT CombinedIdentifier - should be PackageIdentifier/BundleIdentifier
2. CAN/ prefix is a wrapper (CanadianAdoptedIdentifier) not a string prefix
3. CSA adoptions (ISO/IEC/CISPR) need CsaAdoptedIdentifier wrapper
4. Need proper MECE class hierarchy with 8+ identifier types

**Architectural Principle Violated:**
- ✗ String manipulation instead of object composition
- ✗ No wrapper pattern for adoptions
- ✗ Semantic confusion (Combined ≠ Package ≠ Bundle)

**Required Work:**
- Complete architecture redesign
- 8+ new identifier classes
- Wrapper pattern implementation
- Recursive parsing for wrapped identifiers

---

## Session 159 Architectural Issues

### Issue 1: Package vs Combined Confusion

**Current (WRONG):**
```ruby
# "CSA B149.1:25, CSA B149.2:25 & Training Package"
# Parsed as: CombinedIdentifier with package attribute
```

**Correct Architecture:**
```ruby
# This is a PackageIdentifier (or BundleIdentifier) containing:
# - identifiers: [Standard("B149.1:25"), Standard("B149.2:25")]
# - package_items: ["Training Package"]
```

**Why Wrong:** A package identifier is fundamentally different from a combined identifier. Combined means "separate documents published together", Package means "a bundle containing standards plus other materials".

### Issue 2: CAN/ Prefix as String not Wrapper

**Current (WRONG):**
```ruby
# "CAN/CSA-C22.2 NO. 60601-1-9:15"
# Treated as: Standard with publisher_prefix="CAN/CSA-"
```

**Correct Architecture:**
```ruby
# CanadianAdoptedIdentifier wrapping:
#   CsaIdentifier("C22.2 NO. 60601-1-9:15")
# Rendering: "CAN/" + wrapped_identifier.to_s
```

**Why Wrong:** CAN/ indicates Canadian adoption of another standard. This is a wrapper relationship, not a string prefix.

### Issue 3: CSA Adoptions Missing

**Current (WRONG):**
```ruby
# "CSA ISO/IEC TR 12785-3:15 (R2019)"
# Current: iso_iec_adoption rule, but wrong architecture
```

**Correct Architecture:**
```ruby
# CsaAdoptedIdentifier wrapping:
#   IsoIecIdentifier("ISO/IEC TR 12785-3", year: "15")
# Note: Uses 2-digit year (15), not 4-digit (2015)
```

---

## Proper CSA Architecture (MECE)

### Identifier Class Hierarchy

```
PubidNew::Csa::Identifier (base)
│
├─ SingleIdentifier (base for single standards)
│  ├─ Standard (basic CSA standard)
│  ├─ CanIdentifier (CAN3- historical prefix)
│  └─ SeriesIdentifier (SERIES keyword)
│
├─ WrapperIdentifier (base for wrappers)
│  ├─ CanadianAdoptedIdentifier (CAN/{identifier})
│  └─ CsaAdoptedIdentifier (CSA {ISO/IEC/CISPR/etc})
│
├─ CompositeIdentifier (base for multiple identifiers)
│  ├─ CombinedIdentifier (/{separator} - separate docs)
│  ├─ BundledIdentifier (+ - consolidated docs)
│  ├─ PackageIdentifier (standards + package materials)
│  └─ BundleIdentifier (PACKAGE/Bundle keyword)
│
└─ SupplementIdentifier (base for amendments)
   ├─ Amendment
   └─ Corrigendum
```

### Key Architectural Patterns

**1. Wrapper Pattern (for adoptions):**
```ruby
class CanadianAdoptedIdentifier < WrapperIdentifier
  attribute :wrapped_identifier, Identifier  # Recursive
  attribute :reaffirmation, :string

  def to_s
    result = "CAN/#{wrapped_identifier}"
    result += " (R#{reaffirmation})" if reaffirmation
    result
  end
end
```

**2. Composite Pattern (for packages/bundles):**
```ruby
class PackageIdentifier < CompositeIdentifier
  attribute :identifiers, Identifier, collection: true
  attribute :package_items, :string, collection: true

  def to_s
    parts = identifiers.map(&:to_s)
    parts << package_items.join(" & ") if package_items.any?
    parts.join(", ")
  end
end
```

**3. Adoption Pattern (for CSA adoptions):**
```ruby
class CsaAdoptedIdentifier < WrapperIdentifier
  attribute :source_identifier, Identifier  # ISO/IEC/CISPR/etc
  attribute :year, :string  # 2-digit year (CSA convention)
  attribute :reaffirmation, :string

  def to_s
    result = "CSA #{source_identifier.publisher} #{source_identifier.number}"
    result += ":#{year}" if year
    result += " (R#{reaffirmation})" if reaffirmation
    result
  end
end
```

---

## Implementation Roadmap

### Phase 1: Wrapper Infrastructure (Sessions 160-161, 4 hours)

**Session 160: WrapperIdentifier Base (2 hours)**

Create base infrastructure for wrapper pattern:

1. **Create WrapperIdentifier base class**
   ```ruby
   # lib/pubid_new/csa/wrapper_identifier.rb
   class WrapperIdentifier < Identifier
     attribute :wrapped_identifier, Identifier
     attribute :reaffirmation, :string

     def to_s
       raise NotImplementedError
     end
   end
   ```

2. **Create CanadianAdoptedIdentifier**
   ```ruby
   # lib/pubid_new/csa/identifiers/canadian_adopted.rb
   class CanadianAdoptedIdentifier < WrapperIdentifier
     def to_s
       result = "CAN/#{wrapped_identifier}"
   result += " (R#{reaffirmation})" if reaffirmation
       result
     end
   end
   ```

3. **Update Parser for CAN/ pattern**
   - Detect CAN/ prefix
   - Parse wrapped identifier recursively
   - Mark as canadian_adopted

4. **Update Builder for wrapper construction**
   - Build wrapped identifier first
   - Wrap in CanadianAdoptedIdentifier
   - Handle reaffirmation

**Expected:** 50-100 CAN/ identifiers working

**Session 161: CsaAdoptedIdentifier (2 hours)**

1. **Create CsaAdoptedIdentifier**
   - Wrapper for ISO/IEC/CISPR/CEI adoptions
   - 2-digit year handling
   - Publisher passthrough

2. **Update Parser for CSA adoptions**
   - CSA ISO/IEC pattern
   - CSA CISPR pattern
   - CSA IEC pattern (without ISO)

3. **Enhance IEC parser for CEI**
   - CEI/IEC copublisher support
   - CEI-only publisher support

**Expected:** 100-150 adoption identifiers working

---

### Phase 2: Composite Identifiers (Sessions 162-164, 6 hours)

**Session 162: PackageIdentifier (2 hours)**

1. **Create CompositeIdentifier base**
2. **Create PackageIdentifier**
   - Collection of identifiers
   - Collection of package items
   - Proper rendering with separators

3. **Update Parser**
   - Detect package patterns
   - Parse identifier lists
   - Capture package items

**Expected:** 20-30 package identifiers working

**Session 163: BundleIdentifier (2 hours)**

1. **Create BundleIdentifier**
   - PACKAGE keyword
   - Bundle keyword
   - Codebook patterns

2. **Distinguish from PackageIdentifier**
   - Package: comma-separated with materials
   - Bundle: single identifier + PACKAGE

**Expected:** 30-50 bundle identifiers working

**Session 164: Refine CombinedIdentifier (2 hours)**

1. **Remove package logic from Combined**
2. **Pure combined: slash-separated only**
3. **No package attributes**

**Expected:** All combined identifiers clean, no regressions

---

### Phase 3: Historical & Series (Sessions 165-166, 4 hours)

**Session 165: CanIdentifier (2 hours)**

1. **Create CanIdentifier for CAN3-**
   - Historical Canadian prefix
   - Different from CanadianAdopted (CAN/)

2. **Update Parser**
   - Distinguish CAN3- from CAN/

**Expected:** 20-30 CAN3- identifiers working

**Session 166: SeriesIdentifier (2 hours)**

1. **Create SeriesIdentifier**
   - SERIES keyword as primary type
   - Not just attribute

2. **Handle SERIES with suffix**
   - "SERIES C" pattern
   - Letter suffix after SERIES

**Expected:** 15-20 SERIES identifiers working

---

### Phase 4: Testing & Validation (Sessions 167-168, 4 hours)

**Session 167: Comprehensive Testing (2 hours)**

1. Test all 8+ identifier classes
2. Test recursive wrapping
3. Test package compositions
4. Validate round-trip fidelity

**Session 168: 60%+ Achievement (2 hours)**

1. Run full classification
2. Analyze remaining failures
3. Quick fixes for high-value patterns
4. Document final status

**Target:** CSA 60%+ (540+/899)

---

### Phase 5: Documentation (Session 169, 2 hours)

1. Update README.adoc with architecture
2. Document wrapper pattern
3. Document composite pattern
4. Create CSA architecture guide

---

## Success Criteria

### Architectural (CRITICAL)
- ✅ Wrapper pattern for adoptions (CAN/, CSA ISO/IEC)
- ✅ Composite pattern for packages/bundles
- ✅ MECE class hierarchy (8+ types)
- ✅ Recursive identifier parsing
- ✅ Proper object composition, not string manipulation

### Functional
- ✅ CSA at 60%+ (540+/899)
- ✅ All wrapper identifiers working
- ✅ All composite identifiers working
- ✅ Round-trip fidelity maintained

---

## Files to Create

### Wrapper Infrastructure
1. `lib/pubid_new/csa/wrapper_identifier.rb`
2. `lib/pubid_new/csa/identifiers/canadian_adopted.rb`
3. `lib/pubid_new/csa/identifiers/csa_adopted.rb`

### Composite Infrastructure
4. `lib/pubid_new/csa/composite_identifier.rb`
5. `lib/pubid_new/csa/identifiers/package.rb`
6. `lib/pubid_new/csa/identifiers/bundle.rb`

### Historical/Series
7. `lib/pubid_new/csa/identifiers/can.rb` (CAN3- historical)
8. `lib/pubid_new/csa/identifiers/series.rb`

### Tests
9. `spec/pubid_new/csa/identifiers/canadian_adopted_spec.rb`
10. `spec/pubid_new/csa/identifiers/csa_adopted_spec.rb`
11. `spec/pubid_new/csa/identifiers/package_spec.rb`
12. `spec/pubid_new/csa/identifiers/bundle_spec.rb`

---

## Key Principles

**Throughout ALL sessions:**

1. **MODEL-DRIVEN** - Objects not strings
2. **Wrapper Pattern** - Adoptions wrap other identifiers
3. **Composite Pattern** - Packages/bundles contain identifiers
4. **Recursive Parsing** - Wrapped identifiers fully parsed
5. **MECE** - Each identifier type mutually exclusive
6. **Semantic Correctness** - Architecture > test count

**NEVER:**
- Treat wrappers as string prefixes
- Confuse package/bundle/combined semantics
- Skip wrapper pattern for "simplicity"
- Compromise architecture for quick wins

---

## Timeline Summary

| Sessions | Focus | Duration | Deliverables |
|----------|-------|----------|--------------|
| 160-161 | Wrapper infrastructure | 4 hours | CAN/, CSA adoptions |
| 162-164 | Composite identifiers | 6 hours | Package, Bundle, Combined |
| 165-166 | Historical & Series | 4 hours | CAN3-, SERIES |
| 167-168 | Testing & 60%+ | 4 hours | Validation complete |
| 169 | Documentation | 2 hours | Architecture docs |
| **Total** | **Complete redesign** | **20 hours** | **Correct architecture** |

---

## Next Immediate Steps (Session 160)

1. Read this plan thoroughly
2. Create WrapperIdentifier base class
3. Implement CanadianAdoptedIdentifier
4. Update Parser for CAN/ detection
5. Update Builder for wrapper construction
6. Test on CAN/ patterns

---

**Created:** 2025-12-17
**Status:** Ready for execution
**Priority:** CRITICAL - Architecture correctness over test count

**End Goal:** Proper MODEL-DRIVEN CSA architecture with 60%+ validation! 🎯