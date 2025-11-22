# PubID v2 Continuation Plan

## Project Status Overview

### Current Work: PR #19 "PubID v2: New implementation native to lutaml-model"

**Branch:** `rt-new-lutaml-model`
**Status:** Open, in progress
**Scale:** 26,165 additions, 191 deletions, 150 files changed
**PR Link:** https://github.com/metanorma/pubid/pull/19

### What's Working

- ✅ **ISO flavor**: Almost fully functional (minor Directives issue)
- ✅ **IDF flavor**: Fully functional
- ✅ **Core architecture**: Complete lutaml-model migration in `lib/pubid_new/`
- ✅ **Component system**: All base components implemented
- ✅ **Joint identifiers** (`|`): Via `CombinedIdentifier`
- ✅ **Supplement identifiers** (`/`): Via `SupplementIdentifier`
- ✅ **Copublishers**: RFC 5141 requirement met
- ✅ **IWA document type**: Implemented
- ✅ **Supplement of supplements**: Corrigendum of amendment supported

### What's Pending

- ❌ **Combined document operator** (`+`): NOT YET IMPLEMENTED for `EN 10077-1:2006+AC:2009+AC2:2009`
- ⏳ **ISO completion**: Dual-published SAE documents, Directives fixes
- ⏳ **Other flavors**: IEC, ITU-T, IEEE, NIST, CEN, BSI, CCSDS, ETSI, JIS, PLATEAU

---

## PubID v2 Architecture

### Component-Based Design

Located in `lib/pubid_new/components/`:

```
Code         - number, part, subpart values
Date         - year, month, day
Edition      - edition year and number
Language     - ISO 639-1 two-letter codes
Locality     - "all parts" handling
Publisher    - organization body
Stage        - publication stage info
Type         - document type info
TypedStage   - combined type+stage semantics
```

### Identifier Hierarchy

```
Identifier (base class, lutaml-model)
├── SingleIdentifier        # Base documents
│   ├── InternationalStandard
│   ├── TechnicalReport
│   ├── TechnicalSpecification
│   ├── PAS
│   ├── Guide
│   ├── Directives
│   ├── Data
│   ├── IWA
│   └── ...
├── SupplementIdentifier    # Supplements (/)
│   ├── Amendment
│   ├── Corrigendum
│   ├── Addendum
│   ├── DirectivesSupplement
│   ├── Extract
│   └── Supplement
└── CombinedIdentifier      # Joint/Dual (|)
    └── (contains base + additional identifiers)
```

### Scheme Architecture

`PubidNew::Scheme` provides:
- Registry of identifier types per flavor
- Typed stages lookup by abbreviation
- Identifier class resolution by type code
- Centralized configuration

### Parser/Builder Pattern

**Parser** (Parslet-based):
- Flavor-specific grammar rules
- Common parse rules shared via mixins
- Dash character normalization

**Builder**:
- Converts parsed hash to identifier objects
- Component casting and instantiation
- Recursive building for nested structures

---

## The Three Operators (PubID Algebra)

### 1. Supplement Operator (`/`) - ✅ IMPLEMENTED

**Semantic:** Document is a supplement to another document

**Examples:**
```
EN 10077-1:2006/AC:2009
ISO 8601-1:2019/Amd 1:2024
ISO/IEC Guide 98-3:2008/Suppl 1:2008/Cor 1:2009
```

**Implementation:** `SupplementIdentifier` class with `base_identifier` attribute

**Structure:**
```ruby
SupplementIdentifier
  base_identifier: Identifier (the base)
  typed_stage: TypedStage (AMD, COR, etc.)
  number, date, languages, etc.
```

### 2. Dual-Published Operator (`|`) - ✅ IMPLEMENTED

**Semantic:** Document published by multiple organizations

**Examples:**
```
ISO 5537|IDF 26
ISO 17678|IDF 202:2010
ISO/TS 4985:2023 | IDF/RM 255
ISO 4214:2022 | IDF 254:2022
```

**Implementation:** `CombinedIdentifier` class

**Structure:**
```ruby
CombinedIdentifier
  base_identifier: Identifier (first publisher)
  additional_identifiers: [Identifier] (other publishers)
```

### 3. Combined Document Operator (`+`) - ✅ IMPLEMENTED

**Semantic:** Multiple documents combined (base + amendments/corrigenda)

**Examples:**
```
ISO/IEC DIR 1 + IEC SUP:2016-05
ISO/IEC DIR 1:2022 + IEC SUP:2022
EN 10077-1:2006+AC:2009+AC2:2009  (CEN - to be migrated)
```

**Implementation:** New [`BundledIdentifier`](lib/pubid_new/bundled_identifier.rb) class

**Structure:**
```ruby
BundledIdentifier < Identifier
  base_document: Identifier (polymorphic)
  supplements: [Identifier] (polymorphic collection)
  
  # Delegates to base_document: publisher, copublishers, number, date, type, stage, typed_stage
  
  def to_s
    "#{base_document} + #{supplements.join(' + ')}"
  end
```

**Status:**
- ✅ Core class implemented
- ✅ ISO Directives bundled identifiers working
- ✅ Parser rules added to [`lib/pubid_new/iso/parser.rb:297`](lib/pubid_new/iso/parser.rb:297)
- ✅ Builder support in [`lib/pubid_new/iso/builder.rb:35,238`](lib/pubid_new/iso/builder.rb:35)
- ✅ All Directives tests passing (114/114)
- ⏳ CEN migration needed for EN identifiers

---

## Remaining Work Detail

### Phase 1: Complete ISO Implementation

#### 1.1 Fix Directives Handling ✅ COMPLETED

**Issue:** "whacky handling for Directives" per PR description - was excessive debug output

**Resolution:**
- Removed debug `puts` statements from [`lib/pubid_new/iso/builder.rb`](lib/pubid_new/iso/builder.rb)
- Removed debug output from [`lib/pubid_new/scheme.rb`](lib/pubid_new/scheme.rb:51)
- All 114 tests pass cleanly

**Directives Special Handling:**

The Directives identifier has unique parsing rules in [`lib/pubid_new/iso/parser.rb`](lib/pubid_new/iso/parser.rb:240-309):

1. **Organization-specific variants:** `ISO/IEC DIR 2 ISO` or `ISO/IEC DIR 2 IEC`
   - The trailing organization (`ISO` or `IEC`) is treated as a "part" of the number
   - Parsed via `directives_part_and_subpart` rule (line 263)

2. **JTC subgroups:** `ISO/IEC JTC 1 DIR`
   - The `JTC 1` is captured as a `subgroup` component
   - Stored in the [`subgroup`](lib/pubid_new/iso/identifiers/directives.rb:9) attribute

3. **Directives supplements:** `ISO/IEC DIR 1 ISO SUP:2022`
   - Uses [`DirectivesSupplement`](lib/pubid_new/iso/identifiers/directives_supplement.rb:7) class
   - Has its own typed stages (line 10-19)

4. **Combined bundles (NOT YET IMPLEMENTED):** `ISO/IEC DIR 1 + IEC SUP:2016-05`
   - Tests are skipped with `xcontext` (line 492, 537)
   - Awaits implementation of `+` operator

**Test cases verified:**
```
✅ ISO/IEC DIR 1
✅ ISO/IEC DIR 2 ISO:2022
✅ ISO/IEC DIR JTC 1 SUP:2005
❌ ISO/IEC DIR 1 + IEC SUP:2016-05 (needs + operator)
```

#### 1.2 Handle Dual-Published SAE Documents ✅ COMPLETED

**Requirement:** Parse SAE as copublisher in ISO identifiers

**Examples:**
```
ISO/SAE PAS 22736:2021
```

**Implementation:** SAE already supported via copublisher mechanism
- SAE is in `ORGANIZATIONS` list at [`lib/pubid_new/iso/parser.rb:42`](lib/pubid_new/iso/parser.rb:42)
- Parses as: `{publisher: "ISO", copublishers: [{copublisher: "SAE"}]}`
- Renders correctly as: `ISO/SAE PAS 22736:2021`
- No separate SAE module needed (unlike IDF which has dual identifiers)

#### 1.3 Validate Against Test Data
- Run against 7,171 identifiers in `TODO.TMP.md`
- Run corrigendum tests from `TODO.TMP2.md` (147 test cases)
- Measure pass rate and fix failures

### Phase 2: Complete Other Flavors

#### 2.1 IEC Flavor
**Current state:** Uses old architecture with `attr_accessor`
**Target:** Migrate to `attribute` with lutaml-model
**Files:** `gems/pubid-iec/lib/pubid/iec/identifier/*.rb`

#### 2.2 ITU-T Flavor
**Challenge:** Handle dual identifiers with ISO/IEC
**Examples:** ITU-T documents can be co-published with ISO/IEC

#### 2.3 IEEE Flavor  
**Challenge:** Multiple dual identifier types
- ISO/IEC + IEEE
- ANSI + IEEE
- AIEE (legacy IEEE precursor)

**Examples:**
```
ISO/IEC/IEEE 8802-1AR
```

#### 2.4 NIST Flavor
**Challenge:** Dual identifiers with ANSI
**Note:** NIST has complex attributes (see `lib/pubid_new/iso/builder.rb:23-41`)

#### 2.5 Other Flavors
**List:** CEN, BSI, CCSDS, ETSI, JIS, PLATEAU
**Approach:** Follow ISO/IDF pattern, adapt as needed

### Phase 3: Implement Combined Bundle Operator (+)

#### 3.1 Design Decision
**Options:**
1. Extend `CombinedIdentifier` to handle both `|` and `+`
2. Create new `BundledIdentifier` class
3. Use CEN's existing `CombinedBundle` pattern

**Recommendation:** Generalize CEN's `CombinedBundle` to `pubid-core`

#### 3.2 Implementation Strategy
```ruby
# In lib/pubid_new/bundled_identifier.rb
class BundledIdentifier < Identifier
  attribute :base_document, Identifier, polymorphic: true
  attribute :amendments, Identifier, polymorphic: true, collection: true
  attribute :corrigendums, Identifier, polymorphic: true, collection: true
  
  def to_s
    [base_document, amendments, corrigendums]
      .flatten.compact.join('+')
  end
end
```

#### 3.3 Parser Extensions
Add `+` operator parsing to each flavor's parser:
```parslet
rule(:bundled_identifier) do
  identifier.as(:base) >>
    (str('+') >> identifier.as(:supplement)).repeat
end
```

### Phase 4: RFC 5141 Completion

According to `rfc-5141-missing-items.adoc`:

- ✅ Copublishers - already implemented
- ✅ Corr of amd - supported via supplements of supplements
- ✅ Supplement types - guide, directive, directive supplement all implemented
- ⚠️ Stage of base identifier - partially implemented (needs validation)
- ❌ New stages: WDS, CDTS - not yet added
- ✅ New doc types: IWA - implemented

#### 4.1 Add WDS and CDTS Stages
**WDS:** Working Draft Standard
**CDTS:** Committee Draft Technical Specification

Add to appropriate identifier type's `TYPED_STAGES` constant.

### Phase 5: Documentation & Quality

#### 5.1 Create Grammar Definition DSL
**File:** `pubid-lang.adoc`
**Purpose:** Formal specification of identifier grammar
**Content:** BNF or EBNF-style grammar for each operator

#### 5.2 Update README Files
Update each gem's README.adoc with:
- New architecture explanation
- Component descriptions
- Algebra operator usage
- Migration guide from v1

#### 5.3 Security Findings
From PR review comments:
1. **Polynomial regex** in `lib/pubid_new/idf/builder.rb:137` and `lib/pubid_new/iso/builder.rb`
2. **Missing permissions** in `.github/workflows/monorepo-per-gem-release.yml`

---

## Testing Strategy

### Unit Tests
- Component-level tests for each `Components::*` class
- Identifier-level tests for each identifier type
- Parser tests for grammar rules
- Builder tests for component casting

### Integration Tests
- Cross-flavor compatibility
- Round-trip parsing (parse → build → to_s → parse)
- Algebra operations (+ / |)
- Legacy identifier compatibility

### Validation Tests
- 7,171 ISO identifiers from `TODO.TMP.md`
- 147 corrigendum cases from `TODO.TMP2.md`
- Flavor-specific test fixtures

---

## Implementation Priority Order

Based on PR #19 description and dependencies:

1. **Complete ISO** (foundation for others)
2. **Complete IDF** (already done)
3. **Complete IEC** (needed by CEN, BSI)
4. **Complete ITU-T** (dual with ISO/IEC)
5. **Complete IEEE** (dual with ISO/IEC, ANSI)
6. **Complete NIST** (dual with ANSI)
7. **Complete CEN** (depends on ISO, IEC)
8. **Complete BSI** (depends on CEN, NIST, ISO, IEC)
9. **Complete remaining** (CCSDS, ETSI, JIS, PLATEAU)

---

## Key Files Reference

### Core Implementation
- `lib/pubid_new.rb` - Main entry point
- `lib/pubid_new/identifier.rb` - Base identifier class
- `lib/pubid_new/scheme.rb` - Scheme registry
- `lib/pubid_new/components/*.rb` - Component classes

### ISO Implementation
- `lib/pubid_new/iso.rb` - ISO module setup
- `lib/pubid_new/iso/parser.rb` - ISO parser (390 lines)
- `lib/pubid_new/iso/builder.rb` - ISO builder (256 lines)
- `lib/pubid_new/iso/identifier.rb` - ISO base
- `lib/pubid_new/iso/single_identifier.rb` - Base documents
- `lib/pubid_new/iso/supplement_identifier.rb` - Supplements (/)
- `lib/pubid_new/iso/combined_identifier.rb` - Dual published (|)
- `lib/pubid_new/iso/identifiers/*.rb` - Specific types

### IDF Implementation  
- `lib/pubid_new/idf.rb` - IDF module setup
- `lib/pubid_new/idf/parser.rb` - IDF parser
- `lib/pubid_new/idf/builder.rb` - IDF builder
- `lib/pubid_new/idf/identifier.rb` - IDF base
- `lib/pubid_new/idf/identifiers/*.rb` - Specific types

### Test Fixtures
- `spec/fixtures/idf/*.txt` - IDF test data
- `TODO.TMP.md` - 7,171 ISO identifier test cases
- `TODO.TMP2.md` - 147 corrigendum test cases

---

## Next Steps Prompt for Continuation

```
Continue working on PubID v2 (PR #19: https://github.com/metanorma/pubid/pull/19).

Current status:
- ISO flavor: 95% complete (Directives issue remains)
- IDF flavor: 100% complete
- Other flavors: Need migration to lutaml-model

Priority tasks:
1. Fix ISO Directives handling
2. Implement combined bundle operator (+) for identifiers like "EN 10077-1:2006+AC:2009+AC2:2009"
3. Complete IEC flavor migration
4. Add SAE dual-published document support
5. Run validation tests against TODO.TMP.md (7,171 cases) and TODO.TMP2.md (147 cases)

The new architecture uses:
- lutaml-model for all identifiers
- Component-based design (Code, Date, Edition, Language, Publisher, etc.)
- Three identifier types: SingleIdentifier (base), SupplementIdentifier (/), CombinedIdentifier (|)
- Scheme-based registry for type/stage resolution

Reference docs/pubid-v2-continuation-plan.md for complete details.

Please help prioritize and implement the remaining work.
```

---

## Technical Debt & Improvements

### Issues to Address

1. **Debug Output Removal**
   - Remove `puts` statements from builders
   - Use proper logging framework

2. **Security Findings**
   - Fix polynomial regex in builders
   - Add workflow permissions

3. **Error Handling**
   - Consistent error types across flavors
   - Better error messages for users

4. **Performance**
   - Optimize typed stage lookups
   - Cache scheme lookups

5. **Code Quality**
   - Remove commented code
   - Improve documentation
   - Add type annotations

---

## Resources

### Documentation Read
- `README.adoc` - Monorepo structure and development workflow
- `implementation-notes.md` - Original algebra requirements
- `rfc-5141-missing-items.adoc` - RFC compliance checklist
- `CODE_OF_CONDUCT.md` - Contributor guidelines
- `TODO.TMP.md` - 7,171 ISO identifier test cases
- `TODO.TMP2.md` - 147 corrigendum test cases

### Related Files
- `Rakefile` - Monorepo management tasks
- `VERSION` - Synchronized version (1.15.0)
- `Gemfile` - Root dependencies
- `.rubocop.yml` - Code style rules

---

## Success Criteria

### Definition of Done for PubID v2

1. ✅ All three operators implemented and tested:
   - `/` (supplement) ✅
   - `|` (dual-published) ✅  
   - `+` (combined bundle) ❌

2. ⏳ All flavors migrated:
   - ISO ✅ (95%)
   - IDF ✅
   - IEC, ITU-T, IEEE, NIST, CEN, BSI, others ❌

3. ❌ All RFC 5141 items addressed

4. ❌ All tests passing:
   - Unit tests per gem
   - Integration tests
   - Validation against fixtures

5. ❌ Documentation complete:
   - Grammar DSL
   - Architecture guide
   - Migration guide
   - API documentation

6. ❌ Security issues resolved

7. ❌ PR #19 ready for merge

---

## Additional Notes

### CEN Combined Bundle Reference

CEN already has a working implementation of the `+` operator:

**Files:**
- `gems/pubid-cen/lib/pubid/cen/identifier/combined_bundle.rb`
- `gems/pubid-cen/renderer/combined_bundle.rb`

**Pattern to follow:**
```ruby
class CombinedBundle < Base
  attribute :base_document, :string
  attribute :amendments, :string, collection: true
  attribute :corrigendums, :string, collection: true
  
  def to_s
    result = base_document.to_s
    amendments.each { |amd| result += "+#{amd}" }
    corrigendums.each { |cor| result += "+#{cor}" }
    result
  end
end
```

This should be generalized and moved to `pubid-core` for all flavors.

### Lutaml-Model Benefits

The migration to lutaml-model provides:
- Type safety for attributes
- Automatic serialization/deserialization
- Validation support
- Collection handling
- Polymorphic attributes
- Default values
- Better documentation through schema

### Parslet Usage

All parsers must use Parslet (no regex or string matching) per `implementation-notes.md:21`.

Current parsers use:
- `include CommonParseRules` for shared rules
- `include CommonParseMethods` for helper methods
- Flavor-specific rules in each parser

---

## Questions for Consideration

1. **Should `+` operator be generalized or flavor-specific?**
   - CEN has it, but other flavors may need it too
   - Consider moving to pubid-core

2. **How to handle operator precedence?**
   - `ISO/IEC 13818-1:2015/Amd 3:2016/Cor 1:2017` - supplement of supplement
   - `EN 10077-1:2006+AC:2009+AC2:2009` - combined bundle
   - `ISO 4214:2022 | IDF 254:2022` - dual published

3. **Ruby operator overloading:**
   Should we support: `identifier + amendment`, `identifier / supplement`, `identifier | other_identifier`?

4. **Testing strategy:**
   Run all tests incrementally per flavor or wait until multiple flavors complete?

---

## Completion Checklist

Use this to track progress on PR #19:

### ISO Flavor
- [x] Basic structure
- [x] Component migration
- [x] Parser implementation
- [x] Builder implementation
- [x] SingleIdentifier
- [x] SupplementIdentifier
- [x] CombinedIdentifier
- [ ] Directives fixes
- [ ] SAE dual-published
- [ ] All test cases pass

### IDF Flavor
- [x] Complete implementation
- [x] Test fixtures
- [x] All tests pass

### IEC Flavor
- [ ] Migrate to lutaml-model
- [ ] Update parsers
- [ ] Test migration

### Other Flavors (each)
- [ ] Architecture analysis
- [ ] Migration plan
- [ ] Implementation
- [ ] Testing
- [ ] Documentation

### Operators
- [x] Supplement (`/`)
- [x] Dual-published (`|`)
- [ ] Combined bundle (`+`)

### Quality & Docs
- [ ] Grammar DSL written
- [ ] Architecture documented
- [ ] Migration guide created
- [ ] Security issues fixed
- [ ] All tests green
- [ ] PR ready for review

---

*Document created: 2025-11-14*
*Last updated: 2025-11-14*
*Status: Active development on PR #19*