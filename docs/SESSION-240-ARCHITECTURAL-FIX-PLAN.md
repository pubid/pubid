# Session 240+ Architectural Fix Plan: CCSDS, ETSI, PLATEAU MECE Separation

**Created:** 2025-12-31
**Critical Issue:** Current V2 implementations violate MECE principles
**Timeline:** COMPRESSED - Fix in 6-8 sessions (12-16 hours)

---

## CRITICAL ARCHITECTURAL VIOLATION

**Session 239 exposed fundamental architectural problems in 3 V2 implementations:**

### ❌ CCSDS - Corrigenda Conflation
**Current (WRONG):**
- Single `Base` class with `corrigenda` attribute
- Violates MECE: Base document and Corrigendum are different types

**Required (CORRECT):**
- `Base` class for base documents
- `Corrigendum` class extending SupplementIdentifier
- Recursive: Corrigendum wraps Base as `base_identifier`

### ❌ ETSI - Amendments/Corrigenda Conflation
**Current (WRONG):**
- Single `Base` class with `amendments` and `corrigenda` attributes
- Violates MECE: Base, Amendment, Corrigendum are different types

**Required (CORRECT):**
- `Base` class for base documents (EN, ETR, GS, etc.)
- `Amendment` class extending SupplementIdentifier
- `Corrigendum` class extending SupplementIdentifier
- Recursive: Supplements wrap Base as `base_identifier`

### ❌ PLATEAU - Type Conflation
**Current (WRONG):**
- Single `Scheme` class with `type` attribute ("Handbook" or "Technical Report")
- Violates MECE: Handbook and TechnicalReport are different document types

**Required (CORRECT):**
- Base identifier class
- `Handbook` class extending Base
- `TechnicalReport` class extending Base
- Each type has its own class and rendering logic

---

## ROOT CAUSE ANALYSIS

**Why this happened:**
1. Implementers took shortcuts to "get tests passing"
2. Copied V1 anti-patterns instead of following V2 MECE architecture
3. Didn't follow ISO/IEC/IEEE reference implementations
4. Prioritized test count over architectural correctness

**Why this matters:**
1. **Extensibility:** Can't add new document types cleanly
2. **Maintainability:** Logic scattered in conditionals instead of classes
3. **MECE violation:** Each identifier should be EXACTLY ONE type
4. **V2 principles:** Objects should represent semantic types, not data containers

---

## SESSIONS 240-241: CCSDS Architectural Fix (4 hours)

### Session 240: CCSDS Corrigendum Class (2 hours)

**Objective:** Implement proper Corrigendum class following ISO/IEC pattern

**Part A: Create Corrigendum Class (60 min)**

File: `lib/pubid_new/ccsds/identifiers/corrigendum.rb`

```ruby
module PubidNew
  module Ccsds
    module Identifiers
      class Corrigendum < SupplementIdentifier
        attribute :number, :integer
        attribute :base_identifier, Base

        def to_s
          "#{base_identifier} Cor. #{number}"
        end
      end
    end
  end
end
```

**Part B: Update Parser (30 min)**

File: `lib/pubid_new/ccsds/parser.rb`

Separate rules:
- `base_identifier` - Base documents only
- `corrigendum_identifier` - Cor. patterns
- Route correctly in main identifier rule

**Part C: Update Builder (30 min)**

File: `lib/pubid_new/ccsds/builder.rb`

```ruby
def build(data)
  if data[:corrigenda]
    # Build Corrigendum with recursive base parsing
    build_corrigendum(data)
  else
    # Build Base
    build_base(data)
  end
end

def build_corrigendum(data)
  # Extract corrigendum number
  corr_data = data[:corrigenda].is_a?(Array) ? data[:corrigenda].first : data[:corrigenda]

  # Build base identifier recursively
  base_data = data.reject { |k| k == :corrigenda }
  base = build_base(base_data)

  Identifiers::Corrigendum.new(
    number: corr_data[:cor_number].to_i,
    base_identifier: base
  )
end
```

### Session 241: CCSDS Testing & Validation (2 hours)

**Part A: Update Specs (60 min)**

Update `spec/pubid_new/ccsds/identifier_spec.rb`:
- Corrigendum tests expect `Identifiers::Corrigendum` class
- Verify `base_identifier` attribute
- Test recursive structure

**Part B: Comprehensive Testing (60 min)**

```bash
bundle exec rspec spec/pubid_new/ccsds/
```

Fix any issues, ensure all tests pass.

---

## SESSIONS 242-243: ETSI Architectural Fix (4 hours)

### Session 242: ETSI Supplement Classes (2 hours)

**Objective:** Implement Amendment and Corrigendum classes

**Part A: Create Amendment Class (45 min)**

File: `lib/pubid_new/etsi/identifiers/amendment.rb`

```ruby
module PubidNew
  module Etsi
    module Identifiers
      class Amendment < SupplementIdentifier
        attribute :number, :integer
        attribute :base_identifier, Base

        def to_s
          "#{base_identifier}/A#{number}"
        end
      end
    end
  end
end
```

**Part B: Create Corrigendum Class (45 min)**

File: `lib/pubid_new/etsi/identifiers/corrigendum.rb`

```ruby
module PubidNew
  module Etsi
    module Identifiers
      class Corrigendum < SupplementIdentifier
        attribute :number, :integer
        attribute :base_identifier, Base

        def to_s
          "#{base_identifier}/C#{number}"
        end
      end
    end
  end
end
```

**Part C: Update Parser & Builder (30 min)**

Separate supplement patterns from base patterns.

### Session 243: ETSI Testing & Validation (2 hours)

Update specs and comprehensive testing.

---

## SESSIONS 244-245: PLATEAU Architectural Fix (4 hours)

### Session 244: PLATEAU Type Classes (2 hours)

**Objective:** Implement Handbook and TechnicalReport classes

**Part A: Create Base Class (30 min)**

File: `lib/pubid_new/plateau/identifiers/base.rb`

```ruby
module PubidNew
  module Plateau
    module Identifiers
      class Base < Lutaml::Model::Serializable
        attribute :number, :integer
        attribute :annex, :integer
        attribute :edition, :string

        def publisher
          "PLATEAU"
        end

        def type_string
          # Override in subclasses
          raise NotImplementedError
        end

        def to_s
          result = "#{publisher} #{type_string} #{formatted_number}"
          result += "-#{annex}" if annex
          result += " #{formatted_edition}" if edition
          result
        end

        private

        def formatted_number
          "#%02d" % number
        end

        def formatted_edition
          "第#{edition}版"
        end
      end
    end
  end
end
```

**Part B: Create Handbook Class (30 min)**

File: `lib/pubid_new/plateau/identifiers/handbook.rb`

```ruby
module PubidNew
  module Plateau
    module Identifiers
      class Handbook < Base
        def type_string
          "Handbook"
        end
      end
    end
  end
end
```

**Part C: Create TechnicalReport Class (30 min)**

File: `lib/pubid_new/plateau/identifiers/technical_report.rb`

```ruby
module PubidNew
  module Plateau
    module Identifiers
      class TechnicalReport < Base
        def type_string
          "Technical Report"
        end
      end
    end
  end
end
```

**Part D: Update Parser & Builder (30 min)**

Route to correct class based on document type.

### Session 245: PLATEAU Testing & Validation (2 hours)

Update specs and comprehensive testing.

---

## SESSIONS 246-247: JIS & NIST Review (4 hours)

### Objective
Verify JIS and NIST don't have same architectural violations.

**Session 246: JIS Architecture Review (2 hours)**

Check if JIS properly separates identifier types:
- Read implementation
- Verify MECE compliance
- Fix if needed

**Session 247: NIST Architecture Review (2 hours)**

Check if NIST properly separates series types:
- Read implementation
- Verify each series is a class
- Fix if needed

---

## SUCCESS CRITERIA

### Architectural Correctness (MANDATORY)
- ✅ Each document type is a separate class
- ✅ No type conflation via attributes
- ✅ Supplements extend SupplementIdentifier
- ✅ Recursive base_identifier pattern
- ✅ MECE organization validated

### Testing (MANDATORY)
- ✅ All specs updated to expect correct classes
- ✅ No regression in test count
- ✅ Round-trip fidelity maintained
- ✅ Component tests for each class

### Documentation (REQUIRED)
- ✅ Architecture violations documented
- ✅ Fixes documented in commit messages
- ✅ Memory bank updated
- ✅ Continuation plans for remaining work

---

## Implementation Status Tracker

| Session | Flavor | Task | Files | Est. Time | Status |
|---------|--------|------|-------|-----------|--------|
| 240 | CCSDS | Corrigendum class | 3 files | 2 hours | ⏳ Pending |
| 241 | CCSDS | Testing | specs | 2 hours | ⏳ Pending |
| 242 | ETSI | Amendment/Corrigendum | 4 files | 2 hours | ⏳ Pending |
| 243 | ETSI | Testing | specs | 2 hours | ⏳ Pending |
| 244 | PLATEAU | Type classes | 4 files | 2 hours | ⏳ Pending |
| 245 | PLATEAU | Testing | specs | 2 hours | ⏳ Pending |
| 246 | JIS | Review/fix | TBD | 2 hours | ⏳ Pending |
| 247 | NIST | Review/fix | TBD | 2 hours | ⏳ Pending |

**Total:** 16 hours

---

## Key Principles (NEVER VIOLATE)

1. **MECE:** Each identifier is EXACTLY ONE type
2. **Separate classes:** Each document type gets its own class
3. **SupplementIdentifier:** Amendments, Corrigenda extend this
4. **Recursive base:** Supplements wrap base via `base_identifier`
5. **No type attributes:** Type determined by class, not attribute
6. **Follow ISO/IEC pattern:** They are the reference implementation

---

## Reference Implementations

**Study these for correct architecture:**

1. **ISO Supplements:**
   - `lib/pubid_new/iso/identifiers/amendment.rb`
   - `lib/pubid_new/iso/identifiers/corrigendum.rb`
   - `lib/pubid_new/iso/supplement_identifier.rb`

2. **ISO Base Types:**
   - `lib/pubid_new/iso/identifiers/international_standard.rb`
   - `lib/pubid_new/iso/identifiers/guide.rb`
   - Each type is a separate class

3. **IEC Pattern:**
   - Same as ISO but adapted for IEC specifics
   - Each type separated

---

## Next Immediate Steps (Session 240)

1. Read this architectural fix plan
2. Read ISO/IEC supplement implementations
3. Implement CCSDS Corrigendum class
4. Update CCSDS Parser to separate base/corrigendum
5. Update CCSDS Builder for recursive construction
6. Test and validate
7. Commit with clear message about architectural fix

---

**Created:** 2025-12-31
**Priority:** CRITICAL - Architectural correctness
**Sessions:** 240-247
**Status:** Ready for execution

**IMPORTANT:** Tests passing is NOT success if architecture is wrong. Fix architecture FIRST, then update tests to expect correct structure.