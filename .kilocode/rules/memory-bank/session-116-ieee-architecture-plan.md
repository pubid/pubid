# Session 116+: IEEE Complete Architecture Implementation

**Created:** 2025-12-11
**Status:** Ready for implementation
**Estimated Total Time:** 10-11 hours (can be split across multiple sessions)
**Priority:** HIGH - Critical architectural improvement

## Important IEEE information

In IEEE, we have to distinguish between "approved/unapproved draft" and "approved standards".

Look at this reply from "PG" (IEEE staff):

1. What does “Active” mean in an identifier?

"IEEE Active Unapproved Draft Std IEEE PC37.06/D8.3, July 2007”

Is the canonical form of this just:
"IEEE Unapproved Draft IEEE PC37.06/D8.3, July 2007”

PG==> Active means there has not been anything to supercede it, as in a second draft or the published standard.

2. What does “Approved Draft Std” mean? Is it different from “Approved Std” (but with a D number)?

e.g.

IEEE Approved Draft Std P1234 / D12, Feb 2007
IEEE Approved Draft Std P277/D2 - Mar 2007
IEEE Approved Draft Std P48/ D5.4, Apr 2009
IEEE Approved Std P1512.4/rev44, Sep 2006
IEEE Approved Std P1609.3/D23, Feb 2007
IEEE Approved Std P277D1/Jan 2007

PG==> The approved draft is the one that was approved by the standards board but has not yet been published. They should not include Std.

3. The big question. What is the canonical format for a document identifier that is an IEEE draft but with an ISO/IEC stage?

There is a dilemma here because ISO/IEC identifiers do not use the “P” prefix for drafts. But IEEE identifiers do not use ISO/IEC stages.

e.g.

ISO/IEC/IEEE P26511.2_FDIS 2018
=> In the ISO format, it would be “ISO/IEC/IEEE FDIS 26511:2018” (they don’t have a way to express P and the “FDIS for 2nd edition”)
=> In the IEEE format, it would be “ISO/IEC/IEEE P26511/Dx-2018” where X is a number that we don’t know

IEEE Unapproved Draft Std P16326:2008/CD2, Sep 2008
=> In the ISO format, it would be “ISO/IEC/IEEE CD2 16326:2008” (I had to search to find out the correct prefix, and ISO does not have a way to express P)
=> In the IEEE format, it would be “ISO/IEC/IEEE P26511/Dx-2008” where X is a number that we don’t know

PG==> That really depends on if it's a joint development (and who's publishing it) or if it's an adoption (and by whom). So the answer seems to be that they should be treated differently. If that doesn't make sense, I might have to refer you to somebody else.

Document this in the plan to handle.


How about we adopt the Typed Stage concept from ISO?

We also have to handle IEEE codeveloped standards with ISO and IEC and ISO/IEC, where the documents can be Draft P ("P" is for "Project", a published standard no longer has a "project", only for drafts), and the draft document can be both assigned an ISO/IEC draft typed stage (e.g. "CD", "DIS") and also an IEEE Draft P number (approved draft, unapproved draft). How do we handle in an architectually clean and sound manner? There is no equivalnece of draft stages, an ISO/IEC CD is not the same as an IEEE Unapproved Draft P and can be in any order.

SO:
* IEEE has drafts of stages (numbered "Pxxx", means Project xxx which is a draft): Unapproved Draft, Approved Draft ("Approved Draft Std" is wrong as said by PG), "Approved Std"
* IEEE published documents with no prefix

---

## Executive Summary

Implement complete IEEE architecture with:
1. **TYPED_STAGE pattern** IEEE has various draft stages and published standards
2. **Historical sub-flavors** (AIEE, IRE) for frozen legacy patterns
3. **Joint development** identifiers for ISO/IEC/IEEE collaboration
4. **Bidirectional format conversion** (IEEE ↔ ISO representation)

**Current Status:** IEEE at 84.76% (8,084/9,537) after Session 115 improvements
**Target:** 92-95% with complete architecture

---

## Session 115 Achievements (Completed)

✅ **IEEE Parser Enhanced: 44% → 84.76%** (+40.76pp improvement)
- Added number-first identifier patterns
- Added IEEE P draft patterns
- Added IEEE Draft P patterns
- Added IEEE Approved Draft patterns

**Files Modified:**
- `lib/pubid_new/ieee/parser.rb` - Enhanced with 4 new identifier patterns

---

## Architecture Foundation: TYPED_STAGE Pattern

### Concept (Proven from ISO/IEC/CEN/BSI)

**TYPED_STAGE = Type + Stage in single domain object**

Benefits:
- ✅ Single source of truth (no scattered conditionals)
- ✅ MECE organization (mutually exclusive, collectively exhaustive)
- ✅ Extensible (add stages via registry, not code changes)
- ✅ Bidirectional conversion (IEEE ↔ ISO formats)

### IEEE-Specific Requirements

1. **IEEE Stages:**
   - Draft stages: D1-D9 (Working Draft → Final Draft)
   - Approval status: Unapproved, Approved, Published
   - Project indicator: "P" prefix for drafts only

2. **ISO Stages (for joint development):**
   - PWI, NP, WD, CD, DIS, FDIS
   - No "P" prefix
   - Different rendering format

3. **Equivalence Mapping:**
   - THERE IS NO EQUIVALENCE MAPPING, Anything with "P" is IEEE draft

4. **Historical patterns:**
   - AIEE "No" / "No." patterns ("AIEE No 18-1934" is still a standard)
   - IRE numbering patterns
   - Legacy formats

---

## Implementation Plan (Detailed)

### PHASE 1: TYPED_STAGE Foundation (3-4 hours)

#### Task 1.1: Create TypedStage Component (1 hour)

**File:** `lib/pubid_new/ieee/components/typed_stage.rb`

**Implementation:**
```ruby
# frozen_string_literal: true

require "lutaml/model"

module PubidNew
  module Ieee
    module Components
      # TypedStage combines type and stage information
      # Following ISO/IEC proven pattern
      class TypedStage < Lutaml::Model::Serializable
        # All recognized abbreviations for this stage
        attribute :abbr, :string, collection: true

        # IEEE-specific stage code
        attribute :stage_code, :string

        # Document type code
        attribute :type_code, :string

        # ISO stage equivalent (for joint development)
        attribute :iso_stage_equivalent, :string

        # IEEE draft notation equivalent
        attribute :ieee_draft_equivalent, :string

        # Approval status: "unapproved" | "approved" | "published"
        attribute :approval_status, :string

        # Whether "P" (Project) prefix applies
        attribute :project_status, :boolean, default: -> { false }

        # Convert to IEEE format representation
        def to_ieee_format
          return abbr.first unless project_status
          ieee_draft_equivalent || "P"
        end

        # Convert to ISO format representation
        def to_iso_format
          iso_stage_equivalent || abbr.first
        end

        # Get canonical abbreviation (first in list)
        def canonical_abbreviation
          abbr.first
        end

        # Check if this is a draft stage
        def draft?
          project_status || approval_status != "published"
        end

        # Check if board-approved
        def approved?
          approval_status == "approved" || approval_status == "published"
        end
      end
    end
  end
end
```

**Testing:** Create `spec/pubid_new/ieee/components/typed_stage_spec.rb`

---

#### Task 1.2: Create TYPED_STAGES Registry (1.5 hours)

**File:** `lib/pubid_new/ieee/typed_stages.rb`

**Implementation:**
```ruby
# frozen_string_literal: true

require_relative "components/typed_stage"

module PubidNew
  module Ieee
    # Registry of all IEEE typed stages
    # Single source of truth for stage/type combinations
    TYPED_STAGES = [
      # Published Standards (no P prefix)
      Components::TypedStage.new(
        abbr: ["Std"],
        stage_code: "published",
        type_code: "standard",
        approval_status: "published",
        project_status: false
      ),

      # IEEE Draft Stages (P prefix, unapproved)
      Components::TypedStage.new(
        abbr: ["D1"],
        stage_code: "working_draft",
        type_code: "draft",
        ieee_draft_equivalent: "D1",
        iso_stage_equivalent: "WD",
        approval_status: "unapproved",
        project_status: true
      ),

      Components::TypedStage.new(
        abbr: ["D2", "D3"],
        stage_code: "committee_draft",
        type_code: "draft",
        ieee_draft_equivalent: "D2-D3",
        iso_stage_equivalent: "CD",
        approval_status: "unapproved",
        project_status: true
      ),

      Components::TypedStage.new(
        abbr: ["D4", "D5", "D6"],
        stage_code: "draft_standard",
        type_code: "draft",
        ieee_draft_equivalent: "D4-D6",
        iso_stage_equivalent: "DIS",
        approval_status: "unapproved",
        project_status: true
      ),

      # IEEE Draft Stages (P prefix, approved but unpublished)
      Components::TypedStage.new(
        abbr: ["D7", "D8", "D9"],
        stage_code: "final_draft",
        type_code: "draft",
        ieee_draft_equivalent: "D7-D9",
        iso_stage_equivalent: "FDIS",
        approval_status: "approved",
        project_status: true
      ),

      # ISO Stages (for joint development)
      Components::TypedStage.new(
        abbr: ["PWI"],
        stage_code: "preliminary",
        type_code: "draft",
        ieee_draft_equivalent: "P",
        iso_stage_equivalent: "PWI",
        approval_status: "unapproved",
        project_status: true
      ),

      Components::TypedStage.new(
        abbr: ["NP"],
        stage_code: "new_proposal",
        type_code: "draft",
        ieee_draft_equivalent: "P",
        iso_stage_equivalent: "NP",
        approval_status: "unapproved",
        project_status: true
      ),

      Components::TypedStage.new(
        abbr: ["WD"],
        stage_code: "working_draft",
        type_code: "draft",
        ieee_draft_equivalent: "D1",
        iso_stage_equivalent: "WD",
        approval_status: "unapproved",
        project_status: true
      ),

      Components::TypedStage.new(
        abbr: ["CD", "CD2", "CD3"],
        stage_code: "committee_draft",
        type_code: "draft",
        ieee_draft_equivalent: "D2-D3",
        iso_stage_equivalent: "CD",
        approval_status: "unapproved",
        project_status: true
      ),

      Components::TypedStage.new(
        abbr: ["DIS"],
        stage_code: "draft_international_standard",
        type_code: "draft",
        ieee_draft_equivalent: "D5",
        iso_stage_equivalent: "DIS",
        approval_status: "unapproved",
        project_status: true
      ),

      Components::TypedStage.new(
        abbr: ["FDIS"],
        stage_code: "final_draft",
        type_code: "draft",
        ieee_draft_equivalent: "D8",
        iso_stage_equivalent: "FDIS",
        approval_status: "approved",
        project_status: true
      ),

      # Historical stages
      Components::TypedStage.new(
        abbr: ["No", "No."],
        stage_code: "published",
        type_code: "standard",
        approval_status: "published",
        project_status: false
      )
    ].freeze

    # Default typed stage for published standards
    DEFAULT_TYPED_STAGE = TYPED_STAGES.first
  end
end
```

---

#### Task 1.3: Create or Update Scheme (0.5 hours)

**File:** `lib/pubid_new/ieee/scheme.rb` (create if doesn't exist)

**Implementation:**
```ruby
# frozen_string_literal: true

require_relative "typed_stages"

module PubidNew
  module Ieee
    # Scheme provides registry access for IEEE identifiers
    class Scheme
      # Locate typed stage by abbreviation
      def self.locate_typed_stage_by_abbr(abbr)
        return DEFAULT_TYPED_STAGE if abbr.nil? || abbr.empty?

        TYPED_STAGES.find { |ts| ts.abbr.include?(abbr) } ||
          DEFAULT_TYPED_STAGE
      end

      # Locate typed stage by IEEE draft notation
      def self.locate_typed_stage_by_ieee_draft(draft)
        TYPED_STAGES.find { |ts| ts.ieee_draft_equivalent == draft } ||
          TYPED_STAGES.find { |ts| ts.abbr.include?(draft) }
      end

      # Locate typed stage by ISO stage code
      def self.locate_typed_stage_by_iso_stage(stage)
        TYPED_STAGES.find { |ts| ts.iso_stage_equivalent == stage }
      end

      # Locate identifier class by type code
      def self.locate_identifier_klass_by_type_code(type_code)
        case type_code
        when "draft"
          require_relative "identifiers/draft_standard"
          Identifiers::DraftStandard
        when "standard"
          require_relative "identifiers/base"
          Identifiers::Base
        else
          require_relative "identifiers/base"
          Identifiers::Base
        end
      end
    end
  end
end
```

---

#### Task 1.4: Create JointDevelopment Identifier (1 hour)

**File:** `lib/pubid_new/ieee/identifiers/joint_development.rb`

**Implementation:**
```ruby
# frozen_string_literal: true

require_relative "base"

module PubidNew
  module Ieee
    module Identifiers
      # Handles ISO/IEC/IEEE joint development identifiers
      # Supports bidirectional format conversion
      class JointDevelopment < Base
        attribute :publishers, :string, collection: true
        attribute :code, :string
        attribute :typed_stage, Components::TypedStage
        attribute :year, :string
        attribute :rendering_format, :string, default: -> { "ieee" }

        def to_s
          case rendering_format
          when "iso"
            to_iso_format
          when "ieee"
            to_ieee_format
          else
            to_ieee_format
          end
        end

        private

        def to_iso_format
          # ISO/IEC/IEEE FDIS 26511:2018
          parts = []
          parts << publishers.join("/")
          parts << typed_stage.to_iso_format
          parts << code.gsub(/^P/, "")  # Remove P prefix
          "#{parts.join(" ")}:#{year}"
        end

        def to_ieee_format
          # ISO/IEC/IEEE P26511/D8-2018
          parts = []
          parts << publishers.join("/")

          code_part = code.gsub(/^P/, "")
          code_part = "P#{code_part}" if typed_stage.project_status

          if typed_stage.ieee_draft_equivalent
            code_part += "/#{typed_stage.ieee_draft_equivalent}"
          end

          parts << code_part
          "#{parts.join(" ")}-#{year}"
        end
      end
    end
  end
end
```

---

### PHASE 2: Update Existing Identifiers (2 hours)

#### Task 2.1: Update Base Identifier for TypedStage (1 hour)

**File:** `lib/pubid_new/ieee/identifiers/base.rb`

**Changes:**
1. Add `typed_stage` attribute
2. Deprecate separate `type` attribute (keep for backwards compatibility)
3. Update `to_s` to use `typed_stage` when present
4. Add migration helpers

**Implementation notes:**
- Keep existing attributes for backwards compatibility
- Use typed_stage when available
- Fall back to legacy attributes if typed_stage not set

---

#### Task 2.2: Update Parser & Builder (1 hour)

**Parser changes** (`lib/pubid_new/ieee/parser.rb`):
- Capture ISO stage codes (PWI, NP, WD, CD, DIS, FDIS)
- Capture IEEE draft notation separately
- Detect joint development patterns

**Builder changes** (`lib/pubid_new/ieee/builder.rb`):
- Use Scheme to locate typed_stage
- Create appropriate identifier class based on typed_stage
- Handle joint development detection

---

### PHASE 3: Historical Sub-Flavors (3 hours)

#### Task 3.1: AIEE Sub-Flavor (1.5 hours)

**Directory:** `lib/pubid_new/ieee/historical/aiee/`

**Files to create:**
1. `parser.rb` - AIEE-specific patterns
2. `identifier.rb` - AIEE identifier class
3. `typed_stages.rb` - AIEE stage registry

**Patterns to handle:**
- `AIEE No 18-1934`
- `AIEE No 18-1934 (ASA C55 1934)` - Joint with ASA
- `AIEE No 22-1952 (Supercedes AIEE No. 22-1942 and 22A-1949)`
- `AIEE No 431 (105) -1958`

**Key attributes:**
- ieee_equivalent: IEEE Std equivalent number
- joint_asa: ASA collaboration identifier (if applicable)
- supersedes: Previous AIEE standards

---

#### Task 3.2: IRE Sub-Flavor (1 hour)

**Directory:** `lib/pubid_new/ieee/historical/ire/`

**Files to create:**
1. `parser.rb` - IRE-specific patterns
2. `identifier.rb` - IRE identifier class

**Patterns to handle:**
- `52 IRE 7.S2`
- `55 IRE 2.S1 (IEEE Std No 147)`
- `61 IRE 15.S1 (IEEE 182)`
- `62 IRE 12.S1 (IEEE 174)`

**Key attributes:**
- number: Leading number
- series: IRE series code
- sub_series: Sub-series designation (e.g., "S1", "S2")
- ieee_equivalent: IEEE Std equivalent

---

#### Task 3.3: Integration with Main IEEE (0.5 hours)

**File:** `lib/pubid_new/ieee/identifiers/historical_equivalent.rb`

**Implementation:**
```ruby
class HistoricalEquivalent < Base
  attribute :historical_identifier, Base  # AIEE or IRE
  attribute :ieee_equivalent, Base        # Modern IEEE equivalent

  def to_s
    result = historical_identifier.to_s
    result += " (#{ieee_equivalent})" if ieee_equivalent
    result
  end
end
```

**Update IEEE parser to route historical patterns:**
- Detect "AIEE No" → route to AIEE parser
- Detect "IRE" pattern → route to IRE parser
- Wrap result in HistoricalEquivalent

---

### PHASE 4: Testing & Documentation (2 hours)

#### Task 4.1: Comprehensive Testing (1.5 hours)

**Test files to create/update:**
1. `spec/pubid_new/ieee/components/typed_stage_spec.rb`
2. `spec/pubid_new/ieee/identifiers/joint_development_spec.rb`
3. `spec/pubid_new/ieee/identifiers/historical_equivalent_spec.rb`
4. `spec/pubid_new/ieee/historical/aiee/identifier_spec.rb`
5. `spec/pubid_new/ieee/historical/ire/identifier_spec.rb`

**Test coverage:**
- All typed_stage combinations
- Bidirectional IEEE ↔ ISO conversion
- Round-trip parsing
- Historical pattern recognition
- Edge cases from real data

#### Task 4.2: Update Documentation (0.5 hours)

**Files to update:**
- `README.adoc` - Add IEEE architecture notes
- `docs/V2_ARCHITECTURE.adoc` - Document TYPED_STAGE pattern
- Create `docs/IEEE_ARCHITECTURE.md` - Detailed IEEE guide

**Content:**
- TYPED_STAGE pattern explanation
- Joint development handling
- Historical sub-flavors
- Bidirectional conversion examples
- Equivalence mappings

---

## Implementation Status Tracker

### Phase 1: TYPED_STAGE Foundation
- [ ] 1.1 TypedStage component (1h)
- [ ] 1.2 TYPED_STAGES registry (1.5h)
- [ ] 1.3 Scheme class (0.5h)
- [ ] 1.4 JointDevelopment identifier (1h)

### Phase 2: Update Existing
- [ ] 2.1 Base identifier (1h)
- [ ] 2.2 Parser & Builder (1h)

### Phase 3: Historical Sub-Flavors
- [ ] 3.1 AIEE sub-flavor (1.5h)
- [ ] 3.2 IRE sub-flavor (1h)
- [ ] 3.3 Integration (0.5h)

### Phase 4: Testing & Documentation
- [ ] 4.1 Comprehensive testing (1.5h)
- [ ] 4.2 Update documentation (0.5h)

**Total Estimated Time:** 10-11 hours

---

## Success Criteria

### Architecture Quality
✅ TYPED_STAGE pattern implemented (same as ISO/IEC/CEN/BSI)
✅ MECE organization maintained throughout
✅ Single source of truth for all stage/type combinations
✅ Clean bidirectional IEEE ↔ ISO conversion
✅ Historical patterns isolated in sub-flavors

### Functionality
✅ AIEE patterns: 100% coverage (frozen legacy)
✅ IRE patterns: 100% coverage (frozen legacy)
✅ Joint development identifiers working
✅ Draft status correctly distinguished (Unapproved/Approved/Published)
✅ IEEE accuracy: 92-95% (from current 84.76%)

### Code Quality
✅ No hardcoded stage/type logic
✅ Extensible via registry
✅ Comprehensive test coverage
✅ Clear documentation

---

## Session Breakdown Recommendation

**Session 116 (3-4 hours):** Phase 1 - TYPED_STAGE Foundation
- Complete all TypedStage infrastructure
- Test bidirectional conversion
- Validate with joint development examples

**Session 117 (2 hours):** Phase 2 - Update Existing
- Integrate TYPED_STAGE into current code
- Update parser and builder
- Ensure backwards compatibility

**Session 118 (3 hours):** Phase 3 - Historical Sub-Flavors
- Implement AIEE and IRE sub-flavors
- Test with historical patterns
- Integration with main IEEE

**Session 119 (2 hours):** Phase 4 - Testing & Documentation
- Comprehensive test suite
- Full validation with real data
- Complete documentation

**Alternatively:** Can be compressed into 2-3 longer sessions if needed

---

## Critical Architecture Principles

**MUST MAINTAIN:**
1. MODEL-DRIVEN - Objects not strings
2. MECE - Mutually exclusive, collectively exhaustive
3. Three-layer - Parser/Builder/Identifier independence
4. Non-destructive - Source data never modified
5. TYPED_STAGE pattern - Single source of truth
6. Backwards compatible - Don't break existing code

**NO COMPROMISES on architecture quality.**

---

## Files to Create

### New Files
1. `lib/pubid_new/ieee/components/typed_stage.rb`
2. `lib/pubid_new/ieee/typed_stages.rb`
3. `lib/pubid_new/ieee/scheme.rb`
4. `lib/pubid_new/ieee/identifiers/joint_development.rb`
5. `lib/pubid_new/ieee/identifiers/historical_equivalent.rb`
6. `lib/pubid_new/ieee/historical/aiee/parser.rb`
7. `lib/pubid_new/ieee/historical/aiee/identifier.rb`
8. `lib/pubid_new/ieee/historical/ire/parser.rb`
9. `lib/pubid_new/ieee/historical/ire/identifier.rb`
10. `docs/IEEE_ARCHITECTURE.md`

### Files to Modify
1. `lib/pubid_new/ieee/identifiers/base.rb`
2. `lib/pubid_new/ieee/parser.rb`
3. `lib/pubid_new/ieee/builder.rb`
4. `README.adoc`
5. `docs/V2_ARCHITECTURE.adoc`
6. `docs/PROJECT_STATUS.md`

---

## Next Immediate Steps

1. Read this plan thoroughly
2. Start with Phase 1, Task 1.1 (TypedStage component)
3. Test each component before moving to next
4. Validate architecture at each step
5. Update documentation as you go

**Ready to begin Phase 1!**
