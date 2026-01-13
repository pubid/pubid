# PubID Architecture Document

## Executive Summary

PubID uses a **4-stage pipeline** for processing publication identifiers across all flavors (NIST, BSI, IEEE, ISO, etc.):

1. **Preprocessing** - Legacy case normalization, typo fixes, bad input salvage
2. **Parsing** - Syntax validation, lenient parsing, extracting structured components
3. **Building** - Transforming parsed data into MODEL-DRIVEN component objects
4. **Rendering** - Converting models back to string representations in various formats

---

## Stage 1: Preprocessing

### Purpose
Normalize input before parsing to handle legacy formats, common typos, and variations that shouldn't require parser complexity.

### Principles
- **Explicit over implicit**: Document each normalization rule clearly
- **Format preservation**: Maintain original format metadata when needed for round-trip fidelity
- **Progressive enhancement**: Start simple, add complexity incrementally

### Common Patterns

#### Case Normalization
```ruby
# Uppercase publisher codes
cleaned = cleaned.gsub(/\bnist\b/i, "NIST")
cleaned = cleaned.gsub(/\bbsi\b/i, "BSI")

# Lowercase version indicators
cleaned = cleaned.gsub(/\bVer\.\s+(\d+)/, 'ver\1')
```

#### Spacing Fixes
```ruby
# Fix spacing around revision markers
cleaned = cleaned.gsub(/(\d+)r([a-z]+)/i, '\1 r\2')  # 800-22r1a → 800-22 r1A

# Fix volume spacing: "80-2073 2" → "80-2073 v2"
cleaned = cleaned.gsub(/(\d+)\s+(\d)$/, '\1 v\2')
```

#### Legacy Format Conversion
```ruby
# NIST: Edition year normalization (-YYYY → eYYYY)
cleaned = cleaned.gsub(/(?<![eE])(\d(?:[A-DF-Z]?))-(\d{4})(?=\s|$)/, '\1e\2')
# Example: "330-2019" → "330e2019"

# Verbose revision format: "126 rev 2013" → "126r2013"
cleaned = cleaned.gsub(/(\d+)\s+rev\s+(\d{4})/, "\\1r\\2")
```

#### Update Pattern Normalization
```ruby
# Space before update markers
cleaned = cleaned.gsub(/([a-z]\d+)(-upd)/, '\1 \2')  # r1-upd → r1 -upd
cleaned = cleaned.gsub(/([a-z]\d+)(\/upd)/, '\1 \2')  # r1/upd → r1 /upd
```

#### Typo Fixes
```ruby
# Fix letter suffix case: "6529-a" → "6529-A"
cleaned = cleaned.gsub(/(\d)-([a-z])$/, '\1-' + $2.upcase)

# Fix pd spacing: "800-140Br1 2pd" → "800-140B r1 2pd"
cleaned = cleaned.gsub(/\s+(\d+)pd$/, ' \1 pd')
```

#### Format Detection
```ruby
# Detect format before parsing for round-trip fidelity
format = detect_format(input.to_s)  # Returns :short, :mr, :long, :abbrev
```

### Key Design Decisions

1. **Order matters**: More specific patterns must come before general patterns
   - Example: Fix `800-22r1a` before `800-22ra` patterns

2. **Avoid over-matching**: Use negative lookbehinds and lookahead constraints
   - Example: `(?<![eE])(\d)-(19\d{2})` avoids matching `e2-1915`

3. **Preserve format metadata**: Store original format for accurate round-tripping
   - Example: Update component stores `prefix` attribute ("dash" vs "slash")

---

## Stage 2: Parsing

### Purpose
Convert preprocessed string into structured hash of components using parser combinators (Parslet).

### Principles
- **Lenient parsing**: Accept variations that are semantically correct
- **Component extraction**: Identify and extract all meaningful components
- **Grammar clarity**: Parser rules should mirror the specification structure

### Parser Architecture

#### Main Grammar Structure
```ruby
rule(:identifier) do
  compound_series >> (space | dot) >> report_number >> components.repeat
end

rule(:components) do
  edition | date | version | update | stage | translation |
  volume | part | supplement | errata | addendum | language_code
end
```

#### Component-Specific Patterns

```ruby
# Edition: e2, r5, rev2013, -3
rule(:edition) do
  (str("e") >> digits.as(:edition_id)).as(:edition_e) |
  (str("r") >> digits.as(:edition_id)).as(:edition_r) |
  (str("rev") >> space.maybe >> digits.as(:edition_id)).as(:edition_rev) |
  (dash >> match("[1-9]").as(:edition_id) >> digit.absent?).as(:edition_historical)
end

# Update: /Upd1-202102, -upd1
rule(:update) do
  prefix = (str("/Upd") | (space.maybe >> (str("/upd") | str("-upd")))).as(:update_prefix)
  prefix >> digits.as(:update_number).maybe >>
    (dash >> match("[0-9]").repeat(4, 4).as(:update_year) >>
     match("[0-9]").repeat(2, 2).as(:update_month).maybe).maybe
end.as(:update)
end

# Version: v1.1, ver2.0, Ver. 2.0
rule(:version) do
  (str("v") >> space.maybe >> digits >> (dot >> digits).repeat(0, 2)) |
  (space.maybe >> str("ver") >> space.maybe >> digits >> (dot >> digits).repeat(0, 2)) |
  (space.maybe >> str("Ver.") >> space >> digits >> (dot >> digits).repeat(0, 2))
end.as(:version)
```

#### Number Patterns

```ruby
# First number with various suffixes
rule(:first_number) do
  # Special patterns first (most specific)
  str("ADHOC") |
  (str("div") >> digits) |
  (digits >> str("GB") >> dash >> digits >> upper_letter.maybe) |  # GB series
  (digits >> upper_letter >> dash >> digits) |  # CS: 102E-42
  (digits >> str("e") >> digits) |  # Edition suffix: 101e2
  (lower_letter >> digits) |  # CRPL: c4-4
  digits_with_suffix  # Generic
end.as(:first_number)

# Second number (after dash)
rule(:second_number) do
  month_abbrev.absent? >>
    str("draft").absent? >>
    (
      (digits >> upper_letter) |  # 56A
      str("NCMR") | str("PERMIS") |
      upper_letter.repeat(1, 3) |
      digits_with_suffix |
      (lower_letter >> digit.absent?)
    ).as(:second_number)
end
```

### Key Design Decisions

1. **Specificity ordering**: Most specific patterns first prevents mis-matching
   - Example: `ADHOC` before general letter patterns

2. **Exclusion constraints**: Use `.absent?` to prevent wrong matches
   - Example: `month_abbrev.absent?` prevents `-Feb1985` being matched as second_number

3. **Optional flexibility**: Use `space.maybe` for lenient spacing
   - Example: `space.maybe >> str("r") >> digits` accepts both "r5" and " r5"

---

## Stage 3: Building

### Purpose
Transform parsed hash into MODEL-DRIVEN objects using Lutaml::Model::Serializable components.

### Principles
- **MODEL-DRIVEN**: All components are proper objects, not strings
- **Single responsibility**: Each builder method handles one component type
- **Validation**: Enforce semantic rules during construction

### Builder Architecture

```ruby
class Builder
  def initialize(parsed_hash, publisher: nil, series: nil)
    @parsed_hash = parsed_hash
    @identifier_class = determine_identifier_class(publisher, series)
  end

  def build
    # Collect all components from parsed hash
    components = collect_components

    # Instantiate identifier with components
    @identifier_class.new(**components)
  end

  private

  def collect_components
    components = {}

    @parsed_hash.each do |key, value|
      result = cast_to_type(key, value)
      components.merge!(result) if result
    end

    components
  end
end
```

### Component Casting

```ruby
def cast_to_type(type, value)
  case type
  when :first_number, :second_number
    return nil if value.nil? || value.to_s.strip.empty?

    # Handle special patterns
    if type == :first_number
      # CS Emergency: e104 → 104
      if value.to_s =~ /^e(\d{3})$/ && !@parsed_hash[:second_number]
        return { first_number: Components::Code.new(number: $1) }
      end

      # Edition embedded in number: 11e2-1915 → number=11, edition=e2+year=1915
      if value.to_s =~ /^(\d+)e(\d+)$/
        return {
          first_number: Components::Code.new(number: $1),
          edition: Components::Edition.new(type: "e", id: $2)
        }
      end
    end

    { type => Components::Code.new(number: value.to_s) }

  when :edition
    return nil unless value.is_a?(Hash)

    edition_id = value[:edition_id]&.to_s
    type = case value.keys.first
           when :edition_e then "e"
           when :edition_r then "r"
           when :edition_rev then "r"
           when :edition_historical then "-"
           end

    { edition: Components::Edition.new(type: type, id: edition_id) }

  when :update
    return nil unless value.is_a?(Hash)

    number = value[:update_number]&.to_s
    year = value[:update_year]&.to_s
    month = value[:update_month]&.to_s

    # Detect prefix from original input
    prefix_str = value[:update_prefix]&.to_s
    prefix_value = prefix_str&.include?("-") ? "dash" : "slash"

    {
      update: Components::Update.new(number: number, year: year,
                                    month: month, prefix: prefix_value),
      update_component: Components::Update.new(number: number, year: year,
                                               month: month, prefix: prefix_value)
    }
  end
end
```

### Special Pattern Handling

```ruby
# Compound number building
def build_compound_number(first_num, second_num)
  # CS Emergency: e104-43 → number=104, edition=e1943
  if first_num.value.to_s.match?(/^e(\d{3})$/) &&
     second_num.value.to_s.match?(/^\d{2}$/)
    number_part = $1
    year_suffix = second_num.value.to_s
    edition_year = "19#{year_suffix}"

    identifier.number = Components::Code.new(number: number_part)
    identifier.edition = Components::Edition.new(type: "e", id: edition_year)
    return
  end

  # Edition with year: 11e2-1915 → number=11, edition=e2+year=1915
  if first_num.value.to_s.match?(/^(\d+)e(\d+)$/) &&
     second_num.value.to_s.match?(/^\d{4}$/)
    number_part = $1
    edition_id = $2
    year_part = second_num.value.to_s

    identifier.number = Components::Code.new(number: number_part)
    identifier.edition = Components::Edition.new(type: "e", id: edition_id,
                                                 additional_text: year_part)
  end

  # Normal compound number
  compound_value = "#{first_num.value}-#{second_num.value}"
  identifier.number = Components::Code.new(number: compound_value)
end
```

### Key Design Decisions

1. **Component objects over strings**: Always create proper component objects
   - Example: `Components::Update.new(number: "1", year: "2021")` instead of `"upd1-2021"`

2. **Dual attributes for migration**: Keep both legacy and V2 attributes
   - Example: Both `update` (string) and `update_component` (Update object)

3. **Pattern-specific handling**: Special patterns get dedicated code paths
   - Example: CS Emergency `e104-43` has specific builder logic

4. **Default values**: Provide sensible defaults for optional components
   - Example: Update defaults to `number: "1"` when empty

---

## Stage 4: Rendering

### Purpose
Convert MODEL-DRIVEN objects back to string representations in various formats.

### Principles
- **Format多样性**: Support multiple output formats (:short, :long, :abbrev, :mr)
- **Format preservation**: Use original format metadata for accurate round-trips
- **Component-based rendering**: Each component knows how to render itself

### Rendering Architecture

```ruby
class Base < Lutaml::Model::Serializable
  def to_s(format = nil)
    # Use stored format if no explicit format specified
    effective_format = format || parsed_format || :short
    effective_format = effective_format.to_sym if effective_format.is_a?(String)

    case effective_format
    when :full, :long
      to_full_style
    when :abbreviated, :abbrev
      to_abbreviated_style
    when :short
      to_short_style
    when :mr
      to_mr_style
    else
      to_short_style
    end
  end

  private

  def to_short_style
    result = build_base_identifier

    # Add components in specific order
    result += render_edition if edition
    result += render_version if version_component
    result += render_update if update_component
    result += render_stage if stage
    result += render_translation if translation_component

    result
  end
end
```

### Component Rendering

Each component implements its own `to_s(format)` method:

```ruby
class Edition < Lutaml::Model::Serializable
  attribute :type, :string    # "e", "r", "-"
  attribute :id, :string      # "2", "2019"
  attribute :additional_text, :string  # For edition+year patterns

  def to_s(format = :short)
    return "" unless id

    case format
    when :short
      # e2, e2019, r5, -3
      "#{type}#{id}#{additional_text ? '.' + additional_text : ''}"
    when :mr
      # Same as short for MR
      to_s(:short)
    when :long
      case type
      when "e" then "Edition #{id}"
      when "r" then "Revision #{id}"
      when "-" then "(#{id})"
      end
    when :abbrev
      case type
      when "e" then "Ed. #{id}"
      when "r" then "Rev. #{id}"
      when "-" then "(#{id})"
      end
    end
  end
end

class Update < Lutaml::Model::Serializable
  attribute :number, :string
  attribute :year, :string
  attribute :month, :string
  attribute :prefix, :string  # "dash" or "slash"

  def to_s(format = :short)
    return "" if number.nil?

    # Use prefix to preserve original format
    return build_dash_format if prefix == "dash"

    case format
    when :short
      build_short_format      # /Upd1-202102
    when :mr
      build_mr_format         # -upd1-202102
    when :long
      build_long_format       # Update 1-2021 February
    end
  end

  private

  def build_short_format
    if year
      "/Upd#{number}-#{year}#{month}"
    else
      "/Upd#{number}"
    end
  end
end
```

### Format-Specific Styles

```ruby
# Short: "NIST SP 800-53r5 ipd"
def to_short_style
  result = "NIST SP #{number}"
  result += "#{edition}" if edition           # r5
  result += " #{stage.to_s(:short)}" if stage # ipd
  result += "#{update_component.to_s(:short)}" if update_component
  result
end

# MR: "NIST.SP.800-53.r5.ipd"
def to_mr_style
  result = "NIST.SP.#{number}"
  result += ".#{edition.to_s}" if edition
  result += ".#{stage.to_s(:mr)}" if stage
  result
end

# Long: "National Institute of Standards and Technology Special Publication 800-53 Revision 5, Initial Public Draft"
def to_long_style
  result = "#{publisher_full_name} #{series_full_name} #{number}"
  result += " #{edition.to_s(:long)}" if edition
  result += ", #{stage.to_s(:long)}" if stage
  result
end

# Abbreviated: "Natl. Inst. Stand. Technol. Spec. Publ. 800-53 Rev. 5, ipd"
def to_abbreviated_style
  result = "#{publisher_abbreviated_name} #{series_abbreviated_name} #{number}"
  result += " #{edition.to_s(:abbrev)}" if edition
  result += ", #{stage.to_s(:abbrev)}" if stage
  result
end
```

### Series-Specific Customization

```ruby
class CommercialStandardEmergency < Base
  def to_short_style
    result = "NBS CS-E"
    result += " #{number.value}" if number
    result += "#{edition}" if edition  # e1943
    result
  end
end

class CrplReport < Base
  # Override number to normalize prefixes
  def number
    num = super()
    return num unless num

    num_value = num.value.to_s

    # c4-4 → 4-4 (hide 'c' prefix)
    num_value.sub!(/^c(\d+.*)$/, '\1')

    # 4-m-5 → 4-M-5 (uppercase 'm')
    num_value.gsub!(/-m-/, '-M-')

    Components::Code.new(number: num_value)
  end
end
```

### Key Design Decisions

1. **Component self-rendering**: Each component knows its format-specific rendering
   - Example: `Update.to_s(:short)` returns `/Upd1-202102`

2. **Format metadata preservation**: Use original format for accurate round-trips
   - Example: Update component stores `prefix` to distinguish `/Upd` from `-upd`

3. **Series-specific overrides**: Subclasses customize rendering for their patterns
   - Example: CrplReport normalizes prefixes in overridden `number` method

4. **Order matters**: Components render in specific order for correct output
   - Example: Stage after edition, translation at end

---

## Cross-Flavor Consistency

### Common Patterns Across Flavors

| Pattern | NIST | BSI | IEEE | ISO |
|---------|------|-----|------|-----|
| Edition | `e2`, `r5` | `(2)`, `r2` | `Rev2` | `2` |
| Stage | `ipd`, `pd` | `DP`, `FD` | `Draft` | `CD`, `DIS` |
| Update | `/Upd1-202102` | `A1` | `Cor1` | `amd1` |
| Translation | `spa` | `2` | `s` | `fr` |
| Supplement | `suppJan1924` | `No. 2` | `s1` | `+1` |

### Shared Architecture

All flavors use:
1. **Lutaml::Model::Serializable** for component objects
2. **Parslet** for parsing with similar grammar structure
3. **Builder** pattern for component assembly
4. **Multi-format rendering** with :short, :long, :abbrev, :mr

### Flavor-Specific Extensions

```ruby
# NIST: Stage component with stages like ipd, fpd, pd, prd
class Stage < Lutaml::Model::Serializable
  attribute :type, :string  # "ipd", "fpd", etc.
  attribute :iteration, :string  # "2" for 2pd
end

# BSI: Amendment component
class Amendment < Lutaml::Model::Serializable
  attribute :number, :string  # "1", "2"
  attribute :type, :string  # "A" (amendment)
end

# ISO: Harmonized stage code
class Stage < Lutaml::Model::Serializable
  attribute :code, :string  # "CD", "DIS", "FDIS"
  attribute :subcode, :string  # "1" for CD1
end
```

---

## Data Flow Example

### Input: `"NIST SP 800-53r5-upd1-202102 /ipd"`

#### Stage 1: Preprocessing
```ruby
cleaned = "NIST SP 800-53r5-upd1-202102 /ipd"
# No changes needed for this input
format = :short  # Detected
```

#### Stage 2: Parsing
```ruby
parsed_hash = {
  publisher: "NIST",
  series: "SP",
  number: "800-53r5",
  edition: { edition_e: { edition_id: "5" }, type: "r" },
  update: {
    update_prefix: "-upd",
    update_number: "1",
    update_year: "2021",
    update_month: "02"
  },
  stage: { type: "ipd" },
  translation: { language: "/" }
}
# Note: stage and translation confusion needs fixing
```

#### Stage 3: Building
```ruby
identifier = SpecialPublication.new(
  publisher: Components::Publisher.new("NIST"),
  series: Components::Code.new("SP"),
  number: Components::Code.new("800-53"),
  edition: Components::Edition.new(type: "r", id: "5"),
  update_component: Components::Update.new(
    number: "1",
    year: "2021",
    month: "02",
    prefix: "dash"
  ),
  stage: Components::Stage.new(type: "ipd")
)
```

#### Stage 4: Rendering
```ruby
identifier.to_s(:short)
# => "NIST SP 800-53r5-upd1-202102 ipd"

identifier.to_s(:mr)
# => "NIST.SP.800-53.r5-upd1-202102.ipd"

identifier.to_s(:long)
# => "National Institute of Standards and Technology Special Publication 800-53
#     Revision 5, Update 1-2021 February, Initial Public Draft"
```

---

## Design Principles Summary

1. **MODEL-DRIVEN FIRST**: Components are objects, not strings
2. **EXPLICIT OVER IMPLICIT**: Document every transformation
3. **FORMAT PRESERVATION**: Maintain original format metadata
4. **LENIENT PARSING**: Accept variations, normalize in preprocessing
5. **SINGLE RESPONSIBILITY**: Each stage/component has one job
6. **PROGRESSIVE ENHANCEMENT**: Start simple, add complexity incrementally
7. **MECE COMPONENTS**: Mutually Exclusive, Collectively Exhaustive
8. **ROUND-TRIP FIDELITY**: `parse(str).to_s == str` for correct parsing

---

## Testing Strategy

### Unit Tests (Per Component)
```ruby
RSpec.describe PubidNew::Nist::Components::Update do
  it "renders short format with slash prefix" do
    update = Update.new(number: "1", year: "2021", month: "02", prefix: "slash")
    expect(update.to_s(:short)).to eq("/Upd1-202102")
  end

  it "preserves dash prefix for round-trip" do
    update = Update.new(number: "1", prefix: "dash")
    expect(update.to_s(:short)).to eq("-upd1")
  end
end
```

### Integration Tests (Per Stage)
```ruby
RSpec.describe "NIST Preprocessing" do
  it "normalizes edition year pattern" do
    input = "NIST SP 330-2019"
    expected = "NIST SP 330e2019"
    # Verify preprocessing produces expected
  end
end

RSpec.describe "NIST Parsing" do
  it "parses revision with update" do
    parsed = Parser.new.parse("NIST SP 800-27r1-upd")
    expect(parsed[:edition]).to eq({ edition_r: { edition_id: "1" } })
    expect(parsed[:update]).to eq({ update_prefix: "-upd", update_number: "1" })
  end
end

RSpec.describe "NIST Building" do
  it "creates Update component with default number" do
    parsed = { update: { update_prefix: "-upd" } }
    builder = Builder.new(parsed)
    update = builder.send(:cast_to_type, :update, parsed[:update])
    expect(update[:update_component].number).to eq("1")
  end
end
```

### End-to-End Tests (Per Flavor)
```ruby
RSpec.describe "NIST Round-trip Fidelity" do
  it "maintains format through parse-serialize-parse cycle" do
    original = "NIST SP 800-53r5"
    first = PubidNew::Nist.parse(original)
    serialized = first.to_s
    second = PubidNew::Nist.parse(serialized)
    expect(serialized).to eq(original)
    expect(second.to_s).to eq(original)
  end
end
```

---

## Common Pitfalls and Solutions

### Pitfall 1: Over-matching in Preprocessing
**Problem**: Generic replacements break valid patterns
```ruby
# BAD: Converts ALL -YYYY to eYYYY
cleaned = cleaned.gsub(/-(\d{4})/, 'e\1')  # Breaks 800-53r5-2015
```

**Solution**: Use constraints and lookbehinds
```ruby
# GOOD: Only converts when not preceded by edition marker
cleaned = cleaned.gsub(/(?<![eE])(\d)-(19\d{2})(?=\s|$)/, '\1e\2')
```

### Pitfall 2: String-Based Components
**Problem**: Using strings instead of component objects
```ruby
# BAD: update is just a string
identifier.update = "/Upd1-202102"
```

**Solution**: Always use component objects
```ruby
# GOOD: update is a proper object
identifier.update_component = Update.new(number: "1", year: "2021", month: "02")
```

### Pitfall 3: Lost Format Metadata
**Problem**: Can't round-trip because original format was lost
```ruby
# BAD: Both /Upd and -upd render the same
def to_s(format)
  "/Upd#{number}"  # Loses dash format
end
```

**Solution**: Store format metadata
```ruby
# GOOD: Store prefix attribute
class Update < Lutaml::Model::Serializable
  attribute :prefix, :string  # "dash" or "slash"

  def to_s(format)
    return "-upd#{number}" if prefix == "dash"
    "/Upd#{number}"  # Default
  end
end
```

### Pitfall 4: Component Order in Rendering
**Problem**: Wrong order produces invalid output
```ruby
# BAD: Stage before edition
result += " #{stage}" if stage
result += "#{edition}" if edition  # "NIST SP 800-53ipdr5" (wrong)
```

**Solution**: Follow specification order
```ruby
# GOOD: Edition before stage
result += "#{edition}" if edition
result += " #{stage}" if stage  # "NIST SP 800-53r5 ipd" (correct)
```

---

## Future Enhancements

1. **Validation Framework**: Add semantic validation rules to components
   - Example: Edition month must be 01-12
   - Example: Year must be reasonable (1900-2099)

2. **Format Auto-Detection**: Improve format detection from input
   - Currently: Simple heuristic based on dots
   - Future: Machine learning model for format classification

3. **Cross-Flavor Conversion**: Convert between flavors
   - Example: ISO `EN ISO 9001:2015` → BSI `BS EN ISO 9001:2015`

4. **Performance Optimization**: Cache compiled grammars
   - Preprocessing: O(n) where n is input length
   - Parsing: O(n) with Parslet combinators
   - Building: O(m) where m is number of components
   - Rendering: O(m) with component iteration

---

## References

- Lutaml::Model: `https://github.com/lutaml/lutaml-model`
- Parslet: `https://github.com/kschiess/parslet`
- NIST Publications: `https://nvlpubs.nist.gov/nistpubs/`
- BSI Publications: `https://www.bsigroup.com/`
- IEEE Standards: `https://standards.ieee.org/`
- ISO Standards: `https://www.iso.org/`
