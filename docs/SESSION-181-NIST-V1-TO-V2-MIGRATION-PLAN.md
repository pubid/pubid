# Session 181+ NIST V1 to V2 Migration Plan

**Created:** 2025-12-22
**Status:** Phase 1 - Ready to Begin
**Timeline:** COMPRESSED - 6 phases across 4-6 sessions (8-12 hours total)
**Priority:** CRITICAL - Restore NIST to 100% feature parity with V1

---

## Executive Summary

**Current Problem:**
- NIST V2 implementation broke critical V1 features
- Lost Stage system (fpd, ipd, pd with id+type)
- Lost Translation support (3-letter language codes)
- Lost Supplement as separate attribute
- Lost Format tracking (mr/short/long/abbrev)
- Lost multiple render formats

**Solution:**
Properly migrate NIST V1 to V2 by:
1. Reading and documenting all V1 features
2. Creating V2 Lutaml::Model components for V1 concepts
3. Porting V1 parser patterns with V2 architecture
4. Implementing V1 rendering with V2 components
5. Testing against all V1 specs
6. Achieving 100% feature parity

---

## Phase 1: V1 Feature Documentation (2 hours)

### Objective
Thoroughly understand and document all V1 features, patterns, and architecture.

### Tasks

#### 1.1: Read Core V1 Files (30 min)
```bash
# Read all V1 implementation files
archived-gems/pubid-nist/lib/pubid/nist/identifier/base.rb
archived-gems/pubid-nist/lib/pubid/nist/stage.rb
archived-gems/pubid-nist/lib/pubid/nist/edition.rb
archived-gems/pubid-nist/lib/pubid/nist/version.rb
archived-gems/pubid-nist/lib/pubid/nist/update.rb
archived-gems/pubid-nist/lib/pubid/nist/publisher.rb
archived-gems/pubid-nist/lib/pubid/nist/series.rb
archived-gems/pubid-nist/stages.yaml
archived-gems/pubid-nist/update_codes.yaml
```

#### 1.2: Read All V1 Parsers (45 min)
```bash
# Read series-specific parsers
archived-gems/pubid-nist/lib/pubid/nist/parsers/default.rb
archived-gems/pubid-nist/lib/pubid/nist/parsers/sp.rb
archived-gems/pubid-nist/lib/pubid/nist/parsers/fips.rb
archived-gems/pubid-nist/lib/pubid/nist/parsers/hb.rb
archived-gems/pubid-nist/lib/pubid/nist/parsers/tn.rb
archived-gems/pubid-nist/lib/pubid/nist/parsers/gcr.rb
archived-gems/pubid-nist/lib/pubid/nist/parsers/nist_ir.rb
archived-gems/pubid-nist/lib/pubid/nist/parsers/circ.rb
archived-gems/pubid-nist/lib/pubid/nist/parsers/crpl.rb
archived-gems/pubid-nist/lib/pubid/nist/parsers/csm.rb
archived-gems/pubid-nist/lib/pubid/nist/parsers/rpt.rb
# ... all other parsers
```

#### 1.3: Read V1 Specs (45 min)
```bash
# Read test specifications
archived-gems/pubid-nist/spec/pubid_nist/identifier_spec.rb
archived-gems/pubid-nist/spec/pubid_nist/stage_spec.rb
archived-gems/pubid-nist/spec/pubid_nist/edition_spec.rb
# ... all other specs
```

#### 1.4: Document V1 Features (30 min)
Create `docs/NIST-V1-FEATURES.md` documenting:
- Stage system (id: i/f/1-9, type: pd/wd/prd)
- Edition system (year/month/day)
- Version system (dotted notation)
- Update system (update codes)
- Translation system (3-letter codes)
- Supplement system (separate from edition)
- Format system (mr/short/long/abbrev)
- All rendering formats

---

## Phase 2: V2 Component Architecture (2 hours)

### Objective
Create Lutaml::Model components for all V1 concepts with proper MODEL-DRIVEN architecture.

### Tasks

#### 2.1: Stage Component (30 min)
**File:** `lib/pubid_new/nist/components/stage.rb`

```ruby
# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Nist
    module Components
      # Stage component for NIST draft identifiers
      # Combines id (i/f/1-9) with type (pd/wd/prd)
      class Stage < Lutaml::Model::Serializable
        attribute :id, :string          # i, f, 1-9
        attribute :type, :string        # pd, wd, prd

        # Render in different formats
        def to_s(format = :short)
          case format
          when :short, :mr
            "#{id}#{type}"
          when :long
            "(#{id_long} #{type_long})"
          end
        end

        private

        def id_long
          STAGE_IDS[id] || id
        end

        def type_long
          STAGE_TYPES[type] || type
        end

        STAGE_IDS = {
          "i" => "Initial",
          "f" => "Final",
          "1" => "Initial",
          "2" => "Second",
          # ... from stages.yaml
        }.freeze

        STAGE_TYPES = {
          "pd" => "Public Draft",
          "wd" => "Work-in-Progress Draft",
          "prd" => "Preliminary Draft"
        }.freeze
      end
    end
  end
end
```

#### 2.2: Edition Component (20 min)
**File:** `lib/pubid_new/nist/components/edition.rb`

```ruby
class Edition < Lutaml::Model::Serializable
  attribute :number, :integer
  attribute :year, :integer
  attribute :month, :integer
  attribute :day, :integer

  def to_s(format = :short)
    # Implement V1 Edition rendering logic
  end
end
```

#### 2.3: Version Component (20 min)
**File:** `lib/pubid_new/nist/components/version.rb`

```ruby
class Version < Lutaml::Model::Serializable
  attribute :value, :string  # Dotted notation: "1.0.2"

  def to_s(format = :short)
    case format
    when :short
      "v#{value}"
    when :long
      "Version #{value}"
    when :mr
      "v#{value}"
    end
  end
end
```

#### 2.4: Update Component (20 min)
**File:** `lib/pubid_new/nist/components/update.rb`

```ruby
class Update < Lutaml::Model::Serializable
  attribute :number, :integer
  attribute :year, :integer

  def to_s(format = :short)
    # Implement V1 Update rendering logic
  end
end
```

#### 2.5: Translation Component (15 min)
**File:** `lib/pubid_new/nist/components/translation.rb`

```ruby
class Translation < Lutaml::Model::Serializable
  attribute :code, :string  # 3-letter code: slo, es, pt

  def to_s
    code
  end
end
```

#### 2.6: Format Tracking (15 min)
**Add to Base Identifier:**
```ruby
attribute :parsed_format, :symbol  # :mr, :short, :long
```

---

## Phase 3: Parser Migration (3 hours)

### Objective
Port all V1 parser patterns to V2 Parslet grammar with V2 architecture.

### Tasks

#### 3.1: Base Parser Structure (45 min)
**File:** `lib/pubid_new/nist/parser.rb`

Rewrite with V1 patterns:
- Stage patterns (id + type combinations)
- Translation patterns (3-letter codes)
- Supplement patterns (separate from edition)
- Format detection (MR vs others)
- All V1 part combinations

#### 3.2: Series-Specific Parsers (90 min)
Port V1 series parsers:
- SP (Special Publication) - most complex
- FIPS (Federal Information Processing Standards)
- HB (Handbook)
- TN (Technical Note)
- GCR (Grant/Contract Report)
- IR (Internal Report)
- Historical series (CIRC, CRPL, CSM, RPT)

#### 3.3: Format Detection (30 min)
Add logic to detect and track:
- Machine-readable format (NIST.SP.800-116)
- Short format (NIST SP 800-116)
- Long format (NIST Special Publication 800-116)

#### 3.4: Test Parser (15 min)
Test key patterns:
```ruby
# Stage
"NIST SP 800-160v1r1 fpd"
"NIST SP 800-66r2 ipd"
"NIST SP 800-140Cr1-draft2"

# Translation
"NIST SP 800-181r1 slo"
"NIST SP 800-181r1es"

# Supplement
"NIST SP 955 Suppl"

# Format
"NIST.SP.984.4"        # MR format
"NIST SP 984_4"        # Short format
```

---

## Phase 4: Builder & Identifier Updates (2 hours)

### Objective
Update Builder and Identifier classes to handle V2 components with V1 semantics.

### Tasks

#### 4.1: Builder Enhancement (60 min)
**File:** `lib/pubid_new/nist/builder.rb`

Add casting for:
- Stage (id + type)
- Edition (year/month/day)
- Version (dotted notation)
- Update (number/year)
- Translation (3-letter code)
- Format tracking

#### 4.2: Base Identifier (30 min)
**File:** `lib/pubid_new/nist/identifiers/base.rb`

Add attributes:
```ruby
attribute :stage, Components::Stage
attribute :edition, Components::Edition
attribute :version, Components::Version
attribute :update, Components::Update
attribute :translation, Components::Translation
attribute :supplement, :string
attribute :parsed_format, :symbol
```

#### 4.3: Rendering Methods (30 min)
Implement multiple to_s formats:
```ruby
def to_s(format = :short)
  case format
  when :short
    # NIST SP 800-160v1r1 fpd
  when :long
    # NIST Special Publication 800-160 Version 1 Revision 1 (Final Public Draft)
  when :mr
    # NIST.SP.800-160.v1r1-fpd
  when :abbrev
    # SP 800-160v1r1 fpd
  end
end
```

---

## Phase 5: V1 Spec Migration (2 hours)

### Objective
Port all V1 specs to V2 RSpec format and validate 100% compatibility.

### Tasks

#### 5.1: Core Component Specs (45 min)
Create spec files:
- `spec/pubid_new/nist/components/stage_spec.rb`
- `spec/pubid_new/nist/components/edition_spec.rb`
- `spec/pubid_new/nist/components/version_spec.rb`
- `spec/pubid_new/nist/components/update_spec.rb`

#### 5.2: Identifier Specs (60 min)
Port V1 identifier specs:
- Parse/render round-trip tests
- Format-specific tests
- Edge case tests
- All V1 test cases

#### 5.3: Series-Specific Specs (15 min)
Test each series type:
- SP, FIPS, HB, TN, GCR, IR
- Historical series

---

## Phase 6: Validation & Documentation (1 hour)

### Objective
Validate 100% V1 feature parity and update documentation.

### Tasks

#### 6.1: Fixture Validation (20 min)
```bash
cd spec/fixtures
ruby run_classify.rb nist
# Target: 100% pass rate
```

#### 6.2: Regression Testing (20 min)
Run all NIST specs:
```bash
bundle exec rspec spec/pubid_new/nist/
# Target: All passing
```

#### 6.3: Documentation Update (20 min)
Update:
- `README.adoc` - NIST section with V2 features
- `docs/PROJECT_STATUS.md` - Mark NIST 100% complete
- `docs/NIST_V2_ARCHITECTURE.md` - Document V2 implementation

---

## Implementation Status Tracker

### Phase 1: V1 Feature Documentation
- [ ] 1.1: Read Core V1 Files (30 min)
- [ ] 1.2: Read All V1 Parsers (45 min)
- [ ] 1.3: Read V1 Specs (45 min)
- [ ] 1.4: Document V1 Features (30 min)
- **Status:** Not Started
- **Estimated:** 2 hours

### Phase 2: V2 Component Architecture
- [ ] 2.1: Stage Component (30 min)
- [ ] 2.2: Edition Component (20 min)
- [ ] 2.3: Version Component (20 min)
- [ ] 2.4: Update Component (20 min)
- [ ] 2.5: Translation Component (15 min)
- [ ] 2.6: Format Tracking (15 min)
- **Status:** Not Started
- **Estimated:** 2 hours

### Phase 3: Parser Migration
- [ ] 3.1: Base Parser Structure (45 min)
- [ ] 3.2: Series-Specific Parsers (90 min)
- [ ] 3.3: Format Detection (30 min)
- [ ] 3.4: Test Parser (15 min)
- **Status:** Not Started
- **Estimated:** 3 hours

### Phase 4: Builder & Identifier Updates
- [ ] 4.1: Builder Enhancement (60 min)
- [ ] 4.2: Base Identifier (30 min)
- [ ] 4.3: Rendering Methods (30 min)
- **Status:** Not Started
- **Estimated:** 2 hours

### Phase 5: V1 Spec Migration
- [ ] 5.1: Core Component Specs (45 min)
- [ ] 5.2: Identifier Specs (60 min)
- [ ] 5.3: Series-Specific Specs (15 min)
- **Status:** Not Started
- **Estimated:** 2 hours

### Phase 6: Validation & Documentation
- [ ] 6.1: Fixture Validation (20 min)
- [ ] 6.2: Regression Testing (20 min)
- [ ] 6.3: Documentation Update (20 min)
- **Status:** Not Started
- **Estimated:** 1 hour

**Total Estimated Time:** 12 hours (compressed to 4-6 sessions)

---

## Success Criteria

### Minimum Success (90%)
- ✅ All V1 components ported to V2
- ✅ Stage system working (fpd, ipd, pd)
- ✅ Translation working (3-letter codes)
- ✅ Supplement working (separate attribute)
- ✅ Format tracking working
- ✅ 90% of V1 specs passing

### Target Success (95%)
- ✅ All above +
- ✅ Multiple render formats working
- ✅ All series parsers working
- ✅ 95% of V1 specs passing
- ✅ Fixture validation at 99%+

### Stretch Success (100%)
- ✅ All above +
- ✅ 100% V1 feature parity
- ✅ 100% V1 specs passing
- ✅ Fixture validation at 100%
- ✅ Complete documentation

---

## Key Architectural Principles

**MAINTAIN throughout:**
1. **MODEL-DRIVEN** - All concepts as Lutaml::Model components
2. **MECE** - Mutually exclusive, collectively exhaustive organization
3. **Three-layer** - Parser/Builder/Identifier independence
4. **V1 Compatibility** - 100% feature parity with V1
5. **Format Preservation** - Track and render in multiple formats
6. **Component Architecture** - Stage, Edition, Version, Update as components

---

## Critical V1 Features to Preserve

### 1. Stage System
```ruby
# V1 behavior
Pubid::Nist.parse("NIST SP 800-160v1r1 fpd")
# stage.id = "f", stage.type = "pd"
# Renders: "fpd" (short), "(Final Public Draft)" (long)
```

### 2. Translation
```ruby
# V1 behavior
Pubid::Nist.parse("NIST SP 800-181r1 slo")
# translation = "slo" (Slovakian)
```

### 3. Supplement
```ruby
# V1 behavior
Pubid::Nist.parse("NIST SP 955 Suppl")
# supplement = "" (present but no value)
```

### 4. Format Detection
```ruby
# V1 behavior
Pubid::Nist.parse("NIST.SP.984.4")
# parsed_format = :mr
# to_s(:mr) => "NIST.SP.984.4"
# to_s(:short) => "NIST SP 984 Part 4"
```

### 5. Multiple Rendering
```ruby
# V1 behavior
id = Pubid::Nist.parse("NIST SP 800-28 Version 2")
id.to_s(:short)  # => "NIST SP 800-28 Version 2"
id.to_s(:long)   # => "NIST Special Publication 800-28 Version 2"
id.to_s(:mr)     # => "NIST.SP.800-28.ver2"
id.to_s(:abbrev) # => "SP 800-28 Version 2"
```

---

## Files to Create

### Components
- `lib/pubid_new/nist/components/stage.rb`
- `lib/pubid_new/nist/components/edition.rb`
- `lib/pubid_new/nist/components/version.rb`
- `lib/pubid_new/nist/components/update.rb`
- `lib/pubid_new/nist/components/translation.rb`

### Specs
- `spec/pubid_new/nist/components/stage_spec.rb`
- `spec/pubid_new/nist/components/edition_spec.rb`
- `spec/pubid_new/nist/components/version_spec.rb`
- `spec/pubid_new/nist/components/update_spec.rb`

### Documentation
- `docs/NIST_V1_FEATURES.md`
- `docs/NIST_V2_ARCHITECTURE.md`

## Files to Modify

### Core
- `lib/pubid_new/nist/parser.rb` - Complete rewrite with V1 patterns
- `lib/pubid_new/nist/builder.rb` - Add V1 component casting
- `lib/pubid_new/nist/identifiers/base.rb` - Add V1 attributes
- `lib/pubid_new/nist/scheme.rb` - Update for V1 series

### Documentation
- `README.adoc` - Update NIST section
- `docs/PROJECT_STATUS.md` - Mark NIST migration complete

---

**Created:** 2025-12-22
**Status:** Ready to begin Phase 1
**Next Step:** Read and document all V1 features

**End Goal:** NIST with 100% V1 feature parity + V2 MODEL-DRIVEN architecture! 🎯