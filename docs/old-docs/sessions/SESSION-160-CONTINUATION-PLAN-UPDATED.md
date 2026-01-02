# Session 160-167 Continuation Plan: CSA Complete MODEL-DRIVEN Architecture Redesign

**Created:** 2025-12-17 (During Session 160)
**Status:** Session 160 in progress - COMMITTED to complete redesign
**Timeline:** COMPRESSED - 7 sessions, 12-15 hours total
**Priority:** CRITICAL - Architectural correctness over test count

---

## Executive Summary

**USER DIRECTIVE: Complete redesign of any flavor that is NOT MODEL-DRIVEN using Identifier classes**

CSA currently uses string manipulation patterns instead of proper object composition. Session 159 implemented features incorrectly. Session 160 began the proper wrapper pattern implementation.

**Critical Issue:** CSA at 49.83% but with WRONG architecture:
- Combined with package ≠ CombinedIdentifier (should be PackageIdentifier/BundleIdentifier)
- CAN/ prefix is wrapper not string (should be CanadianAdoptedIdentifier)
- CSA adoptions need wrapper (should be CsaAdoptedIdentifier)
- Need proper MECE class hierarchy with 8+ identifier types

**Commitment:** Complete proper MODEL-DRIVEN redesign, target 60%+

---

## Session 160 Status (In Progress)

### Completed ✅
1. WrapperIdentifier base class created
2. CanadianAdoptedIdentifier created
3. CAN/ detection in Identifier.parse
4. Recursive parsing working
5. Proof of concept validated

### Current Issues 🔧
1. Format preservation: CSA- rendering as "CSA " (need to preserve dash)
2. Reaffirmation duplication: (R2024) appearing twice
3. Lutaml::Model type casting for wrapped_identifier

### Remaining for Session 160 (~30 min)
- [ ] Fix format preservation in wrapped identifier rendering
- [ ] Fix reaffirmation extraction/duplication
- [ ] Test on 10+ CAN/ patterns
- [ ] Commit Session 160 complete

---

## SESSION 161: CsaAdoptedIdentifier (90 minutes)

### Objective
Implement CSA adoptions of ISO/IEC/CISPR standards as proper wrapper pattern.

### Architecture

**CsaAdoptedIdentifier wraps external standards:**
```ruby
# "CSA ISO/IEC TR 12785-3:15 (R2019)"
# = CsaAdoptedIdentifier wrapping IsoIecIdentifier
```

**Key difference from CanadianAdopted:**
- CanadianAdopted: CAN/{CSA standard}
- CsaAdopted: CSA {ISO/IEC/CISPR standard}

### Tasks

**Part A: Create CsaAdoptedIdentifier (30 min)**

File: `lib/pubid_new/csa/identifiers/csa_adopted.rb`

```ruby
class CsaAdopted < WrapperIdentifier
  # Wrapped identifier is ISO/IEC/CISPR/etc
  # Note: May need to parse with other flavor parsers

  def to_s
    result = "CSA #{wrapped_identifier}"
    result += " (R#{reaffirmation})" if reaffirmation
    result
  end
end
```

**Part B: Update Identifier.parse for CSA adoptions (30 min)**

Detection logic:
```ruby
if input.match?(/^CSA (ISO\/IEC|CISPR|IEC|CEI)/)
  # Parse as CSA adoption
  # Extract the wrapped standard portion
  # Parse with appropriate flavor (PubidNew::Iso, etc.)
  # Wrap in CsaAdopted
end
```

**Part C: Handle 2-digit vs 4-digit years (20 min)**

CSA adoptions use 2-digit years: `:15` not `:2015`
- Parse wrapped standard normally
- Adjust year rendering in CsaAdopted.to_s

**Part D: Testing (10 min)**

Test patterns:
- `CSA ISO/IEC TR 12785-3:15`
- `CSA ISO/IEC TR 19758:04 (R2024)`
- `CSA CISPR 16-1-1:18`

**Expected gain:** +100-150 adoption identifiers

---

## SESSION 162: PackageIdentifier + CompositeIdentifier Base (120 minutes)

### Objective
Implement proper composite pattern for package identifiers containing multiple standards plus materials.

### Architecture

**CompositeIdentifier base class:**
```ruby
class CompositeIdentifier < Lutaml::Model::Serializable
  # Collection of identifiers (not strings!)
  attribute :identifiers, :string, collection: true  # Actually objects

  def to_s
    raise NotImplementedError
  end
end
```

**PackageIdentifier for packages with materials:**
```ruby
# "CSA B149.1:25, CSA B149.2:25 & Training Package"
class PackageIdentifier < CompositeIdentifier
  attribute :identifiers, :string, collection: true
  attribute :package_items, :string, collection: true

  def to_s
    parts = identifiers.map(&:to_s)
    parts << package_items.join(" & ") if package_items.any?
    parts.join(", ")
  end
end
```

### Tasks

**Part A: Create CompositeIdentifier base (30 min)**
- File: `lib/pubid_new/csa/composite_identifier.rb`
- Inherit from Lutaml::Model::Serializable
- Define identifiers collection

**Part B: Create PackageIdentifier (40 min)**
- File: `lib/pubid_new/csa/identifiers/package.rb`
- Inherit from CompositeIdentifier
- Add package_items attribute
- Implement proper rendering

**Part C: Update Parser for package detection (30 min)**
- Detect comma + package keywords
- Parse each identifier in list
- Capture package items

**Part D: Update Builder for package construction (20 min)**
- Build each identifier separately
- Collect into PackageIdentifier
- Handle package items

**Expected gain:** +20-30 package identifiers

---

## SESSION 163: BundleIdentifier + Refine Combined (120 minutes)

### Objective
Implement BundleIdentifier for PACKAGE/Bundle keywords, distinguish from PackageIdentifier and CombinedIdentifier.

### Semantic Distinctions

**CombinedIdentifier (`/`):** Separate documents published together
- `CSA A23.1:24/CSA A23.2:24`

**PackageIdentifier (`, ` + materials):** Standards + materials bundled
- `CSA B149.1:25, CSA B149.2:25 & Training Package`

**BundleIdentifier (`PACKAGE` keyword):** Single identifier + PACKAGE
- `CSA B149.1:25 PACKAGE`
- `CSA Codebook B44:19`

### Tasks

**Part A: Create BundleIdentifier (40 min)**
- File: `lib/pubid_new/csa/identifiers/bundle.rb`
- Single base_identifier + bundle_type
- PACKAGE or Codebook keywords

**Part B: Remove package logic from Combined (30 min)**
- CombinedIdentifier should be PURE slash-separated
- No package attribute
- Clean semantic separation

**Part C: Update Parser for bundle patterns (30 min)**
- PACKAGE keyword after identifier
- Codebook patterns
- Bundle vs Package vs Combined

**Part D: Testing all three types (20 min)**
- Test Combined (pure slash)
- Test Package (comma + materials)
- Test Bundle (PACKAGE keyword)

**Expected gain:** +30-50 bundle identifiers, clean Combined

---

## SESSION 164: CanIdentifier (CAN3-) + SeriesIdentifier (120 minutes)

### Objective
Implement historical CAN3- prefix and SERIES as primary identifier type.

### CanIdentifier (CAN3- historical)

**Different from CanadianAdopted:**
- CAN3-: Historical Canadian prefix (1970s-1990s)
- CAN/: Modern Canadian adoption wrapper

**Implementation:**
```ruby
class CanIdentifier < SingleIdentifier
  # CAN3- prefix integrated into identifier
  # Not a wrapper, just a variant

  def to_s
    "CAN3-#{code}#{year_portion}..."
  end
end
```

### SeriesIdentifier

**SERIES as primary type, not attribute:**
```ruby
class SeriesIdentifier < SingleIdentifier
  attribute :series_prefix, :string  # MH, RV, etc.

  def to_s
    parts = [publisher_prefix || "CSA", code]
    parts << "#{series_prefix} SERIES" if series_prefix
    parts << "SERIES" unless series_prefix
    # ... year etc
  end
end
```

### Tasks

**Part A: CanIdentifier implementation (40 min)**
**Part B: SeriesIdentifier implementation (40 min)**
**Part C: Update Parser for both types (30 min)**
**Part D: Testing (10 min)**

**Expected gain:** +35-45 identifiers

---

## SESSION 165: Comprehensive Testing (90 minutes)

### Objective
Test all 8+ identifier classes, ensure MECE, validate round-trip fidelity.

### Identifier Classes to Test

1. **Standard** - Basic CSA standard
2. **CanadianAdopted** - CAN/{identifier} wrapper
3. **CsaAdopted** - CSA {ISO/IEC/etc} wrapper
4. **CombinedIdentifier** - Slash-separated
5. **PackageIdentifier** - Comma + materials
6. **BundleIdentifier** - PACKAGE keyword
7. **CanIdentifier** - CAN3- historical
8. **SeriesIdentifier** - SERIES primary type

### Tasks

**Part A: Unit tests for each class (50 min)**
- Create spec file for each
- Test parsing
- Test rendering
- Test round-trip

**Part B: Integration testing (20 min)**
- Test recursive wrapping
- Test package composition
- Test combined continuations

**Part C: Regression testing (20 min)**
- Run full classification
- Document current pass rate
- Identify any regressions

**Expected:** 300-400 tests, 55-65% pass rate

---

## SESSION 166: 60%+ Achievement Enhancement (90 minutes)

### Objective
Targeted enhancements to reach 60%+ validation rate.

### Strategy

Based on Session 165 results, identify top remaining patterns and implement quick wins.

### Likely Patterns

1. **Amendment/Corrigendum supplements** (~30 IDs)
2. **Complex NO. patterns** (~20 IDs)
3. **Edge cases in year formats** (~15 IDs)
4. **Specialized codes** (~10 IDs)

### Tasks

**Part A: Failure analysis (15 min)**
- Analyze fail/*.txt
- Group by pattern
- Prioritize by count

**Part B: Implement top 3 patterns (60 min)**
- 20 min per pattern
- Parser + Builder updates
- Test immediately

**Part C: Final validation (15 min)**
- Run classification
- Verify 60%+ achieved
- Document final status

**Target:** CSA 540+/899 (60%+)

---

## SESSION 167: Complete Documentation (60 minutes)

### Objective
Update all documentation, archive session docs, mark CSA complete.

### Tasks

**Part A: Update README.adoc (25 min)**

Add CSA architecture section:
```asciidoc
==== CSA (Canadian Standards Association)
- Status: ✅ 540+/899 (60%+)
- Architecture: Complete V2 with wrapper and composite patterns

.CSA Identifier Classes (MECE)
1. Standard - Basic CSA standards
2. CanadianAdopted - CAN/{identifier} wrapper
3. CsaAdopted - CSA {ISO/IEC/CISPR} wrapper
4. CombinedIdentifier - Slash-separated (/)
5. PackageIdentifier - Comma + materials
6. BundleIdentifier - PACKAGE keyword
7. CanIdentifier - CAN3- historical
8. SeriesIdentifier - SERIES primary type

.Wrapper Pattern ✨
CSA implements proper object composition for adoptions...

.Composite Pattern ✨
CSA implements proper collections for packages...
```

**Part B: Archive session docs (15 min)**
- Move SESSION-159 docs to old-docs/
- Move SESSION-160 docs to old-docs/
- Create session summaries

**Part C: Update memory bank (20 min)**
- Update context.md with Sessions 160-167
- Mark CSA redesign COMPLETE
- Document final architecture

---

## Implementation Status Tracker

| Session | Focus | Duration | Status | Deliverables |
|---------|-------|----------|--------|--------------|
| 160 | Wrapper base + CanadianAdopted | 90 min | 🔧 In Progress | Base classes |
| 161 | CsaAdoptedIdentifier | 90 min | ⏳ Pending | ISO/IEC adoptions |
| 162 | PackageIdentifier + Composite | 120 min | ⏳ Pending | Package pattern |
| 163 | BundleIdentifier + Combined | 120 min | ⏳ Pending | MECE separation |
| 164 | Can + Series Identifiers | 120 min | ⏳ Pending | Historical + Series |
| 165 | Comprehensive Testing | 90 min | ⏳ Pending | 300+ tests |
| 166 | 60%+ Enhancement | 90 min | ⏳ Pending | Target achievement |
| 167 | Documentation | 60 min | ⏳ Pending | Complete docs |
| **Total** | **Complete redesign** | **12-15 hours** | **COMMITTED** | **Production ready** |

---

## Success Criteria

### Architectural (CRITICAL)
- ✅ Wrapper pattern for adoptions (CAN/, CSA ISO/IEC)
- ✅ Composite pattern for packages/bundles
- ✅ MECE class hierarchy (8+ types)
- ✅ Recursive identifier parsing
- ✅ Proper object composition, not string manipulation
- ✅ Lutaml::Model throughout

### Functional
- ✅ CSA at 60%+ (540+/899)
- ✅ All wrapper identifiers working
- ✅ All composite identifiers working
- ✅ Round-trip fidelity maintained
- ✅ Zero architectural compromises

---

## Key Architectural Principles

**NEVER COMPROMISE ON:**

1. **MODEL-DRIVEN** - Objects not strings
2. **Wrapper Pattern** - Adoptions wrap other identifiers
3. **Composite Pattern** - Packages/bundles contain identifiers
4. **Recursive Parsing** - Wrapped identifiers fully parsed
5. **MECE** - Each identifier type mutually exclusive
6. **Semantic Correctness** - Architecture > test count

**NEVER DO:**
- Treat wrappers as string prefixes
- Confuse package/bundle/combined semantics
- Skip wrapper pattern for "simplicity"
- Compromise architecture for quick wins
- Use hash-based type maps
- Use string manipulation over object composition

---

## Files to Create (Total: ~15 new files)

### Wrapper Infrastructure
1. `lib/pubid_new/csa/wrapper_identifier.rb` ✅
2. `lib/pubid_new/csa/identifiers/canadian_adopted.rb` ✅
3. `lib/pubid_new/csa/identifiers/csa_adopted.rb`

### Composite Infrastructure
4. `lib/pubid_new/csa/composite_identifier.rb`
5. `lib/pubid_new/csa/identifiers/package.rb`
6. `lib/pubid_new/csa/identifiers/bundle.rb`

### Historical/Series
7. `lib/pubid_new/csa/identifiers/can.rb`
8. `lib/pubid_new/csa/identifiers/series.rb`

### Test Files
9-15. Spec files for each new identifier class

---

## Next Immediate Steps (Complete Session 160)

1. Fix format preservation in CanadianAdopted
2. Fix reaffirmation duplication
3. Test on 10+ CAN/ patterns
4. Commit Session 160
5. Begin Session 161

---

**Created:** 2025-12-17
**Status:** COMMITTED to complete redesign
**Timeline:** 12-15 hours compressed
**Target:** CSA 60%+ with proper MODEL-DRIVEN architecture

**End Goal:** Production-ready CSA with perfect architecture! 🎯