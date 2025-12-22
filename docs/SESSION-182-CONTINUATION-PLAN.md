# Session 182+ Continuation Plan: NIST V2 Migration - Phases 2-6

**Created:** 2025-12-22 (Post-Session 181)
**Status:** Phase 1 Complete - Ready for Phases 2-6
**Timeline:** COMPRESSED - Complete in 3-4 sessions (6-8 hours total)
**Priority:** CRITICAL - Restore NIST to 100% V1 feature parity

---

## Session 181 Completion Summary

**Phase 1 COMPLETE:** V1 Feature Documentation ✅

**Deliverable:** [`docs/NIST_V1_FEATURES.md`](NIST_V1_FEATURES.md:1) - 500+ line comprehensive documentation

**Key V1 Features Documented:**
1. ✅ Stage System (id + type → "fpd", "ipd", "2pd")
2. ✅ Translation (3-letter codes: slo, spa, por, ind)
3. ✅ Supplement (separate from edition)
4. ✅ Format Tracking (short, long, abbrev, mr)
5. ✅ Edition (year/month/day combinations)
6. ✅ Version (dotted notation ver1.0.2)
7. ✅ Update (/Upd1-YYYYMM format)
8. ✅ Two-stage parsing (series → series-specific)
9. ✅ Multi-format rendering
10. ✅ Update codes (93 normalization rules)

---

## Remaining Phases (COMPRESSED)

### PHASE 2: V2 Component Architecture (Session 182 - 90 min)

**Objective:** Create all Lutaml::Model components for V1 concepts

**Components to Create (5 files):**

#### 2.1: Stage Component (25 min)
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

        # Load from YAML
        STAGES = YAML.load_file(
          File.join(File.dirname(__FILE__), "../../../../archived-gems/pubid-nist/stages.yaml")
        ).freeze

        def to_s(format = :short)
          case format
          when :short, :mr
            "#{id}#{type}"
          when :long
            "(#{STAGES['id'][id]} #{STAGES['type'][type]})"
          else
            "#{id}#{type}"
          end
        end
      end
    end
  end
end
```

**Test:** Create `spec/pubid_new/nist/components/stage_spec.rb` with V1 parity tests

---

#### 2.2: Edition Component (20 min)
**File:** `lib/pubid_new/nist/components/edition.rb`

```ruby
class Edition < Lutaml::Model::Serializable
  attribute :number, :integer
  attribute :year, :integer
  attribute :month, :integer
  attribute :day, :integer

  def to_s(format = :short)
    case format
    when :short, :mr
      build_short_format
    when :long
      build_long_format
    else
      build_short_format
    end
  end

  private

  def build_short_format
    result = number ? [number.to_s] : []
    if day
      result << Date.new(year, month, day).strftime("%Y%m%d")
    elsif month
      result << Date.new(year, month).strftime("%Y%m")
    elsif year
      result << Date.new(year).strftime("%Y")
    end
    result.join("-")
  end

  def build_long_format
    result = number ? ["Edition #{number}"] : []
    if day
      result << Date.new(year, month, day).strftime("(%B %d, %Y)")
    elsif month
      result << Date.new(year, month).strftime("(%B %Y)")
    elsif year
      result << Date.new(year).strftime("(%Y)")
    end
    result.join(" ")
  end
end
```

---

#### 2.3: Version Component (15 min)
**File:** `lib/pubid_new/nist/components/version.rb`

```ruby
class Version < Lutaml::Model::Serializable
  attribute :value, :string  # Dotted notation: "1.0.2"

  def to_s(format = :short)
    case format
    when :short, :mr
      "ver#{value}"
    when :long
      "Version #{value}"
    else
      "ver#{value}"
    end
  end
end
```

---

#### 2.4: Update Component (15 min)
**File:** `lib/pubid_new/nist/components/update.rb`

```ruby
class Update < Lutaml::Model::Serializable
  attribute :number, :integer
  attribute :year, :integer
  attribute :month, :integer

  def to_s(format = :short)
    case format
    when :short
      year_month = [year, month].compact.join("")
      "/Upd#{number}-#{year_month}"
    when :mr
      year_month = [year, month].compact.join("")
      ".u#{number}-#{year_month}"
    when :long
      month_str = month ? " #{Date::MONTHNAMES[month]}" : ""
      "Update #{number}-#{year}#{month_str}"
    end
  end
end
```

---

#### 2.5: Translation Component (15 min)
**File:** `lib/pubid_new/nist/components/translation.rb`

```ruby
class Translation < Lutaml::Model::Serializable
  attribute :code, :string  # 3-letter code: slo, es, pt

  def to_s(format = :short)
    case format
    when :short
      " #{code}"
    when :mr
      ".#{code}"
    else
      " #{code}"
    end
  end
end
```

---

### PHASE 3: Parser Migration (Session 182-183 - 150 min)

**Objective:** Port V1 Parslet grammar to V2 with all V1 patterns

#### 3.1: Base Parser Enhancement (60 min)
**File:** `lib/pubid_new/nist/parser.rb`

**Key patterns to add:**
```ruby
# Stage patterns (both old and new style)
rule(:old_stage) do
  str("(") >> 
  (stage_id.as(:id) >> stage_type.as(:type)).as(:stage) >> 
  str(")")
end

rule(:stage) do
  (space | dot) >> 
  (stage_id.as(:id) >> stage_type.as(:type)).as(:stage)
end

# Translation patterns
rule(:translation) do
  (str("(") >> match('\w').repeat(3, 3).as(:translation) >> str(")")) |
  ((str(".") | space) >> match('\w').repeat(3, 3).as(:translation))
end

# Supplement patterns (separate from edition!)
rule(:supplement) do
  (str("supp") | str("sup")) >> match('[A-Z\d]').repeat.as(:supplement)
end

# Version patterns
rule(:version) do
  (str("ver") | str(" Ver. ") | str(" Version ")) >> 
  (digits >> (str(".") >> digits).repeat).as(:version)
end

# Update patterns
rule(:update) do
  (str("/Upd") | str("/upd") | str("-upd")) >> 
  (digits.as(:number) >> 
   (str("-") >> year_digits.as(:year) >> 
    (digits.repeat(2, 2).as(:month)).maybe).maybe
  ).as(:update)
end

# Edition patterns (complex - year/month/day combinations)
rule(:edition) do
  # e-prefix with year
  (str("e") >> year_digits.as(:edition_year) >> 
   (month_digits.as(:edition_month) >> 
    (day_digits.as(:edition_day)).maybe).maybe) |
  # dash-year (for certain series)
  (str("-") >> year_digits.as(:edition_year)) |
  # month-year
  (str("-") >> month_letters.as(:edition_month) >> year_digits.as(:edition_year)) |
  # edition number
  (str("e") >> digits.as(:edition))
end
```

**Two-stage parsing (preserve V1 architecture):**
```ruby
def parse(code)
  # Stage 1: Detect series and publisher
  result = series_parser.parse(code)
  series = result[:series]
  publisher = result[:publisher]
  
  # Stage 2: Use series-specific parser
  parser_class = find_parser_class(publisher, series)
  begin
    parser_class.new.parse(result[:remaining].to_s)
  rescue Parslet::ParseFailed
    # Fallback to default parser
    Parsers::Default.new.parse(result[:remaining].to_s)
  end
end
```

---

#### 3.2: Series-Specific Parsers (60 min)
**Files to create:**
- `lib/pubid_new/nist/parsers/default.rb` - Base parser
- `lib/pubid_new/nist/parsers/sp.rb` - Special Publication (most complex)
- `lib/pubid_new/nist/parsers/fips.rb` - FIPS series

**SP Parser specifics:**
```ruby
# SP handles: version dotted notation, revision letters, complex part numbers
rule(:version) do
  ((str("ver") | str(" Ver. ") | str(" Version ")) >> 
   (digits >> str(".") >> digits >> (str(".") >> digits).maybe).as(:version)) |
  (str("v") >> 
   (match('\d') >> str(".") >> match('\d') >> (str(".") >> match('\d')).maybe).as(:version))
end

rule(:revision) do
  ((str(" rev ") | str("rev") | str("r") | str(" Rev. ")) >> 
   (digits >> match("[a-z]").maybe).as(:revision)) |
  (str("-") >> digits.as(:revision)) |
  (str("r") >> match("[a-z]").as(:revision))
end
```

---

#### 3.3: Format Detection (30 min)
**Add to parser:**
```ruby
def detect_format(input)
  if input.include?(".")
    :mr  # Machine-readable: NIST.SP.800-53r5
  else
    :short  # Default: NIST SP 800-53r5
  end
end

# Store in parsed result
def parse(code)
  format = detect_format(code)
  result = super(code)
  result.merge(parsed_format: format)
end
```

---

### PHASE 4: Builder & Identifier Updates (Session 183 - 90 min)

#### 4.1: Builder Enhancement (45 min)
**File:** `lib/pubid_new/nist/builder.rb`

**Add component casting:**
```ruby
def cast(type, value)
  case type
  when :stage
    Components::Stage.new(id: value[:id].to_s, type: value[:type].to_s)
    
  when :edition_year, :edition_month, :edition_day
    # Accumulate edition parts
    edition_parts = extract_edition_parts(parsed_hash)
    Components::Edition.new(**edition_parts) if edition_parts.any?
    
  when :version
    Components::Version.new(value: value.to_s)
    
  when :update
    Components::Update.new(
      number: value[:number]&.to_i || 1,
      year: value[:year]&.to_i,
      month: value[:month]&.to_i
    )
    
  when :translation
    Components::Translation.new(code: normalize_translation(value.to_s))
    
  # ... other types
  end
end

def normalize_translation(code)
  # Apply transformation rules from update_codes.yaml
  # es → spa, pt → por, id → ind, etc.
  TRANSLATION_MAP[code] || code
end
```

---

#### 4.2: Base Identifier (30 min)
**File:** `lib/pubid_new/nist/identifiers/base.rb`

**Add V1 attributes:**
```ruby
class Base < Lutaml::Model::Serializable
  attribute :publisher, Components::Publisher
  attribute :series, Components::Series
  attribute :code, Components::Code
  attribute :stage, Components::Stage
  attribute :edition, Components::Edition
  attribute :version, Components::Version
  attribute :update, Components::Update
  attribute :translation, Components::Translation
  attribute :supplement, :string  # Plain string, not component
  attribute :revision, :string
  attribute :volume, :string
  attribute :part, :string
  attribute :errata, :string
  attribute :index, :string
  attribute :insert, :string
  attribute :section, :string
  attribute :appendix, :string
  attribute :parsed_format, :symbol  # :mr, :short, :long
end
```

---

#### 4.3: Rendering Methods (15 min)
**Add to Base Identifier:**
```ruby
def to_s(format = :short, without_edition: false)
  parts = []
  
  # Publisher and Series
  parts << publisher.to_s(format)
  parts << series.to_s(format)
  
  # Number
  parts << code.value
  
  # Revision, Volume, Part, Version (order matters!)
  parts << "pt#{part}" if part
  parts << "r#{revision}" if revision
  parts << "v#{volume}" if volume
  parts << version.to_s(format) if version
  
  # Edition (unless excluded)
  unless without_edition
    parts << "e#{edition.to_s(format)}" if edition
  end
  
  # Supplement
  parts << "sup#{supplement}" if supplement
  
  # Update
  parts << update.to_s(format) if update
  
  # Stage (at end)
  parts << stage.to_s(format) if stage
  
  # Translation (last)
  parts << translation.to_s(format) if translation
  
  # Join with appropriate separator
  separator = format == :mr ? "." : " "
  parts.join(separator)
end
```

---

### PHASE 5: V1 Spec Migration (Session 184 - 90 min)

**Objective:** Port V1 specs to V2, ensure 100% feature parity

#### Task 5.1: Component Specs (30 min)
Create 5 spec files testing V1 behavior:
- `spec/pubid_new/nist/components/stage_spec.rb`
- `spec/pubid_new/nist/components/edition_spec.rb`
- `spec/pubid_new/nist/components/version_spec.rb`
- `spec/pubid_new/nist/components/update_spec.rb`
- `spec/pubid_new/nist/components/translation_spec.rb`

#### Task 5.2: Identifier Specs (45 min)
Port key V1 specs:
- Stage rendering (ipd, fpd, 2pd)
- Translation (spa, por, ind)
- Edition formats (year, year+month, year+month+day)
- Update formatting
- Multi-format rendering (short, long, abbrev, mr)
- Round-trip parsing

#### Task 5.3: Integration Tests (15 min)
Test V1 examples from documented features:
```ruby
# Stage
"NIST SP 800-53r5 ipd"
"NIST.SP.800-66r2.ipd"

# Translation
"NIST SP 1262es" → "NIST SP 1262 spa"
"NIST SP 800-189 IPD spa"

# Update
"NIST SP 800-53r4/Upd3-2015"
"NIST AMS 300-8r1 (February 2021 update)" → "/Upd1-202102"
```

---

### PHASE 6: Validation & Documentation (Session 184 - 60 min)

#### Task 6.1: Fixture Validation (25 min)
```bash
# Run against V1 fixtures
cd spec/fixtures
ruby run_classify.rb nist

# Target: 100% or near-perfect
```

#### Task 6.2: Update Documentation (25 min)
**Update README.adoc NIST section:**
```asciidoc
==== NIST (National Institute of Standards and Technology)
- Status: ✅ 19,432/19,432 (100%)
- Features: Complete V2 with full V1 feature parity
- Architecture: MODEL-DRIVEN with Lutaml::Model components

**V2 Features:**
- Stage system (ipd, fpd, 2pd with id+type)
- Translation (3-letter codes slo, spa, por, ind)
- Supplement (separate from edition)
- Format tracking (short, long, abbrev, mr)
- Edition (year/month/day)
- Version (dotted notation)
- Update (/Upd1-YYYYMM)
- Multiple render formats
```

#### Task 6.3: Archive Old Docs (10 min)
```bash
mkdir -p docs/old-docs/nist/
mv docs/SESSION-181-NIST-V1-TO-V2-MIGRATION-PLAN.md docs/old-docs/nist/
mv docs/SESSION-181-CONTINUATION-PROMPT.md docs/old-docs/nist/
```

---

## Implementation Status Tracker

### Phase 1: V1 Feature Documentation ✅
- [x] Read V1 core files
- [x] Read V1 parsers
- [x] Read V1 specs
- [x] Create NIST_V1_FEATURES.md
- **Status:** COMPLETE

### Phase 2: V2 Component Architecture (Session 182)
- [ ] Stage component (25 min)
- [ ] Edition component (20 min)
- [ ] Version component (15 min)
- [ ] Update component (15 min)
- [ ] Translation component (15 min)
- **Status:** Ready to begin

### Phase 3: Parser Migration (Sessions 182-183)
- [ ] Base parser (60 min)
- [ ] Series-specific parsers (60 min)
- [ ] Format detection (30 min)
- **Status:** Ready after Phase 2

### Phase 4: Builder & Identifier (Session 183)
- [ ] Builder enhancement (45 min)
- [ ] Base identifier (30 min)
- [ ] Rendering methods (15 min)
- **Status:** Ready after Phase 3

### Phase 5: V1 Spec Migration (Session 184)
- [ ] Component specs (30 min)
- [ ] Identifier specs (45 min)
- [ ] Integration tests (15 min)
- **Status:** Ready after Phase 4

### Phase 6: Validation & Documentation (Session 184)
- [ ] Fixture validation (25 min)
- [ ] Update documentation (25 min)
- [ ] Archive old docs (10 min)
- **Status:** Ready after Phase 5

**Total Remaining Time:** 6-8 hours (3-4 sessions)

---

## Success Criteria

### Minimum (90%)
- ✅ All V1 components ported
- ✅ Stage system working
- ✅ Translation working
- ✅ Supplement separate
- ✅ Format tracking working
- ✅ 90% V1 specs passing

### Target (95%)
- ✅ All above +
- ✅ Multiple render formats
- ✅ All series parsers
- ✅ 95% V1 specs passing
- ✅ 99%+ fixture validation

### Stretch (100%)
- ✅ 100% V1 feature parity
- ✅ 100% V1 specs passing
- ✅ 100% fixture validation
- ✅ Complete documentation

---

## Key Architectural Principles

**NEVER COMPROMISE:**
1. **MODEL-DRIVEN** - All concepts as Lutaml::Model
2. **MECE** - Mutually exclusive, collectively exhaustive
3. **Three-layer** - Parser/Builder/Identifier independence
4. **V1 Compatibility** - 100% feature parity required
5. **Format Preservation** - Track and render 4 formats
6. **Component Architecture** - Proper object orientation

---

**Created:** 2025-12-22
**Sessions:** 182-184 (compressed)
**Status:** Phase 1 complete, ready for Phases 2-6
**Timeline:** 6-8 hours total (COMPRESSED)

**End Goal:** NIST with 100% V1 parity + V2 MODEL-DRIVEN architecture! 🎯